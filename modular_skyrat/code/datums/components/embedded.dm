/*
	This component is responsible for handling individual instances of embedded objects. The embeddable element is what allows an item to be embeddable and stores its embedding stats,
	and when it impacts and meets the requirements to stick into something, it instantiates an embedded component. Once the item falls out, the component is destroyed, while the
	element survives to embed another day.

		- Carbon embedding has all the classical embedding behavior, and tracks more events and signals. The main behaviors and hooks to look for are:
			-- Every process tick, there is a chance to randomly proc pain, controlled by pain_chance. There may also be a chance for the object to fall out randomly, per fall_chance
			-- Every time the mob moves, there is a chance to proc jostling pain, controlled by jostle_chance (and only 50% as likely if the mob is walking or crawling)
			-- Various signals hooking into carbon topic() and the embed removal surgery in order to handle removals.


	In addition, there are 2 cases of embedding: embedding, and sticking

		- Embedding involves harmful and dangerous embeds, whether they cause brute damage, stamina damage, or a mix. This is the default behavior for embeddings, for when something is "pointy"

		- Sticking occurs when an item should not cause any harm while embedding (imagine throwing a sticky ball of tape at someone, rather than a shuriken). An item is considered "sticky"
			when it has 0 for both pain multiplier and jostle pain multiplier. It's a bit arbitrary, but fairly straightforward.

		Stickables differ from embeds in the following ways:
			-- Text descriptors use phrasing like "X is stuck to Y" rather than "X is embedded in Y"
			-- There is no slicing sound on impact
			-- All damage checks and bloodloss are skipped

*/


/datum/component/embedded
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/datum/injury/injury
	var/obj/item/bodypart/limb
	var/obj/item/weapon

	// all of this stuff is explained in _DEFINES/combat.dm
	var/embed_chance // not like we really need it once we're already stuck in but hey
	var/fall_chance
	var/pain_chance
	var/pain_mult
	var/impact_pain_mult
	var/remove_pain_mult
	var/rip_time
	var/ignore_throwspeed_threshold
	var/jostle_chance
	var/jostle_pain_mult
	var/pain_stam_pct

	///if both our pain multiplier and jostle pain multiplier are 0, we're harmless and can omit most of the damage related stuff
	var/harmful

/datum/component/embedded/Initialize(obj/item/I,
			datum/thrownthing/throwingdatum,
			obj/item/bodypart/part,
			embed_chance = EMBED_CHANCE,
			fall_chance = EMBEDDED_ITEM_FALLOUT,
			pain_chance = EMBEDDED_PAIN_CHANCE,
			pain_mult = EMBEDDED_PAIN_MULTIPLIER,
			remove_pain_mult = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER,
			impact_pain_mult = EMBEDDED_IMPACT_PAIN_MULTIPLIER,
			rip_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
			ignore_throwspeed_threshold = FALSE,
			jostle_chance = EMBEDDED_JOSTLE_CHANCE,
			jostle_pain_mult = EMBEDDED_JOSTLE_PAIN_MULTIPLIER,
			pain_stam_pct = EMBEDDED_PAIN_STAM_PCT,
			datum/injury/supplied_injury)

	if(!iscarbon(parent) || !isitem(I))
		return COMPONENT_INCOMPATIBLE

	if(part)
		limb = part
		if(limb.limb_flags & BODYPART_NOEMBED)
			return COMPONENT_INCOMPATIBLE
	src.embed_chance = embed_chance
	src.fall_chance = fall_chance
	src.pain_chance = pain_chance
	src.pain_mult = pain_mult
	src.remove_pain_mult = remove_pain_mult
	src.rip_time = rip_time
	src.impact_pain_mult = impact_pain_mult
	src.ignore_throwspeed_threshold = ignore_throwspeed_threshold
	src.jostle_chance = jostle_chance
	src.jostle_pain_mult = jostle_pain_mult
	src.pain_stam_pct = pain_stam_pct
	src.injury = supplied_injury
	src.weapon = I

	if(!weapon.isEmbedHarmless())
		harmful = TRUE

	weapon.embedded(parent)
	if(supplied_injury)
		LAZYADD(supplied_injury.embedded_objects, I)
		LAZYADD(supplied_injury.embedded_components, src)
	START_PROCESSING(SSdcs, src)
	var/mob/living/carbon/victim = parent

	limb.embedded_objects |= weapon // on the inside... on the inside...
	weapon.forceMove(victim)
	RegisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING), .proc/weaponDeleted)
	victim.recent_embeds[weapon] = "[limb.name]"
	if(victim.embed_timer)
		deltimer(victim.embed_timer)
		victim.embed_timer = null
	victim.embed_timer = addtimer(CALLBACK(src, .proc/embedding_message, victim), EMBED_WAIT_TIME, TIMER_STOPPABLE)

	var/damage = weapon.throwforce
	if(harmful)
		victim.throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
		playsound(victim,'sound/weapons/bladeslice.ogg', 40)
		weapon.add_mob_blood(victim)//it embedded itself in you, of course it's bloody!
		damage += weapon.w_class * impact_pain_mult
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "embedded", /datum/mood_event/embedded)
	if(damage > 0)
		var/armor = victim.run_armor_check(limb.body_zone, "melee", "Your armor has protected your [limb.name].", "Your armor has softened the hit to your [limb.name].",I.armour_penetration)
		if(injury)
			injury.open_injury((1-pain_stam_pct) * damage)
		limb.receive_damage(pain = pain_stam_pct * damage, blocked = armor)

/datum/component/embedded/Destroy()
	var/mob/living/carbon/victim = parent
	if(victim && !victim.has_embedded_objects())
		victim.clear_alert("embeddedobject")
		SEND_SIGNAL(victim, COMSIG_CLEAR_MOOD_EVENT, "embedded")
	if(weapon)
		UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	weapon = null
	limb = null
	injury = null
	return ..()

/datum/component/embedded/proc/embedding_message(mob/living/victim)
	if(!length(victim?.recent_embeds))
		return FALSE
	
	var/is_harmful = harmful
	if(length(victim.recent_embeds) == 1)
		for(var/obj/item/weapon in victim.recent_embeds)
			victim.visible_message("<span class='danger'>[weapon] [is_harmful ? "embeds" : "sticks"] itself [is_harmful ? "in" : "to"] [victim]'s [limb.name]!</span>",\
								"<span class='userdanger'>[weapon] [is_harmful ? "embeds" : "sticks"] itself [is_harmful ? "in" : "to"] your [limb.name]!</span>")
	else
		var/list/counter = list()
		var/list/messages = list()
		var/list/bodyparts = list()
		var/weapon = ""
		var/bodypart = ""
		for(var/obj/item/wpn in victim.recent_embeds)
			if(counter[wpn.name])
				counter[wpn.name]++
			else
				counter[wpn.name] = 1
			if(!wpn.isEmbedHarmless())
				is_harmful = TRUE
			bodyparts |= victim.recent_embeds[wpn]
		
		for(var/i in counter)
			messages |= "[counter[i] > 1 ? "[counter[i]] [i]" : "\the [i]"]"
		weapon = messages.Join(", ", 1, length(messages) - 1)
		if(length(messages) > 1)
			weapon += " and [messages[length(messages)]]"
		
		bodypart = bodyparts.Join(", ", 1, length(bodyparts) - 1)
		if(length(bodyparts) > 1)
			bodypart += " and [bodyparts[length(bodyparts)]]"
		
		victim.visible_message("<span class='danger'>[weapon] [is_harmful ? "embed" : "stick"] themselves [is_harmful ? "in" : "to"] [victim]'s [bodypart]!</span>",\
				"<span class='userdanger'>[weapon] [is_harmful ? "embed" : "stick"] themselves [harmful ? "in" : "to"] your [bodypart]!</span>")
	clearlist(victim.recent_embeds)

/datum/component/embedded/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/jostleCheck)
	RegisterSignal(parent, COMSIG_CARBON_EMBED_RIP, .proc/ripOut)
	RegisterSignal(parent, COMSIG_CARBON_EMBED_REMOVAL, .proc/safeRemove)

/datum/component/embedded/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_EMBED_RIP, COMSIG_CARBON_EMBED_REMOVAL))

/datum/component/embedded/process()
	var/mob/living/carbon/victim = parent

	if(!victim || !limb) // in case the victim and/or their limbs exploded (say, due to a sticky bomb)
		weapon.forceMove(get_turf(weapon))
		qdel(src)
		return

	if(victim.stat == DEAD)
		return

	var/damage = weapon.w_class * pain_mult
	var/pain_chance_current = pain_chance
	if(pain_stam_pct && (victim.IsKnockdown() || victim.InCritical() || victim.incapacitated())) //if it's a less-lethal embed, give them a break if they're already stamcritted
		pain_chance_current *= 0.2
		damage *= 0.5
	else if(victim.mobility_flags & ~MOBILITY_STAND)
		pain_chance_current *= 0.2

	if(harmful && prob(pain_chance_current))
		limb.receive_damage(pain = (1-pain_stam_pct) * damage, stamina = pain_stam_pct * damage, wound_bonus = CANT_WOUND)
		to_chat(victim, "<span class='userdanger'>[weapon] embedded in your [limb.name] hurts!</span>")

	var/fall_chance_current = fall_chance
	if(victim.mobility_flags & ~MOBILITY_STAND)
		fall_chance_current *= 0.2

	if(prob(fall_chance_current))
		fallOut()

////////////////////////////////////////
////////////BEHAVIOR PROCS//////////////
////////////////////////////////////////


/// Called every time a carbon with a harmful embed moves, rolling a chance for the item to cause pain. The chance is halved if the carbon is crawling or walking.
/datum/component/embedded/proc/jostleCheck()
	var/mob/living/carbon/victim = parent
	var/chance = jostle_chance
	if(victim.m_intent == MOVE_INTENT_WALK || !(victim.mobility_flags & MOBILITY_STAND))
		chance *= 0.5

	if(harmful && prob(chance))
		var/damage = weapon.w_class * jostle_pain_mult
		injury.open_injury((1-pain_stam_pct) * damage)
		limb.receive_damage(pain=pain_stam_pct * damage)
		to_chat(victim, "<span class='userdanger'>[weapon] embedded in your [limb.name] jostles and stings!</span>")

/// Called when then item randomly falls out of a carbon. This handles the damage and descriptors, then calls safe_remove()
/datum/component/embedded/proc/fallOut()
	var/mob/living/carbon/victim = parent

	if(harmful)
		var/damage = weapon.w_class * remove_pain_mult
		limb.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage, sharpness=SHARP_EDGED) // can wound

	victim.visible_message("<span class='danger'>[weapon] falls [harmful ? "out" : "off"] of [victim.name]'s [limb.name]!</span>", "<span class='userdanger'>[weapon] falls [harmful ? "out" : "off"] of your [limb.name]!</span>")
	safeRemove(parent)

/// Called when a carbon with an object embedded/stuck to them inspects themselves and clicks the appropriate link to begin ripping the item out. This handles the ripping attempt, descriptors, and dealing damage, then calls safe_remove()
/datum/component/embedded/proc/ripOut(datum/source, obj/item/I, obj/item/bodypart/limb, mob/living/user)
	if(I != weapon || src.limb != limb || !istype(user))
		return

	var/mob/living/carbon/victim = parent
	var/time_taken = rip_time * weapon.w_class
	victim.visible_message("<span class='warning'>[user] attempts to remove [weapon] from [user == victim ? victim.p_their() : "[victim]'s"] [limb.name].</span>","<span class='notice'>You attempt to remove [weapon] from [user == victim ? "your" : "[victim]'s"] [limb.name]... (It will take [DisplayTimeText(time_taken)].)</span>")

	if(!do_mob(user, victim, time_taken))
		return
	
	if(!weapon || !limb || weapon.loc != victim || !(weapon in limb.embedded_objects))
		qdel(src)
		return

	if(harmful)
		var/damage = weapon.w_class * remove_pain_mult
		injury.open_injury((1-pain_stam_pct) * damage)
		limb.receive_damage(pain=pain_stam_pct * damage) //It hurts to rip it out, get surgery you dingus.
		victim.agony_scream()

	victim.visible_message("<span class='notice'>[user] successfully rips [weapon] [harmful ? "out" : "off"] of [user == victim ? victim.p_their() : "[victim]'s"] [limb.name]!</span>", "<span class='notice'>You successfully remove [weapon] from [user == victim ? "your" : "[victim]'s"] [limb.name].</span>")
	safeRemove(parent, TRUE, hand_override = (istype(user) ? user : null))

/// This proc handles the final step and actual removal of an embedded/stuck item from a carbon, whether or not it was actually removed safely.
/// Pass TRUE for to_hands if we want it to go to the victim's hands when they pull it out
/datum/component/embedded/proc/safeRemove(datum/source, to_hands = FALSE, mob/hand_override)
	var/mob/living/carbon/victim = parent
	limb.embedded_objects -= weapon
	if(injury)
		LAZYREMOVE(injury.embedded_objects, weapon)
		LAZYREMOVE(injury.embedded_components, src)

	UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING)) // have to do it here otherwise we trigger weaponDeleted()
	if(!weapon.unembedded()) // if it hasn't deleted itself due to drop del
		UnregisterSignal(weapon, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
		if(to_hands)
			if(hand_override)
				hand_override.put_in_hands(weapon)
			else
				victim.put_in_hands(weapon)
		else
			weapon.forceMove(get_turf(victim))

	SEND_SIGNAL(weapon, COMSIG_ITEM_ON_EMBED_REMOVAL, limb)
	qdel(src)

/// Something deleted or moved our weapon while it was embedded, how rude!
/datum/component/embedded/proc/weaponDeleted()
	var/mob/living/carbon/victim = parent
	limb.embedded_objects -= weapon

	if(victim)
		to_chat(victim, "<span class='userdanger'>\The [weapon] that was embedded in your [limb.name] disappears!</span>")

	qdel(src)

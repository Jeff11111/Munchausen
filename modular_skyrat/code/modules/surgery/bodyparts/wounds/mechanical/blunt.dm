// "Bones"
/datum/wound/mechanical/blunt
	sound_effect = 'sound/effects/clang1.ogg'
	a_or_from = "from"
	wound_type = WOUND_LIST_BLUNT_MECHANICAL
	treatable_by = list(/obj/item/stack/sticky_tape, /obj/item/reagent_containers)

	/// Have we been taped?
	var/taped
	/// Have we been wrenched?
	var/wrenched
	/// If we did the tape + slurry healing method for "fractures", how many regen points we need
	var/regen_points_needed
	/// Our current counter for wrench + slurry regeneration
	var/regen_points_current
	/// If we suffer severe head booboos, we can get brain traumas tied to them
	var/datum/brain_trauma/active_trauma
	/// What brain trauma group, if any, we can draw from for head wounds
	var/brain_trauma_group
	/// If we deal brain traumas, when is the next one due?
	var/next_trauma_cycle
	/// How long do we wait +/- 20% for the next trauma?
	var/trauma_cycle_cooldown
	/// Chance to shock and stun the owner when hit
	var/shock_chance = 0

	base_treat_time = 5 SECONDS
	biology_required = list(HAS_BONE)
	wound_flags = (WOUND_SOUND_HINTS | WOUND_SEEPS_GAUZE | WOUND_VISIBLE_THROUGH_CLOTHING | WOUND_MANGLES_BONE)
	required_status = BODYPART_ROBOTIC
	pain_amount = 10

/*
	Overwriting of base procs
*/

/datum/wound/mechanical/blunt/Destroy()
	. = ..()
	if(active_trauma)
		QDEL_NULL(active_trauma)

/datum/wound/mechanical/blunt/should_disable_limb(obj/item/bodypart/affected)
	. = ..()
	if(.)
		return TRUE
	if(severity >= WOUND_SEVERITY_SEVERE && affected && (!affected.current_gauze || affected.current_gauze.splint_factor > 0.4))
		return TRUE

/datum/wound/mechanical/blunt/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited)
	. = ..()
	if(L.body_zone == BODY_ZONE_HEAD && brain_trauma_group)
		processes = TRUE
		active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	RegisterSignal(victim, COMSIG_MOVABLE_MOVED, .proc/jostle_bone)
	RegisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/attack_with_hurt_hand)
	if(L.held_index && victim.get_item_for_held_index(L.held_index) && (disabling || prob(30 * severity)))
		var/obj/item/I = victim.get_item_for_held_index(L.held_index)
		if(istype(I, /obj/item/offhand))
			I = victim.get_inactive_held_item()

		if(I && victim.dropItemToGround(I))
			victim.visible_message("<span class='danger'><b>[victim]</b> drops [I] in shock!</span>", "<span class='userdanger'>The force on my [L.name] causes me to drop [I]!</span>", vision_distance=COMBAT_MESSAGE_RANGE)

	update_inefficiencies()

/// Jostling
/datum/wound/mechanical/blunt/proc/jostle_bone(mob/living/carbon/source)
	if(source.stat < UNCONSCIOUS && limb.disabled && prob(4 * (severity - WOUND_SEVERITY_MODERATE)) && source.can_feel_pain() && limb.get_organs() && (source.chem_effects[CE_PAINKILLER] < 50))
		source.custom_pain("Pain jolts through your broken [limb.encased ? limb.encased : limb.name], staggering you!", 40, affecting = limb)
		source.Stumble(4 SECONDS)
		if(limb.body_zone in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH))
			source.Rapehead(8 SECONDS)
		source.Stun(3 SECONDS)
		limb.damage_organs(brute = rand(3, 5), wounding_type = WOUND_PIERCE)
		sound_hint(source, source)

/datum/wound/mechanical/blunt/remove_wound(ignore_limb, replaced)
	limp_slowdown = 0
	QDEL_NULL(active_trauma)
	if(victim)
		UnregisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
	return ..()

/datum/wound/mechanical/blunt/handle_process()
	. = ..()
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group && world.time > next_trauma_cycle)
		if(active_trauma)
			QDEL_NULL(active_trauma)
		else
			active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	if(!regen_points_needed)
		return

	regen_points_current++
	if(prob(severity * 3))
		victim.custom_pain("I feel a sharp pain on my [limb] as my bones reform!", \
					max(1, severity - WOUND_SEVERITY_TRIVIAL) * 15, affecting = limb)
		
	if(regen_points_current > regen_points_needed)
		if(!victim || !limb)
			qdel(src)
			return
		to_chat(victim, "<span class='green'>My [limb.name] has recovered from the bending!</span>")
		remove_wound()

/// If we're a synth who's punching something with a broken arm, we might hurt ourselves doing so
/datum/wound/mechanical/proc/attack_with_hurt_hand(mob/M, atom/target, proximity)
	if(victim.get_active_hand() != limb || victim.a_intent == INTENT_HELP || !ismob(target) || severity <= WOUND_SEVERITY_MODERATE)
		return

	// With a severe or critical wound, you have a 15% or 30% chance to proc pain on hit
	if(prob((severity - 1) * 15))
		// And you have a 70% or 50% chance to actually land the blow, respectively
		if(prob(70 - 20 * (severity - 1)))
			to_chat(victim, "<span class='userdanger'>My [limb.name] malfunctions as i strike [target]!</span>")
			limb.receive_damage(brute=rand(1,5), wound_bonus = CANT_WOUND)
		else
			victim.visible_message("<span class='danger'><b>[victim]</b> weakly strikes [target] with [victim.p_their()] bent [limb.name]!</span>", \
			"<span class='userdanger'>I fail to strike [target] as the frictioning metal in my [limb.name] causes it to spark!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
			victim.agony_scream()
			victim.Stun(0.5 SECONDS)
			limb.receive_damage(brute=rand(3,7), wound_bonus = CANT_WOUND)
			return COMPONENT_NO_ATTACK_HAND

/datum/wound/mechanical/blunt/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(!victim || victim.stat == DEAD || wounding_dmg < WOUND_MINIMUM_DAMAGE)
		return

	var/modifier = 1
	if(wounding_type == WOUND_BLUNT)
		modifier = 1.4
	else if(wounding_type == WOUND_PIERCE)
		modifier = 1.2
	else if(wounding_type == WOUND_SLASH)
		modifier = 0.8
	else if(wounding_type == WOUND_BURN)
		modifier = 0.5
	if((wounding_dmg * modifier >= 12/(severity - WOUND_SEVERITY_TRIVIAL)) && prob(wounding_dmg/2 * modifier))
		if(limb.body_zone == BODY_ZONE_CHEST && prob(shock_chance + (wounding_dmg * 2)))
			var/stun_amt = rand(10, wounding_dmg/10 * (severity == WOUND_SEVERITY_CRITICAL ? 20 : 15))
			if(stun_amt)
				victim.visible_message("<span class='smalldanger'><b>[victim]</b> gets stunned as [victim.p_their()] [limb.name] sparks!</span>", "<span class='danger'>I get stunned by the impact on my damaged [limb.name]!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
				victim.Paralyze(stun_amt)
				do_sparks(clamp(round(stun_amt/10, 1), 1, 6), GLOB.alldirs, victim)
		
		else if(limb.body_zone == BODY_ZONE_PRECISE_GROIN && prob(shock_chance + (wounding_dmg * 2)))
			var/stun_amt = rand(10, wounding_dmg/10 * (severity == WOUND_SEVERITY_CRITICAL ? 20 : 15))
			if(stun_amt)
				victim.visible_message("<span class='smalldanger'><b>[victim]</b> gets knocked down as [victim.p_their()] [limb.name] sparks!</span>", "<span class='danger'>I get knocked down by the impact on my damaged [limb.name]!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
				victim.DefaultCombatKnockdown(stun_amt)
				do_sparks(clamp(round(stun_amt/10, 1), 1, 6), GLOB.alldirs, victim)
	
	if(severity >= WOUND_SEVERITY_SEVERE)
		if(prob(round(max(wounding_dmg/10, 1), 1)))
			for(var/obj/item/organ/O in victim.getorganszone(limb.body_zone, TRUE))
				victim.adjustOrganLoss(O.slot, rand(1, wounding_dmg/10), O.maxHealth)

/datum/wound/mechanical/blunt/get_examine_description(mob/user)
	if(!limb.current_gauze && !wrenched && !taped)
		return ..()

	var/msg = ""
	if(!limb.current_gauze)
		msg = "[victim.p_their(TRUE)] [limb.name] [examine_desc]"
	else
		var/sling_condition = ""
		// how much life we have left in these bandages
		switch(limb.current_gauze.obj_integrity / limb.current_gauze.max_integrity * 100)
			if(0 to 25)
				sling_condition = "just barely "
			if(25 to 50)
				sling_condition = "loosely "
			if(50 to 75)
				sling_condition = "mostly "
			if(75 to INFINITY)
				sling_condition = "tightly "

		msg = "[victim.p_their(TRUE)] [limb.name] is [sling_condition] held together with [limb.current_gauze.name]"

	if(taped)
		msg += ", <span class='notice'>and the joints appear to be held together with sticky tape</span>"
	else if(wrenched)
		msg += ", <span class='notice'>and it appears to be tightly secured to avoid further damage</span>"
	return "<span class='danger'><B>[msg]!</B></span>"

/*
	New common procs for /datum/wound/mechanical/blunt/
*/

/datum/wound/mechanical/blunt/proc/update_inefficiencies()
	if(limb.body_zone in list(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_GROIN))
		if(limb.current_gauze)
			limp_slowdown = initial(limp_slowdown) * limb.current_gauze.splint_factor
		else
			limp_slowdown = initial(limp_slowdown)
		if(limb.body_zone == BODY_ZONE_PRECISE_GROIN)
			limp_slowdown *= 2
		victim.apply_status_effect(STATUS_EFFECT_LIMP)
	else if(limb.body_zone in list(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM))
		if(limb.current_gauze)
			interaction_efficiency_penalty = 1 + ((interaction_efficiency_penalty - 1) * limb.current_gauze.splint_factor)
		else
			interaction_efficiency_penalty = interaction_efficiency_penalty
	else if(limb.body_zone == BODY_ZONE_HEAD)
		victim.adjust_blurriness(30)
		if(prob(20))
			victim.emote("scream")

	if(initial(disabling))
		disabling = !limb.current_gauze

	limb.update_wounds()

/*
	Moderate (Joint Desynchronization)
*/

/datum/wound/mechanical/blunt/moderate
	name = "Joint Desynchronization"
	desc = "Parts of the patient's actuators have forcefully disconnected from each other, causing delayed and inefficient limb movement."
	treat_text = "Recommended wrenching of the affected limb, though manual synchronization by applying an aggressive grab to the patient and helpfully interacting with afflicted limb may suffice.  Use of synthetic healing chemicals may also help."
	examine_desc = "has visibly disconnected rotors"
	occur_text = "snaps and becomes unseated"
	severity = WOUND_SEVERITY_MODERATE
	viable_zones = ALL_BODYPARTS_MINUS_EYES
	treatable_by = list(TOOL_WRENCH)
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 3
	threshold_minimum = 35
	threshold_penalty = 15
	status_effect_type = /datum/status_effect/wound/blunt/moderate
	associated_alerts = list()
	can_self_treat = TRUE
	pain_amount = 10
	flat_damage_roll_increase = 5
	descriptive = "A joint is snapped!"
	wound_flags = (WOUND_SOUND_HINTS | WOUND_SEEPS_GAUZE | WOUND_VISIBLE_THROUGH_CLOTHING)

/datum/wound/mechanical/blunt/moderate/self_treat(mob/living/carbon/user, first_time = FALSE)
	. = ..()
	if(.)
		return TRUE
	
	var/time = base_treat_time
	var/time_mod = 2
	var/prob_mod = 12.5
	
	if(first_time)
		user.visible_message("<span class='notice'><b>[user]</b> starts to force their [limb.name]'s rotors back in place...</span>", "<span class='notice'>I start forcing my [limb.name]'s rotors back in place...</span>")

	//Electronics skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/electronics/electronics = GET_SKILL(user, electronics)
		if(electronics)
			time_mod *= ((MAX_SKILL/2)/electronics.level)
			prob_mod *= ((MAX_SKILL/2)/electronics.level)

	if(!do_after(user, time * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, electronics) * 0.75) >= DICE_SUCCESS)
		user.visible_message("<span class='danger'><b>[user]</b> snaps their own [limb.name]'s rotors back in place!</span>", "<span class='danger'>I snap my own [limb.name]'s rotors back into place!</span>")
		victim.emote("scream")
		limb.receive_damage(brute=12, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message("<span class='danger'><b>[user]</b> wrenches their [limb.name] around!</span>", "<span class='danger'>I wrench my [limb.name] around!</span>")
		limb.receive_damage(brute=8, wound_bonus=CANT_WOUND)
		self_treat(user, FALSE)
	return

/datum/wound/mechanical/blunt/moderate/crush()
	if(prob(33))
		victim.visible_message("<span class='danger'><b>[victim]</b>'s unsynchronized [limb.name] actuators snaps back into place!</span>", "<span class='userdanger'>My unsynchronized [limb.name] actuators snap back into place!</span>")
		remove_wound()

/datum/wound/mechanical/blunt/moderate/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone || user.a_intent == INTENT_GRAB)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>I must have <b>[victim]</b> in an aggressive grab to manipulate [victim.p_their()] [lowertext(name)]!</span>")
		return TRUE

	if(user.grab_state >= GRAB_AGGRESSIVE)
		user.visible_message("<span class='danger'><b>[user]</b> begins forcing <b>[victim]</b>'s disconnected [limb.name] actuators!</span>", "<span class='notice'>I begin forcing <b>[victim]</b>'s disconnected [limb.name]'s actuators...</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'><b>[user]</b> begins forcing my [limb.name]'s actuators!</span>")
		if(user.a_intent == INTENT_HELP)
			chiropractice(user)
		else
			malpractice(user)
		return TRUE

/// If someone is snapping our servos into place by hand with an aggro grab and help intent
/datum/wound/mechanical/blunt/moderate/proc/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time
	var/time_mod = 1
	var/prob_mod = 10

	//Electronics skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/electronics/electronics = GET_SKILL(user, electronics)
		if(electronics)
			time_mod *= ((MAX_SKILL/2)/electronics.level)
			prob_mod *= ((MAX_SKILL/2)/electronics.level)

	if(!do_after(user, time * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, electronics) * 0.75) >= DICE_SUCCESS)
		user.visible_message("<span class='danger'><b>[user]</b> forcefully connects <b>[victim]</b>'s disconnected [limb.name] actuators!</span>", "<span class='notice'>I forcefully connect <b>[victim]</b>'s disconnected [limb.name] actuators!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'><b>[user]</b> snaps my desynchronized [limb.name] actuators back into place!</span>")
		victim.emote("scream")
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message("<span class='danger'><b>[user]</b> torques and grinds <b>[victim]</b>'s disconnected [limb.name] actuators!</span>", "<span class='danger'>I torque and grind <b>[victim]</b>'s disconnected [limb.name] actuators!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'><b>[user]</b> torques and grinds my [limb.name]'s disconnected actuators!</span>")
		limb.receive_damage(brute=8, wound_bonus=CANT_WOUND)
		chiropractice(user)

/// If someone is snapping our dislocated joint into a fracture by hand with an aggro grab and harm or disarm intent
/datum/wound/mechanical/blunt/moderate/proc/malpractice(mob/living/carbon/human/user)
	. = FALSE
	if(user.next_move >= world.time)
		return
	var/dice = DICE_SUCCESS
	if(user.mind)
		dice = user.mind.diceroll(GET_STAT_LEVEL(user, str)*1.25, GET_SKILL_LEVEL(user, melee)*0.75, "6d6", 20)

	if(dice >= DICE_SUCCESS)
		var/obj/item/bodypart/funky_kong = limb
		if(dice >= DICE_CRIT_SUCCESS)
			replace_wound(/datum/wound/blunt/critical)
		else
			replace_wound(/datum/wound/blunt/severe)
		user.visible_message("<span class='danger'><b>[user]</b> snaps <b>[victim]</b>'s disconnected [funky_kong.name] actuators with a loud pop![funky_kong.owner?.wound_message]</span>", "<span class='danger'>I snap <b>[victim]</b>'s disconnected [funky_kong.name] actuators with a loud pop![funky_kong.owner?.wound_message]</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'><b>[user]</b> snaps my dislocated [funky_kong.name] with a sickening crack![funky_kong.owner?.wound_message]</span>")
		funky_kong.receive_damage(brute=GET_STAT_LEVEL(user, str)*0.75, wound_bonus = CANT_WOUND)
	else
		user.visible_message("<span class='danger'><b>[user]</b> grinds <b>[victim]</b>'s disconnected [limb.name] actuators![victim.wound_message]</span>", "<span class='danger'>I grind <b>[victim]</b>'s disconnected [limb.name] actuators![victim.wound_message]</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'><b>[user]</b> grinds my dislocated [limb.name] actuators![victim.wound_message]</span>")
		limb.receive_damage(brute=GET_STAT_LEVEL(user, str)*0.5, wound_bonus = CANT_WOUND)
	//Clean the wound string either way
	victim.wound_message = ""
	user.changeNext_move(CLICK_CD_GRABBING)
	return TRUE

/datum/wound/mechanical/blunt/moderate/boneset(obj/item/I, mob/user)
	if(victim == user)
		victim.visible_message("<span class='danger'><b>[user]</b> begins resetting [victim.p_their()] [limb.name] with [I].</span>", "<span class='warning'>I begin resetting my [limb.name] with [I]...</span>")
	else
		user.visible_message("<span class='danger'><b>[user]</b> begins resetting <b>[victim]</b>'s [limb.name] with [I].</span>", "<span class='notice'>I begin resetting <b>[victim]</b>'s [limb.name] with [I]...</span>")

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(victim == user)
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, electronics) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=15, wound_bonus=CANT_WOUND)
		victim.visible_message("<span class='danger'><b>[user]</b> finishes resetting [victim.p_their()] [limb.name]!</span>", "<span class='userdanger'>I reset my [limb.name]!</span>")
	else
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, electronics) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=7, wound_bonus=CANT_WOUND)
		user.visible_message("<span class='danger'><b>[user]</b> finishes resetting <b>[victim]</b>'s [limb.name]!</span>", "<span class='nicegreen'>I finish resetting <b>[victim]</b>'s [limb.name]!</span>", victim)
		to_chat(victim, "<span class='userdanger'><b>[user]</b> resets my [limb.name]!</span>")

	victim.emote("scream")
	qdel(src)

/*
	Severe (Malfunctioning Actuators)
*/

/datum/wound/mechanical/blunt/severe
	name = "Malfunctioning Actuators"
	desc = "Patient's actuators are malfunctioning, causing reduced limb functionality and performance."
	treat_text = "Recommended wrenching and taping of the affected limb. Use of synthetic healing chemicals may also help."
	examine_desc = "has loose and disconnected bits of metal"

	occur_text = "loudly hums as some loose nuts and bolts fall out"

	severity = WOUND_SEVERITY_SEVERE
	viable_zones = ALL_BODYPARTS_MINUS_EYES
	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	threshold_minimum = 60
	threshold_penalty = 30
	status_effect_type = /datum/status_effect/wound/blunt/severe
	treat_priority = TRUE
	brain_trauma_group = BRAIN_TRAUMA_MILD
	trauma_cycle_cooldown = 1.5 MINUTES
	shock_chance = 30
	pain_amount = 20
	flat_damage_roll_increase = 10
	descriptive = "A joint is fractured!"

/*
	Critical (Broken Actuators)
*/

/datum/wound/mechanical/blunt/critical
	name = "Broken Actuators"
	desc = "Patient's actuators have suffered severe dents and component losses, causing a severe decrease in limb functionality and performance."
	treat_text = "Recommended complete internal component repair and replacement, but wrenching and taping of the limb might suffice. Use of synthetic healing chemicals may also help."
	examine_desc = "is damaged at several spots, with protuding bits of metal"
	occur_text = "loudly hums as it's rotors scrapes away bits of metal"
	severity = WOUND_SEVERITY_CRITICAL
	viable_zones = ALL_BODYPARTS_MINUS_EYES
	interaction_efficiency_penalty = 4
	limp_slowdown = 9
	sound_effect = 'sound/effects/clang2.ogg'
	threshold_minimum = 115
	threshold_penalty = 50
	disabling = TRUE
	status_effect_type = /datum/status_effect/wound/blunt/critical
	treat_priority = TRUE
	brain_trauma_group = BRAIN_TRAUMA_SEVERE
	trauma_cycle_cooldown = 2.5 MINUTES
	shock_chance = 45
	pain_amount = 30
	flat_damage_roll_increase = 15
	descriptive = "A joint is shattered!"

/// if someone is using a reagent container
/datum/wound/mechanical/blunt/proc/wrench(obj/item/I, mob/user)
	if(wrenched)
		to_chat(user, "<span class='warning'>[user == victim ? "My" : "<b>[victim]</b>'s"] [limb.name] is already secured in place!</span>")
		return

	user.visible_message("<span class='danger'><b>[user]</b> begins fastening [limb.name]...</span>", "<span class='warning'>I begin fastening [user == victim ? "my" : "<b>[victim]</b>'s"] [limb.name]...</span>")

	if(!do_after(user, base_treat_time * 1.5 * (user == victim ? 1.5 : 1), target = victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return
	
	if(user != victim)
		user.visible_message("<span class='notice'><b>[user]</b> finishes fastening <b>[victim]</b>'s [limb.name], emitting a cranking noise!</span>", "<span class='notice'>I finish fastening <b>[victim]</b>'s [limb.name]!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'><b>[user]</b> finishes fastening my [limb.name]!</span>")
	else
		var/painkiller_bonus = 0
		if(victim.reagents && victim.reagents.has_reagent(/datum/reagent/determination))
			painkiller_bonus += 5
		
		victim.visible_message("<span class='notice'><b>[victim]</b> finishes fastening [victim.p_their()] [limb.name]!</span>", "<span class='notice'>I finish fastening my [limb.name]!</span>")

	limb.receive_damage(15, stamina=75, wound_bonus=CANT_WOUND)
	if(!wrenched)
		wrenched = TRUE
		if(severity <= WOUND_SEVERITY_MODERATE)
			qdel(src)

/// if someone is using sticky tape on our wound
/datum/wound/mechanical/blunt/tape(obj/item/stack/sticky_tape/I, mob/user)
	if(!wrenched)
		to_chat(user, "<span class='warning'>[user == victim ? "My" : "<b>[victim]</b>'s"] [limb.name] must be secured to perform this emergency protocol!</span>")
		return
	
	if(taped)
		to_chat(user, "<span class='warning'>[user == victim ? "My" : "<b>[victim]</b>'s"] [limb.name] is already wrapped in [I.name] and reforming!</span>")
		return

	user.visible_message("<span class='danger'><b>[user]</b> begins applying [I] to <b>[victim]</b>'s' [limb.name]...</span>", "<span class='warning'>I begin applying [I] to [user == victim ? "my" : "<b>[victim]</b>'s"] [limb.name]...</span>")

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return
	if(!I.use(1))
		to_chat(user, "<span class='warning'>There aren't enough stacks of [I.name] to heal \the [src.name]!</span>")
		return
	
	regen_points_current = 0
	regen_points_needed = 15 * (user == victim ? 1.5 : 1) * (severity - WOUND_SEVERITY_TRIVIAL)
	if(user != victim)
		user.visible_message("<span class='notice'><b>[user]</b> finishes applying [I] to <b>[victim]</b>'s [limb.name]!</span>", "<span class='notice'>I finish applying [I] to <b>[victim]</b>'s [limb.name]!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='green'><b>[user]</b> finishes applying [I] to my [limb.name], i can feel the repair processes booting up!</span>")
	else
		victim.visible_message("<span class='notice'><b>[victim]</b> finishes applying [I] to [victim.p_their()] [limb.name]!</span>", "<span class='green'>I finish applying [I] to my [limb.name], and i immediately begin to feel the repair process boot up!</span>")

	taped = TRUE
	processes = TRUE

/datum/wound/mechanical/blunt/proc/boneset(obj/item/I, mob/user)
	return FALSE

/datum/wound/mechanical/blunt/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/wrench))
		wrench(I, user)
		return TRUE
	else if(istype(I, /obj/item/stack/sticky_tape) && user.a_intent != INTENT_HARM)
		tape(I, user)
		return TRUE
	else if(I.tool_behaviour == TOOL_WRENCH)
		boneset(I, user)
		return TRUE

/datum/wound/mechanical/blunt/get_scanner_description(mob/user)
	. = ..()

	. += "<div class='ml-3'>"

	if(severity >= WOUND_SEVERITY_SEVERE)
		if(!wrenched)
			. += "Alternative Treatment: Secure the injured limb with a wrench, then sticky tape to begin automatic repair. This is very ineffective and may damage internal components, and as such only recommended in dire need.</span>\n"
		else if(!taped)
			. += "<span class='notice'>Continue Alternative Treatment: Apply sticky tape directly to injured limb to begin automatic. This is very ineffective and may damage internal components, and as such only recommended in dire need.</span>\n"
		else
			. += "<span class='notice'>Note: Automatic repair in effect. Background tasks are [round((regen_points_current/regen_points_needed) * 100)]% operational.</span>\n"

	if(limb.body_zone == BODY_ZONE_HEAD)
		. += "Head Trauma Detected: Patient will suffer random bouts of [severity == WOUND_SEVERITY_SEVERE ? "mild" : "severe"] runtimes until damage is repaired."
	else if(limb.body_zone == BODY_ZONE_CHEST)
		. += "Chest Trauma Detected: Further trauma to chest is likely to stun or paralyze the victim momentarily."
	else if(limb.body_zone == BODY_ZONE_PRECISE_GROIN)
		. += "Groin Trauma Detected: Further trauma to groin is likely to knock them down momentarily."
	. += "</div>"

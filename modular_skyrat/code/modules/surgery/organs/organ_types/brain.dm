/obj/item/organ/brain
	name = "brain"
	desc = "A piece of juicy meat found in a person's head."
	icon_state = "brain"
	throw_speed = 3
	throw_range = 5
	layer = ABOVE_MOB_LAYER
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_BRAIN
	organ_flags = ORGAN_VITAL
	attack_verb = list("attacked", "slapped", "whacked")

	///The brain's organ variables are significantly more different than the other organs, with half the decay rate for balance reasons, and twice the maxHealth
	decay_factor = STANDARD_ORGAN_DECAY	/ 2		//30 minutes of decaying to result in a fully damaged brain, since a fast decay rate would be unfun gameplay-wise
	healing_factor = 0 //We use our own system to heal up
	maxHealth = BRAIN_DAMAGE_DEATH
	low_threshold = 50
	high_threshold = 150
	damage_reduction = 0
	damage_modifier = 0
	damage_reduction = 0

	var/mob/living/brain/brainmob = null
	var/brain_death = FALSE //if the brainmob was intentionally killed by attacking the brain after removal, or by severe braindamage
	var/decoy_override = FALSE	//I apologize to the security players, and myself, who abused this, but this is going to go.
	//two variables necessary for calculating whether we get a brain trauma or not
	var/damage_delta = 0

	var/list/datum/brain_trauma/traumas = list()

	var/brain_can_heal = TRUE
	var/damage_threshold_count = 10
	var/damage_threshold_value = 0
	var/healed_threshold = 1
	var/oxygen_reserve = 5
	var/last_wobble = 0
	var/wobble_duration = 1070
	relative_size = 70 //Cum is stored in the brain, and i have a headache
	pain_multiplier = 0 //We don't count towards bodypart pain

/obj/item/organ/brain/Destroy()
	. = ..()
	if(brainmob)
		brainmob.ghostize(voluntary = FALSE)

/obj/item/organ/brain/Initialize()
	. = ..()
	damage_threshold_value = round(maxHealth / damage_threshold_count)

/obj/item/organ/brain/proc/get_current_damage_threshold()
	return round(damage / damage_threshold_value)

/obj/item/organ/brain/proc/past_damage_threshold(threshold)
	return (get_current_damage_threshold() > threshold)

/obj/item/organ/brain/on_life()
	. = ..()
	// Brain damage from low oxygenation or lack of blood.
	if(owner.needs_heart())
		// No heart? You are going to have a very bad time. Not 100% lethal because heart transplants should be a thing.
		var/blood_volume = owner.get_blood_oxygenation()
		if(blood_volume < BLOOD_VOLUME_SURVIVE)
			if(!owner.chem_effects[CE_STABLE] || prob(50))
				oxygen_reserve = max(0, oxygen_reserve-1)
		else
			oxygen_reserve = min(initial(oxygen_reserve), oxygen_reserve + 1)
		if(!oxygen_reserve) //(hardcrit)
			if(owner.AmountUnconscious() < 4 SECONDS)
				owner.SetUnconscious(4 SECONDS)
		var/can_heal = damage && brain_can_heal && (damage < maxHealth) && (damage % damage_threshold_value || owner.chem_effects[CE_BRAIN_REGEN] || HAS_TRAIT(owner, TRAIT_STRONGMINDED) || (!past_damage_threshold(3) && owner.chem_effects[CE_STABLE]))
		var/damprob = 0
		//Effects of bloodloss
		switch(blood_volume)
			if(BLOOD_VOLUME_SAFE to INFINITY)
				if(can_heal)
					damage = max(damage-1, 0)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				damprob = owner.chem_effects[CE_STABLE] ? 5 : 50
				if(!past_damage_threshold(2) && prob(damprob))
					applyOrganDamage(DAMAGE_LOW_OXYGENATION)
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				owner.eye_blurry = max(owner.eye_blurry,6)
				damprob = owner.chem_effects[CE_STABLE] ? 10 : 75
				if(!past_damage_threshold(4) && prob(damprob))
					applyOrganDamage(DAMAGE_LOW_OXYGENATION)
				if(!owner.IsParalyzed() && prob(10))
					owner.Paralyze(rand(400,800))
					to_chat(owner, "<span class='warning'>You feel extremely [pick("dizzy","woozy","faint")]...</span>")
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				owner.eye_blurry = max(owner.eye_blurry,6)
				damprob = owner.chem_effects[CE_STABLE] ? 15 : 100
				if(!past_damage_threshold(6) && prob(damprob))
					applyOrganDamage(DAMAGE_LOWER_OXYGENATION)
				if(!owner.IsParalyzed() && prob(15))
					owner.Paralyze(800)
					to_chat(owner, "<span class='warning'>You feel extremely [pick("dizzy","woozy","faint")]...</span>")
			// Also see heart.dm, being below this point puts you into cardiac arrest no matter what
			if(-(INFINITY) to BLOOD_VOLUME_SURVIVE)
				owner.eye_blurry = max(owner.eye_blurry,6)
				damprob = owner.chem_effects[CE_STABLE] ? 20 : 100
				if(prob(damprob))
					applyOrganDamage(DAMAGE_VERY_LOW_OXYGENATION)

/obj/item/organ/brain/onDamage(d, maximum)
	. = ..()
	if(owner)
		//Do the wobble sound
		if((damage >= high_threshold) && (world.time >= last_wobble) && owner)
			last_wobble = world.time
			owner.playsound_local(get_turf(owner), 'modular_skyrat/sound/effects/ear_ring.ogg', 75, 0, channel = CHANNEL_EAR_RING)
		//Or stop it, if we got healed
		else if(damage <= high_threshold)
			owner.stop_sound_channel(CHANNEL_EAR_RING)
		//We received an amount of damage larger than 10, let's do something fun
		if(d > 10)
			// Choose between sudden death and sagging
			if(prob(50))
				INVOKE_ASYNC(src, .proc/handle_sudden_death, owner, d)
			else
				INVOKE_ASYNC(src, .proc/handle_sagging, owner, d)

/obj/item/organ/brain/proc/handle_sudden_death(mob/living/carbon/victim, damage_suffered)
	//Roll endurance to see if we die suddenly
	var/sleep_duration = 3 SECONDS
	if(victim.mind)
		victim.Unconscious(sleep_duration * 5)
		victim.death_rattle()
		sleep(sleep_duration)
		victim.death_rattle()
		sleep(sleep_duration)
		victim.death_rattle()
		sleep(sleep_duration)
		var/roll = victim.mind.diceroll(STAT_DATUM(end), mod = -damage_suffered)
		if(roll >= DICE_SUCCESS)
			victim.death_rattle()
			sleep(sleep_duration)
			to_chat(victim, "<span class='userdanger'>You narrowly avoid death's grasp!</span>")
			if(roll >= DICE_CRIT_SUCCESS)
				victim.Unconscious(-sleep_duration * 2)
		else
			victim.death_rattle()
			sleep(sleep_duration)
			to_chat(victim, "<span class='userdanger'>You suddenly lose your grasp on life.</span>")
			victim.death()
	//Mindless mobs always receive a sudden death
	else
		victim.Unconscious(sleep_duration * 5)
		victim.death_rattle()
		sleep(sleep_duration)
		victim.death_rattle()
		sleep(sleep_duration)
		victim.death_rattle()
		sleep(sleep_duration)
		victim.death_rattle()
		sleep(sleep_duration)
		to_chat(victim, "<span class='userdanger'>You suddenly lose your grasp on life.</span>")
		victim.death()

/obj/item/organ/brain/proc/handle_sagging(mob/living/carbon/victim, damage_suffered)
	if(!victim)
		return
	//Always clear the chat. Sorry chief.
	if(victim.client?.chatOutput)
		victim.client.chatOutput.loaded = FALSE
		victim.client.chatOutput.start()
		victim.client.chatOutput.load()
	//If we have a mind, we do an endurance roll to determine if we go unconscious
	//otherwise assume that the mob is awful at everything
	if(victim.mind)
		switch(victim.mind.diceroll(STAT_DATUM(end), mod = -round(damage_suffered)))
			//We succeeded perfectly - Immobilized, but no dropping items
			if(DICE_CRIT_SUCCESS)
				victim.Immobilize(200)
			//We succeeded - Just get stunned
			if(DICE_SUCCESS)
				victim.Stun(400)
			//We failed - Unconsciousness
			if(DICE_FAILURE)
				victim.Unconscious(600)
			//We failed miserably - Gain a brain trauma along with unconsciousness
			if(DICE_CRIT_FAILURE)
				victim.Unconscious(600)
				victim.gain_trauma_type(pick(BRAIN_TRAUMA_SEVERE, BRAIN_TRAUMA_MILD))
	else
		victim.Unconscious(600)
	//Inform the victim
	var/message = pick("... WHAT HAPPENED? ...", "... WHERE AM I? ...", "... WHO AM I? ...")
	visible_message("<span class='danger'><b>[victim]</b> sags on the ground. They will not regain consciousness any soon.</span>", \
				"<span class='deadsay'><span class='big bold'>[message]</span></span>")

/obj/item/organ/brain/Insert(mob/living/carbon/C, special = 0,no_id_transfer = FALSE, drop_if_replaced = TRUE)
	. = ..()

	name = "brain"

	if(C.mind && C.mind.has_antag_datum(/datum/antagonist/changeling) && !no_id_transfer)	//congrats, you're trapped in a body you don't control
		if(brainmob && !(C.stat == DEAD || (HAS_TRAIT(C, TRAIT_DEATHCOMA))))
			to_chat(brainmob, "<span class = danger>You can't feel your body! You're still just a brain!</span>")
		forceMove(C)
		C.update_hair()
		return

	if(brainmob)
		if(C.key)
			C.ghostize()

		if(brainmob.mind)
			brainmob.mind.transfer_to(C)
		else
			brainmob.transfer_ckey(C)

		QDEL_NULL(brainmob)

	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		BT.owner = owner
		BT.on_gain()
	if(damage > BRAIN_DAMAGE_MILD)
		var/datum/skill_modifier/S
		ADD_SKILL_MODIFIER_BODY(/datum/skill_modifier/brain_damage, null, C, S)
	if(damage > BRAIN_DAMAGE_SEVERE)
		var/datum/skill_modifier/S
		ADD_SKILL_MODIFIER_BODY(/datum/skill_modifier/heavy_brain_damage, null, C, S)

/obj/item/organ/brain/Remove(special = FALSE, no_id_transfer = FALSE)
	. = ..()
	var/mob/living/carbon/C = .
	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		BT.on_lose(TRUE)
		BT.owner = null

	if((!QDELETED(src) || C) && !no_id_transfer)
		transfer_identity(C)
	if(C)
		REMOVE_SKILL_MODIFIER_BODY(/datum/skill_modifier/brain_damage, null, C)
		REMOVE_SKILL_MODIFIER_BODY(/datum/skill_modifier/heavy_brain_damage, null, C)
		C.update_hair()

/obj/item/organ/brain/proc/transfer_identity(mob/living/L)
	name = "[L.name]'s brain"
	if(brainmob)
		return

	if(!L.mind)
		return
	brainmob = new(src)
	brainmob.name = L.real_name
	brainmob.real_name = L.real_name
	brainmob.timeofhostdeath = L.timeofdeath
	if(L.has_dna())
		var/mob/living/carbon/C = L
		if(!brainmob.stored_dna)
			brainmob.stored_dna = new /datum/dna/stored(brainmob)
		C.dna.copy_dna(brainmob.stored_dna)
		if(HAS_TRAIT(L, TRAIT_NOCLONE))
			LAZYSET(brainmob.status_traits, TRAIT_NOCLONE, L.status_traits[TRAIT_NOCLONE])
		var/obj/item/organ/zombie_infection/ZI = L.getorganslot(ORGAN_SLOT_ZOMBIE)
		if(ZI)
			brainmob.set_species(ZI.old_species)	//For if the brain is cloned
	if(!decoy_override && L.mind && L.mind.current)
		L.mind.transfer_to(brainmob)
	to_chat(brainmob, "<span class='notice'>You feel slightly disoriented. That's normal when you're just a brain.</span>")

/obj/item/organ/brain/surgical_examine(mob/user)
	. = ..()
	if(owner)
		return
	if(user.suiciding)
		. += "<span class='info'>It's started turning slightly grey. They must not have been able to handle the stress of it all.</span>"
	else if(brainmob)
		if(brainmob.get_ghost(FALSE, TRUE))
			if(brain_death || brainmob.health <= HEALTH_THRESHOLD_DEAD)
				. += "<span class='info'>It's lifeless and severely damaged, only the strongest of chems will save it.</span>"
			else if(organ_flags & ORGAN_FAILING)
				. += "<span class='info'>It seems to still have a bit of energy within it, but it's rather damaged... You may be able to restore it with some <b>mannitol</b>.</span>"
			else
				. += "<span class='info'>You can feel the small spark of life still left in this one.</span>"
		else if(organ_flags & ORGAN_FAILING)
			. += "<span class='info'>It seems particularly lifeless and is rather damaged... You may be able to restore it with some <b>mannitol</b> incase it becomes functional again later.</span>"
		else
			. += "<span class='info'>This one seems particularly lifeless. Perhaps it will regain some of its luster later.</span>"
	else
		if(decoy_override)
			if(organ_flags & ORGAN_FAILING)
				. += "<span class='info'>It seems particularly lifeless and is rather damaged... You may be able to restore it with some <b>mannitol</b> incase it becomes functional again later.</span>"
			else
				. += "<span class='info'>This one seems particularly lifeless. Perhaps it will regain some of its luster later.</span>"
		else
			. += "<span class='info'>This one is completely devoid of life.</span>"

/obj/item/organ/brain/attack(mob/living/carbon/C, mob/user)
	if(!istype(C))
		return ..()

	add_fingerprint(user)

	if(user.zone_selected != BODY_ZONE_HEAD)
		return ..()

	if((C.head && (C.head.flags_cover & HEADCOVERSEYES)) || (C.wear_mask && (C.wear_mask.flags_cover & MASKCOVERSEYES)) || (C.glasses && (C.glasses.flags_1 & GLASSESCOVERSEYES)))
		to_chat(user, "<span class='warning'>You're going to need to remove [C.p_their()] head cover first!</span>")
		return

//since these people will be dead M != usr

	if(!C.getorgan(/obj/item/organ/brain) && (user.zone_selected == zone))
		if(!C.get_bodypart(BODY_ZONE_HEAD) || !user.temporarilyRemoveItemFromInventory(src))
			return
		var/msg = "[C] has [src] inserted into [C.p_their()] head by [user]."
		if(C == user)
			msg = "[user] inserts [src] into [user.p_their()] head!"

		C.visible_message("<span class='danger'>[msg]</span>",
						"<span class='userdanger'>[msg]</span>")

		if(C != user)
			to_chat(C, "<span class='notice'>[user] inserts [src] into your head.</span>")
			to_chat(user, "<span class='notice'>You insert [src] into [C]'s head.</span>")
		else
			to_chat(user, "<span class='notice'>You insert [src] into your head.</span>"	)

		Insert(C)
	else
		..()

/obj/item/organ/brain/applyOrganDamage(var/d, var/maximum = maxHealth)
	. = ..()
	if(!. || !owner)
		return
	if((damage >= BRAIN_DAMAGE_DEATH) && CHECK_BITFIELD(organ_flags, ORGAN_VITAL)) //rip
		if(owner.stat < DEAD)
			to_chat(owner, "<span class='userdanger'>The last spark of life in your brain fizzles out...</span>")
			owner.stop_sound_channel(CHANNEL_EAR_RING)
			owner.death()
		brain_death = TRUE
	else
		brain_death = FALSE

/obj/item/organ/brain/check_damage_thresholds(mob/M)
	. = ..()
	//if we're not more injured than before, return without gambling for a trauma
	if(damage <= prev_damage)
		if(damage < prev_damage && owner)
			if(prev_damage > BRAIN_DAMAGE_MILD && damage <= BRAIN_DAMAGE_MILD)
				REMOVE_SKILL_MODIFIER_BODY(/datum/skill_modifier/brain_damage, null, owner)
			if(prev_damage > BRAIN_DAMAGE_SEVERE && damage <= BRAIN_DAMAGE_SEVERE)
				REMOVE_SKILL_MODIFIER_BODY(/datum/skill_modifier/heavy_brain_damage, null, owner)
		return
	damage_delta = damage - prev_damage
	if((damage > BRAIN_DAMAGE_MILD) && (damage_delta > MINIMUM_DAMAGE_TRAUMA_ROLL))
		if(prob(damage_delta * (1 + max(0, (damage - BRAIN_DAMAGE_MILD)/100)))) //Base chance is the hit damage; for every point of damage past the threshold the chance is increased by 1% //learn how to do your bloody math properly goddamnit
			gain_trauma_type(BRAIN_TRAUMA_MILD, natural_gain = TRUE)
			if(prev_damage <= BRAIN_DAMAGE_MILD && owner)
				var/datum/skill_modifier/S
				ADD_SKILL_MODIFIER_BODY(/datum/skill_modifier/brain_damage, null, owner, S)
	if((damage > BRAIN_DAMAGE_SEVERE) && (damage_delta > MINIMUM_DAMAGE_TRAUMA_ROLL))
		if(prob(damage_delta * (1 + max(0, (damage - BRAIN_DAMAGE_SEVERE)/100)))) //Base chance is the hit damage; for every point of damage past the threshold the chance is increased by 1%
			if(prob(20))
				gain_trauma_type(BRAIN_TRAUMA_SPECIAL, natural_gain = TRUE)
			else
				gain_trauma_type(BRAIN_TRAUMA_SEVERE, natural_gain = TRUE)
			if(prev_damage <= BRAIN_DAMAGE_SEVERE && owner)
				var/datum/skill_modifier/S
				ADD_SKILL_MODIFIER_BODY(/datum/skill_modifier/heavy_brain_damage, null, owner, S)
	if(owner && (damage_delta > MINIMUM_DAMAGE_TRAUMA_ROLL)) //Don't spam the owner if we didn't roll for traumas
		if(owner.stat < UNCONSCIOUS) //conscious or soft-crit
			var/brain_message
			if(prev_damage < BRAIN_DAMAGE_MILD && damage >= BRAIN_DAMAGE_MILD)
				brain_message = "<span class='warning'>You feel lightheaded.</span>"
			else if(prev_damage < BRAIN_DAMAGE_SEVERE && damage >= BRAIN_DAMAGE_SEVERE)
				brain_message = "<span class='warning'>You feel less in control of your thoughts.</span>"
			else if(prev_damage < (BRAIN_DAMAGE_DEATH - 20) && damage >= (BRAIN_DAMAGE_DEATH - 20))
				brain_message = "<span class='warning'>You can feel your mind flickering on and off...</span>"

			if(.)
				. += "\n[brain_message]"
			else
				return brain_message

/obj/item/organ/brain/Destroy() //copypasted from MMIs.
	if(brainmob)
		QDEL_NULL(brainmob)
	QDEL_LIST(traumas)
	return ..()

/obj/item/organ/brain/alien
	name = "alien brain"
	desc = "We barely understand the brains of terrestial animals. Who knows what we may find in the brain of such an advanced species?"
	icon_state = "brain-x"

////////////////////////////////////TRAUMAS////////////////////////////////////////

/obj/item/organ/brain/proc/has_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		if(istype(BT, brain_trauma_type) && (BT.resilience <= resilience))
			return BT

/obj/item/organ/brain/proc/get_traumas_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_ABSOLUTE)
	. = list()
	for(var/X in traumas)
		var/datum/brain_trauma/BT = X
		if(istype(BT, brain_trauma_type) && (BT.resilience <= resilience))
			. += BT

/obj/item/organ/brain/proc/can_gain_trauma(datum/brain_trauma/trauma, resilience, natural_gain = FALSE)
	if(!ispath(trauma))
		trauma = trauma.type
	if(!initial(trauma.can_gain))
		return FALSE
	if(!resilience)
		resilience = initial(trauma.resilience)
	if(!owner)
		return FALSE
	if(owner.stat == DEAD)
		return FALSE

	var/resilience_tier_count = 0
	for(var/X in traumas)
		if(istype(X, trauma))
			return FALSE
		var/datum/brain_trauma/T = X
		if(resilience == T.resilience)
			resilience_tier_count++

	var/max_traumas
	switch(resilience)
		if(TRAUMA_RESILIENCE_BASIC)
			max_traumas = TRAUMA_LIMIT_BASIC
		if(TRAUMA_RESILIENCE_SURGERY)
			max_traumas = TRAUMA_LIMIT_SURGERY
		if(TRAUMA_RESILIENCE_WOUND)
			max_traumas = TRAUMA_LIMIT_WOUND
		if(TRAUMA_RESILIENCE_LOBOTOMY)
			max_traumas = TRAUMA_LIMIT_LOBOTOMY
		if(TRAUMA_RESILIENCE_MAGIC)
			max_traumas = TRAUMA_LIMIT_MAGIC
		if(TRAUMA_RESILIENCE_ABSOLUTE)
			max_traumas = TRAUMA_LIMIT_ABSOLUTE

	if(natural_gain && resilience_tier_count >= max_traumas)
		return FALSE
	return TRUE

//Proc to use when directly adding a trauma to the brain, so extra args can be given
/obj/item/organ/brain/proc/gain_trauma(datum/brain_trauma/trauma, resilience, ...)
	var/list/arguments = list()
	if(args.len > 2)
		arguments = args.Copy(3)
	. = brain_gain_trauma(trauma, resilience, arguments)

//Direct trauma gaining proc. Necessary to assign a trauma to its brain. Avoid using directly.
/obj/item/organ/brain/proc/brain_gain_trauma(datum/brain_trauma/trauma, resilience, list/arguments)
	if(!can_gain_trauma(trauma, resilience))
		return

	var/datum/brain_trauma/actual_trauma
	if(ispath(trauma))
		if(!LAZYLEN(arguments))
			actual_trauma = new trauma() //arglist with an empty list runtimes for some reason
		else
			actual_trauma = new trauma(arglist(arguments))
	else
		actual_trauma = trauma

	if(actual_trauma.brain) //we don't accept used traumas here
		WARNING("gain_trauma was given an already active trauma.")
		return

	traumas += actual_trauma
	actual_trauma.brain = src
	if(owner)
		actual_trauma.owner = owner
		actual_trauma.on_gain()
	if(resilience)
		actual_trauma.resilience = resilience
	SSblackbox.record_feedback("tally", "traumas", 1, actual_trauma.type)
	return actual_trauma

//Add a random trauma of a certain subtype
/obj/item/organ/brain/proc/gain_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience, natural_gain = FALSE)
	var/list/datum/brain_trauma/possible_traumas = list()
	for(var/T in subtypesof(brain_trauma_type))
		var/datum/brain_trauma/BT = T
		if(can_gain_trauma(BT, resilience, natural_gain) && initial(BT.random_gain))
			possible_traumas += BT

	if(!LAZYLEN(possible_traumas))
		return

	var/trauma_type = pick(possible_traumas)
	return gain_trauma(trauma_type, resilience)

//Cure a random trauma of a certain resilience level
/obj/item/organ/brain/proc/cure_trauma_type(brain_trauma_type = /datum/brain_trauma, resilience = TRAUMA_RESILIENCE_BASIC)
	var/list/traumas = get_traumas_type(brain_trauma_type, resilience)
	if(LAZYLEN(traumas))
		qdel(pick(traumas))

/obj/item/organ/brain/proc/cure_all_traumas(resilience = TRAUMA_RESILIENCE_BASIC)
	var/list/traumas = get_traumas_type(resilience = resilience)
	for(var/X in traumas)
		qdel(X)

/obj/item/organ/brain/transfer_to_limb(obj/item/bodypart/head/LB, mob/living/carbon/human/C)
	. = ..()
	LB.brain = src
	if(brainmob)
		LB.brainmob = brainmob
		brainmob = null
		LB.brainmob.forceMove(LB)
		LB.brainmob.stat = DEAD

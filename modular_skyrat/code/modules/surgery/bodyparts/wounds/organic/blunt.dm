//skyrat edit
/*
	Bones
*/
// TODO: well, a lot really, but i'd kill to get overlays and a bonebreaking effect like Blitz: The League, similar to electric shock skeletons

/*
	Base definition
*/
/datum/wound/blunt
	sound_effect = 'modular_skyrat/sound/gore/crack1.ogg'
	wound_type = WOUND_LIST_BLUNT

	associated_alerts = list()

	/// Have we been taped?
	var/taped
	/// Have we been bone gel'd?
	var/gelled
	/// If we did the gel + surgical tape healing method for fractures, how many regen points we need
	var/regen_points_needed
	/// Our current counter for gel + surgical tape regeneration
	var/regen_points_current
	/// If we suffer severe head booboos, we can get brain traumas tied to them
	var/datum/brain_trauma/active_trauma
	/// What brain trauma group, if any, we can draw from for head wounds
	var/brain_trauma_group
	/// If we deal brain traumas, when is the next one due?
	var/next_trauma_cycle
	/// How long do we wait +/- 20% for the next trauma?
	var/trauma_cycle_cooldown

	infection_chance = 0
	infection_rate = 0
	base_treat_time = 4 SECONDS
	biology_required = list(HAS_BONE)
	required_status = BODYPART_ORGANIC
	pain_amount = 20
	wound_flags = (WOUND_SOUND_HINTS | WOUND_SEEPS_GAUZE | WOUND_VISIBLE_THROUGH_CLOTHING | WOUND_MANGLES_BONE)

/*
	Overwriting of base procs
*/

/datum/wound/blunt/Destroy()
	. = ..()
	if(active_trauma)
		QDEL_NULL(active_trauma)

/datum/wound/blunt/wound_injury(datum/wound/old_wound = null)
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group)
		processes = TRUE
		active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	RegisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/attack_with_hurt_hand)
	var/obj/item/bodypart/child
	if(length(limb.children_zones))
		child = victim.get_bodypart(limb.children_zones[1])
	if((limb.held_index && victim.get_item_for_held_index(limb.held_index) && (disabling || prob(30 * severity))) || (child && child.held_index && victim.get_item_for_held_index(child.held_index) && (disabling || prob(30 * severity))))
		var/obj/item/I = victim.get_item_for_held_index(limb.held_index)
		if(istype(I, /obj/item/offhand))
			I = victim.get_inactive_held_item()

		if(I && victim.dropItemToGround(I))
			victim.visible_message("<span class='danger'><b>[victim]</b> drops [I] in shock!</span>", \
								"<span class='userdanger'>The force on my [limb.name] causes me to drop [I]!</span>", \
								vision_distance=COMBAT_MESSAGE_RANGE)
	
	if(severity >= WOUND_SEVERITY_SEVERE)
		if(victim.mind)
			switch(victim.mind.diceroll(STAT_DATUM(end)))
				//Paralyze a bit
				if(DICE_FAILURE)
					victim.DefaultCombatKnockdown(250)
					victim.death_scream()
				//Paralyze and knockdown
				if(DICE_CRIT_FAILURE)
					victim.DefaultCombatKnockdown(400)
					victim.Paralyze(350)
					victim.death_scream()
		else
			victim.DefaultCombatKnockdown(400)
			victim.Paralyze(350)
			victim.death_scream()
	
	update_inefficiencies()

/datum/wound/blunt/remove_wound(ignore_limb, replaced)
	limp_slowdown = 0
	QDEL_NULL(active_trauma)
	if(victim)
		UnregisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	return ..()

/datum/wound/blunt/handle_process()
	. = ..()
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group && world.time > next_trauma_cycle)
		if(active_trauma)
			QDEL_NULL(active_trauma)
		else
			active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	if(!regen_points_needed)
		return

	regen_points_current += 0.2
	if(GET_STAT_LEVEL(victim, end) >= (MAX_STAT/2))
		regen_points_current += 0.2
	if(GET_STAT_LEVEL(victim, end) >= ((MAX_STAT/4)*3))
		regen_points_current += 0.2
	
	if(prob(severity * 1.5))
		victim.custom_pain("I feel a sharp pain on my [limb] as my bones reform!", \
					max(1, severity - WOUND_SEVERITY_TRIVIAL) * 15)

	if(regen_points_current > regen_points_needed)
		if(!victim || !limb)
			qdel(src)
			return
		to_chat(victim, "<span class='green'>My [limb.name] has recovered from my [lowertext(name)]!</span>")
		remove_wound()

/// If we're a human who's punching something with a broken arm, we might hurt ourselves doing so
/datum/wound/blunt/proc/attack_with_hurt_hand(mob/M, atom/target, proximity)
	if(victim.get_active_hand() != limb || victim.a_intent == INTENT_HELP || !ismob(target) || severity <= WOUND_SEVERITY_MODERATE)
		return

	// With a severe or critical wound, you have a 20% or so chance to proc pain on hit
	if(prob((severity - WOUND_SEVERITY_TRIVIAL) * 20))
		// And you have a 70% or 50% chance to actually land the blow, respectively
		if(prob(70 - 20 * (severity - 1)))
			to_chat(victim, "<span class='userdanger'>The fracture in my [limb.name] shoots with pain as i strike [target]!</span>")
			limb.receive_damage(brute=rand(1,5), wound_bonus = CANT_WOUND)
		else
			victim.visible_message("<span class='danger'><b>[victim]</b> weakly strikes [target] with [victim.p_their()] broken [limb.name], recoiling from pain!</span>", \
				"<span class='userdanger'>I fail to strike [target] as the fracture in my [limb.name] lights up in unbearable pain!</span>", \
				vision_distance=COMBAT_MESSAGE_RANGE)
			victim.agony_scream()
			victim.Stun(0.5 SECONDS)
			limb.receive_damage(brute=rand(2,7), wound_bonus = CANT_WOUND)
			return COMPONENT_NO_ATTACK_HAND

/datum/wound/blunt/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(!victim || victim.stat == DEAD || wounding_dmg < WOUND_MINIMUM_DAMAGE)
		return
	
	if(severity >= WOUND_SEVERITY_SEVERE)
		if(prob(round(max(wounding_dmg/10, 1), 1)))
			for(var/obj/item/organ/O in victim.getorganszone(limb.body_zone, TRUE))
				victim.adjustOrganLoss(O.slot, rand(1, wounding_dmg/2), O.maxHealth)
	
	if(limb.body_zone in list(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_ARM))
		if(prob(round(max(wounding_dmg/10, 1), 1) * (max(1, severity - WOUND_SEVERITY_TRIVIAL) * 10)))
			var/obj/item/oops = victim?.get_item_for_held_index(limb?.held_index)
			if(oops)
				victim?.dropItemToGround(oops)
			to_chat(victim, "<span class='danger'>I drop [oops] in excruciating pain!</span>")
		if(prob(max(1, severity - WOUND_SEVERITY_TRIVIAL) * 10))
			victim.agony_scream()
	
	if(limb.body_zone == BODY_ZONE_PRECISE_GROIN && prob(15 * max(1, severity - WOUND_SEVERITY_TRIVIAL)))
		victim?.Paralyze(severity * 3)
		to_chat(victim, "<span class='danger'>The excruciating pain on my [limb] paralyzes me!</span>")
	
	if(limb.body_zone == BODY_ZONE_CHEST && !HAS_TRAIT(victim, TRAIT_NOBREATH) && severity >= WOUND_SEVERITY_MODERATE)
		var/oxy_dmg = round(rand(1, (wounding_dmg/5) * (max(1, severity - WOUND_SEVERITY_TRIVIAL))))
		victim.adjustOxyLoss(oxy_dmg)

	if(limb.body_zone == BODY_ZONE_HEAD && prob((severity - WOUND_SEVERITY_TRIVIAL + 1) * 12))
		to_chat(victim, "<span class='userdanger'>The strike on my [severity >= WOUND_SEVERITY_SEVERE ? "broken" : (severity >= WOUND_SEVERITY_MODERATE ? "dislocated" : "damaged")] [limb.name] hurts like hell!</span>")
		victim.adjust_blurriness(rand(1 * (severity - WOUND_SEVERITY_TRIVIAL), 10 * (severity - WOUND_SEVERITY_TRIVIAL)))
		victim.confused += max(25, rand(1 * (severity - WOUND_SEVERITY_TRIVIAL), 10 * (severity - WOUND_SEVERITY_TRIVIAL)))
		if(prob(wounding_dmg))
			victim.adjustBrainLoss(rand(1, 4) * (severity - WOUND_SEVERITY_TRIVIAL))
	
	//George floyd says: I CAN'T BREATHE!
	if(limb.body_zone == BODY_ZONE_PRECISE_NECK && prob((severity - WOUND_SEVERITY_TRIVIAL + 1) * 20))
		if(wounding_dmg >= 10)
			to_chat(victim, "<span class='userdanger'>I can't breathe!</span>")
		victim.adjustOxyLoss(min(15, wounding_dmg))

/datum/wound/blunt/get_examine_description(mob/user)
	if(!limb.current_gauze && !gelled && !taped)
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

		msg = "<B>[victim.p_their(TRUE)] [limb.name] is [sling_condition] fastened in a sling of [limb.current_gauze.name]</B>"

	if(taped)
		msg += ", <span class='notice'>and appears to be reforming itself under some surgical tape</span>"
	else if(gelled)
		msg += ", <span class='notice'>with fizzing flecks of blue bone gel sparking off the bone</span>"
	return "<B>[msg]!</B>"

/*
	New common procs for /datum/wound/blunt/
*/

/datum/wound/blunt/proc/update_inefficiencies()
	if(limb.body_zone in list(BODY_ZONE_PRECISE_GROIN, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_GROIN))
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

	if(initial(disabling))
		disabling = !limb.current_gauze

	limb.update_wounds()

/*
	Moderate (Joint Dislocation)
*/

/datum/wound/blunt/moderate
	name = "Joint Dislocation"
	desc = "Patient's bone has been unset from socket, causing pain and reduced motor function."
	treat_text = "Recommended application of bonesetter to affected limb, though manual relocation by applying an aggressive grab to the patient and helpfully interacting with afflicted limb may suffice."
	examine_desc = "is awkwardly jammed out of place"
	occur_text = "jerks violently and becomes unseated"
	severity = WOUND_SEVERITY_MODERATE
	viable_zones = LIMB_BODYPARTS
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 5
	threshold_minimum = 35
	threshold_penalty = 15
	treatable_tool = TOOL_BONESET
	status_effect_type = /datum/status_effect/wound/blunt/moderate
	associated_alerts = list()
	can_self_treat = TRUE
	pain_amount = 20
	flat_damage_roll_increase = 5
	descriptive = "A bone is dislocated!"
	wound_flags = (WOUND_SOUND_HINTS | WOUND_SEEPS_GAUZE | WOUND_VISIBLE_THROUGH_CLOTHING)

/datum/wound/blunt/moderate/crush()
	if(prob(33))
		victim.visible_message("<span class='danger'><b>[victim]</b>'s dislocated [limb.name] pops back into place!</span>", "<span class='userdanger'>My dislocated [limb.name] pops back into place! Ow!</span>")
		remove_wound()

/datum/wound/blunt/moderate/self_treat(mob/living/carbon/user, first_time = FALSE)
	. = ..()
	if(.)
		return TRUE
	
	var/time = base_treat_time
	var/time_mod = 2
	var/custom_location

	if(limb.body_zone == BODY_ZONE_CHEST)
		custom_location = "ribs"
	else if(limb.body_zone == BODY_ZONE_PRECISE_GROIN)
		custom_location = "hips"
	
	if(first_time)
		user.visible_message("<span class='notice'>[user] starts to strain their [custom_location ? custom_location : limb.name] back in place...</span>", "<span class='notice'>I start straining my [custom_location ? custom_location : limb.name] back in place...</span>")
	
	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, time * time_mod, target = victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid)*0.75) >= DICE_SUCCESS)
		user.visible_message("<span class='danger'>[user] snaps their own [custom_location ? custom_location : limb.name] back in place!</span>", "<span class='danger'>I snap my [custom_location ? custom_location : limb.name] back into place!</span>")
		victim.agony_scream()
		limb.receive_damage(brute=12, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message("<span class='danger'>[user] wrenches their own dislocated [custom_location ? custom_location : limb.name] around painfully!</span>", "<span class='danger'>I wrench my own dislocated [custom_location ? custom_location : limb.name] around painfully!</span>")
		limb.receive_damage(brute=8, wound_bonus=CANT_WOUND)
		self_treat(user, FALSE)
	return

/datum/wound/blunt/moderate/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone || user.a_intent == INTENT_GRAB)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>I must have <b>[victim]</b> in an aggressive grab to manipulate [victim.p_their()] [lowertext(name)]!</span>")
		return TRUE

	if(user.grab_state >= GRAB_AGGRESSIVE)
		user.visible_message("<span class='danger'>[user] begins twisting and straining <b>[victim]</b>'s dislocated [limb.name]!</span>", "<span class='notice'>I begin twisting and straining <b>[victim]</b>'s dislocated [limb.name]...</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] begins twisting and straining my dislocated [limb.name]!</span>")
		if(user.a_intent == INTENT_HELP)
			chiropractice(user)
		else
			malpractice(user)
		return TRUE

/// If someone is snapping our dislocated joint back into place by hand with an aggro grab and help intent
/datum/wound/blunt/moderate/proc/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time
	var/time_mod = 1

	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, time * time_mod, target = victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid)*0.75) >= DICE_SUCCESS)
		user.visible_message("<span class='danger'>[user] snaps <b>[victim]</b>'s dislocated [limb.name] back into place!</span>", "<span class='notice'>I snap <b>[victim]</b>'s dislocated [limb.name] back into place!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] snaps my dislocated [limb.name] back into place!</span>")
		victim.agony_scream()
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message("<span class='danger'>[user] wrenches <b>[victim]</b>'s dislocated [limb.name] around painfully!</span>", "<span class='danger'>I wrench <b>[victim]</b>'s dislocated [limb.name] around painfully!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] wrenches my dislocated [limb.name] around painfully!</span>")
		limb.receive_damage(brute=7, wound_bonus=CANT_WOUND)
		chiropractice(user)

/// If someone is snapping our dislocated joint into a fracture by hand with an aggro grab and harm or disarm intent
/datum/wound/blunt/moderate/proc/malpractice(mob/living/carbon/human/user)
	. = FALSE
	if(user.next_move >= world.time)
		return
	
	var/dice = DICE_SUCCESS
	if(user.mind)
		dice = user.mind.diceroll(GET_STAT_LEVEL(user, str)*0.75, GET_SKILL_LEVEL(user, melee)*0.5)
	if(dice >= DICE_SUCCESS)
		victim.agony_scream()
		if(dice >= DICE_CRIT_SUCCESS)
			replace_wound(/datum/wound/blunt/critical, silent = TRUE)
		else
			replace_wound(/datum/wound/blunt/severe, silent = TRUE)
		limb.receive_damage(brute=GET_STAT_LEVEL(user, str)*0.75, wound_bonus = CANT_WOUND)
		user.visible_message("<span class='danger'>[user] snaps <b>[victim]</b>'s dislocated [limb.name] with a sickening crack![victim.wound_message]</span>", "<span class='danger'>I snap <b>[victim]</b>'s dislocated [limb.name] with a sickening crack![victim.wound_message]</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] snaps my dislocated [limb.name] with a sickening crack![victim.wound_message]</span>")
	else
		user.visible_message("<span class='danger'>[user] wrenches <b>[victim]</b>'s dislocated [limb.name] around painfully![victim.wound_message]</span>", "<span class='danger'>I wrench <b>[victim]</b>'s dislocated [limb.name] around painfully![victim.wound_message]</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] wrenches my dislocated [limb.name] around painfully![victim.wound_message]</span>")
		limb.receive_damage(brute=GET_STAT_LEVEL(user, str)*0.5, wound_bonus = CANT_WOUND)
	//Clean the wound string either way
	victim.wound_message = ""
	user.changeNext_move(CLICK_CD_GRABBING)
	return TRUE

/datum/wound/blunt/moderate/treat(obj/item/I, mob/user)
	if(victim == user)
		victim.visible_message("<span class='danger'>[user] begins resetting [victim.p_their()] [limb.name] with [I].</span>", "<span class='warning'>I begin resetting my [limb.name] with [I]...</span>")
	else
		user.visible_message("<span class='danger'>[user] begins resetting <b>[victim]</b>'s [limb.name] with [I].</span>", "<span class='notice'>I begin resetting <b>[victim]</b>'s [limb.name] with [I]...</span>")

	var/time_mod = (user == victim ? 1.5 : 1)
	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	if(!do_after(user, base_treat_time * time_mod, target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	if(victim == user)
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		victim.visible_message("<span class='danger'>[user] finishes resetting [victim.p_their()] [limb.name]!</span>", "<span class='userdanger'>I reset my [limb.name]!</span>")
	else
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=7, wound_bonus=CANT_WOUND)
		user.visible_message("<span class='danger'>[user] finishes resetting <b>[victim]</b>'s [limb.name]!</span>", "<span class='nicegreen'>I finish resetting <b>[victim]</b>'s [limb.name]!</span>", victim)
		to_chat(victim, "<span class='userdanger'>[user] resets my [limb.name]!</span>")

	victim.agony_scream()
	qdel(src)

/*
	Moderate (Rib Dislocation)

	I didn't use the parent because ribs simply require way different text and symptoms.
*/

/datum/wound/blunt/moderate/ribcage
	name = "Rib Dislocation"
	desc = "Patient has dislocated ribs, causing extreme pain and labored breathing."
	treat_text = "Recommended application of bonesetter to the chest, though massaging cartilage by applying an aggressive grab to the laid down patient and helpfully interacting with their chest may suffice."
	examine_desc = "is red and swollen"
	occur_text = "pops loudly"
	severity = WOUND_SEVERITY_MODERATE
	viable_zones = list(BODY_ZONE_CHEST)
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 5
	threshold_minimum = 35
	threshold_penalty = 15
	treatable_tool = TOOL_BONESET
	status_effect_type = /datum/status_effect/wound/blunt/moderate
	associated_alerts = list()
	pain_amount = 20 //Hurts a lot, almost a hairline fracture

/datum/wound/blunt/moderate/ribcage/crush()
	if(prob(33))
		victim.visible_message("<span class='danger'><b>[victim]</b>'s dislocated ribs pop back into place!</span>", "<span class='userdanger'>My dislocated ribs pop back into place! Ow!</span>")
		remove_wound()

/datum/wound/blunt/moderate/ribcage/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone || user.a_intent == INTENT_GRAB)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>I must have <b>[victim]</b> in an aggressive grab to manipulate [victim.p_their()] [lowertext(name)]!</span>")
		return TRUE

	if((user.grab_state >= GRAB_AGGRESSIVE) && (user.a_intent == INTENT_HELP) && victim.lying)
		user.visible_message("<span class='notice'>[user] begins massaging <b>[victim]</b>'s ribs.</span>", "<span class='notice'>I begin massaging <b>[victim]</b>'s dislocated ribs...</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='notice'>[user] begins massaging my dislocated ribs.</span>")
		chiropractice(user)
		return TRUE

/// If someone is massaging the ribs
/datum/wound/blunt/moderate/ribcage/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time
	var/time_mod = 1

	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
		
	if(!do_after(user, time * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
		user.visible_message("<span class='notice'>[user] massages <b>[victim]</b>'s dislocated ribs back in place.</span>", "<span class='notice'>I massage <b>[victim]</b>'s dislocated ribs back into place.</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='notice'>[user] massages my dislocated ribs back into place.</span>")
		victim.agony_scream()
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message("<span class='danger'>[user] grinds <b>[victim]</b>'s rib cartilage around painfully!</span>", "<span class='danger'>I grind <b>[victim]</b>'s rib cartilage around painfully!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] grinds my ribs' cartilage around painfully!</span>")
		limb.receive_damage(brute=8, wound_bonus=CANT_WOUND)
		chiropractice(user)

/datum/wound/blunt/moderate/ribcage/treat(obj/item/I, mob/user)
	if(victim == user)
		victim.visible_message("<span class='danger'>[user] begins resetting [victim.p_their()] ribs with [I].</span>", "<span class='warning'>I begin resetting my ribs with [I]...</span>")
	else
		user.visible_message("<span class='danger'>[user] begins resetting <b>[victim]</b>'s ribs with [I].</span>", "<span class='notice'>I begin resetting <b>[victim]</b>'s ribs with [I]...</span>")
	var/time_mod = (user == victim ? 1.5 : 1)

	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, base_treat_time * time_mod, target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	if(victim == user)
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=15, wound_bonus=CANT_WOUND)
		victim.visible_message("<span class='danger'>[user] finishes resetting [victim.p_their()] ribs!</span>", "<span class='userdanger'>I reset my ribs!</span>")
	else
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		user.visible_message("<span class='danger'>[user] finishes resetting <b>[victim]</b>'s ribs!</span>", "<span class='nicegreen'>I finish resetting <b>[victim]</b>'s ribs!</span>", victim)
		to_chat(victim, "<span class='userdanger'>[user] resets my ribs!</span>")

	victim.agony_scream()
	qdel(src)

/*
	Moderate (Hip Dislocation)
*/

/datum/wound/blunt/moderate/hips
	name = "Hip Dislocation"
	desc = "Patient's thighbone has been forced out of it's socket, causing painful and ineffective locomotion."
	treat_text = "Recommended application of bonesetter to the groin, though manual relocation by applying an aggressive grab to the patient and helpfully interacting with their groin may suffice."
	examine_desc = "seems to be sitting at a weird angle"
	occur_text = "pops loudly"
	severity = WOUND_SEVERITY_MODERATE
	viable_zones = list(BODY_ZONE_PRECISE_GROIN)
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 10
	threshold_minimum = 35
	threshold_penalty = 15
	treatable_tool = TOOL_BONESET
	status_effect_type = /datum/status_effect/wound/blunt/moderate
	associated_alerts = list()
	pain_amount = 20 //Hurts more than your average dislocation

/datum/wound/blunt/moderate/hips/crush()
	if(prob(33))
		victim.visible_message("<span class='danger'><b>[victim]</b>'s dislocated femoral bones pop back into [victim.p_their()] [limb.name]!</span>", "<span class='userdanger'>My dislocated femoral bones pop back into my [limb.name]! Ow!</span>")
		remove_wound()

/datum/wound/blunt/moderate/hips/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone || user.a_intent == INTENT_GRAB)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>I must have <b>[victim]</b> in an aggressive grab to manipulate [victim.p_their()] [lowertext(name)]!</span>")
		return TRUE

	if((user.grab_state >= GRAB_AGGRESSIVE) && (user.a_intent == INTENT_HELP) && victim.lying)
		user.visible_message("<span class='danger'>[user] begins forcing <b>[victim]</b>'s femur into it's socket!</span>", "<span class='notice'>I begin forcing <b>[victim]</b>'s femurs into their sockets...</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] begins forcing my femur in place!</span>")
		chiropractice(user)
		return TRUE

/// If someone is massaging the ribs
/datum/wound/blunt/moderate/hips/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time
	var/time_mod = 1

	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, time * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) >= DICE_SUCCESS)
		user.visible_message("<span class='danger'>[user] forces <b>[victim]</b>'s femoral bone back in place!</span>", "<span class='notice'>I force <b>[victim]</b>'s dislocated femoral bone back in place.</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] forces my femoral bone in place!</span>")
		victim.agony_scream()
		limb.receive_damage(brute=15, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message("<span class='danger'>[user] painfully wrenches <b>[victim]</b>'s femur around!</span>", "<span class='danger'>I painfully wrench <b>[victim]</b>'s femur around!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] painfully wrenches my femur around!</span>")
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		chiropractice(user)

/datum/wound/blunt/moderate/hips/treat(obj/item/I, mob/user)
	if(victim == user)
		victim.visible_message("<span class='danger'>[user] begins resetting [victim.p_their()] femur with [I].</span>", "<span class='warning'>I begin resetting my femur with [I]...</span>")
	else
		user.visible_message("<span class='danger'>[user] begins resetting <b>[victim]</b>'s femur with [I].</span>", "<span class='notice'>I begin resetting <b>[victim]</b>'s femur with [I]...</span>")

	//Medical skill affects the speed of the do_mob
	var/time_mod = (user == victim ? 1.5 : 1)
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, base_treat_time * time_mod, target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	if(victim == user)
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=15, wound_bonus=CANT_WOUND)
		victim.visible_message("<span class='danger'>[user] finishes resetting [victim.p_their()] femur!</span>", "<span class='userdanger'>I reset my femur!</span>")
	else
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=7, wound_bonus=CANT_WOUND)
		user.visible_message("<span class='danger'>[user] finishes resetting <b>[victim]</b>'s femur!</span>", "<span class='nicegreen'>I finish resetting <b>[victim]</b>'s femur!</span>", victim)
		to_chat(victim, "<span class='userdanger'>[user] resets my femur!</span>")

	victim.agony_scream()
	qdel(src)

/*
	Moderate (Jaw Dislocation)
*/

/datum/wound/blunt/moderate/jaw
	name = "Jaw Dislocation"
	desc = "Patient has a dislocated jaw, causing pain and discomfort."
	treat_text = "Recommended application of bonesetter to the head, though forcing the jaw back in place by applying an aggressive grab to the patient and helpfully interacting with their head may suffice."
	examine_desc = "is red and swollen"
	occur_text = "snaps audibly"
	severity = WOUND_SEVERITY_MODERATE
	viable_zones = list(BODY_ZONE_PRECISE_MOUTH)
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 5
	threshold_minimum = 35
	threshold_penalty = 15
	treatable_tool = TOOL_BONESET
	status_effect_type = /datum/status_effect/wound/blunt/moderate
	associated_alerts = list()
	pain_amount = 20 //Hurts a bit more
	descriptive = "The jaw is dislocated!"

/datum/wound/blunt/moderate/jaw/crush()
	if(prob(33))
		victim.visible_message("<span class='danger'><b>[victim]</b>'s dislocated jaw pops back into place!</span>", "<span class='userdanger'>My dislocated jaw pops back into place! Ow!</span>")
		remove_wound()

/datum/wound/blunt/moderate/jaw/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone || user.a_intent == INTENT_GRAB)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>I must have <b>[victim]</b> in an aggressive grab to manipulate [victim.p_their()] [lowertext(name)]!</span>")
		return TRUE

	if((user.grab_state >= GRAB_AGGRESSIVE) && (user.a_intent == INTENT_HELP))
		user.visible_message("<span class='notice'>[user] begins forcing <b>[victim]</b>'s jaw back in place.</span>", "<span class='notice'>I begin forcing <b>[victim]</b>'s jaw back in place...</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='notice'>[user] begins forcing my jaw back in place.</span>")
		chiropractice(user)
		return TRUE

/// If someone is treating the jaw
/datum/wound/blunt/moderate/jaw/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time
	var/time_mod = 1

	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, time * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) >= DICE_SUCCESS)
		user.visible_message("<span class='notice'>[user] jams <b>[victim]</b>'s jaw back in place.</span>", "<span class='notice'>I jam <b>[victim]</b>'s dislocated jaaw back into place.</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='notice'>[user] jams my dislocated jaw back into place.</span>")
		victim.agony_scream()
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message("<span class='danger'>[user] moves <b>[victim]</b>'s jaw around painfully!</span>", "<span class='danger'>I move <b>[victim]</b>'s jaw around painfully!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] moves my jaw around painfully!</span>")
		limb.receive_damage(brute=8, wound_bonus=CANT_WOUND)
		chiropractice(user)

/datum/wound/blunt/moderate/jaw/treat(obj/item/I, mob/user)
	if(victim == user)
		victim.visible_message("<span class='danger'>[user] begins resetting [victim.p_their()] jaw with [I].</span>", "<span class='warning'>I begin resetting my jaw with [I]...</span>")
	else
		user.visible_message("<span class='danger'>[user] begins resetting <b>[victim]</b>'s jaw with [I].</span>", "<span class='notice'>I begin resetting <b>[victim]</b>'s jaw with [I]...</span>")
	
	//Medical skill affects the speed of the do_mob
	var/time_mod = (user == victim ? 1.5 : 1)
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, base_treat_time * time_mod, target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	if(victim == user)
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=15, wound_bonus=CANT_WOUND)
		victim.visible_message("<span class='danger'>[user] finishes resetting [victim.p_their()] jaw!</span>", "<span class='userdanger'>I reset my jaw!</span>")
	else
		if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
			limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		user.visible_message("<span class='danger'>[user] finishes resetting <b>[victim]</b>'s jaw!</span>", "<span class='nicegreen'>I finish resetting <b>[victim]</b>'s jaw!</span>", victim)
		to_chat(victim, "<span class='userdanger'>[user] resets my jaw!</span>")

	victim.agony_scream()
	qdel(src)

/*
	Severe (Hairline Fracture)
*/

/datum/wound/blunt/severe
	name = "Hairline Fracture"
	desc = "Patient's bone has suffered a crack in the foundation, causing serious pain and reduced limb functionality."
	treat_text = "Recommended light surgical application of bone gel, though a sling of medical gauze will prevent worsening situation."
	examine_desc = "appears dented and grotesquely swollen"
	occur_text = "cracks audibly and develops a nasty looking bruise"
	severity = WOUND_SEVERITY_SEVERE
	viable_zones = ALL_BODYPARTS_MINUS_EYES
	interaction_efficiency_penalty = 2
	limp_slowdown = 10
	sound_effect = 'modular_skyrat/sound/gore/crack2.ogg'
	threshold_minimum = 60
	threshold_penalty = 30
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/severe
	treat_priority = TRUE
	brain_trauma_group = BRAIN_TRAUMA_MILD
	trauma_cycle_cooldown = 1.5 MINUTES
	pain_amount = 30
	flat_damage_roll_increase = 10
	descriptive = "A bone is fractured!"

/datum/wound/blunt/critical
	name = "Compound Fracture"
	desc = "Patient's bones have suffered multiple gruesome fractures, causing significant pain and near uselessness of limb."
	treat_text = "Immediate binding of affected limb, followed by surgical intervention ASAP."
	examine_desc = "is mangled and pulped, with exposed and shattered pieces of bone"
	occur_text = "cracks apart, exposing broken bones to open air"
	severity = WOUND_SEVERITY_CRITICAL
	viable_zones = ALL_BODYPARTS_MINUS_EYES
	interaction_efficiency_penalty = 4
	limp_slowdown = 15
	sound_effect = 'modular_skyrat/sound/gore/crack3.ogg'
	threshold_minimum = 115
	threshold_penalty = 50
	disabling = TRUE
	treatable_by = list(/obj/item/stack/sticky_tape/surgical, /obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/critical
	treat_priority = TRUE
	brain_trauma_group = BRAIN_TRAUMA_SEVERE
	trauma_cycle_cooldown = 2.5 MINUTES
	pain_amount = 40
	flat_damage_roll_increase = 15
	descriptive = "A bone is shattered!"

// doesn't make much sense for "a" bone to stick out of your head
/datum/wound/blunt/critical/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited)
	if(L.body_zone == BODY_ZONE_HEAD)
		occur_text = "splits open, exposing a bare, cracked skull through the flesh and blood"
		examine_desc = "has an unsettling indent, with bits of skull poking out"
	else if(L.body_zone == BODY_ZONE_PRECISE_GROIN)
		occur_text = "cracks apart, exposing fragments of the pelvis to open air"
		examine_desc = "looks mushy and mangled, parts of it exposed to the elements"
	else if(L.body_zone == BODY_ZONE_PRECISE_NECK)
		// A compound fractured neck will always instantly kill you
		// (unless you're dreamer!)
		if(!is_dreamer(L.owner))
			L.owner.death_scream()
			L.owner.death()
	. = ..()

/// if someone is using bone gel on our wound
/datum/wound/blunt/proc/gel(obj/item/stack/medical/bone_gel/I, mob/user)
	if(gelled)
		to_chat(user, "<span class='warning'>[user == victim ? "My" : "<b>[victim]</b>'s"] [limb.name] is already coated with bone gel!</span>")
		return

	user.visible_message("<span class='danger'>[user] begins hastily applying [I] to <b>[victim]</b>'s' [limb.name]...</span>", "<span class='warning'>I begin hastily applying [I] to [user == victim ? "my" : "<b>[victim]</b>'s"] [limb.name], disregarding the warning label...</span>")

	//Medical skill affects the speed of the do_mob
	var/time_mod = (user == victim ? 1.5 : 1)
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, base_treat_time * time_mod, target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	if(!I.use(1))
		to_chat(user, "<span class='warning'>There aren't enough stacks of [I.name] to heal \the [src.name]!</span>")
		return
	
	victim.agony_scream()
	if(user != victim)
		user.visible_message("<span class='notice'>[user] finishes applying [I] to <b>[victim]</b>'s [limb.name], emitting a fizzing noise!</span>", "<span class='notice'>I finish applying [I] to <b>[victim]</b>'s [limb.name]!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] finishes applying [I] to my [limb.name], and i can feel the bones exploding with pain as they begin melting and reforming!</span>")
	else
		if(!HAS_TRAIT(user, TRAIT_PAINKILLER))
			var/painkiller_bonus = 0
			if(victim.drunkenness)
				painkiller_bonus += 5
			if(victim.reagents && victim.reagents.has_reagent(/datum/reagent/medicine/morphine))
				painkiller_bonus += 10
			if(victim.reagents && victim.reagents.has_reagent(/datum/reagent/determination))
				painkiller_bonus += 5
			
			var/base_prob = 12.5

			//Medical skill affects the chance of fucking up
			if(user.mind)
				var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
				if(firstaid)
					base_prob *= firstaid.get_medicalstack_mod()

			if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75, mod = -((100 - base_prob)/4)) < DICE_SUCCESS) // 25%/45% chance to fail self-applying with severe and critical wounds, modded by painkillers
				victim.visible_message("<span class='danger'><b>[victim]</b> fails to finish applying [I] to [victim.p_their()] [limb.name], passing out from the pain!</span>", "<span class='notice'>I black out from the pain of applying [I] to my [limb.name] before i can finish!</span>")
				victim.AdjustUnconscious(5 SECONDS)
				return
		victim.visible_message("<span class='notice'><b>[victim]</b> finishes applying [I] to [victim.p_their()] [limb.name], grimacing from the pain!</span>", "<span class='notice'>I finish applying [I] to my [limb.name], and my bones explode in pain!</span>")

	limb.receive_damage(15, stamina=75, wound_bonus=CANT_WOUND)
	if(!gelled)
		gelled = TRUE

/// if someone is using surgical tape on our wound
/datum/wound/blunt/proc/tape(obj/item/stack/sticky_tape/surgical/I, mob/user)
	if(!gelled)
		to_chat(user, "<span class='warning'>[user == victim ? "My" : "<b>[victim]</b>'s"] [limb.name] must be coated with bone gel to perform this emergency operation!</span>")
		return
	if(taped)
		to_chat(user, "<span class='warning'>[user == victim ? "My" : "<b>[victim]</b>'s"] [limb.name] is already wrapped in [I.name] and reforming!</span>")
		return

	user.visible_message("<span class='danger'>[user] begins applying [I] to <b>[victim]</b>'s' [limb.name]...</span>", "<span class='warning'>I begin applying [I] to [user == victim ? "my" : "<b>[victim]</b>'s"] [limb.name]...</span>")

	//aaaaaaaaaaaaaaaaaaa
	var/time_mod = (user == victim ? 1.5 : 1)
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, base_treat_time * time_mod, target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return
	if(!I.use(1))
		to_chat(user, "<span class='warning'>There aren't enough stacks of [I.name] to heal \the [src.name]!</span>")
		return
	
	regen_points_current = 0
	regen_points_needed = 15 * (user == victim ? 1.5 : 1) * (severity - WOUND_SEVERITY_TRIVIAL)
	if(user != victim)
		user.visible_message("<span class='notice'>[user] finishes applying [I] to <b>[victim]</b>'s [limb.name], emitting a fizzing noise!</span>", "<span class='notice'>I finish applying [I] to <b>[victim]</b>'s [limb.name]!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='green'>[user] finishes applying [I] to my [limb.name], i immediately begin to feel my bones start to reform!</span>")
	else
		victim.visible_message("<span class='notice'><b>[victim]</b> finishes applying [I] to [victim.p_their()] [limb.name], !</span>", "<span class='green'>I finish applying [I] to my [limb.name], and i immediately begin to feel my bones start to reform!</span>")

	taped = TRUE
	processes = TRUE

/datum/wound/blunt/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/bone_gel))
		gel(I, user)
	else if(istype(I, /obj/item/stack/sticky_tape/surgical))
		tape(I, user)

/datum/wound/blunt/get_scanner_description(mob/user)
	. = ..()

	. += "<div class='ml-3'>"

	if(severity >= WOUND_SEVERITY_SEVERE)
		if(!gelled)
			. += "Alternative Treatment: Apply bone gel directly to injured limb, then apply surgical tape to begin bone regeneration. This is both excruciatingly painful and slow, and only recommended in dire circumstances.\n"
		else if(!taped)
			. += "<span class='notice'>Continue Alternative Treatment: Apply surgical tape directly to injured limb to begin bone regeneration. Note, this is both excruciatingly painful and slow.</span>\n"
		else
			. += "<span class='notice'>Note: Bone regeneration in effect. Bone is [round((regen_points_current/regen_points_needed) * 100)]% regenerated.</span>\n"

	if(limb.body_zone == BODY_ZONE_HEAD)
		. += "Cranial Trauma Detected: Patient will suffer random bouts of [severity == WOUND_SEVERITY_SEVERE ? "mild" : "severe"] brain traumas until bone is repaired."
	else if(limb.body_zone == BODY_ZONE_CHEST && victim.blood_volume)
		. += "Ribcage Trauma Detected: Further trauma to chest is likely to worsen internal bleeding until bone is repaired."
	else if(limb.body_zone == BODY_ZONE_PRECISE_GROIN && victim.blood_volume)
		. += "Pelvis Trauma Detected: Further trauma to groin is likely to worsen internal bleeding until bone is repaired."
	. += "</div>"

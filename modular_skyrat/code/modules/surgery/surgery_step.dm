//I fuck sex
/datum/surgery_step
	var/name = "NIGGER FAGGOT TRANNY"
	var/list/implements = list()	//format is path = probability of success. alternatively
	var/implement_type = null		//the current type of implement used. This has to be stored, as the actual typepath of the tool may not match the list type.
	var/accept_hand = 0				//does the surgery step require an open hand? If true, ignores implements. Compatible with accept_any_item.
	var/accept_any_item = 0			//does the surgery step accept any item? If true, ignores implements. Compatible with require_hand.
	var/base_time = 10					//how long does the step take for the average niggerr?
	var/repeatable = FALSE			//can this step be repeated?
	var/step_in_progress = FALSE		//are we being done, right now?
	var/list/chems_needed = list()  //list of chems needed to complete the step. Even on success, the step will have no effect if there aren't the chems required in the mob.
	var/require_all_chems = TRUE    //any on the list or all on the list?
	var/silicons_obey_prob = FALSE	//do silicons care about probability of success?
	var/surgery_flags = (STEP_NEEDS_INCISED) //fucking flags
	var/success_multiplier = 1
	var/ignore_clothes = FALSE //Do we check for clothes covering the location?
	var/requires_bodypart = TRUE //Most surgeries need a bodypart to work
	var/requires_bodypart_type = BODYPART_ORGANIC //Prevents you from performing an operation on incorrect limbs. 0 for any limb type
	var/requires_real_bodypart = FALSE	//Some surgeries don't work on limbs that are fake (AKA le item limb)
	var/lying_required = FALSE	//Does the victim need to be lying down?
	var/list/possible_locs = ALL_BODYPARTS //Where this can be performed on
	var/list/target_mobtypes = list(/mob/living/carbon)	//Acceptable mob types
	var/requires_tech //Tech tree datum required to unlock this nigger, will be implemented later

/datum/surgery_step/proc/validate_user(mob/user)
	. = TRUE
	if(!(user.zone_selected in possible_locs))
		. = FALSE

/datum/surgery_step/proc/validate_target(mob/living/target, mob/user)
	. = TRUE
	if(length(target_mobtypes))
		. = FALSE
		for(var/bingus in target_mobtypes)
			if(istype(target, bingus))
				. = TRUE
	if(lying_required && !target.lying)
		. = FALSE
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/mob/living/carbon/human/H = C
		var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
		if(requires_bodypart && !BP)
			. = FALSE
		else if(!requires_bodypart)
			if(BP)
				return FALSE
			return TRUE
		if(istype(H) && !ignore_clothes && H.clothingonpart(BP))
			. = FALSE
		if(requires_bodypart_type && !CHECK_BITFIELD(BP?.status, requires_bodypart_type))
			. = FALSE
		if(CHECK_BITFIELD(surgery_flags, STEP_NEEDS_ENCASED) && !BP?.encased)
			. = FALSE
		var/how_open = BP?.how_open()
		if(CHECK_BITFIELD(surgery_flags, STEP_NEEDS_INCISED) && !CHECK_BITFIELD(how_open, SURGERY_INCISED))
			. = FALSE
		if(CHECK_BITFIELD(surgery_flags, STEP_NEEDS_RETRACTED) && !CHECK_BITFIELD(how_open, SURGERY_RETRACTED))
			. = FALSE
		if(CHECK_BITFIELD(surgery_flags, STEP_NEEDS_DRILLED) && !CHECK_BITFIELD(how_open, SURGERY_DRILLED))
			. = FALSE
		if(CHECK_BITFIELD(surgery_flags, STEP_NEEDS_BROKEN) && !CHECK_BITFIELD(how_open, SURGERY_BROKEN))
			. = FALSE
		if(CHECK_BITFIELD(surgery_flags, STEP_NEEDS_SET_BONES) && !CHECK_BITFIELD(how_open, SURGERY_SET_BONES))
			. = FALSE
		if(user == target)
			var/obj/item/bodypart/active_hand = user.get_active_hand()
			if((active_hand?.body_zone in list(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)) && (user.zone_selected in list(BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND)))
				return FALSE
			if((active_hand?.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)) && (user.zone_selected in list(BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND)))
				return FALSE

/datum/surgery_step/proc/try_op(mob/user, mob/living/target, target_zone, obj/item/tool, try_to_fail = FALSE)
	var/success = FALSE
	if(accept_hand && !tool)
		success = TRUE
	else if(accept_any_item)
		if(tool && tool_check(user, tool, target))
			success = TRUE
	else if(tool)
		for(var/key in implements)
			var/match = FALSE
			if(ispath(key) && istype(tool, key))
				match = TRUE
			else if(tool.tool_behaviour == key)
				match = TRUE
			if(match)
				implement_type = key
				if(tool_check(user, tool, target))
					success = TRUE
					break
	if(success)
		if(!validate_user(user))
			success = FALSE
		if(!validate_target(target, user))
			success = FALSE
		if(target.surgery_steps_in_progress[target_zone])
			success = FALSE
	
	if(success)
		if(get_location_accessible(target, target_zone) || ignore_clothes)
			return initiate(user, target, target_zone, tool, try_to_fail)
	return FALSE

/datum/surgery_step/proc/initiate(mob/user, mob/living/target, target_zone, obj/item/tool, try_to_fail = FALSE)
	target.surgery_steps_in_progress[target_zone] = src
	var/speed_mod = 1
	var/advance = FALSE
	if(preop(user, target, target_zone, tool) == -1)
		target.surgery_steps_in_progress -= target_zone
		return FALSE
	if(tool)
		speed_mod = tool.toolspeed //faster tools mean faster surgeries, but also less experience.
	
	var/delay = base_time * speed_mod
	if(do_after(user, delay, target = target))
		var/prob_chance = 100
		if(implement_type)	//this means it isn't a require hand or any item step.
			prob_chance = implements[implement_type]
		prob_chance *= get_surgery_probability_multiplier(src, target, user)

		if((prob(prob_chance) || (iscyborg(user) && !silicons_obey_prob)) && chem_check(target) && !try_to_fail)
			if(success(user, target, target_zone, tool))
				advance = TRUE
		else
			if(failure(user, target, target_zone, tool))
				advance = TRUE
	target.surgery_steps_in_progress -= target_zone
	return advance

/datum/surgery_step/proc/preop(mob/user, mob/living/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to perform surgery on [target]...</span>",
		"[user] begins to perform surgery on [target].",
		"[user] begins to perform surgery on [target].")

/datum/surgery_step/proc/success(mob/user, mob/living/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You succeed.</span>",
		"[user] succeeds!",
		"[user] finishes.")
	return TRUE

/datum/surgery_step/proc/failure(mob/user, mob/living/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='warning'>You screw up!</span>",
		"<span class='warning'>[user] screws up!</span>",
		"[user] finishes.", TRUE) //By default the patient will notice if the wrong thing has been cut
	return FALSE

/datum/surgery_step/proc/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	return TRUE

/datum/surgery_step/proc/chem_check(mob/living/target)
	if(!LAZYLEN(chems_needed))
		return TRUE
	if(require_all_chems)
		. = TRUE
		for(var/R in chems_needed)
			if(!target.reagents.has_reagent(R))
				return FALSE
	else
		. = FALSE
		for(var/R in chems_needed)
			if(target.reagents.has_reagent(R))
				return TRUE

/datum/surgery_step/proc/get_chem_list()
	if(!LAZYLEN(chems_needed))
		return
	var/list/chems = list()
	for(var/R in chems_needed)
		var/datum/reagent/temp = GLOB.chemical_reagents_list[R]
		if(temp)
			var/chemname = temp.name
			chems += chemname
	return english_list(chems, and_text = require_all_chems ? " and " : " or ")

//Replaces visible_message during operations so only people looking over the surgeon can tell what they're doing, allowing for shenanigans.
/datum/surgery_step/proc/display_results(mob/user, mob/living/carbon/target, self_message, detailed_message, vague_message, target_detailed = FALSE)
	var/list/detailed_mobs = get_hearers_in_view(1, user) //Only the surgeon and people looking over his shoulder can see the operation clearly
	if(!target_detailed)
		detailed_mobs -= target //The patient can't see well what's going on, unless it's something like getting cut
	user.visible_message(detailed_message, self_message, vision_distance = 1, ignored_mobs = target_detailed ? null : target)
	user.visible_message(vague_message, "", ignored_mobs = detailed_mobs)

//Overrides the surgery step to require anasthetics for a smooth surgery
//also lets you do self-surgery again bottom text
/datum/surgery_step/initiate(mob/user, mob/living/target, target_zone, obj/item/tool, try_to_fail = FALSE)
	target.surgery_steps_in_progress[target_zone] = src
	var/speed_mod = (user == target ? 0.25 : 1) //self-surgery is hard
	var/advance = FALSE
	var/obj/item/bodypart/affecting = target.get_bodypart(target_zone)
	if(preop(user, target, target_zone, tool) == -1)
		target.surgery_steps_in_progress -= target_zone
		return FALSE
	
	if(tool)
		speed_mod = tool.toolspeed
	
	if(user.mind)
		var/datum/skills/surgery/surgerye = GET_SKILL(user, surgery)
		if(surgerye)
			speed_mod *= surgerye.get_speed_mod()
			
	if(do_after(user, base_time * speed_mod, target = target))
		var/prob_chance = 100
		if(implement_type)	//this means it isn't a require hand or any item step.
			prob_chance = implements[implement_type]
		else if(!tool)
			prob_chance = accept_hand
		else
			prob_chance = accept_any_item
		if(target == user) //self-surgery is hard
			if(user.mind)
				var/datum/skills/surgery/surgerye = GET_SKILL(user, surgery)
				if(surgerye && surgerye.level <= 10)
					speed_mod *= 0.6
			else
				prob_chance *= 0.6
		if(!target.lying) //doing surgery on someone who's not even lying down is VERY hard
			if(user.mind)
				var/datum/skills/surgery/surgerye = GET_SKILL(user, surgery)
				if(surgerye && surgerye.level < 10)
					prob_chance *= 0.5
			else
				prob_chance *= 0.5
		
		prob_chance *= get_surgery_probability_multiplier(src, target, user)

		var/mob/living/carbon/C = target
		if(istype(C) && C.can_feel_pain() && affecting && affecting.is_organic_limb() && (target.stat <= UNCONSCIOUS) && (target.mob_biotypes & MOB_ORGANIC) && !target.InFullCritical() && !HAS_TRAIT(target, TRAIT_PAINKILLER) && (target.chem_effects[CE_PAINKILLER] < 50))
			if(user.mind)
				var/datum/skills/surgery/surgerye = GET_SKILL(user, surgery)
				if(surgerye && surgerye.level <= 10)
					prob_chance *= surgerye.no_anesthesia_punishment()
			else
				prob_chance *= 0.4
			
			target.visible_message("<span class='warning'>[target] [pick("writhes in pain", "squirms and kicks in agony", "cries in pain as [target.p_their()] body violently jerks")], impeding the surgery!</span>", \
			"<span class='warning'>I[pick(" writhe as agonizing pain surges throught my entire body", " feel burning pain sending my body into a convulsion", " squirm as sickening pain fills every part of me")]!</span>")
			target.emote("scream")
			target.blood_volume -= 5
			target.add_splatter_floor(get_turf(target))
			target.apply_damage(rand(3,6), damagetype = BRUTE, def_zone = target_zone, blocked = FALSE, forced = FALSE, wound_bonus = CANT_WOUND)

		//Dice roll
		var/didntfuckup = TRUE
		if(user.mind && (user.mind.diceroll(GET_STAT_LEVEL(user, int)*0.5, GET_SKILL_LEVEL(user, surgery)*1.5, dicetype = "6d6", mod = -(round(100 - prob_chance)/4), crit = 18) <= DICE_FAILURE))
			didntfuckup = FALSE
		if(didntfuckup || (iscyborg(user) && !silicons_obey_prob && chem_check(target) && !try_to_fail))
			if(success(user, target, target_zone, tool))
				advance = TRUE
		else
			if(failure(user, target, target_zone, tool))
				advance = TRUE
		spread_germs_to_bodypart(affecting, user, tool)
	target.surgery_steps_in_progress -= target_zone
	return advance

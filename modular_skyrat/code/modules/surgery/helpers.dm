/proc/find_cauterizing_tool(list/item_list)
	for(var/obj/item/I in item_list)
		if(I.tool_behaviour == TOOL_CAUTERY || I.get_temperature() > 300)
			return I
		else if(istype(I, /obj/item/stack/medical/suture) || istype(I, /obj/item/stack/medical/gauze))
			return I
	return FALSE

/proc/get_location_modifier(mob/M)
	var/turf/T = get_turf(M)
	if(locate(/obj/structure/table/optable, T))
		return 1
	else if(locate(/obj/structure/table, T))
		return 0.8
	else if(locate(/obj/structure/bed, T))
		return 0.7
	else
		return 0.5

/proc/get_surgery_probability_multiplier(datum/surgery_step/step, mob/target, mob/user)
	var/probability = get_location_modifier(target)
	return probability + step.success_multiplier

/proc/get_location_accessible(mob/M, location)
	var/covered_locations = 0	//based on body_parts_covered
	var/face_covered = 0	//based on flags_inv
	var/eyesmouth_covered = 0	//based on flags_cover
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		for(var/obj/item/clothing/I in list(C.back, C.wear_mask, C.head))
			covered_locations |= I.body_parts_covered
			face_covered |= I.flags_inv
			eyesmouth_covered |= I.flags_cover
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			for(var/obj/item/I in list(H.wear_suit, H.w_uniform, H.w_underwear, H.w_socks, H.w_shirt, H.shoes, H.belt, H.gloves, H.wrists, H.glasses, H.ears, H.ears_extra)) //skyrat edit
				covered_locations |= I.body_parts_covered
				face_covered |= I.flags_inv
				eyesmouth_covered |= I.flags_cover

	switch(location)
		if(BODY_ZONE_HEAD)
			if(covered_locations & HEAD)
				return FALSE
		if(BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE)
			if(covered_locations & HEAD || face_covered & HIDEEYES || eyesmouth_covered & GLASSESCOVERSEYES)
				return FALSE
		if(BODY_ZONE_PRECISE_MOUTH)
			if(covered_locations & HEAD || face_covered & HIDEFACE || eyesmouth_covered & MASKCOVERSMOUTH || eyesmouth_covered & HEADCOVERSMOUTH)
				return FALSE
		if(BODY_ZONE_CHEST)
			if(covered_locations & CHEST)
				return FALSE
		if(BODY_ZONE_PRECISE_GROIN)
			if(covered_locations & GROIN)
				return FALSE
		if(BODY_ZONE_L_ARM)
			if(covered_locations & ARM_LEFT)
				return FALSE
		if(BODY_ZONE_R_ARM)
			if(covered_locations & ARM_RIGHT)
				return FALSE
		if(BODY_ZONE_L_LEG)
			if(covered_locations & LEG_LEFT)
				return FALSE
		if(BODY_ZONE_R_LEG)
			if(covered_locations & LEG_RIGHT)
				return FALSE
		if(BODY_ZONE_PRECISE_L_HAND)
			if(covered_locations & HAND_LEFT)
				return FALSE
		if(BODY_ZONE_PRECISE_R_HAND)
			if(covered_locations & HAND_RIGHT)
				return FALSE
		if(BODY_ZONE_PRECISE_L_FOOT)
			if(covered_locations & FOOT_LEFT)
				return FALSE
		if(BODY_ZONE_PRECISE_R_FOOT)
			if(covered_locations & FOOT_RIGHT)
				return FALSE

	return TRUE

/proc/spread_germs_to_bodypart(obj/item/bodypart/BP, mob/living/carbon/human/user, obj/item/tool)
	if(!istype(user) || !istype(BP) || !istype(BP.owner) || BP.is_robotic_limb())
		return

	//Germs from the surgeon
	var/our_germ_level = user.germ_level
	if(user.gloves)
		our_germ_level = user.gloves.germ_level
	
	//Germs from the tool
	if(tool && (tool.germ_level >= our_germ_level))
		our_germ_level += tool.germ_level
	
	//Germs from the dirtiness on the surgery room
	for(var/turf/open/floor/floor in view(2, get_turf(BP.owner)))
		our_germ_level += floor.dirtiness
	
	//Germs from the wounds on the bodypart
	for(var/datum/wound/W in BP.wounds)
		our_germ_level += W.germ_level
	
	//Germs from organs inside the bodypart
	for(var/obj/item/organ/O in BP.get_organs())
		if(O.germ_level)
			our_germ_level += O.germ_level
	
	//Divide it by 10 to be reasonable
	our_germ_level = CEILING(our_germ_level/10, 1)

	//If the patient has antibiotics, kill germs by an amount equal to 10x the antibiotic force
	//e.g. nalixidic acid has 35 force, thus would decrease germs here by 350
	var/antibiotics = BP.owner.get_antibiotics()
	our_germ_level = max(0, our_germ_level - antibiotics)

	//Germ level is increased/decreased depending on a diceroll
	if(user.mind)
		var/diceroll = user.mind.diceroll(STAT_DATUM(int)*0.5, SKILL_DATUM(surgery)*1.5, "6d6", crit = 18)
		switch(diceroll)
			if(DICE_CRIT_SUCCESS)
				our_germ_level *= 0
			if(DICE_SUCCESS)
				our_germ_level *= 0.5
			if(DICE_FAILURE)
				our_germ_level *= 1
			if(DICE_CRIT_FAILURE)
				our_germ_level *= 2

	if(our_germ_level <= (WOUND_SANITIZATION_STERILIZER/2))
		return

	. = TRUE
	
	//If we still have germs, let's get that W
	//First, infect the wounds on the bodypart
	for(var/datum/wound/W in BP.wounds)
		if(W.germ_level < INFECTION_LEVEL_TWO)
			W.germ_level += our_germ_level
	
	//Infect the organs on the bodypart
	for(var/obj/item/organ/O in BP.get_organs())
		if(O.germ_level < INFECTION_LEVEL_TWO)
			O.germ_level += our_germ_level

	//Infect the bodypart
	if(BP.germ_level < INFECTION_LEVEL_TWO)
		BP.germ_level += our_germ_level

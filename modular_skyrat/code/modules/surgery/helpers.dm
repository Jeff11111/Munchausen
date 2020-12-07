
/proc/attempt_initiate_surgery(obj/item/I, mob/living/M, mob/user)
	if(!istype(M))
		return

	var/mob/living/carbon/C
	var/obj/item/bodypart/affecting
	var/selected_zone = user.zone_selected
	if(iscarbon(M))
		C = M
		affecting = C.get_bodypart(check_zone(selected_zone))

	var/datum/surgery/current_surgery
	for(var/datum/surgery/S in M.surgeries)
		if(S.location == selected_zone)
			current_surgery = S

	var/choose = FALSE
	if(current_surgery)
		choose = TRUE
		if(C && find_cauterizing_tool(list(user.get_inactive_held_item())))
			return attempt_cancel_surgery(current_surgery, I, M, user)
	
	var/list/all_surgeries = GLOB.surgeries_list.Copy()
	var/list/available_surgeries = list()

	for(var/datum/surgery/S in all_surgeries)
		if(!S.possible_locs.Find(selected_zone))
			continue
		if(affecting)
			if(!S.requires_bodypart)
				continue
			if(S.requires_bodypart_type && !(affecting.status & S.requires_bodypart_type))
				continue
			if(S.requires_real_bodypart && affecting.is_pseudopart)
				continue
		else if(C && S.requires_bodypart) //mob with no limb in surgery zone when we need a limb
			continue
		if(S.lying_required && !(M.lying))
			continue
		if(!S.can_start(user, M, I))
			continue
		for(var/path in S.target_mobtypes)
			if(istype(M, path))
				available_surgeries[S.name] = S
				break

	if(!length(available_surgeries))
		return

	var/P
	if(choose)
		P = input("Switch to what procedure?", "Surgery", null, null) as null|anything in available_surgeries
	else if(!affecting)
		P = "Prosthetic replacement"
	else if((user.zone_selected == BODY_ZONE_PRECISE_MOUTH) && affecting.max_teeth && (affecting.get_teeth_amount() < affecting.max_teeth))
		P = "Teeth repair"
	else if(affecting.is_broken())
		if(affecting.is_organic_limb())
			var/datum/wound/blunt/W = locate() in affecting.wounds
			if(W.severity >= WOUND_SEVERITY_CRITICAL)
				P = "Repair bone fracture (Compound)"
			else
				P = "Repair bone fracture (Hairline)"
		else
			var/datum/wound/mechanical/W = locate() in affecting.wounds
			if(W.severity >= WOUND_SEVERITY_CRITICAL)
				P = "Repair endoskeleton damage (Broken)"
			else
				P = "Repair endoskeleton damage (Malfunctioning)"
	else
		if(affecting.is_organic_limb())
			P = "Organ manipulation"
		else
			P = "Prosthesis organ manipulation"
	
	if(P && user && user.Adjacent(M) && (I in user))
		var/datum/surgery/S = available_surgeries[P]
		if(!S)
			P = input("Switch to what procedure?", "Surgery", null, null) as null|anything in available_surgeries
			return
		
		var/list/steps_done = list()
		if(current_surgery)
			var/counter = 0
			for(var/stoop in current_surgery.steps)
				counter++
				if(counter > (current_surgery.status - 1))
					break
				if(stoop in S.steps)
					steps_done |= stoop
			qdel(current_surgery)
		
		if(affecting)
			if(!S.requires_bodypart)
				return
			if(S.requires_bodypart_type && !(affecting.status & S.requires_bodypart_type))
				return

		else if(C && S.requires_bodypart)
			return
		
		if(S.lying_required && !(M.lying))
			return

		if(!S.can_start(user, M, I))
			return

		if(S.ignore_clothes || get_location_accessible(M, selected_zone))
			var/datum/surgery/procedure = new S.type(M, selected_zone, affecting)
			if(istype(I, /obj/item/surgical_drapes) || istype(I, /obj/item/bedsheet))
				user.visible_message("[user] drapes [I] over [M]'s [parse_zone(selected_zone)] to prepare for surgery.", \
					"<span class='notice'>You drape [I] over [M]'s [parse_zone(selected_zone)] to prepare for \an [lowertext(procedure.name)].</span>")
			else
				user.visible_message("[user] prepares [M]'s [parse_zone(selected_zone)] for surgery with [I].", \
					"<span class='notice'>You prepare [M]'s [parse_zone(selected_zone)] for \an [lowertext(procedure.name)] with [I].</span>")
			log_combat(user, M, "operated on", null, "(OPERATION TYPE: [procedure.name]) (TARGET AREA: [selected_zone])")
			while((procedure.status <= length(procedure.steps)) && (surgery_step_in_list(procedure.steps[procedure.status], steps_done)))
				procedure.status++
			if(procedure.status > length(procedure.steps))
				procedure.complete()
			else if(I.get_sharpness() && (procedure.steps[procedure.status] == /datum/surgery_step/incise))
				procedure.next_step(user, user.a_intent)
		else
			to_chat(user, "<span class='warning'>You need to expose [M]'s [parse_zone(selected_zone)] first!</span>")

	return TRUE

/proc/find_cauterizing_tool(list/item_list)
	for(var/obj/item/I in item_list)
		if(I.tool_behaviour == TOOL_CAUTERY || I.get_temperature() > 300)
			return I
		else if(istype(I, /obj/item/stack/medical/suture) || istype(I, /obj/item/stack/medical/gauze))
			return I
	return FALSE

/proc/surgery_step_in_list(step_path, list/step_list)
	var/list/pog = typesof(step_path)
	for(var/pogchamp in step_list)
		if(pogchamp in pog)
			return TRUE
	return FALSE

/proc/attempt_cancel_surgery(datum/surgery/S, obj/item/I, mob/living/M, mob/user)
	var/selected_zone = user.zone_selected
	if(S.status == 1)
		M.surgeries -= S
		user.visible_message("[user] unprepare from [M]'s [parse_zone(selected_zone)].", \
			"<span class='notice'>You unprepare [M]'s [parse_zone(selected_zone)].</span>")
		qdel(S)
	else if(S.can_cancel)
		var/required_tool_type = TOOL_CAUTERY
		var/obj/item/close_tool = user.get_inactive_held_item()
		var/is_robotic = S.requires_bodypart_type & BODYPART_ROBOTIC
		if(is_robotic)
			required_tool_type = TOOL_SCREWDRIVER
		if(iscyborg(user))
			close_tool = find_cauterizing_tool(user.held_items)
			if(!close_tool)
				to_chat(user, "<span class='warning'>You need to equip a cautery in an inactive slot to stop [M]'s surgery!</span>")
				return
		else if(!close_tool || close_tool.tool_behaviour != required_tool_type)
			to_chat(user, "<span class='warning'>You need to hold a [is_robotic ? "screwdriver" : "cautery"] in your inactive hand to stop [M]'s surgery!</span>")
			return
		else if(!do_mob(user, M, 1 SECONDS))
			to_chat(user, "<span class='warning'>You need to stay still to cancel \the [S.name]!</span>")
			return
		
		M.surgeries -= S
		for(var/datum/wound/slash/critical/incision/inch in S.operated_bodypart.wounds)
			if(!istype(inch, /datum/wound/slash/critical/incision/disembowel))
				inch.remove_wound()
		for(var/datum/wound/mechanical/slash/critical/incision/inch in S.operated_bodypart.wounds)
			if(!istype(inch, /datum/wound/mechanical/slash/critical/incision/disembowel))
				inch.remove_wound()
		user.visible_message("<span class='notice'>[user] closes [M]'s [parse_zone(selected_zone)] with [close_tool] and removes [I].</span>", \
			"<span class='notice'>You close [M]'s [parse_zone(selected_zone)] with [close_tool] and remove [I].</span>")
		var/datum/component/storage/concrete/organ/ST = M.GetComponent(/datum/component/storage/concrete/organ)
		if(ST)
			ST.accessible = FALSE
		return TRUE

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
	if(!istype(user) || !istype(BP) || BP.is_robotic_limb())
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
		var/diceroll = user.mind.diceroll(STAT_DATUM(int), SKILL_DATUM(surgery), "6d6", crit = 20)
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

	//If we still have germs, let's get that W
	//First, nfect the wounds on the bodypart
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

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
			return TRUE
		else if(istype(I, /obj/item/stack/medical/suture) || istype(I, /obj/item/stack/medical/gauze))
			return TRUE
	return FALSE

/proc/surgery_step_in_list(step_path, list/step_list)
	for(var/pogchamp in step_list)
		if(istype(step_path, pogchamp))
			return TRUE
	return FALSE

/proc/attempt_cancel_surgery(datum/surgery/S, obj/item/I, mob/living/M, mob/user)
	var/selected_zone = user.zone_selected
	if(S.status == 1)
		M.surgeries -= S
		user.visible_message("[user] removes [I] from [M]'s [parse_zone(selected_zone)].", \
			"<span class='notice'>You remove [I] from [M]'s [parse_zone(selected_zone)].</span>")
		qdel(S)
	else if(S.can_cancel)
		var/required_tool_type = TOOL_CAUTERY
		var/obj/item/close_tool = user.get_inactive_held_item()
		var/is_robotic = S.requires_bodypart_type & BODYPART_ROBOTIC
		if(is_robotic)
			required_tool_type = TOOL_SCREWDRIVER
		if(iscyborg(user))
			close_tool = locate(/obj/item/cautery) in user.held_items
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
		qdel(S)

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
				return 0
		if(BODY_ZONE_PRECISE_EYES)
			if(covered_locations & HEAD || face_covered & HIDEEYES || eyesmouth_covered & GLASSESCOVERSEYES)
				return 0
		if(BODY_ZONE_PRECISE_MOUTH)
			if(covered_locations & HEAD || face_covered & HIDEFACE || eyesmouth_covered & MASKCOVERSMOUTH || eyesmouth_covered & HEADCOVERSMOUTH)
				return 0
		if(BODY_ZONE_CHEST)
			if(covered_locations & CHEST)
				return 0
		if(BODY_ZONE_PRECISE_GROIN)
			if(covered_locations & GROIN)
				return 0
		if(BODY_ZONE_L_ARM)
			if(covered_locations & ARM_LEFT)
				return 0
		if(BODY_ZONE_R_ARM)
			if(covered_locations & ARM_RIGHT)
				return 0
		if(BODY_ZONE_L_LEG)
			if(covered_locations & LEG_LEFT)
				return 0
		if(BODY_ZONE_R_LEG)
			if(covered_locations & LEG_RIGHT)
				return 0
		if(BODY_ZONE_PRECISE_L_HAND)
			if(covered_locations & HAND_LEFT)
				return 0
		if(BODY_ZONE_PRECISE_R_HAND)
			if(covered_locations & HAND_RIGHT)
				return 0
		if(BODY_ZONE_PRECISE_L_FOOT)
			if(covered_locations & FOOT_LEFT)
				return 0
		if(BODY_ZONE_PRECISE_R_FOOT)
			if(covered_locations & FOOT_RIGHT)
				return 0

	return 1

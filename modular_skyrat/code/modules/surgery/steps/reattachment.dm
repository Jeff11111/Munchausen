//limb reattachment
/datum/surgery_step/add_prosthetic
	name = "Add prosthetic"
	implements = list(/obj/item/bodypart = 85, /obj/item/organ_storage = 90, /obj/item = 50)
	base_time = 32
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = ALL_BODYPARTS
	requires_bodypart = FALSE
	requires_bodypart_type = 0
	surgery_flags = 0
	var/organ_rejection_dam = 0

/datum/surgery_step/add_prosthetic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(istype(tool, /obj/item/organ_storage))
		if(!tool.contents.len)
			to_chat(user, "<span class='notice'>There is nothing inside [tool]!</span>")
			return -1
		var/obj/item/I = tool.contents[1]
		if(!isbodypart(I))
			to_chat(user, "<span class='notice'>[I] cannot be attached!</span>")
			return -1
		tool = I
	if(istype(tool, /obj/item/bodypart))
		var/obj/item/bodypart/BP = tool
		if(ismonkey(target))// monkey patient only accept organic monkey limbs
			if((BP.status & BODYPART_ROBOTIC) || BP.animal_origin != MONKEY_BODYPART)
				to_chat(user, "<span class='warning'>[BP] doesn't match the patient's morphology.</span>")
				return -1
		if(!(BP.status & BODYPART_ROBOTIC))
			organ_rejection_dam = 10
			if(ishuman(target))
				if(BP.animal_origin)
					to_chat(user, "<span class='warning'>[BP] doesn't match the patient's morphology.</span>")
					return -1
				var/mob/living/carbon/human/H = target
				if(H.dna.species.id != BP.species_id)
					organ_rejection_dam = 30
				if(ROBOTIC_LIMBS in H.dna?.species?.species_traits)
					organ_rejection_dam = 0

		if(target_zone == BP.body_zone) //so we can't replace a leg with an arm, or a human arm with a monkey arm.
			display_results(user, target, "<span class ='notice'>You begin to replace [target]'s [parse_zone(target_zone)] with [tool]...</span>",
				"[user] begins to replace [target]'s [parse_zone(target_zone)] with [tool].",
				"[user] begins to replace [target]'s [parse_zone(target_zone)].")
		else if(target_zone in BP.children_zones)
			display_results(user, target, "<span class ='notice'>You begin to replace [target]'s [parse_zone(BP.children_zones[1])] with [tool]...</span>",
				"[user] begins to replace [target]'s [parse_zone(BP.children_zones[1])] with [tool].",
				"[user] begins to replace [target]'s [parse_zone(BP.children_zones[1])].")
		else
			to_chat(user, "<span class='warning'>[tool] isn't the right type for [parse_zone(target_zone)].</span>")
			return -1
	else
		display_results(user, target, "<span class='notice'>You begin to attach [tool] onto [target]...</span>",
			"[user] begins to attach [tool] onto [target]'s [parse_zone(target_zone)].",
			"[user] begins to attach something onto [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/add_prosthetic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(istype(tool, /obj/item/organ_storage))
		tool.icon_state = initial(tool.icon_state)
		tool.desc = initial(tool.desc)
		tool.cut_overlays()
		tool = tool.contents[1]
	if(istype(tool, /obj/item/bodypart) && user.temporarilyRemoveItemFromInventory(tool))
		var/obj/item/bodypart/L = tool
		var/bruh = null
		if(target_zone != L.body_zone)
			if(target_zone in L.children_zones)
				for(var/obj/item/bodypart/fosterchild in L)
					if((fosterchild.body_zone in L.children_zones) && (target_zone == fosterchild.body_zone) && !bruh)
						fosterchild.forceMove(get_turf(target))
						fosterchild.attach_limb(target)
						L.forceMove(get_turf(target))
						bruh = fosterchild
		else
			L.attach_limb(target)
		if(organ_rejection_dam)
			target.adjustToxLoss(organ_rejection_dam)
		display_results(user, target, "<span class='notice'>You succeed in replacing [target]'s [parse_zone(target_zone)].</span>",
			"[user] successfully replaces [target]'s [parse_zone(target_zone)] with [bruh ? bruh : tool]!",
			"[user] successfully replaces [target]'s [parse_zone(target_zone)]!")
		return TRUE
	else
		var/obj/item/bodypart/L = target.newBodyPart(target_zone, FALSE, FALSE)
		if(!L)
			return
		L.is_pseudopart = TRUE
		L.attach_limb(target)
		display_results(user, target, "<span class='notice'>You attach [tool].</span>",
			"[user] finishes attaching [tool]!",
			"[user] finishes the attachment procedure!")
		if(istype(tool))
			var/obj/item/new_limb = new tool.type(target)
			if(target_zone == BODY_ZONE_PRECISE_R_HAND)
				target.put_in_r_hand(new_limb)
				ADD_TRAIT(new_limb, TRAIT_NODROP, "surgery")
			else if(target_zone == BODY_ZONE_PRECISE_L_HAND)
				target.put_in_l_hand(new_limb)
				ADD_TRAIT(new_limb, TRAIT_NODROP, "surgery")
			L.name = "[new_limb.name] [L.name]"
			L.desc = new_limb.desc
			L.custom_overlay = mutable_appearance(new_limb.icon, new_limb.icon_state, FLOAT_LAYER, FLOAT_PLANE, new_limb.color)
			L.custom_overlay.transform *= 0.5
			L.custom_overlay.pixel_x = 0
			L.custom_overlay.pixel_y = 0
			L.custom_overlay.pixel_x += 8
			L.custom_overlay.pixel_y -= 8
			switch(target_zone)
				if(BODY_ZONE_HEAD)
					L.custom_overlay.pixel_x -= 8
					L.custom_overlay.pixel_y += 16
				if(BODY_ZONE_CHEST)
					L.custom_overlay.pixel_x -= 8
					L.custom_overlay.pixel_y += 8
				if(BODY_ZONE_PRECISE_GROIN)
					L.custom_overlay.pixel_x -= 8
					L.custom_overlay.pixel_y += 6
				if(BODY_ZONE_R_LEG)
					L.custom_overlay.pixel_x += 0
					L.custom_overlay.pixel_y += 2
				if(BODY_ZONE_PRECISE_R_FOOT)
					L.custom_overlay.pixel_x += 0
					L.custom_overlay.pixel_y += 0
				if(BODY_ZONE_L_LEG)
					L.custom_overlay.pixel_x -= 16
					L.custom_overlay.pixel_y += 2
				if(BODY_ZONE_PRECISE_L_FOOT)
					L.custom_overlay.pixel_x -= 16
					L.custom_overlay.pixel_y += 0
			target.regenerate_icons()
			qdel(tool)
			return TRUE

//sewing a limb back on
/datum/surgery_step/sew_limb
	name = "Sew limb"
	implements = list(/obj/item/stack/medical/suture = 100, /obj/item/stack/medical/fixovein = 100, /obj/item/stack/sticky_tape/surgical = 80, /obj/item/stack/sticky_tape = 65, /obj/item/stack/cable_coil = 50)
	base_time = 32
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = ALL_BODYPARTS
	requires_bodypart = TRUE
	requires_bodypart_type = BODYPART_ORGANIC
	surgery_flags = 0

/datum/surgery_step/sew_limb/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	. = ..()
	var/obj/item/stack/vibe = tool
	if(!istype(vibe))
		return FALSE
	if(vibe.get_amount() < 3)
		return FALSE

/datum/surgery_step/sew_limb/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!. || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/affected = C.get_bodypart(user.zone_selected)
	if(!affected.is_cut_away())
		return FALSE

/datum/surgery_step/sew_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	display_results(user, target, "<span class='notice'>You begin to sew [target]'s [parse_zone(target_zone)] to it's [BP.amputation_point]...</span>",
		"[user] begins to sew [target]'s [parse_zone(target_zone)] in place!",
		"[user] begins to sew [target]'s [parse_zone(target_zone)] in place!")

/datum/surgery_step/sew_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/obj/item/stack/vibe = tool
	if(istype(vibe) && !vibe.use(3))
		return TRUE
	var/mob/living/carbon/human/L = target
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	display_results(user, target, "<span class='notice'>You sew [L]'s [parse_zone(target_zone)] to it's [BP.amputation_point].</span>",
		"[user] sews [L]'s [parse_zone(target_zone)] in place!",
		"[user] sews [L]'s [parse_zone(target_zone)] in place!")
	var/obj/item/bodypart/target_limb = target.get_bodypart(target_zone)
	target_limb?.limb_flags &= ~BODYPART_CUT_AWAY
	return TRUE

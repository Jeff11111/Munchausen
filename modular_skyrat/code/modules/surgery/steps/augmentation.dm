//niggers
/datum/surgery_step/replace_limb
	name = "Replace limb"
	implements = list(/obj/item/bodypart = 85,
					/obj/item/organ_storage = 90)
	base_time = 32
	requires_bodypart_type = 0
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_RETRACTED | STEP_NEEDS_BROKEN)

/datum/surgery_step/replace_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	if(istype(tool, /obj/item/organ_storage) && istype(tool.contents[1], /obj/item/bodypart))
		tool = tool.contents[1]
	var/obj/item/bodypart/aug = tool
	if(aug.body_zone != target_zone)
		to_chat(user, "<span class='warning'>[tool] isn't the right type for [parse_zone(target_zone)].</span>")
		return -1
	var/obj/item/bodypart/L = target.get_bodypart(target_zone)
	if(L)
		display_results(user, target, "<span class ='notice'>You begin to augment [target]'s [parse_zone(user.zone_selected)]...</span>",
			"[user] begins to augment [target]'s [parse_zone(user.zone_selected)] with [aug].",
			"[user] begins to augment [target]'s [parse_zone(user.zone_selected)].")

/datum/surgery_step/replace_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/bodypart/tool)
	var/obj/item/bodypart/L = target.get_bodypart(target_zone)
	if(L)
		if(istype(tool, /obj/item/organ_storage))
			tool.icon_state = initial(tool.icon_state)
			tool.desc = initial(tool.desc)
			tool.cut_overlays()
			tool = tool.contents[1]
		if(istype(tool) && user.temporarilyRemoveItemFromInventory(tool))
			if(tool.body_zone == target_zone)
				tool.replace_limb(target, TRUE)
			else if(target_zone in tool.children_zones)
				var/obj/item/bodypart/BP
				for(var/obj/item/bodypart/candidate in tool)
					if(target_zone == candidate.body_zone)
						BP = candidate
				if(BP)
					BP.replace_limb(target, TRUE)
				else
					return FALSE
		display_results(user, target, "<span class='notice'>You successfully augment [target]'s [parse_zone(target_zone)].</span>",
			"[user] successfully augments [target]'s [parse_zone(target_zone)] with [tool]!",
			"[user] successfully augments [target]'s [parse_zone(target_zone)]!")
		log_combat(user, target, "augmented", addition="by giving him new [parse_zone(target_zone)] INTENT: [uppertext(user.a_intent)]")
	else
		to_chat(user, "<span class='warning'>[target] has no [parse_zone(target_zone)] there!</span>")
	return TRUE

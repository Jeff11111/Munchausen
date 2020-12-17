//British repair
/datum/surgery_step/insert_teeth
	name = "Fix teeth"
	implements = list(/obj/item/stack/teeth = 100)
	base_time = 40
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)
	requires_bodypart_type = 0
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_RETRACTED)

/datum/surgery_step/insert_teeth/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to put the [tool] inside [target]'s mouth...</span>",
		"[user] begins to fix [target]'s teeth.",
		"[user] begins to perform surgery on [target]'s mouth.")

/datum/surgery_step/insert_teeth/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/teeth_part = target.get_bodypart(check_zone(user.zone_selected))
	var/obj/item/stack/our_teeth = tool
	var/obj/item/stack/target_teeth = teeth_part.teeth_object
	if(target_teeth && our_teeth)
		our_teeth.merge(target_teeth)
	else
		our_teeth.forceMove(teeth_part)
		teeth_part.teeth_object = our_teeth
	teeth_part.update_teeth()
	display_results(user, target, "<span class='notice'>You succeed in fixing [target]'s teeth.</span>",
		"[user] successfully fixes [target]'s teeth!",
		"[user] completes the surgery on [target]'s mouth.")
	return TRUE

/datum/surgery_step/insert_teeth/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/teeth_part = target.get_bodypart(check_zone(user.zone_selected))
	if(teeth_part.get_teeth_amount())
		if(target.chem_effects[CE_PAINKILLER] < 30)
			target.emote("scream")
		var/obj/item/stack/teeth = teeth_part.teeth_object
		teeth.forceMove(get_turf(target))
		teeth_part.teeth_object = null
		teeth_part.update_teeth()
		display_results(user, target, "<span class='warning'>You accidentally rip out [target]'s teeth!</span>",
			"<span class='warning'>[user] accidentally rips [target]'s teeth out!</span>",
			"<span class='warning'>[user] accidentally rips [target]'s teeth out!</span>")
	return FALSE

//sewing a limb back on
//(but robotic)
/datum/surgery_step/mechanic_sew_limb
	name = "Weld limb"
	implements = list(TOOL_WELDER = 100)
	base_time = 32
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = ALL_BODYPARTS
	requires_bodypart = TRUE
	requires_bodypart_type = BODYPART_ORGANIC
	surgery_flags = 0

/datum/surgery_step/mechanic_sew_limb/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!. || !iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/affected = C.get_bodypart(user.zone_selected)
	if(!affected.is_cut_away())
		return FALSE

/datum/surgery_step/mechanic_sew_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	display_results(user, target, "<span class='notice'>You begin to weld [target]'s [parse_zone(target_zone)] to it's [BP.amputation_point]...</span>",
		"[user] begins to weld [target]'s [parse_zone(target_zone)] in place!",
		"[user] begins to weld [target]'s [parse_zone(target_zone)] in place!")

/datum/surgery_step/mechanic_sew_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/mob/living/carbon/human/L = target
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	display_results(user, target, "<span class='notice'>You weld [L]'s [parse_zone(target_zone)] to it's [BP.amputation_point].</span>",
		"[user] weld [L]'s [parse_zone(target_zone)] in place!",
		"[user] weld [L]'s [parse_zone(target_zone)] in place!")
	var/obj/item/bodypart/target_limb = target.get_bodypart(target_zone)
	target_limb?.limb_flags &= ~BODYPART_CUT_AWAY
	return TRUE

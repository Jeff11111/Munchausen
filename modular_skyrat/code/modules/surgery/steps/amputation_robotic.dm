//amputate limb
//(but robotic)
/datum/surgery_step/mechanic_sever_limb
	name = "Sever limb"
	implements = list(TOOL_WIRECUTTER = 100, TOOL_SCALPEL = 60)
	base_time = 64
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = AMPUTATE_BODYPARTS
	requires_bodypart_type = BODYPART_ROBOTIC
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_RETRACTED | STEP_NEEDS_BROKEN) //i to this moment still hate black people

/datum/surgery_step/mechanic_sever_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	display_results(user, target, "<span class='notice'>You begin to sever [target]'s [parse_zone(target_zone)] by \the [BP.amputation_point]...</span>",
		"[user] begins to sever [target]'s [parse_zone(target_zone)]!",
		"[user] begins to sever [target]'s [parse_zone(target_zone)]!")

/datum/surgery_step/mechanic_sever_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/mob/living/carbon/human/L = target
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	display_results(user, target, "<span class='notice'>You sever [L]'s [parse_zone(target_zone)] from \the [BP.amputation_point].</span>",
		"[user] severs [L]'s [parse_zone(target_zone)]!",
		"[user] severs [L]'s [parse_zone(target_zone)]!")
	var/obj/item/bodypart/target_limb = target.get_bodypart(target_zone)
	target_limb.drop_limb()
	return TRUE


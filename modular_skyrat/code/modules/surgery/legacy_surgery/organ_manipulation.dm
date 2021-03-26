/datum/surgery/organ_manipulation
	name = "Organ manipulation"
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = ORGAN_BODYPARTS
	requires_bodypart_type = BODYPART_ORGANIC
	requires_real_bodypart = 1
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close,
		)
	var/obj/item/mmi/mmi

/datum/surgery/organ_manipulation/complete()
	var/datum/component/storage/concrete/organ/ST = target?.GetComponent(/datum/component/storage/concrete/organ)
	if(ST)
		ST.accessible = FALSE
	. = ..()

/datum/surgery/organ_manipulation/Destroy()
	var/datum/component/storage/concrete/organ/ST = target?.GetComponent(/datum/component/storage/concrete/organ)
	if(ST)
		ST.accessible = FALSE
	. = ..()

/datum/surgery/organ_manipulation/soft
	possible_locs = list(BODY_ZONE_PRECISE_NECK, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, \
					BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, \
					BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, \
					BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close
		)

/datum/surgery/organ_manipulation/alien
	name = "Alien organ manipulation"
	possible_locs = ALL_BODYPARTS
	target_mobtypes = list(/mob/living/carbon/alien/humanoid)
	steps = list(
		/datum/surgery_step/saw,
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/manipulate_organs,
		/datum/surgery_step/close
		)

/datum/surgery_step/manipulate_organs
	time = 64
	name = "Manipulate organs"
	repeatable = TRUE
	implements = list(TOOL_HEMOSTAT = 100, /obj/item/retractor = 100, TOOL_CROWBAR = 55)
	accept_hand = 100
	var/mob_prepared = FALSE
	var/mob/living/carbon/storage_man
	var/datum/component/storage/concrete/organ/our_component

/datum/surgery_step/manipulate_organs/Destroy(force, ...)
	. = ..()
	our_component = null
	storage_man = null

/datum/surgery_step/manipulate_organs/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(mob_prepared && our_component && !tool)
		our_component.user_show_to_mob(user, FALSE, FALSE)
		return -1
	else if(!mob_prepared)
		to_chat(user, "<span class='notice'>You prepare [target] for organ manipulation.</span>")
		our_component = target.GetComponent(/datum/component/storage/concrete/organ)
		if(our_component)
			our_component.bodypart_affected = target.get_bodypart(check_zone(surgery.location))
			our_component.drop_all_on_deconstruct = FALSE
			our_component.silent = TRUE
			our_component.accessible = TRUE
			our_component.update_insides()
		mob_prepared = TRUE
		return -1
	else if(tool.tool_behaviour in list(TOOL_RETRACTOR, TOOL_CROWBAR))
		display_results(user, target, "<span class='notice'>You begin closing up the incision in [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to close up the incision in [target]'s [parse_zone(target_zone)].",
			"[user] begins to close up the incision in [target]'s [parse_zone(target_zone)].")
		return 0
	return -1

/datum/surgery_step/manipulate_organs/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You close up [target]'s [parse_zone(target_zone)].</span>",
		"[user] closes up [target]'s [parse_zone(target_zone)]!",
		"[user] closes up [target]'s [parse_zone(target_zone)]!")
	QDEL_NULL(our_component)
	return TRUE

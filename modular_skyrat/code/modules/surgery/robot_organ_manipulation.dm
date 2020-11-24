
/datum/surgery/organ_manipulation/mechanic
	name = "Prosthesis organ manipulation"
	possible_locs = ORGAN_BODYPARTS //skyrat edit
	requires_bodypart_type = BODYPART_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/manipulate_organs/mechanic,
		/datum/surgery_step/mechanic_close,
		)

/datum/surgery/organ_manipulation/mechanic/soft
	possible_locs = list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT) //skyrat edit
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/manipulate_organs/mechanic,
		/datum/surgery_step/mechanic_close,
		)

/datum/surgery_step/manipulate_organs/mechanic
	implements = list(TOOL_RETRACTOR = 55, TOOL_CROWBAR = 100)

//Incisions poggers
/datum/wound/slash/critical/incision
	name = "Incision"
	desc = "Patient has been cut open for surgical purposes."
	treat_text = "Finalization of surgical procedures on the affected limb."
	examine_desc = "is surgically cut open, organs visible from it's gaping wound"
	occur_text = "is surgically cut open"
	sound_effect = 'modular_skyrat/sound/effects/blood1.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	viable_zones = ALL_BODYPARTS
	wound_type = WOUND_LIST_INCISION
	initial_flow = 1
	minimum_flow = 0
	clot_rate = 0
	max_per_type = 5
	demotes_to = null
	scarring_descriptions = list("a precise line of scarred tissue", "a long line of slightly darker tissue")
	pain_amount = 15
	infection_chance = 90
	infection_rate = 6
	descriptive = "The flesh is incised!"

/datum/wound/slash/critical/incision/build_wound_overlay()
	if(limb.body_zone in list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN))
		var/icon_poggers = "dissected_[limb.body_zone]"
		wound_overlay = mutable_appearance('modular_skyrat/icons/mob/wound_overlays.dmi', icon_poggers)
		return TRUE

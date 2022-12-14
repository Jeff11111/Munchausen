/datum/species/synthliz
	name = "Synthetic Lizardperson"
	id = "synthliz"
	icon_limbs = DEFAULT_BODYPART_ICON_CITADEL
	say_mod = "beeps"
	default_color = "00FF00"
	species_traits = list(MUTCOLORS,NOTRANSSTING,EYECOLOR,LIPS,HAIR,HAS_FLESH,HAS_BONE)
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	mutant_bodyparts = list("ipc_antenna" = "Synthetic Lizard - Antennae","mam_tail" = "Synthetic Lizard", "mam_snouts" = "Synthetic Lizard - Snout", "legs" = "Digitigrade", "mam_body_markings" = "Synthetic Lizard - Plates", "taur" = "None")
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/ipc
	gib_types = list(/obj/effect/gibspawner/ipc, /obj/effect/gibspawner/ipc/bodypartless)
	mutanttongue = /obj/item/organ/tongue/robot/ipc
	//Just robo looking parts.
	mutantheart = /obj/item/organ/heart/ipc
	mutantlungs = /obj/item/organ/lungs/ipc
	mutantliver = /obj/item/organ/liver/ipc
	mutantstomach = /obj/item/organ/stomach/ipc

	exotic_bloodtype = "S"
	exotic_blood_color = BLOOD_COLOR_OIL
	languagewhitelist = list("Encoded Audio Language")
	bloodtypes = list("HF", "SY", "S")
	bloodreagents = list("Synthetic Blood", "Oil")
	rainbowblood = TRUE

/datum/species/synthliz/qualifies_for_rank(rank, list/features)
	return TRUE

//I wag in death
/datum/species/synthliz/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)

/datum/species/synthliz/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

/datum/species/synthliz/can_wag_tail(mob/living/carbon/human/H)
	return mutant_bodyparts["mam_tail"] || mutant_bodyparts["mam_waggingtail"]

/datum/species/synthliz/is_wagging_tail(mob/living/carbon/human/H)
	return mutant_bodyparts["mam_waggingtail"]

/datum/species/synthliz/start_wagging_tail(mob/living/carbon/human/H)
	if(mutant_bodyparts["mam_tail"])
		mutant_bodyparts["mam_waggingtail"] = mutant_bodyparts["mam_tail"]
		mutant_bodyparts -= "mam_tail"
	H.update_body()

/datum/species/synthliz/stop_wagging_tail(mob/living/carbon/human/H)
	if(mutant_bodyparts["mam_waggingtail"])
		mutant_bodyparts["mam_tail"] = mutant_bodyparts["mam_waggingtail"]
		mutant_bodyparts -= "mam_waggingtail"
	H.update_body()

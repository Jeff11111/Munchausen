/datum/species/lizard
	has_bobs = FALSE
	weiner_type = list("Hemi", "Knotted Hemi")

/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = "ashlizard"
	limbs_id = "lizard"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE,CAN_SCAR,HAS_SKIN,HAS_FLESH,HAS_BONE)
	inherent_traits = list(TRAIT_CHUNKYFINGERS)
	mutantlungs = /obj/item/organ/lungs/ashwalker
	mutanteyes = /obj/item/organ/eyes/night_vision
	burnmod = 0.7
	brutemod = 0.8

/datum/species/lizard
	has_bobs = FALSE
	weiner_type = list("Hemi", "Knotted Hemi", "Tapered")

/datum/species/lizard/ashwalker
	name = "Ash Walker"
	id = "ashlizard"
	limbs_id = "lizard"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,DIGITIGRADE,HAS_FLESH,HAS_BONE,CAN_SCAR)
	inherent_traits = list(TRAIT_CHUNKYFINGERS,TRAIT_NOSHITTING,TRAIT_NOPISSING)
	mutantlungs = /obj/item/organ/lungs/ashwalker
	burnmod = 0.7
	brutemod = 0.8

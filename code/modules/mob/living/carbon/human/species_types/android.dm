/datum/species/android
	name = "Android"
	id = "android"
	say_mod = "states"
	species_traits = list(NOBLOOD,NOGENITALS,NOAROUSAL,HAS_FLESH,HAS_BONE)
	inherent_traits = list(TRAIT_RESISTHEAT,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_RADIMMUNE,TRAIT_NOFIRE,TRAIT_PIERCEIMMUNE,TRAIT_NOHYDRATION,TRAIT_LIMBATTACHMENT)
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	meat = null
	gib_types = /obj/effect/gibspawner/robot
	damage_overlay_type = "synth"
	mutanttongue = /obj/item/organ/tongue/robot
	species_language_holder = /datum/language_holder/synthetic
	limbs_id = "synth"
	bloodtypes = list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "SY")
	exotic_bloodtype = "SY"
	exotic_blood_color = BLOOD_COLOR_SYNTHETIC
	rainbowblood = TRUE

/datum/species/android/on_species_gain(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ROBOTIC, FALSE, TRUE)

/datum/species/android/on_species_loss(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ORGANIC,FALSE, TRUE)

/datum/species/abductor
	name = "Abductor"
	id = "abductor"
	say_mod = "gibbers"
	sexes = FALSE
	species_traits = list(NOBLOOD,NOEYES,NOGENITALS,NOAROUSAL,CAN_SCAR,HAS_FLESH,HAS_BONE)
	inherent_traits = list(TRAIT_VIRUSIMMUNE,TRAIT_CHUNKYFINGERS,TRAIT_NOHUNGER,TRAIT_NOHYDRATION,TRAIT_NOBREATH)
	mutanttongue = /obj/item/organ/tongue/abductor
	exotic_bloodtype = "GREY"
	exotic_blood_color = BLOOD_COLOR_GREY
	rainbowblood = TRUE

/datum/species/abductor/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.add_hud_to(C)

/datum/species/abductor/on_species_loss(mob/living/carbon/C)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.remove_hud_from(C)

/datum/species/xeno
	// A cloning mistake, crossing human and xenomorph DNA
	name = "Xenomorph Hybrid"
	id = "xeno"
	say_mod = "hisses"
	default_color = "00FF00"
	icon_limbs = DEFAULT_BODYPART_ICON_CITADEL
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE)
	mutant_bodyparts = list("xenotail"="Xenomorph Tail","xenohead"="Standard","xenodorsal"="Standard", "mam_body_markings" = "Xeno","mcolor" = "0F0","mcolor2" = "0F0","mcolor3" = "0F0","taur" = "None", "legs" = "Digitigrade")
	mutanttongue = /obj/item/organ/tongue/alien/xenohybrid
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/xeno
	gib_types = list(/obj/effect/gibspawner/xeno/xenoperson, /obj/effect/gibspawner/xeno/xenoperson/bodypartless)
	skinned_type = /obj/item/stack/sheet/animalhide/xeno
	exotic_bloodtype = "X*"
	damage_overlay_type = "xeno"
	liked_food = MEAT
	languagewhitelist = list("Xenomorph")
	has_bobs = FALSE
	weiner_type = list("Hemi", "Knotted Hemi", "Tapered")

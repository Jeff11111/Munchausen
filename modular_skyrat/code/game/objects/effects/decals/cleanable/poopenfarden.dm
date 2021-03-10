//SHIT DECAL
/obj/effect/decal/cleanable/shit
	name = "shit"
	desc = "Some people get aroused by this, somehow?"
	gender = PLURAL
	density = 0
	layer = ABOVE_NORMAL_TURF_LAYER
	icon = 'modular_skyrat/icons/effects/shit_and_piss.dmi'
	icon_state = "splat1"
	random_icon_states = list("splat1", "splat2", "splat3", "splat4", "splat5", "splat6")

/obj/effect/decal/cleanable/shit/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/shit,10)
	for(var/obj/effect/decal/cleanable/shit/shit in src.loc)
		if(shit != src)
			shit.reagents.trans_to(src, shit.reagents.maximum_volume)
			qdel(shit)

//PISS DECAL
/obj/effect/decal/cleanable/piss
	name = "piss"
	desc = "You could scoop this up and throw it at other people, if you're a professional."
	gender = PLURAL
	density = 0
	layer = ABOVE_NORMAL_TURF_LAYER
	icon = 'modular_skyrat/icons/effects/shit_and_piss.dmi'
	icon_state = "urine1"
	random_icon_states = list("urine1", "urine2", "urine3")

/obj/effect/decal/cleanable/piss/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	reagents.add_reagent(/datum/reagent/consumable/piss,10)
	for(var/obj/effect/decal/cleanable/piss/piss in src.loc)
		if(piss != src)
			piss.reagents.trans_to(src, piss.reagents.maximum_volume)
			qdel(piss)

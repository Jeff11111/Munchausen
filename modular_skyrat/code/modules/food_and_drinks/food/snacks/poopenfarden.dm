//SHIT
/obj/item/reagent_containers/food/snacks/shit
	name = "shit"
	desc = "You really shouldn't eat it even though you probably did as a toddler."
	icon = 'modular_skyrat/icons/obj/shit_and_piss.dmi'
	icon_state = "poo1"
	item_state = "poo"

/obj/item/reagent_containers/food/snacks/shit/Initialize(mapload)
	. = ..()
	icon_state = pick("poo1", "poo2", "poo3", "poo4", "poo5", "poo6", "poo7")
	reagents.add_reagent(/datum/reagent/consumable/shit,10)
	bitesize = 3

/obj/item/reagent_containers/food/snacks/shit/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	playsound(hit_atom, "sound/effects/squishy.ogg", 40, 1)
	var/turf/T = get_turf(src)
	if(!istype(T, /turf/open/space))
		new /obj/effect/decal/cleanable/shit(T)
	qdel(src)

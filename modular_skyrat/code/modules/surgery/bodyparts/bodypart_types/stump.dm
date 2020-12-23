/obj/item/bodypart/stump
	name = "limb stump"
	desc = "Oh no..."
	max_damage = 10 //placeholder to avoid runtimes, actually set on dismemberment of a limb
	
/obj/item/bodypart/stump/drop_limb(special, ignore_children, dismembered, destroyed, wounding_type)
	destroyed = TRUE
	. = ..()

/obj/item/bodypart/stump/is_stump()
	return TRUE

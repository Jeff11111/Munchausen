/obj/item/bodypart/stump
	name = "limb stump"
	desc = "Oh no..."
	limb_flags = 0
	max_damage = 10 //placeholder to avoid runtimes, actually set on dismemberment of a limb

/obj/item/bodypart/stump/on_transfer_to_limb(obj/item/bodypart/BP)
	. = ..()
	qdel(src)

/obj/item/bodypart/stump/drop_limb(special, ignore_children, dismembered, destroyed, wounding_type)
	return ..(destroyed = TRUE)

/obj/item/bodypart/stump/is_stump()
	return TRUE

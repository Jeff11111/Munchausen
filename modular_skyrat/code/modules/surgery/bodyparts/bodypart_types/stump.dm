/obj/item/bodypart/stump
	name = "limb stump"
	desc = "Oh no..."

/obj/item/bodypart/stump/can_dismember(obj/item/I)
	return FALSE
	
/obj/item/bodypart/stump/drop_limb(special, ignore_children, dismembered, destroyed, wounding_type)
	destroyed = TRUE
	. = ..()

/obj/item/bodypart/stump/is_stump()
	return TRUE

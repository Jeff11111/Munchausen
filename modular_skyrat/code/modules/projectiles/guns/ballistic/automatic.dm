//Base proc changes
/obj/item/gun/ballistic/automatic
	fire_sound = 'modular_skyrat/sound/guns/smg2.ogg'
	var/generic_magazine_overlays = FALSE

/obj/item/gun/ballistic/automatic/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "-e" : ""]"

/obj/item/gun/ballistic/automatic/update_overlays()
	. = ..()
	safety_overlay = mutable_appearance(icon, "[initial(icon_state)][safety ? "-safe" : "-unsafe"]")
	if(magazine)
		. += mutable_appearance(icon, "[initial(icon_state)]-[generic_magazine_overlays ? "-mag" : initial(magazine.icon_state)]")

//Base proc changes
/obj/item/gun/ballistic/automatic
	fire_sound = 'modular_skyrat/sound/guns/smg2.ogg'
	var/generic_magazine_overlays = TRUE

/obj/item/gun/ballistic/automatic/update_icon()
	. = ..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/gun/ballistic/automatic/build_overlays()
	. = list()
	if(suppressed_overlay)
		. |= suppressed_overlay
	if(flashlight_overlay)
		. |= flashlight_overlay
	if(knife_overlay)
		. |= knife_overlay
	if(sling_overlay)
		. |= sling_overlay
	safety_overlay = mutable_appearance(icon, "[initial(icon_state)]-[safety ? "safe" : "unsafe"]")
	if(safety_overlay)
		. |= safety_overlay
	if(magazine)
		. |= build_magazine_overlay()

/obj/item/gun/ballistic/automatic/proc/build_magazine_overlay()
	. = mutable_appearance(icon, "[initial(icon_state)]-[generic_magazine_overlays ? "mag" : initial(magazine.icon_state)]")

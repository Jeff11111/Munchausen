//shitten farten
/obj/item/gun/ballistic/automatic/l6_saw
	icon = 'modular_skyrat/icons/obj/bobstation/guns/lmg.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/lmg_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/lmg_righthand.dmi'
	icon_state = "pk"
	item_state = "pk"
	safety_sound = 'modular_skyrat/sound/guns/safety2.ogg'
	fire_sound = 'modular_skyrat/sound/guns/smg1.ogg'
	autochamber = TRUE

/obj/item/gun/ballistic/automatic/l6_saw/update_icon()
	. = ..()
	icon_state = "pk[cover_open ? "-open" : ""]"
	item_state = "pk[magazine ? "" : "-e"][is_wielded ? "-wielded" : ""]"

/obj/item/gun/ballistic/automatic/l6_saw/build_magazine_overlay()
	. = mutable_appearance(icon, "[initial(icon_state)]-mag[CEILING(magazine.ammo_count(), 25)]")

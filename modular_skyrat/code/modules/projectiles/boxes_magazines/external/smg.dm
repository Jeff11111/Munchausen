//9mm smg
/obj/item/ammo_box/magazine/uzim9mm
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/smg.dmi'
	icon_state = "smg"

/obj/item/ammo_box/magazine/smgm9mm
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/smg.dmi'
	icon_state = "smg"

/obj/item/ammo_box/magazine/smgm9mm/ap
	icon_state = "smg_l"

/obj/item/ammo_box/magazine/smgm9mm/fire
	icon_state = "smg_p"

/obj/item/ammo_box/magazine/smgm9mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "30" : "0"]"

//.45 smg
/obj/item/ammo_box/magazine/smgm45
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/smg.dmi'
	icon_state = "msmg"

/obj/item/ammo_box/magazine/smgm45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "30" : "0"]"

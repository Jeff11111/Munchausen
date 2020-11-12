//Bulldog ammo
/obj/item/ammo_box/magazine/m12g
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/shotgun.dmi'
	icon_state = "m12"

/obj/item/ammo_box/magazine/m12g/stun
	icon_state = "m12_stun"

/obj/item/ammo_box/magazine/m12g/slug
	icon_state = "m12_slug"

/obj/item/ammo_box/magazine/m12g/dragon
	icon_state = "m12_pellets"

/obj/item/ammo_box/magazine/m12g/bioterror
	icon_state = "m12_pellets"

/obj/item/ammo_box/magazine/m12g/meteor
	icon_state = "m12_pellets"

/obj/item/ammo_box/magazine/m12g/scatter
	icon_state = "m12_pellets"

/obj/item/ammo_box/magazine/m12g/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "8" : "0"]"

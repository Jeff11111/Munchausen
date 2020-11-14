//Microfusion cell box
/obj/item/ammo_box/microfusion
	name = "microfusion cell box"
	icon_state = "40mm" //placeholder
	ammo_type = /obj/item/ammo_casing/microfusion
	caliber = "microfusion"
	max_ammo = 10

//Speedloathers
/obj/item/ammo_box/a357
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/revolver.dmi'
	icon_state = "slmagnum_l"

/obj/item/ammo_box/a357/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[min(6, ammo_count())]"

/obj/item/ammo_box/a357/match
	icon_state = "slmagnum_p"

/obj/item/ammo_box/a357/ap
	icon_state = "slmagnum_p"

/obj/item/ammo_box/c38
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/revolver.dmi'
	icon_state = "slpistol_r"

/obj/item/ammo_box/c38/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[min(6, ammo_count())]"

/obj/item/ammo_box/c38/lethal
	icon_state = "slpistol_l"

/obj/item/ammo_box/c38/hotshot
	icon_state = "slpistol_p"

/obj/item/ammo_box/c38/iceblox
	icon_state = "slpistol_r"

/obj/item/ammo_box/c38/dumdum
	icon_state = "slpistol_l"

/obj/item/ammo_box/c38/trac
	icon_state = "slpistol_l"

/obj/item/ammo_box/c38/match
	icon_state = "slpistol_l"

//Ammo boxes
/obj/item/ammo_box/c9mm
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/boxes.dmi'
	icon_state = "pistol_l"

/obj/item/ammo_box/c9mm/rubber
	name = "ammo box (9mm rubber)"
	icon_state = "pistol_r"
	ammo_type = /obj/item/ammo_casing/c9mm/rubber

/obj/item/ammo_box/c9mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "30" : "0"]"

/obj/item/ammo_box/c10mm
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/boxes.dmi'
	icon_state = "clrifle_l"

/obj/item/ammo_box/c10mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "60" : "0"]"

/obj/item/ammo_box/c10mm/fire
	icon_state = "clrifle_p"

/obj/item/ammo_box/c10mm/hp
	icon_state = "clrifle_hv"

/obj/item/ammo_box/c10mm/ap
	icon_state = "clrifle_p"

/obj/item/ammo_box/c10mm/soporific
	icon_state = "clrifle_r"

/obj/item/ammo_box/c45
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/boxes.dmi'
	icon_state = "magnum_l"

/obj/item/ammo_box/c45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "20" : "0"]"

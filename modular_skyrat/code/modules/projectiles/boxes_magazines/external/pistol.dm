//Pipe pistol
/obj/item/ammo_box/magazine/m10mm/makeshift
	name = "makeshift pistol magazine (10mm)"
	desc = "If this thing doesn't blow up when firing, it's a miracle."
	icon = 'modular_skyrat/icons/obj/ammo.dmi'
	icon_state = "9x19pms"
	ammo_type = /obj/item/ammo_casing/c10mm
	caliber = "10mm"
	max_ammo = 3
	multiple_sprites = 2

/obj/item/ammo_box/magazine/m10mm/makeshift/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "3" : "0"]"

//USP-Match
/obj/item/ammo_box/magazine/usp
	name = "USP magazine (.45)"
	desc = "A magazine for the security USP Match."
	icon = 'modular_skyrat/icons/obj/ammo.dmi'
	icon_state = "uspm-15"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = "9mm"
	max_ammo = 15

//M1911
/obj/item/ammo_box/magazine/m45
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/pistol.dmi'
	icon_state = "pistol45"

/obj/item/ammo_box/magazine/m45/kitchengun
	icon_state = "pistol45_r"

/obj/item/ammo_box/magazine/m45/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(), 2)]"

//Stechkin
/obj/item/ammo_box/magazine/m10mm
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/pistol.dmi'
	icon_state = "pistol10mm"

/obj/item/ammo_box/magazine/m10mm/soporific
	icon_state = "pistol10mm_r"

/obj/item/ammo_box/magazine/m10mm/fire
	icon_state = "pistol10mm_p"

/obj/item/ammo_box/magazine/m10mm/hp
	icon_state = "pistol10mm_hv"

/obj/item/ammo_box/magazine/m10mm/ap
	icon_state = "pistol10mm_l"

/obj/item/ammo_box/magazine/m10mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(), 2)]"

//APS
/obj/item/ammo_box/magazine/m9mm
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/pistol.dmi'
	icon_state = "pistol9mm"

/obj/item/ammo_box/magazine/m9mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[round(ammo_count(), 2)]"

//Nangler
/obj/item/ammo_box/magazine/m9mm/small
	name = "nangler magazine (9mm)"
	desc = "A low capacity magazine for compact pistols."
	icon_state = "small9mm"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 8

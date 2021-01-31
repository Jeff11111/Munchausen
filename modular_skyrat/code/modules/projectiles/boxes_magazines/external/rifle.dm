//Surplus rifel
/obj/item/ammo_box/magazine/m10mm/rifle
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/rifle.dmi'
	icon_state = "surplus"
	max_ammo = 7

/obj/item/ammo_box/magazine/m10mm/rifle/update_icon()
	icon_state = "[initial(icon_state)]-[ammo_count() ? 7 : 0]"

//AR-15
/obj/item/ammo_box/magazine/m556
	name = "rifle magazine (5.56mm)"
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/rifle.dmi'
	icon_state = "ihclrifle"

/obj/item/ammo_box/magazine/m556/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "30" : "0"]"

//AK-47
/obj/item/ammo_box/magazine/m762
	name = "rifle magazine (7.62mm)"
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/rifle.dmi'
	icon_state = "lrifle"
	caliber = "a762"
	ammo_type = /obj/item/ammo_casing/a762
	max_ammo = 30

/obj/item/ammo_box/magazine/m762/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "30" : "0"]"

//Vintorez
/obj/item/ammo_box/magazine/m9x39mm
	name = "rifle magazine (9x39mm)"
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/rifle.dmi'
	icon_state = "srifle"
	caliber = "9x39mm"
	ammo_type = /obj/item/ammo_casing/m9x39mm
	max_ammo = 20

/obj/item/ammo_box/magazine/m9x39mm/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "20" : "0"]"

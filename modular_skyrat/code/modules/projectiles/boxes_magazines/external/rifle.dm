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

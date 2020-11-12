//.50
/obj/item/ammo_box/magazine/sniper_rounds
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/rifle.dmi'
	icon_state = "srifle"

/obj/item/ammo_box/magazine/sniper_rounds/soporific
	icon_state = "srifle_r"

/obj/item/ammo_box/magazine/sniper_rounds/penetrator
	icon_state = "srifle_l"

/obj/item/ammo_box/magazine/sniper_rounds/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[ammo_count() ? "20" : "0"]"

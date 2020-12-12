//l6 saw box
/obj/item/ammo_box/magazine/mm195x129
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/boxes.dmi'
	icon_state = "pk_box"

/obj/item/ammo_box/magazine/mm195x129/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[CEILING(ammo_count(), 25)]"

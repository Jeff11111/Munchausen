/obj/item/ammo_box/magazine/mm195x129
	name = "box magazine (1.95x129mm)"
	icon_state = "a762-50"
	ammo_type = /obj/item/ammo_casing/mm195x129
	caliber = "mm195129"
	max_ammo = 50

/obj/item/ammo_box/magazine/mm195x129/update_icon_state()
	switch(multiple_sprites)
		if(1)
			icon_state = "[initial(icon_state)]-[stored_ammo.len * 2]"
		if(2)
			icon_state = "[initial(icon_state)]-[stored_ammo.len ? "[max_ammo * 2]" : "0"]"

/obj/item/ammo_box/magazine/mm195x129/hollow
	name = "box magazine (Hollow-Point 1.95x129mm)"
	ammo_type = /obj/item/ammo_casing/mm195x129/hollow

/obj/item/ammo_box/magazine/mm195x129/ap
	name = "box magazine (Armor Penetrating 1.95x129mm)"
	ammo_type = /obj/item/ammo_casing/mm195x129/ap

/obj/item/ammo_box/magazine/mm195x129/incen
	name = "box magazine (Incendiary 1.95x129mm)"
	ammo_type = /obj/item/ammo_casing/mm195x129/incen

/obj/item/ammo_box/magazine/mm195x129/update_icon()
	..()
	icon_state = "a762-[round(ammo_count(),10)]"

/obj/item/ammo_box/magazine/mm712x82/match
	name = "box magazine (Match 7.12x82mm)"
	ammo_type = /obj/item/ammo_casing/mm712x82/match

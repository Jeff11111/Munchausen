//piss
/obj/item/ammo_casing/energy
	fire_sound = 'modular_skyrat/sound/weapons/laser1.ogg'
	click_cooldown_override = 4

/obj/item/ammo_casing/energy/disabler
	fire_sound = 'modular_skyrat/sound/weapons/painfire1.ogg'
	select_name = "sparq"
	e_cost = 100
	click_cooldown_override = 8

/obj/item/ammo_casing/energy/disabler/lowcost
	e_cost = 60
	click_cooldown_override = 6

//makeshift laser rifle
/obj/item/ammo_casing/energy/laser/makeshiftlasrifle
	e_cost = 750
	projectile_type = /obj/item/projectile/beam/laser/makeshiftlasrifle
	select_name = "strong"

/obj/item/ammo_casing/energy/laser/makeshiftlasrifle/medium
	e_cost = 375
	projectile_type = /obj/item/projectile/beam/laser/makeshiftlasrifle/medium
	select_name = "medium"
	fire_sound = 'sound/weapons/laser2.ogg'

/obj/item/ammo_casing/energy/laser/makeshiftlasrifle/weak
	e_cost = 180
	projectile_type = /obj/item/projectile/beam/laser/makeshiftlasrifle/weak
	select_name = "weak"
	fire_sound = 'sound/weapons/laser2.ogg'

//captain's laser gun
/obj/item/ammo_casing/energy/lasergun/captain
	e_cost = 80
	projectile_type = /obj/item/projectile/beam/laser/hellfire/ultra
	select_name = "hell-laser"

/obj/item/ammo_casing/energy/disabler/captain
	e_cost = 60
	projectile_type = /obj/item/projectile/beam/disabler/hellfire/ultra
	select_name = "hell-sparq"

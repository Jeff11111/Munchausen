//ultra laser buff
/obj/item/projectile/beam
	impact_effect_type = null
	impact_type = null
	pixels_per_second = TILES_TO_PIXELS(22) //very fast lol

/obj/item/projectile/beam/laser
	bare_wound_bonus = 15
	wound_bonus = 30
	pixels_per_second = TILES_TO_PIXELS(22) //very fast lol
	impact_effect_type = null
	impact_type = null

//disabler changes
/obj/item/projectile/beam/disabler
	icon = 'modular_skyrat/icons/obj/bobstation/guns/projectiles/projectiles.dmi'
	icon_state = "sparq"
	damage = 0
	pain = 70
	wound_bonus = 0
	bare_wound_bonus = 0
	pixels_per_second = TILES_TO_PIXELS(22) //very fast lol
	impact_effect_type = null
	impact_type = null
	light_color = null
	eyeblur = 2

//makeshift laser rifle
/obj/item/projectile/beam/laser/makeshiftlasrifle
	damage = 20

/obj/item/projectile/beam/laser/makeshiftlasrifle/medium
	name = "medium laser"
	damage = 10

/obj/item/projectile/beam/laser/makeshiftlasrifle/weak
	name = "weak laser"
	damage = 5

//hellfire disabler
/obj/item/projectile/beam/disabler/hellfire
	name = "hellfire disabler beam"
	damage = 0
	pain = 85
	light_color = LIGHT_COLOR_ORANGE
	eyeblur = 2

/obj/item/projectile/beam/disabler/hellfire/Initialize()
	. = ..()
	transform *= 2

//captain's laser gun
/obj/item/projectile/beam/laser/hellfire/ultra
	name = "deluxe hellfire laser"
	damage = 30
	wound_bonus = 36
	bare_wound_bonus = 30

/obj/item/projectile/beam/disabler/hellfire/ultra
	name = "deluxe hellfire disabler beam"
	damage = 0
	pain = 100
	color = LIGHT_COLOR_PURPLE
	light_color = LIGHT_COLOR_PURPLE
	eyeblur = 6

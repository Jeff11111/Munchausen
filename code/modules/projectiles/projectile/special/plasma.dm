/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BRUTE
	damage = 20
	range = 4
	dismemberment = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	var/pressure_decrease_active = FALSE
	var/pressure_decrease = 0.5
	var/mine_range = 3 //mines this many additional tiles of rock
	tracer_type = /obj/effect/projectile/tracer/plasma_cutter
	muzzle_type = /obj/effect/projectile/muzzle/plasma_cutter
	impact_type = /obj/effect/projectile/impact/plasma_cutter
	wound_bonus = 15

/obj/item/projectile/plasma/adv
	damage = 28
	range = 5
	mine_range = 5
	wound_bonus = 30

/obj/item/projectile/plasma/adv/mech
	damage = 40
	range = 9
	mine_range = 3
	wound_bonus = 40

/obj/item/projectile/plasma/turret
	//Between normal and advanced for damage, made a beam so not the turret does not destroy glass
	name = "plasma beam"
	damage = 24
	range = 7
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
	wound_bonus = 20

/obj/item/projectile/plasma/weak
	dismemberment = 0
	damage = 10
	range = 4
	mine_range = 0

// .50 (Sniper)

/obj/item/projectile/bullet/p50
	name =".50 BMG bullet"
	pixels_per_second = TILES_TO_PIXELS(25)
	damage = 85
	knockdown = 100
	armour_penetration = 75        //This means it will go clean through bulletproof armor and most hardsuits, it's 18000> Joules of kinetic force jfc
	zone_accuracy_factor = 100		//This guarantees the projectile with hit the tile it's fired at 100%
	var/breakthings = TRUE

/obj/item/projectile/bullet/p50/on_hit(atom/target, blocked = 0)
	if(isobj(target) && (blocked != 100) && breakthings)
		var/obj/O = target
		O.take_damage(80, BRUTE, "bullet", FALSE)
	return ..()

/obj/item/projectile/bullet/p50/soporific
	name =".50 soporific bullet"
	armour_penetration = 0
	damage = 0
	dismemberment = 0
	knockdown = 0
	breakthings = FALSE
	wound_bonus = CANT_WOUND

/obj/item/projectile/bullet/p50/soporific/on_hit(atom/target, blocked = FALSE)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.Sleeping(400)
	return ..()

/obj/item/projectile/bullet/p50/penetrator
	name =".50 penetrator bullet"
	icon_state = "gauss"
	name = "penetrator round"
	damage = 60
	movement_type = FLYING | UNSTOPPABLE
	knockdown = 0
	breakthings = FALSE
	wound_bonus = 50 //goes clean through lmao

/obj/item/projectile/bullet/p50/penetrator/shuttle //Nukeop Shuttle Variety
	icon_state = "gaussstrong"
	damage = 25
	pixels_per_second = TILES_TO_PIXELS(33.33)
	range = 16

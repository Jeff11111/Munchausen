//Surplus rifle changes, because its fucking actual garbage, a fucking PIPE PISTOL is better.
/obj/item/gun/ballistic/automatic/surplus
	icon = 'modular_skyrat/icons/obj/bobstation/guns/rifle.dmi'
	icon_state = "surplus"
	fire_delay = 5
	w_class = WEIGHT_CLASS_BULKY
	safety_sound = 'modular_skyrat/sound/guns/safety2.ogg'
	sling_icon_state = "surplus-sling"
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY

//Bolt-action rifle
/obj/item/gun/ballistic/shotgun/boltaction
	name = "7.62 bolt action rifle"
	desc = "A crappy 7.62mm chambered Mosin Nagant styled rifle. Although it has taken quite a beating, you can still make out the \"Bubba Arms\" logo."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/40x32.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_righthand.dmi'
	icon_state = "nugget"
	item_state = "baction"
	safety_sound = 'modular_skyrat/sound/guns/safety2.ogg'
	fire_sound = 'modular_skyrat/sound/weapons/rifle2.ogg'
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY

/obj/item/gun/ballistic/shotgun/boltaction/update_icon()
	..()
	icon_state = "[initial(icon_state)][bolt_open ? "-open" : ""][chambered ? "" : "-e"]"
	item_state = "[initial(item_state)][is_wielded ? "-wielded" : ""]"

//Bubba-action rifle
/obj/item/gun/ballistic/shotgun/boltaction/polymer
	name = "7.62 bolt action bubba"
	desc = "A crappy 7.62mm chambered mosin nagant styled rifle. Some psychopath has turned it into a polymerized mess."
	icon_state = "nugget_bubba"
	item_state = "baction_polymer"
	weapon_weight = WEAPON_HEAVY

//Marlin model 1894
/obj/item/gun/ballistic/shotgun/boltaction/marlin
	name = ".357 lever action rifle"
	desc = "Ye olde grandpa's rifle, but now mass-produced by \"Bubba Arms\". No matter what, it's still a good rifle."
	icon_state = "marlin"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/marlin
	weapon_weight = WEAPON_HEAVY

//AR-15
/obj/item/gun/ballistic/automatic/ar
	name = "5.56 assault rifle"
	desc = "NT-ARG - A robust assault rifle used by Nanotrasen fighting forces."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/rifle.dmi'
	icon_state = "arg"
	safety_sound = 'modular_skyrat/sound/guns/safety2.ogg'
	fire_sound = 'modular_skyrat/sound/guns/smg1.ogg'
	slot_flags = ITEM_SLOT_BACK

//AK-47
/obj/item/gun/ballistic/automatic/ak
	name = "7.62 assault rifle"
	desc = "The Tiger Cooperative NCK-7.62 assault rifle, favored by Tiger Cooperative operatives and mass shooters."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/rifle.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_lefthand.dmi'
	icon_state = "ak"
	item_state = "ak"
	safety_sound = 'modular_skyrat/sound/guns/safety2.ogg'
	fire_sound = 'modular_skyrat/sound/guns/smg1.ogg'
	mag_type = /obj/item/ammo_box/magazine/m762
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	can_suppress = FALSE
	burst_size = 3
	burst_shot_delay = 1

/obj/item/gun/ballistic/automatic/ak/update_icon()
	..()
	item_state = "[initial(item_state)][magazine ? "" : "-e"][is_wielded ? "-wielded" : ""]"

/obj/item/gun/ballistic/automatic/ak/build_magazine_overlay()
	. = mutable_appearance(icon, "[initial(icon_state)]-[generic_magazine_overlays ? "mag[magazine.max_ammo]" : initial(magazine.icon_state)]")

/obj/item/gun/ballistic/automatic/ak/polymer
	icon_state = "ak_polymer"
	item_state = "ak_polymer"

//Vintorez
/obj/item/gun/ballistic/automatic/vintorez
	name = "9x39mm rifle"
	desc = "A limited MI13 production run of replicas of the classic VSS Vintorez. This suppressed rifle has garnered a lot of fame among the stealthier boarding parties."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/rifle.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_lefthand.dmi'
	icon_state = "vintorez"
	item_state = "vintorez"
	safety_sound = 'modular_skyrat/sound/guns/safety2.ogg'
	fire_sound = 'modular_skyrat/sound/weapons/vintorez.ogg'
	sound_suppressed = 'modular_skyrat/sound/weapons/vintorez.ogg'
	mag_type = /obj/item/ammo_box/magazine/m9x39mm
	slot_flags = ITEM_SLOT_BACK
	can_unsuppress = FALSE
	generic_magazine_overlays = TRUE
	burst_size = 1 //no burst firing that's wacky
	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/ballistic/automatic/vintorez/Initialize()
	. = ..()
	var/obj/item/suppressor/nigger = new()
	nigger.forceMove(src)
	install_suppressor(nigger)

/obj/item/gun/ballistic/automatic/vintorez/update_icon()
	. = ..()
	item_state = "[initial(item_state)][magazine ? "" : "-e"][is_wielded ? "-wielded" : ""]"

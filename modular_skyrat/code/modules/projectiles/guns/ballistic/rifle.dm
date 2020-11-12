//Surplus rifle changes, because its fucking actual garbage, a fucking PIPE PISTOL is better.
/obj/item/gun/ballistic/automatic/surplus
	icon = 'modular_skyrat/icons/obj/bobstation/guns/rifle.dmi'
	icon_state = "surplus"
	fire_delay = 5
	w_class = WEIGHT_CLASS_BULKY
	safety_sound = 'modular_skyrat/sound/guns/safety2.ogg'
	sling_icon_state = "surplus-sling"

/obj/item/gun/ballistic/automatic/surplus/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][magazine ? "" : "-nomag"][safety ? "-safe" : ""]"

//Bolt-action rifle
/obj/item/gun/ballistic/shotgun/boltaction
	name = "bolt action rifle"
	desc = "A crappy 7.62 chambered rifle. Although it has taken quite a beating, you can still make out the \"Gorlex Corporal\" logo."
	icon_state = "baction"
	fire_sound = 'modular_skyrat/sound/weapons/rifle2.ogg'
	sling_icon_state = "baction-sling"

/obj/item/gun/ballistic/shotgun/boltaction/update_icon()
	..()
	icon_state = "[initial(icon_state)][bolt_open ? "" : "-e"]"

//AR-15
/obj/item/gun/ballistic/automatic/ar
	icon = 'modular_skyrat/icons/obj/bobstation/guns/rifle.dmi'
	icon_state = "arg"
	safety_sound = 'modular_skyrat/sound/guns/safety2.ogg'
	fire_sound = 'modular_skyrat/sound/guns/smg1.ogg'

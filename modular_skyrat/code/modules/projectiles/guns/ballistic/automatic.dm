//This ass can fart
/obj/item/gun/ballistic/automatic
	fire_sound = 'modular_skyrat/sound/guns/smg2.ogg'
	
//WT550 augh
/obj/item/gun/ballistic/automatic/wt550
	name = "security semi-auto WT-550"
	desc = "An outdated personal defence weapon. Uses 4.6x30mm rounds."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/smg.dmi'
	icon_state = "wt550"
	item_state = "arg"
	righthand_file = 'modular_skyrat/icons/mob/inhands/weapons/guns_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/mob/inhands/weapons/guns_lefthand.dmi'

/obj/item/gun/ballistic/automatic/wt550/update_icon()
	..()
	icon_state = "[initial(icon_state)]-[magazine ? magazine.ammo_count() : 0]"

/obj/item/gun/ballistic/automatic/wt550/update_overlays()
	. = ..()
	safety_overlay = mutable_appearance(icon, "[initial(icon_state)][safety ? "-safety" : "-unsafety"]")

//AR-15
/obj/item/gun/ballistic/automatic/ar
	icon = 'modular_skyrat/icons/obj/bobstation/guns/rifle.dmi'
	icon_state = "arg"
	safety_sound = 'modular_skyrat/sound/guns/safety2.ogg'
	fire_sound = 'modular_skyrat/sound/guns/smg1.ogg'

/obj/item/gun/ballistic/automatic/ar/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][magazine ? "" : "-nomag"][safety ? "-safe" : ""]"

//israel gun
/obj/item/gun/ballistic/automatic/mini_uzi
	icon = 'modular_skyrat/icons/obj/bobstation/guns/smg.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/weapons/guns_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/mob/inhands/weapons/guns_lefthand.dmi'
	icon_state = "uzi"
	item_state = "uzi"

/obj/item/gun/ballistic/automatic/mini_uzi/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/gun/ballistic/automatic/mini_uzi/update_overlays()
	..()
	if(magazine)
		add_overlay("[initial(icon_state)]-mag")

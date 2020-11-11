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

/obj/item/gun/ballistic/automatic/wt550/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "-e" : ""]"
	if(magazine)
		add_overlay("[initial(icon_state)]-mag")

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
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/smg_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/smg_lefthand.dmi'
	icon_state = "uzi"
	item_state = "uzi"

/obj/item/gun/ballistic/automatic/mini_uzi/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"

/obj/item/gun/ballistic/automatic/mini_uzi/update_overlays()
	..()
	if(magazine)
		add_overlay("[initial(icon_state)]-mag")

//Saber should be an MP5 that would be cool i think
/obj/item/gun/ballistic/automatic/proto
	icon = 'modular_skyrat/icons/obj/bobstation/guns/40x32.dmi'
	icon_state = "mp5"
	item_state = "arg"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Looks eerily similar to another submachine gun..."
	can_suppress = FALSE

/obj/item/gun/ballistic/automatic/proto/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][magazine ? "" : "-nomag"][safety ? "-safe" : ""]"

//Bulldog but sound better
//also eris sprite
/obj/item/gun/ballistic/automatic/shotgun
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/shotgun_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/shotgun_righthand.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/obj/bobstation/guns/worn/back.dmi'
	icon_state = "bo"
	item_state = "shotgun"
	fire_sound = 'modular_skyrat/sound/guns/shotgun.ogg'
	inhand_x_dimension = 32
	inhand_y_dimension = 32

/obj/item/gun/ballistic/automatic/shotgun/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"
	item_state = "[initial(item_state)][is_wielded ? "-wielded" : ""]"
	if(magazine)
		add_overlay("[initial(magazine.icon_state)]")

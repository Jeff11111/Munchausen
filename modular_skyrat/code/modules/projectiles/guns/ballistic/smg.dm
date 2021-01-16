//Israel gun
/obj/item/gun/ballistic/automatic/mini_uzi
	name = "9mm submachine gun"
	desc = "The Type 3 UZI - A lightweight, burst-fire submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/smg.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/smg_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/smg_lefthand.dmi'
	icon_state = "uzi"
	item_state = "uzi"
	generic_magazine_overlays = FALSE

/obj/item/gun/ballistic/automatic/mini_uzi/update_icon()
	..()
	item_state = "[initial(item_state)][magazine ? "" : "-e"]"

//Saber should be an MP5 that would be cool i think
/obj/item/gun/ballistic/automatic/proto
	name = "9mm submachine gun"
	desc = "The NT SABR - A prototype three-round burst 9mm submachine gun. Looks eerily similar to another submachine gun..."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/40x32.dmi'
	icon_state = "mp5"
	item_state = "arg"
	suppressed_pixel_x = 5

//C20R
/obj/item/gun/ballistic/automatic/c20r
	name = ".45 submachine gun"
	icon = 'modular_skyrat/icons/obj/bobstation/guns/smg.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/smg_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/smg_lefthand.dmi'
	icon_state = "c20r"
	item_state = "c20r"
	generic_magazine_overlays = FALSE

//WT550 augh
/obj/item/gun/ballistic/automatic/wt550
	name = "4.6x30mm submachine gun"
	desc = "An outdated personal defence weapon. Uses 4.6x30mm rounds."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/smg.dmi'
	icon_state = "wt550"
	item_state = "arg"

//P90 thing
/obj/item/gun/ballistic/automatic/m90
	name = "5.56 submachine gun"
	desc = "A three-round burst 5.56 toploading carbine, designated 'M-90GL'. Has an attached underbarrel grenade launcher which can be toggled on and off."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/smg.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/smg_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/smg_lefthand.dmi'
	icon_state = "p90"
	item_state = "p90"
	generic_magazine_overlays = TRUE

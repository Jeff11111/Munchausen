//Base pistol changes
/obj/item/gun/ballistic/automatic/pistol
	generic_magazine_overlays = TRUE

/obj/item/gun/ballistic/automatic/pistol/update_icon()
	..()
	item_state = "[initial(item_state)][suppressed ? "suppressed" : ""]"

//Stechkin v2
/obj/item/gun/ballistic/automatic/pistol
	name = "10mm pistol"
	desc = "The Sosig 10mm pistol - A favorite amongst the Syndicate. Has a threaded barrel for suppressors."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/pistol.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "pistol10mm"
	fire_sound = 'modular_skyrat/sound/guns/pistol2.ogg'
	suppressed_pixel_x = 4

//Modular pistol
/obj/item/gun/ballistic/automatic/pistol/modular
	icon = 'modular_skyrat/icons/obj/bobstation/guns/pistol.dmi'
	icon_state = "modularpistol"
	suppressed_pixel_x = 4

//Stechkin APS v2
/obj/item/gun/ballistic/automatic/pistol/cz
	name = "burstfire 9mm pistol"
	desc = "The CZ-80 automatic pistol - A unwieldy firearm to pepper any assailant full of holes."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/pistol.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/pistol_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/pistol_righthand.dmi'
	icon_state = "czauto"
	item_state = "czauto"
	suppressed_pixel_x = 2
	fire_sound = 'modular_skyrat/sound/guns/pistol1.ogg'
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/m9mm
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

//Glock 17
/obj/item/gun/ballistic/automatic/pistol/cz/glock
	name = "burstfire 9mm pistol"
	desc = "The NT Lawman 17 - A decent and lightweight polymer firearm for general law enforcement use."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/pistol.dmi'
	icon_state = "glock"
	item_state = "glock"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/m9mm
	can_suppress = FALSE
	burst_size = 2
	fire_delay = 3
	suppressed_pixel_x = 8
	actions_types = list(/datum/action/item_action/toggle_firemode)
	fire_sound = 'modular_skyrat/sound/guns/pistol1.ogg'

/obj/item/gun/ballistic/automatic/pistol/cz/glock/bbc
	icon_state = "glock_bbc"
	item_state = "glock_bbc"

//Makarov
/obj/item/gun/ballistic/automatic/pistol/makarov
	name = "9mm pistol"
	desc = "The DonkCo. Makarov - A compact firearm for use in covert operations."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/pistol.dmi'
	icon_state = "makarov"
	item_state = "makarov"
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/pistol_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/pistol_righthand.dmi'
	fire_sound = 'modular_skyrat/sound/guns/pistol1.ogg'
	mag_type = /obj/item/ammo_box/magazine/m9mm
	suppressed_pixel_x = 5
	can_suppress = TRUE

//Nangler
/obj/item/gun/ballistic/automatic/pistol/nangler
	name = "9mm pistol"
	desc = "ML Nangler - Standard issue security firearm, widely used by low tier corporate militias. \
			Unreliable at best, this small sidearm is chambered in 9mm."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/pistol.dmi'
	icon_state = "pistol9mm"
	item_state = "pistol9mm"
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/pistol_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/pistol_righthand.dmi'
	fire_sound = 'modular_skyrat/sound/guns/pistol1.ogg'
	mag_type = /obj/item/ammo_box/magazine/m9mm/small
	can_suppress = FALSE

//M1911
/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper .45 pistol"
	desc = "A decent modern replica of the classic Colt M1911, with a small magazine capacity."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/pistol.dmi'
	icon_state = "pistol45"
	item_state = "pistol45"
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/pistol_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/pistol_righthand.dmi'
	fire_sound = 'modular_skyrat/sound/guns/pistol2.ogg'
	suppressed_pixel_x = 8

//Kitchen gun
/obj/item/gun/ballistic/automatic/pistol/m1911/kitchengun
	icon_state = "bigcolt"

//Captain's M1911
/obj/item/gun/ballistic/automatic/pistol/m1911/captain
	name = "\improper .45 pistol"
	icon_state = "captain45"
	desc = "A prized silver Colt M1911. A classy firearm fit for a king."

//USP match
/obj/item/gun/ballistic/automatic/pistol/uspm
	name = "tactical .45 pistol"
	desc = "The USP Match - A black and white .45 handgun to make the wielder a free man."
	lefthand_file = 'modular_skyrat/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "usp-m"
	icon_state = "usp-m"
	fire_sound = 'modular_skyrat/sound/weapons/uspshot.ogg'
	mag_type = /obj/item/ammo_box/magazine/usp
	can_suppress = FALSE
	obj_flags = UNIQUE_RENAME

//Deagle v2
/obj/item/gun/ballistic/automatic/pistol/deagle
	name = ".50 AE pistol"
	desc = "The Gorlex Arms Deagle - A pistol for those who need to compensate for something."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/pistol.dmi'
	icon_state = "deagle"
	fire_sound = 'modular_skyrat/sound/guns/pistol2.ogg'
	suppressed_pixel_x = 4

/obj/item/gun/ballistic/automatic/pistol/deagle/gold
	icon_state = "deagle_golden"

//AT pistol
/obj/item/gun/ballistic/automatic/pistol/antitank
	icon = 'modular_skyrat/icons/obj/bobstation/guns/pistol.dmi'
	icon_state = "antitank"
	fire_sound = 'modular_skyrat/sound/weapons/rifle2.ogg'

//Pipe pistol
/obj/item/gun/ballistic/automatic/pistol/makeshift
	name = "10mm pipe pistol"
	desc = "A somewhat bulky aberration of pipes and wood, in the form of a pistol. It probably should get the job done, still."
	icon = 'modular_skyrat/icons/obj/guns/projectile.dmi'
	icon_state = "pistolms"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/m10mm/makeshift
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 3
	actions_types = list()

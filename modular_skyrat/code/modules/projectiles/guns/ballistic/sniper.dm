//.50 sniper
/obj/item/gun/ballistic/automatic/sniper_rifle
	icon = 'modular_skyrat/icons/obj/bobstation/guns/rifle.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_lefthand.dmi'
	generic_magazine_overlays = TRUE

/obj/item/gun/ballistic/automatic/sniper_rifle/update_icon()
	..()
	item_state = "[initial(item_state)][is_wielded ? "-wielded" : ""]"

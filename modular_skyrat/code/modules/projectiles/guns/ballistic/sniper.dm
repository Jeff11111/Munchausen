//.50 sniper
/obj/item/gun/ballistic/automatic/sniper_rifle
	icon = 'modular_skyrat/icons/obj/bobstation/guns/rifle.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_righthand.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/rifle_lefthand.dmi'
	icon_state = "heavysniper"
	generic_magazine_overlays = TRUE
	fire_sound = 'modular_skyrat/sound/weapons/rifle2.ogg'

/obj/item/gun/ballistic/automatic/sniper_rifle/update_icon()
	..()
	item_state = "[initial(item_state)][is_wielded ? "-wielded" : ""]"

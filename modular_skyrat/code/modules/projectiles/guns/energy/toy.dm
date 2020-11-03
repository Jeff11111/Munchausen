//le warning runtime
/obj/item/gun/energy/laser/bluetag
	icon = 'modular_skyrat/icons/obj/bobstation/guns/energy.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/energy_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/energy_righthand.dmi'
	icon_state = "bluetoy"

/obj/item/gun/energy/laser/bluetag/update_icon()
	..()
	icon_state = "[initial(icon_state)]"

/obj/item/gun/energy/laser/redtag
	icon = 'modular_skyrat/icons/obj/bobstation/guns/energy.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/energy_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/energy_righthand.dmi'
	icon_state = "redtoy"

/obj/item/gun/energy/laser/redtag/update_icon()
	..()
	icon_state = "[initial(icon_state)]"

//Energy gun
/obj/item/gun/energy/e_gun
	name = "energy gun"
	desc = "A basic hybrid energy gun with two settings: sparq and kill."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/energy.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/guns_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/guns_righthand.dmi'
	icon_state = "hellgun"
	item_state = null
	modifystate = FALSE
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)

//Sparq gun
/obj/item/gun/energy/e_gun/advtaser
	name = "sparq gun"
	desc = "NT Detainer - A cheap less than lethal energy weapon that fires sparq disabler beams, which cause massive pain on the target."
	icon_state = "painpistol"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)

/obj/item/gun/energy/e_gun/advtaser/large
	name = "large sparq gun"
	desc = "NT Riot - A less cheap, less than lethal energy weapon that fires sparq disabler beams, which cause massive pain on the target."
	icon_state = "painpistolx"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/lowcost)

//Energy gun
/obj/item/gun/energy/e_gun
	name = "energy gun"
	desc = "A basic hybrid energy gun with two settings: sparq and kill."
	icon = 'modular_skyrat/icons/obj/bobstation/guns/energy.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/energy_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/energy_righthand.dmi'
	icon_state = "hellgun"
	item_state = null
	modifystate = FALSE
	shaded_charge = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)

//Sparq gun
/obj/item/gun/energy/e_gun/advtaser
	name = "sparq gun"
	desc = "NT Detainer - A cheap less than lethal energy weapon that fires sparq disabler beams, which cause massive pain on the target."
	icon_state = "painpistol"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	cell_type = /obj/item/stock_parts/cell{charge = 600; maxcharge = 600}

/obj/item/gun/energy/e_gun/advtaser/large
	name = "large sparq gun"
	desc = "NT Riot - A less cheap, less than lethal energy weapon that fires sparq disabler beams, which cause massive pain on the target."
	icon_state = "painpistolx"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/lowcost)
	cell_type = /obj/item/stock_parts/cell{charge = 720; maxcharge = 720}

//Ion rifle
/obj/item/gun/energy/ionrifle
	shaded_charge = TRUE

//Pulse rifle
/obj/item/gun/energy/pulse
	shaded_charge = TRUE

/datum/job/warden
	title = "Lieutenant"
	supervisors = "the Chief Enforcer"
	department_head = list("Chief Enforcer")
	total_positions = 0
	spawn_positions = 0

/datum/outfit/job/warden
	backpack_contents = list(
					/obj/item/melee/classic_baton/black=1,
					)
	suit_store = /obj/item/gun/energy/e_gun/advtaser/large

/obj/item/choice_beacon/warden
	name = "lieutenant's weapon beacon"
	desc = "A beacon, allowing the lieutenant to select between two available models of personal firearms."

/obj/item/choice_beacon/warden/generate_display_names()
	var/static/list/shotties
	if(!shotties)
		shotties = list()
		shotties["Nangler"] = /obj/item/storage/briefcase/choice/nangler
	return shotties

/obj/item/storage/briefcase/choice
	name = "gun briefcase"
	desc = "Smells like omelette du fromage."

/obj/item/storage/briefcase/choice/nangler/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/nangler(src)
	new /obj/item/ammo_box/magazine/m9mm/small(src)

/obj/item/storage/briefcase/choice/m1911/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/m1911(src)
	new /obj/item/ammo_box/magazine/m45(src)

/obj/item/storage/briefcase/choice/glock/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/APS/glock(src)
	new /obj/item/ammo_box/magazine/m9mm(src)

/obj/item/storage/briefcase/choice/mateba/PopulateContents()
	new /obj/item/gun/ballistic/revolver/mateba(src)
	new /obj/item/ammo_box/a357(src)

/obj/item/storage/briefcase/choice/bladerunner/PopulateContents()
	new /obj/item/gun/ballistic/revolver/mateba/bladerunner(src)
	new /obj/item/ammo_box/a357(src)

/obj/item/storage/briefcase/choice/modular/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol/modular(src)
	new /obj/item/ammo_box/magazine/m10mm(src)

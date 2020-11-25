/datum/job/roboticist
	title = "Roboticist"
	flag = ROBOTICIST
	department_head = list("Research Director")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 2
	spawn_positions = 2
	supervisors = "the research director"
	selection_color = "#9574cd"
	exp_requirements = 120 //SKYRAT CHANGE - upping the exp time on jobs
	exp_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/roboticist

	access = list(ACCESS_ROBOTICS, ACCESS_TOX, ACCESS_TOX_STORAGE, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM, ACCESS_XENOBIOLOGY, ACCESS_GENETICS)
	minimal_access = list(ACCESS_ROBOTICS, ACCESS_TECH_STORAGE, ACCESS_MORGUE, ACCESS_RESEARCH, ACCESS_MINERAL_STOREROOM)
	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_SCI

	starting_modifiers = list(/datum/skill_modifier/job/level/wiring, /datum/skill_modifier/job/affinity/wiring)

	display_order = JOB_DISPLAY_ORDER_ROBOTICIST
	blacklisted_quirks = list(/datum/quirk/mute, /datum/quirk/brainproblems, /datum/quirk/nonviolent, /datum/quirk/paraplegic, /datum/quirk/blindness, /datum/quirk/monophobia)
	threat = 1


/datum/job/roboticist/equip(mob/living/carbon/human/H, visualsOnly, announce, latejoin, datum/outfit/outfit_override, client/preference_source)
	..()
	if(SSevents.holidays && SSevents.holidays[KILLDOZER_DAY])
		var/obj/item/card/id/id = H.wear_id
		if(id)
			id.update_label(H.name, "Welder")
		var/obj/item/gun/ballistic/automatic/ar/ar = new(get_turf(H))
		H.put_in_hands(ar)

/datum/outfit/job/roboticist
	name = "Roboticist"
	jobtype = /datum/job/roboticist

	belt = /obj/item/storage/belt/utility/full
	l_pocket = /obj/item/pda/roboticist
	ears = /obj/item/radio/headset/headset_sci
	uniform = /obj/item/clothing/under/rank/rnd/roboticist
	suit = /obj/item/clothing/suit/toggle/labcoat

	backpack = /obj/item/storage/backpack/science/robo //SKYRAT CHANGE - Roboticist Bags (CHANGE)
	satchel = /obj/item/storage/backpack/satchel/tox/robo //SKYRAT CHANGE - Roboticist Bags (CHANGE)
	duffelbag = /obj/item/storage/backpack/duffel/robo //SKYRAT CHANGE - Roboticist Bags (ADDITION)

	pda_slot = SLOT_L_STORE

/datum/job/brig_physician
	title = "Brig Physician"
	flag = DOCTOR
	department_head = list("Chief Enforcer", "Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief enforcer and chief medical officer"
	selection_color = "#c02f2f"
	minimal_player_age = 7
	exp_requirements = 120 //SKYRAT CHANGE - lowers medical exp requirement
	exp_type = EXP_TYPE_MEDICAL

	outfit = /datum/outfit/job/brig_phys

	paycheck = PAYCHECK_MEDIUM
	paycheck_department = ACCOUNT_MED

	access = list(ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_LEAVE_GENPOP, ACCESS_ENTER_GENPOP, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_GENETICS, ACCESS_CLONING, ACCESS_VIROLOGY, ACCESS_MINERAL_STOREROOM)
	minimal_access = list(ACCESS_SEC_DOORS, ACCESS_BRIG, ACCESS_COURT, ACCESS_MAINT_TUNNELS, ACCESS_LEAVE_GENPOP, ACCESS_ENTER_GENPOP, ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CLONING, ACCESS_MINERAL_STOREROOM)

	display_order = JOB_DISPLAY_ORDER_BRIG_PHYSICIAN
	important_job = TRUE

/datum/outfit/job/brig_phys
	name = "Brig Physician"
	jobtype = /datum/job/brig_physician

	belt = /obj/item/pda/security
	ears = /obj/item/radio/headset/headset_medsec
	uniform = /obj/item/clothing/under/rank/brig_phys
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/hud/health/sunglasses
	suit_store = /obj/item/flashlight/seclite
	l_hand = /obj/item/storage/firstaid/regular
	suit = /obj/item/clothing/suit/armor/vest/combat_medic
	head = /obj/item/clothing/head/helmet/combat_medic

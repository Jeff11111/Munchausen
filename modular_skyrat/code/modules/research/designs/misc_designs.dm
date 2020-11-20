/////////////////////////////////////////
/////////////////HUDs////////////////////
/////////////////////////////////////////

/datum/design/mining_hud
	name = "Ore Scanner HUD"
	desc = "A heads-up display that scans the surrounding ores and displays them to the user."
	id = "mining_hud"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 500, /datum/material/glass = 500, /datum/material/uranium = 500)
	build_path = /obj/item/clothing/glasses/hud/mining
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/mining_hud_prescription
	name = "Ore Scanner HUD (Prescription)"
	desc = "A heads-up display that scans the surrounding ores and displays them to the user. This one has a prescription lens."
	id = "mining_hud_prescription"
	build_type = PROTOLATHE
	materials = list(/datum/material/silver = 850, /datum/material/glass = 500, /datum/material/uranium = 500)
	build_path = /obj/item/clothing/glasses/hud/mining/prescription
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/////////////////////////////////////////
/////////////////Tape////////////////////
/////////////////////////////////////////

/datum/design/sticky_tape
	name = "Sticky Tape"
	id = "sticky_tape"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 500)
	build_path = /obj/item/stack/sticky_tape
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/surgical_tape
	name = "Surgical Tape"
	id = "surgical_sticky_tape"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 750)
	build_path = /obj/item/stack/sticky_tape/surgical
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/super_sticky_tape
	name = "Super Sticky Tape"
	id = "super_sticky_tape"
	build_type = PROTOLATHE
	materials = list(/datum/material/plastic = 3000)
	build_path = /obj/item/stack/sticky_tape/super
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/pointy_tape
	name = "Pointy Tape"
	id = "pointy_tape"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/plastic = 1000)
	build_path = /obj/item/stack/sticky_tape/pointy
	category = list("Tool Designs")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/////////////////////////////////////////
/////////////////Cassettes///////////////
/////////////////////////////////////////

/datum/design/cassette
	name = "Cassette"
	materials = list(/datum/material/iron = 2000, /datum/material/plastic = 1000)
	build_path = /obj/item/device/cassette
	build_type = PROTOLATHE | IMPRINTER
	construction_time = 60
	category = list("Subspace Telecomms")

/datum/design/cassette/os13
	name = "Cassette Vol. 1"
	id = "cassette_os13"
	build_path = /obj/item/device/cassette/os13

/datum/design/cassette/manwhosoldtheworld
	name = "Cassette Vol. 2"
	id = "cassette_manwhosoldtheworld"
	build_path = /obj/item/device/cassette/manwhosoldtheworld

/datum/design/cassette/thecaretaker
	name = "Cassette Vol. 3"
	id = "cassette_thecaretaker"
	build_path = /obj/item/device/cassette/everywhereattheendoftime

/datum/design/cassette/doom
	name = "Cassette Vol. 4"
	id = "cassette_doom"
	build_path = /obj/item/device/cassette/doom

/datum/design/cassette/irreversible
	name = "Cassette Vol. 5"
	id = "cassette_irreversible"
	build_path = /obj/item/device/cassette/irreversible

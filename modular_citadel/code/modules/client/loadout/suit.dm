/datum/gear/poncho
	name = "Poncho"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/poncho

/datum/gear/ponchogreen
	name = "Green poncho"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/poncho/green

/datum/gear/ponchored
	name = "Red poncho"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/poncho/red

/datum/gear/redhood
	name = "Red cloak"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/cloak/david
	cost = 3

/datum/gear/jacketbomber
	name = "Bomber jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket

/datum/gear/jacketleather
	name = "Leather jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/leather

/datum/gear/overcoatleather
	name = "Leather overcoat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/leather/overcoat

/datum/gear/jacketpuffer
	name = "Puffer jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/puffer

/datum/gear/vestpuffer
	name = "Puffer vest"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/puffer/vest

/datum/gear/jacketlettermanbrown
	name = "Brown letterman jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/letterman

/datum/gear/jacketlettermanred
	name = "Red letterman jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/letterman_red

/datum/gear/jacketlettermanNT
	name = "Nanotrasen letterman jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/letterman_nanotrasen

/datum/gear/coat
	name = "Winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat

/datum/gear/coat/aformal
	name = "Assistant's formal winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/aformal

/datum/gear/coat/runed
	name = "Runed winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/narsie/fake

/datum/gear/coat/brass
	name = "Brass winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/ratvar/fake

/datum/gear/coat/polycoat
	name = "Polychromic winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/polychromic
	cost = 4 //too many people with neon green coats is hard on the eyes

/datum/gear/coat/med
	name = "Medical winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/medical
	restricted_roles = list("Chief Medical Officer", "Medical Doctor") // Reserve it to Medical Doctors and their boss, the Chief Medical Officer

/datum/gear/coat/paramedic
	name = "Paramedic winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/paramedic
	restricted_roles = list("Chief Medical Officer", "Paramedic") // Reserve it to Paramedics and their boss, the Chief Medical Officer

/datum/gear/coat/robotics
	name = "Robotics winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/robotics
	restricted_roles = list("Research Director", "Roboticist")

/datum/gear/coat/sci
	name = "Science winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/science
	restricted_roles = list("Research Director", "Scientist", "Roboticist") // Reserve it to the Science Departement

/datum/gear/coat/eng
	name = "Engineering winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering
	restricted_roles = list("Senior Engineer", "Station Engineer") // Reserve it to Station Engineers and their boss, the Senior Engineer

/datum/gear/coat/eng/atmos
	name = "Atmospherics winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	restricted_roles = list("Senior Engineer", "Atmospheric Technician") // Reserve it to Atmos Techs and their boss, the Senior Engineer

/datum/gear/coat/hydro
	name = "Hydroponics winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/hydro
	restricted_roles = list("Head of Personnel", "Botanist") // Reserve it to Botanists and their boss, the Head of Personnel

/datum/gear/coat/cargo
	name = "Cargo winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/cargo
	restricted_roles = list("Logistics Officer", "Cargo Technician") // Reserve it to Cargo Techs and their boss, the Quartermaster

/datum/gear/coat/miner
	name = "Mining winter coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/miner
	restricted_roles = list("Logistics Officer", "Shaft Miner") // Reserve it to Miners and their boss, the Quartermaster

/datum/gear/militaryjacket
	name = "Military Jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/jacket/miljacket

/datum/gear/ianshirt
	name = "Ian Shirt"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/ianshirt

/datum/gear/flakjack
	name = "Flak Jacket"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/flakjack
	cost = 2

/datum/gear/trekds9_coat
	name = "DS9 Overcoat (use uniform)"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/trek/ds9
	restricted_desc = "All, barring Service and Civilian"
	restricted_roles = list("Chief Enforcer","Captain","Head of Personnel","Senior Engineer","Research Director","Chief Medical Officer","Logistics Officer",
							"Medical Doctor","Chemist","Virologist","Paramedic","Geneticist","Scientist", "Roboticist",
							"Atmospheric Technician","Station Engineer","Lieutenant","Detective","Enforcer",
							"Cargo Technician", "Shaft Miner") //everyone who actually deserves a job.
//Federation jackets from movies
/datum/gear/trekcmdcap
	name = "Fed (movie) uniform, Black"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/fedcoat/capt
	restricted_roles = list("Captain","Head of Personnel")

/datum/gear/trekcmdmov
	name = "Fed (movie) uniform, Red"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/fedcoat
	restricted_desc = "Heads of Staff and Security"
	restricted_roles = list("Chief Enforcer","Captain","Head of Personnel","Senior Engineer","Research Director","Chief Medical Officer","Logistics Officer","Lieutenant","Detective","Enforcer")

/datum/gear/trekmedscimov
	name = "Fed (movie) uniform, Blue"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/fedcoat/medsci
	restricted_desc = "Medical and Science"
	restricted_roles = list("Chief Medical Officer","Medical Doctor","Chemist","Virologist","Paramedic","Geneticist","Research Director","Scientist", "Roboticist")

/datum/gear/trekengmov
	name = "Fed (movie) uniform, Yellow"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/fedcoat/eng
	restricted_desc = "Engineering and Cargo"
	restricted_roles = list("Senior Engineer","Atmospheric Technician","Station Engineer","Cargo Technician", "Shaft Miner", "Logistics Officer")

/datum/gear/trekcmdcapmod
	name = "Fed (Modern) uniform, White"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/modernfedcoat
	restricted_roles = list("Captain","Head of Personnel")

/datum/gear/trekcmdmod
	name = "Fed (Modern) uniform, Red"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/modernfedcoat/sec
	restricted_desc = "Heads of Staff and Security"
	restricted_roles = list("Chief Enforcer","Captain","Head of Personnel","Senior Engineer","Research Director","Chief Medical Officer","Logistics Officer","Lieutenant","Detective","Enforcer")

/datum/gear/trekmedscimod
	name = "Fed (Modern) uniform, Blue"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/modernfedcoat/medsci
	restricted_desc = "Medical and Science"
	restricted_roles = list("Chief Medical Officer","Medical Doctor","Chemist","Virologist","Paramedic","Geneticist","Research Director","Scientist", "Roboticist")

/datum/gear/trekengmod
	name = "Fed (Modern) uniform, Yellow"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/storage/fluff/modernfedcoat/eng
	restricted_desc = "Engineering and Cargo"
	restricted_roles = list("Senior Engineer","Atmospheric Technician","Station Engineer","Cargo Technician", "Shaft Miner", "Logistics Officer")

/datum/gear/christmascoatr
	name = "Red Christmas Coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/christmascoatr

/datum/gear/christmascoatg
	name = "Green Christmas Coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/christmascoatg

/datum/gear/christmascoatrg
	name = "Red and Green Christmas Coat"
	category = SLOT_WEAR_SUIT
	path = /obj/item/clothing/suit/hooded/wintercoat/christmascoatrg

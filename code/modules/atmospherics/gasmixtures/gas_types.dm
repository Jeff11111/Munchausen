GLOBAL_LIST_INIT(hardcoded_gases, list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/plasma)) //the main four gases, which were at one time hardcoded
GLOBAL_LIST_INIT(nonreactive_gases, typecacheof(list(/datum/gas/oxygen, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, /datum/gas/pluoxium, /datum/gas/stimulum, /datum/gas/nitryl))) //unable to react amongst themselves

/proc/gas_id2path(id)
	var/list/meta_gas = GLOB.meta_gas_ids
	if(id in meta_gas)
		return id
	for(var/path in meta_gas)
		if(meta_gas[path] == id)
			return path
	return ""

//Unomos - oh god oh fuck oh shit oh lord have mercy this is messy as fuck oh god
//my addiction to seeing better performance numbers isn't healthy, kids
//you see this shit, children?
//i am not a good idol. don't take after me.
//this is literally worse than my alcohol addiction
/proc/meta_gas_heat_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[gas_path] = initial(gas.specific_heat)

/proc/meta_gas_name_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[gas_path] = initial(gas.name)

/proc/meta_gas_visibility_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[gas_path] = initial(gas.moles_visible)

/proc/meta_gas_overlay_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[gas_path] = 0 //gotta make sure if(GLOB.meta_gas_overlays[gaspath]) doesn't break
		if(initial(gas.moles_visible) != null)
			.[gas_path] = new /list(FACTOR_GAS_VISIBLE_MAX)
			for(var/i in 1 to FACTOR_GAS_VISIBLE_MAX)
				.[gas_path][i] = new /obj/effect/overlay/gas(initial(gas.gas_overlay), i * 255 / FACTOR_GAS_VISIBLE_MAX)

/proc/meta_gas_danger_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[gas_path] = initial(gas.dangerous)

/proc/meta_gas_id_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[gas_path] = initial(gas.id)

/proc/meta_gas_fusion_list()
	. = subtypesof(/datum/gas)
	for(var/gas_path in .)
		var/datum/gas/gas = gas_path
		.[gas_path] = initial(gas.fusion_power)

/*||||||||||||||/----------\||||||||||||||*\
||||||||||||||||[GAS DATUMS]||||||||||||||||
||||||||||||||||\__________/||||||||||||||||
||||These should never be instantiated. ||||
||||They exist only to make it easier   ||||
||||to add a new gas. They are accessed ||||
||||only by meta_gas_list().            ||||
\*||||||||||||||||||||||||||||||||||||||||*/

/datum/gas
	var/id = ""
	var/specific_heat = 0
	var/name = ""
	var/gas_overlay = "" //icon_state in icons/effects/atmospherics.dmi
	var/moles_visible = null
	var/dangerous = FALSE //currently used by canisters
	var/fusion_power = 0 //How much the gas accelerates a fusion reaction
	var/rarity = 0 // relative rarity compared to other gases, used when setting up the reactions list.

/datum/gas/oxygen
	id = "o2"
	specific_heat = 20
	name = "Oxygen"
	rarity = 900

/datum/gas/nitrogen
	id = "n2"
	specific_heat = 20
	name = "Nitrogen"
	rarity = 1000

/datum/gas/carbon_dioxide //what the fuck is this?
	id = "co2"
	specific_heat = 30
	name = "Carbon Dioxide"
	fusion_power = 3
	rarity = 700

/datum/gas/plasma
	id = "plasma"
	specific_heat = 200
	name = "Plasma"
	gas_overlay = "plasma"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 800

/datum/gas/water_vapor
	id = "water_vapor"
	specific_heat = 40
	name = "Water Vapor"
	gas_overlay = "water_vapor"
	moles_visible = MOLES_GAS_VISIBLE
	fusion_power = 8
	rarity = 500

/datum/gas/hypernoblium
	id = "nob"
	specific_heat = 2000
	name = "Hyper-noblium"
	gas_overlay = "freon"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	rarity = 50

/datum/gas/nitrous_oxide
	id = "n2o"
	specific_heat = 40
	name = "Nitrous Oxide"
	gas_overlay = "nitrous_oxide"
	moles_visible = MOLES_GAS_VISIBLE * 2
	dangerous = TRUE
	rarity = 600

/datum/gas/nitryl
	id = "no2"
	specific_heat = 20
	name = "Nitryl"
	gas_overlay = "nitryl"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 15
	rarity = 100

/datum/gas/tritium
	id = "tritium"
	specific_heat = 10
	name = "Tritium"
	gas_overlay = "tritium"
	moles_visible = MOLES_GAS_VISIBLE
	dangerous = TRUE
	fusion_power = 1
	rarity = 300

/datum/gas/bz
	id = "bz"
	specific_heat = 20
	name = "BZ"
	dangerous = TRUE
	fusion_power = 8
	rarity = 400

/datum/gas/stimulum
	id = "stim"
	specific_heat = 5
	name = "Stimulum"
	fusion_power = 7
	rarity = 1

/datum/gas/pluoxium
	id = "pluox"
	specific_heat = 80
	name = "Pluoxium"
	fusion_power = 10
	rarity = 200

/obj/effect/overlay/gas
	icon = 'icons/effects/atmospherics.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE  // should only appear in vis_contents, but to be safe
	layer = FLY_LAYER
	appearance_flags = TILE_BOUND
	vis_flags = NONE

/obj/effect/overlay/gas/New(state, alph)
	. = ..()
	icon_state = state
	alpha = alph

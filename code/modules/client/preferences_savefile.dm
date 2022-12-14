//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	18

//This is the current version, anything below this will attempt to update (if it's not obsolete)
//	You do not need to raise this if you are adding new values that have sane defaults.
//	Only raise this value when changing the meaning/format/name/layout of an existing value
//	where you would want the updater procs below to run
#define SAVEFILE_VERSION_MAX	35

/*
SAVEFILE UPDATING/VERSIONING - 'Simplified', or rather, more coder-friendly ~Carn
	This proc checks if the current directory of the savefile S needs updating
	It is to be used by the load_character and load_preferences procs.
	(S.cd=="/" is preferences, S.cd=="/character[integer]" is a character slot, etc)

	if the current directory's version is below SAVEFILE_VERSION_MIN it will simply wipe everything in that directory
	(if we're at root "/" then it'll just wipe the entire savefile, for instance.)

	if its version is below SAVEFILE_VERSION_MAX but above the minimum, it will load data but later call the
	respective update_preferences() or update_character() proc.
	Those procs allow coders to specify format changes so users do not lose their setups and have to redo them again.

	Failing all that, the standard sanity checks are performed. They simply check the data is suitable, reverting to
	initial() values if necessary.
*/
/datum/preferences/proc/savefile_needs_update(savefile/S)
	var/savefile_version
	S["version"] >> savefile_version

	if(savefile_version < SAVEFILE_VERSION_MIN)
		S.dir.Cut()
		return -2
	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version
	return -1

//should these procs get fairly long
//just increase SAVEFILE_VERSION_MIN so it's not as far behind
//SAVEFILE_VERSION_MAX and then delete any obsolete if clauses
//from these procs.
//This only really meant to avoid annoying frequent players
//if your savefile is 3 months out of date, then 'tough shit'.

/datum/preferences/proc/update_preferences(current_version, savefile/S)
	if(current_version < 32)	//If you remove this, remove force_reset_keybindings() too.
		addtimer(CALLBACK(src, .proc/force_reset_keybindings), 30)	//No mob available when this is run, timer allows user choice.

/datum/preferences/proc/update_character(current_version, savefile/S)
	if(current_version < 19)
		pda_style = "mono"
	if(current_version < 20)
		pda_color = sanitize_hexcolor("#808000")
	if((current_version < 21) && features["meat_type"] && (features["meat_type"] == null))
		features["meat_type"] = "Mammalian"
	if(current_version < 22)

		job_preferences = list() //It loaded null from nonexistant savefile field.

		var/job_civilian_high = 0
		var/job_civilian_med = 0
		var/job_civilian_low = 0

		var/job_medsci_high = 0
		var/job_medsci_med = 0
		var/job_medsci_low = 0

		var/job_engsec_high = 0
		var/job_engsec_med = 0
		var/job_engsec_low = 0

		S["job_civilian_high"]	>> job_civilian_high
		S["job_civilian_med"]	>> job_civilian_med
		S["job_civilian_low"]	>> job_civilian_low
		S["job_medsci_high"]	>> job_medsci_high
		S["job_medsci_med"]		>> job_medsci_med
		S["job_medsci_low"]		>> job_medsci_low
		S["job_engsec_high"]	>> job_engsec_high
		S["job_engsec_med"]		>> job_engsec_med
		S["job_engsec_low"]		>> job_engsec_low

		//Can't use SSjob here since this happens right away on login
		for(var/job in subtypesof(/datum/job))
			var/datum/job/J = job
			var/new_value
			var/fval = initial(J.flag)
			switch(initial(J.department_flag))
				if(CIVILIAN)
					if(job_civilian_high & fval)
						new_value = JP_HIGH
					else if(job_civilian_med & fval)
						new_value = JP_MEDIUM
					else if(job_civilian_low & fval)
						new_value = JP_LOW
				if(MEDSCI)
					if(job_medsci_high & fval)
						new_value = JP_HIGH
					else if(job_medsci_med & fval)
						new_value = JP_MEDIUM
					else if(job_medsci_low & fval)
						new_value = JP_LOW
				if(ENGSEC)
					if(job_engsec_high & fval)
						new_value = JP_HIGH
					else if(job_engsec_med & fval)
						new_value = JP_MEDIUM
					else if(job_engsec_low & fval)
						new_value = JP_LOW
			if(new_value)
				job_preferences["[initial(J.title)]"] = new_value
	else if(current_version < 23) // we are fixing a gamebreaking bug.
		job_preferences = list() //It loaded null from nonexistant savefile field.

	if(current_version < 25)
		var/digi
		S["feature_lizard_legs"] >> digi
		if(digi == "Digitigrade Legs")
			WRITE_FILE(S["feature_lizard_legs"], "Digitigrade")
		if(features["meat_type"] == "Inesct")
			features["meat_type"] = "Insect"

	if(current_version < 28)
		var/hockey
		S["feature_cock_shape"] >> hockey
		var/list/malformed_hockeys = list("Taur, Flared" = "Flared", "Taur, Knotted" = "Knotted", "Taur, Tapered" = "Tapered")
		if(malformed_hockeys[hockey])
			features["cock_shape"] = malformed_hockeys[hockey]
			features["cock_taur"] = TRUE

	if(current_version < 31)
		S["wing_color"]			>> features["wings_color"]
		S["horn_color"]			>> features["horns_color"]

	if(current_version < 33)
		features["general_records"]			= strip_html_simple(features["general_records"], MAX_FLAVOR_LEN, TRUE)
		features["security_records"]			= strip_html_simple(features["security_records"], MAX_FLAVOR_LEN, TRUE)
		features["medical_records"]			= strip_html_simple(features["medical_records"], MAX_FLAVOR_LEN, TRUE)
		features["flavor_background"]			= strip_html_simple(features["flavor_background"], MAX_FLAVOR_LEN, TRUE)
		features["character_skills"]			= strip_html_simple(features["character_skills"], MAX_FLAVOR_LEN, TRUE)
		features["exploitable_info"]			= strip_html_simple(features["exploitable_info"], MAX_FLAVOR_LEN, TRUE)

	if(current_version < 34)
		//No more digi nor taurs fuck you
		features["taur"] = "None"
		features["legs"] = "Plantigrade"

		//Updates cock size and diameter do cm
		features["cock_length"] = round(features["cock_length"] * 2.54, 0.1)
		features["cock_diameter_ratio"] = round(features["cock_diameter_ratio"] * 2.54, 0.1)
	
	if(current_version < 35)
		features["left_eye_color"] = features["eye_color"]
		features["right_eye_color"] = features["eye_color"]

/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)
		return
	path = "data/player_saves/[ckey[1]]/[ckey]/[filename]"

/datum/preferences/proc/load_preferences()
	if(!path)
		return 0
	if(world.time < loadprefcooldown)
		if(istype(parent))
			to_chat(parent, "<span class='warning'>You're attempting to load your preferences a little too fast. Wait half a second, then try again.</span>")
		return 0
	loadprefcooldown = world.time + PREF_SAVELOAD_COOLDOWN
	if(!fexists(path))
		return 0

	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	. = TRUE

	//general preferences
	S["ooccolor"]			>> ooccolor
	S["lastchangelog"]		>> lastchangelog
	S["hotkeys"]			>> hotkeys
	S["chat_on_map"]		>> chat_on_map
	S["max_chat_length"]	>> max_chat_length
	S["see_chat_non_mob"] 	>> see_chat_non_mob
	S["tgui_fancy"]			>> tgui_fancy
	S["tgui_lock"]			>> tgui_lock
	S["buttons_locked"]		>> buttons_locked
	S["windowflash"]		>> windowflashing
	S["be_special"] 		>> be_special
	S["see_chat_emotes"] 	>> see_chat_emotes
	S["event_participation"] >> event_participation
	S["event_prefs"] >> event_prefs
	S["appear_in_round_end_report"]	>> appear_in_round_end_report


	S["default_slot"]		>> default_slot
	S["chat_toggles"]		>> chat_toggles
	S["toggles"]			>> toggles
	S["ghost_form"]			>> ghost_form
	S["ghost_orbit"]		>> ghost_orbit
	S["ghost_accs"]			>> ghost_accs
	S["ghost_others"]		>> ghost_others
	S["preferred_map"]		>> preferred_map
	S["ignoring"]			>> ignoring
	S["ghost_hud"]			>> ghost_hud
	S["inquisitive_ghost"]	>> inquisitive_ghost
	S["uses_glasses_colour"]>> uses_glasses_colour
	S["clientfps"]			>> clientfps
	S["parallax"]			>> parallax
	S["ambientocclusion"]	>> ambientocclusion
	S["auto_fit_viewport"]	>> auto_fit_viewport
	S["hud_toggle_flash"]	>> hud_toggle_flash
	S["hud_toggle_color"]	>> hud_toggle_color
	S["menuoptions"]		>> menuoptions
	S["enable_tips"]		>> enable_tips
	S["tip_delay"]			>> tip_delay
	S["pda_style"]			>> pda_style
	S["pda_color"]			>> pda_color
	S["show_credits"] 		>> show_credits
	S["bobux_amount"]		>> bobux_amount

	// Custom hotkeys
	S["key_bindings"]		>> key_bindings
	S["modless_key_bindings"]		>> modless_key_bindings

	//citadel code
	S["arousable"]			>> arousable
	S["widescreenpref"]		>> widescreenpref
	S["fullscreenpref"]		>> fullscreenpref
	S["autostand"]			>> autostand
	S["preferred_chaos"]	>> preferred_chaos
	S["auto_ooc"]			>> auto_ooc
	S["no_tetris_storage"]		>> no_tetris_storage

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)

	//Sanitize
	ooccolor		= sanitize_ooccolor(sanitize_hexcolor(ooccolor, 6, TRUE, initial(ooccolor)))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	hotkeys			= sanitize_integer(hotkeys, 0, 1, initial(hotkeys))
	chat_on_map		= sanitize_integer(chat_on_map, 0, 1, initial(chat_on_map))
	max_chat_length = sanitize_integer(max_chat_length, 1, CHAT_MESSAGE_MAX_LENGTH, initial(max_chat_length))
	see_chat_non_mob	= sanitize_integer(see_chat_non_mob, 0, 1, initial(see_chat_non_mob))
	tgui_fancy		= sanitize_integer(tgui_fancy, 0, 1, initial(tgui_fancy))
	tgui_lock		= sanitize_integer(tgui_lock, 0, 1, initial(tgui_lock))
	buttons_locked	= sanitize_integer(buttons_locked, 0, 1, initial(buttons_locked))
	windowflashing		= sanitize_integer(windowflashing, 0, 1, initial(windowflashing))
	default_slot	= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 16777215, initial(toggles))
	clientfps		= sanitize_integer(clientfps, 0, 1000, 0)
	if (clientfps == 0) clientfps = world.fps*2
	parallax		= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, null)
	ambientocclusion	= sanitize_integer(ambientocclusion, 0, TRUE, initial(ambientocclusion))
	auto_fit_viewport	= sanitize_integer(auto_fit_viewport, 0, TRUE, initial(auto_fit_viewport))
	hud_toggle_flash = sanitize_integer(hud_toggle_flash, 0, TRUE, initial(hud_toggle_flash))
	hud_toggle_color = sanitize_hexcolor(hud_toggle_color, 6, TRUE, initial(hud_toggle_color))
	ghost_form		= sanitize_inlist(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_orbit 	= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_accs		= sanitize_inlist(ghost_accs, GLOB.ghost_accs_options, GHOST_ACCS_DEFAULT_OPTION)
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, GHOST_OTHERS_DEFAULT_OPTION)
	menuoptions		= SANITIZE_LIST(menuoptions)
	be_special		= SANITIZE_LIST(be_special)
	pda_style		= sanitize_inlist(pda_style, GLOB.pda_styles, initial(pda_style))
	pda_color		= sanitize_hexcolor(pda_color, 6, TRUE, initial(pda_color))

	show_credits		= sanitize_integer(show_credits, 0, 1, initial(show_credits))
	widescreenpref		= sanitize_integer(widescreenpref, 0, 1, initial(widescreenpref))
	fullscreenpref		= sanitize_integer(fullscreenpref, 0, 1, initial(fullscreenpref))
	autostand			= sanitize_integer(autostand, 0, 1, initial(autostand))
	auto_ooc			= sanitize_integer(auto_ooc, 0, 1, initial(auto_ooc))
	no_tetris_storage		= sanitize_integer(no_tetris_storage, 0, 1, initial(no_tetris_storage))
	key_bindings 			= sanitize_islist(key_bindings, list())
	modless_key_bindings 	= sanitize_islist(modless_key_bindings, list())

	see_chat_emotes	= sanitize_integer(see_chat_emotes, 0, 1, initial(see_chat_emotes))
	event_participation = sanitize_integer(event_participation, 0, 1, initial(event_participation))
	event_prefs = sanitize_text(event_prefs)
	appear_in_round_end_report	= sanitize_integer(appear_in_round_end_report, 0, 1, initial(appear_in_round_end_report))

	verify_keybindings_valid()		// one of these days this will runtime and you'll be glad that i put it in a different proc so no one gets their saves wiped

	return 1

/datum/preferences/proc/verify_keybindings_valid()
	// Sanitize the actual keybinds to make sure they exist.
	for(var/key in key_bindings)
		if(!islist(key_bindings[key]))
			key_bindings -= key
		var/list/binds = key_bindings[key]
		for(var/bind in binds)
			if(!GLOB.keybindings_by_name[bind])
				binds -= bind
		if(!length(binds))
			key_bindings -= key
	// End
	// I hate copypaste but let's do it again but for modless ones
	for(var/key in modless_key_bindings)
		var/bindname = modless_key_bindings[key]
		if(!GLOB.keybindings_by_name[bindname])
			modless_key_bindings -= key

/datum/preferences/proc/save_preferences()
	if(!path)
		return 0
	if(world.time < saveprefcooldown)
		if(istype(parent))
			to_chat(parent, "<span class='warning'>You're attempting to save your preferences a little too fast. Wait half a second, then try again.</span>")
		return 0
	saveprefcooldown = world.time + PREF_SAVELOAD_COOLDOWN
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	WRITE_FILE(S["version"], SAVEFILE_VERSION_MAX)		//updates (or failing that the sanity checks) will ensure data is not invalid at load. Assume up-to-date

	//general preferences
	WRITE_FILE(S["ooccolor"], ooccolor)
	WRITE_FILE(S["lastchangelog"], lastchangelog)
	WRITE_FILE(S["hotkeys"], hotkeys)
	WRITE_FILE(S["chat_on_map"], chat_on_map)
	WRITE_FILE(S["max_chat_length"], max_chat_length)
	WRITE_FILE(S["see_chat_non_mob"], see_chat_non_mob)
	WRITE_FILE(S["tgui_fancy"], tgui_fancy)
	WRITE_FILE(S["tgui_lock"], tgui_lock)
	WRITE_FILE(S["buttons_locked"], buttons_locked)
	WRITE_FILE(S["windowflash"], windowflashing)
	WRITE_FILE(S["be_special"], be_special)
	WRITE_FILE(S["default_slot"], default_slot)
	WRITE_FILE(S["toggles"], toggles)
	WRITE_FILE(S["chat_toggles"], chat_toggles)
	WRITE_FILE(S["ghost_form"], ghost_form)
	WRITE_FILE(S["ghost_orbit"], ghost_orbit)
	WRITE_FILE(S["ghost_accs"], ghost_accs)
	WRITE_FILE(S["ghost_others"], ghost_others)
	WRITE_FILE(S["preferred_map"], preferred_map)
	WRITE_FILE(S["ignoring"], ignoring)
	WRITE_FILE(S["ghost_hud"], ghost_hud)
	WRITE_FILE(S["inquisitive_ghost"], inquisitive_ghost)
	WRITE_FILE(S["uses_glasses_colour"], uses_glasses_colour)
	WRITE_FILE(S["clientfps"], clientfps)
	WRITE_FILE(S["parallax"], parallax)
	WRITE_FILE(S["ambientocclusion"], ambientocclusion)
	WRITE_FILE(S["auto_fit_viewport"], auto_fit_viewport)
	WRITE_FILE(S["hud_toggle_flash"], hud_toggle_flash)
	WRITE_FILE(S["hud_toggle_color"], hud_toggle_color)
	WRITE_FILE(S["menuoptions"], menuoptions)
	WRITE_FILE(S["enable_tips"], enable_tips)
	WRITE_FILE(S["tip_delay"], tip_delay)
	WRITE_FILE(S["pda_style"], pda_style)
	WRITE_FILE(S["pda_color"], pda_color)
	WRITE_FILE(S["show_credits"], show_credits)
	WRITE_FILE(S["key_bindings"], key_bindings)
	WRITE_FILE(S["modless_key_bindings"], modless_key_bindings)
	WRITE_FILE(S["arousable"], arousable)
	WRITE_FILE(S["widescreenpref"], widescreenpref)
	WRITE_FILE(S["fullscreenpref"], fullscreenpref)
	WRITE_FILE(S["autostand"], autostand)
	WRITE_FILE(S["preferred_chaos"], preferred_chaos)
	WRITE_FILE(S["auto_ooc"], auto_ooc)
	WRITE_FILE(S["no_tetris_storage"], no_tetris_storage)
	WRITE_FILE(S["see_chat_emotes"], see_chat_emotes)
	WRITE_FILE(S["event_participation"], event_participation)
	WRITE_FILE(S["event_prefs"], event_prefs)
	WRITE_FILE(S["appear_in_round_end_report"], appear_in_round_end_report)
	WRITE_FILE(S["bobux_amount"], bobux_amount)

	return 1

/datum/preferences/proc/load_character(slot)
	if(!path)
		return 0
	if(world.time < loadcharcooldown) //This is before the check to see if the filepath exists to ensure that BYOND can't get hung up on read attempts when the hard drive is a little slow
		if(istype(parent))
			to_chat(parent, "<span class='warning'>You're attempting to load your character a little too fast. Wait half a second, then try again.</span>")
		return "SLOW THE FUCK DOWN" //the reason this isn't null is to make sure that people don't have their character slots overridden by random chars if they accidentally double-click a slot
	loadcharcooldown = world.time + PREF_SAVELOAD_COOLDOWN
	if(!fexists(path))
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		WRITE_FILE(S["default_slot"] , slot)

	S.cd = "/character[slot]"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	. = TRUE

	//Species
	var/species_id
	S["species"]			>> species_id
	if(species_id)
		var/newtype = GLOB.species_list[species_id]
		if(newtype)
			pref_species = new newtype

	//Character
	S["real_name"]				>> real_name
	//S["nameless"]				>> nameless
	S["auto_hiss"]				>> auto_hiss
	S["custom_species"]			>> custom_species
	S["name_is_always_random"]	>> be_random_name
	S["body_is_always_random"]	>> be_random_body
	S["gender"]					>> gender
	S["body_model"]				>> features["body_model"]
	S["body_size"]				>> features["body_size"]
	S["age"]					>> age
	S["hair_color"]				>> hair_color
	S["facial_hair_color"]		>> facial_hair_color
	S["left_eye_color"]			>> left_eye_color
	S["right_eye_color"]		>> right_eye_color
	S["use_custom_skin_tone"]	>> use_custom_skin_tone
	S["skin_tone"]				>> skin_tone
	S["hair_style_name"]		>> hair_style
	S["facial_style_name"]		>> facial_hair_style
	S["backbag"]				>> backbag
	S["feature_mcolor"]					>> features["mcolor"]
	S["feature_lizard_tail"]			>> features["tail_lizard"]
	S["feature_lizard_snout"]			>> features["snout"]
	S["feature_lizard_horns"]			>> features["horns"]
	S["feature_lizard_frills"]			>> features["frills"]
	S["feature_lizard_spines"]			>> features["spines"]
	S["feature_lizard_body_markings"]	>> features["body_markings"]
	S["feature_lizard_legs"]			>> features["legs"]
	S["feature_human_tail"]				>> features["tail_human"]
	S["feature_human_ears"]				>> features["ears"]
	S["feature_deco_wings"]				>> features["deco_wings"]
	S["feature_insect_wings"]			>> features["insect_wings"]
	S["feature_insect_fluff"]			>> features["insect_fluff"]
	S["feature_insect_markings"]		>> features["insect_markings"]
	S["feature_horns_color"]			>> features["horns_color"]
	S["feature_wings_color"]			>> features["wings_color"]
	S["bloodtype"]						>> bloodtype
	S["bloodreagent"]					>> bloodreagent
	S["bloodcolor"]						>> bloodcolor
	S["color_gear"]			>> color_gear
	S["bloodreagent"]		>> bloodreagent
	S["bloodtype"]			>> bloodtype
	S["bloodcolor"]			>> bloodcolor

	//Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		S[savefile_slot_name] >> custom_names[custom_name_id]

	S["prefered_security_department"]	>> prefered_security_department

	//Jobs
	S["joblessrole"]		>> joblessrole
	//Load prefs
	S["job_preferences"]	>> job_preferences
	job_preferences	= SANITIZE_LIST(job_preferences)

	//Quirks
	S["special_char"]			>> special_char

	S["language"]			>> language
	S["body_descriptors"]	>> body_descriptors
	body_descriptors = SANITIZE_LIST(body_descriptors)
	if(length(body_descriptors) < length(initial(pref_species.descriptors))) //if we have a null descriptor list, we just force load it from the species
		for(var/i in pref_species.descriptors) //of course some species might not have descriptors and this is uneccessary for them but
			var/datum/mob_descriptor/md = pref_species.descriptors[i] //the hardest coding requires the strongest wills
			body_descriptors[i] = md.current_value

	//Citadel code
	S["feature_genitals_use_skintone"]	>> features["genitals_use_skintone"]
	S["feature_exhibitionist"]			>> features["exhibitionist"]
	S["feature_mcolor2"]				>> features["mcolor2"]
	S["feature_mcolor3"]				>> features["mcolor3"]
	S["feature_mam_body_markings"]		>> features["mam_body_markings"]
	S["feature_mam_tail"]				>> features["mam_tail"]
	S["feature_mam_ears"]				>> features["mam_ears"]
	S["feature_mam_tail_animated"]		>> features["mam_tail_animated"]
	S["feature_taur"]					>> features["taur"]
	S["feature_mam_snouts"]				>> features["mam_snouts"]
	S["feature_meat"]					>> features["meat_type"]
	//Xeno features
	S["feature_xeno_tail"]				>> features["xenotail"]
	S["feature_xeno_dors"]				>> features["xenodorsal"]
	S["feature_xeno_head"]				>> features["xenohead"]
	//cock features
	S["feature_has_cock"]				>> features["has_cock"]
	S["feature_cyber_cock"]				>> features["cyber_cock"]
	S["feature_cock_shape"]				>> features["cock_shape"]
	S["feature_cock_color"]				>> features["cock_color"]
	S["feature_cock_length"]			>> features["cock_length"]
	S["feature_cock_diameter"]			>> features["cock_diameter"]
	//balls features
	S["feature_has_balls"]				>> features["has_balls"]
	S["feature_cyber_balls"]			>> features["cyber_balls"]
	S["feature_balls_color"]			>> features["balls_color"]
	S["feature_balls_size"]				>> features["balls_size"]
	//breasts features
	S["feature_has_breasts"]			>> features["has_breasts"]
	S["feature_cyber_breasts"]			>> features["cyber_breasts"]
	S["feature_breasts_size"]			>> features["breasts_size"]
	S["feature_breasts_shape"]			>> features["breasts_shape"]
	S["feature_breasts_color"]			>> features["breasts_color"]
	S["feature_breasts_producing"]		>> features["breasts_producing"]
	//vagina features
	S["feature_has_vag"]				>> features["has_vag"]
	S["feature_cyber_vag"]				>> features["cyber_vag"]
	S["feature_vag_shape"]				>> features["vag_shape"]
	S["feature_vag_color"]				>> features["vag_color"]
	//womb features
	S["feature_has_womb"]				>> features["has_womb"]
	S["feature_cyber_womb"]				>> features["cyber_womb"]
	//ipc features
	S["feature_ipc_chassis"]			>> features["ipc_chassis"]

	//gear loadout
	var/text_to_load
	S["loadout"] >> text_to_load
	var/list/saved_loadout_paths = splittext(text_to_load, "|")
	chosen_gear = list()
	gear_points = CONFIG_GET(number/initial_gear_points)
	for(var/i in saved_loadout_paths)
		var/datum/gear/path = text2path(i)
		if(path)
			var/init_cost = initial(path.cost)
			if(init_cost > gear_points)
				continue
			chosen_gear += path
			gear_points -= init_cost

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_character(needs_update, S)		//needs_update == savefile_version if we need an update (positive integer)

	//Sanitize

	real_name	= reject_bad_name(real_name)
	gender		= sanitize_gender(gender, TRUE, TRUE)
	features["body_model"] = sanitize_gender(features["body_model"], FALSE, FALSE, gender == MALE ? MALE : FEMALE)
	if(!real_name)
		real_name	= random_unique_name(gender)
	custom_species	= reject_bad_name(custom_species)
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/namedata = GLOB.preferences_custom_names[custom_name_id]
		custom_names[custom_name_id] = reject_bad_name(custom_names[custom_name_id],namedata["allow_numbers"])
		if(!custom_names[custom_name_id])
			custom_names[custom_name_id] = get_default_name(custom_name_id)

	auto_hiss		= sanitize_integer(auto_hiss, 0, 1, initial(auto_hiss))

	nameless		= sanitize_integer(nameless, 0, 1, initial(nameless))
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body	= sanitize_integer(be_random_body, 0, 1, initial(be_random_body))

	hair_style					= sanitize_inlist(hair_style, GLOB.hair_styles_list)
	facial_hair_style			= sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_list)
	age								= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	hair_color						= sanitize_hexcolor(hair_color, 6, TRUE)
	facial_hair_color				= sanitize_hexcolor(facial_hair_color, 6, TRUE)
	left_eye_color					= sanitize_hexcolor(left_eye_color, 6, TRUE)
	right_eye_color					= sanitize_hexcolor(right_eye_color, 6, TRUE)

	var/static/allow_custom_skintones
	if(isnull(allow_custom_skintones))
		allow_custom_skintones = CONFIG_GET(flag/allow_custom_skintones)
	use_custom_skin_tone			= allow_custom_skintones ? sanitize_integer(use_custom_skin_tone, FALSE, TRUE, initial(use_custom_skin_tone)) : FALSE
	if(use_custom_skin_tone)
		skin_tone					= sanitize_hexcolor(skin_tone, 6, TRUE, "#FFFFFF")
	else
		skin_tone					= sanitize_inlist(skin_tone, GLOB.skin_tones - GLOB.nonstandard_skin_tones, initial(skin_tone))

	features["horns_color"]			= sanitize_hexcolor(features["horns_color"], 6, TRUE, "85615a")
	features["wings_color"]			= sanitize_hexcolor(features["wings_color"], 6, TRUE, "FFFFFF")
	backbag							= sanitize_inlist(backbag, GLOB.backbaglist, initial(backbag))
	features["mcolor"]				= sanitize_hexcolor(features["mcolor"], 6, TRUE)
	features["tail_lizard"]			= sanitize_inlist(features["tail_lizard"], GLOB.tails_list_lizard)
	features["tail_human"]			= sanitize_inlist(features["tail_human"], GLOB.tails_list_human)
	features["snout"]				= sanitize_inlist(features["snout"], GLOB.snouts_list)
	features["horns"]				= sanitize_inlist(features["horns"], GLOB.horns_list)
	features["ears"]				= sanitize_inlist(features["ears"], GLOB.ears_list)
	features["frills"]				= sanitize_inlist(features["frills"], GLOB.frills_list)
	features["spines"]				= sanitize_inlist(features["spines"], GLOB.spines_list)
	features["body_markings"]		= sanitize_inlist(features["body_markings"], GLOB.body_markings_list)
	features["legs"]				= sanitize_inlist(features["legs"], GLOB.legs_list, "Plantigrade")
	features["deco_wings"] 			= sanitize_inlist(features["deco_wings"], GLOB.deco_wings_list, "None")
	features["insect_fluff"]		= sanitize_inlist(features["insect_fluff"], GLOB.insect_fluffs_list)
	features["insect_markings"] 	= sanitize_inlist(features["insect_markings"], GLOB.insect_markings_list, "None")
	features["insect_wings"] 		= sanitize_inlist(features["insect_wings"], GLOB.insect_wings_list)

	var/static/size_min
	if(!size_min)
		size_min = CONFIG_GET(number/body_size_min)
	var/static/size_max
	if(!size_max)
		size_max = CONFIG_GET(number/body_size_max)
	features["body_size"]			= sanitize_num_clamp(features["body_size"], size_min, size_max, RESIZE_DEFAULT_SIZE, 0.01)

	var/static/list/B_sizes
	if(!B_sizes)
		var/list/L = CONFIG_GET(keyed_list/breasts_cups_prefs)
		B_sizes = L.Copy()
	var/static/min_D
	if(!min_D)
		min_D = CONFIG_GET(number/penis_min_centimeters_prefs)
	var/static/max_D
	if(!max_D)
		max_D = CONFIG_GET(number/penis_max_centimeters_prefs)
	
	features["breasts_size"]		= sanitize_inlist(features["breasts_size"], B_sizes, BREASTS_SIZE_DEF)
	features["cock_length"]			= sanitize_integer(features["cock_length"], min_D, max_D, COCK_SIZE_DEF)
	var/list/fuck = GLOB.breasts_shapes_list.Copy()
	if(length(pref_species.bobs_type))
		fuck = pref_species.bobs_type.Copy()
	features["breasts_shape"]		= sanitize_inlist(features["breasts_shape"], fuck, fuck[1])
	fuck = GLOB.cock_shapes_list.Copy()
	if(length(pref_species.weiner_type))
		fuck = pref_species.weiner_type.Copy()
	features["cock_shape"]			= sanitize_inlist(features["cock_shape"], fuck, fuck[1])
	fuck = GLOB.balls_shapes_list.Copy()
	if(length(pref_species.balls_type))
		fuck = pref_species.balls_type.Copy()
	features["balls_shape"]			= sanitize_inlist(features["balls_shape"], fuck, fuck[1])
	fuck = GLOB.vagina_shapes_list.Copy()
	if(length(pref_species.vegana_type))
		fuck = pref_species.vegana_type.Copy()
	features["vag_shape"]			= sanitize_inlist(features["vag_shape"], fuck, fuck[1])
	
	var/skintoned = pref_species.use_skintones
	features["breasts_color"]		= sanitize_hexcolor(features["breasts_color"], 6, TRUE, "FFF")
	features["cock_color"]			= sanitize_hexcolor(features["cock_color"], 6, TRUE, "FFF")
	features["balls_color"]			= sanitize_hexcolor(features["balls_color"], 6, TRUE, "FFF")
	features["vag_color"]			= sanitize_hexcolor(features["vag_color"], 6, TRUE, "FFF")
	if(skintoned)
		features["breasts_color"] = SKINTONE2HEX(skin_tone)
		features["cock_color"] = SKINTONE2HEX(skin_tone)
		features["balls_color"] = SKINTONE2HEX(skin_tone)
		features["vag_color"] = SKINTONE2HEX(skin_tone)
	
	if(!features["has_cock"] && !features["has_vag"])
		if(gender == FEMALE)
			features["has_vag"] = TRUE
		else
			features["has_cock"] = TRUE
			features["has_balls"] = TRUE
	joblessrole	= sanitize_integer(joblessrole, 1, 3, initial(joblessrole))
	//Validate job prefs
	for(var/j in job_preferences)
		if(job_preferences["[j]"] != JP_LOW && job_preferences["[j]"] != JP_MEDIUM && job_preferences["[j]"] != JP_HIGH)
			job_preferences -= j

	cit_character_pref_load(S)

	return 1

/datum/preferences/proc/save_character()
	if(!path)
		return 0
	if(world.time < savecharcooldown)
		if(istype(parent))
			to_chat(parent, "<span class='warning'>You're attempting to save your character a little too fast. Wait half a second, then try again.</span>")
		return 0
	savecharcooldown = world.time + PREF_SAVELOAD_COOLDOWN
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/character[default_slot]"

	WRITE_FILE(S["version"]			, SAVEFILE_VERSION_MAX)	//load_character will sanitize any bad data, so assume up-to-date.)

	//Character
	WRITE_FILE(S["real_name"]				, real_name)
	//WRITE_FILE(S["nameless"]				, nameless)
	WRITE_FILE(S["auto_hiss"]				, auto_hiss)
	WRITE_FILE(S["custom_species"]			, custom_species)
	WRITE_FILE(S["name_is_always_random"]	, be_random_name)
	WRITE_FILE(S["body_is_always_random"]	, be_random_body)
	WRITE_FILE(S["gender"]					, gender)
	WRITE_FILE(S["body_model"]				, features["body_model"])
	WRITE_FILE(S["body_size"]				, features["body_size"])
	WRITE_FILE(S["age"]						, age)
	WRITE_FILE(S["hair_color"]				, hair_color)
	WRITE_FILE(S["facial_hair_color"]		, facial_hair_color)
	WRITE_FILE(S["left_eye_color"]			, left_eye_color)
	WRITE_FILE(S["right_eye_color"]			, right_eye_color)
	WRITE_FILE(S["use_custom_skin_tone"]	, use_custom_skin_tone)
	WRITE_FILE(S["skin_tone"]				, skin_tone)
	WRITE_FILE(S["hair_style_name"]			, hair_style)
	WRITE_FILE(S["facial_style_name"]		, facial_hair_style)
	WRITE_FILE(S["backbag"]					, backbag)
	WRITE_FILE(S["species"]					, pref_species.id)
	WRITE_FILE(S["feature_mcolor"]					, features["mcolor"])
	WRITE_FILE(S["feature_lizard_tail"]				, features["tail_lizard"])
	WRITE_FILE(S["feature_human_tail"]				, features["tail_human"])
	WRITE_FILE(S["feature_lizard_snout"]			, features["snout"])
	WRITE_FILE(S["feature_lizard_horns"]			, features["horns"])
	WRITE_FILE(S["feature_human_ears"]				, features["ears"])
	WRITE_FILE(S["feature_lizard_frills"]			, features["frills"])
	WRITE_FILE(S["feature_lizard_spines"]			, features["spines"])
	WRITE_FILE(S["feature_lizard_body_markings"]	, features["body_markings"])
	WRITE_FILE(S["feature_lizard_legs"]				, features["legs"])
	WRITE_FILE(S["feature_deco_wings"]				, features["deco_wings"])
	WRITE_FILE(S["feature_horns_color"]				, features["horns_color"])
	WRITE_FILE(S["feature_wings_color"]				, features["wings_color"])
	WRITE_FILE(S["feature_insect_wings"]			, features["insect_wings"])
	WRITE_FILE(S["feature_insect_fluff"]			, features["insect_fluff"])
	WRITE_FILE(S["feature_insect_markings"]			, features["insect_markings"])
	WRITE_FILE(S["feature_meat"]					, features["meat_type"])
	WRITE_FILE(S["feature_ipc_chassis"]			, features["ipc_chassis"])
	WRITE_FILE(S["bloodtype"]					, bloodtype)
	WRITE_FILE(S["bloodcolor"]					, bloodcolor)
	WRITE_FILE(S["bloodreagent"]				, bloodreagent)
	WRITE_FILE(S["color_gear"]						, color_gear)
	WRITE_FILE(S["bloodtype"]						, bloodtype)
	WRITE_FILE(S["bloodcolor"]						, bloodcolor)
	WRITE_FILE(S["bloodtype"]						, bloodtype)
	WRITE_FILE(S["bloodreagent"]					, bloodreagent)

	WRITE_FILE(S["feature_has_cock"], features["has_cock"])
	WRITE_FILE(S["feature_cyber_cock"], features["cyber_cock"])
	WRITE_FILE(S["feature_cock_shape"], features["cock_shape"])
	WRITE_FILE(S["feature_cock_color"], features["cock_color"])
	WRITE_FILE(S["feature_cock_length"], features["cock_length"])

	WRITE_FILE(S["feature_has_balls"], features["has_balls"])
	WRITE_FILE(S["feature_cyber_balls"], features["cyber_balls"])
	WRITE_FILE(S["feature_balls_color"], features["balls_color"])
	WRITE_FILE(S["feature_balls_size"], features["balls_size"])

	WRITE_FILE(S["feature_has_breasts"], features["has_breasts"])
	WRITE_FILE(S["feature_cyber_breasts"], features["cyber_breasts"])
	WRITE_FILE(S["feature_breasts_size"], features["breasts_size"])
	WRITE_FILE(S["feature_breasts_shape"], features["breasts_shape"])
	WRITE_FILE(S["feature_breasts_color"], features["breasts_color"])
	WRITE_FILE(S["feature_breasts_producing"], features["breasts_producing"])

	WRITE_FILE(S["feature_has_vag"], features["has_vag"])
	WRITE_FILE(S["feature_cyber_vag"], features["cyber_vag"])
	WRITE_FILE(S["feature_vag_shape"], features["vag_shape"])
	WRITE_FILE(S["feature_vag_color"], features["vag_color"])

	WRITE_FILE(S["feature_has_womb"], features["has_womb"])
	WRITE_FILE(S["feature_cyber_womb"], features["cyber_womb"])

	//Custom names
	for(var/custom_name_id in GLOB.preferences_custom_names)
		var/savefile_slot_name = custom_name_id + "_name" //TODO remove this
		WRITE_FILE(S[savefile_slot_name],custom_names[custom_name_id])

	WRITE_FILE(S["prefered_security_department"]	, prefered_security_department)

	//Jobs
	WRITE_FILE(S["joblessrole"]		, joblessrole)
	//Write prefs
	WRITE_FILE(S["job_preferences"] , job_preferences)

	//Quirks
	WRITE_FILE(S["special_char"]		, special_char)
	WRITE_FILE(S["language"]			, language)
	WRITE_FILE(S["body_descriptors"]	, body_descriptors)

	//gear loadout
	if(chosen_gear.len)
		var/text_to_save = chosen_gear.Join("|")
		S["loadout"] << text_to_save
	else
		S["loadout"] << "" //empty string to reset the value

	cit_character_pref_save(S)

	return 1


#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN

#ifdef TESTING
//DEBUG
//Some crude tools for testing savefiles
//path is the savefile path
/client/verb/savefile_export(path as text)
	var/savefile/S = new /savefile(path)
	S.ExportText("/",file("[path].txt"))
//path is the savefile path
/client/verb/savefile_import(path as text)
	var/savefile/S = new /savefile(path)
	S.ImportText("/",file("[path].txt"))

#endif

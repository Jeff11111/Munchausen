#define LINKIFY_READY(string, value, user) "<a href='byond://?src=[REF(user)];ready=[value]'>[string]</a>"
#define DEFAULT_SLOT_AMT	2
#define HANDS_SLOT_AMT		2
#define BACKPACK_SLOT_AMT	4

GLOBAL_LIST_EMPTY(preferences_datums)
GLOBAL_LIST_INIT(food, list(
		"Meat" = MEAT,
		"Vegetables" = VEGETABLES,
		"Raw" = RAW,
		"Junk Food" = JUNKFOOD,
		"Grain" = GRAIN,
		"Fruit" = FRUIT,
		"Dairy" = DAIRY,
		"Fried" = FRIED,
		"Alcohol" = ALCOHOL,
		"Sugar" = SUGAR,
		"Gross" = GROSS,
		"Toxic" = TOXIC,
		"Pineapple" = PINEAPPLE,
		"Breakfast" = BREAKFAST,
	))

/datum/preferences
	var/client/parent
	//doohickeys for savefiles
	var/path
	var/vr_path
	var/default_slot = 1				//Holder so it doesn't default to slot 1, rather the last one used
	var/max_save_slots = 30

	//non-preference stuff
	var/muted = 0
	var/last_ip
	var/last_id
	var/log_clicks = FALSE

	var/icon/custom_holoform_icon
	var/list/cached_holoform_icons
	var/last_custom_holoform = 0

	//Cooldowns for saving/loading. These are four are all separate due to loading code calling these one after another
	var/saveprefcooldown
	var/loadprefcooldown
	var/savecharcooldown
	var/loadcharcooldown

	//game-preferences
	var/lastchangelog = ""				//Saved changlog filesize to detect if there was a change
	var/ooccolor = "#c43b23"
	var/aooccolor = "#ce254f"
	var/enable_tips = TRUE
	var/tip_delay = 500 //tip delay in milliseconds

	//Antag preferences
	var/list/be_special = list()		//Special role selection
	var/tmp/old_be_special = 0			//Bitflag version of be_special, used to update old savefiles and nothing more
										//If it's 0, that's good, if it's anything but 0, the owner of this prefs file's antag choices were,
										//autocorrected this round, not that you'd need to check that.


	var/buttons_locked = FALSE
	var/hotkeys = FALSE
	var/chat_on_map = TRUE
	var/max_chat_length = CHAT_MESSAGE_MAX_LENGTH
	var/see_chat_non_mob = TRUE

	/// Custom Keybindings
	var/list/key_bindings = list()
	/// List with a key string associated to a list of keybindings. Unlike key_bindings, this one operates on raw key, allowing for binding a key that triggers regardless of if a modifier is depressed as long as the raw key is sent.
	var/list/modless_key_bindings = list()


	var/tgui_fancy = TRUE
	var/tgui_lock = TRUE
	var/windowflashing = TRUE
	var/toggles = TOGGLES_DEFAULT
	var/db_flags
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/ghost_form = "ghost"
	var/ghost_orbit = GHOST_ORBIT_CIRCLE
	var/ghost_accs = GHOST_ACCS_DEFAULT_OPTION
	var/ghost_others = GHOST_OTHERS_DEFAULT_OPTION
	var/ghost_hud = 1
	var/inquisitive_ghost = 1
	var/allow_midround_antag = 1
	var/preferred_map = null
	var/preferred_chaos = null
	var/pda_style = MONO
	var/pda_color = "#808000"
	var/show_credits = TRUE
	var/event_participation = FALSE
	var/event_prefs = ""
	var/appear_in_round_end_report = TRUE //whether the player of the character is listed on the round-end report

	var/uses_glasses_colour = 0

	//character preferences
	var/real_name						//our character's name
	var/nameless = FALSE				//whether or not our character is nameless
	var/auto_hiss = FALSE				//if our character hisses
	var/be_random_name = 0				//whether we'll have a random name every round
	var/be_random_body = 0				//whether we'll have a random body every round
	var/gender = MALE					//gender of character (well duh)
	var/age = 30						//age of character

	//SKYRAT CHANGES
	var/bloodtype = ""
	var/bloodreagent = ""
	var/bloodcolor = ""
	var/general_records = ""
	var/security_records = ""
	var/medical_records = ""
	var/flavor_background = ""
	var/character_skills = ""
	var/exploitable_info = ""
	var/flavor_faction = "None (Freelancer)"
	var/corporate_relations = "Neutral"
	var/see_chat_emotes = TRUE
	var/enable_personal_chat_color = FALSE
	var/personal_chat_color = "#ffffff"

	var/language = ""

	var/list/foodlikes = list()
	var/list/fooddislikes = list()
	var/list/color_gear = list()
	var/maxlikes = 3
	var/maxdislikes = 3

	var/list/body_descriptors = list()

	var/list/alt_titles_preferences = list()

	var/backbag = DBACKPACK				//backpack type
	var/hair_style = "Bald"				//Hair type
	var/hair_color = "#FFFFFF"				//Hair color
	var/facial_hair_style = "Shaved"	//Face hair type
	var/facial_hair_color = "#FFFFFF"		//Facial hair color
	var/skin_tone = "caucasian1"		//Skin color
	var/use_custom_skin_tone = FALSE
	//Eye colors
	var/left_eye_color = "#FFFFFF"
	var/right_eye_color = "#FFFFFF"
	var/datum/species/pref_species = new /datum/species/human()	//Mutant race
	var/list/features = list("mcolor" = "FFF",
		"mcolor2" = "FFF",
		"mcolor3" = "FFF",
		"tail_lizard" = "Smooth",
		"tail_human" = "None",
		"snout" = "Round",
		"horns" = "None",
		"horns_color" = "85615a",
		"ears" = "None",
		"wings" = "None",
		"wings_color" = "FFF",
		"frills" = "None",
		"deco_wings" = "None",
		"spines" = "None",
		"body_markings" = "None",
		"legs" = "Plantigrade",
		"insect_wings" = "Plain",
		"insect_fluff" = "None",
		"insect_markings" = "None",
		"mam_body_markings" = "Plain",
		"mam_ears" = "None",
		"mam_snouts" = "None",
		"mam_tail" = "None",
		"mam_tail_animated" = "None",
		"xenodorsal" = "Standard",
		"xenohead" = "Standard",
		"xenotail" = "Xenomorph Tail",
		"taur" = "None",
		"genitals_use_skintone" = TRUE,
		"has_cock" = FALSE,
		"cyber_cock" = FALSE,
		"cock_shape" = DEF_COCK_SHAPE,
		"cock_length" = COCK_SIZE_DEF,
		"cock_diameter_ratio" = COCK_DIAMETER_RATIO_DEF,
		"cock_color" = "fff",
		"cock_taur" = FALSE,
		"has_balls" = FALSE,
		"cyber_balls" = FALSE,
		"balls_color" = "fff",
		"balls_shape" = DEF_BALLS_SHAPE,
		"balls_size" = BALLS_SIZE_DEF,
		"balls_cum_rate" = CUM_RATE,
		"balls_cum_mult" = CUM_RATE_MULT,
		"balls_efficiency" = CUM_EFFICIENCY,
		"has_breasts" = FALSE,
		"cyber_breasts" = FALSE,
		"breasts_color" = "fff",
		"breasts_size" = BREASTS_SIZE_DEF,
		"breasts_shape" = DEF_BREASTS_SHAPE,
		"breasts_producing" = FALSE,
		"has_vag" = FALSE,
		"cyber_vag" = FALSE,
		"vag_shape" = DEF_VAGINA_SHAPE,
		"vag_color" = "fff",
		"has_womb" = FALSE,
		"cyber_womb" = FALSE,
		"ipc_screen" = "Sunburst",
		"ipc_antenna" = "None",
		"meat_type" = "Mammalian",
		"body_model" = MALE,
		"ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)",
		"body_size" = RESIZE_DEFAULT_SIZE
		)
	var/list/custom_names = list()
	var/prefered_security_department = SEC_DEPT_RANDOM
	var/custom_species = ""
	var/list/organ_augments = list() //Organ slots associated with augments
	var/list/limb_augments = list() //Body zones associated with augments

	// Specials aka "QUIRKS"
	var/special_char = FALSE

	// Job preferences 2.0 - indexed by job title, no key or value implies never
	var/list/job_preferences = list()

	// Want randomjob if preferences already filled - Donkie
	var/joblessrole = BERANDOMJOB  //defaults to 1 for fewer assistants

	// 0 = character settings, 1 = game preferences
	var/current_tab = 0

	var/unlock_content = 0

	var/list/ignoring = list()

	var/clientfps = 0

	var/parallax

	var/ambientocclusion = TRUE
	var/auto_fit_viewport = TRUE

	var/hud_toggle_flash = TRUE
	var/hud_toggle_color = "#ffffff"

	var/list/exp = list()
	var/list/menuoptions

	var/action_buttons_screen_locs = list()

	//backgrounds
	var/mutable_appearance/character_background
	var/bgstate = "steel"
	var/list/bgstate_options = list("steel", "plating", "reinforced", "white", "dark", "000", "midgrey", "FFF")

	var/show_mismatched_markings = FALSE //determines whether or not the markings lists should show markings that don't match the currently selected species. Intentionally left unsaved.

	var/no_tetris_storage = FALSE

	///loadout stuff
	var/gear_points = 10
	var/list/gear_categories
	var/list/chosen_gear = list()
	var/gear_tab

	var/arousable = TRUE
	var/widescreenpref = TRUE
	var/fullscreenpref = TRUE
	var/autostand = TRUE
	var/auto_ooc = FALSE

/datum/preferences/New(client/C)
	parent = C
	clientfps = world.fps*2
	for(var/custom_name_id in GLOB.preferences_custom_names)
		custom_names[custom_name_id] = get_default_name(custom_name_id)

	if(istype(C))
		if(!IsGuestKey(C.key))
			load_path(C.ckey)
			unlock_content = C.IsByondMember()
			if(unlock_content)
				max_save_slots = 30
	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			return
	//we couldn't load character data so just randomize the character appearance + name
	random_character()		//let's create a random character then - rather than a fat, bald and naked man.
	key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key) // give them default keybinds and update their movement keys
	C?.update_movement_keys(src)
	real_name = pref_species.random_name(gender,1)
	if(!loaded_preferences_successfully)
		save_preferences()
	save_character()		//let's save this new random character so it doesn't keep generating new ones.
	menuoptions = list()
	return

#define APPEARANCE_CATEGORY_COLUMN "<td valign='top' width='17%'>"
#define MAX_MUTANT_ROWS 5

/datum/preferences/proc/ShowChoices(mob/user)
	if(!user || !user.client)
		return
	update_preview_icon(current_tab != 2)
	var/list/dat = list("<center>")

	dat += "<a href='?_src_=prefs;preference=tab;tab=0' [current_tab == 0 ? "class='linkOn'" : ""]>Character Settings</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=1' [current_tab == 1 ? "class='linkOn'" : ""]>Character Appearance</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=2' [current_tab == 2 ? "class='linkOn'" : ""]>Loadout</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=3' [current_tab == 3 ? "class='linkOn'" : ""]>Game Preferences</a>"
	dat += "<a href='?_src_=prefs;preference=tab;tab=4' [current_tab == 4 ? "class='linkOn'" : ""]>Keybindings</a>"

	if(!path)
		dat += "<div class='notice'>Please create an account to save your preferences</div>"

	dat += "</center>"

	dat += "<HR>"

	switch(current_tab)
		if(0) // Character Settings
			if(path)
				var/savefile/S = new /savefile(path)
				if(S)
					dat += "<center>"
					var/name
					var/unspaced_slots = 0
					for(var/i=1, i<=max_save_slots, i++)
						unspaced_slots++
						if(unspaced_slots > 6)
							dat += "<br>"
							unspaced_slots = 0
						S.cd = "/character[i]"
						S["real_name"] >> name
						if(!name)
							name = "Character[i]"
						dat += "<a style='white-space:nowrap;' href='?_src_=prefs;preference=changeslot;num=[i];' [i == default_slot ? "class='linkOn'" : ""]>[name]</a> "
					dat += "</center>"

			dat += "<hr>"
			dat += "<center><h2>Occupation Choices</h2>"
			dat += "<a href='?_src_=prefs;preference=job;task=menu'>Set Occupation Preferences</a><br></center>"

			dat += "<table width='100%'>"
			dat += "<tr>"
			dat += "<td width='50%' valign='top'>"
			dat += "<center><h2>Food Setup</h2>"
			dat += "<a href='?_src_=prefs;preference=food;task=menu'>Configure Foods</a></center>"
			dat += "<center><b>Current Likings:</b> [foodlikes.len ? foodlikes.Join(", ") : "None"]</center>"
			dat += "<center><b>Current Dislikings:</b> [fooddislikes.len ? fooddislikes.Join(", ") : "None"]</center>"
			dat += "</td>"
			dat += "<td width='50%' valign='top'>"
			dat += "<center><h2>Augment Setup</h2>"
			dat += "<a href='?_src_=prefs;preference=augments;task=configure'>Configure Augments</a></center>"
			var/list/augments = list()
			for(var/a in organ_augments)
				augments |= organ_augments[a][1]
			for(var/a in limb_augments)
				augments |= limb_augments[a][1]
			dat += "<center><b>Current Augments:</b> [augments.len ? augments.Join(", ") : "None"]</center>"
			dat += "</td>"
			dat += "</table>"
			dat += "<hr>"

			dat += "<table width='100%'>"
			dat += "<tr>"
			dat += "<td width='50%' valign='top'>"
			dat += "<h2>Identity</h2>"
			if(jobban_isbanned(user, "appearance"))
				dat += "<b>You are banned from using custom names and appearances. You can continue to adjust your characters, but you will be randomised once you join the game.</b><br>"
			dat += "<b>Always Random Name:</b> <a href='?_src_=prefs;preference=name'>[be_random_name ? "Yes" : "No"]</a><BR>"

			dat += "<b>[nameless ? "Default designation" : "Name"]:</b>"
			dat += " <a href='?_src_=prefs;preference=name;task=input'>[real_name]</a>"
			dat += " <a href='?_src_=prefs;preference=name;task=random'>Random</a>"
			dat += "<br>"

			dat += "<b>Gender:</b> <a href='?_src_=prefs;preference=gender;task=input'>[gender == MALE ? "Male" : "Female"]</a><BR>"
			dat += "<b>Additional Language:</b> <a href='?_src_=prefs;preference=language;task=menu'><b>[language ? language : "None"]</b></a><BR>"
			dat += "<b>Age:</b> <a href='?_src_=prefs;preference=age;task=input'>[age]</a>"

			dat += "<h2>Additional Preferences</h2>"
			dat += "<b>Auto-Hiss:</b> <a href='?_src_=prefs;preference=auto_hiss'>[auto_hiss ? "Yes" : "No"]</a>"
			dat += "</td>"

			dat += "<td width='50%' valign='top'>"
			dat += "<h2>Special Names:</h2>"
			for(var/custom_name_id in (GLOB.preferences_custom_names - list("religion", "deity", "mime")))
				var/namedata = GLOB.preferences_custom_names[custom_name_id]
				dat += "<br><b>[namedata["pref_name"]]:</b> <a href ='?_src_=prefs;preference=[custom_name_id];task=input'>[custom_names[custom_name_id]]</a>"
			
			dat += "<br>"
			dat += "<h2>Job Preferences</h2>"
			dat += "<b>Preferred Security Department:</b> <a href='?_src_=prefs;preference=sec_dept;task=input'>[prefered_security_department]</a><br>"

			var/mob/dead/new_player/NP = user
			dat += "<span align='right'>"
			dat += "<h2>Game</h2>"
			if(istype(NP))
				if(CONFIG_GET(flag/roundstart_traits))
					dat += "<b>Be Special:</b> \["
					if(special_char)
						dat += " <b>Yes</b> | <a href='?_src_=prefs;preference=trait'>No</a>"
					else
						dat += "<a href='?_src_=prefs;preference=trait'>Yes</a> | <b>No</b> "
					dat += "\]<br>"
				if(SSticker.current_state <= GAME_STATE_PREGAME)
					switch(NP.ready)
						if(PLAYER_NOT_READY)
							dat += "\[[LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY, user)] | <b>Not Ready</b> \]<br>"
							dat += "\[[LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE, user)]\]"
						if(PLAYER_READY_TO_PLAY)
							dat += "\[ <b>Ready</b> | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY, user)]\]<br>"
							dat += "\[[LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE, user)]\]"
						if(PLAYER_READY_TO_OBSERVE)
							dat += "\[[LINKIFY_READY("Ready", PLAYER_READY_TO_PLAY, user)] | [LINKIFY_READY("Not Ready", PLAYER_NOT_READY, user)]\]<br>"
							dat += "<b>\[Observe\]</b>"
				else
					dat += "\[<a href='byond://?src=[REF(user)];manifest=1'>Crew Manifest</a>\]<br>"
					dat += "\[<a href='byond://?src=[REF(user)];late_join=1'>Join Game</a>\]<br>"
					dat += "\[[LINKIFY_READY("Observe", PLAYER_READY_TO_OBSERVE, user)]\]"
			else
				dat += "\[<a href='?_src_=prefs;close_setup=1'>Done</a>\]"
			dat += "</span>"
			dat += "</td>"
			dat += "</tr>"
			dat += "</table>"
		if(1) //Character Appearance
			if(path)
				var/savefile/S = new /savefile(path)
				if(S)
					dat += "<center>"
					var/name
					var/unspaced_slots = 0
					for(var/i=1, i<=max_save_slots, i++)
						unspaced_slots++
						if(unspaced_slots > 4)
							dat += "<br>"
							unspaced_slots = 0
						S.cd = "/character[i]"
						S["real_name"] >> name
						if(!name)
							name = "Character[i]"
						dat += "<a style='white-space:nowrap;' href='?_src_=prefs;preference=changeslot;num=[i];' [i == default_slot ? "class='linkOn'" : ""]>[name]</a> "
					dat += "</center>"

			dat += "<table><tr><td width='340px' height='300px' valign='top'>"

			dat += 	"<h2>Records</h2>"
			dat += 	"<a href='?_src_=prefs;preference=general_records;task=input'><b>General</b></a><br>"
			if(length(general_records) <= 40)
				if(!length(general_records))
					dat += "\[...\]"
				else
					dat += "[general_records]"
			else
				dat += "[TextPreview(general_records)]..."
			dat += "<BR>"
			dat += 	"<a href='?_src_=prefs;preference=security_records;task=input'><b>Security</b></a><br>"
			if(length(security_records) <= 40)
				if(!length(security_records))
					dat += "\[...\]"
				else
					dat += "[security_records]"
			else
				dat += "[TextPreview(security_records)]..."
			dat += "<BR>"
			dat += 	"<a href='?_src_=prefs;preference=medical_records;task=input'><b>Medical</b></a><br>"
			if(length(medical_records) <= 40)
				if(!length(medical_records))
					dat += "\[...\]"
				else
					dat += "[medical_records]"
			else
				dat += "[TextPreview(medical_records)]..."
			dat += 	"<h2>Character</h2>"
			dat += 	"<a href='?_src_=prefs;preference=flavor_background;task=input'><b>Background</b></a><br>"
			if(length(flavor_background) <= 40)
				if(!length(flavor_background))
					dat += "\[...\]"
				else
					dat += "[flavor_background]"
			else
				dat += "[TextPreview(flavor_background)]..."
			dat += "<BR>"
			dat += 	"<a href='?_src_=prefs;preference=character_skills;task=input'><b>Skills</b></a><br>"
			if(length(character_skills) <= 40)
				if(!length(character_skills))
					dat += "\[...\]"
				else
					dat += "[character_skills]"
			else
				dat += "[TextPreview(character_skills)]..."
			dat += "<BR>"
			dat += 	"<a href='?_src_=prefs;preference=exploitable_info;task=input'><b>Exploitable Information</b></a><br>"
			if(length(exploitable_info) <= 40)
				if(!length(exploitable_info))
					dat += "\[...\]"
				else
					dat += "[exploitable_info]"
			else
				dat += "[TextPreview(exploitable_info)]..."
			dat += "<BR><BR>"
			if(length(pref_species.bloodtypes))
				dat += "<b>Blood type :</b>"
				dat += 	" <a href='?_src_=prefs;preference=bloodtype;task=input'>[bloodtype ? bloodtype : "Species Default"]</a><br>"
			dat += "<b>Faction/Employer :</b> <a href='?_src_=prefs;preference=flavor_faction;task=input'>[flavor_faction ? flavor_faction : "None (Freelancer)"]</a><br>"
			dat += "<b>Corporate Relations :</b> <a href='?_src_=prefs;preference=corporate_relations;task=input'>[corporate_relations ? corporate_relations : "Neutral"]</a><br>"
			dat += "<b>Custom runechat color :</b> <a href='?_src_=prefs;preference=enable_personal_chat_color'>[enable_personal_chat_color ? "Enabled" : "Disabled"]</a> [enable_personal_chat_color ? "<span style='border: 1px solid #161616; background-color: [personal_chat_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=personal_chat_color;task=input'>Change</a>" : ""]<br>"
			dat += "<h2>Body</h2>"
			dat += "<b>Gender:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=gender;task=input'>[gender == MALE ? "Male" : "Female"]</a><BR>"
			if(pref_species.sexes)
				dat += "<b>Body Model:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=body_model'>[features["body_model"] == MALE ? "Masculine" : "Feminine"]</a><BR>"
			dat += "<b>Species:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=species;task=menu'>[pref_species.name]</a><BR>"
			dat += "<b>Custom Species Name:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=custom_species;task=input'>[custom_species ? custom_species : "None"]</a><BR>"
			if(LAZYLEN(pref_species.descriptors))
				dat += "<b>Descriptors:</b><BR>"
				for(var/entry in pref_species.descriptors)
					var/datum/mob_descriptor/descriptor = pref_species.descriptors[entry]
					if(!descriptor)
						continue
					dat += "<b>[capitalize(descriptor.chargen_label)]:</b> [descriptor.get_standalone_value_descriptor(body_descriptors[entry]) ? descriptor.get_standalone_value_descriptor(body_descriptors[entry]) : "None"] <a href='?_src_=prefs;preference=descriptors;task=input;change_descriptor=[entry]'>Change</a><BR>"
				dat += "<BR>"
			dat += "<b>Random Body:</b><a style='display:block;width:100px' href='?_src_=prefs;preference=all;task=random'>Randomize!</A><BR>"
			dat += "<b>Always Random Body:</b><a href='?_src_=prefs;preference=all'>[be_random_body ? "Yes" : "No"]</A><BR>"
			dat += "<br><b>Cycle background:</b><br>"
			dat += "[icon2html(character_background, user)] "
			dat += "<a href='?_src_=prefs;preference=cycle_bg;task=input'>[bgstate]</a><BR>"

			var/use_skintones = pref_species.use_skintones
			if(use_skintones)
				dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Skin Tone</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=s_tone;task=input'>[use_custom_skin_tone ? "custom: <span style='border:1px solid #161616; background-color: [skin_tone];'>&nbsp;&nbsp;&nbsp;</span>" : skin_tone]</a><BR>"

			var/mutant_colors
			if((MUTCOLORS in pref_species.species_traits) || (MUTCOLORS_PARTSONLY in pref_species.species_traits))
				if(!use_skintones)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h2>Body Colors</h2>"

				dat += "<b>Primary Color:</b><BR>"
				dat += "<span style='border: 1px solid #161616; background-color: [features["mcolor"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color;task=input'>Change</a><BR>"

				dat += "<b>Secondary Color:</b><BR>"
				dat += "<span style='border: 1px solid #161616; background-color: [features["mcolor2"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color2;task=input'>Change</a><BR>"

				dat += "<b>Tertiary Color:</b><BR>"
				dat += "<span style='border: 1px solid #161616; background-color: [features["mcolor3"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=mutant_color3;task=input'>Change</a><BR>"
				mutant_colors = TRUE

			if (CONFIG_GET(number/body_size_min) != CONFIG_GET(number/body_size_max))
				dat += "<b>Sprite Size:</b> <a href='?_src_=prefs;preference=body_size;task=input'>[features["body_size"]*100]%</a><br>"

			if((EYECOLOR in pref_species.species_traits) && !(NOEYES in pref_species.species_traits))

				if(!use_skintones && !mutant_colors)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Eye Colors</h3>"

				dat += "<span style='border: 1px solid #161616; background-color: [left_eye_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=left_eye;task=input'>Left Eye</a><BR>"
				dat += "<span style='border: 1px solid #161616; background-color: [right_eye_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=right_eye;task=input'>Right Eye</a><BR>"

				dat += "</td>"
			else if(use_skintones || mutant_colors)
				dat += "</td>"

			if(HAIR in pref_species.species_traits)

				dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Hair Style</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=hair_style;task=input'>[hair_style ? hair_style : "Shaved"]</a>"
				dat += "<a href='?_src_=prefs;preference=previous_hair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_hair_style;task=input'>&gt;</a><BR>"
				dat += "<span style='border:1px solid #161616; background-color: [hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hair;task=input'>Change</a><BR>"

				dat += "<h3>Facial Hair Style</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=facial_hair_style;task=input'>[facial_hair_style ? facial_hair_style : "Shaved"]</a>"
				dat += "<a href='?_src_=prefs;preference=previous_facehair_style;task=input'>&lt;</a> <a href='?_src_=prefs;preference=next_facehair_style;task=input'>&gt;</a><BR>"
				dat += "<span style='border: 1px solid #161616; background-color: [facial_hair_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=facial;task=input'>Change</a><BR>"

				dat += "</td>"
			//Mutant stuff
			var/mutant_category = 0

			dat += APPEARANCE_CATEGORY_COLUMN
			dat += "<h3>Mismatched Markings</h3>"
			dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=mismatched_markings;task=input'>[show_mismatched_markings ? "Yes" : "No"]</a>"
			mutant_category++
			if(mutant_category >= MAX_MUTANT_ROWS) //just in case someone sets the max rows to 1 or something dumb like that
				dat += "</td>"
				mutant_category = 0

			if(pref_species.mutant_bodyparts["tail_lizard"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Tail</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=tail_lizard;task=input'>[features["tail_lizard"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["mam_tail"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Tail</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=mam_tail;task=input'>[features["mam_tail"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["tail_human"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Tail</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=tail_human;task=input'>[features["tail_human"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["meat_type"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Meat Type</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=meats;task=input'>[features["meat_type"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["snout"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Snout</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=snout;task=input'>[features["snout"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["horns"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Horns</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=horns;task=input'>[features["horns"]]</a>"
				dat += "<span style='border:1px solid #161616; background-color: [features["horns_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=horns_color;task=input'>Change</a><BR>"


				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["frills"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Frills</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=frills;task=input'>[features["frills"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["spines"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Spines</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=spines;task=input'>[features["spines"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["body_markings"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Body Markings</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=body_markings;task=input'>[features["body_markings"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["mam_body_markings"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Species Markings</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=mam_body_markings;task=input'>[features["mam_body_markings"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["mam_ears"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Ears</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=mam_ears;task=input'>[features["mam_ears"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["ears"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Ears</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=ears;task=input'>[features["ears"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["mam_snouts"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Snout</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=mam_snouts;task=input'>[features["mam_snouts"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["deco_wings"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Decorative wings</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=deco_wings;task=input'>[features["deco_wings"]]</a>"
				dat += "<span style='border:1px solid #161616; background-color: [features["wings_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=wings_color;task=input'>Change</a><BR>"

				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["insect_wings"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Insect wings</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=insect_wings;task=input'>[features["insect_wings"]]</a>"
				dat += "<span style='border:1px solid #161616; background-color: [features["wings_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=wings_color;task=input'>Change</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["insect_fluff"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Insect Fluff</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=insect_fluffs;task=input'>[features["insect_fluff"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["insect_markings"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Insect markings</h3>"

				dat += "<a href='?_src_=prefs;preference=insect_markings;task=input'>[features["insect_markings"]]</a><BR>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["wings"] && GLOB.r_wings_list.len >1)
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Wings</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=wings;task=input'>[features["wings"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["xenohead"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Caste Head</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=xenohead;task=input'>[features["xenohead"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["xenotail"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Tail</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=xenotail;task=input'>[features["xenotail"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["xenodorsal"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Dorsal Spines</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=xenodorsal;task=input'>[features["xenodorsal"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["ipc_screen"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Screen</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=ipc_screen;task=input'>[features["ipc_screen"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["ipc_antenna"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Antenna</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=ipc_antenna;task=input'>[features["ipc_antenna"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(pref_species.mutant_bodyparts["ipc_chassis"])
				if(!mutant_category)
					dat += APPEARANCE_CATEGORY_COLUMN

				dat += "<h3>Chassis Type</h3>"

				dat += "<a style='display:block;width:100px' href='?_src_=prefs;preference=ipc_chassis;task=input'>[features["ipc_chassis"]]</a>"

				mutant_category++
				if(mutant_category >= MAX_MUTANT_ROWS)
					dat += "</td>"
					mutant_category = 0

			if(mutant_category)
				dat += "</td>"
				mutant_category = 0

			dat += "</tr></table>"

			dat += "</td>"
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>Clothing & Equipment</h2>"
			dat += "<b>Backpack:</b><a style='display:block;width:100px' href ='?_src_=prefs;preference=bag;task=input'>[backbag]</a><br>"
			dat += "</td>"

			dat +="<td width='220px' height='300px' valign='top'>"
			if(NOGENITALS in pref_species.species_traits)
				dat += "<b>Your species ([pref_species.name]) does not support genitals!</b><br>"
			else
				dat += "<h3>Penis</h3>"
				dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=has_cock'>[(features["has_cock"] && pref_species.has_weiner) ? "Yes" : "No"]</a>"
				if(features["has_cock"] && pref_species.has_weiner)
					if(pref_species.use_skintones || features["genitals_use_skintone"])
						dat += "<b>Penis Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'>&nbsp;&nbsp;&nbsp;</span> (Species uses skin tones</a><br>"
					else
						dat += "<b>Penis Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: [features["cock_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=cock_color;task=input'>Change</a><br>"
					dat += "<b>Cybernetic Penis:</b> <a style='display:block;width:50px' href='?_src_=prefs;preference=cyber_cock'>[features["cyber_cock"] ? "Yes" : "No"]</a>"
					dat += "<b>Penis Shape:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=cock_shape;task=input'>[features["cock_shape"]]</a>"
					dat += "<b>Penis Length:</b> <a style='display:block;width:120px' href='?_src_=prefs;preference=cock_length;task=input'>[round(features["cock_length"], 1)] centimeter(s)</a>"
					dat += "<b>Has Testicles:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_balls'>[(features["has_balls"] && pref_species.has_balls) ? "Yes" : "No"]</a>"
					if(features["has_balls"] && pref_species.has_balls)
						if(pref_species.use_skintones || features["genitals_use_skintone"])
							dat += "<b>Testicles Color:</b></a><BR>"
							dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'>&nbsp;&nbsp;&nbsp;</span>(Skin tone overriding)<br>"
						else
							dat += "<b>Testicles Color:</b></a><BR>"
							dat += "<span style='border: 1px solid #161616; background-color: [features["balls_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=balls_color;task=input'>Change</a><br>"
						dat += "<b>Cybernetic Testes:</b> <a style='display:block;width:50px' href='?_src_=prefs;preference=cyber_balls'>[features["cyber_balls"] ? "Yes" : "No"]</a>"
				dat += APPEARANCE_CATEGORY_COLUMN
				dat += "<h3>Vagina</h3>"
				dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=has_vag'>[features["has_vag"] == TRUE ? "Yes" : "No"]</a>"
				if(features["has_vag"] && pref_species.has_vegana)
					dat += "<b>Vagina Type:</b> <a style='display:block;width:100px' href='?_src_=prefs;preference=vag_shape;task=input'>[features["vag_shape"]]</a>"
					if(pref_species.use_skintones || features["genitals_use_skintone"])
						dat += "<b>Vagina Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'>&nbsp;&nbsp;&nbsp;</span>(Skin tone overriding)<br>"
					else
						dat += "<b>Vagina Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: [features["vag_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=vag_color;task=input'>Change</a><br>"
					dat += "<b>Cybernetic Vagina:</b> <a style='display:block;width:50px' href='?_src_=prefs;preference=cyber_vag'>[features["cyber_vag"] ? "Yes" : "No"]</a>"
					dat += "<b>Has Womb:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=has_womb'>[features["has_womb"] == TRUE ? "Yes" : "No"]</a>"
					dat += "<b>Cybernetic Womb:</b> <a style='display:block;width:50px' href='?_src_=prefs;preference=cyber_womb'>[features["cyber_womb"] ? "Yes" : "No"]</a>"
				dat += "</td>"
				dat += APPEARANCE_CATEGORY_COLUMN
				dat += "<h3>Breasts</h3>"
				dat += "<a style='display:block;width:50px' href='?_src_=prefs;preference=has_breasts'>[features["has_breasts"] == TRUE ? "Yes" : "No"]</a>"
				if(features["has_breasts"] && pref_species.has_bobs)
					if(pref_species.use_skintones || features["genitals_use_skintone"])
						dat += "<b>Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: [SKINTONE2HEX(skin_tone)];'>&nbsp;&nbsp;&nbsp;</span>(Skin tone overriding)<br>"
					else
						dat += "<b>Color:</b></a><BR>"
						dat += "<span style='border: 1px solid #161616; background-color: [features["breasts_color"]];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=breasts_color;task=input'>Change</a><br>"
					dat += "<b>Cup Size:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_size;task=input'>[features["breasts_size"]]</a>"
					dat += "<b>Breasts Shape:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_shape;task=input'>[features["breasts_shape"]]</a>"
					dat += "<b>Lactates:</b><a style='display:block;width:50px' href='?_src_=prefs;preference=breasts_producing'>[features["breasts_producing"] == TRUE ? "Yes" : "No"]</a>"
					dat += "<b>Cybernetic Breasts:</b> <a style='display:block;width:50px' href='?_src_=prefs;preference=cyber_breasts'>[features["cyber_breasts"] ? "Yes" : "No"]</a>"
				dat += "</td>"
			dat += "</td>"
			dat += "</tr></table>"

		if(3) // Game Preferences
			dat += "<table><tr><td width='340px' height='300px' valign='top'>"
			dat += "<h2>General Settings</h2>"
			dat += "<b>tgui Monitors:</b> <a href='?_src_=prefs;preference=tgui_lock'>[(tgui_lock) ? "Primary" : "All"]</a><br>"
			dat += "<b>tgui Style:</b> <a href='?_src_=prefs;preference=tgui_fancy'>[(tgui_fancy) ? "Fancy" : "No Frills"]</a><br>"
			dat += "<b>Show Runechat Chat Bubbles:</b> <a href='?_src_=prefs;preference=chat_on_map'>[chat_on_map ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Runechat message char limit:</b> <a href='?_src_=prefs;preference=max_chat_length;task=input'>[max_chat_length]</a><br>"
			dat += "<b>See Runechat for non-mobs:</b> <a href='?_src_=prefs;preference=see_chat_non_mob'>[see_chat_non_mob ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>See Runechat for emotes:</b> <a href='?_src_=prefs;preference=see_chat_emotes'>[see_chat_emotes ? "Enabled" : "Disabled"]</a><br>"
			dat += "<br>"
			dat += "<b>Action Buttons:</b> <a href='?_src_=prefs;preference=action_buttons'>[(buttons_locked) ? "Locked In Place" : "Unlocked"]</a><br>"
			dat += "<br>"
			dat += "<b>PDA Color:</b> <span style='border:1px solid #161616; background-color: [pda_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=pda_color;task=input'>Change</a><BR>"
			dat += "<b>PDA Style:</b> <a href='?_src_=prefs;task=input;preference=pda_style'>[pda_style]</a><br>"
			dat += "<br>"
			dat += "<b>Ghost Ears:</b> <a href='?_src_=prefs;preference=ghost_ears'>[(chat_toggles & CHAT_GHOSTEARS) ? "All Speech" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost Radio:</b> <a href='?_src_=prefs;preference=ghost_radio'>[(chat_toggles & CHAT_GHOSTRADIO) ? "All Messages":"No Messages"]</a><br>"
			dat += "<b>Ghost Sight:</b> <a href='?_src_=prefs;preference=ghost_sight'>[(chat_toggles & CHAT_GHOSTSIGHT) ? "All Emotes" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost Whispers:</b> <a href='?_src_=prefs;preference=ghost_whispers'>[(chat_toggles & CHAT_GHOSTWHISPER) ? "All Speech" : "Nearest Creatures"]</a><br>"
			dat += "<b>Ghost PDA:</b> <a href='?_src_=prefs;preference=ghost_pda'>[(chat_toggles & CHAT_GHOSTPDA) ? "All Messages" : "Nearest Creatures"]</a><br>"
			dat += "<b>Window Flashing:</b> <a href='?_src_=prefs;preference=winflash'>[(windowflashing) ? "Enabled":"Disabled"]</a><br>"
			dat += "<br>"
			dat += "<b>Play Megafauna Music:</b> <a href='?_src_=prefs;preference=hear_megafauna'>[(toggles & SOUND_MEGAFAUNA) ? "Enabled":"Disabled"]</a><br>"
			dat += "<b>Play Admin MIDIs:</b> <a href='?_src_=prefs;preference=hear_midis'>[(toggles & SOUND_MIDI) ? "Enabled":"Disabled"]</a><br>"
			dat += "<b>Play Lobby Music:</b> <a href='?_src_=prefs;preference=lobby_music'>[(toggles & SOUND_LOBBY) ? "Enabled":"Disabled"]</a><br>"
			dat += "<b>See Pull Requests:</b> <a href='?_src_=prefs;preference=pull_requests'>[(chat_toggles & CHAT_PULLR) ? "Enabled":"Disabled"]</a><br>"
			dat += "<br>"
			if(user.client)
				if(unlock_content)
					dat += "<b>BYOND Membership Publicity:</b> <a href='?_src_=prefs;preference=publicity'>[(toggles & MEMBER_PUBLIC) ? "Public" : "Hidden"]</a><br>"
				if(unlock_content || check_rights_for(user.client, R_ADMIN))
					dat += "<b>OOC Color:</b> <span style='border: 1px solid #161616; background-color: [ooccolor ? ooccolor : GLOB.normal_ooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=ooccolor;task=input'>Change</a><br>"
					dat += "<b>Antag OOC Color:</b> <span style='border: 1px solid #161616; background-color: [aooccolor ? aooccolor : GLOB.normal_aooc_colour];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=aooccolor;task=input'>Change</a><br>"

			dat += "</td>"
			if(user.client.holder)
				dat +="<td width='300px' height='300px' valign='top'>"
				dat += "<h2>Admin Settings</h2>"
				dat += "<b>Adminhelp Sounds:</b> <a href='?_src_=prefs;preference=hear_adminhelps'>[(toggles & SOUND_ADMINHELP)?"Enabled":"Disabled"]</a><br>"
				dat += "<b>Announce Login:</b> <a href='?_src_=prefs;preference=announce_login'>[(toggles & ANNOUNCE_LOGIN)?"Enabled":"Disabled"]</a><br>"
				dat += "<br>"
				dat += "<b>Combo HUD Lighting:</b> <a href = '?_src_=prefs;preference=combohud_lighting'>[(toggles & COMBOHUD_LIGHTING)?"Full-bright":"No Change"]</a><br>"
				dat += "</td>"

			dat +="<td width='300px' height='300px' valign='top'>"
			dat += "<h2>Citadel Preferences</h2>" //Because fuck me if preferences can't be fucking modularized and expected to update in a reasonable timeframe.
			dat += "<b>Widescreen:</b> <a href='?_src_=prefs;preference=widescreenpref'>[widescreenpref ? "Enabled ([CONFIG_GET(string/default_view)])" : "Disabled (15x15)"]</a><br>"
			dat += "<b>Auto stand:</b> <a href='?_src_=prefs;preference=autostand'>[autostand ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Auto OOC:</b> <a href='?_src_=prefs;preference=auto_ooc'>[auto_ooc ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Force Slot Storage HUD:</b> <a href='?_src_=prefs;preference=no_tetris_storage'>[no_tetris_storage ? "Enabled" : "Disabled"]</a><br>"
			var/p_chaos
			if (!preferred_chaos)
				p_chaos = "No preference"
			else
				p_chaos = preferred_chaos
			dat += "<b>Preferred Chaos Amount:</b> <a href='?_src_=prefs;preference=preferred_chaos;task=input'>[p_chaos]</a><br>"
			dat += "<h2>Skyrat Preferences</h2>"
			dat += "<b>Show name at round-end report:</b> <a href='?_src_=prefs;preference=appear_in_round_end_report'>[appear_in_round_end_report ? "Yes" : "No"]</a><br>"
			dat += "<br>"
			dat += "</td>"
			dat += "</tr></table>"
			if(unlock_content)
				dat += "<b>Ghost Form:</b> <a href='?_src_=prefs;task=input;preference=ghostform'>[ghost_form]</a><br>"
				dat += "<B>Ghost Orbit: </B> <a href='?_src_=prefs;task=input;preference=ghostorbit'>[ghost_orbit]</a><br>"
			var/button_name = "If you see this something went wrong."
			switch(ghost_accs)
				if(GHOST_ACCS_FULL)
					button_name = GHOST_ACCS_FULL_NAME
				if(GHOST_ACCS_DIR)
					button_name = GHOST_ACCS_DIR_NAME
				if(GHOST_ACCS_NONE)
					button_name = GHOST_ACCS_NONE_NAME

			dat += "<b>Ghost Accessories:</b> <a href='?_src_=prefs;task=input;preference=ghostaccs'>[button_name]</a><br>"
			switch(ghost_others)
				if(GHOST_OTHERS_THEIR_SETTING)
					button_name = GHOST_OTHERS_THEIR_SETTING_NAME
				if(GHOST_OTHERS_DEFAULT_SPRITE)
					button_name = GHOST_OTHERS_DEFAULT_SPRITE_NAME
				if(GHOST_OTHERS_SIMPLE)
					button_name = GHOST_OTHERS_SIMPLE_NAME

			dat += "<b>Ghosts of Others:</b> <a href='?_src_=prefs;task=input;preference=ghostothers'>[button_name]</a><br>"
			dat += "<br>"

			dat += "<b>FPS:</b> <a href='?_src_=prefs;preference=clientfps;task=input'>[clientfps]</a><br>"

			dat += "<b>Income Updates:</b> <a href='?_src_=prefs;preference=income_pings'>[(chat_toggles & CHAT_BANKCARD) ? "Allowed" : "Muted"]</a><br>"

			dat += "<br>"

			dat += "<b>Parallax (Fancy Space):</b> <a href='?_src_=prefs;preference=parallaxdown' oncontextmenu='window.location.href=\"?_src_=prefs;preference=parallaxup\";return false;'>"
			switch (parallax)
				if (PARALLAX_LOW)
					dat += "Low"
				if (PARALLAX_MED)
					dat += "Medium"
				if (PARALLAX_INSANE)
					dat += "Insane"
				if (PARALLAX_DISABLE)
					dat += "Disabled"
				else
					dat += "High"
			dat += "</a><br>"
			dat += "<b>Ambient Occlusion:</b> <a href='?_src_=prefs;preference=ambientocclusion'>[ambientocclusion ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Fit Viewport:</b> <a href='?_src_=prefs;preference=auto_fit_viewport'>[auto_fit_viewport ? "Auto" : "Manual"]</a><br>"
			dat += "<b>HUD Button Flashes:</b> <a href='?_src_=prefs;preference=hud_toggle_flash'>[hud_toggle_flash ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>HUD Button Flash Color:</b> <span style='border: 1px solid #161616; background-color: [hud_toggle_color];'>&nbsp;&nbsp;&nbsp;</span> <a href='?_src_=prefs;preference=hud_toggle_color;task=input'>Change</a><br>"

			if (CONFIG_GET(flag/maprotation) && CONFIG_GET(flag/tgstyle_maprotation))
				var/p_map = preferred_map
				if (!p_map)
					p_map = "Default"
					if (config.defaultmap)
						p_map += " ([config.defaultmap.map_name])"
				else
					if (p_map in config.maplist)
						var/datum/map_config/VM = config.maplist[p_map]
						if (!VM)
							p_map += " (No longer exists)"
						else
							p_map = VM.map_name
					else
						p_map += " (No longer exists)"
				if(CONFIG_GET(flag/allow_map_voting))
					dat += "<b>Preferred Map:</b> <a href='?_src_=prefs;preference=preferred_map;task=input'>[p_map]</a><br>"

			dat += "</td><td width='300px' height='300px' valign='top'>"

			dat += "<h2>Special Role Settings</h2>"

			if(jobban_isbanned(user, ROLE_SYNDICATE))
				dat += "<font color=red><b>You are banned from antagonist roles.</b></font>"
				src.be_special = list()


			for (var/i in GLOB.special_roles)
				if(jobban_isbanned(user, i))
					dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;jobbancheck=[i]'>BANNED</a><br>"
				else
					var/days_remaining = null
					if(ispath(GLOB.special_roles[i]) && CONFIG_GET(flag/use_age_restriction_for_jobs)) //If it's a game mode antag, check if the player meets the minimum age
						var/mode_path = GLOB.special_roles[i]
						var/datum/game_mode/temp_mode = new mode_path
						days_remaining = temp_mode.get_remaining_days(user.client)

					if(days_remaining)
						dat += "<b>Be [capitalize(i)]:</b> <font color=red> \[IN [days_remaining] DAYS]</font><br>"
					else
						dat += "<b>Be [capitalize(i)]:</b> <a href='?_src_=prefs;preference=be_special;be_special_type=[i]'>[(i in be_special) ? "Enabled" : "Disabled"]</a><br>"
			dat += "<b>Midround Antagonist:</b> <a href='?_src_=prefs;preference=allow_midround_antag'>[(toggles & MIDROUND_ANTAG) ? "Enabled" : "Disabled"]</a><br>"

			dat += "<br>"

		if(2) //Loadout
			if(!gear_tab)
				gear_tab = GLOB.loadout_items[1]
			dat += "<table align='center' width='100%'>"
			dat += "<tr><td colspan=4><center><b><font color='[gear_points == 0 ? "#E62100" : "#CCDDFF"]'>[gear_points]</font> loadout points remaining.</b> \[<a href='?_src_=prefs;preference=gear;clear_loadout=1'>Clear Loadout</a>\]</center></td></tr>"
			dat += "<tr><td colspan=4><center>You can only choose one item per category, unless it's an item that spawns in your backpack or hands.</center></td></tr>"
			dat += "<tr><td colspan=4><center><b>"
			var/firstcat = TRUE
			for(var/i in GLOB.loadout_items)
				if(firstcat)
					firstcat = FALSE
				else
					dat += " |"
				if(i == gear_tab)
					dat += " <span class='linkOn'>[i]</span> "
				else
					dat += " <a href='?_src_=prefs;preference=gear;select_category=[i]'>[i]</a> "
			dat += "</b></center></td></tr>"
			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr><td colspan=4><b><center>[gear_tab]</center></b></td></tr>"
			dat += "<tr><td colspan=4><hr></td></tr>"
			dat += "<tr width=10% style='vertical-align:top;'><td width=15%><b>Name</b></td>"
			dat += "<td style='vertical-align:top'><b>Cost</b></td>"
			dat += "<td width=10%><font size=2><b>Restrictions</b></font></td>"
			dat += "<td width=80%><font size=2><b>Description</b></font></td></tr>"
			for(var/j in GLOB.loadout_items[gear_tab])
				var/datum/gear/gear = GLOB.loadout_items[gear_tab][j]
				var/donoritem = gear.donoritem
				if(donoritem && !gear.donator_ckey_check(user.ckey))
					continue
				var/class_link = ""
				if(gear.type in chosen_gear)
					class_link = "style='white-space:normal;' class='linkOn' href='?_src_=prefs;preference=gear;toggle_gear_path=[html_encode(j)];toggle_gear=0'"
				else if(gear_points <= 0)
					class_link = "style='white-space:normal;' class='linkOff'"
				else if(donoritem)
					class_link = "style='white-space:normal;background:#ebc42e;' href='?_src_=prefs;preference=gear;toggle_gear_path=[html_encode(j)];toggle_gear=1'"
				else
					class_link = "style='white-space:normal;' href='?_src_=prefs;preference=gear;toggle_gear_path=[html_encode(j)];toggle_gear=1'"
				if(gear.has_colors && (gear.name in color_gear))
					var/colore = "<a href='?_src_=prefs;preference=gear;toggle_gear_path=[html_encode(j)];toggle_gear=color'>Color</a><span style='border: 1px solid #161616; background-color: [color_gear[gear.name]];'>&nbsp;&nbsp;&nbsp;</span>"
					dat += "<tr style='vertical-align:top;'><td width=15%><a [class_link]>[j]</a>[colore]</td>"
				else
					dat += "<tr style='vertical-align:top;'><td width=15%><a [class_link]>[j]</a></td>"
				dat += "<td width = 5% style='vertical-align:top'>[gear.cost]</td><td>"
				if(islist(gear.restricted_roles))
					if(gear.restricted_roles.len)
						if(gear.restricted_desc)
							dat += "<font size=2>"
							dat += gear.restricted_desc
							dat += "</font>"
						else
							dat += "<font size=2>"
							dat += gear.restricted_roles.Join(";")
							dat += "</font>"
				dat += "</td><td><font size=2><i>[gear.description]</i></font></td></tr>"
			dat += "</table>"

		if(4) // Keybindings
			dat += "<b>Keybindings:</b> <a href='?_src_=prefs;preference=hotkeys'>[(hotkeys) ? "Hotkeys" : "Input"]</a><br>"
			dat += "Keybindings mode controls how the game behaves with tab and map/input focus.<br>If it is on <b>Hotkeys</b>, the game will always attempt to force you to map focus, meaning keypresses are sent \
			directly to the map instead of the input. You will still be able to use the command bar, but you need to tab to do it every time you click on the game map.<br>\
			If it is on <b>Input</b>, the game will not force focus away from the input bar, and you can switch focus using TAB between these two modes: If the input bar is pink, that means that you are in non-hotkey mode, sending all keypresses of the normal \
			alphanumeric characters, punctuation, spacebar, backspace, enter, etc, typing keys into the input bar. If the input bar is white, you are in hotkey mode, meaning all keypresses go into the game's keybind handling system unless you \
			manually click on the input bar to shift focus there.<br>\
			Input mode is the closest thing to the old input system.<br>\
			<b>IMPORTANT:</b> While in input mode's non hotkey setting (tab toggled), Ctrl + KEY will send KEY to the keybind system as the key itself, not as Ctrl + KEY. This means Ctrl + T/W/A/S/D/all your familiar stuff still works, but you \
			won't be able to access any regular Ctrl binds.<br>"
			dat += "<br><b>Modifier-Independent binding</b> - This is a singular bind that works regardless of if Ctrl/Shift/Alt are held down. For example, if combat mode is bound to C in modifier-independent binds, it'll trigger regardless of if you are \
			holding down shift for sprint. <b>Each keybind can only have one independent binding, and each key can only have one keybind independently bound to it.</b>"
			// Create an inverted list of keybindings -> key
			var/list/user_binds = list()
			var/list/user_modless_binds = list()
			for (var/key in key_bindings)
				for(var/kb_name in key_bindings[key])
					user_binds[kb_name] += list(key)
			for (var/key in modless_key_bindings)
				user_modless_binds[modless_key_bindings[key]] = key

			var/list/kb_categories = list()
			// Group keybinds by category
			for (var/name in GLOB.keybindings_by_name)
				var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
				kb_categories[kb.category] += list(kb)

			dat += {"
			<style>
			span.bindname { display: inline-block; position: absolute; width: 20% ; left: 5px; padding: 5px; } \
			span.bindings { display: inline-block; position: relative; width: auto; left: 20%; width: auto; right: 20%; padding: 5px; } \
			span.independent { display: inline-block; position: absolute; width: 20%; right: 5px; padding: 5px; } \
			</style><body>
			"}

			for (var/category in kb_categories)
				dat += "<h3>[category]</h3>"
				for (var/i in kb_categories[category])
					var/datum/keybinding/kb = i
					var/current_independent_binding = user_modless_binds[kb.name] || "Unbound"
					if(!length(user_binds[kb.name]))
						dat += "<span class='bindname'>[kb.full_name]</span><span class='bindings'><a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=["Unbound"]'>Unbound</a>"
						var/list/default_keys = hotkeys ? kb.hotkey_keys : kb.classic_keys
						if(LAZYLEN(default_keys))
							dat += "| Default: [default_keys.Join(", ")]"
						dat += "</span><span class='independent'>Independent Binding: <a href='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[current_independent_binding];independent=1'>[current_independent_binding]</a></span>"
						dat += "<br>"
					else
						var/bound_key = user_binds[kb.name][1]
						dat += "<span class='bindname'l>[kb.full_name]</span><span class='bindings'><a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
						for(var/bound_key_index in 2 to length(user_binds[kb.name]))
							bound_key = user_binds[kb.name][bound_key_index]
							dat += " | <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[bound_key]</a>"
						if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
							dat += "| <a href ='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name]'>Add Secondary</a>"
						var/list/default_keys = hotkeys ? kb.classic_keys : kb.hotkey_keys
						if(LAZYLEN(default_keys))
							dat += "| Default: [default_keys.Join(", ")]"
						dat += "</span><span class='independent'>Independent Binding: <a href='?_src_=prefs;preference=keybindings_capture;keybinding=[kb.name];old_key=[current_independent_binding];independent=1'>[current_independent_binding]</a></span>"
						dat += "<br>"

			dat += "<br><br>"
			dat += "<a href ='?_src_=prefs;preference=keybindings_reset'>\[Reset to default\]</a>"
			dat += "</body>"


	dat += "<hr><center>"

	if(!IsGuestKey(user.key))
		dat += "<a href='?_src_=prefs;preference=load'>Undo</a> "
		dat += "<a href='?_src_=prefs;preference=save'>Save Setup</a> "

	dat += "<a href='?_src_=prefs;preference=reset_all'>Reset Setup</a>"
	dat += "</center>"

	winshow(user, "preferences_window", TRUE)
	var/datum/browser/popup = new(user, "preferences_browser", "<div align='center'>Character Setup</div>", 600, 700)
	popup.set_window_options("can_close=0;can_minimize=0;can_maximize=0;titlebar=1;statusbar=0")
	popup.set_content(dat.Join())
	popup.open(FALSE)

#undef APPEARANCE_CATEGORY_COLUMN
#undef MAX_MUTANT_ROWS

/datum/preferences/proc/CaptureKeybinding(mob/user, datum/keybinding/kb, old_key, independent = FALSE)
	var/HTML = {"
	<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [kb.full_name]<br>[kb.description]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
	<script>
	var deedDone = false;
	document.onkeyup = function(e) {
		if(deedDone){ return; }
		var alt = e.altKey ? 1 : 0;
		var ctrl = e.ctrlKey ? 1 : 0;
		var shift = e.shiftKey ? 1 : 0;
		var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
		var escPressed = e.keyCode == 27 ? 1 : 0;
		var url = 'byond://?_src_=prefs;preference=keybindings_set;keybinding=[kb.name];old_key=[old_key];[independent?"independent=1":""];clear_key='+escPressed+';key='+e.key+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
		window.location=url;
		deedDone = true;
	}
	document.getElementById('focus').focus();
	</script>
	"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)

/datum/preferences/proc/SetChoices(mob/user, limit = 17, list/splitJobs = list("Senior Engineer"), widthPerColumn = 295, height = 620)
	if(!SSjob)
		return

	//limit - The amount of jobs allowed per column. Defaults to 17 to make it look nice.
	//splitJobs - Allows you split the table by job. You can make different tables for each department by including their heads. Defaults to CE to make it look nice.
	//widthPerColumn - Screen's width for every column.
	//height - Screen's height.

	var/width = widthPerColumn

	var/HTML = "<center>"
	if(SSjob.occupations.len <= 0)
		HTML += "The job SSticker is not yet finished creating jobs, please try again later"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.

	else
		HTML += "<b>Choose occupation chances</b><br>"
		HTML += "<div align='center'>Left-click to raise an occupation preference, right-click to lower it.<br></div>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=close'>Done</a></center><br>" // Easier to press up here.
		HTML += "<script type='text/javascript'>function setJobPrefRedirect(level, rank) { window.location.href='?_src_=prefs;preference=job;task=setJobLevel;level=' + level + ';text=' + encodeURIComponent(rank); return false; }</script>"
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'><tr><td width='20%'>" // Table within a table for alignment, also allows you to easily add more colomns.
		HTML += "<table width='100%' cellpadding='1' cellspacing='0'>"
		var/index = -1

		//The job before the current job. I only use this to get the previous jobs color when I'm filling in blank rows.
		var/datum/job/lastJob

		for(var/datum/job/job in sortList(SSjob.occupations, /proc/cmp_job_display_asc))
			if(!job.total_positions && !job.spawn_positions && !job.current_positions)
				continue
			index += 1
			if((index >= limit) || (job.title in splitJobs))
				width += widthPerColumn
				if((index < limit) && (lastJob != null))
					//If the cells were broken up by a job in the splitJob list then it will fill in the rest of the cells with
					//the last job's selection color. Creating a rather nice effect.
					for(var/i = 0, i < (limit - index), i += 1)
						HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"
				HTML += "</table></td><td width='20%'><table width='100%' cellpadding='1' cellspacing='0'>"
				index = 0

			HTML += "<tr bgcolor='[job.selection_color]'><td width='60%' align='right'>"
			var/rank = job.title
			var/displayed_rank = rank
			if(job.alt_titles.len && (rank in alt_titles_preferences))
				displayed_rank = alt_titles_preferences[rank]
			lastJob = job
			if(jobban_isbanned(user, rank))
				HTML += "<font color=red>[rank]</font></td><td><a href='?_src_=prefs;bancheck=[rank]'> BANNED</a></td></tr>"
				continue
			if(!job.is_whitelisted(parent))
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[ NOT WHITELISTED \] </font></td></tr>"
				continue
			var/required_playtime_remaining = job.required_playtime_remaining(user.client)
			if(required_playtime_remaining)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[ [get_exp_format(required_playtime_remaining)] as [job.get_exp_req_type()] \] </font></td></tr>"
				continue
			if(!job.player_old_enough(user.client))
				var/available_in_days = job.available_in_days(user.client)
				HTML += "<font color=red>[rank]</font></td><td><font color=red> \[IN [(available_in_days)] DAYS\]</font></td></tr>"
				continue
			if(!user.client.prefs.pref_species.qualifies_for_rank(rank, user.client.prefs.features))
				if(user.client.prefs.pref_species.id == "human")
					HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[MUTANT\]</b></font></td></tr>"
				else
					HTML += "<font color=red>[rank]</font></td><td><font color=red><b> \[NON-HUMAN\]</b></font></td></tr>"
				continue
			if((job_preferences["[SSjob.overflow_role]"] == JP_LOW) && (rank != SSjob.overflow_role) && !jobban_isbanned(user, SSjob.overflow_role))
				HTML += "<font color=orange>[rank]</font></td><td></td></tr>"
				continue
			var/rank_title_line = "[displayed_rank]"
			if((rank in GLOB.command_positions) || (rank == "AI"))//Bold head jobs
				rank_title_line = "<b>[rank_title_line]</b>"
			if(job.alt_titles.len)
				rank_title_line = "<a href='?_src_=prefs;preference=job;task=alt_title;job_title=[job.title]'>[rank_title_line]</a>"
			else
				rank_title_line = "<span class='dark'>[rank_title_line]</span>" //Make it dark if we're not adding a button for alt titles
			HTML += rank_title_line

			HTML += "</td><td width='40%'>"

			var/prefLevelLabel = "ERROR"
			var/prefLevelColor = "pink"
			var/prefUpperLevel = -1 // level to assign on left click
			var/prefLowerLevel = -1 // level to assign on right click

			switch(job_preferences["[job.title]"])
				if(JP_HIGH)
					prefLevelLabel = "High"
					prefLevelColor = "slateblue"
					prefUpperLevel = 4
					prefLowerLevel = 2
				if(JP_MEDIUM)
					prefLevelLabel = "Medium"
					prefLevelColor = "green"
					prefUpperLevel = 1
					prefLowerLevel = 3
				if(JP_LOW)
					prefLevelLabel = "Low"
					prefLevelColor = "orange"
					prefUpperLevel = 2
					prefLowerLevel = 4
				else
					prefLevelLabel = "NEVER"
					prefLevelColor = "red"
					prefUpperLevel = 3
					prefLowerLevel = 1

			HTML += "<a class='white' href='?_src_=prefs;preference=job;task=setJobLevel;level=[prefUpperLevel];text=[rank]' oncontextmenu='javascript:return setJobPrefRedirect([prefLowerLevel], \"[rank]\");'>"

			if(rank == SSjob.overflow_role)//Overflow is special
				if(job_preferences["[SSjob.overflow_role]"] == JP_LOW)
					HTML += "<font color=green>Yes</font>"
				else
					HTML += "<font color=red>No</font>"
				HTML += "</a></td></tr>"
				continue

			HTML += "<font color=[prefLevelColor]>[prefLevelLabel]</font>"
			HTML += "</a></td></tr>"

		for(var/i = 1, i < (limit - index), i += 1) // Finish the column so it is even
			HTML += "<tr bgcolor='[lastJob.selection_color]'><td width='60%' align='right'>&nbsp</td><td>&nbsp</td></tr>"

		HTML += "</td'></tr></table>"
		HTML += "</center></table>"

		var/message = "Be an [SSjob.overflow_role] if preferences unavailable"
		if(joblessrole == BERANDOMJOB)
			message = "Get random job if preferences unavailable"
		else if(joblessrole == RETURNTOLOBBY)
			message = "Return to lobby if preferences unavailable"
		HTML += "<center><br><a href='?_src_=prefs;preference=job;task=random'>[message]</a></center>"
		HTML += "<center><a href='?_src_=prefs;preference=job;task=reset'>Reset Preferences</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Occupation Preferences</div>", width, height)
	popup.set_window_options("can_close=0")
	popup.set_content(HTML)
	popup.open(FALSE)

/datum/preferences/proc/SetJobPreferenceLevel(datum/job/job, level)
	if (!job)
		return FALSE

	if (level == JP_HIGH) // to high
		//Set all other high to medium
		for(var/j in job_preferences)
			if(job_preferences["[j]"] == JP_HIGH)
				job_preferences["[j]"] = JP_MEDIUM
				//technically break here

	job_preferences["[job.title]"] = level
	return TRUE

/datum/preferences/proc/UpdateJobPreference(mob/user, role, desiredLvl)
	if(!SSjob || SSjob.occupations.len <= 0)
		return
	var/datum/job/job = SSjob.GetJob(role)

	if(!job)
		user << browse(null, "window=mob_occupation")
		ShowChoices(user)
		return

	if (!isnum(desiredLvl))
		to_chat(user, "<span class='danger'>UpdateJobPreference - desired level was not a number. Please notify coders!</span>")
		ShowChoices(user)
		return

	var/jpval = null
	switch(desiredLvl)
		if(3)
			jpval = JP_LOW
		if(2)
			jpval = JP_MEDIUM
		if(1)
			jpval = JP_HIGH

	if(role == SSjob.overflow_role)
		if(job_preferences["[job.title]"] == JP_LOW)
			jpval = null
		else
			jpval = JP_LOW

	SetJobPreferenceLevel(job, jpval)
	SetChoices(user)

	return 1


/datum/preferences/proc/ResetJobs()
	job_preferences = list()

/datum/preferences/proc/SetLanguage(mob/user)
	var/list/dat = list()
	dat += "<center><b>Choose an Additional Language</b></center><br>"
	dat += "<center>Do note, however, than you can only have one chosen language.</center><br>"
	dat += "<center>If you want no additional language at all, simply remove the currently chosen language.</center><br>"
	dat += "<hr>"
	if(SSlanguage && SSlanguage.languages_by_name.len)
		for(var/V in SSlanguage.languages_by_name)
			var/datum/language/L = SSlanguage.languages_by_name[V]
			if(!L)
				return
			var/language_name = initial(L.name)
			var/restricted = FALSE
			var/has_language = FALSE
			if(L.restricted)
				restricted = TRUE
			if(language_name == language)
				has_language = TRUE
			var/font_color = "#4682B4"
			var/nullify = ""
			if(restricted && !(language_name in pref_species.languagewhitelist))
				continue
			dat += "<b><font color='[font_color]'>[language_name]:</font></b> [initial(L.desc)]"
			dat += "<a href='?_src_=prefs;preference=language;task=update;language=[has_language ? nullify : language_name]'>[has_language ? "Remove" : "Choose"]</a><br>"
	else
		dat += "<center><b>The language subsystem hasn't fully loaded yet! Please wait a bit and try again.</b></center><br>"
	dat += "<hr>"
	dat += "<center><a href='?_src_=prefs;preference=language;task=close'>Done</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Language Preference</div>", 900, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_window_options("can_close=0")
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/SetFood(mob/user)
	var/list/dat = list()
	dat += "<center><b>Choose food setup</b></center><br>"
	dat += "<div align='center'>Click on \"like\" to add a food type to your likings. Click on \"dislike\" to add it to your dislikings.<br>"
	dat += "Food types cannot be liked and disliked at the same time.<br>"
	dat += "If a food type is already liked or disliked, simply click the appropriate button again to remove it from your like or dislike list.<br>"
	dat += "Having no food preferences means you'll just default your species' standard instead.</div><br>"
	dat += "<center><a href='?_src_=prefs;preference=food;task=close'>Done</a></center>"
	dat += "<hr>"
	dat += "<center><b>Current Likings:</b> [foodlikes.len ? foodlikes.Join(", ") : "None"] ([foodlikes.len]/[maxlikes])</center><br>"
	dat += "<center><b>Current Dislikings:</b> [fooddislikes.len ? fooddislikes.Join(", ") : "None"] ([fooddislikes.len]/[maxdislikes])</center>"
	dat += "<hr>"
	for(var/F in GLOB.food)
		var/likes = FALSE
		var/dislikes = FALSE
		for(var/food in foodlikes)
			if(food == F)
				likes = TRUE
		for(var/food in fooddislikes)
			if(food == F)
				dislikes = TRUE
		var/font_color = "#8686ff"
		if(likes)
			dat += "<center><p style='color: [font_color];'><b>[F]: </p></b>"
			dat += "<a style='background-color: #32c232;' href='?_src_=prefs;preference=food;task=update;like=[F]'>Like</a>"
			dat += "<a href='?_src_=prefs;preference=food;task=update;dislike=[F]'>Dislike</a></center>"
		else if(dislikes)
			dat += "<center><p style='color: [font_color];'><b>[F]: </p></b>"
			dat += "<a href='?_src_=prefs;preference=food;task=update;like=[F]'>Like</a>"
			dat += "<a style='background-color: #ff1a1a;' href='?_src_=prefs;preference=food;task=update;dislike=[F]'>Dislike</a></center>"
		else
			dat += "<center><p style='color: [font_color];'><b>[F]: </p></b>"
			dat += "<a href='?_src_=prefs;preference=food;task=update;like=[F]'>Like</a>"
			dat += "<a href='?_src_=prefs;preference=food;task=update;dislike=[F]'>Dislike</a></center>"
	dat += "<br><center><a href='?_src_=prefs;preference=food;task=reset'>Reset Food Preferences</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Food Preferences</div>", 900, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_window_options("can_close=0")
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/proc/SetSpecies(mob/user)
	var/list/dat = list()
	dat += "<center><h2>Choose a species</h2></center>"
	dat += "<center><a href='?_src_=prefs;preference=language;task=close'>Done</a></center>"
	dat += "<hr>"
	for(var/name in GLOB.roundstart_race_names)
		var/selected = FALSE
		var/id = GLOB.roundstart_race_names[name]
		var/datum/species/S = GLOB.roundstart_race_datums[id]
		if(!S)
			return
		if(pref_species.type == S.type)
			selected = TRUE
		var/font_color = "#4682B4"
		dat += "<div style='padding-top:5px;padding-bottom:5px;'>"
		dat += "<b><font color='[font_color]'>[name]:</font></b>"
		dat += "<br>"
		dat += "[initial(S.fluff_desc)]"
		dat += "<br>"
		dat += "<a [selected ? "style='background-color: #32c232;'" : ""] href='?_src_=prefs;preference=species;task=update;species=[id]'>[selected ? "Chosen" : "Choose"]</a><br>"
		dat += "</div>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Species Preference</div>", 900, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_window_options("can_close=0")
	popup.set_content(dat.Join())
	popup.open(FALSE)

/datum/preferences/Topic(href, href_list, hsrc)			//yeah, gotta do this I guess..
	. = ..()
	if(href_list["close"])
		var/client/C = usr.client
		if(C)
			C.clear_character_previews()

/datum/preferences/proc/process_link(mob/user, list/href_list)
	if(href_list["close_setup"])
		user << browse(null, "window=preferences_window") //closes char setup window
		user << browse(null, "window=preferences_browser") //closes char setup window
		return TRUE
	
	if(href_list["jobbancheck"])
		var/job = sanitizeSQL(href_list["jobbancheck"])
		var/sql_ckey = sanitizeSQL(user.ckey)
		var/datum/DBQuery/query_get_jobban = SSdbcore.NewQuery("SELECT reason, bantime, duration, expiration_time, IFNULL((SELECT byond_key FROM [format_table_name("player")] WHERE [format_table_name("player")].ckey = [format_table_name("ban")].a_ckey), a_ckey) FROM [format_table_name("ban")] WHERE ckey = '[sql_ckey]' AND (bantype = 'JOB_PERMABAN'  OR (bantype = 'JOB_TEMPBAN' AND expiration_time > Now())) AND isnull(unbanned) AND job = '[job]'")
		if(!query_get_jobban.warn_execute())
			qdel(query_get_jobban)
			return
		if(query_get_jobban.NextRow())
			var/reason = query_get_jobban.item[1]
			var/bantime = query_get_jobban.item[2]
			var/duration = query_get_jobban.item[3]
			var/expiration_time = query_get_jobban.item[4]
			var/admin_key = query_get_jobban.item[5]
			var/text
			text = "<span class='redtext'>You, or another user of this computer, ([user.key]) is banned from playing [job]. The ban reason is:<br>[reason]<br>This ban was applied by [admin_key] on [bantime]"
			if(text2num(duration) > 0)
				text += ". The ban is for [duration] minutes and expires on [expiration_time] (server time)"
			text += ".</span>"
			to_chat(user, text)
		qdel(query_get_jobban)
		return

	if(href_list["preference"] == "descriptors")
		var/desc_id = href_list["change_descriptor"]
		if(desc_id)
			if(LAZYLEN(pref_species.descriptors) && pref_species.descriptors[desc_id])
				var/datum/mob_descriptor/descriptor = pref_species.descriptors[desc_id]
				var/choice = input("Please select a descriptor", "Descriptor") as null|anything in descriptor.chargen_value_descriptors
				if(choice && pref_species.descriptors[desc_id]) // Check in case they sneakily changed species.
					body_descriptors[descriptor.name] = descriptor.chargen_value_descriptors[choice]
		ShowChoices(user)
		return 1

	else if(href_list["preference"] == "job")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("reset")
				ResetJobs()
				SetChoices(user)
			if("random")
				switch(joblessrole)
					if(RETURNTOLOBBY)
						if(jobban_isbanned(user, SSjob.overflow_role))
							joblessrole = BERANDOMJOB
						else
							joblessrole = BEOVERFLOW
					if(BEOVERFLOW)
						joblessrole = BERANDOMJOB
					if(BERANDOMJOB)
						joblessrole = RETURNTOLOBBY
				SetChoices(user)
			if("setJobLevel")
				UpdateJobPreference(user, href_list["text"], text2num(href_list["level"]))
			if("alt_title")
				var/job_title = href_list["job_title"]
				var/titles_list = list(job_title)
				var/datum/job/J = SSjob.GetJob(job_title)
				for(var/i in J.alt_titles)
					titles_list += i
				var/chosen_title
				chosen_title = input(user, "Choose your job's title:", "Job Preference") as null|anything in titles_list
				if(chosen_title)
					if(chosen_title == job_title)
						if(alt_titles_preferences[job_title])
							alt_titles_preferences.Remove(job_title)
					else
						alt_titles_preferences[job_title] = chosen_title
				SetChoices(user)
			else
				SetChoices(user)
		return 1

	else if(href_list["preference"] == "species")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("update")
				var/id = href_list["species"]
				if(id && (id != pref_species.id))
					var/newtype = GLOB.species_list[id]
					pref_species = new newtype()
					//let's ensure that no weird shit happens on species swapping.
					custom_species = null
					if(!pref_species.mutant_bodyparts["body_markings"])
						features["body_markings"] = "None"
					if(!pref_species.mutant_bodyparts["mam_body_markings"])
						features["mam_body_markings"] = "None"
					if(pref_species.mutant_bodyparts["mam_body_markings"])
						if(features["mam_body_markings"] == "None")
							features["mam_body_markings"] = "Plain"
					if(pref_species.mutant_bodyparts["tail_lizard"])
						features["tail_lizard"] = "Smooth"
					if(pref_species.id == "felinid")
						features["mam_tail"] = "Cat"
						features["mam_ears"] = "Cat"
					//Now that we changed our species, we must verify that the mutant colour is still allowed.
					if(features["mcolor"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits)))
						features["mcolor"] = pref_species.default_color
					if(features["mcolor2"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits)))
						features["mcolor2"] = pref_species.default_color
					if(features["mcolor3"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits)))
						features["mcolor3"] = pref_species.default_color
					language = initial(language)
					bloodtype = initial(bloodtype)
					body_descriptors = list()
					for(var/i in pref_species.descriptors)
						var/datum/mob_descriptor/md = pref_species.descriptors[i]
						body_descriptors[i] = md.current_value
					features["genitals_use_skintone"] = (pref_species?.use_skintones ? TRUE : FALSE)
				SetSpecies(user)
			else
				SetSpecies(user)
		return TRUE

	else if(href_list["preference"] == "trait")
		special_char = !special_char
		to_chat(user, "<span class='notice'>Your character [special_char ? "will " : "won't"] be special.</span>")
		save_character()
		var/mob/dead/new_player/NP = user
		if(istype(NP))
			NP << browse(null, "window=playersetup") //closes the player setup window
			NP.new_player_panel()
		return TRUE
	else if(href_list["preference"] == "food")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("update")
				if(href_list["like"])
					for(var/F in GLOB.food)
						if(F == href_list["like"])
							if(!foodlikes[F])
								if(foodlikes.len < maxlikes)
									foodlikes[F] = GLOB.food[F]
								if(fooddislikes[F])
									fooddislikes.Remove(F)
							else
								foodlikes.Remove(F)
				if(href_list["dislike"])
					for(var/F in GLOB.food)
						if(F == href_list["dislike"])
							if(!fooddislikes[F])
								if(fooddislikes.len < maxdislikes)
									fooddislikes[F] = GLOB.food[F]
								if(foodlikes[F])
									foodlikes.Remove(F)
							else
								fooddislikes.Remove(F)
				if(foodlikes.len > maxlikes)
					foodlikes.Cut(maxlikes+1)
				if(fooddislikes.len > maxdislikes)
					foodlikes.Cut(maxdislikes+1)
				SetFood(user)
			if("reset")
				foodlikes = list()
				fooddislikes = list()
				SetFood(user)
			else
				SetFood(user)
		return TRUE
	else if(href_list["preference"] == "augments")
		var/input = input(user, "What do you wish to augment?", "Cyberpunk 2077", null) as null|anything in list("Limb", "Organ")
		if(input == "Limb")
			var/list/refined_limbs = list()
			for(var/a in ALL_BODYPARTS)
				refined_limbs[parse_zone(a)] = a
			input = input(user, "What limb?", "Cyberpunk 2077", null) as null|anything in refined_limbs
			if(input)
				var/list/augment_options = list()
				for(var/a in GLOB.augment_datums)
					var/datum/augment/augment = a
					if(augment.limb && augment.slot == refined_limbs[input])
						augment_options[augment.name] = augment
				var/newinput = input(user, "What augment?", "Cyberpunk 2077", null) as null|anything in (augment_options + "None")
				if(newinput && newinput != "None")
					var/datum/augment/chosen = augment_options[newinput]
					if(chosen)
						chosen.add_to_prefs(user, src)
				else if(newinput == "None")
					if(!length(limb_augments[refined_limbs[input]]))
						ShowChoices(user)
						return TRUE
					var/datum/augment/augment = limb_augments[refined_limbs[input]][2]
					augment.remove_from_prefs(user, src)
		else if(input == "Organ")
			var/list/organs = list()
			for(var/a in GLOB.augment_datums)
				var/datum/augment/augment = a
				if(!augment.limb)
					organs |= augment.slot
			input = input(user, "What organ?", "Cyberpunk 2077", null) as null|anything in organs
			if(input)
				var/list/augment_options = list()
				for(var/a in GLOB.augment_datums)
					var/datum/augment/augment = a
					if(!augment.limb && augment.slot == input)
						augment_options[augment.name] = augment
				var/newinput = input(user, "What augment?", "Cyberpunk 2077", null) as null|anything in (augment_options + "None")
				if(newinput && newinput != "None")
					var/datum/augment/chosen = augment_options[newinput]
					if(chosen)
						chosen.add_to_prefs(user, src)
				else if(newinput == "None")
					if(!length(organ_augments[input]))
						ShowChoices(user)
						return TRUE
					var/datum/augment/augment = organ_augments[input][2]
					augment.remove_from_prefs(user, src)
		ShowChoices(user)
		return TRUE
	else if(href_list["preference"] == "language")
		switch(href_list["task"])
			if("close")
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			if("update")
				var/lang = href_list["language"]
				if(SSlanguage.languages_by_name[lang] || lang == "")
					language = lang
					SetLanguage(user)
				else
					SetLanguage(user)
			else
				SetLanguage(user)
		return TRUE
	switch(href_list["task"])
		if("random")
			switch(href_list["preference"])
				if("name")
					real_name = pref_species.random_name(gender,1)
				if("age")
					age = rand(AGE_MIN, AGE_MAX)
				if("hair")
					hair_color = sanitize_hexcolor(random_color())
				if("hair_style")
					hair_style = random_hair_style(gender)
				if("facial")
					facial_hair_color = sanitize_hexcolor(random_color())
				if("facial_hair_style")
					facial_hair_style = random_facial_hair_style(gender)
				if("left_eye")
					left_eye_color = random_eye_color()
				if("right_eye")
					right_eye_color = random_eye_color()
				if("s_tone")
					skin_tone = random_skin_tone()
					use_custom_skin_tone = null
				if("bag")
					backbag = pick(GLOB.backbaglist)
				if("all")
					random_character()
		if("input")

			if(href_list["preference"] in GLOB.preferences_custom_names)
				ask_for_custom_name(user,href_list["preference"])

			switch(href_list["preference"])
				if("ghostform")
					if(unlock_content)
						var/new_form = input(user, "Thanks for supporting BYOND - Choose your ghostly form:","Thanks for supporting BYOND",null) as null|anything in GLOB.ghost_forms
						if(new_form)
							ghost_form = new_form
				if("ghostorbit")
					if(unlock_content)
						var/new_orbit = input(user, "Thanks for supporting BYOND - Choose your ghostly orbit:","Thanks for supporting BYOND", null) as null|anything in GLOB.ghost_orbits
						if(new_orbit)
							ghost_orbit = new_orbit

				if("ghostaccs")
					var/new_ghost_accs = alert("Do you want your ghost to show full accessories where possible, hide accessories but still use the directional sprites where possible, or also ignore the directions and stick to the default sprites?",,GHOST_ACCS_FULL_NAME, GHOST_ACCS_DIR_NAME, GHOST_ACCS_NONE_NAME)
					switch(new_ghost_accs)
						if(GHOST_ACCS_FULL_NAME)
							ghost_accs = GHOST_ACCS_FULL
						if(GHOST_ACCS_DIR_NAME)
							ghost_accs = GHOST_ACCS_DIR
						if(GHOST_ACCS_NONE_NAME)
							ghost_accs = GHOST_ACCS_NONE

				if("ghostothers")
					var/new_ghost_others = alert("Do you want the ghosts of others to show up as their own setting, as their default sprites or always as the default white ghost?",,GHOST_OTHERS_THEIR_SETTING_NAME, GHOST_OTHERS_DEFAULT_SPRITE_NAME, GHOST_OTHERS_SIMPLE_NAME)
					switch(new_ghost_others)
						if(GHOST_OTHERS_THEIR_SETTING_NAME)
							ghost_others = GHOST_OTHERS_THEIR_SETTING
						if(GHOST_OTHERS_DEFAULT_SPRITE_NAME)
							ghost_others = GHOST_OTHERS_DEFAULT_SPRITE
						if(GHOST_OTHERS_SIMPLE_NAME)
							ghost_others = GHOST_OTHERS_SIMPLE

				if("name")
					var/new_name = input(user, "Choose your character's name:", "Character Preference")  as text|null
					if(new_name)
						new_name = reject_bad_name(new_name)
						if(new_name)
							real_name = new_name
						else
							to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z, -, ' and .</font>")

				if("age")
					var/new_age = input(user, "Choose your character's age:\n([AGE_MIN]-[AGE_MAX])", "Character Preference") as num|null
					if(new_age)
						age = max(min( round(text2num(new_age)), AGE_MAX),AGE_MIN)

				if("bloodtype")
					var/msg = input(usr, "Choose your blood type", "Blood Type", "") as anything in (pref_species.bloodtypes + "Default")
					if(msg)
						if(msg == "Default")
							bloodtype = ""
						else
							bloodtype = msg

				if("bloodreagent")
					var/msg = input(usr, "Choose your blood reagent", "Blood Reagent", "") as anything in (pref_species.bloodreagents + "Default")
					if(msg)
						if(msg == "Default")
							bloodreagent = ""
						else
							bloodreagent = msg

				if("bloodcolor")
					var/msg = input(usr, "Choose your blood color", "Blood Color", "") as color|null
					if(msg)
						bloodcolor = msg
					else
						bloodcolor = ""

				if("general_records")
					var/msg = input(usr, "Set your general records", "General Records", general_records) as message|null
					if(msg)
						general_records = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)

				if("security_records")
					var/msg = input(usr, "Set your security records", "Security Records", security_records) as message|null
					if(msg)
						security_records = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)

				if("medical_records")
					var/msg = input(usr, "Set your medical records", "Medical Records", medical_records) as message|null
					if(msg)
						medical_records = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)

				if("flavor_background")
					var/msg = input(usr, "Set your background", "Character Background", flavor_background) as message|null
					if(msg)
						flavor_background = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)

				if("flavor_faction")
					var/new_faction = input(user, "Set your faction", "Character Faction") as null|anything in GLOB.factions_list
					if(new_faction)
						flavor_faction = new_faction

				if("corporate_relations")
					var/new_faction = input(user, "Set your corporate relations", "Character Support") as null|anything in list("Loyal", "Supportive", "Neutral", "Skeptical", "Opposed")
					if(new_faction)
						corporate_relations = new_faction

				if("character_skills")
					var/msg = input(usr, "Set your skills or hobbies", "Character Skills", character_skills) as message|null
					if(msg)
						character_skills = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)

				if("exploitable_info")
					var/msg = input(usr, "Set your exploitable information, this rarely will be showed to antagonists", "Exploitable Info", exploitable_info) as message|null
					if(msg)
						exploitable_info = strip_html_simple(msg, MAX_FLAVOR_LEN, TRUE)
				if("hair")
					var/new_hair = input(user, "Choose your character's hair colour:", "Character Preference", hair_color) as color|null
					if(new_hair)
						hair_color = sanitize_hexcolor(new_hair)

				if("hair_style")
					var/new_hair_style
					new_hair_style = input(user, "Choose your character's hair style:", "Character Preference")  as null|anything in GLOB.hair_styles_list
					if(new_hair_style)
						hair_style = new_hair_style

				if("next_hair_style")
					hair_style = next_list_item(hair_style, GLOB.hair_styles_list)

				if("previous_hair_style")
					hair_style = previous_list_item(hair_style, GLOB.hair_styles_list)

				if("facial")
					var/new_facial = input(user, "Choose your character's facial-hair colour:", "Character Preference", facial_hair_color) as color|null
					if(new_facial)
						facial_hair_color = sanitize_hexcolor(new_facial)

				if("facial_hair_style")
					var/new_facial_hair_style
					new_facial_hair_style = input(user, "Choose your character's facial-hair style:", "Character Preference")  as null|anything in GLOB.facial_hair_styles_list
					if(new_facial_hair_style)
						facial_hair_style = new_facial_hair_style

				if("next_facehair_style")
					facial_hair_style = next_list_item(facial_hair_style, GLOB.facial_hair_styles_list)

				if("previous_facehair_style")
					facial_hair_style = previous_list_item(facial_hair_style, GLOB.facial_hair_styles_list)

				if("cycle_bg")
					bgstate = next_list_item(bgstate, bgstate_options)

				if("left_eye")
					var/new_eyes = input(user, "Choose your character's left eye colour:", "Character Preference", left_eye_color) as color|null
					if(new_eyes)
						left_eye_color = sanitize_hexcolor(new_eyes)

				if("right_eye")
					var/new_eyes = input(user, "Choose your character's right eye colour:", "Character Preference", right_eye_color) as color|null
					if(new_eyes)
						right_eye_color = sanitize_hexcolor(new_eyes)

				if("species")
					var/result = input(user, "Select a species", "Species Selection") as null|anything in GLOB.roundstart_race_names
					if(result)
						var/newtype = GLOB.species_list[GLOB.roundstart_race_names[result]]
						pref_species = new newtype()
						//let's ensure that no weird shit happens on species swapping.
						custom_species = null
						if(!pref_species.mutant_bodyparts["body_markings"])
							features["body_markings"] = "None"
						if(!pref_species.mutant_bodyparts["mam_body_markings"])
							features["mam_body_markings"] = "None"
						if(pref_species.mutant_bodyparts["mam_body_markings"])
							if(features["mam_body_markings"] == "None")
								features["mam_body_markings"] = "Plain"
						if(pref_species.mutant_bodyparts["tail_lizard"])
							features["tail_lizard"] = "Smooth"
						if(pref_species.id == "felinid")
							features["mam_tail"] = "Cat"
							features["mam_ears"] = "Cat"

						//Now that we changed our species, we must verify that the mutant colour is still allowed.
						if(features["mcolor"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits)))
							features["mcolor"] = pref_species.default_color
						if(features["mcolor2"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits)))
							features["mcolor2"] = pref_species.default_color
						if(features["mcolor3"] == "#000" || (!(MUTCOLORS_PARTSONLY in pref_species.species_traits)))
							features["mcolor3"] = pref_species.default_color

						language = initial(language)
						bloodtype = initial(bloodtype)
						body_descriptors = list()
						for(var/i in pref_species.descriptors)
							var/datum/mob_descriptor/md = pref_species.descriptors[i]
							body_descriptors[i] = md.current_value
						features["genitals_use_skintone"] = (pref_species?.use_skintones ? TRUE : FALSE)

				if("custom_species")
					var/new_species = reject_bad_name(input(user, "Choose your species subtype, if unique. This will show up on examinations and health scans. Do not abuse this:", "Character Preference", custom_species) as null|text)
					if(new_species)
						custom_species = new_species
					else
						custom_species = null

				if("mutant_color")
					var/new_mutantcolor = input(user, "Choose your character's alien/mutant color:", "Character Preference", features["mcolor"]) as color|null
					if(new_mutantcolor)
						features["mcolor"] = sanitize_hexcolor(new_mutantcolor)

				if("mutant_color2")
					var/new_mutantcolor = input(user, "Choose your character's secondary alien/mutant color:", "Character Preference", features["mcolor2"]) as color|null
					if(new_mutantcolor)
						features["mcolor2"] = sanitize_hexcolor(new_mutantcolor)

				if("mutant_color3")
					var/new_mutantcolor = input(user, "Choose your character's tertiary alien/mutant color:", "Character Preference", features["mcolor3"]) as color|null
					if(new_mutantcolor)
						features["mcolor3"] = sanitize_hexcolor(new_mutantcolor)

				if("mismatched_markings")
					show_mismatched_markings = !show_mismatched_markings

				if("ipc_screen")
					var/new_ipc_screen
					new_ipc_screen = input(user, "Choose your character's screen:", "Character Preference") as null|anything in GLOB.ipc_screens_list
					if(new_ipc_screen)
						features["ipc_screen"] = new_ipc_screen

				if("ipc_antenna")
					var/list/snowflake_antenna_list = list()
					//Potential todo: turn all of THIS into a define to reduce copypasta.
					for(var/path in GLOB.ipc_antennas_list)
						var/datum/sprite_accessory/antenna/instance = GLOB.ipc_antennas_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_antenna_list[S.name] = path
					var/new_ipc_antenna
					new_ipc_antenna = input(user, "Choose your character's antenna:", "Character Preference") as null|anything in snowflake_antenna_list
					if(new_ipc_antenna)
						features["ipc_antenna"] = new_ipc_antenna

				if("ipc_chassis")
					var/new_ipc_chassis
					new_ipc_chassis = input(user, "Choose your character's chassis:", "Character Preference") as null|anything in GLOB.ipc_chassis_list
					if(new_ipc_chassis)
						features["ipc_chassis"] = new_ipc_chassis

				if("tail_lizard")
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in GLOB.tails_list_lizard
					if(new_tail)
						features["tail_lizard"] = new_tail
						if(new_tail != "None")
							features["taur"] = "None"
							features["tail_human"] = "None"
							features["mam_tail"] = "None"

				if("tail_human")
					var/list/snowflake_tails_list = list()
					for(var/path in GLOB.tails_list_human)
						var/datum/sprite_accessory/tails/human/instance = GLOB.tails_list_human[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_tails_list[S.name] = path
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in snowflake_tails_list
					if(new_tail)
						features["tail_human"] = new_tail
						if(new_tail != "None")
							features["taur"] = "None"
							features["tail_lizard"] = "None"
							features["mam_tail"] = "None"

				if("mam_tail")
					var/list/snowflake_tails_list = list()
					for(var/path in GLOB.mam_tails_list)
						var/datum/sprite_accessory/mam_tails/instance = GLOB.mam_tails_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_tails_list[S.name] = path
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in snowflake_tails_list
					if(new_tail)
						features["mam_tail"] = new_tail
						if(new_tail != "None")
							features["taur"] = "None"
							features["tail_human"] = "None"
							features["tail_lizard"] = "None"

				if("meats")
					var/new_meat
					new_meat = input(user, "Choose your character's meat type:", "Character Preference") as null|anything in GLOB.meat_types
					if(new_meat)
						features["meat_type"] = new_meat

				if("snout")
					var/list/snowflake_snouts_list = list()
					for(var/path in GLOB.snouts_list)
						var/datum/sprite_accessory/mam_snouts/instance = GLOB.snouts_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_snouts_list[S.name] = path
					var/new_snout
					new_snout = input(user, "Choose your character's snout:", "Character Preference") as null|anything in snowflake_snouts_list
					if(new_snout)
						features["snout"] = new_snout
						features["mam_snouts"] = "None"


				if("mam_snouts")
					var/list/snowflake_mam_snouts_list = list()
					for(var/path in GLOB.mam_snouts_list)
						var/datum/sprite_accessory/mam_snouts/instance = GLOB.mam_snouts_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_mam_snouts_list[S.name] = path
					var/new_mam_snouts
					new_mam_snouts = input(user, "Choose your character's snout:", "Character Preference") as null|anything in snowflake_mam_snouts_list
					if(new_mam_snouts)
						features["mam_snouts"] = new_mam_snouts
						features["snout"] = "None"

				if("horns")
					var/new_horns
					new_horns = input(user, "Choose your character's horns:", "Character Preference") as null|anything in GLOB.horns_list
					if(new_horns)
						features["horns"] = new_horns

				if("horns_color")
					var/new_horn_color = input(user, "Choose your character's horn colour:", "Character Preference", features["horns_color"]) as color|null
					if(new_horn_color)
						features["horns_color"] = sanitize_hexcolor(new_horn_color)

				if("wings")
					var/new_wings
					new_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.r_wings_list
					if(new_wings)
						features["wings"] = new_wings

				if("wings_color")
					var/new_wing_color = input(user, "Choose your character's wing colour:", "Character Preference",features["wings_color"]) as color|null
					if(new_wing_color)
						features["wings_color"] = sanitize_hexcolor(new_wing_color)

				if("frills")
					var/new_frills
					new_frills = input(user, "Choose your character's frills:", "Character Preference") as null|anything in GLOB.frills_list
					if(new_frills)
						features["frills"] = new_frills

				if("spines")
					var/new_spines
					new_spines = input(user, "Choose your character's spines:", "Character Preference") as null|anything in GLOB.spines_list
					if(new_spines)
						features["spines"] = new_spines

				if("body_markings")
					var/new_body_markings
					new_body_markings = input(user, "Choose your character's body markings:", "Character Preference") as null|anything in GLOB.body_markings_list
					if(new_body_markings)
						features["body_markings"] = new_body_markings
						if(new_body_markings != "None")
							features["mam_body_markings"] = "None"

				if("legs")
					var/new_legs
					new_legs = input(user, "Choose your character's legs:", "Character Preference") as null|anything in GLOB.legs_list
					if(new_legs)
						features["legs"] = new_legs

				if("insect_wings")
					var/new_insect_wings
					new_insect_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.insect_wings_list
					if(new_insect_wings)
						features["insect_wings"] = new_insect_wings

				if("deco_wings")
					var/new_deco_wings
					new_deco_wings = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.deco_wings_list
					if(new_deco_wings)
						features["deco_wings"] = new_deco_wings

				if("insect_fluffs")
					var/new_insect_fluff
					new_insect_fluff = input(user, "Choose your character's wings:", "Character Preference") as null|anything in GLOB.insect_fluffs_list
					if(new_insect_fluff)
						features["insect_fluff"] = new_insect_fluff

				if("insect_markings")
					var/new_insect_markings
					new_insect_markings = input(user, "Choose your character's markings:", "Character Preference") as null|anything in GLOB.insect_markings_list
					if(new_insect_markings)
						features["insect_markings"] = new_insect_markings

				if("s_tone")
					var/list/choices = GLOB.skin_tones - GLOB.nonstandard_skin_tones
					if(CONFIG_GET(flag/allow_custom_skintones))
						choices += "custom"
					var/new_s_tone = input(user, "Choose your character's skin tone:", "Character Preference")  as null|anything in choices
					if(new_s_tone)
						if(new_s_tone == "custom")
							var/default = use_custom_skin_tone ? skin_tone : null
							var/custom_tone = input(user, "Choose your custom skin tone:", "Character Preference", default) as color|null
							if(custom_tone)
								use_custom_skin_tone = TRUE
								skin_tone = sanitize_hexcolor(custom_tone)
						else
							use_custom_skin_tone = FALSE
							skin_tone = new_s_tone

				if("taur")
					var/list/snowflake_taur_list = list()
					for(var/path in GLOB.taur_list)
						var/datum/sprite_accessory/taur/instance = GLOB.taur_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_taur_list[S.name] = path
					var/new_taur
					new_taur = input(user, "Choose your character's tauric body:", "Character Preference") as null|anything in snowflake_taur_list
					if(new_taur)
						features["taur"] = new_taur
						if(new_taur != "None")
							features["mam_tail"] = "None"
							features["xenotail"] = "None"
							features["tail_human"] = "None"
							features["tail_lizard"] = "None"

				if("ears")
					var/list/snowflake_ears_list = list()
					for(var/path in GLOB.ears_list)
						var/datum/sprite_accessory/ears/instance = GLOB.ears_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_ears_list[S.name] = path
					var/new_ears
					new_ears = input(user, "Choose your character's ears:", "Character Preference") as null|anything in snowflake_ears_list
					if(new_ears)
						features["ears"] = new_ears

				if("mam_ears")
					var/list/snowflake_ears_list = list()
					for(var/path in GLOB.mam_ears_list)
						var/datum/sprite_accessory/mam_ears/instance = GLOB.mam_ears_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_ears_list[S.name] = path
					var/new_ears
					new_ears = input(user, "Choose your character's ears:", "Character Preference") as null|anything in snowflake_ears_list
					if(new_ears)
						features["mam_ears"] = new_ears

				if("mam_body_markings")
					var/list/snowflake_markings_list = list()
					for(var/path in GLOB.mam_body_markings_list)
						var/datum/sprite_accessory/mam_body_markings/instance = GLOB.mam_body_markings_list[path]
						if(istype(instance, /datum/sprite_accessory))
							var/datum/sprite_accessory/S = instance
							if(!show_mismatched_markings && S.recommended_species && !S.recommended_species.Find(pref_species.id))
								continue
							if((!S.ckeys_allowed) || (S.ckeys_allowed.Find(user.client.ckey)))
								snowflake_markings_list[S.name] = path
					var/new_mam_body_markings
					new_mam_body_markings = input(user, "Choose your character's body markings:", "Character Preference") as null|anything in snowflake_markings_list
					if(new_mam_body_markings)
						features["mam_body_markings"] = new_mam_body_markings
						if(new_mam_body_markings != "None")
							features["body_markings"] = "None"
						else if(new_mam_body_markings == "None")
							features["mam_body_markings"] = "Plain"
							features["body_markings"] = "None"

				//Xeno Bodyparts
				if("xenohead")//Head or caste type
					var/new_head
					new_head = input(user, "Choose your character's caste:", "Character Preference") as null|anything in GLOB.xeno_head_list
					if(new_head)
						features["xenohead"] = new_head

				if("xenotail")//Currently one one type, more maybe later if someone sprites them. Might include animated variants in the future.
					var/new_tail
					new_tail = input(user, "Choose your character's tail:", "Character Preference") as null|anything in GLOB.xeno_tail_list
					if(new_tail)
						features["xenotail"] = new_tail
						if(new_tail != "None")
							features["mam_tail"] = "None"
							features["taur"] = "None"
							features["tail_human"] = "None"
							features["tail_lizard"] = "None"

				if("xenodorsal")
					var/new_dors
					new_dors = input(user, "Choose your character's dorsal tube type:", "Character Preference") as null|anything in GLOB.xeno_dorsal_list
					if(new_dors)
						features["xenodorsal"] = new_dors

				//Genital code
				if("cock_color")
					var/new_cockcolor = input(user, "Penis color:", "Character Preference", features["cock_color"]) as color|null
					if(new_cockcolor)
						features["cock_color"] = sanitize_hexcolor(new_cockcolor)

				if("cock_length")
					var/min_D = CONFIG_GET(number/penis_min_centimeters_prefs)
					var/max_D = CONFIG_GET(number/penis_max_centimeters_prefs)
					var/new_length = input(user, "Penis length in centimeters:\n([min_D]-[max_D])", "Character Preference") as num|null
					if(new_length)
						features["cock_length"] = clamp(round(new_length, 0.1), min_D, max_D)

				if("cock_shape")
					var/new_shape
					var/list/fuck = GLOB.cock_shapes_list.Copy()
					if(length(pref_species.weiner_type))
						fuck = pref_species.weiner_type.Copy()
					new_shape = input(user, "Penis shape:", "Character Preference") as null|anything in fuck
					if(new_shape)
						features["cock_shape"] = new_shape

				if("balls_color")
					var/new_ballscolor = input(user, "Testicles Color:", "Character Preference", features["balls_color"]) as color|null
					if(new_ballscolor)
						features["balls_color"] = sanitize_hexcolor(new_ballscolor)

				if("breasts_size")
					var/new_size = input(user, "Breast Size", "Character Preference") as null|anything in CONFIG_GET(keyed_list/breasts_cups_prefs)
					if(new_size)
						features["breasts_size"] = new_size

				if("breasts_shape")
					var/new_shape
					var/list/fuck = GLOB.breasts_shapes_list.Copy()
					if(length(pref_species.bobs_type))
						fuck = pref_species.bobs_type.Copy()
					new_shape = input(user, "Breast Shape", "Character Preference") as null|anything in fuck
					if(new_shape)
						features["breasts_shape"] = new_shape

				if("breasts_color")
					var/new_breasts_color = input(user, "Breast Color:", "Character Preference", features["breasts_color"]) as color|null
					if(new_breasts_color)
						features["breasts_color"] = sanitize_hexcolor(new_breasts_color)

				if("vag_shape")
					var/new_shape
					var/list/fuck = GLOB.vagina_shapes_list.Copy()
					if(length(pref_species.vegana_type))
						fuck = pref_species.vegana_type.Copy()
					new_shape = input(user, "Vagina Type", "Character Preference") as null|anything in fuck
					if(new_shape)
						features["vag_shape"] = new_shape

				if("vag_color")
					var/new_vagcolor = input(user, "Vagina color:", "Character Preference", features["vag_color"]) as color|null
					if(new_vagcolor)
						features["vag_color"] = sanitize_hexcolor(new_vagcolor)

				if("ooccolor")
					var/new_ooccolor = input(user, "Choose your OOC colour:", "Game Preference", ooccolor) as color|null
					if(new_ooccolor)
						ooccolor = sanitize_hexcolor(new_ooccolor)

				if("aooccolor")
					var/new_aooccolor = input(user, "Choose your Antag OOC colour:", "Game Preference", ooccolor) as color|null
					if(new_aooccolor)
						aooccolor = sanitize_hexcolor(new_aooccolor)

				if("bag")
					var/new_backbag = input(user, "Choose your character's style of bag:", "Character Preference")  as null|anything in GLOB.backbaglist
					if(new_backbag)
						backbag = new_backbag

				if("sec_dept")
					var/department = input(user, "Choose your preferred security department:", "Security Departments") as null|anything in GLOB.security_depts_prefs
					if(department)
						prefered_security_department = department

				if ("preferred_map")
					var/maplist = list()
					var/default = "Default"
					if (config.defaultmap)
						default += " ([config.defaultmap.map_name])"
					for (var/M in config.maplist)
						var/datum/map_config/VM = config.maplist[M]
						var/friendlyname = "[VM.map_name] "
						if (VM.voteweight <= 0)
							friendlyname += " (disabled)"
						maplist[friendlyname] = VM.map_name
					maplist[default] = null
					var/pickedmap = input(user, "Choose your preferred map. This will be used to help weight random map selection.", "Character Preference")  as null|anything in maplist
					if (pickedmap)
						preferred_map = maplist[pickedmap]

				if ("preferred_chaos")
					var/pickedchaos = input(user, "Choose your preferred level of chaos. This will help with dynamic threat level ratings.", "Character Preference") as null|anything in list(CHAOS_NONE,CHAOS_LOW,CHAOS_MED,CHAOS_HIGH,CHAOS_MAX)
					preferred_chaos = pickedchaos

				if ("clientfps")
					var/desiredfps = input(user, "Choose your desired fps. (0 = synced with server tick rate (currently:[world.fps]))", "Character Preference", clientfps)  as null|num
					if (!isnull(desiredfps))
						clientfps = desiredfps
						parent.fps = desiredfps
				if("pda_style")
					var/pickedPDAStyle = input(user, "Choose your PDA style.", "Character Preference", pda_style)  as null|anything in GLOB.pda_styles
					if(pickedPDAStyle)
						pda_style = pickedPDAStyle
				if("pda_color")
					var/pickedPDAColor = input(user, "Choose your PDA Interface color.", "Character Preference", pda_color) as color|null
					if(pickedPDAColor)
						pda_color = sanitize_hexcolor(pickedPDAColor)
				if ("max_chat_length")
					var/desiredlength = input(user, "Choose the max character length of shown Runechat messages. Valid range is 1 to [CHAT_MESSAGE_MAX_LENGTH] (default: [initial(max_chat_length)]))", "Character Preference", max_chat_length)  as null|num
					if (!isnull(desiredlength))
						max_chat_length = clamp(desiredlength, 1, CHAT_MESSAGE_MAX_LENGTH)
				if("personal_chat_color")
					var/new_chat_color = input(user, "Choose your character's runechat color:", "Character Preference", personal_chat_color) as color|null
					if(new_chat_color)
						personal_chat_color = sanitize_hexcolor(new_chat_color)

				if("hud_toggle_color")
					var/new_toggle_color = input(user, "Choose your HUD toggle flash color:", "Game Preference", hud_toggle_color) as color|null
					if(new_toggle_color)
						hud_toggle_color = sanitize_hexcolor(new_toggle_color)

				if("gender")
					var/chosengender = (gender == FEMALE ? MALE : FEMALE)
					features["body_model"] = chosengender
					gender = chosengender
					facial_hair_style = random_facial_hair_style(gender)
					hair_style = random_hair_style(gender)

				if("body_size")
					var/min = CONFIG_GET(number/body_size_min)
					var/max = CONFIG_GET(number/body_size_max)
					var/danger = CONFIG_GET(number/threshold_body_size_slowdown)
					var/new_body_size = input(user, "Choose your desired sprite size: ([min*100]%-[max*100]%)\nWarning: This may make your character look distorted[danger > min ? "! Additionally, a proportional movement speed penalty will be applied to characters smaller than [danger*100]%." : "!"]", "Character Preference", features["body_size"]*100) as num|null
					if (new_body_size)
						new_body_size = clamp(new_body_size * 0.01, min, max)
						var/dorfy
						if((new_body_size + 0.01) < danger) // Adding 0.01 as a dumb fix to prevent the warning message from appearing when exactly at threshold... Not sure why that happens in the first place.
							dorfy = alert(user, "You have chosen a size below the slowdown threshold of [danger*100]%. For balancing purposes, the further you go below this percentage, the slower your character will be. Do you wish to keep this size?", "Speed Penalty Alert", "Yes", "Move it to the threshold", "No")
							if(dorfy == "Move it to the threshold")
								new_body_size = danger
							if(!dorfy) //Aborts if this var is somehow empty
								return
						if(dorfy != "No")
							features["body_size"] = new_body_size
		else
			switch(href_list["preference"])
				if("genital_colour")
					features["genitals_use_skintone"] = !features["genitals_use_skintone"]
					if(pref_species.use_skintones)
						features["genitals_use_skintone"] = TRUE
				if("arousable")
					arousable = !arousable
				if("has_cock")
					features["has_cock"] = !features["has_cock"]
					if(features["has_cock"] == FALSE)
						features["has_balls"] = FALSE
					if(!features["has_cock"] && !features["has_vag"])
						to_chat(user, "<span class='danger'>Your character needs at least one main genital (vagina or penis).\nYou have been given a vagina.</span>")
						features["has_vag"] = TRUE
				if("cyber_cock")
					features["cyber_cock"] = !features["cyber_cock"]
				if("has_balls")
					features["has_balls"] = !features["has_balls"]
				if("cyber_balls")
					features["cyber_balls"] = !features["cyber_balls"]
				if("has_breasts")
					features["has_breasts"] = !features["has_breasts"]
					if(features["has_breasts"] == FALSE)
						features["breasts_producing"] = FALSE
				if("cyber_breasts")
					features["cyber_breasts"] = !features["cyber_breasts"]
				if("breasts_producing")
					features["breasts_producing"] = !features["breasts_producing"]
				if("has_vag")
					features["has_vag"] = !features["has_vag"]
					if(features["has_vag"] == FALSE)
						features["has_womb"] = FALSE
					if(!features["has_cock"] && !features["has_vag"])
						to_chat(user, "<span class='danger'>Your character needs at least one main genital (vagina or penis).\nYou have been given a penis.</span>")
						features["has_cock"] = TRUE
						features["has_balls"] = TRUE
				if("cyber_vag")
					features["cyber_vag"] = !features["cyber_vag"]
				if("has_womb")
					features["has_womb"] = !features["has_womb"]
				if("cyber_womb")
					features["cyber_womb"] = !features["cyber_womb"]
				if("widescreenpref")
					widescreenpref = !widescreenpref
					user.client.change_view(CONFIG_GET(string/default_view))
				if("autostand")
					autostand = !autostand
				if("auto_ooc")
					auto_ooc = !auto_ooc
				if("no_tetris_storage")
					no_tetris_storage = !no_tetris_storage
				if("nameless")
					nameless = !nameless
				if("auto_hiss")
					auto_hiss = !auto_hiss
				if("publicity")
					if(unlock_content)
						toggles ^= MEMBER_PUBLIC

				if("body_model")
					features["body_model"] = (features["body_model"] == FEMALE ? MALE : FEMALE)

				if("hotkeys")
					hotkeys = !hotkeys
					user.client.set_macros()

				if("keybindings_capture")
					var/datum/keybinding/kb = GLOB.keybindings_by_name[href_list["keybinding"]]
					CaptureKeybinding(user, kb, href_list["old_key"], text2num(href_list["independent"]))
					return

				if("keybindings_set")
					var/kb_name = href_list["keybinding"]
					if(!kb_name)
						user << browse(null, "window=capturekeypress")
						ShowChoices(user)
						return

					var/independent = href_list["independent"]

					var/clear_key = text2num(href_list["clear_key"])
					var/old_key = href_list["old_key"]
					if(clear_key)
						if(independent)
							modless_key_bindings -= old_key
						else
							if(key_bindings[old_key])
								key_bindings[old_key] -= kb_name
								if(!length(key_bindings[old_key]))
									key_bindings -= old_key
						user << browse(null, "window=capturekeypress")
						save_preferences()
						ShowChoices(user)
						return

					var/new_key = uppertext(href_list["key"])
					var/AltMod = text2num(href_list["alt"]) ? "Alt" : ""
					var/CtrlMod = text2num(href_list["ctrl"]) ? "Ctrl" : ""
					var/ShiftMod = text2num(href_list["shift"]) ? "Shift" : ""
					var/numpad = text2num(href_list["numpad"]) ? "Numpad" : ""
					// var/key_code = text2num(href_list["key_code"])

					if(GLOB._kbMap[new_key])
						new_key = GLOB._kbMap[new_key]

					var/full_key
					switch(new_key)
						if("Alt")
							full_key = "[new_key][CtrlMod][ShiftMod]"
						if("Ctrl")
							full_key = "[AltMod][new_key][ShiftMod]"
						if("Shift")
							full_key = "[AltMod][CtrlMod][new_key]"
						else
							full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"
					if(independent)
						modless_key_bindings -= old_key
						modless_key_bindings[full_key] = kb_name
					else
						if(key_bindings[old_key])
							key_bindings[old_key] -= kb_name
							if(!length(key_bindings[old_key]))
								key_bindings -= old_key
						key_bindings[full_key] += list(kb_name)
						key_bindings[full_key] = sortList(key_bindings[full_key])
					user.client.update_movement_keys()
					user << browse(null, "window=capturekeypress")
					save_preferences()

				if("keybindings_reset")
					var/choice = tgalert(user, "Would you prefer 'hotkey' or 'classic' defaults?", "Setup keybindings", "Hotkey", "Classic", "Cancel")
					if(choice == "Cancel")
						ShowChoices(user)
						return
					hotkeys = (choice == "Hotkey")
					key_bindings = (hotkeys) ? deepCopyList(GLOB.hotkey_keybinding_list_by_key) : deepCopyList(GLOB.classic_keybinding_list_by_key)
					modless_key_bindings = list()
					user.client.update_movement_keys()

				if("chat_on_map")
					chat_on_map = !chat_on_map
				if("see_chat_non_mob")
					see_chat_non_mob = !see_chat_non_mob
				if("see_chat_emotes")
					see_chat_emotes = !see_chat_emotes
				if("enable_personal_chat_color")
					enable_personal_chat_color = !enable_personal_chat_color
				if("appear_in_round_end_report")
					appear_in_round_end_report = !appear_in_round_end_report
					user.mind?.appear_in_round_end_report = appear_in_round_end_report
				if("action_buttons")
					buttons_locked = !buttons_locked
				if("tgui_fancy")
					tgui_fancy = !tgui_fancy
				if("tgui_lock")
					tgui_lock = !tgui_lock
				if("winflash")
					windowflashing = !windowflashing
				if("hear_adminhelps")
					toggles ^= SOUND_ADMINHELP
				if("announce_login")
					toggles ^= ANNOUNCE_LOGIN
				if("combohud_lighting")
					toggles ^= COMBOHUD_LIGHTING

				if("be_special")
					var/be_special_type = href_list["be_special_type"]
					if(be_special_type in be_special)
						be_special -= be_special_type
					else
						be_special += be_special_type

				if("name")
					be_random_name = !be_random_name

				if("all")
					be_random_body = !be_random_body

				if("hear_midis")
					toggles ^= SOUND_MIDI

				if("hear_megafauna")
					toggles ^= SOUND_MEGAFAUNA

				if("lobby_music")
					toggles ^= SOUND_LOBBY
					if((toggles & SOUND_LOBBY) && user.client && isnewplayer(user))
						user.client.playtitlemusic()
					else
						user.stop_sound_channel(CHANNEL_LOBBYMUSIC)

				if("ghost_ears")
					chat_toggles ^= CHAT_GHOSTEARS

				if("ghost_sight")
					chat_toggles ^= CHAT_GHOSTSIGHT

				if("ghost_whispers")
					chat_toggles ^= CHAT_GHOSTWHISPER

				if("ghost_radio")
					chat_toggles ^= CHAT_GHOSTRADIO

				if("ghost_pda")
					chat_toggles ^= CHAT_GHOSTPDA

				if("income_pings")
					chat_toggles ^= CHAT_BANKCARD

				if("pull_requests")
					chat_toggles ^= CHAT_PULLR

				if("allow_midround_antag")
					toggles ^= MIDROUND_ANTAG

				if("parallaxup")
					parallax = WRAP(parallax + 1, PARALLAX_INSANE, PARALLAX_DISABLE + 1)
					if (parent && parent.mob && parent.mob.hud_used)
						parent.mob.hud_used.update_parallax_pref(parent.mob)

				if("parallaxdown")
					parallax = WRAP(parallax - 1, PARALLAX_INSANE, PARALLAX_DISABLE + 1)
					if (parent && parent.mob && parent.mob.hud_used)
						parent.mob.hud_used.update_parallax_pref(parent.mob)

				if("ambientocclusion")
					ambientocclusion = !ambientocclusion
					if(parent && parent.screen && parent.screen.len)
						var/obj/screen/plane_master/game_world/G = parent.mob.hud_used.plane_masters["[GAME_PLANE]"]
						var/obj/screen/plane_master/game_world/M = parent.mob.hud_used.plane_masters["[MOB_PLANE]"]
						var/obj/screen/plane_master/above_wall/A = parent.mob.hud_used.plane_masters["[ABOVE_WALL_PLANE]"]
						var/obj/screen/plane_master/wall/W = parent.mob.hud_used.plane_masters["[WALL_PLANE]"]
						G.backdrop(parent.mob)
						M.backdrop(parent.mob)
						A.backdrop(parent.mob)
						W.backdrop(parent.mob)

				if("auto_fit_viewport")
					auto_fit_viewport = !auto_fit_viewport
					if(auto_fit_viewport && parent)
						parent.fit_viewport()

				if("hud_toggle_flash")
					hud_toggle_flash = !hud_toggle_flash

				if("save")
					save_preferences()
					save_character()

				if("load")
					load_preferences()
					load_character()

				if("changeslot")
					if(!load_character(text2num(href_list["num"])))
						random_character()
						real_name = random_unique_name(gender)
						save_character()

				if("tab")
					if(href_list["tab"])
						current_tab = text2num(href_list["tab"])
	if(href_list["preference"] == "gear")
		if(href_list["clear_loadout"])
			chosen_gear = list()
			gear_points = CONFIG_GET(number/initial_gear_points)
			save_preferences()
		if(href_list["select_category"])
			for(var/i in GLOB.loadout_items)
				if(i == href_list["select_category"])
					gear_tab = i
		if(href_list["toggle_gear_path"])
			var/datum/gear/G = GLOB.loadout_items[gear_tab][html_decode(href_list["toggle_gear_path"])]
			if(!G)
				return
			if(href_list["toggle_gear"] != "color")
				var/toggle = text2num(href_list["toggle_gear"])
				if(!toggle && (G.type in chosen_gear))//toggling off and the item effectively is in chosen gear)
					chosen_gear -= G.type
					gear_points += initial(G.cost)
				else if(toggle && (!(is_type_in_ref_list(G, chosen_gear))))
					if(!is_loadout_slot_available(G.category))
						to_chat(user, "<span class='danger'>You cannot take this loadout, as you've already chosen too many of the same category!</span>")
						return
					if(G.donoritem && !G.donator_ckey_check(user.ckey))
						to_chat(user, "<span class='danger'>This is an item intended for donator use only. You are not authorized to use this item.</span>")
						return
					if(gear_points >= initial(G.cost))
						chosen_gear += G.type
						if(!color_gear)
							color_gear = list()
						color_gear |= list(G.name = G.color)
						gear_points -= initial(G.cost)
			else
				var/choice = input(user, "Select a color for [G.name].", "Gear Color") as color
				if(choice)
					if(!color_gear)
						color_gear = list()
					color_gear[G.name] = choice

	ShowChoices(user)
	return 1

/datum/preferences/proc/copy_to(mob/living/carbon/human/character, icon_updates = 1, roundstart_checks = TRUE)
	if(be_random_name)
		real_name = pref_species.random_name(gender)

	if(be_random_body)
		random_character(gender)

	if(roundstart_checks)
		if(CONFIG_GET(flag/humans_need_surnames) && (pref_species.id == "human"))
			var/firstspace = findtext(real_name, " ")
			var/name_length = length(real_name)
			if(!firstspace)	//we need a surname
				real_name += " [pick(GLOB.last_names)]"
			else if(firstspace == name_length)
				real_name += "[pick(GLOB.last_names)]"

	character.real_name = nameless ? "[real_name] #[rand(10000, 99999)]" : real_name
	character.name = character.real_name
	character.nameless = nameless
	character.custom_species = custom_species

	character.gender = gender
	character.age = age

	character.auto_hiss = auto_hiss

	character.left_eye_color = left_eye_color
	character.right_eye_color = right_eye_color
	var/obj/item/bodypart/left_eye/LE = character.get_bodypart_nostump(BODY_ZONE_PRECISE_LEFT_EYE)
	if(LE)
		if(!initial(LE.eye_color))
			LE.eye_color = left_eye_color
		LE.old_eye_color = left_eye_color
	var/obj/item/bodypart/right_eye/RE = character.get_bodypart_nostump(BODY_ZONE_PRECISE_LEFT_EYE)
	if(RE)
		if(!initial(RE.eye_color))
			RE.eye_color = right_eye_color
		RE.old_eye_color = right_eye_color
	character.hair_color = hair_color
	character.facial_hair_color = facial_hair_color
	character.skin_tone = skin_tone
	character.dna.skin_tone_override = use_custom_skin_tone ? skin_tone : null
	character.hair_style = hair_style
	character.facial_hair_style = facial_hair_style

	var/datum/species/chosen_species
	if(!roundstart_checks || (pref_species.id in GLOB.roundstart_races))
		chosen_species = pref_species.type
	else
		chosen_species = /datum/species/human
		pref_species = new /datum/species/human
		save_character()

	var/old_size = character.dna.features["body_size"]

	character.dna.features = features.Copy()
	character.set_species(chosen_species, icon_update = FALSE, pref_load = TRUE)
	character.dna.real_name = character.real_name
	character.dna.nameless = character.nameless
	character.dna.custom_species = character.custom_species

	if(pref_species.mutant_bodyparts["meat_type"])
		character.type_of_meat = GLOB.meat_types[features["meat_type"]]

	//no robotic dummies please
	if(istype(character, /mob/living/carbon/human/dummy))
		for(var/obj/item/bodypart/BP in character.bodyparts)
			BP.drop_limb(TRUE, TRUE, FALSE, TRUE)
		character.regenerate_limbs()

	character.give_genitals(TRUE) //character.update_genitals() is already called on genital.update_appearance()
	character.dna.update_body_size(old_size)
	for(var/a in organ_augments)
		var/datum/augment/augment = organ_augments[a][2]
		if(augment)
			augment.apply(parent, src, character)
	for(var/a in limb_augments)
		var/datum/augment/augment = limb_augments[a][2]
		if(augment)
			augment.apply(parent, src, character)

	SEND_SIGNAL(character, COMSIG_HUMAN_PREFS_COPIED_TO, src, icon_updates, roundstart_checks)

	//let's be sure the character updates
	if(icon_updates)
		character.update_body(TRUE)
		character.update_hair()
	if(auto_hiss)
		character.toggle_hiss()

	//owai detection (kills owai)
	if(findtext(real_name, "Owai"))
		character.death()
		to_chat(character, "there is a pipebomb in your mailbox")

/datum/preferences/proc/get_default_name(name_id)
	switch(name_id)
		if("human")
			return random_unique_name()
		if("ai")
			return pick(GLOB.ai_names)
		if("cyborg")
			return DEFAULT_CYBORG_NAME
		if("jester")
			return pick(GLOB.clown_names)
		if("mime")
			return pick(GLOB.mime_names)
	return random_unique_name()

/datum/preferences/proc/ask_for_custom_name(mob/user,name_id)
	var/namedata = GLOB.preferences_custom_names[name_id]
	if(!namedata)
		return

	var/raw_name = input(user, "Choose your character's [namedata["qdesc"]]:","Character Preference") as text|null
	if(!raw_name)
		if(namedata["allow_null"])
			custom_names[name_id] = get_default_name(name_id)
		else
			return
	else
		var/sanitized_name = reject_bad_name(raw_name,namedata["allow_numbers"])
		if(!sanitized_name)
			to_chat(user, "<font color='red'>Invalid name. Your name should be at least 2 and at most [MAX_NAME_LEN] characters long. It may only contain the characters A-Z, a-z,[namedata["allow_numbers"] ? ",0-9," : ""] -, ' and .</font>")
			return
		else
			custom_names[name_id] = sanitized_name

/datum/preferences/proc/get_filtered_holoform(filter_type)
	if(!custom_holoform_icon)
		return
	LAZYINITLIST(cached_holoform_icons)
	if(!cached_holoform_icons[filter_type])
		cached_holoform_icons[filter_type] = process_holoform_icon_filter(custom_holoform_icon, filter_type)
	return cached_holoform_icons[filter_type]

//Used in savefile update 32, can be removed once that is no longer relevant.
/datum/preferences/proc/force_reset_keybindings()
	var/choice = tgalert(parent.mob, "Your basic keybindings need to be reset, emotes will remain as before. Would you prefer 'hotkey' or 'classic' mode?", "Reset keybindings", "Hotkey", "Classic")
	hotkeys = (choice != "Classic")
	var/list/oldkeys = key_bindings
	key_bindings = (hotkeys) ? deepCopyList(GLOB.hotkey_keybinding_list_by_key) : deepCopyList(GLOB.classic_keybinding_list_by_key)

	for(var/key in oldkeys)
		if(!key_bindings[key])
			key_bindings[key] = oldkeys[key]
	parent.update_movement_keys()

/datum/preferences/proc/is_loadout_slot_available(slot)
	var/list/L
	LAZYINITLIST(L)
	for(var/i in chosen_gear)
		var/datum/gear/G = i
		var/occupied_slots = L[slot_to_string(initial(G.category))] ? L[slot_to_string(initial(G.category))] + 1 : 1
		LAZYSET(L, slot_to_string(initial(G.category)), occupied_slots)
	switch(slot)
		if(SLOT_IN_BACKPACK)
			if(L[slot_to_string(SLOT_IN_BACKPACK)] < BACKPACK_SLOT_AMT)
				return TRUE
		if(SLOT_HANDS)
			if(L[slot_to_string(SLOT_HANDS)] < HANDS_SLOT_AMT)
				return TRUE
		else
			if(L[slot_to_string(slot)] < DEFAULT_SLOT_AMT)
				return TRUE

#undef DEFAULT_SLOT_AMT
#undef HANDS_SLOT_AMT
#undef BACKPACK_SLOT_AMT

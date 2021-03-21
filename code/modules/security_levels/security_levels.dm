GLOBAL_VAR_INIT(security_level, SEC_LEVEL_GREEN)
//SEC_LEVEL_GREEN = code green
//SEC_LEVEL_BLUE = code blue
//SEC_LEVEL_AMBER = code amber
//SEC_LEVEL_RED = code red
//SEC_LEVEL_DELTA = code delta

 /*
  * All security levels, per ascending alert. Nothing too fancy, really.
  * Their positions should also match their numerical values.
  */
GLOBAL_LIST_INIT(all_security_levels, list("green", "blue", "violet", "orange", "amber",  "red", "delta")) //Skyrat change

//config.alert_desc_blue_downto

/proc/set_security_level(level)
	if(!isnum(level))
		level = GLOB.all_security_levels.Find(level)

	//Will not be announced if you try to set to the same level as it already is
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != GLOB.security_level)
		var/string_level = LvlToString(level)
		var/seclevelup = TRUE
		if(GLOB.security_level >= level)
			seclevelup = FALSE
		
		var/announce_title = "Attention! Alert level [seclevelup ? "elevated" : "lowered"] to [string_level]:"
		var/announce_contents = sl_CONFIG_GET(level)
		if(level >= SEC_LEVEL_RED)
			switch(level)
				if(SEC_LEVEL_RED)
					announce_title ="Attention! Code red!"
					sound_to_playing_players('modular_skyrat/sound/misc/redalert1.ogg')
				if(SEC_LEVEL_DELTA)
					announce_title = "Attention! Delta security level reached!"
					sound_to_playing_players('sound/misc/deltakalaxon.ogg')
			for(var/obj/machinery/computer/shuttle/pod/pod in GLOB.machines)
				pod.admin_controlled = 0
			for(var/obj/machinery/door/D in GLOB.machines)
				if(D.red_alert_access)
					D.visible_message("<span class='notice'>[D] whirrs as it automatically lifts access requirements!</span>")
					playsound(D, 'sound/machines/boltsup.ogg', 50, TRUE)
		minor_announce(announce_contents, announce_title, seclevelup)
		GLOB.security_level = level
		for(var/obj/machinery/firealarm/FA in GLOB.machines)
			if(is_station_level(FA.z))
				FA.update_icon()
		SSblackbox.record_feedback("tally", "security_level_changes", 1, NUM2SECLEVEL(GLOB.security_level))
		SSnightshift.check_nightshift()

/proc/sl_CONFIG_GET(level) //fuck whichever retard made CONFIG_GET not accept vars
	var/niggafuckcum
	if(GLOB.security_level >= level) //that would make it so much easier, instead we have THIS
		switch(level)
			if(SEC_LEVEL_GREEN)
				niggafuckcum = CONFIG_GET(string/alert_green)
			if(SEC_LEVEL_BLUE)
				niggafuckcum = CONFIG_GET(string/alert_blue_downto)
			if(SEC_LEVEL_VIOLET)
				niggafuckcum = CONFIG_GET(string/alert_violet_downto)
			if(SEC_LEVEL_ORANGE)
				niggafuckcum = CONFIG_GET(string/alert_orange_downto)
			if(SEC_LEVEL_AMBER)
				niggafuckcum = CONFIG_GET(string/alert_amber_downto)
			if(SEC_LEVEL_RED)
				niggafuckcum = CONFIG_GET(string/alert_red_downto)
	else //nigga i don't care
		switch(level)
			if(SEC_LEVEL_BLUE)
				niggafuckcum = CONFIG_GET(string/alert_blue_upto)
			if(SEC_LEVEL_VIOLET)
				niggafuckcum = CONFIG_GET(string/alert_violet_upto)
			if(SEC_LEVEL_ORANGE)
				niggafuckcum = CONFIG_GET(string/alert_orange_upto)
			if(SEC_LEVEL_AMBER)
				niggafuckcum = CONFIG_GET(string/alert_amber_upto)
			if(SEC_LEVEL_RED)
				niggafuckcum = CONFIG_GET(string/alert_red_upto)
			if(SEC_LEVEL_DELTA)
				niggafuckcum = CONFIG_GET(string/alert_delta)
	return niggafuckcum

/proc/LvlToString(level)
	switch(level)
		if(SEC_LEVEL_GREEN)
			return "green"
		if(SEC_LEVEL_BLUE)
			return "blue"
		if(SEC_LEVEL_VIOLET)
			return "violet"
		if(SEC_LEVEL_ORANGE)
			return "orange"
		if(SEC_LEVEL_AMBER)
			return "amber"
		if(SEC_LEVEL_RED)
			return "red"
		if(SEC_LEVEL_DELTA)
			return "delta"

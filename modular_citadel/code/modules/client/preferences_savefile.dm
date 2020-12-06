/datum/preferences/proc/cit_character_pref_load(savefile/S)
	//ipcs
	S["feature_ipc_screen"] >> features["ipc_screen"]
	S["feature_ipc_antenna"] >> features["ipc_antenna"]

	features["ipc_screen"] 	= sanitize_inlist(features["ipc_screen"], GLOB.ipc_screens_list)
	features["ipc_antenna"] 	= sanitize_inlist(features["ipc_antenna"], GLOB.ipc_antennas_list)
	//Citadel
	if(!features["mcolor2"] || features["mcolor"] == "#000")
		features["mcolor2"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	if(!features["mcolor3"] || features["mcolor"] == "#000")
		features["mcolor3"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	features["mcolor2"]	= sanitize_hexcolor(features["mcolor2"], 6, TRUE)
	features["mcolor3"]	= sanitize_hexcolor(features["mcolor3"], 6, TRUE)
	//SKYRAT CHANGES
	S["enable_personal_chat_color"]			>> enable_personal_chat_color
	S["personal_chat_color"]			>> personal_chat_color

	S["feature_ipc_chassis"] >> features["ipc_chassis"]

	S["alt_titles_preferences"]			>> alt_titles_preferences
	alt_titles_preferences = SANITIZE_LIST(alt_titles_preferences)
	if(SSjob)
		for(var/datum/job/job in sortList(SSjob.occupations, /proc/cmp_job_display_asc))
			if(alt_titles_preferences[job.title])
				if(!(alt_titles_preferences[job.title] in job.alt_titles))
					alt_titles_preferences.Remove(job.title)

	features["ipc_chassis"] 	= sanitize_inlist(features["ipc_chassis"], GLOB.ipc_chassis_list)
	security_records = sanitize_text(S["security_records"])
	medical_records = sanitize_text(S["medical_records"])
	general_records = sanitize_text(S["general_records"])
	character_skills = sanitize_text(S["character_skills"])
	exploitable_info = sanitize_text(S["exploitable_info"])
	enable_personal_chat_color	= sanitize_integer(enable_personal_chat_color, 0, 1, initial(enable_personal_chat_color))
	personal_chat_color	= sanitize_hexcolor(personal_chat_color, 6, TRUE, "#FFFFFF")
	foodlikes = SANITIZE_LIST(S["foodlikes"])
	if(foodlikes.len > maxlikes)
		foodlikes.Cut(maxlikes+1)
	fooddislikes = SANITIZE_LIST(S["fooddislikes"])
	if(fooddislikes.len > maxdislikes)
		fooddislikes.Cut(maxdislikes+1)

/datum/preferences/proc/cit_character_pref_save(savefile/S)
	//ipcs
	WRITE_FILE(S["feature_ipc_screen"], features["ipc_screen"])
	WRITE_FILE(S["feature_ipc_antenna"], features["ipc_antenna"])
	//Citadel
	WRITE_FILE(S["feature_genitals_use_skintone"], features["genitals_use_skintone"])
	WRITE_FILE(S["feature_mcolor2"], features["mcolor2"])
	WRITE_FILE(S["feature_mcolor3"], features["mcolor3"])
	WRITE_FILE(S["feature_mam_body_markings"], features["mam_body_markings"])
	WRITE_FILE(S["feature_mam_tail"], features["mam_tail"])
	WRITE_FILE(S["feature_mam_ears"], features["mam_ears"])
	WRITE_FILE(S["feature_mam_tail_animated"], features["mam_tail_animated"])
	WRITE_FILE(S["feature_taur"], features["taur"])
	WRITE_FILE(S["feature_mam_snouts"],	features["mam_snouts"])
	//Xeno features
	WRITE_FILE(S["feature_xeno_tail"], features["xenotail"])
	WRITE_FILE(S["feature_xeno_dors"], features["xenodorsal"])
	WRITE_FILE(S["feature_xeno_head"], features["xenohead"])
	
	//SKYRAT CHANGES
	WRITE_FILE(S["feature_ipc_chassis"], features["ipc_chassis"])
	WRITE_FILE(S["security_records"], security_records)
	WRITE_FILE(S["medical_records"], medical_records)
	WRITE_FILE(S["general_records"], general_records)
	WRITE_FILE(S["character_skills"], character_skills)
	WRITE_FILE(S["exploitable_info"], exploitable_info)
	WRITE_FILE(S["enable_personal_chat_color"], enable_personal_chat_color)
	WRITE_FILE(S["personal_chat_color"], personal_chat_color)
	WRITE_FILE(S["alt_titles_preferences"], alt_titles_preferences)
	WRITE_FILE(S["foodlikes"], foodlikes)
	WRITE_FILE(S["fooddislikes"], fooddislikes)
	//END OF SKYRAT CHANGES

/datum/speech_mod/torn_vocal_cords

/datum/speech_mod/torn_vocal_cords/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	message = uppertext(message)
	if(prob(20))
		message = pick("GHHHHHH...", "GLLLL...", "ZZRRRRR..")
	else
		var/new_message = ""
		var/m_len = length(message)
		var/tracker = 1
		while(tracker < m_len)
			var/nletter = copytext(message, tracker, tracker + 1)
			if(!(nletter in list("A", "E", "I", "O", "U", " ")) && (tracker % 2))
				nletter = pick("GH", "SHK", "KSS", "SS", "GNHH")
			else if((nletter == " ") && prob(50))
				nletter = "..."
			new_message += nletter
			tracker++
		for(var/uhoh in list("U", "O", "I", "E", "A"))
			new_message = replacetext(new_message, uhoh, pick("H", "HUUUH", "GHHH", "ZZZGH", "GLRG", "GRRR", "GLLL", "...", "RRRRR"))
		message = new_message
	speech_args[SPEECH_MESSAGE] = message

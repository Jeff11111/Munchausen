/client/proc/togglegloballoocs()
	set name = "Show/Hide LOOC Globally"
	set category = "Preferences"
	set desc = "Toggles seeing LocalOutOfCharacter chat globally"
	usr.client.prefs.chat_toggles ^= CHAT_LOOC_ADMIN
	usr.client.prefs.save_preferences()
	to_chat(usr, "You will [(usr.client.prefs.chat_toggles & CHAT_LOOC_ADMIN) ? "now see all" : "now only see local"] messages on the LOOC channel.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Seeing LOOC Globally", "[usr.client.prefs.chat_toggles & CHAT_LOOC_ADMIN ? "Enabled" : "Disabled"]"))

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings, megafauna_music)()
	set name = "Toggle Megafauna Music"
	set category = "Preferences"
	set desc = "Turn megafauna music on/off"

	usr.client.prefs.toggles ^= SOUND_MEGAFAUNA
	usr.client.prefs.save_preferences()
	to_chat(usr, "You [(usr.client.prefs.toggles & SOUND_MEGAFAUNA) ? "turn on" : "turn off"] the playback of megafauna music.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Megafauna Music", "[usr.client.prefs.toggles & SOUND_MEGAFAUNA ? "Yes" : "No"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/verbs/menu/Settings/megafauna_music/Get_checked(client/C)
	return C.prefs.toggles & SOUND_MEGAFAUNA

TOGGLE_CHECKBOX(/datum/verbs/menu/Settings, metric_or_bust)()
	set name = "Toggle Measurements"
	set category = "Preferences"
	set desc = "Toggle/Untoggle Metric Measurements"

	usr.client.prefs.toggles ^= METRIC_OR_BUST
	usr.client.prefs.save_preferences()
	to_chat(usr, "You are now using [(usr.client.prefs.toggles & METRIC_OR_BUST) ? "metric" : "imperial"] measurements.")
	SSblackbox.record_feedback("nested tally", "preferences_verb", 1, list("Toggle Measurements", "[usr.client.prefs.toggles & METRIC_OR_BUST ? "Metric" : "Imperial"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/datum/verbs/menu/Settings/metric_or_bust/Get_checked(client/C)
	return C.prefs.toggles & METRIC_OR_BUST

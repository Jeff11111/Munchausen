//Base aspect datum very cool
/datum/aspect
	var/id = "chungus"
	var/name = "Chungus Mode"
	var/desc = "Every crewmember is a redditor."

/datum/aspect/proc/on_initialize()
	return TRUE

/datum/aspect/proc/on_roundstart()
	return TRUE

/datum/aspect/proc/post_equip(mob/living/bingus, client/preference_source, latejoin = FALSE)
	return TRUE

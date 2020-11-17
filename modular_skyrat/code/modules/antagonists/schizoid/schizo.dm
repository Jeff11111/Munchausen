//Paranoid schizo special
/datum/antagonist/schizoid
	name = "Paranoid Schizophrenic"
	antagpanel_category = "Schizoid"
	roundend_category = "paranoid schizophrenics"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/schizoid/on_gain()
	. = ..()
	var/datum/objective/assassinate/kill = new()
	kill.find_target()
	objectives += kill

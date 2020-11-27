//Paranoid schizo special
/datum/antagonist/schizoid
	name = "Paranoid Schizophrenic"
	antagpanel_category = "Schizoid"
	roundend_category = "paranoid schizophrenics"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/schizoid/on_gain()
	. = ..()
	addtimer(CALLBACK(src, .proc/assign_objective), 10 SECONDS)

/datum/antagonist/schizoid/proc/assign_objective()
	var/datum/objective/assassinate/kill = new()
	kill.find_target()
	objectives += kill
	owner.announce_objectives()

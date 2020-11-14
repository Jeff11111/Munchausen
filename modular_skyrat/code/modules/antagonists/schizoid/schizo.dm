//Paranoid schizo special
/datum/antagonist/schizoid
	name = "Antagonist"
	antagpanel_category = "Schizoid"
	roundend_category = "paranoid schizophrenics"
	show_name_in_check_antagonists = TRUE

/datum/antagonist/schizoid/on_gain()
	. = ..()
	var/datum/objective/assassinate/kill = new()
	objectives += kill

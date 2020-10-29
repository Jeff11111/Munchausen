/datum/traitor_class/human/freeform
	name = "Waffle Co Agent"
	employer = "Waffle Company"
	weight = 16
	chaos = 0

/datum/traitor_class/human/freeform/forge_objectives(datum/antagonist/traitor/T)
	var/datum/objective/escape/O = new
	O.explanation_text = "You have no explicit goals! Antagonize NT however you see fit, be it via mass murder or department bombing!"
	O.owner = T.owner
	T.add_objective(O)
	return

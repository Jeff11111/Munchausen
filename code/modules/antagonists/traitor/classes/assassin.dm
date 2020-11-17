/datum/traitor_class/human/assassin
	name = "Donk Corporative"
	employer = "Donk Corporation"
	weight = 0
	chaos = 1
	threat  = 2

/datum/traitor_class/human/assassin/forge_single_objective(datum/antagonist/traitor/T)
	.=1
	var/is_dynamic = FALSE
	var/datum/game_mode/dynamic/mode
	if(istype(SSticker.mode,/datum/game_mode/dynamic))
		mode = SSticker.mode
		is_dynamic = TRUE
	var/list/active_ais = active_ais()
	if(active_ais.len && prob(30))
		var/datum/objective/destroy/destroy_objective = new
		destroy_objective.owner = T.owner
		destroy_objective.find_target()
		T.add_objective(destroy_objective)
	else if(prob(30) || (is_dynamic && (mode.storyteller.flags & NO_ASSASSIN)))
		var/datum/objective/maroon/maroon = new()
		maroon.owner = T.owner
		maroon.find_target()
		T.add_objective(maroon)
	else
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = T.owner
		kill_objective.find_target()
		T.add_objective(kill_objective)

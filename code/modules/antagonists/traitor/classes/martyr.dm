/datum/traitor_class/human/martyr
	name = "Tiger Cooperator"
	employer = "The Tiger Cooperative"
	weight = 2
	chaos = 5
	threat = 5
	min_players = 20
	uplink_filters = list(/datum/uplink_item/stealthy_weapons/romerol_kit,/datum/uplink_item/bundles_TC/contract_kit)

/datum/traitor_class/human/martyr/forge_objectives(datum/antagonist/traitor/T)
	var/datum/objective/christchurch/O = new
	O.owner = T.owner
	O.explanation_text = "\The [employer] have decided that NanoTrasen has had enough chances, and sent me here on a suicide mission. I must kill at least [O.christchurch_victims] crewmembers."
	T.add_objective(O)

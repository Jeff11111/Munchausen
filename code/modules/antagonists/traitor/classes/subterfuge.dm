/datum/traitor_class/human/subterfuge
	name = "MI13 Operative"
	employer = "MI13"
	weight = 1
	chaos = -5

/datum/traitor_class/human/subterfuge/forge_single_objective(datum/antagonist/traitor/T)
	.=1
	var/assassin_prob = 30
	var/datum/game_mode/dynamic/mode
	if(istype(SSticker.mode,/datum/game_mode/dynamic))
		mode = SSticker.mode
		assassin_prob = max(0,mode.threat_level-40)
	if(prob(assassin_prob))
		if(prob(assassin_prob))
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = T.owner
			kill_objective.find_target()
			T.add_objective(kill_objective)
		else
			var/datum/objective/maroon/maroon = new
			maroon.owner = T.owner
			maroon.find_target()
			T.add_objective(maroon)
	else
		if(prob(15) && !(locate(/datum/objective/download) in T.objectives) && !(T.owner.assigned_role in list("Research Director", "Scientist", "Roboticist")))
			var/datum/objective/download/download_objective = new
			download_objective.owner = T.owner
			download_objective.gen_amount_goal()
			T.add_objective(download_objective)
		else if(prob(70)) // cum. not counting download: 40%.
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = T.owner
			steal_objective.find_target()
			T.add_objective(steal_objective)
		else
			//sabotage objectives are lame, let's do something funny instead
			var/datum/objective/nuclear/nuclear = new
			nuclear.owner = T.owner
			var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.nuke_list
			if(nuke)
				//NO FUCK NO
				if(nuke.r_code == "ADMIN")
					nuke.r_code = random_nukecode()
				nuclear.explanation_text += " [employer] has acquired, and given to you, the code: [nuke.r_code]."
			T.add_objective(nuclear)

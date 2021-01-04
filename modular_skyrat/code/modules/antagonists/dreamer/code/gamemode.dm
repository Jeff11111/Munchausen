//Dreamer is not really recommended as a standalone gamemode.
//This is more for testing and badminning than a serious thing you should actually do.
/datum/game_mode/dreamer
	name = "dreamer"
	config_tag = "dreamer"
	antag_flag = ROLE_DREAMER
	enemy_minimum_age = 0
	announce_text = "A psychopathic killer is among the crew. He speaks of another world, of bizarre visions - What could it mean?"
	false_report_weight = 0 //You can't really report a dreamer
	protected_jobs = list("Cyborg", "AI")
	required_players = 5 //To ensure a dreamer victory, 5 players is a bare minimum
	required_enemies = 1 //One dreamer only
	recommended_enemies = 1 //One dreamer only

/datum/game_mode/dreamer/post_setup(report)
	. = ..()
	var/datum/mind/dreamer
	while(!istype(dreamer))
		if(length(antag_candidates))
			dreamer = pick_n_take(antag_candidates)
		else
			var/mob/M = pick(GLOB.player_list)
			if(M?.mind)
				dreamer = M.mind
	if(istype(dreamer))
		var/datum/antagonist/dreamer/new_antag = new()
		addtimer(CALLBACK(dreamer, /datum/mind.proc/add_antag_datum, new_antag), rand(100,200))

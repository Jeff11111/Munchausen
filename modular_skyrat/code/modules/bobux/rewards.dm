//the rewards themselves
/datum/bobux_reward/become_traitor
	name = "Become Traitor"
	desc = "Become a syndicate agent. Took you long to remember your mission!"
	buy_message = "<b>You remember your true purpose on the station...</span>"
	id = "become_traitor"
	cost = 10

/datum/bobux_reward/become_traitor/can_buy(client/noob, silent, fail_message)
	. = ..()
	if(. && ishuman(noob.mob) && noob.mob.mind)
		return TRUE

/datum/bobux_reward/become_traitor/on_buy(client/noob)
	. = ..()
	var/mob/living/carbon/human/H = noob.mob
	H.mind.add_antag_datum(new /datum/antagonist/traitor())

/datum/bobux_reward/stat_boost
	name = "Boost Stats"
	desc = "Improve all stats by one point."
	buy_message = "<b>I become stronger.</span>"
	id = "statboost"
	cost = 2

/datum/bobux_reward/stat_boost/can_buy(client/noob, silent, fail_message)
	. = ..()
	if(. && ishuman(noob.mob) && noob.mob.mind)
		return TRUE

/datum/bobux_reward/stat_boost/on_buy(client/noob)
	. = ..()
	for(var/stat in noob.mob.mind.mob_stats)
		noob.mob.mind.mob_stats[stat].level += 1

/datum/bobux_reward/combat_boost
	name = "Combat Boost"
	desc = "Improve melee and ranged skill by 4 to 7 points."
	buy_message = "<b>I become better at combat.</span>"
	id = "combatboost"
	cost = 2

/datum/bobux_reward/combat_boost/can_buy(client/noob, silent, fail_message)
	. = ..()
	if(. && ishuman(noob.mob) && noob.mob.mind)
		return TRUE

/datum/bobux_reward/combat_boost/on_buy(client/noob)
	. = ..()
	var/list/poggers = list(SKILL_DATUM(melee), SKILL_DATUM(ranged))
	for(var/fuck in poggers)
		var/datum/skills/pogchamp = noob.mob.mind.mob_skills[fuck]
		if(pogchamp)
			pogchamp.level += rand(4,7)

/datum/bobux_reward/possess_mob
	name = "Possess Mob"
	desc = "Possess a mindless mob, if you're a ghost."
	buy_message = "<b>My mind seizes control over a soulless husk.</span>"
	id = "possess"
	cost = 2

/datum/bobux_reward/possess_mob/can_buy(client/noob, silent, fail_message)
	. = ..()
	if(. && noob.mob && (isobserver(noob.mob)) && length(GLOB.mob_living_list))
		return TRUE

/datum/bobux_reward/possess_mob/on_buy(client/noob)
	..()
	var/list/husks = list()
	for(var/mob/living/L in GLOB.mob_living_list)
		if(!L.mind && !L.client && !ismegafauna(L) && !istype(L, /mob/living/simple_animal/hostile/boss))
			husks |= L
	if(!length(husks))
		to_chat(noob, "<span class='bobux'>You are unable to possess any husk. Bobux refunded.</span>")
		noob.prefs?.adjust_bobux(cost)
		return FALSE
	var/mob/living/choice = input(noob, "I will take over a vessel. Which one?", "Possession", null) as mob in husks
	if(!choice)
		to_chat(noob, "<span class='bobux'>Bobux refunded.</span>")
		noob.prefs?.adjust_bobux(cost)
		return FALSE
	var/datum/mind/mind = choice.mind
	noob.mob.transfer_ckey(choice, TRUE)
	if(mind)
		var/datum/mind/our_mind = noob.mob.mind
		for(var/datum/skills/skill in our_mind.mob_skills)
			skill.level = mind.mob_skills[skill.type].level
		for(var/datum/stats/stat in our_mind.mob_stats)
			stat.level = mind.mob_stats[stat.type].level
	to_chat(noob, "<span class='deadsay'>I have taken over [choice]. The soul does not store memories, the knowledge i have gained in the afterlife no longer serves me.</span>")

/datum/bobux_reward/bounty_hunter
	name = "Bounty Hunter"
	desc = "Contract a syndicate bounty hunter, to find and kill a human target."
	buy_message = null
	id = "bounty_hunter"
	cost = 10

/datum/bobux_reward/bounty_hunter/on_buy(client/noob)
	..()
	var/list/possible_targets = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.mind)
			possible_targets |= H
	if(!length(possible_targets))
		to_chat(noob, "<span class='bobux'>You are unable to send a bounty hunter. Bobux refunded.</span>")
		noob.prefs?.adjust_bobux(cost)
		return FALSE
	var/mob/living/carbon/human/input = input(noob, "I have contracted a bounty hunter. Who is the first bounty?", "Bounty Hunter", null) as mob in possible_targets
	if(!input)
		to_chat(noob, "<span class='bobux'>You are unable to send a bounty hunter. Bobux refunded.</span>")
		noob.prefs?.adjust_bobux(cost)
		return FALSE
	else
		for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list - input))
			if((ROLE_TRAITOR in H.client?.prefs?.be_special) && (H.client?.prefs?.toggles & MIDROUND_ANTAG))
				var/datum/antagonist/traitor/bounty_hunter = H.mind.add_antag_datum(/datum/antagonist/traitor)
				for(var/datum/objective/O in bounty_hunter.objectives)
					qdel(O)
				var/datum/objective/assassinate/kill_objective = new
				kill_objective.owner = H.mind
				kill_objective.target = input.mind
				bounty_hunter.add_objective(kill_objective)
				H.mind.announce_objectives()
				return TRUE

/datum/bobux_reward/market_crash
	name = "Market Crash"
	desc = "Crash the bobux stock market... with no survivors."
	buy_message = "You're a big guy."
	id = "market_crash"
	cost = 50

/datum/bobux_reward/market_crash/on_buy(client/noob)
	. = ..()
	to_chat(world, "<span class='userdanger'><span class='big bold'>The bobux market has been bogged by [noob.key]!</span></span>")
	SEND_SOUND(world, sound('modular_skyrat/sound/misc/dumpit.ogg', volume = 50))
	var/list/bogged = flist("data/player_saves/")
	for(var/fuck in bogged)
		if(copytext(fuck, -1) != "/")
			continue
		var/list/bogged_again = flist("data/player_saves/[fuck]")
		for(var/fucked in bogged_again)
			if(copytext(fucked, -1) != "/")
				continue
			var/savefile/S = new /savefile("data/player_saves/[fuck][fucked]preferences.sav")
			if(!S)
				continue
			S.cd = "/"
			WRITE_FILE(S["bobux_amount"], 0)
	for(var/client/C in GLOB.clients)
		C.prefs?.adjust_bobux(-C.prefs.bobux_amount)
	for(var/datum/preferences/prefs in world)
		prefs.load_preferences()

/datum/bobux_reward/cum_shower
	name = "COOM"
	desc = "Make everyone cum."
	buy_message = "I'M COOOOOOOOOOOOOMING"
	id = "coom"
	cost = 25

/datum/bobux_reward/cum_shower/on_buy(client/noob)
	. = ..()
	message_admins("[noob] has made everyone COOM.")
	log_admin("[noob] has made everyone COOM.")
	SEND_SOUND(world, sound('modular_skyrat/sound/misc/coom.ogg', volume = 50))
	to_chat(world, "<span class='reallybig hypnophrase'>I'M COOMING!!!</span>")
	for(var/mob/living/carbon/human/coomer in GLOB.mob_living_list)
		coomer.moan()
		coomer.cum()

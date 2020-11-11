//the rewards themselves
/datum/bobux_reward/become_traitor
	name = "Become Traitor"
	desc = "Become a syndicate agent. Took you long to remember your mission!"
	buy_message = "<b>You remember your true purpose on the station...</span>"
	id = "become_traitor"
	cost = 5

/datum/bobux_reward/become_traitor/can_buy(client/noob, silent, fail_message)
	. = ..()
	if(. && ishuman(noob.mob) && noob.mob.mind)
		return TRUE

/datum/bobux_reward/become_traitor/on_buy(client/noob)
	. = ..()
	var/mob/living/carbon/human/H = noob.mob
	H.mind.add_antag_datum(new /datum/antagonist/traitor())

/datum/bobux_reward/become_dreamer
	name = "Become Dreamer"
	desc = "Become the dreamer. Wake up."
	buy_message = "<b>Visions...</span>"
	id = "become_dreamer"
	cost = 10

/datum/bobux_reward/become_dreamer/can_buy(client/noob, silent, fail_message)
	. = ..()
	if(. && ishuman(noob.mob) && noob.mob.mind)
		return TRUE

/datum/bobux_reward/become_dreamer/on_buy(client/noob)
	. = ..()
	var/mob/living/carbon/human/H = noob.mob
	H.mind.add_antag_datum(new /datum/antagonist/dreamer())

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
	for(var/datum/stats/stat in noob.mob.mind.mob_stats)
		stat.level += 1

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
	for(var/datum/skills/skill in noob.mob.mind.mob_skills)
		if(istype(skill, SKILL_DATUM(melee)) || istype(skill, SKILL_DATUM(ranged)))
			skill.level += rand(4,7)

/datum/bobux_reward/posses_mob
	name = "Possess Mob"
	desc = "Possess a mindless mob, if you're a ghost."
	buy_message = "<b>My mind seizes control over a soulless husk.</span>"
	id = "possess"
	cost = 2

/datum/bobux_reward/posses_mob/can_buy(client/noob, silent, fail_message)
	. = ..()
	if(. && noob.mob && (isobserver(noob.mob)) && length(GLOB.mob_living_list))
		return TRUE

/datum/bobux_reward/posses_mob/on_buy(client/noob)
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
	desc = "Contract a bounty hunter, to find and kill one or two targets."
	buy_message = null
	id = "bounty_hunter"
	cost = 10

/datum/bobux_reward/bounty_hunter/on_buy(client/noob)
	..()
	var/list/possible_targes = list()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(L.mind)
			possible_targes |= L
	if(!length(possible_targes))
		to_chat(noob, "<span class='bobux'>You are unable to send a bounty hunter. Bobux refunded.</span>")
		noob.prefs?.adjust_bobux(cost)
		return FALSE
	var/mob/living/carbon/human/input = input(noob, "I have contracted a bounty hunter. Who is the first bounty?", "Bounty Hunter", null) as mob in husks
	if(!input)
		to_chat(noob, "<span class='bobux'>You are unable to send a bounty hunter. Bobux refunded.</span>")
		noob.prefs?.adjust_bobux(cost)
		return FALSE
	else
		for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list - input))
			if((ROLE_TRAITOR in H.client?.prefs?.be_special) && (H.client?.prefs?.toggles & MIDROUND_ANTAG))
				var/datum/antagonist/bounty_hunter = H.mind.add_antag_datum(/datum/antagonist/traitor)
				var/datum/objective/assassinate/kill_objective = new
				kill_objective.owner = H.mind
				kill_objective.target = input
				bounty_hunter.add_objective(kill_objective)
				return TRUE

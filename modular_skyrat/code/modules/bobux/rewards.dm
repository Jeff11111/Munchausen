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

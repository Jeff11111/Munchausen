/datum/antagonist/communist
	name = "Communist Agent"
	antagpanel_category = "Commie"
	roundend_category = "bolsheviks"
	antag_memory = "My people have suffered for long enough on this cursed station. I must bring justice to the stowaways."
	threat = 10
	silent = FALSE
	var/commie_type = "Melee"

/datum/antagonist/communist/on_gain()
	. = ..()
	viva_la_revolucion()
	gain_stats()
	greet()

/datum/antagonist/communist/greet()
	to_chat(owner, "<span class='danger'>You are a communist stowaway.</span>")
	var/list/commies = list()
	for(var/datum/antagonist/communist/C in GLOB.antagonists)
		if(C == src)
			continue
		if(C.owner?.current?.name)
			commies |= C.owner.current.name
	if(length(commies))
		to_chat(owner, "<span class='danger'>[english_list(commies)] [length(commies) > 1 ? "are your allies" : "is your ally"].</span>")
	else
		to_chat(owner, "<span class='danger'>You have no allies on-board. Thread carefully, comrade.</span>")
	owner.announce_objectives()

/datum/antagonist/communist/proc/viva_la_revolucion()
	var/datum/objective/commie/viva = new()
	objectives += viva

/datum/antagonist/communist/proc/gain_stats()
	commie_type = pick("Melee", "Ranged", "Defense")
	switch(commie_type)
		if("Melee")
			var/datum/stats/stat = owner.mob_stats[STAT_DATUM(str)]
			stat.level += rand(8, 15)
			var/datum/skills/skill = owner.mob_skills[SKILL_DATUM(melee)]
			skill.level += rand(7, 15)
		if("Ranged")
			var/datum/stats/stat = owner.mob_stats[STAT_DATUM(dex)]
			stat.level += rand(8, 15)
			var/datum/skills/skill = owner.mob_skills[SKILL_DATUM(ranged)]
			skill.level += rand(7, 15)
		if("Defense")
			var/datum/stats/stat = owner.mob_stats[STAT_DATUM(end)]
			stat.level += rand(8, 15)
			var/datum/skills/skill = owner.mob_skills[SKILL_DATUM(melee)]
			skill.level += rand(7, 10)
			skill = owner.mob_skills[SKILL_DATUM(ranged)]
			skill.level += rand(7, 10)

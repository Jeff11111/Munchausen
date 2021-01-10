/datum/antagonist/traitor/on_gain()
	. = ..()
	if(owner)
		for(var/datum/stats/stat in owner.mob_stats)
			if(stat.fake_type)
				continue
			stat.level = min(stat.level + 1, MAX_STAT)
		var/datum/skills/ranged/ranged = owner.mob_skills[SKILL_DATUM(ranged)]
		if(ranged)
			ranged.level = min(ranged.level + rand(5,8), MAX_SKILL)
		var/datum/skills/melee/melee = owner.mob_skills[SKILL_DATUM(melee)]
		if(melee)
			melee.level = min(melee.level + rand(4,6), MAX_SKILL)

/datum/antagonist/nukeop/on_gain()
	. = ..()
	if(owner)
		for(var/statt in owner.mob_stats)
			var/datum/stats/stat = statt
			if(stat.fake_type)
				continue
			stat.level = min(stat.level + rand(4, 10), MAX_STAT)
		var/datum/skills/ranged/ranged = owner.mob_skills[SKILL_DATUM(ranged)]
		if(ranged)
			ranged.level = min(ranged.level + rand(10,20), MAX_SKILL)
		var/datum/skills/melee/melee = owner.mob_skills[SKILL_DATUM(melee)]
		if(melee)
			melee.level = min(melee.level + rand(10,20), MAX_SKILL)
		var/datum/skills/firstaid/firstaid = owner.mob_skills[SKILL_DATUM(firstaid)]
		if(firstaid)
			firstaid.level = min(melee.level + rand(10,20), MAX_SKILL)

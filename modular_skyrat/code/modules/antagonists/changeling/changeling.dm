/datum/antagonist/changeling/on_gain()
	. = ..()
	if(owner)
		for(var/statt in owner.mob_stats)
			var/datum/stats/stat = statt
			if(stat.fake_type)
				continue
			stat.level = min(stat.level + rand(4, 10), MAX_STAT)
		var/datum/skills/melee/melee = owner.mob_skills[SKILL_DATUM(melee)]
		if(melee)
			melee.level = min(melee.level + rand(10,20), MAX_SKILL)

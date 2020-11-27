//Mind holders for stats and skills
//Every mind spawns by default with average skills at everything
/datum/mind
	var/list/datum/stats/mob_stats = list()
	var/list/datum/skills/mob_skills = list()

/datum/mind/New(key)
	. = ..()
	InitializeStats()
	InitializeSkills()

/datum/mind/Destroy()
	. = ..()
	//The defines for deleting lists weren't working, have some cumcode
	for(var/i in mob_stats)
		qdel(mob_stats[i])
		mob_stats[i] = null
	for(var/i in mob_skills)
		qdel(mob_skills[i])
		mob_skills[i] = null
	mob_stats = null
	mob_skills = null

/datum/mind/proc/InitializeStats()
	for(var/thing in init_subtypes(/datum/stats))
		var/datum/stats/S = thing
		mob_stats[S.type] = S

/datum/mind/proc/InitializeSkills()
	for(var/thing in init_subtypes(/datum/skills))
		var/datum/skills/S = thing
		mob_skills[S.type] = S

//Humans always see their stats
/mob/living/carbon/human/Stat(Name, Value)
	. = ..()
	if(statpanel("Status"))
		var/list/stats = list()
		for(var/i in mind?.mob_stats)
			var/datum/stats/mystat = mind.mob_stats[i]
			stats |= mystat
			if(mystat.fake_type)
				for(var/y in stats)
					if(istype(y, mystat.fake_type))
						stats -= y
		var/list/stat_string = list()
		for(var/i in mind?.mob_stats)
			var/datum/stats/mystat = mind.mob_stats[i]
			if(mystat.fake_type)
				continue
			stat_string |= "[mystat.shorthand]: [mystat.level]"
		if(length(stat_string))
			stat(null, "\n\n[stat_string.Join("\n\n")]\n\n")

/datum/antagonist/communist
	name = "Communist Agent"
	antagpanel_category = "Commie"
	roundend_category = "bolsheviks"
	antag_memory = "My people have suffered for long enough on this cursed station. I must bring justice to the stowaways."
	threat = 10
	silent = FALSE

/datum/antagonist/communist/on_gain()
	. = ..()
	viva_la_revolucion()
	gain_stats()

/datum/antagonist/communist/proc/viva_la_revolucion()
	var/datum/objective/commie/viva = new()
	objectives += viva

/datum/antagonist/communist/proc/gain_stats()
	var/commie_type = pick("Melee", "Ranged", "Defense")
	switch(commie_type)
		if("Melee")
			var/datum/stats/stat = owner.mob_stats[STAT_DATUM(str)]
			stat.level += rand(8, 15)
			var/datum/skills/skill = owner.mob_skills[SKILL_DATUM(melee)]
			skill.level += rand(7, 15)
			var/obj/item/kitchen/knife/butcher/butcher = new(owner.current)
			if(!owner.current.put_in_hands(butcher))
				qdel(butcher)
		if("Ranged")
			var/datum/stats/stat = owner.mob_stats[STAT_DATUM(dex)]
			stat.level += rand(8, 15)
			var/datum/skills/skill = owner.mob_skills[SKILL_DATUM(ranged)]
			skill.level += rand(7, 15)
			var/obj/item/gun/ballistic/revolver/doublebarrel/bobox/bobox = new(owner.current)
			if(!owner.current.put_in_hands(bobox))
				qdel(bobox)
		if("Defense")
			var/datum/stats/stat = owner.mob_stats[STAT_DATUM(end)]
			stat.level += rand(8, 15)
			var/datum/skills/skill = owner.mob_skills[SKILL_DATUM(melee)]
			skill.level += rand(7, 10)
			skill = owner.mob_skills[SKILL_DATUM(ranged)]
			skill.level += rand(7, 10)
			var/obj/item/clothing/suit/armor/riot/riot = new(owner.current)
			if(!owner.current.put_in_hands(riot))
				qdel(riot)

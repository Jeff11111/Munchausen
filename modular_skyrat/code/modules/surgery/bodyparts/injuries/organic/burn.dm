/** BURNS **/
/datum/injury/burn
	damage_type = WOUND_BURN
	max_bleeding_stage = 0

/datum/injury/burn/is_bleeding()
	return FALSE //burns cannot bleed

/datum/injury/burn/receive_damage(damage_received = 0, pain_received = 0, damage_type = WOUND_BLUNT)
	if((wound_damage() + (damage_received/2) >= 40) && parent_bodypart && !parent_bodypart.is_dead())
		parent_mob?.wound_message += " \The [parent_bodypart.name] fully melts away!"
		parent_bodypart.kill_limb()

/datum/injury/burn/moderate
	stages = list(
		"ripped burn" = 10,
		"moderate burn" = 5,
		"healing moderate burn" = 2,
		"fresh skin" = 0
		)

/datum/injury/burn/large
	stages = list(
		"ripped large burn" = 20,
		"large burn" = 15,
		"healing large burn" = 5,
		"fresh skin" = 0
		)

/datum/injury/burn/severe
	stages = list(
		"ripped severe burn" = 35,
		"severe burn" = 30,
		"healing severe burn" = 10,
		"burn scar" = 0
		)
	fade_away = INFINITY

/datum/injury/burn/deep
	stages = list(
		"ripped deep burn" = 45,
		"deep burn" = 40,
		"healing deep burn" = 15,
		"large burn scar" = 0
		)
	fade_away = INFINITY

/datum/injury/burn/carbonised
	stages = list(
		"carbonised area" = 50,
		"healing carbonised area" = 20,
		"massive burn scar" = 0
		)
	fade_away = INFINITY

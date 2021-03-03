/** BURNS **/
/datum/injury/burn
	damage_type = WOUND_BURN
	max_bleeding_stage = 0
	infection_rate = 2.5

/datum/injury/burn/infection_check()
	if(is_treated() && damage < 25)	//anything less than a FUCK burn isn't infectable if treated properly
		return FALSE
	if(required_status & BODYPART_ROBOTIC) //Robotic injury
		return FALSE

	switch(damage_type)
		if(WOUND_BLUNT)
			return prob(damage/2)
		if(WOUND_BURN)
			return prob(damage*2)
		if(WOUND_SLASH)
			return prob(damage)
		if(WOUND_PIERCE)
			return prob(damage*1.25)

	return FALSE

/datum/injury/burn/is_bleeding()
	return FALSE //burns cannot bleed

/datum/injury/burn/apply_injury(our_damage, obj/item/bodypart/limb)
	. = ..()
	//Burn damage can cause fluid loss due to blistering and cook-off
	if(limb.owner && (damage >= 5 || damage + limb.burn_dam >= 20))
		limb.owner.blood_volume -= (BLOOD_VOLUME_SURVIVE * damage/(limb.owner.maxHealth/2))
		if(limb.owner.blood_volume < 0)
			limb.owner.blood_volume = 0

/datum/injury/burn/receive_damage(damage_received = 0, pain_received = 0, damage_type = WOUND_BLUNT)
	if((damage_type == WOUND_BURN) && (wound_damage() + damage_received >= 40) && parent_bodypart)
		if(!parent_bodypart.is_dead())
			if(parent_bodypart.is_organic_limb())
				parent_mob?.wound_message += " \The [parent_bodypart.name] partially melts away!"
				parent_bodypart.kill_limb()
			else
				if(parent_bodypart.can_dismember())
					parent_mob?.wound_message += " \The [parent_bodypart.name] fully melts away!"
					parent_bodypart.apply_dismember(WOUND_BURN)
		else if(parent_bodypart.can_dismember())
			if(parent_bodypart.is_organic_limb())
				parent_mob?.wound_message += " \The [parent_bodypart.name] partially melts away!"
				parent_bodypart.kill_limb()
			else
				parent_mob?.wound_message += " \The [parent_bodypart.name] fully melts away!"
				parent_bodypart.apply_dismember(WOUND_BURN)

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
		"fresh burn scar" = 0
		)
	fade_away = INFINITY

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

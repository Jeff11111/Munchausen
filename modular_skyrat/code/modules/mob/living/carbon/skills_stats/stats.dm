//All of the stat datums used ingame

//Strength
/datum/stats/str
	name = "Strength"
	shorthand = "ST"

/datum/stats/str/proc/get_equip_slowdown_mult()
	return round(1.5 - (1 * level/MAX_STAT), 0.1) //Varies from 1.5 to 0.5 depending on how good/bad we are

//Fake str, used by the dreamer
/datum/stats/fakestr
	name = "Fake Strength"
	shorthand = "ST"
	level =  0
	fake_type = /datum/stats/str

//Endurance
/datum/stats/end
	name = "Endurance"
	shorthand = "EN"

/datum/stats/proc/get_shock_mult() //this is stupid
	return 1

/datum/stats/end/get_shock_mult()
	switch(level)
		if(-INFINITY to 1)
			return 2.5
		if(2 to 5)
			return (2.5 - (level/(MAX_STAT/2)))
		if(6 to 9)
			return (2 - (level/(MAX_STAT/2)))
		if(10 to 19)
			return (1.5 - (level/(MAX_STAT/2)))
		if(20 to INFINITY)
			return max(0.1, 0.2 - max(0, (22 - level)/10))

//Dexterity
/datum/stats/dex
	name = "Dexterity"
	shorthand = "DX"

/datum/stats/dex/proc/get_ran_zone_prob(base_prob = 50, level_prob = 50)
	return base_prob + (level_prob * level/MAX_STAT)

/datum/stats/dex/proc/get_click_mod()
	return round(1.25 - (0.5 * level/MAX_STAT), 0.1) //Varies from 1.25 to 0.75 depending on how good/bad we are

/datum/stats/dex/proc/get_base_miss_chance()
	return (20 - level)

/datum/stats/dex/proc/get_miss_stamina_mult()
	return round(1.5 - (level/MAX_STAT), 0.1)

/datum/stats/dex/proc/get_disarm_mult()
	return round(max(2 - (level/MAX_STAT * 2), 0.1), 0.1)

//Intelligence
/datum/stats/int
	name = "Intellect"
	shorthand = "IQ"

/datum/stats/int/statnumtodesc(stat)
	switch(stat)
		if(-INFINITY to 6)
			return "crippling"
		if(7)
			return "poor"
		if(8,9)
			return "below average"
		if(10)
			return "average"
		if(11,12)
			return "above average"
		if(13,14)
			return "exceptional"
		if(15,16)
			return "amazing"
		if(17,18)
			return "legendary"
		if(19,20)
			return "divine"
		if(21 to INFINITY)
			return "divine"
		else
			return "inhuman"

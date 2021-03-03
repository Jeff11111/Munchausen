//All of the skill datums used ingame
/datum/skills/melee
	name = "Melee Combat"

/datum/skills/ranged
	name = "Ranged Combat"

/datum/skills/throwing
	name = "Throwing"

/datum/skills/firstaid
	name = "Medicine"

/datum/skills/firstaid/proc/get_medicalstack_mod()
	return clamp(2 - level/10, 0.1, 2)

/datum/skills/surgery
	name = "Surgery"

/datum/skills/surgery/proc/no_anesthesia_punishment()
	return (0.2 + CEILING((MAX_SKILL - level) * 0.03, 0.1))

/datum/skills/surgery/proc/get_speed_mod()
	return clamp((MAX_SKILL/2)/max(1, level), 0.35, 3)

/datum/skills/surgery/proc/get_probability_mod()
	return clamp((MAX_SKILL/2)/max(1, level), 0.35, 3)

/datum/skills/chemistry
	name = "Chemistry"

/datum/skills/construction
	name = "Construction"

/datum/skills/electronics
	name = "Electronics"

/datum/skills/research
	name = "Research"

/datum/skills/cooking
	name = "Cooking"

/datum/skills/agriculture
	name = "Agriculture"

/datum/skills/gaming
	name = "Gaming"

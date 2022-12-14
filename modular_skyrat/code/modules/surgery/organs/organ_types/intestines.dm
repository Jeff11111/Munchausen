//Intestines: Help with nutrition and stuff
//Most intestine code is done in species.dm
/obj/item/organ/intestines
	name = "intestines"
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "intestines"
	desc = "Used to strangle your enemies. Or, you know, to process nutrients."
	gender = PLURAL
	slot = ORGAN_SLOT_INTESTINES
	zone = BODY_ZONE_PRECISE_GROIN
	low_threshold = 25
	high_threshold = 40
	maxHealth = 50
	relative_size = 30
	var/extra_defecation_gain = 0

/obj/item/organ/intestines/proc/get_defecation_gain()
	if(damage >= low_threshold)
		if(!is_working())
			return (2 + extra_defecation_gain)
		return (1 + (1 * damage/maxHealth) + extra_defecation_gain)
	else
		return (1 + extra_defecation_gain)

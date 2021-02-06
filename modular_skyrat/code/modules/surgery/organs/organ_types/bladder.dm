//Bladder: Help with pissing and stuff
//Most bladder code is done in species.dm
/obj/item/organ/bladder
	name = "bladder"
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "bladder"
	desc = "Unlike sharks you don't use this to float."
	gender = PLURAL
	slot = ORGAN_SLOT_BLADDER
	zone = BODY_ZONE_PRECISE_GROIN
	low_threshold = 25
	high_threshold = 40
	maxHealth = 50
	relative_size = 20
	var/extra_urination_gain = 0

/obj/item/organ/bladder/proc/get_urination_gain()
	if(damage >= low_threshold)
		if(!is_working())
			return (2 + extra_urination_gain)
		return (1 + (1 * damage/maxHealth) + extra_urination_gain)
	else
		return (1 + extra_urination_gain)

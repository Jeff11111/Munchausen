/mob/proc/getorgan(typepath)
	return

/mob/proc/getorganszone(zone)
	return

/mob/proc/getorganslot(slot)
	return

/mob/living/carbon/getorgan(typepath)
	return (locate(typepath) in internal_organs)

/mob/living/carbon/getorganszone(zone, subzones = TRUE)
	. = list()
	if(subzones)
		// Include subzones - groin for chest, eyes and mouth for head
		if(zone == BODY_ZONE_HEAD)
			. |= getorganszone(BODY_ZONE_PRECISE_EYES)
			. |= getorganszone(BODY_ZONE_PRECISE_MOUTH)
			. |= getorganszone(BODY_ZONE_PRECISE_THROAT)
	
	for(var/obj/item/organ/O in internal_organs)
		if(zone == O.zone)
			. |= O

/mob/living/carbon/getorganslot(slot)
	return internal_organs_slot[slot]

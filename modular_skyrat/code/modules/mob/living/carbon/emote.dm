//cant emote proper if you are george floyd and cant breathe
/mob/living/carbon/emote(act, m_type = null, message = null, intentional = FALSE)
	. = ..()
	var/obj/item/organ/lungs/cum = getorganslot(ORGAN_SLOT_LUNGS)
	if(is_asystole() || (needs_lungs() && (!cum || cum.is_broken())))
		if(!(act in list("scream", "screams", "agonyscream", "agonyscreams")))
			act = "quietnoise"
		else
			act = "loudnoise"

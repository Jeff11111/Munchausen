//cant emote proper if you are george floyd and cant breathe
/mob/living/carbon/emote(act, m_type = null, message = null, intentional = FALSE)
	var/obj/item/organ/lungs/cum = getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/bodypart/mouth/shit = get_bodypart(BODY_ZONE_PRECISE_MOUTH)
	if(is_asystole() || needs_lungs() && (!cum || cum.is_broken()))
		if(!(act in list("scream", "screams", "agonyscream", "agonyscreams")))
			act = "quietnoise"
		else
			act = "loudnoise"
	if(!shit || shit.is_disabled())
		return agony_gargle()
	return ..()

//cant emote proper if you are george floyd and cant breathe
/mob/living/carbon/emote(act, m_type = null, message = null, intentional = FALSE)
	act = lowertext(act)
	var/param = message
	var/custom_param = findchar(act, " ")
	var/obj/item/organ/lungs/cum = getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/bodypart/mouth/shit = get_bodypart_nostump(BODY_ZONE_PRECISE_MOUTH)
	if(custom_param)
		param = copytext(act, custom_param + length(act[custom_param]))
		act = copytext(act, 1, custom_param)

	var/datum/emote/E
	E = E.emote_list[act]
	if(E.emote_type == EMOTE_AUDIBLE)
		if(is_asystole() || needs_lungs() && (!cum || cum.is_broken()))
			if(!(act in list("scream", "screams", "agonyscream", "agonyscreams")))
				E = E.emote_list["quietnoise"]
			else
				E = E.emote_list["loudnoise"]
		if(!shit || shit.is_disabled())
			E = E.emote_list["gargle"]
	if(!E)
		to_chat(src, "<span class='notice'>Unusable emote '[act]'. Say *help for a list.</span>")
		return
	
	E.run_emote(src, param, m_type, intentional)

//asystole or no lung niggas cant emote proper
/mob/living/carbon/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	var/obj/item/organ/lungs/cum = getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/bodypart/mouth/shit = get_bodypart(BODY_ZONE_PRECISE_MOUTH)
	if(is_asystole() || needs_lungs() && (!cum || cum.is_broken()))
		return emote("loudnoise")
	if(!shit || shit.is_disabled())
		return emote("gargle")
	. = ..()

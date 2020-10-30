//bracelets - shitty headsets that you cant use while incapacitated
/obj/item/radio/headset/bracelet
	name = "cheap bracelet"
	desc = "A cheap electronic bracelet, used as a cheap alternative to a radio headset."
	body_parts_covered = HANDS
	slot_flags = ITEM_SLOT_WRISTS

/obj/item/radio/headset/bracelet/talk_into(mob/living/M, message, channel, list/spans,datum/language/language, direct=TRUE)
	if(!direct || !ismob(M) || (M.mobility_flags & MOBILITY_USE)) // if can't use items, you can't press the button
		return ..()

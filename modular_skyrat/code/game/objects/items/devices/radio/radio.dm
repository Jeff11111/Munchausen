//Makes it so syndicate borgs dont transmit their radio so well. Due to how comms work there isn't really a better way unless you were to touch comms
/obj/item/radio/borg/syndicate
	canhear_range = 0

//People in shock cannot use le radio
/obj/item/radio/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/boombox, (slot_flags & ITEM_SLOT_EARS ? FALSE : TRUE), 100, 7)

//Le
/obj/item/radio/talk_into(atom/movable/M, message, channel, list/spans, datum/language/language, direct)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.InFullShock() || (C.get_shock() >= PAIN_GIVES_IN))
			to_chat(C, "<span class='warning'>I'm too hurt to reach into [src]!</span>")
			return FALSE
		else if(!C.DirectAccess(src))
			return FALSE
	. = ..()
	
//Makes it so syndicate borgs dont transmit their radio so well. Due to how comms work there isn't really a better way unless you were to touch comms
/obj/item/radio/borg/syndicate
	canhear_range = 0

/obj/item/radio/headset
	slot_flags = ITEM_SLOT_EARS

/obj/item/radio/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/boombox, (slot_flags & ITEM_SLOT_EARS ? FALSE : TRUE), 100, 7)

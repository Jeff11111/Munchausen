//Cassette tape, which holds the music for boomboxes
/obj/item/device/cassette
	name = "cassette"
	desc = "A tape containing some boppin' tunes."
	icon = 'modular_skyrat/icons/obj/bobstation/items/cassette.dmi'
	icon_state = "cassette"
	w_class = WEIGHT_CLASS_TINY
	//Used in examine
	var/vibing_string = ""
	//Our selected sound datum
	var/sound/current_tune
	//Music, name associated with their respective sound datums
	//starts out as name equalling file path
	var/list/all_tunes = list()

/obj/item/device/cassette/Initialize()
	. = ..()
	for(var/bingus in all_tunes)
		var/pog = all_tunes[bingus]
		all_tunes[bingus] = sound(pog, FALSE, 0, CHANNEL_JUKEBOX, 100)
	var/fuck = pick(all_tunes)
	vibing_string = fuck
	current_tune = all_tunes[fuck]

/obj/item/device/cassette/examine(mob/user)
	. = ..()
	. += "<span class='info'>Current track: [vibing_string]</span>"

/obj/item/device/cassette/middleclick_attack_self(mob/user)
	return middle_attack_hand(user)

/obj/item/device/cassette/middle_attack_hand(mob/user)
	var/list/tunes = list()
	for(var/pog in all_tunes)
		tunes |= pog
	if(!length(tunes))
		return FALSE
	var/tune = input(user, "What song should i pick?", "Vibing", null) as null|anything in tunes
	if(tune)
		vibing_string = tune
		current_tune = all_tunes[tune]
	to_chat(user, "<span class='info'>\The [src] is now vibing to <b>[tune]</b>.</span>")
	return TRUE

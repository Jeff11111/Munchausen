//The boombox component itself
/datum/component/boombox
	var/obj/item/device/cassette/current_cassette
	var/loud = TRUE
	var/volume = 100
	var/range = 7
	var/list/obj/item/device/cassette/stored_cassettes = list()

/datum/component/boombox/Initialize(_loud = TRUE, _volume = 100, _range = 7)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	loud = _loud
	volume = _volume
	range = _range
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/check_for_cassete)
	RegisterSignal(parent, COMSIG_CLICK_MIDDLE, .proc/options)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine_message)

/datum/component/boombox/proc/check_for_cassete(datum/source, obj/item/device/cassette/tuner, mob/user, params)
	if(!istype(tuner))
		return FALSE
	playsound(parent, 'modular_skyrat/sound/misc/cassette.ogg', 60)
	tuner.forceMove(parent)
	current_cassette = tuner
	to_chat(user, "<span class='notice'>I insert \the [tuner] into \the [parent]'s cassette player.</span>")
	return TRUE

/datum/component/boombox/proc/options(datum/source, mob/user)
	var/option = input(user, "What do i want to do with [parent]'s cassette module?", "Cassette Options", null) as null|anything in list("Toggle Loudness", "Change Range", "Change Volume", "Take Cassette Out", "Smash the play button")
	switch(option)
		if("Toggle Loudness")
			loud = !loud
			to_chat(user, "<span class='notice'>\The [parent] is now playing cassettes [loud ? "loudly" : "locally"].</span>")
		if("Change Range")
			var/newrange = input(user, "What range (0-10)?", "Cassette Range", 7) as num
			range = min(10, newrange)
		if("Change Volume")
			volume = input(user, "What volume (1-100)?", "Cassette Volume", 100) as num
		if("Take Cassette Out")
			if(!current_cassette)
				if(user.mind && (GET_STAT_LEVEL(user, int) <= 7))
					playsound(parent, 'modular_skyrat/sound/misc/cassette.ogg', 60)
					to_chat(user, "<span class='notice'>Uhhhhhhhhhhhhhhhhhhhhh.</span>")
				else
					to_chat(user, "<span class='warning'>What cassette?</span>")
				return TRUE
			playsound(parent, 'modular_skyrat/sound/misc/cassette.ogg', 60)
			current_cassette.forceMove(get_turf(user))
			user.put_in_hands(current_cassette)
			to_chat(user, "<span class='notice'>I take \the [current_cassette] out of \the [parent].</span>")
			current_cassette = null
		if("Smash the play button")
			if(!current_cassette)
				if(user.mind && (GET_STAT_LEVEL(user, int) <= 7))
					playsound(parent, 'modular_skyrat/sound/misc/cassette.ogg', 60)
					to_chat(user, "<span class='warning'>I smash the play button - It does absolutely nothing.</span>")
				else
					to_chat(user, "<span class='warning'>Play what?</span>")
				return TRUE
			if(loud)
				for(var/mob/M in view(parent, range))
					M.stop_sound_channel(CHANNEL_JUKEBOX)
				playsound(parent, current_cassette.current_tune, volume, 0, 7 - range)
			else
				user.stop_sound_channel(CHANNEL_JUKEBOX)
				user.playsound_local(parent, current_cassette.current_tune, volume, 0, 7 - range)
			to_chat(user, "<span class='warning'>I smash the play button on \the [parent]. Nice.</span>")
	return TRUE

/datum/component/boombox/proc/examine_message(datum/source, mob/user, list/examine_list)
	var/atom/A = parent
	examine_list += "<span class='info'>[capitalize(A.name)] can play cassette tapes.</span>"
	examine_list += "<span class='info'><b>Volume:</b> [volume] ([loud ? "Loud" : "Local"])"
	if(current_cassette)
		examine_list += "<span class='info'><b>Current track:</b> [current_cassette.vibing_string]</span>"

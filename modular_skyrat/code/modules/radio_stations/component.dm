/datum/component/radio_station
	var/current_station = "Chungus FM"
	var/loud = TRUE
	var/volume = 100
	var/range = 7
	var/active = FALSE

/datum/component/radio_station/Initialize(_active = FALSE, _current_station = "Chungus FM", _loud = TRUE, _volume = 100, _range = 7)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	active = _active
	current_station = _current_station
	loud = _loud
	volume = _volume = 100
	range = _range
	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/toggle)
	RegisterSignal(parent, COMSIG_CLICK_MIDDLE, .proc/do_music)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/vibe_examine)
	SSradio_stations.radio_components |= src

/datum/component/radio_station/Destroy(force, silent)
	. = ..()
	SSradio_stations.radio_components -= src

/datum/component/radio_station/proc/toggle(datum/source, mob/user)
	active = !active
	if(user)
		to_chat("<span class='notice'>You [active ? "activate" : "deactive"] [parent]'s radio station module.</span>")

/datum/component/radio_station/proc/do_music(datum/source, mob/user)
	if(!active)
		return FALSE
	
	if(!current_station)
		if(user)
			to_chat(user, "<span class='notice'>What station, retard?</span>")
		return TRUE
	if(loud)
		for(var/mob/M in view(range, src))
			M.stop_sound_channel(CHANNEL_JUKEBOX)
	else
		var/mob/M = parent.loc
		if(istype(M))
			M.stop_sound_channel(CHANNEL_JUKEBOX)
	if(user)
		user.visible_message("<span class='notice'>[user] smashes the play music button on [parent].</span>",\
							"<span class='notice'>You smash the play music button on [parent].</span>")
	if(loud)
		playsound(parent, SSradio_stations.station_assoc_sounds[current_station], volume, range - 7, 0)
	else
		user.playsound_local(parent, SSradio_stations.station_assoc_sounds[current_station], volume, range - 7, 0)
	return TRUE

/datum/component/radio_station/proc/vibe_examine(datum/source, mob/user, list/examine_list)
	if(!active)
		return
	
	var/out = "\n<span class='info'><b>Radio station information:</b>\n"
	out += "Selected station: [current_station ? current_station : "None"]\n"
	if(current_station)
		var/sound/playing = SSradio_stations.station_assoc_sounds[current_station]
		out += "Currently playing: [playing.file]"
	out += "Volume: [volume] ([loud ? "<b>Loud</b>" : "Local"])\n"
	if(loud)
		out += "Range: [range]\n"
	out += "</span>"
	examine_list += out

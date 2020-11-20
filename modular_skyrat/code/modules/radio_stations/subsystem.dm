SUBSYSTEM_DEF(radio_stations)
	name = "Radio Stations"
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 4 SECONDS
	//All radio stations
	var/list/stations = list()
	//Radio stations associated with list of music file paths
	var/list/station_assoc_files = list()
	//Radio stations associated with their current sound datums
	var/list/station_assoc_sounds = list()
	//Radio stations associated with the time they should play their next tracks
	var/list/station_assoc_next_tracks = list()
	//Radio station components that need to be updated and shit associated with their current station
	var/list/radio_components = list()

/datum/controller/subsystem/radio_stations/Initialize(start_timeofday)
	. = ..()
	//Get the radio stations from a config file
	var/list/poggers_music = world.file2list('config/radio_stations/stations.txt')
	for(var/fuck in poggers_music)
		var/station = copytext(fuck, 1, findtext(fuck, "=")-1)
		var/path = copytext(fuck, findtext(fuck, "=")+1)
		stations |= station
		var/list/circumcise_files = flist("config/radio_stations/[path]/")
		for(var/jew in circumcise_files)
			jew = "config/radio_stations/[path]/[jew]"
		station_assoc_files[station] = circumcise_files
		var/sound/sounding = sound(pick(station_assoc_files[station]), FALSE, 0, CHANNEL_JUKEBOX, 100)
		station_assoc_sounds[station] = sounding
		station_assoc_next_tracks[station] = world.time + sounding.len SECONDS

/datum/controller/subsystem/radio_stations/fire(resumed)
	. = ..()
	for(var/station in stations)
		if(world.time >= station_assoc_sounds[station])
			var/sound/sounding = sound(pick(station_assoc_files[station]), FALSE, 0, CHANNEL_JUKEBOX, 100)
			station_assoc_sounds[station] = sounding
			station_assoc_next_tracks[station] = world.time + sounding.len SECONDS
			update_sounding()

/datum/controller/subsystem/radio_stations/proc/update_sounding(station)
	for(var/datum/component/radio_station/bingus in radio_components)
		if(radio_components[bingus] == station)
			bingus.do_music()

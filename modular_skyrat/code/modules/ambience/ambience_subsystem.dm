SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME
	wait = 10 SECONDS
	var/current_generic
	var/list/generic_ambience = list()
	var/time_to_fire = 0

/datum/controller/subsystem/ambience/fire(resumed)
	. = ..()
	if(SSticker.current_state == GAME_STATE_PLAYING)
		if(world.time >= time_to_fire)
			do_funny(TRUE)

/datum/controller/subsystem/ambience/Initialize(start_timeofday)
	. = ..()
	for(var/file in world.file2list("config/generic_ambience.txt"))
		generic_ambience |= file("[file]")

/datum/controller/subsystem/ambience/proc/select_generic()
	if(length(generic_ambience))
		current_generic = pick(generic_ambience)
		return TRUE

/datum/controller/subsystem/ambience/proc/do_funny(new_ambience = FALSE)
	if(new_ambience)
		select_generic()
	if(!current_generic)
		return
	var/sound/S = sound(current_generic, FALSE, 0, CHANNEL_AMBIENT, 30)
	time_to_fire = world.time + S.len SECONDS
	SEND_SOUND(world, S)

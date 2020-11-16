SUBSYSTEM_DEF(ambience)
	name = "Ambience"
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_GAME
	var/current_generic
	var/list/generic_ambience = list()

/datum/controller/subsystem/ambience/Initialize(start_timeofday)
	. = ..()
	for(var/file in world.file2list("config/generic_ambience.txt"))
		generic_ambience |= file("[file]")
	select_generic()

/datum/controller/subsystem/ambience/proc/select_generic()
	if(length(generic_ambience))
		current_generic = pick(generic_ambience)

/datum/controller/subsystem/ambience/proc/do_funny(new_ambience = FALSE)
	if(new_ambience)
		select_generic
	if(!current_generic)
		return
	var/sound/S = sound(current_generic, FALSE, 0, CHANNEL_AMBIENCE, 50)
	SEND_SOUND(world, S)
	addtimer(CALLBACK(src, .proc/do_funny, TRUE), S.len SECONDS)

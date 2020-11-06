SUBSYSTEM_DEF(aspects)
	name = "Aspects"
	flags = SS_BACKGROUND
	var/datum/aspect/chosen_aspect
	var/list/aspect_datums = list()

/datum/controller/subsystem/aspects/proc/announce_aspect()
	if(!chosen_aspect)
		to_chat(world, "<span class='notice'>This shift has no aspect!</span>")
		return FALSE
	to_chat(world, "<span class='notice'>This shift's aspect is: [chosen_aspect.name]</span>")
	spawn(3)
		to_chat(world, "<span class='info'>[chosen_aspect.desc]</span>")
	return TRUE

/datum/controller/subsystem/aspects/Initialize(start_timeofday)
	. = ..()
	for(var/chungus in init_subtypes(/datum/aspect))
		aspect_datums |= chungus
	if(length(aspect_datums))
		chosen_aspect = pick(aspect_datums)
	if(chosen_aspect)
		chosen_aspect.on_initialize()

#define BAD_INIT_QDEL_BEFORE 1
#define BAD_INIT_DIDNT_INIT 2
#define BAD_INIT_SLEPT 4
#define BAD_INIT_NO_HINT 8

SUBSYSTEM_DEF(atoms)
	name = "Atoms"
	init_order = INIT_ORDER_ATOMS
	flags = SS_NO_FIRE

	var/old_initialized

	var/list/late_loaders

	var/list/BadInitializeCalls = list()

/datum/controller/subsystem/atoms/Initialize(timeofday)
	GLOB.fire_overlay.appearance_flags = RESET_COLOR
	initialized = INITIALIZATION_INNEW_MAPLOAD
	InitializeAtoms()
	return ..()

/datum/controller/subsystem/atoms/proc/InitializeAtoms(list/atoms)
	if(initialized == INITIALIZATION_INSSATOMS)
		return

	initialized = INITIALIZATION_INNEW_MAPLOAD

	LAZYINITLIST(late_loaders)

	var/count
	var/list/mapload_arg = list(TRUE)
	if(atoms)
		count = atoms.len
		for(var/I in atoms)
			var/atom/A = I
			if(!(A.flags_1 & INITIALIZED_1))
				InitAtom(I, mapload_arg)
				CHECK_TICK
	else
		count = 0
		for(var/atom/A in world)
			if(!(A.flags_1 & INITIALIZED_1))
				InitAtom(A, mapload_arg)
				++count
				CHECK_TICK

	testing("Initialized [count] atoms")
	pass(count)

	initialized = INITIALIZATION_INNEW_REGULAR

	if(late_loaders.len)
		for(var/I in late_loaders)
			var/atom/A = I
			A.LateInitialize()
		testing("Late initialized [late_loaders.len] atoms")
		late_loaders.Cut()
	var/list/bruh = list(/mob/living/simple_animal/hostile/megafauna/dragon = 0,\
						/mob/living/simple_animal/hostile/megafauna/colossus = 0,\
						/mob/living/simple_animal/hostile/megafauna/bubblegum = 0)
	var/list/accept_turfs = (GLOB.spawned_turfs - GLOB.success_spawned_turfs)
	for(var/mob/living/simple_animal/hostile/megafauna/M in GLOB.mob_living_list)
		if(bruh[M.type])
			bruh[M.type]++
	var/attempts = 0
	for(var/I in bruh)
		attempts = 0
		while(get_mega_count(I) < 1)
			if(attempts >= 30)
				testing("Static megafauna spawning failed after [attempts] attempts.")
				break
			attempts++
			if(length(accept_turfs))
				var/turf/open/floor/plating/asteroid/airless/cave/T = pick_n_take(accept_turfs)
				if(istype(T))
					if(T.BruteForceSpawn(I))
						break
			else
				testing("Static megafauna spawning ran out of possible turfs to spawn on.")
				break
	attempts = 0
	while(get_tendril_count(/obj/structure/spawner/lavaland/legion) < 1)
		if(attempts >= 30)
			testing("Static tendril spawning failed after [attempts] attempts.")
			break
		attempts++
		if(length(accept_turfs))
			var/turf/open/floor/plating/asteroid/airless/cave/T = pick_n_take(accept_turfs)
			if(istype(T))
				if(T.BruteForceTendril(/obj/structure/spawner/lavaland/legion))
					break
		else
			testing("Static tendril spawning ran out of possible turfs to spawn on.")
			break
	//

/datum/controller/subsystem/atoms/proc/InitAtom(atom/A, list/arguments)
	var/the_type = A.type
	if(QDELING(A))
		BadInitializeCalls[the_type] |= BAD_INIT_QDEL_BEFORE
		return TRUE

	var/start_tick = world.time

	var/result = A.Initialize(arglist(arguments))

	if(start_tick != world.time)
		BadInitializeCalls[the_type] |= BAD_INIT_SLEPT

	var/qdeleted = FALSE

	if(result != INITIALIZE_HINT_NORMAL)
		switch(result)
			if(INITIALIZE_HINT_LATELOAD)
				if(arguments[1])	//mapload
					late_loaders += A
				else
					A.LateInitialize()
			if(INITIALIZE_HINT_QDEL)
				qdel(A)
				qdeleted = TRUE
			else
				BadInitializeCalls[the_type] |= BAD_INIT_NO_HINT

	if(!A)	//possible harddel
		qdeleted = TRUE
	else if(!(A.flags_1 & INITIALIZED_1))
		BadInitializeCalls[the_type] |= BAD_INIT_DIDNT_INIT

	return qdeleted || QDELING(A)

/datum/controller/subsystem/atoms/proc/map_loader_begin()
	old_initialized = initialized
	initialized = INITIALIZATION_INSSATOMS

/datum/controller/subsystem/atoms/proc/map_loader_stop()
	initialized = old_initialized

/datum/controller/subsystem/atoms/Recover()
	initialized = SSatoms.initialized
	if(initialized == INITIALIZATION_INNEW_MAPLOAD)
		InitializeAtoms()
	old_initialized = SSatoms.old_initialized
	BadInitializeCalls = SSatoms.BadInitializeCalls

/datum/controller/subsystem/atoms/proc/InitLog()
	. = ""
	for(var/path in BadInitializeCalls)
		. += "Path : [path] \n"
		var/fails = BadInitializeCalls[path]
		if(fails & BAD_INIT_DIDNT_INIT)
			. += "- Didn't call atom/Initialize()\n"
		if(fails & BAD_INIT_NO_HINT)
			. += "- Didn't return an Initialize hint\n"
		if(fails & BAD_INIT_QDEL_BEFORE)
			. += "- Qdel'd in New()\n"
		if(fails & BAD_INIT_SLEPT)
			. += "- Slept during Initialize()\n"

/datum/controller/subsystem/atoms/Shutdown()
	var/initlog = InitLog()
	if(initlog)
		text2file(initlog, "[GLOB.log_directory]/initialize.log")

#undef BAD_INIT_QDEL_BEFORE
#undef BAD_INIT_DIDNT_INIT
#undef BAD_INIT_SLEPT
#undef BAD_INIT_NO_HINT

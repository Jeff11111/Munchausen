GLOBAL_LIST_INIT_TYPED(surgery_steps, /datum/surgery_step, world.setup_surgery_steps())

/world/proc/setup_surgery_steps()
	. = init_subtypes(/datum/surgery_step)

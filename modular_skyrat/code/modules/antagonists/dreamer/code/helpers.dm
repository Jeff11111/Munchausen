/proc/is_dreamer(mob/living/M)
	return M && M.mind && M.mind.has_antag_datum(/datum/antagonist/dreamer)

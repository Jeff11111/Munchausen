//Used by some medical tools
/obj/item/organ/proc/listen()
	return

//Medical scans
/obj/item/organ/proc/get_scan_results(do_tag = FALSE)
	. = list()
	if(is_robotic())
		. += do_tag ? "<span class='notice'>Mechanical</span>" : "Mechanical"
	if(is_synthetic())
		. += do_tag ? "<span class='notice'>Synthetic</span>" : "Synthetic"
	
	if(CHECK_BITFIELD(organ_flags, ORGAN_DEAD))
		if(can_recover())
			. += do_tag ? "<span class='danger'>Decaying</span>" : "Decaying"
		else
			. += do_tag ? "<span class='deadsay'>Necrotic</span>" : "Necrotic"
	
	if(CHECK_BITFIELD(organ_flags, ORGAN_CUT_AWAY))
		. += do_tag ? "<span class='danger'>Severed</span>" : "Severed"

	switch(germ_level)
		if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_ONE + ((INFECTION_LEVEL_TWO - INFECTION_LEVEL_ONE) / 3))
			. += do_tag ?  "<span class='green'>Mild Infection</span>" : "Mild Infection"
		if(INFECTION_LEVEL_ONE + ((INFECTION_LEVEL_TWO - INFECTION_LEVEL_ONE) / 3) to INFECTION_LEVEL_ONE + (2 * (INFECTION_LEVEL_TWO - INFECTION_LEVEL_ONE) / 3))
			. += do_tag ?  "<span class='green'>Mild Infection+</span>" : "Mild Infection+"
		if(INFECTION_LEVEL_ONE + (2 * (INFECTION_LEVEL_TWO - INFECTION_LEVEL_ONE) / 3) to INFECTION_LEVEL_TWO)
			. += do_tag ?  "<span class='green'>Mild Infection++</span>" : "Mild Infection++"
		if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_TWO + ((INFECTION_LEVEL_THREE - INFECTION_LEVEL_THREE) / 3))
			. += do_tag ? "<span class='green'><b>Acute Infection</b></span>" : "Acute Infection"
		if(INFECTION_LEVEL_TWO + ((INFECTION_LEVEL_THREE - INFECTION_LEVEL_THREE) / 3) to INFECTION_LEVEL_TWO + (2 * (INFECTION_LEVEL_THREE - INFECTION_LEVEL_TWO) / 3))
			. += do_tag ? "<span class='green'>Acute Infection+</span>" : "Acute Infection+"
		if(INFECTION_LEVEL_TWO + (2 * (INFECTION_LEVEL_THREE - INFECTION_LEVEL_TWO) / 3) to INFECTION_LEVEL_THREE)
			. += do_tag ? "<span class='deadsay'>Acute Infection++</span>" : "Acute Infection++"
		if(INFECTION_LEVEL_THREE to INFINITY)
			. += do_tag ? "<span class='deadsay'><b>Septic</b></span>" : "Septic"
	
	if(rejecting)
		. += do_tag ? "<span class='danger'><b>Genetic Rejection</b></span>" : "Genetic Rejection"

//Examine stuff
/obj/item/organ/proc/surgical_examine(mob/user)
	. = list()
	var/failing = FALSE
	var/decayed = FALSE
	var/damaged = FALSE
	if(organ_flags & ORGAN_DEAD)
		decayed = TRUE
	if(organ_flags & ORGAN_FAILING)
		failing = TRUE
		if(status & ORGAN_ROBOTIC)
			. += "<span class='warning'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be broken!</span>"
		else
			. += "<span class='warning'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] is severely damaged, and doesn't seem like it will work anymore!</span>"
	if(damage > high_threshold)
		if(!failing)
			damaged = TRUE
			. += "<span class='warning'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] is starting to look discolored.</span>"
	if(!failing && !damaged)
		. += "<span class='notice'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be quite healthy.</span>"
	if(decayed)
		. += "<span class='deadsay'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to have decayed, reaching a necrotic state...</span>"
	if(germ_level)
		switch(germ_level)
			if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_TWO)
				. +=  "<span class='deadsay'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be mildly infected.</span>"
			if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_THREE)
				. +=  "<span class='deadsay'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be oozing some foul pus...</span>"
			if(INFECTION_LEVEL_THREE to INFINITY)
				. += "<span class='deadsay'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be awfully necrotic and riddled with dead tissue!</span>"
	if(etching)
		if(owner)
			. += "<span class='warning'>Something is etched on [src], but i cannot see it clearly.</span>"
		else
			. += "<span class='notice'>[owner ? "[owner.p_their(TRUE)] " : ""][src] has <b>\"[etching]\"</b> inscribed on it.</span>"
	if(!owner)
		. += "<span class='notice'>This organ can be inserted into \the [parse_zone(zone)].</span>"

//Used by injuries (?)
/obj/item/organ/proc/get_visible_state()
	if(damage > maxHealth)
		. = "bits and pieces of a destroyed "
	else if(is_broken())
		. = "broken "
	else if(is_bruised())
		. = "badly damaged "
	else if(damage > 5)
		. = "damaged "
	if(is_dead())
		if(can_recover())
			. = "decaying [.]"
		else
			. = "necrotic [.]"
	. = "[.][name]"

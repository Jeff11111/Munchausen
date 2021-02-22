//Used by some medical tools
/obj/item/bodypart/proc/listen()
	var/list/sounds = list()
	for(var/obj/item/organ/I in get_organs())
		var/gutsound = I.listen()
		if(gutsound)
			sounds += gutsound
	if(!length(sounds))
		if(owner?.pulse())
			sounds += "faint pulse"
	return sounds

//Examine stuff
/obj/item/bodypart/proc/get_injuries_desc()
	var/obj/item/bodypart/parent = owner?.get_bodypart(parent_bodyzone)

	var/list/flavor_text = list()
	if(owner && is_cut_away() && !(parent?.is_cut_away()) && !is_stump())
		flavor_text += "a tear at the [amputation_point] so severe that it hangs by a scrap of [!is_robotic_limb() ? "flesh" : "metal"]"

	var/list/injury_descriptors = list()
	for(var/datum/injury/IN in injuries)
		var/this_injury_desc = IN.desc
		if((IN.can_autoheal()) && (IN.current_stage >= length(IN.stages)) && (IN.damage < 5))
			this_injury_desc = "<span style='color: [COLOR_PALE_RED_GRAY]'>[this_injury_desc]</span>"
		if(IN.damage_type == WOUND_BURN && IN.is_salved())
			this_injury_desc = "<span class='nicegreen'>salved</span> [this_injury_desc]"

		if(IN.is_bleeding())
			if(IN.wound_damage() > IN.bleed_threshold)
				this_injury_desc = "<b><i>badly bleeding</i></b> [this_injury_desc]"
			else
				this_injury_desc = "<b>bleeding</b> [this_injury_desc]"
		if(IN.is_bandaged())
			this_injury_desc = "<span class='white'>bandaged</span> [this_injury_desc]"

		if(IN.germ_level >= INFECTION_LEVEL_TWO)
			this_injury_desc = "<span class='deadsay'><b>badly infected</b></span> [this_injury_desc]"
		else if(IN.germ_level >= INFECTION_LEVEL_ONE)
			this_injury_desc = "<span class='deadsay'>infected</span> [this_injury_desc]"
		
		if(length(IN.embedded_objects))
			var/list/chung = list()
			for(var/item in IN.embedded_objects)
				var/obj/I = item
				chung += "\a [I]"
			this_injury_desc += " with [english_list(chung)] poking out of [IN.amount > 1 ? "them" : "it"]"

		if(injury_descriptors[this_injury_desc])
			injury_descriptors[this_injury_desc] += IN.amount
		else
			injury_descriptors[this_injury_desc] = IN.amount
	
	if(!is_robotic_limb())
		if(CHECK_MULTIPLE_BITFIELDS(how_open(), SURGERY_INCISED | SURGERY_RETRACTED))
			var/bone = encased ? encased : "bone"
			if(is_broken())
				bone = "broken [bone]"
			injury_descriptors["[bone] exposed"] = 1

			if(!encased || (CHECK_BITFIELD(how_open(), SURGERY_BROKEN)))
				var/list/bits = list()
				for(var/obj/item/organ/organ in get_organs())
					bits += organ.get_visible_state()
				if(bits.len)
					injury_descriptors["[english_list(bits)] visible in the wounds"] = 1

	for(var/injury in injury_descriptors)
		switch(injury_descriptors[injury])
			if(-INFINITY to 1)
				flavor_text += "a [injury]"
			if(2)
				flavor_text += "a pair of [injury]s"
			if(3 to 5)
				flavor_text += "several [injury]s"
			if(6 to INFINITY)
				flavor_text += "a ton of [injury]\s"

	return english_list(flavor_text)

//Closer examination
/obj/item/bodypart/proc/inspect(mob/user)
	user.visible_message("<span class='notice'>[user] starts inspecting [owner]'s [name] carefully.</span>")
	if(length(get_injuries_desc()))
		to_chat(user, "<span class='warning'>You find [get_injuries_desc()].</span>")
	else
		to_chat(user, "<span class='notice'>You find no visible wounds.</span>")

	to_chat(user, "<span class='notice'>Checking skin now...</span>")
	if(!do_mob(user, owner, 1 SECONDS))
		to_chat(user, "<span class='warning'>You must stand still to check [owner]'s skin for abnormalities.</span>")
		return

	var/list/badness = list()
	if(owner.shock_stage >= SHOCK_STAGE_2)
		badness |= "clammy and cool to the touch"
	if(owner.getToxLoss() >= 25)
		badness |= "jaundiced"
	if(owner.get_blood_oxygenation() <= BLOOD_VOLUME_OKAY)
		badness |= "turning blue"
	if(owner.get_blood_circulation() <= BLOOD_VOLUME_OKAY + 70)
		badness |= "very pale"
	if(is_dead())
		badness |= "rotting"
	
	if(!length(badness))
		to_chat(user, "<span class='notice'>[owner]'s skin is normal.</span>")
	else
		to_chat(user, "<span class='warning'>[owner]'s skin is [english_list(badness)].</span>")

	to_chat(user, "<span class='notice'>Checking bones now...</span>")
	if(!do_mob(user, owner, 1 SECONDS))
		to_chat(user, "<span class='warning'>You must stand still to feel [src] for fractures.</span>")
		return

	if(is_broken())
		to_chat(user, "<span class='warning'>The [encased ? encased : "bone in the [name]"] moves slightly when you poke it!</span>")
		owner.custom_pain("Your [name] hurts where it's poked.", 30, affecting = src)
	else
		to_chat(user, "<span class='notice'>The [encased ? encased : "bones in the [name]"] seem to be fine.</span>")

	if(is_dislocated())
		to_chat(user, "<span class='warning'>The [joint_name] is dislocated!</span>")

	to_chat(user, "<span class='notice'>Checking tendons and arteries now...</span>")
	if(!do_mob(user, owner, 1 SECONDS))
		to_chat(user, "<span class='warning'>You must stand still to feel [src] for torn tendons and arteries.</span>")
		return

	if(is_tendon_torn())
		to_chat(user, "<span class='warning'>The [tendon_name ? tendon_name : "tendon"] in [name] is severed!</span>")
	else
		to_chat(user, "<span class='notice'>The [tendon_name ? tendon_name : "tendon"] in [name] is OK.</span>")
	
	if(is_artery_torn())
		to_chat(user, "<span class='warning'>The [artery_name ? artery_name : "artery"] in [name] is severed!</span>")
	else
		to_chat(user, "<span class='notice'>The [artery_name ? artery_name : "artery"] in [name] is OK.</span>")
	
	return TRUE

//Medical scans
/obj/item/bodypart/proc/get_scan_results(do_tag = FALSE)
	. = list()
	if(is_robotic_limb())
		. += do_tag ? "<span class='info'>Mechanical</span>" : "Mechanical"
	if(is_synthetic_limb())
		. += do_tag ? "<span class='info'>Synthetic</span>" : "Synthetic"
	
	if(CHECK_BITFIELD(limb_flags, BODYPART_DEAD))
		if(can_recover())
			. += do_tag ? "<span class='danger'>Decaying</span>" : "Decaying"
		else
			. += do_tag ? "<span class='deadsay'>Necrotic</span>" : "Necrotic"

	if(CHECK_BITFIELD(limb_flags, BODYPART_CUT_AWAY))
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

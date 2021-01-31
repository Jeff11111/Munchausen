/mob/living/carbon/examine(mob/user)
	if(user.zone_selected in list(BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE))
		handle_eye_contact(user, TRUE)
	var/t_He = p_they(TRUE)
	var/t_he = p_they()
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_him = p_them()
	var/t_has = p_have()
	var/t_is = p_are()

	. = list("<span class='info'>*---------*\nThis is [icon2html(src, user)] \a <EM>[src]</EM>!")

	if (handcuffed)
		. += "<span class='warning'>[t_He] [t_is] [icon2html(handcuffed, user)] handcuffed!</span>"
	if (head)
		. += "[t_He] [t_is] wearing [head.get_examine_string(user)] on [t_his] head."
	if (wear_mask)
		. += "[t_He] [t_is] wearing [wear_mask.get_examine_string(user)] on [t_his] face."
	var/obj/item/bodypart/mouth/jaw = get_bodypart_nostump(BODY_ZONE_PRECISE_MOUTH)
	if(!wear_mask && istype(jaw) && jaw.tapered)
		. += "<span class='warning'>[t_He] [t_has] \a <b><a href='?src=[REF(jaw)];tape=[jaw.tapered];'>[jaw.tapered.get_examine_string(user)]</a></b> covering [t_his] mouth!</span>"
	if (wear_neck)
		. += "[t_He] [t_is] wearing [wear_neck.get_examine_string(user)] around [t_his] neck.\n"

	for(var/obj/item/I in held_items)
		if(!(I.item_flags & ABSTRACT))
			. += "[t_He] [t_is] holding [I.get_examine_string(user)] in [t_his] [get_held_index_name(get_held_index_of_item(I))]."

	if (back)
		. += "[t_He] [t_has] [back.get_examine_string(user)] on [t_his] back."

	var/list/msg = list()

	var/list/missing = get_missing_limbs()
	var/list/stumps = list()
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		missing -= BP.body_zone
		if(BP.is_stump())
			msg += "<B>[t_He] has a stump where [t_his] [parse_zone(BP.body_zone)] should be!</B>"
			stumps |= BP.body_zone
		if(BP.grasped_by?.grasping_mob == src)
			msg += "[t_He] is applying pressure to [t_his] [BP.name]!"
		missing -= BP.body_zone
	//british detection
	for(var/obj/item/bodypart/teeth_part in bodyparts)
		if(!teeth_part.max_teeth)
			continue
		else if(teeth_part.get_teeth_amount() < teeth_part.max_teeth)
			msg += "<B>[capitalize(t_his)] [teeth_part.name] is missing [teeth_part.max_teeth - teeth_part.get_teeth_amount()] [teeth_part.max_teeth - teeth_part.get_teeth_amount() == 1 ? "tooth" : "teeth"]!</B>"
	//stores missing limbs
	var/l_limbs_missing = 0
	var/r_limbs_missing = 0
	for(var/t in missing)
		var/should_msg = "<B>[capitalize(t_his)] [parse_zone(t)] is missing!</B>"
		if((t==BODY_ZONE_HEAD) || (t==BODY_ZONE_PRECISE_NECK))
			should_msg = "<span class='deadsay'><B>[t_His] [parse_zone(t)] is missing!</B></span>"
		else if(t == BODY_ZONE_L_ARM || t == BODY_ZONE_L_LEG || t == BODY_ZONE_PRECISE_L_FOOT || t == BODY_ZONE_PRECISE_R_FOOT)
			l_limbs_missing++
		else if(t == BODY_ZONE_R_ARM || t == BODY_ZONE_R_LEG || t == BODY_ZONE_PRECISE_L_HAND || t == BODY_ZONE_PRECISE_R_HAND)
			r_limbs_missing++
		
		for(var/datum/wound/L in all_wounds)
			if(L.severity == WOUND_SEVERITY_LOSS)
				var/list/children_atomization = SSquirks.atomize_bodypart_heritage(L.limb?.body_zone)
				if((L.fake_body_zone == t) || (L.fake_body_zone in children_atomization)) //There is already a missing parent bodypart or loss wound for us, no need to be redundant
					should_msg = null
		
		if(SSquirks.bodypart_child_to_parent[t])
			if((SSquirks.bodypart_child_to_parent[t] in missing) || (SSquirks.bodypart_child_to_parent[t] in stumps))
				should_msg = null

		if(should_msg)
			msg += should_msg

	if(l_limbs_missing >= 2 && r_limbs_missing == 0)
		msg += "[t_He] look[p_s()] right winged."
	else if(l_limbs_missing == 0 && r_limbs_missing >= 4)
		msg += "[t_He] look[p_s()] left winged."
	else if(l_limbs_missing >= 4 && r_limbs_missing >= 4)
		msg += "[t_He] [p_are()] a centrist."
	
	if(!(user == src && src.hal_screwyhud == SCREWYHUD_HEALTHY)) //fake healthy
		switch(getBruteLoss() + getFireLoss() + getCloneLoss())
			if(1 to 25)
				msg += "[t_He] [t_is] barely injured."
			if(25 to 50)
				msg += "[t_He] [t_is] <B>moderately</B> injured!"
			if(50 to INFINITY)
				msg += "<B>[t_He] [t_is] severely injured!</B>"

	if(is_dreamer(user))
		var/obj/item/organ/heart = getorganslot(ORGAN_SLOT_HEART)
		if(heart && heart.etching && findtext(heart.etching, "<b>INRL</b> - "))
			var/key_text = copytext(heart.etching, 14, 19)
			msg += "<span class='userdanger'>They KNOW the [key_text], i am sure of it!</span>"
	
	if(msg.len)
		. += "<span class='warning'>[msg.Join("\n")]</span>"
	
	//CONSCIOUSNESS
	var/dist = get_dist(user, src)
	var/consciousness = LOOKS_CONSCIOUS
	var/damage = (getBruteLoss() + getFireLoss()) //If we are very damaged, it's easier to recognize whether or not we are dead

	var/mob/living/carbon/human/H = user
	var/has_health_hud = FALSE
	var/consciousness_msg = null
	if(istype(H))
		var/obj/item/organ/cyberimp/eyes/hud/CIH = H.getorgan(/obj/item/organ/cyberimp/eyes/hud)
		var/obj/item/clothing/glasses/hud/health/health = H.glasses
		if(istype(health) || (istype(CIH) && (CIH.HUD_type == DATA_HUD_MEDICAL_BASIC || CIH.HUD_type == DATA_HUD_MEDICAL_ADVANCED)))
			has_health_hud = TRUE
	if(has_health_hud)
		if(IsSleeping())
			consciousness = LOOKS_SLEEPY
			consciousness_msg = "[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep."
		if(InCritical())
			consciousness = LOOKS_UNCONSCIOUS
			consciousness_msg = "<span class='warning'>[t_His] life signs are shallow and labored[IsUnconscious() ? ", and [t_he] is unconscious" : ""].</span>"
		if(InFullCritical())
			consciousness = LOOKS_VERYUNCONSCIOUS
			consciousness_msg = "<span class='warning'>[t_His] life signs are very shallow and labored, [IsUnconscious() ? "[t_he] is completely unconscious and " : ""][t_he] appears to be undergoing shock.</span>"
		if(stat == DEAD)
			consciousness = LOOKS_DEAD
			consciousness_msg = "<span class='deadsay'>[t_He] [t_is] limp and unresponsive, with no signs of life.</span>"
			if(suiciding)
				consciousness_msg += "\n<span class='deadsay'>[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.</span>"
			if(hellbound)
				consciousness_msg += "\n<span class='deadsay'>[t_His] soul seems to have been ripped out of [t_his] body.  Revival is impossible.</span>"
			if(!getorgan(/obj/item/organ/brain) || (!key && !get_ghost(FALSE)))
				consciousness_msg += "\n<span class='deadsay'>[t_His] body seems empty, [t_his] soul has since departed.</span>"
	else
		if(IsSleeping() || HAS_TRAIT(src, TRAIT_LOOKSSLEEPY) || (consciousness == LOOKS_SLEEPY))
			consciousness = LOOKS_SLEEPY
			if(dist <= 2)
				consciousness_msg = "[t_He] [t_is]n't responding to anything around [t_him] and seems to be asleep."
			else if(dist <= 10)
				consciousness_msg = "[t_He] [t_is]n't responding to anything around [t_him] and seems to be either asleep or unconscious. Hard to tell without getting closer."
		if(InCritical() || HAS_TRAIT(src, TRAIT_LOOKSUNCONSCIOUS) || (consciousness == LOOKS_UNCONSCIOUS))
			consciousness = LOOKS_UNCONSCIOUS
			if((dist <= 2 && is_face_visible() && !HAS_TRAIT(src, TRAIT_NOBREATH)) || (damage >= 75))
				consciousness_msg = "<span class='warning'>[t_His] breathing is shallow and labored[IsUnconscious() ? ", and [t_he] seems to be unconscious" : ""].</span>"
			else if((dist <= 10) && IsUnconscious())
				consciousness = LOOKS_SLEEPY
				consciousness_msg = "[t_He] [t_is]n't responding to anything around [t_him] and seems to be either asleep or unconscious. Hard to tell without getting closer."
		if(InFullCritical() || HAS_TRAIT(src, TRAIT_LOOKSVERYUNCONSCIOUS) || (consciousness == LOOKS_VERYUNCONSCIOUS))
			consciousness = LOOKS_VERYUNCONSCIOUS
			if((dist <= 2) || (damage >= 75))
				consciousness_msg = "<span class='warning'>[t_He] seems to have no identifiable breath[IsUnconscious() ? ", and [t_he] seems to be unconscious" : ""].</span>"
			else if((dist <= 10) && IsUnconscious())
				consciousness = LOOKS_SLEEPY
				consciousness_msg = "[t_He] [t_is]n't responding to anything around [t_him] and seems to be either asleep or unconscious. Hard to tell without getting closer."
		if((stat == DEAD) || (mob_biotypes & MOB_UNDEAD) || HAS_TRAIT(src, TRAIT_LOOKSDEAD) || HAS_TRAIT(src, TRAIT_FAKEDEATH) || (consciousness == LOOKS_DEAD))
			consciousness = LOOKS_DEAD
			if((dist <= 2) || (damage >= 75) || (mob_biotypes & MOB_UNDEAD))
				consciousness_msg = "<span class='deadsay'>[t_He] [t_is] limp and unresponsive, with no signs of life.</span>"
				if(suiciding)
					consciousness_msg += "\n<span class='deadsay'>[t_He] appear[p_s()] to have committed suicide... there is no hope of recovery.</span>"
				if(hellbound)
					consciousness_msg += "\n<span class='deadsay'>[t_His] soul seems to have been ripped out of [t_his] body.  Revival is impossible.</span>"
				if(!getorgan(/obj/item/organ/brain) || (!key && !get_ghost(FALSE)))
					consciousness_msg += "\n<span class='deadsay'>[t_His] body seems empty, [t_his] soul has since departed.</span>"
			else if(dist <= 10 && (lying || IsUnconscious()))
				consciousness_msg = "[t_He] [t_is]n't responding to anything around [t_him] and seems to be either asleep or unconscious. Hard to tell without getting closer."
		
		if(HAS_TRAIT(src, TRAIT_LOOKSCONSCIOUS))
			consciousness = LOOKS_CONSCIOUS
			consciousness_msg = null
	
	if(consciousness_msg)
		. += "\n[consciousness_msg]"
	
	if(HAS_TRAIT(src, TRAIT_DUMB))
		. += "\n[t_He] seem[p_s()] to be clumsy and unable to think."

	if(fire_stacks > 0)
		. += "\n[t_He] [t_is] covered in something flammable."
		
	if(fire_stacks < 0)
		. += "\n[t_He] look[p_s()] a little soaked."

	if(pulledby && pulledby.grab_state)
		. += "\n[t_He] [t_is] restrained by [pulledby]'s grip."
	
	if(digitalcamo)
		. += "\n[t_He] [t_is] moving [t_his] body in an unnatural and blatantly unsimian manner."

	if(SEND_SIGNAL(src, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_ACTIVE))
		. += "\n[t_He] [t_is] visibly tense[CHECK_MOBILITY(src, MOBILITY_STAND) ? "." : ", and [t_is] standing in combative stance."]"

	var/trait_exam = common_trait_examine()
	if (!isnull(trait_exam))
		. += trait_exam

	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
	if(mood)
		switch(mood.shown_mood)
			if(-INFINITY to MOOD_LEVEL_SAD4)
				. += "[t_He] look[p_s()] depressed."
			if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
				. += "[t_He] look[p_s()] very sad."
			if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
				. += "[t_He] look[p_s()] a bit down."
			if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
				. += "[t_He] look[p_s()] quite happy."
			if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
				. += "[t_He] look[p_s()] very happy."
			if(MOOD_LEVEL_HAPPY4 to INFINITY)
				. += "[t_He] look[p_s()] ecstatic."
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)
	. += "*---------*</span>"

//skyrat edit
/mob/living/carbon/examine_more(mob/user)
	. = list("<span class='notice'><i><b>I examine [src] closer, and note the following...</b></i></span>", "<span class='notice'>*---------*</span>")
	
	if((src == user) && HAS_TRAIT(user, TRAIT_SCREWY_CHECKSELF))
		. |= "<span class='smallnotice'>[p_they(TRUE)] [p_have()] no visibly damaged bodyparts.</span>"
		return
	
	var/t_He = p_they(TRUE)
	var/t_His = p_their(TRUE)
	var/t_his = p_their()
	var/t_has = p_have()
	
	var/list/damaged_bodypart_text = list()
	var/list/clothing_items = list(head, wear_mask, wear_neck, back)
	for(var/obj/item/bodypart/BP in bodyparts)
		for(var/obj/item/I in BP.embedded_objects)
			if(I.isEmbedHarmless())
				damaged_bodypart_text += "<span class='warning'>[t_He] [t_has] \a [icon2html(I, user)] [I] stuck to [t_his] [BP.name]!</span>"
		if(BP.etching && !clothingonpart(BP))
			damaged_bodypart_text += "<span class='warning'>[t_His] [BP.name] has \"[BP.etching]\" etched on it!</span>"
		if(BP.is_dead())
			damaged_bodypart_text += "<span class='deadsay'><B>[t_His] [BP.name] is completely necrotic!</B></span>"
		var/obj/item/hidden
		for(var/obj/item/clothing/I in clothing_items)
			if(I && CHECK_BITFIELD(I.body_parts_covered, BP.body_part) && (CHECK_BITFIELD(I.clothing_flags, THICKMATERIAL)))
				hidden = I
				break
		for(var/datum/wound/W in BP.wounds)
			if((!hidden || CHECK_BITFIELD(W.wound_flags, WOUND_VISIBLE_THROUGH_CLOTHING)) && W.get_examine_description(user))
				damaged_bodypart_text += "[W.get_examine_description(user)]"
				if((user != src) && W.severity >= WOUND_SEVERITY_CRITICAL)
					if(GET_SKILL_LEVEL(user, firstaid) <= JOB_SKILLPOINTS_NOVICE)
						SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "saw_wounded", /datum/mood_event/saw_injured)
					else
						SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "saw_wounded", /datum/mood_event/saw_injured/lesser)
		if(hidden)
			if(BP.get_bleed_rate())
				damaged_bodypart_text += "<span class='warning'>[t_He] [t_has] blood soaking through [t_his] [hidden.name] around [t_his] [BP.name]!</span>"
		else
			if(BP.get_injuries_desc() && BP.get_injuries_desc() != "nothing")
				damaged_bodypart_text += "<span class='danger'>[t_He] [t_has] [BP.get_injuries_desc()] on [t_his] [BP.name].</span>"
	
	if(length(damaged_bodypart_text))
		. |= damaged_bodypart_text
	else
		. += "<span class='smallnotice'>[p_they(TRUE)] [p_have()] no visibly damaged bodyparts.</span>"
	
	var/list/obj/item/bodypart/gauzed_limbs = list()
	for(var/i in bodyparts)
		var/obj/item/bodypart/BP = i
		if(BP.current_gauze)
			gauzed_limbs += BP
	var/num_gauze = LAZYLEN(gauzed_limbs)
	var/gauze_text = "<span class='notice'>[t_His]"
	switch(num_gauze)
		if(1 to 2)
			gauze_text += " <a href='?src=[REF(gauzed_limbs[1])];gauze=1;'>"
			gauze_text += "[gauzed_limbs[1].name]"
			gauze_text += "</a>"
			gauze_text += "[num_gauze == 2 ? " and <a href='?src=[REF(gauzed_limbs[2])];gauze=1;'>[gauzed_limbs[2].name]</a>" : ""]"
		if(3 to INFINITY)
			for(var/i in 1 to (num_gauze - 1))
				var/obj/item/bodypart/BP = gauzed_limbs[i]
				gauze_text += " <a href='?src=[REF(BP)];gauze=1;'>[BP.name]</a>,"
			gauze_text += " and <a href='?src=[REF(gauzed_limbs[num_gauze])];gauze=1;'>[gauzed_limbs[num_gauze].name]</a>"
	
	gauze_text += "[num_gauze == 1 ? " is gauzed" : " are gauzed"]"
	gauze_text += ".</span>"
	if(num_gauze)
		. |= gauze_text

	var/list/obj/item/bodypart/suppress_limbs = list()
	for(var/i in bodyparts)
		var/obj/item/bodypart/BP = i
		if(BP.limb_flags & BODYPART_NOBLEED)
			suppress_limbs += BP

	var/num_suppress = LAZYLEN(suppress_limbs)
	var/suppress_text = "<span class='notice'><B>[t_His]"
	switch(num_suppress)
		if(1 to 2)
			suppress_text += " [suppress_limbs[1].name][num_suppress == 2 ? " and [suppress_limbs[2].name]" : ""]"
		if(3 to INFINITY)
			for(var/i in 1 to (num_suppress - 1))
				var/obj/item/bodypart/BP = suppress_limbs[i]
				suppress_text += " [BP.name],"
			suppress_text += " and [suppress_limbs[num_suppress].name]"
	
	suppress_text += "[num_suppress == 1 ? " is impervious to bleeding" : " are impervious to bleeding"]"
	suppress_text += ".</B></span>\n"
	if(num_suppress)
		. += suppress_text
	
	. += "<span class='notice'>*---------*</span>"


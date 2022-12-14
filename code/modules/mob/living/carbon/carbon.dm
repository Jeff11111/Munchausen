/mob/living/carbon
	blood_volume = BLOOD_VOLUME_NORMAL

/mob/living/carbon/Initialize()
	. = ..()
	create_reagents(1000, NONE, NO_REAGENTS_VALUE)
	update_body_parts() //to update the carbon's new bodyparts appearance
	GLOB.carbon_list += src
	blood_volume = (BLOOD_VOLUME_NORMAL * blood_ratio)
	add_movespeed_modifier(/datum/movespeed_modifier/carbon_crawling)
	update_pain()

/mob/living/carbon/Destroy()
	//This must be done first, so the mob ghosts correctly before DNA etc is nulled
	. =  ..()
	QDEL_LIST(internal_organs)
	QDEL_LIST(stomach_contents)
	QDEL_LIST(bodyparts)
	QDEL_LIST(implants)
	hand_bodyparts = null		//Just references out bodyparts, don't need to delete twice.
	for(var/wound in all_wounds) // these LAZYREMOVE themselves when deleted so no need to remove the list here
		qdel(wound)
	for(var/scar in all_scars)
		qdel(scar)
	remove_from_all_data_huds()
	QDEL_NULL(dna)
	GLOB.carbon_list -= src

/mob/living/carbon/relaymove(mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			if(prob(25))
				audible_message("<span class='warning'>You hear something rumbling inside [src]'s stomach...</span>", \
							 "<span class='warning'>You hear something rumbling.</span>", 4,\
							  "<span class='userdanger'>Something is rumbling inside your stomach!</span>")
			var/obj/item/I = user.get_active_held_item()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				var/obj/item/bodypart/BP = get_bodypart(BODY_ZONE_CHEST)
				BP.receive_damage(d, 0)
				if(BP.update_bodypart_damage_state())
					update_damage_overlays()
				visible_message("<span class='danger'>[user] attacks [src]'s stomach wall with the [I.name]!</span>", \
									"<span class='userdanger'>[user] attacks your stomach wall with the [I.name]!</span>")
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

				if(prob(src.getBruteLoss() - 50))
					for(var/atom/movable/A in stomach_contents)
						A.forceMove(drop_location())
						stomach_contents.Remove(A)
					src.gib()

/mob/living/carbon/swap_hand(held_index)
	. = ..()
	if(!.)
		var/obj/item/held_item = get_active_held_item()
		to_chat(usr, "<span class='warning'>Your other hand is too busy holding [held_item].</span>")
		return
	if(!held_index)
		held_index = (active_hand_index % held_items.len)+1
	var/oindex = active_hand_index
	active_hand_index = held_index
	//Update intent and zone selected according to the zone saved
	var/woah = min(length(hand_index_to_intent), active_hand_index)
	a_intent_change(hand_index_to_intent[woah])
	woah = min(length(hand_index_to_throw), active_hand_index)
	if(hand_index_to_throw[woah])
		throw_mode_on()
	else
		throw_mode_off()
	woah = min(length(hand_index_to_zone), active_hand_index)
	if(hud_used)
		var/obj/screen/zone_sel/bingus = hud_used.zone_select
		if(istype(bingus))
			bingus.set_selected_zone(hand_index_to_zone[woah], user = src)
		var/obj/screen/inventory/hand/H
		H = hud_used.hand_slots["[oindex]"]
		if(H)
			H.update_icon()
		H = hud_used.hand_slots["[held_index]"]
		if(H)
			H.update_icon()

/mob/living/carbon/activate_hand(selhand) //l/r OR 1-held_items.len
	if(!selhand)
		selhand = (active_hand_index % held_items.len)+1

	if(istext(selhand))
		selhand = lowertext(selhand)
		if(selhand == "right" || selhand == "r")
			selhand = 2
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != active_hand_index)
		swap_hand(selhand)
	else
		mode() // Activate held item

/mob/living/carbon/attackby(obj/item/I, mob/user, params)
	//attempt surgery if on help or disarm intent
	if(user.a_intent == INTENT_HELP || user.a_intent == INTENT_DISARM)
		for(var/datum/surgery_step/S in GLOB.surgery_steps)
			if(S.try_op(user, src, user.zone_selected, user.get_active_held_item()))
				return TRUE

	//do not fuck someone up with tools if help intent
	if(!length(all_wounds))
		//This is absolute chungus niggercode 420 blaze it but i could not find a way to fix this well
		//so we'll literally check if it's cable coil or a welding tool on a robotic limb
		var/obj/item/bodypart/niggertard = get_bodypart(check_zone(user.zone_selected))
		if((user.a_intent == INTENT_HELP) && I.tool_behaviour && !(niggertard?.is_robotic_limb() && (istype(I, /obj/item/stack/cable_coil) ||  istype(I, /obj/item/weldingtool))))
			return TRUE
		else if(!niggertard?.is_robotic_limb())
			return ..()

	// The following priority/nonpriority searching is so that if we have two wounds on a limb that use the same item for treatment,
	// we prefer whichever wound is not already treated. If there's no priority wounds that this can treat, go through the
	// non-priority ones randomly.
	var/list/nonpriority_wounds = list()
	for(var/datum/wound/W in shuffle(all_wounds))
		if(!W.treat_priority)
			nonpriority_wounds += W
		else if(W.treat_priority && W.try_treating(I, user))
			return TRUE

	for(var/datum/wound/W in shuffle(nonpriority_wounds))
		if(W.try_treating(I, user))
			return TRUE

	return ..()

/mob/living/carbon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	var/hurt = TRUE
	var/extra_speed = 0
	if(throwingdatum?.thrower != src)
		extra_speed = min(max(0, throwingdatum.speed - initial(throw_speed)), 3)
	if(tackling)
		return
	if(throwingdatum?.thrower && iscyborg(throwingdatum.thrower))
		var/mob/living/silicon/robot/R = throwingdatum.thrower
		if(!R.emagged)
			hurt = FALSE
	if(hit_atom.density && isturf(hit_atom))
		if(hurt)
			DefaultCombatKnockdown(20)
			take_bodypart_damage(10 + 5 * extra_speed, check_armor = TRUE, wound_bonus = extra_speed)
	if(iscarbon(hit_atom) && hit_atom != src)
		var/mob/living/carbon/victim = hit_atom
		if(victim.movement_type & FLYING)
			return
		if(hurt)
			victim.take_bodypart_damage(10 + 5 * extra_speed, check_armor = TRUE, wound_bonus = extra_speed * 5)
			take_bodypart_damage(10 + 5 * extra_speed, check_armor = TRUE, wound_bonus = extra_speed * 5)
			victim.DefaultCombatKnockdown(20)
			DefaultCombatKnockdown(20)
			visible_message("<span class='danger'><b>[src]</b> crashes into <b>[victim]</b>[extra_speed ? " really hard" : ""], knocking them both over!</span>",\
				"<span class='userdanger'>I violently crash into <b>[victim]</b>[extra_speed ? " extra hard" : ""]!</span>")
		playsound(src,'sound/weapons/punch1.ogg',50,1)

//Throwing stuff
/mob/living/carbon/proc/toggle_throw_mode()
	if(stat)
		return
	if(in_throw_mode)
		throw_mode_off()
	else
		throw_mode_on()


/mob/living/carbon/proc/throw_mode_off()
	in_throw_mode = FALSE
	hand_index_to_throw[active_hand_index] = FALSE
	if(client && hud_used)
		hud_used.throw_icon.icon_state = "act_throw"


/mob/living/carbon/proc/throw_mode_on()
	in_throw_mode = TRUE
	hand_index_to_throw[active_hand_index] = TRUE
	if(client && hud_used)
		hud_used.throw_icon.icon_state = "act_throw_on"

/mob/proc/throw_item(atom/target)
	SEND_SIGNAL(src, COMSIG_MOB_THROW, target)
	return

/mob/living/carbon/throw_item(atom/target)
	throw_mode_off()
	if(!target || !isturf(loc))
		return
	if(istype(target, /obj/screen))
		return

	if(IS_STAMCRIT(src))
		to_chat(src, "<span class='warning'>You're too exhausted.</span>")
		return

	var/random_turn = a_intent == INTENT_HARM
	var/obj/item/I = get_active_held_item()

	var/atom/movable/thrown_thing
	var/mob/living/throwable_mob

	if(istype(I, /obj/item/clothing/head/mob_holder))
		var/obj/item/clothing/head/mob_holder/holder = I
		if(holder.held_mob)
			throwable_mob = holder.held_mob
			holder.release()

	if(istype(I, /obj/item/grab))
		var/obj/item/grab/grabby = I
		if(grabby.grasped_mob && (grabby.grasped_mob != src))
			if(pulledby && pulledby.grab_state >= GRAB_AGGRESSIVE)
				to_chat(src, "<span class='warning'>I can't throw [pulledby] away! Their grip is too strong!</span>")
				return
			throwable_mob = grabby.grasped_mob
			dropItemToGround(grabby)

	if(!I || throwable_mob)
		if(!throwable_mob && pulling && isliving(pulling) && grab_state >= GRAB_AGGRESSIVE)
			throwable_mob = pulling

		if(throwable_mob && !throwable_mob.buckled)
			thrown_thing = throwable_mob
			if(pulling)
				stop_pulling()
			if(HAS_TRAIT(src, TRAIT_PACIFISM))
				to_chat(src, "<span class='notice'>You gently let go of <b>[throwable_mob]</b>.</span>")
				return
			adjustStaminaLossBuffered(STAM_COST_THROW_MOB * ((throwable_mob.mob_size+1)**2))// throwing an entire person shall be very tiring
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T)
				log_combat(src, throwable_mob, "thrown", addition="grab from tile in [AREACOORD(start_T)] towards tile at [AREACOORD(end_T)]")
			var/power_throw = 0
			if(HAS_TRAIT(src, TRAIT_HULK))
				power_throw++
			if(pulling && grab_state >= GRAB_NECK)
				power_throw++
			visible_message("<span class='danger'><b>[src]</b> throws <b>[throwable_mob]</b>[power_throw ? " really hard!" : "."]</span>", \
							"<span class='danger'>You throw <b>[throwable_mob]</b>[power_throw ? " really hard!" : "."]</span>")
			log_message("has thrown [throwable_mob] [power_throw ? "really hard" : ""]", LOG_ATTACK)
			newtonian_move(get_dir(target, src))
			throwable_mob.safe_throw_at(target, throwable_mob.throw_range, throwable_mob.throw_speed + power_throw, src, FALSE, FALSE, null, move_force)
	else if(!CHECK_BITFIELD(I.item_flags, ABSTRACT) && !HAS_TRAIT(I, TRAIT_NODROP))
		thrown_thing = I
		dropItemToGround(I)

		if(HAS_TRAIT(src, TRAIT_PACIFISM) && I.throwforce)
			to_chat(src, "<span class='notice'>You set [I] down gently on the ground.</span>")
			return

		adjustStaminaLossBuffered(I.getweight(src, STAM_COST_THROW_MULT, SKILL_THROW_STAM_COST))

	if(thrown_thing)
		visible_message("<span class='danger'><b>[src]</b> has thrown [thrown_thing].</span>")
		log_message("has thrown [thrown_thing]", LOG_ATTACK)
		do_attack_animation(target, no_effect = 1)
		if(throwforce)
			playsound(loc, 'sound/weapons/punchmiss.ogg', 50, TRUE, -1)
		newtonian_move(get_dir(target, src))
		thrown_thing.safe_throw_at(target, thrown_thing.throw_range, thrown_thing.throw_speed, src, null, null, null, move_force, random_turn)

/mob/living/carbon/restrained(ignore_grab)
	var/chungus = FALSE
	if(!ignore_grab && pulledby)
		for(var/obj/item/grab/bungus in pulledby.held_items)
			if(bungus.actions_done && ((bungus.grab_mode == GM_TAKEDOWN) || (bungus.grab_mode == GM_STRANGLE)))
				chungus = TRUE
	return (handcuffed || chungus)

/mob/living/carbon/proc/canBeHandcuffed()
	return 0

/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)
	var/dat = {"
	<HR>
	<B><FONT size=3>[name]</FONT></B>
	<HR>
	<BR><B>Head:</B> <A href='?src=[REF(src)];item=[SLOT_HEAD]'>				[(head && !(head.item_flags & ABSTRACT)) 			? head 		: "Nothing"]</A>
	<BR><B>Mask:</B> <A href='?src=[REF(src)];item=[SLOT_WEAR_MASK]'>		[(wear_mask && !(wear_mask.item_flags & ABSTRACT))	? wear_mask	: "Nothing"]</A>
	<BR><B>Neck:</B> <A href='?src=[REF(src)];item=[SLOT_NECK]'>		[(wear_neck && !(wear_neck.item_flags & ABSTRACT))	? wear_neck	: "Nothing"]</A>"}

	for(var/i in 1 to held_items.len)
		var/obj/item/I = get_item_for_held_index(i)
		dat += "<BR><B>[get_held_index_name(i)]:</B></td><td><A href='?src=[REF(src)];item=[SLOT_HANDS];hand_index=[i]'>[(I && !(I.item_flags & ABSTRACT)) ? I : "Nothing"]</a>"

	dat += "<BR><B>Back:</B> <A href='?src=[REF(src)];item=[SLOT_BACK]'>[back ? back : "Nothing"]</A>"

	if(!HAS_TRAIT(src, TRAIT_NO_INTERNALS) && istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/tank))
		dat += "<BR><A href='?src=[REF(src)];internal=1'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	if(handcuffed)
		dat += "<BR><A href='?src=[REF(src)];item=[SLOT_HANDCUFFED]'>Handcuffed</A>"
	if(legcuffed)
		dat += "<BR><A href='?src=[REF(src)];item=[SLOT_LEGCUFFED]'>Legcuffed</A>"

	dat += {"
	<BR>
	<BR><A href='?src=[REF(user)];mach_close=mob[REF(src)]'>Close</A>
	"}
	user << browse(dat, "window=mob[REF(src)];size=325x500")
	onclose(user, "mob[REF(src)]")

/mob/living/carbon/Topic(href, href_list)
	..()
	//strip panel
	if(usr.canUseTopic(src, BE_CLOSE))
		if(href_list["internal"] && !HAS_TRAIT(src, TRAIT_NO_INTERNALS))
			var/slot = text2num(href_list["internal"])
			var/obj/item/ITEM = get_item_by_slot(slot)
			if(ITEM && istype(ITEM, /obj/item/tank) && wear_mask && (wear_mask.clothing_flags & ALLOWINTERNALS))
				visible_message("<span class='danger'>[usr] tries to [internal ? "close" : "open"] the valve on [src]'s [ITEM.name].</span>", \
								"<span class='userdanger'>[usr] tries to [internal ? "close" : "open"] the valve on your [ITEM.name].</span>", \
								target = usr, target_message = "<span class='danger'>You try to [internal ? "close" : "open"] the valve on [src]'s [ITEM.name].</span>")
				if(do_mob(usr, src, POCKET_STRIP_DELAY))
					if(internal)
						internal = null
						update_internals_hud_icon(FALSE)
					else if(ITEM && istype(ITEM, /obj/item/tank))
						if((wear_mask && (wear_mask.clothing_flags & ALLOWINTERNALS)) || getorganslot(ORGAN_SLOT_BREATHING_TUBE))
							internal = ITEM
							update_internals_hud_icon(TRUE)

					visible_message("<span class='danger'>[usr] [internal ? "opens" : "closes"] the valve on [src]'s [ITEM.name].</span>", \
									"<span class='userdanger'>[usr] [internal ? "opens" : "closes"] the valve on your [ITEM.name].</span>", \
									target = usr, target_message = "<span class='danger'>You [internal ? "opens" : "closes"] the valve on [src]'s [ITEM.name].</span>")
	if(href_list["embedded_object"] && usr.canUseTopic(src, BE_CLOSE))
		var/obj/item/bodypart/L = locate(href_list["embedded_limb"]) in bodyparts
		if(!L)
			return
		var/obj/item/I = locate(href_list["embedded_object"]) in L.embedded_objects
		if(!I || I.loc != src) //no item, no limb, or item is not in limb or in the person anymore
			return
		SEND_SIGNAL(src, COMSIG_CARBON_EMBED_RIP, I, L)
		return

/mob/living/carbon/fall(forced)
	loc.handle_fall(src, forced)//it's loc so it doesn't call the mob's handle_fall which does nothing

/mob/living/carbon/is_muzzled()
	return(istype(src.wear_mask, /obj/item/clothing/mask/muzzle))

/mob/living/carbon/hallucinating()
	if(hallucination)
		return TRUE
	else
		return FALSE

/mob/living/carbon/resist_buckle()
	. = FALSE
	if(!buckled)
		return
	if(restrained())
		// too soon.
		if(last_special > world.time)
			return
		var/buckle_cd = 600
		if(handcuffed)
			var/obj/item/restraints/O = src.get_item_by_slot(SLOT_HANDCUFFED)
			buckle_cd = O.breakouttime
		changeNext_move(min(CLICK_CD_BREAKOUT, buckle_cd))
		last_special = world.time + min(CLICK_CD_BREAKOUT, buckle_cd)
		visible_message("<span class='warning'>[src] attempts to unbuckle [p_them()]self!</span>", \
					"<span class='notice'>You attempt to unbuckle yourself... (This will take around [round(buckle_cd/600,1)] minute\s, and you need to stay still.)</span>")
		if(do_after(src, buckle_cd, 0, target = src, required_mobility_flags = MOBILITY_RESIST))
			if(!buckled)
				return
			buckled.user_unbuckle_mob(src, src)
		else
			if(src && buckled)
				to_chat(src, "<span class='warning'>You fail to unbuckle yourself!</span>")
	else
		buckled.user_unbuckle_mob(src,src)

/mob/living/carbon/resist_fire()
	if(last_special > world.time)
		return
	fire_stacks -= 5
	DefaultCombatKnockdown(60, TRUE, TRUE)
	spin(32,2)
	visible_message("<span class='danger'>[src] rolls on the floor, trying to put [p_them()]self out!</span>", \
		"<span class='notice'>You stop, drop, and roll!</span>")
	last_special = world.time + 30
	sleep(30)
	if(fire_stacks <= 0)
		visible_message("<span class='danger'>[src] has successfully extinguished [p_them()]self!</span>", \
			"<span class='notice'>You extinguish yourself.</span>")
		ExtinguishMob()

/mob/living/carbon/resist_restraints(ignore_delay = FALSE)
	var/obj/item/I = null
	var/type = 0
	if(!ignore_delay && (last_special > world.time))
		to_chat(src, "<span class='warning'>You don't have the energy to resist your restraints that fast!</span>")
		return
	if(handcuffed)
		I = handcuffed
		type = 1
	else if(legcuffed)
		I = legcuffed
		type = 2
	if(I)
		if(type == 1)
			changeNext_move(min(CLICK_CD_BREAKOUT, I.breakouttime))
			last_special = world.time + CLICK_CD_BREAKOUT
		if(type == 2)
			changeNext_move(min(CLICK_CD_RANGE, I.breakouttime))
			last_special = world.time + CLICK_CD_RANGE
		cuff_resist(I)

/mob/living/carbon/proc/cuff_resist(obj/item/I, breakouttime = 600, cuff_break = 0)
	if(I.item_flags & BEING_REMOVED)
		to_chat(src, "<span class='warning'>You're already attempting to remove [I]!</span>")
		return
	I.item_flags |= BEING_REMOVED
	breakouttime = I.breakouttime
	//breaking out of cuffs depends on dexterity
	if(mind)
		breakouttime *= (GET_STAT_LEVEL(src, dex)/(MAX_STAT/2))
		//strong man brek cuffe
		if(GET_STAT_LEVEL(src, str) >= 18)
			visible_message("<span class='userdanger'>[src] breaks \the [I] with a loud noise!</span>",
							"<span class='userdanger'>You break \the [I]!</span>")
			clear_cuffs(I, INSTANT_CUFFBREAK)
			return TRUE
	if(!cuff_break)
		visible_message("<span class='warning'>[src] attempts to remove [I]!</span>")
		to_chat(src, "<span class='notice'>You attempt to remove [I]... (This will take around [DisplayTimeText(breakouttime)] and you need to stand still.)</span>")
		if(do_after(src, breakouttime, 0, target = src, required_mobility_flags = MOBILITY_RESIST))
			clear_cuffs(I, cuff_break)
		else
			to_chat(src, "<span class='warning'>You fail to remove [I]!</span>")

	else if(cuff_break == FAST_CUFFBREAK)
		breakouttime = 50
		visible_message("<span class='warning'>[src] is trying to break [I]!</span>")
		to_chat(src, "<span class='notice'>You attempt to break [I]... (This will take around 5 seconds and you need to stand still.)</span>")
		if(do_after(src, breakouttime, 0, target = src))
			clear_cuffs(I, cuff_break)
		else
			to_chat(src, "<span class='warning'>You fail to break [I]!</span>")

	else if(cuff_break == INSTANT_CUFFBREAK)
		clear_cuffs(I, cuff_break)
	I.item_flags &= ~BEING_REMOVED

/mob/living/carbon/proc/uncuff()
	if (handcuffed)
		var/obj/item/W = handcuffed
		handcuffed = null
		if (buckled && buckled.buckle_requires_restraints)
			buckled.unbuckle_mob(src)
		update_handcuffed()
		if (client)
			client.screen -= W
		if (W)
			W.forceMove(drop_location())
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
		changeNext_move(0)
	if (legcuffed)
		var/obj/item/W = legcuffed
		legcuffed = null
		update_inv_legcuffed()
		if (client)
			client.screen -= W
		if (W)
			W.forceMove(drop_location())
			W.dropped(src)
			if (W)
				W.layer = initial(W.layer)
				W.plane = initial(W.plane)
		changeNext_move(0)
	update_equipment_speed_mods() // In case cuffs ever change speed

/mob/living/carbon/proc/clear_cuffs(obj/item/I, cuff_break)
	if(!I.loc || buckled)
		return
	visible_message("<span class='danger'>[src] manages to [cuff_break ? "break" : "remove"] [I]!</span>")
	to_chat(src, "<span class='notice'>You successfully [cuff_break ? "break" : "remove"] [I].</span>")

	if(cuff_break)
		. = !((I == handcuffed) || (I == legcuffed))
		qdel(I)
		return

	else
		if(I == handcuffed)
			handcuffed.forceMove(drop_location())
			handcuffed = null
			I.dropped(src)
			if(buckled && buckled.buckle_requires_restraints)
				buckled.unbuckle_mob(src)
			update_handcuffed()
			return
		if(I == legcuffed)
			legcuffed.forceMove(drop_location())
			legcuffed = null
			I.dropped(src)
			update_inv_legcuffed()
			return
		else
			dropItemToGround(I)
			return

/mob/living/carbon/get_standard_pixel_y_offset(lying = 0)
	. = ..()
	if(lying)
		. -= 6

/mob/living/carbon/proc/accident(obj/item/I)
	if(!I || (I.item_flags & ABSTRACT) || HAS_TRAIT(I, TRAIT_NODROP))
		return

	var/modifier = 50
	if(HAS_TRAIT(src, TRAIT_CLUMSY))
		modifier -= 40 //Clumsy people are more likely to hit themselves -Honk!

	else if(SEND_SIGNAL(src, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
		modifier -= 50

	if(modifier < 100)
		dropItemToGround(I)

	switch(rand(1,100)+modifier) //91-100=Nothing special happens
		if(-INFINITY to 0) //attack yourself
			I.attack(src,src)
		if(1 to 30) //throw it at yourself
			I.throw_impact(src)
		if(31 to 60) //Throw object in facing direction
			var/turf/target = get_turf(loc)
			var/range = rand(2,I.throw_range)
			for(var/i = 1; i < range; i++)
				var/turf/new_turf = get_step(target, dir)
				target = new_turf
				if(new_turf.density)
					break
			I.throw_at(target,I.throw_range,I.throw_speed,src)
		if(61 to 90) //throw it down to the floor
			var/turf/target = get_turf(loc)
			I.safe_throw_at(target,I.throw_range,I.throw_speed,src, force = move_force)

/mob/living/carbon/Stat()
	..()
	if(statpanel("Status"))
		var/obj/item/organ/alien/plasmavessel/vessel = getorgan(/obj/item/organ/alien/plasmavessel)
		if(vessel)
			stat(null, "Plasma Stored: [vessel.storedPlasma]/[vessel.max_plasma]")
		if(locate(/obj/item/assembly/health) in src)
			stat(null, "Health: [health]")

	add_abilities_to_panel()

/mob/living/carbon/attack_ui(slot)
	if(!has_hand_for_held_index(active_hand_index))
		return 0
	return ..()

/mob/living/carbon/proc/vomit(lost_nutrition = 10, blood = FALSE, stun = TRUE, distance = 1, message = TRUE, toxic = FALSE)
	if(HAS_TRAIT(src, TRAIT_NOHUNGER))
		return 1

	if(nutrition < 100 && !blood)
		if(message)
			visible_message("<span class='warning'>[src] dry heaves!</span>", \
							"<span class='userdanger'>You try to throw up, but there's nothing in your stomach!</span>")
		if(stun)
			DefaultCombatKnockdown(200)
		return TRUE

	if(is_mouth_covered()) //make this add a blood/vomit overlay later it'll be hilarious
		if(message)
			visible_message("<span class='danger'><b>[src]</b> throws up all over [p_them()]self!</span>", \
							"<span class='userdanger'>I throw up all over myself!</span>")
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "vomit", /datum/mood_event/vomitself)
		distance = 0
	else
		if(message)
			visible_message("<span class='danger'><b>[src]</b> throws up!</span>", "<span class='userdanger'>I throw up!</span>")
			if(!isflyperson(src))
				SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "vomit", /datum/mood_event/vomit)
	if(stun)
		Stun(80)

	playsound(get_turf(src), 'sound/effects/splat.ogg', 50, 1)
	var/turf/T = get_turf(src)
	if(!blood)
		adjust_nutrition(-lost_nutrition)
		//i dont give a shit the loss of hydration is the same as the loss of hunger
		adjust_hydration(-lost_nutrition)
		adjustToxLoss(-3)
	for(var/i=0 to distance)
		if(blood)
			if(T)
				add_splatter_floor(T)
			if(stun)
				adjustBruteLoss(3)
			else if(src.reagents.has_reagent(/datum/reagent/consumable/ethanol/blazaam))
				if(T)
					T.add_vomit_floor(src, VOMIT_PURPLE)
		else
			if(T)
				T.add_vomit_floor(src, VOMIT_TOXIC)//toxic barf looks different
		T = get_step(T, dir)
		if (is_blocked_turf(T))
			break
	return 1

/mob/living/carbon/proc/spew_organ(power = 5, amt = 1)
	var/list/spillable_organs = list()
	for(var/A in internal_organs)
		var/obj/item/organ/O = A
		if(!(O.organ_flags & ORGAN_NO_DISMEMBERMENT))
			spillable_organs += O
	for(var/i in 1 to amt)
		if(!spillable_organs.len)
			break //Guess we're out of organs!
		var/obj/item/organ/guts = pick(spillable_organs)
		spillable_organs -= guts
		var/turf/T = get_turf(src)
		guts.Remove()
		guts.forceMove(T)
		var/atom/throw_target = get_edge_target_turf(guts, dir)
		guts.throw_at(throw_target, power, 4, src)



/mob/living/carbon/fully_replace_character_name(oldname,newname)
	..()
	if(dna)
		dna.real_name = real_name

//Updates the mob's health from bodyparts and mob damage variables
/mob/living/carbon/updatehealth()
	if(status_flags & GODMODE)
		return
	var/total_burn	= 0
	var/total_brute	= 0
	var/total_stamina = 0
	var/total_pain = 0
	var/total_clone = 0
	var/total_toxin = 0
	for(var/X in bodyparts)	//hardcoded to streamline things a bit
		var/obj/item/bodypart/BP = X
		total_brute	+= (BP.brute_dam * BP.body_damage_coeff)
		total_burn	+= (BP.burn_dam * BP.body_damage_coeff)
		total_stamina += (BP.stamina_dam * BP.stam_damage_coeff)
		total_pain += max(0, (BP.get_pain() - chem_effects[CE_PAINKILLER]) * BP.pain_damage_coeff)
		total_clone += (BP.clone_dam * BP.body_damage_coeff)
		total_pain += (BP.tox_dam * BP.body_damage_coeff)
	health = round(maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute, DAMAGE_PRECISION)
	if(ishuman(src)) //Kind of terrible.
		health = round(maxHealth - getBrainLoss())
	staminaloss = round(total_stamina, DAMAGE_PRECISION)
	painloss = round(total_pain, DAMAGE_PRECISION)
	cloneloss = round(total_clone, DAMAGE_PRECISION)
	toxloss = round(total_toxin, DAMAGE_PRECISION)
	update_stat()
	if(((maxHealth - total_burn) < HEALTH_THRESHOLD_DEAD*2) && stat == DEAD)
		become_husk("burn")
	med_hud_set_health()
	if(stat == SOFT_CRIT)
		add_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)

/mob/living/carbon/update_stamina()
	var/stam = getStaminaLoss()
	if(stam > DAMAGE_PRECISION)
		var/total_health = (maxHealth - stam)
		if(total_health <= crit_threshold && !stat)
			if(CHECK_MOBILITY(src, MOBILITY_STAND))
				to_chat(src, "<span class='notice'>You're too exhausted to keep going...</span>")
			KnockToFloor(TRUE)
			update_health_hud()

/mob/living/carbon/update_sight()
	if(!client)
		return
	if(stat == DEAD)
		sight = (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_OBSERVER
		return

	sight = initial(sight)
	lighting_alpha = initial(lighting_alpha)
	var/obj/item/bodypart/left_eye/LE = get_bodypart_nostump(BODY_ZONE_PRECISE_LEFT_EYE)
	var/obj/item/bodypart/right_eye/RE = get_bodypart_nostump(BODY_ZONE_PRECISE_RIGHT_EYE)
	if(LE || RE)
		see_invisible = LE?.see_invisible || RE?.see_invisible
		see_in_dark = LE?.see_in_dark || RE?.see_in_dark
		sight |= LE?.sight_flags | RE?.sight_flags
		if(!isnull(LE?.lighting_alpha))
			lighting_alpha = LE?.lighting_alpha
		else if(!isnull(RE?.lighting_alpha))
			lighting_alpha = RE?.lighting_alpha
		if(HAS_TRAIT(src, TRAIT_NIGHT_VISION))
			lighting_alpha = min(LIGHTING_PLANE_ALPHA_NV_TRAIT, lighting_alpha)
			see_in_dark = max(NIGHT_VISION_DARKSIGHT_RANGE, see_in_dark)

	if(client.eye && client.eye != src)
		var/atom/A = client.eye
		if(A.update_remote_sight(src)) //returns 1 if we override all other sight updates.
			return

	if(glasses)
		var/obj/item/clothing/glasses/G = glasses
		sight |= G.vision_flags
		see_in_dark = max(G.darkness_view, see_in_dark)
		if(G.invis_override)
			see_invisible = G.invis_override
		else
			see_invisible = min(G.invis_view, see_invisible)
		if(!isnull(G.lighting_alpha))
			lighting_alpha = min(lighting_alpha, G.lighting_alpha)
	if(dna)
		for(var/X in dna.mutations)
			var/datum/mutation/M = X
			if(M.name == XRAY)
				sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
				see_in_dark = max(see_in_dark, 8)

	if(HAS_TRAIT(src, TRAIT_THERMAL_VISION))
		sight |= (SEE_MOBS)
		lighting_alpha = min(lighting_alpha, LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)

	if(HAS_TRAIT(src, TRAIT_XRAY_VISION))
		sight |= (SEE_TURFS|SEE_MOBS|SEE_OBJS)
		see_in_dark = max(see_in_dark, 8)

	if(see_override)
		see_invisible = see_override
	. = ..()


//to recalculate and update the mob's total tint from tinted equipment it's wearing.
/mob/living/carbon/proc/update_tint()
	if(!GLOB.tinted_weldhelh)
		return
	tinttotal = get_total_tint()
	if(tinttotal >= TINT_BLIND)
		become_blind(EYES_COVERED)
	else if(tinttotal >= TINT_DARKENED)
		cure_blind(EYES_COVERED)
		overlay_fullscreen("tint", /obj/screen/fullscreen/impaired, 2)
	else
		cure_blind(EYES_COVERED)
		clear_fullscreen("tint", 0)

/mob/living/carbon/proc/update_eyes()
	var/obj/item/bodypart/left_eye/LE = get_bodypart_nostump(BODY_ZONE_PRECISE_LEFT_EYE)
	var/obj/item/bodypart/right_eye/RE = get_bodypart_nostump(BODY_ZONE_PRECISE_RIGHT_EYE)
	var/left_damage = (LE ? LE.eye_damaged : 3)
	var/right_damage = (RE ? RE.eye_damaged : 3)
	if((left_damage >= 3) && (right_damage >= 3))
		become_blind(EYE_DAMAGE)
		return TRUE
	else
		cure_blind(EYE_DAMAGE)

	var/fuck_with_fov = TRUE
	var/obj/item/clothing/head/beanie = head
	if(istype(beanie) && beanie.fov_angle && beanie.fov_shadow_angle)
		fuck_with_fov = FALSE

	var/datum/component/field_of_vision/fov = GetComponent(/datum/component/field_of_vision)
	if(fuck_with_fov && fov)
		if(left_damage >= 3)
			fov.generate_fov_holder(M = src, _angle = 45, _shadow_angle = FOV_180PLUS45_DEGREES, register = FALSE, delete_holder = TRUE)
		else if(right_damage >= 3)
			fov.generate_fov_holder(M = src, _angle = -45, _shadow_angle = FOV_180MINUS45_DEGREES, register = FALSE, delete_holder = TRUE)

	if((left_damage in 1 to 2) && !fov)
		overlay_fullscreen("left_eye_damage", /obj/screen/fullscreen/impaired/left, left_damage)
	else
		clear_fullscreen("left_eye_damage")
	if(!left_damage && fuck_with_fov && fov && fov.shadow_angle == FOV_180PLUS45_DEGREES)
		fov.generate_fov_holder(M = src, _angle = 0, _shadow_angle = FOV_90_DEGREES, register = FALSE, delete_holder = TRUE)

	if((right_damage in 1 to 2) && !fov)
		overlay_fullscreen("right_eye_damage", /obj/screen/fullscreen/impaired/right, right_damage)
	else
		clear_fullscreen("right_eye_damage")
	if(!right_damage && fuck_with_fov && fov && fov.shadow_angle == FOV_180MINUS45_DEGREES)
		fov.generate_fov_holder(M = src, _angle = 0, _shadow_angle = FOV_90_DEGREES, register = FALSE, delete_holder = TRUE)

	return TRUE

/mob/living/carbon/proc/get_total_tint()
	. = 0
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/HT = head
		. += HT.tint
	if(wear_mask)
		. += wear_mask.tint

	var/obj/item/bodypart/left_eye/LE = get_bodypart(BODY_ZONE_PRECISE_LEFT_EYE)
	var/obj/item/bodypart/right_eye/RE = get_bodypart(BODY_ZONE_PRECISE_RIGHT_EYE)
	if(istype(LE))
		. += LE.tint
	else if(istype(RE))
		. += RE.tint
	else
		. += INFINITY

/mob/living/carbon/get_permeability_protection(list/target_zones = list(HANDS,CHEST,GROIN,LEGS,FEET,ARMS,HEAD))
	var/list/tally = list()
	for(var/obj/item/I in get_equipped_items())
		for(var/zone in target_zones)
			if(I.body_parts_covered & zone)
				tally["[zone]"] = max(1 - I.permeability_coefficient, target_zones["[zone]"])
	var/protection = 0
	for(var/key in tally)
		protection += tally[key]
	protection *= INVERSE(target_zones.len)
	return protection

//this handles hud updates
/mob/living/carbon/update_damage_hud()
	if(!client)
		return

	if(get_physical_damage() <= crit_threshold)
		var/severity = 0
		switch(get_physical_damage())
			if(-20 to -10)
				severity = 1
			if(-30 to -20)
				severity = 2
			if(-40 to -30)
				severity = 3
			if(-50 to -40)
				severity = 4
			if(-50 to -40)
				severity = 5
			if(-60 to -50)
				severity = 6
			if(-70 to -60)
				severity = 7
			if(-90 to -70)
				severity = 8
			if(-95 to -90)
				severity = 9
			if(-INFINITY to -95)
				severity = 10
		if(!InFullShock())
			var/visionseverity = 4
			switch(health)
				if(-8 to -4)
					visionseverity = 5
				if(-12 to -8)
					visionseverity = 6
				if(-16 to -12)
					visionseverity = 7
				if(-20 to -16)
					visionseverity = 8
				if(-24 to -20)
					visionseverity = 9
				if(-INFINITY to -24)
					visionseverity = 10
			overlay_fullscreen("critvision", /obj/screen/fullscreen/crit/vision, visionseverity)
		else
			clear_fullscreen("critvision")
		overlay_fullscreen("crit", /obj/screen/fullscreen/crit, severity)
	else
		clear_fullscreen("crit")
		clear_fullscreen("critvision")

	//Oxygen damage overlay
	var/windedup = getOxyLoss() + getStaminaLoss() * 0.2
	if(windedup)
		var/severity = 0
		switch(windedup)
			if(10 to 20)
				severity = 1
			if(20 to 25)
				severity = 2
			if(25 to 30)
				severity = 3
			if(30 to 35)
				severity = 4
			if(35 to 40)
				severity = 5
			if(40 to 45)
				severity = 6
			if(45 to INFINITY)
				severity = 7
		overlay_fullscreen("oxy", /obj/screen/fullscreen/oxy, severity)
	else
		clear_fullscreen("oxy")

	//Fire and Brute damage overlay (BSSR)
	var/hurtdamage = getBruteLoss() + getFireLoss() + damageoverlaytemp
	if(hurtdamage)
		var/severity = 0
		switch(hurtdamage)
			if(5 to 15)
				severity = 1
			if(15 to 30)
				severity = 2
			if(30 to 45)
				severity = 3
			if(45 to 70)
				severity = 4
			if(70 to 85)
				severity = 5
			if(85 to INFINITY)
				severity = 6
		overlay_fullscreen("brute", /obj/screen/fullscreen/brute, severity)
	else
		clear_fullscreen("brute")

/mob/living/carbon/update_health_hud(shown_health_amount)
	if(!client || !hud_used)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			. = TRUE
			switch(pulse())
				if(PULSE_NONE)
					hud_used.healths.icon_state = "health7"
				if(PULSE_SLOW)
					hud_used.healths.icon_state = "health6"
				if(PULSE_THREADY)
					hud_used.healths.icon_state = "health5"
				if(PULSE_2FAST)
					hud_used.healths.icon_state = "health4"
				if(PULSE_FAST)
					hud_used.healths.icon_state = "health3"
				if(PULSE_NORM)
					hud_used.healths.icon_state = "health0"
				else
					hud_used.healths.icon_state = "health6"
		else
			hud_used.healths.icon_state = "health7"

/mob/living/carbon/proc/update_internals_hud_icon(internal_state = 0)
	if(hud_used && hud_used.internals)
		hud_used.internals.icon_state = "internal[internal_state]"

/mob/living/carbon/update_stat()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD)
		if(health <= HEALTH_THRESHOLD_DEAD && !HAS_TRAIT(src, TRAIT_NODEATH))
			death()
			return
		var/old_stat = stat
		if(IsUnconscious() || IsSleeping() || (getOxyLoss() >= 50) && (!mind ||(mind?.diceroll(STAT_DATUM(end)) <= DICE_FAILURE)) || (HAS_TRAIT(src, TRAIT_DEATHCOMA)))
			stat = UNCONSCIOUS
			SEND_SIGNAL(src, COMSIG_DISABLE_COMBAT_MODE)
			if(!eye_blind)
				blind_eyes(1)
		else
			if(InFullShock() && !HAS_TRAIT(src, TRAIT_NOSOFTCRIT))
				stat = SOFT_CRIT
				SEND_SIGNAL(src, COMSIG_DISABLE_COMBAT_MODE)
			else
				stat = CONSCIOUS
			if(eye_blind <= 1)
				adjust_blindness(-1)
		//update eyelids
		if(stat != old_stat && ishuman(src))
			dna?.species?.handle_body(src)
		update_mobility()
	update_damage_hud()
	update_health_hud()
	med_hud_set_status()

//called when we get cuffed/uncuffed
/mob/living/carbon/proc/update_handcuffed()
	if(handcuffed)
		drop_all_held_items()
		stop_pulling()
		throw_alert("handcuffed", /obj/screen/alert/restrained/handcuffed, new_master = src.handcuffed)
		if(handcuffed.demoralize_criminals)
			SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "handcuffed", /datum/mood_event/handcuffed)
	else
		clear_alert("handcuffed")
		SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "handcuffed")
	update_action_buttons_icon() //some of our action buttons might be unusable when we're handcuffed.
	update_inv_handcuffed()
	update_hud_handcuffed()

/mob/living/carbon/proc/can_defib()
	var/tlimit = DEFIB_TIME_LIMIT * 10
	var/obj/item/organ/heart = getorgan(/obj/item/organ/heart)
	if(suiciding || hellbound || HAS_TRAIT(src, TRAIT_HUSK) || AmBloodsucker(src))
		return
	if((world.time - timeofdeath) > tlimit)
		return
	if((getBruteLoss() >= MAX_REVIVE_BRUTE_DAMAGE) || (getFireLoss() >= MAX_REVIVE_FIRE_DAMAGE))
		return
	if(!heart || (heart.organ_flags & ORGAN_FAILING))
		return
	var/obj/item/organ/brain/BR = getorgan(/obj/item/organ/brain)
	if(QDELETED(BR) || BR.brain_death || (BR.organ_flags & ORGAN_FAILING) || suiciding)
		return
	return TRUE

/mob/living/carbon/fully_heal(admin_revive = FALSE)
	if(reagents)
		reagents.clear_reagents()
	var/obj/item/organ/brain/B = getorgan(/obj/item/organ/brain)
	if(B)
		B.brain_death = FALSE
	remove_all_embedded_objects()
	shock_stage = 0
	setPainLoss(0, FALSE)
	janitize(0, 0, 0)
	for(var/O in internal_organs)
		var/obj/item/organ/organ = O
		organ.rejecting = FALSE
		organ.setOrganDamage(0)
		organ.organ_flags &= ~ORGAN_CUT_AWAY
		organ.organ_flags &= ~ORGAN_DEAD
		organ.janitize(0, 0, 0)
	for(var/BP in bodyparts)
		var/obj/item/bodypart/bodypart = BP
		if(admin_revive && bodypart.is_stump())
			qdel(bodypart)
			continue
		bodypart.rejecting = FALSE
		bodypart.janitize(0, 0, 0)
		bodypart.fill_teeth()
		bodypart.limb_flags &= ~BODYPART_CUT_AWAY
		bodypart.limb_flags &= ~BODYPART_DEAD
		for(var/datum/injury/IN in bodypart.injuries)
			qdel(IN)
		bodypart.update_injuries()
	for(var/thing in diseases)
		var/datum/disease/D = thing
		if(D.severity != DISEASE_SEVERITY_POSITIVE)
			D.cure(FALSE)
	for(var/i in all_wounds)
		var/datum/wound/W = i
		if(istype(W))
			qdel(W)
	if(admin_revive)
		regenerate_limbs()
		regenerate_organs()
		handcuffed = initial(handcuffed)
		for(var/obj/item/restraints/R in contents) //actually remove cuffs from inventory
			qdel(R)
		update_handcuffed()
		if(reagents)
			for(var/addi in reagents.addiction_list)
				reagents.remove_addiction(addi)
	if(blood_volume < (BLOOD_VOLUME_NORMAL*blood_ratio))
		blood_volume = (BLOOD_VOLUME_NORMAL*blood_ratio)
	drunkenness = 0
	cure_all_traumas(TRAUMA_RESILIENCE_MAGIC)
	set_heartattack(FALSE)
	. = ..()
	// heal ears after healing traits, since ears check TRAIT_DEAF trait
	// when healing.
	restoreEars()
	REMOVE_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)

/mob/living/carbon/can_be_revived()
	. = ..()
	if(!getorgan(/obj/item/organ/brain) && (!mind || !mind.has_antag_datum(/datum/antagonist/changeling)))
		return 0
	if(HAS_TRAIT(src, TRAIT_DNR))
		return 0

/mob/living/carbon/harvest(mob/living/user)
	if(QDELETED(src))
		return
	var/organs_amt = 0
	for(var/X in internal_organs)
		var/obj/item/organ/O = X
		if(prob(50))
			organs_amt++
			O.Remove()
			O.forceMove(drop_location())
	if(organs_amt)
		to_chat(user, "<span class='notice'>You retrieve some of [src]\'s internal organs!</span>")

/mob/living/carbon/ExtinguishMob()
	for(var/X in get_equipped_items())
		var/obj/item/I = X
		I.acid_level = 0 //washes off the acid on our clothes
		I.extinguish() //extinguishes our clothes
	..()

/mob/living/carbon/fakefire(var/fire_icon = "Generic_mob_burning")
	var/mutable_appearance/new_fire_overlay = mutable_appearance('icons/mob/OnFire.dmi', fire_icon, -FIRE_LAYER)
	new_fire_overlay.appearance_flags = RESET_COLOR
	overlays_standing[FIRE_LAYER] = new_fire_overlay
	apply_overlay(FIRE_LAYER)

/mob/living/carbon/fakefireextinguish()
	remove_overlay(FIRE_LAYER)

/mob/living/carbon/proc/devour_mob(mob/living/carbon/C, devour_time = 130)
	C.visible_message("<span class='danger'>[src] is attempting to devour [C]!</span>", \
					"<span class='userdanger'>[src] is attempting to devour you!</span>")
	if(!do_mob(src, C, devour_time))
		return
	if(pulling && pulling == C && grab_state >= GRAB_AGGRESSIVE && a_intent == INTENT_GRAB)
		C.visible_message("<span class='danger'>[src] devours [C]!</span>", \
						"<span class='userdanger'>[src] devours you!</span>")
		C.forceMove(src)
		stomach_contents.Add(C)
		log_combat(src, C, "devoured")

/mob/living/carbon/do_after_coefficent()
	. = ..()
	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood) //Currently, only carbons or higher use mood, move this once that changes.
	if(mood)
		switch(mood.sanity) //Alters do_after delay based on how sane you are
			if(SANITY_INSANE to SANITY_DISTURBED)
				. *= 1.25
			if(SANITY_NEUTRAL to SANITY_GREAT)
				. *= 0.90


/mob/living/carbon/proc/create_internal_organs()
	for(var/X in internal_organs)
		var/obj/item/organ/I = X
		I.Insert(src)

/mob/living/carbon/proc/update_disabled_bodyparts()
	for(var/B in bodyparts)
		var/obj/item/bodypart/BP = B
		BP.update_disabled()

/mob/living/carbon/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---------")
	VV_DROPDOWN_OPTION(VV_HK_MAKE_AI, "Make AI")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_BODYPART, "Modify bodypart")
	VV_DROPDOWN_OPTION(VV_HK_MODIFY_ORGANS, "Modify organs")
	VV_DROPDOWN_OPTION(VV_HK_HALLUCINATION, "Hallucinate")
	VV_DROPDOWN_OPTION(VV_HK_MARTIAL_ART, "Give Martial Arts")
	VV_DROPDOWN_OPTION(VV_HK_GIVE_TRAUMA, "Give Brain Trauma")
	VV_DROPDOWN_OPTION(VV_HK_CURE_TRAUMA, "Cure Brain Traumas")

/mob/living/carbon/vv_do_topic(list/href_list)
	. = ..()
	if(href_list[VV_HK_MODIFY_BODYPART])
		if(!check_rights(R_SPAWN))
			return
		var/edit_action = input(usr, "What would you like to do?","Modify Body Part") as null|anything in list("add","remove", "augment")
		if(!edit_action)
			return
		var/list/limb_list = list()
		if(edit_action == "remove" || edit_action == "augment")
			for(var/obj/item/bodypart/B in bodyparts)
				limb_list += B.body_zone
			if(edit_action == "remove")
				limb_list -= BODY_ZONE_CHEST
		else
			limb_list = list(BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			for(var/obj/item/bodypart/B in bodyparts)
				limb_list -= B.body_zone
		var/result = input(usr, "Please choose which body part to [edit_action]","[capitalize(edit_action)] Body Part") as null|anything in limb_list
		if(result)
			var/obj/item/bodypart/BP = get_bodypart(result)
			switch(edit_action)
				if("remove")
					if(BP)
						BP.drop_limb()
					else
						to_chat(usr, "[src] doesn't have such bodypart.")
				if("add")
					if(BP)
						to_chat(usr, "[src] already has such bodypart.")
					else
						if(!regenerate_limb(result))
							to_chat(usr, "[src] cannot have such bodypart.")
				if("augment")
					if(ishuman(src))
						if(BP)
							BP.change_bodypart_status(BODYPART_ROBOTIC, TRUE, TRUE)
						else
							to_chat(usr, "[src] doesn't have such bodypart.")
					else
						to_chat(usr, "Only humans can be augmented.")
		admin_ticket_log("[key_name_admin(usr)] has modified the bodyparts of [src]")
	if(href_list[VV_HK_MAKE_AI])
		if(!check_rights(R_SPAWN))
			return
		if(alert("Confirm mob type change?",,"Transform","Cancel") != "Transform")
			return
		usr.client.holder.Topic("vv_override", list("makeai"=href_list[VV_HK_TARGET]))
	if(href_list[VV_HK_MODIFY_ORGANS])
		if(!check_rights(NONE))
			return
		usr.client.manipulate_organs(src)
	if(href_list[VV_HK_MARTIAL_ART])
		if(!check_rights(NONE))
			return
		var/list/artpaths = subtypesof(/datum/martial_art)
		var/list/artnames = list()
		for(var/i in artpaths)
			var/datum/martial_art/M = i
			artnames[initial(M.name)] = M
		var/result = input(usr, "Choose the martial art to teach","JUDO CHOP") as null|anything in artnames
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(result)
			var/chosenart = artnames[result]
			var/datum/martial_art/MA = new chosenart
			MA.teach(src)
			log_admin("[key_name(usr)] has taught [MA] to [key_name(src)].")
			message_admins("<span class='notice'>[key_name_admin(usr)] has taught [MA] to [key_name_admin(src)].</span>")
	if(href_list[VV_HK_GIVE_TRAUMA])
		if(!check_rights(NONE))
			return
		var/list/traumas = subtypesof(/datum/brain_trauma)
		var/result = input(usr, "Choose the brain trauma to apply","Traumatize") as null|anything in traumas
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(!result)
			return
		var/datum/brain_trauma/BT = gain_trauma(result)
		if(BT)
			log_admin("[key_name(usr)] has traumatized [key_name(src)] with [BT.name]")
			message_admins("<span class='notice'>[key_name_admin(usr)] has traumatized [key_name_admin(src)] with [BT.name].</span>")
	if(href_list[VV_HK_CURE_TRAUMA])
		if(!check_rights(NONE))
			return
		cure_all_traumas(TRAUMA_RESILIENCE_ABSOLUTE)
		log_admin("[key_name(usr)] has cured all traumas from [key_name(src)].")
		message_admins("<span class='notice'>[key_name_admin(usr)] has cured all traumas from [key_name_admin(src)].</span>")
	if(href_list[VV_HK_HALLUCINATION])
		if(!check_rights(NONE))
			return
		var/list/hallucinations = subtypesof(/datum/hallucination)
		var/result = input(usr, "Choose the hallucination to apply","Send Hallucination") as null|anything in hallucinations
		if(!usr)
			return
		if(QDELETED(src))
			to_chat(usr, "Mob doesn't exist anymore")
			return
		if(result)
			new result(src, TRUE)

/mob/living/carbon/can_resist()
	return bodyparts.len > 2 && ..()

/mob/living/carbon/proc/hypnosis_vulnerable()//unused atm, but added in case
	if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
		return FALSE
	if(hallucinating())
		return TRUE
	if(IsSleeping())
		return TRUE
	if(HAS_TRAIT(src, TRAIT_DUMB))
		return TRUE
	var/datum/component/mood/mood = src.GetComponent(/datum/component/mood)
	if(mood)
		if(mood.sanity < SANITY_UNSTABLE)
			return TRUE

/mob/living/carbon/can_see_reagents()
	. = ..()
	if(.) //No need to run through all of this if it's already true.
		return
	if(isclothing(head))
		var/obj/item/clothing/H = head
		if(H.clothing_flags & SCAN_REAGENTS)
			return TRUE
	if(isclothing(wear_mask) && (wear_mask.clothing_flags & SCAN_REAGENTS))
		return TRUE

/mob/living/carbon/can_hold_items()
	return TRUE

/mob/living/carbon/set_gender(ngender = NEUTER, silent = FALSE, update_icon = TRUE, forced = FALSE)
	var/bender = gender != ngender
	. = ..()
	if(!.)
		return
	if(dna && bender)
		if(ngender == MALE || ngender == FEMALE)
			dna.features["body_model"] = ngender
			if(!silent)
				var/adj = ngender == MALE ? "masculine" : "feminine"
				visible_message("<span class='boldnotice'>[src] suddenly looks more [adj]!</span>", "<span class='boldwarning'>You suddenly feel more [adj]!</span>")
		else if(ngender == NEUTER)
			dna.features["body_model"] = MALE
	if(update_icon)
		update_body()

/mob/living/carbon/proc/get_total_bleed_rate()
	var/total_bleed_rate = 0
	for(var/i in bodyparts)
		var/obj/item/bodypart/BP = i
		total_bleed_rate += BP.get_bleed_rate()

	return total_bleed_rate

/// if any of our bodyparts are bleeding
/mob/living/carbon/proc/is_bleeding()
	for(var/i in bodyparts)
		var/obj/item/bodypart/BP = i
		if(BP.get_bleed_rate())
			return TRUE

// Check if any of our limbs is gauzed
/mob/living/proc/has_gauze()
	return FALSE

/mob/living/carbon/has_gauze()
	for(var/obj/item/bodypart/limb in bodyparts)
		if(limb.current_gauze)
			return limb.current_gauze

// If our face is visible
/mob/living/carbon/is_face_visible()
	return !(wear_mask?.flags_inv & HIDEFACE) && !(head?.flags_inv & HIDEFACE)

/mob/living/carbon/proc/get_biological_state()
	. = BIO_INORGANIC

/mob/living/carbon/is_asystole()
	if(!needs_heart() || HAS_TRAIT(src, TRAIT_STABLEHEART))
		return FALSE

	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(!istype(heart) || !heart.is_working())
		return TRUE
	return FALSE

//Blood volume, affected by the heart
/mob/living/carbon/proc/get_blood_circulation()
	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	var/apparent_blood_volume = blood_volume
	// The dreamer does not give a fuck about blood loss
	if(HAS_TRAIT(src, TRAIT_BLOODLOSSIMMUNE))
		return BLOOD_VOLUME_NORMAL
	if(HAS_TRAIT(src, TRAIT_STABLEHEART))
		return blood_volume

	if(!heart && needs_heart())
		return 0.25 * apparent_blood_volume

	var/pulse_mod = 1
	if(HAS_TRAIT(src, TRAIT_FAKEDEATH))
		pulse_mod = 1
	else
		switch(heart.pulse)
			if(-INFINITY to PULSE_NONE)
				if(length(heart.recent_pump) && (world.time <= text2num(heart.recent_pump[1]) + heart.pump_duration))
					pulse_mod *= heart.recent_pump[heart.recent_pump[1]]
				else
					pulse_mod *= 0.25 //Fuck.
			if(PULSE_SLOW)
				pulse_mod *= 0.9
			if(PULSE_FAST)
				pulse_mod *= 1.1
			if(PULSE_2FAST, PULSE_THREADY)
				pulse_mod *= 1.25

	apparent_blood_volume *= pulse_mod
	apparent_blood_volume *= max(0.3, (1-(heart.damage / heart.maxHealth)))

	if(!heart.open && chem_effects[CE_BLOCKAGE])
		apparent_blood_volume *= max(0, 1 - (chem_effects[CE_BLOCKAGE])/100)

	return min(apparent_blood_volume, BLOOD_VOLUME_NORMAL)

//Blood volume, affected by the condition of circulation organs, affected by the oxygen loss. What ultimately matters for brain.
/mob/living/carbon/proc/get_blood_oxygenation()
	var/apparent_blood_volume = get_blood_circulation()
	// The dreamer does not give a fuck about blood loss
	if(HAS_TRAIT(src, TRAIT_BLOODLOSSIMMUNE))
		return BLOOD_VOLUME_NORMAL
	if(blood_carries_oxygen())
		if(is_asystole()) // Heart is missing or isn't beating and we're not breathing (hardcrit)
			return min(apparent_blood_volume, BLOOD_VOLUME_SURVIVE)
		if(!needs_lungs())
			return apparent_blood_volume
	else
		apparent_blood_volume = BLOOD_VOLUME_NORMAL

	var/apparent_blood_volume_mod = max(0, 1 - round(getOxyLoss()/maxHealth, DAMAGE_PRECISION))
	var/oxygenated_mult = 0
	if(chem_effects[CE_OXYGENATED] == 1) // Dexalin
		oxygenated_mult = 0.5
	else if(chem_effects[CE_OXYGENATED] >= 2) // Dexalin plus
		oxygenated_mult = 0.8
	apparent_blood_volume_mod += (apparent_blood_volume_mod * oxygenated_mult)
	apparent_blood_volume = apparent_blood_volume * apparent_blood_volume_mod
	return min(apparent_blood_volume, BLOOD_VOLUME_NORMAL)

//Do we need blood to sustain the brain?
/mob/living/carbon/proc/blood_carries_oxygen()
	return TRUE

//Do we need lungs?
/mob/living/carbon/proc/needs_lungs()
	return TRUE

//Get the pulse integer
/mob/living/carbon/proc/pulse()
	var/obj/item/organ/heart/H = getorganslot(ORGAN_SLOT_HEART)
	return ((stat != DEAD) && H) ? H.pulse : PULSE_NONE

//A pulse to be read by players
/mob/living/carbon/proc/get_pulse_as_number()
	var/obj/item/organ/heart/heart_organ = getorganslot(ORGAN_SLOT_HEART)
	if(!heart_organ)
		return 0

	switch(pulse())
		if(PULSE_NONE)
			return 0
		if(PULSE_SLOW)
			return rand(40, 60)
		if(PULSE_NORM)
			return rand(60, 90)
		if(PULSE_FAST)
			return rand(90, 120)
		if(PULSE_2FAST)
			return rand(120, 160)
		if(PULSE_THREADY)
			return PULSE_MAX_BPM

	return 0

//Generates realistic-ish pulse output based on preset levels as text
/mob/living/carbon/proc/get_pulse(method)	//method 0 is for hands, 1 is for machines, more accurate
	var/obj/item/organ/heart/heart_organ = getorganslot(ORGAN_SLOT_HEART)
	if(!heart_organ)
		// No heart, no pulse
		return "0"
	if(heart_organ.open && !method)
		// Heart is a open type (?) and cannot be checked unless it's a machine
		return "muddled and unclear; you can't seem to find a vein"

	var/bpm = get_pulse_as_number()
	if(bpm >= PULSE_MAX_BPM)
		if(method == GETPULSE_ADVANCED)
			return ">[PULSE_MAX_BPM]"
		else
			return "extremely weak and fast, patient's artery feels like a thread"

	if(method == GETPULSE_ADVANCED)
		return "[bpm]"
	else
		return "[bpm > 0 ? max(0, bpm + rand(-10, 10)) : 0]"

//Get how damaged the mob is, regardless of how fucked the brain is.
/mob/living/carbon/get_physical_damage()
	return round(maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - getBruteLoss() - getFireLoss(), DAMAGE_PRECISION)

//Brain is fried.
/mob/living/carbon/nervous_system_failure()
	var/obj/item/organ/brain/brain = getorgan(ORGAN_SLOT_BRAIN)
	if(CHECK_BITFIELD(brain?.organ_flags, ORGAN_CUT_AWAY))
		return TRUE
	return (getBrainLoss() >= maxHealth * 0.75)

//Replaces crit with shock
/mob/living/carbon/InCritical()
	if(!ishuman(src)) //Horrible.
		return ..()
	return InShock()

/mob/living/carbon/InFullCritical()
	if(!ishuman(src)) //Horrible.
		return ..()
	return InFullShock()

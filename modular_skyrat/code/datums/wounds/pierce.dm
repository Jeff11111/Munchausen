//skyrat edit obviously
/*
	Pierce
*/

/datum/wound/pierce
	sound_effect = 'sound/weapons/slice.ogg'
	processes = TRUE
	wound_type = WOUND_LIST_PIERCE
	treatable_by = list(/obj/item/stack/medical/suture)
	treatable_by_grabbed = list(/obj/item/gun/energy/laser)
	treatable_tool = TOOL_CAUTERY
	accepts_gauze = TRUE

	/// How much blood we start losing when this wound is first applied
	var/initial_flow
	/// If gauzed, what percent of the internal bleeding actually clots of the total absorption rate
	var/gauzed_clot_rate

	/// How much flow we've already cauterized
	var/cauterized
	/// How much flow we've already sutured
	var/sutured
	/// When hit on this bodypart, we have this chance of losing some blood + the incoming damage
	var/internal_bleeding_chance
	/// If we let off blood when hit, the max blood lost is this * the incoming damage
	var/internal_bleeding_coefficient

	base_treat_time = 2.5 SECONDS
	biology_required = list(HAS_FLESH)
	required_status = BODYPART_ORGANIC
	can_self_treat = TRUE
	wound_flags = (MANGLES_SKIN | MANGLES_MUSCLE)

/datum/wound/pierce/self_treat(mob/living/carbon/user, first_time = FALSE)
	. = ..()
	if(.)
		return TRUE
	
	if(victim && limb?.body_zone)
		victim.attempt_self_grasp(victim, limb.body_zone)
		return

/datum/wound/pierce/wound_injury(datum/wound/old_wound)
	blood_flow = initial_flow

/datum/wound/pierce/handle_process()
	blood_flow = min(blood_flow, WOUND_PIERCE_MAX_BLOODFLOW)

	if(victim.bodytemperature < (BODYTEMP_NORMAL -  10))
		blood_flow -= 0.2
		if(prob(5))
			to_chat(victim, "<span class='notice'>You feel the [lowertext(name)] in your [limb.name] firming up from the cold!</span>")

	if(victim?.reagents?.has_reagent(/datum/reagent/toxin/heparin))
		blood_flow += 0.5 // old herapin used to just add +2 bleed stacks per tick, this adds 0.5 bleed flow to all open cuts which is probably even stronger as long as you can cut them first
	else if(victim?.reagents?.has_reagent(/datum/reagent/medicine/coagulant))
		blood_flow -= 0.25

	if(limb.current_gauze)
		blood_flow -= limb.current_gauze.absorption_rate * gauzed_clot_rate
		limb.current_gauze.absorption_capacity -= limb.current_gauze.absorption_rate

	if(blood_flow <= 0)
		qdel(src)

/datum/wound/pierce/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/gun/energy/laser))
		las_cauterize(I, user)
	else if(istype(I, /obj/item/stack/medical/suture))
		suture(I, user)
	else if(I.tool_behaviour == TOOL_CAUTERY || I.get_temperature() > 300)
		tool_cauterize(I, user)

/datum/wound/pierce/on_xadone(power)
	. = ..()
	blood_flow -= 0.03 * power // i think it's like a minimum of 3 power, so .09 blood_flow reduction per tick is pretty good for 0 effort


/// If someone is using a suture to close this cut
/datum/wound/pierce/proc/suture(obj/item/stack/medical/suture/I, mob/user)
	user.visible_message("<span class='notice'>[user] begins stitching [victim]'s [limb.name] with [I]...</span>", "<span class='notice'>You begin stitching [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	var/time_mod = (user == victim ? 2 : 1)

	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, base_treat_time * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return
	
	if(!I.use(1))
		to_chat(user, "<span class='warning'>There aren't enough stacks of [I.name] to heal \the [src.name]!</span>")
		return
	
	user.visible_message("<span class='green'>[user] stitches up some of the bleeding on [victim].</span>", "<span class='green'>You stitch up some of the bleeding on [user == victim ? "yourself" : "[victim]"].</span>")
	var/blood_sutured = I.stop_bleeding / time_mod * 0.5
	blood_flow -= blood_sutured
	limb.heal_damage(I.heal_brute, I.heal_burn)

	if(blood_flow > 0)
		try_treating(I, user)
	else
		to_chat(user, "<span class='green'>You successfully close the hole in [user == victim ? "your" : "[victim]'s"] [limb.name].</span>")

/// If someone is using either a cautery tool or something with heat to cauterize this pierce
/datum/wound/pierce/proc/tool_cauterize(obj/item/I, mob/user)
	user.visible_message("<span class='danger'>[user] begins cauterizing [victim]'s [limb.name] with [I]...</span>", "<span class='danger'>You begin cauterizing [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	var/time_mod = (user == victim ? 2 : 1)

	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(!do_after(user, base_treat_time * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] cauterizes some of the bleeding on [victim].</span>", "<span class='green'>You cauterize some of the bleeding on [victim].</span>")
	if(user.mind?.diceroll(GET_STAT_LEVEL(user, int)*0.25, GET_SKILL_LEVEL(user, firstaid) * 0.75) < DICE_SUCCESS)
		limb.receive_damage(burn = min(1 + severity, 3), wound_bonus = CANT_WOUND)
	if(prob(30))
		victim.emote("scream")
	var/blood_cauterized = (0.6 / max(1, time_mod))
	blood_flow -= blood_cauterized

	if(blood_flow > 0)
		try_treating(I, user)

/// If someone's putting a laser gun up to our cut to cauterize it
/datum/wound/pierce/proc/las_cauterize(obj/item/gun/energy/laser/lasgun, mob/user)
	var/time_mod = (user == victim ? 2 : 1)

	//Ranged skill affects the speed of the do_mob lol
	if(user.mind)
		var/datum/skills/ranged/ranged = GET_SKILL(user, ranged)
		if(ranged)
			time_mod *= ((MAX_SKILL/2)/ranged.level)
	
	user.visible_message("<span class='warning'>[user] begins aiming [lasgun] directly at [victim]'s [fake_limb ? "[fake_limb] stump" : limb.name]...</span>", "<span class='userdanger'>You begin aiming [lasgun] directly at [user == victim ? "your" : "[victim]'s"] [fake_limb ? "[fake_limb] stump" : limb.name]...</span>")
	if(!do_after(user, base_treat_time  * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return
	var/damage = lasgun.chambered.BB.damage
	lasgun.chambered.BB.wound_bonus -= 30
	lasgun.chambered.BB.damage *= time_mod
	if(!lasgun.process_fire(victim, victim, TRUE, null, limb.body_zone))
		return
	victim.emote("scream")
	blood_flow -= damage / (5 * time_mod) // 20 / 5 = 4 bloodflow removed, p good
	victim.visible_message("<span class='warning'>The punctures on [victim]'s [fake_limb ? "[fake_limb] stump" : limb.name] scar over!</span>")

/datum/wound/pierce/moderate
	name = "Minor Breakage"
	desc = "Patient's skin has been broken open, causing severe bruising and minor internal bleeding in affected area."
	treat_text = "Treat affected site with bandaging or exposure to extreme cold. In dire cases, brief exposure to vacuum may suffice." // lol shove your bruised arm out into space, ss13 logic
	examine_desc = "has a small, circular hole, slowly bleeding"
	occur_text = "spurts out a thin stream of blood"
	sound_effect = 'modular_skyrat/sound/effects/blood1.ogg'
	severity = WOUND_SEVERITY_MODERATE
	viable_zones = ALL_BODYPARTS
	initial_flow = 2
	gauzed_clot_rate = 0.4
	internal_bleeding_chance = 30
	internal_bleeding_coefficient = 1.25
	threshold_minimum = 30
	threshold_penalty = 20
	status_effect_type = /datum/status_effect/wound/pierce/moderate
	scarring_descriptions = list("a small, faded bruise", "a small twist of reformed skin", "a thumb-sized puncture scar")
	pain_amount = 8
	infection_chance = 35 //low, but possible
	infection_rate = 4
	descriptive = "The skin is penetrated!"

/datum/wound/pierce/severe
	name = "Open Puncture"
	desc = "Patient's internal tissue is penetrated, causing sizeable internal bleeding and reduced limb stability."
	treat_text = "Repair punctures in skin by suture or cautery, extreme cold may also work."
	examine_desc = "is pierced clear through, with bits of tissue obscuring the open hole"
	occur_text = "lets loose a violent spray of blood, revealing a nasty pierce wound"
	sound_effect = 'modular_skyrat/sound/effects/blood2.ogg'
	severity = WOUND_SEVERITY_SEVERE
	viable_zones = ALL_BODYPARTS
	initial_flow = 3.25
	gauzed_clot_rate = 0.5
	internal_bleeding_chance = 60
	internal_bleeding_coefficient = 1.5
	threshold_minimum = 50
	threshold_penalty = 35
	status_effect_type = /datum/status_effect/wound/pierce/severe
	scarring_descriptions = list("an ink-splat shaped pocket of scar tissue", "a long-faded puncture wound", "a tumbling puncture hole with evidence of faded stitching")
	pain_amount = 15
	infection_chance = 60 //yep possible
	infection_rate = 5
	descriptive = "The flesh is penetrated!"

/datum/wound/pierce/critical
	name = "Ruptured Cavity"
	desc = "Patient's internal tissue and circulatory system is shredded, causing significant internal bleeding and damage to internal organs."
	treat_text = "Surgical repair of puncture wound, followed by supervised resanguination."
	examine_desc = "is ripped clear through, barely held together by exposed bone and tissue"
	occur_text = "blasts apart, sending chunks of viscera flying in all directions"
	sound_effect = 'modular_skyrat/sound/effects/blood3.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	viable_zones = ALL_BODYPARTS
	initial_flow = 4.25
	gauzed_clot_rate = 0.6
	internal_bleeding_chance = 80
	internal_bleeding_coefficient = 1.75
	threshold_minimum = 100
	threshold_penalty = 50
	status_effect_type = /datum/status_effect/wound/pierce/critical
	scarring_descriptions = list("a rippling shockwave of scar tissue", "a wide, scattered cloud of shrapnel marks", "a gruesome multi-pronged puncture scar")
	pain_amount = 20
	infection_chance = 80 //yep possible
	infection_rate = 6
	descriptive = "The flesh is ruptured!"

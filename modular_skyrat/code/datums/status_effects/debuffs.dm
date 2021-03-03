//Harm crusher
/datum/status_effect/crusher_mark/harm
	id = "crusher_mark_harm"
	duration = 100

/datum/status_effect/crusher_mark/harm/on_apply()
	. = ..()
	marked_underlay = mutable_appearance('icons/effects/effects.dmi', "shield2")
	marked_underlay.pixel_x = -owner.pixel_x
	marked_underlay.pixel_y = -owner.pixel_y
	owner.underlays += marked_underlay
	return TRUE

//Tracks the damage dealt to this mob by the ebony blade, based on crusher damage tracking
/datum/status_effect/ebony_damage
	id = "ebony_damage"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

//Holorifle burn
/datum/status_effect/holoburn
	id = "holoburn"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 10
	duration = 200
	alert_type = null
	var/icon/burn

/datum/status_effect/holoburn/on_apply()
	. = ..()
	if(iscarbon(owner))
		var/mob/living/carbon/C = owner
		burn = icon('modular_skyrat/icons/mob/onfire.dmi', "holoburn")
		C.add_overlay(burn)
	else
		burn = icon('modular_skyrat/icons/mob/onfire.dmi', "generic_holoburn")
		owner.add_overlay(burn)

/datum/status_effect/holoburn/tick()
	. = ..()
	owner.adjustCloneLoss(1)

/datum/status_effect/holoburn/on_remove()
	. = ..()
	owner.cut_overlay(burn)

//Cloning illness
/obj/screen/alert/cloneill
	name = "Cloning Illness"
	desc = "You still need to adapt to your new body... Your body feels frail, and you're more susceptible to damage and wounds."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "cloneill"

/datum/status_effect/cloneill
	id = "cloneill"
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 7 SECONDS
	duration = 15 MINUTES
	alert_type = /obj/screen/alert/cloneill
	var/healthpenalty = 25
	var/cloneloss_amount = 20
	var/hallucination_prob = 10
	var/storedmaxhealth = 0
	var/list/hallucinate_options = list(
		"Self",
		"Others",
		"Delusion",
		"Battle",
		"Bubblegum",
		"Message",
		"Battle",
		"Sound",
		"Weird Sound",
		"Station Message",
		"Health",
		"Alert",
		"Fire",
		"Shock",
		"Plasma Flood",
		"Random",
	)

/datum/status_effect/cloneill/on_creation(mob/living/new_owner, healthp = 25, cloneloss = 20, hallucination = 10)
	. = ..()
	healthpenalty = healthp
	cloneloss_amount = cloneloss
	hallucination_prob = hallucination

/datum/status_effect/cloneill/on_apply()
	. = ..()
	owner.adjustCloneLoss(cloneloss_amount)
	storedmaxhealth = owner.maxHealth
	owner.maxHealth -= healthpenalty
	ADD_TRAIT(owner, TRAIT_EASYLIMBDISABLE, "cloneill")
	ADD_TRAIT(owner, TRAIT_SCREWY_CHECKSELF, "cloneill")

/datum/status_effect/cloneill/on_remove()
	. = ..()
	owner.maxHealth = storedmaxhealth
	REMOVE_TRAIT(owner, TRAIT_EASYLIMBDISABLE, "cloneill")
	REMOVE_TRAIT(owner, TRAIT_SCREWY_CHECKSELF, "cloneill")

/datum/status_effect/cloneill/tick()
	. = ..()
	if(prob(hallucination_prob) && iscarbon(owner))
		var/mob/living/carbon/C = owner
		var/chosen_hallucination = pick(hallucinate_options)
		switch(chosen_hallucination)
			if("Message")
				new /datum/hallucination/chat(C, TRUE)
			if("Battle")
				new /datum/hallucination/battle(C, TRUE)
			if("Sound")
				new /datum/hallucination/sounds(C, TRUE)
			if("Weird Sound")
				new /datum/hallucination/weird_sounds(C, TRUE)
			if("Station Message")
				new /datum/hallucination/stationmessage(C, TRUE)
			if("Health")
				new /datum/hallucination/hudscrew(C, TRUE)
			if("Alert")
				new /datum/hallucination/fake_alert(C, TRUE)
			if("Fire")
				new /datum/hallucination/fire(C, TRUE)
			if("Shock")
				new /datum/hallucination/shock(C, TRUE)
			if("Plasma Flood")
				new /datum/hallucination/fake_flood(C, TRUE)
			if("Bubblegum")
				new /datum/hallucination/oh_yeah(C, TRUE)
			if("Battle")
				new /datum/hallucination/battle(C, TRUE)
			if("Others")
				new /datum/hallucination/items_other(C, TRUE)
			if("Self")
				new /datum/hallucination/items(C, TRUE)
			if("Delusion")
				new /datum/hallucination/delusion(C, TRUE)
			else
				var/hal_type = pick(subtypesof(/datum/hallucination))
				new hal_type(C, TRUE)

//Stumbling like a fucking idiot
/datum/status_effect/incapacitating/dazed/stumble
	id = "stumble"
	var/didknockdown = FALSE

/datum/status_effect/incapacitating/dazed/stumble/on_apply()
	. = ..()
	if(!didknockdown && iscarbon(owner))
		var/mob/living/C = owner
		if(C.mind)
			switch(C.mind.diceroll(STAT_DATUM(end)))
				if(DICE_FAILURE)
					C.DefaultCombatKnockdown(250)
				if(DICE_CRIT_FAILURE)
					C.DefaultCombatKnockdown(500)
		else
			C.DefaultCombatKnockdown(200)

/datum/status_effect/incapacitating/dazed/stumble/on_remove()
	. = ..()
	if(!didknockdown && iscarbon(owner))
		var/mob/living/C = owner
		if(C.mind)
			switch(C.mind.diceroll(STAT_DATUM(end)))
				if(DICE_CRIT_FAILURE)
					C.DefaultCombatKnockdown(50)
				if(DICE_FAILURE)
					C.DefaultCombatKnockdown(25)
				if(DICE_SUCCESS)
					C.DefaultCombatKnockdown(10)
		else
			C.DefaultCombatKnockdown(20)

/mob/living/proc/IsStumble() //If we're stumbling
	return has_status_effect(STATUS_EFFECT_STUMBLE)

/mob/living/proc/AmountStumble() //How many deciseconds remain in our Dazed status effect
	var/datum/status_effect/incapacitating/dazed/stumble/I = IsStumble()
	if(I)
		return I.duration - world.time
	return 0

/mob/living/proc/Stumble(amount, updating = TRUE, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_DAZE, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(!ignore_canstun && (!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/dazed/stumble/I = IsStumble()
	if(I)
		I.duration = max(world.time + amount, I.duration)
	else if(amount > 0)
		I = apply_status_effect(STATUS_EFFECT_STUMBLE, amount, updating)
	return I

/mob/living/proc/SetStumble(amount, updating = TRUE, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_DAZE, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(!ignore_canstun && (!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)))
		return
	var/datum/status_effect/incapacitating/dazed/stumble/I = IsStumble()
	if(amount <= 0)
		if(I)
			qdel(I)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(I)
			I.duration = world.time + amount
		else
			I = apply_status_effect(STATUS_EFFECT_STUMBLE, amount, updating)
	return I

/mob/living/proc/AdjustStumble(amount, updating = TRUE, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_DAZE, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(!ignore_canstun && (!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/dazed/stumble/I = IsStumble()
	if(I)
		I.duration += amount
	else if(amount > 0)
		I = apply_status_effect(STATUS_EFFECT_STUMBLE, amount, updating)
	return I

//head bad
/datum/status_effect/incapacitating/rapedhead
	id = "raped_head"
	tick_interval = 4 SECONDS
	var/static/list/alphas = list(128, 65, 64, 32, 16)
	var/intensity = 3
	var/list/screens = null
	var/list/new_screens = null
	blocks_sprint = TRUE

/datum/status_effect/incapacitating/rapedhead/on_apply()
	. = ..()
	if(owner?.hud_used)
		new_screens = list()
		screens = list(owner.hud_used.plane_masters["[FLOOR_PLANE]"], owner.hud_used.plane_masters["[ABOVE_FLOOR_PLANE]"],
					owner.hud_used.plane_masters["[WALL_PLANE]"], owner.hud_used.plane_masters["[ABOVE_WALL_PLANE]"],
					owner.hud_used.plane_masters["[GAME_PLANE]"], owner.hud_used.plane_masters["[MOB_PLANE]"],
					owner.hud_used.plane_masters["[FIELD_OF_VISION_VISUAL_PLANE]"], owner.hud_used.plane_masters["[OPENSPACE_BACKDROP_PLANE]"], 
					owner.hud_used.plane_masters["[CHAT_PLANE]"], owner.hud_used.plane_masters["[LIGHTING_PLANE]"],
					)
		for(var/obj/screen/plane_master/master in screens)
			new_screens["[master.plane]"] = list()
			for(var/i in 1 to min(intensity, length(alphas)))
				var/obj/screen/plane_master/servant = new /obj/screen/plane_master()
				servant.alpha = alphas[i]
				servant.render_source = master.render_target
				servant.plane = FULLSCREEN_PLANE
				servant.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
				new_screens["[master.plane]"] += servant
				owner.client?.screen += servant
		tick()

/datum/status_effect/incapacitating/rapedhead/tick()
	. = ..()
	if(length(screens))
		INVOKE_ASYNC(src, .proc/rape_head)

/datum/status_effect/incapacitating/rapedhead/proc/rape_head()
	var/list/offsets_x = list()
	for(var/i in 1 to min(intensity, length(alphas)))
		offsets_x += rand(-16, 16)
	var/list/offsets_y = list()
	for(var/i in 1 to min(intensity, length(alphas)))
		offsets_y += rand(-16, 16)
	for(var/obj/screen/plane_master/master in screens)
		var/list/servants = new_screens["[master.plane]"]
		var/i = 0
		for(var/serve in servants)
			i++
			spawn(0)
				var/obj/screen/plane_master/servant = serve
				var/matrix/old_transform = servant.transform
				var/matrix/new_transform = servant.transform.Translate(offsets_x[i], offsets_y[i])
				animate(servant, transform = new_transform, 2 SECONDS)
				sleep(2 SECONDS)
				animate(servant, transform = old_transform, 2 SECONDS)
	sleep(4 SECONDS)

/datum/status_effect/incapacitating/rapedhead/on_remove()
	if(length(screens) && length(new_screens))
		for(var/obj/screen/plane_master/master in screens)
			owner?.client?.screen -= new_screens["[master.plane]"]
			for(var/bingus in new_screens["[master.plane]"])
				qdel(bingus)
	screens = null
	new_screens = null
	. = ..()

/mob/living/proc/IsRapedhead() //If we're stumbling
	return has_status_effect(STATUS_EFFECT_RAPEDHEAD)

/mob/living/proc/AmountRapedhead() //How many deciseconds remain in our Dazed status effect
	var/datum/status_effect/incapacitating/rapedhead/I = IsRapedhead()
	if(I)
		return I.duration - world.time
	return 0

/mob/living/proc/Rapehead(amount, updating = TRUE, ignore_canstun = FALSE) //Can't go below remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_DAZE, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(!ignore_canstun && (!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/rapedhead/I = IsRapedhead()
	if(I)
		I.duration = max(world.time + amount, I.duration)
	else if(amount > 0)
		I = apply_status_effect(STATUS_EFFECT_RAPEDHEAD, amount, updating)
	return I

/mob/living/proc/SetRapedhead(amount, updating = TRUE, ignore_canstun = FALSE) //Sets remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_DAZE, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(!ignore_canstun && (!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)))
		return
	var/datum/status_effect/incapacitating/rapedhead/I = IsRapedhead()
	if(amount <= 0)
		if(I)
			qdel(I)
	else
		if(absorb_stun(amount, ignore_canstun))
			return
		if(I)
			I.duration = world.time + amount
		else
			I = apply_status_effect(STATUS_EFFECT_RAPEDHEAD, amount, updating)
	return I

/mob/living/proc/AdjustRapedhead(amount, updating = TRUE, ignore_canstun = FALSE) //Adds to remaining duration
	if(SEND_SIGNAL(src, COMSIG_LIVING_STATUS_DAZE, amount, updating, ignore_canstun) & COMPONENT_NO_STUN)
		return
	if(!ignore_canstun && (!(status_flags & CANKNOCKDOWN) || HAS_TRAIT(src, TRAIT_STUNIMMUNE)))
		return
	if(absorb_stun(amount, ignore_canstun))
		return
	var/datum/status_effect/incapacitating/rapedhead/I = IsRapedhead()
	if(I)
		I.duration += amount
	else if(amount > 0)
		I = apply_status_effect(STATUS_EFFECT_RAPEDHEAD, amount, updating)
	return I

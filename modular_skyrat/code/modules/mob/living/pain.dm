// Pain. Ported from Baystation 12 and cleaned up a bit.
/mob/living
	var/last_pain_message = ""
	var/next_pain_time = 0
	var/next_pain_message_time = 0

// aghhh shiver me timbers shiver me ni-
/mob/living/proc/agony_scream()
	return

/mob/living/proc/agony_gargle()
	return

/mob/living/proc/death_rattle()
	return

//Called on Life()
/mob/living/proc/handle_pain()
	return

/mob/living/proc/can_feel_pain()
	return FALSE

/mob/living/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_LIVING_REVIVE, .proc/update_pain)
	RegisterSignal(src, COMSIG_MOB_DEATH, .proc/update_pain)

/mob/living/Destroy()
	. = ..()
	UnregisterSignal(src, COMSIG_LIVING_REVIVE)
	UnregisterSignal(src, COMSIG_MOB_DEATH)

/mob/proc/flash_pain(target_alpha = 175, settle_alpha = 0, time_in = 1, time_away = 5)
	if(hud_used?.redpains)
		var/obj/screen/fullscreen/pain/pain = hud_used.redpains
		animate(pain, alpha = target_alpha, time = time_in, easing = pick(ELASTIC_EASING, LINEAR_EASING))
		spawn(time_in)
			animate(pain, alpha = settle_alpha, time = time_away, easing = pick(ELASTIC_EASING, LINEAR_EASING))
		return TRUE

// Message is the custom message to be displayed
// Power decides how much painkillers will stop the message
// Force means it ignores anti-spam timer
// Robo_message is the message that gets used if it's a robotic limb instead
/mob/living/proc/custom_pain(message, power, force, obj/item/bodypart/affecting, nopainloss, robo_mesage)
	if((!message && !robo_mesage) || (stat >= UNCONSCIOUS) || !can_feel_pain() || chem_effects[CE_PAINKILLER] > power)
		return FALSE
	
	if(affecting?.status & BODYPART_NOPAIN)
		return FALSE

	power -= chem_effects[CE_PAINKILLER]/2	//Take the edge off.

	//Endurance takes the edge off a bit from the pain
	if(mind)
		var/datum/stats/end/end = GET_STAT(src, end)
		if(end?.level >= 10)
			power -= (end.level * 0.75)

	// Excessive pain is horrible, just give them enough to make it visible.
	if(!nopainloss && power)
		if(affecting)
			affecting.receive_damage(pain = CEILING(power/2, 1))
		else
			adjustPainLoss(CEILING(power/2, 1))

	// Anti message spam checks
	if(force || (message != last_pain_message) || (world.time >= next_pain_time))
		last_pain_message = message
		if(world.time >= next_pain_message_time)
			to_chat(src, "<span class='userdanger'>[message]</span>")

		var/force_emote
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			if(H.dna?.species)
				force_emote = H.dna.species.get_pain_emote(power)
		else if(ismonkey(src))
			force_emote = "groan"
		if(force_emote && prob(power))
			emote(force_emote)
	//Briefly flash the pain overlay
	flash_pain(min(round(power/30) * 255, 255), 0, rand(1,4), pick(5,10))
	next_pain_message_time = world.time + (rand(150, 250) - power)
	next_pain_time = world.time + (rand(100, 200) - power)
	return TRUE

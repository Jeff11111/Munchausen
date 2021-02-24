/mob/living/carbon/can_feel_pain()
	if(HAS_TRAIT(src, TRAIT_NOPAIN))
		return FALSE
	return TRUE

/mob/living/carbon/handle_pain()
	if((stat >= UNCONSCIOUS) || !can_feel_pain() || (world.time < next_pain_time))
		return
	
	//Great amounts of pain hinder your stamina
	if(get_shock() >= 30 && !lying)
		var/max_payne = get_shock()
		adjustStaminaLossBuffered(round(max_payne/15))
	
	var/maxdam = 0
	var/obj/item/bodypart/damaged_bodypart = null
	for(var/obj/item/bodypart/BP in bodyparts)
		if(!BP.can_feel_pain())
			continue
		var/dam = BP.get_damage()
		// make the choice of the organ depend on damage,
		// but also sometimes use one of the less damaged ones
		if(dam >= maxdam && (maxdam <= 0 || prob(70)) )
			damaged_bodypart = BP
			maxdam = dam
	
	if(damaged_bodypart && (chem_effects[CE_PAINKILLER] < maxdam))
		if(maxdam > 10 && IsParalyzed())
			var/datum/status_effect/incapacitating/paralyzed/P = IsParalyzed(FALSE)
			if(P)
				P.duration -= round(maxdam/10)
		if((damaged_bodypart.held_index) && maxdam >= 25 && prob(maxdam * 1.5))
			var/obj/item/droppy = get_item_for_held_index(damaged_bodypart.held_index)
			if(droppy)
				dropItemToGround(droppy)
		var/burning = damaged_bodypart.burn_dam > damaged_bodypart.brute_dam
		var/msg
		switch(maxdam)
			if(1 to 10)
				msg =  "My [damaged_bodypart.name] [burning ? "burns" : "hurts"]."
			if(11 to 90)
				msg = "My [damaged_bodypart.name] [burning ? "burns" : "hurts"] badly!"
			if(91 to INFINITY)
				msg = "OH GOD! My [damaged_bodypart.name] is [burning ? "on fire" : "hurting terribly"]!"
		custom_pain(msg, maxdam, FALSE, damaged_bodypart)
	
	// Damage to internal organs hurts a lot.
	for(var/obj/item/organ/O in internal_organs)
		if(prob(1) && !((O.organ_flags & ORGAN_FAILING) || (O.status & ORGAN_ROBOTIC)) && O.damage >= 5)
			var/obj/item/bodypart/parent = get_bodypart(O.zone)
			if(parent)
				var/pain = 10
				var/message = "I feel a dull pain in my [parent.name]."
				if(O.damage >= O.low_threshold)
					pain = 25
					message = "I feel a pain in my [parent.name]."
				if((O.damage >= O.high_threshold) || (O.organ_flags & ORGAN_FAILING))
					pain = 50
					message = "I feel a sharp pain in my [parent.name]."
				custom_pain(message, pain, FALSE, parent)

	var/toxDamageMessage = null
	var/toxMessageProb = 1
	var/toxin_damage = getToxLoss()
	switch(toxin_damage)
		if(1 to 5)
			toxMessageProb = 1
			toxDamageMessage = "My body stings slightly."
		if(5 to 10)
			toxMessageProb = 2
			toxDamageMessage = "My whole body hurts a little."
		if(10 to 20)
			toxMessageProb = 2
			toxDamageMessage = "My whole body hurts."
		if(20 to 30)
			toxMessageProb = 3
			toxDamageMessage = "My whole body hurts badly."
		if(30 to INFINITY)
			toxMessageProb = 5
			toxDamageMessage = "My body aches all over, it's driving me mad!"
	
	if(toxDamageMessage && prob(toxMessageProb))
		custom_pain(toxDamageMessage, toxin_damage)

/mob/living/carbon/update_pain()
	if(!client || !hud_used)
		return
	var/shock_val = get_shock()
	if(shock_val >= 30 && HAS_TRAIT(src, TRAIT_PAINGOOD))
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "pain", /datum/mood_event/paingood)
	else if(shock_val >= 60)
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "pain", /datum/mood_event/painbad)
	if(hud_used.pains)
		if(stat != DEAD)
			. = 1
			if(!HAS_TRAIT(src, TRAIT_SCREWY_CHECKSELF))
				switch(get_shock())
					if(-INFINITY to 5)
						hud_used.pains.icon_state = "pain0"
					if(5 to 15)
						hud_used.pains.icon_state = "pain1"
					if(15 to 30)
						hud_used.pains.icon_state = "pain2"
					if(30 to 45)
						hud_used.pains.icon_state = "pain3"
					if(45 to 60)
						hud_used.pains.icon_state = "pain4"
					if(60 to 75)
						hud_used.pains.icon_state = "pain5"
					if(75 to INFINITY)
						hud_used.pains.icon_state = "pain6"
			else
				hud_used.pains.icon_state = "pain0"
			//modo waker
			if(HAS_TRAIT(src, TRAIT_NOPAIN))
				hud_used.pains.icon_state = "paind"
		else
			hud_used.pains.icon_state = "pain7"

/mob/living/carbon/proc/print_pain()
	return check_self_for_injuries()

//How much we are actually in shock
/mob/living/carbon/proc/get_shock()
	if(!can_feel_pain())
		return 0

	var/traumatic_shock = getPainLoss() //How much pain we are in
	if(mind)
		var/datum/stats/end/end = GET_STAT(src, end)
		if(end)
			traumatic_shock *= end.get_shock_mult()
	traumatic_shock -= chem_effects[CE_PAINKILLER]
	return max(0,traumatic_shock)

/mob/living/carbon/proc/InShock()
	return (shock_stage >= SHOCK_STAGE_4)

/mob/living/carbon/proc/InFullShock()
	return (shock_stage >= SHOCK_STAGE_6)

/mob/living/carbon/proc/handle_shock()
	if(!can_feel_pain())
		shock_stage = 0
		return
	
	//Handle pain effects - as raw pain, not shock
	var/traumatic_shock = get_shock()
	if(traumatic_shock >= PAIN_GIVES_IN)
		switch(mind?.diceroll(STAT_DATUM(end)))
			//Critical success = nothing happens
			//Success = blurry eyes (update_health() handles the speed penalty)
			if(DICE_SUCCESS)
				blur_eyes(2)
			//Failure - we are knocked down
			if(DICE_FAILURE)
				blur_eyes(2)
				if(IsKnockdown())
					AdjustKnockdown(3 SECONDS)
				else
					visible_message("<span class='danger'><b>[src]</b> gives in to the pain!</span>", "<span class='userdanger'>I give in to the pain.</span>")
					//Cum blood on they screen
					//(very quick)
					flash_pain(255, 0, 1, 3)
					//Immobilize for a second
					Stun(1 SECONDS)
					//Fall down
					spawn(1 SECONDS)
						AdjustKnockdown(3 SECONDS)
			//Crit failure - unconsciousness
			if(DICE_CRIT_FAILURE)
				blur_eyes(2)
				if(!IsUnconscious())
					AdjustUnconscious(3 SECONDS)
				else
					visible_message("<span class='danger'><b>[src]</b> falls in to the pain!</span>", "<span class='userdanger'>I fall in to the pain.</span>")
					//Cum blood on they screen
					//(very quick)
					flash_pain(255, 0, 1, 3)
					//Immobilize for a second
					Stun(1 SECONDS)
					//Fall down
					spawn(1 SECONDS)
						AdjustUnconscious(3 SECONDS)

	//Start handling shock
	if(is_asystole())
		shock_stage = max(shock_stage + 1, SHOCK_STAGE_4)
	
	if(traumatic_shock >= max(SHOCK_STAGE_2, 0.8*shock_stage))
		shock_stage += 1
	else if(!is_asystole())
		shock_stage = min(shock_stage, SHOCK_STAGE_7)
		var/recovery = 1
		//Lower shock faster if pain is gone completely
		if(traumatic_shock < 0.5 * shock_stage)
			recovery++
		if(traumatic_shock < 0.25 * shock_stage)
			recovery++
		//High endurance means we recover even faster
		if(mind)
			var/datum/stats/end/end = GET_STAT(src, end)
			if(end.level > 10)
				recovery++
			if(end.level >= 15)
				recovery++
		shock_stage = max(shock_stage - recovery, 0)
		return

	if(stat > UNCONSCIOUS)
		return
	
	if(shock_stage == SHOCK_STAGE_1)
		// Please be very careful when calling custom_pain() from within code that relies on pain/trauma values. There's the
		// possibility of a feedback loop from custom_pain() being called with a positive power, incrementing pain on a limb,
		// which triggers this proc, which calls custom_pain(), etc. Make sure you call it with nopainloss = TRUE in these cases!
		custom_pain("[pick("It hurts so much", "You really need some painkillers", "Dear god, the pain")]!", 10, nopainloss = TRUE)

	if(shock_stage >= SHOCK_STAGE_2)
		if(shock_stage == SHOCK_STAGE_2)
			visible_message("<b>[src]</b> is having trouble keeping [p_their()] eyes open.")
		if(prob(30))
			blur_eyes(3)
			stuttering = max(stuttering, 5)

	if(shock_stage == SHOCK_STAGE_3)
		custom_pain("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!", 40, nopainloss = TRUE)
	
	if(shock_stage >= SHOCK_STAGE_4)
		if(shock_stage == SHOCK_STAGE_4)
			visible_message("<b>[src]</b>'s body becomes limp.")
			Paralyze(200)
		if(prob(2))
			custom_pain("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!", shock_stage, nopainloss = TRUE)
			DefaultCombatKnockdown(125)
		if(prob(4))
			emote("gasp")

	if(shock_stage >= SHOCK_STAGE_5)
		if(prob(5))
			custom_pain("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!", shock_stage, nopainloss = TRUE)
			DefaultCombatKnockdown(125)
			Paralyze(20 SECONDS)
		if(prob(4))
			if(!IsUnconscious())
				custom_pain("[pick("Every breath you take hurts", "Everything seems to be fading away", "Your mind feels numb")]!", shock_stage, nopainloss = TRUE)
			Unconscious(120 SECONDS)
		
	if(shock_stage >= SHOCK_STAGE_6)
		if(prob(2))
			if(!IsUnconscious())
				custom_pain("[pick("You black out", "You feel like you could die any moment now", "You're about to lose consciousness")]!", shock_stage, nopainloss = TRUE)
			Unconscious(rand(200 SECONDS, 300 SECONDS))
		if(prob(2))
			custom_pain("[pick("The pain is excruciating", "Please, just end the pain", "Your whole body is going numb")]!", shock_stage, nopainloss = TRUE)
			DefaultCombatKnockdown(200)
			Stun(40 SECONDS)

	if(shock_stage == SHOCK_STAGE_7)
		if(!IsKnockdown())
			visible_message("<b>[src]</b> can no longer stand, collapsing!")
		DefaultCombatKnockdown(200)
		Stun(50 SECONDS)
		agony_gargle()

	if(shock_stage >= SHOCK_STAGE_7)
		DefaultCombatKnockdown(200)
		Stun(50 SECONDS)
		if(prob(4))
			Unconscious(65 SECONDS)
		//Gargle our throat
		if(prob(10))
			agony_gargle()
	
	if(shock_stage == SHOCK_STAGE_8)
		//Death is near
		death_rattle()
	
	if(shock_stage >= SHOCK_STAGE_8)
		if(!IsUnconscious())
			visible_message("<span class='danger'><b>[src]</b> [dna.species.painloss_message]</span>", "<span class='userdanger'>[dna.species.painloss_message_self]</span>")
		//We are fucking dying, do the rattle
		if(prob(10))
			death_rattle()
		DefaultCombatKnockdown(200)
		Stun(80 SECONDS)
		Unconscious(120 SECONDS)

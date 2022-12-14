/mob/living/carbon/human/AltUnarmedAttack(atom/A, proximity, attackchain_flags)
	if(!has_active_hand())
		to_chat(src, "<span class='notice'>You look at the state of the universe and sigh.</span>") //lets face it, people rarely ever see this message in its intended condition.
		return TRUE
	
	//Dual intent means we attack with our offhand instead,
	//and thus ignore any alt attack functionality
	var/c_intent = combat_intent
	if(c_intent == CI_DUAL)
		var/obj/item/W = get_inactive_held_item()
		var/old_zone = zone_selected
		var/old_intent = a_intent
		a_intent = hand_index_to_intent[get_inactive_hand_index()]
		zone_selected = hand_index_to_zone[get_inactive_hand_index()]
		if(W)
			W.melee_attack_chain(src, A)
		else
			UnarmedAttack(A, TRUE)
		zone_selected = old_zone
		a_intent = old_intent
		return TRUE

	//Otherwise, try alt attacking
	if(!A.alt_attack_hand(src))
		A.attack_hand(src)
		return TRUE
	return TRUE

/mob/living/carbon/human/AltRangedAttack(atom/A, params)
	if(isturf(A) || incapacitated()) // pretty annoying to wave your fist at floors and walls. And useless.
		return TRUE
	changeNext_move(CLICK_CD_RANGE)
	var/list/target_viewers = fov_viewers(11, A) //doesn't check for blindness.
	if(!(src in target_viewers)) //click catcher issuing calls for out of view objects.
		return TRUE
	if(!has_active_hand())
		to_chat(src, "<span class='notice'>You ponder your life choices and sigh.</span>")
		return TRUE
	var/list/src_viewers = viewers(DEFAULT_MESSAGE_RANGE, src) - src // src has a different message.
	var/the_action = "waves to [A]"
	var/what_action = "waves to something you can't see"
	var/self_action = "wave to [A]"

	switch(a_intent)
		if(INTENT_DISARM)
			the_action = "shoos away [A]"
			what_action = "shoo away something out of your vision"
			self_action = "shoo away [A]"
		if(INTENT_GRAB)
			the_action = "beckons [A] to come"
			what_action = "beckons something out of your vision to come"
			self_action = "beckon [A] to come"
		if(INTENT_HARM)
			var/pronoun = "[p_their()]"
			the_action = "shakes [pronoun] fist at [A]"
			what_action = "shakes [pronoun] fist at something out of your vision"
			self_action = "shake your fist at [A]"

	if(!eye_blind)
		to_chat(src, "You [self_action].")
	for(var/B in src_viewers)
		var/mob/M = B
		if(!M.eye_blind)
			var/message = (M in target_viewers) ? the_action : what_action
			to_chat(M, "[src] [message].")
	return TRUE

/atom/proc/alt_attack_hand(mob/user)
	return FALSE

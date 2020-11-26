/obj/item/proc/middleclick_melee_attack_chain(mob/user, atom/target, params)
	//middle click bullshit
	if(!middle_pre_attack(target, user, params))
		return middleafterattack(target, user, TRUE, params)
	else
		return TRUE

/obj/item/proc/middle_pre_attack(atom/A, mob/living/user, params)
	return FALSE

/atom/proc/middleattackby(obj/item/W, mob/user, params)
	return FALSE

/obj/item/proc/middleclick_attack_self(mob/user)
	return FALSE

/obj/item/proc/middleafterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(SEND_SIGNAL(src, COMSIG_ITEM_MIDDLE_AFTERATTACK, target, user, proximity_flag, click_parameters))
		return TRUE
	if(get_sharpness())
		if(user.a_intent == INTENT_HELP)
			attempt_initiate_surgery(src, target, user)
		else if(user.mind && iscarbon(target))
			var/mob/living/carbon/victim = target
			var/obj/item/bodypart/BP = victim.get_bodypart(check_zone(user.zone_selected))
			if(!BP || INTERACTING_WITH(user, victim))
				return FALSE
			var/datum/skills/surgery/choppa = GET_SKILL_LEVEL(user, surgery)
			var/time = 1.5 SECONDS
			if(!victim.IsUnconscious())
				time *= 5
			time *= clamp((MAX_STAT/2)/choppa, 0.25, 2)
			var/diceroll = user.mind.diceroll(skills = SKILL_DATUM(surgery))
			if(BP.can_dismember())
				to_chat(user, "<span class='warning'>I start severing \the [target]'s [BP]...</span>")
				if(!do_mob(user, victim, time))
					to_chat(user, "<span class='warning'>I must stand still!</span>")
					return FALSE
				if(diceroll <= DICE_FAILURE)
					to_chat(user, "<span class='danger'>Oh no - I fucked up...</span>")
					if(prob(40))
						BP.painless_wound_roll(WOUND_SLASH, force, wound_bonus, bare_wound_bonus)
					return FALSE
				BP.dismember_wound(WOUND_SLASH)
				user.put_in_hands(BP)
			else if(BP.can_disembowel())
				to_chat(user, "<span class='warning'>I start slicing \the [target]'s [BP] open...</span>")
				if(!do_mob(user, victim, time))
					to_chat(user, "<span class='warning'>I must stand still!</span>")
					return FALSE
				if(diceroll <= DICE_FAILURE)
					to_chat(user, "<span class='danger'>Oh no - I fucked up...</span>")
					if(prob(40))
						BP.painless_wound_roll(WOUND_SLASH, force, wound_bonus, bare_wound_bonus)
					return FALSE
				BP.disembowel_wound(WOUND_SLASH)
			else if((BP.body_zone == BODY_ZONE_CHEST) && (length(victim.bodyparts) <= 1))
				to_chat(user, "<span class='warning'>I begin dissecting \the [target]'s [BP] open...</span>")
				if(!do_mob(user, victim, time))
					to_chat(user, "<span class='warning'>I must stand still!</span>")
					return FALSE
				if(diceroll <= DICE_FAILURE)
					to_chat(user, "<span class='danger'>Oh no - I fucked up...</span>")
					if(prob(40))
						BP.painless_wound_roll(WOUND_SLASH, force, wound_bonus, bare_wound_bonus)
					return FALSE
				BP.drop_limb(TRUE)
				user.put_in_hands(BP)
				qdel(victim)
		return TRUE
	return FALSE

/atom/proc/middle_attack_hand(mob/user)
	return FALSE

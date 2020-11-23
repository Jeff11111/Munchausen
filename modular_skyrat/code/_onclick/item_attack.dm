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
			if(!BP || !BP.can_dismember())
				return FALSE
			var/datum/skills/surgery/choppa = GET_SKILL_LEVEL(user, surgery)
			var/time = 1 SECONDS
			if(!victim.IsUnconscious())
				time *= 4
			time *= min(2, (MAX_STAT/2)/choppa)
			to_chat(user, "<span class='warning'>I start severing \the [target]'s [BP]...</span>")
			if(!do_mob(user, victim, time))
				to_chat(user, "<span class='warning'>I must stand still!</span>")
				return FALSE
			BP.dismember_wound(WOUND_SLASH)
		return TRUE
	return FALSE

/atom/proc/middle_attack_hand(mob/user)
	return FALSE

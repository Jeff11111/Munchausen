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
	SEND_SIGNAL(src, COMSIG_ITEM_MIDDLE_AFTERATTACK, target, user, proximity_flag, click_parameters)
	if(get_sharpness())
		if(user.a_intent == INTENT_HELP)
			attempt_initiate_surgery(src, target, user)
		return TRUE
	return FALSE

/atom/proc/middle_attack_hand(mob/user)
	return FALSE

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
		if(user.mind && iscarbon(target))
			var/mob/living/carbon/victim = target
			var/obj/item/bodypart/BP = victim.get_bodypart(check_zone(user.zone_selected))
			if(!BP || INTERACTING_WITH(user, victim))
				return FALSE
			var/datum/skills/surgery/choppa = GET_SKILL_LEVEL(user, surgery)
			var/time = 2 SECONDS
			if(victim.stat >= UNCONSCIOUS)
				time *= 3
			time *= clamp((MAX_STAT/2)/choppa, 0.25, 2)
			var/diceroll = user.mind.diceroll(skills = SKILL_DATUM(surgery))
			if(BP.can_dismember())
				user.visible_message("<span class='danger'><b>[user]</b> starts severing <b>[target]</b>'s [BP.name]!</span>", \
									"<span class='warning'>I start severing <b>\the [target]</b>'s [BP.name]...</span>", \
									target = target, \
									target_message = "<span class='userdanger'><b>[user]</b> starts severing my [BP.name]!</span>")
				if(!do_mob(user, victim, time))
					to_chat(user, "<span class='warning'>I must stand still!</span>")
					return FALSE
				if(diceroll <= DICE_CRIT_FAILURE)
					user.visible_message("<span class='danger'><b>[user]</b> botches the dismemberment!</span>", 
										"<span class='warning'>Oh no - I fucked up...</span>")
					if(prob(40))
						BP.create_injury(WOUND_SLASH, force * 2, FALSE, FALSE)
					return FALSE
				BP.apply_dismember(WOUND_SLASH)
				user.put_in_hands(BP)
			else if(BP.encased && !BP.get_incision(TRUE) && BP.get_organs())
				user.visible_message("<span class='danger'><b>[user]</b> starts dissecting <b>[target]</b>'s [BP.name]!</span>", \
									"<span class='warning'>I start dissecting <b>\the [target]</b>'s [BP.name]...</span>", \
									target = target, \
									target_message = "<span class='userdanger'><b>[user]</b> starts dissecting my [BP.name]!</span>")
				if(!do_mob(user, victim, time))
					to_chat(user, "<span class='warning'>I must stand still!</span>")
					return FALSE
				if(diceroll <= DICE_CRIT_FAILURE)
					user.visible_message("<span class='danger'><b>[user]</b> botches the dissection!</span>", 
										"<span class='warning'>Oh no - I fucked up...</span>")
					if(prob(40))
						BP.create_injury(WOUND_SLASH, force * 2, FALSE, FALSE)
					return FALSE
				var/datum/injury/ouchie = BP.create_injury(WOUND_SLASH, BP.max_damage * 0.75, TRUE)
				ouchie.apply_injury(BP.max_damage * 0.75, BP)
				ouchie.injury_flags |= (INJURY_SURGICAL | INJURY_RETRACTED_SKIN)
				if(!BP.is_broken())
					if(BP.is_robotic_limb())
						var/datum/wound/mechanical/blunt/critical/chungus = new()
						chungus.apply_wound(BP, TRUE)
					else
						var/datum/wound/blunt/critical/chungus = new()
						chungus.apply_wound(BP, TRUE)
				victim.wound_message = ""
				playsound(target, 'modular_skyrat/sound/gore/flesh.ogg', 75, 0)
			else if((BP.body_zone == BODY_ZONE_CHEST) && (length(victim.bodyparts) <= 1))
				user.visible_message("<span class='danger'><b>[user]</b> starts slicing <b>[target]</b> into a bloody carcass!</span>", \
									"<span class='warning'>I start slicing <b>[target]</b> into a carccass...</span>", \
									target = target, \
									target_message = "<span class='userdanger'><b>[user]</b> starts dissecting me into a carcass!</span>")
				if(!do_mob(user, victim, time))
					to_chat(user, "<span class='warning'>I must stand still!</span>")
					return FALSE
				if(diceroll <= DICE_FAILURE)
					user.visible_message("<span class='danger'><b>[user]</b> botches the dissection!</span>", 
										"<span class='warning'>Oh no - I fucked up...</span>")
					if(prob(40))
						BP.create_injury(WOUND_SLASH, force * 2, FALSE, FALSE)
					return FALSE
				BP.drop_limb(TRUE)
				user.put_in_hands(BP)
				qdel(victim)
		return TRUE
	return FALSE

/atom/proc/middle_attack_hand(mob/user)
	return FALSE

/**
  *This is the proc that handles the order of an item_attack.
  *The order of procs called is:
  *tool_act on the target. If it returns TRUE, the chain will be stopped.
  *pre_attack() on src. If this returns TRUE, the chain will be stopped.
  *attackby on the target. If it returns TRUE, the chain will be stopped.
  *and lastly
  *afterattack. The return value does not matter.
  */
/obj/item/proc/melee_attack_chain(mob/user, atom/target, params, flags, damage_multiplier = 1)
	if(isliving(user))
		var/mob/living/L = user
		if(!CHECK_MOBILITY(L, MOBILITY_USE) && !(flags & ATTACKCHAIN_PARRY_COUNTERATTACK))
			to_chat(L, "<span class='warning'>You are unable to swing [src] right now!</span>")
			return
		if(L.pinned() && w_class >= WEIGHT_CLASS_NORMAL)
			to_chat(L, "<span class='warning'>[src] is too heavy to use while pinned!</span>")
			return
	if(tool_behaviour && target.tool_act(user, src, tool_behaviour))
		return
	if(pre_attack(target, user, params))
		return
	if(target.attackby(src, user, params, flags, damage_multiplier))
		return
	if(QDELETED(src) || QDELETED(target))
		return
	afterattack(target, user, TRUE, params)

/// Like melee_attack_chain but for ranged.
/obj/item/proc/ranged_attack_chain(mob/user, atom/target, params)
	if(isliving(user))
		var/mob/living/L = user
		if(!CHECK_MOBILITY(L, MOBILITY_USE))
			to_chat(L, "<span class='warning'>You are unable to raise [src] right now!</span>")
			return
		if(L.pinned() && w_class >= WEIGHT_CLASS_NORMAL)
			to_chat(L, "<span class='warning'>[src] is too heavy to use while pinned!</span>")
			return
	afterattack(target, user, FALSE, params)

// Called when the item is in the active hand, and clicked; alternately, there is an 'activate held object' verb or you can hit pagedown.
/obj/item/proc/attack_self(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(L.pinned() && w_class >= WEIGHT_CLASS_NORMAL)
			to_chat(L, "<span class='warning'>[src] is too heavy to use while pinned!</span>")
			return
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user) & COMPONENT_NO_INTERACT)
		return
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK_SELF, src)
	interact(user)

/obj/item/proc/pre_attack(atom/A, mob/living/user, params) //do stuff before attackby!
	if(SEND_SIGNAL(src, COMSIG_ITEM_PRE_ATTACK, A, user, params) & COMPONENT_NO_ATTACK)
		return TRUE
	return FALSE //return TRUE to avoid calling attackby after this proc does stuff

// No comment
/atom/proc/attackby(obj/item/W, mob/user, params)
	if(SEND_SIGNAL(src, COMSIG_PARENT_ATTACKBY, W, user, params) & COMPONENT_NO_AFTERATTACK)
		return TRUE
	return FALSE

/obj/attackby(obj/item/I, mob/living/user, params)
	return ..() || ((obj_flags & CAN_BE_HIT) && I.attack_obj(src, user))

/mob/living/attackby(obj/item/I, mob/living/user, params, attackchain_flags, damage_multiplier)
	if(..())
		return TRUE
	I.attack_delay_done = FALSE //Should be set TRUE in pre_attacked_by()
	. = I.attack(src, user, attackchain_flags, damage_multiplier)
	if(!I.attack_delay_done) //Otherwise, pre_attacked_by() should handle it.
		user.changeNext_move(I.click_delay)

/**
  * Called when someone uses us to attack a mob in melee combat.
  *
  * This proc respects CheckAttackCooldown() default clickdelay handling.
  *
  * @params
  * * mob/living/M - target
  * * mob/living/user - attacker
  * * attackchain_flags - see [code/__DEFINES/_flags/return_values.dm]
  * * damage_multiplier - what to multiply the damage by
  */
/obj/item/proc/attack(mob/living/M, mob/living/user, attackchain_flags = NONE, damage_multiplier = 1)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK, M, user) & COMPONENT_ITEM_NO_ATTACK)
		return
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_ATTACK, M, user)
	if(item_flags & NOBLUDGEON)
		return
	if(force && damtype != STAMINA && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>You don't want to harm other living beings!</span>")
		return

	M.lastattacker = user.real_name
	M.lastattackerckey = user.ckey

	user.do_attack_animation(M)
	var/madden = M.attacked_by(src, user, attackchain_flags, damage_multiplier)

	if(!force || !madden)
		playsound(loc, 'sound/weapons/tap.ogg', get_clamped_volume(), 1, -1)
	else if(hitsound)
		playsound(loc, hitsound, get_clamped_volume(), 1, -1)
	
	log_combat(user, M, "attacked", src.name, "(INTENT: [uppertext(user.a_intent)]) (DAMTYPE: [uppertext(damtype)])")
	add_fingerprint(user)

	var/weight = getweight(user, STAM_COST_ATTACK_MOB_MULT, attackchain_flags = attackchain_flags) //makes attacking things cause stamina loss
	if(weight)
		user.adjustStaminaLossBuffered(weight)

//the equivalent of the standard version of attack() but for object targets.
/obj/item/proc/attack_obj(obj/O, mob/living/user)
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_OBJ, O, user) & COMPONENT_NO_ATTACK_OBJ)
		return
	if(item_flags & NOBLUDGEON)
		return
	user.do_attack_animation(O)
	if(!O.attacked_by(src, user))
		user.changeNext_move(click_delay)
	var/weight = getweight(user, STAM_COST_ATTACK_OBJ_MULT)
	if(weight)
		user.adjustStaminaLossBuffered(weight)//makes attacking things cause stamina loss

/atom/movable/proc/attacked_by()
	return

/obj/attacked_by(obj/item/I, mob/living/user, attackchain_flags = NONE, damage_multiplier = 1)
	var/totitemdamage = I.force * damage_multiplier
	var/bad_trait

	var/stamloss = user.getStaminaLoss()
	var/next_move_mult = 1
	if(stamloss > STAMINA_NEAR_SOFTCRIT) //The more tired you are, the less damage you do.
		var/penalty = (stamloss - STAMINA_NEAR_SOFTCRIT)/(STAMINA_NEAR_CRIT - STAMINA_NEAR_SOFTCRIT)*STAM_CRIT_ITEM_ATTACK_PENALTY
		totitemdamage *= 1 - penalty
		next_move_mult += penalty*STAM_CRIT_ITEM_ATTACK_DELAY

	//Dexterity alters how quickly we recover from an attack
	var/click_stat_mod = 1
	if(user.mind)
		var/datum/stats/dex/dex = GET_STAT(user, dex)
		if(dex)
			click_stat_mod *= dex.get_click_mod()
	
	//Same applies for the combat intent
	var/c_intent = CI_DEFAULT
	if(iscarbon(user))
		var/mob/living/carbon/carbon_mob = user
		c_intent = carbon_mob.combat_intent
	
	switch(c_intent)
		if(CI_FURIOUS)
			if(attackchain_flags & ATTACKCHAIN_RIGHTCLICK)
				click_stat_mod *= 0.75 //Keep it simple, endurance already changes the stamina penalty, dexterity already buffed us before
		if(CI_STRONG)
			if(attackchain_flags & ATTACKCHAIN_RIGHTCLICK)
				click_stat_mod *= 2 //Keep it simple, strength already buffs damage a fuckton
		if(CI_DEFEND)
			damage_multiplier *= 0.5 //Straight up halve the damage - stats and skills will just dictate parrying and blocking
		if(CI_GUARD)
			damage_multiplier *= 0.66 //2/3rds of the damage - stats and skills will just dictate parrying and blocking
	user.changeNext_move(I.click_delay*next_move_mult*click_stat_mod)

	if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
		bad_trait = SKILL_COMBAT_MODE //blacklist combat skills.

	if(I.used_skills && user.mind)
		if(totitemdamage)
			totitemdamage = user.mind.item_action_skills_mod(I, totitemdamage, I.skill_difficulty, SKILL_ATTACK_OBJ, bad_trait)
		for(var/skill in I.used_skills)
			if(!(I.used_skills[skill] & SKILL_TRAIN_ATTACK_OBJ))
				continue
			user.mind.auto_gain_experience(skill, I.skill_gain)
	
	//If the user has a mind and the item uses a stat, we always try to get a damage multiplier based on the stat
	if(user.mind && I.used_melee_stat)
		totitemdamage *= user.mind.get_skillstat_damagemod(I.used_melee_stat)
	
	//If the user has bad st, sometimes... the attack gets really shit
	var/pitiful = FALSE
	if(user.mind && GET_STAT_LEVEL(user, str) < 10)
		switch(user.mind.diceroll(STAT_DATUM(str)))
			if(DICE_CRIT_FAILURE)
				totitemdamage *= 0.75
				pitiful = TRUE
	if(totitemdamage)
		visible_message("<span class='danger'><b>[user]</b> has[pitiful ? " pitifully" : ""] hit [src] with [I]!</span>", null, null, COMBAT_MESSAGE_RANGE)
		//only witnesses close by and the victim see a hit message.
		log_combat(user, src, "attacked", I)
	take_damage(totitemdamage, I.damtype, "melee", 1)
	return TRUE

/mob/living/attacked_by(obj/item/I, mob/living/user, attackchain_flags = NONE, damage_multiplier = 1)
	var/list/block_return = list()
	var/totitemdamage = pre_attacked_by(I, user, attackchain_flags = attackchain_flags) * damage_multiplier
	if((user != src) && mob_run_block(I, totitemdamage, "the [I.name]", ((attackchain_flags & ATTACKCHAIN_PARRY_COUNTERATTACK)? ATTACK_TYPE_PARRY_COUNTERATTACK : NONE) | ATTACK_TYPE_MELEE, I.armour_penetration, user, null, block_return) & BLOCK_SUCCESS)
		return FALSE
	totitemdamage = block_calculate_resultant_damage(totitemdamage, block_return)
	I.do_stagger_action(src, user, totitemdamage)
	if(I.force)
		apply_damage(totitemdamage, I.damtype)
		send_item_attack_message(I, user, null, totitemdamage)
		if(I.damtype == BRUTE)
			if(prob(33))
				I.add_mob_blood(src)
				if(totitemdamage >= 10 && get_dist(user, src) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(src)
				var/dist = rand(0,max(min(round(totitemdamage/5, 1),3), 1))
				var/turf/location = get_turf(src)
				if(istype(location))
					add_splatter_floor(location)
				var/turf/targ = get_ranged_target_turf(user, get_dir(user, src), dist)
				if(istype(targ) && dist > 0 && ((mob_biotypes & MOB_ORGANIC) || (mob_biotypes & MOB_HUMANOID)))
					var/obj/effect/decal/cleanable/blood/hitsplatter/B = new(loc, get_blood_dna_list())
					B.add_blood_DNA(get_blood_dna_list())
					B.GoTo(targ, dist)
		
		//Combat intent can cause some effects
		var/c_intent = CI_DEFAULT
		if(iscarbon(user))
			var/mob/living/carbon/carbon_mob = user
			c_intent = carbon_mob.combat_intent
		
		switch(c_intent)
			if(CI_FEINT)
				if(attackchain_flags & ATTACKCHAIN_RIGHTCLICK)
					//Successful feint attack - victim is unable to attack for a while
					var/multi = 2
					if(user.mind)
						var/datum/skills/melee/melee = GET_SKILL(user, melee)
						if(melee)
							multi = melee.level/(MAX_SKILL/4)
					changeNext_move(CLICK_CD_MELEE * multi)

		return TRUE //successful attack

/mob/living/simple_animal/attacked_by(obj/item/I, mob/living/user, attackchain_flags = NONE, damage_multiplier = 1)
	if(I.force < force_threshold || I.damtype == STAMINA)
		playsound(loc, 'sound/weapons/tap.ogg', I.get_clamped_volume(), 1, -1)
		user.changeNext_move(I.click_delay) //pre_attacked_by not called
	else
		return ..()

/mob/living/proc/pre_attacked_by(obj/item/I, mob/living/user, attackchain_flags)
	. = I.force
	if(!.)
		return

	var/stamloss = user.getStaminaLoss()
	var/stam_mobility_mult = 1
	var/next_move_mult = 1
	if(stamloss > STAMINA_NEAR_SOFTCRIT) //The more tired you are, the less damage you do.
		var/penalty = (stamloss - STAMINA_NEAR_SOFTCRIT)/(STAMINA_NEAR_CRIT - STAMINA_NEAR_SOFTCRIT)*STAM_CRIT_ITEM_ATTACK_PENALTY
		stam_mobility_mult -= penalty
		next_move_mult += penalty*STAM_CRIT_ITEM_ATTACK_DELAY
	if(stam_mobility_mult > LYING_DAMAGE_PENALTY && !CHECK_MOBILITY(user, MOBILITY_STAND)) //damage penalty for fighting prone, doesn't stack with the above.
		stam_mobility_mult = LYING_DAMAGE_PENALTY
	. *= stam_mobility_mult

	//Dexterity alters how quickly we recover from an attack
	var/click_stat_mod = 1
	if(user.mind)
		var/datum/stats/dex/dex = GET_STAT(user, dex)
		if(dex)
			click_stat_mod *= dex.get_click_mod()
	
	//Same applies for the combat intent
	var/c_intent = CI_DEFAULT
	if(iscarbon(user))
		var/mob/living/carbon/carbon_mob = user
		c_intent = carbon_mob.combat_intent
	
	switch(c_intent)
		if(CI_FURIOUS)
			if(attackchain_flags & ATTACKCHAIN_RIGHTCLICK)
				click_stat_mod *= 0.75 //Keep it simple, endurance already changes the stamina penalty, dexterity already buffed us before
		if(CI_STRONG)
			if(attackchain_flags & ATTACKCHAIN_RIGHTCLICK)
				click_stat_mod *= 2 //Keep it simple, strength already buffs damage a fuckton
		if(CI_DEFEND)
			. *= 0.5 //Straight up halve the damage - stats and skills will just dictate parrying and blocking
		if(CI_GUARD)
			. *= 0.66 //2/3rds of the damage - stats and skills will just dictate parrying and blocking
	user.changeNext_move(I.click_delay*next_move_mult*click_stat_mod)
	I.attack_delay_done = TRUE

	var/bad_trait
	if(!(I.item_flags & NO_COMBAT_MODE_FORCE_MODIFIER))
		if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
			bad_trait = SKILL_COMBAT_MODE //blacklist combat skills.
			if(SEND_SIGNAL(src, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_ACTIVE))
				. *= 0.9
		else if(SEND_SIGNAL(src, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
			. *= 1.1

	//If the user has a mind and the item uses a stat, we always try to get a damage multiplier based on the stat
	if(user.mind && I.used_melee_stat)
		. *= user.mind.get_skillstat_damagemod(I.used_melee_stat)

	//If the user has bad st, sometimes... the attack gets really shit
	if(user.mind && GET_STAT_LEVEL(user, str) < 10)
		switch(user.mind.diceroll(STAT_DATUM(str)))
			if(DICE_FAILURE)
				. *= 0.7
			if(DICE_CRIT_FAILURE)
				. *= 0.25
	
	if(!user.mind || !I.used_skills)
		return
	if(.)
		. = user.mind.item_action_skills_mod(I, ., I.skill_difficulty, SKILL_ATTACK_MOB, bad_trait)
	for(var/skill in I.used_skills)
		if(!(I.used_skills[skill] & SKILL_TRAIN_ATTACK_MOB))
			continue
		user.mind.auto_gain_experience(skill, I.skill_gain)

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/**
  * Called after attacking something if the melee attack chain isn't interrupted before.
  * Also called when clicking on something with an item without being in melee range
  *
  * WARNING: This does not automatically check clickdelay if not in a melee attack! Be sure to account for this!
  *
  * @params
  * * target - The thing we clicked
  * * user - mob of person clicking
  * * proximity_flag - are we in melee range/doing it in a melee attack
  * * click_parameters - mouse control parameters, check BYOND ref.
  */
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK, target, user, proximity_flag, click_parameters)

/obj/item/proc/get_clamped_volume()
	if(w_class)
		if(force)
			return clamp((force + w_class) * 4, 30, 100)// Add the item's force to its weight class and multiply by 4, then clamp the value between 30 and 100
		else
			return clamp(w_class * 6, 10, 100) // Multiply the item's weight class by 6, then clamp the value between 10 and 100

/mob/living/proc/send_item_attack_message(obj/item/I, mob/living/user, hit_area, current_force, obj/item/bodypart/hit_BP)
	var/message_verb = "attacked"
	if(I.attack_verb && I.attack_verb.len)
		message_verb = "[pick(I.attack_verb)]"
	if(current_force < I.force * FEEBLE_ATTACK_MSG_THRESHOLD)
		message_verb = "[pick("feebly", "limply", "saplessly")] [message_verb]"
	if(!I.force)
		return
	var/message_hit_area = ""
	if(hit_area)
		message_hit_area = " in the [hit_area]"
	var/attack_message = "<b>[src]</b> has been [message_verb][message_hit_area] with [I]."
	if(user in viewers(src, null))
		attack_message = "<b>[user]</b> has [message_verb] <b>[src]</b>[message_hit_area] with [I]!"
	visible_message("<span class='danger'>[attack_message]</span>",\
		"<span class='userdanger'>[attack_message]</span>", null, COMBAT_MESSAGE_RANGE)
	if(hit_area == BODY_ZONE_HEAD)
		if(prob(2))
			playsound(src, 'sound/weapons/dink.ogg', 30, 1)
	return 1

/// How much stamina this takes to swing this is not for realism purposes hecc off.
/obj/item/proc/getweight(mob/living/user, multiplier = 1, trait = SKILL_STAMINA_COST, attackchain_flags)
	. = (total_mass || w_class * STAM_COST_W_CLASS_MULT) * multiplier
	if(!user)
		return
	var/bad_trait
	if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
		. *= STAM_COST_NO_COMBAT_MULT
		bad_trait = SKILL_COMBAT_MODE
	if(used_skills && user.mind)
		. = user.mind.item_action_skills_mod(src, ., skill_difficulty, trait, bad_trait, FALSE)
	var/total_health = user.getStaminaLoss()
	var/c_intent = CI_DEFAULT
	if(iscarbon(user))
		var/mob/living/carbon/carbon_mob = user
		c_intent = carbon_mob.combat_intent
	
	switch(c_intent)
		if(CI_FURIOUS)
			if(attackchain_flags & ATTACKCHAIN_RIGHTCLICK)
				//Endurance lowers the staminaloss penalty
				var/multi = 2
				if(user.mind)
					var/datum/stats/end/end = GET_STAT(user, end)
					if(end)
						multi = (2.5 - (end.level/MAX_STAT))
				. *= multi
		if(CI_STRONG)
			if(attackchain_flags & ATTACKCHAIN_RIGHTCLICK)
				//Endurance lowers the staminaloss penalty
				var/multi = 2.5
				if(user.mind)
					var/datum/stats/end/end = GET_STAT(user, end)
					if(end)
						multi = (3 - ((end.level/MAX_STAT) * 1.5))
				. *= multi
	. = clamp(., 0, STAMINA_NEAR_CRIT - total_health)

/// How long this staggers for. 0 and negatives supported.
/obj/item/proc/melee_stagger_duration(force_override)
	if(!isnull(stagger_force))
		return stagger_force
	/// totally not an untested, arbitrary equation.
	return clamp((1.5 + (w_class/7.5)) * ((force_override || force) / 2), 0, 10 SECONDS)

/obj/item/proc/do_stagger_action(mob/living/target, mob/living/user, force_override)
	if(!CHECK_BITFIELD(target.status_flags, CANSTAGGER))
		return FALSE
	if(target.combat_flags & COMBAT_FLAG_SPRINT_ACTIVE)
		target.do_staggered_animation()
	var/duration = melee_stagger_duration(force_override)
	if(!duration)		//0
		return FALSE
	else if(duration > 0)
		target.Stagger(duration)
	else				//negative
		target.AdjustStaggered(duration)
	return TRUE

/mob/proc/do_staggered_animation()
	set waitfor = FALSE
	animate(src, pixel_x = -2, pixel_y = -2, time = 1, flags = ANIMATION_RELATIVE | ANIMATION_PARALLEL)
	animate(pixel_x = 4, pixel_y = 4, time = 1, flags = ANIMATION_RELATIVE)
	animate(pixel_x = -2, pixel_y = -2, time = 0.5, flags = ANIMATION_RELATIVE)

//Do stuff depending on stats and skills etc
/mob/living/carbon/proc/do_stat_effects(mob/living/carbon/user, obj/item/weapon, force, obj/item/bodypart/affecting)
	var/did_something = FALSE
	var/victim_str = 10
	if(GET_STAT_LEVEL(src, str))
		victim_str = GET_STAT_LEVEL(src, str)
	var/user_str = 10
	if(GET_STAT_LEVEL(user, str))
		user_str = GET_STAT_LEVEL(user, str)
	var/force_mod = clamp(FLOOR(force/15, 1), 1, 3)
	var/knockback_tiles = clamp(round(max(0, user_str - victim_str)/2 * force_mod * pick(1,1.5)), 0, 5)
	//Slam time
	if((!weapon || (weapon.damtype == BRUTE && !weapon.get_sharpness())) && knockback_tiles)
		if(knockback_tiles > 1)
			Stumble(knockback_tiles * 10)
			if(affecting?.body_zone in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE))
				Rapehead(knockback_tiles * 15)
			sound_hint(src, user)
		var/turf/target_turf = get_ranged_target_turf(src, get_dir(user, src), knockback_tiles)
		throw_at(target_turf, knockback_tiles, 1, user, spin = FALSE)
		did_something = TRUE
	//Knock teeth out
	if((!weapon || (weapon.damtype == BRUTE && !weapon.get_sharpness())) && !CHECK_BITFIELD(status_flags, GODMODE))
		var/obj/item/bodypart/teeth_part = affecting || get_bodypart(check_zone(user.zone_selected))
		if(teeth_part && teeth_part.max_teeth && prob(force * 3))
			if(teeth_part.knock_out_teeth(rand(1, 2) * max(round(force/10), 1), get_dir(user, src)))
				var/tooth_sound = pick('modular_skyrat/sound/gore/trauma1.ogg',
								'modular_skyrat/sound/gore/trauma2.ogg',
								'modular_skyrat/sound/gore/trauma3.ogg')
				playsound(src, tooth_sound, 60)
				wound_message += " <b>[src]</b>'s teeth sail off in an arc!"
				Stun(2 SECONDS)
				Stumble(4 SECONDS)
				Rapehead(6 SECONDS)
				did_something = TRUE
	//Critical hits and critical failures
	if(user.mind)
		switch(rand(1,100))
			if(99 to 100)
				var/crit = rand(1,3)
				switch(crit)
					if(1)
						wound_message += " <b>CRITICAL HIT!</b> [src] is stunned!"
						Stun(3 SECONDS)
					if(2)
						wound_message += " <b>CRITICAL HIT!</b> [src] is knocked down!"
						DefaultCombatKnockdown(3 SECONDS)
					if(3)
						wound_message += " <b>CRITICAL HIT!</b> [src] is paralyzed!"
						Paralyze(3 SECONDS)
				did_something = TRUE
			if(0 to 1)
				var/crit = rand(1,2)
				switch(crit)
					if(1)
						if(user != src)
							wound_message += " <b>CRITICAL FAILURE!</b> [user] knock[user.p_s()] [user.p_themselves()] down!"
							user.drop_all_held_items()
							user.DefaultCombatKnockdown(3 SECONDS)
					if(2)
						if(user != src)
							wound_message += " <b>CRITICAL FAILURE!</b> [user] hit[user.p_s()] [user.p_themselves()]!"
							if(weapon)
								weapon.melee_attack_chain(user, user)
							else
								user.UnarmedAttack(user)
				did_something = TRUE
	return did_something

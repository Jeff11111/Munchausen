/mob/living/proc/run_armor_check(def_zone = null, attack_flag = "melee", absorb_text = null, soften_text = null, armour_penetration, penetrated_text, silent=FALSE)
	var/armor = getarmor(def_zone, attack_flag)
	
	if(silent)
		return max(0, armor - armour_penetration)

	if(armor <= 0)
		return armor
	if(silent)
		return max(0, armor - armour_penetration)

	//the if "armor" check is because this is used for everything on /living, including humans
	if(armour_penetration)
		armor = max(0, armor - armour_penetration)
		if(penetrated_text)
			to_chat(src, "<span class='userdanger'>[penetrated_text]</span>")
		else
			to_chat(src, "<span class='userdanger'>Your armor was penetrated!</span>")
	else if(armor >= 100)
		if(absorb_text)
			to_chat(src, "<span class='notice'>[absorb_text]</span>")
		else
			to_chat(src, "<span class='notice'>Your armor absorbs the blow!</span>")
	else
		if(soften_text)
			to_chat(src, "<span class='warning'>[soften_text]</span>")
		else
			to_chat(src, "<span class='warning'>Your armor softens the blow!</span>")
	return armor

/mob/living/proc/getarmor(def_zone, type)
	return 0

//this returns the mob's protection against eye damage (number between -1 and 2) from bright lights
/mob/living/proc/get_eye_protection()
	return 0

//this returns the mob's protection against ear damage (0:no protection; 1: some ear protection; 2: has no ears)
/mob/living/proc/get_ear_protection()
	return 0

/mob/living/proc/is_mouth_covered(head_only = 0, mask_only = 0)
	return FALSE

/mob/living/proc/is_eyes_covered(check_glasses = 1, check_head = 1, check_mask = 1)
	return FALSE

/mob/living/proc/on_hit(obj/item/projectile/P)
	return BULLET_ACT_HIT

/mob/living/proc/handle_projectile_attack_redirection(obj/item/projectile/P, redirection_mode, silent = FALSE)
	P.ignore_source_check = TRUE
	switch(redirection_mode)
		if(REDIRECT_METHOD_DEFLECT)
			P.setAngle(SIMPLIFY_DEGREES(P.Angle + rand(120, 240)))
			if(!silent)
				visible_message("<span class='danger'>[P] gets deflected by [src]!</span>", \
					"<span class='userdanger'>You deflect [P]!</span>")
		if(REDIRECT_METHOD_REFLECT)
			P.setAngle(SIMPLIFY_DEGREES(P.Angle + 180))
			if(!silent)
				visible_message("<span class='danger'>[P] gets reflected by [src]!</span>", \
					"<span class='userdanger'>You reflect [P]!</span>")
		if(REDIRECT_METHOD_PASSTHROUGH)
			if(!silent)
				visible_message("<span class='danger'>[P] passes through [src]!</span>", \
					"<span class='userdanger'>[P] passes through you!</span>")
			return
		if(REDIRECT_METHOD_RETURN_TO_SENDER)
			if(!silent)
				visible_message("<span class='danger'>[src] deflects [P] back at their attacker!</span>", \
					"<span class='userdanger'>You deflect [P] back at your attacker!</span>")
			if(P.firer)
				P.setAngle(Get_Angle(src, P.firer))
			else
				P.setAngle(SIMPLIFY_DEGREES(P.Angle + 180))
		else
			CRASH("Invalid rediretion mode [redirection_mode]")

/mob/living/bullet_act(obj/item/projectile/P, def_zone)
	var/totaldamage = P.damage
	var/final_percent = 0
	if(P.original != src || P.firer != src) //try to block or reflect the bullet, can't do so when shooting oneself
		var/list/returnlist = list()
		var/returned = mob_run_block(P, P.damage, "the [P.name]", ATTACK_TYPE_PROJECTILE, P.armour_penetration, P.firer, def_zone, returnlist)
		final_percent = returnlist[BLOCK_RETURN_PROJECTILE_BLOCK_PERCENTAGE]
		if(returned & BLOCK_SHOULD_REDIRECT)
			handle_projectile_attack_redirection(P, returnlist[BLOCK_RETURN_REDIRECT_METHOD])
		if(returned & BLOCK_REDIRECTED)
			return BULLET_ACT_FORCE_PIERCE
		if(returned & BLOCK_SUCCESS)
			P.on_hit(src, final_percent, def_zone)
			return BULLET_ACT_BLOCK
		totaldamage = block_calculate_resultant_damage(totaldamage, returnlist)
	// Armor damage reduction
	var/armor_block = run_armor_check(def_zone, P.flag, null, null, P.armour_penetration, null)

	var/Pdamagetype = P.damage_type
	var/Pwound_bonus = P.wound_bonus
	var/Pbarewound_bonus = P.bare_wound_bonus
	var/Psharpness = P.get_sharpness()

	if(ishuman(src))
		var/mob/living/carbon/human/H = src

		// Blocking values that mean the damage was under armor, so wounding is changed to blunt
		var/armor_border_blocking = 1 - (H.checkarmormax(H.get_bodypart(def_zone), "under_armor_mult") * 1/max(0.01, H.checkarmormax(H.get_bodypart(def_zone), "armor_range_mult")))
		if(armor_block >= armor_border_blocking)
			Pwound_bonus = max(0, Pwound_bonus - armor_block/100 * totaldamage)
			Pbarewound_bonus = 0
			Psharpness = SHARP_NONE
	
	armor_block = min(95, armor_block)
	if(totaldamage && !P.nodamage)
		var/mob/living/carbon/C = src
		var/datum/injury/created_injury
		var/obj/item/bodypart/BP
		if(!istype(C))
			apply_damage(totaldamage, Pdamagetype, def_zone, armor_block, wound_bonus = Pwound_bonus, bare_wound_bonus = Pbarewound_bonus, sharpness = Psharpness)
		else
			BP = get_bodypart(def_zone)
			if(BP)
				created_injury = BP.receive_damage(brute = (Pdamagetype == BRUTE ? totaldamage : 0), burn = (Pdamagetype == BURN ? totaldamage : 0), blocked = armor_block, wound_bonus = Pwound_bonus, bare_wound_bonus = Pbarewound_bonus, sharpness = Psharpness)
			else
				apply_damage(totaldamage, Pdamagetype, def_zone, armor_block, wound_bonus = Pwound_bonus, bare_wound_bonus= Pbarewound_bonus, sharpness = Psharpness)
		if(created_injury)
			SEND_SIGNAL(P, COMSIG_PROJECTILE_AFTER_INJURING, src, BP, created_injury)
		if(P.dismemberment)
			check_projectile_dismemberment(P, def_zone)
		if((P.damage_type == BRUTE) && iscarbon(src))
			// Always stumble when shot
			Stumble(P.damage)
			if(BP?.body_zone in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE))
				Rapehead(P.damage + 1 SECONDS)
			// Do a diceroll to decide whether we get paralyzed/knocked down
			if(mind)
				switch(mind.diceroll(STAT_DATUM(end), mod = -min(15, P.damage*0.2)))
					if(DICE_CRIT_SUCCESS)
						shake_camera(src, ((P.damage - 10) * 0.01 + 1) * 2, ((P.damage - 10) * 0.01)* 2)
					if(DICE_SUCCESS)
						shake_camera(src, ((P.damage - 10) * 0.01 + 1) * 3, ((P.damage - 10) * 0.01)* 3)
					if(DICE_FAILURE)
						shake_camera(src, ((P.damage - 10) * 0.01 + 1) * 4, ((P.damage - 10) * 0.01) * 4)
						AdjustImmobilized(P.damage/4)
					if(DICE_CRIT_FAILURE)
						shake_camera(src, ((P.damage - 10) * 0.01 + 1) * 5, ((P.damage - 10) * 0.01) * 5)
						drop_all_held_items()
						AdjustParalyzed(P.damage)
						AdjustKnockdown(P.damage*2)
			else
				shake_camera(src, ((P.damage - 10) * 0.01 + 1) * 5, ((P.damage - 10) * 0.01) * 5)
				drop_all_held_items()
				AdjustParalyzed(P.damage)
				AdjustKnockdown(P.damage*2)
		if((P.damage_type == BRUTE) && ((mob_biotypes & MOB_ORGANIC) || (mob_biotypes & MOB_HUMANOID)) && (totaldamage >= 10) && !P.nodamage)
			if(!istype(C) || (istype(C) && !C.is_asystole() && C.needs_heart() && (ishuman(C) ? !(NOBLOOD in C.dna?.species?.species_traits) : TRUE)))
				var/obj/effect/decal/cleanable/blood/hitsplatter/B = new(loc, get_blood_dna_list())
				B.add_blood_DNA(get_blood_dna_list())
				var/dist = rand(1,min(totaldamage/10, 5))
				var/turf/targ = get_ranged_target_turf(src, get_dir(P.starting, src), dist)
				B.GoTo(targ, dist)
	var/missing = 100 - final_percent
	var/armor_ratio = armor_block * 0.01
	if(missing > 0)
		final_percent += missing * armor_ratio
	return P.on_hit(src, final_percent, def_zone) ? BULLET_ACT_HIT : BULLET_ACT_BLOCK

/mob/living/proc/check_projectile_dismemberment(obj/item/projectile/P, def_zone)
	return 0

/obj/item/proc/get_volume_by_throwforce_and_or_w_class()
	if(throwforce && w_class)
		return clamp((throwforce + w_class) * 5, 30, 100)// Add the item's throwforce to its weight class and multiply by 5, then clamp the value between 30 and 100
	else if(w_class)
		return clamp(w_class * 8, 20, 100) // Multiply the item's weight class by 8, then clamp the value between 20 and 100
	else
		return 0

/mob/living/proc/catch_item(obj/item/I, skip_throw_mode_check = FALSE)
	return FALSE

/mob/living/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	// Throwingdatum can be null if someone had an accident() while slipping with an item in hand.
	var/obj/item/I
	var/throwpower = 30
	if(isitem(AM))
		I = AM
		throwpower = I.throwforce
	var/impacting_zone = ran_zone(BODY_ZONE_CHEST, 65)//Hits a random part of the body, geared towards the chest
	var/list/block_return = list()
	var/total_damage = I.throwforce
	if(ishuman(throwingdatum.thrower))
		var/mob/living/L = throwingdatum.thrower
		total_damage *= GET_STAT_LEVEL(L, str)/(MAX_STAT/2)
	if(mob_run_block(AM, throwpower, "\the [AM.name]", ATTACK_TYPE_THROWN, 0, throwingdatum?.thrower, impacting_zone, block_return) & BLOCK_SUCCESS)
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE
		total_damage = block_calculate_resultant_damage(total_damage, block_return)
	if(I)
		var/nosell_hit = SEND_SIGNAL(I, COMSIG_MOVABLE_IMPACT_ZONE, src, impacting_zone, throwingdatum, FALSE, blocked)
		if(nosell_hit)
			skipcatch = TRUE
			hitpush = FALSE
		
		if(!skipcatch && isturf(I.loc) && catch_item(I))
			return TRUE
		
		var/dtype = BRUTE
		var/zone = ran_zone(BODY_ZONE_CHEST, 65)//Hits a random part of the body, geared towards the chest
		//If it was thrown by a human mob, let's do something a bit more involved
		if(throwingdatum?.thrower?.mind && ishuman(throwingdatum.thrower) && iscarbon(src))
			var/mob/living/carbon/human/assailant = throwingdatum.thrower
			var/mob/living/carbon/victim = src
			var/ran_zone_prob = 50
			var/extra_zone_prob = 50
			var/miss_entirely = 10
			var/obj/item/bodypart/supposed_to_affect = victim.get_bodypart(check_zone(assailant.zone_selected))
			if(supposed_to_affect)
				ran_zone_prob = supposed_to_affect.zone_prob
				extra_zone_prob = supposed_to_affect.extra_zone_prob
				miss_entirely = supposed_to_affect.miss_entirely_prob
			miss_entirely *= (victim.lying ? 0.2 : 1)
			//good modifier if aimed
			var/modifier = 0
			if(assailant.combat_intent == CI_AIMED)
				modifier += 5
			
			if(assailant.mind.diceroll(GET_STAT_LEVEL(assailant, dex)*0.5, GET_SKILL_LEVEL(assailant, throwing)*1.5, dicetype = "6d6", mod = -FLOOR(miss_entirely/5 + throwingdatum.dist_travelled/5, 1) + modifier, crit = 18) <= DICE_CRIT_FAILURE)
				blocked = TRUE
				var/swing_sound = pick('modular_skyrat/sound/attack/swing_01.ogg',
									'modular_skyrat/sound/attack/swing_02.ogg',
									'modular_skyrat/sound/attack/swing_03.ogg',
									)
				playsound(get_turf(victim), swing_sound, 50)
				visible_message("<span class='warning'><b>FAILURE!</b> \The [I.name] misses [victim] entirely!</span>", \
								"<span class='userdanger'><b>FAILURE!</b> \The [I.name] misses you entirely!</span>")
			var/datum/stats/dex/dex = GET_STAT(assailant, dex)
			if(dex)
				ran_zone_prob = dex.get_ran_zone_prob(ran_zone_prob, extra_zone_prob)
			zone = ran_zone(check_zone(assailant.zone_selected), ran_zone_prob)
		if(iscarbon(src) && mind?.handle_dodge(src, I, total_damage, throwingdatum.thrower))
			//le cops
			var/mob/living/carbon/victim = src
			//Make the victim step to an adjacent tile because ooooooh dodge
			var/list/turf/dodge_turfs = list()
			for(var/turf/open/O in range(1,src))
				if(CanReach(O))
					dodge_turfs += O
			//No available turfs == we can't actually dodge
			if(length(dodge_turfs))
				var/turf/yoink = pick(dodge_turfs)
				//We moved to the tile, therefore we dodged successfully
				if(Move(yoink, get_dir(src, yoink)))
					blocked = TRUE
					playsound(get_turf(src), victim.dna?.species?.miss_sound, 70)
					visible_message("<span class='danger'>[victim] dodges [I]!</span>")
		
		if(nosell_hit)
			skipcatch = TRUE
			hitpush = FALSE
		dtype = I.damtype

		if(!blocked)
			if(I.thrownby)
				log_combat(I.thrownby, src, "threw and hit", I)
			if(!nosell_hit)
				visible_message("<span class='danger'><b>[src]</b> is hit by [I]!</span>", \
								"<span class='userdanger'>You're hit by [I]!</span>")
				if(!total_damage)
					return

				var/armor = run_armor_check(zone, "melee", "Your armor has protected your [parse_zone(zone)].", "Your armor has softened hit to your [parse_zone(zone)].",I.armour_penetration)
				apply_damage(total_damage, dtype, zone, armor, sharpness = I.get_sharpness(), wound_bonus = I.wound_bonus, bare_wound_bonus = I.bare_wound_bonus)
			
		else
			hitpush = FALSE
			skipcatch = TRUE
			return TRUE
	else
		playsound(loc, 'sound/weapons/genhit.ogg', 50, 1, -1)
	. = ..()

/mob/living/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M.occupant, TRAIT_PACIFISM))
			to_chat(M.occupant, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		M.do_attack_animation(src)
		if(M.damtype == "brute")
			step_away(src,M,15)
		switch(M.damtype)
			if(BRUTE)
				Unconscious(20)
				take_overall_damage(rand(M.force/2, M.force))
				playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
			if(BURN)
				take_overall_damage(0, rand(M.force/2, M.force))
				playsound(src, 'sound/items/welder.ogg', 50, 1)
			if(TOX)
				M.mech_toxin_damage(src)
			else
				return
		updatehealth()
		visible_message("<span class='danger'><b>[M.name]</b> has hit <b>[src]</b>!</span>", \
						"<span class='userdanger'><b>[M.name]</b> has hit you!</span>", null, COMBAT_MESSAGE_RANGE, null,
						M.occupant, "<span class='danger'>You hit <b>[src]</b> with your <b>[M.name]</b>!</span>")
		log_combat(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")
	else
		step_away(src,M)
		log_combat(M.occupant, src, "pushed", M)
		visible_message("<span class='warning'><b>[M]</b> pushes <b>[src]</b> out of the way.</span>", \
			"<span class='warning'>[M] pushes you out of the way.</span>", null, COMBAT_MESSAGE_RANGE, null,
			M.occupant, "<span class='warning'>You push <b>[src]</b> out of the way with your <b>[M.name]</b>.</span>")

/mob/living/fire_act()
	adjust_fire_stacks(3)
	IgniteMob()

/mob/living/attack_hand(mob/user)
	..() //Ignoring parent return value here.
	SEND_SIGNAL(src, COMSIG_MOB_ATTACK_HAND, user)
	if((user != src) && user.a_intent != INTENT_HELP && (mob_run_block(user, 0, user.name, ATTACK_TYPE_UNARMED | ATTACK_TYPE_MELEE, null, user, check_zone(user.zone_selected), null) & BLOCK_SUCCESS))
		log_combat(user, src, "attempted to touch")
		visible_message("<span class='warning'>[user] attempted to touch [src]!</span>",
			"<span class='warning'>[user] attempted to touch you!</span>", target = user,
			target_message = "<span class='warning'>You attempted to touch [src]!</span>")
		return TRUE

/mob/living/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			to_chat(user, "<span class='notice'>You don't want to hurt [src]!</span>")
			return TRUE
		var/hulk_verb = pick("smash","pummel")
		if(user != src && (mob_run_block(user, 15, "the [hulk_verb]ing", ATTACK_TYPE_MELEE, null, user, check_zone(user.zone_selected), null) & BLOCK_SUCCESS))
			return TRUE
		..()
	return FALSE

/mob/living/attack_slime(mob/living/simple_animal/slime/M)
	if(!SSticker.HasRoundStarted())
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.buckled)
		if(M in buckled_mobs)
			M.Feedstop()
		return // can't attack while eating!

	if(HAS_TRAIT(M, TRAIT_PACIFISM))
		to_chat(M, "<span class='notice'>You don't want to hurt anyone!</span>")
		return FALSE

	var/damage = rand(5, 35)
	if(M.is_adult)
		damage = rand(20, 40)
	var/list/block_return = list()
	if(mob_run_block(M, damage, "the [M.name]", ATTACK_TYPE_MELEE, null, M, check_zone(M.zone_selected), block_return) & BLOCK_SUCCESS)
		return FALSE
	damage = block_calculate_resultant_damage(damage, block_return)

	if (stat != DEAD)
		log_combat(M, src, "attacked")
		M.do_attack_animation(src)
		visible_message("<span class='danger'>The [M.name] glomps [src]!</span>", \
				"<span class='userdanger'>The [M.name] glomps [src]!</span>", null, COMBAT_MESSAGE_RANGE, null,
				M, "<span class='danger'>You glomp [src]!</span>")
		return TRUE

/mob/living/attack_animal(mob/living/simple_animal/M)
	M.face_atom(src)
	if(M.melee_damage_upper == 0)
		M.visible_message("<span class='notice'>\The [M] [M.friendly_verb_continuous] [src]!</span>",
			"<span class='notice'>You [M.friendly_verb_simple] [src]!</span>", target = src,
			target_message = "<span class='notice'>\The [M] [M.friendly_verb_continuous] you!</span>")
		return 0
	else
		if(HAS_TRAIT(M, TRAIT_PACIFISM))
			to_chat(M, "<span class='notice'>You don't want to hurt anyone!</span>")
			return FALSE
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/list/return_list = list()
		if(mob_run_block(M, damage, "the [M.name]", ATTACK_TYPE_MELEE, M.armour_penetration, M, check_zone(M.zone_selected), return_list) & BLOCK_SUCCESS)
			return 0
		damage = block_calculate_resultant_damage(damage, return_list)
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		M.do_attack_animation(src)
		visible_message("<span class='danger'>\The [M] [M.attack_verb_continuous] [src]!</span>", \
						"<span class='userdanger'>\The [M] [M.attack_verb_continuous] you!</span>", null, COMBAT_MESSAGE_RANGE, null,
						M, "<span class='danger'>You [M.attack_verb_simple] [src]!</span>")
		log_combat(M, src, "attacked")
		return damage

/mob/living/attack_paw(mob/living/carbon/monkey/M)
	if (M.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M, TRAIT_PACIFISM))
			to_chat(M, "<span class='notice'>You don't want to hurt anyone!</span>")
			return FALSE
		if(M.is_muzzled() || (M.wear_mask && M.wear_mask.flags_cover & MASKCOVERSMOUTH))
			to_chat(M, "<span class='warning'>You can't bite with your mouth covered!</span>")
			return FALSE
		if(mob_run_block(M, 0, "the [M.name]", ATTACK_TYPE_MELEE | ATTACK_TYPE_UNARMED, 0, M, check_zone(M.zone_selected), null) & BLOCK_SUCCESS)
			return FALSE
		M.do_attack_animation(src, ATTACK_EFFECT_BITE)
		if (prob(75))
			log_combat(M, src, "attacked")
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
			visible_message("<span class='danger'>[M.name] bites [src]!</span>", \
					"<span class='userdanger'>[M.name] bites you!</span>", null, COMBAT_MESSAGE_RANGE, null,
					M, "<span class='danger'>You bite [src]!</span>")
			return TRUE
		else
			visible_message("<span class='danger'>[M.name] has attempted to bite [src]!</span>", \
				"<span class='userdanger'>[M.name] has attempted to bite [src]!</span>", null, COMBAT_MESSAGE_RANGE, null,
				M, "<span class='danger'>You have attempted to bite [src]!</span>")
	return FALSE

/mob/living/attack_larva(mob/living/carbon/alien/larva/L)
	switch(L.a_intent)
		if(INTENT_HELP)
			visible_message("<span class='notice'>[L.name] rubs its head against [src].</span>",
				"<span class='notice'>[L.name] rubs its head against you.</span>", target = L, \
				target_message = "<span class='notice'>You rub your head against [src].</span>")
			return FALSE

		else
			if(HAS_TRAIT(L, TRAIT_PACIFISM))
				to_chat(L, "<span class='notice'>You don't want to hurt anyone!</span>")
				return FALSE
			if(L != src && (mob_run_block(L, rand(1, 3), "the [L.name]", ATTACK_TYPE_MELEE | ATTACK_TYPE_UNARMED, 0, L, check_zone(L.zone_selected), null) & BLOCK_SUCCESS))
				return FALSE
			L.do_attack_animation(src)
			if(prob(90))
				log_combat(L, src, "attacked")
				visible_message("<span class='danger'>[L.name] bites [src]!</span>", \
					"<span class='userdanger'>[L.name] bites you!</span>", null, COMBAT_MESSAGE_RANGE, null, L, \
					"<span class='danger'>You bite [src]!</span>")
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				return TRUE
			else
				visible_message("<span class='danger'>[L.name] has attempted to bite [src]!</span>", \
					"<span class='userdanger'>[L.name] has attempted to bite you!</span>", null, COMBAT_MESSAGE_RANGE, null, L, \
					"<span class='danger'>You have attempted to bite [src]!</span>")

/mob/living/attack_alien(mob/living/carbon/alien/humanoid/M)
	if((M != src) && M.a_intent != INTENT_HELP && (mob_run_block(M, 0, "the [M.name]", ATTACK_TYPE_MELEE | ATTACK_TYPE_UNARMED, 0, M, check_zone(M.zone_selected), null) & BLOCK_SUCCESS))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>",
			"<span class='danger'>[M] attempted to touch you!</span>")
		return FALSE
	switch(M.a_intent)
		if (INTENT_HELP)
			if(!isalien(src)) //I know it's ugly, but the alien vs alien attack_alien behaviour is a bit different.
				visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>",
					"<span class='notice'>[M] caresses you with its scythe like arm.</span>", target = M,
					target_message = "<span class='notice'>You caress [src] with your scythe like arm.</span>")
			return FALSE
		if(INTENT_GRAB)
			grabbedby(M)
			return FALSE
		if(INTENT_HARM)
			if(HAS_TRAIT(M, TRAIT_PACIFISM))
				to_chat(M, "<span class='notice'>You don't want to hurt anyone!</span>")
				return FALSE
			if(!isalien(src))
				M.do_attack_animation(src)
			return TRUE
		if(INTENT_DISARM)
			if(!isalien(src))
				M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			return TRUE

/mob/living/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()

//Looking for irradiate()? It's been moved to radiation.dm under the rad_act() for mobs.

/mob/living/acid_act(acidpwr, acid_volume)
	take_bodypart_damage(acidpwr * min(1, acid_volume * 0.1))
	return 1

///As the name suggests, this should be called to apply electric shocks.
/mob/living/proc/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	SEND_SIGNAL(src, COMSIG_LIVING_ELECTROCUTE_ACT, shock_damage, source, siemens_coeff, flags)
	shock_damage *= siemens_coeff
	if((flags & SHOCK_TESLA) && HAS_TRAIT(src, TRAIT_TESLA_SHOCKIMMUNE))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_SHOCKIMMUNE))
		return FALSE
	if(shock_damage < 1)
		return FALSE
	if(!(flags & SHOCK_ILLUSION))
		adjustFireLoss(shock_damage)
	else
		adjustStaminaLoss(shock_damage)
	visible_message(
		"<span class='danger'>[src] was shocked by \the [source]!</span>", \
		"<span class='userdanger'>You feel a powerful shock coursing through your body!</span>", \
		"<span class='hear'>You hear a heavy electrical crack.</span>" \
	)
	return shock_damage

/mob/living/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/O in contents)
		O.emp_act(severity)

/mob/living/singularity_act()
	var/gain = 20
	investigate_log("([key_name(src)]) has been consumed by the singularity.", INVESTIGATE_SINGULO) //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/narsie_act()
	if(status_flags & GODMODE || QDELETED(src))
		return

	if(is_servant_of_ratvar(src) && !stat)
		to_chat(src, "<span class='userdanger'>You resist Nar'Sie's influence... but not all of it. <i>Run!</i></span>")
		adjustBruteLoss(35)
		if(src && reagents)
			reagents.add_reagent(/datum/reagent/toxin/heparin, 5)
		return FALSE
	if(GLOB.cult_narsie && GLOB.cult_narsie.souls_needed[src])
		GLOB.cult_narsie.souls_needed -= src
		GLOB.cult_narsie.souls += 1
		if((GLOB.cult_narsie.souls == GLOB.cult_narsie.soul_goal) && (GLOB.cult_narsie.resolved == FALSE))
			GLOB.cult_narsie.resolved = TRUE
			sound_to_playing_players('sound/machines/alarm.ogg')
			addtimer(CALLBACK(GLOBAL_PROC, .proc/cult_ending_helper, 1), 120)
			addtimer(CALLBACK(GLOBAL_PROC, .proc/ending_helper), 270)
	if(client)
		makeNewConstruct(/mob/living/simple_animal/hostile/construct/harvester, src, cultoverride = TRUE)
	else
		switch(rand(1, 6))
			if(1)
				new /mob/living/simple_animal/hostile/construct/armored/hostile(get_turf(src))
			if(2)
				new /mob/living/simple_animal/hostile/construct/wraith/hostile(get_turf(src))
			if(3 to 6)
				new /mob/living/simple_animal/hostile/construct/builder/hostile(get_turf(src))
	spawn_dust()
	gib()
	return TRUE


/mob/living/ratvar_act()
	if(status_flags & GODMODE)
		return
	if(stat != DEAD && !is_servant_of_ratvar(src))
		to_chat(src, "<span class='userdanger'>A blinding light boils you alive! <i>Run!</i></span>")
		adjust_fire_stacks(20)
		IgniteMob()
		return FALSE


//called when the mob receives a bright flash
/mob/living/proc/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /obj/screen/fullscreen/flash)
	if(get_eye_protection() < intensity && (override_blindness_check || !(HAS_TRAIT(src, TRAIT_BLIND))))
		overlay_fullscreen("flash", type)
		addtimer(CALLBACK(src, .proc/clear_fullscreen, "flash", 25), 25)
		return TRUE
	return FALSE

//called when the mob receives a loud bang
/mob/living/proc/soundbang_act()
	return 0

//to damage the clothes worn by a mob
/mob/living/proc/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	return

/mob/living/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!used_item)
		used_item = get_active_held_item()
	..()
	floating_need_update = TRUE

/mob/living/proc/getBruteLoss_nonProsthetic()
	return getBruteLoss()

/mob/living/proc/getFireLoss_nonProsthetic()
	return getFireLoss()

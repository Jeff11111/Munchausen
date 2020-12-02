/mob/living/carbon/human/getarmor(def_zone, type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isbodypart(def_zone))
			var/obj/item/bodypart/bp = def_zone
			if(bp.body_part)
				return checkarmor(def_zone, type)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(def_zone))
		return checkarmor(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		armorval += checkarmor(BP, type)
		organnum++
	return (armorval/max(organnum, 1))


/mob/living/carbon/human/proc/checkarmor(obj/item/bodypart/def_zone, d_type)
	if(!d_type || !def_zone)
		return 0
	var/protection = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, w_underwear, w_socks, w_shirt, back, gloves, wrists, shoes, belt, s_store, glasses, ears, ears_extra, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor) //skyrat edit
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(istype(bp, /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				protection += C.armor.getRating(d_type)
	protection += physiology.armor.getRating(d_type)
	return protection

/mob/living/carbon/human/on_hit(obj/item/projectile/P)
	if(dna && dna.species)
		dna.species.on_hit(P, src)

/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	if(dna && dna.species)
		var/spec_return = dna.species.bullet_act(P, src)
		if(spec_return)
			return spec_return

	if(mind) //martial art stuff
		if(mind.martial_art && mind.martial_art.can_use(src)) //Some martial arts users can deflect projectiles!
			var/martial_art_result = mind.martial_art.on_projectile_hit(src, P, def_zone)
			if(!(martial_art_result == BULLET_ACT_HIT))
				return martial_art_result
		if(mind.handle_dodge(src, P, P.damage, P.firer))
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
					playsound(get_turf(src), dna?.species?.miss_sound, 70)
					visible_message("<span class='danger'>[src] dodges [P]!</span>")
					return BULLET_ACT_FORCE_PIERCE
	//Dice roll to handle missing
	if(P.firer && ishuman(P.firer))
		var/mob/living/carbon/human/fireboy = P.firer
		if(fireboy.mind)
			var/victim_dex = 10
			if(mind)
				victim_dex = GET_STAT_LEVEL(src, dex)
			//Victims being held at gunpoint are less likely to have the shots miss them
			if(length(gunpointed))
				victim_dex -= GET_SKILL_LEVEL(fireboy, ranged)
			//We already dealt with hitting the wrong zone, so let's deal with missing entirely
			var/miss_entirely = 10
			var/obj/item/bodypart/supposed_to_affect = get_bodypart(P.def_zone)
			if(supposed_to_affect)
				miss_entirely = supposed_to_affect.miss_entirely_prob
			miss_entirely /= (lying ? 10 : 1)
			switch(fireboy.mind.diceroll(GET_STAT_LEVEL(fireboy, dex)*0.5, GET_SKILL_LEVEL(fireboy, ranged)*1.5, dicetype = "6d6", mod = -CEILING(miss_entirely/7 + get_dist(P.starting, src)/5, 1), crit = 20))
				//Missed shot
				if(DICE_CRIT_FAILURE, DICE_FAILURE)
					if(fireboy != src)
						visible_message("<span class='danger'><b>FAILURE!</b>[P] misses <b>[src]</b> entirely!</span>")
						return BULLET_ACT_FORCE_PIERCE
	//Critical hits
	if(mind)
		switch(rand(1,100))
			if(0 to 2)
				visible_message("<span class='danger'><b>CRITICAL HIT!</b>[P] mauls <b>[src]</b>!")
				P.damage *= 2
	return ..()

/mob/living/carbon/human/proc/check_martial_melee_block()
	if(mind)
		if(mind.martial_art && prob(mind.martial_art.block_chance) && mind.martial_art.can_use(src) && in_throw_mode && !incapacitated(FALSE, TRUE))
			return TRUE
	return FALSE

/mob/living/carbon/human/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	//skyrat edit
	if(dna && dna.species)
		var/spec_return = dna.species.spec_hitby(AM, src)
		if(spec_return)
			return spec_return
	var/obj/item/I
	//var/throwpower = 30 //skyrat edit
	if(istype(AM, /obj/item))
		I = AM
		//throwpower = I.throwforce
		if(I.thrownby == src) //No throwing stuff at yourself to trigger hit reactions
			return ..()
	/*
	if(check_shields(AM, throwpower, "\the [AM.name]", THROWN_PROJECTILE_ATTACK))
		hitpush = FALSE
		skipcatch = TRUE
		blocked = TRUE
	*/
	return ..()

/mob/living/carbon/human/grabbedby(mob/living/carbon/user, supress_message = 0)
	if(user == src && pulling && !pulling.anchored && grab_state >= GRAB_AGGRESSIVE && (HAS_TRAIT(src, TRAIT_FAT)) && ismonkey(pulling))
		devour_mob(pulling)
	else
		..()

/mob/living/carbon/human/grippedby(mob/living/user, instant = FALSE)
	if(w_uniform)
		w_uniform.add_fingerprint(user)
	..()

/mob/living/carbon/human/attacked_by(obj/item/I, mob/living/user, attackchain_flags = NONE, damage_multiplier = 1)
	if(!I || !user)
		return 0

	var/obj/item/bodypart/affecting
	if(user == src)
		affecting = get_bodypart(check_zone(user.zone_selected)) //stabbing yourself always hits the right target
	else
		//Hitting where the attacker aimed is dictated by a few things
		var/obj/item/bodypart/supposed_to_affect = get_bodypart(check_zone(user.zone_selected))
		var/ran_zone_prob = 50
		var/extra_zone_prob = 50
		var/miss_entirely = 10
		if(supposed_to_affect)
			ran_zone_prob = supposed_to_affect.zone_prob
			extra_zone_prob = supposed_to_affect.extra_zone_prob
			miss_entirely = supposed_to_affect.miss_entirely_prob
		miss_entirely /= (lying ? 10 : 1)
		var/c_intent = CI_DEFAULT
		if(iscarbon(user))
			var/mob/living/carbon/carbon_mob = user
			//Chance to miss the attack entirely, based on a diceroll
			var/missed = FALSE
			if(user.mind && user.mind.diceroll(GET_STAT_LEVEL(user, dex)*0.75, GET_SKILL_LEVEL(user, melee)*1.25, dicetype = "6d6", mod = -(miss_entirely/5), crit = 20) <= DICE_FAILURE)
				missed = TRUE
			c_intent = carbon_mob.combat_intent
			if(carbon_mob.mind)
				var/datum/stats/dex/dex = GET_STAT(carbon_mob, dex)
				if(dex)
					ran_zone_prob = dex.get_ran_zone_prob(ran_zone_prob, extra_zone_prob)
			if(missed && (user != src))
				visible_message("<span class='danger'><b>[user]</b> misses <b>[src]</b> with [I]!</span>", \
							"<span class='danger'>You avoid <b>[user]</b>'s attack with [I]!</span>", "<span class='hear'>You hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, null, \
							user, "<span class='warning'>You miss <b>[src]</b> with [I]!</span>")
				var/swing_sound = pick('modular_skyrat/sound/attack/swing_01.ogg',
									'modular_skyrat/sound/attack/swing_02.ogg',
									'modular_skyrat/sound/attack/swing_03.ogg',
									)
				playsound(get_turf(src), swing_sound, 50)
				return 0
			else if(c_intent == CI_FEINT)
				if(attackchain_flags & ATTACKCHAIN_RIGHTCLICK)
					//Successful feint attack - victim is unable to attack for a while
					var/multi = 2
					if(user.mind)
						var/datum/skills/melee/melee = GET_SKILL(user, melee)
						if(melee)
							multi = melee.level/(MAX_SKILL/2)
					changeNext_move(CLICK_CD_MELEE * multi)
		affecting = get_bodypart(ran_zone(check_zone(user.zone_selected), ran_zone_prob))
	var/target_area = parse_zone(check_zone(user.zone_selected)) //our intended target

	SEND_SIGNAL(I, COMSIG_ITEM_ATTACK_ZONE, src, user, affecting)

	SSblackbox.record_feedback("nested tally", "item_used_for_combat", 1, list("[I.force]", "[I.type]"))
	SSblackbox.record_feedback("tally", "zone_targeted", 1, target_area)

	// The attacked_by code varies among species
	return dna.species.spec_attacked_by(I, user, affecting, a_intent, src, attackchain_flags, damage_multiplier)

/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM)
		. = ..(user, TRUE)
		if(.)
			return
		var/hulk_verb_continous = "smashes"
		var/hulk_verb_simple = "smash"
		if(prob(50))
			hulk_verb_continous = "pummels"
			hulk_verb_simple = "pummel"
		playsound(loc, user.dna.species.attack_sound, 25, 1, -1)
		visible_message("<span class='danger'>[user] [hulk_verb_continous] [src]!</span>", \
						"<span class='userdanger'>[user] [hulk_verb_continous] you!</span>", null, COMBAT_MESSAGE_RANGE, null, user,
						"<span class='danger'>You [hulk_verb_simple] [src]!</span>")
		apply_damage(15, BRUTE, wound_bonus=10) //skyrat edit
		return 1

/mob/living/carbon/human/attack_hand(mob/user)
	. = ..()
	if(.) //To allow surgery to return properly.
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		dna.species.spec_attack_hand(H, src)

/mob/living/carbon/human/attack_paw(mob/living/carbon/monkey/M)
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)
	if(M.a_intent == INTENT_HELP)
		return ..() //shaking

	if(M.a_intent == INTENT_DISARM) //Always drop item in hand, if no item, get stunned instead.
		var/obj/item/I = get_active_held_item()
		if(I && dropItemToGround(I))
			playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
					"<span class='userdanger'>[M] has disarmed you!</span>", null, COMBAT_MESSAGE_RANGE, null, M,
					"<span class='danger'>You have disarmed [src]!</span>")
		else if(!M.client || prob(5)) // only natural monkeys get to stun reliably, (they only do it occasionaly)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			DefaultCombatKnockdown(100)
			log_combat(M, src, "tackled")
			visible_message("<span class='danger'>[M] has tackled down [src]!</span>", \
				"<span class='userdanger'>[M] has tackled you down!</span>", null, COMBAT_MESSAGE_RANGE, null, M,
				"<span class='danger'>You have tackled [src] down!</span>")

	if(M.limb_destroyer)
		dismembering_strike(M, affecting.body_zone)

	if(can_inject(M, 1, affecting))//Thick suits can stop monkey bites.
		if(..()) //successful monkey bite, this handles disease contraction.
			var/damage = rand(1, 3)
			apply_damage(damage, BRUTE, affecting, run_armor_check(affecting, "melee")) //skyrat edit
		return 1

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	. = ..()
	if(!.)
		return
	if(M.a_intent == INTENT_HARM)
		if (w_uniform)
			w_uniform.add_fingerprint(M)
		var/damage = prob(90) ? M.meleeSlashHumanPower : 0
		if(!damage)
			playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
			visible_message("<span class='danger'>[M] has lunged at [src]!</span>", \
				"<span class='userdanger'>[M] has lunged at you!</span>", target = M, \
				target_message = "<span class='danger'>You have lunged at [src]!</span>")
			return 0
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(check_zone(M.zone_selected)))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, "melee", null, null,10)

		playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
		visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
			"<span class='userdanger'>[M] has slashed at you!</span>", target = M, \
			target_message = "<span class='danger'>You have slashed at [src]!</span>")
		log_combat(M, src, "attacked")
		if(!dismembering_strike(M, M.zone_selected)) //Dismemberment successful
			return 1
		apply_damage(damage, BRUTE, affecting, armor_block)

	if(M.a_intent == INTENT_DISARM) //Always drop item in hand, if no item, get stun instead.
		var/obj/item/I = get_active_held_item()
		if(I && dropItemToGround(I))
			playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
					"<span class='userdanger'>[M] has disarmed you!</span>", target = M, \
					target_message = "<span class='danger'>You have disarmed [src]!</span>")
		else
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			DefaultCombatKnockdown(M.meleeKnockdownPower)
			log_combat(M, src, "tackled")
			visible_message("<span class='danger'>[M] has tackled down [src]!</span>", \
				"<span class='userdanger'>[M] has tackled you down!</span>", target = M, \
				target_message = "<span class='danger'>You have tackled down [src]!</span>")

/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/L)
	. = ..()
	if(!.) //unsuccessful larva bite.
		return
	var/damage = rand(1, 3)
	if(stat != DEAD)
		L.amount_grown = min(L.amount_grown + damage, L.max_grown)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(check_zone(L.zone_selected)))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor_block = run_armor_check(affecting, "melee")
		apply_damage(damage, BRUTE, affecting, armor_block)


/mob/living/carbon/human/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = .
		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return TRUE
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		var/armor = run_armor_check(affecting, "melee", armour_penetration = M.armour_penetration)
		apply_damage(damage, M.melee_damage_type, affecting, armor, FALSE, M.wound_bonus, M.bare_wound_bonus, M.sharpness)


/mob/living/carbon/human/attack_slime(mob/living/simple_animal/slime/M)
	. = ..()
	if(!.) //unsuccessful slime attack
		return
	var/damage = rand(5, 25)
	//skyrat edit
	var/wound_mod = -45 // 25^1.4=90, 90-45=45
	//
	if(M.is_adult)
		damage = rand(10, 35)
		//skyrat edit
		wound_mod = -90 // 35^1.4=145, 145-90=55
		//

	var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	if(!dam_zone) //Dismemberment successful
		return 1

	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	if(!affecting)
		affecting = get_bodypart(BODY_ZONE_CHEST)
	var/armor_block = run_armor_check(affecting, "melee")
	apply_damage(damage, BRUTE, affecting, armor_block, wound_bonus=wound_mod) //skyrat edit

/mob/living/carbon/human/mech_melee_attack(obj/mecha/M)
	if(M.occupant.a_intent == INTENT_HARM)
		if(HAS_TRAIT(M.occupant, TRAIT_PACIFISM))
			to_chat(M.occupant, "<span class='warning'>You don't want to harm other living beings!</span>")
			return
		M.do_attack_animation(src)
		if(M.damtype == "brute")
			step_away(src,M,15)
		var/obj/item/bodypart/temp = get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_CHEST, BODY_ZONE_HEAD))
		if(temp)
			var/update = 0
			var/dmg = rand(M.force/2, M.force)
			var/atom/throw_target = get_edge_target_turf(src, M.dir)
			switch(M.damtype)
				if("brute")
					if(M.force > 35) // durand and other heavy mechas
						DefaultCombatKnockdown(50)
						src.throw_at(throw_target, rand(1,5), 7)
					else if(M.force >= 20 && CHECK_MOBILITY(src, MOBILITY_STAND)) // lightweight mechas like gygax
						DefaultCombatKnockdown(30)
						src.throw_at(throw_target, rand(1,3), 7)
					update |= temp.receive_damage(dmg, 0)
					playsound(src, 'sound/weapons/punch4.ogg', 50, 1)
				if("fire")
					update |= temp.receive_damage(0, dmg)
					playsound(src, 'sound/items/welder.ogg', 50, 1)
				if("tox")
					M.mech_toxin_damage(src)
				else
					return
			if(update)
				update_damage_overlays()
			updatehealth()

		visible_message("<span class='danger'><b>[M.name]</b> has hit <b>[src]</b>!</span>", \
						"<span class='userdanger'><b>[M.name]</b> has hit you!</span>", null, COMBAT_MESSAGE_RANGE, target = M,
						target_message = "<span class='danger'>You have hit <b>[src]</b>!</span>")
		log_combat(M.occupant, src, "attacked", M, "(INTENT: [uppertext(M.occupant.a_intent)]) (DAMTYPE: [uppertext(M.damtype)])")

	else
		..()


/mob/living/carbon/human/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if (!severity)
		return
	var/brute_loss = 0
	var/burn_loss = 0
	var/bomb_armor = getarmor(null, "bomb")

	//200 max knockdown for EXPLODE_HEAVY
	//160 max knockdown for EXPLODE_LIGHT

	switch (severity)
		if (EXPLODE_DEVASTATE)
			if(bomb_armor < EXPLODE_GIB_THRESHOLD) //gibs the mob if their bomb armor is lower than EXPLODE_GIB_THRESHOLD
				for(var/I in contents)
					var/atom/A = I
					if(!QDELETED(A))
						A.ex_act(severity)
				gib()
				return
			else
				brute_loss = 500
				var/atom/throw_target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(throw_target, 200, 4)
				damage_clothes(400 - bomb_armor, BRUTE, "bomb")

		if (EXPLODE_HEAVY)
			brute_loss = 60
			burn_loss = 60
			if(bomb_armor)
				brute_loss = 30*(2 - round(bomb_armor*0.01, 0.05))
				burn_loss = brute_loss				//damage gets reduced from 120 to up to 60 combined brute+burn
			damage_clothes(200 - bomb_armor, BRUTE, "bomb")
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(30, 120)
			Unconscious(20)							//short amount of time for follow up attacks against elusive enemies like wizards
			Knockdown(200 - (bomb_armor * 1.6)) 	//between ~4 and ~20 seconds of knockdown depending on bomb armor

		if(EXPLODE_LIGHT)
			brute_loss = 30
			if(bomb_armor)
				brute_loss = 15*(2 - round(bomb_armor*0.01, 0.05))
			damage_clothes(max(50 - bomb_armor, 0), BRUTE, "bomb")
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				adjustEarDamage(15,60)
			Knockdown(160 - (bomb_armor * 1.6))		//100 bomb armor will prevent knockdown altogether

	take_overall_damage(brute_loss,burn_loss)

	//attempt to dismember bodyparts
	if(severity <= 2 || !bomb_armor)
		var/max_limb_loss = round(4/severity) //so you don't lose four limbs at severity 3.
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(50/severity) && !prob(getarmor(BP, "bomb")) && BP.body_zone != BODY_ZONE_HEAD && BP.body_zone != BODY_ZONE_CHEST)
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break


/mob/living/carbon/human/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	show_message("<span class='userdanger'>The blob attacks you!</span>")
	var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, "melee"))


///Calculates the siemens coeff based on clothing and species, can also restart hearts.
/mob/living/carbon/human/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	//Calculates the siemens coeff based on clothing. Completely ignores the arguments
	if(flags & SHOCK_TESLA) //I hate this entire block. This gets the siemens_coeff for tesla shocks
		if(gloves && gloves.siemens_coefficient <= 0)
			siemens_coeff -= 0.5
		if(wear_suit)
			if(wear_suit.siemens_coefficient == -1)
				siemens_coeff -= 1
			else if(wear_suit.siemens_coefficient <= 0)
				siemens_coeff -= 0.95
		siemens_coeff = max(siemens_coeff, 0)
	else if(!(flags & SHOCK_NOGLOVES)) //This gets the siemens_coeff for all non tesla shocks
		if(gloves)
			siemens_coeff *= gloves.siemens_coefficient
	siemens_coeff *= physiology.siemens_coeff
	. = ..()
	//Don't go further if the shock was blocked/too weak.
	if(!.)
		return
	//Note we both check that the user is in cardiac arrest and can actually heartattack
	//If they can't, they're missing their heart and this would runtime
	if(undergoing_cardiac_arrest() && can_heartattack() && !(flags & SHOCK_ILLUSION))
		if(shock_damage * siemens_coeff >= 1 && prob(25))
			var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
			if(heart.Restart() && stat == CONSCIOUS)
				to_chat(src, "<span class='notice'>You feel your heart beating again!</span>")
	electrocution_animation(40)

/********moved to modular_skyrat
/mob/living/carbon/human/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	var/informed = FALSE
	for(var/obj/item/bodypart/L in src.bodyparts)
		if(L.status == BODYPART_ROBOTIC)
			if(!informed)
				to_chat(src, "<span class='userdanger'>You feel a sharp pain as your robotic limbs overload.</span>")
				informed = TRUE
			switch(severity)
				if(1)
					L.receive_damage(0,10)
					Stun(200)
				if(2)
					L.receive_damage(0,5)
					Stun(100)
*/

/mob/living/carbon/human/acid_act(acidpwr, acid_volume, bodyzone_hit)
	var/list/damaged = list()
	var/list/inventory_items_to_kill = list()
	var/acidity = acidpwr * min(acid_volume*0.005, 0.1)
	//HEAD//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD) //only if we didn't specify a zone or if that zone is the head.
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			if(!(head_clothes.resistance_flags & UNACIDABLE))
				head_clothes.acid_act(acidpwr, acid_volume)
				update_inv_glasses()
				update_inv_wear_mask()
				update_inv_neck()
				update_inv_head()
			else
				to_chat(src, "<span class='notice'>Your [head_clothes.name] protects your head and face from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_HEAD)
			if(.)
				damaged += .
			if(ears)
				inventory_items_to_kill += ears

	//CHEST//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			if(!(chest_clothes.resistance_flags & UNACIDABLE))
				chest_clothes.acid_act(acidpwr, acid_volume)
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [chest_clothes.name] protects your body from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_CHEST)
			if(.)
				damaged += .
			if(wear_id)
				inventory_items_to_kill += wear_id
			if(r_store)
				inventory_items_to_kill += r_store
			if(l_store)
				inventory_items_to_kill += l_store
			if(s_store)
				inventory_items_to_kill += s_store


	//ARMS & HANDS//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_ARM || bodyzone_hit == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit

		if(arm_clothes)
			if(!(arm_clothes.resistance_flags & UNACIDABLE))
				arm_clothes.acid_act(acidpwr, acid_volume)
				update_inv_gloves()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [arm_clothes.name] protects your arms and hands from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_R_ARM)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_ARM)
			if(.)
				damaged += .


	//LEGS & FEET//
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_L_LEG || bodyzone_hit == BODY_ZONE_R_LEG || bodyzone_hit == "feet")
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (w_uniform.body_parts_covered & LEGS))))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (bodyzone_hit != "feet" && (wear_suit.body_parts_covered & LEGS))))
			leg_clothes = wear_suit
		if(leg_clothes)
			if(!(leg_clothes.resistance_flags & UNACIDABLE))
				leg_clothes.acid_act(acidpwr, acid_volume)
				update_inv_shoes()
				update_inv_w_uniform()
				update_inv_wear_suit()
			else
				to_chat(src, "<span class='notice'>Your [leg_clothes.name] protects your legs and feet from the acid!</span>")
		else
			. = get_bodypart(BODY_ZONE_R_LEG)
			if(.)
				damaged += .
			. = get_bodypart(BODY_ZONE_L_LEG)
			if(.)
				damaged += .


	//DAMAGE//
	for(var/obj/item/bodypart/affecting in damaged)
		affecting.receive_damage(acidity, 2*acidity)

		if(affecting.name == BODY_ZONE_HEAD)
			if(prob(min(acidpwr*acid_volume/10, 90))) //Applies disfigurement
				affecting.receive_damage(acidity, 2*acidity)
				emote("scream")
				facial_hair_style = "Shaved"
				hair_style = "Bald"
				update_hair()
				ADD_TRAIT(src, TRAIT_DISFIGURED, TRAIT_GENERIC)

		update_damage_overlays()

	//MELTING INVENTORY ITEMS//
	//these items are all outside of armour visually, so melt regardless.
	if(!bodyzone_hit)
		if(back)
			inventory_items_to_kill += back
		if(belt)
			inventory_items_to_kill += belt

		inventory_items_to_kill += held_items

	for(var/obj/item/I in inventory_items_to_kill)
		I.acid_act(acidpwr, acid_volume)
	return 1

/mob/living/carbon/human/singularity_act()
	var/gain = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Senior Engineer") )
			gain = 100
		if(HAS_TRAIT(mind, TRAIT_CLOWN_MENTALITY))
			gain = rand(-300, 300)
	investigate_log("([key_name(src)]) has been consumed by the singularity.", INVESTIGATE_SINGULO) //Oh that's where the clown ended up!
	gib()
	return(gain)

/mob/living/carbon/human/help_shake_act(mob/living/carbon/M)
	if(!istype(M))
		return

	if(health >= 0)
		if(src == M)
			if(has_status_effect(STATUS_EFFECT_CHOKINGSTRAND))
				to_chat(src, "<span class='notice'>You attempt to remove the durathread strand from around your neck.</span>")
				if(do_after(src, 35, null, src))
					to_chat(src, "<span class='notice'>You succesfuly remove the durathread strand.</span>")
					remove_status_effect(STATUS_EFFECT_CHOKINGSTRAND)
				return
			M.check_self_for_injuries()
		else
			if(wear_suit)
				wear_suit.add_fingerprint(M)
			else if(w_uniform)
				w_uniform.add_fingerprint(M)

			..()


/mob/living/carbon/human/damage_clothes(damage_amount, damage_type = BRUTE, damage_flag = 0, def_zone)
	if(damage_type != BRUTE && damage_type != BURN)
		return
	damage_amount *= 0.5 //0.5 multiplier for balance reason, we don't want clothes to be too easily destroyed
	var/list/torn_items = list()

	//HEAD//
	if(!def_zone || def_zone == BODY_ZONE_HEAD)
		var/obj/item/clothing/head_clothes = null
		if(glasses)
			head_clothes = glasses
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			head_clothes = head
		if(head_clothes)
			torn_items += head_clothes
		else if(ears)
			torn_items += ears

	//CHEST//
	if(!def_zone || def_zone == BODY_ZONE_CHEST)
		var/obj/item/clothing/chest_clothes = null
		if(w_uniform)
			chest_clothes = w_uniform
		if(wear_suit)
			chest_clothes = wear_suit
		if(chest_clothes)
			torn_items += chest_clothes

	//ARMS & HANDS//
	if(!def_zone || def_zone == BODY_ZONE_L_ARM || def_zone == BODY_ZONE_R_ARM)
		var/obj/item/clothing/arm_clothes = null
		if(gloves)
			arm_clothes = gloves
		if(w_uniform && ((w_uniform.body_parts_covered & HANDS) || (w_uniform.body_parts_covered & ARMS)))
			arm_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & HANDS) || (wear_suit.body_parts_covered & ARMS)))
			arm_clothes = wear_suit
		if(arm_clothes)
			torn_items |= arm_clothes

	//LEGS & FEET//
	if(!def_zone || def_zone == BODY_ZONE_L_LEG || def_zone == BODY_ZONE_R_LEG)
		var/obj/item/clothing/leg_clothes = null
		if(shoes)
			leg_clothes = shoes
		if(w_uniform && ((w_uniform.body_parts_covered & FEET) || (w_uniform.body_parts_covered & LEGS)))
			leg_clothes = w_uniform
		if(wear_suit && ((wear_suit.body_parts_covered & FEET) || (wear_suit.body_parts_covered & LEGS)))
			leg_clothes = wear_suit
		if(leg_clothes)
			torn_items |= leg_clothes

	for(var/obj/item/I in torn_items)
		I.take_damage(damage_amount, damage_type, damage_flag, 0)

//skyrat cum inflation
/mob/living/carbon/human/check_self_for_injuries()
	if(stat == DEAD || stat == UNCONSCIOUS || !src.canUseTopic(src, TRUE, check_resting = FALSE))
		return

	visible_message("<span class='notice'>[src] examines [p_themselves()].</span>", \
		"<span class='notice'><i><b>I check myself for injuries.</b><i></span>")

	for(var/X in ALL_BODYPARTS)
		var/obj/item/bodypart/LB = get_bodypart(X)
		if(!LB)
			to_chat(src, "\t[parse_zone(X)]: <span class='deadsay'>MISSING</span>")
			continue

		var/limb_max_damage = LB.max_damage
		var/limb_max_pain = min(100, LB.max_pain_damage)
		var/list/status = list()
		var/brutedamage = LB.brute_dam
		var/burndamage = LB.burn_dam
		var/paindamage = LB.get_pain()
		if(hallucination)
			if(prob(30))
				brutedamage += rand(30,40)
			if(prob(30))
				burndamage += rand(30,40)
			if(prob(30))
				paindamage += rand(30,40)

		if(HAS_TRAIT(src, TRAIT_SELF_AWARE))
			if(!brutedamage && !burndamage)
				status += "<span class='nicegreen'>OK</span>"
			else
				status += "<span class='[brutedamage >= 5 ? "danger" : "notice"]'>[brutedamage] BRUTE</span>"
				status += "<span class='[burndamage >= 5 ? "danger" : "notice"]'>[burndamage] BURN</span>"
				status += "<span class='[paindamage >= 10 ? "danger" : "notice"]'>[paindamage] PAIN</span>"
		else
			if(brutedamage > (limb_max_damage*0.75))
				status += "<span class='userdanger'>[uppertext(LB.heavy_brute_msg)]</span>"
			else if(brutedamage > (limb_max_damage*0.25))
				status += "<span class='danger'>[uppertext(LB.medium_brute_msg)]</span>"
			else if(brutedamage > 0)
				status += "<span class='warning'>[uppertext(LB.light_brute_msg)]</span>"

			if(burndamage > (limb_max_damage*0.75))
				status += "<span class='userdanger'>[uppertext(LB.heavy_burn_msg)]</span>"
			else if(burndamage > (limb_max_damage*0.25))
				status += "<span class='danger'>[uppertext(LB.medium_burn_msg)]</span>"
			else if(burndamage > 0)
				status += "<span class='warning'>[uppertext(LB.light_burn_msg)]</span>"

			if(paindamage > (limb_max_pain*0.75))
				status += "<span class='userdanger'>[uppertext(LB.heavy_pain_msg)]</span>"
			else if(burndamage > (limb_max_pain*0.25))
				status += "<span class='danger'>[uppertext(LB.medium_pain_msg)]</span>"
			else if(burndamage > 0)
				status += "<span class='warning'>[uppertext(LB.light_pain_msg)]</span>"

		if(!HAS_TRAIT(src, TRAIT_SCREWY_CHECKSELF) && length(LB.wounds))
			for(var/thing in LB.wounds)
				var/datum/wound/W = thing
				var/woundmsg
				if(W.can_self_treat)
					woundmsg = "<a href='?src=[REF(W)];self_treat=1;' class='warning'>[uppertext(W.name)]</a>"
				else
					woundmsg = "[uppertext(W.name)]"
				switch(W.severity)
					if(WOUND_SEVERITY_TRIVIAL)
						status += "<span class='warning'>[woundmsg]</span>"
					if(WOUND_SEVERITY_MODERATE)
						status += "<span class='warning'>[woundmsg]</span>"
					if(WOUND_SEVERITY_SEVERE)
						status += "<span class='danger'><b>[woundmsg]</b></span>"
					if(WOUND_SEVERITY_CRITICAL)
						status += "<span class='userdanger'>[woundmsg]</span>"
					if(WOUND_SEVERITY_LOSS)
						status += "<span class='deadsay'>[woundmsg]</span>"
					if(WOUND_SEVERITY_PERMANENT)
						status += "<span class='userdanger'>[woundmsg]</span>"
		
		if(!HAS_TRAIT(src, TRAIT_SCREWY_CHECKSELF) && length(LB.embedded_objects))
			for(var/obj/item/I in LB.embedded_objects)
				status += "<span class='warning'><a href='?src=[REF(src)];embedded_object=[REF(I)];embedded_limb=[REF(LB)]'>[I.isEmbedHarmless() ? "STUCK" : "EMBEDDED"] [uppertext(I.name)]</a></span>"

		if(LB.get_bleed_rate())
			status += "<span class='danger'><b>BLEEDING</b></span>"
		
		if(!HAS_TRAIT(src, TRAIT_SCREWY_CHECKSELF) && LB.is_disabled())
			status += "<span class='danger'><b>DISABLED</b></span>"
		
		if(LB.body_zone == BODY_ZONE_HEAD)
			var/obj/item/bodypart/head/HD = LB
			if(HD.tapered)
				if(!wear_mask)
					status += "<span class='warning'><b><a href='?src=[REF(HD)];tape=[HD.tapered];'>TAPED</a></b></span>"
		
		if(LB.current_gauze)
			status += "<span class='notice'><a href='?src=[REF(LB)];gauze=1;'>GAUZED</a></span>"
		
		if(!length(status))
			status += "<span class='nicegreen'>OK</span>"
		
		if(!HAS_TRAIT(src, TRAIT_SCREWY_CHECKSELF))
			to_chat(src, "<span class='notice'>[LB.name]: [jointext(status, " | ")] </span>")
		else
			to_chat(src, "<span class='notice'>[LB.name]: <span class='nicegreen'>OK</span> </span>")

///Get all the clothing on a specific body part
/mob/living/carbon/human/proc/clothingonpart(obj/item/bodypart/def_zone)
	var/list/covering_part = list()
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, back, gloves, shoes, belt, s_store, glasses, ears, wear_id, wear_neck) //Everything but pockets. Pockets are l_store and r_store. (if pockets were allowed, putting something armored, gloves or hats for example, would double up on the armor)
	for(var/bp in body_parts)
		if(!bp)
			continue
		if(bp && istype(bp , /obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				covering_part += C
	return length(covering_part)

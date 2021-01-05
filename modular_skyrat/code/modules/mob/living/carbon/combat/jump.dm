//AAAAAAAAAAAAA
/mob/living/carbon
	var/tackling = FALSE //Whether or not we are tackling/jumping, this will prevent some of the knock into effects for carbons
	var/tackle_base_stamina_cost = 50 //Stamina cost for a tackle with 10 dex (lowers with higher dex, increases with lower)
	var/tackle_base_knockdown = 3 SECONDS //How long we get knocked down with 10 dex (lowers with higher dex, increases with lower)
	var/tackle_speed = 1 //Speed of the tackle - not normally affected by stats or skills
	var/tackle_base_range = 2 //How much a nigga with 10 dex can tackle etc
	var/max_tackle_range = 5 //The absolute maximum distance for a jump, dex impacts reach but cannot go above this
	var/min_tackle_range = 1 //Absolute minimum tackle distance

//Jumping (tackling)
/mob/living/carbon/proc/perform_jump(atom/A, params)
	if(buckling)
		return

	if(HAS_TRAIT(src, TRAIT_HULK))
		to_chat(src, "<span class='warning'>I'm too angry to remember how to tackle!</span>")
		return

	if(restrained())
		to_chat(src, "<span class='warning'>I need free use of my hands to tackle!</span>")
		return

	if(!CHECK_BITFIELD(mobility_flags, MOBILITY_STAND))
		to_chat(src, "<span class='warning'>I must be standing to tackle!</span>")
		return

	if(src.tackling)
		to_chat(src, "<span class='warning'>I'm not ready to tackle!</span>")
		return
	
	if(src.has_status_effect(STATUS_EFFECT_TASED)) // can't tackle if you just got tased
		to_chat(src, "<span class='warning'>I can't tackle while tased!</span>")
		return

	face_atom(A)
	tackling = TRUE

	if(can_see(src, A, 7))
		if(ismob(A))
			visible_message("<span class='warning'><b>[src]</b> leaps at <b>[A]</b>!</span>", "<span class='danger'>I leap at <b>[A]</b>!</span>")
		else
			visible_message("<span class='warning'><b>[src]</b> leaps at [A]!</span>", "<span class='danger'>I leap at [A]!</span>")
	else
		visible_message("<span class='warning'><b>[src]<b> leaps!</span>", "<span class='danger'>I leap!</span>")

	if(get_dist(src, A) < min_tackle_range)
		A = get_ranged_target_turf(src, get_dir(src, A), min_tackle_range)

	var/our_dex = GET_STAT_LEVEL(src, dex) || 10
	Knockdown(tackle_base_knockdown/our_dex * MAX_STAT/2, TRUE, TRUE)
	adjustStaminaLoss(tackle_base_stamina_cost/our_dex * MAX_STAT/2)
	playsound(src, 'sound/weapons/thudswoosh.ogg', 40, TRUE, -1)
	RegisterSignal(src, COMSIG_MOVABLE_IMPACT, .proc/tackle_sack)
	throw_at(A, clamp(tackle_base_range/our_dex * MAX_STAT/2, min_tackle_range, max_tackle_range), tackle_speed, src, FALSE)
	addtimer(CALLBACK(src, .proc/reset_tackle), tackle_base_knockdown/our_dex * MAX_STAT/2, TIMER_STOPPABLE)

//Resetting our tackle
/mob/living/carbon/proc/reset_tackle()
	UnregisterSignal(src, COMSIG_MOVABLE_IMPACT)
	tackling = FALSE

/mob/living/carbon/proc/tackle_sack(mob/living/carbon/user, atom/hit)
	if(!tackling)
		return
	
	if(!iscarbon(hit))
		if(hit.density)
			return tackle_splat(user, hit)
		return
	
	var/mob/living/carbon/target = hit
	var/roll = mind?.diceroll(GET_STAT_LEVEL(src, dex), mod = -GET_STAT_LEVEL(target, dex)/2) || DICE_SUCCESS
	tackling = FALSE

	switch(roll)
		if(DICE_CRIT_FAILURE)
			visible_message("<span class='danger'><b>[src]</b> botches [p_their()] tackle and slams [p_their()] head into <b>[target]</b>, knocking [user.p_them()]self silly!</span>", "<span class='userdanger'>You botch your tackle and slam your head into <b>[target]</b>, knocking yourself silly!</span>", target)
			to_chat(target, "<span class='userdanger'><b>[src]</b> botches [p_their()] tackle and slams [p_their()] head into you, knocking [user.p_them()]self silly!</span>")

			Paralyze(3 SECONDS)
			var/obj/item/bodypart/head/hed = get_bodypart(BODY_ZONE_HEAD)
			if(hed)
				hed.receive_damage(brute=rand(10, 20), updating_health=TRUE)
			if(prob(35))
				gain_trauma(/datum/brain_trauma/mild/concussion)
		if(DICE_FAILURE)
			user.visible_message("<span class='warning'><b>[src]</b> lands a weak tackle on <b>[target]</b>, briefly knocking [target.p_them()] off-balance!</span>", "<span class='userdanger'>You land a weak tackle on <b>[target]</b>, briefly knocking [target.p_them()] off-balance!</span>", target)
			to_chat(target, "<span class='userdanger'><b>[src]</b> lands a weak tackle on you, briefly knocking you off-balance!</span>")
			Knockdown(3 SECONDS)
			Stumble(6 SECONDS)
			target.adjustStaminaLoss(rand(15, 25))
			target.Stumble(6 SECONDS)
		if(DICE_SUCCESS)
			visible_message("<span class='warning'><b>[src]</b> lands a tackle on <b>[target]</b>, sending them both tumbling!</span>", "<span class='userdanger'>You land a takle on <b>[target]</b>, sending you both tumbling!</span>", target)
			to_chat(target, "<span class='userdanger'><b>[src]</b> lands a tackle on you, sending you both tumbling!</span>")

			target.Paralyze(((0.5 SECONDS)/min(GET_STAT_LEVEL(target, dex), 1) * MAX_STAT/2)
			target.adjustStaminaLoss((tackle_base_stamina_cost * 1.5)/min(GET_STAT_LEVEL(target, dex), 1) * MAX_STAT/2)
			target.Knockdown((3 SECONDS)/min(GET_STAT_LEVEL(target, dex), 1) * MAX_STAT/2)
			target.Stumble(6 SECONDS)
			Knockdown(1.5 SECONDS)
			Stumble(6 SECONDS)
		if(DICE_CRIT_SUCCESS)
			visible_message("<span class='warning'><b>[src]</b> lands an expert tackle on <b>[target]</b>, knocking [target.p_them()] down hard while landing on [user.p_their()] feet with a grip!</span>", "<span class='userdanger'>You land an expert tackle on <b>[target]</b>, knocking [target.p_them()] down hard while landing on your feet with a grip!</span>", target)
			to_chat(target, "<span class='userdanger'><b>[src]</b> lands an expert tackle on you, knocking you down hard and maintaining a grab!</span>")

			SetKnockdown(0)
			set_resting(FALSE, TRUE, FALSE)
			forceMove(get_turf(target))
			target.adjustStaminaLoss(((tackle_base_stamina_cost * 1.5)/min(GET_STAT_LEVEL(target, dex), 1)) * MAX_STAT/2)
			target.Paralyze(5)
			target.Knockdown(((3 SECONDS)/GET_STAT_LEVEL(target, dex)) * MAX_STAT/2) //So they cant get up instantly.
			if(iscarbon(src))
				target.grabbedby(src)

/mob/living/carbon/proc/tackle_splat(mob/living/carbon/user, atom/hit)
	if(istype(hit, /obj/structure/window))
		var/obj/structure/window/W = hit
		tackle_splat_window(user, W)
		if(QDELETED(W))
			return COMPONENT_MOVABLE_IMPACT_NEVERMIND
		return

	var/roll = mind?.diceroll(GET_STAT_LEVEL(src, dex)) || DICE_SUCCESS
	switch(roll)
		if(DICE_CRIT_FAILURE)
			visible_message("<span class='danger'><b>[src]</b> slams head-first into [hit], suffering major cranial trauma!</span>", "<span class='userdanger'>I slam head-first into [hit], and the world explodes around me!</span>")
			adjustStaminaLoss(40)
			apply_damage(30, BRUTE, BODY_ZONE_HEAD)
			confused += 15
			if(prob(75 - GET_STAT_LEVEL(src, dex)))
				gain_trauma(/datum/brain_trauma/mild/concussion)
			playsound_local(get_turf(user), 'sound/weapons/flashbang.ogg', 100, TRUE, 8, 0.9)
			DefaultCombatKnockdown(4 SECONDS)
			shake_camera(user, 5, 5)
			overlay_fullscreen("flash", /obj/screen/fullscreen/flash)
			clear_fullscreen("flash", 2.5)

		if(DICE_FAILURE)
			visible_message("<span class='danger'><b>[src]</b> slams hard into [hit], knocking [user.p_them()] senseless!</span>", "<span class='userdanger'>I slam hard into [hit], knocking myself senseless!</span>")
			adjustStaminaLoss(40)
			apply_damage(rand(10, 15), BRUTE, BODY_ZONE_HEAD)
			confused += 10
			DefaultCombatKnockdown(30)
			shake_camera(user, 3, 4)

		if(DICE_SUCCESS)
			visible_message("<span class='danger'><b>[src]</b> slams into [hit]!</span>", "<span class='userdanger'>I slam into [hit]!</span>")
			adjustStaminaLoss(30)
			apply_damage(rand(5, 10), BRUTE, BODY_ZONE_HEAD)
			DefaultCombatKnockdown(3 SECONDS)
			shake_camera(user, 2, 2)
		
		if(DICE_CRIT_SUCCESS)
			visible_message("<span class='danger'><b>[src]</b> slams into [hit]!</span>", "<span class='userdanger'>I slam into [hit]!</span>")
			adjustStaminaLoss(20)
			Stumble(3 SECONDS)
			shake_camera(user, 2, 2)
		
	playsound(user, 'sound/weapons/smash.ogg', 70, TRUE)

/mob/living/carbon/proc/tackle_splat_window(mob/living/carbon/user, obj/structure/window/W)
	playsound(src, "sound/effects/Glasshit.ogg", 140, TRUE)

	if(W.type in list(/obj/structure/window, /obj/structure/window/fulltile, /obj/structure/window/unanchored, /obj/structure/window/fulltile/unanchored)) // boring unreinforced windows
		for(var/i = 0, i < 2 * tackle_speed, i++)
			var/obj/item/shard/shard = new /obj/item/shard(get_turf(user))
			shard.updateEmbedding()
			user.hitby(shard, skipcatch = TRUE, hitpush = FALSE)
			shard.embedding = list()
			shard.updateEmbedding()
		W.obj_destruction()
		adjustStaminaLoss(20 * tackle_speed)
		DefaultCombatKnockdown(4 SECONDS)
		Paralyze(5 * tackle_speed)
		visible_message("<span class='danger'><b>[user]</b> slams into [W] and shatters it, shredding [user.p_them()]self with glass shards!</span>", "<span class='userdanger'>I slam into [W] and shatter it, shredding myself with glass shards!</span>")
	else
		visible_message("<span class='danger'><b>[user]</b> slams into [W], nearly shattering it!</span>", "<span class='userdanger'>I slam into [W], nearly shattering it!</span>")
		adjustStaminaLoss(20 * tackle_speed)
		DefaultCombatKnockdown(2 SECONDS * tackle_speed)
		Paralyze(2 * tackle_speed)
		apply_damage(rand(5, 10) * tackle_speed, BRUTE, BODY_ZONE_HEAD)
		W.take_damage(20 * tackle_speed)

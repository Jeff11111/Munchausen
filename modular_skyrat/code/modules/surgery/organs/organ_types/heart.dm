#define HEART_MAX_HEALTH 45

/obj/item/organ/heart
	name = "heart"
	desc = "I feel bad for the heartless bastard who lost this."
	icon_state = "heart-on"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_HEART

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = "<span class='info'>Prickles of pain appear then die out from within your chest...</span>"
	high_threshold_passed = "<span class='warning'>Something inside your chest hurts, and the pain isn't subsiding. You notice yourself breathing far faster than before.</span>"
	now_fixed = "<span class='info'>Your heart begins to beat again.</span>"
	high_threshold_cleared = "<span class='info'>The pain in your chest has died down, and your breathing becomes more relaxed.</span>"

	// Heart attack code is in code/modules/mob/living/carbon/human/life.dm
	var/no_pump = FALSE
	var/icon_base = "heart"
	attack_verb = list("beat", "thumped")
	var/beat = BEAT_NONE //is this mob having a heatbeat sound played? if so, which?

	var/failed = FALSE		//to prevent constantly running failing code
	var/operated = FALSE	//whether the heart's been operated on to fix some of its damages

	maxHealth = HEART_MAX_HEALTH
	low_threshold = HEART_MAX_HEALTH/4.5
	high_threshold = HEART_MAX_HEALTH/3 * 2

	//Bobmed variables
	damage_reduction = 0.7
	relative_size = 4 //Chance is low because getting shot in the chest once and going into crit ain't good
	var/pulse = PULSE_NORM
	var/heartbeat = 0
	var/open = 0

/obj/item/organ/heart/surgical_examine(mob/user)
	. = list()
	var/failing = FALSE
	var/decayed = FALSE
	var/damaged = FALSE
	if(organ_flags & ORGAN_DEAD)
		decayed = TRUE
	if(organ_flags & ORGAN_FAILING)
		failing = TRUE
		if(status & ORGAN_ROBOTIC)
			. += "<span class='warning'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be broken!</span>"
		else
			. += "<span class='warning'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] is severely damaged, and doesn't seem like it will work anymore!</span>"
	if(damage > high_threshold)
		if(!failing)
			damaged = TRUE
			. += "<span class='warning'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] is starting to look discolored.</span>"
	if(!failing && !damaged)
		. += "<span class='notice'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be quite healthy.</span>"
	if(decayed)
		. += "<span class='deadsay'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to have decayed, reaching a non-functional state...</span>"
	if(germ_level)
		switch(germ_level)
			if(INFECTION_LEVEL_ONE to INFECTION_LEVEL_TWO)
				. +=  "<span class='deadsay'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be mildly infected.</span>"
			if(INFECTION_LEVEL_TWO to INFECTION_LEVEL_THREE)
				. +=  "<span class='deadsay'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be oozing some foul pus...</span>"
			if(INFECTION_LEVEL_THREE to INFINITY)
				. += "<span class='deadsay'>[owner ? "[owner.p_their(TRUE)] " : ""][owner ? src.name : capitalize(src.name)] seems to be awfully necrotic and riddled with dead tissue!</span>"
	if(etching)
		if(!is_dreamer(user))
			if(!findtext(etching, "<b>INRL</b> - "))
				if(owner)
					. += "<span class='warning'>Something is etched on [src], but i cannot see it clearly.</span>"
				else
					. += "<span class='notice'>[owner ? "[owner.p_their(TRUE)] " : ""][src] has <b>\"[etching]\"</b> inscribed on it.</span>"
		else
			if(owner)
				. += "<span class='userdanger'>I must inspect it CLOSELY.</span>"
			else
				. += "<b>There's something CUT on this HEART. \"[etching]. Add it to the other keys to exit INRL.\"</b>"
				var/datum/antagonist/dreamer/droomer = user.mind.has_antag_datum(/datum/antagonist/dreamer)
				if(droomer && !(etching in droomer.hearts_seen))
					user.playsound_local(get_turf(user), 'modular_skyrat/sound/effects/newheart.ogg', 75, 0)
					droomer.hearts_seen |= etching
	else if(is_dreamer(user) && !findtext(etching, "<b>INRL</b> - "))
		. += "<b>There is NOTHING on his heart. Should be? Following the TRUTH - not here. I need to keep LOOKING. Keep FOLLOWING my heart.</b>"
	if(!owner)
		. += "<span class='notice'>This organ can be inserted into \the [parse_zone(zone)].</span>"

/obj/item/organ/heart/on_death()
	. = ..()
	stop_if_unowned()

/obj/item/organ/heart/is_working()
	. = ..()
	if(!. || (damage >= high_threshold))
		return FALSE
	
	return pulse > PULSE_NONE || (owner && HAS_TRAIT(owner, TRAIT_FAKEDEATH))

/obj/item/organ/heart/update_icon_state()
	if(is_working())
		icon_state = "[icon_base]-on"
	else
		icon_state = "[icon_base]-off"

/obj/item/organ/heart/Remove(special = FALSE)
	if(!special)
		addtimer(CALLBACK(src, .proc/stop_if_unowned), 12 SECONDS)
	return ..()

/obj/item/organ/heart/proc/stop_if_unowned()
	if(!owner)
		Stop()

/obj/item/organ/heart/attack_self(mob/user)
	..()
	if(!pulse)
		user.visible_message("<span class='notice'>[user] squeezes [src] to \
			make it beat again!</span>","<span class='notice'>You squeeze [src] to make it beat again!</span>")
		Restart()
		addtimer(CALLBACK(src, .proc/stop_if_unowned), 80)

/obj/item/organ/heart/proc/Stop()
	if(owner)
		if(CHECK_BITFIELD(organ_flags, ORGAN_VITAL))
			owner.death()
		to_chat(owner, "<span class='userdanger'><b>MY HEART HAS STOPPED!</b></span>")
	pulse = PULSE_NONE
	update_icon()
	return 1

/obj/item/organ/heart/proc/Restart()
	pulse = PULSE_NORM
	update_icon()
	return 1

/obj/item/organ/heart/proc/HeartStrengthMessage()
	if(pulse >= PULSE_NORM)
		return "a healthy"
	return "<span class='danger'>an unstable</span>"

/obj/item/organ/heart/OnEatFrom(eater, feeder)
	. = ..()
	pulse = PULSE_NONE
	update_icon()

/obj/item/organ/heart/on_life()
	. = ..()
	handle_pulse()
	if(pulse)
		handle_heartbeat()
		if(pulse == PULSE_2FAST && prob(1))
			applyOrganDamage(1)
		else if(pulse >= PULSE_THREADY && prob(5))
			applyOrganDamage(1)

/obj/item/organ/heart/proc/can_stop() //Can the heart stop beating? Used to prevent bloodsucker hearts from failing under normal circumstances
	return TRUE

/obj/item/organ/heart/proc/handle_pulse()
	// Pulse mod starts out as just the chemical effect amount
	var/pulse_mod = owner.chem_effects[CE_PULSE]
	var/is_stable = owner.chem_effects[CE_STABLE] || (owner && HAS_TRAIT(owner, TRAIT_STABLEHEART))
		
	// If you have enough heart chemicals to be over 2, you're likely to take extra damage.
	if(pulse_mod > 2 && !is_stable)
		var/damage_chance = (pulse_mod - 2) ** 2
		if(prob(damage_chance))
			applyOrganDamage(1)
	
	// Now pulse mod is impacted by shock stage and other things too
	if(owner.shock_stage > SHOCK_STAGE_2)
		pulse_mod++
	if(owner.shock_stage > SHOCK_STAGE_5)
		pulse_mod++

	var/oxy = owner.get_blood_oxygenation()
	if(oxy < BLOOD_VOLUME_OKAY) //Brain wants us to get MOAR OXY
		pulse_mod++
	if(oxy < BLOOD_VOLUME_BAD) //MOAR
		pulse_mod++

	if(HAS_TRAIT(owner, TRAIT_FAKEDEATH) || owner.chem_effects[CE_NOPULSE])
		pulse = clamp(PULSE_NONE + pulse_mod, PULSE_NONE, PULSE_2FAST) //Pretend that we're dead. unlike actual death, can be inflienced by meds
		return

	//If heart is stopped, it isn't going to restart itself randomly.
	if(pulse == PULSE_NONE)
		return
	//And if it's beating, let's see if it should
	else
		var/should_stop = (owner.get_blood_circulation() < BLOOD_VOLUME_SURVIVE) && prob(25) //cardiovascular shock, not enough liquid to pump
		should_stop = should_stop || prob(max(0, owner.getBrainLoss() - owner.maxHealth * 0.75)) //brain failing to work heart properly
		should_stop = should_stop || ((pulse >= PULSE_THREADY) && prob(2)) //erratic heart patterns, usually caused by oxyloss
		if(should_stop && can_stop()) // The heart has stopped due to going into traumatic or cardiovascular shock.
			Stop()
			return

	// Pulse normally shouldn't go above PULSE_2FAST
	pulse = clamp(PULSE_NORM + pulse_mod, PULSE_SLOW, PULSE_2FAST)

	// If fibrillation, then it can be PULSE_THREADY
	var/fibrillation = (oxy <= BLOOD_VOLUME_SURVIVE) || (prob(5) && owner.shock_stage > SHOCK_STAGE_6)
	if(pulse && fibrillation)	//I SAID MOAR OXYGEN
		pulse = PULSE_THREADY

	// Stablising chemicals pull the heartbeat towards the center
	if(pulse != PULSE_NORM && is_stable)
		if(pulse > PULSE_NORM)
			pulse--
		else
			pulse++

/obj/item/organ/heart/proc/handle_heartbeat()
	if((pulse >= PULSE_2FAST) || (owner.shock_stage >= SHOCK_STAGE_1))
		//PULSE_THREADY - maximum value for pulse, currently it's 5.
		//High pulse value corresponds to a fast rate of heartbeat.
		//Divided by 2, otherwise it is too slow.
		var/rate = (PULSE_THREADY - pulse)/2
		if(owner.chem_effects[CE_PULSE] > 2)
			heartbeat++

		if(heartbeat >= rate)
			heartbeat = 0
		else
			heartbeat++
	
	if(!is_working())	//heart broke, stopped beating, death imminent
		if(owner.stat == CONSCIOUS)
			owner.visible_message("<span class='danger'><b>[owner]</b> clutches at [owner.p_their()] chest as if [owner.p_their()] heart is stopping!</span>")
		owner.set_heartattack(TRUE)
		failed = TRUE

	if(owner.client && heartbeat)
		failed = FALSE
		var/sound/slowbeat = sound('sound/health/slowbeat.ogg', repeat = TRUE)
		var/sound/fastbeat = sound('sound/health/fastbeat.ogg', repeat = TRUE)

		if(owner.InCritical() && beat != BEAT_SLOW)
			beat = BEAT_SLOW
			owner.playsound_local(get_turf(owner), slowbeat,40,0, channel = CHANNEL_HEARTBEAT)
		else if(!owner.InCritical() && beat == BEAT_SLOW)
			owner.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

		if(owner.jitteriness)
			if(owner.health > HEALTH_THRESHOLD_FULLCRIT && (!beat || beat == BEAT_SLOW))
				owner.playsound_local(get_turf(owner),fastbeat,40,0, channel = CHANNEL_HEARTBEAT)
				beat = BEAT_FAST
		else if(beat == BEAT_FAST)
			owner.stop_sound_channel(CHANNEL_HEARTBEAT)
			beat = BEAT_NONE

/obj/item/organ/heart/listen()
	if(CHECK_BITFIELD(status, ORGAN_ROBOTIC) && is_working())
		if(damage >= low_threshold)
			return "sputtering pump"
		else
			return "steady whirr of the pump"

	if(!pulse || (HAS_TRAIT(owner, TRAIT_FAKEDEATH)))
		return "no pulse"

	var/pulsesound = "normal"
	if(damage >= low_threshold)
		pulsesound = "irregular"

	switch(pulse)
		if(PULSE_SLOW)
			pulsesound = "slow"
		if(PULSE_FAST)
			pulsesound = "fast"
		if(PULSE_2FAST)
			pulsesound = "very fast"
		if(PULSE_THREADY)
			pulsesound = "extremely fast and faint"

	. = "[pulsesound] pulse"

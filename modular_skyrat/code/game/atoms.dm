// Trash that should not exist
/atom
	var/abandoned_code = FALSE

/atom/Initialize(mapload, ...)
	. = ..()
	if(abandoned_code)
		QDEL_IN(src, 1 SECONDS)

// Override this to impede examine messages etc
/atom/proc/on_examined_check()
	return TRUE

// Germ / infection stuff
/atom
	var/germ_level = GERM_LEVEL_AMBIENT

// Used to add or reduce germ level on an atom
/atom/proc/janitize(add_germs, minimum_germs = 0, maximum_germs = MAXIMUM_GERM_LEVEL)
	germ_level = clamp(germ_level + add_germs, minimum_germs, maximum_germs)

// Stumbling makes you fall like a jackass
/atom/Bumped(atom/movable/AM)
	. = ..()
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(!CanPass(C, get_turf(src)) && C.IsStumble())
			deal_with_stumbling_idiot(AM)

/atom/proc/deal_with_stumbling_idiot(mob/living/carbon/idiot)
	if(!idiot.IsStumble())
		return
	if(idiot.mind)
		//Deal with knockdown
		switch(idiot.mind.diceroll(STAT_DATUM(dex)))
			if(DICE_FAILURE)
				idiot.Immobilize(2 SECONDS)
				idiot.DefaultCombatKnockdown(rand(50, 100))
			if(DICE_CRIT_FAILURE)
				idiot.drop_all_held_items()
				idiot.Immobilize(5 SECONDS)
				idiot.DefaultCombatKnockdown(rand(100, 200))
			else
				idiot.DefaultCombatKnockdown(30)
		//Deal with damage
		switch(idiot.mind.diceroll(STAT_DATUM(end)))
			if(DICE_FAILURE)
				var/obj/item/bodypart/head = idiot.get_bodypart(BODY_ZONE_HEAD)
				if(head)
					head.receive_damage(MAX_STAT - GET_STAT_LEVEL(idiot, end))
				else
					idiot.take_bodypart_damage((MAX_STAT - GET_STAT_LEVEL(idiot, end)) * 2)
			if(DICE_CRIT_FAILURE)
				var/obj/item/bodypart/head = idiot.get_bodypart(BODY_ZONE_HEAD)
				if(head)
					head.receive_damage((MAX_STAT - GET_STAT_LEVEL(idiot, end)) * 2)
				else
					idiot.take_bodypart_damage((MAX_STAT - GET_STAT_LEVEL(idiot, end)) * 2)
			else
				idiot.take_bodypart_damage(rand(3, 5))
		idiot.Rapehead(6 SECONDS)
	else
		idiot.DefaultCombatKnockdown(30)
		idiot.take_bodypart_damage(rand(3, 5))
	var/smash_sound = pick('modular_skyrat/sound/gore/smash1.ogg',
						'modular_skyrat/sound/gore/smash2.ogg',
						'modular_skyrat/sound/gore/smash3.ogg')
	playsound(src, smash_sound, 75)
	sound_hint(src, idiot)

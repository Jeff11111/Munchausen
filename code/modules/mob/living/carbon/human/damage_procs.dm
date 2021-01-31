/mob/living/carbon/human/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE)
	// depending on the species, it will run the corresponding apply_damage code there
	return dna.species.apply_damage(damage, damagetype, def_zone, blocked, src, forced, wound_bonus, bare_wound_bonus, sharpness)

/mob/living/carbon/human/adjustOxyLoss(amount, updating_health, forced)
	. = ..()
	//if the amount is greater than 5, do an end diceroll to put this dude unconscious
	if((amount > 5) && !IsUnconscious() && mind && (mind.diceroll(STAT_DATUM(end)) <= DICE_FAILURE))
		to_chat(src, "<span class='userdanger'>I pass out.</span>")
		AdjustUnconscious(rand(1 SECONDS, 4 SECONDS))

//fists of steel
/datum/quirk/steel_fists
	name = "Fists of steel"
	desc = "<span class='info'>I am exceptionally good at unarmed combat. My punches hurt more.</span>"

/datum/quirk/steel_fists/add()
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = quirk_holder
		if(H && istype(H))
			H.dna.species.punchdamagehigh += 5
			H.dna.species.punchdamagelow += 5
			H.dna.species.punchstunthreshold += 5

//pain man good
//(turns masochist into a proper non-meme quirk)
/datum/quirk/maso
	name = "Masochism"
	desc = "<span class='info'>I am wired differently. Pain still hurts, but it hurts so good.</span>"
	mob_trait = TRAIT_PAINGOOD

//no pain no gain
/datum/quirk/painless
	name = "The Painless"
	desc = "<span class='info'>I can't feel pain at all, I am numb to everything.</span>"
	mob_trait = TRAIT_NOPAIN

//rich
/datum/quirk/wealthy
	name = "Wealthy"
	desc = "<span class='info'>I was born to awealthy family! I have savings to spare.</span>"

/datum/quirk/wealthy/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/card/id/id = H.get_idcard()
	if(id)
		var/datum/bank_account/B = id.registered_account
		B.adjust_money(2000)

/datum/quirk/gun1
	name = "Gun nut"
	desc = "<span class='info'>I know how to operate and use firearms, but I have much to learn.</span>"
	lose_text = "<span class='warning'>All I know of the fighting is lost to memories.</span>"

/datum/quirk/gun1/add()
	. = ..()
	var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(ranged && dexterity)
		ranged.level = clamp(ranged.level + 7, MIN_SKILL, MAX_SKILL) //enough to be a novice
		dexterity.level = clamp(dexterity.level + 1, MIN_STAT, MAX_STAT)

/datum/quirk/gun1/remove()
	. = ..()
	var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(ranged && dexterity)
		ranged.level = clamp(ranged.level - 7, MIN_SKILL, MAX_SKILL)
		dexterity.level = clamp(dexterity.level - 1, MIN_STAT, MAX_STAT)

/datum/quirk/gun2
	name = "Ranger"
	desc = "<span class='info'>I am skilled with firearms, able to use just about any like a natural.</span>"
	lose_text = "<span class='warning'>All I know of the fighting is lost to memories.</span>"

/datum/quirk/gun2/add()
	. = ..()
	var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)	
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(ranged && dexterity)
		ranged.level = clamp(ranged.level + 12, MIN_SKILL, MAX_SKILL)
		dexterity.level = clamp(dexterity.level + 2, MIN_STAT, MAX_STAT)

/datum/quirk/gun2/remove()
	. = ..()
	var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)	
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(ranged && dexterity)
		ranged.level = clamp(ranged.level - 12, MIN_SKILL, MAX_SKILL)
		dexterity.level = clamp(dexterity.level - 2, MIN_STAT, MAX_STAT)

/datum/quirk/gun3
	name = "Legendary Gunslinger"
	desc = "<span class='boldnotice'>I am the shooter born in heaven.</span>"
	lose_text = "<span class='warning'>All I know of the fighting is lost to memories.</span>"

/datum/quirk/gun3/add()
	. = ..()
	var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)	
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(ranged && dexterity)
		ranged.level = clamp(ranged.level + 20, MIN_SKILL, MAX_SKILL)
		dexterity.level = clamp(dexterity.level + 4, MIN_STAT, MAX_STAT)

/datum/quirk/gun3/remove()
	. = ..()
	var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)	
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(ranged && dexterity)
		ranged.level = clamp(ranged.level - 10, MIN_SKILL, MAX_SKILL) // -20 would set it to 0, so we set it to 10 and hope that
		dexterity.level = clamp(dexterity.level - 4, MIN_STAT, MAX_STAT) // whoever removed this quirk knows what they're doing.

/datum/quirk/melee1
	name = "Self defence trained"
	desc = "<span class='info'>I am trained in self defence.</span>"
	lose_text = "<span class='warning'>All I know of the fighting is lost to memories.</span>"

/datum/quirk/melee1/add()
	. = ..()
	var/datum/skills/melee = GET_SKILL(quirk_holder, melee)	
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	if(melee && strength)
		melee.level = clamp(melee.level + 7, MIN_SKILL, MAX_SKILL)
		strength.level = clamp(strength.level + 1, MIN_STAT, MAX_STAT)

/datum/quirk/melee1/remove()
	. = ..()
	var/datum/skills/melee = GET_SKILL(quirk_holder, melee)	
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	if(melee && strength)
		melee.level = clamp(melee.level - 7, MIN_SKILL, MAX_SKILL)
		strength.level = clamp(strength.level - 1, MIN_STAT, MAX_STAT)

/datum/quirk/melee2
	name = "Martial artist"
	desc = "<span class='info'>I am a skilled martial artist.</span>"
	lose_text = "<span class='warning'>All I know of the fighting is lost to memories.</span>"

/datum/quirk/melee2/add()
	. = ..()
	var/datum/skills/melee = GET_SKILL(quirk_holder, melee)	
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	if(melee && strength)
		melee.level = clamp(melee.level + 12, MIN_SKILL, MAX_SKILL)
		strength.level = clamp(strength.level + 2, MIN_STAT, MAX_STAT)

/datum/quirk/melee2/remove()
	. = ..()
	var/datum/skills/melee = GET_SKILL(quirk_holder, melee)	
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	if(melee && strength)
		melee.level = clamp(melee.level - 12, MIN_SKILL, MAX_SKILL)
		strength.level = clamp(strength.level - 2, MIN_STAT, MAX_STAT)

/datum/quirk/melee3
	name = "Blademaster"
	desc = "<span class='boldnotice'>I am the legendary fighter of the Void.</span>"
	lose_text = "<span class='warning'>All I know of the fighting is lost to memories.</span>"

/datum/quirk/melee3/add()
	. = ..()
	var/datum/skills/melee = GET_SKILL(quirk_holder, melee)
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	if(melee && strength)
		melee.level = clamp(melee.level + 20, MIN_SKILL, MAX_SKILL)
		strength.level = clamp(strength.level + 4, MIN_STAT, MAX_STAT)
	
/datum/quirk/melee3/remove()
	. = ..()
	var/datum/skills/melee = GET_SKILL(quirk_holder, melee)
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	if(melee && strength)
		melee.level = clamp(melee.level - 10, MIN_SKILL, MAX_SKILL) // -20 would set it to 0, so we set it to 10 and hope that
		strength.level = clamp(strength.level - 4, MIN_STAT, MAX_STAT) // whoever removed this quirk knows what they're doing.

/datum/quirk/body1
	name = "Fit"
	desc = "<span class='info'>I am fitter than most.</span>"
	lose_text = "<span class='warning'>A shame, my energy has waned.</span>"

/datum/quirk/body1/add()
	. = ..()	
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(strength && endurance && dexterity)
		strength.level = clamp(strength.level + 1, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level + 1, MIN_STAT, MAX_STAT)
		dexterity.level = clamp(dexterity.level + 1, MIN_STAT, MAX_STAT)

/datum/quirk/body1/remove()
	. = ..()	
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(strength && endurance && dexterity)
		strength.level = clamp(strength.level - 1, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level - 1, MIN_STAT, MAX_STAT)
		dexterity.level = clamp(dexterity.level - 1, MIN_STAT, MAX_STAT)

/datum/quirk/body2
	name = "Bodybuilder"
	desc = "<span class='info'>I am strong, my efforts have paid off in gains.</span>"
	lose_text = "<span class='warning'>A shame, body is weak.</span>"

/datum/quirk/body2/add()
	. = ..()
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	if(strength && endurance)
		strength.level = clamp(strength.level + 2, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level + 2, MIN_STAT, MAX_STAT)

/datum/quirk/body2/remove()
	. = ..()
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	if(strength && endurance)
		strength.level = clamp(strength.level - 2, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level - 2, MIN_STAT, MAX_STAT)

/datum/quirk/body3
	name = "Beast"
	desc = "<span class='boldnotice'>I am the beast I worship.</span>"
	lose_text = "<span class='warning'>Oh god! My body is weak!</span>"

/datum/quirk/body3/add()
	. = ..()
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	if(strength && endurance)
		strength.level = clamp(strength.level + 4, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level + 2, MIN_STAT, MAX_STAT)

/datum/quirk/body3/remove()
	. = ..()
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	if(strength && endurance)
		strength.level = clamp(strength.level - 4, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level - 2, MIN_STAT, MAX_STAT)

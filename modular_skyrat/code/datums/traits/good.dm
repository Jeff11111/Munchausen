//fists of steel
/datum/quirk/steel_fists
	name = "Fists of steel"
	desc = "<span class='info'>I am exceptionally good at unarmed combat. My punches hurt more.</span>"
	medical_condition = FALSE

/datum/quirk/steel_fists/on_spawn()
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

/datum/quirk/painless/on_spawn()
	. = ..()
	ADD_TRAIT(quirk_holder, TRAIT_NOPAIN, "quirk")
	ADD_TRAIT(quirk_holder, TRAIT_SCREWY_CHECKSELF, "quirk")

//rich
/datum/quirk/wealthy
	name = "Wealthy"
	desc = "<span class='info'>I was born to a wealthy family! I have savings to spare.</span>"
	medical_condition = FALSE

/datum/quirk/wealthy/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/card/id/id = H.get_idcard()
	if(id)
		var/datum/bank_account/B = id.registered_account
		B.adjust_money(2000)

//cum nuts
/datum/quirk/gun_nut
	name = "Gun nut"
	desc = "<span class='info'>I have decent knowledge of how to operate and use firearms.</span>"
	lose_text = "<span class='warning'>All I know of the fighting is lost to memories.</span>"
	medical_condition = FALSE

/datum/quirk/gun_nut/on_spawn()
	. = ..()
	if(quirk_holder)
		var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)
		var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
		if(ranged && dexterity)
			ranged.level = clamp(ranged.level + 7, MIN_SKILL, MAX_SKILL) //enough to be a novice
			dexterity.level = clamp(dexterity.level + 2, MIN_STAT, MAX_STAT)

/datum/quirk/gun_nut/remove()
	. = ..()
	var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(ranged && dexterity)
		ranged.level = clamp(ranged.level - 7, MIN_SKILL, MAX_SKILL)
		dexterity.level = clamp(dexterity.level - 2, MIN_STAT, MAX_STAT)

//self defense
/datum/quirk/self_defense
	name = "Self-defense trained"
	desc = "<span class='info'>I am trained in self defense.</span>"
	lose_text = "<span class='warning'>All I know of the fighting is lost to memories.</span>"
	medical_condition = FALSE

/datum/quirk/self_defense/on_spawn()
	. = ..()
	var/datum/skills/melee = GET_SKILL(quirk_holder, melee)	
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	if(melee && strength)
		melee.level = clamp(melee.level + 7, MIN_SKILL, MAX_SKILL)
		strength.level = clamp(strength.level + 1, MIN_STAT, MAX_STAT)

/datum/quirk/self_defense/remove()
	. = ..()
	var/datum/skills/melee = GET_SKILL(quirk_holder, melee)	
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	if(melee && strength)
		melee.level = clamp(melee.level - 7, MIN_SKILL, MAX_SKILL)
		strength.level = clamp(strength.level - 1, MIN_STAT, MAX_STAT)

//fitness
/datum/quirk/fitness
	name = "Fit"
	desc = "<span class='info'>I am fitter than most.</span>"
	lose_text = "<span class='warning'>A shame, my energy has waned.</span>"
	medical_condition = FALSE

/datum/quirk/fitness/on_spawn()
	. = ..()
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(strength && endurance && dexterity)
		strength.level = clamp(strength.level + 1, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level + 1, MIN_STAT, MAX_STAT)
		dexterity.level = clamp(dexterity.level + 1, MIN_STAT, MAX_STAT)

/datum/quirk/fitness/remove()
	. = ..()
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(strength && endurance && dexterity)
		strength.level = clamp(strength.level - 1, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level - 1, MIN_STAT, MAX_STAT)
		dexterity.level = clamp(dexterity.level - 1, MIN_STAT, MAX_STAT)

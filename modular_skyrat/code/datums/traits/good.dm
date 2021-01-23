//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones

//Ignore bad :)
/datum/quirk/apathetic
	name = "Apathetic"
	desc = "I just don't care as much as other people. That's nice to have in a place like this, I guess."
	value = 1
	mood_quirk = TRUE
	medical_record_text = "Patient was administered the Apathy Evaluation Scale but did not bother to complete it."

/datum/quirk/apathetic/add()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier = 0.5

/datum/quirk/apathetic/remove()
	if(quirk_holder)
		var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
		if(mood)
			mood.mood_modifier = 1 //Change this once/if species get their own mood modifiers.

//Dwarf
/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make me feel on top of the world. Whenever i'm drunk, i slowly recover from injuries."
	value = 2
	mob_trait = TRAIT_DRUNK_HEALING
	gain_text = "<span class='notice'>I feel like a drink would do me good.</span>"
	lose_text = "<span class='danger'>I no longer feel like drinking would ease my pain.</span>"
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."

//Know what is up with people etc
/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	value = 2
	mob_trait = TRAIT_EMPATH
	gain_text = "<span class='notice'>You feel in tune with those around you.</span>"
	lose_text = "<span class='danger'>You feel isolated from others.</span>"
	medical_record_text = "Patient is highly perceptive of and sensitive to social cues, or may possibly have ESP. Further testing needed."
	medical_condition = FALSE

//:)
/datum/quirk/jolly
	name = "Jolly"
	desc = "I love my life."
	value = 1
	mob_trait = TRAIT_JOLLY
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates constant euthymia irregular for environment. It's a bit much, to be honest."
	medical_condition = FALSE

/datum/quirk/jolly/on_process()
	if(prob(0.5))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "jolly", /datum/mood_event/jolly)

//Speedy gonzalez
/datum/quirk/quick_step
	name = "Quick Step"
	desc = "I walk with determined strides, and out-pace most people when walking."
	value = 2
	mob_trait = TRAIT_SPEEDY_STEP
	gain_text = "<span class='notice'>I feel determined. No time to lose.</span>"
	lose_text = "<span class='danger'>I feel less determined. What's the rush?</span>"
	medical_record_text = "Patient scored highly on racewalking tests."
	medical_condition = FALSE

//Medical man
/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "I know my body well, and can accurately assess the extent of my wounds."
	value = 2
	mob_trait = TRAIT_SELF_AWARE
	medical_record_text = "Patient demonstrates an uncanny knack for self-diagnosis."
	medical_condition = FALSE

//Locker man
/datum/quirk/skittish
	name = "Skittish"
	desc = "I can conceal yourself in danger. Middle-click a closed locker to jump into it, as long as you have access."
	value = 2
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Patient demonstrates a high aversion to danger and has described hiding in containers out of fear."
	medical_condition = FALSE

//More blood!
/datum/quirk/bloodpressure
	name = "Polycythemia vera"
	desc = "I have a treated form of Polycythemia vera that increases the total blood volume inside of me as well as the rate of replenishment."
	value = 2 //I honeslty dunno if this is a good trait? I just means you use more of medbays blood and make janitors madder, but you also regen blood a lil faster.
	mob_trait = TRAIT_HIGH_BLOOD
	gain_text = "<span class='notice'>I feel full of blood!</span>"
	lose_text = "<span class='notice'>I feel like my blood pressure went down.</span>"
	medical_record_text = "Patient's blood tests report an abnormal concentration of red blood cells in their bloodstream."

/datum/quirk/bloodpressure/add()
	quirk_holder.blood_ratio = 1.2
	quirk_holder.blood_volume += 150

/datum/quirk/bloodpressure/remove()
	if(quirk_holder)
		quirk_holder.blood_ratio = 1

//fists of steel
/datum/quirk/steel_fists
	name = "Fists of Steel"
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

/datum/quirk/steel_fists/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H && istype(H))
		H.dna.species.punchdamagehigh -= 5
		H.dna.species.punchdamagelow -= 5
		H.dna.species.punchstunthreshold -= 5
	. = ..()
	
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

/datum/quirk/painless/remove()
	REMOVE_TRAIT(quirk_holder, TRAIT_NOPAIN, "quirk")
	REMOVE_TRAIT(quirk_holder, TRAIT_SCREWY_CHECKSELF, "quirk")
	. = ..()
	
//rich
/datum/quirk/wealthy
	name = "Wealthy"
	desc = "<span class='info'>I was born to a wealthy family! I have savings to spare.</span>"
	medical_condition = FALSE

/datum/quirk/wealthy/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/card/id/id = H.get_idcard()
	if(id)
		var/datum/bank_account/B = id.registered_account
		B.adjust_money(3000)
	. = ..()

//cum nuts
/datum/quirk/gun_nut
	name = "Gun nut"
	desc = "<span class='info'>I have decent knowledge of how to operate and use firearms.</span>"
	lose_text = "<span class='warning'>All I know of the shooting is lost to memories.</span>"
	medical_condition = FALSE

/datum/quirk/gun_nut/on_spawn()
	. = ..()
	if(quirk_holder)
		var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)
		var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
		if(ranged && dexterity)
			ranged.level = clamp(ranged.level + 7, MIN_SKILL, MAX_SKILL) //enough to be a novice
			dexterity.level = clamp(dexterity.level + 3, MIN_STAT, MAX_STAT)

/datum/quirk/gun_nut/remove()
	var/datum/skills/ranged = GET_SKILL(quirk_holder, ranged)
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(ranged && dexterity)
		ranged.level = clamp(ranged.level - 7, MIN_SKILL, MAX_SKILL)
		dexterity.level = clamp(dexterity.level - 3, MIN_STAT, MAX_STAT)
	. = ..()

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
		strength.level = clamp(strength.level + 3, MIN_STAT, MAX_STAT)

/datum/quirk/self_defense/remove()
	var/datum/skills/melee = GET_SKILL(quirk_holder, melee)	
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	if(melee && strength)
		melee.level = clamp(melee.level - 7, MIN_SKILL, MAX_SKILL)
		strength.level = clamp(strength.level - 3, MIN_STAT, MAX_STAT)
	. = ..()

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
		strength.level = clamp(strength.level + 2, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level + 3, MIN_STAT, MAX_STAT)
		dexterity.level = clamp(dexterity.level + 2, MIN_STAT, MAX_STAT)

/datum/quirk/fitness/remove()
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	var/datum/stats/dexterity = GET_STAT(quirk_holder, dex)
	if(strength && endurance && dexterity)
		strength.level = clamp(strength.level - 2, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level - 3, MIN_STAT, MAX_STAT)
		dexterity.level = clamp(dexterity.level - 2, MIN_STAT, MAX_STAT)
	. = ..()

//long arms
/datum/quirk/longarms
	name = "Long Arms"
	desc = "<span class='info'>I have unusually long arms and can reach into my backpack while wearing it.</span>"
	lose_text = "<span class='warning'>My arms shorten.</span>"
	medical_condition = TRUE
	mob_trait = TRAIT_LONGARMS

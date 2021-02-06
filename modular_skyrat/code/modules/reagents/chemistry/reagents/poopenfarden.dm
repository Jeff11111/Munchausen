//SHIT
/datum/reagent/consumable/shit
	name = "shit"
	color = "#643200"
	taste_description = "expired chocolate"
	pH = 6.5

/datum/reagent/consumable/shit/reaction_mob(mob/living/M, method, reac_volume)
	. = ..()
	M.adjust_disgust(10)
	M.ForceContractDisease(/datum/disease/appendicitis)

/datum/reagent/consumable/shit/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_disgust(1)

//PISS
/datum/reagent/consumable/piss
	name = "piss"
	color = COLOR_YELLOW
	taste_description = "expired beer"
	pH = 5

/datum/reagent/consumable/piss/reaction_mob(mob/living/M, method, reac_volume)
	. = ..()
	M.adjust_disgust(10)
	M.adjust_hydration(-5)

/datum/reagent/consumable/piss/on_mob_life(mob/living/carbon/M)
	. = ..()
	M.adjust_disgust(1)
	M.adjust_hydration(-3)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		var/obj/item/organ/kidneys/kidneys = C.getorganslot(ORGAN_SLOT_KIDNEYS)
		if(kidneys)
			kidneys.add_toxins(pick(1,2))

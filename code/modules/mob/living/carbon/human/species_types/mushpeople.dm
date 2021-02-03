/datum/species/mush //mush mush codecuck
	name = "Anthromorphic Mushroom"
	id = "mush"
	mutant_bodyparts = list("caps" = "Round")

	fixed_mut_color = "DBBF92"
	hair_color = "FF4B19" //cap color, spot color uses eye color
	nojumpsuit = TRUE

	say_mod = "poofs" //what does a mushroom sound like
	species_traits = list(MUTCOLORS, NOEYES, NO_UNDERWEAR,NOGENITALS,NOAROUSAL,HAS_FLESH)
	inherent_traits = list(TRAIT_NOBREATH)
	speedmod = 1.5 //faster than golems but not by much

	punchdamagelow = 2
	punchdamagehigh = 12 //still better than humans
	punchstunthreshold = 10

	no_equip = list(SLOT_WEAR_MASK, SLOT_WEAR_SUIT, SLOT_GLOVES, SLOT_SHOES, SLOT_W_UNIFORM)

	burnmod = 1.25
	heatmod = 1.5

	bloodtypes = list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "SPOR")
	exotic_bloodtype = "SPOR"
	exotic_blood_color = BLOOD_COLOR_MUSHROOM
	languagewhitelist = list("Mushroom")

/datum/species/mush/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	//H.grant_language(/datum/language/mushroom) //pomf pomf
	species_language_holder = /datum/language_holder/mushroom
/*
/datum/species/mush/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.grant_language(/datum/language/mushroom) //pomf pomf SKYRAT CHANGE= We have an additional language option for this
*/

/datum/species/mush/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	if(!ishuman(C))
		return
	var/mob/living/carbon/human/H = C
	if(!H.dna.features["caps"])
		H.dna.features["caps"] = "Round"
		handle_mutant_bodyparts(H)
	H.faction |= "mushroom"

/datum/species/mush/on_species_loss(mob/living/carbon/C)
	. = ..()
	UnregisterSignal(C, COMSIG_MOB_ON_NEW_MIND)
	C.faction -= "mushroom"

/datum/species/mush/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/plantbgone/weedkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
	return ..()

/datum/species/mush/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	forced_colour = FALSE
	. = ..()

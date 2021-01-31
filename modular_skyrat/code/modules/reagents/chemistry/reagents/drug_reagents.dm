//Pogchungus
/datum/reagent/drug/methamphetamine/on_mob_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.add_chem_effect(CE_PULSE, 2)

/datum/reagent/drug/methamphetamine/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.remove_chem_effect(CE_PULSE, 2)

/datum/reagent/drug/bath_salts/on_mob_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.add_chem_effect(CE_PULSE, 2)

/datum/reagent/drug/bath_salts/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.remove_chem_effect(CE_PULSE, 2)

/datum/reagent/drug/happiness/on_mob_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.add_chem_effect(CE_PULSE, -1)

/datum/reagent/drug/happiness/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.remove_chem_effect(CE_PULSE, -1)

/datum/reagent/drug/aphrodisiac/on_mob_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.add_chem_effect(CE_PULSE, 1)

/datum/reagent/drug/aphrodisiac/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.remove_chem_effect(CE_PULSE, 1)

/datum/reagent/drug/aphrodisiacplus/on_mob_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.add_chem_effect(CE_PULSE, 2)

/datum/reagent/drug/aphrodisiacplus/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.remove_chem_effect(CE_PULSE, 2)

/datum/reagent/drug/anaphrodisiac/on_mob_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.add_chem_effect(CE_PULSE, -1)

/datum/reagent/drug/anaphrodisiac/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.remove_chem_effect(CE_PULSE, -1)

/datum/reagent/drug/anaphrodisiacplus/on_mob_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.add_chem_effect(CE_PULSE, -2)

/datum/reagent/drug/anaphrodisiacplus/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.remove_chem_effect(CE_PULSE, -2)

/datum/reagent/drug/space_drugs/on_mob_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.add_chem_effect(CE_PULSE, -1)

/datum/reagent/drug/space_drugs/on_mob_end_metabolize(mob/living/L)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		C.remove_chem_effect(CE_PULSE, -1)

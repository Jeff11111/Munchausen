/obj/item/organ/genital/womb
	name = "womb"
	desc = "A female reproductive organ."
	icon = 'icons/obj/genitals/vagina.dmi'
	icon_state = "womb"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_WOMB
	genital_flags = GENITAL_INTERNAL|GENITAL_FUID_PRODUCTION
	fluid_id = /datum/reagent/consumable/femcum
	linked_organ_slot = ORGAN_SLOT_VAGINA

/obj/item/organ/genital/womb/get_features(mob/living/carbon/human/H)
	var/datum/dna/D = H.dna
	var/datum/species/S = D.species
	if(S)
		//commies stole the means of reproduction again idk
		if(!S.has_whopper)
			Remove()
			qdel(src)
			return
	if(D.features["cyber_womb"])
		status |= ORGAN_ROBOTIC
		status &= ~ORGAN_ORGANIC

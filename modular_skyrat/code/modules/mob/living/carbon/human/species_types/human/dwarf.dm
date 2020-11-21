//this is stupid
/datum/species/dwarf/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.AddElement(/datum/element/mob_holder, null, null)

/datum/species/dwarf/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.RemoveElement(/datum/element/mob_holder)

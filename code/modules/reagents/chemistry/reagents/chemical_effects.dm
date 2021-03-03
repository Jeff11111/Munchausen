//Add a chemical effect
/mob/living/carbon/proc/add_chem_effect(effect, magnitude = 1, source)
	if(effect in chem_effects)
		chem_effects[effect] += magnitude
	else
		chem_effects[effect] = magnitude
	if(source)
		if(chem_effect_sources[source])
			chem_effect_sources[source] += magnitude
		else
			chem_effect_sources[source] = magnitude

/mob/living/carbon/proc/add_up_to_chem_effect(effect, magnitude = 1, source)
	if(effect in chem_effects)
		chem_effects[effect] = max(magnitude, chem_effects[effect])
	else
		chem_effects[effect] = magnitude
	if(source)
		if(chem_effect_sources[source])
			chem_effect_sources[source] += magnitude
		else
			chem_effect_sources[source] = magnitude

/mob/living/carbon/proc/remove_chem_effect(effect, magnitude = 1, source)
	if(effect in chem_effects)
		chem_effects[effect] = max(0, chem_effects[effect] - magnitude)
	if(source)
		if(chem_effect_sources[source])
			chem_effect_sources[source] = max(0, chem_effect_sources[source] - magnitude)
		else
			chem_effect_sources[source] = magnitude

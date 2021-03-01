/obj/item/organ/kidneys
	name = "kidneys"
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "kidneys"
	desc = "You have to be kidneying me."
	gender = PLURAL
	slot = ORGAN_SLOT_KIDNEYS
	zone = BODY_ZONE_CHEST
	low_threshold = 25
	high_threshold = 45
	maxHealth = 70
	//Reagents associated with the damage they deal when metabolized, if the kidney is damaged
	var/static/list/bad_reagents = list(
		/datum/reagent/consumable/coffee = 0.1,
	)
	relative_size = 8
	//Kidneys work as secondary toxin sacks
	var/tox_dam = 0 //How much toxin damage we have right now
	var/max_tox_dam = 50 //Maximum toxin we can achieve
	var/extra_hydration_loss = 0

/obj/item/organ/kidneys/get_pain()
	var/damage_mult = 1
	//Robotic organs do not feel pain, simply for balancing reasons
	//Thus lowering the shock of IPCs and other synths is easier, as
	//they don't have many painkillers
	if(CHECK_BITFIELD(status, ORGAN_ROBOTIC))
		return 0
	//Cut organs don't feel pain
	if(CHECK_BITFIELD(organ_flags, ORGAN_CUT_AWAY))
		return 0
	//Failing organs always cause maxHealth pain
	if(CHECK_BITFIELD(organ_flags, ORGAN_FAILING | ORGAN_DEAD))
		return (maxHealth + get_toxins())
	return ((get_toxins() * 0.75 + damage) * damage_mult * pain_multiplier)

//Returns a percentage value for use by GetToxloss().
/obj/item/organ/kidneys/proc/get_toxins()
	if(!is_working())
		return max_tox_dam
	return round((tox_dam/owner.maxHealth)*max_tox_dam)

/obj/item/organ/kidneys/proc/remove_toxins(amount)
	var/last_tox = tox_dam
	tox_dam = min(max_tox_dam, max(0, tox_dam - amount))
	return (amount - (last_tox - tox_dam))

/obj/item/organ/kidneys/proc/add_toxins(amount)
	var/last_tox = tox_dam
	tox_dam = min(max_tox_dam, max(0, tox_dam + amount))
	return (amount - (tox_dam - last_tox))

/obj/item/organ/kidneys/proc/get_adrenaline_multiplier()
	var/multiplier = 1
	if(is_broken())
		multiplier = 0
	else if(is_bruised())
		multiplier *= (damage/maxHealth)
	if(owner?.chem_effects[CE_BLOODRESTORE])
		multiplier *= min(2, owner.chem_effects[CE_BLOODRESTORE])
	return multiplier

/obj/item/organ/kidneys/on_life()
	. = ..()
	for(var/i in bad_reagents)
		var/bad = owner.reagents.get_reagent_amount(i)
		if(bad)
			if(damage >= low_threshold)
				owner.adjustToxLoss(bad_reagents[i])
			else if(damage >= high_threshold)
				owner.adjustToxLoss(bad_reagents[i] * 3)

	//If your kidneys aren't working, your body's going to have a hard time cleaning your blood.
	if(!owner.chem_effects[CE_ANTITOX])
		if(prob(33))
			if(damage >= high_threshold)
				owner.adjustToxLoss(0.5)
			if(organ_flags & ORGAN_FAILING)
				owner.adjustToxLoss(1)

/obj/item/organ/kidneys/proc/get_hydration_loss()
	if(damage >= low_threshold)
		if(!is_working())
			return (2 + extra_hydration_loss)
		return (1 + (1 * damage/maxHealth) + extra_hydration_loss)
	else
		return (1 + extra_hydration_loss)

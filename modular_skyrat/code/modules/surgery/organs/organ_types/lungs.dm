#define LUNGS_MAX_HEALTH 70

/obj/item/organ/lungs
	name = "lungs"
	desc = "Looking at them makes you start manual breathing."
	icon_state = "lungs"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	gender = PLURAL
	w_class = WEIGHT_CLASS_NORMAL

	var/failed = FALSE
	var/operated = FALSE	//whether we can still have our damages fixed through surgery

	//health
	maxHealth = LUNGS_MAX_HEALTH

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	high_threshold = 0.45 * LUNGS_MAX_HEALTH	//threshold at 45
	low_threshold = 0.25 * LUNGS_MAX_HEALTH	//threshold at 25

	high_threshold_passed = "<span class='warning'>You feel some sort of constriction around your chest as your breathing becomes shallow and rapid.</span>"
	now_fixed = "<span class='warning'>Your lungs seem to once again be able to hold air.</span>"
	high_threshold_cleared = "<span class='info'>The constriction around your chest loosens as your breathing calms down.</span>"

	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/salbutamol = 5)

	//Breath damage

	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 50 // Too much of a good thing, in kPa as well.
	var/safe_nitro_min = 0
	var/safe_nitro_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_toxins_min = 0
	var/safe_toxins_max = MOLES_GAS_VISIBLE
	var/SA_para_min = 1 //Sleeping agent
	var/SA_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas
	var/gas_stimulation_min = 0.002 //Nitryl and Stimulum

	var/oxy_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/oxy_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/oxy_damage_type = OXY
	var/nitro_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/nitro_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/nitro_damage_type = OXY
	var/co2_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/co2_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/co2_damage_type = OXY
	var/tox_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/tox_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/tox_damage_type = TOX

	var/cold_message = "your face freezing and an icicle forming"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_type = BURN

	var/hot_message = "your face burning and a searing heat"
	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 1000
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_type = BURN

	var/crit_stabilizing_reagent = /datum/reagent/medicine/epinephrine

	var/active_breathing = 1
	var/breathing = 0
	var/breath_fail_ratio = 0 // How badly they failed a breath. Higher is worse.
	var/last_successful_breath
	var/oxygen_deprivation = 0
	var/last_int_pressure = ONE_ATMOSPHERE / (CELL_VOLUME/BREATH_VOLUME)
	var/last_ext_pressure = ONE_ATMOSPHERE
	var/max_ext_pressure_diff = ((ONE_ATMOSPHERE/100) * 60)
	var/max_int_pressure_diff = ((ONE_ATMOSPHERE/100) * 60) / (CELL_VOLUME/BREATH_VOLUME)
	relative_size = 30 //Chest has many organs, we need to cut some chances off to round up to 100

/obj/item/organ/lungs/proc/remove_oxygen_deprivation(amount)
	var/last_suffocation = oxygen_deprivation
	oxygen_deprivation = min(owner.maxHealth,max(0,oxygen_deprivation - amount))
	return -(oxygen_deprivation - last_suffocation)

/obj/item/organ/lungs/proc/add_oxygen_deprivation(amount)
	var/last_suffocation = oxygen_deprivation
	oxygen_deprivation = min(owner.maxHealth,max(0,oxygen_deprivation + amount))
	return (oxygen_deprivation - last_suffocation)

// Returns a percentage value for use by GetOxyloss().
/obj/item/organ/lungs/proc/get_oxygen_deprivation()
	if(is_broken())
		return 100
	return round((oxygen_deprivation/owner.maxHealth)*100)

/obj/item/organ/lungs/on_life()
	. = ..()
	if(germ_level > INFECTION_LEVEL_ONE && active_breathing)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised() && !owner.is_asystole())
		if(prob(2))
			if(active_breathing)
				owner.visible_message(
					"<b>[owner]</b> coughs up blood!",
					"<span class='warning'>You cough up blood!</span>",
					"You hear someone coughing!",
				)
			else
				var/obj/item/bodypart/parent = owner.get_bodypart(zone)
				owner.visible_message(
					"blood drips from <b>[owner]'s</b> [parent.name]!",
				)
			owner.bleed(2)
		if(prob(4))
			if(active_breathing)
				owner.visible_message(
					"<b>[owner]</b> gasps for air!",
					"<span class='danger'>You can't breathe!</span>",
					"You hear someone gasp for air!",
				)
			else
				to_chat(owner, "<span class='userdanger'>You're having trouble getting enough air!</span>")

			owner.losebreath += round(damage/2)

/obj/item/organ/lungs/proc/rupture()
	if(!owner)
		return FALSE
	
	var/obj/item/bodypart/parent = owner.get_bodypart(zone)
	if(istype(parent) && !is_bruised())
		owner.custom_pain("You feel a stabbing pain in your [parent.name]!", 30, TRUE, affecting = parent)
	if(!is_broken())
		applyOrganDamage(20) //le collapse

//Exposure to extreme pressures can rupture lungs
/obj/item/organ/lungs/proc/check_rupturing(breath_pressure, datum/gas_mixture/enviro)
	if(!max_int_pressure_diff && !max_ext_pressure_diff)
		return FALSE
	
	//Get external pressure
	var/ext_pressure = enviro?.return_pressure()

	//Don't explode the lungs if we are in a space suit
	ext_pressure = owner.calculate_affecting_pressure(ext_pressure)

	//Get the diffs
	var/int_pressure_diff = abs(last_int_pressure - breath_pressure)
	var/ext_pressure_diff = abs(last_ext_pressure - ext_pressure)

	//If the diffs are great enough, lung go boom
	if(int_pressure_diff > max_int_pressure_diff && ext_pressure_diff > max_ext_pressure_diff)
		var/lung_rupture_prob =  (is_robotic() ? 30 : 60) //Robotic lungs are less likely to rupture.
		if(!is_broken() && prob(lung_rupture_prob)) //Only rupture if NOT already ruptured
			rupture()

//TODO: lung health affects lung function
/obj/item/organ/lungs/onDamage(damage_mod) //damage might be too low atm.
	var/cached_damage = damage
	if(maxHealth == INFINITY)
		return
	if(cached_damage+damage_mod <= 0)
		cached_damage = 0
		return

	cached_damage += damage_mod
	if((cached_damage/maxHealth) > 1)
		to_chat(owner, "<span class='userdanger'>You feel your lungs collapse within your chest as you gasp for air, unable to inflate them anymore!</span>")
		if(!owner.nervous_system_failure())
			owner.emote("gasp")
		SSblackbox.record_feedback("tally", "fermi_chem", 1, "Lungs lost")
		//qdel(src) - Handled elsewhere for now.
	else if((cached_damage / maxHealth) > 0.75)
		to_chat(owner, "<span class='warning'>It's getting really hard to breathe!!</span>")
		if(!owner.nervous_system_failure())
			owner.emote("gasp")
		owner.Dizzy(3)
	else if((cached_damage / maxHealth) > 0.5)
		owner.Dizzy(2)
		to_chat(owner, "<span class='notice'>Your chest is really starting to hurt.</span>")
		if(!owner.nervous_system_failure())
			owner.emote("cough")
	else if((cached_damage / maxHealth) > 0.2)
		to_chat(owner, "<span class='notice'>You feel an ache within your chest.</span>")
		if(!owner.nervous_system_failure())
			owner.emote("cough")
		owner.Dizzy(1)

/obj/item/organ/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
	//TODO: add lung damage = less oxygen gains
	var/breathModifier = (5-(5*(damage/maxHealth)/2)) //range 2.5 - 5
	if((H.status_flags & GODMODE))
		return
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		return

	if(!safe_oxygen_min && !safe_nitro_min && !safe_toxins_min && !safe_co2_min)
		H.failed_last_breath = FALSE
		if(!H.InFullShock())
			H.adjustOxyLoss(-breathModifier) //More damaged lungs = slower oxy rate up to a factor of half
		H.clear_alert("not_enough_oxy")
		return TRUE
	
	var/breath_pressure = breath?.return_pressure()

	//Check for rupture before we update the last_int_pressure and last_ext_pressure variables
	var/datum/gas_mixture/environment = owner.loc.return_air()
	check_rupturing(breath_pressure, environment)

	last_ext_pressure = environment?.return_pressure()
	last_int_pressure = breath_pressure

	if((!breath || (breath?.total_moles() == 0)) && (safe_co2_min || safe_nitro_min || safe_oxygen_min || safe_toxins_min))
		if(H.reagents.has_reagent(crit_stabilizing_reagent))
			return
		
		if(!H.InFullShock())
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else if(!HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
			H.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		H.failed_last_breath = TRUE
		if(safe_oxygen_min)
			H.throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		else if(safe_toxins_min)
			H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else if(safe_co2_min)
			H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else if(safe_nitro_min)
			H.throw_alert("not_enough_nitro", /obj/screen/alert/not_enough_nitro)
		return FALSE

	var/gas_breathed = 0
	
	var/list/breath_gases = breath?.gases
	if(length(breath_gases))
		//Partial pressures in our breath
		var/O2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen])+(8*breath.get_breath_partial_pressure(breath_gases[/datum/gas/pluoxium]))
		var/N2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrogen])
		var/Toxins_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma])
		var/CO2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide])


		//-- OXY --//

		//Too much oxygen! //Yes, some species may not like it.
		if(safe_oxygen_max)
			if((O2_pp > safe_oxygen_max) && !(oxy_damage_type == OXY) && !(safe_oxygen_max == 0)) //SKYRAT CHANGE - basically fixes this 'if' cause it'd never be true
				var/ratio = (breath_gases[/datum/gas/oxygen]/safe_oxygen_max) * 10
				H.apply_damage_type(clamp(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type)
				H.throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)
				//SKYRAT CHANGES - visual cue to choking this way
				if(prob(30))
					H.emote("cough")
				//END OF SKYRAT CHANGES

			else if((O2_pp > safe_oxygen_max) && !(safe_oxygen_max == 0)) //Why yes, this is like too much CO2 and spahget. Dirty lizards.
				if(!H.o2overloadtime)
					H.o2overloadtime = world.time
				else if(world.time - H.o2overloadtime > 120)
					H.Dizzy(10)	// better than a minute of you're fucked KO, but certainly a wake up call. Honk.
					H.adjustOxyLoss(3)
					if(world.time - H.o2overloadtime > 300)
						H.adjustOxyLoss(8)
				if(prob(20))
					H.emote("cough")
				H.throw_alert("too_much_oxy", /obj/screen/alert/too_much_oxy)

			else
				H.o2overloadtime = 0
				H.clear_alert("too_much_oxy")

		//Too little oxygen!
		if(safe_oxygen_min)
			if(O2_pp < safe_oxygen_min)
				gas_breathed = handle_too_little_breath(H, O2_pp, safe_oxygen_min, breath_gases[/datum/gas/oxygen])
				H.throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
			else
				H.failed_last_breath = FALSE
				if(!H.InFullShock())
					H.adjustOxyLoss(-breathModifier) //More damaged lungs = slower oxy rate up to a factor of half
				gas_breathed = breath_gases[/datum/gas/oxygen]
				H.clear_alert("not_enough_oxy")

		//Exhale
		breath_gases[/datum/gas/oxygen] -= gas_breathed
		breath_gases[/datum/gas/carbon_dioxide] += gas_breathed
		gas_breathed = 0

		//-- Nitrogen --//

		//Too much nitrogen!
		if(safe_nitro_max)
			if(N2_pp > safe_nitro_max && !(safe_nitro_max == 0))
				var/ratio = (breath_gases[/datum/gas/nitrogen]/safe_nitro_max) * 10
				H.apply_damage_type(clamp(ratio, nitro_breath_dam_min, nitro_breath_dam_max), nitro_damage_type)
				H.throw_alert("too_much_nitro", /obj/screen/alert/too_much_nitro)
				H.losebreath += 2
			else
				H.clear_alert("too_much_nitro")

		//Too little nitrogen!
		if(safe_nitro_min)
			if(N2_pp < safe_nitro_min)
				gas_breathed = handle_too_little_breath(H, N2_pp, safe_nitro_min, breath_gases[/datum/gas/nitrogen])
				H.throw_alert("nitro", /obj/screen/alert/not_enough_nitro)
			else
				H.failed_last_breath = FALSE
				if(!H.InFullShock())
					H.adjustOxyLoss(-breathModifier)
				gas_breathed = breath_gases[/datum/gas/nitrogen]
				H.clear_alert("nitro")

		//Exhale
		breath_gases[/datum/gas/nitrogen] -= gas_breathed
		breath_gases[/datum/gas/carbon_dioxide] += gas_breathed
		gas_breathed = 0

		//-- CO2 --//

		//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
		if(safe_co2_max)
			if(CO2_pp > safe_co2_max && !(safe_co2_max == 0))
				if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
					H.co2overloadtime = world.time
				else if(world.time - H.co2overloadtime > 120)
					H.Unconscious(60)
					H.apply_damage_type(3, co2_damage_type) // Lets hurt em a little, let them know we mean business
					if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
						H.apply_damage_type(8, co2_damage_type)
					H.throw_alert("too_much_co2", /obj/screen/alert/too_much_co2)
				if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
					H.emote("cough")

			else
				H.co2overloadtime = 0
				H.clear_alert("too_much_co2")

		//Too little CO2!
		if(safe_co2_min)
			if(CO2_pp < safe_co2_min)
				gas_breathed = handle_too_little_breath(H, CO2_pp, safe_co2_min, breath_gases[/datum/gas/carbon_dioxide])
				H.throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
			else
				H.failed_last_breath = FALSE
				if(!H.InFullShock())
					H.adjustOxyLoss(-breathModifier)
				gas_breathed = breath_gases[/datum/gas/carbon_dioxide]
				H.clear_alert("not_enough_co2")

		//Exhale
		breath_gases[/datum/gas/carbon_dioxide] -= gas_breathed
		breath_gases[/datum/gas/oxygen] += gas_breathed
		gas_breathed = 0


		//-- TOX --//

		//Too much toxins!
		if(safe_toxins_max)
			if(Toxins_pp > safe_toxins_max && !(safe_toxins_max == 0))
				var/ratio = (breath_gases[/datum/gas/plasma]/safe_toxins_max) * 10
				H.apply_damage_type(clamp(ratio, tox_breath_dam_min, tox_breath_dam_max), tox_damage_type)
				H.throw_alert("too_much_tox", /obj/screen/alert/too_much_tox)
			else
				H.clear_alert("too_much_tox")


		//Too little toxins!
		if(safe_toxins_min)
			if(Toxins_pp < safe_toxins_min)
				gas_breathed = handle_too_little_breath(H, Toxins_pp, safe_toxins_min, breath_gases[/datum/gas/plasma])
				H.throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
			else
				H.failed_last_breath = FALSE
				if(!H.InFullShock())
					H.adjustOxyLoss(-breathModifier)
				gas_breathed = breath_gases[/datum/gas/plasma]
				H.clear_alert("not_enough_tox")

		//Exhale
		breath_gases[/datum/gas/plasma] -= gas_breathed
		breath_gases[/datum/gas/carbon_dioxide] += gas_breathed
		gas_breathed = 0


		//-- TRACES --//

		// N2O

		var/SA_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrous_oxide])
		if(SA_pp > SA_para_min) // Enough to make us stunned for a bit
			H.Unconscious(60) // 60 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.Sleeping(max(H.AmountSleeping() + 40, 200))
			if(!(H.chem_effects[CE_PAINKILLER] >= 100))
				H.add_chem_effect(CE_PAINKILLER, 100)
		else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))
				SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
		else
			if(H.chem_effects["n2o"])
				H.remove_chem_effect(CE_PAINKILLER, H.chem_effects["n2o"])
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")

		// BZ

			var/bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz])
			if(bz_pp > BZ_trip_balls_min)
				H.hallucination += 10
				H.reagents.add_reagent(/datum/reagent/bz_metabolites,5)
				if(prob(33))
					H.adjustBrainLoss(3, 150)

			else if(bz_pp > 0.01)
				H.hallucination += 5
				H.reagents.add_reagent(/datum/reagent/bz_metabolites,1)


		// Tritium
			var/trit_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/tritium])
			if (trit_pp > 50)
				H.radiation += trit_pp/2 //If you're breathing in half an atmosphere of radioactive gas, you fucked up.
			else
				H.radiation += trit_pp/10

		// Nitryl
			var/nitryl_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitryl])
			if (prob(nitryl_pp))
				to_chat(H, "<span class='alert'>Your mouth feels like it's burning!</span>")
			if (nitryl_pp >40)
				H.emote("gasp")
				H.adjustFireLoss(10)
				if (prob(nitryl_pp/2))
					to_chat(H, "<span class='alert'>Your throat closes up!</span>")
					H.silent = max(H.silent, 3)
			else
				H.adjustFireLoss(nitryl_pp/4)
			gas_breathed = breath_gases[/datum/gas/nitryl]
			if (gas_breathed > gas_stimulation_min)
				H.reagents.add_reagent(/datum/reagent/nitryl,1)

			breath_gases[/datum/gas/nitryl]-=gas_breathed

		// Stimulum
			gas_breathed = breath_gases[/datum/gas/stimulum]
			if (gas_breathed > gas_stimulation_min)
				var/existing = H.reagents.get_reagent_amount(/datum/reagent/stimulum)
				H.reagents.add_reagent(/datum/reagent/stimulum, max(0, 5 - existing))
			breath_gases[/datum/gas/stimulum]-=gas_breathed

		// Miasma
			if (breath_gases[/datum/gas/miasma])
				var/miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma])
				if(miasma_pp > MINIMUM_MOLES_DELTA_TO_MOVE)

					//Miasma sickness
					//SKYRAT CHANGES, MODIFIES MIASMA BALANCE
					if(miasma_pp >= 5 && prob(0.05 * miasma_pp))
					//END OF SKYRAT CHANGES, MODIFIES MIASMA BALANCE
						var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(TRUE, 2,3)
						miasma_disease.name = "Unknown"
						miasma_disease.try_infect(owner)

					// Miasma side effects
					switch(miasma_pp)
						//SKYRAT CHANGES, MODIFIES MIASMA BALANCE
						if(0.5 to 5)
						//END OF SKYRAT CHANGES, MODIFIES MIASMA BALANCE
							// At lower pp, give out a little warning
							SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")
							if(prob(5))
								to_chat(owner, "<span class='notice'>There is an unpleasant smell in the air.</span>")
						if(5 to 15)
							//At somewhat higher pp, warning becomes more obvious
							if(prob(15))
								to_chat(owner, "<span class='warning'>You smell something horribly decayed inside this room.</span>")
								SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/bad_smell)
						if(15 to 30)
							//Small chance to vomit. By now, people have internals on anyway
							if(prob(5))
								to_chat(owner, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
								SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
								owner.vomit()
						if(30 to INFINITY)
							//Higher chance to vomit. Let the horror start
							if(prob(15))
								to_chat(owner, "<span class='warning'>The stench of rotting carcasses is unbearable!</span>")
								SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "smell", /datum/mood_event/disgust/nauseating_stench)
								owner.vomit()
						else
							SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")

					// In a full miasma atmosphere with 101.34 pKa, about 10 disgust per breath, is pretty low compared to threshholds
					// Then again, this is a purely hypothetical scenario and hardly reachable
					owner.adjust_disgust(0.1 * miasma_pp)

					breath_gases[/datum/gas/miasma]-=gas_breathed

			// Clear out moods when no miasma at all
			else
				SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "smell")

			handle_breath_temperature(breath, H)
			GAS_GARBAGE_COLLECT(breath.gases)
	return TRUE


/obj/item/organ/lungs/proc/handle_too_little_breath(mob/living/carbon/human/H = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return FALSE
	
	if(prob(15) && !owner.nervous_system_failure())
		if(!owner.is_asystole())
			if(active_breathing)
				owner.emote("gasp")
		else
			owner.emote(pick("shiver","twitch"))
	
	if(breath_pp > 0)
		var/ratio = safe_breath_min/breath_pp
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
		H.failed_last_breath = TRUE
		. = true_pp*ratio/6
	else
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.failed_last_breath = TRUE

/obj/item/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	var/breath_temperature = breath.temperature

	if(!HAS_TRAIT(H, TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/cold_modifier = H.dna.species.coldmod
		if(breath_temperature < cold_level_3_threshold)
			H.apply_damage_type(cold_level_3_damage*cold_modifier, cold_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (cold_level_3_damage*cold_modifier*2))
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			H.apply_damage_type(cold_level_2_damage*cold_modifier, cold_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (cold_level_2_damage*cold_modifier*2))
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			H.apply_damage_type(cold_level_1_damage*cold_modifier, cold_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (cold_level_1_damage*cold_modifier*2))
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [cold_message] in your [name]!</span>")

	if(!HAS_TRAIT(H, TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/heat_modifier = H.dna.species.heatmod
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			H.apply_damage_type(heat_level_1_damage*heat_modifier, heat_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (heat_level_1_damage*heat_modifier*2))
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			H.apply_damage_type(heat_level_2_damage*heat_modifier, heat_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (heat_level_2_damage*heat_modifier*2))
		if(breath_temperature > heat_level_3_threshold)
			H.apply_damage_type(heat_level_3_damage*heat_modifier, heat_damage_type)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, (heat_level_3_damage*heat_modifier*2))
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(H, "<span class='warning'>You feel [hot_message] in your [name]!</span>")

/obj/item/organ/lungs/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(!.)
		return
	if(!failed && is_broken())
		if(owner && owner.stat == CONSCIOUS)
			owner.visible_message("<span class='danger'><b>[owner]</b> grabs [owner.p_their()] throat, struggling for breath!</span>", \
								"<span class='userdanger'>You suddenly feel like you can't breathe!</span>")
		failed = TRUE
	else if(is_working())
		failed = FALSE

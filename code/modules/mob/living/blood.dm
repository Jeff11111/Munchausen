/****************************************************
				BLOOD SYSTEM
****************************************************/

#define EXOTIC_BLEED_MULTIPLIER 4 //Multiplies the actually bled amount by this number for the purposes of turf reaction calculations.


///Returns how much blood we're losing from being dragged a tile, from [mob/living/proc/makeTrail]
/mob/living/proc/get_bleed_amount(brute_ratio)
	return max(1, brute_ratio * 2)

/mob/living/carbon/get_bleed_amount(brute_ratio)
	. = 0
	for(var/i in all_wounds)
		var/datum/wound/W = i
		. += W.drag_bleed_amt()
	for(var/i in all_injuries)
		var/datum/injury/IN = i
		. += IN.drag_bleed_amt()

/mob/living/carbon/monkey/handle_blood()
	if(bodytemperature <= TCRYO || (HAS_TRAIT(src, TRAIT_HUSK))) //cryosleep or husked people do not pump the blood.
		return

	blood_volume = max(0, blood_volume)
	var/temp_bleed = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/BP = X
		temp_bleed += BP.get_bleed_rate()
		BP.generic_bleedstacks = max(0, BP.generic_bleedstacks - 1)
		if(BP.current_gauze)
			BP.seep_gauze(BP.current_gauze.absorption_rate * (BP.get_bleed_rate() * 0.75))
	bleed(temp_bleed)

	//Blood regeneration if there is some space
	if(blood_volume < BLOOD_VOLUME_NORMAL)
		//Need a spleen to regenerate blood
		var/obj/item/organ/spleen/spleen = getorganslot(ORGAN_SLOT_SPLEEN)
		if(spleen)
			var/nutrition_ratio = 0
			switch(nutrition)
				if(0 to NUTRITION_LEVEL_STARVING)
					nutrition_ratio = 0.2
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					nutrition_ratio = 0.4
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					nutrition_ratio = 0.6
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					nutrition_ratio = 0.8
				else
					nutrition_ratio = 1
			var/hydration_ratio = 0
			switch(hydration)
				if(0 to HYDRATION_LEVEL_THIRSTY)
					hydration_ratio = 0.5
				else
					hydration_ratio =  1
			adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR)
			adjust_hydration(-hydration_ratio * THIRST_FACTOR)
			blood_volume += (spleen.get_blood() * nutrition_ratio * hydration_ratio)
		if(blood_volume < BLOOD_VOLUME_OKAY)
			adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))

// Takes care blood loss and regeneration
/mob/living/carbon/human/handle_blood()
	if(NOBLOOD in dna.species.species_traits)
		return
	if(HAS_TRAIT(src, TRAIT_NOMARROW)) //Bloodsuckers don't need to be here.
		return
	blood_volume = max(0, blood_volume)
	if(bodytemperature >= TCRYO && !(HAS_TRAIT(src, TRAIT_NOCLONE))) //cryosleep or husked people do not pump the blood.
		//Blood regeneration if there is some space, and a spleen
		var/obj/item/organ/spleen/spleen = getorganslot(ORGAN_SLOT_SPLEEN)
		if(spleen && blood_volume < (BLOOD_VOLUME_NORMAL * blood_ratio) && !HAS_TRAIT(src, TRAIT_NOHUNGER))
			var/nutrition_ratio = 0
			switch(nutrition)
				if(0 to NUTRITION_LEVEL_STARVING)
					nutrition_ratio = 0.2
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					nutrition_ratio = 0.4
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					nutrition_ratio = 0.6
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					nutrition_ratio = 0.8
				else
					nutrition_ratio = 1
			if(HAS_TRAIT(src, TRAIT_HIGH_BLOOD))
				nutrition_ratio *= 1.2
			if(satiety > 80)
				nutrition_ratio *= 1.25
			var/hydration_ratio = 0
			switch(hydration)
				if(0 to HYDRATION_LEVEL_THIRSTY)
					hydration_ratio = 0.5
				else
					hydration_ratio =  1
			adjust_nutrition(-nutrition_ratio * HUNGER_FACTOR)
			blood_volume = min((BLOOD_VOLUME_NORMAL * blood_ratio), blood_volume + spleen.get_blood() * nutrition_ratio * hydration_ratio)

		//Effects of low blood circulation
		switch(get_blood_circulation())
			if(BLOOD_VOLUME_EXCESS to BLOOD_VOLUME_MAX_LETHAL)
				if(prob(15))
					to_chat(src, "<span class='userdanger'>Blood starts to tear your skin apart. You're going to burst!</span>")
					var/severity = rand(15, 50)
					adjustStaminaLoss(severity)
					if(severity >= 40)
						AdjustUnconscious(severity)
					adjustBruteLoss(severity/5)
					bleed(severity/2)
			if(BLOOD_VOLUME_MAXIMUM to BLOOD_VOLUME_EXCESS)
				if(prob(10))
					to_chat(src, "<span class='warning'>You feel terribly bloated.</span>")

		//Effects of low blood oxygenation
		var/word = pick("dizzy","woozy","faint")
		switch(get_blood_oxygenation())
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(prob(5))
					to_chat(src, "<span class='warning'>You feel [word].</span>")
				adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.01, 1))
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))
				if(prob(5))
					blur_eyes(6)
					to_chat(src, "<span class='warning'>You feel very [word].</span>")
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				adjustOxyLoss(5)
				if(prob(15))
					Unconscious(rand(20,60))
					to_chat(src, "<span class='warning'>You feel extremely [word].</span>")
			if(-INFINITY to BLOOD_VOLUME_SURVIVE)
				adjustOxyLoss(10)

		if(get_blood_circulation() <= BLOOD_VOLUME_SURVIVE)
			var/obj/item/organ/heart/bingus = getorganslot(ORGAN_SLOT_HEART)
			if(bingus && !CHECK_BITFIELD(bingus.status, ORGAN_ROBOTIC))
				adjustOrganLoss(ORGAN_SLOT_HEART, pick(0.5, 1))

		var/temp_bleed = 0
		//Bleeding out
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			temp_bleed += BP.get_bleed_rate()
			BP.generic_bleedstacks = max(0, BP.generic_bleedstacks - 1)
			if(BP.current_gauze)
				for(var/ouchie in BP.injuries)
					var/datum/injury/IN = ouchie
					if(!IN.is_bleeding())
						continue
					BP.seep_gauze(BP.current_gauze.absorption_rate * IN.get_bleed_rate())
		bleed(temp_bleed)

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/bleed(amt, splatter = TRUE)
	if(!amt)
		return
	if(blood_volume)
		blood_volume = max(blood_volume - amt, 0)
		if(isturf(src.loc) && splatter) //Blood loss still happens in locker, floor stays clean
			if(amt >= 10)
				add_splatter_floor(src.loc)
			else
				add_splatter_floor(src.loc, TRUE)

/mob/living/carbon/human/bleed(amt, splatter = TRUE)
	if(!amt)
		return
	amt *= physiology.bleed_mod
	if(HAS_TRAIT(src, TRAIT_HEMOPHILIA))
		amt *= 2
	if(!(NOBLOOD in dna.species.species_traits))
		. = ..()
		if(dna.species.exotic_blood && .) // Do we have exotic blood, and have we left any on the ground?
			var/datum/reagent/R = GLOB.chemical_reagents_list[get_blood_id()]
			if(istype(R) && isturf(loc) && splatter)
				R.reaction_turf(get_turf(src), amt * EXOTIC_BLEED_MULTIPLIER)
				var/bloodsound = pick('modular_skyrat/sound/gore/blood1.ogg',
								'modular_skyrat/sound/gore/blood2.ogg',
								'modular_skyrat/sound/gore/blood3.ogg',
								'modular_skyrat/sound/gore/blood4.ogg',
								'modular_skyrat/sound/gore/blood5.ogg',
								'modular_skyrat/sound/gore/blood6.ogg',
								)
				playsound(get_turf(src), bloodsound, 100, 0, -3)

/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/restore_blood()
	blood_volume = (BLOOD_VOLUME_NORMAL * blood_ratio)
	for(var/i in bodyparts)
		var/obj/item/bodypart/BP = i
		BP.generic_bleedstacks = 0

/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	if(!blood_volume || !AM.reagents)
		return FALSE
	if(blood_volume < (BLOOD_VOLUME_BAD * blood_ratio) && !forced)
		return FALSE

	if(blood_volume < amount)
		amount = blood_volume

	var/blood_id = get_blood_id()
	if(!blood_id)
		return FALSE

	blood_volume -= amount

	var/list/blood_data = get_blood_data(blood_id)

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_id == C.get_blood_id())//both mobs have the same blood substance
			if(blood_id == /datum/reagent/blood || blood_id == /datum/reagent/blood/jellyblood) //normal blood
				if(blood_data["viruses"])
					for(var/thing in blood_data["viruses"])
						var/datum/disease/D = thing
						if((D.spread_flags & DISEASE_SPREAD_SPECIAL) || (D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS))
							continue
						C.ForceContractDisease(D)
				//This used to inject oof ouch results, but since we add the reagent, and the reagent causes oof ouch on mob life... why double dip?

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAXIMUM)
			return TRUE

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	AM.janitize(WOUND_SANITIZATION_STERILIZER * 2)
	return TRUE


/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/get_blood_data(blood_id)
	if(blood_id == /datum/reagent/blood || /datum/reagent/blood/jellyblood) //actual blood reagent
		var/blood_data = list()
		//set the blood data
		blood_data["donor"] = src
		blood_data["viruses"] = list()

		for(var/thing in diseases)
			var/datum/disease/D = thing
			blood_data["viruses"] += D.Copy()

		blood_data["blood_DNA"] = dna.unique_enzymes
		blood_data["bloodcolor"] = dna.species.exotic_blood_color
		if(dna.blood_color)
			blood_data["bloodcolor"] = dna.blood_color
		if(!blood_data["bloodcolor"])
			blood_data["bloodcolor"] = BLOOD_COLOR_HUMAN
		if(disease_resistances && disease_resistances.len)
			blood_data["resistances"] = disease_resistances.Copy()
		var/list/temp_chem = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			temp_chem[R.type] = R.volume
		blood_data["trace_chem"] = list2params(temp_chem)
		if(mind)
			blood_data["mind"] = mind
		else if(last_mind)
			blood_data["mind"] = last_mind
		if(ckey)
			blood_data["ckey"] = ckey
		else if(last_mind)
			blood_data["ckey"] = ckey(last_mind.key)

		if(!suiciding)
			blood_data["cloneable"] = 1
		blood_data["blood_type"] = dna.blood_type
		blood_data["gender"] = gender
		blood_data["real_name"] = real_name
		blood_data["features"] = dna.features
		blood_data["factions"] = faction
		blood_data["quirks"] = list()
		for(var/V in roundstart_quirks)
			var/datum/quirk/T = V
			blood_data["quirks"] += T.type
		blood_data["changeling_loudness"] = 0
		if(mind)
			var/datum/antagonist/changeling/ling = mind.has_antag_datum(/datum/antagonist/changeling)
			if(istype(ling))
				blood_data["changeling_loudness"] = ling.loudfactor
		return blood_data

//get the id of the substance this mob use as blood.
/mob/proc/get_blood_id()
	return

/mob/living/simple_animal/get_blood_id()
	if(blood_volume)
		return /datum/reagent/blood

/mob/living/carbon/monkey/get_blood_id()
	if(!(HAS_TRAIT(src, TRAIT_NOCLONE)))
		return /datum/reagent/blood

/mob/living/carbon/get_blood_id()
	if(isjellyperson(src))
		return /datum/reagent/blood/jellyblood
	if(dna?.species?.exotic_blood)
		return dna.species.exotic_blood
	else if((dna && (NOBLOOD in dna.species.species_traits)) || HAS_TRAIT(src, TRAIT_NOCLONE))
		return
	else
		return /datum/reagent/blood

// This is has more potential uses, and is probably faster than the old proc.
/proc/get_safe_blood(bloodtype)
	. = list()
	if(!bloodtype)
		return

	var/static/list/bloodtypes_safe = list(
		"A-" = list("A-", "O-", "SY"),
		"A+" = list("A-", "A+", "O-", "O+", "SY"),
		"B-" = list("B-", "O-", "SY"),
		"B+" = list("B-", "B+", "O-", "O+", "SY"),
		"AB-" = list("A-", "B-", "O-", "AB-", "SY"),
		"AB+" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+", "SY"),
		"O-" = list("O-","SY"),
		"O+" = list("O-", "O+","SY"),
		"L" = list("L","SY"),
		"U" = list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+", "L", "U","SY"),
		"HF" = list("HF", "SY"),
		"X*" = list("X*", "SY"),
		"SY" = list("SY"),
		"GEL" = list("GEL","SY"),
		"BUG" = list("BUG", "SY"),
		"PL" = list("PL", "SY"),
		"AL" = list("AL", "SY"),
		"GREY" = list("GREY", "SY"),
		"ANGL" = list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-", "ANGL", "SY", "HF", "PL", "AL", "GREY",\
						"GEL", "BUG", "X", "L", "U", "SPOR", "DRK", "S"),
		"SPOR" = list("SPOR", "SY"),
		"DRK" = list("DRK", "HF", "SY"),
		"S" = list("S", "SY", "HF"),
		"BHZ" = list("BHZ", "SY", "DRK", "BUG", "GREY")
	)

	var/safe = bloodtypes_safe[bloodtype]
	if(safe)
		. = safe

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/T, small_drip)
	if(get_blood_id() == null)
		return
	if(!T)
		T = get_turf(src)

	var/list/temp_blood_DNA
	if(small_drip)
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in T
		if(drop)
			if(drop.drips < 5)
				drop.drips++
				drop.add_overlay(pick(drop.random_icon_states))
				drop.transfer_mob_blood_dna(src)
				drop.update_icon()
				return
			else if(drop.drips < 9)
				drop.drips++
				drop.overlays.Cut()
				drop.transfer_mob_blood_dna(src)
				drop.update_icon()
				return
			else
				temp_blood_DNA = (drop.blood_DNA - "color")	//transfer dna from drip to splatter.
				temp_blood_DNA["color"] = drop.blood_DNA["color"]
				qdel(drop)//the drip is replaced by a bigger splatter
		else
			drop = new(T, get_static_viruses())
			drop.transfer_mob_blood_dna(src)
			drop.update_icon()
			return

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/splats/B = locate() in T
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splats(T, get_static_viruses())
	if(B.bloodiness < MAX_SHOE_BLOODINESS) //add more blood, up to a limit
		B.bloodiness += BLOOD_AMOUNT_PER_DECAL
	B.transfer_mob_blood_dna(src) //give blood info to the blood decal.
	if(temp_blood_DNA)
		B.blood_DNA |= (temp_blood_DNA - "color")
		if(temp_blood_DNA["color"])
			if(B.blood_DNA["color"])
				B.blood_DNA["color"] = BlendRGB(B.blood_DNA["color"], temp_blood_DNA["color"])
			else
				temp_blood_DNA["color"] = B.blood_DNA["color"]

/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip)
	if(!(NOBLOOD in dna.species.species_traits))
		..()

/mob/living/carbon/alien/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in T.contents
	if(!B)
		B = new(T)
	B.blood_DNA["color"] = BLOOD_COLOR_HUMAN
	B.blood_DNA["UNKNOWN DNA"] = "X*"

/mob/living/silicon/robot/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/oil/B = locate() in T.contents
	if(!B)
		B = new(T)

/mob/living/proc/add_splash_floor(turf/T)
	if(get_blood_id() == null)
		return
	if(!T)
		T = get_turf(src)

	var/list/temp_blood_DNA

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/B = locate() in T
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(T, get_static_viruses())
	if(B.bloodiness < MAX_SHOE_BLOODINESS) //add more blood, up to a limit
		B.bloodiness += BLOOD_AMOUNT_PER_DECAL
	B.transfer_mob_blood_dna(src) //give blood info to the blood decal.
	src.transfer_blood_to(B, 10) //very heavy bleeding, should logically leave larger pools
	if(temp_blood_DNA)
		B.blood_DNA |= (temp_blood_DNA - "color")
		if(B.blood_DNA["color"])
			B.blood_DNA["color"] = BlendRGB(temp_blood_DNA["color"], B.blood_DNA["color"])
		else
			B.blood_DNA["color"] = temp_blood_DNA["color"]

/mob/living/carbon/human/add_splash_floor(turf/T)
	if(!(NOBLOOD in dna.species.species_traits))
		..()

/mob/living/carbon/alien/add_splash_floor(turf/T)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in T.contents
	if(!B)
		B = new(T)
	B.blood_DNA["color"] = BLOOD_COLOR_HUMAN
	B.blood_DNA["UNKNOWN DNA"] = "X*"

/mob/living/silicon/robot/add_splash_floor(turf/T)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/oil/B = locate() in T.contents
	if(!B)
		B = new(T)

//This is a terrible way of handling it.
/mob/living/proc/ResetBloodVol()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if (HAS_TRAIT(src, TRAIT_HIGH_BLOOD))
			blood_ratio = 1.2
			H.handle_blood()
			return
		blood_ratio = 1
		H.handle_blood()
		return
	blood_ratio = 1

/mob/living/proc/AdjustBloodVol(value)
	if(blood_ratio == value)
		return
	blood_ratio = value
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		H.handle_blood()

//skyrat edit
/*
	Dismemberment
*/
/datum/wound/loss
	name = "Dismembered stump"
	desc = "Patient's limb has been violently dismembered, leaving only a severely damaged stump in it's place."
	viable_zones = ALL_BODYPARTS
	wound_type = WOUND_LIST_LOSS
	severity = WOUND_SEVERITY_LOSS
	ignore_preexisting = TRUE
	threshold_minimum = 180
	status_effect_type = null
	scarring_descriptions = list("is several skintone shades paler than the rest of the body", "is a gruesome patchwork of artificial flesh", "has a large series of attachment scars at the articulation points")
	biology_required = list()
	required_status = null

/datum/wound/loss/proc/apply_dismember(obj/item/bodypart/L, wounding_type = WOUND_SLASH, silent = FALSE)
	if(!istype(L) || !L.owner || !(L.body_zone in viable_zones) || isalien(L.owner) || !L.can_dismember())
		qdel(src)
		return
	
	if(L.body_zone == BODY_ZONE_CHEST)
		qdel(src)
		var/datum/wound/disembowel/des = new()
		des.apply_disembowel(L, wounding_type, TRUE)
		return

	if(ishuman(L.owner))
		var/mob/living/carbon/human/H = L.owner
		if((required_status & BODYPART_ORGANIC) && !L.is_organic_limb())
			qdel(src)
			return
		else if((required_status & BODYPART_ROBOTIC) && !L.is_robotic_limb())
			qdel(src)
			return
		
		for(var/biology_flag in biology_required)
			if(!(biology_flag in H.dna.species.species_traits))
				qdel(src)
				return

	occur_text = "is slashed through the last tissue holding it together, severing it completely"
	switch(wounding_type)
		if(WOUND_BLUNT)
			occur_text = "is shattered into a shower of gore"
			if(L.is_robotic_limb())
				occur_text = "is shattered into a shower of sparks"
		if(WOUND_SLASH)
			occur_text = "is slashed through the last bit of tissue holding it together, severing it completely"
			if(L.is_robotic_limb())
				occur_text = "is slashed through the last bit of exoskeleton layer holding it together, severing it completely"
		if(WOUND_PIERCE)
			occur_text = "is pierced through the last tissue holding it together, goring it into unrecognizable giblets"
			if(L.is_robotic_limb())
				occur_text = "is pierced through the last bit of exoskeleton holding it together, goring it into unrecognizable scrap metal"
		if(WOUND_BURN)
			occur_text = "is completely incinerated, falling to a pile of carbonized remains"
			if(L.is_robotic_limb())
				occur_text = "is completely incinerated, falling to a puddle of debris"

	var/mob/living/carbon/victim = L.owner
	if(prob(40))
		victim.confused += 5
	if(prob(50 - GET_STAT_LEVEL(victim, end)))
		victim.emote("scream")

	var/msg = "<b><span class='danger'>[victim]'s [parse_zone(check_zone(fake_body_zone))] [occur_text]!</span></b>"

	if(!silent)
		victim.visible_message(msg, "<span class='userdanger'>Your [parse_zone(check_zone(fake_body_zone))] [occur_text]!</span>")

	if(wounding_type == WOUND_BURN)
		if(L.is_organic_limb())
			new /obj/effect/decal/cleanable/ash(get_turf(L))
		else if(L.is_robotic_limb())
			new /obj/effect/decal/remains/robot(get_turf(L))
	
	//apply the blood gush effect
	if(wounding_type != WOUND_BURN && L.owner)
		var/direction = L.owner.dir
		direction = turn(direction, 180)
		var/bodypart_turn = 0 //relative north
		if(L.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_L_HAND))
			bodypart_turn = -90 //relative east
		else if(L.body_zone in list(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_R_HAND))
			bodypart_turn = 90 //relative west
		direction = turn(direction, bodypart_turn)
		var/dist = rand(3, 5)
		var/turf/targ = get_ranged_target_turf(L.owner, direction, dist)
		if(targ)
			var/obj/effect/decal/cleanable/blood/hitsplatter/B = new(L.owner.loc, L.owner.get_blood_dna_list())
			B.add_blood_DNA(L.owner.get_blood_dna_list())
			B.GoTo(targ, dist)

	second_wind()
	log_wound(victim, src)
	var/should_kaplosh = FALSE
	if(wounding_type in list(WOUND_BURN, WOUND_PIERCE, WOUND_BLUNT))
		should_kaplosh = TRUE
	var/kaplosh_sound = pick(
		'modular_skyrat/sound/gore/chop1.ogg',
		'modular_skyrat/sound/gore/chop2.ogg',
		'modular_skyrat/sound/gore/chop3.ogg',
		'modular_skyrat/sound/gore/chop4.ogg',
		'modular_skyrat/sound/gore/chop5.ogg',
		'modular_skyrat/sound/gore/chop6.ogg',
	)
	if(length(L.dismember_sounds))
		kaplosh_sound = pick(L.dismember_sounds)
	if(L.is_robotic_limb())
		kaplosh_sound = 'modular_skyrat/sound/effects/crowbarhit.ogg'
	playsound(L.owner, kaplosh_sound, 80, 0)
	L.dismember(dam_type = (wounding_type == WOUND_BURN ? BURN : BRUTE), silent = TRUE, destroy = should_kaplosh, wounding_type = wounding_type)
	qdel(src)

/datum/wound/slash/loss
	name = "Dismembered"
	desc = "Patient's limb has been violently dismembered, leaving only a severely damaged stump in it's place."
	treat_text = "Immediate surgical reattachment of the lost limb or suitable equivalent if possible. Suturization or cauterization of the stump otherwise."
	examine_desc = "has been violently severed from their body"
	viable_zones = ALL_BODYPARTS
	severity = WOUND_SEVERITY_LOSS
	wound_type = WOUND_LIST_LOSS
	ignore_preexisting = TRUE
	max_per_type = 4
	threshold_penalty = 80
	demotes_to = null
	threshold_minimum = 180
	status_effect_type = /datum/status_effect/wound/loss
	scarring_descriptions = list("is several skintone shades paler than the rest of the body", "is a gruesome patchwork of artificial flesh", "has a large series of attachment scars at the articulation points")
	required_status = BODYPART_ORGANIC
	biology_required = list()
	pain_amount = 40 //Horrible, will probably send you into shock.
	infection_chance = 90
	infection_rate = 6
	occur_text = null
	initial_flow = 4.25
	minimum_flow = 4
	clot_rate = 0
	descriptive = null

/datum/wound/slash/loss/get_examine_description(mob/user)
	. = ..()
	if(fake_body_zone in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK))
		return "<span class='deadsay'>[..()]</span>"

/datum/wound/slash/loss/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited)
	. = ..()
	switch(L.body_zone)
		if(BODY_ZONE_HEAD)
			initial_flow *= 1
			minimum_flow *= (1/4)
		if(BODY_ZONE_PRECISE_NECK)
			initial_flow *= (6/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_CHEST)
			initial_flow *= (5/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_PRECISE_GROIN)
			initial_flow *= (5/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_L_ARM)
			initial_flow *= (3/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_R_ARM)
			initial_flow *= (3/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_PRECISE_L_HAND)
			initial_flow *= (1/2)
			minimum_flow *= (1/3)
		if(BODY_ZONE_PRECISE_R_HAND)
			initial_flow *= (1/2)
			minimum_flow *= (1/3)
		if(BODY_ZONE_L_LEG)
			initial_flow *= (3/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_R_LEG)
			initial_flow *= (3/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_PRECISE_L_FOOT)
			initial_flow *= (1/2)
			minimum_flow *= (1/3)
		if(BODY_ZONE_PRECISE_R_FOOT)
			initial_flow *= (1/2)
			minimum_flow *= (1/3)

/datum/wound/mechanical/slash/loss
	name = "Dismembered stump"
	desc = "Patient's limb has been violently dismembered, leaving only a severely damaged stump in it's place."
	treat_text = "Immediate surgical reattachment of the lost limb or suitable equivalent if possible. Welding and patching of the stump otherwise."
	examine_desc = "has been violently severed from their body"
	viable_zones = ALL_BODYPARTS
	severity = WOUND_SEVERITY_LOSS
	wound_type = WOUND_LIST_LOSS
	ignore_preexisting = TRUE
	clot_rate = 0
	max_per_type = 4
	threshold_penalty = 80
	demotes_to = null
	threshold_minimum = 180
	status_effect_type = /datum/status_effect/wound/loss
	scarring_descriptions = list("is several skintone shades paler than the rest of the body", "is a gruesome patchwork of artificial flesh", "has a large series of attachment scars at the articulation points")
	required_status = BODYPART_ROBOTIC
	biology_required = list()
	pain_amount = 40
	occur_text = null
	descriptive = null

/datum/wound/mechanical/slash/loss/get_examine_description(mob/user)
	. = ..()
	if(fake_body_zone in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK))
		return "<span class='deadsay'>[..()]</span>"

/datum/wound/mechanical/slash/loss/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited)
	. = ..()
	switch(L.body_zone)
		if(BODY_ZONE_HEAD)
			initial_flow *= 1
			minimum_flow *= (1/4)
		if(BODY_ZONE_PRECISE_NECK)
			initial_flow *= (6/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_CHEST)
			initial_flow *= (5/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_PRECISE_GROIN)
			initial_flow *= (5/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_L_ARM)
			initial_flow *= (3/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_R_ARM)
			initial_flow *= (3/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_PRECISE_L_HAND)
			initial_flow *= (1/2)
			minimum_flow *= (1/3)
		if(BODY_ZONE_PRECISE_R_HAND)
			initial_flow *= (1/2)
			minimum_flow *= (1/3)
		if(BODY_ZONE_L_LEG)
			initial_flow *= (3/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_R_LEG)
			initial_flow *= (3/4)
			minimum_flow *= (1/4)
		if(BODY_ZONE_PRECISE_L_FOOT)
			initial_flow *= (1/2)
			minimum_flow *= (1/3)
		if(BODY_ZONE_PRECISE_R_FOOT)
			initial_flow *= (1/2)
			minimum_flow *= (1/3)

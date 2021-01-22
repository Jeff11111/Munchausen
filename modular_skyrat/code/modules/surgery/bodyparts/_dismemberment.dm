//Check if the limb is stumpable
/obj/item/bodypart/proc/can_stump(obj/item/I)
	if(CHECK_BITFIELD(limb_flags, BODYPART_CAN_STUMP))
		return TRUE

//Check if the limb is dismemberable
/obj/item/bodypart/proc/can_dismember(obj/item/I)
	if(owner && dismemberable && !HAS_TRAIT(owner, TRAIT_NODISMEMBER) && !(owner.status_flags & GODMODE))
		return TRUE

//Dismember a limb
/obj/item/bodypart/proc/dismember(dam_type = BRUTE, silent = FALSE, destroy = FALSE, wounding_type = WOUND_SLASH)
	if(!can_dismember())
		return FALSE
	
	var/mob/living/carbon/C = owner
	var/obj/item/bodypart/affecting = C.get_bodypart(parent_bodyzone)
	if(istype(affecting))
		affecting.receive_damage(clamp(brute_dam/2 * affecting.body_damage_coeff, 15, 50), clamp(burn_dam/2 * affecting.body_damage_coeff, 0, 50), wound_bonus=CANT_WOUND) //Damage the parent bodyzone based on limb's existing damage
	
	if(!silent)
		C.visible_message("<span class='danger'><B>[C]'s [src.name] has been violently dismembered!</B></span>")
		playsound(get_turf(C), 'modular_skyrat/sound/gore/dismember.ogg', 80, TRUE)
	
	SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "dismembered", /datum/mood_event/dismembered)
	drop_limb(dismembered = TRUE, destroyed = destroy, wounding_type = wounding_type)
	C.update_equipment_speed_mods() // Update in case speed affecting item unequipped by dismemberment
	C.bleed(12)

	if(QDELETED(src)) //Could have dropped into lava/explosion/chasm/whatever
		return TRUE
	
	add_mob_blood(C)
	var/direction = pick(GLOB.cardinals)
	var/t_range = rand(2,max(throw_range/2, 2))
	var/turf/target_turf = get_turf(src)
	for(var/i in 1 to t_range-1)
		var/turf/new_turf = get_step(target_turf, direction)
		if(!new_turf)
			break
		target_turf = new_turf
		if(new_turf.density)
			break
	throw_at(target_turf, throw_range, throw_speed)
	return TRUE

//Limb removal. The "special" argument is used for swapping a limb with a new one without the effects of losing a limb kicking in.
//Destroyed just qdels the limb.
/obj/item/bodypart/proc/drop_limb(special = FALSE, ignore_children = FALSE, dismembered = FALSE, destroyed = FALSE, wounding_type = WOUND_SLASH)
	if(!owner)
		return
	
	var/atom/Tsec = owner.drop_location()
	var/mob/living/carbon/C = owner
	SEND_SIGNAL(C, COMSIG_CARBON_REMOVE_LIMB, src, dismembered)
	update_limb(TRUE)
	C.bodyparts -= src

	if(held_index)
		if(C.get_item_for_held_index(held_index))
			C.dropItemToGround(owner.get_item_for_held_index(held_index), TRUE, TRUE)
		C.hand_bodyparts[held_index] = null
	
	for(var/thing in wounds)
		var/datum/wound/W = thing
		W.remove_wound(TRUE)
	
	owner = null
	if(!ignore_children)
		for(var/BP in children_zones)
			var/obj/item/bodypart/thing = C.get_bodypart(BP)
			if(thing)
				thing.drop_limb(special, ignore_children, dismembered, destroyed)
				thing.forceMove(src)
				thing.on_transfer_to_limb(src)
		C.updatehealth()

	for(var/obj/item/I in embedded_objects)
		embedded_objects -= I
		I.forceMove(get_turf(src))
		I.unembedded()
	if(!C.has_embedded_objects())
		C.clear_alert("embeddedobject")
		SEND_SIGNAL(C, COMSIG_CLEAR_MOOD_EVENT, "embedded")

	for(var/i in injuries)
		C.all_injuries -= i
	
	if(!special)
		if(CHECK_BITFIELD(limb_flags, BODYPART_VITAL))
			C.death()
		if(C.dna)
			for(var/X in C.dna.mutations) //some mutations require having specific limbs to be kept.
				var/datum/mutation/human/MT = X
				if(MT.limb_req && MT.limb_req == body_zone)
					C.dna.force_lose(MT)
		for(var/X in C.internal_organs) //internal organs inside the dismembered limb are dropped.
			var/obj/item/organ/O = X
			var/org_zone = check_zone(O.zone)
			if(org_zone != body_zone)
				continue
			O.transfer_to_limb(src, C)

	limb_flags |= BODYPART_CUT_AWAY
	if(dismembered && !is_stump() && can_stump()) //Not a clean chopping off
		var/obj/item/bodypart/stump/stump  = new(C)
		stump.name = "stump of a [parse_zone(body_zone)]"
		stump.body_zone = body_zone
		stump.body_part = body_part
		stump.amputation_point = amputation_point
		stump.joint_name = joint_name
		stump.parent_bodyzone = parent_bodyzone
		stump.encased = encased
		stump.dismember_sounds = dismember_sounds?.Copy()
		stump.artery_name = "mangled [artery_name ? artery_name : "artery"]"
		stump.tendon_name = "mangled [tendon_name ? tendon_name : "tendon"]"
		stump.cavity_name = cavity_name
		stump.miss_entirely_prob = miss_entirely_prob
		stump.zone_prob = zone_prob
		stump.extra_zone_prob = extra_zone_prob
		stump.max_damage = max_damage
		stump.max_tox_damage = max_tox_damage
		stump.max_pain_damage = max_pain_damage
		stump.status = status
		stump.limb_flags = limb_flags
		stump.animal_origin = animal_origin
		stump.attach_limb(C, FALSE, FALSE)
		var/datum/wound/artery/artery = new()
		artery.apply_wound(stump, TRUE)
		var/datum/injury/ouchie = stump.create_injury(wounding_type, stump.max_damage / 2, FALSE, TRUE)
		ouchie.apply_injury(stump.max_damage / 2, stump)
	
	update_icon_dropped()
	if(destroyed)
		for(var/obj/item/organ/O in src)
			qdel(O)
	
	C.update_health_hud() //update the healthdoll
	C.update_body()
	C.update_hair()
	C.update_mobility()

	if(!Tsec || destroyed)	// Tsec = null happens when a "dummy human" used for rendering icons on prefs screen gets its limbs replaced.
		qdel(src)
		return

	//Start processing rotting... if we didn't get destroyed
	START_PROCESSING(SSobj, src)
	//Also, recover integrity
	limb_integrity = max_integrity
	
	if(is_pseudopart)
		drop_organs(C) //Pseudoparts shouldn't have organs, but just in case
		qdel(src)
		return

	if(istype(Tsec))
		forceMove(Tsec)
	
/**
  * get_mangled_state() is relevant for flesh and bone bodyparts, and returns whether this bodypart has mangled skin, mangled bone, or both (or neither i guess)
  *
  * Dismemberment for flesh and bone requires the victim to have the skin on their bodypart destroyed (either a critical cut or piercing wound), and at least a hairline fracture
  * (severe bone), at which point we can start rolling for dismembering. The attack must also deal at least 10 damage, and must be a brute attack of some kind (sorry for now, cakehat, maybe later)
  *
  * Returns: BODYPART_MANGLED_NONE if we're fine, BODYPART_MANGLED_SKIN if our skin is broken, BODYPART_MANGLED_BONE if our bone is broken, or BODYPART_MANGLED_BOTH if both are broken and we're up for dismembering
  */
/obj/item/bodypart/proc/get_mangled_state()
	. = BODYPART_MANGLED_NONE
	var/biological_state = owner?.get_biological_state()
	var/required_bone_severity = WOUND_SEVERITY_SEVERE //How fractured the bone needs to be, pretty much
	var/required_muscle_severity = 15 //How much damage the cut or pierce injury must have
	if(biological_state && (biological_state & BIO_BONE) && !(biological_state & BIO_FLESH) && !HAS_TRAIT(owner, TRAIT_EASYDISMEMBER))
		required_bone_severity = WOUND_SEVERITY_CRITICAL
	
	if(biological_state && (biological_state & BIO_FLESH) && !(biological_state & BIO_FLESH) && !HAS_TRAIT(owner, TRAIT_EASYDISMEMBER))
		required_muscle_severity = 25

	// fracture check
	for(var/i in wounds)
		var/datum/wound/W = i
		if((W.wound_flags & WOUND_MANGLES_BONE) && (W.severity >= required_bone_severity))
			. |= BODYPART_MANGLED_BONE

	for(var/datum/injury/IN in injuries)
		if((IN.damage_type in list(WOUND_SLASH, WOUND_PIERCE)) && (IN.damage >= required_muscle_severity))
			. |= BODYPART_MANGLED_MUSCLE
/**
  * damage_integrity() is used, once we've confirmed that a flesh and bone bodypart has both the skin, muscle and bone mangled,
  * to try and damage it's integrity, which once it reaches 0... the bodypart is dismembered or gored.
  *
  * Arguments:
  * * wounding_type: Either WOUND_BLUNT, WOUND_SLASH, or WOUND_PIERCE, basically only matters for the dismember message
  * * wounding_dmg: The damage of the strike that prompted this roll, higher damage = higher integrity loss
  * * wound_bonus: Not actually used right now, but maybe someday
  * * bare_wound_bonus: Ditto above
  */

/obj/item/bodypart/proc/damage_integrity(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
	if(!owner)
		return FALSE
	if((wounding_dmg < DISMEMBER_MINIMUM_DAMAGE) || ((wounding_dmg + wound_bonus) < DISMEMBER_MINIMUM_DAMAGE) || wound_bonus <= CANT_WOUND)
		return FALSE
	
	//High endurance - less dismemberment
	if(owner?.mind)
		wounding_dmg *= max(0.5, 2 - (GET_STAT_LEVEL(owner, end)/10))
	
	//If we have a compound fracture or, then deal more integrity damage
	if((locate(/datum/wound/blunt/critical) in wounds) || (locate(/datum/wound/mechanical/blunt/critical) in wounds))
		wounding_dmg *= 1.35
	
	//Damage the integrity with the wounding damage
	limb_integrity = max(0, limb_integrity - wounding_dmg)

/**
  * try_dismember() is used, once we've confirmed that a flesh and bone bodypart has both the skin, muscle and bone mangled, to actually roll for it
  *
  * Mangling is described in the above proc, [/obj/item/bodypart/proc/get_mangled_state()]. This simply makes the roll for whether we actually dismember or not
  * using how damaged the limb already is, and how much damage this blow was for. If we have a critical bone wound instead of just a severe, we add +10% to the roll.
  * Lastly, we choose which kind of dismember we want based on the wounding type we hit with
  *
  * Arguments:
  * * wounding_type: Either WOUND_BLUNT, WOUND_SLASH, or WOUND_PIERCE, basically only matters for the dismember message
  * * wounding_dmg: The damage of the strike that prompted this roll, higher damage = higher chance
  * * wound_bonus: Not actually used right now, but maybe someday
  * * bare_wound_bonus: ditto above
  */

/obj/item/bodypart/proc/try_dismember(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
	if(!owner)
		return FALSE
	if(!can_dismember() || (wounding_dmg < DISMEMBER_MINIMUM_DAMAGE) || ((wounding_dmg + wound_bonus) < DISMEMBER_MINIMUM_DAMAGE) || wound_bonus <= CANT_WOUND)
		return FALSE

	if(!(limb_integrity <= 0))
		return FALSE

	apply_dismember(wounding_type, TRUE)
	return TRUE

/obj/item/bodypart/proc/apply_dismember(wounding_type = WOUND_SLASH, silent = FALSE)
	if(!owner || isalien(owner) || !can_dismember())
		return FALSE

	var/occur_text = "is slashed through the last tissue holding it together, severing it completely"
	switch(wounding_type)
		if(WOUND_BLUNT)
			occur_text = "is shattered into a shower of gore"
			if(is_robotic_limb())
				occur_text = "is shattered into a shower of sparks"
		if(WOUND_SLASH)
			occur_text = "is slashed through the last bit of tissue holding it together, severing it completely"
			if(is_robotic_limb())
				occur_text = "is slashed through the last bit of exoskeleton layer holding it together, severing it completely"
		if(WOUND_PIERCE)
			occur_text = "is pierced through the last tissue holding it together, goring it into unrecognizable giblets"
			if(is_robotic_limb())
				occur_text = "is pierced through the last bit of exoskeleton holding it together, goring it into unrecognizable scrap metal"
		if(WOUND_BURN)
			occur_text = "is completely incinerated, falling to a pile of carbonized remains"
			if(is_robotic_limb())
				occur_text = "is completely incinerated, falling to a puddle of debris"

	var/mob/living/carbon/poorsod = owner
	if(prob(50 - GET_STAT_LEVEL(poorsod, end)))
		poorsod.confused += max(0, 15 - GET_STAT_LEVEL(poorsod, end))
	if((body_zone == BODY_ZONE_PRECISE_GROIN) && prob(35 - GET_STAT_LEVEL(poorsod, end)))
		poorsod.vomit(15, 15, 25)
	if(prob(80 - GET_STAT_LEVEL(poorsod, end)))
		poorsod.death_scream()

	if(!silent)
		poorsod.visible_message("<b><span class='danger'>[poorsod]'s [name] [occur_text]!</span></b>", "<span class='userdanger'>Your [name] [occur_text]!</span>")
	else
		switch(wounding_type)
			if(WOUND_SLASH)
				poorsod.wound_message += " \The [name] is violently severed!"
			if(WOUND_PIERCE, WOUND_BLUNT)
				poorsod.wound_message += " \The [name] is violently gored!"
			if(WOUND_BURN)
				poorsod.wound_message += " \The [name] is violently incinerated!"
	
	if(wounding_type == WOUND_BURN)
		if(is_organic_limb())
			new /obj/effect/decal/cleanable/ash(get_turf(owner))
		if(is_robotic_limb())
			new /obj/effect/decal/remains/robot(get_turf(owner))
	
	//apply the blood gush effect
	if(wounding_type != WOUND_BURN && owner)
		var/direction = owner.dir
		direction = turn(direction, 180)
		var/bodypart_turn = 0 //relative north
		if(body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_L_HAND))
			bodypart_turn = -90 //relative east
		else if(body_zone in list(BODY_ZONE_R_ARM, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_R_HAND))
			bodypart_turn = 90 //relative west
		direction = turn(direction, bodypart_turn)
		var/dist = rand(3, 5)
		var/turf/targ = get_ranged_target_turf(owner, direction, dist)
		if(istype(targ) && dist > 0 && ((owner.mob_biotypes & MOB_ORGANIC) || (owner.mob_biotypes & MOB_HUMANOID)) && owner.needs_heart() && !owner.is_asystole() && (ishuman(owner) ? !(NOBLOOD in owner.dna?.species?.species_traits) : TRUE))
			var/obj/effect/decal/cleanable/blood/hitsplatter/B = new(owner.loc, owner.get_blood_dna_list())
			B.add_blood_DNA(owner.get_blood_dna_list())
			B.GoTo(targ, dist)

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
	if(length(dismember_sounds))
		kaplosh_sound = pick(dismember_sounds)
	if(is_robotic_limb())
		kaplosh_sound = 'modular_skyrat/sound/effects/crowbarhit.ogg'
	playsound(owner, kaplosh_sound, 80, 0)
	dismember(dam_type = (wounding_type == WOUND_BURN ? BURN : BRUTE), silent = TRUE, destroy = should_kaplosh, wounding_type = wounding_type)

//Stuff you do when you go inside a parent limb that was chopped off
/obj/item/bodypart/proc/on_transfer_to_limb(obj/item/bodypart/BP)
	return FALSE

//Attach a limb to a human and drop any existing limb of that type.
/obj/item/bodypart/proc/replace_limb(mob/living/carbon/C, special)
	if(!istype(C))
		return
	var/obj/item/bodypart/O = C.get_bodypart(body_zone)
	if(O)
		O.drop_limb(special, TRUE, FALSE, FALSE)
	attach_limb(C, special)

/obj/item/bodypart/proc/attach_limb(mob/living/carbon/C, special, ignore_parent_restriction = FALSE)
	if(SEND_SIGNAL(C, COMSIG_CARBON_ATTACH_LIMB, src, special) & COMPONENT_NO_ATTACH)
		return FALSE
	var/obj/item/bodypart/screaming = C.get_bodypart(parent_bodyzone)
	if(parent_bodyzone && !ignore_parent_restriction && (!istype(screaming) || screaming.is_stump()))
		return FALSE
	. = TRUE
	moveToNullspace()

	// We check if there is another limb like us before attaching. If so, we kindly delete them.
	var/obj/item/bodypart/rival = C.get_bodypart(body_zone)
	if(rival)
		rival.drop_limb(special = TRUE, ignore_children = TRUE)
		qdel(rival)
	
	owner = C
	C.bodyparts += src
	if(held_index)
		if(held_index > C.hand_bodyparts.len)
			C.hand_bodyparts.len = held_index
		C.hand_bodyparts[held_index] = src
		if(C.dna.species.mutanthands && !is_pseudopart)
			C.put_in_hand(new C.dna.species.mutanthands(), held_index)
		if(C.hud_used)
			var/obj/screen/inventory/hand/hand = C.hud_used.hand_slots["[held_index]"]
			if(hand)
				hand.update_icon()
		C.update_inv_gloves()
	
	//Stored limbs. in normal circumstances, this will be either nothing or just the children.
	for(var/obj/item/bodypart/BP in src)
		BP.attach_limb(C, special, ignore_parent_restriction)

	//Remove the dismemberment wound from the parent, if there is one at all
	var/obj/item/bodypart/parent = C.get_bodypart(parent_bodyzone)
	if(parent)
		for(var/datum/wound/woundie in parent.wounds)
			if((woundie.fake_body_zone == body_zone) && (woundie.severity == WOUND_SEVERITY_LOSS))
				woundie.remove_wound()
		for(var/datum/injury/lost_limb/lost_limb in injuries)
			qdel(lost_limb)
	
	//Insert stored organs on the owner
	for(var/obj/item/organ/O in contents)
		O.Insert(C)
	
	//Apply stored wounds to the owner
	for(var/i in wounds)
		var/datum/wound/W = i
		W.apply_wound(src, TRUE)

	//Add injuries to the owner's injury list
	for(var/i in injuries)
		C.all_injuries |= i
	
	update_bodypart_damage_state()
	update_disabled()

	C.updatehealth()
	C.update_body()
	C.update_hair()
	C.update_damage_overlays()
	C.update_mobility()

//Regenerates all limbs. Returns amount of limbs regenerated
/mob/living/proc/regenerate_limbs(noheal = FALSE, list/excluded_limbs = list())
	. = list()
	SEND_SIGNAL(src, COMSIG_LIVING_REGENERATE_LIMBS, noheal, excluded_limbs)

/mob/living/carbon/regenerate_limbs(noheal = FALSE, list/excluded_limbs = list(), ignore_parent_restriction = FALSE)
	. = ..()
	var/list/limb_list = ALL_BODYPARTS_ORDERED //Can't use ALL_BODYPARTS because order matters
	if(excluded_limbs.len)
		limb_list -= excluded_limbs
	for(var/Z in limb_list)
		. += regenerate_limb(Z, noheal, ignore_parent_restriction)

/mob/living/proc/regenerate_limb(limb_zone, noheal, ignore_parent_restriction)
	return

/mob/living/carbon/regenerate_limb(limb_zone, noheal, ignore_parent_restriction)
	var/obj/item/bodypart/L
	if(get_bodypart(limb_zone))
		return
	L = newBodyPart(limb_zone, 0, 0)
	if(L)
		if(!noheal)
			L.brute_dam = 0
			L.burn_dam = 0
			L.brutestate = 0
			L.burnstate = 0

		var/mob/living/carbon/human/H = src
		if(istype(H) && (ROBOTIC_LIMBS in H.dna?.species?.species_traits))
			L.change_bodypart_status(BODYPART_ROBOTIC)
			L.render_like_organic = TRUE
		
		L.attach_limb(src, TRUE, ignore_parent_restriction)
		return L

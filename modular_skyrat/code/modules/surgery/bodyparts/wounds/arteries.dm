/datum/wound/artery
	name = "Torn Artery"
	desc = "Patient's artery has been violently slashed open, causing severe hemorrhaging."
	treat_text = "Immediate inciosion of the limb followed by suturing or fix o' veining the torn artery."
	examine_desc = "is bleeding profusely"
	occur_text = "is violently torn, severing an artery"
	sound_effect = 'modular_skyrat/sound/gore/artery.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	wound_type = WOUND_LIST_ARTERY
	viable_zones = ALL_BODYPARTS
	threshold_minimum = 115
	threshold_penalty = 0
	infection_chance = 0
	infection_rate = 0
	treatable_by = list(/obj/item/stack/medical/suture, /obj/item/stack/medical/fixovein)
	treat_priority = TRUE
	base_treat_time = 2 SECONDS
	blood_flow = 3
	blood_time = 3
	descriptive = "An artery is torn!"
	wound_flags = (WOUND_SOUND_HINTS)
	var/next_squirt = 0 //kinky.
	var/squirt_delay_min = 8 SECONDS
	var/squirt_delay_max = 12 SECONDS

/datum/wound/artery/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited)
	if(L)
		if(!L.artery_name)
			qdel(src)
			return FALSE
		name = "Torn [capitalize(L.artery_name, TRUE)]"
		desc = "Patient's [L.artery_name] has been violently slashed open, causing severe hemorrhaging."
		switch(L.body_zone)
			if(BODY_ZONE_PRECISE_LEFT_EYE)
				blood_flow *= 0.35
			if(BODY_ZONE_PRECISE_RIGHT_EYE)
				blood_flow *= 0.35
			if(BODY_ZONE_HEAD)
				blood_flow *= 1.5
			if(BODY_ZONE_PRECISE_NECK)
				blood_flow *= 2.5
			if(BODY_ZONE_CHEST)
				blood_flow *= 1
			if(BODY_ZONE_PRECISE_GROIN)
				blood_flow *= 1
			if(BODY_ZONE_L_ARM)
				blood_flow *= 0.75
			if(BODY_ZONE_R_ARM)
				blood_flow *= 0.75
			if(BODY_ZONE_PRECISE_L_HAND)
				blood_flow *= 0.5
			if(BODY_ZONE_PRECISE_R_HAND)
				blood_flow *= 0.5
			if(BODY_ZONE_L_LEG)
				blood_flow *= 0.75
			if(BODY_ZONE_R_LEG)
				blood_flow *= 0.75
			if(BODY_ZONE_PRECISE_L_FOOT)
				blood_flow *= 0.5
			if(BODY_ZONE_PRECISE_R_FOOT)
				blood_flow *= 0.5
	blood_time = blood_flow
	L.owner.bleed(blood_flow)
	L.owner.add_splatter_floor(get_turf(victim))
	L.owner.death_scream()
	. = ..()

/datum/wound/artery/handle_process()
	. = ..()
	//No bleeding means we should be gone
	if(blood_flow <= 0)
		qdel(src)
		return
	
	//do the funny
	var/bleed_mod = 1
	if(limb.grasped_by)
		bleed_mod *= 0.75
	
	if(world.time >= next_squirt)
		cum(bleed_mod)
	else
		cum_less(bleed_mod)

/datum/wound/artery/proc/cum(bleed_mod = 1, force = FALSE)
	//People with no pulse can't really squirt blood, can they?
	//Nor can people with no blood
	if((!(victim.stat >= DEAD) && !(victim.pulse() < PULSE_NORM) && !(victim.blood_volume <= blood_flow) && (blood_flow >= 1)) || force)
		playsound(victim, sound_effect, 75, 0)
		victim.bleed(blood_flow * bleed_mod, FALSE)
		victim.visible_message("<span class='danger'><b>[victim]</b>'s [limb.name]'s [limb.artery_name] squirts blood!</span>", \
						"<span class='userdanger'>Blood squirts from my [limb.name]'s [limb.artery_name]!</span>")
		var/spray_dir = pick(GLOB.alldirs)
		var/turf/uhoh = get_edge_target_turf(victim, spray_dir)
		if(istype(uhoh) && ((victim.mob_biotypes & MOB_ORGANIC) || (victim.mob_biotypes & MOB_HUMANOID)) && victim.needs_heart() && !(NOBLOOD in victim.dna?.species?.species_traits))
			var/obj/effect/decal/cleanable/blood/hitsplatter/B = new (get_turf(victim), victim.get_blood_dna_list())
			B.GoTo(uhoh, rand(1,3))
		next_squirt = world.time + FLOOR(rand(squirt_delay_min, squirt_delay_max), 10)
	else
		next_squirt = world.time + FLOOR(rand(squirt_delay_min, squirt_delay_max), 10)
		return cum_less(bleed_mod)

/datum/wound/artery/proc/cum_less(bleed_mod = 1)
	//just bleed without being dramatic
	victim.bleed(blood_flow * bleed_mod)

/datum/wound/artery/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/suture) || istype(I, /obj/item/stack/medical/fixovein))
		attempt_suture(I, user)

/datum/wound/artery/proc/attempt_suture(obj/item/stack/medical/I, mob/user)
	if(!locate(/datum/wound/slash/critical/incision) in limb.wounds)
		to_chat(user, "<span class='notice'>I must incise [limb] to treat it's arterial bleeding!</span>")
		return
	user.visible_message("<span class='notice'>[user] begins stitching [victim]'s [limb] [limb.artery_name] with [I]...</span>", \
					"<span class='notice'>You begin stitching [user == victim ? "your" : "[victim]'s"] [limb] [limb.artery_name] with [I]...</span>")
	var/time_mod = (user == victim ? 1.5 : 1)

	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()

	if(!do_after(user, base_treat_time * time_mod, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(!I.use(1))
		to_chat(user, "<span class='warning'>There aren't enough stacks of [I.name] to heal \the [src.name]!</span>")
		return

	user.visible_message("<span class='green'>[user] stitches up [victim]'s [limb.artery_name].</span>", \
				"<span class='green'>You stitch up [user == victim ? "your" : "[victim]'s"] [limb.artery_name].</span>")
	var/blood_sutured = I.stop_bleeding / max(1, time_mod)
	blood_time -= blood_sutured
	limb.heal_damage(I.heal_brute, I.heal_burn)
	if(blood_time <= 0)
		to_chat(user, "<span class='nicegreen'>You successfully stitch \the [limb.artery_name] back together.</span>")
		qdel(src)
	else
		try_treating(I, user)

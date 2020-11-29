/datum/wound/artery
	name = "Torn Artery"
	desc = "Patient's artery has been violently slashed open, causing severe hemorrhaging."
	treat_text = "Immediate inciosion of the limb followed by suturing or fix o' veining the torn artery."
	examine_desc = "is bleeding profusely"
	occur_text = "is violently torn, severing an artery"
	sound_effect = 'modular_skyrat/sound/gore/artery.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	wound_type = WOUND_LIST_ARTERY
	threshold_minimum = 100
	threshold_penalty = 0
	infection_chance = 0
	infection_rate = 0
	treatable_by = list(/obj/item/stack/medical/suture, /obj/item/stack/medical/fixovein)
	treat_priority = TRUE
	base_treat_time = 2.5 SECONDS
	var/next_squirt = 0 //kinky.
	var/squirt_delay_min = 8 SECONDS
	var/squirt_delay_max = 12 SECONDS
	var/blood_loss_per_squirt = 3
	descriptive = "An artery is torn!"

/datum/wound/artery/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited)
	if(L)
		name = "Torn [capitalize(L.artery_name)]"
		desc = "Patient's [L.artery_name] has been violently slashed open, causing severe hemorrhaging."
		switch(L.body_zone)
			if(BODY_ZONE_HEAD)
				blood_loss_per_squirt *= 1.5
			if(BODY_ZONE_PRECISE_NECK)
				blood_loss_per_squirt *= 2.5
			if(BODY_ZONE_CHEST)
				blood_loss_per_squirt *= 1
			if(BODY_ZONE_PRECISE_GROIN)
				blood_loss_per_squirt *= 1
			if(BODY_ZONE_L_ARM)
				blood_loss_per_squirt *= 0.75
			if(BODY_ZONE_R_ARM)
				blood_loss_per_squirt *= 0.75
			if(BODY_ZONE_PRECISE_L_HAND)
				blood_loss_per_squirt *= 0.5
			if(BODY_ZONE_PRECISE_R_HAND)
				blood_loss_per_squirt *= 0.5
			if(BODY_ZONE_L_LEG)
				blood_loss_per_squirt *= 0.75
			if(BODY_ZONE_R_LEG)
				blood_loss_per_squirt *= 0.75
			if(BODY_ZONE_PRECISE_L_FOOT)
				blood_loss_per_squirt *= 0.5
			if(BODY_ZONE_PRECISE_R_FOOT)
				blood_loss_per_squirt *= 0.5
	victim.bleed(blood_loss_per_squirt)
	victim.add_splatter_floor(get_turf(victim))
	. = ..()

/datum/wound/artery/handle_process()
	. = ..()
	//No bleeding means we should be gone
	if(blood_loss_per_squirt <= 0)
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

/datum/wound/artery/proc/cum(bleed_mod = 1)
	//People with no pulse can't really squirt blood, can they?
	//Nor can people with no blood
	if(!(victim.stat < DEAD) && !(victim.pulse() < PULSE_NORM) && !(victim.blood_volume <= blood_loss_per_squirt) && (blood_loss_per_squirt >= 1))
		playsound(victim, sound_effect, 75, 0)
		victim.bleed(blood_loss_per_squirt * bleed_mod)
		victim.visible_message("<span class='danger'>Blood squirts from [victim]'s [limb] [limb.artery_name]!</span>", \
						"<span class='userdanger'>Blood squirts from my [limb]'s [limb.artery_name]!</span>")
		var/spray_dir = pick(GLOB.alldirs)
		var/turf/uhoh = get_ranged_target_turf(victim, spray_dir, rand(1, 3))
		var/obj/effect/decal/cleanable/blood/hitsplatter/B = new (get_turf(victim), victim.get_blood_dna_list())
		B.GoTo(uhoh)
		next_squirt = world.time + FLOOR(rand(squirt_delay_min, squirt_delay_max), 10)
	else
		next_squirt = world.time + FLOOR(rand(squirt_delay_min, squirt_delay_max), 10)
		return cum_less(bleed_mod)

/datum/wound/artery/proc/cum_less(bleed_mod = 1)
	//just bleed without being dramatic
	victim.bleed(blood_loss_per_squirt * bleed_mod)

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
	blood_loss_per_squirt -= blood_sutured
	limb.heal_damage(I.heal_brute, I.heal_burn)
	if(blood_loss_per_squirt <= 0)
		to_chat(user, "<span class='nicegreen'>You successfully stitch \the [limb.artery_name] back together.</span>")
		qdel(src)
	else
		try_treating(I, user)

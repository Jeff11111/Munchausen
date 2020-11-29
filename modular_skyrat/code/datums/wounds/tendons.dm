/datum/wound/tendon
	name = "Torn Tendon"
	desc = "Patient's tendon has been violently slashed open, disabling the affected limb."
	treat_text = "Incision of the limb followed by suturing or fix o' veining of the tendon.."
	examine_desc = null
	occur_text = "is violently torn, severing a tendon"
	severity = WOUND_SEVERITY_CRITICAL
	wound_type = WOUND_LIST_TENDON
	viable_zones =	list(BODY_ZONE_PRECISE_NECK, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
	threshold_minimum = 100
	threshold_penalty = 15
	infection_chance = 0
	infection_rate = 0
	treatable_by = list(/obj/item/stack/medical/suture, /obj/item/stack/medical/fixovein)
	treat_priority = TRUE
	base_treat_time = 2.5 SECONDS
	descriptive = "A tendon is torn!"
	disabling = TRUE
	var/datum/speech_mod/aughaughgblerg
	var/torn = 3

/datum/wound/tendon/Destroy()
	. = ..()
	QDEL_NULL(aughaughgblerg)

/datum/wound/tendon/get_examine_description(mob/user)
	return null

/datum/wound/tendon/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited)
	if(L)
		name = "Torn [capitalize(L.tendon_name)]"
		desc = "Patient's [L.tendon_name] has been violently slashed open, disabling the affected limb."
		switch(L.body_zone)
			if(BODY_ZONE_HEAD)
				torn *= 1.5
			if(BODY_ZONE_PRECISE_NECK)
				torn *= 2.5
				aughaughgblerg = new /datum/speech_mod/torn_vocal_cords()
				aughaughgblerg.add_speech_mod(L.owner)
			if(BODY_ZONE_CHEST)
				torn *= 1
			if(BODY_ZONE_PRECISE_GROIN)
				torn *= 1
			if(BODY_ZONE_L_ARM)
				torn *= 0.75
			if(BODY_ZONE_R_ARM)
				torn *= 0.75
			if(BODY_ZONE_PRECISE_L_HAND)
				torn *= 0.5
			if(BODY_ZONE_PRECISE_R_HAND)
				torn *= 0.5
			if(BODY_ZONE_L_LEG)
				torn *= 0.75
			if(BODY_ZONE_R_LEG)
				torn *= 0.75
			if(BODY_ZONE_PRECISE_L_FOOT)
				torn *= 0.5
			if(BODY_ZONE_PRECISE_R_FOOT)
				torn *= 0.5
	. = ..()

/datum/wound/tendon/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/suture) || istype(I, /obj/item/stack/medical/fixovein))
		attempt_suture(I, user)

/datum/wound/tendon/proc/attempt_suture(obj/item/stack/medical/I, mob/user)
	if(!locate(/datum/wound/slash/critical/incision) in limb.wounds)
		to_chat(user, "<span class='notice'>I must incise [limb] to treat it's torn [limb.tendon_name]!</span>")
		return
	user.visible_message("<span class='notice'>[user] begins stitching [victim]'s [limb] [limb.tendon_name] with [I]...</span>", \
					"<span class='notice'>You begin stitching [user == victim ? "your" : "[victim]'s"] [limb] [limb.tendon_name] with [I]...</span>")
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

	user.visible_message("<span class='green'>[user] stitches up [victim]'s [limb.tendon_name].</span>", \
				"<span class='green'>You stitch up [user == victim ? "your" : "[victim]'s"] [limb.tendon_name].</span>")
	var/sutured = I.stop_bleeding / max(1, time_mod)
	torn -= sutured
	limb.heal_damage(I.heal_brute, I.heal_burn)
	if(torn <= 0)
		to_chat(user, "<span class='nicegreen'>You successfully stitch \the [limb.tendon_name] back together.</span>")
		qdel(src)
	else
		try_treating(I, user)

/obj/item/bodypart/r_leg
	name = "right leg"
	desc = "You put your right leg in, your right leg out. In, out, in, out, \
		shake it all about. And apparently then it detaches.\n\
		The hokey pokey has certainly changed a lot since space colonisation."
	icon_state = "default_human_r_leg"
	attack_verb = list("kicked", "stomped")
	max_damage = 50
	max_stamina_damage = 50
	body_zone = BODY_ZONE_R_LEG
	body_part = LEG_RIGHT
	body_damage_coeff = 0.75
	px_x = 2
	px_y = 12
	stam_heal_tick = 4
	amputation_point = "groin"
	parent_bodyzone = BODY_ZONE_PRECISE_GROIN
	children_zones = list(BODY_ZONE_PRECISE_R_FOOT)
	heal_zones = list(BODY_ZONE_PRECISE_R_FOOT)
	specific_locations = list("inner right thigh", "outer right calf", "outer right hip", "right kneecap", "lower right shin")
	max_cavity_size = WEIGHT_CLASS_SMALL
	dismember_mod = 0.8
	miss_entirely_prob = 12
	zone_prob = 65
	extra_zone_prob = 35
	amputation_point = "right hip"
	joint_name = "right knee"
	tendon_name = "cruciate ligament"
	artery_name = "femoral artery"

/obj/item/bodypart/r_leg/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_R_LEG))
		return BODYPART_DISABLED_PARALYSIS
	. = ..()

/obj/item/bodypart/r_leg/set_disabled(new_disabled)
	. = ..()
	if(!. || owner.stat >= UNCONSCIOUS)
		return
	switch(disabled)
		if(BODYPART_DISABLED_PAIN)
			to_chat(owner, "<span class='userdanger'>The pain in my [name] is too agonizing!</span>")
		if(BODYPART_DISABLED_DAMAGE)
			owner.emote("scream")
			to_chat(owner, "<span class='userdanger'>My [name] is too damaged to function!</span>")
		if(BODYPART_DISABLED_PARALYSIS)
			to_chat(owner, "<span class='userdanger'>I can't feel my [name]!</span>")

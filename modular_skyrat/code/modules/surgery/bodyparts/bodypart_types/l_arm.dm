/obj/item/bodypart/l_arm
	name = "left arm"
	desc = "Did you know that the word 'sinister' stems originally from the \
		Latin 'sinestra' (left hand), because the left hand was supposed to \
		be possessed by the devil? This arm appears to be possessed by no \
		one though."
	icon_state = "default_human_l_arm"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	max_stamina_damage = 50
	body_zone = BODY_ZONE_L_ARM
	body_part = ARM_LEFT
	body_damage_coeff = 0.75
	px_x = -6
	px_y = 0
	stam_heal_tick = 4
	amputation_point = "left shoulder"
	children_zones = list(BODY_ZONE_PRECISE_L_HAND)
	heal_zones = list(BODY_ZONE_PRECISE_L_HAND)
	specific_locations = list("outer left forearm", "inner left wrist", "outer left wrist", "left elbow", "left bicep", "left shoulder")
	max_cavity_size = WEIGHT_CLASS_SMALL
	dismember_mod = 0.8
	miss_entirely_prob = 12
	zone_prob = 65
	extra_zone_prob = 35
	amputation_point = "left shoulder"
	joint_name = "left elbow"
	tendon_name = "palmaris longus tendon"
	artery_name = "basilic vein"

/obj/item/bodypart/l_arm/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

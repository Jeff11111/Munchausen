/obj/item/bodypart/r_arm
	name = "right arm"
	desc = "Over 87% of humans are right handed. That figure is much lower \
		among humans missing their right arm."
	icon_state = "default_human_r_hand"
	attack_verb = list("slapped", "punched")
	max_damage = 50
	max_stamina_damage = 50
	body_zone = BODY_ZONE_R_ARM
	body_part = ARM_RIGHT
	body_damage_coeff = 0.75
	px_x = 6
	px_y = 0
	stam_heal_tick = STAM_RECOVERY_LIMB
	amputation_point = "right shoulder"
	children_zones = list(BODY_ZONE_PRECISE_R_HAND)
	heal_zones = list(BODY_ZONE_PRECISE_R_HAND)
	specific_locations = list("outer right forearm", "inner right wrist", "outer right wrist", "right elbow", "right bicep", "right shoulder")
	max_cavity_size = WEIGHT_CLASS_SMALL
	dismember_mod = 0.8
	miss_entirely_prob = 12
	zone_prob = 65
	extra_zone_prob = 35
	amputation_point = "right shoulder"
	joint_name = "right elbow"
	tendon_name = "palmaris longus tendon"
	artery_name = "basilic vein"

/obj/item/bodypart/r_arm/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
		return BODYPART_DISABLED_PARALYSIS
	. = ..()

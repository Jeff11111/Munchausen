/obj/item/bodypart/chest
	name = "chest"
	desc = "The very base of a human body - The torso, or chest. This one has lost all appendages..."
	icon_state = "default_human_chest"
	max_damage = 100
	max_stamina_damage = 100
	body_zone = BODY_ZONE_CHEST
	body_part = CHEST
	px_x = 0
	px_y = 0
	stam_damage_coeff = 1
	children_zones = list(BODY_ZONE_PRECISE_NECK, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM)
	heal_zones = list(BODY_ZONE_PRECISE_GROIN)
	specific_locations = list("upper chest", "lower abdomen", "midsection", "collarbone", "lower back")
	max_cavity_size = WEIGHT_CLASS_BULKY
	dismember_mod = 0.3
	miss_entirely_prob = 5
	zone_prob = 80
	extra_zone_prob = 20
	amputation_point = "spine"
	joint_name = "ribs"
	encased = "ribcage"
	artery_name = "aorta"
	cavity_name = "thoracic"

/obj/item/bodypart/chest/can_dismember(obj/item/I)
	return FALSE

/obj/item/bodypart/chest/drop_limb(special, ignore_children = FALSE, dismembered = FALSE, destroyed = FALSE, wounding_type = WOUND_SLASH)
	if(special)
		. = ..()

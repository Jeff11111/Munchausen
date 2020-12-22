/obj/item/bodypart/l_foot
	name = "left foot"
	desc = "You feel like someones gonna be needing a peg-leg."
	icon_state = "default_human_r_foot"
	attack_verb = list("kicked", "stomped")
	max_damage = 30
	max_stamina_damage = 30
	body_part = FOOT_LEFT
	body_damage_coeff = 0.75
	px_x = -2
	px_y = 9
	stam_heal_tick = 4
	children_zones = list()
	amputation_point = "right leg"
	parent_bodyzone = BODY_ZONE_L_LEG
	heal_zones = list(BODY_ZONE_L_LEG)
	specific_locations = list("left sole", "left ankle", "left heel")
	max_cavity_size = WEIGHT_CLASS_TINY
	miss_entirely_prob = 15
	zone_prob = 50
	extra_zone_prob = 50
	amputation_point = "left ankle"
	joint_name = "left ankle"
	tendon_name = "achilles tendon"
	artery_name = "arcuate artery"

/obj/item/bodypart/l_foot/drop_limb(special, ignore_children = FALSE, dismembered = FALSE, destroyed = FALSE, wounding_type = WOUND_SLASH) //copypasta
	if(owner && !special)
		if(owner.legcuffed)
			owner.legcuffed.forceMove(owner.drop_location())
			owner.legcuffed.dropped(owner)
			owner.legcuffed = null
			owner.update_inv_legcuffed()
		if(owner.shoes)
			owner.dropItemToGround(owner.shoes, TRUE)
	. = ..()

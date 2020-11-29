/obj/item/bodypart/neck
	name = "neck"
	desc = "Whoever did this was a real cut-throat."
	max_damage = 30
	max_stamina_damage = 30
	body_zone = BODY_ZONE_PRECISE_NECK
	body_part = NECK
	children_zones = list(BODY_ZONE_HEAD)
	w_class = WEIGHT_CLASS_BULKY
	stam_heal_tick = 2
	stam_damage_coeff = 1
	throw_range = 5
	px_x = 0
	px_y = -8
	wound_resistance = -15
	dismember_sounds = list(
		'modular_skyrat/sound/gore/head_explodie1.ogg',
		'modular_skyrat/sound/gore/head_explodie2.ogg',
		'modular_skyrat/sound/gore/head_explodie3.ogg',
		'modular_skyrat/sound/gore/head_explodie4.ogg',
	)
	miss_entirely_prob = 40
	zone_prob = 40
	extra_zone_prob = 30
	max_cavity_size = WEIGHT_CLASS_TINY
	amputation_point = "trachea"
	joint = "cervical spine"
	tendon_name = "vocal cords"
	artery_name = "carotid artery"

/obj/item/bodypart/neck/get_limb_icon(dropped)
	. = ..()
	if(dropped)
		for(var/obj/item/bodypart/head/nohead in src)
			. |= nohead.get_limb_icon(TRUE)
			break

/obj/item/bodypart/neck/update_limb(dropping_limb, mob/living/carbon/source)
	. = ..()
	if(!owner)
		for(var/obj/item/bodypart/head/nohead in src)
			name = "[nohead.name]'s neck"
			break
	else
		name = initial(name)

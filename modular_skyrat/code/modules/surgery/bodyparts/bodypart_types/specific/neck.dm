/obj/item/bodypart/neck
	name = "neck"
	desc = "Whoever did this was a real cut-throat."
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "vertebrae"
	max_damage = 30
	max_stamina_damage = 30
	dismember_bodyzone = BODY_ZONE_CHEST
	body_zone = BODY_ZONE_PRECISE_NECK
	body_part = NECK
	children_zones = list(BODY_ZONE_HEAD)
	parent_bodyzone = BODY_ZONE_CHEST
	w_class = WEIGHT_CLASS_BULKY
	stam_heal_tick = 2
	stam_damage_coeff = 1
	throw_range = 4
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
	zone_prob = 25
	extra_zone_prob = 45
	max_cavity_size = WEIGHT_CLASS_TINY
	amputation_point = "trachea"
	joint_name = "cervical spine"
	tendon_name = "vocal cords"
	artery_name = "carotid artery"

/obj/item/bodypart/neck/get_limb_icon(dropped)
	. = ..()
	if(dropped)
		for(var/obj/item/bodypart/head/nohead in src)
			. |= nohead.get_limb_icon(TRUE)
			return
		. |= mutable_appearance(icon, initial(icon_state), -BODYPARTS_LAYER, color = src.color)

/obj/item/bodypart/neck/update_icon_dropped()
	if(locate(/obj/item/bodypart/head) in src)
		return ..()
	cut_overlays()
	icon_state = initial(icon_state)//default to dismembered sprite

/obj/item/bodypart/neck/update_limb(dropping_limb, mob/living/carbon/source)
	. = ..()
	if(!owner)
		for(var/obj/item/bodypart/head/nohead in src)
			name = "[nohead.name]'s neck"
			break
	else
		name = initial(name)

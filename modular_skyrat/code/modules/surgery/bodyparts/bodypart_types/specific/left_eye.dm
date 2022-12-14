#define BLURRY_VISION_ONE	1
#define BLURRY_VISION_TWO	2
#define BLIND_VISION_THREE	3

/obj/item/bodypart/left_eye
	name = "left eye"
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "eye"
	desc = "Sightless, until the eyes reappear."
	body_zone = BODY_ZONE_PRECISE_LEFT_EYE
	body_part = LEFT_EYE
	w_class = WEIGHT_CLASS_TINY
	parent_bodyzone = BODY_ZONE_HEAD
	stam_heal_tick = 0
	stam_damage_coeff = 0
	throw_range = 7
	px_x = 0
	px_y = 0
	wound_resistance = -20
	max_damage = 20
	max_stamina_damage = 20
	dismember_sounds = list('modular_skyrat/sound/gore/severed.ogg')
	throw_range = 7
	miss_entirely_prob = 40
	zone_prob = 20
	extra_zone_prob = 70
	max_cavity_size = 0
	amputation_point = "eyesocket"
	tendon_name = "rectus"
	artery_name = "central retinal artery"
	limb_flags = 0
	stam_heal_tick = 2
	var/sight_flags = 0
	var/see_in_dark = 2
	var/tint = 0
	var/eye_color = "" //set to a hex code to override a mob's eye color
	var/old_eye_color = "#000000"
	var/flash_protect = 0
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha
	var/eye_damaged	= 0	//indicates that our eyes are undergoing some level of negative effect

/obj/item/bodypart/left_eye/get_mangled_state()
	return (..() | BODYPART_MANGLED_BONE)

/obj/item/bodypart/left_eye/get_limb_icon(dropped)
	if(dropped && !istype(loc, /obj/item/bodypart))
		. = list()
		. += mutable_appearance('modular_skyrat/icons/obj/surgery.dmi', "[initial(icon_state)]", GAME_PLANE, color = src.color)
	else
		return ..()

/obj/item/bodypart/left_eye/update_icon_dropped()
	if(istype(loc, /obj/item/bodypart)) //we're inside a head or neck
		return ..()
	cut_overlays()
	icon_state = initial(icon_state)//default to dismembered eye sprite
	var/mutable_appearance/iris = mutable_appearance(icon, "eye-iris", layer+1, GAME_PLANE, plane, eye_color || old_eye_color)
	add_overlay(iris)
	return

/obj/item/bodypart/left_eye/attach_limb(mob/living/carbon/C, special, ignore_parent_restriction)
	. = ..()
	if(!.)
		return
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		old_eye_color = H.left_eye_color
		if(eye_color)
			H.left_eye_color = eye_color
		else
			eye_color = H.left_eye_color
		H.dna?.species?.handle_body(H) //regenerate eyeballs overlays
	check_damage()
	C.update_tint()
	C.update_sight()
	C.update_eyes()

/obj/item/bodypart/left_eye/drop_limb(special, ignore_children, dismembered, destroyed, wounding_type)
	var/mob/living/carbon/C = owner
	. = ..()
	if(QDELETED(C))
		return
	if(ishuman(C) && eye_color && old_eye_color)
		var/mob/living/carbon/human/H = C
		H.left_eye_color = old_eye_color
		if(!special)
			H.dna.species.handle_body(H)
	C.update_tint()
	C.update_sight()
	C.update_eyes()

/obj/item/bodypart/left_eye/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE, spread_damage = TRUE, pain = 0, toxin = 0, clone = 0)
	. = ..()
	check_damage()

/obj/item/bodypart/left_eye/heal_damage(brute, burn, stamina, only_robotic, only_organic, updating_health, pain, toxin, clone)
	. = ..()
	check_damage()

/obj/item/bodypart/left_eye/set_disabled(new_disabled)
	. = ..()
	check_damage()

/obj/item/bodypart/left_eye/on_transfer_to_limb(obj/item/bodypart/BP)
	if(istype(BP, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/HD = BP
		HD.left_eye = src
		return TRUE
	else
		return ..()

/obj/item/bodypart/left_eye/proc/check_damage()
	if(!owner)
		return

	var/old_dam = eye_damaged
	switch(get_damage(include_pain = TRUE))
		if(-INFINITY to 5)
			eye_damaged = FALSE
		if(5 to 10)
			eye_damaged = BLURRY_VISION_ONE
		if(10 to 15)
			eye_damaged = BLURRY_VISION_TWO
		if(15 to INFINITY)
			eye_damaged = BLIND_VISION_THREE
		else
			eye_damaged = FALSE
	if(is_disabled() || current_gauze || grasped_by)
		eye_damaged = BLIND_VISION_THREE
	if(owner && (old_dam != eye_damaged))
		owner.update_eyes()
	return eye_damaged

#undef BLURRY_VISION_ONE
#undef BLURRY_VISION_TWO
#undef BLIND_VISION_THREE

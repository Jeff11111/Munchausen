#define BLURRY_VISION_ONE	1
#define BLURRY_VISION_TWO	2
#define BLIND_VISION_THREE	3

/obj/item/bodypart/right_eye
	name = "right eye"
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "eye"
	desc = "Sightless, until the eyes reappear."
	body_zone = BODY_ZONE_PRECISE_RIGHT_EYE
	body_part = RIGHT_EYE
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
	miss_entirely_prob = 50
	zone_prob = 25
	extra_zone_prob = 65
	max_cavity_size = 0
	amputation_point = "eyesocket"
	tendon_name = "rectus"
	artery_name = "central retinal artery"
	var/sight_flags = 0
	var/see_in_dark = 2
	var/tint = 0
	var/eye_color = "" //set to a hex code to override a mob's eye color
	var/old_eye_color = "fff"
	var/flash_protect = 0
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha
	var/eye_damaged	= FALSE	//indicates that our eyes are undergoing some level of negative effect

/obj/item/bodypart/right_eye/get_mangled_state()
	return BODYPART_MANGLED_BOTH

/obj/item/bodypart/right_eye/can_disembowel(obj/item/I)
	return FALSE

/obj/item/bodypart/right_eye/get_limb_icon(dropped)
	. = ..()
	if(dropped)
		. = list()
		. += mutable_appearance('modular_skyrat/icons/obj/surgery.dmi', "[initial(icon_state)]", layer, plane, color)

/obj/item/bodypart/right_eye/update_icon_dropped()
	cut_overlays()
	icon_state = initial(icon_state)//default to dismembered eye sprite
	return

/obj/item/bodypart/right_eye/attach_limb(mob/living/carbon/C, special, ignore_parent_restriction)
	. = ..()
	if(!.)
		return
	switch(eye_damaged)
		if(BLURRY_VISION_ONE, BLURRY_VISION_TWO)
			owner.overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, eye_damaged)
		if(BLIND_VISION_THREE)
			owner.become_blind(EYE_DAMAGE)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		old_eye_color = H.right_eye_color
		if(eye_color)
			H.right_eye_color = eye_color
		else
			eye_color = H.right_eye_color
		H.dna?.species?.handle_body(H) //regenerate eyeballs overlays
	C.update_tint()
	owner.update_sight()

/obj/item/bodypart/right_eye/drop_limb(special, ignore_children, dismembered, destroyed, wounding_type)
	var/mob/living/carbon/C = owner
	. = ..()
	if(QDELETED(C) || !.)
		return
	switch(eye_damaged)
		if(BLURRY_VISION_ONE, BLURRY_VISION_TWO)
			C.clear_fullscreen("eye_damage")
		if(BLIND_VISION_THREE)
			C.cure_blind(EYE_DAMAGE)
	if(ishuman(C) && eye_color && old_eye_color)
		var/mob/living/carbon/human/H = C
		H.right_eye_color = old_eye_color
		if(!special)
			H.dna.species.handle_body(H)
	if(!special)
		C.update_tint()
		C.update_sight()

/obj/item/bodypart/right_eye/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE, spread_damage = TRUE, pain = 0, toxin = 0, clone = 0)
	. = ..()
	if(!.)
		return
	var/old_damaged = eye_damaged
	switch(brute_dam + burn_dam)
		if(max_damage to INFINITY)
			eye_damaged = BLIND_VISION_THREE
		if(max_damage/2 to max_damage)
			eye_damaged = BLURRY_VISION_TWO
		if(max_damage/4 to max_damage/2)
			eye_damaged = BLURRY_VISION_ONE
		else
			eye_damaged = FALSE
	if(eye_damaged == old_damaged || !owner)
		return
	if(old_damaged == BLIND_VISION_THREE)
		owner.cure_blind(EYE_DAMAGE)
	else if(eye_damaged == BLIND_VISION_THREE)
		owner.become_blind(EYE_DAMAGE)
	if(eye_damaged && eye_damaged != BLIND_VISION_THREE)
		owner.overlay_fullscreen("eye_damage", /obj/screen/fullscreen/impaired, eye_damaged)
	else
		owner.clear_fullscreen("eye_damage")

/obj/item/bodypart/right_eye/on_transfer_to_limb(obj/item/bodypart/BP)
	if(istype(BP, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/HD = BP
		HD.right_eye = src
		return TRUE
	else
		return ..()

#undef BLURRY_VISION_ONE
#undef BLURRY_VISION_TWO
#undef BLIND_VISION_THREE

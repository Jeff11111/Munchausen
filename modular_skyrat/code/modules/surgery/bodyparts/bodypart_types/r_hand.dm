/obj/item/bodypart/r_hand
	name = "right hand"
	desc = "It probably wasn't the right hand."
	icon_state = "default_human_r_hand"
	aux_icons = list(BODY_ZONE_PRECISE_R_HAND = HANDS_PART_LAYER, "r_hand_behind" = BODY_BEHIND_LAYER)
	attack_verb = list("slapped", "punched")
	max_damage = 30
	max_stamina_damage = 30
	body_zone = BODY_ZONE_PRECISE_R_HAND
	body_part = HAND_RIGHT
	held_index = 2
	px_x = 6
	px_y = -3
	stam_heal_tick = 4
	parent_bodyzone = BODY_ZONE_R_ARM
	heal_zones = list(BODY_ZONE_R_ARM)
	amputation_point = "right arm"
	children_zones = list()
	specific_locations = list("right palm", "right back palm")
	max_cavity_size = WEIGHT_CLASS_TINY
	miss_entirely_prob = 15
	zone_prob = 50
	extra_zone_prob = 50
	amputation_point = "right wrist"
	joint_name = "right wrist"
	tendon_name = "carpal ligament"
	artery_name = "deep palmar arch artery"

/obj/item/bodypart/r_hand/is_disabled()
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS_L_ARM))
		return BODYPART_DISABLED_PARALYSIS
	return ..()

/obj/item/bodypart/r_hand/set_disabled(new_disabled)
	. = ..()
	if(!.)
		return
	if(owner.stat < UNCONSCIOUS)
		switch(disabled)
			if(BODYPART_DISABLED_PAIN)
				to_chat(owner, "<span class='userdanger'>The pain in my [name] is too agonizing!</span>")
			if(BODYPART_DISABLED_DAMAGE)
				owner.emote("scream")
				to_chat(owner, "<span class='userdanger'>My [name] is too damaged to function!</span>")
			if(BODYPART_DISABLED_PARALYSIS)
				to_chat(owner, "<span class='userdanger'>I can't feel my [name]!</span>")
	if(held_index)
		owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	if(owner.hud_used)
		var/obj/screen/inventory/hand/L = owner.hud_used.hand_slots["[held_index]"]
		if(L)
			L.update_icon()

/obj/item/bodypart/r_hand/drop_limb(special, ignore_children = FALSE, dismembered = FALSE, destroyed = FALSE, wounding_type = WOUND_SLASH)
	var/mob/living/carbon/C = owner
	. = ..()
	if(C && !special)
		if(C.handcuffed)
			C.handcuffed.forceMove(drop_location())
			C.handcuffed.dropped(C)
			C.handcuffed = null
			C.update_handcuffed()
		if(C.hud_used)
			var/obj/screen/inventory/hand/R = C.hud_used.hand_slots["[held_index]"]
			if(R)
				R.update_icon()
		if(C.gloves)
			C.dropItemToGround(C.gloves, TRUE)
		C.update_inv_gloves() //to remove the bloody hands overlay

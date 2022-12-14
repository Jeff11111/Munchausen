// The shattered remnants of your broken limbs fill you with determination!
/obj/screen/alert/status_effect/determined
	name = "Determined"
	desc = "The serious wounds you've sustained have put your body into fight-or-flight mode! Now's the time to look for an exit!"
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "determination"

/datum/status_effect/determined
	id = "determined"
	alert_type = null

/datum/status_effect/determined/on_apply()
	. = ..()
	owner.emote("gasp")

/datum/status_effect/determined/on_remove()
	owner.emote("gasp")
	to_chat(owner, "<span class='warning'><b>Your adrenaline rush dies off, and the pain from your wounds come aching back in...</b></span>")
	return ..()

/datum/status_effect/limp
	id = "limp"
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = 10
	alert_type = null
	var/msg_stage = 0//so you dont get the most intense messages immediately
	/// The left leg of the limping person
	var/obj/item/bodypart/l_leg/left_leg
	/// The right leg of the limping person
	var/obj/item/bodypart/r_leg/right_leg
	/// The left foot of the limping person
	var/obj/item/bodypart/l_foot/left_foot
	/// The right foot of the limping person
	var/obj/item/bodypart/r_foot/right_foot
	/// Which leg/foot we're limping with next
	var/obj/item/bodypart/next_foot
	/// How many deciseconds we limp for on the left leg
	var/slowdown_left = 0
	/// How many deciseconds we limp for on the right leg
	var/slowdown_right = 0

/datum/status_effect/limp/on_apply()
	. = ..()
	if(!owner || !iscarbon(owner))
		return FALSE
	var/mob/living/carbon/C = owner
	left_leg = C.get_bodypart(BODY_ZONE_L_LEG)
	right_leg = C.get_bodypart(BODY_ZONE_R_LEG)
	left_foot = C.get_bodypart(BODY_ZONE_PRECISE_L_FOOT)
	right_foot = C.get_bodypart(BODY_ZONE_PRECISE_R_FOOT)
	RegisterSignal(C, COMSIG_MOVABLE_MOVED, .proc/check_step)
	RegisterSignal(C, list(COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB), .proc/update_limp)
	update_limp()
	return TRUE

/datum/status_effect/limp/on_remove()
	. = ..()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_CARBON_GAIN_WOUND, COMSIG_CARBON_LOSE_WOUND, COMSIG_CARBON_ATTACH_LIMB, COMSIG_CARBON_REMOVE_LIMB))

/obj/screen/alert/status_effect/limp
	name = "Limping"
	desc = "One or more of your legs has been wounded, slowing down steps with that leg! Get it fixed, or at least splinted!"

/datum/status_effect/limp/proc/check_step(mob/whocares, OldLoc, Dir, forced)
	if(!owner.client || !(owner.mobility_flags & MOBILITY_STAND) || !owner.has_gravity() || (owner.movement_type & FLYING) || forced)
		return
	var/determined_mod = 1
	if(owner.has_status_effect(STATUS_EFFECT_DETERMINED))
		determined_mod = 0.65
	if(next_foot == right_foot)
		owner.client.move_delay += slowdown_right * determined_mod
		next_foot = left_foot
	else if(next_foot == left_foot)
		owner.client.move_delay += slowdown_left * determined_mod
		next_foot = right_foot

/datum/status_effect/limp/proc/update_limp()
	var/mob/living/carbon/C = owner
	left_leg = C.get_bodypart(BODY_ZONE_L_LEG)
	right_leg = C.get_bodypart(BODY_ZONE_R_LEG)
	left_foot = C.get_bodypart(BODY_ZONE_PRECISE_L_FOOT)
	right_foot = C.get_bodypart(BODY_ZONE_PRECISE_R_FOOT)

	if(!left_foot && !right_foot)
		C.remove_status_effect(src)
		return

	slowdown_left = 0
	slowdown_right = 0

	if(left_leg)
		for(var/thing in left_leg.wounds)
			var/datum/wound/W = thing
			slowdown_left += W.limp_slowdown

	if(right_leg)
		for(var/thing in right_leg.wounds)
			var/datum/wound/W = thing
			slowdown_right += W.limp_slowdown

	if(left_foot)
		for(var/thing in left_foot.wounds)
			var/datum/wound/W = thing
			slowdown_left += W.limp_slowdown

	if(right_foot)
		for(var/thing in right_foot.wounds)
			var/datum/wound/W = thing
			slowdown_right += W.limp_slowdown
	
	// this handles losing your leg with the limp and the other one being in good shape as well
	if(!slowdown_left && !slowdown_right)
		C.remove_status_effect(src)
		return

/////////////////////////
//////// WOUNDS /////////
/////////////////////////

// wound alert
/obj/screen/alert/status_effect/wound
	name = "Wounded"
	desc = "Your body has sustained serious damage, click here to inspect yourself."

/obj/screen/alert/status_effect/wound/Click()
	var/mob/living/carbon/C = usr
	C.check_self_for_injuries()

/obj/screen/alert/status_effect/wound/blunt
	name = "Bashed"
	desc = "Your body has sustained serious bruises, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_blunt"

/obj/screen/alert/status_effect/wound/slash
	name = "Slashed"
	desc = "Your body has sustained serious slashes, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_slash"

/obj/screen/alert/status_effect/wound/pierce
	name = "Pierced"
	desc = "Your body has sustained serious piercing, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_pierce"

/obj/screen/alert/status_effect/wound/burn
	name = "Burned"
	desc = "Your body has sustained serious burns, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_burn"

/obj/screen/alert/status_effect/wound/loss
	name = "Dismembered"
	desc = "Your body has suffered the loss of one or more limbs, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_dismember"

/obj/screen/alert/status_effect/wound/bleed
	name = "Bleeding"
	desc = "One or more of your limbs are bleeding profusely, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_bleeding"

/obj/screen/alert/status_effect/wound/bleed/mechanical
	name = "Leaking"
	desc = "One or more of your limbs are leaking profusely, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_bleeding_metal"

/obj/screen/alert/status_effect/wound/bone
	name = "Bone Damage"
	desc = "One or more of your limbs have suffered a bone injury, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_bone"

/obj/screen/alert/status_effect/wound/bone/mechanical
	name = "Bent"
	desc = "One or more of your limbs have suffered bending, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_bone_metal"

/obj/screen/alert/status_effect/wound/sepsis
	name = "Sepsis"
	desc = "One or more of your limbs are suffering with an infection, click here to inspect yourself."
	icon = 'modular_skyrat/icons/mob/screen/screen_alert.dmi'
	icon_state = "wound_sepsis"

// wound status effect base
/datum/status_effect/wound
	id = "wound"
	status_type = STATUS_EFFECT_MULTIPLE
	var/obj/item/bodypart/linked_limb
	var/datum/wound/linked_wound
	alert_type = null

/datum/status_effect/wound/on_creation(mob/living/new_owner, incoming_wound)
	. = ..()
	var/datum/wound/W = incoming_wound
	if(istype(W))
		linked_wound = W
		linked_limb = linked_wound.limb

/datum/status_effect/wound/on_remove()
	..()
	linked_wound = null
	linked_limb = null
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_WOUND)

/datum/status_effect/wound/on_apply()
	..()
	if(!iscarbon(owner))
		return FALSE
	RegisterSignal(owner, COMSIG_CARBON_LOSE_WOUND, .proc/check_remove)
	return TRUE

/// check if the wound getting removed is the wound we're tied to
/datum/status_effect/wound/proc/check_remove(mob/living/L, datum/wound/W)
	if(W == linked_wound)
		qdel(src)

// blunt
/datum/status_effect/wound/blunt/interact_speed_modifier()
	var/mob/living/carbon/C = owner

	if(C.get_active_hand() == linked_limb)
		to_chat(C, "<span class='warning'>The [lowertext(linked_wound)] in your [linked_limb.name] slows your progress!</span>")
		return linked_wound.interaction_efficiency_penalty

	return 1

/datum/status_effect/wound/blunt/nextmove_modifier()
	var/mob/living/carbon/C = owner

	if(C.get_active_hand() == linked_limb)
		return linked_wound.interaction_efficiency_penalty

	return 1

/datum/status_effect/wound/blunt/moderate
	id = "disjoint"

/datum/status_effect/wound/blunt/severe
	id = "hairline"

/datum/status_effect/wound/blunt/critical
	id = "compound"

// slash
/datum/status_effect/wound/slash/moderate
	id = "abrasion"

/datum/status_effect/wound/slash/severe
	id = "laceration"

/datum/status_effect/wound/slash/critical
	id = "avulsion"

// pierce
/datum/status_effect/wound/pierce/moderate
	id = "breakage"

/datum/status_effect/wound/pierce/severe
	id = "puncture"

/datum/status_effect/wound/pierce/critical
	id = "rupture"

// dismemberment
/datum/status_effect/wound/loss
	id = "loss"

// burns
/datum/status_effect/wound/burn/moderate
	id = "seconddeg"

/datum/status_effect/wound/burn/severe
	id = "thirddeg"

/datum/status_effect/wound/burn/critical
	id = "fourthdeg"

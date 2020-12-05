//Augmented Eyesight: Gives you X-ray vision or protection from flashes. Also, high DNA cost because of how powerful it is.
//Possible todo: make a custom message for directing a penlight/flashlight at the eyes - not sure what would display though.

/obj/effect/proc_holder/changeling/augmented_eyesight
	name = "Augmented Eyesight"
	desc = "Creates heat receptors in our eyes and dramatically increases light sensing ability, or protects your vision from flashes."
	helptext = "Grants us thermal vision or flash protection. We will become a lot more vulnerable to flash-based devices while thermal vision is active."
	chemical_cost = 0
	dna_cost = 2 //Would be 1 without thermal vision
	active = FALSE
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "ling_augmented_eyesight"
	action_background_icon_state = "bg_ling"

/obj/effect/proc_holder/changeling/augmented_eyesight/on_purchase(mob/user) //The ability starts inactive, so we should be protected from flashes.
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/C = user
	var/obj/item/bodypart/left_eye/LE = C.get_bodypart(BODY_ZONE_PRECISE_LEFT_EYE)
	var/obj/item/bodypart/left_eye/RE = C.get_bodypart(BODY_ZONE_PRECISE_RIGHT_EYE)
	if(LE || RE)
		LE?.flash_protect = 2
		RE?.flash_protect = 2
		to_chat(user, "We adjust our eyes to protect them from bright lights.")
		action.Grant(user)
	else
		to_chat(user, "We can't adjust our eyes if we don't have any!")

/obj/effect/proc_holder/changeling/augmented_eyesight/sting_action(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/mob/living/carbon/C = user
	var/obj/item/bodypart/left_eye/LE = C.get_bodypart(BODY_ZONE_PRECISE_LEFT_EYE)
	var/obj/item/bodypart/left_eye/RE = C.get_bodypart(BODY_ZONE_PRECISE_RIGHT_EYE)
	if(LE || RE)
		if(!active)
			ADD_TRAIT(user, TRAIT_THERMAL_VISION, CHANGELING_TRAIT)
			LE?.flash_protect = -1 //Adjust the user's eyes' flash protection
			RE?.flash_protect = -1
			to_chat(user, "We adjust our eyes to sense prey through walls.")
			active = TRUE //Defined in code/modules/spells/spell.dm
		else
			REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, CHANGELING_TRAIT)
			LE?.flash_protect = 2 //Adjust the user's eyes' flash protection
			RE?.flash_protect = 2
			to_chat(user, "We adjust our eyes to protect them from bright lights.")
			active = FALSE
		user.update_sight()
	else
		to_chat(user, "We can't adjust our eyes if we don't have any!")

	return 1

/obj/effect/proc_holder/changeling/augmented_eyesight/on_refund(mob/user) //Get rid of X-ray vision and flash protection when the user refunds this ability
	if(!iscarbon(user))
		return FALSE
	action.Remove(user)
	REMOVE_TRAIT(user, TRAIT_THERMAL_VISION, CHANGELING_TRAIT)
	var/mob/living/carbon/C = user
	var/obj/item/bodypart/left_eye/LE = C.get_bodypart(BODY_ZONE_PRECISE_LEFT_EYE)
	var/obj/item/bodypart/left_eye/RE = C.get_bodypart(BODY_ZONE_PRECISE_RIGHT_EYE)
	LE?.flash_protect = initial(LE?.flash_protect)
	RE?.flash_protect = initial(RE?.flash_protect)
	user.update_sight()

/mob/living/proc/has_hands()
	return FALSE

/mob/living/has_hands()
	return TRUE//(can_use_hand("l_hand") || can_use_hand("r_hand"))

/mob/living/proc/has_mouth()
	return TRUE

/mob/living/proc/mouth_is_free()
	return TRUE

/mob/living/proc/foot_is_free()
	return TRUE

/mob/living/carbon/human/has_mouth()
	var/obj/item/bodypart/head/headass
	for(var/obj/item/bodypart/head/shoeonhead in bodyparts)
		headass = shoeonhead
	if(headass)
		return TRUE
	return FALSE

/mob/living/mouth_is_free()
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		var/obj/item/clothing/mask/mask = H.wear_mask
		if(!mask || mask.mask_adjusted)
			return TRUE
	else
		return TRUE

/mob/living/foot_is_free()
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		return !H.shoes
	else
		return TRUE

/mob/living/proc/do_blowsmoke(mob/living/partner)
	to_chat(src, "<span class='warning'>You aren't even humanoid. How are you hoping to accomplish this?</span>")
	return

/mob/living/carbon/human/do_blowsmoke(mob/living/partner) //we have to make it human only for the wear_mask check
    var/obj/item/clothing/mask/cigarette/held_cig = get_active_held_item()
    var/obj/item/clothing/mask/vape/held_vape = get_active_held_item()
    var/smoking_cig = FALSE
    if(istype(wear_mask, /obj/item/clothing/mask/cigarette))
        var/obj/item/clothing/mask/cigarette/worn_cig = wear_mask
        if(worn_cig.lit)
            smoking_cig = TRUE
    if(istype(wear_mask, /obj/item/clothing/mask/vape))
        smoking_cig = TRUE
    if((istype(held_cig, /obj/item/clothing/mask/cigarette) && held_cig.lit) || smoking_cig || istype(held_vape, /obj/item/clothing/mask/vape))
        var/message
        message = "[pick(
            "blows a plume of smoke into \the <b>[partner]</b>'s face.",
            "takes a drag before blowing smoke into \the <b>[partner]</b>'s face.",
            "exhales a cloud of smoke into \the <b>[partner]</b>'s face")]"
        var/mob/living/carbon/C = partner
        var/datum/effect_system/smoke_spread/chem/smoke_machine/s = new
        s.set_up(reagents, 0, 24, C.loc)
        s.start()
        visible_message(message = "<font color=purple><b>\The [src]</b> [message]</font>", ignored_mobs = get_unconsenting(TRUE))
        do_fucking_animation(get_dir(src, partner))
    else
        to_chat(src, "<span class='warning'>You can only blow smoke into their face with something that causes smoke in either hand or mouth.</span>")

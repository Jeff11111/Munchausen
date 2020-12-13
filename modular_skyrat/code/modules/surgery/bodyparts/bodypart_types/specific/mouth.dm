/obj/item/bodypart/mouth
	name = "jaw"
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "jaw"
	desc = "I have no mouth and yet i must scream."
	body_zone = BODY_ZONE_PRECISE_MOUTH
	body_part = JAW
	max_teeth = 32
	dismember_sounds = list('modular_skyrat/sound/gore/severed.ogg')
	max_damage = 30
	max_stamina_damage = 30
	wound_resistance = -15
	miss_entirely_prob = 30
	zone_prob = 35
	extra_zone_prob = 65
	var/obj/item/stack/sticky_tape/tapered = null
	amputation_point = "face"
	joint_name = "ramus"
	artery_name = "facial artery"
	tendon_name = "lateral ligament"
	cavity_name = "dental"

/obj/item/bodypart/mouth/get_limb_icon(dropped)
	. = ..()
	if(dropped)
		. = list()
		. += mutable_appearance('modular_skyrat/icons/obj/surgery.dmi', "[initial(icon_state)]", -BODYPARTS_LAYER, color = src.color)

/obj/item/bodypart/mouth/update_icon_dropped()
	cut_overlays()
	icon_state = initial(icon_state)//default to dismembered sprite

/obj/item/bodypart/mouth/attach_limb(mob/living/carbon/C, special, ignore_parent_restriction)
	. = ..()
	//Handle teeth and tape stuff
	if(!.)
		return
	if(tapered)
		ADD_TRAIT(owner, TRAIT_MUTE, "tape")
	if(teeth_mod)
		teeth_mod.add_speech_mod(C)

/obj/item/bodypart/mouth/drop_limb(special, ignore_children, dismembered, destroyed, wounding_type)
	var/mob/living/carbon/C = owner
	. = ..()
	//Handle teeth and tape stuff
	if(!.)
		return
	if(tapered)
		ADD_TRAIT(C, TRAIT_MUTE, "tape")
	if(teeth_mod)
		teeth_mod.remove_speech_mod()

/obj/item/bodypart/mouth/on_transfer_to_limb(obj/item/bodypart/BP)
	if(istype(BP, /obj/item/bodypart/head))
		var/obj/item/bodypart/head/HD = BP
		HD.jaw = src
		return TRUE
	else
		return ..()

/obj/item/bodypart/mouth/Initialize()
	. = ..()
	//Add TEETH.
	fill_teeth()

/obj/item/bodypart/mouth/get_teeth_amount()
	. = 0
	if(teeth_object)
		. += teeth_object.amount

/obj/item/bodypart/mouth/knock_out_teeth(amount = 1, throw_dir = SOUTH)
	amount = clamp(amount, 0, 32)
	if(!amount)
		return
	if(teeth_object && teeth_object.amount)
		//No point in making many stacks because they get merged on the ground
		var/drop = min(teeth_object.amount, amount)
		if(!drop)
			return
		for(var/y in 1 to drop)
			var/obj/item/stack/teeth/dropped_teeth = new teeth_object.type(get_turf(owner))
			dropped_teeth.add_mob_blood(owner)
			dropped_teeth.amount = 1
			teeth_object.use(1)
			var/range = clamp(round(amount/2), rand(0,1), 3)
			var/turf/target_turf = get_ranged_target_turf(dropped_teeth, throw_dir, range)
			dropped_teeth.throw_at(target_turf, range, rand(1,3))
			spawn(0)
				dropped_teeth.do_knock_out_animation()
		if(teeth_mod)
			teeth_mod.update_lisp()
		else
			teeth_mod = new()
			if(owner)
				teeth_mod.add_speech_mod(owner)
		if(owner)
			sound_hint(owner, owner)
		return drop

/obj/item/bodypart/mouth/update_teeth()
	if(teeth_mod)
		teeth_mod.update_lisp()
	else
		if(get_teeth_amount() < max_teeth)
			teeth_mod = new()
			teeth_mod.add_speech_mod(owner)
	return TRUE

/obj/item/bodypart/mouth/Topic(href, href_list)
	. = ..()
	if(href_list["tape"])
		var/mob/living/carbon/C = usr
		if(!istype(C) || !C.canUseTopic(owner, TRUE, FALSE, FALSE) || owner?.wear_mask)
			return
		if(C == owner)
			owner.visible_message("<span class='warning'>[owner] desperately tries to rip \the [tapered] from their mouth!</span>",
								"<span class='warning'>You desperately try to rip \the [tapered] from your mouth!</span>")
			if(do_mob(owner, owner, 3 SECONDS))
				tapered.forceMove(get_turf(owner))
				tapered = null
				owner.visible_message("<span class='warning'>[owner] rips \the [tapered] from their mouth!</span>",
									"<span class='warning'>You successfully remove \the [tapered] from your mouth!</span>")
				playsound(owner, 'modular_skyrat/sound/effects/clothripping.ogg', 40, 0, -4)
				owner.emote("scream")
				REMOVE_TRAIT(owner, TRAIT_MUTE, "tape")
			else
				to_chat(owner, "<span class='warning'>You fail to take \the [tapered] off.</span>")
		else
			if(do_mob(usr, owner, 1.5 SECONDS))
				owner.UnregisterSignal(tapered, COMSIG_MOB_SAY)
				tapered.forceMove(get_turf(owner))
				tapered = null
				usr.visible_message("<span class='warning'>[usr] rips \the [tapered] from [owner]'s mouth!</span>",
								"<span class='warning'>You rip \the [tapered] out of [owner]'s mouth!</span>")
				playsound(owner, 'modular_skyrat/sound/effects/clothripping.ogg', 40, 0, -4)
				if(owner)
					owner.emote("scream")
					REMOVE_TRAIT(owner, TRAIT_MUTE, "tape")
			else
				to_chat(usr, "<span class='warning'>You fail to take \the [tapered] off.</span>")
		update_limb(!owner, owner)

/obj/item/bodypart/mouth/proc/get_stickied(obj/item/stack/sticky_tape/tape, mob/user)
	if(!tape || tapered)
		return
	if(tape.use(1))
		if(user && owner)
			owner.visible_message(message = "<span class='danger'>[user] tapes [owner]'s mouth closed with \the [tape]!</span>", self_message = "<span class='userdanger'>[user] tapes your mouth closed with \the [tape]!</span>", ignored_mobs = list(user))
			to_chat(user, "<span class='warning'>You successfully gag [owner] with \the [src]!</span>")
		else if(user)
			user.visible_message("<span class='notice'>[user] tapes off [src]'s mouth.</span>")
		tapered = new tape.type(owner)
		tapered.amount = 1
		if(owner)
			ADD_TRAIT(owner, TRAIT_MUTE, "tape")
	update_limb(!owner, owner)

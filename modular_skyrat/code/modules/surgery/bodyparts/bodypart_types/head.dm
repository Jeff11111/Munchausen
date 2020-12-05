//The head is a bit snowflakey
/obj/item/bodypart/head
	name = "head"
	desc = "Didn't make sense not to live for fun, your brain gets smart but your head gets dumb."
	icon = 'modular_skyrat/icons/mob/human_parts.dmi'
	icon_state = "default_human_head"
	max_damage = 75
	max_stamina_damage = 75
	body_zone = BODY_ZONE_HEAD
	body_part = HEAD
	w_class = WEIGHT_CLASS_BULKY
	stam_heal_tick = 2
	stam_damage_coeff = 1
	throw_range = 4
	px_x = 0
	px_y = -8

	//Limb appearance info:
	var/real_name = "" //Replacement name
	//Hair colour and style
	var/hair_color = "000"
	var/hair_style = "Bald"
	var/hair_alpha = 255
	//Facial hair colour and style
	var/facial_hair_color = "000"
	var/facial_hair_style = "Shaved"
	//Eye Colouring
	var/obj/item/bodypart/left_eye/left_eye
	var/obj/item/bodypart/left_eye/right_eye
	//Lips
	var/lip_style = null
	var/lip_color = "white"
	//If the head is a special sprite
	var/custom_head
	//skyrat edit
	wound_resistance = 10
	specific_locations = list("left eyebrow", "right eyebrow", "cheekbone", "neck", "throat", "jawline", "entire face", "forehead")
	scars_covered_by_clothes = FALSE
	max_cavity_size = WEIGHT_CLASS_SMALL
	parent_bodyzone = BODY_ZONE_PRECISE_NECK
	children_zones = list(BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE)
	var/obj/item/stack/sticky_tape/tapered = null
	dismember_mod = 0.7
	disembowel_mod = 0.7
	max_teeth = 32
	dismember_sounds = list(
		'modular_skyrat/sound/gore/head_explodie1.ogg',
		'modular_skyrat/sound/gore/head_explodie2.ogg',
		'modular_skyrat/sound/gore/head_explodie3.ogg',
		'modular_skyrat/sound/gore/head_explodie4.ogg',
	)
	miss_entirely_prob = 25
	zone_prob = 60
	extra_zone_prob = 40
	encased = "skull"
	amputation_point = "epiglotis"
	artery_name = "temporal artery"
	cavity_name = "cranial"

/obj/item/bodypart/head/kill_limb()
	. = ..()
	if(owner && !HAS_TRAIT_FROM(owner, TRAIT_DISFIGURED, "rotten"))
		ADD_TRAIT(owner, TRAIT_DISFIGURED, "rotten")

/obj/item/bodypart/head/revive_limb()
	. = ..()
	if(owner && HAS_TRAIT_FROM(owner, TRAIT_DISFIGURED, "rotten"))
		REMOVE_TRAIT(owner, TRAIT_DISFIGURED, "rotten")

/obj/item/bodypart/head/decay()
	. = ..()
	if(owner && (germ_level >= INFECTION_LEVEL_TWO) && !HAS_TRAIT_FROM(owner, TRAIT_DISFIGURED, "rotten"))
		ADD_TRAIT(owner, TRAIT_DISFIGURED, "rotten")

/obj/item/bodypart/head/Initialize()
	. = ..()
	//Add TEETH.
	fill_teeth()

/obj/item/bodypart/head/get_teeth_amount()
	. = 0
	if(teeth_object)
		. += teeth_object.amount

/obj/item/bodypart/head/knock_out_teeth(amount = 1, throw_dir = SOUTH)
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

/obj/item/bodypart/head/update_teeth()
	if(teeth_mod)
		teeth_mod.update_lisp()
	else
		if(get_teeth_amount() < max_teeth)
			teeth_mod = new()
			teeth_mod.add_speech_mod(owner)
	return TRUE

/obj/item/bodypart/head/update_limb(dropping_limb, mob/living/carbon/source)
	. = ..()
	
	if(istype(loc, /obj/item/bodypart/neck))
		var/obj/item/bodypart/neck/neck = loc
		neck.update_limb(dropping_limb, source)
	
	if(no_update)
		return
	
	var/mob/living/carbon/C
	if(source)
		C = source
	else if(owner)
		C = owner
	
	if(C)
		real_name = C.real_name
	
	if((C && HAS_TRAIT(C, TRAIT_HUSK)) || is_dead())
		real_name = "Unknown"
		hair_style = "Bald"
		facial_hair_style = "Shaved"
		lip_style = null

	else if(!animal_origin)
		var/mob/living/carbon/human/H = C
		var/datum/species/S = H.dna.species

		//Facial hair
		if(H.facial_hair_style && (FACEHAIR in S.species_traits))
			facial_hair_style = H.facial_hair_style
			if(S.hair_color)
				if(S.hair_color == "mutcolor")
					facial_hair_color = H.dna.features["mcolor"]
				else
					facial_hair_color = S.hair_color
			else
				facial_hair_color = H.facial_hair_color
			hair_alpha = S.hair_alpha
		else
			facial_hair_style = "Shaved"
			facial_hair_color = "000"
			hair_alpha = 255
		//Hair
		if(H.hair_style && (HAIR in S.species_traits))
			hair_style = H.hair_style
			if(S.hair_color)
				if(S.hair_color == "mutcolor")
					hair_color = H.dna.features["mcolor"]
				else
					hair_color = S.hair_color
			else
				hair_color = H.hair_color
			hair_alpha = S.hair_alpha
		else
			hair_style = "Bald"
			hair_color = "000"
			hair_alpha = initial(hair_alpha)
		//Lipstick
		if(H.lip_style && (LIPS in S.species_traits))
			lip_style = H.lip_style
			lip_color = H.lip_color
		else
			lip_style = null
			lip_color = "white"

/obj/item/bodypart/head/update_icon_dropped()
	if(custom_head)
		return
	var/list/standing = get_limb_icon(TRUE)
	if(!standing.len)
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	add_overlay(standing)

/obj/item/bodypart/head/get_limb_icon(dropped)
	if(custom_head)
		return
	cut_overlays()
	. = ..()
	if(dropped) //certain overlays only appear when the limb is being detached from its owner.
		if(!(status & BODYPART_ROBOTIC)) //having a robotic head hides certain features.
			//hair
			if(hair_style)
				var/datum/sprite_accessory/S = GLOB.hair_styles_list[hair_style]
				if(S)
					var/image/hair_overlay = image(S.icon, "[S.icon_state]", -HAIR_LAYER, SOUTH)
					hair_overlay.color = "#" + hair_color
					hair_overlay.alpha = hair_alpha
					. += hair_overlay
			//facial hair
			if(facial_hair_style)
				var/datum/sprite_accessory/S2 = GLOB.facial_hair_styles_list[facial_hair_style]
				if(S2)
					var/image/facial_overlay = image(S2.icon, "[S2.icon_state]", -HAIR_LAYER, SOUTH)
					facial_overlay.color = "#" + facial_hair_color
					facial_overlay.alpha = hair_alpha
					. += facial_overlay

		// lipstick
		if(lip_style)
			var/image/lips_overlay = image('icons/mob/human_face.dmi', "lips_[lip_style]", -BODY_LAYER, SOUTH)
			lips_overlay.color = lip_color
			. += lips_overlay

		// eyes
		var/mutable_appearance/eyes_overlay = mutable_appearance('icons/mob/human_face.dmi', "blank", -BODY_LAYER)
		var/mutable_appearance/left_eye_overlay
		var/mutable_appearance/right_eye_overlay

		if(left_eye)
			left_eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eye-left", -BODY_LAYER)
		else
			left_eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eye-left-missing", -BODY_LAYER)
		eyes_overlay.add_overlay(left_eye_overlay)

		if(right_eye)
			right_eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eye-right", -BODY_LAYER)
		else
			right_eye_overlay = mutable_appearance('icons/mob/human_face.dmi', "eye-right-missing", -BODY_LAYER)
		eyes_overlay.add_overlay(right_eye_overlay)
		. += eyes_overlay
		
	// tape gag
	if(tapered)
		var/image/tape_overlay = image('modular_skyrat/icons/mob/tapegag.dmi', "tapegag", -BODY_LAYER, SOUTH)
		. += tape_overlay

/obj/item/bodypart/head/proc/get_stickied(obj/item/stack/sticky_tape/tape, mob/user)
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

/obj/item/bodypart/head/Topic(href, href_list)
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

/obj/item/bodypart/head/examine(mob/user)
	. = ..()
	if(tapered)
		. += "<span class='notice'>The mouth on [src] is taped shut with [tapered].</span>"

/obj/item/bodypart/head/attach_limb(mob/living/carbon/C, special)
	. = ..()
	if(. && tapered && owner)
		ADD_TRAIT(owner, TRAIT_MUTE, "tape")
	//Handle teeth stuff
	if(teeth_mod)
		teeth_mod.add_speech_mod(C)
	//Neck stuff
	var/obj/item/bodypart/neck/neck = C.get_bodypart(BODY_ZONE_PRECISE_NECK)
	if(neck)
		neck.status = status
		neck.synthetic = synthetic
		neck.render_like_organic = render_like_organic

/obj/item/bodypart/head/drop_limb(special, ignore_children = FALSE, dismembered = FALSE, destroyed = FALSE, wounding_type = WOUND_SLASH)
	. = ..()
	var/mob/living/og_owner = owner
	if(.)
		REMOVE_TRAIT(og_owner, TRAIT_MUTE, "tape")
	//Handle teeth stuff
	if(teeth_mod)
		teeth_mod.remove_speech_mod()

/obj/item/bodypart/head/replace_limb(mob/living/carbon/C, special)
	if(!istype(C))
		return
	var/obj/item/bodypart/head/O = C.get_bodypart(body_zone)
	if(O)
		if(!special)
			return
		else
			O.drop_limb(special, TRUE, FALSE, FALSE)
	attach_limb(C, special)

/obj/item/bodypart/head/can_dismember(obj/item/I)
	. = ..()
	if(. && owner)
		if(HAS_TRAIT(owner, TRAIT_NODECAP))
			return FALSE
		var/obj/item/bodypart/neck/throat = owner.get_bodypart(BODY_ZONE_PRECISE_NECK)
		if(throat)
			return throat.can_dismember(I)

/obj/item/bodypart/head/attach_limb(mob/living/carbon/C, special)
	//Transfer some head appearance vars over
	if(brain)
		if(brainmob)
			brainmob.container = null //Reset brainmob head var.
			brainmob.forceMove(brain) //Throw mob into brain.
			brain.brainmob = brainmob //Set the brain to use the brainmob
			brainmob = null //Set head brainmob var to null
		brain.Insert(C) //Now insert the brain proper
		brain = null //No more brain in the head

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		H.hair_color = hair_color
		H.hair_style = hair_style
		H.facial_hair_color = facial_hair_color
		H.facial_hair_style = facial_hair_style
		H.lip_style = lip_style
		H.lip_color = lip_color
	if(real_name)
		C.real_name = real_name
	real_name = ""
	name = initial(name)

	//Handle dental implants
	for(var/obj/item/reagent_containers/pill/P in src)
		for(var/datum/action/item_action/hands_free/activate_pill/AP in P.actions)
			P.forceMove(C)
			AP.Grant(C)
			break
	. = ..()

/obj/item/bodypart/head/drop_limb(special, ignore_children = FALSE, dismembered = FALSE, destroyed = FALSE, wounding_type = WOUND_SLASH)
	if(!special)
		//Drop all worn head items
		for(var/X in list(owner.glasses, owner.ears, owner.wear_mask, owner.head))
			var/obj/item/I = X
			owner.dropItemToGround(I, TRUE)

	owner.wash_cream() //clean creampie overlay

	//Handle dental implants
	for(var/datum/action/item_action/hands_free/activate_pill/AP in owner.actions)
		AP.Remove(owner)
		var/obj/pill = AP.target
		if(pill)
			pill.forceMove(src)

	//Make sure de-zombification happens before organ removal instead of during it
	var/obj/item/organ/zombie_infection/ooze = owner.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(istype(ooze))
		ooze.transfer_to_limb(src, owner)

	name = "[owner.real_name]'s head"
	..()

//Organ storage component, used in organ manipulation
/datum/component/storage/concrete/organ
	rustle_sound = list('modular_skyrat/sound/gore/organ1.ogg', 'modular_skyrat/sound/gore/organ2.ogg')
	storage_flags = 0
	var/obj/item/bodypart/bodypart_affected

//Unregister signals we don't want
/datum/component/storage/concrete/organ/Initialize()
	. = ..()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	UnregisterSignal(parent, list(COMSIG_MOUSEDROPPED_ONTO, COMSIG_CLICK_ALT, COMSIG_CLICK_MIDDLE, \
							COMSIG_ATOM_ATTACK_HAND, COMSIG_ITEM_PRE_ATTACK, COMSIG_ITEM_ATTACK_SELF, \
							COMSIG_ITEM_PICKUP, COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_GHOST, COMSIG_PARENT_ATTACKBY))
	addtimer(CALLBACK(src, .proc/update_insides), 1 SECONDS)

//Gives all organs parent as stored_in
/datum/component/storage/concrete/organ/proc/update_insides()
	for(var/obj/item/I in contents())
		I.stored_in = parent
		RegisterSignal(I, COMSIG_CLICK, /datum/component/storage/concrete/organ.proc/override_click, TRUE)

//Revert the opacity proper
/datum/component/storage/concrete/organ/Destroy()
	for(var/atom/_A in contents())
		_A.mouse_opacity = initial(_A.mouse_opacity)
	for(var/obj/item/I in contents())
		I.stored_in = null
		UnregisterSignal(I, COMSIG_CLICK)
	bodypart_affected = null
	return ..()

//Check if we are accessible
/datum/component/storage/concrete/organ/proc/is_accessible(mob/living/carbon/nigger)
	. = FALSE
	if(bodypart_affected)
		var/how_open = bodypart_affected.how_open()
		if((bodypart_affected.encased && CHECK_MULTIPLE_BITFIELDS(how_open, SURGERY_INCISED | SURGERY_RETRACTED | SURGERY_BROKEN)) || (!bodypart_affected.encased && CHECK_MULTIPLE_BITFIELDS(how_open, SURGERY_INCISED | SURGERY_RETRACTED)))
			return TRUE
	else
		return TRUE

//Only open this if aiming at the correct limb
/datum/component/storage/concrete/organ/on_attack_hand(datum/source, mob/user)
	update_insides()
	var/atom/A = parent

	if(!attack_hand_interact || !is_accessible(parent))
		return FALSE
	
	if(user.a_intent != INTENT_GRAB)
		return FALSE
	
	if(user.active_storage == src && A.loc == user) //if you're already looking inside the storage item
		user.active_storage.close(user)
		close(user)
		return COMPONENT_NO_ATTACK_HAND

	if(bodypart_affected && (user.zone_selected != bodypart_affected.body_zone))
		return FALSE
	
	if(rustle_sound)
		playsound(A, pick(rustle_sound), 50, 1, -5)
	
	if(isitem(A))
		var/obj/item/I = A
		if(!worn_check(I, user, TRUE))
			return FALSE
	
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == A && !H.get_active_held_item())	//Prevents opening if it's in a pocket.
			. = COMPONENT_NO_ATTACK_HAND
			H.put_in_hands(A)
			H.l_store = null
			return
		if(H.r_store == A && !H.get_active_held_item())
			. = COMPONENT_NO_ATTACK_HAND
			H.put_in_hands(A)
			H.r_store = null
			return

	if(A.loc == user)
		if(!check_locked(source, user, TRUE))
			ui_show(user)
		return COMPONENT_NO_ATTACK_HAND
	else if(attack_hand_open)
		ui_show(user)
		return COMPONENT_NO_ATTACK_HAND

//Only visible when acessible
/datum/component/storage/concrete/organ/show_to_ghost(datum/source, mob/dead/observer/M)
	if(!is_accessible(parent))
		return
	. = ..()

//Only visible when accessible
/datum/component/storage/concrete/organ/user_show_to_mob(mob/M, force, ghost)
	if(!is_accessible(parent) && !force)
		return
	. = ..()

//Can only insert organs or cavity implants depending on a few conditions
/datum/component/storage/concrete/organ/handle_item_insertion(obj/item/I, prevent_warning = FALSE, mob/M, datum/component/storage/remote)		//Remote is null or the slave datum
	var/datum/component/storage/concrete/master = master()
	var/atom/parent = src.parent
	var/moved = FALSE
	if(!istype(I))
		return FALSE
	if(M)
		if(!worn_check(parent, M))
			return FALSE
		if(!M.temporarilyRemoveItemFromInventory(I))
			return FALSE
		else
			moved = TRUE			//At this point if the proc fails we need to manually move the object back to the turf/mob/whatever.
	if(I.pulledby)
		I.pulledby.stop_pulling()
	if(silent)
		prevent_warning = TRUE
	if(!_insert_physical_item(I))
		if(moved)
			if(M)
				if(!M.put_in_active_hand(I))
					I.forceMove(parent.drop_location())
			else
				I.forceMove(parent.drop_location())
		return FALSE
	I.on_enter_storage(master)
	refresh_mob_views()
	I.mouse_opacity = MOUSE_OPACITY_OPAQUE //So you can click on the area around the item to equip it, instead of having to pixel hunt
	if(M)
		if(M.client && M.active_storage != src)
			M.client.screen -= I
		if(M.observers && length(M.observers))
			for(var/i in M.observers)
				var/mob/dead/observe = i
				if(observe.client && observe.active_storage != src)
					observe.client.screen -= I
		if(!remote)
			parent.add_fingerprint(M)
			if(!prevent_warning)
				mob_item_insertion_feedback(usr, M, I)
	playsound(I, pick(rustle_sound), 50, 1, -5)
	update_icon()
	update_insides()
	return TRUE

//Return the proper organ list
/datum/component/storage/concrete/organ/contents()
	if(!bodypart_affected)
		var/mob/living/carbon/carbon_parent = parent
		return carbon_parent.internal_organs
	else
		return (bodypart_affected.get_organs() + (bodypart_affected.cavity_item))

//Hide the organs proper
/datum/component/storage/concrete/organ/get_ui_item_objects_hide(mob/M)
	return contents()

//No real location
/datum/component/storage/concrete/organ/can_be_inserted(obj/item/I, stop_messages = FALSE, mob/M)
	if(!istype(I) || (I.item_flags & ABSTRACT) || !is_accessible(parent))
		return FALSE //Not an item
	if(I == parent)
		return FALSE //no paradoxes for you
	if(M.a_intent != INTENT_GRAB)
		return FALSE //must be on grab intent
	var/obj/item/organ/O = I
	if(!istype(O) && !(bodypart_affected && !bodypart_affected.cavity_item && (I.w_class <= bodypart_affected.max_cavity_size)))
		return FALSE
	else if(istype(O) && bodypart_affected && (O.zone != bodypart_affected.body_zone))
		return FALSE
	var/mob/living/carbon/carbon_parent = parent
	if(istype(O) && carbon_parent.getorganslot(O.slot))
		return FALSE
	var/list/not_a_location = contents()
	var/atom/host = parent
	if(I in not_a_location)
		return FALSE //Means the item is already in the storage item
	if(check_locked(null, M, !stop_messages))
		if(M && !stop_messages)
			host.add_fingerprint(M)
		return FALSE
	if(!worn_check(parent, M))
		host.add_fingerprint(M)
		return FALSE
	if(!length(can_hold_extra) || !is_type_in_typecache(I, can_hold_extra))
		if(length(can_hold) && !is_type_in_typecache(I, can_hold))
			if(!stop_messages)
				to_chat(M, "<span class='warning'>[host] cannot hold [I]!</span>")
			return FALSE
		if(is_type_in_typecache(I, cant_hold)) //Check for specific items which this container can't hold.
			if(!stop_messages)
				to_chat(M, "<span class='warning'>[host] cannot hold [I]!</span>")
			return FALSE
		if(storage_flags & STORAGE_LIMIT_MAX_W_CLASS && I.w_class > max_w_class)
			if(!stop_messages)
				to_chat(M, "<span class='warning'>[I] is too long for [host]!</span>")
			return FALSE
	///STORAGE LIMITS
	if(storage_flags & STORAGE_LIMIT_MAX_ITEMS)
		if(length(not_a_location) >= max_items)
			if(!stop_messages)
				to_chat(M, "<span class='warning'>[host] has too many things in it, make some space!</span>")
			return FALSE //Storage item is full
	if(storage_flags & STORAGE_LIMIT_COMBINED_W_CLASS)
		var/sum_w_class = I.w_class
		for(var/obj/item/_I in not_a_location)
			sum_w_class += _I.w_class //Adds up the combined w_classes which will be in the storage item if the item is added to it.
		if(sum_w_class > max_combined_w_class)
			if(!stop_messages)
				to_chat(M, "<span class='warning'>[I] won't fit in [host], make some space!</span>")
			return FALSE
	if(storage_flags & STORAGE_LIMIT_VOLUME)
		var/sum_volume = I.get_w_volume()
		for(var/obj/item/_I in not_a_location)
			sum_volume += _I.get_w_volume()
		if(sum_volume > get_max_volume())
			if(!stop_messages)
				to_chat(M, "<span class='warning'>[I] is too spacious to fit in [host], make some space!</span>")
			return FALSE
	/////////////////
	if(isitem(host))
		var/obj/item/IP = host
		var/datum/component/storage/STR_I = I.GetComponent(/datum/component/storage)
		if((I.w_class >= IP.w_class) && STR_I && !allow_big_nesting)
			if(!stop_messages)
				to_chat(M, "<span class='warning'>[IP] cannot hold [O] as it's a storage item of the same size!</span>")
			return FALSE //To prevent the stacking of same sized storage items.
	if(HAS_TRAIT(O, TRAIT_NODROP)) //SHOULD be handled in unEquip, but better safe than sorry.
		to_chat(M, "<span class='warning'>\the [O] is stuck to your hand, you can't put it in \the [host]!</span>")
		return FALSE
	var/datum/component/storage/concrete/master = master()
	if(!istype(master))
		return FALSE
	return master.slave_can_insert_object(src, I, stop_messages, M)

//No real location
/datum/component/storage/concrete/organ/_insert_physical_item(obj/item/I, override)
	. = FALSE
	var/obj/item/organ/O = I
	if(istype(I, /obj/item/mmi))
		var/obj/item/mmi/meme = I
		if(meme.brain)
			O = meme.brain
			O.forceMove(parent)
			meme.brain = null
			qdel(meme)
	
	if(istype(O))
		var/list/not_a_location = contents()
		if(!(O in not_a_location))
			var/mob/living/carbon/carbon_parent = parent
			O.forceMove(carbon_parent)
			O.Insert(carbon_parent)
			update_insides()
		refresh_mob_views()
		return TRUE
	else if(!bodypart_affected.cavity_item && (I.w_class <= bodypart_affected.max_cavity_size))
		var/list/not_a_location = contents()
		if(!(I in not_a_location))
			I.forceMove(bodypart_affected)
			bodypart_affected.cavity_item = I
			update_insides()
		refresh_mob_views()
		return TRUE

//No real location
/datum/component/storage/concrete/organ/attackby(datum/source, obj/item/I, mob/M, params)
	. = TRUE //no afterattack
	if(iscyborg(M))
		return FALSE
	if(!can_be_inserted(I, FALSE, M))
		return FALSE
	handle_item_insertion(I, FALSE, M)

//No real location
/datum/component/storage/concrete/organ/remaining_space_items()
	var/list/not_a_location = contents()
	return max(0, max_items - length(not_a_location))

//No real location
/datum/component/storage/concrete/organ/signal_take_obj(datum/source, atom/movable/AM, new_loc, force = FALSE)
	if(!(AM in contents()))
		return FALSE
	return remove_from_storage(AM, new_loc)

//No real location
/datum/component/storage/concrete/organ/on_contents_del(datum/source, atom/A)
	var/list/not_a_location = contents()
	if(A in not_a_location)
		usr = null
		remove_from_storage(A, null)

//Handled by carbon parent
/datum/component/storage/concrete/organ/emp_act(datum/source, severity)
	return FALSE

//Deal with cavity items and organs appropriately
/datum/component/storage/concrete/organ/remove_from_storage(atom/movable/AM, atom/new_location)
	if(!is_accessible(parent))
		return FALSE
	. = ..()
	if(.)
		AM.mouse_opacity = initial(AM.mouse_opacity)
		var/obj/item/organ/O = AM
		if(!istype(O))
			if(bodypart_affected?.cavity_item == AM)
				bodypart_affected.cavity_item.stored_in = null
				bodypart_affected.cavity_item = null
				return
			return FALSE
		var/mob/living/carbon/carbon_parent = parent
		if(!carbon_parent.IsUnconscious() && (carbon_parent.chem_effects[CE_PAINKILLER] < 50))
			carbon_parent.death_scream()
			carbon_parent.custom_pain("MY [capitalize(O.name)] HURTS!", rand(30, 40))
		if(!CHECK_BITFIELD(O.organ_flags, ORGAN_CUT_AWAY) && bodypart_affected)
			for(var/datum/injury/fucked in bodypart_affected.wounds)
				fucked.open_injury(rand(5, 15))
			O.applyOrganDamage(rand(10, 20))
		O.stored_in = null
		O.Remove(FALSE)
		O.organ_flags |= ORGAN_CUT_AWAY
		refresh_mob_views()
		playsound(O, pick(rustle_sound), 50, 1, -5)
		update_insides()
		return TRUE

//Nullspace is a bitch
/datum/component/storage/concrete/organ/proc/override_click(datum/source, location, control, params, user)
	var/atom/A = parent
	var/obj/item/nigger = source
	var/mob/living/carbon/niggertwo = user
	if(!istype(niggertwo) || !istype(nigger))
		return
	
	if(niggertwo.incapacitated() || !A.Adjacent(user) || niggertwo.lying || (niggertwo.a_intent != INTENT_GRAB))
		return

	var/list/params_list = params2list(params)
	if(params_list["shift"])
		nigger.examine(user)
	else if(!niggertwo.get_active_held_item())
		playsound(A, pick(rustle_sound), 50, 1, -5)
		nigger.attack_hand(niggertwo)
	else
		playsound(A, pick(rustle_sound), 50, 1, -5)
		nigger.attackby(niggertwo.get_active_held_item(), niggertwo, params)
	return TRUE

//AAAAAAAA
/datum/component/storage/concrete/organ/mousedrop_onto(datum/source, atom/over_object, mob/M)
	set waitfor = FALSE
	var/mob/A = parent
	A.add_fingerprint(M)
	if(!over_object)
		return FALSE
	if(ismecha(M.loc)) // stops inventory actions in a mech
		return FALSE
	// this must come before the screen objects only block, dunno why it wasn't before
	var/mob/living/L = M
	//FUCK
	var/mob/living/carbon/nigger_faggot = parent
	if(L.a_intent == INTENT_GRAB)
		bodypart_affected = nigger_faggot.get_bodypart(L.zone_selected)
	if(!istype(L) || !(L.a_intent == INTENT_GRAB) || !is_accessible(L))
		return FALSE
	if(isliving(over_object) && (L.zone_selected == bodypart_affected.body_zone))
		update_insides()
		user_show_to_mob(M)
		return COMPONENT_NO_MOUSEDROP

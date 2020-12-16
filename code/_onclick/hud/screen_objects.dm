/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen_gen.dmi'
	layer = HUD_LAYER
	plane = HUD_PLANE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	appearance_flags = APPEARANCE_UI
	var/obj/master = null	//A reference to the object in the slot. Grabs or items, generally.
	var/datum/hud/hud = null // A reference to the owner HUD, if any.

/obj/screen/take_damage()
	return

/obj/screen/Destroy()
	master = null
	hud = null
	return ..()

/obj/screen/examine(mob/user)
	return list()

/obj/screen/orbit()
	return

/obj/screen/proc/component_click(obj/screen/component_button/component, params)
	return

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480

/obj/screen/swap_hand
	layer = HUD_LAYER
	plane = HUD_PLANE
	name = "swap hand"

/obj/screen/swap_hand/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE

	if(usr.incapacitated())
		return TRUE

	if(ismob(usr))
		var/mob/M = usr
		M.swap_hand()
	return TRUE

/obj/screen/craft
	name = "crafting menu"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "craft"
	screen_loc = ui_crafting

/obj/screen/area_creator
	name = "create new area"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "area_edit"
	screen_loc = ui_building

/obj/screen/area_creator/Click()
	if(usr.incapacitated() || (isobserver(usr) && !IsAdminGhost(usr)))
		return TRUE
	var/area/A = get_area(usr)
	if(!A.outdoors)
		to_chat(usr, "<span class='warning'>There is already a defined structure here.</span>")
		return TRUE
	create_area(usr)

/obj/screen/language_menu
	name = "language menu"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "talk_wheel"
	screen_loc = ui_language_menu

/obj/screen/language_menu/Click()
	var/mob/M = usr
	var/datum/language_holder/H = M.get_language_holder()
	H.open_language_menu(usr)

/obj/screen/inventory
	var/slot_id	// The indentifier for the slot. It has nothing to do with ID cards.
	var/icon_empty // Icon when empty. For now used only by humans.
	var/icon_full  // Icon when contains an item. For now used only by humans.
	var/list/object_overlays = list()
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/inventory/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(world.time <= usr.next_move)
		return TRUE

	if(usr.incapacitated())
		return TRUE
	if(ismecha(usr.loc)) // stops inventory actions in a mech
		return TRUE

	if(hud?.mymob && slot_id)
		var/obj/item/inv_item = hud.mymob.get_item_by_slot(slot_id)
		if(inv_item)
			return inv_item.Click(location, control, params)

	if(usr.attack_ui(slot_id))
		usr.update_inv_hands()
	return TRUE

/obj/screen/inventory/MouseEntered()
	..()
	add_overlays()

/obj/screen/inventory/MouseExited()
	..()
	cut_overlay(object_overlays)
	object_overlays.Cut()

/obj/screen/inventory/update_icon_state()
	if(!icon_empty)
		icon_empty = icon_state

	if(hud?.mymob && slot_id && icon_full)
		if(hud.mymob.get_item_by_slot(slot_id))
			icon_state = icon_full
		else
			icon_state = icon_empty

/obj/screen/inventory/proc/add_overlays()
	var/mob/user = hud?.mymob

	if(!user || !slot_id)
		return

	var/obj/item/holding = user.get_active_held_item()

	if(!holding || user.get_item_by_slot(slot_id))
		return

	var/image/item_overlay = image(holding)
	item_overlay.alpha = 92

	if(!user.can_equip(holding, slot_id, TRUE, TRUE)) //skyrat change
		item_overlay.color = "#FF0000"
	else
		item_overlay.color = "#00ff00"

	object_overlays += item_overlay
	add_overlay(object_overlays)

/obj/screen/inventory/hand
	var/mutable_appearance/handcuff_overlay
	var/static/mutable_appearance/blocked_overlay = mutable_appearance('icons/mob/screen_gen.dmi', "blocked")
	var/held_index = 0

/obj/screen/inventory/hand/update_overlays()
	. = ..()

	if(!handcuff_overlay)
		var/state = (!(held_index % 2)) ? "markus" : "gabrielle"
		handcuff_overlay = mutable_appearance('icons/mob/screen_gen.dmi', state)

	if(!hud?.mymob)
		return

	if(iscarbon(hud.mymob))
		var/mob/living/carbon/C = hud.mymob
		if(C.handcuffed)
			. += handcuff_overlay

		if(held_index)
			if(!C.has_hand_for_held_index(held_index))
				. += blocked_overlay

	if(held_index == hud.mymob.active_hand_index)
		. += "hand_active"


/obj/screen/inventory/hand/Click(location, control, params)
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	var/mob/user = hud?.mymob
	if(usr != user)
		return TRUE
	if(world.time <= user.next_move)
		return TRUE
	if(user.incapacitated())
		return TRUE
	if(ismecha(user.loc)) // stops inventory actions in a mech
		return TRUE

	if(user.active_hand_index == held_index)
		var/obj/item/I = user.get_active_held_item()
		if(I)
			I.Click(location, control, params)
	else
		user.swap_hand(held_index)
	return TRUE

/obj/screen/drop
	name = "drop"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_drop"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/drop/Click()
	if(usr.stat == CONSCIOUS)
		usr.dropItemToGround(usr.get_active_held_item())

/obj/screen/act_intent
	name = "intent"
	icon_state = "help"
	screen_loc = ui_acti

/obj/screen/act_intent/Click(location, control, params)
	usr.a_intent_change(INTENT_HOTKEY_RIGHT)

/obj/screen/act_intent/segmented/Click(location, control, params)
	if(usr.client.prefs.toggles & INTENT_STYLE)
		var/_x = text2num(params2list(params)["icon-x"])
		var/_y = text2num(params2list(params)["icon-y"])

		if(_x<=16 && _y<=16)
			usr.a_intent_change(INTENT_HARM)

		else if(_x<=16 && _y>=17)
			usr.a_intent_change(INTENT_HELP)

		else if(_x>=17 && _y<=16)
			usr.a_intent_change(INTENT_GRAB)

		else if(_x>=17 && _y>=17)
			usr.a_intent_change(INTENT_DISARM)
	else
		return ..()

/obj/screen/act_intent/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_movi

/obj/screen/act_intent/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_intents

/obj/screen/internals
	name = "toggle internals"
	icon_state = "internal0"
	screen_loc = ui_internal

/obj/screen/internals/Click()
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/C = usr
	if(C.incapacitated())
		return

	if(C.internal)
		C.internal = null
		to_chat(C, "<span class='notice'>You are no longer running on internals.</span>")
		icon_state = "internal0"
	else
		if(!C.getorganslot(ORGAN_SLOT_BREATHING_TUBE))
			if(HAS_TRAIT(C, TRAIT_NO_INTERNALS))
				to_chat(C, "<span class='warning'>Due to cumbersome equipment or anatomy, you are currently unable to use internals!</span>")
				return
			var/obj/item/clothing/check
			var/internals = FALSE

			for(check in GET_INTERNAL_SLOTS(C))
				if(istype(check, /obj/item/clothing/mask))
					var/obj/item/clothing/mask/M = check
					if(M.mask_adjusted)
						M.adjustmask(C)
				if(CHECK_BITFIELD(check.clothing_flags, ALLOWINTERNALS))
					internals = TRUE
			if(!internals)
				to_chat(C, "<span class='warning'>You are not wearing an internals mask!</span>")
				return

		var/obj/item/I = C.is_holding_item_of_type(/obj/item/tank)
		if(I)
			to_chat(C, "<span class='notice'>You are now running on internals from [I] in your [C.get_held_index_name(C.get_held_index_of_item(I))].</span>")
			C.internal = I
		else if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(istype(H.s_store, /obj/item/tank))
				to_chat(H, "<span class='notice'>You are now running on internals from [H.s_store] on your [H.wear_suit.name].</span>")
				H.internal = H.s_store
			else if(istype(H.belt, /obj/item/tank))
				to_chat(H, "<span class='notice'>You are now running on internals from [H.belt] on your belt.</span>")
				H.internal = H.belt
			else if(istype(H.l_store, /obj/item/tank))
				to_chat(H, "<span class='notice'>You are now running on internals from [H.l_store] in your left pocket.</span>")
				H.internal = H.l_store
			else if(istype(H.r_store, /obj/item/tank))
				to_chat(H, "<span class='notice'>You are now running on internals from [H.r_store] in your right pocket.</span>")
				H.internal = H.r_store

		//Separate so CO2 jetpacks are a little less cumbersome.
		if(!C.internal && istype(C.back, /obj/item/tank))
			to_chat(C, "<span class='notice'>You are now running on internals from [C.back] on your back.</span>")
			C.internal = C.back

		if(C.internal)
			icon_state = "internal1"
		else
			to_chat(C, "<span class='warning'>You don't have an oxygen tank!</span>")
			return
	C.update_action_buttons_icon()

/obj/screen/mov_intent
	name = "run/walk toggle"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "running"

/obj/screen/mov_intent/Click()
	toggle(usr)

/obj/screen/mov_intent/update_icon_state()
	switch(hud?.mymob?.m_intent)
		if(MOVE_INTENT_WALK)
			icon_state = "walking"
		if(MOVE_INTENT_RUN)
			icon_state = "running"

/obj/screen/mov_intent/proc/toggle(mob/user)
	if(isobserver(user))
		return
	user.toggle_move_intent(user)

/obj/screen/pull
	name = "stop pulling"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "pull"

/obj/screen/pull/Click()
	if(isobserver(usr))
		return
	usr.stop_pulling()

/obj/screen/pull/update_icon_state()
	if(hud?.mymob?.pulling)
		name = "stop pulling"
		icon_state = "pull_on"
	else
		name = "pull"
		icon_state = "pull"

/obj/screen/resist
	name = "resist"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_resist"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/resist/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.resist()

/obj/screen/rest
	name = "rest"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_rest"
	layer = HUD_LAYER
	plane = HUD_PLANE

/obj/screen/rest/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		L.lay_down()

/obj/screen/rest/update_icon_state()
	var/mob/living/user = hud?.mymob
	if(!istype(user))
		return
	if(user.resting)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = initial(icon_state)

/obj/screen/throw_catch
	name = "throw/catch"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_throw"

/obj/screen/throw_catch/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()

/obj/screen/zone_sel
	name = "damage zone"
	icon = 'modular_skyrat/icons/mob/screen/zone_sel32x64.dmi'
	var/overlay_icon = 'modular_skyrat/icons/mob/screen/zone_sel32x64.dmi'
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/static/list/hover_overlays_cache = list()
	var/hovering

/obj/screen/zone_sel/Click(location, control,params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)
	if(!choice)
		return 1

	return set_selected_zone(choice, usr)

/obj/screen/zone_sel/MouseEntered(location, control, params)
	MouseMove(location, control, params)

/obj/screen/zone_sel/MouseMove(location, control, params)
	if(isobserver(usr))
		return

	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/choice = get_zone_at(icon_x, icon_y)

	if(hovering == choice)
		return
	vis_contents -= hover_overlays_cache[hovering]
	hovering = choice

	var/obj/effect/overlay/zone_sel/overlay_object = hover_overlays_cache[choice]
	if(!overlay_object)
		overlay_object = new
		overlay_object.icon_state = "[choice]"
		hover_overlays_cache[choice] = overlay_object
	vis_contents += overlay_object

/obj/effect/overlay/zone_sel
	icon = 'modular_skyrat/icons/mob/screen/zone_sel32x64.dmi'
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 128
	anchored = TRUE
	layer = ABOVE_HUD_LAYER
	plane = ABOVE_HUD_PLANE

/obj/screen/zone_sel/MouseExited(location, control, params)
	if(!isobserver(usr) && hovering)
		vis_contents -= hover_overlays_cache[hovering]
		hovering = null

/obj/screen/zone_sel/proc/get_zone_at(icon_x, icon_y)
	//skyrat edit - more bodyparts
	switch(icon_y)
		if(5) //Feet
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_PRECISE_R_FOOT
				if(22 to 25)
					return BODY_ZONE_PRECISE_L_FOOT
		if(6 to 7) //Feet
			switch(icon_x)
				if(7 to 12)
					return BODY_ZONE_PRECISE_R_FOOT
				if(21 to 26)
					return BODY_ZONE_PRECISE_L_FOOT
		if(8) //Feet and legs
			switch(icon_x)
				if(8 to 11)
					return BODY_ZONE_PRECISE_R_FOOT
				if(12)
					return BODY_ZONE_R_LEG
				if(21)
					return BODY_ZONE_L_LEG
				if(22 to 26)
					return BODY_ZONE_PRECISE_L_FOOT
		if(9) //Feet and legs
			switch(icon_x)
				if(9, 10)
					return BODY_ZONE_PRECISE_R_FOOT
				if(11, 12)
					return BODY_ZONE_R_LEG
				if(21, 22)
					return BODY_ZONE_L_LEG
				if(23, 24)
					return BODY_ZONE_PRECISE_L_FOOT
		if(10) //Legs
			switch(icon_x)
				if(9 to 12)
					return BODY_ZONE_R_LEG
				if(21 to 24)
					return BODY_ZONE_L_LEG
		if(11 to 16) //Legs
			switch(icon_x)
				if(9 to 13)
					return BODY_ZONE_R_LEG
				if(20 to 24)
					return BODY_ZONE_L_LEG
		if(17) //Legs
			switch(icon_x)
				if(10 to 13)
					return BODY_ZONE_R_LEG
				if(20 to 23)
					return BODY_ZONE_L_LEG
		if(18 to 22)
			switch(icon_x)
				if(10 to 14)
					return BODY_ZONE_R_LEG
				if(19 to 23)
					return BODY_ZONE_L_LEG
		if(23, 24) //Legs
			switch(icon_x)
				if(10 to 15)
					return BODY_ZONE_R_LEG
				if(18 to 23)
					return BODY_ZONE_L_LEG
		if(25) //Legs, groin
			switch(icon_x)
				if(10 to 12)
					return BODY_ZONE_R_LEG
				if(13 to 20)
					return BODY_ZONE_PRECISE_GROIN
				if(21 to 23)
					return BODY_ZONE_L_LEG
		if(26) //Legs, groin
			switch(icon_x)
				if(10)
					return BODY_ZONE_R_LEG
				if(11 to 22)
					return BODY_ZONE_PRECISE_GROIN
				if(23)
					return BODY_ZONE_L_LEG
		if(27) //Groin, hands
			switch(icon_x)
				if(7, 8)
					return BODY_ZONE_PRECISE_R_HAND
				if(10 to 23)
					return BODY_ZONE_PRECISE_GROIN
				if(24 to 27)
					return BODY_ZONE_PRECISE_L_HAND
		if(28) //Groin, hands
			switch(icon_x)
				if(6 to 9)
					return BODY_ZONE_PRECISE_R_HAND
				if(10 to 23)
					return BODY_ZONE_PRECISE_GROIN
				if(24 to 27)
					return BODY_ZONE_PRECISE_L_HAND
		if(29) //Groin, hands
			switch(icon_x)
				if(5 to 9)
					return BODY_ZONE_PRECISE_R_HAND
				if(10 to 23)
					return BODY_ZONE_PRECISE_GROIN
				if(24 to 28)
					return BODY_ZONE_PRECISE_L_HAND
		if(30) //Groin, hands
			switch(icon_x)
				if(5 to 10)
					return BODY_ZONE_PRECISE_R_HAND
				if(11 to 22)
					return BODY_ZONE_PRECISE_GROIN
				if(23 to 28)
					return BODY_ZONE_PRECISE_L_HAND
		if(31) //Groin, chest, hands
			switch(icon_x)
				if(5 to 9)
					return BODY_ZONE_PRECISE_R_HAND
				if(11, 12)
					return BODY_ZONE_PRECISE_GROIN
				if(13 to 20)
					return BODY_ZONE_CHEST
				if(21, 22)
					return BODY_ZONE_PRECISE_L_HAND
		if(32) //Chest, arms, hands
			switch(icon_x)
				if(5)
					return BODY_ZONE_R_ARM
				if(6 to 8)
					return BODY_ZONE_PRECISE_R_HAND
				if(11 to 22)
					return BODY_ZONE_CHEST
				if(25 to 27)
					return BODY_ZONE_PRECISE_L_HAND
				if(28)
					return BODY_ZONE_L_ARM
		if(33 to 36) //Chest, arms
			switch(icon_x)
				if(5 to 8)
					return BODY_ZONE_R_ARM
				if(11 to 22)
					return BODY_ZONE_CHEST
				if(25 to 28)
					return BODY_ZONE_L_ARM
		if(37, 38) //Chest, arms
			switch(icon_x)
				if(5 to 9)
					return BODY_ZONE_R_ARM
				if(11 to 22)
					return BODY_ZONE_CHEST
				if(24 to 28)
					return BODY_ZONE_L_ARM
		if(39 to 41) //Chest, arms
			switch(icon_x)
				if(6 to 10)
					return BODY_ZONE_R_ARM
				if(11 to 22)
					return BODY_ZONE_CHEST
				if(23 to 27)
					return BODY_ZONE_L_ARM
		if(42 to 44) //Chest, arms
			switch(icon_x)
				if(7 to 10)
					return BODY_ZONE_R_ARM
				if(11 to 22)
					return BODY_ZONE_CHEST
				if(23 to 26)
					return BODY_ZONE_L_ARM
		if(45) //Chest, arms
			switch(icon_x)
				if(8 to 10)
					return BODY_ZONE_R_ARM
				if(11 to 22)
					return BODY_ZONE_CHEST
				if(23 to 25)
					return BODY_ZONE_L_ARM
		if(46) //Chest, neck, arms
			switch(icon_x)
				if(9, 10)
					return BODY_ZONE_R_ARM
				if(11 to 13)
					return BODY_ZONE_CHEST
				if(14 to 19)
					return BODY_ZONE_PRECISE_NECK
				if(20 to 22)
					return BODY_ZONE_CHEST
				if(23 to 25)
					return BODY_ZONE_L_ARM
		if(47) //Chest, neck, arms
			switch(icon_x)
				if(10)
					return BODY_ZONE_R_ARM
				if(11 to 13)
					return BODY_ZONE_CHEST
				if(14 to 19)
					return BODY_ZONE_PRECISE_NECK
				if(20 to 22)
					return BODY_ZONE_CHEST
				if(23)
					return BODY_ZONE_L_ARM
		if(48) //Chest, neck
			switch(icon_x)
				if(12)
					return BODY_ZONE_CHEST
				if(13 to 20)
					return BODY_ZONE_PRECISE_NECK
				if(21)
					return BODY_ZONE_CHEST
		if(49) //Neck, head
			switch(icon_x)
				if(14, 15)
					return BODY_ZONE_PRECISE_NECK
				if(16, 17)
					return BODY_ZONE_HEAD
		if(50) //Neck, head
			switch(icon_x)
				if(14)
					return BODY_ZONE_PRECISE_NECK
				if(15)
					return BODY_ZONE_HEAD
				if(16, 17)
					return BODY_ZONE_PRECISE_MOUTH
				if(18)
					return BODY_ZONE_HEAD
				if(19)
					return BODY_ZONE_PRECISE_NECK
		if(51) //Head, mouth
			switch(icon_x)
				if(13 to 15)
					return BODY_ZONE_HEAD
				if(16, 17)
					return BODY_ZONE_PRECISE_MOUTH
				if(18 to 20)
					return BODY_ZONE_HEAD
		if(52) //Head, mouth
			switch(icon_x)
				if(13 to 15)
					return BODY_ZONE_HEAD
				if(16, 17)
					return BODY_ZONE_PRECISE_MOUTH
				if(18 to 20)
					return BODY_ZONE_HEAD
		if(53) //Head, eyes
			switch(icon_x)
				if(12 to 14)
					return BODY_ZONE_HEAD
				if(15)
					return BODY_ZONE_PRECISE_RIGHT_EYE
				if(16, 17)
					return BODY_ZONE_HEAD
				if(18)
					return BODY_ZONE_PRECISE_LEFT_EYE
				if(19 to 21)
					return BODY_ZONE_HEAD
		if(54) //Head, eyes
			switch(icon_x)
				if(12, 13)
					return BODY_ZONE_HEAD
				if(14 to 16)
					return BODY_ZONE_PRECISE_RIGHT_EYE
				if(17 to 19)
					return BODY_ZONE_PRECISE_LEFT_EYE
				if(20, 21)
					return BODY_ZONE_HEAD
		if(55) //Head, eyes
			switch(icon_x)
				if(13, 14)
					return BODY_ZONE_HEAD
				if(15)
					return BODY_ZONE_PRECISE_RIGHT_EYE
				if(16, 17)
					return BODY_ZONE_HEAD
				if(18)
					return BODY_ZONE_PRECISE_LEFT_EYE
				if(19, 20)
					return BODY_ZONE_HEAD
		if(56, 57) //Head, eyes
			switch(icon_x)
				if(13 to 20)
					return BODY_ZONE_HEAD
		if(58) //Head, eyes
			switch(icon_x)
				if(14 to 19)
					return BODY_ZONE_HEAD
		if(59) //Head, eyes
			switch(icon_x)
				if(15 to 18)
					return BODY_ZONE_HEAD

/obj/screen/zone_sel/proc/set_selected_zone(choice, mob/user)
	if(user != hud?.mymob)
		return

	if(choice != hud.mymob.zone_selected)
		//Change zone variable on mob
		hud.mymob.zone_selected = choice

		//Update the hand shit
		hud.mymob.hand_index_to_zone[hud.mymob.active_hand_index] = hud.mymob.zone_selected
		
		//Fucking update
		update_icon()

	return TRUE

/obj/screen/zone_sel/update_overlays()
	. = ..()
	if(!hud?.mymob)
		return
	. += mutable_appearance(overlay_icon, "[hud.mymob.zone_selected]")

/obj/screen/zone_sel/alien
	icon = 'icons/mob/screen_alien.dmi'
	overlay_icon = 'icons/mob/screen_alien.dmi'

/obj/screen/zone_sel/robot
	icon = 'icons/mob/screen_cyborg.dmi'

/obj/screen/flash
	name = "flash"
	icon_state = "blank"
	blend_mode = BLEND_ADD
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	layer = FLASH_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/damageoverlay
	icon = 'icons/mob/screen_full.dmi'
	icon_state = "oxydamageoverlay0"
	name = "dmg"
	blend_mode = BLEND_MULTIPLY
	screen_loc = "CENTER-7,CENTER-7"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = UI_DAMAGE_LAYER
	plane = FULLSCREEN_PLANE

/obj/screen/healths
	name = "pulse"
	icon_state = "health0"
	screen_loc = ui_pulse

/obj/screen/healths/Click(location, control, params)
	var/mob/living/carbon/C = usr
	if(istype(C))
		C.check_pulse()

/obj/screen/healths/alien
	icon = 'icons/mob/screen_alien.dmi'
	screen_loc = ui_alien_health

/obj/screen/healths/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_health

/obj/screen/healths/blob
	name = "blob health"
	icon_state = "block"
	screen_loc = ui_internal
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/blob/naut
	name = "health"
	icon = 'icons/mob/blob.dmi'
	icon_state = "nauthealth"

/obj/screen/healths/blob/naut/core
	name = "overmind health"
	screen_loc = ui_pulse
	icon_state = "corehealth"

/obj/screen/healths/guardian
	name = "summoner health"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "base"
	screen_loc = ui_pulse
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/clock
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_clock"
	screen_loc = ui_pulse
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/clock/gear
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "bg_gear"
	screen_loc = ui_internal

/obj/screen/healths/revenant
	name = "essence"
	icon = 'icons/mob/actions.dmi'
	icon_state = "bg_revenant"
	screen_loc = ui_pulse
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/construct
	icon = 'icons/mob/screen_construct.dmi'
	icon_state = "artificer_health0"
	screen_loc = ui_construct_health
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healths/lavaland_elite
	icon = 'icons/mob/screen_elite.dmi'
	icon_state = "elite_health0"
	screen_loc = ui_pulse
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/screen/healthdoll
	name = "health doll"
	screen_loc = ui_healthdoll
	icon = 'modular_skyrat/icons/mob/screen/screen_gen.dmi'

/obj/screen/healthdoll/Click(location,control,params)
	var/mob/living/L = usr
	if(istype(L))
		L.ClickOn(L, params)
		L.update_health_hud()

/obj/screen/mood
	name = "mood"
	icon = 'modular_skyrat/icons/mob/screen/screen_mood.dmi'
	icon_state = "mood5"
	screen_loc = ui_mood

/obj/screen/splash
	icon = 'icons/blank_title.png'
	icon_state = ""
	screen_loc = "1,1"
	layer = SPLASHSCREEN_LAYER
	plane = SPLASHSCREEN_PLANE
	var/client/holder

/obj/screen/splash/New(client/C, visible, use_previous_title) //TODO: Make this use INITIALIZE_IMMEDIATE, except its not easy
	. = ..()

	holder = C

	if(!visible)
		alpha = 0

	if(!use_previous_title)
		if(SStitle.icon)
			icon = SStitle.icon
	else
		if(!SStitle.previous_icon)
			qdel(src)
			return
		icon = SStitle.previous_icon

	holder.screen += src

/obj/screen/splash/proc/Fade(out, qdel_after = TRUE)
	if(QDELETED(src))
		return
	if(out)
		animate(src, alpha = 0, time = 30)
	else
		alpha = 0
		animate(src, alpha = 255, time = 30)
	if(qdel_after)
		QDEL_IN(src, 30)

/obj/screen/splash/Destroy()
	if(holder)
		holder.screen -= src
		holder = null
	return ..()


/obj/screen/component_button
	var/obj/screen/parent

/obj/screen/component_button/Initialize(mapload, obj/screen/parent)
	. = ..()
	src.parent = parent

/obj/screen/component_button/Click(params)
	if(parent)
		parent.component_click(src, params)

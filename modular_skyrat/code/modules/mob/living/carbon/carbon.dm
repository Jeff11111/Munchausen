//Poggers
/mob/living/carbon/ComponentInitialize()
	. = ..()
	//Carbon mobs always have an organ storage component - it just becomes accessible when necessary.
	AddComponent(/datum/component/storage/concrete/organ)
	//Carbon mobs can teach
	AddElement(/datum/element/teaching)

/mob/living/carbon/Destroy()
	. = ..()
	var/datum/component/storage/concrete/organ/ST = GetComponent(/datum/component/storage/concrete/organ)
	if(ST)
		qdel(ST)

/mob/living/carbon/proc/create_bodyparts()
	var/l_hand_index_next = -1
	var/r_hand_index_next = 0
	for(var/X in bodyparts)
		var/obj/item/bodypart/O = new X()
		O.owner = src
		bodyparts.Remove(X)
		bodyparts.Add(O)
		if(O.body_part == HAND_LEFT)
			l_hand_index_next += 2
			O.held_index = l_hand_index_next //1, 3, 5, 7...
			hand_bodyparts += O
		else if(O.body_part == HAND_RIGHT)
			r_hand_index_next += 2
			O.held_index = r_hand_index_next //2, 4, 6, 8...
			hand_bodyparts += O

/mob/living/carbon/handle_diseases()
	. = ..()
	if(immunity > 0.2 * immunity_norm && immunity < immunity_norm)
		immunity = min(immunity + 0.25, immunity_norm)

/mob/living/carbon/proc/virus_immunity()
	. = 0
	var/antibiotic_boost = reagents.get_reagent_amount(/datum/reagent/medicine/spaceacillin) / 20
	return max(immunity/100 * (1+antibiotic_boost), antibiotic_boost)

/mob/living/carbon/proc/immunity_weakness()
	return max(2-virus_immunity(), 0)

/mob/living/carbon/proc/get_antibiotics()
	. = 0
	. += chem_effects[CE_ANTIBIOTIC]

/mob/living/carbon/Move(atom/newloc, direct = 0)
	. = ..()
	if(gunpointing)
		var/dir = get_dir(get_turf(gunpointing.source),get_turf(gunpointing.target))
		if(dir)
			setDir(dir)
	// Moving around increases germ_level faster
	if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
		germ_level++

//Wielding
/mob/living/carbon/wield_active_hand()
	var/obj/item/active = get_active_held_item()
	if(istype(active))
		active.wield_act(src)
	else
		to_chat(src, "<span class='warning'>You have nothing to wield!</span>")

/mob/living/carbon/proc/wield_ui_on()
	if(hud_used)
		hud_used.wielded.active = TRUE
		hud_used.wielded.update_icon()
		return TRUE

/mob/living/carbon/proc/wield_ui_off()
	if(hud_used)
		hud_used.wielded.active = FALSE
		hud_used.wielded.update_icon()
		return TRUE

//TGUI info menu
/mob/living/carbon/proc/item_info()
	var/obj/item/holding = get_active_held_item()
	if(istype(holding))
		SEND_SIGNAL(holding, COMSIG_ITEM_ITEMINFO, src)
	else
		to_chat(src, "<span class='warning'>You need to hold an item in your active hand to open it's information menu!</span>")

/mob/living/carbon/revive(full_heal, admin_revive)
	. = ..()
	//Regardless of full heal or not, we cap brain damage to 100 max
	if(getBrainLoss() >= 100)
		setBrainLoss(100)
	//Cap oxygen damage to 75
	if(getOxyLoss() > 75)
		setOxyLoss(75)

/mob/living/carbon/succumb()
	set name = "Succumb"
	set category = "IC"
	if(src.has_status_effect(/datum/status_effect/chem/enthrall))
		var/datum/status_effect/chem/enthrall/E = src.has_status_effect(/datum/status_effect/chem/enthrall)
		if(E.phase < 3)
			if(HAS_TRAIT(src, TRAIT_MINDSHIELD))
				to_chat(src, "<span class='notice'>Your mindshield prevents your mind from giving in!</span>")
			else if(src.mind.assigned_role in GLOB.command_positions)
				to_chat(src, "<span class='notice'>Your dedication to your department prevents you from giving in!</span>")
			else
				E.enthrallTally += 20
				to_chat(src, "<span class='notice'>You give into [E.master]'s influence.</span>")
	if(InShock())
		log_message("Has succumbed to death while in [InFullShock() ? "hard":"soft"] shock with [round(health, 0.1)] points of health!", LOG_ATTACK)
		adjustOxyLoss(health - HEALTH_THRESHOLD_DEAD)
		updatehealth()
		to_chat(src, "<span class='notice'>You have given up life and succumbed to death.</span>")
		death()

//Pulse
/mob/living/carbon/middle_attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(user.zone_selected in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND))
		return check_pulse(user)

/mob/living/carbon/proc/check_pulse(mob/living/carbon/user)
	var/self = FALSE
	if(user == src)
		self = TRUE
	
	if(!user.canUseTopic(src, TRUE) || INTERACTING_WITH(user, src))
		to_chat(user, "<span class='warning'>You're unable to check [self ? "your" : "<b>[src]</b>'s"] pulse.</</span>")
		return FALSE
	
	if((GET_SKILL_LEVEL(user, firstaid) < 10) || (GET_STAT_LEVEL(user, int) < 8))
		to_chat(user, "<span class='warning'>[pick("Uhh", "Ugh", "Hnngh", "Hmm")]... I don't know how to to that.</span>")
		return FALSE
	
	if(!self)
		user.visible_message("<span class='notice'><b>[user]</b> puts \his hand on <b>[src]</b>'s wrist and begins counting their pulse.</span>",\
		"<span class='notice'>You begin counting <b>[src]</b>'s pulse...</span>")
	else
		user.visible_message("<span class='notice'><b>[user]</b> begins counting their own pulse.</span>",\
		"<span class='notice'>You begin counting your pulse...</span>")

	var/pogtime = max(0.35, (MAX_SKILL - GET_SKILL_LEVEL(src, firstaid))/10)
	if(!do_mob(user, src, pogtime SECONDS))
		to_chat(user, "<span class='warning'>You failed to check [self ? "your" : "<b>[src]</b>'s"] pulse.</span>")
		return FALSE

	if(pulse())
		to_chat(user, "<span class='notice'>[self ? "You have a" : "<b>[src]</b> has a"] pulse! Counting...</span>")
	else
		to_chat(user, "<span class='danger'>[self ? "You have no" : "<b>[src]</b> has no"] pulse!</span>")
		return FALSE
	
	if(do_mob(user, src, pogtime * 5 SECONDS))
		to_chat(user, "<span class='notice'>[self ? "Your" : "<b>[src]</b>'s"] pulse is approximately <b>[src.get_pulse(GETPULSE_BASIC)] BPM</b>.</span>")
	else
		to_chat(user, "<span class='warning'>You failed to check [self ? "your" : "<b>[src]</b>'s"] pulse.</span>")

//zoomies
/mob/living/carbon
	var/default_zoomies = 4
	var/default_zoomout = 0
	var/zoomed = FALSE

/mob/living/carbon/CtrlShiftClickOn(atom/A)
	perform_zoom(A)
	return

/mob/living/carbon/proc/unperform_zoom() //used to unzoom when you die and stuff
	zoomed = FALSE
	client?.change_view(CONFIG_GET(string/default_view))
	client?.pixel_x = 0
	client?.pixel_y = 0
	if(hud_used?.fov_holder)
		hud_used.fov_holder.screen_loc = ui_fov

/mob/living/carbon/proc/perform_zoom(atom/A)
	//Maximum zoom is based on ranged skill
	//also we need a client fuck
	if(!mind || !client)
		to_chat(src, "<span class='warning'>My mindless form cannot look at the distance.</span>")
		return FALSE

	var/ranged_skill = GET_SKILL_LEVEL(src, ranged)
	var/dist = get_dist(src, A)
	var/zoomies = clamp(round(default_zoomies * ranged_skill/(MAX_SKILL/2)), 1, dist)
	var/zoomout = default_zoomout

	//Certain guns change our zoomies abilities
	var/obj/item/gun/G = get_active_held_item()
	if(istype(G))
		zoomies = min(dist, round(G.zoom_amt * ranged_skill/(MAX_SKILL/2)))
		zoomout = round(G.zoom_out_amt * ranged_skill/(MAX_SKILL/2))
	
	//Big chungus
	zoomed = !zoomed
	var/_x = 0
	var/_y = 0
	if(zoomed)
		var/direction = get_dir(src, A)
		if(direction & NORTH)
			_y += zoomies
		if(direction & EAST)
			_x += zoomies
		if(direction & SOUTH)
			_y += -zoomies
		if(direction & WEST)
			_x += -zoomies

	if(zoomed)		
		if(zoomout)
			client.change_view(zoomout)
		
		client.pixel_x = world.icon_size*_x
		client.pixel_y = world.icon_size*_y
		if(hud_used?.fov_holder)
			hud_used.fov_holder.screen_loc = "CENTER-7:[world.icon_size*-_x],CENTER-7:[world.icon_size*-_y]"
	else
		client.change_view(CONFIG_GET(string/default_view))
		client.pixel_x = 0
		client.pixel_y = 0
		if(hud_used?.fov_holder)
			hud_used.fov_holder.screen_loc = ui_fov
	to_chat(src, "<span class='notice'>I [zoomed ? "look" : "stop looking"] at the distance.</span>")

/mob/living/carbon/on_examine_atom(atom/examined)
	if(!istype(examined) || !client || !examined.on_examined_check())
		return

	if((get_dist(src, examined) > EYE_CONTACT_RANGE) || (stat > CONSCIOUS))
		return
	
	if(CHECK_BITFIELD(wear_mask?.flags_inv, HIDEFACE) || CHECK_BITFIELD(head?.flags_inv, HIDEFACE) || CHECK_BITFIELD(glasses?.flags_inv, HIDEFACE))
		return
	
	if(!ismob(examined))
		visible_message("<span class='notice'>\The <b>[src]</b> looks at [examined].</span>", "<span class='notice'>I look at [examined].</span>", vision_distance = 4)
	else
		visible_message("<span class='notice'>\The <b>[src]</b> looks at <b>[examined]</b>.</span>", "<span class='notice'>I look at <b>[examined]</b>.</span>", vision_distance = 4)

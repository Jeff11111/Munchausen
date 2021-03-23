
#define DUALWIELD_PENALTY_EXTRA_MULTIPLIER 1.4
#define SEMIAUTO	1
#define ROUNDBURST	2
#define FULLAUTO	3

/obj/item/gun
	name = "gun"
	desc = "It's a gun. It's pretty terrible, though."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron=2000)
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	item_flags = NEEDS_PERMIT
	attack_verb = list("struck", "hit", "bashed")

	var/fire_sound = "gunshot"
	var/recoil = 0						//boom boom shake the room
	var/clumsy_check = TRUE
	var/obj/item/ammo_casing/chambered = null
	trigger_guard = TRIGGER_GUARD_NORMAL	//trigger guard on the weapon, hulks can't fire them with their big meaty fingers
	var/sawn_desc = null				//description change if weapon is sawn-off
	var/sawn_off = FALSE

	/// can we be put into a turret
	var/can_turret = TRUE
	/// can we be put in a circuit
	var/can_circuit = TRUE
	/// can we be put in an emitter
	var/can_emitter = TRUE

	/// Weapon is burst fire if this is above 1
	var/burst_size = 1
	/// The time between shots in burst.
	var/burst_shot_delay = 0.5 SECONDS
	/// The time between firing actions, this means between bursts if this is burst weapon. The reason this is 0 is because you are still, by default, limited by clickdelay.
	var/fire_delay = 0.5 SECONDS
	/// Last world.time this was fired
	var/last_fire = 0
	/// Currently firing, whether or not it's a burst or not.
	var/firing = FALSE
	/// Used in gun-in-mouth execution/suicide and similar, while TRUE nothing should work on this like firing or modification and so on and so forth.
	var/busy_action = FALSE
	var/weapon_weight = WEAPON_LIGHT	//used for inaccuracy and wielding requirements/penalties
	var/spread = 0						//Spread induced by the gun itself.
	var/burst_spread = 1				//Spread induced by the gun itself during burst fire per iteration. Only checked if spread is 0.
	var/randomspread = 1				//Set to 0 for shotguns. This is used for weapons that don't fire all their bullets at once.
	var/inaccuracy_modifier = 1

	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

	//Firing pin stuff
	var/obj/item/firing_pin/pin = /obj/item/firing_pin //reference for the current firing pin, and typepath of the initial firing pin
	var/no_pin_required = FALSE //whether the gun can be fired without a pin

	// Flashlight stuff
	var/obj/item/flashlight/gun_light
	var/mutable_appearance/flashlight_overlay
	var/flight_x_offset = 15
	var/flight_y_offset = 10
	var/can_flashlight = TRUE
	var/can_unflashlight = TRUE
	var/datum/action/item_action/toggle_gunlight/alight
	var/custom_light_icon //custom flashlight icon
	var/custom_light_state //custom flashlight state
	var/custom_light_color //custom flashlight light color

	// Bayonet stuff
	var/obj/item/kitchen/knife/bayonet
	var/mutable_appearance/knife_overlay
	var/knife_x_offset = 15
	var/knife_y_offset = 8
	var/can_bayonet = FALSE
	var/can_unbayonet = TRUE

	// Suppressor stuff
	var/obj/item/suppressor/suppressed //having a suppressor means we dont make funny sound
	var/mutable_appearance/suppressed_overlay //this ass can fart
	var/suppressed_pixel_x = 4
	var/suppressed_pixel_y = 0
	var/sound_suppressed = 'modular_skyrat/sound/weapons/shot_silenced.ogg' //fire sound when suppressed
	var/can_suppress = FALSE
	var/can_unsuppress = TRUE

	// Sling stuff
	var/obj/item/stack/cable_coil/sling
	var/mutable_appearance/sling_overlay
	var/sling_icon_state = "sling_overlay"
	var/sling_pixel_x = 0
	var/sling_pixel_y = 0
	var/can_sling = TRUE
	var/can_unsling = TRUE

	// Safety stuff
	var/has_safety = TRUE
	var/safety = TRUE
	var/mutable_appearance/safety_overlay
	var/safety_sound = 'modular_skyrat/sound/weapons/safety1.ogg'

	// Used for positioning ammo count overlay on some sprites
	var/ammo_x_offset = 0
	var/ammo_y_offset = 0

	// Zooming
	var/zoomable = FALSE //whether the gun generates a Zoom action on creation
	var/zoomed = FALSE //Zoom toggle
	var/zoom_amt = 3 //Distance in TURFs to move the user's screen forward (the "zoom" effect)
	var/zoom_out_amt = 0
	var/datum/action/item_action/toggle_scope_zoom/azoom

	var/dualwield_spread_mult = 1		//dualwield spread multiplier

	/// Just 'slightly' snowflakey way to modify projectile damage for projectiles fired from this gun.
	var/projectile_damage_multiplier = 1

	/// It's less intensive to use a boolean rather than always getting the component when firing
	var/is_wielded = FALSE

/obj/item/gun/Initialize()
	. = ..()
	if(no_pin_required)
		pin = null
	else if(pin)
		pin = new pin(src)
	if(gun_light)
		alight = new (src)
	if(zoomable)
		azoom = new (src)
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)
	addtimer(CALLBACK(src, /atom.proc/update_icon), 2)

/obj/item/gun/proc/on_wield(mob/living/carbon/user)
	is_wielded = TRUE
	update_icon()

/obj/item/gun/proc/on_unwield(mob/living/carbon/user)
	is_wielded = FALSE
	update_icon()

/obj/item/gun/verb/safety_toggle()
	set name = "Toggle Safety"
	set category = "Object"
	set desc = "Toggle a firearm's safety mechanisms."

	if(!has_safety)
		set hidden = TRUE

	if(usr.default_can_use_topic(src))
		perform_safety(usr)

/obj/item/gun/Destroy()
	if(pin)
		QDEL_NULL(pin)
	if(gun_light)
		QDEL_NULL(gun_light)
	if(bayonet)
		QDEL_NULL(bayonet)
	if(chambered)
		QDEL_NULL(chambered)
	return ..()

/obj/item/gun/CheckParts(list/parts_list)
	..()
	var/obj/item/gun/G = locate(/obj/item/gun) in contents
	if(G)
		G.forceMove(loc)
		QDEL_NULL(G.pin)
		visible_message("[G] can now fit a new pin, but the old one was destroyed in the process.", null, null, 3)
		qdel(src)

/obj/item/gun/examine(mob/user)
	. = ..()
	if(!no_pin_required)
		if(pin)
			. += "It has \a [pin] installed."
		else
			. += "It doesn't have a firing pin installed, and won't fire."
	if(has_safety)
		. += "It's safety is [safety ? "<span class='green'><b>enabled</b></span>" : "<span class='red'><b>disabled</b></span>"]."
	if(gun_light)
		. += "It has \a [gun_light] attached, at [gun_light.powercell ? gun_light.powercell.percent() : 0 ]% power."
	if(suppressed)
		. += "It is suppressed with \a <i>[suppressed]</i>."
	if(bayonet)
		. += "It has \a <i>[bayonet]</i> attached as a bayonet."
	switch(weapon_weight)
		if(WEAPON_HEAVY)
			. += "It is a <b>heavy</b> weapon."
		if(WEAPON_MEDIUM)
			. += "It is a <b>medium-weight</b> weapon."
		if(WEAPON_LIGHT)
			. += "It is a <b>lightweight</b> weapon."

/obj/item/gun/rightclick_attack_self(mob/user)
	return perform_safety(user)

/obj/item/gun/proc/perform_safety(mob/user)
	toggle_safety(user)
	return TRUE

/obj/item/gun/proc/toggle_safety(mob/user)
	safety = !safety
	if(user)
		to_chat(user, "<span class='notice'>I [safety ? "enable" : "disable"] \the [src]'s safety mechanism.</span>")
		playsound(get_turf(src), safety_sound, 50, 0)
	update_icon()

/obj/item/gun/equipped(mob/living/user, slot)
	. = ..()
	if(zoomed && user.get_active_held_item() != src)
		zoom(user, FALSE) //we can only stay zoomed in if it's in our hands	//yeah and we only unzoom if we're actually zoomed using the gun!!

//called after the gun has successfully fired its chambered ammo.
/obj/item/gun/proc/process_chamber(mob/living/user)
	return FALSE

//check if there's enough ammo/energy/whatever to shoot one time
//i.e if clicking would make it shoot
/obj/item/gun/proc/can_shoot()
	return TRUE

/obj/item/gun/proc/shoot_with_empty_chamber(mob/living/user as mob|obj, no_message = FALSE)
	if(on_cooldown())
		return FALSE
	if(!no_message)
		to_chat(user, "<span class='danger'>*click*</span>")
	playsound(src, "gun_dry_fire", 30, 1)

/obj/item/gun/proc/shoot_live_shot(mob/living/user, pointblank = FALSE, mob/pbtarget, message = 1, stam_cost = 0)
	if(recoil)
		shake_camera(user, recoil + 1, recoil)

	if(stam_cost)
		var/safe_cost = clamp(stam_cost, 0, STAMINA_NEAR_CRIT - user.getStaminaLoss())*(firing && burst_size >= 2 ? 1/burst_size : 1)
		user.adjustStaminaLossBuffered(safe_cost)

	if(suppressed)
		playsound(user, fire_sound, 10, 1)
	else
		playsound(user, fire_sound, 50, 1)
		if(message)
			if(pointblank)
				user.visible_message("<span class='danger'><b>[user]</b> fires [src] point blank at <b>[pbtarget]</b>!</span>", null, null, COMBAT_MESSAGE_RANGE)
			else
				user.visible_message("<span class='danger'><b>[user]</b> fires [src]!</span>", null, null, COMBAT_MESSAGE_RANGE)

	var/ranged = GET_SKILL_LEVEL(user, ranged)
	if(!is_wielded && (((weapon_weight >= WEAPON_HEAVY) && !(ranged >= JOB_SKILLPOINTS_EXPERT)) || ((weapon_weight >= WEAPON_MEDIUM) && !(ranged >= JOB_SKILLPOINTS_NOVICE))))
		user.visible_message("<span class='danger'>\The [src] falls out of <b>[user]</b>'s unskilled hands!</span>", \
						"<span class='userdanger'>\The [src] falls out of my unskilled hands!</span>")
		user.dropItemToGround(src)

/obj/item/gun/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_CONTENTS))
		for(var/obj/O in contents)
			O.emp_act(severity)

/obj/item/gun/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	process_afterattack(target, user, flag, params)

/obj/item/gun/proc/process_afterattack(atom/target, mob/living/user, flag, params)
	if(!target)
		return
	if(firing)
		return
	var/stamloss = user.getStaminaLoss()
	if(stamloss >= STAMINA_NEAR_SOFTCRIT) //The more tired you are, the less damage you do.
		var/penalty = (stamloss - STAMINA_NEAR_SOFTCRIT)/(STAMINA_NEAR_CRIT - STAMINA_NEAR_SOFTCRIT)*STAM_CRIT_GUN_DELAY
		//low dexterity = higher penalty
		var/dexterity = GET_STAT_LEVEL(user, dex)
		penalty = max(0, penalty + (10-dexterity)/10)
		user.changeNext_move(CLICK_CD_RANGE+(CLICK_CD_RANGE*penalty))
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || (user.a_intent == INTENT_HARM && (user != target) && !isturf(target))) //melee attack
			return
		if(iscarbon(target))
			var/mob/living/carbon/C = target
			for(var/datum/wound/W in C.all_wounds)
				if(W.try_treating(src, user))
					return // another coward cured!

	if(istype(user))//Check if the user can use the gun, if the user isn't alive(turrets) assume it can.
		var/mob/living/L = user
		if(!can_trigger_gun(L))
			return

	if(!can_shoot()) //Just because you can pull the trigger doesn't mean it can shoot.
		shoot_with_empty_chamber(user)
		return

	//Exclude lasertag guns from the TRAIT_CLUMSY check.
	if(clumsy_check)
		if(istype(user))
			if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(40))
				to_chat(user, "<span class='userdanger'>You shoot yourself in the foot with [src]!</span>")
				var/shot_leg = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
				process_fire(user, user, FALSE, params, shot_leg)
				user.dropItemToGround(src, TRUE)
				return

	//Critical failures
	if(user.mind)
		switch(user.mind.diceroll(GET_STAT_LEVEL(user, dex)*0.5, GET_SKILL_LEVEL(user, ranged)))
			if(DICE_CRIT_FAILURE)
				to_chat(user, "<span class='userdanger'><b>CRITICAL FAILURE!</b></span>")
				process_fire(user, user)
				return

	var/ranged = GET_SKILL_LEVEL(user, ranged)

	//DUAL (or more!) WIELDING
	var/bonus_spread = 0
	var/loop_counter = 0

	if(user)
		bonus_spread += getinaccuracy(user, bonus_spread, stamloss)
		bonus_spread += calculate_extra_inaccuracy(user, bonus_spread, stamloss)

	if(ishuman(user) && user.a_intent == INTENT_HARM && weapon_weight <= WEAPON_LIGHT)
		var/mob/living/carbon/human/H = user
		for(var/obj/item/gun/G in H.held_items)
			if(G == src || G.weapon_weight >= WEAPON_MEDIUM)
				continue
			else if(G.can_trigger_gun(user))
				bonus_spread += (15 * G.weapon_weight * G.dualwield_spread_mult * (ranged ? ((MAX_SKILL/2)/ranged) : 1))
				loop_counter++
				var/stam_cost = G.getstamcost(user)
				addtimer(CALLBACK(G, /obj/item/gun.proc/process_fire, target, user, TRUE, params, null, bonus_spread, stam_cost), loop_counter)

	var/stam_cost = getstamcost(user)
	process_fire(target, user, TRUE, params, null, bonus_spread, stam_cost)

/obj/item/gun/can_trigger_gun(mob/living/user)
	. = ..()
	if(!.)
		return
	if(!handle_pins(user))
		return FALSE
	if(HAS_TRAIT(user, TRAIT_PACIFISM) && chambered?.harmful) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
		to_chat(user, "<span class='notice'> [src] is lethally chambered! You don't want to risk harming anyone...</span>")
		return FALSE

/obj/item/gun/proc/calculate_extra_inaccuracy()
	return 0

/obj/item/gun/proc/handle_pins(mob/living/user)
	if(no_pin_required)
		return TRUE
	if(pin)
		if(pin.pin_auth(user) || (pin.obj_flags & EMAGGED))
			return TRUE
		else
			pin.auth_fail(user)
			return FALSE
	else
		to_chat(user, "<span class='warning'>[src]'s trigger is locked. This weapon doesn't have a firing pin installed!</span>")
	return FALSE

/obj/item/gun/proc/recharge_newshot()
	return

/obj/item/gun/proc/on_cooldown()
	return busy_action || firing || (last_fire + fire_delay > world.time)

/obj/item/gun/proc/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, stam_cost = 0)
	add_fingerprint(user)
	if(on_cooldown())
		return
	firing = TRUE
	. = do_fire(target, user, message, params, zone_override, bonus_spread, stam_cost)
	firing = FALSE
	last_fire = world.time

	if(user)
		user.update_inv_hands()
		SEND_SIGNAL(user, COMSIG_LIVING_GUN_PROCESS_FIRE, target, params, zone_override, bonus_spread, stam_cost)

/obj/item/gun/proc/do_fire(atom/target, mob/living/user, message = TRUE, params, zone_override = "", bonus_spread = 0, stam_cost = 0)
	var/sprd = 0
	var/randomized_gun_spread = 0
	var/rand_spr = rand()
	if(spread)
		randomized_gun_spread = rand(0, spread)
	else if(burst_size > 1 && burst_spread)
		randomized_gun_spread = rand(0, burst_spread)
	if(HAS_TRAIT(user, TRAIT_POOR_AIM)) //nice shootin' tex
		bonus_spread += 25

	var/randomized_bonus_spread = 0
	if(bonus_spread)
		randomized_bonus_spread = rand(0, bonus_spread)
	if(burst_size > 1)
		before_firing(target,user)
		do_burst_shot(user, target, message, params, zone_override, sprd, randomized_gun_spread, randomized_bonus_spread, rand_spr, 1)
		for(var/i in 2 to burst_size)
			sleep(burst_shot_delay)
			if(QDELETED(src))
				break
			do_burst_shot(user, target, message, params, zone_override, sprd, randomized_gun_spread, randomized_bonus_spread, rand_spr, i, stam_cost)
	else
		if(chambered)
			var/dual_wield_penalty_multiplier = 1
			if(user.a_intent == INTENT_HARM && istype(user.get_inactive_held_item(), /obj/item/gun))
				dual_wield_penalty_multiplier += DUALWIELD_PENALTY_EXTRA_MULTIPLIER
			sprd = round((rand() * pick(1, -1)) * dual_wield_penalty_multiplier * (randomized_gun_spread + randomized_bonus_spread))
			before_firing(target,user)
			if((safety && has_safety) || !chambered.fire_casing(target, user, params, null, suppressed, zone_override, sprd, src))
				shoot_with_empty_chamber(user)
				return
			else
				if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
					shoot_live_shot(user, 1, target, message, stam_cost)
				else
					shoot_live_shot(user, 0, target, message, stam_cost)
		else
			shoot_with_empty_chamber(user)
			return
		process_chamber(user)
		update_icon()

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)
	return TRUE

/obj/item/gun/proc/do_burst_shot(mob/living/user, atom/target, message = TRUE, params=null, zone_override = "", sprd = 0, randomized_gun_spread = 0, randomized_bonus_spread = 0, rand_spr = 0, iteration = 0, stam_cost = 0)
	if(!user || !firing)
		firing = FALSE
		return FALSE
	if(!issilicon(user))
		if(iteration > 1 && !(user.is_holding(src))) //for burst firing
			firing = FALSE
			return FALSE
	if(chambered && chambered.BB)
		if(HAS_TRAIT(user, TRAIT_PACIFISM)) // If the user has the pacifist trait, then they won't be able to fire [src] if the round chambered inside of [src] is lethal.
			if(chambered.harmful) // Is the bullet chambered harmful?
				to_chat(user, "<span class='notice'> [src] is lethally chambered! You don't want to risk harming anyone...</span>")
				return
		if(randomspread)
			sprd = round((rand() * pick(1, -1)) * DUALWIELD_PENALTY_EXTRA_MULTIPLIER * (randomized_gun_spread + randomized_bonus_spread), 1)
		else //Smart spread
			sprd = round((((rand_spr/burst_size) * iteration) - (0.5 + (rand_spr * 0.25))) * (randomized_gun_spread + randomized_bonus_spread), 1)
		before_firing(target,user)
		if((safety && has_safety) || !chambered.fire_casing(target, user, params, null, suppressed, zone_override, sprd, src))
			shoot_with_empty_chamber(user)
			firing = FALSE
			return FALSE
		else
			if(get_dist(user, target) <= 1) //Making sure whether the target is in vicinity for the pointblank shot
				shoot_live_shot(user, 1, target, message, stam_cost)
			else
				shoot_live_shot(user, 0, target, message, stam_cost)
			if (iteration >= burst_size)
				firing = FALSE
	else
		shoot_with_empty_chamber(user)
		firing = FALSE
		return FALSE
	process_chamber(user)
	update_icon()
	return TRUE

/obj/item/gun/attack(mob/living/M, mob/user)
	if(user.a_intent == INTENT_HARM) //Flogging
		if(bayonet)
			M.attackby(bayonet, user)
			attack_delay_done = TRUE
			return
		else
			return ..()
	attack_delay_done = TRUE //we are firing the gun, not bashing people with its butt.

/obj/item/gun/update_overlays()
	. = ..()
	. += build_overlays()

/obj/item/gun/proc/build_overlays()
	. = list()
	if(suppressed_overlay)
		. |= suppressed_overlay
	if(flashlight_overlay)
		. |= flashlight_overlay
	if(knife_overlay)
		. |= knife_overlay
	if(sling_overlay)
		. |= sling_overlay

/obj/item/gun/middle_attack_hand(mob/user)
	. = ..()
	if(src in user.held_items)
		if(!user.is_holding(src))
			return ..()
		else if(suppressed && can_unsuppress)
			var/obj/item/suppressor/S = suppressed
			to_chat(user, "<span class='notice'>You unscrew \the [S] from [src].</span>")
			user.put_in_hands(S)
			fire_sound = S.oldsound
			w_class -= S.w_class
			suppressed = null
			suppressed_overlay = null
			update_icon()
			return TRUE
		else if(gun_light && can_unflashlight)
			var/obj/item/flashlight/seclite/S = gun_light
			to_chat(user, "<span class='notice'>You unscrew \the [S] from \the [src].</span>")
			user.put_in_hands(S)
			gun_light = null
			update_gunlight(user)
			S.update_brightness(user)
			QDEL_NULL(alight)
			update_icon()
			return TRUE
		else if(bayonet && can_unbayonet)
			var/obj/item/kitchen/knife/K = bayonet
			to_chat(user, "<span class='notice'>You unscrew \the [K] from \the [src].</span>")
			user.put_in_hands(K)
			bayonet = null
			knife_overlay = null
			update_icon()
			return TRUE
		else if(sling && can_unsling)
			var/obj/item/slong = sling
			to_chat(user, "<span class='notice'>You rip \the [slong] from \the [src].</span>")
			QDEL_NULL(sling)
			sling_overlay = null
			update_icon()
			return TRUE

/obj/item/gun/attack_obj(obj/O, mob/user)
	if(user.a_intent == INTENT_HARM)
		if(bayonet)
			O.attackby(bayonet, user)
			return TRUE
	return ..()

/obj/item/gun/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()
	else if(istype(I, /obj/item/flashlight/seclite))
		if(!can_flashlight)
			return ..()
		var/obj/item/flashlight/seclite/S = I
		if(!gun_light)
			if(!user.transferItemToLoc(I, src))
				return
			to_chat(user, "<span class='notice'>You click \the [S] into place on \the [src].</span>")
			if(S.on)
				set_light(0)
			gun_light = S
			update_gunlight(user)
			alight = new /datum/action/item_action/toggle_gunlight(src)
			if(loc == user)
				alight.Grant(user)
	else if(istype(I, /obj/item/kitchen/knife))
		var/obj/item/kitchen/knife/K = I
		if(!can_bayonet || !K.bayonet || bayonet) //ensure the gun has an attachment point available, and that the knife is compatible with it.
			return ..()
		if(!user.transferItemToLoc(I, src))
			return
		to_chat(user, "<span class='notice'>You attach \the [K] to the front of \the [src].</span>")
		bayonet = K
		var/state = "bayonet"							//Generic state.
		if(bayonet.icon_state in icon_states('icons/obj/guns/bayonets.dmi'))		//Snowflake state?
			state = bayonet.icon_state
		var/icon/bayonet_icons = 'icons/obj/guns/bayonets.dmi'
		knife_overlay = mutable_appearance(bayonet_icons, state)
		knife_overlay.pixel_x = knife_x_offset
		knife_overlay.pixel_y = knife_y_offset
		update_icon()
	else if(istype(I, /obj/item/stack/cable_coil))
		if(!can_sling || sling)
			return ..()
		if(I.use_tool(src, user, 0, 10))
			slot_flags |= (ITEM_SLOT_BACK | ITEM_SLOT_SUITSTORE)
			to_chat(user, "<span class='notice'>You tie the lengths of cable to \the [src], making a sling.</span>")
			sling = new /obj/item/stack/cable_coil(src)
			sling_overlay = mutable_appearance((sling_icon_state && (sling_icon_state != "sling_overlay")) ? icon : 'modular_skyrat/icons/obj/bobstation/gun_mods/mods.dmi', sling_icon_state)
			sling_overlay.pixel_x = sling_pixel_x
			sling_overlay.pixel_y = sling_pixel_y
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least ten lengths of cable if you want to make a sling!</span>")
	else
		return ..()

/obj/item/gun/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_scope_zoom))
		zoom(user)
	else if(istype(action, alight))
		toggle_gunlight()

/obj/item/gun/proc/toggle_gunlight()
	if(!gun_light)
		return

	var/mob/living/carbon/human/user = usr
	gun_light.on = !gun_light.on
	to_chat(user, "<span class='notice'>You toggle the gunlight [gun_light.on ? "on":"off"].</span>")

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_gunlight(user)
	return

/obj/item/gun/proc/update_gunlight(mob/user = null)
	if(gun_light)
		var/datum/component/overlay_lighting/OL = GetComponent(/datum/component/overlay_lighting)
		if(!OL)
			OL = AddComponent(/datum/component/overlay_lighting, gun_light.light_color, gun_light.brightness_on, gun_light.flashlight_power, FALSE)
		if(gun_light.on)
			OL.turn_on()
		else
			OL.turn_off()
		cut_overlays(flashlight_overlay, TRUE)
		var/icon2use = 'icons/obj/guns/flashlights.dmi'
		var/state = "flight[gun_light.on? "_on":""]"	//Generic state.
		if(gun_light.icon_state in icon_states('icons/obj/guns/flashlights.dmi'))	//Snowflake state?
			state = gun_light.icon_state
		if(custom_light_state)
			state = "[custom_light_state][gun_light.on? "_on":""]"
		if(custom_light_icon)
			icon2use = custom_light_icon
		flashlight_overlay = mutable_appearance(icon2use, state)
		if(!custom_light_icon)
			flashlight_overlay.pixel_x = flight_x_offset
			flashlight_overlay.pixel_y = flight_y_offset
		add_overlay(flashlight_overlay, TRUE)
	else
		//set_light(0)
		cut_overlays(flashlight_overlay, TRUE)
		flashlight_overlay = null
	update_icon(TRUE)
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/gun/item_action_slot_check(slot, mob/user, datum/action/A)
	if(istype(A, /datum/action/item_action/toggle_scope_zoom) && slot != SLOT_HANDS)
		return FALSE
	return ..()

/obj/item/gun/proc/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params, bypass_timer)
	if(!ishuman(user) || !ishuman(target))
		return

	if(on_cooldown())
		return

	if(user == target)
		target.visible_message("<span class='warning'>[user] sticks [src] in [user.p_their()] mouth, ready to pull the trigger...</span>", \
			"<span class='userdanger'>You stick [src] in your mouth, ready to pull the trigger...</span>")
	else
		target.visible_message("<span class='warning'>[user] points [src] at [target]'s head, ready to pull the trigger...</span>", \
			"<span class='userdanger'>[user] points [src] at your head, ready to pull the trigger...</span>")

	busy_action = TRUE

	if(!bypass_timer && (!do_mob(user, target, 120) || user.zone_selected != BODY_ZONE_PRECISE_MOUTH))
		if(user)
			if(user == target)
				user.visible_message("<span class='notice'>[user] decided not to shoot.</span>")
			else if(target && target.Adjacent(user))
				target.visible_message("<span class='notice'>[user] has decided to spare [target]</span>", "<span class='notice'>[user] has decided to spare your life!</span>")
		busy_action = FALSE
		return

	busy_action = FALSE

	target.visible_message("<span class='warning'>[user] pulls the trigger!</span>", "<span class='userdanger'>[user] pulls the trigger!</span>")

	playsound('sound/weapons/dink.ogg', 30, 1)

	if(chambered && chambered.BB)
		chambered.BB.damage *= 5

	process_fire(target, user, TRUE, params, stam_cost = getstamcost(user))

/obj/item/gun/proc/unlock() //used in summon guns and as a convience for admins
	if(pin)
		qdel(pin)
	pin = new /obj/item/firing_pin

//Happens before the actual projectile creation
/obj/item/gun/proc/before_firing(atom/target,mob/user)
	return

/////////////
// ZOOMING //
/////////////

/datum/action/item_action/toggle_scope_zoom
	name = "Toggle Scope"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"

/datum/action/item_action/toggle_scope_zoom/IsAvailable(silent = FALSE)
	. = ..()
	if(!.)
		var/obj/item/gun/G = target
		G.zoom(owner, FALSE)

/datum/action/item_action/toggle_scope_zoom/Remove(mob/living/L)
	var/obj/item/gun/G = target
	G.zoom(L, FALSE)
	return ..()

/obj/item/gun/proc/zoom(mob/living/user, forced_zoom)
	if(!(user?.client))
		return

	//Maximum zoom is based on ranged skill
	if(!user.mind)
		to_chat(user, "<span class='warning'>My mindless form cannot aim with [src].</span>")
		return FALSE

	var/ranged_skill = GET_SKILL_LEVEL(user, ranged)
	if(ranged_skill <= JOB_SKILLPOINTS_NOVICE)
		to_chat(user, "<span class='warning'>I am far too incompetent to aim with [src].</span>")
		return FALSE

	var/zoomies = round(zoom_amt * ranged_skill/(MAX_SKILL/2))
	if(!isnull(forced_zoom))
		if(zoomed == forced_zoom)
			return
		zoomed = forced_zoom
	else
		zoomed = !zoomed

	if(zoomed)
		var/_x = 0
		var/_y = 0
		switch(user.dir)
			if(NORTH)
				_y = zoomies
			if(EAST)
				_x = zoomies
			if(SOUTH)
				_y = -zoomies
			if(WEST)
				_x = -zoomies

		if(zoom_out_amt)
			user.client.change_view(zoom_out_amt)
		user.client.pixel_x = world.icon_size*_x
		user.client.pixel_y = world.icon_size*_y
	else
		if(zoom_out_amt)
			user.client.change_view(CONFIG_GET(string/default_view))
		user.client.pixel_x = 0
		user.client.pixel_y = 0

/obj/item/gun/handle_atom_del(atom/A)
	if(A == chambered)
		chambered = null
		update_icon()

/obj/item/gun/pickup(mob/user)
	. = ..()
	//Picking up a gun, even if you're just swapping hands, changes the last_fire var
	//Why? Because picking up a gun and firing at people instantly is terrible, you should AIM
	last_fire = world.time

/obj/item/gun/proc/getinaccuracy(mob/living/user, bonus_spread, stamloss)
	var/ranged_skill = GET_SKILL_LEVEL(user, ranged)
	//Wielding always makes you aim better, no matter the weapon size
	if(!is_wielded)
		var/spread_penalty = 4 * (weapon_weight - WEAPON_LIGHT)
		if(ranged_skill)
			spread_penalty *= (MAX_SKILL/2)/ranged_skill
		bonus_spread += (spread_penalty * weapon_weight)
	if(inaccuracy_modifier <= 0)
		return bonus_spread
	var/base_inaccuracy = 10 * weapon_weight * inaccuracy_modifier
	var/noaim_penalty = 0 //Otherwise aiming would be meaningless for slower guns such as sniper rifles and launchers
	//Firing guns repeatedly is bad, don't go full auto man
	var/penalty = max((last_fire + fire_delay + GUN_AIMING_TIME) - world.time, 0) //Time we didn't take to aim, but should have
	if(penalty > 0)
		if((penalty >= 1 SECONDS) && (chambered?.BB))
			to_chat(user, "<span class='warning'>I should have waited a bit more.</span>")
		noaim_penalty = (penalty * 2)
	if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_ACTIVE)) //To be removed in favor of something less tactless later.
		base_inaccuracy *= 0.75
	if(stamloss >= STAMINA_NEAR_SOFTCRIT) //This can null out the above bonus.
		base_inaccuracy *= 1 + (stamloss - STAMINA_NEAR_SOFTCRIT)/(STAMINA_NEAR_CRIT - STAMINA_NEAR_SOFTCRIT)*0.5
	var/datum/component/mood/insanity = user.GetComponent(/datum/component/mood)
	if(insanity)
		//Mood fucks up your aim if it's low enough
		if(insanity.sanity <= 50)
			base_inaccuracy += weapon_weight * 5 * inaccuracy_modifier
			if(insanity.sanity <= 25)
				base_inaccuracy += weapon_weight * 5 * inaccuracy_modifier
	//Damn we suck huh
	base_inaccuracy *= (MAX_SKILL/2)/ranged_skill
	var/mult = clamp(noaim_penalty/GUN_AIMING_TIME, 1, 4)
	return max(bonus_spread + (base_inaccuracy * mult), 0)

/obj/item/gun/proc/getstamcost(mob/living/carbon/user)
	. = recoil * 2
	if(user && !user.has_gravity())
		. = recoil * 10

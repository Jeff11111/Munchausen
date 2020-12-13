/**
  * Combat mode component. It makes the user face whichever atom the mouse pointer is hovering,
  * amongst other things designed outside of this file, namely PvP and PvE stuff, hence the name.
  * Can be toggled on and off by clicking the screen hud object or by pressing the assigned hotkey (default 'C')
  */
/datum/component/combat_mode
	var/mode_flags = COMBAT_MODE_INACTIVE
	var/combatmessagecooldown
	var/lastmousedir
	var/obj/screen/combattoggle/hud_icon
	var/hud_loc

/datum/component/combat_mode/Initialize(hud_loc = ui_combat_toggle)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/L = parent

	src.hud_loc = hud_loc

	RegisterSignal(L, SIGNAL_TRAIT(TRAIT_COMBAT_MODE_LOCKED), .proc/update_combat_lock)
	RegisterSignal(L, COMSIG_TOGGLE_COMBAT_MODE, .proc/user_toggle_intentional_combat_mode)
	RegisterSignal(L, COMSIG_DISABLE_COMBAT_MODE, .proc/safe_disable_combat_mode)
	RegisterSignal(L, COMSIG_ENABLE_COMBAT_MODE, .proc/safe_enable_combat_mode)
	RegisterSignal(L, COMSIG_MOB_DEATH, .proc/on_death)
	RegisterSignal(L, COMSIG_MOB_CLIENT_LOGOUT, .proc/on_logout)
	RegisterSignal(L, COMSIG_MOB_HUD_CREATED, .proc/on_mob_hud_created)
	RegisterSignal(L, COMSIG_COMBAT_MODE_CHECK, .proc/check_flags)

	update_combat_lock()

	if(L.client)
		on_mob_hud_created(L)

/datum/component/combat_mode/Destroy()
	if(parent)
		safe_disable_combat_mode(parent)
	if(hud_icon)
		var/mob/living/L = parent
		L?.hud_used?.combat_mode = null
		L?.hud_used?.static_inventory -= hud_icon
		QDEL_NULL(hud_icon)
	return ..()

/// Creates the hud screen object.
/datum/component/combat_mode/proc/on_mob_hud_created(mob/source)
	hud_icon = new
	hud_icon.hud = source.hud_used
	hud_icon.icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	hud_icon.screen_loc = hud_loc
	source.hud_used.combat_mode = hud_icon
	source.hud_used.static_inventory += hud_icon
	hud_icon.update_icon()
	source.client?.screen |= hud_icon

/// Combat mode can be locked out, forcibly disabled by a status trait.
/datum/component/combat_mode/proc/update_combat_lock()
	var/locked = HAS_TRAIT(parent, TRAIT_COMBAT_MODE_LOCKED)
	var/desired = CHECK_BITFIELD(mode_flags, COMBAT_MODE_TOGGLED)
	var/actual = CHECK_BITFIELD(mode_flags, COMBAT_MODE_ACTIVE)
	if(actual)
		if(locked)
			disable_combat_mode(parent, FALSE, TRUE)
		else if(!desired)
			disable_combat_mode(parent, TRUE, TRUE)
	else
		if(desired && !locked)
			enable_combat_mode(parent, FALSE, TRUE)

/// Enables combat mode. Please use 'safe_enable_combat_mode' instead, if you wish to also enable the toggle flag.
/datum/component/combat_mode/proc/enable_combat_mode(mob/living/source, silent = TRUE, forced = TRUE, visible = FALSE, locked = FALSE, playsound = FALSE)
	if(locked)
		if(hud_icon)
			hud_icon.combat_on = TRUE
			hud_icon.update_icon()
		return
	if(CHECK_BITFIELD(mode_flags, COMBAT_MODE_ACTIVE))
		return
	mode_flags |= COMBAT_MODE_ACTIVE
	mode_flags &= ~COMBAT_MODE_INACTIVE
	SEND_SIGNAL(source, COMSIG_LIVING_COMBAT_ENABLED, forced)
	if(!silent)
		var/self_message = forced? "<span class='warning'>Your muscles reflexively tighten!</span>" : "<span class='warning'>You drop into a combative stance!</span>"
		if(visible && (forced || world.time >= combatmessagecooldown))
			combatmessagecooldown = world.time + 10 SECONDS
			var/list/ignore_mobs = list()
			//Only INTJ boys can notice someone going combat
			for(var/mob/living/carbon/human/H in view(src))
				if(H != source)
					if(H.mind?.diceroll(STAT_DATUM(int)) <= DICE_SUCCESS)
						ignore_mobs |= H
			if(!forced)
				if(source.a_intent != INTENT_HELP)
					source.visible_message("<span class='warning'><b>[source]</b> [source.resting ? "tenses up" : "drops into a combative stance"].</span>", self_message, ignored_mobs = ignore_mobs)
				else
					source.visible_message("<span class='notice'><b>[source]</b> [pick("looks","seems","goes")] [pick("alert","attentive","vigilant")].</span>", ignored_mobs = ignore_mobs)
			else
				source.visible_message("<span class='warning'><b>[source]</b> drops into a combative stance!</span>", self_message, ignored_mobs = ignore_mobs)
		else
			to_chat(source, self_message)
		if(playsound)
			source.playsound_local(source, 'sound/misc/ui_toggle.ogg', 50, FALSE, pressure_affected = FALSE) //Sound from interbay!
		source.stop_sound_channel(CHANNEL_COMBAT)
		if(source.mind?.combat_music)
			var/sound/music = sound(get_sfx(source.mind.combat_music), TRUE)
			source.playsound_local(turf_source = source, S = music, vol = 75, vary = 0, channel = CHANNEL_COMBAT, pressure_affected = FALSE)
	if(hud_icon)
		hud_icon.combat_on = TRUE
		hud_icon.update_icon()

/// Disables combat mode. Please use 'safe_disable_combat_mode' instead, if you wish to also disable the toggle flag.
/datum/component/combat_mode/proc/disable_combat_mode(mob/living/source, silent = TRUE, forced = TRUE, visible = FALSE, locked = FALSE, playsound = FALSE)
	if(locked)
		if(hud_icon)
			hud_icon.combat_on = FALSE
			hud_icon.update_icon()
		return
	if(!CHECK_BITFIELD(mode_flags, COMBAT_MODE_ACTIVE))
		return
	mode_flags &= ~COMBAT_MODE_ACTIVE
	mode_flags |= COMBAT_MODE_INACTIVE
	SEND_SIGNAL(source, COMSIG_LIVING_COMBAT_DISABLED, forced)
	if(!silent)
		var/self_message = forced? "<span class='warning'>Your muscles are forcibly relaxed!</span>" : "<span class='warning'>You relax your stance.</span>"
		if(visible)
			source.visible_message("<span class='warning'>[source] relaxes [source.p_their()] stance.</span>", self_message)
		else
			to_chat(source, self_message)
		if(playsound)
			source.playsound_local(source, 'sound/misc/ui_toggleoff.ogg', 50, FALSE, pressure_affected = FALSE) //Slightly modified version of the toggleon sound!
		source.stop_sound_channel(CHANNEL_COMBAT)
	if(hud_icon)
		hud_icon.combat_on = FALSE
		hud_icon.update_icon()
	source.stop_active_blocking()
	source.end_parry_sequence()

/// Toggles whether the user is intentionally in combat mode. THIS should be the proc you generally use! Has built in visual/to other player feedback, as well as an audible cue to ourselves.
/datum/component/combat_mode/proc/user_toggle_intentional_combat_mode(mob/living/source)
	if(CHECK_BITFIELD(mode_flags, COMBAT_MODE_TOGGLED))
		safe_disable_combat_mode(source)
	else if(source.stat == CONSCIOUS && !CHECK_BITFIELD(source.combat_flags, COMBAT_FLAG_HARD_STAMCRIT))
		safe_enable_combat_mode(source)

/// Enables intentionally being in combat mode. Please try to use the COMSIG_COMBAT_MODE_CHECK signal for feedback when possible.
/datum/component/combat_mode/proc/safe_enable_combat_mode(mob/living/source, silent = FALSE, visible = TRUE)
	if(CHECK_BITFIELD(mode_flags, COMBAT_MODE_TOGGLED) && CHECK_BITFIELD(mode_flags, COMBAT_MODE_ACTIVE))
		return TRUE
	mode_flags |= COMBAT_MODE_TOGGLED
	enable_combat_mode(source, silent, FALSE, visible, HAS_TRAIT(source, TRAIT_COMBAT_MODE_LOCKED), TRUE)
	return TRUE

/// Disables intentionally being in combat mode. Please try to use the COMSIG_COMBAT_MODE_CHECK signal for feedback when possible.
/datum/component/combat_mode/proc/safe_disable_combat_mode(mob/living/source, silent = FALSE, visible = FALSE)
	if(CHECK_BITFIELD(mode_flags, COMBAT_MODE_TOGGLED) && !CHECK_BITFIELD(mode_flags, COMBAT_MODE_ACTIVE))
		return TRUE
	mode_flags &= ~COMBAT_MODE_TOGGLED
	disable_combat_mode(source, silent, FALSE, visible, !CHECK_BITFIELD(mode_flags, COMBAT_MODE_ACTIVE), TRUE)
	return TRUE

/// Returns a field of flags that are contained in both the second arg and our bitfield variable.
/datum/component/combat_mode/proc/check_flags(mob/living/source, flags)
	return CHECK_BITFIELD(mode_flags, flags)

/// Disables combat mode upon death.
/datum/component/combat_mode/proc/on_death(mob/living/source)
	safe_disable_combat_mode(source)

/// Disables combat mode upon logout
/datum/component/combat_mode/proc/on_logout(mob/living/source)
	safe_disable_combat_mode(source)

/// The screen button.
/obj/screen/combattoggle
	name = "combat mode"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "combat"
	var/combat_on = FALSE ///Wheter combat mode is enabled or not, so we don't have to store a reference.

/obj/screen/combattoggle/Click()
	if(hud && usr == hud.mymob)
		SEND_SIGNAL(hud.mymob, COMSIG_TOGGLE_COMBAT_MODE)

/obj/screen/combattoggle/update_icon_state()
	var/mob/living/user = hud?.mymob
	if(!user)
		return
	if(combat_on)
		icon_state = "combat_on"
		if(is_dreamer(hud?.mymob))
			icon_state = "combat_rage"
	else if(HAS_TRAIT(user, TRAIT_COMBAT_MODE_LOCKED))
		icon_state = "combat_locked"
	else
		icon_state = "combat"

/obj/screen/combattoggle/update_overlays()
	. = ..()
	var/mob/living/carbon/user = hud?.mymob
	if(!(user?.client))
		return

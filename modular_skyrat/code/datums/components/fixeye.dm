//Separates fixeye into it's own thing instead of tacking it on combat mode
/datum/component/fixeye
	var/obj/screen/fixeye/hud_icon
	var/fixeye_flags
	var/hud_loc
	var/facedir

//Does stuff.
/datum/component/fixeye/Initialize(_hud_loc = ui_fixeye)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/L = parent
	hud_loc = _hud_loc
	RegisterSignal(L, COMSIG_TOGGLE_FIXEYE, .proc/user_toggle_fixeye)
	RegisterSignal(L, COMSIG_DISABLE_FIXEYE, .proc/safe_disable_fixeye)
	RegisterSignal(L, COMSIG_ENABLE_FIXEYE, .proc/safe_enable_fixeye)
	RegisterSignal(L, COMSIG_MOB_DEATH, .proc/on_death)
	RegisterSignal(L, COMSIG_MOB_CLIENT_LOGOUT, .proc/on_logout)
	RegisterSignal(L, COMSIG_MOB_HUD_CREATED, .proc/on_mob_hud_created)
	RegisterSignal(L, COMSIG_FIXEYE_CHECK, .proc/check_flags)
	if(L.client)
		on_mob_hud_created(L)

///Creates the hud screen object.
/datum/component/fixeye/proc/on_mob_hud_created(mob/source)
	hud_icon = new
	hud_icon.hud = source.hud_used
	hud_icon.icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	hud_icon.screen_loc = hud_loc
	source.hud_used.fixeye = hud_icon
	source.hud_used.static_inventory += hud_icon
	hud_icon.update_icon()
	source.client?.screen |= hud_icon

//Toggles intentionally between on and off
/datum/component/fixeye/proc/user_toggle_fixeye(mob/living/source)
	if(CHECK_BITFIELD(fixeye_flags, FIXEYE_TOGGLED))
		safe_disable_fixeye(source)
	else if(source.stat == CONSCIOUS && !(source.combat_flags & COMBAT_FLAG_HARD_STAMCRIT))
		safe_enable_fixeye(source)

//Intentionally toggling on
/datum/component/fixeye/proc/safe_enable_fixeye(mob/living/source, silent = FALSE, forced = FALSE)
	if((fixeye_flags & FIXEYE_TOGGLED) && (fixeye_flags & FIXEYE_ACTIVE))
		return TRUE
	fixeye_flags |= FIXEYE_TOGGLED
	enable_fixeye(source, silent)
	return TRUE

//Handles toggling on itself
/datum/component/fixeye/proc/enable_fixeye(mob/living/source, silent = TRUE, forced = TRUE)
	if(fixeye_flags & FIXEYE_ACTIVE)
		return
	fixeye_flags |= FIXEYE_ACTIVE
	fixeye_flags &= ~FIXEYE_INACTIVE
	SEND_SIGNAL(source, COMSIG_LIVING_FIXEYE_ENABLED, forced)
	if(!silent)
		source.playsound_local(source, 'sound/misc/ui_toggle.ogg', 50, FALSE, pressure_affected = FALSE)
	facedir = source.dir
	RegisterSignal(source, COMSIG_MOVABLE_MOVED, .proc/on_move)
	RegisterSignal(source, COMSIG_MOVABLE_BUMP, .proc/on_bump)
	RegisterSignal(source, COMSIG_MOB_CLIENT_MOVE, .proc/on_client_move)
	if(hud_icon)
		hud_icon.fixed_eye = TRUE
		hud_icon.update_icon()

//Intentionally toggling off
/datum/component/fixeye/proc/safe_disable_fixeye(mob/living/source, silent = FALSE, forced = FALSE)
	if(!CHECK_BITFIELD(fixeye_flags, FIXEYE_TOGGLED) && !CHECK_BITFIELD(fixeye_flags, FIXEYE_ACTIVE))
		return TRUE
	fixeye_flags &= ~FIXEYE_TOGGLED
	disable_fixeye(source, silent, FALSE)
	return TRUE

//Handles toggling off itself
/datum/component/fixeye/proc/disable_fixeye(mob/living/source, silent = TRUE, forced = TRUE)
	if(!CHECK_BITFIELD(fixeye_flags, FIXEYE_ACTIVE))
		return
	fixeye_flags &= ~FIXEYE_ACTIVE
	fixeye_flags |= FIXEYE_INACTIVE
	facedir = null
	SEND_SIGNAL(source, COMSIG_LIVING_FIXEYE_DISABLED, forced)
	if(!silent)
		source.playsound_local(source, 'sound/misc/ui_toggleoff.ogg', 50, FALSE, pressure_affected = FALSE)
	UnregisterSignal(source, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_BUMP, COMSIG_MOB_CLIENT_MOVE))
	if(hud_icon)
		hud_icon.fixed_eye = FALSE
		hud_icon.update_icon()

//Returns a field of flags that are contained in both the second arg and our bitfield variable.
/datum/component/fixeye/proc/check_flags(mob/living/source, flags)
	return CHECK_BITFIELD(fixeye_flags, flags)

//Disables fixeye upon death.
/datum/component/fixeye/proc/on_death(mob/living/source)
	safe_disable_fixeye(source)

//Disables fixeye upon logout
/datum/component/fixeye/proc/on_logout(mob/living/source)
	safe_disable_fixeye(source)

//Added movement delay if moving backward.
/datum/component/fixeye/proc/on_client_move(mob/source, client/client, direction, n, oldloc, added_delay)
	if(oldloc != n && direction == REVERSE_DIR(source.dir))
		client.move_delay += added_delay*0.5

//Keep that fucking face right onwards
/datum/component/fixeye/proc/on_move(atom/movable/source, dir, atom/oldloc, forced)
	var/mob/living/L = source
	if(CHECK_BITFIELD(fixeye_flags, FIXEYE_ACTIVE) && L.client && facedir && L.dir != facedir) 
		L.setDir(facedir)

/datum/component/fixeye/proc/on_bump(mob/living/source, bumped)
	on_move(source)

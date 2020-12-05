/obj/item/bodypart/left_eye/robotic
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "Your vision is augmented."
	status = BODYPART_ROBOTIC | BODYPART_SYNTHETIC

/obj/item/bodypart/left_eye/robotic/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	to_chat(owner, "<span class='warning'>Static obfuscates your vision!</span>")
	owner.flash_act(visual = 1)
	if(severity == EMP_HEAVY)
		receive_damage(brute=20)

/obj/item/bodypart/left_eye/robotic/xray
	name = "\improper X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	eye_color = "000"
	see_in_dark = 8
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/bodypart/left_eye/robotic/thermals
	name = "thermal eyes"
	desc = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included."
	eye_color = "FC0"
	sight_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = -1
	see_in_dark = 8

/obj/item/bodypart/left_eye/robotic/flashlight
	name = "flashlight eyes"
	desc = "It's two flashlights rigged together with some wire. Why would you put these in someone's head?"
	eye_color ="fee5a3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = 2
	tint = INFINITY
	var/obj/item/flashlight/eyelight/eye

/obj/item/bodypart/left_eye/robotic/flashlight/emp_act(severity)
	return

/obj/item/bodypart/left_eye/robotic/flashlight/attach_limb(mob/living/carbon/C, special, ignore_parent_restriction)
	. = ..()
	if(!eye)
		eye = new /obj/item/flashlight/eyelight()
	eye.on = TRUE
	eye.forceMove(C)
	eye.update_brightness(C)
	C.become_blind("flashlight_eyes")

/obj/item/bodypart/left_eye/robotic/flashlight/drop_limb(special, ignore_children, dismembered, destroyed, wounding_type)
	. = ..()
	if(. && !QDELETED(owner))
		eye.on = FALSE
		eye.update_brightness(owner)
		eye.forceMove(src)
		owner.cure_blind("flashlight_eyes")

// Welding shield implant
/obj/item/bodypart/left_eye/robotic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	flash_protect = 2

/obj/item/bodypart/left_eye/robotic/shield/emp_act(severity)
	return

#define RGB2EYECOLORSTRING(definitionvar) ("[copytext_char(definitionvar, 2, 3)][copytext_char(definitionvar, 4, 5)][copytext_char(definitionvar, 6, 7)]")

/obj/item/bodypart/left_eye/robotic/glow
	name = "High Luminosity Eyes"
	desc = "Special glowing eyes, used by snowflakes who want to be special."
	eye_color = "000"
	actions_types = list(/datum/action/item_action/organ_action/use, /datum/action/item_action/organ_action/toggle)
	var/current_color_string = "#ffffff"
	var/active = FALSE
	var/max_light_beam_distance = 5
	var/light_beam_distance = 5
	var/light_object_range = 1
	var/light_object_power = 2
	var/list/obj/effect/abstract/eye_lighting/eye_lighting
	var/obj/effect/abstract/eye_lighting/on_mob
	var/image/mob_overlay

/obj/item/bodypart/left_eye/robotic/glow/Initialize()
	. = ..()
	mob_overlay = image('icons/mob/human_face.dmi', "eyes_glow_gs")

/obj/item/bodypart/left_eye/robotic/glow/Destroy()
	terminate_effects()
	. = ..()

/obj/item/bodypart/left_eye/robotic/glow/drop_limb(special, ignore_children, dismembered, destroyed, wounding_type)
	terminate_effects()
	. = ..()

/obj/item/bodypart/left_eye/robotic/glow/proc/terminate_effects()
	if(owner && active)
		deactivate(TRUE)
	active = FALSE
	clear_visuals(TRUE)

/obj/item/bodypart/left_eye/robotic/glow/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()
	else if(istype(action, /datum/action/item_action/organ_action/use))
		prompt_for_controls(owner)

/obj/item/bodypart/left_eye/robotic/glow/proc/toggle_active()
	if(active)
		deactivate()
	else
		activate()

/obj/item/bodypart/left_eye/robotic/glow/proc/prompt_for_controls(mob/user)
	var/C = input(owner, "Select Color", "Select color", "#ffffff") as color|null
	if(!C || QDELETED(src) || QDELETED(user) || QDELETED(owner) || owner != user)
		return
	var/range = input(user, "Enter range (0 - [max_light_beam_distance])", "Range Select", 0) as null|num
	if(!isnum(range))
		return

	set_distance(clamp(range, 0, max_light_beam_distance))
	assume_rgb(C)

/obj/item/bodypart/left_eye/robotic/glow/proc/assume_rgb(newcolor)
	current_color_string = newcolor
	eye_color = RGB2EYECOLORSTRING(current_color_string)
	sync_light_effects()
	cycle_mob_overlay()
	if(!QDELETED(owner) && ishuman(owner))		//Other carbon mobs don't have eye color.
		owner.dna.species.handle_body(owner)

/obj/item/bodypart/left_eye/robotic/glow/proc/cycle_mob_overlay()
	remove_mob_overlay()
	mob_overlay.color = current_color_string
	add_mob_overlay()

/obj/item/bodypart/left_eye/robotic/glow/proc/add_mob_overlay()
	if(!QDELETED(owner))
		owner.add_overlay(mob_overlay)

/obj/item/bodypart/left_eye/robotic/glow/proc/remove_mob_overlay()
	if(!QDELETED(owner))
		owner.cut_overlay(mob_overlay)

/obj/item/bodypart/left_eye/robotic/glow/emp_act()
	. = ..()
	if(!active || . & EMP_PROTECT_SELF)
		return
	deactivate(silent = TRUE)

/obj/item/bodypart/left_eye/robotic/glow/proc/activate(silent = FALSE)
	start_visuals()
	if(!silent)
		to_chat(owner, "<span class='warning'>Your [src] clicks and makes a whining noise, before shooting out a beam of light!</span>")
	active = TRUE
	RegisterSignal(owner, COMSIG_ATOM_DIR_CHANGE, .proc/update_visuals)
	cycle_mob_overlay()

/obj/item/bodypart/left_eye/robotic/glow/proc/deactivate(silent = FALSE)
	clear_visuals()
	if(!silent)
		to_chat(owner, "<span class='warning'>Your [src] shuts off!</span>")
	active = FALSE
	UnregisterSignal(owner, COMSIG_ATOM_DIR_CHANGE)
	remove_mob_overlay()

/obj/item/bodypart/left_eye/robotic/glow/proc/update_visuals(datum/source, olddir, newdir)
	if((LAZYLEN(eye_lighting) < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	var/turf/scanfrom = get_turf(owner)
	var/scandir = owner.dir
	if (newdir && scandir != newdir) // COMSIG_ATOM_DIR_CHANGE happens before the dir change, but with a reference to the new direction.
		scandir = newdir
	if(!istype(scanfrom))
		clear_visuals()
	var/turf/scanning = scanfrom
	var/stop = FALSE
	on_mob.forceMove(scanning)
	for(var/i in 1 to light_beam_distance)
		scanning = get_step(scanning, scandir)
		if(!scanning)
			break
		if(scanning.opacity || scanning.has_opaque_atom)
			stop = TRUE
		var/obj/effect/abstract/eye_lighting/L = LAZYACCESS(eye_lighting, i)
		if(stop)
			L.forceMove(src)
		else
			L.forceMove(scanning)

/obj/item/bodypart/left_eye/robotic/glow/proc/clear_visuals(delete_everything = FALSE)
	if(delete_everything)
		QDEL_LIST(eye_lighting)
		QDEL_NULL(on_mob)
	else
		for(var/i in eye_lighting)
			var/obj/effect/abstract/eye_lighting/L = i
			L.forceMove(src)
		if(!QDELETED(on_mob))
			on_mob.forceMove(src)

/obj/item/bodypart/left_eye/robotic/glow/proc/start_visuals()
	if(!islist(eye_lighting))
		regenerate_light_effects()
	if((LAZYLEN(eye_lighting) < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	sync_light_effects()
	update_visuals()

/obj/item/bodypart/left_eye/robotic/glow/proc/set_distance(dist)
	light_beam_distance = dist
	regenerate_light_effects()

/obj/item/bodypart/left_eye/robotic/glow/proc/regenerate_light_effects()
	clear_visuals(TRUE)
	on_mob = new(src)
	for(var/i in 1 to light_beam_distance)
		LAZYADD(eye_lighting,new /obj/effect/abstract/eye_lighting(src))
	sync_light_effects()

/obj/item/bodypart/left_eye/robotic/glow/proc/sync_light_effects()
	for(var/I in eye_lighting)
		var/obj/effect/abstract/eye_lighting/L = I
		L.set_light(light_object_range, light_object_power, current_color_string)
	if(on_mob)
		on_mob.set_light(1, 1, current_color_string)

/obj/effect/abstract/eye_lighting
	var/obj/item/bodypart/parent

/obj/effect/abstract/eye_lighting/Initialize()
	. = ..()
	parent = loc
	if(!istype(parent))
		return INITIALIZE_HINT_QDEL

/obj/item/bodypart/left_eye/robotic/glow/attach_limb(mob/living/carbon/C, special, ignore_parent_restriction)
	. = ..()
	if(.)
		RegisterSignal(C, COMSIG_MOB_DEATH, .proc/deactivate)
		RegisterSignal(C, COMSIG_LIVING_GAIN_UNCONSCIOUS, .proc/deactivate)
		RegisterSignal(C, COMSIG_LIVING_STOP_UNCONSCIOUS, .proc/active_block)

/obj/item/bodypart/left_eye/robotic/glow/drop_limb(special, ignore_children, dismembered, destroyed, wounding_type)
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_DEATH)
	UnregisterSignal(owner, COMSIG_LIVING_GAIN_UNCONSCIOUS)
	UnregisterSignal(owner, COMSIG_LIVING_STOP_UNCONSCIOUS)

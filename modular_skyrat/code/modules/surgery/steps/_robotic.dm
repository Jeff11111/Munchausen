//open shell
/datum/surgery_step/mechanic_incise
	name = "Unscrew shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		TOOL_SCALPEL 		= 75, // med borgs could try to unscrew shell with scalpel
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	base_time = 24
	surgery_flags = 0 //fucking FAGS
	requires_bodypart_type = BODYPART_ROBOTIC

/datum/surgery_step/mechanic_incise/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	if(BP.get_incision(TRUE))
		return FALSE

/datum/surgery_step/mechanic_incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to unscrew the shell of [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)].",
			"[user] begins to unscrew the shell of [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_incise/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	. = ..()
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	if(istype(tool, /obj/item/reagent_containers))
		return FALSE

/datum/surgery_step/mechanic_incise/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!(NOBLOOD in H.dna.species.species_traits))
			display_results(user, target, "<span class='notice'>Hydraulic fluid pools around the incision in [H]'s [parse_zone(target_zone)].</span>",
				"Hydraulic fluid pools around the incision in [H]'s [parse_zone(target_zone)].")
			var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
			if(istype(BP))
				var/datum/injury/ouchie = BP.create_injury(WOUND_SLASH, BP.max_damage * 0.4, TRUE)
				ouchie.apply_injury(BP.max_damage * 0.4, BP)
				ouchie.injury_flags |= INJURY_SURGICAL
				target.wound_message = ""
				if(BP.current_gauze)
					BP.remove_gauze()

//prepare electronics
//(mechanical equivalente of clamp bleeders)
/datum/surgery_step/mechanic_clamp_bleeders
	name = "Prepare electronics"
	implements = list(
		TOOL_MULTITOOL = 100,
		TOOL_HEMOSTAT = 10) // try to reboot internal controllers via short circuit with some conductor
	base_time = 24
	requires_bodypart_type = BODYPART_ROBOTIC

/datum/surgery_step/mechanic_clamp_bleeders/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/limb = C.get_bodypart(user.zone_selected)
	if(limb.is_clamped())
		return FALSE

/datum/surgery_step/mechanic_clamp_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to prepare electronics in [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)].",
			"[user] begins to prepare electronics in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_clamp_bleeders/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/BP = C.get_bodypart(target_zone)
		if(BP)
			BP.clamp_limb()

//unwrench
//(mechanical equivalent of retract skin)
/datum/surgery_step/mechanic_retract_skin
	name = "Unwrench bolts"
	implements = list(
		TOOL_WRENCH = 100,
		TOOL_RETRACTOR = 10)
	base_time = 24
	requires_bodypart_type = BODYPART_ROBOTIC

/datum/surgery_step/mechanic_retract_skin/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	var/datum/injury/incision = BP.get_incision()
	if(CHECK_BITFIELD(incision?.injury_flags, INJURY_RETRACTED_SKIN))
		return FALSE

/datum/surgery_step/mechanic_retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to unwrench some bolts in [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].",
			"[user] begins to unwrench some bolts in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_retract_skin/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	. = ..()
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(BP)
		BP.open_incision(user)

//pry off plating
//(mechanical equivalent of sawing through bone)
/datum/surgery_step/mechanic_saw
	name = "Pry off plating"
	implements = list(
		TOOL_CROWBAR = 100,
		TOOL_HEMOSTAT = 10)
	base_time = 24
	requires_bodypart_type = BODYPART_ROBOTIC

/datum/surgery_step/mechanic_saw/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	if(BP.is_broken())
		return FALSE

/datum/surgery_step/mechanic_saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to pry off [target]'s [parse_zone(target_zone)] plating...</span>",
			"[user] begins to pry off [target]'s [parse_zone(target_zone)] plating.",
			"[user] begins to pry off [target]'s [parse_zone(target_zone)] plating.")

/datum/surgery_step/mechanic_saw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You pry [target]'s [parse_zone(target_zone)] open.</span>",
		"[user] pry [target]'s [parse_zone(target_zone)] open!",
		"[user] pry [target]'s [parse_zone(target_zone)] open!")
	//oh GOD oh fuck we need to break this nigga's limb to continue surgery
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(target_zone)
	if(!BP.is_broken())
		var/datum/wound/mechanical/blunt/severe/metal_nigger_bones = new()
		metal_nigger_bones.apply_wound(BP, TRUE)
		C.wound_message = ""
	return TRUE

//close shell
//(mechanical equivalent of mend incision)
/datum/surgery_step/mechanic_close
	name = "Screw shell"
	implements = list(
		TOOL_SCREWDRIVER		= 100,
		TOOL_SCALPEL 		= 75,
		/obj/item/kitchen/knife	= 50,
		/obj/item				= 10) // 10% success with any sharp item.
	base_time = 24
	requires_bodypart_type = BODYPART_ROBOTIC

/datum/surgery_step/mechanic_close/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	for(var/datum/injury/IN in BP.injuries)
		if(IN.is_bleeding() || IN.damage_type == WOUND_SLASH || IN.damage_type == WOUND_PIERCE)
			return TRUE
	return FALSE

/datum/surgery_step/mechanic_close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to screw the shell of [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to screw the shell of [target]'s [parse_zone(target_zone)].",
			"[user] begins to screw the shell of [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_close/success(mob/user, mob/living/target, target_zone, obj/item/tool)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/BP = C.get_bodypart(target_zone)
		if(istype(BP))
			for(var/datum/injury/inch in BP.injuries)
				if(inch.is_surgical())
					inch.close_injury()
				else
					inch.clamp_injury()
		if(BP.is_clamped())
			BP.unclamp_limb()

/datum/surgery_step/mechanic_close/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	return TRUE

//Generic steps used in a lot of surgeries

//make incision
/datum/surgery_step/incise
	name = "Make incision"
	implements = list(TOOL_SCALPEL = 100, /obj/item/melee/transforming/energy/sword = 75, /obj/item/kitchen/knife = 65,
		/obj/item/shard = 45, /obj/item = 30) // 30% success with any sharp item.
	base_time = 16
	surgery_flags = 0 //fucking FAGS

/datum/surgery_step/incise/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	if(BP.get_incision(TRUE))
		return FALSE

/datum/surgery_step/incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to make an incision in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to make an incision in [target]'s [parse_zone(target_zone)].",
		"[user] begins to make an incision in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/incise/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	. = ..()
	if(implement_type == /obj/item && !tool.get_sharpness())
		return FALSE
	if(istype(tool, /obj/item/reagent_containers))
		return FALSE

/datum/surgery_step/incise/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(!(NOBLOOD in H.dna.species.species_traits))
			display_results(user, target, "<span class='notice'>Blood pools around the incision in [H]'s [parse_zone(target_zone)].</span>",
				"Blood pools around the incision in [H]'s [parse_zone(target_zone)].")
			var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
			if(istype(BP))
				var/datum/injury/ouchie = BP.create_injury(WOUND_SLASH, BP.max_damage * 0.4, TRUE)
				ouchie.apply_injury(BP.max_damage * 0.4, BP)
				ouchie.injury_flags |= INJURY_SURGICAL
				target.wound_message = ""
				playsound(target, 'modular_skyrat/sound/gore/flesh.ogg', 75, 0)

//clamp bleeders
//Not a hard requirement, just needed if you don't want your patient to bleed out
/datum/surgery_step/clamp_bleeders
	name = "Clamp bleeders"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_WIRECUTTER = 60, /obj/item/stack/packageWrap = 35, /obj/item/stack/cable_coil = 15)
	base_time = 24

/datum/surgery_step/clamp_bleeders/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/limb = C.get_bodypart(user.zone_selected)
	if(limb.is_clamped())
		return FALSE

/datum/surgery_step/clamp_bleeders/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to clamp bleeders in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to clamp bleeders in [target]'s [parse_zone(target_zone)].",
		"[user] begins to clamp bleeders in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/clamp_bleeders/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/BP = C.get_bodypart(target_zone)
		if(BP)
			BP.clamp_limb()

//retract skin
/datum/surgery_step/retract_skin
	name = "Retract skin"
	implements = list(TOOL_RETRACTOR = 100, TOOL_SCREWDRIVER = 45, TOOL_WIRECUTTER = 35)
	base_time = 24

/datum/surgery_step/retract_skin/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	var/datum/injury/incision = BP.get_incision()
	if(CHECK_BITFIELD(incision?.injury_flags, INJURY_RETRACTED_SKIN))
		return FALSE

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to retract the skin in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].",
		"[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/retract_skin/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	. = ..()
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(BP)
		BP.open_incision()
		if(!length(tool.embedding))
			tool.embedding = EMBED_NONE
		tool.tryEmbed(BP, TRUE, TRUE)
		RegisterSignal(tool, COMSIG_ITEM_ON_EMBED_REMOVAL, .proc/unspeculumize, TRUE)
		playsound(target, 'modular_skyrat/sound/gore/stuck2.ogg', 60, 0)
		target.update_body()

/datum/surgery_step/retract_skin/proc/unspeculumize(mob/source, obj/item/bodypart/limb)
	var/datum/injury/incision = limb?.get_incision()
	if(incision)
		incision.injury_flags &= ~INJURY_RETRACTED_SKIN
	if(istype(source))
		playsound(source, 'modular_skyrat/sound/gore/stuck1.ogg', 60, 0)
		source.update_body()

//saw bone
/datum/surgery_step/saw
	name = "Saw bone"
	implements = list(TOOL_SAW = 100, /obj/item/melee/arm_blade = 75, /obj/item/fireaxe = 50, /obj/item/hatchet = 35, /obj/item/kitchen/knife/butcher = 25)
	base_time = 54
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_RETRACTED)

/datum/surgery_step/saw/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	if(BP.is_broken())
		return FALSE

/datum/surgery_step/saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to saw through the bone in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to saw through the bone in [target]'s [parse_zone(target_zone)].",
		"[user] begins to saw through the bone in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/saw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You saw [target]'s [parse_zone(target_zone)] open.</span>",
		"[user] saws [target]'s [parse_zone(target_zone)] open!",
		"[user] saws [target]'s [parse_zone(target_zone)] open!")
	//oh GOD oh fuck we need to break this nigga's limb to continue surgery
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(target_zone)
	if(!BP.is_broken())
		var/datum/wound/blunt/severe/nigger_bones = new()
		nigger_bones.apply_wound(BP, TRUE)
		C.wound_message = ""
	return TRUE

//drill bone
/datum/surgery_step/drill
	name = "Drill bone"
	implements = list(TOOL_DRILL = 100, /obj/item/screwdriver/power = 80, /obj/item/pickaxe/drill = 60, TOOL_SCREWDRIVER = 20)
	base_time = 30
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_RETRACTED)

/datum/surgery_step/drill/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	if(CHECK_BITFIELD(BP?.how_open(), SURGERY_DRILLED))
		return FALSE

/datum/surgery_step/drill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to drill into the bone in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].",
		"[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/drill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You drill into [target]'s [parse_zone(target_zone)].</span>",
		"[user] drills into [target]'s [parse_zone(target_zone)]!",
		"[user] drills into [target]'s [parse_zone(target_zone)]!")
	var/obj/item/bodypart/BP = target.get_bodypart(user.zone_selected)
	var/datum/injury/incision = BP.get_incision()
	incision?.injury_flags |= INJURY_DRILLED
	return TRUE

//Cauterize incision
/datum/surgery_step/close
	name = "Cauterize"
	implements = list(TOOL_CAUTERY = 100, /obj/item/gun/energy/laser = 80, /obj/item = 70) // 70% success with any hot item.
	base_time = 24

/datum/surgery_step/close/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	for(var/datum/injury/IN in BP.injuries)
		if(IN.is_bleeding() || IN.damage_type == WOUND_SLASH || IN.damage_type == WOUND_PIERCE)
			return TRUE
	return FALSE

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin cauterizing the wounds in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to cauterize the wounds in [target]'s [parse_zone(target_zone)].",
		"[user] begins to cauterize the wounds in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/close/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	if(implement_type == TOOL_WELDER || implement_type == /obj/item)
		return tool.get_temperature()
	return TRUE

/datum/surgery_step/close/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
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

//disinfect injuries
/datum/surgery_step/disinfect_injuries
	name = "Disinfect injuries"
	implements = list(/obj/item/reagent_containers = 100)
	base_time = 40
	surgery_flags = 0

/datum/surgery_step/disinfect_injuries/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	. = ..()
	if(.)
		var/obj/item/reagent_containers/RC = tool
		if(!istype(RC) || !RC.is_drainable())
			return FALSE
		if(!RC.reagents?.has_reagent(/datum/reagent/space_cleaner/sterilizine, 10) && !RC.reagents.has_reagent(/datum/reagent/consumable/ethanol, 30))
			return FALSE
		if(RC.reagents.has_reagent(/datum/reagent/consumable/ethanol, 30))
			var/datum/reagent/consumable/ethanol/ethanol = RC.reagents.get_reagent(/datum/reagent/consumable/ethanol)
			if(ethanol.boozepwr < 40)
				return FALSE

/datum/surgery_step/disinfect_injuries/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	if(BP.is_disinfected())
		return FALSE

/datum/surgery_step/disinfect_injuries/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to disinfect the injuries on [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to sterilize the injuries on [target]'s [parse_zone(target_zone)].",
		"[user] begins to sterilize the injuries on [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/disinfect_injuries/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You sterilize the injuries on [target]'s [parse_zone(target_zone)].</span>",
		"[user] sterilizes the injuries on [target]'s [parse_zone(target_zone)]!",
		"[user] sterilizes the injuries on [target]'s [parse_zone(target_zone)]!")
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	BP?.disinfect_limb()
	return TRUE

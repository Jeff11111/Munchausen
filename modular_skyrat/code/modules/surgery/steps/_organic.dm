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
	if(locate(/datum/wound/slash/critical/incision) in BP.wounds)
		to_chat(user, "<span class='notice'>\The [BP] has already been incised open.</span>")
		return FALSE

/datum/surgery_step/incise/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to make an incision in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to make an incision in [target]'s [parse_zone(target_zone)].",
		"[user] begins to make an incision in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/incise/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	. = ..()
	if(istype(tool, /obj/item/pen) && user.a_intent == INTENT_HELP && target)
		var/obj/item/bodypart/BP = target.get_bodypart(user.zone_selected)
		if(istype(BP))
			BP.attackby(tool, user)
		return FALSE
	if(implement_type == /obj/item && !tool.get_sharpness())
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
				var/datum/wound/slash/critical/incision/inch = new()
				inch.apply_wound(BP, TRUE)
				if(inch)
					inch.blood_flow += 3
				target.wound_message = ""

//clamp bleeders
//Not a hard requirement, just needed if you don't want your patient to bleed out
/datum/surgery_step/clamp_bleeders
	name = "Clamp bleeders"
	implements = list(TOOL_HEMOSTAT = 100, TOOL_WIRECUTTER = 60, /obj/item/stack/packageWrap = 35, /obj/item/stack/cable_coil = 15)
	base_time = 24

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
			var/datum/wound/slash/critical/incision = locate() in BP.wounds
			if(incision)
				incision.blood_flow = 0.1

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
	var/datum/wound/slash/critical/incision/incision = locate() in BP.wounds
	if(CHECK_BITFIELD(incision?.wound_flags, WOUND_RETRACTED_SKIN))
		to_chat(user, "<span class='notice'>\The [BP] has already been retracted.</span>")
		return FALSE

/datum/surgery_step/retract_skin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to retract the skin in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].",
		"[user] begins to retract the skin in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/retract_skin/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		var/obj/item/bodypart/BP = C.get_bodypart(target_zone)
		if(BP)
			var/datum/wound/slash/critical/incision = locate() in BP.wounds
			if(incision)
				incision.wound_flags |= WOUND_RETRACTED_SKIN

//saw bone
/datum/surgery_step/saw
	name = "Saw bone"
	implements = list(TOOL_SAW = 100, /obj/item/melee/arm_blade = 75, /obj/item/fireaxe = 50, /obj/item/hatchet = 35, /obj/item/kitchen/knife/butcher = 25)
	base_time = 54
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_RETRACTED | STEP_NEEDS_ENCASED)

/datum/surgery_step/saw/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //nah nigga lol
		return FALSE
	var/mob/living/carbon/C = target
	var/obj/item/bodypart/BP = C.get_bodypart(user.zone_selected)
	if(BP.is_broken())
		to_chat(user, "<span class='notice'>\The [BP] has already been broken open.</span>")
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

/datum/surgery_step/drill/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to drill into the bone in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].",
		"[user] begins to drill into the bone in [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/drill/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You drill into [target]'s [parse_zone(target_zone)].</span>",
		"[user] drills into [target]'s [parse_zone(target_zone)]!",
		"[user] drills into [target]'s [parse_zone(target_zone)]!")
	return TRUE

//close incision
/datum/surgery_step/close
	name = "Mend incision"
	implements = list(TOOL_CAUTERY = 100, /obj/item/gun/energy/laser = 90, TOOL_WELDER = 70, /obj/item = 30) // 30% success with any hot item.
	base_time = 24

/datum/surgery_step/close/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to mend the incision in [target]'s [parse_zone(target_zone)]...</span>",
		"[user] begins to mend the incision in [target]'s [parse_zone(target_zone)].",
		"[user] begins to mend the incision in [target]'s [parse_zone(target_zone)].")

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
			for(var/datum/wound/slash/critical/incision/inch in BP.wounds)
				inch.remove_wound()
			for(var/datum/wound/mechanical/slash/critical/incision/inch in BP.wounds)
				inch.remove_wound()

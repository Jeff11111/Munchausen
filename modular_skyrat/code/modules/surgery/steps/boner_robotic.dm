// Set bones
//(but robotic)
/datum/surgery_step/mechanic_set_bones
	name = "Add plating"
	implements = list(/obj/item/stack/sheet/metal = 100)
	base_time = 24
	requires_bodypart_type = BODYPART_ROBOTIC
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_BROKEN) //i hate black people
	var/metalamount = 5

/datum/surgery_step/mechanic_set_bones/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	var/obj/item/stack/sheet/plat = tool
	if(!istype(plat))
		to_chat(user, "<span class='warning'>No, that won't work!</span>")
		return FALSE
	if(plat.get_amount() < metalamount)
		to_chat(user, "<span class='warning'>Not enough metal!</span>")
		return FALSE
	return TRUE

/datum/surgery_step/mechanic_set_bones/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //no chungus
		return
	var/obj/item/bodypart/borked = target.get_bodypart(user.zone_selected)
	var/datum/wound/slash/critical/incision = locate() in borked?.wounds
	if(CHECK_BITFIELD(incision?.wound_flags, WOUND_SET_BONES))
		return FALSE
	
/datum/surgery_step/mechanic_set_bones/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to add plating to [target]'s [parse_zone(target_zone)]...</span>",
			"[user] begins to add plating to [target]'s [parse_zone(target_zone)].",
			"[user] begins to add plating to [target]'s [parse_zone(target_zone)].")

/datum/surgery_step/mechanic_set_bones/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, default_display_results = FALSE)
	display_results(user, target, "<span class='notice'>You successfully repair the fracture in [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] successfully repairs the fracture in [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		"<span class='notice'>[user] successfully repairs the fracture in [target]'s [parse_zone(target_zone)]!</span>")
	log_combat(user, target, "added plating in", addition="INTENT: [uppertext(user.a_intent)]")
	var/obj/item/bodypart/borked = target.get_bodypart(target_zone)
	var/datum/wound/mechanical/slash/critical/incision = locate() in borked?.wounds
	if(incision)
		incision.wound_flags |= WOUND_SET_BONES
	var/obj/item/stack/sheet/metal/plat = tool
	if(plat && !(plat.get_amount() < metalamount)) //failproof
		plat.use(metalamount)
	return ..()

/datum/surgery_step/mechanic_set_bones/failure(mob/user, mob/living/target, target_zone, obj/item/tool, var/fail_prob = 0)
	. = ..()
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(FLOOR(metalamount/2, 1))

// Gel le bone
//(but robotic)
/datum/surgery_step/mechanic_gel_bones
	name = "Apply nanopaste"
	implements = list(/obj/item/stack/medical/nanopaste = 100, /obj/item/stack/sticky_tape/surgical = 80, /obj/item/stack/sticky_tape = 60)
	base_time = 40
	requires_bodypart_type = BODYPART_ROBOTIC
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_BROKEN | STEP_NEEDS_SET_BONES) //i still hate black people

/datum/surgery_step/mechanic_gel_bones/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin applying [tool] on the plating in [target]'s [parse_zone(user.zone_selected)]...</span>",
		"<span class='notice'>[user] begins applying [tool] on the plating in [target]'s [parse_zone(user.zone_selected)] with [tool].</span>",
		"<span class='notice'>[user] begins applying [tool] on the plating in [target]'s [parse_zone(user.zone_selected)].</span>")

/datum/surgery_step/mechanic_gel_bones/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, default_display_results = FALSE)
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)
	display_results(user, target, "<span class='notice'>You successfully apply [tool] on the plating on [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] successfully applies [tool] on the plating on [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		"<span class='notice'>[user] successfully applies [tool] on the plating on [target]'s [parse_zone(target_zone)]!</span>")
	log_combat(user, target, "nanopasted fracture in", addition="INTENT: [uppertext(user.a_intent)]")
	var/obj/item/bodypart/nigger_fractures = target.get_bodypart(target_zone)
	for(var/datum/wound/blunt/blunt in nigger_fractures?.wounds)
		if(blunt.severity >= WOUND_SEVERITY_SEVERE)
			qdel(blunt)
	var/datum/wound/mechanical/slash/critical/incision = locate() in nigger_fractures?.wounds
	if(incision)
		incision.wound_flags &= ~WOUND_SET_BONES
	return ..()

/datum/surgery_step/mechanic_gel_bones/failure(mob/user, mob/living/target, target_zone, obj/item/tool, var/fail_prob = 0)
	. = ..()
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(2)

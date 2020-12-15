
/////BONE FIXING SURGERIES//////

///// Set bones
/datum/surgery_step/set_bones
	name = "Set bones"
	implements = list(TOOL_BONESET = 100, /obj/item/stack/sticky_tape/surgical = 80, /obj/item/stack/sticky_tape/super = 50, /obj/item/stack/sticky_tape = 30)
	base_time = 40
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_BROKEN) //i hate black people

/datum/surgery_step/set_bones/validate_target(mob/living/target, mob/user)
	. = ..()
	if(!.) //no chungus
		return
	var/obj/item/bodypart/borked = target.get_bodypart(user.zone_selected)
	var/datum/wound/slash/critical/incision = locate() in borked?.wounds
	if(CHECK_BITFIELD(incision?.wound_flags, WOUND_SET_BONES))
		to_chat(user, "<span class='notice'>\The bones in [borked] have already been set properly.</span>")
		return FALSE
	
/datum/surgery_step/set_bones/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to set the bones in [target]'s [parse_zone(user.zone_selected)]...</span>",
		"<span class='notice'>[user] begins to set the bones in [target]'s [parse_zone(user.zone_selected)] with [tool].</span>",
		"<span class='notice'>[user] begins to set the bones in [target]'s [parse_zone(user.zone_selected)].</span>")

/datum/surgery_step/set_bones/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)
	display_results(user, target, "<span class='notice'>You successfully repair the fracture in [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] successfully repairs the fracture in [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		"<span class='notice'>[user] successfully repairs the fracture in [target]'s [parse_zone(target_zone)]!</span>")
	log_combat(user, target, "set bones in", addition="INTENT: [uppertext(user.a_intent)]")
	var/obj/item/bodypart/borked = target.get_bodypart(target_zone)
	var/datum/wound/slash/critical/incision = locate() in borked?.wounds
	if(incision)
		incision.wound_flags |= WOUND_SET_BONES
	return ..()

/datum/surgery_step/set_bones/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	. = ..()
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(2)

///// Gel le bone
/datum/surgery_step/gel_bones
	name = "Gel bones"
	implements = list(/obj/item/stack/medical/bone_gel = 100, /obj/item/stack/sticky_tape/surgical = 100, /obj/item/stack/sticky_tape/super = 50, /obj/item/stack/sticky_tape = 30)
	base_time = 40
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_BROKEN | STEP_NEEDS_SET_BONES) //i still hate black people

/datum/surgery_step/gel_bones/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to repair the fracture in [target]'s [parse_zone(user.zone_selected)]...</span>",
		"<span class='notice'>[user] begins to repair the fracture in [target]'s [parse_zone(user.zone_selected)] with [tool].</span>",
		"<span class='notice'>[user] begins to repair the fracture in [target]'s [parse_zone(user.zone_selected)].</span>")

/datum/surgery_step/gel_bones/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(1)
	display_results(user, target, "<span class='notice'>You successfully repair the fracture in [target]'s [parse_zone(target_zone)].</span>",
		"<span class='notice'>[user] successfully repairs the fracture in [target]'s [parse_zone(target_zone)] with [tool]!</span>",
		"<span class='notice'>[user] successfully repairs the fracture in [target]'s [parse_zone(target_zone)]!</span>")
	log_combat(user, target, "gelled bones in", addition="INTENT: [uppertext(user.a_intent)]")
	var/obj/item/bodypart/nigger_fractures = target.get_bodypart(target_zone)
	for(var/datum/wound/blunt/blunt in nigger_fractures?.wounds)
		if(blunt.severity >= WOUND_SEVERITY_SEVERE)
			qdel(blunt)
	var/datum/wound/slash/critical/incision = locate() in nigger_fractures?.wounds
	if(incision)
		incision.wound_flags &= ~WOUND_SET_BONES
	return ..()

/datum/surgery_step/gel_bones/failure(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, var/fail_prob = 0)
	. = ..()
	if(istype(tool, /obj/item/stack))
		var/obj/item/stack/used_stack = tool
		used_stack.use(2)

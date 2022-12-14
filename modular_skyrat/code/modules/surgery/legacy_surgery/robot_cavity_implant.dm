/datum/surgery/cavity_implant/mechanical
	name = "Cavity implant"
	steps = list(/datum/surgery_step/mechanic_open,
				/datum/surgery_step/mechanic_unwrench,
				/datum/surgery_step/open_hatch,
				/datum/surgery_step/mechanic_handle_cavity,
				/datum/surgery_step/mechanic_wrench,
				/datum/surgery_step/mechanic_close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = ALL_BODYPARTS
	requires_bodypart_type = BODYPART_ROBOTIC

//handle cavity
/datum/surgery_step/mechanic_handle_cavity
	name = "Implant item"
	accept_hand = 85
	accept_any_item = 100
	implements = list(/obj/item = 100)
	repeatable = TRUE
	time = 32
	var/obj/item/IC = null

/datum/surgery_step/mechanic_handle_cavity/tool_check(mob/user, obj/item/tool, mob/living/carbon/target)
	if(istype(tool, /obj/item/cautery) || istype(tool, /obj/item/gun/energy/laser))
		return FALSE
	return !tool.get_temperature()

/datum/surgery_step/mechanic_handle_cavity/preop(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/CH = target.get_bodypart(target_zone)
	IC = CH.cavity_item
	if(tool)
		display_results(user, target, "<span class='notice'>You begin to insert [tool] into [target]'s [target_zone]...</span>",
			"[user] begins to insert [tool] into [target]'s [target_zone].",
			"[user] begins to insert [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "something"] into [target]'s [target_zone].")
	else
		display_results(user, target, "<span class='notice'>You check for items in [target]'s [target_zone]...</span>",
			"[user] checks for items in [target]'s [target_zone].",
			"[user] looks for something in [target]'s [target_zone].")

/datum/surgery_step/mechanic_handle_cavity/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/CH = target.get_bodypart(target_zone)
	if(tool)
		if(IC || tool.w_class > CH.max_cavity_size || HAS_TRAIT(tool, TRAIT_NODROP) || istype(tool, /obj/item/organ))
			to_chat(user, "<span class='warning'>You can't seem to fit [tool] in [target]'s [target_zone]!</span>")
			return 0
		else
			display_results(user, target, "<span class='notice'>You stuff [tool] into [target]'s [target_zone].</span>",
				"[user] stuffs [tool] into [target]'s [target_zone]!",
				"[user] stuffs [tool.w_class > WEIGHT_CLASS_SMALL ? tool : "something"] into [target]'s [target_zone].")
			user.transferItemToLoc(tool, target, TRUE)
			CH.cavity_item = tool
			return 1
	else
		if(IC)
			display_results(user, target, "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>",
				"[user] pulls [IC] out of [target]'s [target_zone]!",
				"[user] pulls [IC.w_class > WEIGHT_CLASS_SMALL ? IC : "something"] out of [target]'s [target_zone].")
			user.put_in_hands(IC)
			CH.cavity_item = null
			return 1
		else
			to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone].</span>")
			return 0

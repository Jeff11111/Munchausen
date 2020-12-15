//amputate limb
/datum/surgery_step/sever_limb
	name = "Sever limb"
	implements = list(TOOL_SAW = 100, /obj/item/melee/transforming/energy/sword/cyborg/saw = 100, /obj/item/melee/arm_blade = 80, /obj/item/chainsaw = 80, /obj/item/mounted_chainsaw = 80, /obj/item/fireaxe = 50, /obj/item/hatchet = 40, /obj/item/kitchen/knife/butcher = 25)
	base_time = 64
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = AMPUTATE_BODYPARTS
	surgery_flags = (STEP_NEEDS_INCISED | STEP_NEEDS_BROKEN) //i to this moment still hate black people

/datum/surgery_step/sever_limb/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	display_results(user, target, "<span class='notice'>You begin to sever [target]'s [parse_zone(target_zone)] by \the [BP.amputation_point]...</span>",
		"[user] begins to sever [target]'s [parse_zone(target_zone)]!",
		"[user] begins to sever [target]'s [parse_zone(target_zone)]!")

/datum/surgery_step/sever_limb/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	var/mob/living/carbon/human/L = target
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	display_results(user, target, "<span class='notice'>You sever [L]'s [parse_zone(target_zone)] from \the [BP.amputation_point].</span>",
		"[user] severs [L]'s [parse_zone(target_zone)]!",
		"[user] severs [L]'s [parse_zone(target_zone)]!")
	var/obj/item/bodypart/target_limb = target.get_bodypart(target_zone)
	target_limb.drop_limb()
	return TRUE

//Disembowelment
/datum/surgery_step/disembowel
	name = "Disembowel limb"
	implements = list(TOOL_RETRACTOR = 100, TOOL_HEMOSTAT = 100, TOOL_CROWBAR = 100, TOOL_SHOVEL = 100)
	base_time = 80
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = ORGAN_BODYPARTS
	surgery_flags = (STEP_NEEDS_ENCASED | STEP_NEEDS_INCISED | STEP_NEEDS_RETRACTED | STEP_NEEDS_BROKEN) //i to this moment still hate black people

/datum/surgery_step/disembowel/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='notice'>You begin to spoon out [target]'s [parse_zone(target_zone)] organs...</span>",
		"[user] begins to spoon out [target]'s [parse_zone(target_zone)] organs!",
		"[user] begins to spoon out [target]'s [parse_zone(target_zone)] organs!")

/datum/surgery_step/disembowel/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool)
	display_results(user, target, "<span class='warning'>You spoon out [target]'s [parse_zone(target_zone)] organs!</span>",
		"[user] spoons out [target]'s [parse_zone(target_zone)] organs!",
		"[user] spoons out [target]'s [parse_zone(target_zone)] organs!")
	
	var/obj/item/bodypart/BP = target.get_bodypart(target_zone)
	if(istype(BP))
		BP.disembowel()
	
	return TRUE

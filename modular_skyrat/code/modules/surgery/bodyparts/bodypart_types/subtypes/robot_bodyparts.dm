#define ROBOTIC_NO_BRUTE_MSG "not dented"
#define ROBOTIC_LIGHT_BRUTE_MSG "marred"
#define ROBOTIC_MEDIUM_BRUTE_MSG "dented"
#define ROBOTIC_HEAVY_BRUTE_MSG "falling apart"

#define ROBOTIC_NO_BURN_MSG "not burnt"
#define ROBOTIC_LIGHT_BURN_MSG "scorched"
#define ROBOTIC_MEDIUM_BURN_MSG "charred"
#define ROBOTIC_HEAVY_BURN_MSG "smoldering"

//For ye whom may venture here, split up arm / hand sprites are formatted as "l_hand" & "l_arm".
//The complete sprite (displayed when the limb is on the ground) should be named "borg_l_arm".
//Failure to follow this pattern will cause the hand's icons to be missing due to the way get_limb_icon() works to generate the mob's icons using the aux_zone var.

/obj/item/bodypart/l_arm/robot
	name = "cyborg left arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_l_arm"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE
	starting_children = list(/obj/item/bodypart/l_hand/robot)

/obj/item/bodypart/l_arm/robot/nochildren
	starting_children = null

/obj/item/bodypart/l_hand/robot
	name = "cyborg left hand"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_l_hand"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE
	starting_children = list()

/obj/item/bodypart/r_arm/robot
	name = "cyborg right arm"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_r_arm"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE
	starting_children = list(/obj/item/bodypart/r_hand/robot)

/obj/item/bodypart/r_arm/robot/nochildren
	starting_children = null

/obj/item/bodypart/r_hand/robot
	name = "cyborg right hand"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("slapped", "punched")
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_r_hand"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE
	starting_children = list()

/obj/item/bodypart/l_leg/robot
	name = "cyborg left leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_l_leg"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE
	starting_children = list(/obj/item/bodypart/l_foot/robot)

/obj/item/bodypart/l_leg/robot/nochildren
	starting_children = null

/obj/item/bodypart/l_foot/robot
	name = "cyborg left foot"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_l_foot"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE
	starting_children = list()

/obj/item/bodypart/r_leg/robot
	name = "cyborg right leg"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_r_leg"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE
	starting_children = list(/obj/item/bodypart/r_foot/robot)

/obj/item/bodypart/r_leg/robot/nochildren
	starting_children = null

/obj/item/bodypart/r_foot/robot
	name = "cyborg right foot"
	desc = "A skeletal limb wrapped in pseudomuscles, with a low-conductivity case."
	attack_verb = list("kicked", "stomped")
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_r_foot"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE
	starting_children = list()

/obj/item/bodypart/chest/robot
	name = "cyborg torso"
	desc = "A heavily reinforced case containing cyborg logic boards, with space for a standard power cell."
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_chest"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE

	var/wired = 0
	var/obj/item/stock_parts/cell/cell = null
	starting_children = list(/obj/item/bodypart/groin/robot)

/obj/item/bodypart/chest/robot/nochildren
	starting_children = null

/obj/item/bodypart/groin/robot
	name = "cyborg groin"
	desc = "A heavily reinforced case containing cyborg logic boards."
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_groin"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 2
	burn_reduction = 1

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE
	starting_children = list()

/obj/item/bodypart/chest/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		if(src.cell)
			to_chat(user, "<span class='warning'>You have already inserted a cell!</span>")
			return
		else
			if(!user.transferItemToLoc(W, src))
				return
			src.cell = W
			to_chat(user, "<span class='notice'>You insert the cell.</span>")
	else if(istype(W, /obj/item/stack/cable_coil))
		if(src.wired)
			to_chat(user, "<span class='warning'>You have already inserted wire!</span>")
			return
		if (W.use_tool(src, user, 0, 1))
			src.wired = 1
			to_chat(user, "<span class='notice'>You insert the wire.</span>")
		else
			to_chat(user, "<span class='warning'>You need one length of coil to wire it!</span>")
	else
		return ..()

/obj/item/bodypart/chest/robot/Destroy()
	if(cell)
		qdel(cell)
		cell = null
	return ..()


/obj/item/bodypart/chest/robot/drop_organs(mob/user)
	if(wired)
		new /obj/item/stack/cable_coil(user.loc, 1)
	if(cell)
		cell.forceMove(user.loc)
		cell = null
	. = ..()

/obj/item/bodypart/head/robot
	name = "cyborg head"
	desc = "A standard reinforced braincase, with spine-plugged neural socket and sensor gimbals."
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/mob/augments/augments.dmi'
	flags_1 = CONDUCT_1
	icon_state = "borg_head"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

	brute_reduction = 5
	burn_reduction = 4

	no_brute_msg = ROBOTIC_NO_BRUTE_MSG
	light_brute_msg = ROBOTIC_LIGHT_BRUTE_MSG
	medium_brute_msg = ROBOTIC_MEDIUM_BRUTE_MSG
	heavy_brute_msg = ROBOTIC_HEAVY_BRUTE_MSG

	no_burn_msg = ROBOTIC_NO_BURN_MSG
	light_burn_msg = ROBOTIC_LIGHT_BURN_MSG
	medium_burn_msg = ROBOTIC_MEDIUM_BURN_MSG
	heavy_burn_msg = ROBOTIC_HEAVY_BURN_MSG
	render_like_organic = FALSE

	var/obj/item/assembly/flash/handheld/flash1 = null
	var/obj/item/assembly/flash/handheld/flash2 = null
	starting_children = list(/obj/item/bodypart/left_eye/robot, /obj/item/bodypart/right_eye/robot, /obj/item/bodypart/mouth/robot)

/obj/item/bodypart/head/robot/nochildren
	starting_children = null

/obj/item/bodypart/head/robot/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/assembly/flash/handheld))
		var/obj/item/assembly/flash/handheld/F = W
		if(src.flash1 && src.flash2)
			to_chat(user, "<span class='warning'>You have already inserted the eyes!</span>")
			return
		else if(F.crit_fail)
			to_chat(user, "<span class='warning'>You can't use a broken flash!</span>")
			return
		else
			if(!user.transferItemToLoc(F, src))
				return
			if(src.flash1)
				src.flash2 = F
			else
				src.flash1 = F
			to_chat(user, "<span class='notice'>You insert the flash into the eye socket.</span>")
	else if(istype(W, /obj/item/crowbar))
		if(flash1 || flash2)
			W.play_tool_sound(src)
			to_chat(user, "<span class='notice'>You remove the flash from [src].</span>")
			if(flash1)
				flash1.forceMove(user.loc)
				flash1 = null
			if(flash2)
				flash2.forceMove(user.loc)
				flash2 = null
		else
			to_chat(user, "<span class='warning'>There is no flash to remove from [src].</span>")

	else
		return ..()

/obj/item/bodypart/head/robot/Destroy()
	if(flash1)
		qdel(flash1)
		flash1 = null
	if(flash2)
		qdel(flash2)
		flash2 = null
	return ..()


/obj/item/bodypart/head/robot/drop_organs(mob/user)
	if(flash1)
		flash1.forceMove(user.loc)
		flash1 = null
	if(flash2)
		flash2.forceMove(user.loc)
		flash2 = null
	. = ..()

/obj/item/bodypart/mouth/robot
	name = "cyborg jaw"
	desc = "A standard reinforced tongue case."
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	flags_1 = CONDUCT_1
	icon_state = "jaw-c"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED

/obj/item/bodypart/neck/robot
	name = "cyborg neck"
	desc = "A standard reinforced vocal cord case, with spine-plugged neural socket and sensor gimbals."
	item_state = "buildpipe"
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	flags_1 = CONDUCT_1
	icon_state = "vertebrae-c"
	status = BODYPART_ROBOTIC
	limb_flags = BODYPART_NOBLEED
	starting_children = list(/obj/item/bodypart/head/robot)

/obj/item/bodypart/neck/robot/nochildren
	starting_children = null

// Surplus limbs
/obj/item/bodypart/l_arm/robot/surplus
	name = "surplus prosthetic left arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	status = BODYPART_ROBOTIC
	starting_children = list(/obj/item/bodypart/l_hand/robot/surplus)

/obj/item/bodypart/l_hand/robot/surplus
	name = "surplus prosthetic left hand"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	status = BODYPART_ROBOTIC

/obj/item/bodypart/r_arm/robot/surplus
	name = "surplus prosthetic right arm"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	status = BODYPART_ROBOTIC
	starting_children = list(/obj/item/bodypart/r_hand/robot/surplus)

/obj/item/bodypart/r_hand/robot/surplus
	name = "surplus prosthetic right hand"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	status = BODYPART_ROBOTIC

/obj/item/bodypart/l_leg/robot/surplus
	name = "surplus prosthetic left leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	status = BODYPART_ROBOTIC
	starting_children = list(/obj/item/bodypart/l_foot/robot/surplus)

/obj/item/bodypart/l_foot/robot/surplus
	name = "surplus prosthetic left foot"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	status = BODYPART_ROBOTIC

/obj/item/bodypart/r_leg/robot/surplus
	name = "surplus prosthetic right leg"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	status = BODYPART_ROBOTIC
	starting_children = list(/obj/item/bodypart/r_foot/robot/surplus)

/obj/item/bodypart/r_foot/robot/surplus
	name = "surplus prosthetic right foot"
	desc = "A skeletal, robotic limb. Outdated and fragile, but it's still better than nothing."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 0
	burn_reduction = 0
	max_damage = 20
	status = BODYPART_ROBOTIC

// Upgraded Surplus limbs - Better then robotic limbs
/obj/item/bodypart/l_arm/robot/surplus_upgraded
	name = "reinforced surplus prosthetic left arm"
	desc = "A skeletal, robotic limb. This one is reinforced to provide better protection, and is made of stronger parts."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 3
	burn_reduction = 2
	max_damage = 55
	status = BODYPART_ROBOTIC
	starting_children = list(/obj/item/bodypart/l_hand/robot/surplus_upgraded)

/obj/item/bodypart/l_hand/robot/surplus_upgraded
	name = "reinforced surplus prosthetic left hand"
	desc = "A skeletal, robotic limb. This one is reinforced to provide better protection, and is made of stronger parts."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 3
	burn_reduction = 2
	max_damage = 55

/obj/item/bodypart/r_arm/robot/surplus_upgraded
	name = "reinforced surplus prosthetic right arm"
	desc = "A skeletal, robotic limb. This one is reinforced to provide better protection, and is made of stronger parts."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 3
	burn_reduction = 2
	max_damage = 55
	starting_children = list(/obj/item/bodypart/r_hand/robot/surplus_upgraded)

/obj/item/bodypart/r_hand/robot/surplus_upgraded
	name = "reinforced surplus prosthetic right hand"
	desc = "A skeletal, robotic limb. This one is reinforced to provide better protection, and is made of stronger parts."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 3
	burn_reduction = 2
	max_damage = 55

/obj/item/bodypart/l_leg/robot/surplus_upgraded
	name = "reinforced surplus prosthetic left leg"
	desc = "A skeletal, robotic limb. This one is reinforced to provide better protection, and is made of stronger parts."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 3
	burn_reduction = 2
	max_damage = 55
	starting_children = list(/obj/item/bodypart/l_foot/robot/surplus_upgraded)

/obj/item/bodypart/l_foot/robot/surplus_upgraded
	name = "reinforced surplus prosthetic left foot"
	desc = "A skeletal, robotic limb. This one is reinforced to provide better protection, and is made of stronger parts."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 3
	burn_reduction = 2
	max_damage = 55

/obj/item/bodypart/r_leg/robot/surplus_upgraded
	name = "reinforced surplus prosthetic right leg"
	desc = "A skeletal, robotic limb. This one is reinforced to provide better protection, and is made of stronger parts."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 3
	burn_reduction = 2
	max_damage = 55
	starting_children = list(/obj/item/bodypart/r_foot/robot/surplus_upgraded)

/obj/item/bodypart/r_foot/robot/surplus_upgraded
	name = "reinforced surplus prosthetic right foot"
	desc = "A skeletal, robotic limb. This one is reinforced to provide better protection, and is made of stronger parts."
	icon = 'modular_skyrat/icons/mob/augments/surplus_augments.dmi'
	brute_reduction = 3
	burn_reduction = 2
	max_damage = 55

#undef ROBOTIC_LIGHT_BRUTE_MSG
#undef ROBOTIC_MEDIUM_BRUTE_MSG
#undef ROBOTIC_HEAVY_BRUTE_MSG

#undef ROBOTIC_LIGHT_BURN_MSG
#undef ROBOTIC_MEDIUM_BURN_MSG
#undef ROBOTIC_HEAVY_BURN_MSG

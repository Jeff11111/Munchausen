/// General limb augments
/datum/augment/limb
	limb = TRUE

/// Amputated limb base
/datum/augment/limb/amputated
	name = "Amputated Limb"

/datum/augment/limb/amputated/apply(client/cli, datum/preferences/prefs, mob/living/carbon/C)
	var/obj/item/bodypart/BP = C.get_bodypart(slot)
	if(BP)
		BP.drop_limb(FALSE, FALSE, FALSE, TRUE)

/datum/augment/limb/amputated/head
	name = "Amputated Head"
	slot = BODY_ZONE_HEAD

/datum/augment/limb/amputated/r_eye
	name = "Amputated Right Eye"
	slot = BODY_ZONE_PRECISE_RIGHT_EYE

/datum/augment/limb/amputated/l_eye
	name = "Amputated Left Eye"
	slot = BODY_ZONE_PRECISE_LEFT_EYE

/datum/augment/limb/amputated/jaw
	name = "Amputated Jaw"
	slot = BODY_ZONE_PRECISE_MOUTH

/datum/augment/limb/amputated/neck
	name = "Amputated Neck"
	slot = BODY_ZONE_PRECISE_NECK

/datum/augment/limb/amputated/r_arm
	name = "Amputated Right Arm"
	slot = BODY_ZONE_R_ARM

/datum/augment/limb/amputated/r_hand
	name = "Amputated Right Hand"
	slot = BODY_ZONE_PRECISE_R_HAND

/datum/augment/limb/amputated/l_arm
	name = "Amputated Left Arm"
	slot = BODY_ZONE_L_ARM

/datum/augment/limb/amputated/l_hand
	name = "Amputated Left Hand"
	slot = BODY_ZONE_PRECISE_L_HAND

/datum/augment/limb/amputated/groin
	name = "Amputated Groin"
	slot = BODY_ZONE_PRECISE_GROIN

/datum/augment/limb/amputated/r_leg
	name = "Amputated Right Leg"
	slot = BODY_ZONE_R_LEG

/datum/augment/limb/amputated/r_foot
	name = "Amputated Right Foot"
	slot = BODY_ZONE_PRECISE_R_FOOT

/datum/augment/limb/amputated/l_leg
	name = "Amputated Left Leg"
	slot = BODY_ZONE_L_LEG

/datum/augment/limb/amputated/l_foot
	name = "Amputated Left Foot"
	slot = BODY_ZONE_PRECISE_L_FOOT

/// Cybernetic limb base
/datum/augment/limb/robotic
	name = "Cybernetic Limb"

/datum/augment/limb/robotic/apply(client/cli, datum/preferences/prefs, mob/living/carbon/C)
	var/obj/item/bodypart/BP = new augmentation(C)
	BP.limb_flags &= ~BODYPART_NOBLEED
	BP.replace_limb(C, TRUE)

/datum/augment/limb/robotic/head
	name = "Cybernetic Head"
	slot = BODY_ZONE_HEAD
	augmentation = /obj/item/bodypart/head/robot/nochildren

/datum/augment/limb/robotic/r_eye
	name = "Cybernetic Right Eye"
	slot = BODY_ZONE_PRECISE_RIGHT_EYE
	augmentation = /obj/item/bodypart/right_eye/robot

/datum/augment/limb/robotic/l_eye
	name = "Cybernetic Left Eye"
	slot = BODY_ZONE_PRECISE_LEFT_EYE
	augmentation = /obj/item/bodypart/left_eye/robot

/datum/augment/limb/robotic/jaw
	name = "Cybernetic Jaw"
	slot = BODY_ZONE_PRECISE_MOUTH
	augmentation = /obj/item/bodypart/mouth/robot

/datum/augment/limb/robotic/neck
	name = "Cybernetic Neck"
	slot = BODY_ZONE_PRECISE_NECK
	augmentation = /obj/item/bodypart/neck/robot

/datum/augment/limb/robotic/r_arm
	name = "Cybernetic Right Arm"
	slot = BODY_ZONE_R_ARM
	augmentation = /obj/item/bodypart/r_arm/robot/nochildren

/datum/augment/limb/robotic/r_hand
	name = "Cybernetic Right Hand"
	slot = BODY_ZONE_PRECISE_R_HAND
	augmentation = /obj/item/bodypart/r_hand/robot

/datum/augment/limb/robotic/l_arm
	name = "Cybernetic Left Arm"
	slot = BODY_ZONE_L_ARM
	augmentation = /obj/item/bodypart/l_arm/robot/nochildren

/datum/augment/limb/robotic/l_hand
	name = "Cybernetic Left Hand"
	slot = BODY_ZONE_PRECISE_L_HAND
	augmentation = /obj/item/bodypart/l_hand/robot

/datum/augment/limb/robotic/chest
	name = "Cybernetic Chest"
	slot = BODY_ZONE_CHEST
	augmentation = /obj/item/bodypart/chest/robot/nochildren

/datum/augment/limb/robotic/groin
	name = "Cybernetic Groin"
	slot = BODY_ZONE_PRECISE_GROIN
	augmentation = /obj/item/bodypart/groin/robot

/datum/augment/limb/robotic/r_leg
	name = "Cybernetic Right Leg"
	slot = BODY_ZONE_R_LEG
	augmentation = /obj/item/bodypart/r_leg/robot/nochildren

/datum/augment/limb/robotic/r_foot
	name = "Cybernetic Right Foot"
	slot = BODY_ZONE_PRECISE_R_FOOT
	augmentation = /obj/item/bodypart/r_foot/robot

/datum/augment/limb/robotic/l_leg
	name = "Cybernetic Left Leg"
	slot = BODY_ZONE_L_LEG
	augmentation = /obj/item/bodypart/l_leg/robot/nochildren

/datum/augment/limb/robotic/l_foot
	name = "Cybernetic Left Foot"
	slot = BODY_ZONE_PRECISE_L_FOOT
	augmentation = /obj/item/bodypart/l_foot/robot

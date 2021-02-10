/// General organ augments
/datum/augment/organ
	limb = TRUE

/// Missing organ base
/datum/augment/organ/missing
	name = "Missing Organ"

/datum/augment/organ/missing/apply(client/cli, datum/preferences/prefs, mob/living/carbon/C)
	var/obj/item/organ/O = C.getorganslot(slot)
	if(O)
		O.Remove(FALSE)
		qdel(O)

/datum/augment/organ/missing/brain
	name = "Missing Brain"
	slot = ORGAN_SLOT_BRAIN

/datum/augment/organ/missing/ears
	name = "Missing Ears"
	slot = ORGAN_SLOT_EARS

/datum/augment/organ/missing/tongue
	name = "Missing Tongue"
	slot = ORGAN_SLOT_TONGUE

/datum/augment/organ/missing/heart
	name = "Missing Heart"
	slot = ORGAN_SLOT_HEART

/datum/augment/organ/missing/lungs
	name = "Missing Lungs"
	slot = ORGAN_SLOT_LUNGS

/datum/augment/organ/missing/liver
	name = "Missing Liver"
	slot = ORGAN_SLOT_LIVER

/datum/augment/organ/missing/kidneys
	name = "Missing Kidneys"
	slot = ORGAN_SLOT_KIDNEYS

/datum/augment/organ/missing/spleen
	name = "Missing Spleen"
	slot = ORGAN_SLOT_SPLEEN

/datum/augment/organ/missing/stomach
	name = "Missing Stomach"
	slot = ORGAN_SLOT_STOMACH

/datum/augment/organ/missing/appendix
	name = "Missing Appendix"
	slot = ORGAN_SLOT_APPENDIX

/datum/augment/organ/missing/intestines
	name = "Missing Intestines"
	slot = ORGAN_SLOT_INTESTINES

/datum/augment/organ/missing/bladder
	name = "Missing Bladder"
	slot = ORGAN_SLOT_BLADDER

/datum/augment/organ/missing/alcohol_gland
	name = "Missing Alcohol Gland"
	slot = ORGAN_SLOT_ALCOHOL_GLAND

/datum/augment/organ/missing/tail
	name = "Missing Tail"
	slot = ORGAN_SLOT_TAIL

/// Robotic organ base
/datum/augment/organ/robotic
	name = "Robotic Organ"

/datum/augment/organ/robotic/apply(client/cli, datum/preferences/prefs, mob/living/carbon/C)
	var/obj/item/organ/O = new augmentation(C)
	if(O)
		O.Insert(C, TRUE)

/datum/augment/organ/robotic/brain
	name = "IPC Brain"
	slot = ORGAN_SLOT_BRAIN
	augmentation = /obj/item/organ/brain/ipc_positron

/datum/augment/organ/robotic/ears
	name = "Cybernetic Ears"
	slot = ORGAN_SLOT_EARS
	augmentation = /obj/item/organ/ears/cybernetic

/datum/augment/organ/robotic/tongue
	name = "Cybernetic Tongue"
	slot = ORGAN_SLOT_TONGUE
	augmentation = /obj/item/organ/tongue/cybernetic

/datum/augment/organ/robotic/heart
	name = "Cybernetic Heart"
	slot = ORGAN_SLOT_HEART
	augmentation = /obj/item/organ/heart/cybernetic

/datum/augment/organ/robotic/lungs
	name = "Cybernetic Lungs"
	slot = ORGAN_SLOT_LUNGS
	augmentation = /obj/item/organ/lungs/cybernetic

/datum/augment/organ/robotic/liver
	name = "Cybernetic Liver"
	slot = ORGAN_SLOT_LIVER
	augmentation = /obj/item/organ/liver/cybernetic

/datum/augment/organ/robotic/kidneys
	name = "Cybernetic Kidneys"
	slot = ORGAN_SLOT_KIDNEYS
	augmentation = /obj/item/organ/kidneys/cybernetic

/datum/augment/organ/robotic/spleen
	name = "Cybernetic Spleen"
	slot = ORGAN_SLOT_SPLEEN
	augmentation = /obj/item/organ/spleen/cybernetic

/datum/augment/organ/robotic/stomach
	name = "Cybernetic Stomach"
	slot = ORGAN_SLOT_STOMACH
	augmentation = /obj/item/organ/stomach/robot_ipc

/datum/augment/organ/robotic/intestines
	name = "Cybernetic Intestines"
	slot = ORGAN_SLOT_INTESTINES
	augmentation = /obj/item/organ/intestines/cybernetic

/datum/augment/organ/robotic/bladder
	name = "Cybernetic Bladder"
	slot = ORGAN_SLOT_BLADDER
	augmentation = /obj/item/organ/bladder/cybernetic

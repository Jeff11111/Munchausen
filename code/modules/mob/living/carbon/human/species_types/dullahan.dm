/datum/species/dullahan
	name = "Dullahan"
	id = "dullahan"
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS,CAN_SCAR,HAS_FLESH,HAS_BONE)
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOHYDRATION,TRAIT_NOBREATH)
	mutant_bodyparts = list("tail_human" = "None", "ears" = "None", "deco_wings" = "None")
	use_skintones = USE_SKINTONES_GRAYSCALE_CUSTOM
	mutantbrain = /obj/item/organ/brain/dullahan
	mutanttongue = /obj/item/organ/tongue/dullahan
	mutantears = /obj/item/organ/ears/dullahan
	blacklisted = TRUE
	limbs_id = "human"
	skinned_type = /obj/item/stack/sheet/animalhide/human
	has_field_of_vision = FALSE //Too much of a trouble, their vision is already bound to their severed head.
	var/pumpkin = FALSE
	var/obj/item/dullahan_relay/myhead
	bloodtypes = list("A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-")

/datum/species/dullahan/pumpkin
	name = "Pumpkin Head Dullahan"
	id = "pumpkindullahan"
	pumpkin = TRUE

/datum/species/dullahan/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return FALSE

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	DISABLE_BITFIELD(H.flags_1, HEAR_1)
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		if(pumpkin)//Pumpkinhead!
			head.animal_origin = 100
			head.icon = 'icons/obj/clothing/hats.dmi'
			head.icon_state = "hardhat1_pumpkin_j"
			head.custom_head = TRUE
		head.drop_limb()
		if(!QDELETED(head)) //drop_limb() deletes the limb if it's no drop location and dummy humans used for rendering icons are located in nullspace. Do the math.
			head.throwforce = 25
			myhead = new /obj/item/dullahan_relay (head, H)
			H.put_in_hands(head)
			var/obj/item/bodypart/left_eye/LE = H.get_bodypart(BODY_ZONE_PRECISE_LEFT_EYE)
			var/obj/item/bodypart/right_eye/RE = H.get_bodypart(BODY_ZONE_PRECISE_RIGHT_EYE)
			for(var/datum/action/item_action/organ_action/OA in LE?.actions)
				OA.Trigger()
			for(var/datum/action/item_action/organ_action/OA in RE?.actions)
				OA.Trigger()

/datum/species/dullahan/on_species_loss(mob/living/carbon/human/H)
	ENABLE_BITFIELD(H.flags_1, HEAR_1)
	H.reset_perspective(H)
	if(myhead)
		var/obj/item/dullahan_relay/DR = myhead
		myhead = null
		DR.owner = null
		qdel(DR)
	H.regenerate_limb(BODY_ZONE_HEAD,FALSE)
	..()

/datum/species/dullahan/spec_life(mob/living/carbon/human/H)
	if(QDELETED(myhead))
		myhead = null
		H.gib()
	var/obj/item/bodypart/head/head2 = H.get_bodypart(BODY_ZONE_HEAD)
	if(head2)
		myhead = null
		H.gib()

/datum/species/dullahan/proc/update_vision_perspective(mob/living/carbon/human/H)
	var/obj/item/bodypart/left_eye/LE = H.get_bodypart(BODY_ZONE_PRECISE_LEFT_EYE)
	var/obj/item/bodypart/right_eye/RE = H.get_bodypart(BODY_ZONE_PRECISE_RIGHT_EYE)
	if(LE || RE)
		if(LE.tint || RE.tint)
			H.reset_perspective(H)
		else
			H.reset_perspective(myhead)
		H.update_tint()

/obj/item/organ/brain/dullahan
	decoy_override = TRUE
	organ_flags = ORGAN_NO_SPOIL//Do not decay

/obj/item/organ/tongue/dullahan
	zone = "abstract"
	modifies_speech = TRUE

/obj/item/organ/tongue/dullahan/handle_speech(datum/source, list/speech_args)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(isdullahan(H))
			var/datum/species/dullahan/D = H.dna.species
			if(isobj(D.myhead.loc))
				var/obj/O = D.myhead.loc
				O.say(speech_args[SPEECH_MESSAGE])
	speech_args[SPEECH_MESSAGE] = ""

/obj/item/organ/ears/dullahan
	zone = "abstract"

/datum/action/item_action/organ_action/dullahan
	name = "Toggle Perspective"
	desc = "Switch between seeing normally from your head, or blindly from your body."

/datum/action/item_action/organ_action/dullahan/Trigger()
	. = ..()
	var/mob/living/carbon/C = owner
	if(!istype(C))
		return
	var/obj/item/bodypart/left_eye/LE = C.get_bodypart(BODY_ZONE_PRECISE_LEFT_EYE)
	var/obj/item/bodypart/right_eye/RE = C.get_bodypart(BODY_ZONE_PRECISE_RIGHT_EYE)
	if(LE?.tint)
		LE?.tint = 0
	else
		LE?.tint = INFINITY

	if(RE?.tint)
		RE?.tint = 0
	else
		RE?.tint = INFINITY

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(isdullahan(H))
			var/datum/species/dullahan/D = H.dna.species
			D.update_vision_perspective(H)

/obj/item/dullahan_relay
	name = "dullahan relay"
	var/mob/living/owner
	flags_1 = HEAR_1

/obj/item/dullahan_relay/Initialize(mapload, mob/living/carbon/human/new_owner)
	. = ..()
	if(!new_owner)
		return INITIALIZE_HINT_QDEL
	owner = new_owner
	START_PROCESSING(SSobj, src)
	RegisterSignal(owner, COMSIG_MOB_CLICKED_SHIFT_ON, .proc/examinate_check)
	RegisterSignal(src, COMSIG_ATOM_HEARER_IN_VIEW, .proc/include_owner)
	RegisterSignal(owner, COMSIG_LIVING_REGENERATE_LIMBS, .proc/unlist_head)
	RegisterSignal(owner, COMSIG_LIVING_REVIVE, .proc/retrieve_head)

/obj/item/dullahan_relay/proc/examinate_check(mob/source, atom/target)
	if(source.client.eye == src)
		return COMPONENT_ALLOW_EXAMINATE

/obj/item/dullahan_relay/proc/include_owner(datum/source, list/processing_list, list/hearers)
	if(!QDELETED(owner))
		hearers += owner

/obj/item/dullahan_relay/proc/unlist_head(datum/source, noheal = FALSE, list/excluded_limbs)
	excluded_limbs |= BODY_ZONE_HEAD // So we don't gib when regenerating limbs.

//Retrieving the owner's head for better ahealing.
/obj/item/dullahan_relay/proc/retrieve_head(datum/source, full_heal, admin_revive)
	if(admin_revive)
		var/obj/item/bodypart/head/H = loc
		var/turf/T = get_turf(owner)
		if(H && istype(H) && T && !(H in owner.GetAllContents()))
			H.forceMove(T)

/obj/item/dullahan_relay/process()
	if(!istype(loc, /obj/item/bodypart/head) || QDELETED(owner))
		. = PROCESS_KILL
		qdel(src)

/obj/item/dullahan_relay/Destroy()
	if(!QDELETED(owner))
		var/mob/living/carbon/human/H = owner
		if(isdullahan(H))
			var/datum/species/dullahan/D = H.dna.species
			D.myhead = null
			owner.gib()
	owner = null
	..()



/datum/antagonist/bloodsucker/proc/CheckVampOrgans()
	// Do I have any parts that need replacing?
	var/obj/item/organ/O
	// Heart
	O = owner.current.getorganslot(ORGAN_SLOT_HEART)

	if(!istype(O, /obj/item/organ/heart/vampheart) && !istype(O, /obj/item/organ/heart/demon))
		qdel(O)
		var/obj/item/organ/heart/vampheart/H = new
		H.Insert(owner.current)
		H.Stop() // Now...stop beating!
	
	// Eyes
	var/mob/living/carbon/C = owner.current
	if(istype(C))
		var/obj/item/bodypart/left_eye/LE = C.get_bodypart(BODY_ZONE_PRECISE_LEFT_EYE)
		var/obj/item/bodypart/right_eye/RE = C.get_bodypart(BODY_ZONE_PRECISE_RIGHT_EYE)
		if(!istype(LE, /obj/item/bodypart/left_eye/vassal/bloodsucker))
			qdel(LE)
			LE = new /obj/item/bodypart/left_eye/vassal/bloodsucker(C)
			LE.attach_limb(C, TRUE, FALSE)
		if(!istype(RE, /obj/item/bodypart/right_eye/vassal/bloodsucker))
			qdel(RE)
			RE = new /obj/item/bodypart/right_eye/vassal/bloodsucker(C)
			RE.attach_limb(C, TRUE, FALSE)

/datum/antagonist/bloodsucker/proc/RemoveVampOrgans()
	// Heart
	var/obj/item/organ/heart/H = new
	H.Insert(owner.current)
	// Eyes
	var/obj/item/bodypart/left_eye/LE = new
	var/obj/item/bodypart/right_eye/RE = new
	LE.attach_limb(owner.current, TRUE, FALSE)
	RE.attach_limb(owner.current, TRUE, FALSE)

// 		HEART: OVERWRITE	//
// 		HEART 		//
/obj/item/organ/heart/vampheart
	pulse = 0
	var/fakingit = 0

/obj/item/organ/heart/vampheart/can_stop() //We don't stop beating in normal circumstances
	return FALSE

/obj/item/organ/heart/vampheart/Restart()
	pulse = 0	// DONT run ..(). We don't want to start beating again.
	return 0

/obj/item/organ/heart/vampheart/Stop()
	fakingit = 0
	return ..()

/obj/item/organ/heart/vampheart/proc/FakeStart()
	fakingit = 1 // We're pretending to beat, to fool people.

/obj/item/organ/heart/vampheart/HeartStrengthMessage()
	if(fakingit)
		return "a healthy"
	return "<span class='danger'>no</span>"	// Bloodsuckers don't have a heartbeat at all when stopped (default is "an unstable")
// 		EYES 		//

/obj/item/bodypart/left_eye/vassal
	lighting_alpha = 180 //  LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE  <--- This is too low a value at 128. We need to SEE what the darkness is so we can hide in it.
	see_in_dark = 12
	flash_protect = -1 //These eyes are weaker to flashes, but let you see in the dark

/obj/item/bodypart/right_eye/vassal
	lighting_alpha = 180 //  LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE  <--- This is too low a value at 128. We need to SEE what the darkness is so we can hide in it.
	see_in_dark = 12
	flash_protect = -1 //These eyes are weaker to flashes, but let you see in the dark

/obj/item/bodypart/left_eye/vassal/bloodsucker
	flash_protect = 2 //Eye healing isnt working properly
	sight_flags = SEE_MOBS // Taken from augmented_eyesight.dm

/obj/item/bodypart/right_eye/vassal/bloodsucker
	flash_protect = 2 //Eye healing isnt working properly
	sight_flags = SEE_MOBS // Taken from augmented_eyesight.dm

/*
//		LIVER		//
/obj/item/organ/liver/vampliver
	// Livers run on_life(), which calls reagents.metabolize() in holder.dm, which calls on_mob_life.dm in the cheam (medicine_reagents.dm)
	//															Holder also calls reagents.reaction_mob for the moment it happens

/obj/item/organ/liver/vampliver/on_life()
	var/mob/living/carbon/C = owner

	if(!istype(C))
		return

*/

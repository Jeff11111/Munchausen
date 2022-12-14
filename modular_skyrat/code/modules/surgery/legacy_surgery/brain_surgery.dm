/datum/surgery/brain_surgery
	name = "Brain surgery"
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/fix_brain,
	/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_HEAD)
	requires_bodypart_type = BODYPART_ORGANIC //Skyrat change
	var/antispam = FALSE

/datum/surgery_step/fix_brain
	name = "Fix brain"
	implements = list(TOOL_HEMOSTAT = 90, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15) //don't worry, pouring some alcohol on their open brain will get that chance to 100
	time = 120 //long and complicated

/datum/surgery/brain_surgery/can_start(mob/user, mob/living/carbon/target, obj/item/tool)
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	return TRUE

/datum/surgery_step/fix_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/surgery/healing/the_surgery = surgery
	if(!the_surgery.antispam)
		display_results(user, target, "<span class='notice'>You begin to fix [target]'s brain...</span>",
			"[user] begins to fix [target]'s brain.",
			"[user] begins to perform surgery on [target]'s brain.")

/datum/surgery_step/fix_brain/initiate(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail)
	if(..() && iscarbon(target))
		var/mob/living/carbon/C = target
		while(C.getBrainLoss() || C.get_traumas())
			if(!..())
				break

/datum/surgery_step/fix_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/brainwashed))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	target.setBrainLoss(target.getBrainLoss() - 60)	//we set damage in this case in order to clear the "failing" flag
	target.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	display_results(user, target, "<span class='notice'>You succeed in fixing [target]'s brain.</span>",
		"[user] successfully fixes [target]'s brain!",
		"[user] completes the surgery step on [target]'s brain.")
	var/datum/surgery/brain_surgery/the_surgery = surgery
	the_surgery.antispam = TRUE
	return TRUE

/datum/surgery_step/fix_brain/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(user, target, "<span class='warning'>You screw up, causing more damage!</span>",
			"<span class='warning'>[user] screws up, causing brain damage!</span>",
			"[user] completes the surgery on [target]'s brain.")
		if(prob(20))
			target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message("<span class='warning'>[user] suddenly notices that the brain [user.p_they()] [user.p_were()] working on is not there anymore.", "<span class='warning'>You suddenly notice that the brain you were working on is not there anymore.</span>")
	var/datum/surgery/brain_surgery/the_surgery = surgery
	the_surgery.antispam = TRUE
	return FALSE

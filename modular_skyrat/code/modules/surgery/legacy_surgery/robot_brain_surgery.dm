/datum/surgery/robot_brain_surgery
	name = "Reset posibrain logic (Brain surgery)"
	steps = list(
	/datum/surgery_step/mechanic_open,
	/datum/surgery_step/open_hatch,
	/datum/surgery_step/fix_robot_brain,
	/datum/surgery_step/mechanic_close)
	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYPART_ROBOTIC
	desc = "A surgical procedure that restores the default behavior logic and personality matrix of an IPC posibrain."
	var/antispam = FALSE

/datum/surgery_step/fix_robot_brain
	name = "Fix posibrain (multitool)"
	implements = list(TOOL_MULTITOOL = 100, TOOL_HEMOSTAT = 35, TOOL_SCREWDRIVER = 15)
	time = 120 //long and complicated

/datum/surgery/robot_brain_surgery/can_start(mob/user, mob/living/carbon/target, obj/item/tool)
	. = ..()
	var/obj/item/organ/brain/B = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!B)
		return FALSE
	possible_locs = list(B.zone)

/datum/surgery_step/fix_robot_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/datum/surgery/healing/the_surgery = surgery
	if(!the_surgery.antispam)
		display_results(user, target, "<span class='notice'>You begin to fix [target]'s posibrain...</span>",
			"[user] begins to fix [target]'s posibrain.",
			"[user] begins to perform surgery on [target]'s posibrain.")

/datum/surgery_step/fix_robot_brain/initiate(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail)
	if(..() && iscarbon(target))
		var/mob/living/carbon/C = target
		while(C.getBrainLoss() || C.get_traumas())
			if(!..())
				break

/datum/surgery_step/fix_robot_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/brainwashed))
		target.mind.remove_antag_datum(/datum/antagonist/brainwashed)
	target.setBrainLoss(target.getBrainLoss() - 60)	//we set damage in this case in order to clear the "failing" flag
	target.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY) //Lobotomy tier fix cause you can't clone this!
	display_results(user, target, "<span class='notice'>You succeed in fixing [target]'s posibrain.</span>",
		"[user] successfully fixes [target]'s posibrain!",
		"[user] completes the surgery on [target]'s posibrain.")
	var/datum/surgery/healing/the_surgery = surgery
	the_surgery.antispam = TRUE
	return TRUE

/datum/surgery_step/fix_robot_brain/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.getorganslot(ORGAN_SLOT_BRAIN))
		display_results(user, target, "<span class='warning'>You screw up, causing more damage!</span>",
			"<span class='warning'>[user] screws up, causing damage to the circuits!</span>",
			"[user] completes the surgery step on [target]'s posibrain.")
		target.adjustBrainLoss(60)
		target.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
	else
		user.visible_message("<span class='warning'>[user] suddenly notices that the posibrain [user.p_they()] [user.p_were()] working on is not there anymore.", "<span class='warning'>You suddenly notice that the posibrain you were working on is not there anymore.</span>")
	return FALSE 

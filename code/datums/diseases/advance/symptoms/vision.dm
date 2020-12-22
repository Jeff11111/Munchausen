/*
//////////////////////////////////////

Hyphema (Eye bleeding)

	Slightly noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity.
	Critical Level.

Bonus
	Causes blindness.

//////////////////////////////////////
*/

/datum/symptom/visionloss

	name = "Hyphema"
	desc = "The virus causes inflammation of the retina, leading to eye damage and eventually blindness."
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 5
	base_message_chance = 50
	symptom_delay_min = 25
	symptom_delay_max = 80
	var/remove_eyes = FALSE
	threshold_desc = list(
		"Resistance 12" = "Weakens extraocular muscles, eventually leading to complete detachment of the eyes.",
		"Stealth 4" = "The symptom remains hidden until active.",
	)
/datum/symptom/visionloss/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.properties["stealth"] >= 4)
		suppress_warning = TRUE
	if(A.properties["resistance"] >= 12) //goodbye eyes
		remove_eyes = TRUE

/datum/symptom/visionloss/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!istype(M))
		return
	
	var/obj/item/bodypart/left_eye/LE = M.get_bodypart(BODY_ZONE_PRECISE_LEFT_EYE)
	var/obj/item/bodypart/right_eye/RE = M.get_bodypart(BODY_ZONE_PRECISE_RIGHT_EYE)
	if(LE || RE)
		switch(A.stage)
			if(1, 2)
				if(prob(base_message_chance) && !suppress_warning)
					to_chat(M, "<span class='warning'>Your eyes itch.</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>Your eyes burn!</b></span>")
				M.blur_eyes(10)
				LE?.receive_damage(burn=1)
				RE?.receive_damage(burn=1)
			else
				M.blur_eyes(20)
				LE?.receive_damage(brute=1)
				RE?.receive_damage(brute=1)
				if((LE?.get_damage() + RE?.get_damage()) >= 10)
					M.become_nearsighted(EYE_DAMAGE)
				if(prob((LE?.get_damage() + RE?.get_damage()) - 10 + 1))
					if(!remove_eyes)
						if(!HAS_TRAIT(M, TRAIT_BLIND))
							to_chat(M, "<span class='userdanger'>You go blind!</span>")
							LE?.kill_limb()
							RE?.kill_limb()
					else
						M.visible_message("<span class='warning'>[M]'s eyes fall off their sockets!</span>", "<span class='userdanger'>Your eyes fall off their sockets!</span>")
						LE?.apply_dismember(WOUND_SLASH)
						RE?.apply_dismember(WOUND_SLASH)
				else
					to_chat(M, "<span class='userdanger'>Your eyes burn horrifically!</span>")

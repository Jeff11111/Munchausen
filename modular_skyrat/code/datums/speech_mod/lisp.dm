//Lisp caused by lack of teeth
/datum/speech_mod/lisp
	var/lisp_force = 0

/datum/speech_mod/lisp/add_speech_mod(mob/living/carbon/human/M)
	..()
	update_lisp()

/datum/speech_mod/lisp/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = prob(lisp_force) ? replacetext(message, "f", "ph") : message
		message = prob(lisp_force) ? replacetext(message, "t", "ph") : message
		message = prob(lisp_force) ? replacetext(message, "s", "sh") : message
		message = prob(lisp_force) ? replacetext(message, "th", "hh") : message
		message = prob(lisp_force) ? replacetext(message, "ck", "gh") : message
		message = prob(lisp_force) ? replacetext(message, "c", "gh") : message
		message = prob(lisp_force) ? replacetext(message, "k", "gh") : message
	speech_args[SPEECH_MESSAGE] = message

/datum/speech_mod/lisp/proc/update_lisp()
	var/obj/item/bodypart/mouth/jaw = affected_mob.get_bodypart_nostump(BODY_ZONE_PRECISE_MOUTH)
	if(jaw)
		lisp_force = (1 - jaw.get_teeth_amount()/jaw.max_teeth) * 100
	else
		lisp_force = 100
	//Remove if we have teeth (aka stopped being british)
	if(!lisp_force || (jaw.get_teeth_amount() >= jaw.max_teeth))
		remove_speech_mod()

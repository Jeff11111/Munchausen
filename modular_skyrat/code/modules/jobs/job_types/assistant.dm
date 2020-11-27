/datum/job/assistant
	title = "Stowaway"
	paycheck = 0
	paycheck_department = null
	var/commieprob = 15

/datum/job/assistant/equip(mob/living/carbon/human/H, visualsOnly, announce, latejoin, datum/outfit/outfit_override, client/preference_source)
	..()
	if(prob(commieprob) && (ROLE_COMMIE in preference_source.prefs?.be_special))
		var/datum/antagonist/communist/new_antag = new()
		addtimer(CALLBACK(H.mind, /datum/mind.proc/add_antag_datum, new_antag), rand(100,200))

/datum/outfit/job/assistant
	belt = null

/datum/outfit/job/assistant/post_equip(mob/living/carbon/human/H, visualsOnly, client/preference_source)
	. = ..()
	var/obj/item/card/id/id = H.wear_id?.GetID()
	if(id)
		id.update_label(null, "staff ID")

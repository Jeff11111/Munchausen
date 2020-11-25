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
	uniform = /obj/item/clothing/under/color/grey/os13
	shoes = /obj/item/clothing/shoes/sneakers/black

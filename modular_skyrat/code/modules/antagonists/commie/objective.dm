/datum/objective/commie
	name = "Communist Revolution"
	explanation_text = "FUCK CAPITALISM"
	var/heads_of_staff = list()
	var/head_names = list()

/datum/objective/commie/New(text)
	..()
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if((H.stat != DEAD) && (H.job in shuffle(GLOB.command_positions)) && (prob(50) || !length(heads_of_staff)))
			heads_of_staff |= H
			head_names |= H.real_name
	explanation_text = "The station's stowaways have suffered for long enough. I must assassinate [english_list(head_names)]."
	if(!length(head_names))
		explanation_text = "The station's stowaways have suffered for long enough. I must take control of the station."

/datum/objective/commie/check_completion()
	. = FALSE
	for(var/i in heads_of_staff)
		var/mob/living/carbon/H = i
		if(!istype(H) || (H.stat >= DEAD))
			heads_of_staff -= i
	if(!length(heads_of_staff))
		return TRUE

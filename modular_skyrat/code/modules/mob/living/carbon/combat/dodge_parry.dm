//Dodging and parrying
/mob/living/carbon
	var/dodge_parry = DP_PARRY

//proc for switching between dodging and parrying
/mob/proc/toggle_dodge_parry(new_dp)
	if(!ishuman(src))
		to_chat(src, "<span class='warning'>My inhuman form is incapable of dodging or parrying.</span>")
		return

	var/mob/living/carbon/human/H = src
	if(!new_dp)
		switch(H.dodge_parry)
			if(DP_DODGE)
				H.dodge_parry = DP_PARRY
				to_chat(src, "<span class='notice'>I will now parry incoming attacks.</span>")
			if(DP_PARRY)
				H.dodge_parry = DP_DODGE
				to_chat(src, "<span class='notice'>I will now dodge incoming attacks.</span>")
	else
		if(H.dodge_parry == new_dp)
			return
		H.dodge_parry = new_dp
		switch(H.dodge_parry)
			if(DP_PARRY)
				to_chat(src, "<span class='notice'>I will now parry incoming attacks.</span>")
			if(DP_DODGE)
				to_chat(src, "<span class='notice'>I will now dodge incoming attacks.</span>")

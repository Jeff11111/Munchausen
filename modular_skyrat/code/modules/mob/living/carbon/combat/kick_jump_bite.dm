//Special attacks
/mob/living/carbon
	var/special_attack = SPECIAL_ATK_NONE

//Verb for switching between jump, kick and bite
/mob/proc/toggle_kick_bite(new_attack)
	if(!ishuman(src))
		to_chat(src, "<span class='warning'>My inhuman form is incapable of doing special attacks.</span>")
		return

	var/mob/living/carbon/human/H = src
	if(new_attack == H.special_attack)
		H.special_attack = SPECIAL_ATK_NONE
		to_chat(src, "<span class='notice'>I will now attack my targets normally.</span>")
	else
		switch(new_attack)
			if(SPECIAL_ATK_KICK)
				H.special_attack = SPECIAL_ATK_KICK
				to_chat(src, "<span class='notice'>I will now try to kick my targets.</span>")
			if(SPECIAL_ATK_BITE)
				H.special_attack = SPECIAL_ATK_BITE
				to_chat(src, "<span class='notice'>I will now try to bite my targets.</span>")
			if(SPECIAL_ATK_JUMP)
				H.special_attack = SPECIAL_ATK_JUMP
				to_chat(src, "<span class='notice'>I will now attempt to tackle at my targets.</span>")

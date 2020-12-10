/obj/screen/jump
	name = "jump"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_jump"

/obj/screen/jump/Click(location, control, params)
	. = ..()
	hud?.mymob?.toggle_kick_bite(SPECIAL_ATK_JUMP)

/obj/screen/bite/update_icon_state()
	var/mob/living/carbon/C = hud?.mymob
	if(istype(C) && C.special_attack == SPECIAL_ATK_JUMP)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = initial(icon_state)

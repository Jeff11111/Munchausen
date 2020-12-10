/obj/screen/kick
	name = "kick"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_kick"

/obj/screen/kick/Click(location, control, params)
	. = ..()
	hud?.mymob?.toggle_kick_bite(SPECIAL_ATK_KICK)

/obj/screen/bite/update_icon()
	. = ..()
	var/mob/living/carbon/C = hud?.mymob
	if(istype(C) && C.special_attack == SPECIAL_ATK_KICK)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = initial(icon_state)

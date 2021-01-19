/obj/screen/teach
	name = "teach"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_teach"

/obj/screen/teach/Click(location, control, params)
	. = ..()
	SEND_SIGNAL(usr, COMSIG_ELEMENT_TRY_TEACHING)

/obj/screen/teach/update_icon_state()
	. = ..()
	if(hud?.mymob && (SEND_SIGNAL(hud.mymob, COMSIG_ELEMENT_CHECK_TEACHING) || SEND_SIGNAL(hud.mymob, COMSIG_ELEMENT_CHECK_TAUGHT)))
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = initial(icon_state)

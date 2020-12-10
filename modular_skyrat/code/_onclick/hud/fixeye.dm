/obj/screen/fixeye
	name = "fix eye"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "fixeye"
	var/fixed_eye = FALSE

/obj/screen/fixeye/Click(location, control, params)
	. = ..()
	if(hud && usr == hud.mymob)
		SEND_SIGNAL(hud.mymob, COMSIG_TOGGLE_FIXEYE)

/obj/screen/fixeye/update_icon_state()
	. = ..()
	if(fixed_eye)
		name = "unfix eye"
		icon_state = "[initial(icon_state)]_on"
	else
		name = "fix eye"
		icon_state = initial(icon_state)

//resting
/obj/screen/restbutton
	name = "rest"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_rest"

/obj/screen/restbutton/Click()
	if(isliving(usr))
		var/mob/living/theuser = usr
		theuser.lay_down()

/obj/screen/restbutton/update_icon()
	. = ..()
	if(hud?.mymob?.resting)
		icon_state = "[initial(icon_state)]_on"
	else
		icon_state = initial(icon_state)

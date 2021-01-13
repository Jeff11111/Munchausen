/obj/screen/sleeping
	name = "sleep"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_sleep"

/obj/screen/sleeping/Click(location, control, params)
	. = ..()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.sleeping = !C.sleeping
		update_icon()

/obj/screen/sleeping/update_icon_state()
	. = ..()
	var/mob/living/carbon/C = hud?.mymob
	if(!istype(C))
		return
	if(C.sleeping)
		icon_state = "[initial(icon_state)]_on"
		name = "sleeping"
	else
		if(C.IsSleeping())
			icon_state = "[initial(icon_state)]_waking"
			name = "waking up"
		else
			icon_state = initial(icon_state)
			name = "sleep"

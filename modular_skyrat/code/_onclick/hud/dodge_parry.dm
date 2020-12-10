/obj/screen/dodge_parry
	name = "dodge/parry toggle"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = DP_PARRY

/obj/screen/dodge_parry/Click(location, control, params)
	. = ..()
	var/mob/living/carbon/C = usr
	if(!istype(C))
		return
	C.toggle_dodge_parry()
	update_icon()

/obj/screen/dodge_parry/update_icon()
	. = ..()
	var/mob/living/carbon/C = hud?.mymob
	if(istype(C) && (C.dodge_parry == DP_DODGE))
		icon_state = DP_DODGE
	else
		icon_state = DP_PARRY

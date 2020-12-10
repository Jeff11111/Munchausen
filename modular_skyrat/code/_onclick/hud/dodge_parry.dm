/obj/screen/dodge_parry
	name = "dodge/parry toggle"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = DP_PARRY

/obj/screen/dodge_parry/Click(location, control, params)
	. = ..()
	var/mob/living/carbon/C = usr
	if(!istype(C))
		return
	var/list/PL = params2list(params)
	var/icon_y = text2num(PL["icon-y"])
	var/what_we_chose = (icon_y > 16 ? DP_DODGE : DP_PARRY)
	C.toggle_dodge_parry(what_we_chose)
	update_icon()

/obj/screen/dodge_parry/update_icon()
	. = ..()
	var/mob/living/carbon/C = hud?.mymob
	if(istype(C) && (C.dodge_parry == DP_DODGE))
		icon_state = DP_DODGE
	else
		icon_state = DP_PARRY

/obj/screen/kick_jump_bite
	name = "kick/jump/bite toggle"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_kickjumpbite"

/obj/screen/kick_jump_bite/Click(location, control, params)
	. = ..()
	var/list/PL = params2list(params)
	var/icon_y = text2num(PL["icon-y"])
	var/what_we_chose = (icon_y >= 12 ? (icon_y >= 22 ? SPECIAL_ATK_KICK : SPECIAL_ATK_JUMP) : SPECIAL_ATK_BITE)
	hud?.mymob?.toggle_kick_bite(what_we_chose)
	update_icon()

/obj/screen/kick_jump_bite/update_icon_state()
	var/mob/living/carbon/C = hud?.mymob
	if(istype(C) && (C.special_attack != SPECIAL_ATK_NONE))
		icon_state = "[initial(icon_state)]_[C.special_attack]"
	else
		icon_state = initial(icon_state)

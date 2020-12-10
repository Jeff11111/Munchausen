/obj/screen/wield
	name = "wield"
	icon_state = "act_wield"
	layer = ABOVE_HUD_LAYER - 0.1
	var/active = FALSE

/obj/screen/wield/update_icon()
	. = ..()
	if(active)
		name = "unwield"
		icon_state = "[initial(icon_state)]_on"
	else
		name = "wield"
		icon_state = initial(icon_state)

/obj/screen/wield/Click()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.wield_active_hand()

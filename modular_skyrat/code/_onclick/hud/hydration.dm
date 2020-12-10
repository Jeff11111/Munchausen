/obj/screen/hydration
	name = "hydration"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "hydration"

/obj/screen/hydration/update_icon()
	. = ..()
	switch(hud?.mymob?.hydration)
		if(HYDRATION_LEVEL_FULL to INFINITY)
			icon_state = "hydration4"
		if(HYDRATION_LEVEL_WELL_HYDRATED to HYDRATION_LEVEL_FULL)
			icon_state = "hydration3"
		if(HYDRATION_LEVEL_HYDRATED to HYDRATION_LEVEL_WELL_HYDRATED)
			icon_state = "hydration2"
		if(HYDRATION_LEVEL_THIRSTY to HYDRATION_LEVEL_HYDRATED)
			icon_state = "hydration1"
		if(0 to HYDRATION_LEVEL_THIRSTY)
			icon_state = "hydration0"

/obj/screen/nutrition
	name = "nutrition"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "nutrition"

/obj/screen/nutrition/update_icon()
	. = ..()
	switch(hud?.mymob?.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			icon_state = "nutrition4"
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			icon_state = "nutrition3"
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			icon_state = "nutrition2"
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			icon_state = "nutrition1"
		if(0 to NUTRITION_LEVEL_HUNGRY)
			icon_state = "nutrition0"

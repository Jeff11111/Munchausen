//Noise holder
/obj/screen/fullscreen/noise
	icon = 'modular_skyrat/icons/mob/screen/noise.dmi'
	icon_state = "1j"
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = HUD_LAYER-1
	plane = HUD_PLANE-1
	var/loggers = "j"
	var/poggers = 1

/obj/screen/fullscreen/noise/update_for_view(client_view)
	. = ..()
	poggers = rand(1,9)
	update_icon()

/obj/screen/fullscreen/noise/update_icon()
	. = ..()
	icon_state = "[poggers][loggers]"

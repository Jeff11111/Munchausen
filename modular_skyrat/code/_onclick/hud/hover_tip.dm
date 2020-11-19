//nice and gay
/obj/screen/hover_tip
	icon = 'modular_skyrat/icons/mob/noise.dmi'
	icon_state = "blank"
	screen_loc = "NORTH,CENTER-3"
	maptext_width = 256
	maptext_x = -16
	plane = HUD_PLANE
	var/style_carbon = "text-shadow:2px 2px 0 #000, -2px -2px 0 #000, 2px -2px 0 #000, -2px 2px 0 #000, 0px 2px 0 #000,2px 0px 0 #000,0px -2px 0 #000,-2px 0px 0 #000,2px 2px 5px #000;color: #7ea1ff;"
	var/style_atom = "text-shadow:2px 2px 0 #000, -2px -2px 0 #000, 2px -2px 0 #000, -2px 2px 0 #000, 0px 2px 0 #000,2px 0px 0 #000,0px -2px 0 #000,-2px 0px 0 #000,2px 2px 5px #000;color: #85d1e4;"

//OH NO NO NO
/obj/screen/hover_tip/proc/clownify()
	style_carbon = "text-shadow: 2px 2px 2px black;color: #7ea1ff;font-family: 'Comic Sans MS', 'Comic Sans', cursive;"
	style_atom = "position: absolute;left: 0;right: 0;margin: 15px 0;padding: 0 5px;font-family: impact;color: white;text-shadow:2px 2px 0 #000, -2px -2px 0 #000, 2px -2px 0 #000, -2px 2px 0 #000, 0px 2px 0 #000,2px 0px 0 #000,0px -2px 0 #000,-2px 0px 0 #000,2px 2px 5px #000;"

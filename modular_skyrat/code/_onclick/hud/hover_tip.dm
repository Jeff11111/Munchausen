//nice and gay
/obj/screen/hover_tip
	icon = 'modular_skyrat/icons/mob/screen/noise.dmi'
	icon_state = "blank"
	screen_loc = "NORTH,CENTER-3"
	maptext_width = 256
	maptext_height = 64
	maptext_x = -16
	plane = HUD_PLANE
	var/style_carbon = "font-family: \"Small Fonts\";font-size:12px;text-shadow: 1px 1px 0 #000000,-1px -1px 0 #000000, 2px 2px 0 #000000,-2px -2px 0 #000000;color: #7ea1ff;"
	var/style_atom = "font-family: \"Small Fonts\";font-size:12px;text-shadow: 1px 1px 0 #000000,-1px -1px 0 #000000, 2px 2px 0 #000000,-2px -2px 0 #000000;color: #85d1e4;"

//OH NO NO NO
/obj/screen/hover_tip/proc/clownify()
	style_carbon = "font-family: \"Cursive\";font-size:12px;text-shadow: 2px 2px 2px black;color: #7ea1ff;"
	style_atom = "font-family: impact;font-size:12px;position: absolute;left: 0;right: 0;margin: 15px 0;padding: 0 5px;color: white;text-shadow:2px 2px 0 #000, -2px -2px 0 #000, 2px -2px 0 #000, -2px 2px 0 #000, 0px 2px 0 #000,2px 0px 0 #000,0px -2px 0 #000,-2px 0px 0 #000,2px 2px 5px #000;"

/world/proc/update_status()

	var/list/features = list()


	var/s = ""
	var/hostedby
	if(config)
		var/server_name = CONFIG_GET(string/servername)
		if (server_name)
			s += "<b>[server_name]</b> &#8212; "

	s += " ("
	s += "<a href=\"discord.gg/bz9a9XkJef\">" //Change this to wherever you want the hub to link to. wzds change - links to the discord
	s += "Discord"  //Replace this with something else. Or ever better, delete it and uncomment the game version. wzds change - modifies hub entry link
	// s += "</a>|<a href=\"https://shadow-station.com\">"
	// s += "Website"
	// s += "</a>"
	s += ")\]" //encloses the server title in brackets to make the hub entry fancier
	s += "<br>[CONFIG_GET(string/servertagline)]<br>"


	var/n = 0
	for (var/mob/M in GLOB.player_list)
		if (M.client)
			n++

	if(SSmapping.config) // this just stops the runtime, honk.
		features += "[SSmapping.config.map_name]"

	if(NUM2SECLEVEL(GLOB.security_level))
		features += "[NUM2SECLEVEL(GLOB.security_level)] alert"

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"

	if (!host && hostedby)
		features += "hosted by <b>[hostedby]</b>"

	if (features)
		s += "\[[jointext(features, ", ")]"

	status = s

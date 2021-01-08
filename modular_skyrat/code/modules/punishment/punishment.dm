//Sometimes, fraglist aint enough
GLOBAL_LIST_INIT(fraggots, world.file2list('config/fraggots.txt'))

/mob
	var/fraggot = FALSE

/mob/proc/fraggotify(name_override = FALSE)
	fraggot = TRUE
	if(client?.key)
		GLOB.fraggots |= client.key
	//Announce to every player but the fraggot
	for(var/client/C in (GLOB.clients - client))
		SEND_SOUND(C, sound('modular_skyrat/sound/fraggot/kill_her_now_kill_her_now.ogg', FALSE, CHANNEL_COMBAT, 70))
		to_chat(C, "<span class='warning'><span class='big bold'>[emoji_parse(":killher:")][name_override ? name_override : src.real_name] IS A NIGGER FRAGGOT! KILL HER! KILL HER![emoji_parse(":killher:")]</span></span>")

/mob/transfer_ckey(mob/new_mob, send_signal)
	. = ..()
	if(client && (client.key in GLOB.fraggots))
		fraggot = TRUE
		new_mob.fraggot = TRUE
		//Announce to every player but the fraggot
		for(var/client/C in (GLOB.clients - client))
			SEND_SOUND(C, sound('modular_skyrat/sound/fraggot/kill_her_now_kill_her_now.ogg', FALSE, CHANNEL_COMBAT, 70))
			to_chat(C, "<span class='warning'><span class='big bold'>[emoji_parse(":killher:")][new_mob] IS A NIGGER FRAGGOT! KILL HER! KILL HER![emoji_parse(":killher:")]</span></span>")

/mob/living/Life(seconds, times_fired)
	. = ..()
	//Fragots effects
	if(fraggot)
		//Earrape
		if(prob(5))
			var/bees = pick('modular_skyrat/sound/fraggot/p1.ogg', 'modular_skyrat/sound/fraggot/p1.ogg')
			playsound_local(get_turf(src), bees, 200)
		//Chat spam
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>BIG CHUNGUS LOLOLOLOLLLLOLOLOLO!!!!</span></span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>UGANDA KNUCKLES LOLOLOLOL!</span></span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>REDDIT!!!!!!</span></span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>EPSTEIN DIDENT KILL HIMSELF!!!!</span></span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>GAMING!!!!</span></span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>BOBUX LOL!!!!</span></span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>YOU ARE NOT INVITED!!!!</span></span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>PLANES ARE STORED IN DA PARKIGN LOTS!!!!</span></span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>AIRCRAFT MORTORS ARE ENGINES!!!!</span></span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'><span class='big bold'>NIGGER!!!!</span></span>")
		//Screaming
		if(prob(25))
			agony_scream()
		if(prob(15))
			death_scream()
		if(prob(5))
			death_rattle()

//Killing fraggots gives you bobux
/mob/living/death(gibbed)
	. = ..()
	if(fraggot)
		for(var/mob/M in range(7, src))
			if(M.client?.prefs)
				M.client.prefs.adjust_bobux(1, "<span class='bobux'>You have seen a fraggot die! +1 bobux!</span>")

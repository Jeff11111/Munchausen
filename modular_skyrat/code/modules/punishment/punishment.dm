//Sometimes, fraglist aint enough
GLOBAL_LIST_INIT(fraggots, world.file2list('config/fraggots.txt'))

/mob
	var/fraggot = FALSE

/mob/transfer_ckey(mob/new_mob, send_signal)
	. = ..()
	if(ckey in GLOB.fraggots)
		fraggot = TRUE
		new_mob.fraggot = TRUE
		//Announce to every player but the fraggot
		for(var/client/C in (GLOB.clients - client))
			SEND_SOUND(C, sound('modular_skyrat/sound/fraggot/kill_her_now_kill_her_now.ogg', FALSE, CHANNEL_COMBAT, 70))
			to_chat(C, "<span class='warning'><span class='bigbold'>[emoji_parse(":killher:")][new_mob] IS A NIGGER FRAGGOT! KILL HER! KILL HER![emoji_parse(":killher:")]</span>")

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
			to_chat(src, "<span class='userdanger'>BIG CHUNGUS LOLOLOLOLLLLOLOLOLO!!!!</span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'>UGANDA KNUCKLES LOLOLOLOL!</span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'>REDDIT!!!!!!</span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'>EPSTEIN DIDENT KILL HIMSELF!!!!</span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'>GAMING!!!!</span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'>BOBUX LOL!!!!</span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'>YOU ARE NOT INVITED!!!!</span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'>PLANES ARE STORED IN DA PARKIGN LOTS!!!!</span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'>AIRCRAFT MORTORS ARE ENGINES!!!!</span>")
		if(prob(25))
			to_chat(src, "<span class='userdanger'>NIGGER!!!!</span>")
		//Screaming
		if(prob(25))
			agony_scream()

//Killing fraggots gives you bobux
/mob/living/death(gibbed)
	. = ..()
	if(fraggot)
		for(var/mob/M in range(7, src))
			if(M.client?.prefs)
				M.client.prefs.adjust_bobux(1, "<span class='bobux'>You have seen a fraggot die! +1 bobux!</span>")

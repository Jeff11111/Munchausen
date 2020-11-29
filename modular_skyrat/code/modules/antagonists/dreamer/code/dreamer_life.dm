//Processing procs related to dreamer, so he hallucinates and shit
GLOBAL_LIST_INIT(dreamer_object, world.file2list('modular_skyrat/code/modules/antagonists/dreamer/object_visions.txt'))
GLOBAL_LIST_INIT(dreamer_radio, world.file2list('modular_skyrat/code/modules/antagonists/dreamer/radio_visions.txt'))
GLOBAL_LIST_INIT(dreamer_ahelp, world.file2list('modular_skyrat/code/modules/antagonists/dreamer/ahelp_visions.txt'))
GLOBAL_LIST_INIT(dreamer_ooc, world.file2list('modular_skyrat/code/modules/antagonists/dreamer/ooc_visions.txt'))
GLOBAL_LIST_INIT(dreamer_bans, world.file2list('modular_skyrat/code/modules/antagonists/dreamer/ban_visions.txt'))

/datum/antagonist/dreamer
	var/dreamer_dreaming = FALSE

/datum/antagonist/dreamer/process()
	handle_dreamer()

/datum/antagonist/dreamer/proc/handle_dreamer()
	if(owner?.current)
		if(SEND_SIGNAL(owner.current, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_ACTIVE) || owner.current.hud_used?.dreamer?.waking_up)
			spawn(0)
				handle_dreamer_screenshake()
		spawn(0)
			handle_dreamer_hallucinations()
		if(owner.current.hud_used.dreamer.waking_up)
			spawn(0)
				handle_dreamer_waking_up()

/datum/antagonist/dreamer/proc/handle_dreamer_hallucinations()
	if(dreamer_dreaming)
		return
	//Modo waker ATIVAR
	dreamer_dreaming = TRUE
	//Standard screen flash annoyance
	if(prob(3))
		var/obj/screen/fullscreen/dreamer/dream = owner.current.hud_used?.dreamer
		if(dream)
			dream.icon_state = "hall[rand(1,10)]"
			var/kill_her = 2
			animate(dream, alpha = 255, time = kill_her)
			spawn(kill_her)
				var/hallsound = pick(
									'modular_skyrat/code/modules/antagonists/dreamer/sound/hall_appear1.ogg',
									'modular_skyrat/code/modules/antagonists/dreamer/sound/hall_appear2.ogg',
									'modular_skyrat/code/modules/antagonists/dreamer/sound/hall_appear3.ogg',
									)
				owner.current.playsound_local(get_turf(owner.current), hallsound, 100, 0)
				spawn(1)
					if(prob(50))
						var/comicsound = pick(
											'modular_skyrat/code/modules/antagonists/dreamer/sound/comic1.ogg',
											'modular_skyrat/code/modules/antagonists/dreamer/sound/comic2.ogg',
											'modular_skyrat/code/modules/antagonists/dreamer/sound/comic3.ogg',
											'modular_skyrat/code/modules/antagonists/dreamer/sound/comic4.ogg',
											)
						owner.current.playsound_local(get_turf(owner.current), comicsound, 100, 0)
					spawn(5)
						animate(dream, alpha = 0, time = 10)
	//Just random laughter
	else if(prob(2))
		var/comicsound = pick('modular_skyrat/code/modules/antagonists/dreamer/sound/comic1.ogg',
							'modular_skyrat/code/modules/antagonists/dreamer/sound/comic2.ogg',
							'modular_skyrat/code/modules/antagonists/dreamer/sound/comic3.ogg',
							'modular_skyrat/code/modules/antagonists/dreamer/sound/comic4.ogg',
							)
		owner.current.playsound_local(get_turf(owner.current), comicsound, 100, 0)
	//Crewmember radioing
	else if(prob(1))
		var/list/people = list()
		for(var/mob/living/carbon/human/H in GLOB.alive_mob_list)
			people += H
		if(length(people))
			var/mob/living/carbon/human/person = pick(people)
			var/list/dreamer_radio = GLOB.dreamer_radio.Copy()
			dreamer_radio |= owner.current.last_pain_message
			dreamer_radio |= owner.current.last_words
			var/speak = pick(dreamer_radio)
			speak = replacetext_char(speak, "SRC", "[owner.current.real_name]")
			speak = replacetext_char(speak, "CAPITALIZEME", "[uppertext(owner.current.real_name)]")
			var/message = owner.current.compose_message(person, owner.current.language_holder?.selected_language, speak,"[FREQ_COMMON]", list(person.speech_span), face_name = TRUE, source = (person.ears ? person.ears : person.ears_extra))
			to_chat(owner.current, message)
	//VERY rare mom/mob hallucination
	else if(prob(1) && prob(50))
		spawn(0)
			handle_dreamer_mob_hallucination()
	//Even rarer OOC hallucination
	else if(prob(1) && prob(25))
		var/clientkey = owner.current.client.key
		if(prob(50))
			var/client/cliente = pick(GLOB.clients)
			clientkey = cliente.key
		var/list/ooc_visions = GLOB.dreamer_ooc.Copy()
		ooc_visions |= owner.current.last_pain_message
		ooc_visions |= owner.current.last_words
		var/message = pick(ooc_visions)
		message = replacetext_char(message, "SRC", "[owner.current.real_name]")
		message = replacetext_char(message, "CAPITALIZEME", "[uppertext(owner.current.real_name)]")
		to_chat(owner.current, "<span class='ooc'><span class='prefix'>OOC:</span> <EM>[clientkey]:</EM> <span class='message linkify'>[message]</span></span>")
	//Even rarer than that jannie hallucination - bwoink hallucination
	else if(prob(1) && prob(10))
		var/fakemin = "Trey Liam"
		if(length(GLOB.admin_datums))
			var/datum/admins/badmin = GLOB.admin_datums[pick(GLOB.admin_datums)]
			if(badmin?.owner?.key)
				fakemin = badmin.owner.key
		var/list/dreamer_ahelps = GLOB.dreamer_ahelp.Copy()
		dreamer_ahelps |= owner.current.last_pain_message
		dreamer_ahelps |= owner.current.last_words
		var/message = pick(dreamer_ahelps)
		message = replacetext_char(message, "SRC", "[owner.current.real_name]")
		message = replacetext_char(message, "CAPITALIZEME", "[uppertext(owner.current.real_name)]")
		to_chat(owner.current, "<font color='red' size='4'><b>-- Administrator private message --</b></font>")
		to_chat(owner.current, "<span class='danger'>Admin PM from-<b><a href='https://youtu.be/wJWksPWDKOc'>[fakemin]</a></b>: <span class='linkify'>[message]</span></span>")
		to_chat(owner.current, "<span class='danger'><i>Click on the administrator's name to reply, or see all of your tickets in the admin column.</i></span>")
		SEND_SOUND(owner.current, sound('sound/effects/adminhelp.ogg'))
	//Ban hallucination
	else if(prob(1) && prob(5))
		var/fakemin = "Trey Liam"
		if(length(GLOB.admin_datums))
			var/datum/admins/badmin = GLOB.admin_datums[pick(GLOB.admin_datums)]
			if(badmin?.owner?.key)
				fakemin = badmin.owner.key
		var/list/dreamer_ban = GLOB.dreamer_bans.Copy()
		dreamer_ban |= owner.current.last_pain_message
		dreamer_ban |= owner.current.last_words
		var/message = pick(dreamer_ban)
		message = replacetext_char(message, "SRC", "[owner.current.real_name]")
		message = replacetext_char(message, "CAPITALIZEME", "[uppertext(owner.current.real_name)]")
		to_chat(owner.current, "<span class='boldannounce'><BIG>You have been banned by [fakemin].\nReason: [message]</BIG></span>")
		to_chat(owner.current, "<span class='danger'>This is a permanent ban. The round ID is [GLOB.round_id].</span>")
		var/bran = CONFIG_GET(string/banappeals)
		if(!bran)
			bran = "your grave"
		to_chat(owner.current, "<span class='danger'>To try to resolve this matter head to <a href='https://www.sprc.org/'>[bran]</a>")
		to_chat(owner.current, "<div class='connectionClosed internal'>You are either AFK, experiencing lag or the connection has closed.</div>")
	//Talking objects
	if(prob(6))
		var/list/objects = list()
		for(var/obj/O in view(owner.current))
			objects += O
		if(length(objects))
			var/message
			if(prob(66) || !length(owner.current.last_words))
				var/list/dreamer_object = GLOB.dreamer_object.Copy()
				dreamer_object |= "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"
				message = pick(dreamer_object)
			else
				message = owner.current.last_words
			message = replacetext_char(message, "SRC", "[owner.current.real_name]")
			message = replacetext_char(message, "CAPITALIZEME", "[uppertext(owner.current.real_name)]")
			var/obj/speaker = pick(objects)
			if(speaker && message)
				var/speak_sound = pick(
								'modular_skyrat/code/modules/antagonists/dreamer/sound/female_talk1.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/female_talk2.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/female_talk3.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/female_talk4.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/female_talk5.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/male_talk1.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/male_talk2.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/male_talk3.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/male_talk4.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/male_talk5.ogg',
								'modular_skyrat/code/modules/antagonists/dreamer/sound/male_talk6.ogg',
								)
				owner.current.playsound_local(get_turf(owner.current), speak_sound, 50, 0)
				var/new_message = owner.current.compose_message(speaker, owner.current.language_holder?.selected_language, message)
				to_chat(owner.current, new_message)
				owner.current.create_chat_message(speaker, null, message)
	//Floors go crazy go stupid
	var/list/turf/open/floor/floorlist = list()
	for(var/turf/open/floor/F in view(owner.current))
		if(prob(15))
			floorlist += F
	for(var/F in floorlist)
		spawn(0)
			handle_dreamer_floor(F)
	//Shit on THA walls
	var/list/turf/closed/wall/walllist = list()
	for(var/turf/closed/wall/W in view(owner.current))
		if(prob(7))
			walllist += W
	for(var/W in walllist)
		spawn(0)
			handle_dreamer_wall(W)
	dreamer_dreaming = FALSE

/datum/antagonist/dreamer/proc/handle_dreamer_floor(turf/open/floor/T)
	if(!T || !owner.current.client)
		return
	var/image/I = image(T.icon, T, T.icon_state, T.layer+0.1, T.dir)
	owner.current.client?.images += I
	var/offset = pick(-3,-2, -1, 1, 2, 3)
	var/disappearfirst = (rand(10, 30) * abs(offset))
	animate(I, pixel_y = (I.pixel_y + offset), time = disappearfirst)
	sleep(disappearfirst)
	var/disappearsecond = (rand(10, 30) * abs(offset))	
	animate(I, pixel_y = (I.pixel_y - offset), time = disappearsecond)
	sleep(disappearsecond)
	owner.current.client?.images -= I
	qdel(I)

/datum/antagonist/dreamer/proc/handle_dreamer_wall(turf/closed/wall/W)
	if(!W || !owner.current.client)
		return
	var/image/I = image('modular_skyrat/icons/effects/shit_and_piss.dmi', W, "splat[rand(1,8)]", W.layer+0.1)
	owner.current.client?.images += I
	var/offset = pick(-1, 1, 2)
	var/disappearfirst = rand(20, 40)
	animate(I, pixel_y = (I.pixel_y + offset), time = disappearfirst)
	sleep(disappearfirst)
	var/disappearsecond = rand(20, 40)	
	animate(I, pixel_y = (I.pixel_y - offset), time = disappearsecond)
	sleep(disappearsecond)
	owner.current.client?.images -= I
	qdel(I)

/datum/antagonist/dreamer/proc/handle_dreamer_screenshake()
	if(!owner.current.client)
		return
	var/client/C = owner.current.client
	var/shakeit = 0
	while(shakeit < 10)
		shakeit++
		var/intensity = 1 //i tried rand(1,2) but even that was 2 intense
		animate(C, pixel_y = (C.pixel_y + intensity), time = intensity)
		sleep(intensity)
		animate(C, pixel_y = (C.pixel_y - intensity), time = intensity)
		sleep(intensity)

/datum/antagonist/dreamer/proc/handle_dreamer_mob_hallucination()
	if(!owner.current.client)
		return
	var/mob_msg = pick("It's mom!", "I have to HURRY UP!", "They are CLOSE!","They are NEAR!")
	var/turf/turfie
	var/list/turf/turfies = list()
	for(var/turf/torf in view(owner.current))
		turfies += torf
	if(length(turfies))
		turfie = pick(turfies)
	if(!turfie)
		return
	var/hall_type = pick("mom", "M3", "deepone")
	if(mob_msg == "It's mom!")
		hall_type = "mom"
	var/image/I = image('modular_skyrat/code/modules/antagonists/dreamer/icons/dreamer_mobs.dmi', turfie, hall_type, FLOAT_LAYER, get_dir(turfie, owner.current))
	I.plane = FLOAT_PLANE
	owner.current.client?.images += I
	to_chat(owner.current, "<span class='danger'><span class='big bold'>[mob_msg]</span></span>")
	sleep(5)
	var/hallsound = pick(
						'modular_skyrat/code/modules/antagonists/dreamer/sound/hall_attack1.ogg',
						'modular_skyrat/code/modules/antagonists/dreamer/sound/hall_attack2.ogg',
						'modular_skyrat/code/modules/antagonists/dreamer/sound/hall_attack3.ogg',
						'modular_skyrat/code/modules/antagonists/dreamer/sound/hall_attack4.ogg',
						)
	owner.current.playsound_local(get_turf(owner.current), hallsound, 100, 0)
	var/chase_tiles = 7
	var/chase_wait_per_tile = rand(4,6)
	var/caught_dreamer = FALSE
	while(chase_tiles > 0)
		turfie = get_step(turfie, get_dir(turfie, owner.current))
		if(turfie)
			owner.current.client?.images -= I
			qdel(I)
			I = image('modular_skyrat/code/modules/antagonists/dreamer/icons/dreamer_mobs.dmi', turfie, hall_type, FLOAT_LAYER, get_dir(turfie, owner.current))
			I.plane = FLOAT_PLANE
			owner.current.client?.images += I
			if(turfie == get_turf(owner.current))
				caught_dreamer = TRUE
				sleep(chase_wait_per_tile)
				break
		chase_tiles--
		sleep(chase_wait_per_tile)
	owner.current.client?.images -= I
	if(!QDELETED(I))
		qdel(I)
	if(caught_dreamer)
		owner.current.Paralyze(rand(2, 5) SECONDS)
		var/pain_msg = pick("NO!", "THEY GOT ME!", "AGH!")
		to_chat(owner.current, "<span class='userdanger'>[pain_msg]</span>")
		owner.current.flash_pain(255, 0, 5, 10)

/datum/antagonist/dreamer/proc/handle_dreamer_waking_up()
	if(!owner.current.client)
		return
	var/list/turf/open/floor/floorlist = list()
	for(var/turf/open/floor/F in view(owner.current))
		if(prob(15))
			floorlist += F
	for(var/F in floorlist)
		spawn(0)
			handle_waking_up_floor(F)

/datum/antagonist/dreamer/proc/handle_waking_up_floor(turf/open/floor/T)
	if(!T)
		return
	var/image/I = image('icons/turf/floors.dmi', T, pick("rcircuitanim", "gcircuitanim"), T.layer+0.1, T.dir)
	owner.current.client?.images += I
	var/offset = pick(-1, 1)
	var/disappearfirst = 30
	animate(I, pixel_y = (I.pixel_y + offset), time = disappearfirst)
	sleep(disappearfirst)
	var/disappearsecond = 30
	animate(I, pixel_y = (I.pixel_y - offset), time = disappearsecond)
	sleep(disappearsecond)
	owner.current.client?.images -= I
	qdel(I)

/mob/living/simple_animal/pet/chungus
	icon = 'modular_skyrat/icons/mob/chungus.dmi'
	icon_state = "chungus"
	name = "\proper Big Chungus"
	desc = "The beast itself."
	speak = list("Thanks for the gold, kind stranger!",
				"I am a cuck, AMA!",
				"Keanu Reeves!",
				"Wholesome 100!",
				"I hate fortnite!",
				"Pewdiepie plays minecraft!",
				"Big big chungus!",
				)
	var/chungus_music = 'modular_skyrat/sound/chungus/bigchungus.ogg'

/mob/living/simple_animal/pet/chungus/BiologicalLife(seconds, times_fired)
	. = ..()
	//1% chance to play big chungus.ogg every 2 seconds
	if(chungus_music && prob(1))
		playsound(src, chungus_music, rand(50,100), 0)

/mob/living/simple_animal/pet/chungus/xom
	name = "xom"
	desc = "This otherwordly creature keeps spouting senseless crap. Maybe you're just not wise enough to comprehend."
	icon_state = "xom"
	chungus_music = null
	var/icon_state_cool = "cooler_xom"
	var/static/list/funny = list(
		'modular_skyrat/sound/cultiste/cultiste_rire_1.ogg',
		'modular_skyrat/sound/cultiste/cultiste_rire_2.ogg',
		'modular_skyrat/sound/cultiste/cultiste_rire_3.ogg',
		'modular_skyrat/sound/cultiste/cultiste_rire_4.ogg',
		'modular_skyrat/sound/cultiste/cultiste_rire_5.ogg',
		'modular_skyrat/sound/cultiste/cultiste_rire_6.ogg',
	)

/mob/living/simple_animal/pet/chungus/xom/handle_automated_speech(override)
	set waitfor = FALSE
	if(prob(speak_chance) || override)
		//xom just says random shit someone has spouted in the round with a chance
		//to say a cringe word at the end (or nigger)
		var/list/cringe = list("nigger")
		cringe |= GLOB.in_character_filter
		var/message = "Penis guacamole"
		var/list/possible_messages = list()
		for(var/mob/living/L in GLOB.mob_living_list)
			var/log_source = L.logging
			for(var/log_type in log_source)//this whole loop puts the read-ee's say logs into say_log in an easy to access way
				var/nlog_type = text2num(log_type)
				if(nlog_type & LOG_SAY)
					var/list/reversed = log_source[log_type]
					if(islist(reversed))
						possible_messages |= reverseRange(reversed.Copy())
						break
		if(length(possible_messages))
			message = pick(possible_messages)
		if(config.punctuation_filter && !findtext(message, config.punctuation_filter, length(message)) && !findtext(message, config.punctuation_filter, 1, 2))
			message += "."
		say("[message] [capitalize(pick(cringe))]!")
		//do the funny laugh
		playsound(src, pick(funny), 65, 0)
		//give xom glasses for 2.5 seconds after shitposting
		icon_state = icon_state_cool
		addtimer(CALLBACK(src, .proc/not_cool), 2.5 SECONDS)

/mob/living/simple_animal/pet/chungus/xom/proc/not_cool()
	icon_state = initial(icon_state)

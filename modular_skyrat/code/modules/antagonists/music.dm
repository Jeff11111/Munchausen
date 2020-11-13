//Antag music
/datum/antagonist
	var/music_file

/datum/antagonist/on_gain()
	. = ..()
	if(owner && music_file)
		owner.combat_music = music_file

/datum/antagonist/dreamer/New()
	. = ..()
	music_file = pick('modular_skyrat/sound/music/hot_plates.ogg',
					'modular_skyrat/sound/music/converter.ogg',
					)

/datum/antagonist/traitor/New()
	. = ..()
	music_file = pick(
				'modular_skyrat/sound/music/stress.ogg',
				'modular_skyrat/sound/music/hydrogen.ogg',
				'modular_skyrat/sound/music/army.ogg',
				'modular_skyrat/sound/music/divide.ogg',
				'modular_skyrat/sound/music/selectedfaces.ogg',
				)

/datum/antagonist/nukeop/New()
	. = ..()
	music_file = pick(
				'modular_skyrat/sound/music/pursuit.ogg',
				'modular_skyrat/sound/music/evileye.ogg',
				'modular_skyrat/sound/music/bingus.ogg',
				)

/datum/antagonist/ert/deathsquad/New()
	. = ..()
	music_file = pick(
				'modular_skyrat/sound/music/rollermobster.ogg',
				'modular_skyrat/sound/music/deathsquads.ogg',
				)

/datum/antagonist/communist/New()
	. = ..()
	music_file = pick(
				'modular_skyrat/sound/music/blackracers.ogg',
				)

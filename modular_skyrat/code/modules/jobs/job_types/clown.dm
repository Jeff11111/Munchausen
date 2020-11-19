/datum/job/clown
	music_file = 'modular_skyrat/sound/music/yomama.ogg'

/datum/outfit/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source)
	. = ..()
	preference_source?.hover_tip?.clownify()

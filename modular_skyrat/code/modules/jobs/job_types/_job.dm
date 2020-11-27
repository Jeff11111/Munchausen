//Alt titles
/datum/job
	var/list/alt_titles = list()
	var/flatter_string = ""
	var/music_file = 'modular_skyrat/sound/music/ritual.ogg'

//Job music
/datum/job/after_spawn(mob/living/H, mob/M)
	. = ..()
	if(music_file && H.mind)
		H.mind.combat_music = music_file

//Outfit music
/datum/outfit
	var/music_file = 'modular_skyrat/sound/music/ritual.ogg'

/datum/outfit/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source)
	. = ..()
	if(music_file && H.mind)
		H.mind.combat_music = music_file

//OS13 shit
/datum/outfit/job
	uniform = /obj/item/clothing/under/color/grey/os13
	shoes = /obj/item/clothing/shoes/laceup

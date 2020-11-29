/datum/job/clown
	music_file = 'modular_skyrat/sound/music/yomama.ogg'

/datum/outfit/job/clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE, client/preference_source)
	. = ..()
	preference_source?.hover_tip?.clownify()

/datum/outfit/job/clown
	head = /obj/item/clothing/head/jester
	uniform = /obj/item/clothing/under/rank/civilian/clown/jester
	shoes = /obj/item/clothing/shoes/clown_shoes/jester

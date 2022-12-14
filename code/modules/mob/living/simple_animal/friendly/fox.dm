//Foxxy
/mob/living/simple_animal/pet/fox
	name = "fox"
	desc = "It's a fox."
	icon = 'icons/mob/pets.dmi'
	icon_state = "fox"
	icon_living = "fox"
	icon_dead = "fox_dead"
	speak = list("Ack-Ack","Ack-Ack-Ack-Ackawoooo","Geckers","Awoo","Tchoff")
	speak_emote = list("geckers", "barks")
	emote_hear = list("howls.","barks.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 3)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW
	var/held_icon = "fox"

/mob/living/simple_animal/pet/fox/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/wuv, "yaps happily!", EMOTE_AUDIBLE, /datum/mood_event/pet_animal, "screeches!", EMOTE_AUDIBLE)
	AddElement(/datum/element/mob_holder, held_icon)

//quotefox
/mob/living/simple_animal/pet/fox/Renault
	name = "Simon"
	desc = "Simon - The really really unfunny polish white fox."
	icon = 'modular_skyrat/icons/mob/simon.dmi'
	icon_state = "simon"
	icon_dead = "simon_dead"
	gender = MALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/fox/Renault/Initialize()
	. = ..()
	addtimer(CALLBACK(src, .proc/death), 1 SECONDS)

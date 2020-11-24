//floppa
/mob/living/simple_animal/pet/caracal
	name = "caracal"
	desc = "A domesticated caracal. Much cuter than a mere cat."
	icon = 'modular_skyrat/icons/mob/floppa.dmi'
	icon_state = "caracal"
	icon_dead = "caracal_dead"
	speak_chance = 5
	speak = list("Flop.", "Meow.", "HSSS")
	emote_hear = list("meows!", "hisses.", "purrs.")
	emote_see = list("shows their fangs!", "wags their tail.", "flop their ears!")
	gender = MALE
	response_help_continuous = "flops"
	response_help_simple = "flop"
	response_disarm_continuous = "bops"
	response_disarm_simple = "bop"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"

/mob/living/simple_animal/pet/caracal/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/mob_holder)

/mob/living/simple_animal/pet/caracal/floppa
	name = "big floppa"
	desc = "Flops for no hoe."

/mob/living/simple_animal/pet/caracal/floppa/stanislav
	name = "\proper Stanislav"
	desc = "A war veteran caracal, always carrying it's trust rifle. He has seen terrible things."
	speak = list("I have committed numerous war crimes.", "I must bomb them.", "The horrors of war.")
	icon_state = "stanislav"
	icon_dead = "stanislav_dead"

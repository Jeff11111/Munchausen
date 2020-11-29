/mob/living/simple_animal/pet/cat/Runtime
	name = "pet mono gp"
	desc = "BARRIL!"
	speak = list("Meowrowr!", "Mew!", "Miauen!", "BARRIL!")

/mob/living/simple_animal/pet/cat/Runtime/MouseDrop(mob/over)
	. = ..()
	over.Topic()

/mob/living/simple_animal/pet/cat/Runtime/Topic(href, href_list)
	. = ..()
	var/githubissues = "[CONFIG_GET(string/githuburl)]"
	usr << link(githubissues)

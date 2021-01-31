/datum/mood_event/hug
	description = "<span class='nicegreen'>Hugs are nice.</span>"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/arcade
	description = "<span class='nicegreen'>I beat the arcade game!</span>"
	mood_change = 3
	timeout = 3000

/datum/mood_event/blessing
	description = "<span class='nicegreen'>I've been blessed.</span>"
	mood_change = 3
	timeout = 3000

/datum/mood_event/book_nerd
	description = "<span class='nicegreen'>I have recently read a book.</span>"
	mood_change = 3
	timeout = 3000

/datum/mood_event/exercise
	description = "<span class='nicegreen'>Working out releases those endorphins!</span>"
	mood_change = 3
	timeout = 3000

/datum/mood_event/pet_animal
	description = "<span class='nicegreen'>Animals are adorable! I can't stop petting them!</span>"
	mood_change = 2
	timeout = 5 MINUTES

/datum/mood_event/pet_animal/add_effects(mob/animal)
	description = "<span class='nicegreen'>\The [animal.name] is adorable! I can't stop petting [animal.p_them()]!</span>"

/datum/mood_event/honk
	description = "<span class='nicegreen'>Maybe clowns aren't so bad after all. Honk!</span>"
	mood_change = 2
	timeout = 2400

/datum/mood_event/bshonk
	description = "<span class='nicegreen'>Quantum mechanics can be fun and silly, too! Honk!</span>"
	mood_change = 6
	timeout = 4800

/datum/mood_event/perform_cpr
	description = "<span class='nicegreen'>It feels good to save a life.</span>"
	mood_change = 6
	timeout = 3000

/datum/mood_event/oblivious
	description = "<span class='nicegreen'>What a lovely day.</span>"
	mood_change = 3

/datum/mood_event/jolly
	description = "<span class='nicegreen'>I feel happy for no particular reason.</span>"
	mood_change = 6
	timeout = 2 MINUTES

/datum/mood_event/focused
	description = "<span class='nicegreen'>I have a goal, and I will reach it, whatever it takes!</span>" //Used for syndies, nukeops etc so they can focus on their goals
	mood_change = 2
	hidden = TRUE

/datum/mood_event/revolution
	description = "<span class='nicegreen'>VIVA LA REVOLUTION!</span>"
	mood_change = 2
	hidden = TRUE

/datum/mood_event/cult
	description = "<span class='nicegreen'>I have seen the truth, praise the almighty one!</span>"
	mood_change = 40 //maybe being a cultist isnt that bad after all
	hidden = TRUE

/datum/mood_event/family_heirloom
	description = "<span class='nicegreen'>My family heirloom is safe with me.</span>"
	mood_change = 1

/datum/mood_event/goodmusic
	description = "<span class='nicegreen'>There is something soothing about this music.</span>"
	mood_change = 3
	timeout = 600

/datum/mood_event/chemical_euphoria
	description = "<span class='nicegreen'>Heh...hehehe...hehe...</span>"
	mood_change = 4

/datum/mood_event/chemical_laughter
	description = "<span class='nicegreen'>Laughter really is the best medicine! Or is it?</span>"
	mood_change = 4
	timeout = 3 MINUTES

/datum/mood_event/chemical_superlaughter
	description = "<span class='nicegreen'>*WHEEZE*</span>"
	mood_change = 12
	timeout = 3 MINUTES

/datum/mood_event/betterhug
	description = "<span class='nicegreen'>Someone was very nice to me.</span>"
	mood_change = 3
	timeout = 3000

/datum/mood_event/betterhug/add_effects(mob/friend)
	description = "<span class='nicegreen'>[friend.name] was very nice to me.</span>"

/datum/mood_event/besthug
	description = "<span class='nicegreen'>Someone is great to be around, they make me feel so happy!</span>"
	mood_change = 5
	timeout = 3000

/datum/mood_event/besthug/add_effects(mob/friend)
	description = "<span class='nicegreen'>[friend.name] is great to be around, [friend.p_they()] makes me feel so happy!</span>"

/datum/mood_event/happy_empath
	description = "<span class='warning'>Someone seems happy!</span>"
	mood_change = 3
	timeout = 600

/datum/mood_event/happy_empath/add_effects(var/mob/happytarget)
	description = "<span class='nicegreen'>[happytarget.name]'s happiness is infectious!</span>"

/datum/mood_event/headpat
	description = "<span class='nicegreen'>Headpats are nice.</span>"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/hugbox
	description = "<span class='nicegreen'>I hugged a box of hugs recently.</span>"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/plushpet
	description = "<span class='nicegreen'>I pet a plush recently.</span>"
	mood_change = 1
	timeout = 3000

/datum/mood_event/plushplay
	description = "<span class='nicegreen'>I've played with plushes recently.</span>"
	mood_change = 3
	timeout = 3000

/datum/mood_event/breakfast
	description = "<span class='nicegreen'>Nothing like a hearty breakfast to start the shift.</span>"
	mood_change = 2
	timeout = 15 MINUTES

/datum/mood_event/nanite_happiness
	description = "<span class='nicegreen robot'>+++++++HAPPINESS ENHANCEMENT+++++++</span>"
	mood_change = 7

/datum/mood_event/nanite_happiness/add_effects(message)
	description = "<span class='nicegreen robot'>+++++++[message]+++++++</span>"

/datum/mood_event/area
	description = "" //Fill this out in the area
	mood_change = 0
//Power gamer stuff below
/datum/mood_event/drankblood
	description = "<span class='nicegreen'>I have fed greedly from that which nourishes me.</span>"
	mood_change = 10
	timeout = 900

/datum/mood_event/coffinsleep
	description = "<span class='nicegreen'>I slept in a coffin during the day. I feel whole again.</span>"
	mood_change = 8
	timeout = 1200

//Cursed stuff
/datum/mood_event/orgasm
	description = "<span class='userlove'>I came!</span>"
	mood_change = 4
	timeout = 10 MINUTES

/datum/mood_event/hope_lavaland
	description = "<span class='nicegreen'>What a peculiar emblem.  It makes me feel hopeful for my future.</span>"
	mood_change = 5

/datum/mood_event/artok
	description = "<span class='nicegreen'>It's nice to see people are making art around here.</span>"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/artgood
	description = "<span class='nicegreen'>What a thought-provoking piece of art. I'll remember that for a while.</span>"
	mood_change = 3
	timeout = 3 MINUTES

/datum/mood_event/artgreat
	description = "<span class='nicegreen'>That work of art was so great it made me believe in the goodness of humanity. Says a lot in a place like this.</span>"
	mood_change = 4
	timeout = 4 MINUTES

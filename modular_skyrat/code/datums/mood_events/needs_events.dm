//Hydration
/datum/mood_event/wellhydrated
	description = "<span class='nicegreen'>I'm gonna burst!</span>"
	mood_change = 4

/datum/mood_event/hydrated
	description = "<span class='nicegreen'>I have recently had some water.</span>"
	mood_change = 2

/datum/mood_event/thirsty
	description = "<span class='warning'>I'm getting a bit thirsty.</span>"
	mood_change = -4

/datum/mood_event/dehydrated
	description = "<span class='boldwarning'>I'm dehydrated!</span>"
	mood_change = -10

//Urination
/datum/mood_event/piss_on_sink
	description = "<span class='nicegreen'>I pissed on the sink. I pity the janitor...</span>"
	mood_change = 3
	timeout = 5 MINUTES

/datum/mood_event/piss
	description = "<span class='warning'>I need to pee.</span>"
	mood_change = -4

/datum/mood_event/verypiss
	description = "<span class='boldwarning'>My bladder is going to explode!</span>"
	mood_change = -8

/datum/mood_event/pissed_self
	description = "<span class='boldwarning'>I have pissed my pants. This day is ruined.</span>"
	mood_change = -8
	timeout = 10 MINUTES

//Defecation
/datum/mood_event/shit_on_sock
	description = "<span class='nicegreen'>I made a poop sock!</span>"
	mood_change = 4
	timeout = 5 MINUTES

/datum/mood_event/shit
	description = "<span class='warning'>I need to poop.</span>"
	mood_change = -5

/datum/mood_event/veryshit
	description = "<span class='boldwarning'>My anus is <b>BLEEDING</b>!</span>"
	mood_change = -8

/datum/mood_event/shat_self
	description = "<span class='boldwarning'>I have shat my pants. This day is ruined.</span>"
	mood_change = -8
	timeout = 10 MINUTES

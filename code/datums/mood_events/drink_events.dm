/datum/mood_event/drunk
	mood_change = 3
	description = "<span class='nicegreen'>Everything just feels better after a drink or two.</span>"
	timeout = 3000

/datum/mood_event/quality_nice
	description = "<span class='nicegreen'>That drink wasn't bad at all.</span>"
	mood_change = 1
	timeout = 2 MINUTES

/datum/mood_event/quality_good
	description = "<span class='nicegreen'>That drink was pretty good.</span>"
	mood_change = 2
	timeout = 2 MINUTES

/datum/mood_event/quality_verygood
	description = "<span class='nicegreen'>That drink was great!</span>"
	mood_change = 3
	timeout = 2 MINUTES

/datum/mood_event/quality_fantastic
	description = "<span class='nicegreen'>That drink was amazing!</span>"
	mood_change = 4
	timeout = 2 MINUTES

/datum/mood_event/race_drink
	description = "<span class='nicegreen'>That drink was made for me!</span>"
	mood_change = 6
	timeout = 5 MINUTES

/datum/mood_event/amazingtaste
	description = "<span class='nicegreen'>Amazing taste!</span>"
	mood_change = 50 //Is this not really high..?
	timeout = 10 MINUTES

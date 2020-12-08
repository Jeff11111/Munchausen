//Mom get the epipen quirk
/datum/mood_event/allergyshock
	description = "<span class='userdanger'>WHERE IS THE EPI PEN?!?!</span>"
	mood_change = -25
	timeout = 10 SECONDS

//Masochist mood
/datum/mood_event/paingood
	description = "<span class='nicegreen'>Pain cleanses the mind and the soul.</span>"
	mood_change = 4
	timeout = 2 MINUTES

//I love sex
/datum/mood_event/orgasm/nympho
	description = "<span class='userlove'>I LOVE SEX!</span>"
	mood_change = 8
	timeout = 10 MINUTES

//I need sex
/datum/mood_event/blueballs
	description = "<span class='userdanger'><i>I NEED SEX!</i></span>"
	mood_change = -4
	timeout = 10 MINUTES

//I *need* sex
/datum/mood_event/blueballs/bad
	description = "<span class='userdanger'><b>I NEED SEX!</b></span>"
	mood_change = -8
	timeout = 15 MINUTES

//AAAAAAAAAAHHHHHHHHHH
/datum/mood_event/blueballs/cbt
	description = "<span class='userlove'><b>I WOULD KILL JUST FOR A CRUMBLE OF PUSSY!</b></span>"
	mood_change = -12
	timeout = 20 MINUTES

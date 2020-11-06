//Mom get the epipen quirk
/datum/mood_event/allergyshock
	description = "<span class='userdanger'>WHERE IS THE EPI PEN?!?!</span>\n"
	mood_change = -25
	timeout = 10 SECONDS

//Got cloned recently
/datum/mood_event/clooned
	description = "<span class='boldwarning'>Awake... but at what cost?</span>\n"
	mood_change = -8
	timeout = 15 MINUTES

//Cringe filter
/datum/mood_event/cringe
	description = "<span class='boldwarning'>I tried to say something stupid.</span>\n"
	mood_change = -5
	timeout = 5 MINUTES

/datum/mood_event/ultracringe
	description = "<span class='boldwarning'>I am fucking retarded!</span>\n"
	mood_change = -10
	timeout = 10 MINUTES

//Pain mood
/datum/mood_event/painbad
	description = "<span class='danger'>I am feeling so much pain!</span>\n"
	mood_change = -6
	timeout = 2 MINUTES

//Got injured recently
/datum/mood_event/injured
	description = "<span class='danger'>I have gotten myself badly wounded recently.</span>\n"
	mood_change = -2
	timeout = 10 MINUTES

//Saw an injured crewmember
/datum/mood_event/saw_injured
	description = "<span class='danger'>I have seen someone being severely wounded.</span>\n"
	mood_change = -2
	timeout = 5 MINUTES

/datum/mood_event/saw_injured/lesser
	mood_change = -1
	timeout = 5 MINUTES

//Saw a crewmember die
/datum/mood_event/saw_dead
	description = "<span class='deadsay'>I have seen someone die!</span>\n"
	mood_change = -6
	timeout = 10 MINUTES

/datum/mood_event/saw_dead/lesser
	mood_change = -4
	timeout = 5 MINUTES

//Died
/datum/mood_event/died
	description = "<span class='deadsay'><b>I saw the afterlife, and i don't like it!</b></span>\n"
	mood_change = -8
	timeout = 10 MINUTES

//Hydration
/datum/mood_event/thirsty
	description = "<span class='warning'>I'm getting a bit thirsty.</span>\n"
	mood_change = -5

/datum/mood_event/dehydrated
	description = "<span class='boldwarning'>I'm dehydrated!</span>\n"
	mood_change = -10

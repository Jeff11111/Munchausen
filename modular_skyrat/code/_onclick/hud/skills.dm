//Le skill buttone
/obj/screen/skills
	name = "check skills"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "skills"

/obj/screen/skills/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(!usr.mind)
		to_chat(usr, "<span class='warning'>How do you check the skills of [(usr == src)? "yourself when you are" : "something"] without a mind?</span>")
		return
	
	var/msg = "<span class='info'>Let's check my trained capabilities...</span><br>"
	for(var/s in usr.mind.mob_skills)
		var/datum/skills/skill = usr.mind.mob_skills[s]
		//if we suck just ignore the skill entirely
		//when the screen button is added, to check garbage skills it'll be rmb.
		if((skill.level > 1) || modifiers["middle"])
			msg += "<span class='info'>- I am <b>[skill.skillnumtodesc(skill.level)] ([skill.level])</b> at <b>[lowertext(skill.name)]</b>.</span><br>"
	
	msg += "<br>"

	msg += "<span class='info'>Let's check my physical capabilities...</span><br>"
	for(var/s in usr.mind.mob_stats)
		var/datum/stats/stat = usr.mind.mob_stats[s]
		//Ignore the fakes
		if(stat.fake_type)
			continue
		msg += "<span class='info'>- I have <b>[stat.statnumtodesc(stat.level)] ([stat.level])</b> <b>[lowertext(stat.name)] ([stat.shorthand])</b>.</span><br>"
	
	to_chat(usr, msg)

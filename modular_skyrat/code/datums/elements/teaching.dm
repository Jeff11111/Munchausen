//Element for mobs that are INTJs and can teach other non-mindless mobs how to be swagger
/datum/element/teaching
	var/list/active_teachers = list()
	var/list/active_students = list()

/datum/element/teaching/Attach(datum/target)
	. = ..()
	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ELEMENT_TRY_TEACHING, .proc/invoke_try_teaching)
	RegisterSignal(target, COMSIG_ELEMENT_CHECK_TEACHING, .proc/check_teaching)
	RegisterSignal(target, COMSIG_ELEMENT_CHECK_TAUGHT, .proc/check_being_taught)

/datum/element/teaching/proc/check_teaching(mob/living/source)
	if(source in active_teachers)
		return TRUE
	return FALSE

/datum/element/teaching/proc/check_being_taught(mob/living/source)
	if(source in active_students)
		return TRUE
	return FALSE

/datum/element/teaching/proc/invoke_try_teaching(mob/living/source)
	//sleeping on signal handlers is bad, do NOT do that.
	INVOKE_ASYNC(src, .proc/try_teaching, source)

/datum/element/teaching/proc/try_teaching(mob/living/source)
	if(!source.mind || !source.client) //Not sapient
		to_chat(source, "<span class='warning'>I lack a mind or puppeteer.</span>")
		return
	if(check_teaching(source)) //Can't perform multi-task teaching
		to_chat(source, "<span class='warning'>I am already teaching someone.</span>")
		return
	if(check_being_taught(source)) //Can't perform multi-task learning
		to_chat(source, "<span class='warning'>I am already being taught.</span>")
		return
	if(HAS_TRAIT(source, TRAIT_MUTE)) //Mute people are bad teachers
		to_chat(source, "<span class='warning'>I cannot teach anyone without a voice.</span>")
		return
	if(HAS_TRAIT(source, TRAIT_UNINTELLIGIBLE_SPEECH)) //Stuttersluts are bad teachers
		to_chat(source, "<span class='warning'>I cannot teach anyone with senseless rambling.</span>")
		return
	if(source.getBrainLoss() >= 50) //Retards can't teach
		to_chat(source, "<span class='danger'>Uhhhh...???</span>")
		return
	var/list/mob/living/students = list()
	for(var/mob/living/carbon/C in fov_viewers(1, source)) //We use view() because blind people are bad teachers
		if(C.mind && C.client && (source != C))
			students["[C.name]"] = C
	if(!length(students))
		to_chat(source, "<span class='warning'>There are no suitable students around me.</span>")
		return
	var/potential_student = input(source, "Who should i teach to?", "Master of puppets") as anything in students
	if(!potential_student)
		to_chat(source, "<span class='warning'>Nevermind.</span>")
		return
	var/mob/living/carbon/puppet = students[potential_student]
	if(!puppet || QDELETED(puppet) || !source.canUseTopic(puppet, TRUE, FALSE, TRUE))
		to_chat(source, "<span class='warning'>They are out of my reach.</span>")
		return
	var/list/potential_skills = list()
	for(var/fuck in subtypesof(/datum/skills))
		var/datum/skills/shitter = fuck
		potential_skills[initial(shitter.name)] = fuck
	var/skill_string = input(source, "What should i teach?", "Master of puppets") as anything in potential_skills
	if(!skill_string || !potential_skills[skill_string])
		to_chat(source, "<span class='warning'>Nevermind.</span>")
		return
	var/potential_skill = potential_skills[skill_string]
	if(!puppet || QDELETED(puppet) || !source.canUseTopic(puppet, TRUE, FALSE, TRUE))
		to_chat(source, "<span class='warning'>They are out of my reach.</span>")
		return
	var/puppet_IQ = GET_STAT_LEVEL(puppet, int)
	var/master_IQ = GET_STAT_LEVEL(source, int)
	var/master_skill = source.mind.mob_skills[potential_skill].level
	var/timeperteach = CEILING(20 SECONDS * max(0.1, 1 - puppet_IQ/MAX_STAT), 1 SECONDS) //stupidity of the student affects how quickly they learn
	var/maximum_teachernus = min(20, FLOOR(master_skill * (0.8 * master_IQ/MAX_STAT), 1)) //stupidity of the teacher affects how much the student can learn out of their full skill bingus
	if(master_IQ <= JOB_STATPOINTS_NOVICE)
		to_chat(source, "<span class='warning'>Me are too dumb to teach.</span>")
		return
	if(puppet_IQ <= JOB_STATPOINTS_NOVICE)
		to_chat(source, "<span class='warning'>I'd need a degree in special education to teach this imbecile.</span>")
		return
	if(check_being_taught(puppet)) //Can't perform multi-task teaching
		to_chat(source, "<span class='warning'><b>[puppet.name]</b> is already being taught.</span>")
		return
	//We do a little teaching
	active_teachers |= source
	active_students |= puppet
	source?.hud_used?.teach?.update_icon()
	puppet?.hud_used?.teach?.update_icon()
	source.visible_message("<b>[source.name]</b> starts teaching <b>[puppet.name]</b> about <i>[skill_string]</i>.", \
						"<span class='notice'>I start teaching <b>[puppet.name]</b> about <i>[skill_string]</i>.")
	while(do_mob(source, puppet, timeperteach))
		if(puppet.mind.mob_skills[potential_skill].level >= maximum_teachernus)
			to_chat(source, "<span class='notice'>I've taught <b>[puppet.name]</b> all that i could.</span>")
			break
		puppet.mind.mob_skills[potential_skill].level += 1
		to_chat(source, "<span class='notice'>I do a little teaching.</span>")
		to_chat(puppet, "<span class='notice'>I do a little learning.</span>")
	source.visible_message("<b>[source.name]</b> stops teaching <b>[puppet.name]</b>.",
							"<span class='notice'>I stop teaching <b>[puppet.name]</b></span>",
							target = puppet,
							target_message = "<span class='notice'><b>[source.name]</b> stops teaching me.</span>")
	active_teachers -= source
	active_students -= puppet
	source?.hud_used?.teach?.update_icon()
	puppet?.hud_used?.teach?.update_icon()

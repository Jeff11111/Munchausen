/datum/element/multitool_emaggable

/datum/element/multitool_emaggable/Attach(datum/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_CLICK_MIDDLE, .proc/try_hacking)

/datum/element/multitool_emaggable/Detach(datum/source, force)
	. = ..()
	UnregisterSignal(source, COMSIG_CLICK_MIDDLE)

/datum/element/multitool_emaggable/proc/try_hacking(atom/source, mob/user)
	if(!isliving(user) || !user.canUseTopic(source))
		return FALSE
	var/mob/living/livingUser = user
	var/obj/item/userActiveItem = livingUser.get_active_held_item()
	if(!userActiveItem)
		return FALSE
	if(!(userActiveItem.tool_behaviour == TOOL_MULTITOOL))
		return FALSE
	if(!livingUser.mind)
		return FALSE
	var/datum/skills/electronics/electronics = GET_SKILL(livingUser, electronics)
	var/electronic_level = electronics.level
	if(electronic_level < JOB_SKILLPOINTS_EXPERT)
		to_chat(livingUser, "<span class='warning'>I am incapable of doing this.</span>")
		return
	source.audible_message("<span class='warning'>[source] starts to beep sporadically!</span>")
	to_chat(livingUser, "<span class='warning'>I start to hack [source].</span>")
	if(!do_after(livingUser, 5 SECONDS, target = source))
		to_chat(livingUser, "<span class='warning'>I failed to hack [source] open!</span>")
		return
	if(user.mind.diceroll(skills = SKILL_DATUM(electronics)) <= DICE_FAILURE)
		source.audible_message("<span class='warning'>[source] pings successfully at defending the hack attempt!</span>")
		to_chat(livingUser, "<span class='warning'>I fail to hack [source].</span>")
		return
	source.audible_message("<span class='warning'>[source] starts to beep even more frantically!</span>")
	to_chat(livingUser, "<span class='warning'>I continue to hack [source].</span>")
	if(!do_after(livingUser, 10 SECONDS, target = source))
		to_chat(livingUser, "<span class='warning'>I failed to hack [source] open!</span>")
		return
	if(user.mind.diceroll(skills = SKILL_DATUM(electronics)) <= DICE_FAILURE)
		source.audible_message("<span class='warning'>[source] pings successfully at defending the hack attempt!</span>")
		to_chat(livingUser, "<span class='warning'>I fail to hack [source].</span>")
		return
	source.audible_message("<span class='warning'>[source] beeps one last time...</span>")
	to_chat(livingUser, "<span class='warning'>Success.</span>")
	source.emag_act(user)
	return TRUE

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
	var/fail_chance = ((20 - electronic_level) * 10) + 1
	if(electronic_level < JOB_SKILLPOINTS_EXPERT)
		to_chat(livingUser, "<span class='warning'>I am incapable of doing this.</span>")
		return
	source.audible_message("<span class='warning'>[src] starts to beep sporadically!</span>")
	to_chat(livingUser, "<span class='warning'>I start to hack [src].</span>")
	if(!do_after(livingUser, 10 SECONDS, target = src))
		to_chat(livingUser, "<span class='warning'>I failed to hack [src] open!</span>")
		return
	if(prob(fail_chance))
		source.audible_message("<span class='warning'>[src] pings successfully at defending the hack attempt!</span>")
		to_chat(livingUser, "<span class='warning'>I fail to hack [src].</span>")
		return
	source.audible_message("<span class='warning'>[src] starts to beep even more frantically!</span>")
	to_chat(livingUser, "<span class='warning'>I continue to hack [src].</span>")
	if(!do_after(livingUser, 10 SECONDS, target = src))
		to_chat(livingUser, "<span class='warning'>I failed to hack [src] open!</span>")
		return
	if(prob(fail_chance))
		source.audible_message("<span class='warning'>[src] pings successfully at defending the hack attempt!</span>")
		to_chat(livingUser, "<span class='warning'>I fail to hack [src].</span>")
		return
	source.audible_message("<span class='warning'>[src] beeps one last time...</span>")
	to_chat(livingUser, "<span class='warning'>Success.</span>")
	source.emag_act(user)
	return TRUE

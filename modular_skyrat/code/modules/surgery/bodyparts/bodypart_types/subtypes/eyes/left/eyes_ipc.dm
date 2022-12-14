/obj/item/bodypart/left_eye/robot_ipc
	name = "robotic left eye"
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "eye-c"
	desc = "A very basic set of optical sensors with no extra vision modes or functions."
	status = BODYPART_ROBOTIC

/obj/item/bodypart/left_eye/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	to_chat(owner, "<span class='warning'>Static obfuscates your vision!</span>")
	owner.flash_act(visual = 1)
	if(severity == EMP_HEAVY)
		receive_damage(brute=20)

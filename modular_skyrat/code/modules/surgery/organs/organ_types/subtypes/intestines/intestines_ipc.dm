/obj/item/organ/intestines/robot_ipc
	name = "ipc intestines"
	icon_state = "intestines-c"
	desc = "Even IPCs deserve a throne."
	status = ORGAN_ROBOTIC

/obj/item/organ/intestines/robot_ipc/emp_act(severity)
	applyOrganDamage(severity * 10)

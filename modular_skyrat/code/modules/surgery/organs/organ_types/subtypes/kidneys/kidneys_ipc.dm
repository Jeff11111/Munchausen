/obj/item/organ/kidneys/robot_ipc
	name = "ipc kidneys"
	desc = "When you have balls of steel, you need kidneys of titanium."
	icon_state = "kidneys-c"
	status = ORGAN_ROBOTIC

/obj/item/organ/kidneys/robot_ipc/emp_act(severity)
	applyOrganDamage(severity * 10)

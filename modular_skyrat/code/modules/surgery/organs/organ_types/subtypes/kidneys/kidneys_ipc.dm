/obj/item/organ/kidneys/robot_ipc
	name = "ipc kidneys"
	desc = "When you have balls of steel, you need kidneys of titanium."
	icon_state = "kidneys-c"
	status = ORGAN_ROBOTIC

/obj/item/organ/kidneys/robot_ipc/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			applyOrganDamage(maxHealth*0.75)
		if(2)
			applyOrganDamage(0.35 * maxHealth)

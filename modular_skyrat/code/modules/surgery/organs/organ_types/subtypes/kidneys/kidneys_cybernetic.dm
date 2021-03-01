/obj/item/organ/kidneys/cybernetic
	name = "cybernetic kidneys"
	icon_state = "kidneys-c"
	desc = "Urine trouble."
	status = ORGAN_ROBOTIC

/obj/item/organ/kidneys/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			applyOrganDamage(maxHealth*0.75)
		if(2)
			applyOrganDamage(0.35 * maxHealth)

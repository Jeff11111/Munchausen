/obj/item/organ/liver/robot_ipc
	name = "ipc liver"
	desc = "An electronic device that processes the beneficial chemicals for the synthetic user."
	status = ORGAN_ROBOTIC
	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "liver-c"
	filterToxins = FALSE //We dont filter them, we're immune ot them

/obj/item/organ/liver/robot_ipc/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	switch(severity)
		if(1)
			applyOrganDamage(maxHealth*0.75)
		if(2)
			applyOrganDamage(0.35 * maxHealth)

//shitty cit liver
/obj/item/organ/liver/ipc
	name = "reagent processing liver"
	icon_state = "liver-c"

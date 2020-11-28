
/proc/spread_germs_to_bodypart(obj/item/bodypart/BP, mob/living/carbon/human/user, obj/item/tool)
	if(!istype(user) || !istype(BP) || BP.is_robotic_limb())
		return

	//Germs from the surgeon
	var/our_germ_level = user.germ_level
	if(user.gloves)
		our_germ_level = user.gloves.germ_level
	
	//Germs from the tool
	if(tool && (tool.germ_level >= our_germ_level))
		our_germ_level += tool.germ_level
	
	//Germs from the dirtiness on the surgery room
	for(var/turf/open/floor/floor in view(2, get_turf(BP.owner)))
		our_germ_level += floor.dirtiness
	
	//Germs from the wounds on the bodypart
	for(var/datum/wound/W in BP.wounds)
		our_germ_level += W.germ_level
	
	//Germs from organs inside the bodypart
	for(var/obj/item/organ/O in BP.get_organs())
		if(O.germ_level)
			our_germ_level += O.germ_level
	
	//Divide it by 10 to be reasonable
	our_germ_level = CEILING(our_germ_level/10, 1)

	//If the patient has antibiotics, kill germs by an amount equal to 10x the antibiotic force
	//e.g. nalixidic acid has 35 force, thus would decrease germs here by 350
	var/antibiotics = BP.owner.get_antibiotics()
	our_germ_level = max(0, our_germ_level - antibiotics)

	//Germ level is increased/decreased depending on a diceroll
	if(user.mind)
		var/diceroll = user.mind.diceroll(STAT_DATUM(int), SKILL_DATUM(surgery), "6d6")
		switch(diceroll)
			if(DICE_CRIT_SUCCESS)
				our_germ_level *= 0
			if(DICE_SUCCESS)
				our_germ_level *= 0.5
			if(DICE_FAILURE)
				our_germ_level *= 1
			if(DICE_CRIT_FAILURE)
				our_germ_level *= 2

	if(our_germ_level <= (WOUND_SANITIZATION_STERILIZER/2))
		return

	//If we still have germs, let's get that W
	//First, nfect the wounds on the bodypart
	for(var/datum/wound/W in BP.wounds)
		if(W.germ_level < INFECTION_LEVEL_TWO)
			W.germ_level += our_germ_level
	
	//Infect the organs on the bodypart
	for(var/obj/item/organ/O in BP.get_organs())
		if(O.germ_level < INFECTION_LEVEL_TWO)
			O.germ_level += our_germ_level

	//Infect the bodypart
	if(BP.germ_level < INFECTION_LEVEL_TWO)
		BP.germ_level += our_germ_level

/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_APPENDIX
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	maxHealth = 0.45 * STANDARD_ORGAN_THRESHOLD
	high_threshold = 0.3 * STANDARD_ORGAN_THRESHOLD
	low_threshold = 0.2 * STANDARD_ORGAN_THRESHOLD
	relative_size = 20 //Makes sense if you consider how the groin only has the intestines, appendix and maybe some mutant organs and genetools

	now_failing = "<span class='warning'>An explosion of pain erupts in your lower right abdomen!</span>"
	now_fixed = "<span class='info'>The pain in your abdomen has subsided.</span>"

	var/inflamed = FALSE

/obj/item/organ/appendix/on_life()
	. = ..()
	if(. || !owner)
		return
	owner.adjustToxLoss(4, TRUE, TRUE)	//forced to ensure people don't use it to gain tox as slime person

/obj/item/organ/appendix/update_icon_state()
	..()
	if(inflamed)
		name = "inflamed appendix"
		icon_state = "appendix-inflamed"
	else
		icon_state = "appendix"
		name = "appendix"

/obj/item/organ/appendix/Remove(special = FALSE)
	if(owner)
		for(var/datum/disease/appendicitis/A in owner.diseases)
			A.cure()
			inflamed = TRUE
	update_icon()
	..()

/obj/item/organ/appendix/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	..()
	if(inflamed)
		M.ForceContractDisease(new /datum/disease/appendicitis(), FALSE, TRUE)

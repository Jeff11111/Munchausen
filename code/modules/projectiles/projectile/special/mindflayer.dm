/obj/item/projectile/beam/mindflayer
	name = "flayer ray"
	wound_bonus = CANT_WOUND

/obj/item/projectile/beam/mindflayer/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		M.adjustBrainLoss(20)
		M.hallucination += 30

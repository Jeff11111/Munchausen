//Mostly garbage related to the ending "cutscene"
/obj/item/clothing/head/cyberdeck
	name = "cyberdeck headset"
	desc = "Sweet dreams..."
	icon = 'modular_skyrat/code/modules/antagonists/dreamer/icons/cyberdeck/cyberdeck.dmi'
	mob_overlay_icon = 'modular_skyrat/code/modules/antagonists/dreamer/icons/cyberdeck/cyberdeck_mob.dmi'
	icon_state = "cyberdeck"
	mutantrace_variation = STYLE_NO_ANTHRO_ICON
	armor = list("melee" = 25, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "wound" = 15)
	tint = 3 //it covers ya eyes
	var/busted = FALSE

/obj/item/clothing/head/cyberdeck/Initialize()
	. = ..()
	if(prob(5))
		busted = TRUE //TODO: make busted do something

/obj/item/clothing/head/cyberdeck/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		user.become_blind("blindfold_[REF(src)]")

/obj/item/clothing/head/cyberdeck/dropped(mob/living/carbon/human/user)
	..()
	user.cure_blind("blindfold_[REF(src)]")

/datum/outfit/treyliam
	name = "Trey Liam"
	head = /obj/item/clothing/head/cyberdeck
	uniform = /obj/item/clothing/under/rank/civilian/lawyer/bluesuit
	shoes = /obj/item/clothing/shoes/laceup

/obj/effect/landmark/treyliam
	name = "trey"

//CP helmet very nice
/obj/item/clothing/head/helmet/cphood
	name = "Civil Protection hood"
	desc = "Fits perfectly with a CP gas mask."
	icon = 'modular_skyrat/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/head.dmi'
	icon_state = "cphood"
	item_state = "cphood"

//Infiltrator helmet buff
/obj/item/clothing/head/helmet/infiltrator
	armor = list("melee" = 40, "bullet" = 40, "laser" = 30, "energy" = 40, "bomb" = 70, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "wound" = 20)

//cloaker armor vest
/obj/item/clothing/head/helmet/advanced
	name = "night vision helmet"
	desc = "I fought the law, and the law won."
	icon = 'modular_skyrat/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/head.dmi'
	icon_state = "cloaker"
	armor = list("melee" = 40, "bullet" = 35, "laser" = 35, "energy" = 50, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100, "wound" = 25)
	mutantrace_variation = STYLE_NO_ANTHRO_ICON
	actions_types = list(/datum/action/item_action/toggle_nv)
	var/activated = FALSE
	var/stored_nv = 0

/datum/action/item_action/toggle_nv
	name = "Toggle Night-Vision"
	desc = "Toggle your helmet's night vision."

/obj/item/clothing/head/helmet/advanced/item_action_slot_check(slot, mob/user, datum/action/A)
	. = ..()
	if(. && (slot == SLOT_HEAD))
		return TRUE

/obj/item/clothing/head/helmet/advanced/dropped(mob/user)
	. = ..()
	if(activated)
		activated = !activated
		user.see_in_dark = stored_nv

/obj/item/clothing/head/helmet/advanced/ui_action_click(mob/user, action)
	. = ..()
	if(istype(action, /datum/action/item_action/toggle_nv))
		if(!activated)
			activated = !activated
			stored_nv = user.see_in_dark
			user.see_in_dark = 8
			to_chat(user, "<span class='notice'>You activate [src]'s night vision.</span>")
		else
			activated = !activated
			user.see_in_dark = stored_nv
			to_chat(user, "<span class='notice'>You deactivate [src]'s night vision.</span>")

//brig phys
/obj/item/clothing/head/helmet/combat_medic
	name = "brig physician's armored helmet"
	desc = "Protects the head from circular saws."
	icon = 'modular_skyrat/icons/obj/clothing/enforcer.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	icon_state = "medichelmet"
	mutantrace_variation = STYLE_NO_ANTHRO_ICON

//doggy
/obj/item/clothing/head/helmet/sec/HoS/cerberus
	name = "cerberus' helmet"
	desc = "For the chief enforcer that likes barking a lot."
	icon = 'modular_skyrat/icons/obj/clothing/enforcer.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	icon_state = "doggy"
	mutantrace_variation = STYLE_NO_ANTHRO_ICON
	flags_inv = HIDEHAIR|HIDEFACIALHAIR|HIDEFACE|HIDESNOUT|HIDEMASK|HIDEEARS

//hunk helmet
/obj/item/clothing/head/helmet/enforcer
	name = "enforcer helmet"
	desc = "Part of corporate's plan to scare employees into submission. The effectiveness of this plan so far has been doubtful."
	icon = 'modular_skyrat/icons/obj/clothing/enforcer.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	icon_state = "hunk_helmet"
	mutantrace_variation = STYLE_NO_ANTHRO_ICON

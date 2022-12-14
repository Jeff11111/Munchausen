//child p- civil protection armor
/obj/item/clothing/suit/armor/vest/cparmor
	name = "Civil Protection armor"
	desc = "It barely covers your chest, but does a decent job at protecting you from crowbars."
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "cparmor"
	item_state = "cparmor"
	blood_overlay_type = "armor"
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

//infiltrator suit buff
/obj/item/clothing/suit/armor/vest/infiltrator
	armor = list("melee" = 40, "bullet" = 40, "laser" = 30, "energy" = 40, "bomb" = 70, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "wound" = 20)

//blueshield armor
/obj/item/clothing/suit/armor/vest/blueshield
	name = "blueshield security armor"
	desc = "An armored vest with the badge of a Blueshield Lieutenant."
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "blueshield"
	item_state = "blueshield"
	armor = list("melee" = 35, "bullet" = 35, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 75, "wound" = 25)
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/suit/armor/vest/blueshield/old
	name = "blueshield security armor"
	desc = "An armored vest with the badge of a Blueshield Lieutenant. This is the older variant."
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "blueshield_old"
	item_state = "blueshield_old"
	armor = list("melee" = 35, "bullet" = 35, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 75, "wound" = 25)
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

//makeshift armor
/obj/item/clothing/suit/armor/makeshift
	name = "makeshift armor"
	desc = "A hazard vest with metal plate taped on it. It offers minor protection at the cost of speed."
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "makeshiftarmor-worn"
	item_state = "makeshiftarmor"
	w_class = 3
	blood_overlay_type = "armor"
	slowdown = 0.35
	armor = list("melee" = 25, "bullet" = 10, "laser" = 0, "energy" = 0, "bomb" = 5, "bio" = 0, "rad" = 0, "wound" = 12)

//cloaker armor vest
/obj/item/clothing/suit/armor/vest/advanced
	name = "advanced armor vest"
	desc = "Stop hitting yourself."
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	icon_state = "cloaker"
	armor = list("melee" = 40, "bullet" = 35, "laser" = 35, "energy" = 50, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100, "wound" = 25)
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

//captin carapace
/obj/item/clothing/suit/armor/vest/capcarapace
	icon = 'modular_skyrat/icons/obj/clothing/captain.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/captain.dmi'
	icon_state = "carapace"
	mutantrace_variation = STYLE_NO_ANTHRO_ICON

//detective 
/obj/item/clothing/suit/armor/vest/det_suit
	icon = 'modular_skyrat/icons/obj/clothing/deputy.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/deputy.dmi'
	icon_state = "deputy_vest"
	desc = "An unremarkable green armored vest."
	mutantrace_variation = STYLE_NO_ANTHRO_ICON

//hos armor
/obj/item/clothing/suit/armor/hos/carrier
	name = "chief enforcer's carrier set"
	desc = "A robust, kevlar plate carrier with an attached set of arm and leg guards."
	icon = 'modular_skyrat/icons/obj/clothing/enforcer.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	icon_state = "cecarrier"
	item_state = "cecarrier"

//brig phys
/obj/item/clothing/suit/armor/vest/combat_medic
	name = "brig physician's armor vest"
	desc = "An unremarkable red cross vest or something."
	icon = 'modular_skyrat/icons/obj/clothing/enforcer.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	icon_state = "medicarmor"
	mutantrace_variation = STYLE_NO_ANTHRO_ICON

/* TEMPLATE
	unique_reskin_icons = list(
	)
	unique_reskin_worn = list(
	)
	unique_reskin_worn_anthro = list(
	)
	unique_reskin = list(
	)
*/

//port tg's armor energy resists, adds reskins to various armors
/obj/item/clothing/head/helmet
	can_flashlight = 1
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30,"energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "wound" = 15)

/obj/item/clothing/head/helmet/sec
	icon = 'modular_skyrat/icons/obj/clothing/enforcer.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/enforcer_muzzled.dmi'
	icon_state = "ehelmet"
	mutantrace_variation = STYLE_MUZZLE
	flags_inv = HIDEEYES
	flash_protect = 1

/obj/item/clothing/head/helmet/sec/equipped(mob/living/carbon/human/user, slot)
	..()
	if(slot == SLOT_HEAD)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
		DHUD.add_hud_to(user)

/obj/item/clothing/head/helmet/sec/dropped(mob/living/carbon/human/user)
	..()
	if(user.head == src)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
		DHUD.remove_hud_from(user)

/obj/item/clothing/head/helmet/alt
	can_flashlight = 1
	armor = list("melee" = 40, "bullet" = 60, "laser" = 20, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "wound" = 20)
	icon = 'modular_skyrat/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/head.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/head.dmi'
	icon_state = "epic_bp_helmet"

/obj/item/clothing/head/helmet/riot
	armor = list("melee" = 60, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "wound" = 25)
	unique_reskin = null

/obj/item/clothing/head/helmet/swat
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30,"energy" = 40, "bomb" = 50, "bio" = 90, "rad" = 20, "fire" = 50, "acid" = 50, "wound" = 25)

/obj/item/clothing/head/helmet/swat/Initialize()
	. = ..()
	//still awful
	if(type == /obj/item/clothing/head/helmet/swat)
		icon = 'modular_skyrat/icons/obj/clothing/hats.dmi'
		mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/head.dmi'
		anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/head_muzzled.dmi'
		icon_state = "chonker_helmet"
		mutantrace_variation = STYLE_MUZZLE

/obj/item/clothing/head/helmet/thunderdome
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90, "wound" = 35)
	unique_reskin = null

/obj/item/clothing/head/helmet/roman
	armor = list("melee" = 25, "bullet" = 0, "laser" = 25, "energy" = 10, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "wound" = 10)
	unique_reskin = null

/obj/item/clothing/head/helmet/roman/fake
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "wound" = 0)

/obj/item/clothing/head/helmet/redtaghelm
	armor = list("melee" = 15, "bullet" = 10, "laser" = 20,"energy" = 10, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 50, "wound" = 5)
	unique_reskin = null

/obj/item/clothing/head/helmet/bluetaghelm
	armor = list("melee" = 15, "bullet" = 10, "laser" = 20,"energy" = 10, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 50, "wound" = 5)
	unique_reskin = null

/obj/item/clothing/head/helmet/knight
	armor = list("melee" = 50, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "wound" = 25)
	unique_reskin = null

/obj/item/clothing/head/helmet/skull
	armor = list("melee" = 35, "bullet" = 25, "laser" = 25, "energy" = 35, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "wound" = 8)
	unique_reskin = null

/obj/item/clothing/head/helmet/durathread
	unique_reskin = null

/obj/item/clothing/head/helmet/rus_helmet
	armor = list("melee" = 25, "bullet" = 30, "laser" = 0, "energy" = 10, "bomb" = 10, "bio" = 0, "rad" = 20, "fire" = 20, "acid" = 50, "wound" = 10)
	unique_reskin = null

/obj/item/clothing/head/helmet/rus_ushanka
	armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 20, "bio" = 50, "rad" = 20, "fire" = -10, "acid" = 50, "wound" = 10)
	unique_reskin = null

/obj/item/clothing/head/caphat
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 35, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "wound" = 20)

/obj/item/clothing/head/hopcap
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 35, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "wound" = 5)

/obj/item/clothing/head/fedora/det_hat
	armor = list("melee" = 25, "bullet" = 5, "laser" = 25, "energy" = 35, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 50, "wound" = 5)

/obj/item/clothing/head/HoS
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 60, "wound" = 25)

/obj/item/clothing/head/helmet/sec/HoS
	name = "chief enforcer's helmet"
	desc = "A slightly updated variant of the regular security helmet featuring... Suprisingly little difference."
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 60, "wound" = 25)

/obj/item/clothing/head/HoS/beret/syndicate
	unique_reskin = null

/obj/item/clothing/head/warden
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 60, "wound" = 20)

/obj/item/clothing/head/beret/sec
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50, "wound" = 15)

/obj/item/clothing/head/beret/sec/navywarden
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 50, "wound" = 20)
	unique_reskin = null

/obj/item/clothing/head/helmet/space/hardsuit
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75, "wound" = 10)
	unique_reskin = null

/obj/item/clothing/suit/space/hardsuit
	armor = list("melee" = 10, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 50, "acid" = 75, "wound" = 10)
	unique_reskin = null

/obj/item/clothing/head/helmet/space/hardsuit/engine
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75, "wound" = 10)

/obj/item/clothing/suit/space/hardsuit/engine
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75, "wound" = 10)

/obj/item/clothing/head/helmet/space/hardsuit/engine/atmos
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75, "wound" = 10)

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75, "wound" = 10)

/obj/item/clothing/head/helmet/space/hardsuit/engine/elite
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 90, "wound" = 10)

/obj/item/clothing/suit/space/hardsuit/engine/elite
	armor = list("melee" = 40, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 90, "wound" = 10)

/obj/item/clothing/head/helmet/space/hardsuit/mining
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75, "wound" = 15)
	icon = 'modular_skyrat/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/head.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/head_muzzled.dmi'
	icon_state = "hardsuit0-explorer"
	hardsuit_type = "explorer"

/obj/item/clothing/suit/space/hardsuit/mining
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75, "wound" = 15)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator, /obj/item/pickaxe, /obj/item/gun/energy/plasmacutter)
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "hardsuit-explorer"

/obj/item/clothing/head/helmet/space/hardsuit/syndi
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90, "wound" = 25)

/obj/item/clothing/suit/space/hardsuit/syndi
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 90, "wound" = 25)

/obj/item/clothing/head/helmet/space/hardsuit/syndi/elite
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 60, "bomb" = 55, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100, "wound" = 30)

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	armor = list("melee" = 60, "bullet" = 60, "laser" = 50, "energy" = 60, "bomb" = 55, "bio" = 100, "rad" = 70, "fire" = 100, "acid" = 100, "wound" = 30)

/obj/item/clothing/head/helmet/space/hardsuit/wizard
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 50, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 35)

/obj/item/clothing/suit/space/hardsuit/wizard
	armor = list("melee" = 40, "bullet" = 40, "laser" = 40, "energy" = 50, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 35)

/obj/item/clothing/head/helmet/space/hardsuit/medical
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75, "wound" = 10)

/obj/item/clothing/suit/space/hardsuit/medical
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 75, "wound" = 10)

/obj/item/clothing/head/helmet/space/hardsuit/rd
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80, "wound" = 12)

/obj/item/clothing/suit/space/hardsuit/rd
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 100, "bio" = 100, "rad" = 60, "fire" = 60, "acid" = 80, "wound" = 12)

/obj/item/clothing/head/helmet/space/hardsuit/security
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30,"energy" = 40, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75, "wound" = 20)
	icon = 'modular_skyrat/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/head.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/head_muzzled.dmi'
	icon_state = "hardsuit0-assprotection"
	hardsuit_type = "assprotection"

/obj/item/clothing/suit/space/hardsuit/security
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30,"energy" = 40, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75, "wound" = 20)
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "hardsuit-assprotection"

/obj/item/clothing/head/helmet/space/hardsuit/security/hos
	armor = list("melee" = 45, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95, "wound" = 25)
	unique_reskin = null

/obj/item/clothing/suit/space/hardsuit/security/hos
	armor = list("melee" = 45, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 100, "rad" = 50, "fire" = 95, "acid" = 95, "wound" = 25)
	unique_reskin = null

/obj/item/clothing/suit/space/swat
	armor = list("melee" = 40, "bullet" = 50, "laser" = 50, "energy" = 60, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 35)
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "chonker_suit"

/obj/item/clothing/head/helmet/space/hardsuit/clown
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 60, "acid" = 30, "wound" = 10)

/obj/item/clothing/suit/space/hardsuit/clown
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 60, "acid" = 30, "wound" = 10)

/obj/item/clothing/head/helmet/space/hardsuit/ancient
	armor = list("melee" = 30, "bullet" = 5, "laser" = 5, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 75, "wound" = 10)

/obj/item/clothing/suit/space/hardsuit/ancient
	armor = list("melee" = 30, "bullet" = 5, "laser" = 5, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 75, "wound" = 10)

/obj/item/clothing/suit/space/hardsuit/shielded
	armor = list("melee" = 30, "bullet" = 15, "laser" = 30, "energy" = 40, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 20)

/obj/item/clothing/suit/space/hardsuit/shielded/ctf
	armor = list("melee" = 0, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 95, "acid" = 95, "wound" = 20)

/obj/item/clothing/head/helmet/space/hardsuit/shielded/ctf
	armor = list("melee" = 0, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 95, "acid" = 95, "wound" = 20)

/obj/item/clothing/suit/space/hardsuit/shielded/syndi
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 30)

/obj/item/clothing/head/helmet/space/hardsuit/shielded/syndi
	armor = list("melee" = 40, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 35, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 30)

/obj/item/clothing/suit/space/hardsuit/shielded/swat
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 60, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "wound" = 45)

/obj/item/clothing/head/helmet/space/hardsuit/shielded/swat
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 60, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "wound" = 45)

/obj/item/clothing/suit/armor/vest
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "wound" = 15)
	icon = 'modular_skyrat/icons/obj/clothing/enforcer.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	icon_state = "earmor"

/obj/item/clothing/suit/armor/vest/warden
	icon = 'icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'icons/mob/clothing/suit.dmi'

/obj/item/clothing/suit/armor/vest/alt
	icon_state = "earmor"

/obj/item/clothing/suit/armor/vest/old
	icon_state = "earmor"

/obj/item/clothing/suit/armor/hos
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90, "wound" = 25)

/obj/item/clothing/suit/armor/vest/capcarapace
	armor = list("melee" = 50, "bullet" = 40, "laser" = 50, "energy" = 50, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 90, "wound" = 30)
	icon = 'icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'icons/mob/clothing/suit_digi.dmi'
	unique_reskin = null

/obj/item/clothing/suit/armor/riot
	armor = list("melee" = 60, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 10, "bio" = 10, "rad" = 0, "fire" = 65, "acid" = 70, "wound" = 25)
	slowdown = 0
	unique_reskin = null

/obj/item/clothing/suit/armor/bone
	armor = list("melee" = 35, "bullet" = 25, "laser" = 25, "energy" = 35, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "wound" = 5)
	unique_reskin = null

/obj/item/clothing/suit/armor/bulletproof
	armor = list("melee" = 30, "bullet" = 60, "laser" = 20, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "wound" = 20)
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "epic_bp_armor"

/obj/item/clothing/suit/armor/laserproof
	armor = list("melee" = 10, "bullet" = 10, "laser" = 60, "energy" = 60, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "wound" = 15)
	unique_reskin = null

/obj/item/clothing/suit/armor/centcom
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90, "wound" = 40)
	unique_reskin = null

/obj/item/clothing/suit/armor/heavy
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90, "wound" = 40)
	unique_reskin = null

/obj/item/clothing/suit/armor/tdome
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 50, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90, "wound" = 45)
	unique_reskin = null

/obj/item/clothing/suit/armor/riot/knight/greyscale
	armor = list("melee" = 35, "bullet" = 10, "laser" = 10, "energy" = 10, "bomb" = 10, "bio" = 10, "rad" = 10, "fire" = 40, "acid" = 40, "wound" = 15)
	unique_reskin = null

/obj/item/clothing/suit/armor/vest/durathread
	unique_reskin = null

/obj/item/clothing/suit/armor/vest/russian
	armor = list("melee" = 25, "bullet" = 30, "laser" = 0, "energy" = 10, "bomb" = 10, "bio" = 0, "rad" = 20, "fire" = 20, "acid" = 50, "wound" = 15)
	unique_reskin = null

/obj/item/clothing/suit/armor/vest/russian_coat
	armor = list("melee" = 25, "bullet" = 20, "laser" = 20, "energy" = 30, "bomb" = 20, "bio" = 50, "rad" = 20, "fire" = -10, "acid" = 50, "wound" = 10)
	unique_reskin = null

/obj/item/clothing/suit/det_suit
	armor = list("melee" = 25, "bullet" = 10, "laser" = 25, "energy" = 35, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 45, "wound" = 10)

/obj/item/clothing/suit/security/officer
	armor = list("melee" = 25, "bullet" = 10, "laser" = 25, "energy" = 35, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 45, "wound" = 10)

/obj/item/clothing/suit/security/warden
	armor = list("melee" = 35, "bullet" = 25, "laser" = 30, "energy" = 35, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 60, "wound" = 12)

/obj/item/clothing/suit/security/hos
	armor = list("melee" = 45, "bullet" = 35, "laser" = 35, "energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 25, "acid" = 90, "wound" = 15)

/obj/item/clothing/under/rank/security/officer
	icon = 'modular_skyrat/icons/obj/clothing/enforcer.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	icon_state = "ejumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/head_of_security
	icon = 'modular_skyrat/icons/obj/clothing/enforcer.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/enforcer.dmi'
	icon_state = "cejumpsuit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/security/officer/blueshirt
	icon = 'icons/obj/clothing/uniforms.dmi'
	mob_overlay_icon = 'icons/mob/clothing/uniform.dmi'
	anthro_mob_worn_overlay = 'icons/mob/clothing/uniform_digi.dmi'
	icon_state = "blueshift"
	item_state = "blueshift"

/obj/item/storage/belt/military
	desc = "A set of tactical webbing worn by militaries everywhere."

/obj/item/storage/belt/military/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.can_hold = typecacheof(list(
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/multitool,
		/obj/item/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/analyzer,
		/obj/item/extinguisher/mini,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/reagent_containers/hypospray,
		/obj/item/gps,
		/obj/item/melee/baton,
		/obj/item/melee/classic_baton,
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/kitchen/knife,
		/obj/item/melee/classic_baton/telescopic,
		/obj/item/clothing/gloves,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medspray,
		/obj/item/stack/medical,
		/obj/item/pinpointer/crew
		))

/obj/item/clothing/head/helmet/roman
	unique_reskin = null

/obj/item/clothing/head/helmet/gladiator
	unique_reskin = null

/obj/item/clothing/head/helmet/skull
	unique_reskin = null

/obj/item/clothing/head/helmet/knight
	unique_reskin = null

/obj/item/clothing/head/helmet/infiltrator
	unique_reskin = null

/obj/item/clothing/suit/armor/vest/old
	unique_reskin = null

/obj/item/clothing/suit/armor/vest/blueshirt
	icon = 'icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'icons/mob/clothing/suit_digi.dmi'
	unique_reskin = null

/obj/item/clothing/suit/armor/vest/infiltrator
	unique_reskin = null

/obj/item/clothing/suit/armor/riot/knight
	unique_reskin = null

/obj/item/clothing/suit/armor/vest/warden
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_ALL_TAURIC
	taur_mob_worn_overlay = 'modular_skyrat/icons/mob/suits_taur.dmi'

/obj/item/clothing/suit/hooded/techpriest
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_ALL_TAURIC|STYLE_NO_ANTHRO_ICON
	taur_mob_worn_overlay = 'modular_skyrat/icons/mob/suits_taur.dmi'

// Reskinnable Trek uniforms
/obj/item/clothing/under/trek/command
	name = "enterprise command uniform"
	desc = "An enterprise corps uniform worn by command officers."
	unique_reskin_icons = list(
	"Orvlike" = 'icons/obj/clothing/uniforms.dmi',
	"The Original Series" = 'icons/obj/clothing/uniforms.dmi',
	"The New Generation" = 'icons/obj/clothing/uniforms.dmi',
	"Voyager" = 'icons/obj/clothing/uniforms.dmi',
	"Deep Space Nine" = 'icons/obj/clothing/uniforms.dmi',
	"Enterprise" = 'icons/obj/clothing/uniforms.dmi'
	)
	unique_reskin_worn = list(
	"Orvlike" = 'icons/mob/clothing/uniform.dmi',
	"The Original Series" = 'icons/mob/clothing/uniform.dmi',
	"The New Generation" = 'icons/mob/clothing/uniform.dmi',
	"Voyager" = 'icons/mob/clothing/uniform.dmi',
	"Deep Space Nine" = 'icons/mob/clothing/uniform.dmi',
	"Enterprise" = 'icons/mob/clothing/uniform.dmi'
	)
	unique_reskin_worn_anthro = list(
	"Orvlike" = 'icons/mob/clothing/uniform_digi.dmi',
	"The Original Series" = 'icons/mob/clothing/uniform_digi.dmi',
	"The New Generation" = 'icons/mob/clothing/uniform_digi.dmi',
	"Voyager" = 'icons/mob/clothing/uniform_digi.dmi',
	"Deep Space Nine" = 'icons/mob/clothing/uniform_digi.dmi',
	"Enterprise" = 'icons/mob/clothing/uniform_digi.dmi'
	)
	unique_reskin = list(
	"Orvlike" = "orv_com",
	"The Original Series" = "trek_command",
	"The New Generation" = "trek_next_command",
	"Voyager" = "trek_voy_command",
	"Deep Space Nine" = "trek_ds9_command",
	"Enterprise" = "trek_ent_command"
	)
	unique_desc = list(
	"Orvlike" = "An uniform worn by command officers since 2420s.",
	"The Original Series" = "An uniform worn by command officers in the mid 2260s.",
	"The New Generation" = "An uniform worn by command officers. This one is from the mid 2360s.",
	"Voyager" = "An uniform worn by command officers of the 2370s.",
	"Deep Space Nine" = "An uniform worn by command officers of the 2380s.",
	"Enterprise" = "An uniform worn by command officers of the 2140s."
	)

// Let's not allow reskin of specified command uniform...
/obj/item/clothing/under/trek/command/orv/captain
	name = "enterprise captain uniform"
	desc = "An enterprise corps uniform worn by captains."
	unique_reskin = null

/obj/item/clothing/under/trek/command/orv/engsec
	name = "enterprise operations command uniform"
	desc = "An enterprise corps uniform worn by operations command officers."
	unique_reskin = null

/obj/item/clothing/under/trek/command/orv/medsci
	name = "enterprise medsci command uniform"
	desc = "An enterprise corps uniform worn by medsci command officers."
	unique_reskin = null

/obj/item/clothing/under/trek/engsec
	name = "enterprise operations uniform"
	desc = "An enterprise corps uniform worn by operations officers."
	unique_reskin_icons = list(
	"Orvlike" = 'icons/obj/clothing/uniforms.dmi',
	"The Original Series" = 'icons/obj/clothing/uniforms.dmi',
	"The New Generation" = 'icons/obj/clothing/uniforms.dmi',
	"Voyager" = 'icons/obj/clothing/uniforms.dmi',
	"Deep Space Nine" = 'icons/obj/clothing/uniforms.dmi',
	"Enterprise" = 'icons/obj/clothing/uniforms.dmi'
	)
	unique_reskin_worn = list(
	"Orvlike" = 'icons/mob/clothing/uniform.dmi',
	"The Original Series" = 'icons/mob/clothing/uniform.dmi',
	"The New Generation" = 'icons/mob/clothing/uniform.dmi',
	"Voyager" = 'icons/mob/clothing/uniform.dmi',
	"Deep Space Nine" = 'icons/mob/clothing/uniform.dmi',
	"Enterprise" = 'icons/mob/clothing/uniform.dmi'
	)
	unique_reskin_worn_anthro = list(
	"Orvlike" = 'icons/mob/clothing/uniform_digi.dmi',
	"The Original Series" = 'icons/mob/clothing/uniform_digi.dmi',
	"The New Generation" = 'icons/mob/clothing/uniform_digi.dmi',
	"Voyager" = 'icons/mob/clothing/uniform_digi.dmi',
	"Deep Space Nine" = 'icons/mob/clothing/uniform_digi.dmi',
	"Enterprise" = 'icons/mob/clothing/uniform_digi.dmi'
	)
	unique_reskin = list(
	"Orvlike" = "orv_ops",
	"The Original Series" = "trek_engsec",
	"The New Generation" = "trek_next_engsec",
	"Voyager" = "trek_voy_engsec",
	"Deep Space Nine" = "trek_ds9_engsec",
	"Enterprise" = "trek_ent_engsec"
	)
	unique_desc = list(
	"Orvlike" = "An uniform worn by operations officers since 2420s.",
	"The Original Series" = "An uniform worn by operations officers in the mid 2260s. You feel strangely vulnerable just seeing this...",
	"The New Generation" = "An uniform worn by operations officers. This one is from the mid 2360s.",
	"Voyager" = "An uniform worn by operations officers of the 2370s.",
	"Deep Space Nine" = "An uniform worn by operations officers of the 2380s.",
	"Enterprise" = "An uniform worn by operations officers of the 2140s."
	)

/obj/item/clothing/under/trek/medsci
	name = "enterprise medsci uniform"
	desc = "An enterprise corps uniform worn by medsci officers."
	unique_reskin_icons = list(
	"Orvlike" = 'icons/obj/clothing/uniforms.dmi',
	"The Original Series" = 'icons/obj/clothing/uniforms.dmi',
	"The New Generation" = 'icons/obj/clothing/uniforms.dmi',
	"Voyager" = 'icons/obj/clothing/uniforms.dmi',
	"Deep Space Nine" = 'icons/obj/clothing/uniforms.dmi',
	"Enterprise" = 'icons/obj/clothing/uniforms.dmi'
	)
	unique_reskin_worn = list(
	"Orvlike" = 'icons/mob/clothing/uniform.dmi',
	"The Original Series" = 'icons/mob/clothing/uniform.dmi',
	"The New Generation" = 'icons/mob/clothing/uniform.dmi',
	"Voyager" = 'icons/mob/clothing/uniform.dmi',
	"Deep Space Nine" = 'icons/mob/clothing/uniform.dmi',
	"Enterprise" = 'icons/mob/clothing/uniform.dmi'
	)
	unique_reskin_worn_anthro = list(
	"Orvlike" = 'icons/mob/clothing/uniform_digi.dmi',
	"The Original Series" = 'icons/mob/clothing/uniform_digi.dmi',
	"The New Generation" = 'icons/mob/clothing/uniform_digi.dmi',
	"Voyager" = 'icons/mob/clothing/uniform_digi.dmi',
	"Deep Space Nine" = 'icons/mob/clothing/uniform_digi.dmi',
	"Enterprise" = 'icons/mob/clothing/uniform_digi.dmi'
	)
	unique_reskin = list(
	"Orvlike" = "orv_medsci",
	"The Original Series" = "trek_medsci",
	"The New Generation" = "trek_next_medsci",
	"Voyager" = "trek_voy_medsci",
	"Deep Space Nine" = "trek_ds9_medsci",
	"Enterprise" = "trek_ent_medsci"
	)
	unique_desc = list(
	"Orvlike" = "An uniform worn by medsci officers since 2420s.",
	"The Original Series" = "An uniform worn by medsci officers in the mid 2260s.",
	"The New Generation" = "An uniform worn by medsci officers. This one is from the mid 2360s.",
	"Voyager" = "An uniform worn by medsci officers of the 2370s.",
	"Deep Space Nine" = "An uniform worn by medsci officers of the 2380s.",
	"Enterprise" = "An uniform worn by medsci officers of the 2140s."
	)

// Bonus for assistants and service.
/obj/item/clothing/under/trek/orv
	name = "enterprise assistant uniform"
	desc = "An enterprise corps uniform worn by adjutants <i>(assistants)</i>."
	unique_reskin_icons = list(
	"Default" = 'icons/obj/clothing/uniforms.dmi',
	"The Motion Picture (The Original Series)" = 'icons/obj/clothing/uniforms.dmi'
	)
	unique_reskin_worn = list(
	"Default" = 'icons/mob/clothing/uniform.dmi',
	"The Motion Picture (The Original Series)" = 'icons/mob/clothing/uniform.dmi'
	)
	unique_reskin_worn_anthro = list(
	"Default" = 'icons/mob/clothing/uniform_digi.dmi',
	"The Motion Picture (The Original Series)" = 'icons/mob/clothing/uniform_digi.dmi'
	)
	unique_reskin = list(
	"Default" = "orv_ass",
	"The Motion Picture (The Original Series)" = "trek_tmp_trainee"
	)
	unique_name = list(
	"Default" = "enterprise assistant uniform",
	"The Motion Picture (The Original Series)" = "federation trainee uniform"
	)
	unique_desc = list(
	"Default" = "An uniform worn by adjutants <i>(assistants)</i> since 2550s.",
	"The Motion Picture (The Original Series)" = "An uniform worn by enlisted trainees in 2285s."
	)

/obj/item/clothing/under/trek/orv/service
	name = "enterprise service uniform"
	desc = "An enterprise corps uniform worn by service officers... Or is it just <i>service uniform</i> worn by officers?"
	unique_reskin_icons = list(
	"Default" = 'icons/obj/clothing/uniforms.dmi',
	"The Motion Picture (The Original Series)" = 'icons/obj/clothing/uniforms.dmi'
	)
	unique_reskin_worn = list(
	"Default" = 'icons/mob/clothing/uniform.dmi',
	"The Motion Picture (The Original Series)" = 'icons/mob/clothing/uniform.dmi'
	)
	unique_reskin_worn_anthro = list(
	"Default" = 'icons/mob/clothing/uniform_digi.dmi',
	"The Motion Picture (The Original Series)" = 'icons/mob/clothing/uniform_digi.dmi'
	)
	unique_reskin = list(
	"Default" = "orv_srv",
	"The Motion Picture (The Original Series)" = "trek_tmp_service"
	)
	unique_name = list(
	"Default" = "enterprise service uniform",
	"The Motion Picture (The Original Series)" = "federation service uniform"
	)
	unique_desc = list(
	"Default" = "An uniform worn by service officers since 2550s.",
	"The Motion Picture (The Original Series)" = "An uniform worn by enlists for service work in 2285s."
	)

// Changes name/desc to the jackets, makes modern/non-classic jacket to have same list of allowed suit-storage items as classic one.
/obj/item/clothing/suit/storage/fluff/fedcoat
	name = "federation classic uniform jacket"
	desc = "The federation's classic uniform jacket. Set phasers to awesome!"

/obj/item/clothing/suit/storage/fluff/modernfedcoat
	name = "enterprise uniform jacket"
	desc = "An enterprise corps uniform jacket."
	allowed = list(
				/obj/item/tank/internals/emergency_oxygen,
				/obj/item/flashlight,
				/obj/item/analyzer,
				/obj/item/radio,
				/obj/item/gun,
				/obj/item/melee/baton,
				/obj/item/restraints/handcuffs,
				/obj/item/reagent_containers/hypospray,
				/obj/item/hypospray,
				/obj/item/healthanalyzer,
				/obj/item/reagent_containers/syringe,
				/obj/item/reagent_containers/glass/bottle/vial,
				/obj/item/reagent_containers/glass/beaker,
				/obj/item/storage/pill_bottle,
				/obj/item/taperecorder)

/obj/item/clothing/head/caphat/formal/fedcover
	name = "enterprise officer cap"
	desc = "A peaked cap, that demands <i>at least <u>some</u></i> discipline from its wearer."

/obj/item/clothing/head/kepi/orvi
	name = "enterprise kepi"
	desc = "A visored cap, that demands <i>at least <u>some</u></i> honor from it's wearer."

//durathread buff
/obj/item/clothing/head/beanie/durathread
	armor = list("melee" = 25, "bullet" = 20, "laser" = 15,"energy" = 10, "bomb" = 30, "bio" = 15, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 12)

/obj/item/clothing/head/helmet/durathread
	armor = list("melee" = 25, "bullet" = 20, "laser" = 15,"energy" = 10, "bomb" = 30, "bio" = 15, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 12)

/obj/item/clothing/suit/armor/vest/durathread
	armor = list("melee" = 25, "bullet" = 20, "laser" = 15,"energy" = 10, "bomb" = 30, "bio" = 15, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 12)

/obj/item/clothing/suit/hooded/wintercoat/durathread
	armor = list("melee" = 25, "bullet" = 20, "laser" = 15,"energy" = 10, "bomb" = 30, "bio" = 15, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 12)

/obj/item/clothing/head/hooded/winterhood/durathread
	armor = list("melee" = 25, "bullet" = 20, "laser" = 15,"energy" = 10, "bomb" = 30, "bio" = 15, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 12)

/obj/item/clothing/suit/hooded/cloak/drake
	armor = list("melee" = 70, "bullet" = 30, "laser" = 50, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 30)

/obj/item/clothing/head/hooded/cloakhood/drake
	armor = list("melee" = 70, "bullet" = 30, "laser" = 50, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 30)

//heck suit armor adjustments because honestly why the fuck is the drake armor statistically better
/obj/item/clothing/suit/space/hostile_environment
	armor = list("melee" = 70, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 30)

/obj/item/clothing/head/helmet/space/hostile_environment
	armor = list("melee" = 70, "bullet" = 50, "laser" = 30, "energy" = 40, "bomb" = 70, "bio" = 60, "rad" = 50, "fire" = 100, "acid" = 100, "wound" = 30)

//Cargo Utilitarian reskins
/obj/item/clothing/under/rank/cargo
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/qm
	icon = 'modular_skyrat/icons/obj/clothing/cargoutilit.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/cargoutil.dmi'
	icon_state = "turtleneck_qm"

/obj/item/clothing/under/rank/cargo/tech
	icon = 'modular_skyrat/icons/obj/clothing/cargoutilit.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/cargoutil.dmi'
	icon_state = "gorka_cargo"

// Armored boots and gloves

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots lined with kevlar, these are the real deal."
	armor = list("melee" = 15, "bullet" = 15, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 80, "rad" = 20, "fire" = 80, "acid" = 50, "wound" = 5)

/obj/item/clothing/shoes/jackboots/unarmored
	name = "black boots"
	desc = "Nanotrasen brand black leather boots."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "wound" = 0)

/obj/item/clothing/shoes/workboots
	name = "work boots"
	desc = "Nanotrasen-issue Engineering lace-up work boots with plated soles and toes, for the especially blue-collar."
	armor = list("melee" = 20, "bullet" = 5, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 80, "rad" = 80, "fire" = 80, "acid" = 50, "wound" = 5)

/obj/item/clothing/shoes/workboots/unarmored
	name = "tan boots"
	desc = "Nanotrasen brand lace up boots."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "wound" = 0)

/obj/item/clothing/shoes/workboots/mining
	name = "mining boots"
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 80, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 10)

/obj/item/clothing/shoes/workboots/mining/unarmored
	name = "hiking boots"
	desc = "Nanotrasen brand hiking boots."
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "wound" = 0)

/obj/item/clothing/shoes/combat
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 50, "bio" = 80, "rad" = 80, "fire" = 100, "acid" = 50, "wound" = 10)
	force = 5

/obj/item/clothing/gloves/color/black
	armor = list("melee" = 15, "bullet" = 15, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 80, "rad" = 20, "fire" = 80, "acid" = 50, "wound" = 10)

/obj/item/clothing/gloves/combat
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 50, "bio" = 80, "rad" = 80, "fire" = 100, "acid" = 50, "wound" = 10)
	force = 5

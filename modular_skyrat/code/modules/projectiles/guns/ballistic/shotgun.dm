// Holorifle: ballistic energy pump action shotgun thing. Original /tg/ PR made by necromanceranne.
/obj/item/gun/ballistic/shotgun/holorifle
	name = "holorifle"
	desc = "A shotgun-like weapon crafted to utilize holographic projectors like a laser firing lens. Its power expenditure requires dedicated microfusion cells to fire in place of standard ammunition."
	icon = 'modular_skyrat/icons/obj/guns/energy.dmi'
	icon_state = "holorifle"
	lefthand_file = 'modular_skyrat/icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/weapons/64x_guns_right.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/back.dmi'
	item_state = "holorifle"
	fire_sound = 'sound/weapons/pulse.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/holorifle
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	pin = null

//Cane gun, chad mime and clown traitor item
/obj/item/gun/ballistic/shotgun/canegun
	name = "pimp stick"
	desc = "A gold-rimmed cane, with a gleaming diamond set at the top. Great for bashing in kneecaps."
	mag_type = /obj/item/ammo_box/magazine/internal/shot/canegun
	icon = 'modular_skyrat/icons/obj/items_and_weapons.dmi'
	icon_state = "pimpstick"
	item_state = "pimpstick"
	lefthand_file = 'modular_skyrat/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/righthand.dmi'
	force = 15
	throwforce = 7
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("pimped", "smacked", "disciplined", "busted", "capped", "decked")
	resistance_flags = FIRE_PROOF
	var/mob/current_owner

/obj/item/gun/ballistic/shotgun/canegun/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_HANDS)
		if(!current_owner && user)
			current_owner = user
		if(current_owner && current_owner != user)
			current_owner = null

/obj/item/gun/ballistic/shotgun/canegun/sawoff(mob/user)
	to_chat(user, "<span class='warning'>Kinda defeats the purpose of a cane, doesn't it?</span>")
	return

/obj/item/gun/ballistic/shotgun/canegun/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is hitting [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to discipline [user.p_them()]self for being a mark-ass trick.</span>")
	return (BRUTELOSS)

/obj/item/ammo_box/magazine/internal/shot/canegun
	name = "cane-gun internal magazine"
	max_ammo = 3

//upgraded double barrel
/obj/item/gun/ballistic/revolver/doublebarrel/upgraded
	name = "upgraded double barreled shotgun"
	desc = "Two times the fun, at once."
	burst_size = 2
	burst_shot_delay = 4

/obj/item/gun/ballistic/revolver/doublebarrel/upgraded/sawoff(mob/user)
	to_chat(user, "<span class='warning'>Considering the modifications, sawing it off probably would break it entirely.</span>")
	return

//Warden's combat shotgun
/obj/item/gun/ballistic/shotgun/automatic/combat/compact/warden
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com/compact/warden
//
//
//
//
////////////////////////
// IMPROVISED SHOTGUN //
////////////////////////
//		Let's throw out the old and bring in a break-action shotgun.

/obj/item/gun/ballistic/shotgun/improvised
	name = "improvised shotgun"
	desc = "A break-action 12 gauge shotgun. You need both hands to fire this."
	icon = 'modular_skyrat/icons/obj/guns/projectile40x32.dmi'
	icon_state = "ishotgun"
	item_state = "ishotgun"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	lefthand_file = 'modular_skyrat/icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/weapons/64x_guns_right.dmi'
	pixel_x = -4
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	sawn_desc = "A break-action 12 gauge shotgun, but with most of the stock and some of the barrel removed. You still need both hands to fire this."
	unique_reskin = null
	weapon_weight = WEAPON_HEAVY	// It's big.
	recoil = 4	// We're firing 12 gauge.
	var/barrel_open

//	//	//	Weapon "animation" code block - We want the player to have visual feedback and to see the shotgun barrel is open.
/obj/item/gun/ballistic/shotgun/improvised/pump(mob/M)
	playsound(M, 'modular_skyrat/sound/weapons/bolt_in.ogg', 60, 1)
	if(barrel_open)
		pump_reload(M)
	else
		pump_unload(M)
	barrel_open = !barrel_open
	update_icon()
	return 1

/obj/item/gun/ballistic/shotgun/improvised/update_icon()
	..()
	icon_state = "[initial(icon_state)][barrel_open ? "-open" : ""]"
	item_state = "[initial(item_state)][sling ? "sling" :  ""]"

/obj/item/gun/ballistic/shotgun/improvised/attackby(obj/item/A, mob/user, params)
	if(!barrel_open)
		to_chat(user, "<span class='notice'>The barrel is closed!</span>")
		return
	else
		return ..()

/obj/item/gun/ballistic/shotgun/improvised/sawn
	name = "sawn-off improvised shotgun"
	desc = "The barrel and stock have been sawn and filed down; it can fit in backpacks. You still need two hands to fire this if you value unbroken wrists."
	icon_state = "ishotgun_sawn"
	item_state = "ishotgun_sawn"
	w_class = WEIGHT_CLASS_NORMAL
	sawn_off = TRUE
	slot_flags = ITEM_SLOT_BELT

////////////////////////
//  IMPROVISED RIFLE  //
////////////////////////
//		We're overriding what's defined in the core files here.

/obj/item/gun/ballistic/shotgun/boltaction/improvised
	name = "Improvised Rifle"
	desc = "A crude bolt action 7.62 rifle. There is no magazine, once the bolt is open and the spent shell is ejected, a new one must be loaded."
	icon = 'modular_skyrat/icons/obj/guns/projectile40x32.dmi'
	icon_state = "irifle"
	item_state = "irifle"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	lefthand_file = 'modular_skyrat/icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/weapons/64x_guns_right.dmi'
	pixel_x = -4
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY	// Requires two hands to fire.
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/improvised
	can_bayonet = FALSE

/obj/item/gun/ballistic/shotgun/boltaction/improvised/update_icon()
	icon_state = "[initial(icon_state)][chambered ? "" : "-open"]"

//Shotgun but better
/obj/item/gun/ballistic/shotgun
	icon = 'modular_skyrat/icons/obj/bobstation/guns/shotgun.dmi'
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/shotgun_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/shotgun_righthand.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/obj/bobstation/guns/worn/back.dmi'
	icon_state = "shotgun"
	item_state = "shotgun"
	fire_sound = 'modular_skyrat/sound/guns/shotgun.ogg'
	inhand_x_dimension = 32
	inhand_y_dimension = 32

/obj/item/gun/ballistic/shotgun/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"]"
	item_state = "[initial(item_state)][is_wielded ? "-wielded" : ""]"

/obj/item/gun/ballistic/shotgun/riot
	icon_state = "riotshotgun"
	item_state = "riotshotgun"

/obj/item/gun/ballistic/shotgun/automatic/combat
	icon_state = "combatshotgun"
	item_state = "combatshotgun"

//Bulldog
/obj/item/gun/ballistic/automatic/shotgun
	lefthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/shotgun_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/obj/bobstation/guns/inhands/shotgun_righthand.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/obj/bobstation/guns/worn/back.dmi'
	icon_state = "bo"
	item_state = "shotgun"
	fire_sound = 'modular_skyrat/sound/guns/shotgun.ogg'
	generic_magazine_overlays = FALSE

/obj/item/gun/ballistic/automatic/shotgun/update_icon()
	..()
	item_state = "[initial(item_state)][is_wielded ? "-wielded" : ""]"

//Security HEV
/obj/item/clothing/head/helmet/space/hardsuit/security/metrocop
	name = "security HEV suit helmet"
	desc = "This helmet seems like something out of this world... It has been designed by Nanotrasen for their security teams to be used during emergency operations in hazardous environments. This one provides more protection from the environment in exchange for the usual combat protection of a regular security suit."
	icon = 'modular_skyrat/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/head.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/head_muzzled.dmi'
	icon_state = "hardsuit0-metrocop"
	item_state = "hardsuit0-metrocop"
	hardsuit_type = "metrocop"
	armor = list("melee" = 50, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 60, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 100, "wound" = 10)
	resistance_flags = FIRE_PROOF | ACID_PROOF | GOLIATH_RESISTANCE
	mutantrace_variation = STYLE_MUZZLE

/obj/item/clothing/suit/space/hardsuit/security/metrocop
	name = "security HEV suit"
	desc = "This suit seems like something out of this world... It has been designed by Nanotrasen for their security teams to be used during emergency operations in hazardous environments. This one provides more protection from the environment in exchange for the usual combat protection of a regular security suit."
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "hardsuit-metrocop"
	item_state = "hardsuit-metrocop"
	hardsuit_type = "metrocop"
	armor = list("melee" = 50, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 60, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 100, "wound" = 10)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/security/metrocop
	resistance_flags = FIRE_PROOF | ACID_PROOF | GOLIATH_RESISTANCE
	mutantrace_variation = STYLE_DIGITIGRADE

//Snowflake hardsuit modules
/obj/item/melee/transforming/armblade
	name = "Hardsuit Blade"
	desc = "A pointy, murdery blade that can be attached to your hardsuit."
	force = 0
	force_on = 20
	sharpness = SHARP_NONE
	var/sharpness_on = SHARP_EDGED
	throwforce = 0
	throwforce_on = 0
	hitsound_on = 'sound/weapons/bladeslice.ogg'
	armour_penetration = 0
	var/armour_penetration_on = 25
	icon = 'modular_skyrat/icons/obj/items_and_weapons.dmi'
	icon_state = "armblade0"
	icon_state_on = "armblade1"
	lefthand_file = 'modular_skyrat/icons/mob/inhands/armblade_lefthand.dmi'
	righthand_file = 'modular_skyrat/icons/mob/inhands/armblade_righthand.dmi'
	item_state = "armblade0"
	var/item_state_on = "armblade1"
	attack_verb_off = list("bopped")
	total_mass_on = 0.6
	var/obj/item/clothing/suit/space/hardsuit/mastersuit = null
	actions_types = list(/datum/action/item_action/extendoblade)
	var/extendo = FALSE

/datum/action/item_action/extendoblade
	name = "Extend Blade"
	desc = "Extend the hardsuit's blade."

/obj/item/melee/transforming/armblade/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/extendoblade) && mastersuit && !extendo)
		var/mob/living/carbon/human/H = user
		if(H)
			var/obj/item/arm_item = user.get_active_held_item()
			if(arm_item)
				if(!user.dropItemToGround(arm_item))
					to_chat(user, "<span class='warning'>Your [arm_item] interferes with [src]!</span>")
					return
				else
					to_chat(user, "<span class='notice'>You drop [arm_item] to activate [src]!</span>")
			user.put_in_r_hand(src)
			ADD_TRAIT(src, TRAIT_NODROP, "hardsuit")
			playsound(get_turf(user), 'sound/mecha/mechmove03.ogg', 50, 1)
			extendo = !extendo

	else if (istype(action, /datum/action/item_action/extendoblade) && mastersuit && extendo)
		REMOVE_TRAIT(src, TRAIT_NODROP, "hardsuit")
		user.transferItemToLoc(src, mastersuit, TRUE)
		playsound(get_turf(user), 'sound/mecha/mechmove03.ogg', 50, 1)
		extendo = !extendo
		for(var/X in src.actions)
			var/datum/action/A = X
			A.Grant(user)

/obj/item/melee/transforming/armblade/Initialize()
	..()
	AddComponent(/datum/component/butchering, 50, 100, 0, hitsound_on)

/obj/item/melee/transforming/armblade/transform_weapon(mob/living/user, supress_message_text)
	..()
	if(active)
		sharpness = sharpness_on
		armour_penetration = armour_penetration_on
		item_state = item_state_on
	else
		sharpness = initial(sharpness)
		armour_penetration = initial(armour_penetration)
		item_state = initial(item_state)

/obj/item/melee/transforming/armblade/transform_messages(mob/living/user, supress_message_text)
	playsound(user, active ? 'sound/weapons/batonextend.ogg' : 'sound/items/sheath.ogg', 50, 1)
	if(!supress_message_text)
		to_chat(user, "<span class='notice'>[src] [active ? "has been extended":"has been concealed"].</span>")

/obj/item/melee/transforming/armblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!mastersuit)
		to_chat(user, "<span class='notice'>[src] can only be used while attached to a hardsuit.</span>")
		return
	else
		..()

/obj/item/melee/transforming/armblade/attack_self(mob/living/carbon/user)
	if(!mastersuit)
		to_chat(user, "<span class='notice'>[src] can only be used while attached to a hardsuit.</span>")
		return
	else
		..()

/obj/item/clothing/suit/space/hardsuit
	var/obj/item/melee/transforming/armblade = null

/obj/item/clothing/suit/space/hardsuit/Initialize()
	if(jetpack && ispath(jetpack))
		jetpack = new jetpack(src)
	if(armblade && ispath(armblade))
		armblade = new armblade(src)
	. = ..()

/obj/item/clothing/suit/space/hardsuit/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/jetpack/suit))
		if(jetpack)
			to_chat(user, "<span class='warning'>[src] already has a jetpack installed.</span>")
			return
		if(src == user.get_item_by_slot(SLOT_WEAR_SUIT)) //Make sure the player is not wearing the suit before applying the upgrade.
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return

		if(user.transferItemToLoc(I, src))
			jetpack = I
			to_chat(user, "<span class='notice'>You successfully install the jetpack into [src].</span>")
			return
	else if(istype(I, /obj/item/screwdriver))
		if(!jetpack)
			to_chat(user, "<span class='warning'>[src] has no jetpack installed.</span>")
			return
		if(src == user.get_item_by_slot(SLOT_WEAR_SUIT))
			to_chat(user, "<span class='warning'>You cannot remove the jetpack from [src] while wearing it.</span>")
			return

		jetpack.turn_off(user)
		jetpack.forceMove(drop_location())
		jetpack = null
		to_chat(user, "<span class='notice'>You successfully remove the jetpack from [src].</span>")
		if(!armblade)
			to_chat(user, "<span class='warning'>[src] has no armblade installed.</span>")
			return
		if(src == user.get_item_by_slot(SLOT_WEAR_SUIT))
			to_chat(user, "<span class='warning'>You cannot remove the armblade from [src] while wearing it.</span>")
			return
		armblade.forceMove(drop_location())
		var/obj/item/melee/transforming/armblade/M = armblade
		if(M)
			M.mastersuit = null
		armblade = null
		to_chat(user, "<span class='notice'>You successfully remove the armblade from [src].</span>")
		return
	else if(istype(I, /obj/item/melee/transforming/armblade))
		if(armblade)
			to_chat(user, "<span class='warning'>[src] already has an armblade installed.</span>")
			return
		if(src == user.get_item_by_slot(SLOT_WEAR_SUIT))
			to_chat(user, "<span class='warning'>You cannot install the upgrade to [src] while wearing it.</span>")
			return

		if(user.transferItemToLoc(I, src))
			var/obj/item/melee/transforming/armblade/M = I
			M.mastersuit = src
			src.armblade = M
			to_chat(user, "<span class='notice'>You successfully install the armblade into [src].</span>")
			return
	return ..()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	..()
	if(jetpack)
		if(slot == SLOT_WEAR_SUIT)
			for(var/X in jetpack.actions)
				var/datum/action/A = X
				A.Grant(user)
	if(armblade)
		if(slot == SLOT_WEAR_SUIT)
			for(var/X in armblade.actions)
				var/datum/action/A = X
				A.Grant(user)

/obj/item/clothing/suit/space/hardsuit/dropped(mob/user)
	..()
	if(jetpack)
		for(var/X in jetpack.actions)
			var/datum/action/A = X
			A.Remove(user)
	if(armblade)
		for(var/X in armblade.actions)
			var/datum/action/A = X
			A.Remove(user)

//Power armor
/obj/item/clothing/head/helmet/space/hardsuit/powerarmor
	name = "Power Armor Helmet MK. I"
	desc = "An advanced helmet attached to a powered exoskeleton suit. Protects well against most forms of harm, but struggles against exotic hazards."
	icon = 'modular_skyrat/icons/obj/clothing/hats.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/head.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/head_muzzled.dmi'
	icon_state = "hardsuit0-powerarmor-1"
	item_state = "hardsuit0-powerarmor-1"
	hardsuit_type = "powerarmor"
	clothing_flags = THICKMATERIAL //Ouchie oofie my bones
	armor = list("melee" = 40, "bullet" = 35, "laser" = 30, "energy" = 20, "bomb" = 40, "bio" = 100, "rad" = 5, "fire" = 75, "acid" = 100, "wound" = 30)
	resistance_flags = ACID_PROOF
	mutantrace_variation = STYLE_MUZZLE | STYLE_NO_ANTHRO_ICON

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor/Initialize()
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	update_icon()

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor/update_overlays()
	. = ..()
	var/mutable_appearance/glass_overlay = mutable_appearance(icon, "hardsuit0-powerarmor-2")
	if(icon_state == "hardsuit1-powerarmor-1")
		glass_overlay = mutable_appearance(icon, "hardsuit1-powerarmor-2")
		var/mutable_appearance/flight_overlay = mutable_appearance(icon, "hardsuit1-powerarmor-3")
		flight_overlay.appearance_flags = RESET_COLOR
		. += flight_overlay
	glass_overlay.appearance_flags = RESET_COLOR
	. += glass_overlay

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor/worn_overlays(isinhands, icon_file, used_state, style_flags = NONE)
	. = ..()
	if(!isinhands)
		var/mutable_appearance/M1 = mutable_appearance(icon_file, "hardsuit0-powerarmor-2")
		if(icon_state == "hardsuit1-powerarmor-1")
			M1 = mutable_appearance(icon_file, "hardsuit1-powerarmor-2")
			var/mutable_appearance/M2 = mutable_appearance(icon, "hardsuit1-powerarmor-3")
			M2.appearance_flags = RESET_COLOR
			. += M2
		M1.appearance_flags = RESET_COLOR
		. += M1

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == SLOT_HEAD)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		DHUD.add_hud_to(user)
	if(suit)
		clothing_flags = suit.clothing_flags
		armor = suit.armor
		max_heat_protection_temperature = suit.max_heat_protection_temperature

/obj/item/clothing/head/helmet/space/hardsuit/powerarmor/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		var/datum/atom_hud/DHUD = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
		DHUD.remove_hud_from(user)

/obj/item/clothing/suit/space/hardsuit/powerarmor
	name = "Power Armor MK. I"
	desc = "A self-powered exoskeleton suit comprised of flexible Plasteel sheets and advanced components, designed to offer excellent protection while still allowing mobility. Does not protect against Space, and struggles against more exotic hazards."
	icon = 'modular_skyrat/icons/obj/clothing/suits.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/suit.dmi'
	anthro_mob_worn_overlay = 'modular_skyrat/icons/mob/clothing/suit_digi.dmi'
	icon_state = "hardsuit-powerarmor-1"
	item_state = "hardsuit-powerarmor-1"
	slowdown = -0.1
	clothing_flags = THICKMATERIAL //Not spaceproof. No, it isn't Spaceproof in Rimworld either.
	//armor = list("melee" = 40, "bullet" = 35, "laser" = 30, "energy" = 20, "bomb" = 40, "bio" = 100, "rad" = 5, "fire" = 75, "acid" = 100, "wound" = 30) //I was asked to buff this again. Here, fine.
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 100, "rad" = 0, "fire" = 0, "acid" = 100, "wound" = 30)
	resistance_flags = ACID_PROOF
	var/explodioprobemp = 1
	var/stamdamageemp = 200
	var/brutedamageemp = 20
	var/rebootdelay
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/powerarmor
	mutantrace_variation = STYLE_DIGITIGRADE | STYLE_NO_ANTHRO_ICON

	var/max_upgrades = 13
	/*explanation
	2 points from melee
	2 points from bullet
	2 points from laser
	1 point from energy
	2 points from bomb
	0 points from rad
	4 points from fire
	*/

	//armor upgrades
	var/armor_melee_upgrade = 0
	//costs 1: increases armor by 20. Max 5
	var/armor_bullet_upgrade = 0
	//costs 1: increases armor by 20. Max 5
	var/armor_laser_upgrade = 0
	//costs 1: increases armor by 20. Max 5
	var/armor_energy_upgrade = 0
	//costs 1: increases armor by 20. Max 5
	var/armor_bomb_upgrade = 0
	//costs 1: increases armor by 20. Max 5
	var/armor_rad_upgrade = 0
	//costs 1: increases armor by 20. Max 5
	var/armor_fire_upgrade = 0
	//costs 1: increases armor by 20. Max 5

	//misc upgrades
	var/spaceproof = FALSE
	//costs 7: makes armor spaceproof. Max 1
	var/speed_slowdown = 0
	//costs 1: makes armor speed faster. Max 9
	var/medical_upgrade = FALSE
	//costs 7: makes armor dispense chemicals. Max 1
	var/temperature_safe = FALSE
	//costs 4: makes armor safe to low/high temps. Max 1

/obj/item/clothing/suit/space/hardsuit/powerarmor/Initialize()
	. = ..()
	AddComponent(/datum/component/spraycan_paintable)
	update_icon()

/obj/item/clothing/suit/space/hardsuit/powerarmor/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/suit/space/hardsuit/powerarmor/process()
	if(medical_upgrade)
		if(istype(loc, /mob/living/carbon))
			var/mob/living/carbon/carbonLOC = loc
			if(carbonLOC.stat == CONSCIOUS)
				return
			carbonLOC.adjustOxyLoss(-3)
			carbonLOC.adjustBruteLoss(-3)
			carbonLOC.adjustFireLoss(-3)
			carbonLOC.adjustToxLoss(-3)
			//I would have injected reagents instead, but that is way more operations required
			//so this will just suffice. pretend the suit has nanobots that slowly repair the body back

/obj/item/clothing/suit/space/hardsuit/powerarmor/update_overlays()
	. = ..()
	var/mutable_appearance/black_overlay = mutable_appearance(icon, "hardsuit-powerarmor-2")
	black_overlay.appearance_flags = RESET_COLOR
	var/mutable_appearance/bluecore_overlay = mutable_appearance(icon, "hardsuit-powerarmor-3")
	bluecore_overlay.appearance_flags = RESET_COLOR
	. += black_overlay
	. += bluecore_overlay

/obj/item/clothing/suit/space/hardsuit/powerarmor/worn_overlays(isinhands, icon_file, used_state, style_flags = NONE)
	. = ..()
	if(!isinhands)
		var/mutable_appearance/M1 = mutable_appearance(icon_file, "hardsuit-powerarmor-2")
		M1.appearance_flags = RESET_COLOR
		var/mutable_appearance/M2 = mutable_appearance(icon_file, "hardsuit-powerarmor-3")
		M2.appearance_flags = RESET_COLOR
		. += M1
		. += M2

/obj/item/clothing/suit/space/hardsuit/powerarmor/emp_act()
	. = ..()
	var/mob/living/carbon/human/user = src.loc
	playsound(src.loc, 'modular_skyrat/sound/misc/suitmalf.ogg', 60, 1, 10)
	if (ishuman(user) && (user.wear_suit == src))
		to_chat(user, "<span class='danger'>The motors on your armor cease to function, causing the full weight of the suit to weigh on you all at once!</span>")
		user.emote("scream")
		user.adjustStaminaLoss(stamdamageemp)
		user.adjustBruteLoss(brutedamageemp)
	if(prob(explodioprobemp))
		playsound(src.loc, 'sound/effects/fuse.ogg', 60, 1, 10)
		visible_message("<span class ='warning'>The power module on the [src] begins to smoke, glowing with an alarming warmth! Get away from it, now!")
		addtimer(CALLBACK(src, .proc/detonate),50)
	else
		addtimer(CALLBACK(src, .proc/revivemessage), rebootdelay)
		return

/obj/item/clothing/suit/space/hardsuit/powerarmor/proc/revivemessage() //we use this proc to add a timer, so we can have it take a while to boot
	visible_message("<span class ='warning'>The power module on the [src] briefly flickers, before humming to life once more.</span>") //without causing any problems
	return //that sleep() would

/obj/item/clothing/suit/space/hardsuit/powerarmor/proc/detonate()
	visible_message("<span class ='danger'>The power module of the [src] overheats, causing it to destabilize and explode!")
	explosion(src.loc,0,0,3,flame_range = 3)
	qdel(src)
	return

/obj/item/clothing/suit/space/hardsuit/powerarmor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/powerarmor_upgrade))
		var/obj/item/powerarmor_upgrade/chosenUpgrade = I
		var/hypo_upgradeLeft = max_upgrades - chosenUpgrade.upgradecost
		if(hypo_upgradeLeft < 0)
			to_chat(user, "<span class='warning'>There is no more room for this upgrade!</span>")
			return
		var/chosen_number = chosenUpgrade.upgradetype
		switch(chosen_number)
			if(1)
				if(armor_melee_upgrade >= 100)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				armor_melee_upgrade += 20
				upgraded_armor()
			if(2)
				if(armor_bullet_upgrade >= 100)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				armor_bullet_upgrade += 20
				upgraded_armor()
			if(3)
				if(armor_laser_upgrade >= 100)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				armor_laser_upgrade += 20
				upgraded_armor()
			if(4)
				if(armor_energy_upgrade >= 100)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				armor_energy_upgrade += 20
				upgraded_armor()
			if(5)
				if(armor_bomb_upgrade >= 100)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				armor_bomb_upgrade += 20
				upgraded_armor()
			if(6)
				if(armor_rad_upgrade >= 100)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				armor_rad_upgrade += 20
				upgraded_armor()
			if(7)
				if(armor_fire_upgrade >= 100)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				armor_fire_upgrade += 20
				upgraded_armor()
			if(8)
				if(spaceproof)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				clothing_flags |= STOPSPRESSUREDAMAGE
			if(9)
				if(temperature_safe)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
			if(10)
				if(medical_upgrade)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				medical_upgrade = TRUE
				START_PROCESSING(SSobj, src)
			if(11)
				if(speed_slowdown >= 9)
					to_chat(user, "<span class='warning'>You cannot install any more of this upgrade!</span>")
					return
				if(!user.transferItemToLoc(chosenUpgrade, src))
					to_chat(user, "<span class='warning'>The upgrade is unable to leave your hand!</span>")
					return
				slowdown -= 0.1
		max_upgrades -= chosenUpgrade.upgradecost
		to_chat(user, "<span class='warning'>You install [chosenUpgrade] into [src].</span>")
		return
	else if(istype(I, /obj/item/crowbar))
		to_chat(user, "<span class='warning'>You pry off all the upgrades!</span>")
		for(var/obj/item/powerarmor_upgrade/paUpgrade in contents)
			paUpgrade.forceMove(drop_location())
		max_upgrades = 13
		medical_upgrade = FALSE
		STOP_PROCESSING(SSobj, src)
		slowdown = -0.1
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
		speed_slowdown = 0
		armor_fire_upgrade = 0
		armor_rad_upgrade = 0
		armor_bomb_upgrade = 0
		armor_energy_upgrade = 0
		armor_laser_upgrade = 0
		armor_bullet_upgrade = 0
		armor_melee_upgrade = 0
		upgraded_armor()
	else
		..()
	
/obj/item/powerarmor_upgrade
	name = "parent power armor upgrade"
	desc = "you shouldn't see this, contact jake park"
	icon = 'modular_skyrat/icons/obj/powerarmor_upgrades.dmi'
	icon_state = "armor_upgrade"
	var/upgradetype = 0
	var/upgradecost = 0

/obj/item/powerarmor_upgrade/melee_armor
	name = "melee armor upgrade"
	desc = "This upgrade increases melee armor by twenty. You can only install five of this upgrade. Costs one point."
	upgradetype = 1
	upgradecost = 1

/obj/item/powerarmor_upgrade/bullet_armor
	name = "bullet armor upgrade"
	desc = "This upgrade increases bullet armor by twenty. You can only install five of this upgrade. Costs one point."
	upgradetype = 2
	upgradecost = 1

/obj/item/powerarmor_upgrade/laser_armor
	name = "laser armor upgrade"
	desc = "This upgrade increases laser armor by twenty. You can only install five of this upgrade. Costs one point."
	upgradetype = 3
	upgradecost = 1

/obj/item/powerarmor_upgrade/energy_armor
	name = "energy armor upgrade"
	desc = "This upgrade increases energy armor by twenty. You can only install five of this upgrade. Costs one point."
	upgradetype = 4
	upgradecost = 1

/obj/item/powerarmor_upgrade/bomb_armor
	name = "bomb armor upgrade"
	desc = "This upgrade increases bomb armor by twenty. You can only install five of this upgrade. Costs one point."
	upgradetype = 5
	upgradecost = 1

/obj/item/powerarmor_upgrade/rad_armor
	name = "radiation armor upgrade"
	desc = "This upgrade increases radiation armor by twenty. You can only install five of this upgrade. Costs one point."
	upgradetype = 6
	upgradecost = 1

/obj/item/powerarmor_upgrade/fire_armor
	name = "fire armor upgrade"
	desc = "This upgrade increases fire armor by twenty. You can only install five of this upgrade. Costs one point."
	upgradetype = 7
	upgradecost = 1

/obj/item/powerarmor_upgrade/spaceproof
	name = "space-proof armor upgrade"
	desc = "This upgrade makes the armor space-proof. You can only install one of this upgrade. Costs seven points."
	icon_state = "space_upgrade"
	upgradetype = 8
	upgradecost = 7

/obj/item/powerarmor_upgrade/tempproof
	name = "temperature-resistant armor upgrade"
	desc = "This upgrade makes the armor temperature-resistant. You can only install one of this upgrade. Costs four points."
	icon_state = "temp_upgrade"
	upgradetype = 9
	upgradecost = 4

/obj/item/powerarmor_upgrade/healing
	name = "medical assistant armor upgrade"
	desc = "This upgrade makes the armor slowly heal the unconscious wearer. You can only install one of this upgrade. Costs seven points."
	icon_state = "heal_upgrade"
	upgradetype = 10
	upgradecost = 7

/obj/item/powerarmor_upgrade/speed
	name = "speed armor upgrade"
	desc = "This upgrade makes the armor space-proof. You can only install nine of this upgrade. Costs one point."
	icon_state = "speed_upgrade"
	upgradetype = 11
	upgradecost = 1

/obj/item/clothing/suit/space/hardsuit/powerarmor/proc/upgraded_armor()
	armor = list("melee" = armor_melee_upgrade, "bullet" = armor_bullet_upgrade, "laser" = armor_laser_upgrade, "energy" = armor_energy_upgrade, "bomb" = armor_bomb_upgrade, "bio" = 100, "rad" = armor_rad_upgrade, "fire" = armor_fire_upgrade, "acid" = 100, "wound" = 30)

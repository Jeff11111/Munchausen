//blueshit gloves
/obj/item/clothing/gloves/combat/blueshield
    name = "combat gloves"
    desc = "These tactical gloves appear to be unique, made out of double woven durathread fibers which make it fireproof as well as acid resistant"
    icon_state = "combat"
    item_state = "blackgloves"
    siemens_coefficient = 0
    permeability_coefficient = 0.05
    strip_delay = 80
    cold_protection = HANDS
    min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
    heat_protection = HANDS
    max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
    resistance_flags = FIRE_PROOF |  ACID_PROOF
    armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "wound" = 15)
    strip_mod = 1.5

//Power gloves (TM)
/obj/item/clothing/gloves/color/yellow/power
	name = "\proper Power Gloves (TM)"
	desc = "Produced by Not-tendo, these gloves are capable of both stunning and throwing lightning bolts at targets."
	icon = 'modular_skyrat/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/hands.dmi'
	icon_state = "powergloves"
	item_state = "powergloves"
	var/obj/item/stock_parts/cell/ourcell
	var/stamforce = 50
	var/stuncost = 250
	var/boltcost = 1000
	var/knockdown = TRUE
	var/knockdown_force = 100
	var/lightning_energy = 50
	var/bounces = 5
	var/mode = "none"
	var/worn = FALSE
	actions_types = list(/datum/action/item_action/powerglove)

/datum/action/item_action/powerglove
	name = "Change Mode"
	desc = "Change mode your powerglove's mode."

/obj/item/clothing/gloves/color/yellow/power/Initialize()
	..()
	ourcell = new /obj/item/stock_parts/cell(src)

/obj/item/clothing/gloves/color/yellow/power/examine(mob/user)
	. = ..()
	var/chargepercentage = ((ourcell.charge/ourcell.maxcharge) * 100)
	. += "<span class ='notice'>It's cell is <b>[chargepercentage]%</b> charged. <br>It is currently in [mode] mode.</span>"

/obj/item/clothing/gloves/color/yellow/power/equipped(mob/living/M, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		for(var/datum/action/item_action/A in actions_types)
			A.Grant(M, src)
		worn = TRUE

/obj/item/clothing/gloves/color/yellow/power/dropped(mob/living/M, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		for(var/datum/action/item_action/A in actions_types)
			A.Remove(M, src)
		worn = FALSE

/obj/item/clothing/gloves/color/yellow/power/ui_action_click(mob/living/user, action)
	if(istype(action, /datum/action/item_action/powerglove))
		if(mode == "none")
			mode = "stun"
			to_chat(user, "<span class='notice'>You will now stun your target.</span>")
		else if(mode == "stun")
			mode = "bolt"
			to_chat(user, "<span class='notice'>You will now throw a lightning bolt at your target.</span>")
		else
			mode = "none"
			to_chat(user, "<span class='notice'>You will now interact normally with your target.</span>")

/obj/item/clothing/gloves/color/yellow/power/Touch(atom/A, proximity)
	var/mob/user = usr
	if(!worn)
		return FALSE
	if(!user)
		return FALSE
	if(mode == "stun")
		if(isliving(A) && proximity)
			Stun(user, A, TRUE, knockdown_force)
			return TRUE
		return FALSE
	else if(mode == "bolt")
		if(isliving(A))
			Bolt(origin = user, target = A, bolt_energy = lightning_energy, bounces = 5, usecharge = TRUE)
			return TRUE
		return FALSE
	else
		return FALSE

/obj/item/clothing/gloves/color/yellow/power/proc/Stun(mob/user, mob/living/target, disarming = TRUE, knockdown_force = 100)
	if(!ourcell || !ourcell.use(stuncost))
		return FALSE
	var/stunpwr = stamforce
	var/stuncharge = ourcell.charge
	if(QDELETED(src) || QDELETED(ourcell)) //it was rigged (somehow?)
		return FALSE
	if(stuncharge < stuncost)
		target.visible_message("<span class='warning'>[user] has touched [target] with [src]. Luckily it was out of charge.</span>", \
							"<span class='warning'>[user] has touched you with [src]. Luckily it was out of charge.</span>")
		return FALSE
	if(knockdown)
		target.DefaultCombatKnockdown(knockdown_force, override_stamdmg = 0)
		target.adjustStaminaLoss(stunpwr)
	if(disarming)
		target.drop_all_held_items()
	target.apply_effect(EFFECT_STUTTER, stamforce)
	SEND_SIGNAL(target, COMSIG_LIVING_MINOR_SHOCK)
	if(user)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		target.visible_message("<span class='danger'>[user] has stunned [target] with [src]!</span>", \
								"<span class='userdanger'>[user] has stunned you with [src]!</span>")
		log_combat(user, target, "stunned")
	playsound(loc, 'sound/weapons/egloves.ogg', 100, 1, -1)
	return TRUE

/obj/item/clothing/gloves/color/yellow/power/proc/Bolt(mob/origin = usr, mob/target, bolt_energy = 50,bounces = 5, mob/user = usr, usecharge = TRUE)
	if(usecharge)
		if(!ourcell.use(boltcost))
			origin.visible_message("<span class='danger'>[origin] tries to harness lightning to throw at [target], but only sparks come out...</span>")
			return FALSE
	if(QDELETED(src) || QDELETED(ourcell)) //it was rigged (somehow?)
		return FALSE
	playsound(get_turf(origin), 'sound/magic/lightningshock.ogg', 150, 1, -1)
	origin.Beam(target,icon_state="lightning[rand(1,12)]",time=5, maxdistance = 7)
	var/mob/living/current = target
	if(bounces < 1)
		current.electrocute_act(bolt_energy,"Lightning Bolt", flags = SHOCK_TESLA)
		playsound(get_turf(current), 'sound/magic/lightningshock.ogg', 150, 1, -1)
	else
		current.electrocute_act(bolt_energy,"Lightning Bolt", flags = SHOCK_TESLA)
		playsound(get_turf(current), 'sound/magic/lightningshock.ogg', 150, 1, -1)
		var/list/possible_targets = new
		for(var/mob/living/M in view_or_range(7,target,"view"))
			if(user == M || target == M && los_check(current,M)) // || origin == M ? Not sure double shockings is good or not
				continue
			possible_targets += M
		if(!possible_targets.len)
			return
		var/mob/living/next = pick(possible_targets)
		if(next)
			Bolt(current,next,max((bolt_energy-5),5),bounces-1,user, usecharge = FALSE)

/obj/item/clothing/gloves/color/yellow/power/proc/los_check(atom/movable/user, mob/target)
	var/turf/user_turf = user.loc
	if(!istype(user_turf))
		return 0
	var/obj/dummy = new(user_turf)
	dummy.pass_flags |= PASSTABLE|PASSGLASS|PASSGRILLE
	for(var/turf/turf in getline(user_turf,target))
		if(turf.density)
			qdel(dummy)
			return 0
		for(var/atom/movable/AM in turf)
			if(!AM.CanPass(dummy,turf,1))
				qdel(dummy)
				return 0
	qdel(dummy)
	return 1

/obj/item/clothing/gloves/color/yellow/power/get_cell()
	return ourcell

/obj/item/clothing/gloves/color/yellow/power/debug/Initialize()
	..()
	qdel(ourcell)
	ourcell = new /obj/item/stock_parts/cell()
	ourcell.maxcharge = 9999999
	ourcell.charge = 9999999

//Sterile gloves
/obj/item/clothing/gloves/color/latex
	germ_level = 0
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 10, "bomb" = 0, "bio" = 100, "rad" = 60, "fire" = 0, "acid" = 100, "wound" = 0)

//Insuls
/obj/item/clothing/gloves/color/yellow
	armor = list("melee" = 5, "bullet" = 0, "laser" = 30, "energy" = 30, "bomb" = 0, "bio" = 60, "rad" = 100, "fire" = 60, "acid" = 100, "wound" = 0)

//Captin gloves
/obj/item/clothing/gloves/color/captain
	icon = 'modular_skyrat/icons/obj/clothing/captain.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/captain.dmi'
	desc = "Regal black gloves, with a nice silver trim, a diamond anti-shock coating, and an integrated thermal barrier. Swanky."
	armor = list("melee" = 20, "bullet" = 20, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 80, "rad" = 20, "fire" = 100, "acid" = 100, "wound" = 10)
	mutantrace_variation = STYLE_NO_ANTHRO_ICON
	icon_state = "shiny_gloves"
	item_state = "shiny_gloves"

//Leather gloves
/obj/item/clothing/gloves/botanic_leather
	name = "leather gloves"
	desc = "Gloves that protect you against mundane objects."
	armor = list("melee" = 15, "bullet" = 5, "laser" = 20, "energy" = 10, "bomb" = 30, "bio" = 40, "rad" = 60, "fire" = 80, "acid" = 80, "wound" = 5)
	icon = 'modular_skyrat/icons/obj/clothing/hydroponics.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/hydroponics.dmi'
	icon_state = "leathery"
	item_state = "leathery"

//Krav maga gloves (no longer krav maga)
/obj/item/clothing/gloves/krav_maga/sec
	name = "fingerless combat gloves"
	desc = "Kind of nullifies the point of being armored, doesn't it?"
	armor = list("melee" = 20, "bullet" = 20, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 0, "rad" = 20, "fire" = 0, "acid" = 0, "wound" = 10)
	icon = 'modular_skyrat/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/hands.dmi'
	icon_state = "fingerlesscombat"
	item_state = "fingerlesscombat"

//Black gloves
/obj/item/clothing/gloves/color/black
	icon = 'modular_skyrat/icons/obj/clothing/gloves.dmi'
	armor = list("melee" = 20, "bullet" = 20, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 60, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 10)
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/hands.dmi'
	icon_state = "black"
	item_state = "black"

//Combat gloves plus
/obj/item/clothing/gloves/krav_maga/combatglovesplus
	icon = 'modular_skyrat/icons/obj/clothing/gloves.dmi'
	armor = list("melee" = 20, "bullet" = 20, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 60, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 10)
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/hands.dmi'
	icon_state = "comfycombat"
	item_state = "comfycombat"

//Fingerless gloves
/obj/item/clothing/gloves/fingerless
	icon = 'modular_skyrat/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/hands.dmi'
	icon_state = "fingerless"
	item_state = "fingerless"

//CE gloves
/obj/item/clothing/gloves/color/black/ce
	name = "impact gloves"
	desc = "Thick  impact-resistant black leather gloves. Fancy."
	armor = list("melee" = 20, "bullet" = 20, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 60, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 10)
	icon = 'modular_skyrat/icons/obj/clothing/gloves.dmi'
	mob_overlay_icon = 'modular_skyrat/icons/mob/clothing/hands.dmi'
	icon_state = "comfy"
	item_state = "comfy"
	siemens_coefficient = 0.5
	force = 5

//Tacklers
/obj/item/clothing/gloves/tackler/combat
	armor = list("melee" = 25, "bullet" = 25, "laser" = 10, "energy" = 10, "bomb" = 30, "bio" = 60, "rad" = 20, "fire" = 100, "acid" = 50, "wound" = 10)

#define MODE_MULTIPLE "multiple limbs"
#define MODE_SINGULAR "single limb"

/obj/item/stack/medical
	name = "medical pack"
	singular_name = "medical pack"
	icon = 'modular_skyrat/icons/obj/medical.dmi'
	amount = 16
	max_amount = 16
	w_class = WEIGHT_CLASS_TINY
	full_w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	resistance_flags = FLAMMABLE
	max_integrity = 40
	novariants = FALSE
	item_flags = NOBLUDGEON
	germ_level = 0
	var/self_delay = 15
	var/other_delay = 10
	var/repeating = TRUE
	/// How much brute we heal per application
	var/heal_brute
	/// How much burn we heal per application
	var/heal_burn
	/// How much we heal stamina on application
	var/heal_stamina
	/// How much we reduce bleeding per application on cut wounds
	var/stop_bleeding
	/// How much sanitization to apply to burns on application
	var/sanitization
	/// How much we add to flesh_healing for burn wounds on application
	var/flesh_regeneration
	/// The limb status flags we require to be applicable on a limb
	var/required_status = BODYPART_ORGANIC
	/// What mode we're on (multiple limbs, singular limb)
	var/mode = MODE_MULTIPLE
	/// Cost per injury or limb to apply healing
	var/stackperuse = 1

/obj/item/stack/medical/attack(mob/living/M, mob/user)
	. = ..()
	if(!INTERACTING_WITH(user, M))
		try_heal(M, user)
	else
		to_chat(user, "<span class='warning'>You're already interacting with \the [M]!")

/obj/item/stack/medical/proc/try_heal(mob/living/M, mob/user, silent = FALSE, obj/item/bodypart/specific_part)
	if(!M.can_inject(user, TRUE))
		return
	var/time_mod = 1

	//Medical skill affects the speed of the do_mob
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	
	if(M == user)
		if(!silent)
			user.visible_message("<span class='notice'>[user] starts to apply \the [src] on [user.p_them()]self...</span>", "<span class='notice'>You begin applying \the [src] on yourself...</span>")
		if(!do_mob(user, M, self_delay * time_mod, extra_checks=CALLBACK(M, /mob/living/proc/can_inject, user, TRUE)))
			return
	else if(other_delay)
		if(!silent)
			user.visible_message("<span class='notice'>[user] starts to apply \the [src] on [M].</span>", "<span class='notice'>You begin applying \the [src] on [M]...</span>")
		if(!do_mob(user, M, other_delay * time_mod, extra_checks=CALLBACK(M, /mob/living/proc/can_inject, user, TRUE)))
			return

	if(heal(M, user))
		log_combat(user, M, "healed", src.name)
		var/obj/item/bodypart/BP = M.get_bodypart(user.zone_selected)
		if(repeating && (amount > 0) && (!BP || (BP.brute_dam && heal_brute) || (BP.burn_dam && heal_burn) || (BP.stamina_dam && heal_stamina)))
			try_heal(M, user, TRUE)

/obj/item/stack/medical/proc/heal(mob/living/M, mob/user, silent = FALSE, obj/item/bodypart/specific_part)
	return

/obj/item/stack/medical/proc/heal_carbon(mob/living/carbon/C, mob/user, brute, burn, silent = FALSE, affect_children = FALSE, obj/item/bodypart/specific_part)
	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
	if(specific_part)
		affecting = specific_part
	if(!affecting) //Missing limb?
		if(!silent)
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
		return
	if(!(affecting.status & required_status)) //Limb must satisfy these status requirements
		if(!silent)
			to_chat(user, "<span class='warning'>\The [src] won't work on that limb!</span>")
		return
	if(affecting.brute_dam && brute || affecting.burn_dam && burn)
		if(!silent)
			user.visible_message("<span class='green'>[user] applies \the [src] on [C]'s [affecting.name].</span>", "<span class='green'>You apply \the [src] on [C]'s [affecting.name].</span>")
		if(affecting.heal_damage(brute, burn, heal_stamina, FALSE, FALSE, TRUE))
			C.update_damage_overlays()
		use(stackperuse)
		if(affect_children)
			if(length(affecting.heal_zones))
				for(var/bodypart in affecting.heal_zones)
					var/obj/item/bodypart/child = C.get_bodypart(bodypart)
					if(!child)
						continue
					heal_carbon(C, user, brute, burn, TRUE, FALSE, child)
		return TRUE
	if(!silent)
		to_chat(user, "<span class='warning'>[C]'s [affecting.name] can not be healed with \the [src]!</span>")

/obj/item/stack/medical/bruise_pack
	name = "bruise pack"
	singular_name = "bruise pack"
	desc = "A therapeutic gel pack and bandages designed to treat blunt-force trauma."
	icon_state = "brutepack"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	heal_brute = 40
	self_delay = 30
	other_delay = 20
	amount = 12
	max_amount = 12
	grind_results = list(/datum/reagent/medicine/styptic_powder = 10)

/obj/item/stack/medical/bruise_pack/one
	amount = 1

/obj/item/stack/medical/bruise_pack/heal(mob/living/M, mob/user, silent = FALSE)
	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if (!(critter.healable))
			if(!silent)
				to_chat(user, "<span class='warning'>You cannot use \the [src] on [M]!</span>")
			return FALSE
		else if (critter.health >= critter.maxHealth)
			if(!silent)
				to_chat(user, "<span class='notice'>[M] is at full health.</span>")
			return FALSE
		if(!silent)
			user.visible_message("<span class='green'>[user] applies \the [src] on [M].</span>", "<span class='green'>You apply \the [src] on [M].</span>")
		M.heal_bodypart_damage((heal_brute/2))
		use(stackperuse)
		return TRUE
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, heal_burn, FALSE, (mode == MODE_MULTIPLE ? TRUE : FALSE))
	if(!silent)
		to_chat(user, "<span class='warning'>You can't heal [M] with \the [src]!</span>")

/obj/item/stack/medical/bruise_pack/heal_carbon(mob/living/carbon/C, mob/user, brute, burn, silent, affect_children, obj/item/bodypart/specific_part)
	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
	if(specific_part)
		affecting = specific_part
	if(!affecting) //Missing limb?
		if(!silent)
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
		return
	if(!(affecting.status & required_status)) //Limb must satisfy these status requirements
		if(!silent)
			to_chat(user, "<span class='warning'>\The [src] won't work on that limb!</span>")
		return
	if(affecting.is_bandaged())
		if(!silent)
			to_chat(user, "<span class='warning'>All wounds on \the [affecting] have been bandaged up!</span>")
		return
	if(affecting.brute_dam || affecting.burn_dam)
		var/heymedic = GET_SKILL_LEVEL(user, firstaid)
		for(var/datum/injury/IN in affecting.injuries)
			if(IN.is_bandaged())
				continue
			if(!do_mob(user, C, IN.damage / (heymedic/2.5)))
				to_chat(user, "<span class='warning'>I must stand still!</span>")
				return
			var/diceroll = user.mind?.diceroll(skills = heymedic)
			if(!(diceroll >= DICE_CRIT_SUCCESS) && !use(stackperuse))
				to_chat(user, "<span class='warning'>All used up...</span>")
				return
			if(diceroll >= DICE_CRIT_SUCCESS)
				to_chat(user, "<span class='nicegreen'>I manage to economize on \the [src]'s use.</span>")
			if(IN.current_stage <= IN.max_bleeding_stage)
				user.visible_message("<span class='notice'>\The [user] bandages \a [IN.desc] on [C]'s [affecting.name].", \
									"I bandage \a [IN.desc] on [C]'s [affecting.name].")
			else if(IN.damage_type == WOUND_BLUNT)
				user.visible_message("\The [user] places a bruise patch over \a [IN.desc] on [C]'s [affecting.name].", \
									"I place a bruise patch over \a [IN.desc] on [C]'s [affecting.name].")
			else
				user.visible_message("\The [user] places a bandaid over \a [IN.desc] on [C]'s [affecting.name].", \
									"I place a bandaid over \a [IN.desc] on [C]'s [affecting.name].")
			IN.bandage()
		if(affect_children)
			if(length(affecting.heal_zones))
				for(var/bodypart in affecting.heal_zones)
					var/obj/item/bodypart/child = C.get_bodypart(bodypart)
					if(!child)
						continue
					heal_carbon(C, user, brute, burn, TRUE, FALSE, child)
		return TRUE
	if(!silent)
		to_chat(user, "<span class='warning'>[C]'s [affecting.name] can not be healed with \the [src]!</span>")

/obj/item/stack/medical/bruise_pack/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is bludgeoning [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return (BRUTELOSS)

/obj/item/stack/medical/gauze
	name = "medical gauze"
	desc = "A roll of elastic cloth, perfect for stabilizing all kinds of wounds, from cuts and burns, to broken bones. "
	gender = PLURAL
	singular_name = "medical gauze"
	icon_state = "gauze"
	self_delay = 30
	other_delay = 20
	amount = 16
	max_amount = 16
	custom_price = PRICE_EXPENSIVE
	absorption_rate = 0.25
	absorption_capacity = 5
	splint_factor = 0.35

/obj/item/stack/medical/gauze/try_heal(mob/living/M, mob/user, silent = FALSE, obj/item/bodypart/specific_part)
	var/obj/item/bodypart/limb = M.get_bodypart(check_zone(user.zone_selected))
	if(specific_part)
		limb = specific_part
	if(!limb)
		if(!silent)
			to_chat(user, "<span class='notice'>There's nothing there to bandage!</span>")
		return
	if(limb.current_gauze && (limb.current_gauze.absorption_capacity * 0.8 > absorption_capacity)) // ignore if our new wrap is < 20% better than the current one, so someone doesn't bandage it 5 times in a row
		if(!silent)
			to_chat(user, "<span class='warning'>The bandage currently on [user==M ? "your" : "[M]'s"] [limb.name] is still in good condition!</span>")
		return

	if(!silent)
		user.visible_message("<span class='warning'>[user] begins wrapping the wounds on [M]'s [limb.name] with [src]...</span>", "<span class='warning'>You begin wrapping \the [src.name] on [user == M ? "your" : "[M]'s"] [limb.name]...</span>")
	var/time_mod = 1
	//Medical skill affects the speed of the do_after
	if(user.mind)
		var/datum/skills/firstaid/firstaid = GET_SKILL(user, firstaid)
		if(firstaid)
			time_mod *= firstaid.get_medicalstack_mod()
	if(!do_after(user, (user == M ? self_delay : other_delay) * time_mod, target=M))
		return

	if(!silent)
		user.visible_message("<span class='green'>[user] applies [src] to [M]'s [limb.name].</span>", "<span class='green'>You bandage [user == M ? "your" : "[M]'s"] [limb.name].</span>")
	limb.apply_gauze(src)
	if(mode == MODE_MULTIPLE)
		for(var/bodypart in limb.heal_zones)
			var/obj/item/bodypart/child = M.get_bodypart(bodypart)
			if(!child || !length(child.wounds))
				continue
			try_heal(M, user, silent, child, TRUE)

/obj/item/stack/medical/gauze/twelve
	amount = 12

/obj/item/stack/medical/gauze/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.get_sharpness())
		if(get_amount() < 2)
			to_chat(user, "<span class='warning'>You need at least two gauzes to do this!</span>")
			return
		new /obj/item/stack/sheet/cloth(user.drop_location())
		user.visible_message("<span class='notice'>[user] cuts [src] into pieces of cloth with [I].</span>", \
					 "<span class='notice'>You cut [src] into pieces of cloth with [I].</span>", \
					 "<span class='hear'>You hear cutting.</span>")
		use(2)
	else if(I.is_drainable() && I.reagents.has_reagent(/datum/reagent/space_cleaner/sterilizine))
		if(!I.reagents.has_reagent(/datum/reagent/space_cleaner/sterilizine, 5))
			to_chat(user, "<span class='warning'>There's not enough sterilizine in [I] to sterilize [src]!</span>")
			return
		user.visible_message("<span class='notice'>[user] pours the contents of [I] onto [src], sterilizing it.</span>", "<span class='notice'>You pour the contents of [I] onto [src], sterilizing it.</span>")
		I.reagents.remove_reagent(/datum/reagent/space_cleaner/sterilizine, 5)
		new /obj/item/stack/medical/gauze/adv/one(user.drop_location())
		use(1)
	else
		return ..()

/obj/item/stack/medical/gauze/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] begins tightening \the [src] around [user.p_their()] neck! It looks like [user.p_they()] forgot how to use medical supplies!</span>")
	return OXYLOSS

/obj/item/stack/medical/gauze/improvised
	name = "improvised gauze"
	singular_name = "improvised gauze"
	desc = "A roll of cloth roughly cut from something that does a decent job of stabilizing wounds, but less efficiently so than real medical gauze."
	self_delay = 45
	other_delay = 30
	absorption_rate = 0.15
	absorption_capacity = 4

/obj/item/stack/medical/gauze/cyborg
	custom_materials = null
	is_cyborg = 1
	cost = 250

/obj/item/stack/medical/gauze/adv
	name = "sterilized medical gauze"
	desc = "A roll of elastic sterilized cloth that is extremely effective at stopping bleeding, heals minor wounds and cleans them."
	singular_name = "sterilized medical gauze"
	icon = 'modular_skyrat/icons/obj/medical.dmi'
	icon_state = "adv_gauze"
	heal_brute = 5
	self_delay = 22.5
	other_delay = 15
	absorption_rate = 0.4
	absorption_capacity = 6

/obj/item/stack/medical/gauze/adv/one
	amount = 1

/obj/item/stack/medical/suture
	name = "suture"
	desc = "Basic sterile sutures used to seal up cuts and lacerations and stop bleeding."
	gender = PLURAL
	singular_name = "suture"
	icon_state = "suture"
	self_delay = 15
	other_delay = 10
	amount = 16
	max_amount = 16
	repeating = TRUE
	heal_brute = 10
	stop_bleeding = 0.6
	grind_results = list(/datum/reagent/medicine/spaceacillin = 2)

/obj/item/stack/medical/suture/heal_carbon(mob/living/carbon/C, mob/user, brute, burn, silent, affect_children, obj/item/bodypart/specific_part)
	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
	if(specific_part)
		affecting = specific_part
	if(!affecting) //Missing limb?
		if(!silent)
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
		return
	if(!(affecting.status & required_status)) //Limb must satisfy these status requirements
		if(!silent)
			to_chat(user, "<span class='warning'>\The [src] won't work on that limb!</span>")
		return
	var/has_cut_or_pierce = FALSE
	for(var/datum/injury/IN in affecting.injuries)
		if(IN.damage && IN.is_bleeding())
			has_cut_or_pierce = TRUE
			break
	if(!has_cut_or_pierce)
		if(!silent)
			to_chat(user, "<span class='warning'>All wounds on \the [affecting] have been closed up!</span>")
		return
	if(affecting.brute_dam || affecting.burn_dam)
		var/heymedic = GET_SKILL_LEVEL(user, firstaid)
		for(var/datum/injury/IN in affecting.injuries)
			if(IN.is_clamped())
				continue
			if(!do_mob(user, C, 1 SECONDS - (heymedic/4)))
				to_chat(user, "<span class='warning'>I must stand still!</span>")
				return
			var/diceroll = user.mind?.diceroll(skills = heymedic)
			if(!(diceroll >= DICE_CRIT_SUCCESS) && !use(stackperuse))
				to_chat(user, "<span class='warning'>All used up...</span>")
				return
			if(diceroll >= DICE_CRIT_SUCCESS)
				to_chat(user, "<span class='nicegreen'>I manage to economize on \the [src]'s use.</span>")
			if(IN.damage >= IN.autoheal_cutoff)
				user.visible_message("<span class='notice'>\The [user] partially closes a wound on [C]'s [affecting.name] with \the [src].</span>", \
				"<span class='notice'>I partially close a wound on [C]'s [affecting.name] with \the [src].</span>")
				IN.heal_damage(rand(heal_brute/2, heal_brute))
			else
				user.visible_message("<span class='notice'>\The [user] closes a wound on [C]'s [affecting.name] with \the [src].</span>", \
				"<span class='notice'>I close a wound on [C]'s [affecting.name] with \the [src].</span>")
				if(!IN.damage)
					qdel(IN)
				else if(IN.damage <= IN.autoheal_cutoff)
					IN.clamp_injury()
		affecting.update_injuries()
		if(affect_children)
			if(length(affecting.heal_zones))
				for(var/bodypart in affecting.heal_zones)
					var/obj/item/bodypart/child = C.get_bodypart(bodypart)
					if(!child)
						continue
					heal_carbon(C, user, brute, burn, TRUE, FALSE, child)
		return TRUE
	if(!silent)
		to_chat(user, "<span class='warning'>[C]'s [affecting.name] can not be healed with \the [src]!</span>")

/obj/item/stack/medical/suture/one
	amount = 1

/obj/item/stack/medical/suture/five
	amount = 5

/obj/item/stack/medical/suture/emergency
	name = "emergency suture"
	desc = "A value pack of cheap sutures, not very good at repairing damage, but still decent at stopping bleeding."
	heal_brute = 5
	amount = 6
	max_amount = 6

/obj/item/stack/medical/suture/medicated
	name = "medicated suture"
	icon_state = "suture_purp"
	desc = "A suture infused with drugs that speed up wound healing of the treated laceration."
	heal_brute = 20
	stop_bleeding = 0.75
	grind_results = list(/datum/reagent/medicine/polypyr = 2)

/obj/item/stack/medical/suture/one
	amount = 1

/obj/item/stack/medical/suture/heal(mob/living/M, mob/user, silent = FALSE, obj/item/bodypart/specific_part)
	. = ..()
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, heal_burn, FALSE, (mode == MODE_MULTIPLE ? TRUE : FALSE))
	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if (!(critter.healable))
			if(!silent)
				to_chat(user, "<span class='warning'>You cannot use \the [src] on [M]!</span>")
			return FALSE
		else if (critter.health >= critter.maxHealth)
			if(!silent)
				to_chat(user, "<span class='notice'>[M] is at full health.</span>")
			return FALSE
		if(!silent)
			user.visible_message("<span class='green'>[user] applies \the [src] on [M].</span>", "<span class='green'>You apply \the [src] on [M].</span>")
		M.heal_bodypart_damage(heal_brute)
		use(stackperuse)
		return TRUE

	to_chat(user, "<span class='warning'>You can't heal [M] with \the [src]!</span>")

/obj/item/stack/medical/ointment
	name = "ointment"
	desc = "Basic burn ointment, rated effective for second degree burns, though it's still an effective stabilizer for worse injuries. Not terribly good at outright healing, however."
	gender = PLURAL
	singular_name = "ointment"
	icon_state = "ointment"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	amount = 12
	max_amount = 12
	self_delay = 30
	other_delay = 20
	amount = 12
	max_amount = 12
	heal_burn = 10
	flesh_regeneration = 2
	sanitization = 1.5 //Doesn't actually matter much, straight up disinfects
	grind_results = list(/datum/reagent/medicine/spaceacillin = 5)
	repeating = FALSE

/obj/item/stack/medical/ointment/one
	amount = 1

/obj/item/stack/medical/ointment/heal(mob/living/M, mob/user, silent = FALSE, obj/item/bodypart/specific_part)
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, heal_burn, FALSE, (mode == MODE_MULTIPLE ? TRUE : FALSE))
	if(!silent)
		to_chat(user, "<span class='warning'>You can't heal [M] with \the [src]!</span>")

/obj/item/stack/medical/ointment/heal_carbon(mob/living/carbon/C, mob/user, brute, burn, silent, affect_children, obj/item/bodypart/specific_part)
	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
	if(specific_part)
		affecting = specific_part
	if(!affecting) //Missing limb?
		if(!silent)
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
		return
	if(!(affecting.status & required_status)) //Limb must satisfy these status requirements
		if(!silent)
			to_chat(user, "<span class='warning'>\The [src] won't work on that limb!</span>")
		return
	if(affecting.is_salved())
		if(!silent)
			to_chat(user, "<span class='warning'>All wounds on \the [affecting] have been salved!</span>")
		return
	if(affecting.brute_dam || affecting.burn_dam)
		var/heymedic = GET_SKILL_LEVEL(user, firstaid)
		for(var/datum/injury/IN in affecting.injuries)
			if(IN.is_salved() && IN.is_disinfected())
				continue
			if(!do_mob(user, C, 1 SECONDS - (heymedic/4)))
				to_chat(user, "<span class='warning'>I must stand still!</span>")
				return
			var/diceroll = user.mind?.diceroll(skills = heymedic)
			if(!(diceroll >= DICE_CRIT_SUCCESS) && !use(stackperuse))
				to_chat(user, "<span class='warning'>All used up...</span>")
				return
			if(diceroll >= DICE_CRIT_SUCCESS)
				to_chat(user, "<span class='nicegreen'>I manage to economize on \the [src]'s use.</span>")
			user.visible_message("<span class='notice'>\The [user] salves \a [IN.desc] on [C]'s [affecting.name].", \
								"I salve \a [IN.desc] on [C]'s [affecting.name].")
			IN.salve()
			IN.disinfect()
		if(affect_children)
			if(length(affecting.heal_zones))
				for(var/bodypart in affecting.heal_zones)
					var/obj/item/bodypart/child = C.get_bodypart(bodypart)
					if(!child)
						continue
					heal_carbon(C, user, brute, burn, TRUE, FALSE, child)
		return TRUE
	if(!silent)
		to_chat(user, "<span class='warning'>[C]'s [affecting.name] can not be healed with \the [src]!</span>")

/obj/item/stack/medical/ointment/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is squeezing \the [src] into [user.p_their()] mouth! [user.p_do(TRUE)]n't [user.p_they()] know that stuff is toxic?</span>")
	return TOXLOSS

/obj/item/stack/medical/mesh
	name = "regenerative mesh"
	desc = "A bacteriostatic mesh used to dress injuries."
	gender = PLURAL
	singular_name = "regenerative mesh"
	icon_state = "regen_mesh"
	self_delay = 15
	other_delay = 10
	amount = 16
	heal_burn = 10
	max_amount = 16
	repeating = TRUE
	sanitization = 0.75
	flesh_regeneration = 3
	grind_results = list(/datum/reagent/medicine/silver_sulfadiazine = 5)
	var/is_open = TRUE ///This var determines if the sterile packaging of the mesh has been opened.

/obj/item/stack/medical/mesh/heal(mob/living/M, mob/user, silent = FALSE, obj/item/bodypart/specific_part)
	. = ..()
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, heal_burn, FALSE, (mode == MODE_MULTIPLE ? TRUE : FALSE))
	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if (!(critter.healable))
			if(!silent)
				to_chat(user, "<span class='warning'>You cannot use \the [src] on [M]!</span>")
			return FALSE
		else if (critter.health >= critter.maxHealth)
			if(!silent)
				to_chat(user, "<span class='notice'>[M] is at full health.</span>")
			return FALSE
		if(!silent)
			user.visible_message("<span class='green'>[user] applies \the [src] on [M].</span>", "<span class='green'>You apply \the [src] on [M].</span>")
		M.heal_bodypart_damage(heal_brute, heal_burn)
		use(stackperuse)
		return TRUE

	to_chat(user, "<span class='warning'>You can't heal [M] with \the [src]!</span>")

/obj/item/stack/medical/mesh/heal_carbon(mob/living/carbon/C, mob/user, brute, burn, silent, affect_children, obj/item/bodypart/specific_part)
	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
	if(specific_part)
		affecting = specific_part
	if(!affecting) //Missing limb?
		if(!silent)
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
		return
	if(!(affecting.status & required_status)) //Limb must satisfy these status requirements
		if(!silent)
			to_chat(user, "<span class='warning'>\The [src] won't work on that limb!</span>")
		return
	if(affecting.is_salved() && affecting.is_bandaged())
		if(!silent)
			to_chat(user, "<span class='warning'>All wounds on \the [affecting] have been salved and bandaged up!</span>")
		return
	if(affecting.brute_dam || affecting.burn_dam)
		var/heymedic = GET_SKILL_LEVEL(user, firstaid)
		for(var/datum/injury/IN in affecting.injuries)
			if(IN.is_salved())
				continue
			if(!do_mob(user, C, 1 SECONDS - (heymedic/4)))
				to_chat(user, "<span class='warning'>I must stand still!</span>")
				return
			var/diceroll = user.mind?.diceroll(skills = heymedic)
			if(!(diceroll >= DICE_CRIT_SUCCESS) && !use(stackperuse))
				to_chat(user, "<span class='warning'>All used up...</span>")
				return
			if(diceroll >= DICE_CRIT_SUCCESS)
				to_chat(user, "<span class='nicegreen'>I manage to economize on \the [src]'s use.</span>")
			if(IN.damage >= IN.autoheal_cutoff)
				user.visible_message("<span class='notice'>\The [user] partially bandages a wound on [C]'s [affecting.name] with \the [src].</span>", \
				"<span class='notice'>I partially bandage a wound on [C]'s [affecting.name] with \the [src].</span>")
				IN.heal_damage(rand(heal_burn/2, heal_burn))
				IN.germ_level = max(0, IN.germ_level - (WOUND_SANITIZATION_STERILIZER * sanitization))
			else
				user.visible_message("<span class='notice'>\The [user] bandages a wound on [C]'s [affecting.name] with \the [src].</span>", \
				"<span class='notice'>I bandage a wound on [C]'s [affecting.name] with \the [src].</span>")
				IN.germ_level = max(0, IN.germ_level - (WOUND_SANITIZATION_STERILIZER * sanitization))
				if(!IN.damage)
					qdel(IN)
				else if(IN.damage <= IN.autoheal_cutoff)
					IN.salve()
					IN.bandage()
		affecting.update_injuries()
		if(affect_children)
			if(length(affecting.heal_zones))
				for(var/bodypart in affecting.heal_zones)
					var/obj/item/bodypart/child = C.get_bodypart(bodypart)
					if(!child)
						continue
					heal_carbon(C, user, brute, burn, TRUE, FALSE, child)
		return TRUE
	if(!silent)
		to_chat(user, "<span class='warning'>[C]'s [affecting.name] can not be healed with \the [src]!</span>")

/obj/item/stack/medical/mesh/one
	amount = 1

/obj/item/stack/medical/mesh/five
	amount = 5

/obj/item/stack/medical/mesh/advanced
	name = "advanced regenerative mesh"
	desc = "An advanced mesh made with aloe extracts and sterilizing chemicals, used to treat burns."
	gender = PLURAL
	singular_name = "advanced regenerative mesh"
	icon_state = "aloe_mesh"
	heal_burn = 20
	sanitization = 1.25
	flesh_regeneration = 3.5
	grind_results = list(/datum/reagent/consumable/aloejuice = 5, /datum/reagent/medicine/spaceacillin = 5)

/obj/item/stack/medical/mesh/advanced/one
	amount = 1

/obj/item/stack/medical/mesh/Initialize()
	. = ..()
	if(amount == max_amount)	 //only seal full mesh packs
		is_open = FALSE
		update_icon()

/obj/item/stack/medical/mesh/advanced/update_icon_state()
	if(!is_open)
		icon_state = "aloe_mesh_closed"
	else
		return ..()

/obj/item/stack/medical/mesh/update_icon_state()
	if(!is_open)
		icon_state = "regen_mesh_closed"
	else
		return ..()

/obj/item/stack/medical/mesh/heal(mob/living/M, mob/user, silent = FALSE, obj/item/bodypart/specific_part)
	. = ..()
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, heal_burn, FALSE, (mode == MODE_MULTIPLE ? TRUE : FALSE))
	if(!silent)
		to_chat(user, "<span class='warning'>You can't heal [M] with \the [src]!</span>")


/obj/item/stack/medical/mesh/try_heal(mob/living/M, mob/user, silent = FALSE, obj/item/bodypart/specific_part)
	if(!is_open)
		if(!silent)
			to_chat(user, "<span class='warning'>You need to open [src] first.</span>")
		return
	. = ..()

/obj/item/stack/medical/mesh/AltClick(mob/living/user)
	if(!is_open)
		to_chat(user, "<span class='warning'>You need to open [src] first.</span>")
		return
	. = ..()

/obj/item/stack/medical/mesh/attack_hand(mob/user)
	if(!is_open && user.get_inactive_held_item() == src)
		to_chat(user, "<span class='warning'>You need to open [src] first.</span>")
		return
	. = ..()

/obj/item/stack/medical/mesh/attack_self(mob/user)
	if(!is_open)
		is_open = TRUE
		to_chat(user, "<span class='notice'>You open the sterile mesh package.</span>")
		update_icon()
		playsound(src, 'sound/items/poster_ripped.ogg', 20, TRUE)
		return
	. = ..()

/obj/item/stack/medical/aloe
	name = "aloe cream"
	desc = "A healing paste you can apply on wounds."

	icon_state = "aloe_paste"
	self_delay = 15
	other_delay = 10
	novariants = TRUE
	amount = 16
	max_amount = 16
	heal_brute = 6
	heal_burn = 6
	sanitization = 1.5
	grind_results = list(/datum/reagent/consumable/aloejuice = 1)
	repeating = FALSE

/obj/item/stack/medical/aloe/heal(mob/living/M, mob/user, silent = FALSE, obj/item/bodypart/specific_part)
	. = ..()
	if(iscarbon(M))
		return heal_carbon(M, user, heal_brute, heal_burn, FALSE, (mode == MODE_MULTIPLE ? TRUE : FALSE))
	if(isanimal(M))
		var/mob/living/simple_animal/critter = M
		if (!(critter.healable))
			if(!silent)
				to_chat(user, "<span class='warning'>You cannot use \the [src] on [M]!</span>")
			return FALSE
		else if (critter.health >= critter.maxHealth)
			if(!silent)
				to_chat(user, "<span class='notice'>[M] is at full health.</span>")
			return FALSE
		if(!silent)
			user.visible_message("<span class='green'>[user] applies \the [src] on [M].</span>", "<span class='green'>You apply \the [src] on [M].</span>")
		M.heal_bodypart_damage(heal_brute, heal_burn)
		use(stackperuse)
		return TRUE

	if(!silent)
		to_chat(user, "<span class='warning'>You can't heal [M] with the \the [src]!</span>")

/obj/item/stack/medical/aloe/heal_carbon(mob/living/carbon/C, mob/user, brute, burn, silent, affect_children, obj/item/bodypart/specific_part)
	var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
	if(specific_part)
		affecting = specific_part
	if(!affecting) //Missing limb?
		if(!silent)
			to_chat(user, "<span class='warning'>[C] doesn't have \a [parse_zone(user.zone_selected)]!</span>")
		return
	if(!(affecting.status & required_status)) //Limb must satisfy these status requirements
		if(!silent)
			to_chat(user, "<span class='warning'>\The [src] won't work on that limb!</span>")
		return
	if(affecting.is_salved())
		if(!silent)
			to_chat(user, "<span class='warning'>All wounds on \the [affecting] have been salved!</span>")
		return
	if(affecting.brute_dam || affecting.burn_dam)
		var/heymedic = GET_SKILL_LEVEL(user, firstaid)
		for(var/datum/injury/IN in affecting.injuries)
			if(IN.is_salved() && (IN.damage >= IN.autoheal_cutoff))
				continue
			if(!do_mob(user, C, 1 SECONDS - (heymedic/4)))
				to_chat(user, "<span class='warning'>I must stand still!</span>")
				return
			var/diceroll = user.mind?.diceroll(skills = heymedic)
			if(!(diceroll >= DICE_CRIT_SUCCESS) && !use(stackperuse))
				to_chat(user, "<span class='warning'>All used up...</span>")
				return
			if(diceroll >= DICE_CRIT_SUCCESS)
				to_chat(user, "<span class='nicegreen'>I manage to economize on \the [src]'s use.</span>")
			if(IN.damage >= IN.autoheal_cutoff)
				user.visible_message("<span class='notice'>\The [user] partially salves a wound on [C]'s [affecting.name] with \the [src].</span>", \
				"<span class='notice'>I partially salve a wound on [C]'s [affecting.name] with \the [src].</span>")
				if(IN.damage_type == WOUND_BURN)
					IN.heal_damage(rand(heal_burn/2, heal_burn))
				else
					IN.heal_damage(rand(heal_brute/2, heal_brute))
				IN.germ_level = max(0, IN.germ_level - (WOUND_SANITIZATION_STERILIZER * sanitization))
			else
				user.visible_message("<span class='notice'>\The [user] salves a wound on [C]'s [affecting.name] with \the [src].</span>", \
				"<span class='notice'>I salve a wound on [C]'s [affecting.name] with \the [src].</span>")
				IN.germ_level = max(0, IN.germ_level - (WOUND_SANITIZATION_STERILIZER * sanitization))
				if(!IN.damage)
					qdel(IN)
				else if(IN.damage <= IN.autoheal_cutoff)
					IN.salve()
					IN.disinfect()
		affecting.update_injuries()
		if(affect_children)
			if(length(affecting.heal_zones))
				for(var/bodypart in affecting.heal_zones)
					var/obj/item/bodypart/child = C.get_bodypart(bodypart)
					if(!child)
						continue
					heal_carbon(C, user, brute, burn, TRUE, FALSE, child)
		return TRUE
	if(!silent)
		to_chat(user, "<span class='warning'>[C]'s [affecting.name] can not be healed with \the [src]!</span>")

/*
The idea is for these medical devices to work like a hybrid of the old brute packs and tend wounds,
they heal a little at a time, have reduced healing density and does not allow for rapid healing while in combat.
However they provice graunular control of where the healing is directed, this makes them better for curing work-related cuts and scrapes.

The interesting limb targeting mechanic is retained and i still believe they will be a viable choice, especially when healing others in the field.
*/

/obj/item/stack/medical/bone_gel
	name = "bone gel"
	singular_name = "bone gel"
	desc = "A potent medical gel that, when applied to a damaged bone in a proper surgical setting, triggers an intense melding reaction to repair the wound. Can be directly applied alongside surgical sticky tape to a broken bone in dire circumstances, though this is very harmful to the patient and not recommended."

	icon = 'modular_skyrat/icons/obj/surgery.dmi'
	icon_state = "bone-gel"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'

	amount = 10
	max_amount = 10
	self_delay = 60
	other_delay = 40
	grind_results = list(/datum/reagent/medicine/styptic_powder = 10, /datum/reagent/potassium = 10, /datum/reagent/space_cleaner/sterilizine = 10)
	novariants = TRUE

/obj/item/stack/medical/bone_gel/attack(mob/living/M, mob/user)
	to_chat(user, "<span class='warning'>Bone gel can only be used on fractured limbs!</span>")
	return

/obj/item/stack/medical/bone_gel/suicide_act(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.visible_message("<span class='suicide'>[C] is squirting all of \the [src] into [C.p_their()] mouth! That's not proper procedure! It looks like [C.p_theyre()] trying to commit suicide!</span>")
		if(do_after(C, 2 SECONDS))
			C.emote("scream")
			for(var/i in C.bodyparts)
				var/obj/item/bodypart/bone = i
				var/datum/wound/blunt/severe/oof_ouch = new
				oof_ouch.apply_wound(bone)
				var/datum/wound/blunt/critical/oof_OUCH = new
				oof_OUCH.apply_wound(bone)

			for(var/i in C.bodyparts)
				var/obj/item/bodypart/bone = i
				bone.receive_damage(brute=60)
			use(1)
			return (BRUTELOSS)
		else
			C.visible_message("<span class='suicide'>[C] screws up like an idiot and still dies anyway!</span>")
			return (BRUTELOSS)

/obj/item/stack/medical/bone_gel/cyborg
	custom_materials = null
	is_cyborg = 1
	cost = 250

#undef MODE_MULTIPLE
#undef MODE_SINGULAR

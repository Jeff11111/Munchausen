//yes i modularized bodyparts entirely
/obj/item/bodypart
	name = "limb"
	desc = "Why is it detached..."
	force = 3
	throwforce = 3
	icon = 'modular_skyrat/icons/mob/human_parts.dmi'
	w_class = WEIGHT_CLASS_SMALL
	icon_state = ""
	layer = BELOW_MOB_LAYER //so it isn't hidden behind objects when on the floor
	var/mob/living/carbon/owner = null
	var/mob/living/carbon/original_owner = null
	var/needs_processing = FALSE

	var/body_zone //BODY_ZONE_CHEST, BODY_ZONE_L_ARM, etc, used for def_zone
	var/list/aux_icons // associative list, currently used on hands
	var/body_part = null //bitflag used to check which clothes cover this bodypart
	var/use_digitigrade = NOT_DIGITIGRADE //Used for alternate legs, useless elsewhere
	var/list/embedded_objects = list()
	var/held_index = 0 //are we a hand? if so, which one!
	var/is_pseudopart = FALSE //For limbs that don't really exist, eg chainsaws

	var/disabled = BODYPART_NOT_DISABLED //If disabled, limb is as good as missing
	var/body_damage_coeff = 1 //Multiplier of the limb's damage that gets applied to the mob
	var/stam_damage_coeff = 0.75
	var/brutestate = 0
	var/burnstate = 0
	var/brute_dam = 0
	var/burn_dam = 0
	var/stamina_dam = 0
	var/max_stamina_damage = 0
	var/incoming_stam_mult = 1 //Multiplier for incoming staminaloss, decreases when taking staminaloss when the limb is disabled, resets back to 1 when limb is no longer disabled.
	var/max_damage = 0
	var/stam_heal_tick = 0		//per Life(). Defaults to 0

	var/brute_reduction = 0 //Subtracted to brute damage taken
	var/burn_reduction = 0	//Subtracted to burn damage taken
	var/stamina_reduction = 0 //Subtracted to stamina damage taken

	//Coloring and proper item icon update
	var/skin_tone = ""
	var/body_gender = ""
	var/species_id = ""
	var/color_src
	var/base_bp_icon //Overrides the icon being used for this limb. This is mainly for downstreams, implemented and maintained as a favor in return for implementing synths. And also because should_draw_* for icon overrides was pretty messy. You're welcome.
	var/should_draw_gender = FALSE
	var/species_color = ""
	var/mutation_color = ""
	var/no_update = 0
	var/body_markings = ""	//for bodypart markings
	var/body_markings_icon = 'modular_citadel/icons/mob/mam_markings.dmi'
	var/list/markings_color = list()
	var/aux_marking
	var/digitigrade_type

	var/animal_origin = null //for nonhuman bodypart (e.g. monkey)
	var/dismemberable = TRUE //whether or not it can be dismembered with a weapon.

	var/px_x = 0
	var/px_y = 0

	var/species_flags_list = list()
	var/dmg_overlay_type //the type of damage overlay (if any) to use when this bodypart is bruised/burned.

	//Damage messages used by help_shake_act()
	var/no_brute_msg = "not bruised"
	var/light_brute_msg = "bruised"
	var/medium_brute_msg = "battered"
	var/heavy_brute_msg = "mangled"

	var/no_burn_msg = "not burnt"
	var/light_burn_msg = "numb"
	var/medium_burn_msg = "blistered"
	var/heavy_burn_msg = "peeling"

	var/no_pain_msg = "no pain"
	var/light_pain_msg = "pain"
	var/medium_pain_msg = "pain"
	var/heavy_pain_msg = "pain"

	/// Bobmed variables
	germ_level = 0 //Germs.
	var/parent_bodyzone //body zone that is considered a "parent" of this bodypart's zone
	var/list/starting_children = list() //children that are already "inside" this limb on spawn. could be organs or limbs.
	var/list/children_zones = list() //body zones that are considered "children" of this bodypart's zone
	var/list/heal_zones = list() //body zones that are healed in "multiple" mode on medical items
	var/obj/item/cavity_item
	/// The (TG) wounds currently afflicting this body part
	var/list/wounds = list()
	/// The (Bay) injuries currently afflicting this bodypart
	var/list/injuries = list()
	/// Number of injuries - Does not always equal length(injuries)
	var/number_injuries = 0
	/// Our current stored wound damage multiplier
	var/wound_damage_multiplier = 1
	/// This number is subtracted from all wound rolls on this bodypart, higher numbers mean more defense, negative means easier to wound
	var/wound_resistance = 0
	/// When this bodypart hits max damage, this number is added to all wound rolls. Obviously only relevant for bodyparts that have damage caps.
	var/disabled_wound_penalty = 15
	/// How much we multiply the dismemberment roll chance by, when rolling for dismemberment
	var/dismember_mod = 1

	/// Descriptions for the locations on the limb for scars to be assigned, just cosmetic
	var/list/specific_locations = list("general area")
	/// So we know if we need to scream if this limb hits max damage
	var/last_maxed
	/// How much generic bleedstacks we have on this bodypart
	var/generic_bleedstacks = 0
	/// If we have a gauze wrapping currently applied
	var/obj/item/stack/current_gauze
	/// If someone has written something on us
	var/etching = ""
	/// Robotic, organic, etc
	var/status = BODYPART_ORGANIC
	/// General bodypart flags
	var/limb_flags = (BODYPART_CAN_STUMP)
	/// Maximum weight for a cavity item
	var/max_cavity_size = WEIGHT_CLASS_TINY
	/// Synthetic bodyparts can have patches applied but are harder to repair by conventional means
	var/synthetic = FALSE
	/// For robotic limbs that pretend to be organic, for the sake of features, icon paths etc. etc.
	var/render_like_organic = FALSE
	/// This is used for pseudolimbs. Basically replaces the mob overlay icon with this.
	var/mutable_appearance/custom_overlay = null

	/// These were head vars before, but i had to generify behavior for edge cases
	/// (IPCs have their brain in da chest)
	var/mob/living/brain/brainmob = null
	var/obj/item/organ/brain/brain = null

	/// If something is currently grasping this bodypart and trying to staunch bleeding
	var/obj/item/grab/grasped_by = null

	/// How much pain this limb is feeling
	var/pain_dam = 0
	/// Like stam_damage_coeff - but for pain
	var/pain_damage_coeff = 1
	/// Amount of pain healed per on_life() tick, which gets multiplied by 1/10 of the owner's endurance
	var/pain_heal_tick = 1
	/// How much we multiply pain_heal_tick by if the owner is lying down
	var/pain_heal_rest_multiplier = 3
	/// Multiply incoming pain by this. Works like incoming_stam_mult in a way.
	var/incoming_pain_mult = 1
	/// Maximum pain this limb can suffer
	var/max_pain_damage = 0
	/// Point at which the limb is disabled due to pain
	var/pain_disability_threshold = 0
	/// Reduces incoming pain by this, flat
	var/pain_reduction = 0

	/// Toxin damage
	var/tox_dam = 0
	/// Maximum toxin damage this limb can suffer
	var/max_tox_damage = 0
	/// Reduces incoming toxin damage by this, flat
	var/tox_reduction = 0
	/// How many toxins this bodyparts filters when processed on Life()
	/// Filtering toxins turns the bodypart toxin damage into organ damage
	var/tox_filter_per_tick =  0.1

	/// Clone/cellular damage
	var/clone_dam = 0
	/// Maximum cellular damage this limb can suffer
	var/max_clone_damage = 0
	/// Reduces incoming cellular damage by this, flat
	var/clone_reduction = 0

	/// How damaged the limb needs to be to start taking internal organ damage
	var/organ_damage_requirement = 0
	/// How much damage an attack needs to do, at the very least, to damage internal organs
	var/organ_damage_hit_minimum = 0

	// Integrity, used by dismemberment code
	var/limb_integrity = 0
	// Max integrity
	var/max_limb_integrity = 0

	// Used to check if we can recover from complete sepsis
	var/death_time = 0
	// Used to handle rejection
	var/rejecting = FALSE
	var/decay_factor = 0.01 //Multiplier of max_tox_damage applied when rotting
	var/datum/dna/original_dna
	var/datum/species/original_species

	//TEETH!
	var/max_teeth = 0
	var/datum/speech_mod/lisp/teeth_mod
	var/obj/item/stack/teeth/teeth_object

	//Specific dismemberment sounds
	var/list/dismember_sounds

	//Raw probability of missing entirely in melee attacks
	var/miss_entirely_prob = 10
	//Base prob of hitting this limb correctly in melee attacks
	var/zone_prob = 50
	//Extra prob, multiplied by dexterity/MAX_STAT
	var/extra_zone_prob = 50

	//Descriptive strings
	var/encased //descriptive string for the bones that encase the limb (skull, ribcage, pelvic bones)
	var/amputation_point //descriptive string used in amputation (neck, spine, hips)
	var/artery_name = "artery"//descriptive string used in arterial wounds (aorta)
	var/tendon_name //descriptive string used in tendon wounds (palmaris longus)
	var/cavity_name //descriptive string used in cavity implant surgery (thoracic)
	var/joint_name = "joint" //descriptive string used in dislocation.

/obj/item/bodypart/Initialize()
	. = ..()
	if(length(starting_children))
		for(var/I in starting_children)
			new I(src)
	if(!pain_disability_threshold)
		pain_disability_threshold = (max_damage * 0.75)
	if(!max_tox_damage)
		max_tox_damage = max_damage
	if(!max_pain_damage)
		max_pain_damage = max_damage * 1.5
	if(!max_clone_damage)
		max_clone_damage = max_damage
	if(!organ_damage_requirement)
		organ_damage_requirement = max_damage * 0.2
	if(!organ_damage_hit_minimum)
		organ_damage_hit_minimum = 5
	if(!max_limb_integrity)
		max_limb_integrity = min(60, max_damage)
	limb_integrity = max_limb_integrity
	//Runs decay when outside of a person AND ONLY WHEN OUTSIDE (i.e. long obj).
	START_PROCESSING(SSobj, src)

//Processing outside the body
/obj/item/bodypart/process()
	if(owner)
		STOP_PROCESSING(SSobj, src)
		return
	if(isturf(loc))
		limb_flags |= BODYPART_CUT_AWAY
	on_death()

/obj/item/bodypart/proc/on_death()
	decay()

//Appliess the slow damage over time decay
/obj/item/bodypart/proc/decay()
	if(!can_decay())
		STOP_PROCESSING(SSobj, src)
		return
	is_cold()
	if(CHECK_BITFIELD(limb_flags, BODYPART_FROZEN | BODYPART_DEAD))
		return
	janitize(rand(MIN_ORGAN_DECAY_INFECTION,MAX_ORGAN_DECAY_INFECTION))
	if(germ_level >= INFECTION_LEVEL_TWO)
		janitize(rand(MIN_ORGAN_DECAY_INFECTION,MAX_ORGAN_DECAY_INFECTION))
		for(var/obj/item/bodypart/BP in src)
			BP.update_limb(FALSE)
			BP.update_icon_dropped()
		if(owner)
			owner.update_icon()
		else
			update_icon_dropped()
	if(germ_level >= INFECTION_LEVEL_THREE)
		kill_limb()
		for(var/obj/item/bodypart/BP in src)
			BP.update_limb(FALSE)
			BP.update_icon_dropped()
		if(owner)
			owner.update_icon()
		else
			update_icon_dropped()

//Checks to see if the bodypart is frozen from temperature
/obj/item/bodypart/proc/is_cold()
	if(istype(loc, /obj/))//Freezer of some kind, I hope.
		if(is_type_in_typecache(loc, GLOB.freezing_objects))
			if(!CHECK_BITFIELD(limb_flags, BODYPART_FROZEN)) //Incase someone puts them in when cold, but they warm up inside of the thing. (i.e. they have the flag, the thing turns it off, this rights it.)
				limb_flags |= BODYPART_FROZEN
			return TRUE
		return CHECK_BITFIELD(limb_flags, BODYPART_FROZEN) //Incase something else toggles it

	var/local_temp
	if(istype(loc, /turf/))//Only concern is adding an organ to a freezer when the area around it is cold.
		var/turf/T = loc
		var/datum/gas_mixture/enviro = T.return_air()
		local_temp = enviro.temperature

	else if(!owner && ismob(loc))
		var/mob/M = loc
		if(is_type_in_typecache(M.loc, GLOB.freezing_objects))
			if(!CHECK_BITFIELD(limb_flags, BODYPART_FROZEN))
				limb_flags |= BODYPART_FROZEN
			return TRUE
		var/turf/T = M.loc
		var/datum/gas_mixture/enviro = T.return_air()
		local_temp = enviro.temperature

	if(owner)
		//Don't interfere with bodies frozen by structures.
		if(is_type_in_typecache(owner.loc, GLOB.freezing_objects))
			if(!CHECK_BITFIELD(limb_flags, BODYPART_FROZEN))
				limb_flags |= BODYPART_FROZEN
			return TRUE
		local_temp = owner.bodytemperature

	if(!local_temp)//Shouldn't happen but in case
		return
	if(local_temp < 154)//I have a pretty shaky citation that states -120 allows indefinite cyrostorage
		limb_flags |= BODYPART_FROZEN
		return TRUE
	limb_flags &= ~BODYPART_FROZEN
	return FALSE

//Germs
/obj/item/bodypart/janitize(add_germs, minimum_germs = 0, maximum_germs = MAXIMUM_GERM_LEVEL)
	. = ..()
	if(germ_level >= INFECTION_LEVEL_THREE && !is_dead())
		kill_limb()
	var/already_rot = (species_id == "rot")
	update_limb(!owner)
	if(owner && !already_rot && (species_id == "rot"))
		owner?.regenerate_icons()
	else if(!owner)
		update_icon_dropped()

/obj/item/bodypart/proc/handle_antibiotics()
	if(!owner || (owner.stat == DEAD) || !germ_level)
		return

	var/antibiotics = owner.get_antibiotics()
	if(antibiotics <= 0)
		return

	if(germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else
		janitize(-antibiotics * SANITIZATION_ANTIBIOTIC)	//at germ_level == 500 and 50 antibiotic, this should cure the infection in 5 minutes
		for(var/fuck in injuries)
			var/datum/injury/IN = fuck
			IN.germ_level = clamp(IN.germ_level - antibiotics, 0, INFECTION_LEVEL_THREE)
	if(owner && owner.lying)
		janitize(-SANITIZATION_LYING)
		for(var/fuck in injuries)
			var/datum/injury/IN = fuck
			IN.germ_level = clamp(IN.germ_level - SANITIZATION_LYING, 0, INFECTION_LEVEL_THREE)

/obj/item/bodypart/proc/handle_germ_effects()
	//Handle infection effects
	var/virus_immunity = owner.virus_immunity()
	var/antibiotics = owner.get_antibiotics()

	if(germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(virus_immunity*0.3))
		germ_level--

	if(germ_level >= INFECTION_LEVEL_ONE/2)
		//Warn the user that they're a bit fucked
		if(prob(4) && germ_level < INFECTION_LEVEL_ONE)
			if(owner.stat != DEAD)
				owner.custom_pain("Your [src.name] feels a bit warm and swollen...", 8, FALSE, src)
		//Aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes, when immunity is full.
		if(antibiotics < 5 && prob(round(germ_level/6 * owner.immunity_weakness() * 0.01)))
			if(virus_immunity > 0)
				janitize(clamp(round(1/virus_immunity), 1, 10)) //Immunity starts at 100. This doubles infection rate at 50% immunity. Rounded to nearest whole.
			else //Will only trigger if immunity has hit zero. Once it does, 10x infection rate.
				janitize(10)

	if(germ_level >= INFECTION_LEVEL_ONE)
		if(prob(6) && germ_level < INFECTION_LEVEL_TWO)
			if(owner.stat != DEAD)
				owner.custom_pain("Your [src.name] feels hotter than normal...", 12, FALSE, src)
		var/fever_temperature = (BODYTEMP_HEAT_DAMAGE_LIMIT - BODYTEMP_NORMAL - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + BODYTEMP_NORMAL
		owner.bodytemperature += clamp((fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, 0, fever_temperature - owner.bodytemperature)

	//Spread the infection to internal organs, child and parent bodyparts
	if(germ_level >= INFECTION_LEVEL_TWO)
		//Chance to cause pain, while also informing the owner
		if(owner && prob(8))
			if(owner.stat != DEAD)
				owner.custom_pain("Your [src.name] starts leaking some pus...", 18, FALSE, src)

		//Make internal organs become infected one at a time instead of all at once
		var/obj/item/organ/target_organ
		for(var/obj/item/organ/O in get_organs())
			//Once the organ reaches whatever we can give it, or level two, switch to a different one
			if(O.germ_level > 0 && O.germ_level < min(germ_level, INFECTION_LEVEL_TWO))
				//Choose the organ with the highest germ_level
				if(!target_organ || (O.germ_level > target_organ.germ_level))
					target_organ = O

		//Infect the target organ
		if(target_organ)
			target_organ.janitize(1)

		//Spread the infection to child and parent organs
		var/zones = list()
		zones |= parent_bodyzone
		zones |= children_zones
		if(length(zones))
			for(var/child in zones)
				var/obj/item/bodypart/bodypart = owner.get_bodypart(child)
				if(bodypart && (bodypart.germ_level < germ_level))
					if(bodypart.germ_level < INFECTION_LEVEL_ONE*2 || prob(30))
						bodypart.janitize(1)

	//Overdosing is necessary to stop severe infections
	if(germ_level >= INFECTION_LEVEL_THREE && antibiotics < 45)
		if(!is_dead())
			limb_flags |= BODYPART_DEAD
			if(owner.stat != DEAD)
				owner.custom_pain("I can't feel my [name] anymore...", 21,  TRUE, src, FALSE)
			update_disabled()
		janitize(1)

//Rejection
/obj/item/bodypart/proc/handle_rejection()
	if(is_robotic_limb())
		return

	// Process unsuitable transplants. TODO: consider some kind of
	// immunosuppressant that changes transplant data to make it match.
	if(owner.virus_immunity() < 10) //for now just having shit immunity will suppress it
		original_dna = owner.dna
		original_species = owner.dna?.species
		rejecting = 0
		return

	if(original_dna)
		if(!rejecting)
			if(!(owner.dna.blood_type in get_safe_blood(original_dna?.blood_type)))
				rejecting = REJECTION_LEVEL_1
		else
			rejecting++ //Rejection severity increases over time.
			if(rejecting % 10 == 0) //Only fire every ten rejection ticks.
				switch(rejecting)
					if(REJECTION_LEVEL_1 to REJECTION_LEVEL_2)
						janitize(1)
					if(REJECTION_LEVEL_2 to REJECTION_LEVEL_3)
						janitize(rand(1,2))
					if(REJECTION_LEVEL_3 to REJECTION_LEVEL_4)
						janitize(rand(2,3))
					if(REJECTION_LEVEL_4 to INFINITY)
						janitize(rand(3,5))

/obj/item/bodypart/Topic(href, href_list)
	. = ..()
	if(href_list["gauze"])
		var/mob/living/carbon/C = usr
		if(!istype(C) || !C.canUseTopic(owner, TRUE, FALSE, FALSE) || !current_gauze)
			return
		if(INTERACTING_WITH(C, src))
			to_chat(C, "<span class='warning'>You are already interacting with [src]!</span>")
			return
		if(C == owner)
			owner.visible_message("<span class='warning'>[owner] starts ripping off \the [current_gauze] from [owner.p_their()] [src.name]!</span>",
								"<span class='warning'>You start ripping off \the [current_gauze] from your [src.name]!</span>")
			if(do_mob(owner, owner, 5 SECONDS))
				owner.visible_message("<span class='warning'>[owner] rips \the [current_gauze] from [owner.p_their()] [src.name], destroying it in the process!</span>",
									"<span class='warning'>You rip \the [current_gauze] from your [src.name], destroying it in the process!</span>")
				playsound(owner, 'modular_skyrat/sound/effects/clothripping.ogg', 40, 0, -4)
				remove_gauze(FALSE)
			else
				to_chat(owner, "<span class='warning'>You fail to rip \the [current_gauze] on your [src.name] off.</span>")
		else
			if(do_mob(usr, owner, 3 SECONDS))
				usr.visible_message("<span class='warning'>[usr] rips \the [current_gauze] from [owner]'s [src.name], destroying it in the process!</span>",
								"<span class='warning'>You rip \the [current_gauze] from [owner]'s [src.name], destroying it in the process!</span>")
				playsound(owner, 'modular_skyrat/sound/effects/clothripping.ogg', 40, 0, -4)
				remove_gauze(FALSE)
			else
				to_chat(usr, "<span class='warning'>You fail to rip \the [current_gauze] from [owner]'s [src.name].</span>")

/obj/item/bodypart/blob_act()
	take_damage(max_damage)

/obj/item/bodypart/Destroy()
	if(owner)
		owner.bodyparts -= src
		owner = null
	if(cavity_item)
		QDEL_NULL(cavity_item)
	for(var/atom/A in src)
		qdel(A)
	for(var/datum/wound/W in wounds)
		qdel(W)
	for(var/datum/injury/IN in injuries)
		qdel(IN)
	return ..()

/obj/item/bodypart/attack(mob/living/carbon/C, mob/user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(HAS_TRAIT(C, TRAIT_LIMBATTACHMENT))
			if(!H.get_bodypart(body_zone) && !animal_origin)
				if(H == user)
					H.visible_message("<span class='warning'>[H] jams [src] into [H.p_their()] empty socket!</span>",\
					"<span class='notice'>You force [src] into your empty socket, and it locks into place!</span>")
				else
					H.visible_message("<span class='warning'>[user] jams [src] into [H]'s empty socket!</span>",\
					"<span class='notice'>[user] forces [src] into your empty socket, and it locks into place!</span>")
				user.temporarilyRemoveItemFromInventory(src, TRUE)
				attach_limb(C)
				return
	. = ..()

/obj/item/bodypart/attackby(obj/item/W, mob/user, params)
	if(W.get_sharpness() && (user.a_intent == INTENT_HARM))
		add_fingerprint(user)
		if(!length(contents))
			user.visible_message("<span class='warning'><b>[user]</b> begins to butcher [src].</span>",\
				"<span class='notice'>You begin butchering [src]...</span>")
			if(do_after(user, 54, target = src))
				user.visible_message("<span class='warning'><b>[user]</b> butchers [src] into giblets!</span>",\
					"<span class='warning'>You butcher [src] into giblets!</span>")
				new /obj/item/reagent_containers/food/snacks/meat/slab/human(get_turf(src))
				new /obj/item/reagent_containers/food/snacks/meat/slab/human(get_turf(src))
				if(joint_name)
					new /obj/item/stack/sheet/bone(get_turf(src))
				return qdel(src)
			return
		playsound(loc, 'sound/weapons/slice.ogg', 50, 1, -1)
		user.visible_message("<span class='warning'><b>[user]</b> begins to cut open [src].</span>",\
			"<span class='notice'>You begin to cut open [src]...</span>")
		if(do_after(user, 5 SECONDS, target = src))
			drop_organs(user)
	else if(istype(W, /obj/item/pen))
		var/badboy = input(user, "What do you want to inscribe on [src]?", "Malpractice", "") as text
		if(badboy)
			badboy = strip_html_simple(badboy)
			etching = "<b>[badboy]</b>"
			user.visible_message("<span class='notice'><b>[user]</b> etches something on \the [src] with \the [W].</span>", " <span class='notice'>You etch \"[badboy]\" on [src] with \the [W]. Hehe.</span>")
		else
			return ..()
	else
		return ..()

/obj/item/bodypart/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!is_robotic_limb())
		playsound(get_turf(src), 'sound/misc/splort.ogg', 50, 1, -1)
	pixel_x = rand(-3, 3)
	pixel_y = rand(-3, 3)
	update_limb(!owner)
	update_icon_dropped()

//empties the bodypart from its organs and other things inside it
/obj/item/bodypart/proc/drop_organs(mob/user, violent_removal)
	var/turf/T = get_turf(src)
	if(!is_robotic_limb())
		playsound(T, 'sound/misc/splort.ogg', 50, 1, -1)
	if(current_gauze)
		remove_gauze(drop_gauze = FALSE)
	for(var/X in get_organs())
		var/obj/item/organ/O = X
		O.transfer_to_limb(src, owner)
	for(var/obj/item/I in src)
		if(I == brain)
			if(brainmob)
				brainmob.container = null
				brainmob.forceMove(brain)
				brain.brainmob = brainmob
				brainmob = null
			if(istype(T))
				brain.forceMove(T)
			else
				brain.moveToNullspace()
			brain = null
			update_icon_dropped()
			continue
		if(istype(I, /obj/item/reagent_containers/pill))
			for(var/datum/action/item_action/hands_free/activate_pill/AP in I.actions)
				qdel(AP)
		else if(istype(I, /obj/item/bodypart))
			var/obj/item/bodypart/BP = I
			BP.update_limb(TRUE)
			BP.update_icon_dropped()
		if(istype(T))
			I.forceMove(T)
		else
			I.moveToNullspace()
	if(cavity_item)
		cavity_item = null
	update_limb(!owner)
	update_icon_dropped()

/obj/item/bodypart/proc/get_organs()
	if(!owner)
		return FALSE

	var/list/our_organs
	for(var/X in owner.internal_organs)
		var/obj/item/organ/O = X
		if(!istype(O))
			continue
		var/org_zone = check_zone(O.zone)
		if(org_zone == body_zone)
			LAZYADD(our_organs, O)

	return our_organs

/obj/item/bodypart/proc/consider_processing()
	if(stamina_dam > DAMAGE_PRECISION)
		. = TRUE
	//else if.. else if.. so on.
	else if(number_injuries)
		. = TRUE
	else if(max(0, (get_pain() - owner?.chem_effects[CE_PAINKILLER]) * (owner?.mind ? owner.mind.mob_stats[STAT_DATUM(end)].get_shock_mult() : 1)) > DAMAGE_PRECISION)
		. = TRUE
	else if(tox_dam > DAMAGE_PRECISION)
		. = TRUE
	else if(can_decay() && germ_level)
		. = TRUE
	else if(rejecting || !(owner.dna.blood_type in get_safe_blood(original_dna?.blood_type)))
		. = TRUE
	else
		. = FALSE
	needs_processing = .

//The bodypart can rot and get infected
/obj/item/bodypart/proc/can_decay()
	if(CHECK_BITFIELD(status, BODYPART_ROBOTIC) || CHECK_BITFIELD(limb_flags, BODYPART_DEAD))
		return FALSE
	if(owner?.reagents?.has_reagent(/datum/reagent/medicine/preservahyde) || owner?.reagents?.has_reagent(/datum/reagent/toxin/formaldehyde))
		return FALSE
	return TRUE

//Return TRUE to get whatever mob this is in to update health.
/obj/item/bodypart/proc/on_life()
	//DO NOT update health here, it'll be done in the carbon's life.
	if(stam_heal_tick && stamina_dam > DAMAGE_PRECISION)
		//Pain makes you regenerate stamina slower.
		//At maximum pain, you barely regenerate stamina on the limb.
		var/multiplier = max(0.1, 1 - (max(0, (get_pain() - owner?.chem_effects[CE_PAINKILLER])/max_pain_damage * (owner?.mind ? owner.mind.mob_stats[STAT_DATUM(end)].get_shock_mult() : 1))))
		if(!can_feel_pain())
			multiplier = 1
		if(heal_damage(stamina = (stam_heal_tick * (disabled ? 2 : 1) * multiplier), only_robotic = FALSE, only_organic = FALSE, updating_health = FALSE))
			. |= BODYPART_LIFE_UPDATE_HEALTH
	if(pain_heal_tick && pain_dam > DAMAGE_PRECISION)
		if(heal_damage(pain = (pain_heal_tick * (owner?.lying ? pain_heal_rest_multiplier : 1) * (owner?.mind ? (2 - GET_STAT(owner, end).get_shock_mult()) : 1)), only_robotic = FALSE, only_organic = FALSE, updating_health = FALSE))
			. |= BODYPART_LIFE_UPDATE_HEALTH
	if(tox_filter_per_tick && tox_dam > DAMAGE_PRECISION)
		filter_toxins(toxins = tox_filter_per_tick, only_robotic = FALSE, only_organic = FALSE, updating_health = FALSE)
		. |= BODYPART_LIFE_UPDATE_HEALTH
	if(rejecting)
		handle_rejection()
		. |= BODYPART_LIFE_UPDATE_HEALTH
	if(length(injuries))
		update_injuries()

/obj/item/bodypart/proc/update_germs()
	if(!can_decay())
		return
	//Cryo stops germs from moving and doing their bad stuffs
	if(owner.bodytemperature <= 170)
		return
	handle_germ_sync()
	handle_antibiotics()
	handle_germ_effects()

/obj/item/bodypart/proc/handle_germ_sync()
	//If we have no wounds, nor injuries, nor germ level, no point in trying to update
	if(!length(wounds) && !length(injuries) && !germ_level)
		return

	var/turf/open/floor/T = get_turf(owner)
	var/owner_germ_level = 2*owner.germ_level
	for(var/obj/item/embeddies in embedded_objects)
		if(!embeddies.isEmbedHarmless())
			owner_germ_level += (embeddies.germ_level/5)

	//Open wounds can become infected
	for(var/datum/wound/W in wounds)
		if(istype(T) && W.infection_check() && (max(2*T.dirtiness, owner_germ_level) > W.germ_level))
			W.germ_level = clamp(W.germ_level + W.infection_rate, 0, INFECTION_LEVEL_THREE)

	//Open injuries can become infected, regardless of antibiotics
	for(var/datum/injury/IN in injuries)
		if(istype(T) && IN.infection_check() && (max(2*T.dirtiness, owner_germ_level) > IN.germ_level))
			IN.germ_level = clamp(IN.germ_level + IN.infection_rate, 0, INFECTION_LEVEL_THREE)

	//If we have antibiotics, then skip over, the infection is going away
	var/antibiotics = owner.get_antibiotics()
	if(antibiotics > 0)
		return

	for(var/datum/wound/W in wounds)
		//Infected wounds raise the bodypart's germ level
		if(W.germ_level > germ_level || prob(min(W.germ_level, 40)))
			janitize(W.infection_rate)
			break	//Limit increase to a maximum of one wound infection per 2 seconds

	for(var/datum/injury/IN in injuries)
		//Infected injuries raise the bodypart's germ level
		if(IN.germ_level > germ_level || prob(min(IN.germ_level, 40)))
			janitize(1)
			break	//limit increase to a maximum of one injury infection per 2 seconds

/obj/item/bodypart/proc/update_injuries()
	for(var/datum/injury/IN in injuries)
		// Wounds can disappear after 10 minutes at the earliest
		if(IN.damage <= 0 && IN.created && (IN.created + IN.fade_away <= world.time || is_robotic_limb()))
			qdel(IN)
			continue

		// Slow healing
		var/heal_amt = 0
		// If damage >= 50 AFTER treatment then it's probably too severe to heal within the timeframe of a round.
		if(!owner.chem_effects[CE_TOXIN] && IN.can_autoheal() && IN.wound_damage() && (IN.wound_damage()/max_damage) < 0.5)
			heal_amt += 0.02
			if(owner.IsSleeping()) // sleepy niggas heal quadruple
				heal_amt *= 10
		heal_amt = CEILING(heal_amt, 0.1)
		if(heal_amt)
			IN.heal_damage(heal_amt)

		// Bleeding
		if(owner && !(ishuman(owner) && (NOBLOOD in owner.dna?.species?.species_traits)))
			IN.bleed_timer--

	// Sync the limb's damage with its injuries
	update_damages()
	if(owner && update_bodypart_damage_state())
		owner.update_damage_overlays()

// Updates brute_damn and burn_damn from wound damages
/obj/item/bodypart/proc/update_damages()
	number_injuries = 0
	brute_dam = 0
	burn_dam = 0
	for(var/datum/injury/IN in injuries)
		if(IN.damage <= 0)
			continue

		if(IN.damage_type != WOUND_BURN)
			brute_dam += IN.damage
		else
			burn_dam += IN.damage

		number_injuries += IN.amount

//Teeth if applicable
/obj/item/bodypart/proc/knock_out_teeth(amount = 32, throw_dir = SOUTH)
	return

/obj/item/bodypart/proc/get_teeth_amount()
	return 0

/obj/item/bodypart/proc/update_teeth()
	return FALSE

/obj/item/bodypart/proc/fill_teeth()
	if(max_teeth)
		if(!teeth_object)
			teeth_object = new(src)
		teeth_object.amount = max_teeth
		return TRUE

//Applies brute and burn damage to the organ. Returns 1 if the damage-icon states changed at all.
//Damage will not exceed max_damage using this proc
//Cannot apply negative damage
/obj/item/bodypart/proc/receive_damage(brute = 0, burn = 0, stamina = 0, blocked = 0, updating_health = TRUE, required_status = null, wound_bonus = 0, bare_wound_bonus = 0, sharpness = SHARP_NONE, spread_damage = FALSE, pain = 0, toxin = 0, clone = 0)
	if(!owner)
		return FALSE

	var/hit_percent = (100-blocked)/100
	if((!brute && !burn && !stamina && !pain && !toxin && !clone) || hit_percent <= 0)
		return FALSE

	if(owner.status_flags & GODMODE)
		return FALSE	//godmode

	if(required_status && !(status & required_status))
		return FALSE

	var/dmg_mlt = CONFIG_GET(number/damage_multiplier) * hit_percent
	var/burn_brutemod = 1 + (0.35 * burn_dam/max_damage)
	brute = round(max(brute * dmg_mlt * wound_damage_multiplier * burn_brutemod, 0), DAMAGE_PRECISION)
	burn = round(max(burn * dmg_mlt * wound_damage_multiplier, 0), DAMAGE_PRECISION)
	brute = max(0, brute - brute_reduction)
	burn = max(0, burn - burn_reduction)
	stamina = round(max(stamina * dmg_mlt, 0), DAMAGE_PRECISION)
	stamina = max(0, stamina - stamina_reduction)
	pain = round(max(pain * dmg_mlt, 0), DAMAGE_PRECISION)
	pain = max(0, pain - pain_reduction)
	toxin = round(max(toxin * dmg_mlt, 0), DAMAGE_PRECISION)
	toxin = max(0, toxin - tox_reduction)
	clone = round(max(clone * dmg_mlt, 0), DAMAGE_PRECISION)
	clone = max(0, clone - clone_reduction)

	if(!brute && !burn && !stamina && !pain && !toxin && !clone)
		return FALSE

	switch(animal_origin)
		if(ALIEN_BODYPART,LARVA_BODYPART) //aliens take double burn //nothing can burn with so much snowflake code around
			burn *= 2

	// what kind of wounds and injuries we're gonna roll for, take the greater between brute and burn, then if it's brute, we subdivide based on sharpness
	var/wounding_type = WOUND_NONE
	if(brute || burn)
		wounding_type = (brute > burn ? WOUND_BLUNT : WOUND_BURN)
	var/wounding_dmg = max(brute, burn)

	var/mangled_state = get_mangled_state()
	var/bio_state = owner.get_biological_state()

	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	//First we check the sharpness var to see if we're slashing or piercing rather than plain blunt
	if(wounding_type == WOUND_BLUNT)
		if(sharpness == SHARP_EDGED)
			wounding_type = WOUND_SLASH
		else if(sharpness == SHARP_POINTY)
			wounding_type = WOUND_PIERCE

	//Use this later to dismember proper
	var/initial_wounding_type = wounding_type

	//Now we have our wounding_type and are ready to carry on with dealing damage and then wounds

	//We add the pain values before we scale damage down
	//Pain does not care about your feelings, nor if your limb was already damaged
	//to it's maximum
	pain += 0.75 * clone
	pain += 0.7 * burn
	pain += 0.6 * brute
	pain += 0.5 * toxin
	pain = min(max_pain_damage, pain)

	//We damage the organs, if possible, before adding onto the limb's damage
	//Doing so later would fuck up with calculations
	damage_organs(brute = brute, burn = burn, toxin = toxin, clone = clone, wounding_type = wounding_type)

	//Total damage used to calculate the can_inflicts
	var/total_damage = brute + burn

	//How much we are actuallly allowed to inflict
	var/can_inflict = max_damage - get_damage()
	var/can_inflict_brute = max(0, (brute/max(1, total_damage)) * can_inflict)
	var/can_inflict_burn = max(0, (burn/max(1, total_damage)) * can_inflict)
	var/can_inflict_stamina = max(0, max_stamina_damage - stamina_dam)
	var/can_inflict_toxin = max(0, max_tox_damage - tox_dam)
	var/can_inflict_clone = max(0, max_clone_damage - clone_dam)
	var/can_inflict_pain = max(0, max_pain_damage - get_pain())

	//We save these values to spread out to other limbs
	var/extrabrute = max(0, brute - can_inflict_brute)
	var/extraburn = max(0, burn - can_inflict_burn)
	var/extrastamina = max(0, stamina - can_inflict_stamina)
	var/extratoxin = max(0, toxin - can_inflict_toxin)
	var/extraclone = max(0, clone - can_inflict_clone)
	var/extrapain = max(0, pain - can_inflict_pain)

	if(stamina && (stamina > can_inflict_stamina))
		stamina = can_inflict_stamina
	if(toxin && (toxin > can_inflict_toxin))
		stamina = can_inflict_toxin
	if(clone && (clone > can_inflict_clone))
		clone = can_inflict_clone
	if(pain && (pain > can_inflict_pain))
		pain = can_inflict_pain

	if(total_damage && (total_damage > can_inflict))
		brute = can_inflict_brute
		burn = can_inflict_burn

	if(owner && spread_damage && (extrabrute || extraburn || extrastamina || extraclone || extrapain))
		//We still have damage left. Time to spread.
		//First we get the body zones.
		var/list/spreadable_limbs = list()
		if(parent_bodyzone)
			spreadable_limbs |= parent_bodyzone
		if(length(children_zones))
			spreadable_limbs |= children_zones

		//Hitting the head should not spread to the eyes
		spreadable_limbs -= list(BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE)

		//We replace the body zones with the appropriate limbs
		for(var/i in spreadable_limbs)
			spreadable_limbs -= i
			var/obj/item/bodypart/BP = owner.get_bodypart(i)
			if(BP && ((BP.brute_dam + BP.burn_dam) < BP.max_damage))
				spreadable_limbs |= BP

		//We have the limbs. Now we divide the damage appropriately between children and parent.
		if(length(spreadable_limbs))
			extrabrute = round(extrabrute/length(spreadable_limbs), 1)
			extraburn = round(extraburn/length(spreadable_limbs), 1)
			extrastamina = round(extrastamina/length(spreadable_limbs), 1)
			extratoxin = round(extratoxin/length(spreadable_limbs), 1)
			extraclone = round(extraclone/length(spreadable_limbs), 1)
			for(var/obj/item/bodypart/damage_limb in spreadable_limbs)
				//We apply damage without any armor checks, because the limb that made it suffer damage is absolutely FUCKED anyways.
				damage_limb.receive_damage(brute = extrabrute, burn = extraburn, stamina = extrastamina, toxin = extratoxin, clone = extraclone, sharpness = sharpness, spread_damage = FALSE)
	else if(!spread_damage && owner?.can_feel_pain()) //Can't spread, just add to the owner's shock
		owner.shock_stage += max(0, extrabrute + extraburn - (owner?.chem_effects[CE_PAINKILLER]/3))

	//Damage the wounds and injuries, too
	for(var/i in wounds)
		var/datum/wound/W = i
		W.receive_damage(wounding_type, wounding_dmg, wound_bonus, pain)
	for(var/i in injuries)
		var/datum/injury/IN = i
		IN.receive_damage(max(brute, burn), pain, wounding_type)

	//Brute and burn damage is associated with injuries
	var/datum/injury/created_injury
	if(brute)
		created_injury = create_injury(wounding_type, brute)
		if(created_injury && !(created_injury in injuries))
			created_injury.apply_injury(brute, src)
	if(burn)
		created_injury = create_injury(wounding_type, burn)
		if(created_injury && !(created_injury in injuries))
			created_injury.apply_injury(burn, src)
		if(owner && prob(burn * 2))
			owner.IgniteMob()

	//Sync the bodypart's damage with the wounds we have created
	update_damages()

	stamina_dam += stamina
	tox_dam += toxin
	clone_dam += clone

	//Damage has been dealt. Let's deal with wounding.
	//We check all wound-related traits to multiply damage adequately.
	if((body_zone == BODY_ZONE_PRECISE_MOUTH || body_zone == BODY_ZONE_HEAD) && HAS_TRAIT(owner, TRAIT_GLASSJAW))
		wounding_dmg *= 2
	if(wounding_type == WOUND_BLUNT && HAS_TRAIT(owner, TRAIT_EASYBLUNT))
		wounding_dmg *= 2

	// Standard humanoids, flesh and bone
	if(CHECK_MULTIPLE_BITFIELDS(bio_state, BIO_FULL))
		// If we've already mangled the muscle (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
		// So a big sharp weapon is still all you need to rip off a limb
		if((mangled_state & BODYPART_MANGLED_MUSCLE) && !(mangled_state & BODYPART_MANGLED_BONE) && sharpness)
			playsound(src, "modular_skyrat/sound/effects/crackandbleed.ogg", 100)
			if(wounding_type == WOUND_SLASH && !easy_dismember)
				wounding_dmg *= 0.6 // edged weapons pass along 60% of their wounding damage to the bone since the power is spread out over a larger area
			if(wounding_type == WOUND_PIERCE && !easy_dismember)
				wounding_dmg *= 0.8 // piercing weapons pass along 80% of their wounding damage to the bone since it's more concentrated
			if((wounding_type == WOUND_SLASH) || (wounding_type == WOUND_PIERCE))
				wounding_type = WOUND_BLUNT
			else if(wounding_type == WOUND_BLUNT)
				wounding_type = WOUND_PIERCE
		// A big blunt weapon too can dismember a limb
		// If we already have a mangled bone, we start rolling (inefficiently) for slashes
		else if((wounding_type == WOUND_BLUNT) && (mangled_state & BODYPART_MANGLED_BONE) && !(mangled_state & BODYPART_MANGLED_MUSCLE) && !sharpness)
			playsound(src, "modular_skyrat/sound/effects/crackandbleed.ogg", 100)
			if(!easy_dismember)
				wounding_dmg *= 0.5
			wounding_type = WOUND_SLASH
	// Bone only, all cutting/piercing attacks go straight to the bone
	else if(CHECK_BITFIELD(bio_state, BIO_BONE))
		if(wounding_type == WOUND_SLASH)
			wounding_type = WOUND_BLUNT
			if(!easy_dismember)
				wounding_dmg *= 0.5
		else if(wounding_type == WOUND_PIERCE)
			wounding_type = WOUND_BLUNT
			if(!easy_dismember)
				wounding_dmg *= 0.75
	// Slime people, flesh only
	else if(CHECK_BITFIELD(bio_state, BIO_FLESH))
		if(wounding_type == WOUND_BLUNT)
			wounding_type = WOUND_SLASH
			if(!easy_dismember)
				wounding_dmg *= 0.5
		else if(wounding_type == WOUND_PIERCE)
			wounding_dmg *= 1.5 // it's easy to puncture into plain flesh

	// Check the wounding now
	if(owner && wounding_dmg >= WOUND_MINIMUM_DAMAGE && wound_bonus > CANT_WOUND)
		check_wounding(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
		if(wounding_type in list(WOUND_SLASH, WOUND_PIERCE))
			if(wounding_dmg >= ARTERY_MINIMUM_DAMAGE)
				check_wounding(WOUND_ARTERY, wounding_dmg * (initial_wounding_type == WOUND_PIERCE ? 0.75 : 1), wound_bonus, bare_wound_bonus)
		if(wounding_type in list(WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE))
			if(wounding_dmg >= TENDON_MINIMUM_DAMAGE)
				check_wounding(WOUND_TENDON, wounding_dmg * (initial_wounding_type in list(WOUND_BLUNT, WOUND_PIERCE) ? 0.75 : 1), wound_bonus, bare_wound_bonus)

	//We've dealt with everything else, so let's share the pain
	if(!can_feel_pain())
		//Or not - The trip was cut short
		pain = 0

	pain_dam += (pain - (owner?.chem_effects[CE_PAINKILLER]/3))
	if(extrapain && owner?.can_feel_pain())
		//extra pain - add it straight to the shock value
		owner.shock_stage += max(0, extrapain - (owner?.chem_effects[CE_PAINKILLER]/3))

	if(owner && pain && (pain >= (max_pain_damage * 0.5)) && prob(10))
		owner.emote("agonyscream")

	if(owner && pain)
		owner.flash_pain(min(round(pain/30) * 255, 255), 0, rand(1,4), pick(5,10))

	if(is_robotic_limb() && owner)
		if((brute+burn) > 3 && prob(20+brute+burn))
			do_sparks(3,FALSE,src.owner)

	//Update the owner's health stuffies
	if(owner && updating_health)
		owner.updatehealth()
		if(stamina > DAMAGE_PRECISION)
			owner.update_stamina()
		if(pain > DAMAGE_PRECISION)
			owner.update_pain()

	//Handle dismemberment if appropriate, everything is done
	if(CHECK_MULTIPLE_BITFIELDS(bio_state, BIO_FULL))
		if(CHECK_MULTIPLE_BITFIELDS(mangled_state, BODYPART_MANGLED_BOTH))
			damage_integrity(initial_wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
	else if(CHECK_BITFIELD(bio_state, BIO_FLESH))
		if(CHECK_BITFIELD(mangled_state, BODYPART_MANGLED_MUSCLE))
			damage_integrity(initial_wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
	else if(CHECK_BITFIELD(bio_state, BIO_BONE))
		if(CHECK_BITFIELD(mangled_state, BODYPART_MANGLED_BONE))
			damage_integrity(initial_wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
	if(try_dismember(initial_wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus))
		return

	consider_processing()
	update_disabled()
	return created_injury

/// Creates an injury on the bodypart
/obj/item/bodypart/proc/create_injury(injury_type = WOUND_BLUNT, damage = 0, surgical = FALSE, wound_messages = TRUE)
	if(damage <= 0)
		return FALSE

	// First check whether we can widen an existing wound
	if(!surgical && length(injuries) && prob(clamp(50 + (number_injuries-1 * 10), 50, 80)))
		// Piercing injuries cannot merge together
		// Small ass damage should create a new wound entirely
		if((injury_type != WOUND_PIERCE) && damage >= 5)
			var/list/compatible_injuries = list()
			for(var/datum/injury/IN in injuries)
				if(IN.can_worsen(injury_type, damage))
					compatible_injuries |= IN
			if(length(compatible_injuries))
				var/datum/injury/IN = pick(compatible_injuries)
				IN.open_injury(damage)
				if(owner && wound_messages && prob(25 + damage))
					owner.wound_message += " \The [IN.desc] on [src] worsens!"
				return IN

	//Creating injury
	var/wound_type = get_injury_type(injury_type, damage)
	if(wound_type)
		var/datum/injury/IN = new wound_type()
		//Check whether we can add the wound to an existing wound
		if(surgical)
			IN.autoheal_cutoff = 0
			IN.injury_flags |= INJURY_SURGICAL
		else
			for(var/datum/injury/other in injuries)
				if(other.can_merge(IN))
					other.merge_injury(IN)
					return other
		return IN
	return FALSE

/// Allows us to roll for and apply a wound without actually dealing damage. Used for aggregate wounding power with pellet clouds (note this doesn't let sharp go to bone)
/obj/item/bodypart/proc/painless_wound_roll(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus, silent = FALSE)
	if(!owner || (wounding_dmg <= WOUND_MINIMUM_DAMAGE) || (wound_bonus <= CANT_WOUND))
		return FALSE

	var/initial_wounding_type = wounding_type
	var/mangled_state = get_mangled_state()
	var/bio_state = owner.get_biological_state()

	var/easy_dismember = HAS_TRAIT(owner, TRAIT_EASYDISMEMBER) // if we have easydismember, we don't reduce damage when redirecting damage to different types (slashing weapons on mangled/skinless limbs attack at 100% instead of 50%)

	//We check all wound-related traits to multiply damage adequately.
	if((body_zone == BODY_ZONE_PRECISE_MOUTH || body_zone == BODY_ZONE_HEAD) && HAS_TRAIT(owner, TRAIT_GLASSJAW))
		wounding_dmg *= 2
	if(wounding_type == WOUND_BLUNT && HAS_TRAIT(owner, TRAIT_EASYBLUNT))
		wounding_dmg *= 2

	// Standard humanoids, flesh and bone
	if(CHECK_MULTIPLE_BITFIELDS(bio_state, BIO_FULL))
		// If we've already mangled the muscle (critical slash or piercing wound), then the bone is exposed, and we can damage it with sharp weapons at a reduced rate
		// So a big sharp weapon is still all you need to rip off a limb
		if((mangled_state & BODYPART_MANGLED_MUSCLE) && !(mangled_state & BODYPART_MANGLED_BONE) && sharpness)
			playsound(src, "modular_skyrat/sound/effects/crackandbleed.ogg", 100)
			if(wounding_type == WOUND_SLASH && !easy_dismember)
				wounding_dmg *= 0.6 // edged weapons pass along 60% of their wounding damage to the bone since the power is spread out over a larger area
			if(wounding_type == WOUND_PIERCE && !easy_dismember)
				wounding_dmg *= 0.8 // piercing weapons pass along 80% of their wounding damage to the bone since it's more concentrated
			if((wounding_type == WOUND_SLASH) || (wounding_type == WOUND_PIERCE))
				wounding_type = WOUND_BLUNT
			else if(wounding_type == WOUND_BLUNT)
				wounding_type = WOUND_PIERCE
		// A big blunt weapon too can dismember a limb
		// If we already have a mangled bone, we start rolling (inefficiently) for slashes
		else if((wounding_type == WOUND_BLUNT) && (mangled_state & BODYPART_MANGLED_BONE) && !(mangled_state & BODYPART_MANGLED_MUSCLE) && !sharpness)
			playsound(src, "modular_skyrat/sound/effects/crackandbleed.ogg", 100)
			if(!easy_dismember)
				wounding_dmg *= 0.5
			wounding_type = WOUND_SLASH
	// Bone only, all cutting/piercing attacks go straight to the bone
	else if(CHECK_BITFIELD(bio_state, BIO_BONE))
		if(wounding_type == WOUND_SLASH)
			wounding_type = WOUND_BLUNT
			if(!easy_dismember)
				wounding_dmg *= 0.5
		else if(wounding_type == WOUND_PIERCE)
			wounding_type = WOUND_BLUNT
			if(!easy_dismember)
				wounding_dmg *= 0.75
	// Slime people, flesh only
	else if(CHECK_BITFIELD(bio_state, BIO_FLESH))
		if(wounding_type == WOUND_BLUNT)
			wounding_type = WOUND_SLASH
			if(!easy_dismember)
				wounding_dmg *= 0.5
		else if(wounding_type == WOUND_PIERCE)
			wounding_dmg *= 1.5 // it's easy to puncture into plain flesh

	// Check the wounding now
	if(owner && wounding_dmg >= WOUND_MINIMUM_DAMAGE && wound_bonus > CANT_WOUND)
		check_wounding(wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
		if(wounding_type in list(WOUND_SLASH, WOUND_PIERCE))
			if(wounding_dmg >= ARTERY_MINIMUM_DAMAGE)
				check_wounding(WOUND_ARTERY, wounding_dmg * (initial_wounding_type == WOUND_PIERCE ? 0.5 : 1), wound_bonus, bare_wound_bonus)
		if(wounding_type in list(WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE))
			if(wounding_dmg >= TENDON_MINIMUM_DAMAGE)
				check_wounding(WOUND_TENDON, wounding_dmg * (initial_wounding_type == WOUND_PIERCE ? 0.5 : 1), wound_bonus, bare_wound_bonus)

	//Handle dismemberment if appropriate, everything is done
	if(CHECK_MULTIPLE_BITFIELDS(bio_state, BIO_FULL))
		if(CHECK_MULTIPLE_BITFIELDS(mangled_state, BODYPART_MANGLED_BOTH))
			damage_integrity(initial_wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
	else if(CHECK_BITFIELD(bio_state, BIO_FLESH))
		if(CHECK_MULTIPLE_BITFIELDS(mangled_state, BODYPART_MANGLED_MUSCLE))
			damage_integrity(initial_wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
	else if(CHECK_BITFIELD(bio_state, BIO_BONE))
		if(CHECK_MULTIPLE_BITFIELDS(mangled_state, BODYPART_MANGLED_BONE))
			damage_integrity(initial_wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)
	try_dismember(initial_wounding_type, wounding_dmg, wound_bonus, bare_wound_bonus)

//Proc for damaging organs inside a limb
/obj/item/bodypart/proc/damage_organs(brute = 0, burn = 0, toxin = 0, clone = 0, wounding_type = WOUND_BLUNT)
	var/list/internal_organs = owner?.getorganszone(body_zone)
	for(var/obj/item/organ/O in internal_organs)
		internal_organs -= O
		if(O.damage < O.maxHealth)
			internal_organs[O] = O.relative_size
	if(!length(internal_organs) || (!brute && !burn && !toxin && !clone))
		return

	var/broken = is_broken()
	var/initial_damage_amt = brute
	var/cur_damage = brute_dam
	//Robotic limbs count burns for organ damage
	if(is_robotic_limb() && ((wounding_type == WOUND_BURN) || (burn > brute)))
		//Think of it as frying the organs with hot metal
		initial_damage_amt += burn
		cur_damage += burn_dam
	//Organic limbs take clone damage, however...
	else if(is_organic_limb())
		initial_damage_amt += clone
		//Clone damage makes you way more likely to get your organs fricked up
		//Think of it as cancer
		cur_damage += clone

	var/damage_amt = initial_damage_amt
	var/organ_damage_threshold = organ_damage_hit_minimum
	var/organ_damage_required = organ_damage_requirement
	//Piercing damage is more likely to damage internal organs
	if(wounding_type == WOUND_PIERCE)
		organ_damage_threshold *= 0.5
	//Slashing damage is *slightly* more likely to damage internal organs
	else if(wounding_type == WOUND_SLASH)
		organ_damage_threshold *= 0.75
	//Wounds can alter our odds of harming organs
	for(var/datum/wound/W in wounds)
		damage_amt += initial_damage_amt * W.damage_roll_increase
		damage_amt += W.flat_damage_roll_increase
		organ_damage_threshold = max(1, organ_damage_threshold - (organ_damage_hit_minimum * W.organ_threshold_reduction))
		organ_damage_required = max(1, organ_damage_required - (organ_damage_requirement * W.organ_required_reduction))
	if(!(cur_damage + damage_amt >= organ_damage_required) && !(damage_amt >= organ_damage_threshold))
		return FALSE

	var/organ_hit_chance = (25 * damage_amt/organ_damage_threshold)

	if(encased && !broken)
		organ_hit_chance *= 0.6

	organ_hit_chance = CEILING(organ_hit_chance, 1)
	organ_hit_chance = min(organ_hit_chance, 100)

	if(prob(organ_hit_chance))
		var/obj/item/organ/victim = pickweight(internal_organs)
		damage_amt = max(0, damage_amt - victim.damage_reduction - (damage_amt * victim.damage_modifier))
		if(damage_amt >= 1)
			victim.applyOrganDamage(damage_amt)
		if(owner && (damage_amt >= 10))
			owner.custom_pain("<b>MY [uppertext(victim.name)] HURTS!</b>", 20, affecting = src)
		return TRUE

//Heals brute, burn, stamina, pain, toxin and clone damage for the organ. Returns 1 if the damage-icon states changed at all.
//Damage cannot go below zero.
//Cannot remove negative damage (i.e. apply damage)
/obj/item/bodypart/proc/heal_damage(brute, burn, stamina, only_robotic = FALSE, only_organic = TRUE, updating_health = TRUE, pain, toxin, clone)
	if(only_robotic && !is_robotic_limb()) //This makes organic limbs not heal when the proc is in robotic mode.
		return

	if(only_organic && !is_organic_limb()) //This makes robolimbs not healable by chems.
		return

	for(var/datum/injury/IN in injuries)
		if(brute <= 0)
			break
		if(IN.damage_type == WOUND_BURN)
			continue
		brute = IN.heal_damage(brute)

	for(var/datum/injury/IN in injuries)
		if(burn <= 0)
			break
		if(IN.damage_type != WOUND_BURN)
			continue
		burn = IN.heal_damage(burn)

	limb_integrity = round(min(limb_integrity + brute + burn, max_limb_integrity))
	stamina_dam = round(max(stamina_dam - stamina, 0), DAMAGE_PRECISION)
	pain_dam = round(max(pain_dam - pain, 0), DAMAGE_PRECISION)
	tox_dam = round(max(tox_dam - toxin, 0), DAMAGE_PRECISION)
	clone_dam = round(max(clone_dam - clone, 0), DAMAGE_PRECISION)
	if(owner && updating_health)
		owner.updatehealth()
	if(owner.dna && owner.dna.species && (REVIVESBYHEALING in owner.dna.species.species_traits))
		if(((owner.maxHealth - owner.get_physical_damage()) > owner.dna.species.revivesbyhealreq) && !owner.hellbound)
			if((NOBLOOD in owner.dna.species.species_traits) || (owner.blood_volume >= BLOOD_VOLUME_OKAY))
				owner.revive(0)
				owner.cure_husk(0) // If it has REVIVESBYHEALING, it probably can't be cloned. No husk cure.
	update_damages()
	consider_processing()
	update_disabled()
	return update_bodypart_damage_state() || .

//Filters toxins into the organs
/obj/item/bodypart/proc/filter_toxins(toxins = 0, only_robotic = FALSE, only_organic = FALSE, updating_health = FALSE)
	toxins = clamp(toxins, 0, max(0, tox_dam))
	if(!toxins || !owner)
		return

	// Heal the bodypart toxin damage.
	var/tox_before = tox_dam
	heal_damage(toxin = toxins, only_robotic = only_robotic, only_organic = only_organic, updating_health = updating_health)

	// Just to be sure nothing will go wrong
	if(tox_before >= tox_dam)
		return

	// Get a list of the organs we should damage.
	var/list/pick_organs = list()
	pick_organs |= get_organs()
	pick_organs = shuffle(pick_organs)

	// Prioritize damaging our filtration organs first.
	var/obj/item/organ/liver/liver = owner.getorganslot(ORGAN_SLOT_LIVER)
	if(liver && (liver in pick_organs))
		pick_organs -= liver
		pick_organs.Insert(1, liver)

	var/obj/item/organ/kidneys/kidneys = owner.getorganslot(ORGAN_SLOT_KIDNEYS)
	if(kidneys && (kidneys in pick_organs))
		pick_organs -= kidneys
		pick_organs.Insert(1, kidneys)

	// Brain damage literally kills us, so we damage the brain last
	var/obj/item/organ/brain/brain = owner.getorganslot(ORGAN_SLOT_BRAIN)
	if(brain && (brain in pick_organs))
		pick_organs -= brain
		pick_organs += brain

	for(var/obj/item/organ/O in pick_organs)
		if(toxins <= 0)
			break

		var/cap_damage = (O.maxHealth - O.damage)
		O.applyOrganDamage(min(cap_damage, toxins * O.toxin_multiplier))
		if(toxins > cap_damage)
			toxins -= cap_damage

	// Well... shit, we ran through our organs but we still need to dish out pain.
	// We run another cycle through all of the organs
	if(toxins > 0)
		pick_organs = owner.getCurrentOrgans()
		if(kidneys)
			pick_organs -= kidneys
			pick_organs.Insert(1, kidneys)
		if(liver)
			pick_organs -= liver
			pick_organs.Insert(1, liver)
		for(var/obj/item/organ/O in pick_organs)
			if(toxins <= 0)
				break

			var/cap_damage = (O.maxHealth - O.damage)
			O.applyOrganDamage(min(cap_damage, toxins))
			if(toxins > cap_damage)
				toxins -= cap_damage

//Returns total damage.
/obj/item/bodypart/proc/get_damage(include_stamina = FALSE, include_pain = FALSE, include_clone = FALSE, include_tox = FALSE)
	var/total = brute_dam + burn_dam
	if(include_stamina)
		total += stamina_dam
	if(include_pain)
		total += pain_dam
	if(include_clone)
		total += clone_dam
	if(include_tox)
		total += tox_dam
	return total

//Returns pain damage
/obj/item/bodypart/proc/get_pain()
	if(!can_feel_pain())
		return 0
	var/multiplier = 1 //Multiply our total pain damage by this
	if(grasped_by)
		//Being grasped lowers the pain just a bit
		multiplier *= 0.75
	if(is_robotic_limb())
		//Robotic limbs feel a bit less pain, but are not immune to it
		multiplier *= 0.5
	var/extra_pain = 0
	extra_pain += 0.5 * brute_dam
	extra_pain += 0.6 * burn_dam
	extra_pain += 1 * tox_dam // Toxin damage gets filtered, but causes a lot of pain while on the bodypart
	extra_pain += 0.7 * clone_dam // Damage at a cellular level is quite painful
	for(var/datum/wound/W in wounds)
		extra_pain += W.pain_amount
	for(var/obj/item/organ/O in get_organs())
		extra_pain += O.get_pain()
	for(var/obj/item/I in embedded_objects)
		if(!I.isEmbedHarmless())
			extra_pain += 5 * I.w_class
	return clamp((pain_dam + extra_pain) * multiplier, 0, max_pain_damage)

//Returns whether or not the bodypart can feel pain
/obj/item/bodypart/proc/can_feel_pain()
	if(is_cut_away())
		return FALSE
	if(owner)
		if(!owner.can_feel_pain())
			return FALSE
		return TRUE
	return FALSE

//Checks disabled status thresholds
/obj/item/bodypart/proc/update_disabled(upparent = TRUE, upchildren = TRUE)
	if(!owner)
		return
	set_disabled(is_disabled())
	if(upparent)
		if(parent_bodyzone)
			var/obj/item/bodypart/BP = owner.get_bodypart(parent_bodyzone)
			if(BP)
				BP.update_disabled(TRUE, FALSE)
	if(children_zones)
		for(var/zoner in children_zones)
			var/obj/item/bodypart/CBP = owner.get_bodypart(zoner)
			if(CBP)
				CBP.update_disabled(FALSE, TRUE)

/obj/item/bodypart/proc/is_disabled()
	if(!owner)
		return FALSE
	if(is_dead())
		return BODYPART_DISABLED_DEAD
	if(is_cut_away() || is_stump())
		return BODYPART_DISABLED_SEVERED
	if(HAS_TRAIT(owner, TRAIT_PARALYSIS) || (is_dead()))
		return BODYPART_DISABLED_PARALYSIS
	for(var/i in wounds)
		var/datum/wound/W = i
		if(W.should_disable_limb(src))
			return BODYPART_DISABLED_WOUND
	if(can_dismember())
		. = disabled //inertia, to avoid limbs healing 0.1 damage and being re-enabled
		if(parent_bodyzone && (parent_bodyzone != BODY_ZONE_CHEST) && (parent_bodyzone != BODY_ZONE_HEAD))
			if(!(owner.get_bodypart(parent_bodyzone)))
				return BODYPART_DISABLED_DAMAGE
			else
				var/obj/item/bodypart/parent = owner.get_bodypart(parent_bodyzone)
				if(parent.is_disabled())
					return parent.is_disabled()
		if(stamina_dam >= ((max_damage * (HAS_TRAIT(owner, TRAIT_EASYLIMBDISABLE) ? 0.6 : 1) * (owner?.mind ? (2 - GET_STAT(owner, end).get_shock_mult()) : 1)))) //Easy limb disable disables the limb at 40% health instead of 0%
			if(!last_maxed)
				last_maxed = TRUE
				owner?.emote("scream")
			return BODYPART_DISABLED_DAMAGE
		if(stamina_dam >= max_stamina_damage)
			return BODYPART_DISABLED_DAMAGE
		if((get_pain() - owner?.chem_effects[CE_PAINKILLER]) * (owner?.mind ? owner.mind.mob_stats[STAT_DATUM(end)].get_shock_mult() : 1) >= pain_disability_threshold)
			return BODYPART_DISABLED_PAIN
		if(disabled && (get_damage(include_stamina = TRUE) <= (max_damage * 0.8)) && (pain_dam < pain_disability_threshold)) // reenabled at 80% now instead of 50% as of wounds update
			last_maxed = FALSE
			return BODYPART_NOT_DISABLED
	else
		return BODYPART_NOT_DISABLED

/obj/item/bodypart/proc/check_disabled() //This might be depreciated and should be safe to remove.
	if(!owner || !can_dismember())
		return
	if(!disabled && (get_damage(TRUE) >= max_damage))
		set_disabled(TRUE)
	else if(disabled && (get_damage(TRUE) <= (max_damage * 0.5)))
		set_disabled(FALSE)

/obj/item/bodypart/proc/set_disabled(new_disabled)
	if(disabled == new_disabled || !owner)
		return FALSE
	disabled = new_disabled
	if(disabled && owner.get_item_for_held_index(held_index))
		owner.dropItemToGround(owner.get_item_for_held_index(held_index))
	owner.update_health_hud() //update the healthdoll
	owner.update_body()
	owner.update_mobility()
	if(!disabled)
		incoming_stam_mult = 1
	return TRUE

//Updates an organ's brute/burn states for use by update_damage_overlays()
//Returns 1 if we need to update overlays. 0 otherwise.
/obj/item/bodypart/proc/update_bodypart_damage_state()
	var/need_update = FALSE
	var/tbrute	= round( (brute_dam/max_damage)*3, 1 )
	var/tburn	= round( (burn_dam/max_damage)*3, 1 )
	var/datum/injury/inj = get_incision()
	if(inj && CHECK_BITFIELD(inj.injury_flags, INJURY_RETRACTED_SKIN))
		need_update = TRUE
	if((tbrute != brutestate) || (tburn != burnstate))
		brutestate = tbrute
		burnstate = tburn
		need_update = TRUE
	return need_update

//Change bodypart status
/obj/item/bodypart/proc/change_bodypart_status(new_limb_status, heal_limb, change_icon_to_default, override = TRUE)
	if(override)
		status = new_limb_status
	else
		status |= new_limb_status
	if(heal_limb)
		burn_dam = 0
		brute_dam = 0
		brutestate = 0
		burnstate = 0
		stamina_dam = 0
		pain_dam = 0
		tox_dam = 0
		clone_dam = 0

	if(change_icon_to_default)
		if(is_organic_limb())
			icon = base_bp_icon || DEFAULT_BODYPART_ICON_ORGANIC
		else
			icon = DEFAULT_BODYPART_ICON_ROBOTIC

	if(owner)
		owner.updatehealth()
		owner.update_body() //if our head becomes robotic, we remove the lizard horns and human hair.
		owner.update_hair()
		owner.update_damage_overlays()
		owner.update_medicine_overlays()

//Status related procs
/obj/item/bodypart/proc/is_organic_limb()
	return (CHECK_BITFIELD(status, BODYPART_ORGANIC))

/obj/item/bodypart/proc/is_robotic_limb()
	return (CHECK_BITFIELD(status, BODYPART_ROBOTIC))

/obj/item/bodypart/proc/is_mixed_limb()
	return (is_organic_limb() && is_robotic_limb())

/obj/item/bodypart/proc/can_bleed()
	return !(limb_flags & BODYPART_NOBLEED)

/obj/item/bodypart/proc/is_dead()
	return (limb_flags & BODYPART_DEAD)

/obj/item/bodypart/proc/is_cut_away()
	return (limb_flags & BODYPART_CUT_AWAY)

/obj/item/bodypart/proc/is_tendon_torn()
	. = FALSE
	for(var/datum/wound/W in wounds)
		if(istype(W, /datum/wound/tendon)) //We have a torn tendon
			return TRUE

/obj/item/bodypart/proc/is_artery_torn()
	. = FALSE
	for(var/datum/wound/W in wounds)
		if(istype(W, /datum/wound/artery)) //We have a torn artery
			return TRUE

/obj/item/bodypart/proc/is_broken()
	. = FALSE
	for(var/datum/wound/W in wounds)
		if((istype(W, /datum/wound/blunt) || istype(W, /datum/wound/mechanical/blunt)) && (W.severity >= WOUND_SEVERITY_SEVERE)) //We have a fracture
			return TRUE

/obj/item/bodypart/proc/is_dislocated()
	. = FALSE
	for(var/datum/wound/W in wounds)
		if(istype(W, /datum/wound/blunt) || istype(W, /datum/wound/mechanical/blunt)) //We have a dislocation/fracture
			return TRUE

/obj/item/bodypart/proc/is_bandaged()
	. = TRUE
	for(var/datum/injury/IN in injuries)
		if(!IN.is_bandaged())
			return FALSE

/obj/item/bodypart/proc/is_salved()
	. = TRUE
	for(var/datum/injury/IN in injuries)
		if(!IN.is_salved())
			return FALSE

/obj/item/bodypart/proc/is_disinfected()
	. = TRUE
	for(var/datum/injury/IN in injuries)
		if(!IN.is_disinfected())
			return FALSE

/obj/item/bodypart/proc/is_clamped()
	. = TRUE
	for(var/datum/injury/IN in injuries)
		if(!IN.is_clamped())
			return FALSE

/obj/item/bodypart/proc/is_stump()
	return FALSE

/obj/item/bodypart/proc/kill_limb()
	limb_flags |= BODYPART_DEAD
	var/already_rot = (species_id == "rot")
	update_limb(!owner)
	if(owner && !already_rot && (species_id == "rot"))
		owner?.regenerate_icons()
	else if(!owner)
		update_icon_dropped()

/obj/item/bodypart/proc/revive_limb()
	limb_flags &= ~BODYPART_DEAD
	var/already_rot = (species_id == "rot")
	update_limb(!owner)
	if(owner && already_rot && (species_id != "rot"))
		owner?.regenerate_icons()
	else if(!owner)
		update_icon_dropped()

// open incisions and expose implants
// this is the retract step of surgery
/obj/item/bodypart/proc/open_incision(mob/user)
	var/datum/injury/IN = get_incision()
	if(!IN)
		return

	IN.open_injury(min(IN.damage * 2, IN.damage_list[1] - IN.damage), TRUE)
	for(var/obj/item/organ/O in get_organs())
		O.on_find(user)

/obj/item/bodypart/proc/clamp_limb()
	for(var/datum/injury/IN in injuries)
		IN.clamp_injury()

/obj/item/bodypart/proc/unclamp_limb()
	for(var/datum/injury/IN in injuries)
		IN.unclamp_injury()

/obj/item/bodypart/proc/salve_limb()
	for(var/datum/injury/IN in injuries)
		IN.salve_injury()

/obj/item/bodypart/proc/unsalve_limb()
	for(var/datum/injury/IN in injuries)
		IN.unsalve_injury()

/obj/item/bodypart/proc/disinfect_limb()
	for(var/datum/injury/IN in injuries)
		IN.disinfect_injury()

/obj/item/bodypart/proc/undisinfect_limb()
	for(var/datum/injury/IN in injuries)
		IN.undisinfect_injury()

/obj/item/bodypart/proc/bandage_limb()
	for(var/datum/injury/IN in injuries)
		IN.bandage_injury()

/obj/item/bodypart/proc/unbandage_limb()
	for(var/datum/injury/IN in injuries)
		IN.unbandage_injury()

/obj/item/bodypart/proc/can_recover()
	return ((max_damage > 0) && !(limb_flags & BODYPART_DEAD)) || (death_time >= world.time - ORGAN_RECOVERY_THRESHOLD)

//Used by surgery
/obj/item/bodypart/proc/get_incision(strict = FALSE)
	var/datum/injury/incision
	for(var/datum/injury/slash/IN in injuries)
		if(IN.is_bandaged() || IN.current_stage > IN.max_bleeding_stage) // Shit's unusable
			continue
		if(strict && !IN.is_surgical()) //We don't need dirty ones
			continue
		if(!incision)
			incision = IN
			continue
		var/same = (IN.is_surgical() && incision.is_surgical())
		if(same) //If they're both dirty or both are surgical, just get bigger one
			if(IN.damage > incision.damage)
				incision = IN
		else if(IN.is_surgical()) //otherwise surgical one takes priority
			incision = IN
	return incision

/obj/item/bodypart/proc/how_open()
	. = 0
	var/datum/injury/incision = get_incision()
	if(incision)
		. |= SURGERY_INCISED
		if(CHECK_BITFIELD(incision.injury_flags, INJURY_RETRACTED_SKIN))
			. |= SURGERY_RETRACTED
		if(CHECK_BITFIELD(incision.injury_flags, INJURY_SET_BONES))
			. |= SURGERY_SET_BONES
		if(CHECK_BITFIELD(incision.injury_flags, INJURY_DRILLED))
			. |= SURGERY_DRILLED
	if(is_broken())
		. |= SURGERY_BROKEN

//To update the bodypart's icon when not attached to a mob
/obj/item/bodypart/proc/update_icon_dropped()
	cut_overlays()
	var/list/standing = get_limb_icon(TRUE)
	for(var/image/I in standing)
		I.pixel_x = px_x
		I.pixel_y = px_y
	for(var/obj/item/bodypart/BP in src)
		if(iseye(BP))
			continue
		var/list/substanding = BP.get_limb_icon(TRUE)
		for(var/image/I in substanding)
			I.pixel_x = px_x
			I.pixel_y = px_y
		standing |= substanding
		for(var/obj/item/bodypart/grandchild in BP)
			var/list/subsubstanding = grandchild.get_limb_icon(TRUE)
			for(var/image/I in subsubstanding)
				I.pixel_x = px_x
				I.pixel_y = px_y
			standing |= subsubstanding
			//the ride never ends
			for(var/obj/item/bodypart/ggrandchild in grandchild)
				var/list/subsubsubstanding = ggrandchild.get_limb_icon(TRUE)
				for(var/image/I in subsubsubstanding)
					I.pixel_x = px_x
					I.pixel_y = px_y
				standing |= subsubsubstanding
	if(!length(standing))
		icon_state = initial(icon_state)//no overlays found, we default back to initial icon.
		return
	add_overlay(standing)

/obj/item/bodypart/deconstruct(disassembled = TRUE)
	drop_organs()
	qdel(src)

/**
  * check_wounding() is where we handle rolling for, selecting, and applying a wound if we meet the criteria
  *
  * We generate a "score" for how woundable the attack was based on the damage and other factors discussed in [check_woundings_mods()], then go down the list from most severe to least severe wounds in that category.
  * We can promote a wound from a lesser to a higher severity this way, but we give up if we have a wound of the given type and fail to roll a higher severity, so no sidegrades/downgrades
  *
  * Arguments:
  * * woundtype- Either WOUND_SLASH, WOUND_PIERCE, WOUND_BLUNT, or WOUND_BURN based on the attack type.
  * * damage- How much damage is tied to this attack, since wounding potential scales with damage in an attack (see: WOUND_DAMAGE_EXPONENT)
  * * wound_bonus- The wound_bonus of an attack
  * * bare_wound_bonus- The bare_wound_bonus of an attack
  * * silent - If not silent, the wound displays a message in chat
  */
/obj/item/bodypart/proc/check_wounding(woundtype, damage, wound_bonus, bare_wound_bonus, silent = TRUE)
	if(!owner)
		return
	// actually roll wounds if applicable
	var/organic = is_organic_limb()
	if(HAS_TRAIT(owner, TRAIT_EASYLIMBDISABLE))
		damage *= 1.5

	var/base_roll = rand(1, round(damage ** WOUND_DAMAGE_EXPONENT))
	var/injury_roll = base_roll
	var/check_gauze = FALSE
	injury_roll += check_woundings_mods(woundtype, damage, wound_bonus, bare_wound_bonus)
	var/list/wounds_checking

	switch(woundtype)
		if(WOUND_BLUNT)
			wounds_checking = WOUND_LIST_BLUNT
			if(!organic)
				wounds_checking = WOUND_LIST_BLUNT_MECHANICAL
			check_gauze = TRUE
		if(WOUND_ARTERY)
			wounds_checking = WOUND_LIST_ARTERY
			if(!organic)
				wounds_checking = null
		if(WOUND_TENDON)
			wounds_checking = WOUND_LIST_TENDON
			if(!organic)
				wounds_checking = null

	if(!length(wounds_checking))
		return

	//check if there's gauze, and if we should destroy or damage it, before we apply any wounds
	if(current_gauze && check_gauze)
		if(prob(base_roll/2))
			if(prob(base_roll/2))
				owner.visible_message("<span class='danger'>\The [current_gauze] on [owner]'s [src.name] shreds apart completely!</span>", "<span class='userdanger'>\The [current_gauze] on your [src.name] gets completely shredded!</span>")
				var/obj/item/reagent_containers/rag/R = new /obj/item/reagent_containers/rag()
				R.name = "shredded [current_gauze.name]"
				R.desc = "Pretty worthless for medicine now..."
				R.add_mob_blood(owner)
				remove_gauze(drop_gauze = FALSE)
			else
				owner.visible_message("<span class='danger'>\The [current_gauze] on [owner]'s [src.name] falls off!</span>", "<span class='userdanger'>\The [current_gauze] on your [src.name] falls off!</span>")
				current_gauze.add_mob_blood(owner)
				remove_gauze(drop_gauze = TRUE)

		else if(prob(base_roll))
			owner.visible_message("<span class='boldwarning'>\The [current_gauze] on [owner]'s [src.name] tears up a bit!</span>", "<span class='danger'>\The [current_gauze] on your [src.name] tears up a bit!</span>")
			for(var/i in wounds)
				var/datum/wound/woundie = i
				if(istype(woundie) && CHECK_BITFIELD(woundie.wound_flags, WOUND_SEEPS_GAUZE))
					seep_gauze(current_gauze.absorption_rate * (0.25 * woundie.severity))
			seep_gauze(current_gauze.absorption_rate * round(damage/10, 1))

	// quick re-check to see if bare_wound_bonus applies, for the benefit of log_wound(), see about getting the check from check_woundings_mods() somehow
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/list/clothing = H.clothingonpart(src)
		for(var/c in clothing)
			var/obj/item/clothing/clothes_check = c
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			if(clothes_check.armor.getRating("wound"))
				bare_wound_bonus = 0
				break

	//cycle through the wounds of the relevant category from the most severe down
	for(var/PW in wounds_checking)
		//I fucking hate byond, i cannot see the possible zones without creating a fucking new wound datum
		var/datum/wound/possible_wound = new PW()
		if(!(body_zone in possible_wound.viable_zones)) //Applying this wound won't even work, let's try the next one
			qdel(possible_wound)
			continue

		var/datum/wound/replaced_wound
		for(var/i in wounds)
			var/datum/wound/existing_wound = i
			if(existing_wound.type in wounds_checking)
				if(existing_wound.severity >= initial(possible_wound.severity))
					return
				else
					replaced_wound = existing_wound

		if(possible_wound.threshold_minimum * CONFIG_GET(number/wound_threshold_multiplier) < injury_roll)
			var/datum/wound/new_wound
			if(replaced_wound)
				new_wound = replaced_wound.replace_wound(possible_wound.type, FALSE, TRUE, silent)
				log_wound(owner, new_wound, damage, wound_bonus, bare_wound_bonus, base_roll)
				qdel(possible_wound)
			else
				new_wound = new possible_wound.type
				new_wound.apply_wound(src, silent)
				log_wound(owner, new_wound, damage, wound_bonus, bare_wound_bonus, base_roll)
				qdel(possible_wound)
			return new_wound

// try forcing a specific wound, but only if there isn't already a wound of that severity or greater for that type on this bodypart
/obj/item/bodypart/proc/force_wound_upwards(specific_woundtype, smited = FALSE)
	var/datum/wound/new_wound = new specific_woundtype
	for(var/datum/wound/existing_wound in wounds)
		if(existing_wound.wound_type == new_wound.wound_type)
			if(existing_wound.severity < initial(new_wound.severity)) // we only try if the existing one is inferior to the one we're trying to force
				existing_wound.replace_wound(new_wound, smited, TRUE)
			return

	var/severity = new_wound.severity
	if(!(body_zone in new_wound.viable_zones))
		var/list/fuck = (new_wound.wound_type - new_wound.type)
		for(var/i in fuck)
			new_wound = new i()
			if(!(body_zone in new_wound.viable_zones) || (severity != new_wound.severity))
				qdel(new_wound)
				continue
			else
				break
	if(new_wound)
		new_wound.apply_wound(src, smited = smited)

/**
  * check_wounding_mods() is where we handle the various modifiers of a wound roll
  *
  * A short list of things we consider: any armor a human target may be wearing, and if they have no wound armor on the limb, if we have a bare_wound_bonus to apply, plus the plain wound_bonus
  * We also flick through all of the wounds we currently have on this limb and add their threshold penalties, so that having lots of bad wounds makes you more liable to get hurt worse
  * Lastly, we add the inherent wound_resistance variable the bodypart has (heads and chests are slightly harder to wound), and a small bonus if the limb is already disabled
  *
  * Arguments:
  * * It's the same ones on [receive_damage()]
  */
/obj/item/bodypart/proc/check_woundings_mods(wounding_type, damage, wound_bonus, bare_wound_bonus)
	var/armor_ablation = 0
	var/injury_mod = 0

	if(owner && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		var/list/clothing = H.clothingonpart(src)
		for(var/c in clothing)
			var/obj/item/clothing/C = c
			// unlike normal armor checks, we tabluate these piece-by-piece manually so we can also pass on appropriate damage the clothing's limbs if necessary
			armor_ablation += C.armor.getRating("wound")
			if(wounding_type == WOUND_SLASH)
				C.take_damage_zone(body_zone, damage, BRUTE, armour_penetration)
			else if(wounding_type == WOUND_BURN && damage >= 10) // lazy way to block freezing from shredding clothes without adding another var onto apply_damage()
				C.take_damage_zone(body_zone, damage, BURN, armour_penetration)

		if(!armor_ablation)
			injury_mod += bare_wound_bonus

	injury_mod -= armor_ablation
	injury_mod += wound_bonus

	for(var/thing in wounds)
		var/datum/wound/W = thing
		injury_mod += W.threshold_penalty

	var/part_mod = -wound_resistance
	if(is_disabled())
		part_mod += disabled_wound_penalty

	injury_mod += part_mod

	return injury_mod

/// Get whatever wound of the given type is currently attached to this limb, if any
/obj/item/bodypart/proc/get_wound_type(checking_type)
	if(isnull(wounds))
		return

	for(var/datum/wound/W in wounds)
		if(istype(W, checking_type))
			return W

/**
  * update_wounds() is called whenever a wound is gained or lost on this bodypart, as well as if there's a change of some kind on a bone wound possibly changing disabled status
  *
  * Covers tabulating the damage multipliers we have from wounds (burn specifically), as well as deleting our gauze wrapping if we don't have any wounds that can use bandaging
  *
  * Arguments:
  * * replaced- If true, this is being called from the remove_wound() of a wound that's being replaced, so the bandage that already existed is still relevant, but the new wound hasn't been added yet
  */
/obj/item/bodypart/proc/update_wounds(replaced = FALSE)
	var/dam_mul = initial(wound_damage_multiplier)

	// we can (normally) only have one wound per type, but remember there's multiple types (smites like :B:loodless can generate multiple cuts on a limb)
	for(var/datum/wound/W in wounds)
		dam_mul *= W.damage_multiplier_penalty

	if(!LAZYLEN(wounds) && current_gauze && !replaced && (current_gauze.absorption_capacity <= 0))
		owner.visible_message("<span class='notice'>\The [current_gauze] on [owner]'s [name] fall away.</span>", "<span class='notice'>The [current_gauze] on your [name] fall away.</span>")
		remove_gauze(drop_gauze = FALSE)

	wound_damage_multiplier = dam_mul
	update_disabled()

/obj/item/bodypart/proc/get_bleed_rate()
	if(!can_bleed())
		return 0

	var/bleed_rate = 0
	if(generic_bleedstacks > 0)
		bleed_rate += 1

	for(var/thing in wounds)
		var/datum/wound/W = thing
		//Arteries don't give a shit about gauze so we do them later
		if(istype(W) && !(W.wound_type == WOUND_LIST_ARTERY))
			bleed_rate += W.blood_flow

	for(var/datum/injury/IN in injuries)
		if(IN.is_bleeding())
			bleed_rate += IN.get_bleed_rate()

	if(current_gauze)
		bleed_rate = max(0, bleed_rate - current_gauze.absorption_rate)

	if(!CHECK_BITFIELD(owner.mobility_flags, MOBILITY_STAND))
		bleed_rate *= 0.75

	if(grasped_by)
		bleed_rate *= 0.75

	return bleed_rate

/obj/item/bodypart/proc/apply_gauze(obj/item/stack/I)
	if(!istype(I) || !I.absorption_capacity)
		return
	QDEL_NULL(current_gauze)
	current_gauze = new I.type(src)
	current_gauze.amount = 1
	I.use(1)
	if(!owner)
		update_icon_dropped()
	else
		owner.update_medicine_overlays()

/obj/item/bodypart/proc/remove_gauze(drop_gauze = FALSE)
	if(!current_gauze)
		return

	if(!drop_gauze)
		QDEL_NULL(current_gauze)
	else
		var/turf/drop = get_turf(src)
		if(istype(drop))
			current_gauze.forceMove(drop)
		else
			qdel(current_gauze)
		current_gauze = null

	if(!owner)
		update_icon_dropped()
	else
		owner.update_medicine_overlays()

/**
  * seep_gauze() is for when a gauze wrapping absorbs blood or pus from wounds, lowering its absorption capacity.
  *
  * The passed amount of seepage is deducted from the bandage's absorption capacity, and if we reach a negative absorption capacity, the bandages fall off and we're left with nothing.
  *
  * Arguments:
  * * seep_amt - How much absorption capacity we're removing from our current bandages (think, how much blood or pus are we soaking up this tick?)
  */
/obj/item/bodypart/proc/seep_gauze(seep_amt = 0)
	if(!current_gauze)
		return
	current_gauze.absorption_capacity -= seep_amt
	if(current_gauze.absorption_capacity <= 0)
		owner.visible_message("<span class='danger'>\The [current_gauze] on [owner]'s [name] fall away in rags.</span>", "<span class='warning'>\The [current_gauze] on your [name] fall away in rags.</span>", vision_distance=COMBAT_MESSAGE_RANGE)
		remove_gauze()

//Update_limb() changes because synths
/obj/item/bodypart/proc/update_limb(dropping_limb, mob/living/carbon/source)
	var/mob/living/carbon/C
	if(source)
		C = source
		if(!original_owner)
			original_owner = source
			if(!original_dna && source.dna)
				original_dna = source.dna
				if(!original_species && source.dna.species)
					original_species = source.dna.species
		no_update = FALSE
	else if((owner && original_owner) && (owner != original_owner)) //Foreign limb
		C = owner
		no_update = TRUE
	else if(owner)
		C = owner
		no_update = FALSE

	if(!C)
		no_update = TRUE

	if(C && HAS_TRAIT(C, TRAIT_HUSK))
		species_id = "husk" //overrides species_id
		dmg_overlay_type = "" //no damage overlay shown when husked
		should_draw_gender = FALSE
		color_src = FALSE
		base_bp_icon = DEFAULT_BODYPART_ICON
		no_update = TRUE
		body_markings = "husk" // reeee
		aux_marking = "husk"
	else if((germ_level >= INFECTION_LEVEL_TWO) && is_organic_limb())
		species_id = "rot" //overrides species_id
		dmg_overlay_type = "" //no damage overlay shown when rotting
		should_draw_gender = FALSE
		color_src = FALSE
		base_bp_icon = DEFAULT_BODYPART_ICON
		no_update = TRUE
		body_markings = "husk" // reeee
		aux_marking = "husk"

	if(no_update)
		return

	if(!animal_origin)
		var/mob/living/carbon/human/H = C
		var/datum/species/S = H.dna?.species
		base_bp_icon = S?.icon_limbs || DEFAULT_BODYPART_ICON
		species_id = S?.limbs_id
		species_flags_list = S?.species_traits.Copy()

		//body marking memes
		var/list/colorlist = list()
		colorlist.Cut()
		colorlist += ReadRGB("[H.dna.features["mcolor"]]FF")
		colorlist += ReadRGB("[H.dna.features["mcolor2"]]FF")
		colorlist += ReadRGB("[H.dna.features["mcolor3"]]FF")
		colorlist += list(0,0,0, S.hair_alpha)
		for(var/index=1, index<=length(colorlist), index++)
			colorlist[index] = colorlist[index]/255

		if(S.use_skintones)
			skin_tone = H.skin_tone
			base_bp_icon = (base_bp_icon == DEFAULT_BODYPART_ICON) ? DEFAULT_BODYPART_ICON_ORGANIC : base_bp_icon
		else
			skin_tone = ""

		body_gender = H.dna.features["body_model"]
		should_draw_gender = S.sexes

		var/mut_colors = (MUTCOLORS in S.species_traits)
		if(mut_colors)
			if(S.fixed_mut_color)
				species_color = S.fixed_mut_color
			else
				species_color = H.dna.features["mcolor"]
			base_bp_icon = (base_bp_icon == DEFAULT_BODYPART_ICON) ? DEFAULT_BODYPART_ICON_ORGANIC : base_bp_icon
		else
			species_color = ""

		if(!(base_bp_icon in list(DEFAULT_BODYPART_ICON, DEFAULT_BODYPART_ICON_ROBOTIC)))
			color_src = mut_colors ? MUTCOLORS : ((H.dna.skin_tone_override && S.use_skintones == USE_SKINTONES_GRAYSCALE_CUSTOM) ? CUSTOM_SKINTONE : SKINTONE)

		if(S.mutant_bodyparts["legs"])
			if(body_zone == BODY_ZONE_L_LEG || body_zone == BODY_ZONE_R_LEG || body_zone == BODY_ZONE_PRECISE_R_FOOT || body_zone == BODY_ZONE_PRECISE_L_FOOT)
				if(DIGITIGRADE in S.species_traits)
					digitigrade_type = lowertext(H.dna.features["legs"])
			else
				digitigrade_type = null

		if(S.mutant_bodyparts["mam_body_markings"])
			var/datum/sprite_accessory/Smark
			Smark = GLOB.mam_body_markings_list[H.dna.features["mam_body_markings"]]
			if(Smark)
				body_markings_icon = Smark.icon
			if(H.dna.features["mam_body_markings"] != "None")
				body_markings = Smark?.icon_state || lowertext(H.dna.features["mam_body_markings"])
				aux_marking = Smark?.icon_state || lowertext(H.dna.features["mam_body_markings"])
			else
				body_markings = "plain"
				aux_marking = "plain"
			markings_color = list(colorlist)
		else
			body_markings = null
			aux_marking = null

		if(!dropping_limb && H.dna.check_mutation(HULK))
			mutation_color = "00aa00"
		else
			mutation_color = ""

		if(istype(S, /datum/species/synth))
			var/datum/species/synth/synthspecies = S
			var/redundantactualhealth = (100 - (owner.getBruteLoss() + owner.getFireLoss() + owner.getOxyLoss() + owner.getToxLoss() + owner.getCloneLoss()))
			if(synthspecies.isdisguised == FALSE || (synthspecies.actualhealth < 45) || (redundantactualhealth < 45))
				base_bp_icon = initial(synthspecies.icon_limbs)

		dmg_overlay_type = S.damage_overlay_type

	else if(animal_origin == MONKEY_BODYPART) //currently monkeys are the only non human mob to have damage overlays.
		dmg_overlay_type = animal_origin

	if(is_robotic_limb())
		dmg_overlay_type = "robotic"
		if(!render_like_organic)
			body_markings = null
			aux_marking = null

	if(dropping_limb)
		no_update = TRUE //when unattached, the limb won't be affected by the appearance changes of its mob owner.

/obj/item/bodypart/proc/get_limb_icon(dropped)
	cut_overlays()

	if(is_stump()) //Stumps have no icons... YET!
		return FALSE

	icon_state = "" //to erase the default sprite, we're building the visual aspects of the bodypart through overlays alone.

	. = list()

	if(custom_overlay)
		. += custom_overlay
		return

	var/image_dir = 0
	var/icon_gender = (body_gender == FEMALE) ? "f" : "m" //gender of the icon, if applicable

	if(dropped)
		image_dir = SOUTH
		if(dmg_overlay_type)
			if(brutestate)
				. += image('modular_skyrat/icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_[brutestate]0", -DAMAGE_LAYER, image_dir)
			if(burnstate)
				. += image('modular_skyrat/icons/mob/dam_mob.dmi', "[dmg_overlay_type]_[body_zone]_0[burnstate]", -DAMAGE_LAYER, image_dir)
			to_chat(owner, "[dmg_overlay_type]_[body_zone]_[brutestate]0")
			to_chat(owner, "[dmg_overlay_type]_[body_zone]_0[burnstate]")

		if(!isnull(body_markings) && is_organic_limb())
			if(!use_digitigrade)
				if((body_zone == BODY_ZONE_CHEST) || (body_zone == BODY_ZONE_PRECISE_GROIN))
					. += image(body_markings_icon, "[body_markings]_[body_zone]_[icon_gender]", -MARKING_LAYER, image_dir)
				else
					. += image(body_markings_icon, "[body_markings]_[body_zone]", -MARKING_LAYER, image_dir)
			else
				. += image(body_markings_icon, "[body_markings]_[digitigrade_type]_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir)

	var/image/limb = image(layer = -BODYPARTS_LAYER, dir = image_dir)
	var/list/aux = list()
	var/image/marking
	var/list/auxmarking = list()

	. += limb

	if(animal_origin)
		if(is_organic_limb())
			limb.icon = 'icons/mob/animal_parts.dmi'
			if(species_id == "husk")
				limb.icon_state = "[animal_origin]_husk_[body_zone]"
			else
				limb.icon_state = "[animal_origin]_[body_zone]"
		else
			limb.icon = 'icons/mob/augmentation/augments.dmi'
			limb.icon_state = "[animal_origin]_[body_zone]"
		return

	if(body_zone != BODY_ZONE_HEAD && body_zone != BODY_ZONE_CHEST && body_zone != BODY_ZONE_PRECISE_GROIN)
		should_draw_gender = FALSE

	if(is_organic_limb() || render_like_organic)
		limb.icon = base_bp_icon || DEFAULT_BODYPART_ICON
		if(is_dead())
			limb.icon = DEFAULT_BODYPART_ICON
			base_bp_icon = DEFAULT_BODYPART_ICON
			species_id = "rot"
			limb.icon_state = "[species_id]_[body_zone]"
			color_src = FALSE
		else
			if(should_draw_gender)
				limb.icon_state = "[species_id]_[body_zone]_[icon_gender]"
			else if(use_digitigrade)
				if(base_bp_icon == DEFAULT_BODYPART_ICON_ORGANIC) //Compatibility hack for the current iconset.
					limb.icon_state = "[digitigrade_type]_[use_digitigrade]_[body_zone]"
				else
					limb.icon_state = "[species_id]_[digitigrade_type]_[use_digitigrade]_[body_zone]"
			else
				limb.icon_state = "[species_id]_[body_zone]"

		// Body markings
		if(!is_dead() && !isnull(body_markings))
			if(species_id == "husk")
				marking = image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[body_zone]", -MARKING_LAYER, image_dir)
			else if(species_id == "husk" && use_digitigrade)
				marking = image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[digitigrade_type]_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir)

			else if(!use_digitigrade)
				if((body_zone == BODY_ZONE_CHEST) || (body_zone == BODY_ZONE_PRECISE_GROIN))
					marking = image(body_markings_icon, "[body_markings]_[body_zone]_[icon_gender]", -MARKING_LAYER, image_dir)
				else
					marking = image(body_markings_icon, "[body_markings]_[body_zone]", -MARKING_LAYER, image_dir)
			else
				marking = image(body_markings_icon, "[body_markings]_[digitigrade_type]_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir)

			. += marking

		if(aux_icons)
			for(var/I in aux_icons)
				var/aux_layer = aux_icons[I]
				aux += image(limb.icon, "[species_id]_[I]", -aux_layer, image_dir)
				if(!isnull(aux_marking))
					if(species_id == "husk")
						auxmarking += image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[I]", -aux_layer, image_dir)
					else
						auxmarking += image(body_markings_icon, "[body_markings]_[I]", -aux_layer, image_dir)
			. += aux
			. += auxmarking
	else
		limb.icon = icon
		if(should_draw_gender)
			limb.icon_state = "[body_zone]_[icon_gender]"
		else
			limb.icon_state = "[body_zone]"

		if(aux_icons)
			for(var/I in aux_icons)
				var/aux_layer = aux_icons[I]
				aux += image(limb.icon, "[I]", -aux_layer, image_dir)
				if(!isnull(aux_marking))
					if(species_id == "husk")
						auxmarking += image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[I]", -aux_layer, image_dir)
					else
						auxmarking += image(body_markings_icon, "[body_markings]_[I]", -aux_layer, image_dir)
			. += auxmarking
			. += aux

		if(!isnull(body_markings))
			if(species_id == "husk")
				marking = image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_[body_zone]", -MARKING_LAYER, image_dir)
			else if(species_id == "husk" && use_digitigrade)
				marking = image('modular_citadel/icons/mob/markings_notmammals.dmi', "husk_digitigrade_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir)

			else if(!use_digitigrade)
				if((body_zone == BODY_ZONE_CHEST) || (body_zone == BODY_ZONE_PRECISE_GROIN))
					marking = image(body_markings_icon, "[body_markings]_[body_zone]_[icon_gender]", -MARKING_LAYER, image_dir)
				else
					marking = image(body_markings_icon, "[body_markings]_[body_zone]", -MARKING_LAYER, image_dir)
			else
				marking = image(body_markings_icon, "[body_markings]_[digitigrade_type]_[use_digitigrade]_[body_zone]", -MARKING_LAYER, image_dir)
			. += marking

	if(color_src) //TODO - add color matrix support for base species limbs
		var/draw_color = mutation_color || species_color
		var/grayscale = FALSE
		if(!draw_color)
			draw_color = SKINTONE2HEX(skin_tone)
			grayscale = (color_src == CUSTOM_SKINTONE) //Cause human limbs have a very pale pink hue by def.
		else
			draw_color = "[draw_color]"
		if(draw_color)
			if(grayscale)
				limb.icon_state += "_g"
			limb.color = draw_color
			if(aux_icons)
				for(var/a in aux)
					var/image/I = a
					if(grayscale)
						I.icon_state += "_g"
					I.color = draw_color
				if(!isnull(aux_marking))
					for(var/a in auxmarking)
						var/image/I = a
						if(species_id == "husk")
							I.color = "#141414"
						else
							I.color = list(markings_color)

			if(!isnull(body_markings))
				if(species_id == "husk")
					marking.color = "#141414"
				else
					marking.color = list(markings_color)
	for(var/datum/wound/W in wounds)
		if(W.wound_overlay)
			. += W.wound_overlay
	return

// This code handles different species in the game.

GLOBAL_LIST_EMPTY(roundstart_races)
GLOBAL_LIST_EMPTY(roundstart_race_names)
GLOBAL_LIST_EMPTY(roundstart_race_datums)

#define BURN_WOUND_ROLL_MULT 10
#define SPECIFY_BODYPART_BURN_PROB 90

/datum/species
	var/id	// if the game needs to manually check your race to do something not included in a proc here, it will use this
	var/limbs_id		//this is used if you want to use a different species limb sprites. Mainly used for angels as they look like humans.
	var/name	// this is the fluff name. these will be left generic (such as 'Lizardperson' for the lizard race) so servers can change them to whatever
	var/default_color = "#FFFFFF"	// if alien colors are disabled, this is the color that will be used by that race

	var/sexes = TRUE // whether or not the race has sexual characteristics. at the moment this is only 0 for skeletons and shadows
	var/has_field_of_vision = TRUE

	//Species Icon Drawing Offsets - Pixel X, Pixel Y, Aka X = Horizontal and Y = Vertical, from bottom left corner
	var/list/offset_features = list( //skyrat edit
		OFFSET_UNIFORM = list(0,0),
		OFFSET_UNDERWEAR = list(0,0),
		OFFSET_SOCKS = list(0,0),
		OFFSET_SHIRT = list(0,0),
		OFFSET_ID = list(0,0),
		OFFSET_GLOVES = list(0,0),
		OFFSET_WRISTS = list(0,0),
		OFFSET_GLASSES = list(0,0),
		OFFSET_EARS = list(0,0),
		OFFSET_SHOES = list(0,0),
		OFFSET_S_STORE = list(0,0),
		OFFSET_FACEMASK = list(0,0),
		OFFSET_HEAD = list(0,0),
		OFFSET_EYES = list(0,0),
		OFFSET_LIPS = list(0,0),
		OFFSET_BELT = list(0,0),
		OFFSET_BACK = list(0,0),
		OFFSET_HAIR = list(0,0),
		OFFSET_FHAIR = list(0,0),
		OFFSET_SUIT = list(0,0),
		OFFSET_NECK = list(0,0),
		OFFSET_MUTPARTS = list(0,0)
		)

	var/hair_color	// this allows races to have specific hair colors... if null, it uses the H's hair/facial hair colors. if "mutcolor", it uses the H's mutant_color
	var/hair_alpha = 255	// the alpha used by the hair. 255 is completely solid, 0 is transparent.
	var/use_skintones = NO_SKINTONES	// does it use skintones or not? (spoiler alert this is only used by humans)
	var/exotic_blood = ""	// If your race wants to bleed something other than bog standard blood, change this to reagent id.
	var/exotic_bloodtype = "" //If your race uses a non standard bloodtype (A+, O-, AB-, etc)
	var/exotic_blood_color = BLOOD_COLOR_HUMAN //assume human as the default blood colour, override this default by species subtypes
	var/meat = /obj/item/reagent_containers/food/snacks/meat/slab/human //What the species drops on gibbing
	var/list/gib_types = list(/obj/effect/gibspawner/human, /obj/effect/gibspawner/human/bodypartless)
	var/skinned_type
	var/liked_food = NONE
	var/disliked_food = GROSS
	var/toxic_food = TOXIC
	var/list/no_equip = list()	// slots the race can't equip stuff to
	var/nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids
	var/blacklisted = 0 //Flag to exclude from green slime core species.
	var/dangerous_existence //A flag for transformation spells that tells them "hey if you turn a person into one of these without preperation, they'll probably die!"
	var/say_mod = "says"	// affects the speech message
	var/species_language_holder = /datum/language_holder
	var/list/mutant_bodyparts = list() 	// Visible CURRENT bodyparts that are unique to a species. Changes to this list for non-species specific bodyparts (ie cat ears and tails) should be assigned at organ level if possible. Layer hiding is handled by handle_mutant_bodyparts() below.
	var/list/mutant_organs = list()		//Internal organs that are unique to this race.
	var/speedmod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	var/armor = 0		// overall defense for the race... or less defense, if it's negative.
	var/brutemod = 1	// multiplier for brute damage
	var/burnmod = 1		// multiplier for burn damage
	var/painmod = 1		// multiplier for pain damage
	var/coldmod = 1		// multiplier for cold damage
	var/heatmod = 1		// multiplier for heat damage
	var/stunmod = 1		// multiplier for stun duration
	var/punchdamagelow = 1       //lowest possible punch damage. if this is set to 0, punches will always miss
	var/punchdamagehigh = 10      //highest possible punch damage
	var/punchstunthreshold = 10//damage at which punches from this race will stun //yes it should be to the attacked race but it's not useful that way even if it's logical
	var/siemens_coeff = 1 //base electrocution coefficient
	var/damage_overlay_type = "human" //what kind of damage overlays (if any) appear on our species when wounded?
	var/fixed_mut_color = "" //to use MUTCOLOR with a fixed color that's independent of dna.feature["mcolor"]
	var/inert_mutation = DWARFISM
	var/list/special_step_sounds //Sounds to override barefeet walkng
	var/grab_sound //Special sound for grabbing
	var/datum/outfit/outfit_important_for_life // A path to an outfit that is important for species life e.g. plasmaman outfit

	// species-only traits. Can be found in DNA.dm
	var/list/species_traits = list()
	// generic traits tied to having the species
	var/list/inherent_traits = list()
	var/inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID

	var/attack_verb = "punch"	// punch-specific attack verb
	var/attack_verb_continuous = "punches"
	var/static/list/sound/attack_sound = list('modular_skyrat/sound/gore/melee1.ogg', \
											'modular_skyrat/sound/gore/melee2.ogg', \
											'modular_skyrat/sound/gore/melee3.ogg', \
											)
	var/static/list/sound/miss_sound = list('modular_skyrat/sound/gore/punchmiss.ogg')

	var/list/mob/living/ignored_by = list()	// list of mobs that will ignore this species

	//Breathing!
	var/breathid = "o2"

	var/obj/item/organ/brain/mutantbrain = /obj/item/organ/brain
	var/obj/item/organ/heart/mutantheart = /obj/item/organ/heart
	var/obj/item/organ/lungs/mutantlungs = /obj/item/organ/lungs
	var/obj/item/organ/ears/mutantears = /obj/item/organ/ears
	var/obj/item/organ/liver/mutantliver = /obj/item/organ/liver
	var/obj/item/organ/kidneys/mutantkidneys = /obj/item/organ/kidneys
	var/obj/item/organ/stomach/mutantstomach = /obj/item/organ/stomach
	var/obj/item/organ/intestines/mutantintestines = /obj/item/organ/intestines
	var/obj/item/organ/spleen/mutantspleen = /obj/item/organ/spleen
	var/obj/item/organ/bladder/mutantbladder = /obj/item/organ/bladder
	var/obj/item/organ/tongue/mutanttongue = /obj/item/organ/tongue
	var/obj/item/organ/innards/mutant_mystery_organ
	var/obj/item/organ/tail/mutanttail

	var/obj/item/mutanthands

	var/override_float = FALSE

	//Citadel snowflake
	var/fixed_mut_color2 = ""
	var/fixed_mut_color3 = ""
	var/whitelisted = 0 		//Is this species restricted to certain players?
	var/whitelist = list() 		//List the ckeys that can use this species, if it's whitelisted.: list("John Doe", "poopface666", "SeeALiggerPullTheTrigger") Spaces & capitalization can be included or ignored entirely for each key as it checks for both.
	var/icon_limbs //Overrides the icon used for the limbs of this species. Mainly for downstream, and also because hardcoded icons disgust me. Implemented and maintained as a favor in return for a downstream's implementation of synths.
	/// Our default override for typing indicator state
	var/typing_indicator_state
	/// Pain messages
	var/painloss_message = "slumps over, too weak to continue fighting..."
	var/painloss_message_self = "The pain is too severe for me to keep going..."

///////////
// PROCS //
///////////

/datum/species/New()
	//if we havent set a limbs id to use, just use our own id
	if(!limbs_id)
		limbs_id = id

	//Set our descriptors proper
	if(LAZYLEN(descriptors))
		var/list/descriptor_datums = list()
		for(var/desctype in descriptors)
			var/datum/mob_descriptor/descriptor = new desctype
			descriptor.current_value = descriptors[desctype]
			if(descriptor.current_value == "default")
				descriptor.current_value = descriptor.default_value
			descriptor_datums[descriptor.name] = descriptor
		descriptors = descriptor_datums

	. = ..()


/proc/generate_selectable_species(clear = FALSE)
	if(clear)
		GLOB.roundstart_races = list()
		GLOB.roundstart_race_names = list()
	for(var/I in subtypesof(/datum/species))
		var/datum/species/S = new I
		if(S.check_roundstart_eligible())
			GLOB.roundstart_races |= S.id
			GLOB.roundstart_race_names["[S.name]"] = S.id
			//skyrat edit
			GLOB.roundstart_race_datums["[S.id]"] = S
			//
	if(!GLOB.roundstart_races.len)
		GLOB.roundstart_races += "human"

/datum/species/proc/check_roundstart_eligible()
	if(id in (CONFIG_GET(keyed_list/roundstart_races)))
		return TRUE
	return FALSE

/datum/species/proc/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_name(gender)

	var/randname
	if(gender == MALE)
		randname = pick(GLOB.first_names_male)
	else
		randname = pick(GLOB.first_names_female)

	if(lastname)
		randname += " [lastname]"
	else
		randname += " [pick(GLOB.last_names)]"

	return randname

//Called when cloning, copies some vars that should be kept
/datum/species/proc/copy_properties_from(datum/species/old_species)
	return

//Please override this locally if you want to define when what species qualifies for what rank if human authority is enforced.
/datum/species/proc/qualifies_for_rank(rank, list/features) //SPECIES JOB RESTRICTIONS
	//if(rank in GLOB.command_positions) Left as an example: The format qualifies for rank takes.
	//	return 0 //It returns false when it runs the proc so they don't get jobs from the global list.
	return 1 //It returns 1 to say they are a-okay to continue.

//Will regenerate missing organs
/datum/species/proc/regenerate_organs(mob/living/carbon/C,datum/species/old_species,replace_current=TRUE)
	var/obj/item/organ/brain/brain = C.getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/heart/heart = C.getorganslot(ORGAN_SLOT_HEART)
	var/obj/item/organ/lungs/lungs = C.getorganslot(ORGAN_SLOT_LUNGS)
	var/obj/item/organ/appendix/appendix = C.getorganslot(ORGAN_SLOT_APPENDIX)
	var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
	var/obj/item/organ/tongue/tongue = C.getorganslot(ORGAN_SLOT_TONGUE)
	var/obj/item/organ/liver/liver = C.getorganslot(ORGAN_SLOT_LIVER)
	var/obj/item/organ/kidneys/kidneys = C.getorganslot(ORGAN_SLOT_KIDNEYS)
	var/obj/item/organ/stomach/stomach = C.getorganslot(ORGAN_SLOT_STOMACH)
	var/obj/item/organ/intestines/intestines = C.getorganslot(ORGAN_SLOT_INTESTINES)
	var/obj/item/organ/spleen/spleen = C.getorganslot(ORGAN_SLOT_SPLEEN)
	var/obj/item/organ/bladder/bladder = C.getorganslot(ORGAN_SLOT_BLADDER)
	var/obj/item/organ/innards/mystery_organ = C.getorganslot(ORGAN_SLOT_INNARDS)
	var/obj/item/organ/tail/tail = C.getorganslot(ORGAN_SLOT_TAIL)

	var/should_have_brain = TRUE
	var/should_have_heart = !(NOBLOOD in species_traits)
	var/should_have_lungs = !(TRAIT_NOBREATH in inherent_traits)
	var/should_have_ears = TRUE
	var/should_have_tongue = TRUE
	var/should_have_liver = !(NOLIVER in species_traits)
	var/should_have_appendix = !(NOAPPENDIX in species_traits)
	var/should_have_kidneys = !(NOKIDNEYS in species_traits)
	var/should_have_stomach = !(NOSTOMACH in species_traits)
	var/should_have_spleen = !(NOSPLEEN in species_traits)
	var/should_have_intestines = !(NOINTESTINES in species_traits)
	var/should_have_bladder = !(NOBLADDER in species_traits)
	var/should_have_mystery_organ = !(NOAPPENDIX in species_traits) //Mystery organ is like a second appendix anyways
	var/should_have_tail = mutanttail ? TRUE : FALSE

	if(brain && (replace_current || !should_have_brain))
		if(!brain.decoy_override)//Just keep it if it's fake
			brain.Remove(TRUE,TRUE)
			QDEL_NULL(brain)
	if(should_have_brain && !brain)
		brain = new mutantbrain()
		brain.Insert(C, TRUE, TRUE)

	if(heart && (!should_have_heart || replace_current))
		heart.Remove(TRUE)
		QDEL_NULL(heart)
	if(should_have_heart && !heart)
		heart = new mutantheart()
		heart.Insert(C)

	if(lungs && (!should_have_lungs || replace_current))
		lungs.Remove(TRUE)
		QDEL_NULL(lungs)
	if(should_have_lungs && !lungs)
		if(mutantlungs)
			lungs = new mutantlungs()
		else
			lungs = new()
		lungs.Insert(C)

	if(liver && (!should_have_liver || replace_current))
		liver.Remove(TRUE)
		QDEL_NULL(liver)
	if(should_have_liver && !liver)
		if(mutantliver)
			liver = new mutantliver()
		else
			liver = new()
		liver.Insert(C)

	if(kidneys && (!should_have_kidneys || replace_current))
		kidneys.Remove(TRUE)
		QDEL_NULL(kidneys)
	if(should_have_kidneys && !kidneys)
		if(mutantkidneys)
			kidneys = new mutantkidneys()
		else
			kidneys = new()
		kidneys.Insert(C)

	if(stomach && (!should_have_stomach || replace_current))
		stomach.Remove(TRUE)
		QDEL_NULL(stomach)
	if(should_have_stomach && !stomach)
		if(mutantstomach)
			stomach = new mutantstomach()
		else
			stomach = new()
		stomach.Insert(C)

	if(spleen && (!should_have_spleen || replace_current))
		spleen.Remove(TRUE)
		QDEL_NULL(spleen)
	if(should_have_spleen && !spleen)
		if(mutantspleen)
			spleen = new mutantspleen()
		else
			spleen = new()
		spleen.Insert(C)

	if(intestines && (!should_have_intestines || replace_current))
		intestines.Remove(TRUE)
		QDEL_NULL(intestines)
	if(should_have_intestines && !intestines)
		if(mutantintestines)
			intestines = new mutantintestines()
		else
			intestines = new()
		intestines.Insert(C)

	if(appendix && (!should_have_appendix || replace_current))
		appendix.Remove(TRUE)
		QDEL_NULL(appendix)
	if(should_have_appendix && !appendix)
		appendix = new()
		appendix.Insert(C)

	if(bladder && (!should_have_bladder || replace_current))
		bladder.Remove(TRUE)
		QDEL_NULL(bladder)
	if(should_have_bladder && !bladder)
		if(mutantbladder)
			bladder = new mutantbladder()
		else
			bladder = new()
		bladder.Insert(C)

	if(mystery_organ && (!should_have_mystery_organ || replace_current))
		mystery_organ.Remove(TRUE)
		QDEL_NULL(appendix)
	if(should_have_mystery_organ && prob(2) && !mystery_organ)
		mystery_organ = new()
		mystery_organ.Insert(C)

	if(tail && (!should_have_tail || replace_current))
		tail.Remove(TRUE)
		QDEL_NULL(tail)
	if(should_have_tail && !tail)
		tail = new mutanttail()
		tail.Insert(C)

	var/obj/item/bodypart/shoe_on_head = C.get_bodypart_nostump(BODY_ZONE_HEAD)
	if(shoe_on_head)
		if(ears && (replace_current || !should_have_ears))
			ears.Remove(TRUE)
			QDEL_NULL(ears)
		if(should_have_ears && !ears)
			ears = new mutantears
			ears.Insert(C)

		if(tongue && (replace_current || !should_have_tongue))
			tongue.Remove(TRUE)
			QDEL_NULL(tongue)
		if(should_have_tongue && !tongue)
			tongue = new mutanttongue
			tongue.Insert(C)

	if(old_species)
		for(var/mutantorgan in old_species.mutant_organs)
			var/obj/item/organ/I = C.getorgan(mutantorgan)
			if(I)
				I.Remove()
				QDEL_NULL(I)

	for(var/path in mutant_organs)
		var/obj/item/organ/I = new path()
		I.Insert(C)

/datum/species/proc/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	// Drop the items the new species can't wear
	for(var/slot_id in no_equip)
		var/obj/item/thing = C.get_item_by_slot(slot_id)
		if(thing && (!thing.species_exception || !is_type_in_list(src,thing.species_exception)))
			C.dropItemToGround(thing)
	if(C.hud_used)
		C.hud_used.update_locked_slots()

	C.mob_biotypes = inherent_biotypes

	regenerate_organs(C,old_species)

	if(exotic_bloodtype && C.dna.blood_type != exotic_bloodtype)
		C.dna.blood_type = exotic_bloodtype

	if(C.client)
		var/client/cli = C.client
		if(rainbowblood && cli.prefs.bloodcolor)
			C.dna.blood_color = cli.prefs.bloodcolor

	if(old_species.mutanthands)
		for(var/obj/item/I in C.held_items)
			if(istype(I, old_species.mutanthands))
				qdel(I)

	if(mutanthands)
		// Drop items in hands
		// If you're lucky enough to have a TRAIT_NODROP item, then it stays.
		for(var/V in C.held_items)
			var/obj/item/I = V
			if(istype(I))
				C.dropItemToGround(I)
			else	//Entries in the list should only ever be items or null, so if it's not an item, we can assume it's an empty hand
				C.put_in_hands(new mutanthands())

	for(var/X in inherent_traits)
		ADD_TRAIT(C, X, SPECIES_TRAIT)

	if(TRAIT_VIRUSIMMUNE in inherent_traits)
		for(var/datum/disease/A in C.diseases)
			A.cure(FALSE)

	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(NOGENITALS in H.dna.species.species_traits)
			H.give_genitals(TRUE) //call the clean up proc to delete anything on the mob then return.
		if(mutant_bodyparts["meat_type"]) //I can't believe it's come to the meat
			H.type_of_meat = GLOB.meat_types[H.dna.features["meat_type"]]

		if(H.physiology)
			if(mutant_bodyparts["taur"])
				var/datum/sprite_accessory/taur/T = GLOB.taur_list[H.dna.features["taur"]]
				switch(T?.taur_mode)
					if(STYLE_HOOF_TAURIC)
						H.physiology.footstep_type = FOOTSTEP_MOB_SHOE
					if(STYLE_PAW_TAURIC)
						H.physiology.footstep_type = FOOTSTEP_MOB_CLAW
					if(STYLE_SNEK_TAURIC)
						H.physiology.footstep_type = FOOTSTEP_MOB_CRAWL
					else
						H.physiology.footstep_type = null
			else
				H.physiology.footstep_type = null

		if(H.client && has_field_of_vision && CONFIG_GET(flag/use_field_of_vision))
			H.LoadComponent(/datum/component/field_of_vision, H.field_of_vision_type)

	C.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/species, TRUE, multiplicative_slowdown = speedmod)

	SEND_SIGNAL(C, COMSIG_SPECIES_GAIN, src, old_species)

/datum/species/proc/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	if(C.dna.species.exotic_bloodtype)
		if(!new_species.exotic_bloodtype)
			C.dna.blood_type = random_blood_type()
		else
			C.dna.blood_type = new_species.exotic_bloodtype
	for(var/X in inherent_traits)
		REMOVE_TRAIT(C, X, SPECIES_TRAIT)

	C.remove_movespeed_modifier(/datum/movespeed_modifier/species)

	if(mutant_bodyparts["meat_type"])
		C.type_of_meat = GLOB.meat_types[C.dna.features["meat_type"]]
	else
		C.type_of_meat = initial(meat)

	//If their inert mutation is not the same, swap it out
	if((inert_mutation != new_species.inert_mutation) && LAZYLEN(C.dna.mutation_index) && (inert_mutation in C.dna.mutation_index))
		C.dna.remove_mutation(inert_mutation)
		//keep it at the right spot, so we can't have people taking shortcuts
		var/location = C.dna.mutation_index.Find(inert_mutation)
		C.dna.mutation_index[location] = new_species.inert_mutation
		C.dna.mutation_index[new_species.inert_mutation] = create_sequence(new_species.inert_mutation)

	if(!new_species.has_field_of_vision && has_field_of_vision && ishuman(C) && CONFIG_GET(flag/use_field_of_vision))
		var/datum/component/field_of_vision/F = C.GetComponent(/datum/component/field_of_vision)
		if(F)
			qdel(F)

	SEND_SIGNAL(C, COMSIG_SPECIES_LOSS, src)

/datum/species/proc/handle_hair(mob/living/carbon/human/H, forced_colour)
	H.remove_overlay(HAIR_LAYER)
	var/obj/item/bodypart/head/HD = H.get_bodypart_nostump(BODY_ZONE_HEAD)
	if(!HD) //Decapitated
		return
	if(HAS_TRAIT(H, TRAIT_HUSK))
		return

	var/datum/sprite_accessory/S
	var/list/standing = list()

	var/hair_hidden = FALSE //ignored if the matching dynamic_X_suffix is non-empty
	var/facialhair_hidden = FALSE // ^

	var/dynamic_hair_suffix = "" //if this is non-null, and hair+suffix matches an iconstate, then we render that hair instead
	var/dynamic_fhair_suffix = ""

	//for augmented heads
	if(HD.is_robotic_limb() && !HD.render_like_organic) //Skyrat change, robo limbs that render like organic
		return

	//we check if our hat or helmet hides our facial hair.
	if(H.head)
		var/obj/item/I = H.head
		if(istype(I, /obj/item/clothing))
			var/obj/item/clothing/C = I
			dynamic_fhair_suffix = C.dynamic_fhair_suffix
		if(I.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.wear_mask && istype(H.wear_mask))
		var/obj/item/clothing/mask/M = H.wear_mask
		dynamic_fhair_suffix = M.dynamic_fhair_suffix //mask > head in terms of facial hair
		if(M.flags_inv & HIDEFACIALHAIR)
			facialhair_hidden = TRUE

	if(H.facial_hair_style && (FACEHAIR in species_traits) && (!facialhair_hidden || dynamic_fhair_suffix))
		S = GLOB.facial_hair_styles_list[H.facial_hair_style]
		if(S)
			//List of all valid dynamic_fhair_suffixes
			var/static/list/fextensions
			if(!fextensions)
				var/icon/fhair_extensions = icon('icons/mob/facialhair_extensions.dmi')
				fextensions = list()
				for(var/s in fhair_extensions.IconStates(1))
					fextensions[s] = TRUE
				qdel(fhair_extensions)

			//Is hair+dynamic_fhair_suffix a valid iconstate?
			var/fhair_state = S.icon_state
			var/fhair_file = S.icon
			if(fextensions[fhair_state+dynamic_fhair_suffix])
				fhair_state += dynamic_fhair_suffix
				fhair_file = 'icons/mob/facialhair_extensions.dmi'

			var/mutable_appearance/facial_overlay = mutable_appearance(fhair_file, fhair_state, -HAIR_LAYER)

			if(!forced_colour)
				if(hair_color)
					if(hair_color == "mutcolor")
						facial_overlay.color = sanitize_hexcolor(H.dna.features["mcolor"])
					else
						facial_overlay.color = sanitize_hexcolor(hair_color)
				else
					facial_overlay.color = sanitize_hexcolor(H.facial_hair_color)
			else
				facial_overlay.color = forced_colour

			facial_overlay.alpha = hair_alpha

			if(OFFSET_FHAIR in H.dna.species.offset_features)
				facial_overlay.pixel_x += H.dna.species.offset_features[OFFSET_FHAIR][1]
				facial_overlay.pixel_y += H.dna.species.offset_features[OFFSET_FHAIR][2]

			standing += facial_overlay

	if(H.head)
		var/obj/item/I = H.head
		if(istype(I, /obj/item/clothing))
			var/obj/item/clothing/C = I
			dynamic_hair_suffix = C.dynamic_hair_suffix
		if(I.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(H.wear_mask && istype(H.wear_mask))
		var/obj/item/clothing/mask/M = H.wear_mask
		if(!dynamic_hair_suffix) //head > mask in terms of head hair
			dynamic_hair_suffix = M.dynamic_hair_suffix
		if(M.flags_inv & HIDEHAIR)
			hair_hidden = TRUE

	if(!hair_hidden || dynamic_hair_suffix)
		var/mutable_appearance/hair_overlay = mutable_appearance(layer = -HAIR_LAYER)
		if(H.hair_style && (HAIR in species_traits))
			S = GLOB.hair_styles_list[H.hair_style]
			if(S)
				//List of all valid dynamic_hair_suffixes
				var/static/list/extensions
				if(!extensions)
					var/icon/hair_extensions = icon('icons/mob/hair_extensions.dmi') //hehe
					extensions = list()
					for(var/s in hair_extensions.IconStates(1))
						extensions[s] = TRUE
					qdel(hair_extensions)

				//Is hair+dynamic_hair_suffix a valid iconstate?
				var/hair_state = S.icon_state
				var/hair_file = S.icon
				if(extensions[hair_state+dynamic_hair_suffix])
					hair_state += dynamic_hair_suffix
					hair_file = 'icons/mob/hair_extensions.dmi'

				hair_overlay.icon = hair_file
				hair_overlay.icon_state = hair_state

				if(!forced_colour)
					if(hair_color)
						if(hair_color == "mutcolor")
							hair_overlay.color = sanitize_hexcolor(H.dna.features["mcolor"])
						else
							hair_overlay.color = sanitize_hexcolor(hair_color)
					else
						hair_overlay.color = sanitize_hexcolor(H.hair_color)
				else
					hair_overlay.color = forced_colour
				hair_overlay.alpha = hair_alpha

				if(OFFSET_HAIR in H.dna.species.offset_features)
					hair_overlay.pixel_x += H.dna.species.offset_features[OFFSET_HAIR][1]
					hair_overlay.pixel_y += H.dna.species.offset_features[OFFSET_HAIR][2]

		if(hair_overlay.icon)
			standing += hair_overlay

	if(standing.len)
		H.overlays_standing[HAIR_LAYER] = standing

	H.apply_overlay(HAIR_LAYER)

/datum/species/proc/handle_body(mob/living/carbon/human/H)
	H.remove_overlay(BODY_LAYER)

	var/list/standing = list()

	var/obj/item/bodypart/head/HD = H.get_bodypart_nostump(BODY_ZONE_HEAD)

	if(HD && !(HAS_TRAIT(H, TRAIT_HUSK)))
		// Lipstick
		if(H.lip_style && (LIPS in species_traits))
			var/mutable_appearance/lip_overlay = mutable_appearance('icons/mob/human_face.dmi', "lips-[H.lip_style]", -BODY_LAYER)
			lip_overlay.color = H.lip_color

			if(OFFSET_LIPS in H.dna.species.offset_features)
				lip_overlay.pixel_x += H.dna.species.offset_features[OFFSET_LIPS][1]
				lip_overlay.pixel_y += H.dna.species.offset_features[OFFSET_LIPS][2]

			standing += lip_overlay

		// Eyes
		if(!(NOEYES in species_traits))
			var/obj/item/bodypart/left_eye/LE = H.get_bodypart_nostump(BODY_ZONE_PRECISE_LEFT_EYE)
			var/obj/item/bodypart/right_eye/RE = H.get_bodypart_nostump(BODY_ZONE_PRECISE_RIGHT_EYE)
			var/mutable_appearance/left_eye_overlay
			var/mutable_appearance/right_eye_overlay

			//variables for eye colors, since i want to make sleepy niggas have eyelids instead of showing the eyes
			//(they are sleepy silly they cant eye)
			var/left_eye_color = ((EYECOLOR in species_traits) ? sanitize_hexcolor(H.left_eye_color) : "#000000")
			var/right_eye_color = ((EYECOLOR in species_traits) ? sanitize_hexcolor(H.right_eye_color) : "#000000")

			//sleepy mode activate
			if((H.stat > CONSCIOUS) && ishuman(H))
				var/neweyecolor = sanitize_hexcolor(SKINTONE2HEX(H.skin_tone))
				if(H.dna.skin_tone_override)
					neweyecolor = sanitize_hexcolor(SKINTONE2HEX(H.dna.skin_tone_override))
				else
					neweyecolor = sanitize_hexcolor(SKINTONE2HEX(H.dna.features["mcolor"]))
				left_eye_color = neweyecolor
				right_eye_color = neweyecolor

			if(LE)
				left_eye_overlay = mutable_appearance(icon_eyes, "eye-left", -BODY_LAYER, color = left_eye_color)
			else
				left_eye_overlay = mutable_appearance(icon_eyes, "eye-left-missing", -BODY_LAYER)

			if(RE)
				right_eye_overlay = mutable_appearance(icon_eyes, "eye-right", -BODY_LAYER, color = right_eye_color)
			else
				right_eye_overlay = mutable_appearance(icon_eyes, "eye-right-missing", -BODY_LAYER)

			if(OFFSET_EYES in H.dna.species.offset_features)
				left_eye_overlay.pixel_x += H.dna.species.offset_features[OFFSET_EYES][1]
				left_eye_overlay.pixel_y += H.dna.species.offset_features[OFFSET_EYES][2]
				right_eye_overlay.pixel_x += H.dna.species.offset_features[OFFSET_EYES][1]
				right_eye_overlay.pixel_y += H.dna.species.offset_features[OFFSET_EYES][2]

			standing += left_eye_overlay
			standing += right_eye_overlay

		if(!(NOJAW in species_traits))
			var/obj/item/bodypart/mouth/jaw = H.get_bodypart_nostump(BODY_ZONE_PRECISE_MOUTH)
			if(!jaw)
				standing += mutable_appearance(icon_eyes, "lips-missing", -BODY_LAYER)

	if(standing.len)
		H.overlays_standing[BODY_LAYER] = standing

	H.apply_overlay(BODY_LAYER)
	handle_mutant_bodyparts(H)

/datum/species/proc/handle_mutant_bodyparts(mob/living/carbon/human/H, forced_colour)
	var/list/bodyparts_to_add = mutant_bodyparts.Copy()

	H.remove_overlay(BODY_BEHIND_LAYER)
	H.remove_overlay(BODY_ADJ_LAYER)
	H.remove_overlay(BODY_ADJ_UPPER_LAYER)
	H.remove_overlay(BODY_FRONT_LAYER)
	H.remove_overlay(HORNS_LAYER)

	if(!mutant_bodyparts)
		return

	var/obj/item/bodypart/head/HD = H.get_bodypart_nostump(BODY_ZONE_HEAD)
	var/tauric = mutant_bodyparts["taur"] && H.dna.features["taur"] && H.dna.features["taur"] != "None"

	if(mutant_bodyparts["tail_lizard"])
		if((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric)
			bodyparts_to_add -= "tail_lizard"

	if(mutant_bodyparts["waggingtail_lizard"])
		if((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric)
			bodyparts_to_add -= "waggingtail_lizard"
		else if (mutant_bodyparts["tail_lizard"])
			bodyparts_to_add -= "waggingtail_lizard"

	if(mutant_bodyparts["tail_human"])
		if((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric)
			bodyparts_to_add -= "tail_human"

	if(mutant_bodyparts["waggingtail_human"])
		if((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric)
			bodyparts_to_add -= "waggingtail_human"
		else if (mutant_bodyparts["tail_human"])
			bodyparts_to_add -= "waggingtail_human"

	if(mutant_bodyparts["spines"])
		if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR))
			bodyparts_to_add -= "spines"

	if(mutant_bodyparts["waggingspines"])
		if(!H.dna.features["spines"] || H.dna.features["spines"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR))
			bodyparts_to_add -= "waggingspines"
		else if (mutant_bodyparts["tail"])
			bodyparts_to_add -= "waggingspines"

	if(mutant_bodyparts["snout"]) //Take a closer look at that snout!
		if((H.wear_mask && (H.wear_mask.flags_inv & HIDESNOUT)) || (H.head && (H.head.flags_inv & HIDESNOUT)) || !istype(HD) || (HD.is_robotic_limb() && !HD.render_like_organic)) //Skyrat change, robo limbs that render like organic
			bodyparts_to_add -= "snout"

	if(mutant_bodyparts["frills"])
		if(!H.dna.features["frills"] || H.dna.features["frills"] == "None" || !istype(HD) || (HD.is_robotic_limb() && !HD.render_like_organic)) //skyrat change
			bodyparts_to_add -= "frills"

	if(mutant_bodyparts["horns"])
		if(!H.dna.features["horns"] || H.dna.features["horns"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || !istype(HD) || (HD.is_robotic_limb() && !HD.render_like_organic)) //skyrat change
			bodyparts_to_add -= "horns"

	if(mutant_bodyparts["ears"])
		if(!H.dna.features["ears"] || H.dna.features["ears"] == "None" || H.head && (H.head.flags_inv & HIDEEARS) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEEARS)) || !istype(HD) || (HD.is_robotic_limb() && !HD.render_like_organic)) //skyrat change
			bodyparts_to_add -= "ears"

	if(mutant_bodyparts["wings"])
		if(!H.dna.features["wings"] || H.dna.features["wings"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception))))
			bodyparts_to_add -= "wings"

	if(mutant_bodyparts["wings_open"])
		if(H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT) && (!H.wear_suit.species_exception || !is_type_in_list(src, H.wear_suit.species_exception)))
			bodyparts_to_add -= "wings_open"
		else if (mutant_bodyparts["wings"])
			bodyparts_to_add -= "wings_open"

	if(mutant_bodyparts["insect_fluff"])
		if(!H.dna.features["insect_fluff"] || H.dna.features["insect_fluff"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "insect_fluff"

	//CITADEL EDIT
	//Race specific bodyparts:
	//Synthetics
	if(mutant_bodyparts["ipc_screen"])
		if(!H.dna.features["ipc_screen"] || H.dna.features["ipc_screen"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || !istype(HD) || !(HD.is_robotic_limb() && !HD.render_like_organic))
			bodyparts_to_add -= "ipc_screen"
	//Xenos
	if(mutant_bodyparts["xenodorsal"])
		if(!H.dna.features["xenodorsal"] || H.dna.features["xenodorsal"] == "None" || (H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT)))
			bodyparts_to_add -= "xenodorsal"
	if(mutant_bodyparts["xenohead"])//This is an overlay for different castes using different head crests
		if(!H.dna.features["xenohead"] || H.dna.features["xenohead"] == "None" || H.head && (H.head.flags_inv & HIDEHAIR) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEHAIR)) || !istype(HD) || (HD.is_robotic_limb() && !HD.render_like_organic)) //skyrat change
			bodyparts_to_add -= "xenohead"
	if(mutant_bodyparts["xenotail"])
		if(!H.dna.features["xenotail"] || H.dna.features["xenotail"] == "None" || H.wear_suit && (H.wear_suit.flags_inv & HIDEJUMPSUIT))
			bodyparts_to_add -= "xenotail"

	//Other Races
	if(mutant_bodyparts["mam_tail"])
		if((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric)
			bodyparts_to_add -= "mam_tail"

	if(mutant_bodyparts["mam_waggingtail"])
		if((H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)) || tauric)
			bodyparts_to_add -= "mam_waggingtail"
		else if (mutant_bodyparts["mam_tail"])
			bodyparts_to_add -= "mam_waggingtail"

	if(mutant_bodyparts["mam_ears"])
		if(!H.dna.features["mam_ears"] || H.dna.features["mam_ears"] == "None" || H.head && (H.head.flags_inv & HIDEEARS) || (H.wear_mask && (H.wear_mask.flags_inv & HIDEEARS)) || !istype(HD) || (HD.is_robotic_limb() && !HD.render_like_organic)) //skyrat change
			bodyparts_to_add -= "mam_ears"

	if(mutant_bodyparts["mam_snouts"]) //Take a closer look at that snout!
		if((H.wear_mask && (H.wear_mask.flags_inv & HIDESNOUT)) || (H.head && (H.head.flags_inv & HIDESNOUT)) || !istype(HD) || (HD.is_robotic_limb() && !HD.render_like_organic)) //Skyrat change, robo limbs that render like organic
			bodyparts_to_add -= "mam_snouts"

	if(mutant_bodyparts["taur"])
		if(!tauric || (H.wear_suit && (H.wear_suit.flags_inv & HIDETAUR)))
			bodyparts_to_add -= "taur"

	//END EDIT

	//Digitigrade legs are stuck in the phantom zone between true limbs and mutant bodyparts. Mainly it just needs more agressive updating than most limbs.
	var/update_needed = FALSE
	var/not_digitigrade = TRUE
	if(update_needed)
		H.update_body_parts()
	if(not_digitigrade && (DIGITIGRADE in species_traits)) //Curse is lifted
		species_traits -= DIGITIGRADE

	if(!bodyparts_to_add)
		return

	var/list/relevant_layers = list()
	var/list/dna_feature_as_text_string = list()

	for(var/bodypart in bodyparts_to_add)
		var/datum/sprite_accessory/S
		switch(bodypart)
			if("tail_lizard")
				S = GLOB.tails_list_lizard[H.dna.features["tail_lizard"]]
			if("waggingtail_lizard")
				S = GLOB.animated_tails_list_lizard[H.dna.features["tail_lizard"]]
			if("tail_human")
				S = GLOB.tails_list_human[H.dna.features["tail_human"]]
			if("waggingtail_human")
				S = GLOB.animated_tails_list_human[H.dna.features["tail_human"]]
			if("spines")
				S = GLOB.spines_list[H.dna.features["spines"]]
			if("waggingspines")
				S = GLOB.animated_spines_list[H.dna.features["spines"]]
			if("snout")
				S = GLOB.snouts_list[H.dna.features["snout"]]
			if("frills")
				S = GLOB.frills_list[H.dna.features["frills"]]
			if("horns")
				S = GLOB.horns_list[H.dna.features["horns"]]
			if("ears")
				S = GLOB.ears_list[H.dna.features["ears"]]
			if("body_markings")
				S = GLOB.body_markings_list[H.dna.features["body_markings"]]
			if("wings")
				S = GLOB.wings_list[H.dna.features["wings"]]
			if("wingsopen")
				S = GLOB.wings_open_list[H.dna.features["wings"]]
			if("deco_wings")
				S = GLOB.deco_wings_list[H.dna.features["deco_wings"]]
			if("legs")
				S = GLOB.legs_list[H.dna.features["legs"]]
			if("insect_wings")
				S = GLOB.insect_wings_list[H.dna.features["insect_wings"]]
			if("insect_fluff")
				S = GLOB.insect_fluffs_list[H.dna.features["insect_fluff"]]
			if("insect_markings")
				S = GLOB.insect_markings_list[H.dna.features["insect_markings"]]
			if("caps")
				S = GLOB.caps_list[H.dna.features["caps"]]
			if("ipc_screen")
				S = GLOB.ipc_screens_list[H.dna.features["ipc_screen"]]
			if("ipc_antenna")
				S = GLOB.ipc_antennas_list[H.dna.features["ipc_antenna"]]
			if("mam_tail")
				S = GLOB.mam_tails_list[H.dna.features["mam_tail"]]
			if("mam_waggingtail")
				S = GLOB.mam_tails_animated_list[H.dna.features["mam_tail"]]
			if("mam_body_markings")
				S = GLOB.mam_body_markings_list[H.dna.features["mam_body_markings"]]
			if("mam_ears")
				S = GLOB.mam_ears_list[H.dna.features["mam_ears"]]
			if("mam_snouts")
				S = GLOB.mam_snouts_list[H.dna.features["mam_snouts"]]
			if("taur")
				S = GLOB.taur_list[H.dna.features["taur"]]
			if("xenodorsal")
				S = GLOB.xeno_dorsal_list[H.dna.features["xenodorsal"]]
			if("xenohead")
				S = GLOB.xeno_head_list[H.dna.features["xenohead"]]
			if("xenotail")
				S = GLOB.xeno_tail_list[H.dna.features["xenotail"]]

		if(!S || S.icon_state == "none")
			continue

		for(var/L in S.relevant_layers)
			LAZYADD(relevant_layers["[L]"], S)
		if(!S.mutant_part_string)
			dna_feature_as_text_string[S] = bodypart

	var/static/list/layer_text = list(
		"[BODY_BEHIND_LAYER]" = "BEHIND",
		"[BODY_ADJ_LAYER]" = "ADJ",
		"[BODY_ADJ_UPPER_LAYER]" = "ADJUP",
		"[BODY_FRONT_LAYER]" = "FRONT",
		"[HORNS_LAYER]" = "HORNS",
		)

	var/g = (H.dna.features["body_model"] == FEMALE) ? "f" : "m"
	var/list/colorlist = list()
	var/husk = HAS_TRAIT(H, TRAIT_HUSK)
	colorlist += husk ? ReadRGB("#a3a3a3FF") : ReadRGB("[H.dna.features["mcolor"]]FF")
	colorlist += husk ? ReadRGB("#a3a3a3FF") : ReadRGB("[H.dna.features["mcolor2"]]FF")
	colorlist += husk ? ReadRGB("#a3a3a3FF") : ReadRGB("[H.dna.features["mcolor3"]]FF")
	colorlist += list(0,0,0, hair_alpha)
	for(var/index in 1 to length(colorlist))
		colorlist[index] /= 255

	for(var/layer in relevant_layers)
		var/list/standing = list()
		var/layertext = layer_text[layer]
		if(!layertext) //shouldn't happen
			stack_trace("invalid layer '[layer]' found in the list of relevant layers on species.handle_mutant_bodyparts().")
			continue
		var/layernum = text2num(layer)
		for(var/bodypart in relevant_layers[layer])
			var/datum/sprite_accessory/S = bodypart
			var/mutable_appearance/accessory_overlay = mutable_appearance(S.icon, layer = -layernum)
			bodypart = S.mutant_part_string || dna_feature_as_text_string[S]

			if(S.gender_specific)
				accessory_overlay.icon_state = "[g]_[bodypart]_[S.icon_state]_[layertext]"
			else
				accessory_overlay.icon_state = "m_[bodypart]_[S.icon_state]_[layertext]"

			if(S.center)
				accessory_overlay = center_image(accessory_overlay, S.dimension_x, S.dimension_y)

			if(!husk)
				if(!forced_colour)
					switch(S.color_src)
						if(SKINTONE)
							accessory_overlay.color = SKINTONE2HEX(H.skin_tone)
						if(MUTCOLORS)
							if(fixed_mut_color)
								accessory_overlay.color = "[fixed_mut_color]"
							else
								accessory_overlay.color = "[H.dna.features["mcolor"]]"
						if(MUTCOLORS2)
							if(fixed_mut_color2)
								accessory_overlay.color = "[fixed_mut_color2]"
							else
								accessory_overlay.color = "[H.dna.features["mcolor2"]]"
						if(MUTCOLORS3)
							if(fixed_mut_color3)
								accessory_overlay.color = "[fixed_mut_color3]"
							else
								accessory_overlay.color = "[H.dna.features["mcolor3"]]"

						if(MATRIXED)
							accessory_overlay.color = list(colorlist)

						if(HAIR)
							if(hair_color == "mutcolor")
								accessory_overlay.color = "[H.dna.features["mcolor"]]"
							else
								accessory_overlay.color = "[H.hair_color]"

						if(FACEHAIR)
							accessory_overlay.color = "[H.facial_hair_color]"
						if(EYECOLOR)
							accessory_overlay.color = "[H.left_eye_color]"
						if(RIGHTEYECOLOR)
							accessory_overlay.color = "[H.right_eye_color]"
						if(HORNCOLOR)
							accessory_overlay.color = "[H.dna.features["horns_color"]]"
						if(WINGCOLOR)
							accessory_overlay.color = "[H.dna.features["wings_color"]]"
				else
					accessory_overlay.color = forced_colour
			else
				if(bodypart == "ears")
					accessory_overlay.icon_state = "m_ears_none_[layertext]"
				if(bodypart == "tail")
					accessory_overlay.icon_state = "m_tail_husk_[layertext]"
				if(S.color_src == MATRIXED)
					accessory_overlay.color = colorlist

			if(OFFSET_MUTPARTS in H.dna.species.offset_features)
				accessory_overlay.pixel_x += H.dna.species.offset_features[OFFSET_MUTPARTS][1]
				accessory_overlay.pixel_y += H.dna.species.offset_features[OFFSET_MUTPARTS][2]

			standing += accessory_overlay

			if(S.extra) //apply the extra overlay, if there is one
				var/mutable_appearance/extra_accessory_overlay = mutable_appearance(S.icon, layer = -layernum)
				if(S.gender_specific)
					extra_accessory_overlay.icon_state = "[g]_[bodypart]_extra_[S.icon_state]_[layertext]"
				else
					extra_accessory_overlay.icon_state = "m_[bodypart]_extra_[S.icon_state]_[layertext]"
				if(S.center)
					extra_accessory_overlay = center_image(extra_accessory_overlay, S.dimension_x, S.dimension_y)


				switch(S.extra_color_src) //change the color of the extra overlay
					if(MUTCOLORS)
						if(fixed_mut_color)
							extra_accessory_overlay.color = "[fixed_mut_color]"
						else
							extra_accessory_overlay.color = "[H.dna.features["mcolor"]]"
					if(MUTCOLORS2)
						if(fixed_mut_color2)
							extra_accessory_overlay.color = "[fixed_mut_color2]"
						else
							extra_accessory_overlay.color = "[H.dna.features["mcolor2"]]"
					if(MUTCOLORS3)
						if(fixed_mut_color3)
							extra_accessory_overlay.color = "[fixed_mut_color3]"
						else
							extra_accessory_overlay.color = "[H.dna.features["mcolor3"]]"
					if(HAIR)
						if(hair_color == "mutcolor")
							extra_accessory_overlay.color = "[H.dna.features["mcolor3"]]"
						else
							extra_accessory_overlay.color = "[H.hair_color]"
					if(FACEHAIR)
						extra_accessory_overlay.color = "[H.facial_hair_color]"
					if(EYECOLOR)
						extra_accessory_overlay.color = "[H.left_eye_color]"
					if(RIGHTEYECOLOR)
						extra_accessory_overlay.color = "[H.right_eye_color]"

					if(HORNCOLOR)
						extra_accessory_overlay.color = "[H.dna.features["horns_color"]]"
					if(WINGCOLOR)
						extra_accessory_overlay.color = "[H.dna.features["wings_color"]]"

				if(OFFSET_MUTPARTS in H.dna.species.offset_features)
					extra_accessory_overlay.pixel_x += H.dna.species.offset_features[OFFSET_MUTPARTS][1]
					extra_accessory_overlay.pixel_y += H.dna.species.offset_features[OFFSET_MUTPARTS][2]

				standing += extra_accessory_overlay

			if(S.extra2) //apply the extra overlay, if there is one
				var/mutable_appearance/extra2_accessory_overlay = mutable_appearance(S.icon, layer = -layernum)
				if(S.gender_specific)
					extra2_accessory_overlay.icon_state = "[g]_[bodypart]_extra2_[S.icon_state]_[layertext]"
				else
					extra2_accessory_overlay.icon_state = "m_[bodypart]_extra2_[S.icon_state]_[layertext]"
				if(S.center)
					extra2_accessory_overlay = center_image(extra2_accessory_overlay, S.dimension_x, S.dimension_y)

				switch(S.extra2_color_src) //change the color of the extra overlay
					if(MUTCOLORS)
						if(fixed_mut_color)
							extra2_accessory_overlay.color = "[fixed_mut_color]"
						else
							extra2_accessory_overlay.color = "[H.dna.features["mcolor"]]"
					if(MUTCOLORS2)
						if(fixed_mut_color2)
							extra2_accessory_overlay.color = "[fixed_mut_color2]"
						else
							extra2_accessory_overlay.color = "[H.dna.features["mcolor2"]]"
					if(MUTCOLORS3)
						if(fixed_mut_color3)
							extra2_accessory_overlay.color = "[fixed_mut_color3]"
						else
							extra2_accessory_overlay.color = "[H.dna.features["mcolor3"]]"
					if(HAIR)
						if(hair_color == "mutcolor3")
							extra2_accessory_overlay.color = "[H.dna.features["mcolor"]]"
						else
							extra2_accessory_overlay.color = "[H.hair_color]"
					if(HORNCOLOR)
						extra2_accessory_overlay.color = "[H.dna.features["horns_color"]]"
					if(WINGCOLOR)
						extra2_accessory_overlay.color = "[H.dna.features["wings_color"]]"

				if(OFFSET_MUTPARTS in H.dna.species.offset_features)
					extra2_accessory_overlay.pixel_x += H.dna.species.offset_features[OFFSET_MUTPARTS][1]
					extra2_accessory_overlay.pixel_y += H.dna.species.offset_features[OFFSET_MUTPARTS][2]

				standing += extra2_accessory_overlay

		H.overlays_standing[layernum] = standing

	H.apply_overlay(BODY_BEHIND_LAYER)
	H.apply_overlay(BODY_ADJ_LAYER)
	H.apply_overlay(BODY_ADJ_UPPER_LAYER)
	H.apply_overlay(BODY_FRONT_LAYER)
	H.apply_overlay(HORNS_LAYER)


/*
 * Equip the outfit required for life. Replaces items currently worn.
 */
/datum/species/proc/give_important_for_life(mob/living/carbon/human/human_to_equip)
	if(!outfit_important_for_life)
		return
	outfit_important_for_life= new()
	outfit_important_for_life.equip(human_to_equip)

/* TODO: Snowflake trail marks
// Impliments different trails for species depending on if they're wearing shoes.
/datum/species/proc/get_move_trail(var/mob/living/carbon/human/H)
	if(H.lying)
		return /obj/effect/decal/cleanable/blood/footprints/tracks/body
	if(H.shoes || (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)))
		var/obj/item/clothing/shoes/shoes = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) ? H.wear_suit : H.shoes // suits take priority over shoes
		return shoes.move_trail
	else
		return move_trail
*/

/datum/species/proc/spec_life(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		H.setOxyLoss(0)
		H.losebreath = 0

		var/takes_crit_damage = !HAS_TRAIT(H, TRAIT_NOCRITDAMAGE)
		if(H.is_asystole() && takes_crit_damage)
			H.adjustBruteLoss(1)

/datum/species/proc/spec_death(gibbed, mob/living/carbon/human/H)
	return

/datum/species/proc/auto_equip(mob/living/carbon/human/H)
	// handles the equipping of species-specific gear
	return

/datum/species/proc/can_equip(obj/item/I, slot, disable_warning, mob/living/carbon/human/H, bypass_equip_delay_self = FALSE)
	if(slot in no_equip)
		if(!I.species_exception || !is_type_in_list(src, I.species_exception))
			return FALSE

	var/num_hands = H.get_num_hands(FALSE)
	var/num_feet = H.get_num_feet(FALSE)

	switch(slot)
		if(SLOT_HANDS)
			if(H.get_empty_held_indexes())
				return TRUE
			return FALSE
		if(SLOT_WEAR_MASK)
			if(H.wear_mask)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_MASK))
				return FALSE
			if(!H.get_bodypart_nostump(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_NECK)
			if(H.wear_neck)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_NECK) )
				return FALSE
			return TRUE
		if(SLOT_BACK)
			if(H.back)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_BACK) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_WEAR_SUIT)
			if(H.wear_suit)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_OCLOTHING) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_GLOVES)
			if(H.gloves)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_GLOVES) )
				return FALSE
			if(num_hands < 2) //skyrat edit
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_WRISTS)
			if(H.wrists)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_WRISTS) )
				return FALSE
			if(num_hands < 2)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_SHOES)
			if(H.shoes)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_FEET) )
				return FALSE
			if(num_feet < 2) //skyrat edit
				return FALSE
			if(DIGITIGRADE in species_traits)
				if(!is_species(H, /datum/species/lizard/ashwalker))
					H.update_inv_shoes()
				else
					return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_BELT)
			if(H.belt)
				return FALSE
			if(!CHECK_BITFIELD(I.item_flags, NO_UNIFORM_REQUIRED))
				var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
				if(!H.w_uniform && !nojumpsuit && (!O || O.is_organic_limb()))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>I need a jumpsuit before I can attach this [I.name]!</span>")
					return FALSE
			if(!(I.slot_flags & ITEM_SLOT_BELT))
				return
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_GLASSES)
			if(H.glasses)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EYES))
				return FALSE
			if(!H.get_bodypart_nostump(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_HEAD)
			if(H.head)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_HEAD))
				return FALSE
			if(!H.get_bodypart_nostump(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_EARS_LEFT) //skyrat edit
			if(H.ears)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EARS))
				return FALSE
			if(!H.get_bodypart_nostump(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_EARS_RIGHT)
			if(H.ears_extra)
				return FALSE
			if(!(I.slot_flags & ITEM_SLOT_EARS))
				return FALSE
			if(!H.get_bodypart_nostump(BODY_ZONE_HEAD))
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_W_UNDERWEAR)
			if(H.w_underwear)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_UNDERWEAR) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_W_SOCKS)
			if(H.w_socks)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_SOCKS) )
				return FALSE
			if(num_feet < 2)
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_W_SHIRT)
			if(H.w_shirt)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_SHIRT) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_W_UNIFORM)
			if(H.w_uniform)
				return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ICLOTHING) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_WEAR_ID)
			if(H.wear_id)
				return FALSE
			if(!CHECK_BITFIELD(I.item_flags, NO_UNIFORM_REQUIRED))
				var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_CHEST)
				if(!H.w_uniform && !nojumpsuit && (!O || O.is_organic_limb()))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>I need a jumpsuit before I can attach this [I.name]!</span>")
					return FALSE
			if( !(I.slot_flags & ITEM_SLOT_ID) )
				return FALSE
			return equip_delay_self_check(I, H, bypass_equip_delay_self)
		if(SLOT_L_STORE)
			if(HAS_TRAIT(I, TRAIT_NODROP)) //Pockets aren't visible, so you can't move TRAIT_NODROP items into them.
				return FALSE
			if(H.l_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart_nostump(BODY_ZONE_L_LEG)
			if(!H.w_uniform && !nojumpsuit && (!O || O.is_organic_limb()))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>I need a jumpsuit before I can attach this [I.name]!</span>")
				return FALSE
			if(I.slot_flags & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_POCKET) )
				return TRUE
		if(SLOT_R_STORE)
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(H.r_store)
				return FALSE

			var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_LEG)

			if(!H.w_uniform && !nojumpsuit && (!O || O.is_organic_limb()))
				if(!disable_warning)
					to_chat(H, "<span class='warning'>I need a jumpsuit before I can attach this [I.name]!</span>")
				return FALSE
			if(I.slot_flags & ITEM_SLOT_DENYPOCKET)
				return FALSE
			if( I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & ITEM_SLOT_POCKET) )
				return TRUE
			return FALSE
		if(SLOT_S_STORE)
			var/obj/item/gun/G = I
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(H.s_store)
				return FALSE
			if(istype(I, /obj/item/riding_offhand))
				var/obj/item/riding_offhand/rider = I
				if(rider.parent == H)
					return TRUE
			if(!H.wear_suit)
				if(!istype(G))
					if(!disable_warning)
						to_chat(H, "<span class='warning'>I need a suit before I can attach this [I.name]!</span>")
						return FALSE
				else if(!G.sling)
					if(!disable_warning)
						to_chat(H, "<span class='warning'>\The [G] needs to be slung before I can wear it!</span>")
						return FALSE
			else if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(H, "You somehow have a suit with no defined allowed items for suit storage, stop that.")
				return FALSE
			if(istype(I, /obj/item/pda) || istype(I, /obj/item/pen) || (istype(G) && G.sling) || is_type_in_list(I, H.wear_suit?.allowed))
				return TRUE
			if(I.w_class > WEIGHT_CLASS_BULKY)
				if(!disable_warning)
					to_chat(H, "The [I.name] is too big to attach.")
				return FALSE
			return FALSE
		if(SLOT_HANDCUFFED)
			if(H.handcuffed)
				return FALSE
			if(!istype(I, /obj/item/restraints/handcuffs))
				return FALSE
			if(num_hands < 2)
				return FALSE
			return TRUE
		if(SLOT_LEGCUFFED)
			if(H.legcuffed)
				return FALSE
			if(!istype(I, /obj/item/restraints/legcuffs))
				return FALSE
			if(num_feet < 2)
				return FALSE
			return TRUE
		if(SLOT_IN_BACKPACK)
			if(H.back)
				if(SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_CAN_INSERT, I, H, TRUE))
					return TRUE
			return FALSE
	return FALSE //Unsupported slot

/datum/species/proc/equip_delay_self_check(obj/item/I, mob/living/carbon/human/H, bypass_equip_delay_self)
	if(!I.equip_delay_self || bypass_equip_delay_self)
		return TRUE
	H.visible_message("<span class='notice'>[H] start putting on [I]...</span>", "<span class='notice'>I start putting on [I]...</span>")
	return do_after(H, I.equip_delay_self, target = H)

/datum/species/proc/before_equip_job(datum/job/J, mob/living/carbon/human/H)
	return

/datum/species/proc/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	H.update_mutant_bodyparts()

/datum/species/proc/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == exotic_blood && !istype(exotic_blood, /datum/reagent/blood))
		H.blood_volume = min(H.blood_volume + round(chem.volume, 0.1), BLOOD_VOLUME_MAXIMUM)
		H.reagents.del_reagent(chem.type)
		//skyrat edit - we try to revive the carbon mob if it happens to be a synthetic
		if(length(species_traits) && (ROBOTIC_LIMBS in species_traits) && length(H.bodyparts))
			var/obj/item/bodypart/affecting = H.bodyparts[1]
			if(istype(affecting))
				affecting.heal_damage(0, 0, 0, TRUE, FALSE, FALSE)
		//skyrat edit end
		return TRUE
	return FALSE

/datum/species/proc/check_weakness(obj/item, mob/living/attacker)
	return FALSE

////////
//LIFE//
////////

/datum/species/proc/handle_nutrition(mob/living/carbon/H)
	if(HAS_TRAIT(H, TRAIT_NOHUNGER))
		return //hunger is for BABIES

	//The fucking TRAIT_FAT mutation is the dumbest shit ever. It makes the code so difficult to work with
	if(HAS_TRAIT(H, TRAIT_FAT))//I share your pain, past coder.
		if(H.overeatduration < 100)
			to_chat(H, "<span class='notice'>I feel fit again!</span>")
			REMOVE_TRAIT(H, TRAIT_FAT, OBESITY)
			H.remove_movespeed_modifier(/datum/movespeed_modifier/obesity)
			H.update_inv_w_uniform()
			H.update_inv_w_underwear()
			H.update_inv_w_socks()
			H.update_inv_w_shirt()
			H.update_inv_wear_suit()
	else
		if(H.overeatduration >= 100)
			to_chat(H, "<span class='danger'>I suddenly feel blubbery!</span>")
			ADD_TRAIT(H, TRAIT_FAT, OBESITY)
			H.add_movespeed_modifier(/datum/movespeed_modifier/obesity)
			H.update_inv_w_uniform()
			H.update_inv_w_underwear()
			H.update_inv_w_socks()
			H.update_inv_w_shirt()
			H.update_inv_wear_suit()

	var/intestines_nutrition_loss = 1 //This is the maximum loss multiplier you can get with an intestine, in case they don't have none
	var/intestines_nutrition_gain = 1
	// nutrition decrease and satiety
	if(H.nutrition > 0 && H.stat != DEAD)
		// THEY HUNGER
		var/hunger_rate = HUNGER_FACTOR
		var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
		if(mood && mood.sanity > SANITY_DISTURBED)
			hunger_rate *= max(0.5, 1 - 0.002 * mood.sanity) //0.85 to 0.75

		// Whether we cap off our satiety or move it towards 0
		if(H.satiety > MAX_SATIETY)
			H.satiety = MAX_SATIETY
		else if(H.satiety > 0)
			H.satiety--
		else if(H.satiety < -MAX_SATIETY)
			H.satiety = -MAX_SATIETY
		else if(H.satiety < 0)
			H.satiety++
			if(prob(round(-H.satiety/40)))
				H.Jitter(5)
			hunger_rate = 3 * HUNGER_FACTOR
		hunger_rate *= intestines_nutrition_loss
		if(ishuman(H))
			var/mob/living/carbon/human/humie = H
			hunger_rate *= humie.physiology.hunger_mod
		if(hunger_rate > 0 && !HAS_TRAIT(H, TRAIT_NOSHITTING))
			H.adjust_defecation(hunger_rate)
		H.adjust_nutrition(-hunger_rate)

	if(H.nutrition > NUTRITION_LEVEL_FULL)
		if(H.overeatduration < 600) //capped so people don't take forever to unfat
			H.overeatduration++
	else
		if(H.overeatduration > 1)
			H.overeatduration -= (2 * intestines_nutrition_gain) //I know this doesn't make much sense since it's gain, but you should not
									// be rewarded for damaged intestines

	//Metabolism change
	if(H.nutrition > NUTRITION_LEVEL_FAT)
		H.metabolism_efficiency = 1
	else if(H.nutrition > NUTRITION_LEVEL_FED && H.satiety > 80)
		if(H.metabolism_efficiency != 1.25 && !HAS_TRAIT(H, TRAIT_NOHUNGER))
			to_chat(H, "<span class='notice'>I feel vigorous.</span>")
			H.metabolism_efficiency = 1.25
	else if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		if(H.metabolism_efficiency != 0.8)
			to_chat(H, "<span class='notice'>I feel sluggish.</span>")
		H.metabolism_efficiency = 0.8
	else
		if(H.metabolism_efficiency == 1.25)
			to_chat(H, "<span class='notice'>I no longer feel vigorous.</span>")
		H.metabolism_efficiency = 1

	H.metabolism_efficiency *= intestines_nutrition_gain

	//Hunger slowdown for if mood isn't enabled
	if(CONFIG_GET(flag/disable_human_mood))
		if(!HAS_TRAIT(H, TRAIT_NOHUNGER))
			var/hungry = (500 - H.nutrition) / 5 //So overeat would be 100 and default level would be 80
			if(hungry >= 70)
				H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/hunger, multiplicative_slowdown = (hungry / 50))
			else
				H.remove_movespeed_modifier(/datum/movespeed_modifier/hunger)
	H.hud_used?.nutrition?.update_icon()

/datum/species/proc/handle_hydration(mob/living/carbon/H)
	if(HAS_TRAIT(H, TRAIT_NOHYDRATION))
		return FALSE

	// hydration decrease wowie
	if(H.hydration > 0 && H.stat != DEAD)
		// THEY hydrate
		var/dehydration_rate = THIRST_FACTOR
		var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
		if(mood && mood.sanity > SANITY_DISTURBED)
			dehydration_rate *= max(0.5, 1 - 0.002 * mood.sanity) //0.85 to 0.75

		if(dehydration_rate > 0 && !HAS_TRAIT(H, TRAIT_NOPISSING))
			H.adjust_urination(dehydration_rate)
		H.adjust_hydration(-dehydration_rate)

	H.hud_used?.hydration?.update_icon()

//cursed.
/datum/species/proc/handle_defecation(mob/living/carbon/H)
	if(HAS_TRAIT(H, TRAIT_NOSHITTING))
		H.defecation = 0
		return //girls don't shit
	switch(H.defecation)
		if(DEFECATION_LEVEL_POOPY to DEFECATION_LEVEL_VERY_POOPY)
			if(prob(2))
				to_chat(H, "<span class='danger'>I need to shit.</span>")
		if(DEFECATION_LEVEL_VERY_POOPY to DEFECATION_LEVEL_POOPENFARDEN)
			if(prob(5))
				to_chat(H, "<span class='danger'>I <b>really</b> need to shit.</span>")
		if(DEFECATION_LEVEL_POOPENFARDEN to DEFECATION_LEVEL_SHITPANTS)
			if(prob(10))
				H.defecate()
			else if(prob(15))
				to_chat(H, "<span class='danger'>I'm gonna <b>SHIT MYSELF</b>!</span>")
		if(DEFECATION_LEVEL_SHITPANTS to INFINITY)
			H.defecate()

/datum/species/proc/handle_urination(mob/living/carbon/H)
	if(HAS_TRAIT(H, TRAIT_NOPISSING))
		H.urination = 0
		return //girls dont piss
	switch(H.urination)
		if(URINATION_LEVEL_PISSY to URINATION_LEVEL_VERY_PISSY)
			if(prob(2))
				to_chat(H, "<span class='danger'>I need to piss.</span>")
		if(URINATION_LEVEL_VERY_PISSY to URINATION_LEVEL_PISSENCUMMEN)
			if(prob(5))
				to_chat(H, "<span class='danger'>I <b>really</b> need to piss.</span>")
		if(URINATION_LEVEL_PISSENCUMMEN to URINATION_LEVEL_PISSPANTS)
			if(prob(10))
				H.urinate()
			else if(prob(15))
				to_chat(H, "<span class='danger'>I'm gonna <b>PISS MYSELF</b>!</span>")
		if(URINATION_LEVEL_PISSPANTS to INFINITY)
			H.urinate()

/datum/species/proc/update_health_hud(mob/living/carbon/human/H)
	return 0

/datum/species/proc/handle_mutations_and_radiation(mob/living/carbon/human/H)
	. = FALSE
	var/radiation = H.radiation

	if(HAS_TRAIT(H, TRAIT_RADIMMUNE))
		radiation = 0
		return TRUE

	if(radiation > RAD_MOB_KNOCKDOWN && prob(RAD_MOB_KNOCKDOWN_PROB))
		if(CHECK_MOBILITY(H, MOBILITY_STAND))
			H.emote("collapse")
		H.DefaultCombatKnockdown(RAD_MOB_KNOCKDOWN_AMOUNT)
		to_chat(H, "<span class='danger'>I feel weak.</span>")

	if(radiation > RAD_MOB_VOMIT && prob(RAD_MOB_VOMIT_PROB))
		H.vomit(10, TRUE)

	if(radiation > RAD_MOB_MUTATE)
		if(prob(1))
			to_chat(H, "<span class='danger'>I mutate!</span>")
			H.easy_randmut(NEGATIVE+MINOR_NEGATIVE)
			H.emote("gasp")
			H.domutcheck()

	if(radiation > RAD_MOB_HAIRLOSS)
		if(prob(15) && !(H.hair_style == "Bald") && (HAIR in species_traits))
			to_chat(H, "<span class='danger'>Your hair starts to fall out in clumps...</span>")
			addtimer(CALLBACK(src, .proc/go_bald, H), 50)

/datum/species/proc/go_bald(mob/living/carbon/human/H)
	if(QDELETED(H))	//may be called from a timer
		return
	H.facial_hair_style = "Shaved"
	H.hair_style = "Bald"
	H.update_hair()

//////////////////
// ATTACK PROCS //
//////////////////

/datum/species/proc/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style, rightclick = FALSE)
	if(attacker_style && attacker_style.help_act(user,target)) // SKYRAT EDIT
		return TRUE

	var/we_breathe = !HAS_TRAIT(user, TRAIT_NOBREATH)
	var/we_lung = user.getorganslot(ORGAN_SLOT_LUNGS)
	if(!target.lying)
		target.help_shake_act(user)
		if(target != user)
			log_combat(user, target, "shaked")
		return TRUE
	if(user != target)
		switch(user.zone_selected)
			if(BODY_ZONE_PRECISE_MOUTH)
				if(we_breathe && we_lung)
					user.do_cpr(target, MOUTH_CPR)
				else if(we_breathe && !we_lung)
					to_chat(user, "<span class='warning'>I have no lungs, i cannot peform mouth to mouth!</span>")
				else if(!we_breathe)
					to_chat(user, "<span class='notice'>I don't breathe, i cannot perform mouth to mouth!</span>")
				return TRUE
			if(BODY_ZONE_CHEST)
				user.do_cpr(target, CHEST_CPR)
				return TRUE
			else
				target.help_shake_act(user)
				if(target != user)
					log_combat(user, target, "shaked")
				return TRUE

/datum/species/proc/grab(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style, rightclick = FALSE)
	if(target.check_martial_melee_block())
		target.visible_message("<span class='warning'><b>[target]</b> blocks <b>[user]</b>'s grab attempt!</span>", target = user, \
			target_message = "<span class='warning'><b>[target]</b> blocks your grab attempt!</span>")
		return 0

	if(target.mind?.handle_parry(target, null, 0, user))
		playsound(get_turf(target), 'modular_skyrat/sound/attack/parry.ogg', 70)
		var/held_item
		if(target.get_active_held_item())
			held_item = " with [target.p_their()] [target.get_active_held_item()]"
		else
			held_item = " with [target.p_their()] bare hands"
		target.visible_message("<span class='danger'><b>[target]</b> blocks <b>[user]</b>[held_item]!</span>")
		return 0

	if(target.mind?.handle_dodge(target, null, 0, user))
		//Make the victim step to an adjacent tile because ooooooh dodge
		var/list/turf/dodge_turfs = list()
		for(var/turf/open/O in range(1,target))
			if(target.CanReach(O))
				dodge_turfs += O
		//No available turfs == we can't actually dodge
		if(length(dodge_turfs))
			var/turf/yoink = pick(dodge_turfs)
			//We moved to the tile, therefore we dodged successfully
			if(target.Move(yoink, get_dir(target, yoink)))
				playsound(get_turf(target), miss_sound, 70)
				target.visible_message("<span class='danger'><b>[target]</b> dodges <b>[user]</b>!</span>")
				return 0

	if(attacker_style && attacker_style.grab_act(user,target))
		return 1
	else
		target.grabbedby(user)
		return 1

/datum/species/proc/harm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style, rightclick = FALSE)
	if(!attacker_style && HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>I don't want to harm <b>[target]</b>!</span>")
		return FALSE
	if(IS_STAMCRIT(user)) //CITADEL CHANGE - makes it impossible to punch while in stamina softcrit
		to_chat(user, "<span class='warning'>I'm too exhausted!</span>") //CITADEL CHANGE - ditto
		return FALSE //CITADEL CHANGE - ditto
	if(target.check_martial_melee_block())
		target.visible_message("<span class='warning'><b>[target]</b> blocks <b>[user]</b>'s attack!</span>", target = user, \
			target_message = "<span class='warning'><b>[target]</b> blocks your attack!</span>")
		return FALSE

	if(target.mind?.handle_parry(target, null, 0, user))
		playsound(get_turf(target), 'modular_skyrat/sound/attack/parry.ogg', 70)
		var/held_item
		if(target.get_active_held_item())
			held_item = " with [target.p_their()] [target.get_active_held_item()]"
		else
			held_item = " with [target.p_their()] bare hands"
		target.visible_message("<span class='danger'><b>[target]</b> blocks <b>[user]</b>[held_item]!</span>")
		return FALSE

	if(target.mind?.handle_dodge(target, null, 0, user))
		//Make the victim step to an adjacent tile because ooooooh dodge
		var/list/turf/dodge_turfs = list()
		for(var/turf/open/O in range(1,target))
			if(target.CanReach(O))
				dodge_turfs += O
		//No available turfs == we can't actually dodge
		if(length(dodge_turfs))
			var/turf/yoink = pick(dodge_turfs)
			//We moved to the tile, therefore we parried successfully
			if(target.Move(yoink, get_dir(target, yoink)))
				playsound(get_turf(target), miss_sound, 70)
				target.visible_message("<span class='danger'><b>[target]</b> dodges <b>[user]</b>!</span>")
				return FALSE

	if(HAS_TRAIT(user, TRAIT_PUGILIST))//CITADEL CHANGE - makes punching cause staminaloss but funny martial artist types get a discount
		user.adjustStaminaLossBuffered(1.5)
	else
		user.adjustStaminaLossBuffered(3.5)

	if(attacker_style && attacker_style.harm_act(user,target))
		return TRUE
	else
		var/atk_verb = user.dna.species.attack_verb
		switch(atk_verb)
			if(ATTACK_EFFECT_CLAW)
				user.do_attack_animation(target, ATTACK_EFFECT_CLAW)
			if(ATTACK_EFFECT_SMASH)
				user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
			else
				user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)

		var/damage = (user.dna.species.punchdamagelow + user.dna.species.punchdamagehigh)/2
		var/obj/item/clothing/gloves/G = user.gloves

		//Raw damage is affected by the user's strength
		var/str_mod = 1
		if(user.mind)
			str_mod = user.mind.get_skillstat_damagemod(STAT_DATUM(str))
		damage *= str_mod

		//Combat intents change how much your fisto deals
		if(rightclick)
			switch(user.combat_intent)
				if(CI_STRONG)
					damage *= 1.5 //fuck it
				if(CI_WEAK)
					damage *= 0.25

		var/punchedstam = target.getStaminaLoss()
		var/punchedbrute = target.getBruteLoss()

		//CITADEL CHANGES - makes resting and disabled combat mode reduce punch damage, makes being out of combat mode result in you taking more damage
		if(SEND_SIGNAL(target, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
			damage *= 1.1
		if(!CHECK_MOBILITY(user, MOBILITY_STAND))
			damage *= 0.75
		if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE))
			damage *= 0.9
		//END OF CITADEL CHANGES

		//If the user has bad st, sometimes... the attack gets really shit
		var/pitiful = FALSE
		if(user.mind && GET_STAT_LEVEL(user, str) < 10)
			switch(user.mind.diceroll(STAT_DATUM(str)))
				if(DICE_CRIT_FAILURE)
					damage *= 0.75
					pitiful = TRUE

		//Gloves with the force var modify total damage
		if(user.gloves)
			damage += G.force

		//The probability of hitting the correct zone depends on dexterity
		//and also on which limb we aim at
		var/obj/item/bodypart/supposed_to_affect = target.get_bodypart(user.zone_selected)
		var/ran_zone_prob = 50
		var/extra_zone_prob = 50
		var/miss_entirely = 10
		if(supposed_to_affect)
			ran_zone_prob = supposed_to_affect.zone_prob
			extra_zone_prob = supposed_to_affect.extra_zone_prob
			miss_entirely = supposed_to_affect.miss_entirely_prob
		miss_entirely *= (target.lying ? 0.2 : 1)
		if(user.mind)
			var/datum/stats/dex/dex = GET_STAT(user, dex)
			if(dex)
				ran_zone_prob = dex.get_ran_zone_prob(ran_zone_prob, extra_zone_prob)

		//Get the bodypart we actually affect
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(user.zone_selected, ran_zone_prob))
		var/missed = FALSE

		//good modifier if aimed
		var/modifier = 0
		if(rightclick && (user.combat_intent == CI_AIMED))
			modifier += 6

		//Dice roll to see if we fuck up
		if(user.mind && user.mind.diceroll(GET_STAT_LEVEL(user, dex)*0.5, GET_SKILL_LEVEL(user, melee)*1.5, dicetype = "6d6", mod = -(miss_entirely/5) + modifier, crit = 18) <= DICE_CRIT_FAILURE)
			missed = TRUE

		if(!damage || !affecting || (missed && target != user))//future-proofing for species that have 0 damage/weird cases where no zone is targeted
			playsound(target.loc, user.dna.species.miss_sound, 25, TRUE, -1)
			target.visible_message("<span class='danger'><b>[user]</b>'s [atk_verb] misses <b>[target]</b>!</span>", \
							"<span class='danger'><b>[user]</b>'s misses [user.p_their()] [atk_verb] against me!</span>", \
							"<span class='hear'>I hear a swoosh!</span>", COMBAT_MESSAGE_RANGE, null, \
							user, "<span class='warning'>My [atk_verb] misses <b>[target]</b>!</span>")
			log_combat(user, target, "attempted to punch")
			return FALSE

		// Armor damage reduction
		var/armor_block = target.run_armor_check(affecting, "melee")

		var/atk_wound_bonus = 0
		var/atk_barewound_bonus = 0
		var/atk_sharpness = SHARP_NONE

		// Blocking values that mean the damage was under armor, so wounding is changed to blunt
		var/armor_border_blocking = 1 - (target.checkarmormax(affecting, "under_armor_mult") * 1/max(0.01, target.checkarmormax(affecting, "armor_range_mult")))
		if(armor_block >= armor_border_blocking)
			atk_wound_bonus = max(0, atk_wound_bonus - armor_block/100 * damage)
			atk_barewound_bonus = 0
			atk_sharpness = SHARP_NONE

		armor_block = min(95, armor_block)
		playsound(target.loc, pick(user.dna.species.attack_sound), 25, 1, -1)

		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		user.dna.species.spec_unarmedattacked(user, target)

		if(user.limb_destroyer)
			target.dismembering_strike(user, affecting.body_zone)

		if(atk_verb == ATTACK_EFFECT_KICK)//kicks deal 1.5x raw damage + 0.5x stamina damage
			target.apply_damage(damage*1.5, BRUTE, affecting, armor_block, wound_bonus = atk_wound_bonus, bare_wound_bonus = atk_barewound_bonus, sharpness = atk_sharpness)
			target.apply_damage(damage*0.5, STAMINA, affecting, armor_block)
			log_combat(user, target, "kicked")
		else//other attacks deal full raw damage + 2x in stamina damage
			target.apply_damage(damage, BRUTE, affecting, armor_block, wound_bonus = atk_wound_bonus, bare_wound_bonus = atk_barewound_bonus, sharpness = atk_sharpness)
			target.apply_damage(damage*2, STAMINA, affecting, armor_block)
			log_combat(user, target, "punched")

		//Knockdown and stuff
		target.do_stat_effects(user, null, damage, affecting)

		//Attack message
		target.visible_message("<span class='danger'><b>[user]</b>[pitiful ? " pitifully" : ""] [user.dna.species.attack_verb_continuous] <b>[target]</b> on their [affecting.name]![target.wound_message]</span>", \
					"<span class='userdanger'><b>[user]</b>[pitiful ? " pitifully" : ""] [user.dna.species.attack_verb_continuous] me on my [affecting.name]![target.wound_message]</span>", null, COMBAT_MESSAGE_RANGE, null, \
					user, "<span class='danger'>I[pitiful ? " pitifully" : ""] [user.dna.species.attack_verb] <b>[target]</b> on their [affecting.name]![target.wound_message]</span>")

		//Clean the descriptive string
		target.wound_message = ""

		if((target.stat != DEAD) && damage >= user.dna.species.punchstunthreshold)
			if((punchedstam > 50) && prob(punchedstam*0.5)) //If our punch victim has been hit above the threshold, and they have more than 50 stamina damage, roll for stun, probability of 1% per 2 stamina damage
				target.visible_message("<span class='danger'><b>[user]</b> knocks <b>[target]</b> down!</span>", \
								"<span class='userdanger'>I'm knocked down by <b>[user]</b>!</span>",
								"<span class='hear'>I hear aggressive shuffling followed by a loud thud!</span>", COMBAT_MESSAGE_RANGE, null,
								user, "<span class='danger'>I knock <b>[target]</b> down!</span>")

				var/knockdown_duration = 40 + (punchedstam + (punchedbrute*0.5))*0.8 - armor_block
				target.DefaultCombatKnockdown(knockdown_duration)
				target.forcesay(GLOB.hit_appends)
				log_combat(user, target, "got a stun punch with their previous punch")

				if(HAS_TRAIT(user, TRAIT_KI_VAMPIRE) && !HAS_TRAIT(target, TRAIT_NOBREATH) && (punchedbrute < 100)) //If we're a ki vampire we also sap them of lifeforce, but only if they're not too beat up. Also living organics only.
					user.adjustBruteLoss(-5)
					user.adjustFireLoss(-5)
					user.adjustStaminaLoss(-20)

					target.adjustCloneLoss(10)
					target.adjustBruteLoss(10)

		else if(!(target.mobility_flags & MOBILITY_STAND))
			target.forcesay(GLOB.hit_appends)

/datum/species/proc/spec_unarmedattacked(mob/living/carbon/human/user, mob/living/carbon/human/target)
	return

/datum/species/proc/disarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style, rightclick = FALSE)
	// CITADEL EDIT slap mouthy gits and booty
	var/aim_for_mouth = user.zone_selected == "mouth"
	var/target_on_help = target.a_intent == INTENT_HELP
	var/target_aiming_for_mouth = target.zone_selected == "mouth"
	var/target_restrained = target.restrained()
	var/same_dir = (target.dir & user.dir)
	var/aim_for_groin  = user.zone_selected == "groin"
	var/target_aiming_for_groin = target.zone_selected == "groin"

	if(target.check_martial_melee_block()) //END EDIT
		target.visible_message("<span class='warning'><b>[target]</b> blocks <b>[user]</b>'s disarm attempt!</span>", target = user, \
			target_message = "<span class='warning'><b>[target]</b> blocks your disarm attempt!</span>")
		return FALSE

	if(target.mind?.handle_parry(target, null, 0, user))
		playsound(get_turf(target), 'modular_skyrat/sound/attack/parry.ogg', 70)
		var/held_item
		if(target.get_active_held_item())
			held_item = " with [target.p_their()] [target.get_active_held_item()]"
		else
			held_item = " with [target.p_their()] bare hands"
		target.visible_message("<span class='danger'><b>[target]</b> blocks <b>[user]</b>[held_item]!</span>")
		return 0

	if(target.mind?.handle_dodge(target, null, 0, user))
		//Make the victim step to an adjacent tile because ooooooh dodge
		var/list/turf/dodge_turfs = list()
		for(var/turf/open/O in range(1,target))
			if(target.CanReach(O))
				dodge_turfs += O
		//No available turfs == we can't actually dodge
		if(length(dodge_turfs))
			var/turf/yoink = pick(dodge_turfs)
			//We moved to the tile, therefore we parried successfully
			if(target.Move(yoink, get_dir(target, yoink)))
				playsound(get_turf(target), pick(miss_sound), 70)
				target.visible_message("<span class='danger'><b>[target]</b> dodges <b>[user]</b>!</span>")
				return 0

	if(IS_STAMCRIT(user))
		to_chat(user, "<span class='warning'>I'm too exhausted!</span>")
		return FALSE

	else if(aim_for_mouth && ( target_on_help || target_restrained || target_aiming_for_mouth))
		playsound(target.loc, 'sound/weapons/slap.ogg', 50, 1, -1)

		target.visible_message(\
			"<span class='danger'>\The <b>[user]</b> slaps [user == target ? "[user.p_them()]self" : "\the <b>[target]</b>"] in the face!</span>",\
			"<span class='notice'><b>[user]</b> slaps me in the face! </span>",\
			"I hear a slap.", target = user, target_message = "<span class='notice'>I slap [user == target ? "myself" : "\the <b>[target]</b>"] in the face! </span>")
		user.do_attack_animation(target, ATTACK_EFFECT_FACE_SLAP)
		user.adjustStaminaLossBuffered(3)
		if(!HAS_TRAIT(target, TRAIT_PERMABONER))
			stop_wagging_tail(target)
		return FALSE
	else if(aim_for_groin && (target == user || target.lying || same_dir) && (target_on_help || target_restrained || target_aiming_for_groin))
		user.do_attack_animation(target, ATTACK_EFFECT_ASS_SLAP)
		user.adjustStaminaLossBuffered(3)
		target.adjust_arousal(20,maso = TRUE)
		if(!HAS_TRAIT(target, TRAIT_PERMABONER))
			stop_wagging_tail(target)
		playsound(target.loc, 'sound/weapons/slap.ogg', 50, 1, -1)
		target.visible_message(\
			"<span class='danger'>\The <b>[user]</b> slaps [user == target ? "[user.p_their()] own" : "\the <b>[target]</b>'s"] ass!</span>",\
			"<span class='notice'><b>[user]</b> slaps my ass! </span>",\
			"I hear a slap.", target = user, target_message = "<span class='notice'>I slap [user == target ? "my own" : "\the <b>[target]</b>'s"] ass! </span>")

		return FALSE

	else
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)

		if(HAS_TRAIT(user, TRAIT_PUGILIST))//CITADEL CHANGE - makes disarmspam cause staminaloss, pugilists can do it almost effortlessly
			user.adjustStaminaLossBuffered(1)
		else
			user.adjustStaminaLossBuffered(3)

		if(attacker_style && attacker_style.disarm_act(user,target))
			return TRUE

		if(target.w_uniform)
			target.w_uniform.add_fingerprint(user)
		else if(target.w_underwear)
			target.w_underwear.add_fingerprint(user)
		else if(target.w_socks)
			target.w_socks.add_fingerprint(user)
		else if(target.w_shirt)
			target.w_shirt.add_fingerprint(user)
		SEND_SIGNAL(target, COMSIG_HUMAN_DISARM_HIT, user, user.zone_selected)
		if(target.pulling == user)
			target.visible_message("<span class='warning'><b>[user]</b> wrestles out of <b>[target]</b>'s grip!</span>", \
				"<span class='warning'><b>[user]</b> wrestles out of my grip!</span>", target = user, \
				target_message = "<span class='warning'>I wrestle out of <b>[target]</b>'s grip!</span>")
			target.stop_pulling()
			playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			log_combat(user, target, "disarmed out of grab from")
			return
		var/randn = rand(1, 100)
		if(SEND_SIGNAL(target, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE)) // CITADEL CHANGE
			randn += -10 //CITADEL CHANGE - being out of combat mode makes it easier for you to get disarmed
		if(!CHECK_MOBILITY(user, MOBILITY_STAND)) //CITADEL CHANGE
			randn += 100 //CITADEL CHANGE - No kosher disarming if you're resting
		if(SEND_SIGNAL(user, COMSIG_COMBAT_MODE_CHECK, COMBAT_MODE_INACTIVE)) //CITADEL CHANGE
			randn += 25 //CITADEL CHANGE - Makes it harder to disarm outside of combat mode
		if(user.pulling == target)
			randn -= 20 //If you have the time to get someone in a grab, you should have a greater chance at snatching the thing in their hand. Will be made completely obsolete by the grab rework but i've got a poor track record for releasing big projects on time so w/e i guess
		if(HAS_TRAIT(user, TRAIT_PUGILIST))
			randn -= 25 //if you are a pugilist, you're slapping that item from them pretty reliably
		if(HAS_TRAIT(target, TRAIT_PUGILIST))
			randn += 25 //meanwhile, pugilists are less likely to get disarmed

		//High dexterity target means it's harder to disarm
		if(target.mind)
			var/datum/stats/dex/dex = GET_STAT(target, dex)
			if(dex)
				randn *= dex.get_disarm_mult()

		//High dexterity attacker means it's easier to disarm
		if(user.mind)
			var/datum/stats/dex/dex = GET_STAT(user, dex)
			if(dex)
				randn /= dex.get_disarm_mult()

		if(randn <= 35)//CIT CHANGE - changes this back to a 35% chance to accomodate for the above being commented out in favor of right-click pushing
			var/obj/item/I = null
			if(target.pulling)
				target.visible_message("<span class='warning'><b>[user]</b> has broken <b>[target]</b>'s grip on [target.pulling]!</span>", \
					"<span class='warning'><b>[user]</b> has broken my grip on <b>[target.pulling]</b>!</span>", target = user, \
					target_message = "<span class='warning'>I have broken <b>[target]</b>'s grip on <b>[target.pulling]</b>!</span>")
				target.stop_pulling()
			else
				I = target.get_active_held_item()
				if(target.dropItemToGround(I))
					target.visible_message("<span class='danger'><b>[user]</b> has disarmed <b>[target]</b>!</span>", \
						"<span class='userdanger'><b>[user]</b> has disarmed me!</span>", null, COMBAT_MESSAGE_RANGE, null, \
						user, "<span class='danger'>I have disarmed <b>[target]</b>!</span>")
				else
					I = null
			playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			log_combat(user, target, "disarmed", "[I ? " removing \the [I]" : ""]")
			return


		playsound(target, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		target.visible_message("<span class='danger'><b>[user]</b> attempted to disarm <b>[target]</b>!</span>", \
						"<span class='userdanger'><b>[user]</b> attemped to disarm <b>[target]</b>!</span>", null, COMBAT_MESSAGE_RANGE, null, \
						user, "<span class='danger'>I attempted to disarm <b>[target]</b>!</span>")
		log_combat(user, target, "attempted to disarm")


/datum/species/proc/spec_hitby(atom/movable/AM, mob/living/carbon/human/H)
	return

/datum/species/proc/spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style, rightclick = FALSE)
	if(!istype(M))
		return
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(H)

	if(!istype(M)) //sanity check for drones.
		return
	if(M.mind)
		attacker_style = M.mind.martial_art
		if(attacker_style?.pacifism_check && HAS_TRAIT(M, TRAIT_PACIFISM)) // most martial arts are quite harmful, alas.
			attacker_style = null
	switch(M.a_intent)
		if(INTENT_HELP)
			help(M, H, attacker_style, rightclick)

		if(INTENT_GRAB)
			grab(M, H, attacker_style, rightclick)

		if(INTENT_HARM)
			switch(M.special_attack)
				if(SPECIAL_ATK_NONE)
					harm(M, H, attacker_style, rightclick)
				if(SPECIAL_ATK_KICK)
					kick(M, H, attacker_style, rightclick)
				if(SPECIAL_ATK_BITE)
					bite(M, H, attacker_style, rightclick)

		if(INTENT_DISARM)
			disarm(M, H, attacker_style, rightclick)

/datum/species/proc/spec_attacked_by(obj/item/I, mob/living/user, obj/item/bodypart/affecting, intent, mob/living/carbon/human/H, attackchain_flags = NONE, damage_multiplier = 1)
	var/totitemdamage = H.pre_attacked_by(I, user) * damage_multiplier
	// Allows you to put in item-specific reactions based on species
	if(user != H)
		var/list/block_return = list()
		if(H.mob_run_block(I, totitemdamage, "the [I.name]", ((attackchain_flags & ATTACKCHAIN_PARRY_COUNTERATTACK) ? ATTACK_TYPE_PARRY_COUNTERATTACK : NONE) | ATTACK_TYPE_MELEE, I.armour_penetration, user, affecting?.body_zone, block_return) & BLOCK_SUCCESS)
			return 0
		totitemdamage = block_calculate_resultant_damage(totitemdamage, block_return)

	if(H.check_martial_melee_block())
		H.visible_message("<span class='warning'><b>[H]></b> blocks [I]!</span>")
		return 0

	if(H.mind?.handle_parry(H, I, totitemdamage, user))
		playsound(get_turf(H), 'modular_skyrat/sound/attack/parry.ogg', 70)
		var/held_item
		if(H.get_active_held_item())
			held_item = " with [H.p_their()] [H.get_active_held_item()]"
		else
			held_item = " with [H.p_their()] bare hands"
		H.visible_message("<span class='warning'><b>[H]</b> blocks [I][held_item]!</span>")
		return 0

	if(H.mind?.handle_dodge(H, I, totitemdamage, user))
		//Make the victim step to an adjacent tile because ooooooh dodge
		var/list/turf/dodge_turfs = list()
		for(var/turf/open/O in range(1,H))
			if(H.CanReach(O))
				dodge_turfs += O
		//No available turfs == we can't actually dodge
		if(length(dodge_turfs))
			var/turf/yoink = pick(dodge_turfs)
			//We moved to the tile, therefore we parried successfully
			if(H.Move(yoink, get_dir(H, yoink)))
				playsound(get_turf(H), miss_sound, 70)
				H.visible_message("<span class='warning'><b>[H]</b> dodges [I]!</span>")
				return 0

	var/hit_area
	if(!affecting) //Something went wrong. Maybe the limb is missing?
		affecting = H.bodyparts[1]

	hit_area = affecting?.body_zone

	// Armor damage reduction
	var/armor_block = H.run_armor_check(affecting, "melee", "<span class='notice'>Your armor has protected your [parse_zone(hit_area)].</span>", "<span class='notice'>Your armor has softened a hit to your [parse_zone(hit_area)].</span>",I.armour_penetration)

	var/Iforce = I.force //to avoid runtimes on the forcesay checks at the bottom. Some items might delete themselves if you drop them. (stunning yourself, ninja swords)

	var/Iwound_bonus = I.wound_bonus

	var/Ibarewound_bonus = I.bare_wound_bonus

	var/Isharpness = I.get_sharpness()

	// Blocking values that mean the damage was under armor, so wounding is changed to blunt
	var/armor_border_blocking = 1 - (H.checkarmormax(affecting, "under_armor_mult") * 1/max(0.01, H.checkarmormax(affecting, "armor_range_mult")))
	if(armor_block >= armor_border_blocking)
		Iwound_bonus = max(0, Iwound_bonus - armor_block/100 * Iforce)
		Ibarewound_bonus = 0
		Isharpness = SHARP_NONE

	var/weakness = H.check_weakness(I, user)
	armor_block = min(95, armor_block)

	//Damage moment
	apply_damage(totitemdamage * weakness, I.damtype, hit_area, armor_block, H, wound_bonus = Iwound_bonus, bare_wound_bonus = Ibarewound_bonus, sharpness = Isharpness)

	//How the fuck does this work?
	I.do_stagger_action(H, user, totitemdamage)

	//Mine is fucking better idc
	if(H.mind || user.mind)
		H.do_stat_effects(user, I, totitemdamage, affecting)

	//Send item attack message
	H.send_item_attack_message(I, user, hit_area, totitemdamage * weakness, affecting)

	//Clean the descriptive string
	H.wound_message = ""

	//fuck piss
	if(!totitemdamage)
		return 0 //item force is zero

	var/bloody = 0
	if(((I.damtype == BRUTE) && I.force && prob(25 + (I.force * 2))))
		if(affecting.is_organic_limb())
			I.add_mob_blood(H)	//Make the weapon bloody, not the person.
			if(prob(I.force * 2))	//blood spatter!
				bloody = 1
				if(get_dist(user, H) <= 1)	//people with TK won't get smeared with blood
					user.add_mob_blood(H)
				var/dist = rand(0,max(min(round(totitemdamage/5, 1),3), 1))
				var/turf/location = get_turf(H)
				if(istype(location))
					H.add_splatter_floor(location)
				var/turf/targ = get_ranged_target_turf(user, get_dir(user, H), dist)
				if(istype(targ) && dist > 0 && ((H.mob_biotypes & MOB_ORGANIC) || (H.mob_biotypes & MOB_HUMANOID)) && H.needs_heart() && !H.is_asystole() && (ishuman(H) ? !(NOBLOOD in species_traits) : TRUE))
					var/obj/effect/decal/cleanable/blood/hitsplatter/B = new(H.loc, H.get_blood_dna_list())
					B.add_blood_DNA(H.get_blood_dna_list())
					B.GoTo(targ, dist)

		switch(hit_area)
			if(BODY_ZONE_HEAD)
				if(!I.get_sharpness() && armor_block < 50)
					if(prob(I.force))
						H.adjustBrainLoss(20)
						if(H.stat == CONSCIOUS)
							H.visible_message("<span class='danger'><b>[H]</b> has been knocked senseless!</span>", \
											"<span class='userdanger'>I have been knocked senseless!</span>")
							H.confused = max(H.confused, 20)
							H.adjust_blurriness(10)
						if(prob(5))
							H.gain_trauma(/datum/brain_trauma/mild/concussion)
					else
						H.adjustBrainLoss(I.force * 0.2)

					if(H.stat == CONSCIOUS && H != user && prob(I.force + ((100 - H.health) * 0.5))) // rev deconversion through blunt trauma.
						var/datum/antagonist/rev/rev = H.mind?.has_antag_datum(/datum/antagonist/rev)
						var/datum/antagonist/gang/gang = H.mind?.has_antag_datum(/datum/antagonist/gang && !/datum/antagonist/gang/boss)
						if(rev)
							rev.remove_revolutionary(FALSE, user)
						if(gang)
							H.mind.remove_antag_datum(/datum/antagonist/gang)

				if(bloody)	//Apply blood
					if(H.wear_mask)
						H.wear_mask.add_mob_blood(H)
						H.update_inv_wear_mask()
					if(H.head)
						H.head.add_mob_blood(H)
						H.update_inv_head()
					if(H.glasses && prob(33))
						H.glasses.add_mob_blood(H)
						H.update_inv_glasses()

			if(BODY_ZONE_CHEST)
				if(H.stat == CONSCIOUS && !I.get_sharpness() && armor_block < 50)
					if(prob(I.force))
						H.visible_message("<span class='danger'><b>[H]</b> has been knocked down!</span>", \
									"<span class='userdanger'><b>[H]</b> has been knocked down!</span>")
						H.apply_effect(60, EFFECT_KNOCKDOWN, armor_block)

				if(bloody)
					if(H.wear_suit)
						H.wear_suit.add_mob_blood(H)
						H.update_inv_wear_suit()
					if(H.w_uniform)
						H.w_uniform.add_mob_blood(H)
						H.update_inv_w_uniform()
			if(BODY_ZONE_PRECISE_GROIN)
				if(H.stat == CONSCIOUS && !I.get_sharpness() && armor_block < 50)
					if(prob(I.force))
						H.visible_message("<span class='danger'><b>[H]</b> has been knocked down!</span>", \
									"<span class='userdanger'><b>[H]</b> has been knocked down!</span>")
						H.apply_effect(60, EFFECT_KNOCKDOWN, armor_block)
					//skyrat edit
					if(H.w_underwear)
						H.w_underwear.add_mob_blood(H)
						H.update_inv_w_underwear()
					if(H.w_socks)
						H.w_socks.add_mob_blood(H)
						H.update_inv_w_socks()
					if(H.w_shirt)
						H.w_underwear.add_mob_blood(H)
						H.update_inv_w_shirt()
					//

				if(bloody)
					if(H.wear_suit)
						H.wear_suit.add_mob_blood(H)
						H.update_inv_wear_suit()
					if(H.w_uniform)
						H.w_uniform.add_mob_blood(H)
						H.update_inv_w_uniform()
	return TRUE

/datum/species/proc/alt_spec_attack_hand(mob/living/carbon/human/M, mob/living/carbon/human/H, datum/martial_art/attacker_style)
	if(!istype(M))
		return TRUE
	CHECK_DNA_AND_SPECIES(M)
	CHECK_DNA_AND_SPECIES(H)

	if(!istype(M)) //sanity check for drones.
		return TRUE
	if(M.mind)
		attacker_style = M.mind.martial_art
	switch(M.a_intent)
		if(INTENT_HELP)
			if(M == H)
				althelp(M, H, attacker_style)
				return TRUE
			return FALSE
	return FALSE

/datum/species/proc/althelp(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(user == target && istype(user))
		if(IS_STAMCRIT(user))
			to_chat(user, "<span class='warning'>I'm too exhausted for that!</span>")
			return
		if(user.IsKnockdown() || user.IsParalyzed() || user.IsStun())
			to_chat(user, "<span class='warning'>I can't seem to force myself up right now!</span>")
			return
		if(CHECK_MOBILITY(user, MOBILITY_STAND))
			return
		user.visible_message("<span class='notice'><b>[user]</b> forces [p_them()]self up to [p_their()] feet!</span>", "<span class='notice'>I force myself up to your feet!</span>")
		user.set_resting(FALSE, TRUE)
		user.adjustStaminaLossBuffered(user.stambuffer) //Rewards good stamina management by making it easier to instantly get up from resting
		playsound(user, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/datum/species/proc/altdisarm(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	if(IS_STAMCRIT(user))
		to_chat(user, "<span class='warning'>I'm too exhausted!</span>")
		return FALSE
	if(target.check_martial_melee_block())
		target.visible_message("<span class='warning'><b>[target]</b> blocks <b>[user]</b>'s shoving attempt!</span>", \
			"<span class='warning'>I block <b>[user]</b>'s shoving attempt!</span>", target = user, \
			target_message = "<span class='warning'><b>[target]</b> blocks my shoving attempt!</span>")
		return FALSE

	if(target.mind?.handle_parry(target, null, 0, user))
		playsound(get_turf(target), 'modular_skyrat/sound/attack/parry.ogg', 70)
		var/held_item
		if(target.get_active_held_item())
			held_item = " with [target.p_their()] [target.get_active_held_item()]"
		else
			held_item = " with [target.p_their()] bare hands"
		target.visible_message("<span class='danger'><b>[target]</b> blocks <b>[user]</b>[held_item]!</span>")
		return 0

	if(target.mind?.handle_dodge(target, null, 0, user))
		//Make the victim step to an adjacent tile because ooooooh dodge
		var/list/turf/dodge_turfs = list()
		for(var/turf/open/O in range(1,target))
			if(target.CanReach(O))
				dodge_turfs += O
		//No available turfs == we can't actually dodge
		if(length(dodge_turfs))
			var/turf/yoink = pick(dodge_turfs)
			//We moved to the tile, therefore we parried successfully
			if(target.Move(yoink, get_dir(target, yoink)))
				playsound(get_turf(target), miss_sound, 70)
				target.visible_message("<span class='danger'><b>[target]</b> dodges <b>[user]</b>!</span>")
				return 0

	if(attacker_style && attacker_style.disarm_act(user,target))
		return TRUE
	if(!CHECK_MOBILITY(user, MOBILITY_STAND))
		return FALSE
	else
		if(user == target)
			return
		user.do_attack_animation(target, ATTACK_EFFECT_DISARM)
		user.adjustStaminaLossBuffered(4)
		playsound(target, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

		if(target.w_uniform)
			target.w_uniform.add_fingerprint(user)
		//skyrat edit
		else if(target.w_shirt)
			target.w_shirt.add_fingerprint(user)
		else if(target.w_socks)
			target.w_socks.add_fingerprint(user)
		else if(target.w_underwear)
			target.w_underwear.add_fingerprint(user)
		//
		SEND_SIGNAL(target, COMSIG_HUMAN_DISARM_HIT, user, user.zone_selected)

		if(CHECK_MOBILITY(target, MOBILITY_STAND))
			target.adjustStaminaLoss(5)

		if(target.is_shove_knockdown_blocked())
			return

		var/turf/target_oldturf = target.loc
		var/shove_dir = get_dir(user.loc, target_oldturf)
		var/turf/target_shove_turf = get_step(target.loc, shove_dir)
		var/mob/living/carbon/human/target_collateral_human
		var/shove_blocked = FALSE //Used to check if a shove is blocked so that if it is knockdown logic can be applied

		//Thank you based whoneedsspace
		target_collateral_human = locate(/mob/living/carbon/human) in target_shove_turf.contents
		if(target_collateral_human && CHECK_MOBILITY(target_collateral_human, MOBILITY_STAND))
			shove_blocked = TRUE
		else
			target_collateral_human = null
			target.Move(target_shove_turf, shove_dir)
			if(get_turf(target) == target_oldturf)
				shove_blocked = TRUE

		var/append_message = ""
		if(shove_blocked && !target.buckled)
			var/directional_blocked = !target.Adjacent(target_shove_turf)
			var/targetatrest = !CHECK_MOBILITY(target, MOBILITY_STAND)
			if((directional_blocked || !(target_collateral_human || target_shove_turf.shove_act(target, user))) && !targetatrest)
				target.DefaultCombatKnockdown(SHOVE_KNOCKDOWN_SOLID)
				target.visible_message("<span class='danger'><b>[user.name]</b> shoves <b>[target.name]</b>, knocking them down!</span>",
					"<span class='danger'><b>[user.name]</b> shoves me, knocking me down!</span>", null, COMBAT_MESSAGE_RANGE, null,
					user, "<span class='danger'>I shove <b>[target.name]</b>, knocking them down!</span>")
				log_combat(user, target, "shoved", "knocking them down")
			else if(target_collateral_human && !targetatrest)
				target.DefaultCombatKnockdown(SHOVE_KNOCKDOWN_HUMAN)
				target_collateral_human.DefaultCombatKnockdown(SHOVE_KNOCKDOWN_COLLATERAL)
				target.visible_message("<span class='danger'><b>[user.name]</b> shoves <b>[target.name]</b> into <b>[target_collateral_human.name]</b>!</span>",
					"<span class='danger'><b>[user.name]</b> shoves me into <b>[target_collateral_human.name]</b>!</span>", null, COMBAT_MESSAGE_RANGE, null,
					user, "<span class='danger'>I shove <b>[target.name]</b> into <b>[target_collateral_human.name]</b>!</span>")
				append_message += ", into <b>[target_collateral_human.name]</b>"

		else
			target.visible_message("<span class='danger'><b>[user.name]</b> shoves <b>[target.name]</b>!</span>",
				"<span class='danger'><b>[user.name]</b> shoves me!</span>", null, COMBAT_MESSAGE_RANGE, null,
				user, "<span class='danger'>I shove <b>[target.name]</b>!</span>")
		var/obj/item/target_held_item = target.get_active_held_item()
		if(!is_type_in_typecache(target_held_item, GLOB.shove_disarming_types))
			target_held_item = null
		if(!target.has_movespeed_modifier(/datum/movespeed_modifier/shove))
			target.add_movespeed_modifier(/datum/movespeed_modifier/shove)
			if(target_held_item)
				if(!HAS_TRAIT(target_held_item, TRAIT_NODROP))
					target.visible_message("<span class='danger'><b>[target.name]</b>'s grip on \the [target_held_item] loosens!</span>",
						"<span class='danger'>Your grip on \the [target_held_item] loosens!</span>", null, COMBAT_MESSAGE_RANGE)
					append_message += ", loosening their grip on [target_held_item]"
				else
					append_message += ", but couldn't loose their grip on [target_held_item]"
			addtimer(CALLBACK(target, /mob/living/carbon/human/proc/clear_shove_slowdown), SHOVE_SLOWDOWN_LENGTH)
		else if(target_held_item)
			if(target.dropItemToGround(target_held_item))
				target.visible_message("<span class='danger'><b>[target.name]</b> drops \the [target_held_item]!!</span>",
					"<span class='danger'>I drop \the [target_held_item]!!</span>", null, COMBAT_MESSAGE_RANGE)
				append_message += ", causing them to drop [target_held_item]"
		log_combat(user, target, "shoved", append_message)

/datum/species/proc/on_hit(obj/item/projectile/P, mob/living/carbon/human/H)
	// called when hit by a projectile
	switch(P.type)
		if(/obj/item/projectile/energy/floramut) // overwritten by plants/pods
			H.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")
		if(/obj/item/projectile/energy/florayield)
			H.show_message("<span class='notice'>The radiation beam dissipates harmlessly through your body.</span>")

/datum/species/proc/bullet_act(obj/item/projectile/P, mob/living/carbon/human/H)
	// called before a projectile hit
	return

/////////////
//BREATHING//
/////////////

/datum/species/proc/breathe(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		return TRUE

/datum/species/proc/handle_environment(datum/gas_mixture/environment, mob/living/carbon/human/H)
	if(!environment)
		return
	if(istype(H.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		return

	var/loc_temp = H.get_temperature(environment)

	//Body temperature is adjusted in two parts: first there your body tries to naturally preserve homeostasis (shivering/sweating), then it reacts to the surrounding environment
	//Thermal protection (insulation) has mixed benefits in two situations (hot in hot places, cold in hot places)
	if(!H.on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		var/natural = 0
		if(H.stat != DEAD)
			natural = H.natural_bodytemperature_stabilization()
		var/thermal_protection = 1
		if(loc_temp < H.bodytemperature) //Place is colder than we are
			thermal_protection -= H.get_thermal_protection(loc_temp, TRUE) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(H.bodytemperature < BODYTEMP_NORMAL) //we're cold, insulation helps us retain body heat and will reduce the heat we lose to the environment
				H.adjust_bodytemperature((thermal_protection+1)*natural + max(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_COLD_DIVISOR, BODYTEMP_COOLING_MAX))
			else //we're sweating, insulation hinders our ability to reduce heat - and it will reduce the amount of cooling you get from the environment
				H.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + max((thermal_protection * (loc_temp - H.bodytemperature) + BODYTEMP_NORMAL - H.bodytemperature) / BODYTEMP_COLD_DIVISOR , BODYTEMP_COOLING_MAX)) //Extra calculation for hardsuits to bleed off heat
		else //Place is hotter than we are
			thermal_protection -= H.get_thermal_protection(loc_temp) //This returns a 0 - 1 value, which corresponds to the percentage of protection based on what you're wearing and what you're exposed to.
			if(H.bodytemperature < BODYTEMP_NORMAL) //and we're cold, insulation enhances our ability to retain body heat but reduces the heat we get from the environment
				H.adjust_bodytemperature((thermal_protection+1)*natural + min(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))
			else //we're sweating, insulation hinders out ability to reduce heat - but will reduce the amount of heat we get from the environment
				H.adjust_bodytemperature(natural*(1/(thermal_protection+1)) + min(thermal_protection * (loc_temp - H.bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))
		switch((loc_temp - H.bodytemperature)*thermal_protection)
			if(-INFINITY to -50)
				H.throw_alert("temp", /obj/screen/alert/cold, 3)
			if(-50 to -35)
				H.throw_alert("temp", /obj/screen/alert/cold, 2)
			if(-35 to -20)
				H.throw_alert("temp", /obj/screen/alert/cold, 1)
			if(-20 to 0) //This is the sweet spot where air is considered normal
				H.clear_alert("temp")
			if(0 to 15) //When the air around you matches your body's temperature, you'll start to feel warm.
				H.throw_alert("temp", /obj/screen/alert/hot, 1)
			if(15 to 30)
				H.throw_alert("temp", /obj/screen/alert/hot, 2)
			if(30 to INFINITY)
				H.throw_alert("temp", /obj/screen/alert/hot, 3)

	// +/- 50 degrees from 310K is the 'safe' zone, where no damage is dealt.
	if(H.bodytemperature > BODYTEMP_HEAT_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTHEAT))
		//Body temperature is too hot.

		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "hot", /datum/mood_event/hot)

		H.remove_movespeed_modifier(/datum/movespeed_modifier/cold)

		var/burn_damage
		var/firemodifier = H.fire_stacks / 50
		if (H.on_fire)
			burn_damage = max(log(2-firemodifier,(H.bodytemperature-BODYTEMP_NORMAL))-5,0)
		else
			firemodifier = min(firemodifier, 0)
			burn_damage = max(log(2-firemodifier,(H.bodytemperature-BODYTEMP_NORMAL))-5,0) // this can go below 5 at log 2.5
		burn_damage = burn_damage * heatmod * H.physiology.heat_mod
		if (H.stat < UNCONSCIOUS && (prob(burn_damage) * 5) / 4) //40% for level 3 damage on humans
			H.emote("agonyscream")
		var/obj/item/bodypart/BP
		if(length(H.bodyparts) && prob(SPECIFY_BODYPART_BURN_PROB))
			BP = pick(H.bodyparts)
		if(!HAS_TRAIT(H, TRAIT_NOTEMPERATUREWOUNDING))
			H.apply_damage(damage = burn_damage, damagetype = BURN, def_zone = BP)

	else if(H.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT && !HAS_TRAIT(H, TRAIT_RESISTCOLD))
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "hot")
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "cold", /datum/mood_event/cold)
		//Apply cold slowdown
		H.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/cold, multiplicative_slowdown = ((BODYTEMP_COLD_DAMAGE_LIMIT - H.bodytemperature) / COLD_SLOWDOWN_FACTOR))
		var/obj/item/bodypart/BP
		if(length(H.bodyparts) && prob(SPECIFY_BODYPART_BURN_PROB))
			BP = pick(H.bodyparts)
		if(!HAS_TRAIT(H, TRAIT_NOTEMPERATUREWOUNDING))
			switch(H.bodytemperature)
				if(200 to BODYTEMP_COLD_DAMAGE_LIMIT)
					H.apply_damage(damage = COLD_DAMAGE_LEVEL_1*coldmod*H.physiology.cold_mod, damagetype = BURN, def_zone = BP)
				if(120 to 200)
					H.apply_damage(damage = COLD_DAMAGE_LEVEL_2*coldmod*H.physiology.cold_mod, damagetype = BURN, def_zone = BP)
				else
					H.apply_damage(damage = COLD_DAMAGE_LEVEL_3*coldmod*H.physiology.cold_mod, damagetype = BURN, def_zone = BP)
	else
		H.remove_movespeed_modifier(/datum/movespeed_modifier/cold)
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "cold")
		SEND_SIGNAL(H, COMSIG_CLEAR_MOOD_EVENT, "hot")

	var/pressure = environment.return_pressure()
	var/adjusted_pressure = H.calculate_affecting_pressure(pressure) //Returns how much pressure actually affects the mob.
	switch(adjusted_pressure)
		if(HAZARD_HIGH_PRESSURE to INFINITY)
			if(!HAS_TRAIT(H, TRAIT_RESISTHIGHPRESSURE))
				H.throw_alert("pressure", /obj/screen/alert/highpressure, 2)
				var/applydam = (min(((adjusted_pressure / HAZARD_HIGH_PRESSURE) -1 ) * PRESSURE_DAMAGE_COEFFICIENT, MAX_HIGH_PRESSURE_DAMAGE) * H.physiology.pressure_mod)
				H.apply_damage(damage = applydam, damagetype = BRUTE, wound_bonus = CANT_WOUND)
			else
				H.clear_alert("pressure")
		if(WARNING_HIGH_PRESSURE to HAZARD_HIGH_PRESSURE)
			H.throw_alert("pressure", /obj/screen/alert/highpressure, 1)
		if(WARNING_LOW_PRESSURE to WARNING_HIGH_PRESSURE)
			H.clear_alert("pressure")
		if(HAZARD_LOW_PRESSURE to WARNING_LOW_PRESSURE)
			H.throw_alert("pressure", /obj/screen/alert/lowpressure, 1)
		else
			if(HAS_TRAIT(H, TRAIT_RESISTLOWPRESSURE))
				H.clear_alert("pressure")
			else
				H.throw_alert("pressure", /obj/screen/alert/lowpressure, 2)
				var/applydam = LOW_PRESSURE_DAMAGE * H.physiology.pressure_mod
				H.apply_damage(damage = applydam, damagetype = BRUTE, wound_bonus = CANT_WOUND)

//////////
// FIRE //
//////////

/datum/species/proc/handle_fire(mob/living/carbon/human/H, no_protection = FALSE)
	if(HAS_TRAIT(H, TRAIT_NOFIRE))
		return
	if(H.on_fire)
		//the fire tries to damage the exposed clothes and items
		var/list/burning_items = list()
		//HEAD//
		var/obj/item/clothing/head_clothes = null
		if(H.glasses)
			head_clothes = H.glasses
		if(H.wear_mask)
			head_clothes = H.wear_mask
		if(H.wear_neck)
			head_clothes = H.wear_neck
		if(H.head)
			head_clothes = H.head
		if(head_clothes)
			burning_items += head_clothes
		else if(H.ears)
			burning_items += H.ears

		//CHEST//
		var/obj/item/clothing/chest_clothes = null
		//skyrat edit
		if(H.w_underwear && (H.w_underwear.body_parts_covered & CHEST))
			chest_clothes = H.w_underwear
		if(H.w_socks && (H.w_socks.body_parts_covered & CHEST))
			chest_clothes = H.w_socks
		if(H.w_shirt && (H.w_shirt.body_parts_covered & CHEST))
			chest_clothes = H.w_shirt
		//
		if(H.w_uniform)
			chest_clothes = H.w_uniform
		if(H.wear_suit)
			chest_clothes = H.wear_suit

		if(chest_clothes)
			burning_items += chest_clothes

		//ARMS & HANDS//
		var/obj/item/clothing/arm_clothes = null
		//skyrat edit
		if(H.wrists)
			arm_clothes = H.wrists
		if(H.w_underwear && (H.w_underwear.body_parts_covered & ARMS))
			arm_clothes = H.w_underwear
		if(H.w_socks && (H.w_socks.body_parts_covered & ARMS))
			arm_clothes = H.w_socks
		if(H.w_shirt && (H.w_shirt.body_parts_covered & ARMS))
			arm_clothes = H.w_shirt
		//
		if(H.gloves)
			arm_clothes = H.gloves
		if(H.w_uniform && ((H.w_uniform.body_parts_covered & HANDS) || (H.w_uniform.body_parts_covered & ARMS)))
			arm_clothes = H.w_uniform
		if(H.wear_suit && ((H.wear_suit.body_parts_covered & HANDS) || (H.wear_suit.body_parts_covered & ARMS)))
			arm_clothes = H.wear_suit
		if(arm_clothes)
			burning_items |= arm_clothes

		//LEGS & FEET//
		var/obj/item/clothing/leg_clothes = null
		//skyrat edit
		if(H.w_underwear && (H.w_underwear.body_parts_covered & LEGS))
			leg_clothes = H.w_underwear
		if(H.w_socks && (H.w_socks.body_parts_covered & LEGS))
			leg_clothes = H.w_socks
		if(H.w_shirt && (H.w_shirt.body_parts_covered & LEGS))
			leg_clothes = H.w_shirt
		//
		if(H.shoes)
			leg_clothes = H.shoes
		if(H.w_uniform && ((H.w_uniform.body_parts_covered & FEET) || (H.w_uniform.body_parts_covered & LEGS)))
			leg_clothes = H.w_uniform
		if(H.wear_suit && ((H.wear_suit.body_parts_covered & FEET) || (H.wear_suit.body_parts_covered & LEGS)))
			leg_clothes = H.wear_suit
		if(leg_clothes)
			burning_items |= leg_clothes

		for(var/X in burning_items)
			var/obj/item/I = X
			if(!(I.resistance_flags & FIRE_PROOF))
				I.take_damage(H.fire_stacks, BURN, "fire", 0)

		var/thermal_protection = H.easy_thermal_protection()

		if(thermal_protection >= FIRE_IMMUNITY_MAX_TEMP_PROTECT && !no_protection)
			return
		if(thermal_protection >= FIRE_SUIT_MAX_TEMP_PROTECT && !no_protection)
			H.adjust_bodytemperature(11)
		else
			H.adjust_bodytemperature(BODYTEMP_HEATING_MAX + (H.fire_stacks * 12))
			SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "on_fire", /datum/mood_event/on_fire)

/datum/species/proc/CanIgniteMob(mob/living/carbon/human/H)
	if(HAS_TRAIT(H, TRAIT_NOFIRE))
		return FALSE
	return TRUE

/datum/species/proc/ExtinguishMob(mob/living/carbon/human/H)
	return


////////////
////Stun////
////////////

/datum/species/proc/spec_stun(mob/living/carbon/human/H,amount)
	. = stunmod * H.physiology.stun_mod * amount

//////////////
//Space Move//
//////////////

/datum/species/proc/space_move(mob/living/carbon/human/H)
	return 0

/datum/species/proc/negates_gravity(mob/living/carbon/human/H)
	return 0

////////////////
//Tail Wagging//
////////////////

/datum/species/proc/can_wag_tail(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/is_wagging_tail(mob/living/carbon/human/H)
	return FALSE

/datum/species/proc/start_wagging_tail(mob/living/carbon/human/H)

/datum/species/proc/stop_wagging_tail(mob/living/carbon/human/H)

//skyrat edit

/**
  * The human species version of [/mob/living/carbon/proc/get_biological_state]. Depends on the HAS_FLESH and HAS_BONE species traits, having bones lets you have blunt wounds, having flesh lets you have burn, slash, and piercing wounds
  */
/datum/species/proc/get_biological_state()
	. = BIO_INORGANIC
	if(HAS_FLESH in species_traits)
		. |= BIO_FLESH
	if(HAS_BONE in species_traits)
		. |= BIO_BONE

#undef BURN_WOUND_ROLL_MULT
#undef SPECIFY_BODYPART_BURN_PROB

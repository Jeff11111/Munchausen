/datum/species/synth
	name = "Synthetic" //inherited from the real species, for health scanners and things
	id = "synth"
	say_mod = "beep boops" //inherited from a user's real species
	sexes = 0
	species_traits = list(NOTRANSSTING,NOGENITALS,NOAROUSAL,HAS_FLESH,HAS_BONE) //all of these + whatever we inherit from the real species
	inherent_traits = list(TRAIT_VIRUSIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOLIMBDISABLE,TRAIT_NOHYDRATION,TRAIT_NOBREATH,TRAIT_NOSHITTING,TRAIT_NOPISSING)
	inherent_biotypes = MOB_ROBOTIC|MOB_HUMANOID
	dangerous_existence = 1
	blacklisted = 1
	meat = null
	gib_types = /obj/effect/gibspawner/robot
	damage_overlay_type = "synth"
	limbs_id = "synth"
	var/list/initial_species_traits = list(NOTRANSSTING) //for getting these values back for assume_disguise()
	var/list/initial_inherent_traits = list(TRAIT_VIRUSIMMUNE,TRAIT_NODISMEMBER,TRAIT_NOLIMBDISABLE,TRAIT_NOHYDRATION,TRAIT_NOBREATH)
	var/disguise_fail_health = 75 //When their health gets to this level their synthflesh partially falls off
	var/datum/species/fake_species = null //a species to do most of our work for us, unless we're damaged
	languagewhitelist = list("Encoded Audio Language")
	bloodtypes = list("HF", "SY")
	bloodreagents = list("Synthetic Blood", "Oil")
	rainbowblood = TRUE
	exotic_bloodtype = "SY"
	exotic_blood_color = BLOOD_COLOR_SYNTHETIC
	species_language_holder = /datum/language_holder/synthetic

/datum/species/synth/military
	name = "Military Synth"
	id = "military_synth"
	armor = 25
	punchdamagelow = 10
	punchdamagehigh = 19
	punchstunthreshold = 14
	disguise_fail_health = 50

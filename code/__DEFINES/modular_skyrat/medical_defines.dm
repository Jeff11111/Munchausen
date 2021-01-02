//Painkillers
#define PAINKILLER_MINERSSALVE	"PAINKILLER - MINERS SALVE"
#define PAINKILLER_MORPHINE 	"PAINKILLER - MORPHINE"

//Wound stuff
#define WOUND_DAMAGE_EXPONENT	1.4

#define WOUND_MINIMUM_DAMAGE		5 // an attack must do this much damage after armor in order to roll for being a wound (incremental pressure damage need not apply)
#define WOUND_MAX_CONSIDERED_DAMAGE	35 // any damage dealt over this is ignored for damage rolls unless the target has the frail quirk (35^1.4=145)
#define DISMEMBER_MINIMUM_DAMAGE	10 // an attack must do this much damage after armor in order to be eliigible to dismember a suitably mushed bodypart
#define DISEMBOWEL_MINIMUM_DAMAGE	18 // an attack must do this much damage after armor in order to be eliigible to disembowel a suitably mushed bodypart
#define ARTERY_MINIMUM_DAMAGE		12 // an attack must do this much damage after armor to roll for artery wounds
#define TENDON_MINIMUM_DAMAGE		12 // ditto but for tendon wounds

#define WOUND_SEVERITY_NONE		0
#define WOUND_SEVERITY_TRIVIAL	1 // for jokey/memey wounds like stubbed toe, no standard messages/sounds or second winds
#define WOUND_SEVERITY_MODERATE	2
#define WOUND_SEVERITY_SEVERE	3
#define WOUND_SEVERITY_CRITICAL	4
#define WOUND_SEVERITY_LOSS		5 // theoretical total limb loss, like dismemberment for cuts
#define WOUND_SEVERITY_PERMANENT 6 // for wounds, severe or not, that cannot be removed via normal means (e.g just amputate the limb affected)

#define WOUND_NONE 0 // doesn't actually wound
#define WOUND_BLUNT 1 // any brute weapon/attack that doesn't have sharpness. rolls for blunt bone wounds
#define WOUND_SLASH 2 // any brute weapon/attack with sharpness = SHARP_EDGED. rolls for slash wounds
#define WOUND_PIERCE 3 // any brute weapon/attack with sharpness = SHARP_POINTY. rolls for piercing wounds
#define WOUND_ARTERY 4 // any sharp weapon, edged or pointy, can cause arteries to be torn
#define WOUND_TENDON 5 // any sharp weapon, edged or pointy, can cause tendons to be torn
#define WOUND_BURN	6 // any kind of burning attack rolls for burning wounds

// How much determination reagent to add each time someone gains a new wound in [/datum/wound/proc/second_wind()]
#define WOUND_DETERMINATION_MODERATE	2
#define WOUND_DETERMINATION_SEVERE		5
#define WOUND_DETERMINATION_CRITICAL	7.5
#define WOUND_DETERMINATION_LOSS		10
#define WOUND_DETERMINATION_PERMANENT	10

#define WOUND_DETERMINATION_MAX			10 // the max amount of determination you can have

// Set wound_bonus on an item or attack to this to disable checking wounding for the attack
#define CANT_WOUND -100

// List in order of highest severity to lowest (if the wound is rolled for normally - there are edge cases)
#define WOUND_LIST_BLUNT		list(/datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/moderate/jaw, /datum/wound/blunt/moderate/ribcage, /datum/wound/blunt/moderate/hips, /datum/wound/blunt/moderate)
#define WOUND_LIST_BLUNT_MECHANICAL list(/datum/wound/mechanical/blunt/critical, /datum/wound/mechanical/blunt/severe, /datum/wound/mechanical/blunt/moderate)
#define WOUND_LIST_TENDON	list(/datum/wound/tendon)
#define WOUND_LIST_ARTERY	list(/datum/wound/artery)

// Thresholds for infection for wounds, once infestation hits each threshold, things get steadily worse
#define WOUND_INFECTION_MODERATE	250 // below this has no ill effects from germs
#define WOUND_INFECTION_SEVERE		330 // then below here, you ooze some pus and suffer minor tox damage, but nothing serious
#define WOUND_INFECTION_CRITICAL	600 // then below here, your limb occasionally locks up from damage and infection and briefly becomes disabled. Things are getting really bad
#define WOUND_INFECTION_SEPTIC		1000 // below here, your skin is almost entirely falling off and your limb locks up more frequently. You are within a stone's throw of septic paralysis and losing the limb
// Above WOUND_INFECTION_SEPTIC, your limb is completely putrid and you start rolling to lose the entire limb by way of paralyzation. After 3 failed rolls (~4-5% each probably), the limb is paralyzed

#define WOUND_BONE_HEAD_TIME_VARIANCE 	20 // if we suffer a bone wound to the head that creates brain traumas, the timer for the trauma cycle is +/- by this percent (0-100)

// General dismemberment now requires 3 things for a limb to be dismemberable:
//	1. Skin is mangled: At least a moderate slash or pierce wound
// 	2. Muscle is mangled: A critical slash or pierce wound
// 	3. Bone is mangled: At least a severe bone wound on that limb
// see [/obj/item/bodypart/proc/get_mangled_state()] for more information
#define BODYPART_MANGLED_NONE	0
#define BODYPART_MANGLED_MUSCLE (1<<0)
#define BODYPART_MANGLED_BONE	(1<<1)
#define BODYPART_MANGLED_BOTH 	(BODYPART_MANGLED_MUSCLE | BODYPART_MANGLED_BONE)

// What kind of biology we have, and what wounds we can suffer, mostly relies on the HAS_FLESH and HAS_BONE species traits on human species
#define BIO_INORGANIC	0 // golems, cannot suffer any wounds
#define BIO_BONE	(1<<0) // skeletons and plasmemes, can only suffer bone wounds, only needs mangled bone to be able to dismember
#define BIO_FLESH	(1<<1) // slimepeople can only suffer slashing, piercing, and burn wounds
#define BIO_FULL	(BIO_BONE | BIO_FLESH) // standard humanoids, can suffer all wounds, needs mangled bone and flesh to dismember

//Wound flags
#define WOUND_MANGLES_SKIN (1<<0)
#define WOUND_MANGLES_MUSCLE (1<<1)
#define WOUND_MANGLES_BONE (1<<2)
#define WOUND_VISIBLE_THROUGH_CLOTHING (1<<3)
#define WOUND_SEEPS_GAUZE (1<<5)
#define WOUND_ACCEPTS_STUMP (1<<6)
#define WOUND_SOUND_HINTS (1<<7)

//Injury flags
#define INJURY_SOUND_HINTS (1<<0)
#define INJURY_BANDAGED (1<<1)
#define INJURY_CLAMPED (1<<2)
#define INJURY_SALVED (1<<3)
#define INJURY_DISINFECTED (1<<4)
#define INJURY_SURGICAL (1<<5)
#define INJURY_RETRACTED_SKIN (1<<6)
#define INJURY_DRILLED (1<<7)
#define INJURY_SET_BONES (1<<8)

//Organ status flags
#define ORGAN_ORGANIC   (1<<0)
#define ORGAN_ROBOTIC   (1<<1)

//Flags for the organ_flags var on /obj/item/organ
#define ORGAN_SYNTHETIC			(1<<0)	//Synthetic organs, or cybernetic organs. Reacts to EMPs and don't deteriorate or heal
#define ORGAN_FROZEN			(1<<1)	//Frozen organs, don't deteriorate
#define ORGAN_FAILING			(1<<2)	//Failing organs perform damaging effects until replaced or fixed
#define ORGAN_DEAD				(1<<3)  //Not only is the organ failing, it is completely septic and spreading it around
#define ORGAN_EXTERNAL			(1<<4)	//Was this organ implanted/inserted/etc, if true will not be removed during species change.
#define ORGAN_VITAL				(1<<5)	//Currently only the brain
#define ORGAN_NO_SPOIL			(1<<6)	//Do not spoil under any circumstances
#define ORGAN_NO_DISMEMBERMENT	(1<<7)	//Immune to disembowelment.
#define ORGAN_EDIBLE			(1<<8)	//is a snack? :D
#define ORGAN_CUT_AWAY			(1<<9)	//Required for ogan manipulation

//Bodypart status flags
#define BODYPART_ORGANIC	(1<<0)
#define BODYPART_ROBOTIC	(1<<1)
#define BODYPART_SYNTHETIC	(1<<2)

//Flags for the limb_flags var on /obj/item/bodypart
#define	BODYPART_VITAL		(1<<0) //Kills the owner if destroyed or dismembered
#define	BODYPART_HEALS_OVERKILL	(1<<1) //Heals bad injuries on it's own
#define	BODYPART_CAN_STUMP	(1<<2) //Leaves a stump behind when violently severed
#define BODYPART_DEAD		(1<<3) //Completely septic and unusable limb
#define BODYPART_CUT_AWAY	(1<<4) //Just got reattached but needs to be sewn back on to organ
#define BODYPART_FROZEN		(1<<5) //Cold, doesn't rot
#define BODYPART_NOBLEED	(1<<6) //Does not bleed
#define BODYPART_NOEMBED	(1<<7) //Does not suffer with embedding
#define BODYPART_NOPAIN 	(1<<8) //Does not feel pain

//Bodypart disabling defines
#define BODYPART_NOT_DISABLED 0
#define BODYPART_DISABLED_DAMAGE 1
#define BODYPART_DISABLED_WOUND 2
#define BODYPART_DISABLED_PAIN 3
#define BODYPART_DISABLED_PARALYSIS 4
#define BODYPART_DISABLED_DEAD 5
#define BODYPART_DISABLED_SEVERED 5

//Maximum number of brain traumas wounds to the head can cause
#define TRAUMA_LIMIT_WOUND 2

//Bodypart defines
#define ALL_BODYPARTS_MINUS_EYES list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, \
					BODY_ZONE_PRECISE_NECK, \
					BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, \
					BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, \
					BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, \
					BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, \
					BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
#define ALL_BODYPARTS_MINUS_EYES_AND_JAW list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK, \
					BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, \
					BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, \
					BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, \
					BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, \
					BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
#define ALL_BODYPARTS list(BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE, \
					BODY_ZONE_PRECISE_MOUTH, \
					BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK, \
					BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, \
					BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, \
					BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, \
					BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, \
					BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
#define ALL_BODYPARTS_ORDERED list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_NECK, \
					BODY_ZONE_PRECISE_GROIN, BODY_ZONE_HEAD, \
					BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE, \
					BODY_ZONE_PRECISE_MOUTH, \
					BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, \
					BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, \
					BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, \
					BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
#define TORSO_BODYPARTS list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)
#define AMPUTATE_BODYPARTS list(BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE, \
					BODY_ZONE_PRECISE_MOUTH, \
					BODY_ZONE_PRECISE_NECK, BODY_ZONE_R_ARM, \
					BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_GROIN, \
					BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, \
					BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, \
					BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
#define LIMB_AND_HEAD_BODYPARTS list(BODY_ZONE_PRECISE_LEFT_EYE, BODY_ZONE_PRECISE_RIGHT_EYE, \
					BODY_ZONE_PRECISE_MOUTH, \
					BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK, \
					BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, \
					BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_R_HAND, \
					BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_FOOT, \
					BODY_ZONE_PRECISE_L_FOOT)
#define LIMB_BODYPARTS list(BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, \
					BODY_ZONE_R_LEG, BODY_ZONE_L_LEG, \
					BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, \
					BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
#define EXTREMITY_BODYPARTS list(BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_PRECISE_L_HAND, \
					BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
#define HEAD_BODYPARTS list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_NECK, \
					BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_LEFT_EYE, \
					BODY_ZONE_PRECISE_RIGHT_EYE)
#define ORGAN_BODYPARTS list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)

#define SSPARTS	list(/obj/item/bodypart/chest, /obj/item/bodypart/groin, \
					/obj/item/bodypart/neck, /obj/item/bodypart/head, \
					/obj/item/bodypart/mouth, \
					/obj/item/bodypart/left_eye, /obj/item/bodypart/right_eye, \
					/obj/item/bodypart/r_arm, /obj/item/bodypart/r_hand, \
					/obj/item/bodypart/l_arm, /obj/item/bodypart/l_hand, \
					/obj/item/bodypart/r_leg, /obj/item/bodypart/r_foot, \
					/obj/item/bodypart/l_leg, /obj/item/bodypart/l_foot)

#define BODYPARTS_PATH list(/obj/item/bodypart/left_eye, /obj/item/bodypart/right_eye, \
						/obj/item/bodypart/mouth, \
						/obj/item/bodypart/head, /obj/item/bodypart/neck, \
						/obj/item/bodypart/chest, /obj/item/bodypart/groin, \
						/obj/item/bodypart/l_arm, /obj/item/bodypart/l_hand, \
						/obj/item/bodypart/r_arm, /obj/item/bodypart/r_hand,\
						/obj/item/bodypart/l_leg, /obj/item/bodypart/l_foot, \
						/obj/item/bodypart/r_leg, /obj/item/bodypart/r_foot)

#define ALIEN_BODYPARTS_PATH list(/obj/item/bodypart/left_eye/night_vision/alien, /obj/item/bodypart/right_eye/night_vision/alien, \
								/obj/item/bodypart/head/alien, \
								/obj/item/bodypart/mouth/alien, /obj/item/bodypart/neck/alien, \
								/obj/item/bodypart/chest/alien, /obj/item/bodypart/groin/alien, \
								/obj/item/bodypart/l_arm/alien, /obj/item/bodypart/l_hand/alien, \
								/obj/item/bodypart/r_arm/alien, /obj/item/bodypart/r_hand/alien, \
								/obj/item/bodypart/r_leg/alien, /obj/item/bodypart/r_foot/alien, \
								/obj/item/bodypart/l_leg/alien, /obj/item/bodypart/l_foot/alien)
#define DEVIL_BODYPARTS_PATH list(/obj/item/bodypart/left_eye/devil, /obj/item/bodypart/right_eye/devil, \
								/obj/item/bodypart/head/devil, \
								/obj/item/bodypart/mouth/devil, /obj/item/bodypart/neck/devil, \
								/obj/item/bodypart/chest/devil, /obj/item/bodypart/groin/devil, \
								/obj/item/bodypart/l_arm/devil, /obj/item/bodypart/l_hand/devil, \
								/obj/item/bodypart/r_arm/devil, /obj/item/bodypart/r_hand/devil, \
								/obj/item/bodypart/r_leg/devil, /obj/item/bodypart/r_foot/devil, \
								/obj/item/bodypart/l_leg/devil, /obj/item/bodypart/l_foot/devil)
#define MONKEY_BODYPARTS_PATH list(/obj/item/bodypart/left_eye/monkey, /obj/item/bodypart/right_eye/monkey, \
							/obj/item/bodypart/head/monkey, \
							/obj/item/bodypart/mouth/monkey, /obj/item/bodypart/neck/monkey, \
							/obj/item/bodypart/chest/monkey, /obj/item/bodypart/groin/monkey, \
							/obj/item/bodypart/l_arm/monkey, /obj/item/bodypart/l_hand/monkey, \
							/obj/item/bodypart/r_arm/monkey, /obj/item/bodypart/r_hand/monkey, \
							/obj/item/bodypart/l_leg/monkey, /obj/item/bodypart/l_foot/monkey, \
							/obj/item/bodypart/r_leg/monkey, /obj/item/bodypart/r_foot/monkey)
#define LARVA_BODYPARTS_PATH list(/obj/item/bodypart/left_eye/night_vision/alien, /obj/item/bodypart/right_eye/night_vision/alien, \
							/obj/item/bodypart/head/larva, \
							/obj/item/bodypart/mouth/larva, /obj/item/bodypart/neck/larva, \
							/obj/item/bodypart/chest/larva)

//Defines related to apparent consciousness, when you examine someone
#define LOOKS_CONSCIOUS	0
#define LOOKS_SLEEPY	1
#define LOOKS_UNCONSCIOUS 2
#define LOOKS_VERYUNCONSCIOUS 3
#define LOOKS_DEAD		4

//Pain-related defines
#define PAIN_EMOTE_MINIMUM 10
#define PAIN_LEVEL_1 0
#define PAIN_LEVEL_2 10
#define PAIN_LEVEL_3 40
#define PAIN_LEVEL_4 70

// Pulse levels, very simplified.
#define PULSE_NONE    0   // So !M.pulse checks would be possible.
#define PULSE_SLOW    1   // <60     bpm
#define PULSE_NORM    2   //  60-90  bpm
#define PULSE_FAST    3   //  90-120 bpm
#define PULSE_2FAST   4   // >120    bpm
#define PULSE_THREADY 5   // Occurs during hypovolemic shock
#define PULSE_MAX_BPM 250 // Highest, readable BPM by machines and humans.
#define GETPULSE_BASIC 0   // Less accurate. (hand, health analyzer, etc.)
#define GETPULSE_ADVANCED 1   // More accurate. (med scanner, sleeper, etc.)

// Shock defines
#define SHOCK_STAGE_1 10
#define SHOCK_STAGE_2 30
#define SHOCK_STAGE_3 40
#define SHOCK_STAGE_4 60
#define SHOCK_STAGE_5 80
#define SHOCK_STAGE_6 120
#define SHOCK_STAGE_7 150
#define SHOCK_STAGE_8 200

//Infection defines
#define GERM_LEVEL_AMBIENT  275 // Maximum germ level you can reach by standing still.
#define GERM_LEVEL_MOVE_CAP 300 // Maximum germ level you can reach by running around.

//Sanitization
#define MAXIMUM_GERM_LEVEL	1000
#define SANITIZATION_SPACE_CLEANER 100
#define SANITIZATION_ANTIBIOTIC 0.1 // CE_ANTIBIOTIC sanitization
#define SANITIZATION_LYING 2

#define INFECTION_LEVEL_ONE   250
#define INFECTION_LEVEL_TWO   500  // infections grow from ambient to two in ~5 minutes
#define INFECTION_LEVEL_THREE 1000 // infections grow from two to three in ~10 minutes

#define WOUND_INFECTION_SANITIZATION_RATE	10 // how quickly sanitization removes infestation and decays per tick
#define WOUND_SANITIZATION_PER_ANTIBIOTIC 1 // Sanitization for each point in the antibiotic chem effect
#define WOUND_SANITIZATION_STERILIZER	100 // How much sterilizer sanitizes a wound
#define WOUND_INFECTION_SEEP_RATE		0.15 // How much we seep gauze per life tick

//How much time it takes for a dead organ to recover
#define ORGAN_RECOVERY_THRESHOLD (5 MINUTES)

//How much toxin the liver can handle
#define LIVER_MAX_TOXIN 50
//How much toxin the kidneys can handle
#define KIDNEY_MAX_TOXIN 50

//Rejection levels
#define REJECTION_LEVEL_1 1
#define REJECTION_LEVEL_2 50
#define REJECTION_LEVEL_3 200
#define REJECTION_LEVEL_4 500

//Brain damage related defines
#define MINIMUM_DAMAGE_TRAUMA_ROLL 4 //We need to take at least this much brainloss gained at once to roll for traumas, any less it won't roll
#define DAMAGE_LOW_OXYGENATION 1 //Brainloss caused by low blood oxygenation
#define DAMAGE_LOWER_OXYGENATION 2 //Brainloss caused by lower than low blood oxygenation
#define DAMAGE_VERY_LOW_OXYGENATION 3 //The above but even worse

//Pain required to do endurancce rolls with negative effects
#define PAIN_GIVES_IN 60

//Above or equal to this amount of pain, can't use radios
#define PAIN_NO_RADIO PAIN_GIVES_IN * 2

//CPR types
#define MOUTH_CPR "m2m"
#define CHEST_CPR "cardio"

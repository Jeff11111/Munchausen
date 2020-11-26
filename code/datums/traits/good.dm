//predominantly positive traits
//this file is named weirdly so that positive traits are listed above negative ones
/datum/quirk/alcohol_tolerance
	name = "Alcohol Tolerance"
	desc = "I become drunk more slowly and suffer fewer drawbacks from alcohol."
	value = 1
	mob_trait = TRAIT_ALCOHOL_TOLERANCE
	gain_text = "<span class='notice'>I feel like i could drink a whole keg!</span>"
	lose_text = "<span class='danger'>I don't feel as resistant to alcohol anymore. Somehow.</span>"
	medical_record_text = "Patient demonstrates a high tolerance for alcohol."

/datum/quirk/apathetic
	name = "Apathetic"
	desc = "I just don't care as much as other people. That's nice to have in a place like this, I guess."
	value = 1
	mood_quirk = TRUE
	medical_record_text = "Patient was administered the Apathy Evaluation Scale but did not bother to complete it."

/datum/quirk/apathetic/add()
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(mood)
		mood.mood_modifier = 0.75

/datum/quirk/apathetic/remove()
	if(quirk_holder)
		var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
		if(mood)
			mood.mood_modifier = 1 //Change this once/if species get their own mood modifiers.

/datum/quirk/drunkhealing
	name = "Drunken Resilience"
	desc = "Nothing like a good drink to make me feel on top of the world. Whenever i'm drunk, i slowly recover from injuries."
	value = 2
	mob_trait = TRAIT_DRUNK_HEALING
	gain_text = "<span class='notice'>I feel like a drink would do me good.</span>"
	lose_text = "<span class='danger'>I no longer feel like drinking would ease my pain.</span>"
	medical_record_text = "Patient has unusually efficient liver metabolism and can slowly regenerate wounds by drinking alcoholic beverages."

/datum/quirk/empath
	name = "Empath"
	desc = "Whether it's a sixth sense or careful study of body language, it only takes you a quick glance at someone to understand how they feel."
	value = 2
	mob_trait = TRAIT_EMPATH
	gain_text = "<span class='notice'>You feel in tune with those around you.</span>"
	lose_text = "<span class='danger'>You feel isolated from others.</span>"
	medical_record_text = "Patient is highly perceptive of and sensitive to social cues, or may possibly have ESP. Further testing needed."
	medical_condition = FALSE

/datum/quirk/jolly
	name = "Jolly"
	desc = "You sometimes just feel happy, for no reason at all."
	value = 1
	mob_trait = TRAIT_JOLLY
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates constant euthymia irregular for environment. It's a bit much, to be honest."
	medical_condition = FALSE

/datum/quirk/jolly/on_process()
	if(prob(0.05))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "jolly", /datum/mood_event/jolly)

/datum/quirk/quick_step
	name = "Quick Step"
	desc = "I walk with determined strides, and out-pace most people when walking."
	value = 2
	mob_trait = TRAIT_SPEEDY_STEP
	gain_text = "<span class='notice'>I feel determined. No time to lose.</span>"
	lose_text = "<span class='danger'>I feel less determined. What's the rush?</span>"
	medical_record_text = "Patient scored highly on racewalking tests."
	medical_condition = FALSE

/datum/quirk/selfaware
	name = "Self-Aware"
	desc = "I know my body well, and can accurately assess the extent of my wounds."
	value = 2
	mob_trait = TRAIT_SELF_AWARE
	medical_record_text = "Patient demonstrates an uncanny knack for self-diagnosis."
	medical_condition = FALSE

/datum/quirk/skittish
	name = "Skittish"
	desc = "I can conceal yourself in danger. Middle-click a closed locker to jump into it, as long as you have access."
	value = 2
	mob_trait = TRAIT_SKITTISH
	medical_record_text = "Patient demonstrates a high aversion to danger and has described hiding in containers out of fear."
	medical_condition = FALSE

/datum/quirk/trandening
	name = "High Luminosity Eyes"
	desc = "When the next big fancy implant came out i bought one on impulse."
	value = 1
	gain_text = "<span class='notice'>I have to keep up with the next big thing!.</span>"
	lose_text = "<span class='danger'>High-tech gizmos are a scam...</span>"

/datum/quirk/trandening/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/autosurgeon/gloweyes/gloweyes = new(get_turf(H))
	H.equip_to_slot(gloweyes, SLOT_IN_BACKPACK)
	H.regenerate_icons()

/datum/quirk/bloodpressure
	name = "Polycythemia vera"
	desc = "I have a treated form of Polycythemia vera that increases the total blood volume inside of me as well as the rate of replenishment."
	value = 2 //I honeslty dunno if this is a good trait? I just means you use more of medbays blood and make janitors madder, but you also regen blood a lil faster.
	mob_trait = TRAIT_HIGH_BLOOD
	gain_text = "<span class='notice'>I feel full of blood!</span>"
	lose_text = "<span class='notice'>I feel like my blood pressure went down.</span>"
	medical_record_text = "Patient's blood tests report an abnormal concentration of red blood cells in their bloodstream."

/datum/quirk/bloodpressure/add()
	quirk_holder.blood_ratio = 1.2
	quirk_holder.blood_volume += 150

/datum/quirk/bloodpressure/remove()
	if(quirk_holder)
		quirk_holder.blood_ratio = 1

/datum/quirk/night_vision
	name = "Night Vision"
	desc = "I can see slightly more clearly in full darkness than most people."
	value = 1
	mob_trait = TRAIT_NIGHT_VISION
	gain_text = "<span class='notice'>The shadows seem a little less dark.</span>"
	lose_text = "<span class='danger'>Everything seems a little darker.</span>"

/datum/quirk/night_vision/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.update_sight()

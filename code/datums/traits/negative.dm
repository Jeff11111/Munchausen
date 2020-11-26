//predominantly negative traits
/datum/quirk/depression
	name = "Depression"
	desc = "I sometimes just hate life."
	mob_trait = TRAIT_DEPRESSION
	value = -1
	gain_text = "<span class='danger'>I start feeling depressed.</span>"
	lose_text = "<span class='notice'>I no longer feel depressed.</span>" //if only it were that easy!
	medical_record_text = "Patient has a severe mood disorder, causing them to experience acute episodes of depression."
	mood_quirk = TRUE

/datum/quirk/depression/on_process()
	if(prob(0.05))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)

/datum/quirk/family_heirloom
	name = "Family Heirloom"
	desc = "I am the current owner of an heirloom, passed down for generations. I have to keep it safe!"
	value = -1
	mood_quirk = TRUE
	medical_record_text = "Patient demonstrates an unnatural attachment to a family heirloom."
	var/obj/item/heirloom
	var/where

GLOBAL_LIST_EMPTY(family_heirlooms)
/* moved to modular_skyrat
/datum/quirk/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/heirloom_type
	switch(quirk_holder.mind.assigned_role)
		if("Clown")
			heirloom_type = pick(/obj/item/paint/anycolor, /obj/item/bikehorn/golden)
		if("Mime")
			heirloom_type = pick(/obj/item/paint/anycolor, /obj/item/toy/dummy)
		if("Cook")
			heirloom_type = /obj/item/kitchen/knife/scimitar
		if("Botanist")
			heirloom_type = pick(/obj/item/cultivator, /obj/item/reagent_containers/glass/bucket, /obj/item/storage/bag/plants, /obj/item/toy/plush/beeplushie)
		if("Medical Doctor")
			heirloom_type = /obj/item/healthanalyzer
		if("Paramedic")
			heirloom_type = /obj/item/lighter
		if("Station Engineer")
			heirloom_type = /obj/item/wirecutters/brass
		if("Atmospheric Technician")
			heirloom_type = /obj/item/extinguisher/mini/family
		if("Lawyer")
			heirloom_type = /obj/item/storage/briefcase/lawyer/family
		if("Janitor")
			heirloom_type = /obj/item/mop
		if("enforcer")
			heirloom_type = /obj/item/clothing/accessory/medal/silver/valor
		if("Scientist")
			heirloom_type = /obj/item/toy/plush/slimeplushie
		if("Assistant")
			heirloom_type = /obj/item/clothing/gloves/cut/family
		if("Chaplain")
			heirloom_type = /obj/item/camera/spooky/family
		if("Captain")
			heirloom_type = /obj/item/clothing/accessory/medal/gold/captain/family
	if(!heirloom_type)
		heirloom_type = pick(
		/obj/item/toy/cards/deck,
		/obj/item/lighter,
		/obj/item/dice/d20)
	heirloom = new heirloom_type(get_turf(quirk_holder))
	GLOB.family_heirlooms += heirloom
	var/list/slots = list(
		"in your left pocket" = SLOT_L_STORE,
		"in your right pocket" = SLOT_R_STORE,
		"in your backpack" = SLOT_IN_BACKPACK
	)
	where = H.equip_in_one_of_slots(heirloom, slots, FALSE) || "at your feet"
*/
/datum/quirk/family_heirloom/post_add()
	if(where == "in my backpack")
		var/mob/living/carbon/human/H = quirk_holder
		SEND_SIGNAL(H.back, COMSIG_TRY_STORAGE_SHOW, H)

	to_chat(quirk_holder, "<span class='boldnotice'>There is a precious family [heirloom.name] [where], passed down from generation to generation. I must keep it safe!</span>")
	var/list/family_name = splittext(quirk_holder.real_name, " ")
	heirloom.name = "\improper [family_name[family_name.len]] family [heirloom.name]"

/datum/quirk/family_heirloom/on_process()
	if(heirloom in quirk_holder.GetAllContents())
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom_missing")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom", /datum/mood_event/family_heirloom)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "family_heirloom")
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "family_heirloom_missing", /datum/mood_event/family_heirloom_missing)

/datum/quirk/family_heirloom/clone_data()
	return heirloom

/datum/quirk/family_heirloom/on_clone(data)
	heirloom = data

/datum/quirk/heavy_sleeper
	name = "Heavy Sleeper"
	desc = "I sleep like a rock! Whenever i am put to sleep, i sleep for a little bit longer."
	value = -1
	mob_trait = TRAIT_HEAVY_SLEEPER
	gain_text = "<span class='danger'>I feel sleepy.</span>"
	lose_text = "<span class='notice'>I feel awake again.</span>"
	medical_record_text = "Patient has abnormal sleep study results and is difficult to wake up."

/datum/quirk/nearsighted //t. errorage
	name = "Nearsighted"
	desc = "I are nearsighted without prescription glasses."
	value = -1
	gain_text = "<span class='danger'>Things far away from me start looking blurry.</span>"
	lose_text = "<span class='notice'>I start seeing faraway things normally again.</span>"
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."

/datum/quirk/nearsighted/add()
	quirk_holder.become_nearsighted(ROUNDSTART_TRAIT)

/datum/quirk/nyctophobia
	name = "Nyctophobia"
	desc = "As far as i can remember, i've always been afraid of the dark. While in the dark without a light source, i instinctually act careful, and constantly feel a sense of dread."
	value = -1
	medical_record_text = "Patient demonstrates an abnormal fear of the dark."

/datum/quirk/nyctophobia/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(H.dna.species.id in list("shadow", "nightmare"))
		return //we're tied with the dark, so we don't get scared of it; don't cleanse outright to avoid cheese
	var/turf/T = get_turf(quirk_holder)
	var/lums = T.get_lumcount()
	if(lums <= 0.2)
		if(quirk_holder.m_intent == MOVE_INTENT_RUN)
			to_chat(quirk_holder, "<span class='warning'>Easy, easy, take it slow... you're in the dark...</span>")
			quirk_holder.toggle_move_intent()
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "nyctophobia", /datum/mood_event/nyctophobia)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "nyctophobia")

/datum/quirk/lightless
	name = "Light Sensitivity"
	desc = "Bright lights irritate you. My eyes start to water, my skin feels itchy against the photon radiation, and my hair gets dry and frizzy."
	value = -1
	gain_text = "<span class='danger'>The safety of light feels off...</span>"
	lose_text = "<span class='notice'>Enlightening.</span>"
	medical_record_text = "Despite my warnings, the patient refuses turn on the lights, only to end up rolling down a full flight of stairs and into the cellar."

/datum/quirk/lightless/on_process()
	var/turf/T = get_turf(quirk_holder)
	var/lums = T.get_lumcount()
	if(lums >= 0.8)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "brightlight", /datum/mood_event/brightlight)
	else
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "brightlight")

/datum/quirk/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes me sick. So much so, in fact, that i can't hurt anyone."
	value = -2
	mob_trait = TRAIT_PACIFISM
	gain_text = "<span class='danger'>I feel repulsed by the thought of violence!</span>"
	lose_text = "<span class='notice'>I think i can defend myself again.</span>"
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."
	antag_removal_text = "My antagonistic nature has caused me to renounce my pacifism."

/datum/quirk/paraplegic
	name = "Paraplegic"
	desc = "My legs do not function. Nothing will ever fix this."
	value = -3
	mob_trait = TRAIT_PARA
	human_only = TRUE
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Patient has an untreatable impairment in motor function in the lower extremities."

/datum/quirk/paraplegic/add()
	var/datum/brain_trauma/severe/paralysis/paraplegic/T = new()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/paraplegic/on_spawn()
	if(quirk_holder.buckled) // Handle late joins being buckled to arrival shuttle chairs.
		quirk_holder.buckled.unbuckle_mob(quirk_holder)

	var/turf/T = get_turf(quirk_holder)
	var/obj/structure/chair/spawn_chair = locate() in T

	var/obj/vehicle/ridden/wheelchair/wheels = new(T)
	if(spawn_chair) // Makes spawning on the arrivals shuttle more consistent looking
		wheels.setDir(spawn_chair.dir)

	wheels.buckle_mob(quirk_holder)

	// During the spawning process, they may have dropped what they were holding, due to the paralysis
	// So put the things back in their hands.

	for(var/obj/item/I in T)
		if(I.fingerprintslast == quirk_holder.ckey)
			quirk_holder.put_in_hands(I)

/datum/quirk/poor_aim
	name = "Poor Aim"
	desc = "I am terrible with guns and can't line up a straight shot to save my life. Dual-wielding is right out."
	value = -1
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Patient possesses a strong tremor in both hands."

/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "I have a mental disorder that prevents me from being able to recognize faces at all."
	value = -1
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."

/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused me to lose one of my limbs. Because of this, i now have a prosthetic."
	value = -1
	var/slot_string = "limb"

/datum/quirk/prosthetic_limb/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/limb_slot
	if(HAS_TRAIT(H, TRAIT_PARA))//Prevent paraplegic legs being replaced
		limb_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	else
		limb_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/old_part = H.get_bodypart(limb_slot)
	var/obj/item/bodypart/prosthetic
	switch(limb_slot)
		if(BODY_ZONE_L_ARM)
			prosthetic = new/obj/item/bodypart/l_arm/robot/surplus(quirk_holder)
			slot_string = "left arm"
		if(BODY_ZONE_R_ARM)
			prosthetic = new/obj/item/bodypart/r_arm/robot/surplus(quirk_holder)
			slot_string = "right arm"
		if(BODY_ZONE_L_LEG)
			prosthetic = new/obj/item/bodypart/l_leg/robot/surplus(quirk_holder)
			slot_string = "left leg"
		if(BODY_ZONE_R_LEG)
			prosthetic = new/obj/item/bodypart/r_leg/robot/surplus(quirk_holder)
			slot_string = "right leg"
	prosthetic.replace_limb(H)
	qdel(old_part)
	H.regenerate_icons()

/datum/quirk/prosthetic_limb/post_add()
	to_chat(quirk_holder, "<span class='boldannounce'>My [slot_string] has been replaced with a surplus prosthetic. It is fragile and will easily come apart under duress. Additionally, \
	i need to use a welding tool and cables to repair it, instead of sutures and mesh.</span>")

/datum/quirk/insanity
	name = "Reality Dissociation Syndrome"
	desc = "I suffer from a severe disorder that causes very vivid hallucinations. Mindbreaker toxin can suppress its effects, and i am immune to mindbreaker's hallucinogenic properties."
	value = -2
	//no mob trait because it's handled uniquely
	gain_text = "<span class='userdanger'>...</span>"
	lose_text = "<span class='notice'>You feel in tune with the world again.</span>"
	medical_record_text = "Patient suffers from acute Reality Dissociation Syndrome and experiences vivid hallucinations."

/datum/quirk/insanity/on_process()
	if(quirk_holder.reagents.has_reagent(/datum/reagent/toxin/mindbreaker))
		quirk_holder.hallucination = 0
		return
	if(prob(2)) //we'll all be mad soon enough
		madness()

/datum/quirk/insanity/proc/madness()
	quirk_holder.hallucination += rand(10, 25)

/datum/quirk/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for me, and i often stutter or even lock up."
	value = -1
	gain_text = "<span class='danger'>I start worrying about what i'm saying.</span>"
	lose_text = "<span class='notice'>I feel easier about talking again.</span>" //if only it were that easy!
	medical_record_text = "Patient is usually anxious in social encounters and prefers to avoid them."
	var/dumb_thing = TRUE

/datum/quirk/social_anxiety/add()
	RegisterSignal(quirk_holder, COMSIG_MOB_EYECONTACT, .proc/eye_contact)
	RegisterSignal(quirk_holder, COMSIG_MOB_EXAMINATE, .proc/looks_at_floor)

/datum/quirk/social_anxiety/remove()
	UnregisterSignal(quirk_holder, list(COMSIG_MOB_EYECONTACT, COMSIG_MOB_EXAMINATE))

/datum/quirk/social_anxiety/on_process()
	var/nearby_people = 0
	if(HAS_TRAIT(quirk_holder, TRAIT_FEARLESS)) //Skyrat change
		return //Skyrat change
	for(var/mob/living/carbon/human/H in oview(3, quirk_holder))
		if(H.client)
			nearby_people++
	var/mob/living/carbon/human/H = quirk_holder
	if(prob(2 + nearby_people))
		H.stuttering = max(3, H.stuttering)
	else if(prob(min(3, nearby_people)) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(10, H.silent)
	else if(prob(0.5) && dumb_thing)
		to_chat(H, "<span class='userdanger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life
		if(prob(1))
			new/obj/item/reagent_containers/food/snacks/pastatomato(get_turf(H)) //now that's what I call spaghetti code

// small chance to make eye contact with inanimate objects/mindless mobs because of nerves
/datum/quirk/social_anxiety/proc/looks_at_floor(datum/source, atom/A)
	var/mob/living/mind_check = A
	if(prob(85) || (istype(mind_check) && mind_check.mind))
		return

	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, quirk_holder, "<span class='smallnotice'>You make eye contact with [A].</span>"), 3)

/datum/quirk/social_anxiety/proc/eye_contact(datum/source, mob/living/other_mob, triggering_examiner)
	if(prob(75))
		return
	var/msg
	if(triggering_examiner)
		msg = "I make eye contact with [other_mob], "
	else
		msg = "[other_mob] makes eye contact with you, "

	switch(rand(1,3))
		if(1)
			quirk_holder.Jitter(10)
			msg += "causing you to start fidgeting!"
		if(2)
			quirk_holder.stuttering = max(3, quirk_holder.stuttering)
			msg += "causing you to start stuttering!"
		if(3)
			quirk_holder.Stun(2 SECONDS)
			msg += "causing you to freeze up!"

	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "anxiety_eyecontact", /datum/mood_event/anxiety_eyecontact)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, quirk_holder, "<span class='userdanger'>[msg]</span>"), 3) // so the examine signal has time to fire and this will print after
	return COMSIG_BLOCK_EYECONTACT

/datum/mood_event/anxiety_eyecontact
	description = "<span class='warning'>Sometimes eye contact makes me so nervous...</span>\n"
	mood_change = -5
	timeout = 3 MINUTES

/datum/quirk/phobia
	name = "Phobia"
	desc = "I've had a traumatic past, one that has scarred you for life, and cripples you when dealing with your greatest fears."
	value = -2 // It can hardstun you. You can be a job that your phobia targets...
	gain_text = "<span class='danger'>I begin to tremble as an immeasurable fear grips your mind.</span>"
	lose_text = "<span class='notice'>My confidence wipes away the fear that had been plaguing me.</span>"
	medical_record_text = "Patient has an extreme or irrational fear and aversion to an undefined stimuli."
	var/datum/brain_trauma/mild/phobia/phobia

/datum/quirk/phobia/post_add()
	var/mob/living/carbon/human/H = quirk_holder
	phobia = new
	H.gain_trauma(phobia, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/phobia/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H?.cure_trauma_type(phobia, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/mute
	name = "Mute"
	desc = "Due to some accident or medical condition, i am completely unable to speak."
	value = -2 //HALP MAINTS
	gain_text = "<span class='danger'>I find myself unable to speak!</span>"
	lose_text = "<span class='notice'>I feel a growing strength in my vocal chords.</span>"
	medical_record_text = "Functionally mute, patient is unable to use their voice in any capacity."
	var/datum/brain_trauma/severe/mute/mute

/datum/quirk/mute/add()
	var/mob/living/carbon/human/H = quirk_holder
	mute = new
	H.gain_trauma(mute, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/mute/remove()
	var/mob/living/carbon/human/H = quirk_holder
	H?.cure_trauma_type(mute, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/unstable
	name = "Unstable"
	desc = "Due to past troubles, i am unable to recover your sanity if i lose it."
	value = -2
	mob_trait = TRAIT_UNSTABLE
	gain_text = "<span class='danger'>There's a lot on my mind right now.</span>"
	lose_text = "<span class='notice'>My mind finally feels calm.</span>"
	medical_record_text = "Patient's mind is in a vulnerable state, and cannot recover from traumatic events."

/datum/quirk/coldblooded
	name = "Cold-blooded"
	desc = "My body doesn't create its own internal heat, requiring external heat regulation."
	value = -2
	medical_record_text = "Patient is ectothermic."
	mob_trait = TRAIT_COLDBLOODED
	gain_text = "<span class='notice'>I feel cold-blooded.</span>"
	lose_text = "<span class='notice'>I feel more warm-blooded.</span>"

/datum/quirk/monophobia
	name = "Monophobia"
	desc = "I will become increasingly stressed when not in company of others, triggering panic reactions ranging from sickness to heart attacks."
	value = -3 // Might change it to 4.
	gain_text = "<span class='danger'>I feel really lonely...</span>"
	lose_text = "<span class='notice'>I feel like i could be safe on my own.</span>"
	medical_record_text = "Patient feels sick and distressed when not around other people, leading to potentially lethal levels of stress."

/datum/quirk/monophobia/post_add()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	H.gain_trauma(/datum/brain_trauma/severe/monophobia, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/monophobia/remove()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	H?.cure_trauma_type(/datum/brain_trauma/severe/monophobia, TRAUMA_RESILIENCE_ABSOLUTE)

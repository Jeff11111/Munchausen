//predominantly negative traits

//i hate my life
/datum/quirk/depression
	name = "Depression"
	desc = "I hate my life."
	mob_trait = TRAIT_DEPRESSION
	value = -1
	gain_text = "<span class='danger'>I start feeling depressed.</span>"
	lose_text = "<span class='notice'>I no longer feel depressed.</span>" //if only it were that easy!
	medical_record_text = "Patient has a severe mood disorder, causing them to experience acute episodes of depression."
	mood_quirk = TRUE

/datum/quirk/depression/on_process()
	if(prob(0.25))
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "depression", /datum/mood_event/depression)

//Heirloom
/datum/quirk/family_heirloom
	name = "Family Heirloom"
	desc = "I am the current owner of an heirloom, passed down for generations. I have to keep it safe!"
	value = -1
	mood_quirk = TRUE
	medical_condition = FALSE
	medical_record_text = "Patient demonstrates an unnatural attachment to a family heirloom."
	var/obj/item/heirloom
	var/where

GLOBAL_LIST_EMPTY(family_heirlooms)
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
			heirloom_type = /obj/item/healthanalyzer
		if("Station Engineer")
			heirloom_type = /obj/item/wirecutters/brass
		if("Atmospheric Technician")
			heirloom_type = /obj/item/extinguisher/mini/family
		if("Lawyer")
			heirloom_type = /obj/item/storage/briefcase/lawyer/family
		if("Brig Physician")
			heirloom_type = pick(/obj/item/clothing/neck/stethoscope, /obj/item/roller, /obj/item/book/manual/wiki/security_space_law)
		if("Prisoner")
			heirloom_type = /obj/item/pen/blue
		if("Janitor")
			heirloom_type = /obj/item/mop
		if("Enforcer")
			heirloom_type = /obj/item/clothing/accessory/medal/silver/valor
		if("Scientist")
			heirloom_type = /obj/item/toy/plush/slimeplushie
		if("Stowaway")
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
	if(is_species(H, /datum/species/insect/moth) && prob(50))
		heirloom_type = /obj/item/flashlight/lantern/heirloom_moth
	heirloom = new heirloom_type(get_turf(quirk_holder))
	GLOB.family_heirlooms += heirloom
	RegisterSignal(heirloom, COMSIG_PARENT_QDELETING, .proc/deleting_heirloom)
	var/list/slots = list(
		"in my left pocket" = SLOT_L_STORE,
		"in my right pocket" = SLOT_R_STORE,
		"in my backpack" = SLOT_IN_BACKPACK
	)
	where = H.equip_in_one_of_slots(heirloom, slots, FALSE) || "at my feet"

/datum/quirk/family_heirloom/proc/deleting_heirloom()
	GLOB.family_heirlooms -= heirloom
	UnregisterSignal(heirloom, COMSIG_PARENT_QDELETING)
	heirloom = null

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

//Myopia
/datum/quirk/nearsighted
	name = "Nearsighted"
	desc = "I are nearsighted without prescription glasses."
	value = -1
	gain_text = "<span class='danger'>Things far away from me start looking blurry.</span>"
	lose_text = "<span class='notice'>I start seeing faraway things normally again.</span>"
	medical_record_text = "Patient requires prescription glasses in order to counteract nearsightedness."

/datum/quirk/nearsighted/add()
	quirk_holder.become_nearsighted(ROUNDSTART_TRAIT)

//Fear of the dark... fear of the dark...
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

//Fear of the light
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

//Bubba
/datum/quirk/poor_aim
	name = "Poor Aim"
	desc = "I am terrible with guns and can't line up a straight shot to save my life. Dual-wielding is right out."
	value = -1
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Patient possesses a strong tremor in both hands."

//Slender man lol
/datum/quirk/prosopagnosia
	name = "Prosopagnosia"
	desc = "I have a mental disorder that prevents me from being able to recognize faces at all."
	value = -1
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."

//Liveleak victim
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

//Blabla i'm crazy now
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

//Don't hug me, i'm scared
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

//Nigga throat
/datum/quirk/mute
	name = "Mute"
	desc = "My vocal cords have been damaged beyond relief. All of my speech is incomprehensible."
	value = -2 //HALP MAINTS
	gain_text = "<span class='danger'>I find myself unable to speak!</span>"
	lose_text = "<span class='notice'>I feel a growing strength in my vocal chords.</span>"
	medical_record_text = "Functionally mute, patient is unable to use their voice in any capacity."
	var/datum/speech_mod/torn_vocal_cords/gargles

/datum/quirk/mute/add()
	gargles = new
	gargles.add_speech_mod(quirk_holder)

/datum/quirk/mute/remove()
	QDEL_NULL(gargles)

//Bipolar nigga
/datum/quirk/unstable
	name = "Unstable"
	desc = "Due to past troubles, i am unable to recover your sanity if i lose it."
	value = -2
	mob_trait = TRAIT_UNSTABLE
	gain_text = "<span class='danger'>There's a lot on my mind right now.</span>"
	lose_text = "<span class='notice'>My mind finally feels calm.</span>"
	medical_record_text = "Patient's mind is in a vulnerable state, and cannot recover from traumatic events."

//Ligger faggot
/datum/quirk/coldblooded
	name = "Cold-blooded"
	desc = "My body doesn't create its own internal heat, requiring external heat regulation."
	value = -2
	medical_record_text = "Patient is ectothermic."
	mob_trait = TRAIT_COLDBLOODED
	gain_text = "<span class='notice'>I feel cold-blooded.</span>"
	lose_text = "<span class='notice'>I feel more warm-blooded.</span>"

//Clumsy
/datum/quirk/disaster_artist
	name = "Disaster Artist"
	desc = "<span class='warning'>I always manage to wreak havoc on everything I touch.</span>"
	value = -2
	mob_trait = TRAIT_CLUMSY
	medical_record_text = "Patient lacks proper spatial awareness."

//Can't see mood
/datum/quirk/screwy_mood
	name = "Alexithymia"
	desc = "<span class='warning'>I cannot accurately assess my feelings.</span>"
	value = -1
	mob_trait = TRAIT_SCREWY_MOOD
	medical_record_text = "Patient is incapable of communicating their emotions."

//Hemophilia
/datum/quirk/hemophiliac
	name = "Hemophiliac"
	desc = "<span class='warning'>My body is bad at coagulating blood. Bleeding will be twice as bad when compared to the average person.</span>"
	value = -3
	mob_trait = TRAIT_HEMOPHILIA
	medical_record_text = "Patient has abnormal blood coagulation behavior."

//Asthma
/datum/quirk/asthmatic
	name = "Asthmatic"
	desc = "<span class='warning'>I have been diagnosed with asthma. I can only run half of what a healthy person can, and running causes me to lose my breath.</span>"
	value = -2
	mob_trait = TRAIT_ASTHMATIC
	medical_record_text = "Patient is asthmatic."

//Frail
/datum/quirk/frail
	name = "Frail"
	desc = "<span class='warning'>My whole body is weak! I suffer wounds much more easily than most.</span>"
	value = -3
	mob_trait = TRAIT_EASYLIMBDISABLE
	gain_text = "<span class='danger'>You feel frail.</span>"
	lose_text = "<span class='notice'>You feel sturdy again.</span>"
	medical_record_text = "Patient's body is fragile, and tends to suffer more damage from all sources."

//Xavleg
/datum/quirk/xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx
	name = "Xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx"
	desc = "<span class='warning'>This is my name.</span>"
	medical_condition = FALSE

/datum/quirk/xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx/add()
	. = ..()
	quirk_holder.fully_replace_character_name(quirk_holder.real_name, "Xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx")

//Poore
/datum/quirk/endebted
	name = "Endebted"
	desc = "<span class='warning'>I owe corporate a lot of money. They took everything out of my account.</span>"
	medical_condition = FALSE

/datum/quirk/endebted/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/card/id/id = H.get_idcard()
	if(id)
		var/datum/bank_account/B = id.registered_account
		B.adjust_money(-B.account_balance)

//Hunted
/datum/quirk/hunted
	name = "Hunted"
	desc = "<span class='warning'>I have a secret enemy, I dread that I will know who they are soon...</span>"
	medical_condition = FALSE

/datum/quirk/hunted/on_spawn()
	. = ..()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list - quirk_holder))
		if((ROLE_TRAITOR in H.client?.prefs?.be_special) && (H.client?.prefs?.toggles & MIDROUND_ANTAG))
			var/datum/antagonist/traitor/bounty_hunter = H.mind.add_antag_datum(/datum/antagonist/traitor)
			for(var/datum/objective/O in bounty_hunter.objectives)
				qdel(O)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = H.mind
			kill_objective.target = quirk_holder.mind
			bounty_hunter.add_objective(kill_objective)
			H.mind.announce_objectives()
			break

//Do not revive
/datum/quirk/dnr
	name = "Do Not Revive"
	desc = "<span class='warning'>I cannot be revived in any way, this is my only shot at life.</span>"
	value = -2
	gain_text = "<span class='notice'>Your spirit gets too scarred to accept revival.</span>"
	lose_text = "<span class='notice'>You can feel your soul healing again.</span>"
	mob_trait = TRAIT_DNR

//Fetal alcohol syndrome
/datum/quirk/fas
	name = "Fetal Alcohol Syndrome"
	desc = "<span class='warning'>I have fetal alcohol syndrome. My mother didn't care for me.</span>"

/datum/quirk/fas/on_spawn()
	. = ..()
	for(var/datum/stats/fuck in quirk_holder.mind.mob_stats)
		fuck.level = clamp(fuck.level - 2, MIN_STAT, MAX_STAT)

//British
/datum/quirk/british
	name = "British"
	desc = "<span class='warning'>The tea has completely rotted away my gums, and my teeth are gone.</span>"
	medical_condition = FALSE

/datum/quirk/british/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/bodypart/feefh = H.get_bodypart(BODY_ZONE_HEAD)
	QDEL_NULL(feefh.teeth_object)
	feefh.update_teeth()

//Anemia
/datum/quirk/anemic
	name = "Anemia Stricken"
	desc = "<span class='warning'>I am anemic, my body cannot produce enough blood and I am lethargic.</span>"
	lose_text = "<span class='info'>Oh good, I am no longer anemic.</span>"
	medical_record_text = "Patient is anemic."

/datum/quirk/anemic/on_process()
	var/mob/living/carbon/human/H = quirk_holder
	if(NOBLOOD in H.dna.species.species_traits)
		return
	else
		quirk_holder.blood_volume -= 0.1 //Was actual aids at 0.2 but now you're less robust too.

/datum/quirk/anemic/on_spawn()
	. = ..()
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	if(strength && endurance)
		strength.level = clamp(strength.level - 1, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level - 1, MIN_STAT, MAX_STAT)

/datum/quirk/anemic/remove()
	. = ..()
	var/datum/stats/strength = GET_STAT(quirk_holder, str)
	var/datum/stats/endurance = GET_STAT(quirk_holder, end)
	if(strength && endurance)
		strength.level = clamp(strength.level + 1, MIN_STAT, MAX_STAT)
		endurance.level = clamp(endurance.level + 1, MIN_STAT, MAX_STAT)

//Bruno powroznik
/datum/quirk/libido
	name = "Nymphomania"
	desc = "I love sex."
	value = 0
	mob_trait = TRAIT_PERMABONER
	gain_text = "<span class='userlove'>You are feeling extra wild.</span>"
	lose_text = "<span class='purple'>You don't feel that burning sensation anymore.</span>"
	var/ineedsex = 0 //0-100
	var/needsex_increase = 0.01 //how much we increase our need for sex per on_process

/datum/quirk/libido/special_requirement_check(mob/living/carbon/human/imbecile)
	. = ..()
	if(!imbecile.has_penis() && !imbecile.has_vagina())
		return FALSE

/datum/quirk/libido/add()
	. = ..()
	RegisterSignal(quirk_holder, COMSIG_HUMAN_CUMMED, .proc/cummed)

/datum/quirk/libido/remove()
	. = ..()
	UnregisterSignal(quirk_holder, COMSIG_HUMAN_CUMMED)

/datum/quirk/libido/on_process()
	. = ..()
	if(quirk_holder.stat == CONSCIOUS)
		ineedsex = min(100, ineedsex + needsex_increase)
	if(ineedsex == 10)
		to_chat(quirk_holder, "<span class='userlove'>I can't stop thinking about hot single ladies in my area...</span>")
	else if(ineedsex == 25)
		if(quirk_holder.has_penis())
			to_chat(quirk_holder, "<span class='userlove'>My cock is THROBBING.</span>")
		else if(quirk_holder.has_vagina())
			to_chat(quirk_holder, "<span class='userlove'>My vagina is WET.</span>")
		else
			to_chat(quirk_holder, "<span class='userlove'>I am in HEAT.</span>")
	else if(ineedsex == 50)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "orgasm", /datum/mood_event/blueballs)
		to_chat(quirk_holder, "<span class='userlove'>I NEED TO CUM, JIZZ AND SPUNK.</span>")
	else if(ineedsex == 75)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "orgasm", /datum/mood_event/blueballs/bad)
		to_chat(quirk_holder, "<span class='userlove'>EARTHLY PLEASURES CONSUME ME.</span>")
	else if(ineedsex == 99)
		SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "orgasm", /datum/mood_event/blueballs/cbt)
		to_chat(quirk_holder, "<span class='userlove'>I AM GOING TO FUCKING RAPE A CREWMEMBER.</span>")

/datum/quirk/libido/proc/cummed(atom/target, obj/item/organ/genital/G, spill = TRUE)
	//We can only sate our lust by actually having sex...
	//However, masturbating does still give you a mood boost.
	if(target)
		ineedsex = 0
	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "orgasm", /datum/mood_event/orgasm/nympho)

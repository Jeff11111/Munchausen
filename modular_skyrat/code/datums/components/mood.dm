#define ECSTATIC_SANITY_PEN -1
#define SLIGHT_INSANITY_PEN 1
#define MINOR_INSANITY_PEN 5
#define MAJOR_INSANITY_PEN 10
#define MOOD_INSANITY_MALUS 0.13 // 13% debuff per sanity_level above the default of 4 (higher is worser), overall a 39% debuff to skills at rock bottom depression.

/datum/component/mood
	var/mood //Real happiness
	var/sanity = 100 //Current sanity
	var/shown_mood //Shown happiness, this is what others can see when they try to examine you, prevents antag checking by noticing traitors are always very happy.
	var/mood_level = 5 //To track what stage of moodies they're on
	var/sanity_level = 3 //To track what stage of sanity they're on
	var/mood_modifier = 1 //Modifier to allow certain mobs to be less affected by moodlets
	var/list/datum/mood_event/mood_events = list()
	var/insanity_effect = 0 //is the owner being punished for low mood? If so, how much?
	var/obj/screen/mood/screen_obj
	var/datum/skill_modifier/bad_mood/malus
	var/datum/skill_modifier/great_mood/bonus
	var/static/malus_id = 0
	var/static/list/free_maluses = list()
	var/static/list/insanity_sounds = list(
		'modular_skyrat/sound/sanity/ragdoll.ogg',
		'modular_skyrat/sound/sanity/inspectorj_foxcry.wav',
		'modular_skyrat/sound/sanity/synthscream1.wav',
		'modular_skyrat/sound/sanity/synthscream2.wav',
		'modular_skyrat/sound/sanity/deathbreath.ogg',
		'modular_skyrat/sound/sanity/seamonster.wav',
		'modular_skyrat/sound/sanity/wheniseechungus.wav',
	)

/datum/component/mood/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/owner = parent
	if(owner.stat != DEAD)
		START_PROCESSING(SSobj, src)

	RegisterSignal(parent, COMSIG_ADD_MOOD_EVENT, .proc/add_event)
	RegisterSignal(parent, COMSIG_CLEAR_MOOD_EVENT, .proc/clear_event)
	RegisterSignal(parent, COMSIG_MODIFY_SANITY, .proc/modify_sanity)
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, .proc/on_revive)
	RegisterSignal(parent, COMSIG_MOB_HUD_CREATED, .proc/modify_hud)
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/stop_processing)

	if(owner.hud_used)
		modify_hud()
		var/datum/hud/hud = owner.hud_used
		hud.show_hud(hud.hud_version)

/datum/component/mood/Destroy()
	STOP_PROCESSING(SSobj, src)
	unmodify_hud()
	return ..()

/datum/component/mood/proc/stop_processing()
	STOP_PROCESSING(SSobj, src)

/datum/component/mood/proc/get_left_signs_from_number(num)
	var/mood_signs = num
	var/mood_symbol = "<span class='green'><b>+</b></span>"
	if(mood_signs == 0)
		mood_symbol = ""
	else if(mood_signs < 0)
		mood_symbol = "<span class='red'><b>-</b></span>"
	mood_signs = abs(mood_signs)
	var/left_symbols = ""
	if(mood_signs && mood_symbol)
		mood_signs = CEILING(mood_signs/2, 1)
		var/bingus = 0
		while(bingus < mood_signs)
			bingus++
			left_symbols += mood_symbol
	return left_symbols

/datum/component/mood/proc/get_right_signs_from_number(num)
	var/mood_signs = num
	var/mood_symbol = "<span class='green'><b>+</b></span>"
	if(mood_signs == 0)
		mood_symbol = ""
	else if(mood_signs < 0)
		mood_symbol = "<span class='red'><b>-</b></span>"
	mood_signs = abs(mood_signs)
	var/right_symbols = ""
	if(mood_signs && mood_symbol)
		mood_signs = FLOOR(mood_signs/2, 1)
		var/bingus = 0
		while(bingus < mood_signs)
			bingus++
			right_symbols += mood_symbol
	return right_symbols

/datum/component/mood/proc/print_mood(mob/user)
	var/msg = "<span class='info'>*---------*</span>\n"
	msg += "<span class='notice'><b>My thoughts</b></span>\n"
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		msg += "<span class='info'>I remember my name, it is <b>[H.real_name]</b>.</span>\n"
		msg += "<span class='info'>I am, chronologically, <b>[H.age]</b> years old.</span>\n"
		if(H.mind.assigned_role)
			msg += "<span class='info'>I'm \a <b>[H.mind.assigned_role]</b> by trade.</span>\n"
		for(var/datum/antagonist/antag in H.mind.antag_datums)
			msg += "<span class='info'>I am also \a <span class='red'>[lowertext(antag.name)]</span>.</span>\n"
		msg += "<span class='info'>My blood type is <span class='pink'>[H.dna.blood_type]</span>.</span>\n"
		msg += "<span class='info'>My gender is <i>[lowertext(H.gender)]</i>.</span>\n"
		msg += "<span class='info'>My species is <i>[lowertext(H.dna.species.name)]</i>.</span>\n"
		if(length(H.roundstart_quirks))
			msg += "<span class='info'>I am special: [H.get_trait_string(FALSE, FALSE)].</span>\n"
	msg += "<span class='notice'><b>My current mood: </b></span>\n" //Short term
	var/left_symbols = get_left_signs_from_number(mood_level - 5)
	var/right_symbols = get_right_signs_from_number(mood_level - 5)
	if(!HAS_TRAIT(user, TRAIT_SCREWY_MOOD))
		switch(mood_level)
			if(1)
				msg += "<span class='boldwarning'>[left_symbols]I wish I was dead![right_symbols]</span>\n"
			if(2)
				msg += "<span class='boldwarning'>[left_symbols]I feel terrible...[right_symbols]</span>\n"
			if(3)
				msg += "<span class='boldwarning'>[left_symbols]I feel very upset.[right_symbols]</span>\n"
			if(4)
				msg += "<span class='boldwarning'>[left_symbols]I'm a bit sad.[right_symbols]</span>\n"
			if(5)
				msg += "<span class='nicegreen'>[left_symbols]I'm alright.[right_symbols]</span>\n"
			if(6)
				msg += "<span class='nicegreen'>[left_symbols]I feel pretty okay.[right_symbols]</span>\n"
			if(7)
				msg += "<span class='nicegreen'>[left_symbols]I feel pretty good.[right_symbols]</span>\n"
			if(8)
				msg += "<span class='nicegreen'>[left_symbols]I feel amazing![right_symbols]</span>\n"
			if(9)
				msg += "<span class='nicegreen'>[left_symbols]I love life![right_symbols]</span>\n"
			else
				msg += "<span class='nicegreen'>[left_symbols]I'm alright.[right_symbols]</span>\n"
	else
		msg += "<span class='notice'>No clue.</span>\n"

	msg += "<span class='notice'><b>Moodlets:\n</b></span>"//All moodlets
	if(!HAS_TRAIT(user, TRAIT_SCREWY_MOOD))
		if(length(mood_events))
			for(var/i in mood_events)
				var/datum/mood_event/event = mood_events[i]
				left_symbols = get_left_signs_from_number(event.mood_change)
				right_symbols = get_right_signs_from_number(event.mood_change)
				msg += "[left_symbols][event.description][right_symbols]\n"
		else
			msg += "<span class='nicegreen'>I don't have much of a reaction to anything right now.</span>\n"
	else
		msg += "<span class='notice'>No idea.</span>\n"
	msg += "<span class='info'>*---------*</span>"
	to_chat(user || parent, msg)
	var/mob/living/living_user = user
	if(istype(living_user) && !HAS_TRAIT(living_user, TRAIT_SCREWY_CHECKSELF))
		var/list/additional_info = list()
		if(living_user.getStaminaLoss())
			if(living_user.getStaminaLoss() > 30)
				additional_info += "<span class='info'>I'm completely exhausted.</span>\n"
			else
				additional_info += "<span class='info'>I feel fatigued.</span>\n"
		if(!HAS_TRAIT(living_user, TRAIT_NOHUNGER))
			switch(living_user.nutrition)
				if(NUTRITION_LEVEL_FULL to INFINITY)
					additional_info += "<span class='info'>I'm completely stuffed!</span>\n"
				if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
					additional_info += "<span class='info'>I'm well fed!</span>\n"
				if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
					additional_info += "<span class='info'>I'm not hungry.</span>\n"
				if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
					additional_info += "<span class='info'>I could use a bite to eat.</span>\n"
				if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
					additional_info += "<span class='info'>I feel quite hungry.</span>\n"
				if(0 to NUTRITION_LEVEL_STARVING)
					additional_info += "<span class='danger'>I'm starving!</span>\n"
		if(!HAS_TRAIT(living_user, TRAIT_NOHYDRATION))
			switch(living_user.hydration)
				if(HYDRATION_LEVEL_FULL to INFINITY)
					additional_info += "<span class='info'>I'm completely full!</span>\n"
				if(HYDRATION_LEVEL_WELL_HYDRATED to HYDRATION_LEVEL_FULL)
					additional_info += "<span class='info'>I'm well hydrated!</span>\n"
				if(HYDRATION_LEVEL_HYDRATED to HYDRATION_LEVEL_WELL_HYDRATED)
					additional_info += "<span class='info'>I'm not thirsty.</span>\n"
				if(HYDRATION_LEVEL_THIRSTY to HYDRATION_LEVEL_HYDRATED)
					additional_info += "<span class='info'>I could use a drink.</span>\n"
				if(HYDRATION_LEVEL_DEHYDRATED to HYDRATION_LEVEL_THIRSTY)
					additional_info += "<span class='info'>I feel quite thirsty.</span>\n"
				if(0 to HYDRATION_LEVEL_DEHYDRATED)
					additional_info += "<span class='danger'>I'm dehydrated!</span>\n"
		if(HAS_TRAIT(living_user, TRAIT_SELF_AWARE))
			var/toxloss = living_user.getToxLoss()
			if(toxloss)
				if(toxloss > 10)
					additional_info += "<span class='danger'>I feel sick.</span>\n"
				else if(toxloss > 20)
					additional_info += "<span class='danger'>I feel nauseated.</span>\n"
				else if(toxloss > 40)
					additional_info += "<span class='danger'>I feel very unwell!</span>\n"
			var/oxyloss = living_user.getOxyLoss()
			if(oxyloss)
				if(oxyloss > 10)
					additional_info += "<span class='danger'>I feel lightheaded.</span>\n"
				else if(oxyloss > 20)
					additional_info += "<span class='danger'>My thinking is clouded and distant.</span>\n"
				else if(oxyloss > 30)
					additional_info += "<span class='danger'>I'm choking!</span>\n"

		if(length(additional_info))
			to_chat(living_user, "<span class='info'><b>Additional:</b></span>")
			additional_info += "<span class='info'>*---------*</span>"
			to_chat(living_user, jointext(additional_info, ""))

///Called after moodevent/s have been added/removed.
/datum/component/mood/proc/update_mood()
	var/previous_mood_level = mood_level
	mood = 0
	shown_mood = 0
	for(var/i in mood_events)
		var/datum/mood_event/event = mood_events[i]
		mood += event.mood_change
		if(!event.hidden)
			shown_mood += event.mood_change
		mood *= mood_modifier
		shown_mood *= mood_modifier
	switch(mood)
		if(-INFINITY to MOOD_LEVEL_SAD4)
			mood_level = 1
		if(MOOD_LEVEL_SAD4 to MOOD_LEVEL_SAD3)
			mood_level = 2
		if(MOOD_LEVEL_SAD3 to MOOD_LEVEL_SAD2)
			mood_level = 3
		if(MOOD_LEVEL_SAD2 to MOOD_LEVEL_SAD1)
			mood_level = 4
		if(MOOD_LEVEL_SAD1 to MOOD_LEVEL_HAPPY1)
			mood_level = 5
		if(MOOD_LEVEL_HAPPY1 to MOOD_LEVEL_HAPPY2)
			mood_level = 6
		if(MOOD_LEVEL_HAPPY2 to MOOD_LEVEL_HAPPY3)
			mood_level = 7
		if(MOOD_LEVEL_HAPPY3 to MOOD_LEVEL_HAPPY4)
			mood_level = 8
		if(MOOD_LEVEL_HAPPY4 to INFINITY)
			mood_level = 9
	var/mob/living/L = parent
	if(istype(L) && is_dreamer(L))
		mood_level = MOOD_LEVEL_NEUTRAL
		sanity = SANITY_NEUTRAL
	if(mood_level > previous_mood_level)
		to_chat(parent, "<span class='nicegreen'>My mood gets better.</span>")
	else if(mood_level < previous_mood_level)
		to_chat(parent, "<span class='danger'>My mood gets worse.</span>")
	update_mood_icon()

/datum/component/mood/proc/update_mood_icon()
	var/mob/living/owner = parent
	if(!HAS_TRAIT(owner, TRAIT_SCREWY_MOOD))
		if(owner.client && owner.hud_used)
			if(is_dreamer(owner))
				screen_obj.icon_state = "mood_dreamer"
			else if(sanity < 25)
				screen_obj.icon_state = "mood_insane"
			else if(owner.has_status_effect(/datum/status_effect/chem/enthrall))//Fermichem enthral chem, maybe change?
				screen_obj.icon_state = "mood_entrance"
			else
				screen_obj.icon_state = "mood[mood_level]"
			var/motherfucker = ""
			switch(CEILING(mood_level/3, 1))
				if(1)
					motherfucker = "h"
				if(2)
					motherfucker = "j"
				if(3)
					motherfucker = ""
			if(is_dreamer(owner))
				motherfucker = "h"
			owner.hud_used.noise_filter?.loggers = motherfucker
			owner.hud_used.noise_filter?.update_icon()
	else
		if(owner.client && owner.hud_used)
			screen_obj.icon_state = "mood5"
			owner.hud_used.noise_filter?.loggers = "j"
			if(is_dreamer(owner))
				owner.hud_used.noise_filter?.loggers = "h"
			owner.hud_used.noise_filter?.update_icon()

/datum/component/mood/process() //Called on SSobj process
	if(QDELETED(parent)) // workaround to an obnoxious sneaky periodical runtime.
		qdel(src)
		return
	var/mob/living/owner = parent
	switch(mood_level)
		if(1)
			modify_sanity(-0.6, minimum=SANITY_LOST)
		if(2)
			modify_sanity(-0.4, minimum=SANITY_LOST)
		if(3)
			modify_sanity(-0.3, minimum=SANITY_INSANE)
		if(4)
			modify_sanity(-0.2, minimum=SANITY_CRAZY)
		if(5)
			modify_sanity(0.1, maximum=SANITY_NEUTRAL)
		if(6)
			modify_sanity(0.15, maximum=SANITY_NEUTRAL)
		if(7)
			modify_sanity(0.2, maximum=SANITY_NEUTRAL)
		if(8)
			modify_sanity(0.3, maximum=SANITY_GREAT)
		if(9)
			modify_sanity(0.4, maximum=SANITY_AMAZING)
	HandleSanity(owner)
	HandleNutrition(owner)
	HandleHydration(owner)

/datum/component/mood/proc/setSanity(amount, minimum=SANITY_LOST, maximum=SANITY_NEUTRAL)//I'm sure bunging this in here will have no negative repercussions.
	var/mob/living/master = parent

	if(amount == sanity)
		return
	// If we're out of the acceptable minimum-maximum range move back towards it in steps of 0.5
	// If the new amount would move towards the acceptable range faster then use it instead
	if(sanity < minimum && amount < sanity + 0.5)
		amount = sanity + 0.5
	else if(sanity > maximum && amount > sanity - 0.5)
		amount = sanity - 0.5

	// Disturbed stops you from getting any more sane
	if(HAS_TRAIT(master, TRAIT_UNSTABLE))
		sanity = min(amount,sanity)
	else
		sanity = amount

	var/old_sanity_level = sanity_level
	switch(sanity)
		if(-INFINITY to SANITY_CRAZY)
			setInsanityEffect(MAJOR_INSANITY_PEN)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/insane)
			sanity_level = 6
		if(SANITY_CRAZY to SANITY_UNSTABLE)
			setInsanityEffect(MINOR_INSANITY_PEN)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/crazy)
			sanity_level = 5
		if(SANITY_UNSTABLE to SANITY_DISTURBED)
			setInsanityEffect(SLIGHT_INSANITY_PEN)
			master.add_movespeed_modifier(/datum/movespeed_modifier/sanity/disturbed)
			sanity_level = 4
		if(SANITY_DISTURBED to SANITY_NEUTRAL)
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			sanity_level = 3
		if(SANITY_NEUTRAL+1 to SANITY_GREAT+1) //shitty hack but +1 to prevent it from responding to super small differences
			setInsanityEffect(0)
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			sanity_level = 2
		if(SANITY_GREAT+1 to INFINITY)
			setInsanityEffect(ECSTATIC_SANITY_PEN) //It's not a penalty but w/e
			master.remove_movespeed_modifier(MOVESPEED_ID_SANITY)
			sanity_level = 1

	if(sanity_level != old_sanity_level)
		if(sanity_level >= 4)
			if(!malus)
				if(!length(free_maluses))
					ADD_SKILL_MODIFIER_BODY(/datum/skill_modifier/bad_mood, malus_id++, master, malus)
				else
					malus = pick_n_take(free_maluses)
					if(master.mind)
						master.mind.add_skill_modifier(malus.identifier)
					else
						malus.RegisterSignal(master, COMSIG_MOB_ON_NEW_MIND, /datum/skill_modifier.proc/on_mob_new_mind, TRUE)
			malus.value_mod = malus.level_mod = 1 - (sanity_level - 3) * MOOD_INSANITY_MALUS
		else if(malus)
			if(master.mind)
				master.mind.remove_skill_modifier(malus.identifier)
			else
				malus.UnregisterSignal(master, COMSIG_MOB_ON_NEW_MIND)
			free_maluses += malus
			malus = null
		switch(sanity_level)
			if(1,2)
				master.hud_used?.darkness.alpha = 0
			if(3)
				master.hud_used?.darkness.alpha = 32
			if(4)
				master.hud_used?.darkness.alpha = 64
			if(5)
				master.hud_used?.darkness.alpha = 128
			if(6)
				master.hud_used?.darkness.alpha = 160

/datum/component/mood/proc/setInsanityEffect(newval)//More code so that the previous proc works
	if(newval == insanity_effect)
		return

	var/mob/living/L = parent
	if(newval == ECSTATIC_SANITY_PEN && !bonus)
		ADD_SKILL_MODIFIER_BODY(/datum/skill_modifier/great_mood, null, L, bonus)
	else if(bonus)
		REMOVE_SKILL_MODIFIER_BODY(/datum/skill_modifier/great_mood, null, L)
		bonus = null

	insanity_effect = newval

/datum/component/mood/proc/modify_sanity(datum/source, amount, minimum = SANITY_LOST, maximum = SANITY_AMAZING)
	setSanity(sanity + amount, minimum, maximum)

/datum/component/mood/proc/add_event(datum/source, category, type, param) //Category will override any events in the same category, should be unique unless the event is based on the same thing like hunger.
	//trey liam dose not give a fuck
	var/mob/living/L = parent
	if(istype(L) && is_dreamer(L))
		return
	var/datum/mood_event/the_event
	if(mood_events[category])
		the_event = mood_events[category]
		if(the_event.type != type)
			clear_event(null, category)
		else
			if(the_event.timeout)
				addtimer(CALLBACK(src, .proc/clear_event, null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)
			return 0 //Don't have to update the event.
	the_event = new type(src, param)//This causes a runtime for some reason, was this me? No - there's an event floating around missing a definition.
	
	if(HAS_TRAIT(parent, TRAIT_EMOTIONAL))
		the_event.mood_change *= 2
	
	mood_events[category] = the_event
	update_mood()

	if(the_event.timeout)
		addtimer(CALLBACK(src, .proc/clear_event, null, category), the_event.timeout, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/component/mood/proc/clear_event(datum/source, category)
	var/datum/mood_event/event = mood_events[category]
	if(!event)
		return 0

	mood_events -= category
	qdel(event)
	update_mood()

/datum/component/mood/proc/remove_temp_moods() //Removes all temp moodsfor(var/i in mood_events)
	for(var/i in mood_events)
		var/datum/mood_event/moodlet = mood_events[i]
		if(!moodlet || !moodlet.timeout)
			continue
		mood_events -= i
		qdel(moodlet)
	update_mood()

/datum/component/mood/proc/modify_hud(datum/source)
	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	screen_obj = new
	hud.infodisplay += screen_obj
	RegisterSignal(hud, COMSIG_PARENT_QDELETING, .proc/unmodify_hud)
	RegisterSignal(screen_obj, COMSIG_CLICK, .proc/hud_click)

/datum/component/mood/proc/unmodify_hud(datum/source)
	if(!screen_obj || !parent)
		return
	var/mob/living/owner = parent
	var/datum/hud/hud = owner.hud_used
	if(hud && hud.infodisplay)
		hud.infodisplay -= screen_obj
	QDEL_NULL(screen_obj)

/datum/component/mood/proc/hud_click(datum/source, location, control, params, mob/user)
	print_mood(user)

/datum/component/mood/proc/HandleNutrition(mob/living/L)
	switch(L.nutrition)
		if(NUTRITION_LEVEL_FULL to INFINITY)
			add_event(null, "nutrition", /datum/mood_event/fat)
		if(NUTRITION_LEVEL_WELL_FED to NUTRITION_LEVEL_FULL)
			add_event(null, "nutrition", /datum/mood_event/wellfed)
		if(NUTRITION_LEVEL_FED to NUTRITION_LEVEL_WELL_FED)
			add_event(null, "nutrition", /datum/mood_event/fed)
		if(NUTRITION_LEVEL_HUNGRY to NUTRITION_LEVEL_FED)
			clear_event(null, "nutrition")
		if(NUTRITION_LEVEL_STARVING to NUTRITION_LEVEL_HUNGRY)
			add_event(null, "nutrition", /datum/mood_event/hungry)
		if(0 to NUTRITION_LEVEL_STARVING)
			add_event(null, "nutrition", /datum/mood_event/starving)
	switch(L.defecation)
		if(DEFECATION_LEVEL_POOPY to DEFECATION_LEVEL_VERY_POOPY)
			add_event(null, "defecation", /datum/mood_event/shit)
		if(DEFECATION_LEVEL_VERY_POOPY to INFINITY)
			add_event(null, "defecation", /datum/mood_event/veryshit)
		else
			clear_event(null, "defecation")

/datum/component/mood/proc/HandleHydration(mob/living/L)
	switch(L.hydration)
		if(HYDRATION_LEVEL_FULL to INFINITY)
			add_event(null, "hydration", /datum/mood_event/wellhydrated)
		if( HYDRATION_LEVEL_WELL_HYDRATED to HYDRATION_LEVEL_FULL)
			add_event(null, "hydration", /datum/mood_event/hydrated)
		if(HYDRATION_LEVEL_THIRSTY to HYDRATION_LEVEL_WELL_HYDRATED)
			clear_event(null, "hydration")
		if(HYDRATION_LEVEL_DEHYDRATED to HYDRATION_LEVEL_THIRSTY)
			add_event(null, "hydration", /datum/mood_event/thirsty)
		if(0 to HYDRATION_LEVEL_DEHYDRATED)
			add_event(null, "hydration", /datum/mood_event/dehydrated)
	switch(L.urination)
		if(URINATION_LEVEL_PISSY to URINATION_LEVEL_VERY_PISSY)
			add_event(null, "urination", /datum/mood_event/piss)
		if(URINATION_LEVEL_VERY_PISSY to INFINITY)
			add_event(null, "urination", /datum/mood_event/verypiss)
		else
			clear_event(null, "urination")

/datum/component/mood/proc/HandleSanity(mob/living/carbon/human/H)
	if(!istype(H))
		return
	if(sanity <= SANITY_INSANE)
		//more hallucination hahaHAHAHAH
		H.hallucination++
		//red screen crazy crazy
		if(!H.has_client_colour(/datum/client_colour/sanity/crazy))
			H.add_client_colour(/datum/client_colour/sanity/crazy)
		//killing self
		if(prob(2))
			if(H.canSuicide())
				to_chat(H, "<span class='deadsay'>I've always felt alone. My whole life. For as long as I can remember. I don't know if I like it or if I'm used to it, but I know this; being lonely does things to you. Feeling shit and bitter and angry all the time just... Eats away at you...</span>")
				H.kill_self()
		//screame
		else if(prob(20))
			H.agony_scream()
		//brain trauma
		else if(length(H.get_traumas()) <= 3 && prob(10))
			H.gain_trauma_type(/datum/brain_trauma/severe, TRAUMA_RESILIENCE_LOBOTOMY)
		//crying
		else if(!(world.time % 4))
			H.emote("cry")
	if(sanity <= SANITY_CRAZY)
		//gasping and moaning
		if(prob(3))
			H.emote("gasp")
		else if(prob(2))
			H.emote("moan")
		//more hallucination haha
		if(prob(50))
			H.hallucination++
		//prain trauma
		if(length(H.get_traumas()) <= 2 && prob(4))
			H.gain_trauma_type(/datum/brain_trauma/severe, TRAUMA_RESILIENCE_SURGERY)
		//get stunned
		else if(prob(4))
			to_chat(H, "<span class='deadsay'><b>I can't take this anymore!</b></span>")
			H.AdjustImmobilized(4 SECONDS)
			H.AdjustDazed(10 SECONDS)
	if(sanity <= SANITY_UNSTABLE)
		//gmod horror map sounds
		if(prob(3) || (sanity <= SANITY_CRAZY && prob(6)))
			SEND_SOUND(H.client, sound(pick(insanity_sounds), channel = CHANNEL_AMBIENT))
		//hallucinations begin
		if(prob(25))
			H.hallucination++
		//prain trauma
		else if(length(H.get_traumas()) && prob(2))
			H.gain_trauma_type(/datum/brain_trauma/severe, TRAUMA_RESILIENCE_BASIC)
	if(sanity <= SANITY_DISTURBED)
		//it's all over, but the crying
		if(prob(2) || (sanity <= SANITY_UNSTABLE && prob(6)))
			H.emote("cry")
		else if(prob(4))
			H.emote("sneeze")
	if(sanity > SANITY_DISTURBED)
		if(H.client)
			H.remove_client_colour(/datum/client_colour/sanity/crazy)

/datum/component/mood/proc/insanity_screenshake(mob/living/carbon/human/H)
	if(!H.client)
		return
	var/client/C = H.client
	var/shakeit = 0
	while(shakeit < 10)
		shakeit++
		var/intensity = rand(1,3)
		if(prob(75))
			animate(C, pixel_y = (C.pixel_y + intensity), time = 0.5)
			sleep(0.5)
			animate(C, pixel_y = (C.pixel_y - intensity), time = 0.5)
			sleep(0.5)
		else
			animate(C, pixel_x = (C.pixel_x + intensity), time = 0.5)
			sleep(0.5)
			animate(C, pixel_x = (C.pixel_x - intensity), time = 0.5)
			sleep(0.5)

/datum/component/mood/proc/update_beauty(area/A)
	if(A.outdoors) //if we're outside, we don't care.
		clear_event(null, "area_beauty")
		return FALSE
	if(HAS_TRAIT(parent, TRAIT_SNOB))
		switch(A.beauty)
			if(-INFINITY to BEAUTY_LEVEL_HORRID)
				add_event(null, "area_beauty", /datum/mood_event/horridroom)
				return
			if(BEAUTY_LEVEL_HORRID to BEAUTY_LEVEL_BAD)
				add_event(null, "area_beauty", /datum/mood_event/badroom)
				return
	switch(A.beauty)
		if(-INFINITY to BEAUTY_LEVEL_DECENT)
			clear_event(null, "area_beauty")
		if(BEAUTY_LEVEL_DECENT to BEAUTY_LEVEL_GOOD)
			add_event(null, "area_beauty", /datum/mood_event/decentroom)
		if(BEAUTY_LEVEL_GOOD to BEAUTY_LEVEL_GREAT)
			add_event(null, "area_beauty", /datum/mood_event/goodroom)
		if(BEAUTY_LEVEL_GREAT to INFINITY)
			add_event(null, "area_beauty", /datum/mood_event/greatroom)

///Called when parent is revived.
/datum/component/mood/proc/on_revive(datum/source, full_heal)
	START_PROCESSING(SSobj, src)
	if(!full_heal)
		return
	remove_temp_moods()
	setSanity(initial(sanity))

#undef ECSTATIC_SANITY_PEN
#undef SLIGHT_INSANITY_PEN
#undef MINOR_INSANITY_PEN
#undef MAJOR_INSANITY_PEN
#undef MOOD_INSANITY_MALUS

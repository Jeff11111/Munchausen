//Dreamer antagonist datum
/datum/antagonist/dreamer
	name = "Dreamer"
	roundend_category = "dreamers"
	antagpanel_category = "Dreamer"
	antag_memory = "<b>Recently I've been visited by a lot of VISIONS. They're all about another WORLD, ANOTHER life. I will do EVERYTHING to know the TRUTH, and return to the REAL world.</b><br>"
	threat = 10
	silent = TRUE
	var/ambience = 'modular_skyrat/code/modules/antagonists/dreamer/sound/dreamer_is_still_asleep.ogg'
	var/ambience_duration = 1620
	var/last_ambience = 0
	var/list/recipe_progression = list(/datum/crafting_recipe/wonder, /datum/crafting_recipe/wonder/second, /datum/crafting_recipe/wonder/third, /datum/crafting_recipe/wonder/fourth)
	var/list/heart_keys = list()
	var/list/associated_keys = list()
	var/list/hearts_seen = list()
	var/list/obj/structure/wonder/wonders_done = list()
	var/current_wonder = 1
	var/sum_keys = 0

//Transferring body unfucking.
/datum/antagonist/dreamer/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(new_body.hud_used)
		give_hallucination_object(new_body)
	if(iscarbon(new_body))
		var/mob/living/carbon/C = new_body
		//Following my HEART
		var/obj/item/organ/heart/my_heart = C.getorganslot(ORGAN_SLOT_HEART)
		if(my_heart)
			my_heart.organ_flags |= ORGAN_VITAL

/datum/antagonist/dreamer/New()
	. = ..()
	set_keys()

/datum/antagonist/dreamer/proc/set_keys()
	var/list/alphabet = list("A", "B", "C",\
							"D", "E", "F",\
							"G", "H", "I",\
							"J", "K", "L",\
							"M", "N", "O",\
							"P", "Q", "R",\
							"S", "T", "U",\
							"V", "W", "X",\
							"Y", "Z")
	heart_keys = list()
	//We need 4 numbers and four keys
	for(var/i in 1 to 4)
		//Make the number first
		var/randumb = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"
		while(randumb in heart_keys)
			randumb = "[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"
		//Make the key second
		var/rantelligent = "[pick(alphabet)][pick(alphabet)][pick(alphabet)][pick(alphabet)]"
		while(rantelligent in associated_keys)
			rantelligent = "[pick(alphabet)][pick(alphabet)][pick(alphabet)][pick(alphabet)]"

		//Stick then in the lists, continue the loop
		heart_keys[randumb] = rantelligent
		associated_keys[rantelligent] = randumb
	
	sum_keys = 0
	for(var/i in heart_keys)
		sum_keys += text2num(i)

/datum/antagonist/dreamer/proc/give_wakeup_call()
	var/datum/objective/dreamer/wakeup = new()
	objectives += wakeup

/datum/antagonist/dreamer/proc/give_hallucination_object(mob/living/carbon/M)
	if(istype(M) && M.hud_used)
		M.hud_used.dreamer = new()
		if(M.client)
			M.hud_used.dreamer.update_for_view(M.client.view)
		M.client?.screen += M.hud_used.dreamer
		M.hud_used.bloodlust = new()
		M.client?.screen += M.hud_used.dreamer
		RegisterSignal(M, COMSIG_LIVING_COMBAT_ENABLED, .proc/activate_bloodlust)
		RegisterSignal(M, COMSIG_LIVING_COMBAT_DISABLED, .proc/deactivate_bloodlust)

/datum/antagonist/dreamer/proc/give_stats(mob/living/carbon/M)
	if(!istype(M) || !M.mind)
		return
	var/datum/stats/str/str = GET_STAT(M, str)
	var/datum/stats/fakestr/fake = GET_STAT(M, fakestr)
	if(istype(fake) && istype(str))
		fake.level = str.level
	if(istype(str))
		str.level = min(str.level + rand(10, 15), 30)
	var/datum/stats/end/end = GET_STAT(M, end)
	if(istype(end))
		end.level = min(end.level + rand(10, 15), 30)
	var/datum/skills/surgery/surgery = GET_SKILL(M, surgery)
	if(istype(surgery))
		surgery.level = min(surgery.level + rand(15, 20), 30)
	var/datum/skills/melee/melee = GET_SKILL(M, melee)
	if(istype(melee))
		melee.level = min(melee.level + rand(15, 20), 30)
	//Following my HEART
	var/obj/item/organ/heart/my_heart = M.getorganslot(ORGAN_SLOT_HEART)
	if(my_heart)
		my_heart.organ_flags |= ORGAN_VITAL
	ADD_TRAIT(M, TRAIT_NOPAIN, "dreamer")
	ADD_TRAIT(M.mind, TRAIT_NOPAIN, "dreamer")
	ADD_TRAIT(M, TRAIT_BLOODLOSSIMMUNE, "dreamer")
	ADD_TRAIT(M.mind, TRAIT_BLOODLOSSIMMUNE, "dreamer")
	ADD_TRAIT(M, TRAIT_NOHUNGER, "dreamer")
	ADD_TRAIT(M.mind, TRAIT_NOHUNGER, "dreamer")
	ADD_TRAIT(M, TRAIT_NOHYDRATION, "dreamer")
	ADD_TRAIT(M.mind, TRAIT_NOHYDRATION, "dreamer")

/datum/antagonist/dreamer/proc/grant_first_wonder_recipe(mob/living/carbon/M)
	if(!istype(M))
		return
	var/datum/crafting_recipe/wonder/wonderful = new()
	wonderful.name = "[associated_keys[1]] Wonder"
	wonderful.update_global_wonder()
	owner.teach_crafting_recipe(wonderful.type)
	qdel(wonderful)

/datum/antagonist/dreamer/proc/spawn_trey_liam()
	var/turf/spawnturf
	var/obj/effect/landmark/treyliam/trey = locate(/obj/effect/landmark/treyliam) in world
	if(trey)
		spawnturf = get_turf(trey)
	if(spawnturf)
		var/mob/living/carbon/human/H = new /mob/living/carbon/human(spawnturf)
		H.fully_replace_character_name(H.name, "Trey Liam")
		H.set_gender(MALE)
		H.skin_tone = "caucasian1"
		H.hair_color = "999"
		H.hair_style = "Very Long Hair"
		H.facial_hair_color = "999"
		H.facial_hair_style = "Beard (Full)"
		H.age = 50
		H.give_genital(/obj/item/organ/genital/penis)
		H.give_genital(/obj/item/organ/genital/testicles)
		H.equipOutfit(/datum/outfit/treyliam)
		H.regenerate_icons()
		for(var/obj/machinery/vr_sleeper/chungus in get_turf(H))
			chungus.buckle_mob(H, TRUE, FALSE)
		return H

/datum/antagonist/dreamer/proc/wake_up()
	STOP_PROCESSING(SSobj, src)
	var/mob/living/carbon/dreamer = owner.current
	var/client/dreamer_client = dreamer.client // Trust me, we need it later
	dreamer.clear_fullscreen("dream")
	dreamer.clear_fullscreen("wakeup")
	for(var/datum/objective/objective in objectives)
		objective.completed = TRUE
	for(var/mob/M in GLOB.player_list)
		if(M.client)
			SEND_SOUND(M, sound(null))
			M.playsound_local(get_turf(M), 'modular_skyrat/code/modules/antagonists/dreamer/sound/dreamer_win.ogg', 100, 0)
	var/mob/living/carbon/human/H = spawn_trey_liam()
	if(H)
		dreamer.transfer_ckey(H, TRUE)
		//Explodie all our wonders
		for(var/wond in wonders_done)
			var/obj/structure/wonder/wondie = wond
			if(istype(wondie))
				explosion(wondie, 8, 16, 32, 64)
		var/obj/item/organ/brain/brain = dreamer.getorganslot(ORGAN_SLOT_BRAIN)
		var/obj/item/bodypart/head/head = dreamer.get_bodypart(BODY_ZONE_HEAD)
		if(head)
			head.apply_dismember(WOUND_BURN)
		if(brain)
			qdel(brain)
		H.SetSleeping(250)
		dreamer_client.chatOutput?.loaded = FALSE
		dreamer_client.chatOutput?.start()
		dreamer_client.chatOutput?.load()
		SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "dreamer", /datum/mood_event/woke_up)
		sleep(15)
		to_chat(H, "<span class='big bold'><span class='deadsay'>... WHERE AM I? ...</span></span>")
		sleep(30)
		to_chat(H, "<span class='deadsay'>... Munchausen? No ... It doesn't exist ...</span>")
		sleep(30)
		to_chat(H, "<span class='deadsay'>... My name is Trey. Trey Liam, Scientific Overseer ...</span>")
		sleep(30)
		to_chat(H, "<span class='deadsay'>... I'm on NT Aeon, a self sustaining ship, used to preserve what remains of humanity ...</span>")
		sleep(30)
		to_chat(H, "<span class='deadsay'>... Launched into the stars, INRL preserves their memories ... Their personalities ...</span>")
		sleep(30)
		to_chat(H, "<span class='deadsay'>... Keeps them alive in cyberspace, oblivious to the catastrophe ...</span>")
		sleep(30)
		to_chat(H, "<span class='deadsay'>... There is no hope left. Only the cyberspace deck lets me live in the forgery ...</span>")
		sleep(30)
		to_chat(H, "<span class='deadsay'>... What have i done!? ...</span>")
		sleep(40)
	SSticker.declare_completion()
	to_chat(world, "<span class='deadsay'><span class='big bold'>The Dreamer has awakened!</span></span>")
	SSticker.Reboot("The Dreamer has awakened.", "The Dreamer has awakened.", delay = 60 SECONDS)

/datum/antagonist/dreamer/proc/cant_wake_up()
	if(!iscarbon(owner?.current))
		return
	to_chat(owner.current, "<span class='deadsay'><span class='big bold'>I CAN'T WAKE UP.</span></span>")
	sleep(20)
	to_chat(owner.current, "<span class='deadsay'><span class='big bold'>ICANTWAKEUP</span></span>")
	sleep(10)
	var/mob/living/carbon/C = owner.current
	var/obj/item/organ/brain/brain = C.getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/bodypart/head/head = C.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.apply_dismember(WOUND_BURN)
	if(brain)
		qdel(brain)

/datum/antagonist/dreamer/proc/agony(mob/living/carbon/M)
	if(!istype(M))
		return
	var/sound/im_sick = sound('modular_skyrat/code/modules/antagonists/dreamer/sound/dreamt.ogg', TRUE, FALSE, CHANNEL_HIGHEST_AVAILABLE, 100)
	M.playsound_local(turf_source = get_turf(M), S = im_sick, vol = 100, vary = 0)
	M.overlay_fullscreen("dream", /obj/screen/fullscreen/dreaming, 1)
	M.overlay_fullscreen("wakeup", /obj/screen/fullscreen/dreaming/waking_up, 1)
	waking_up = TRUE

/datum/antagonist/dreamer/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	if(owner?.current)
		owner.current.client?.screen -= owner.current.hud_used?.dreamer
		if(owner.current.hud_used?.dreamer)
			QDEL_NULL(owner.current.hud_used.dreamer)

/datum/antagonist/dreamer/greet()
	. = ..()
	if(!owner?.current)
		return
	owner.current.playsound_local(owner.current, 'modular_skyrat/code/modules/antagonists/dreamer/sound/dreamer_warning.ogg', 100, 0)
	to_chat(owner.current, "<span class='danger'><b>Recently I've been visited by a lot of VISIONS. They're all about another WORLD, ANOTHER life. I will do EVERYTHING to know the TRUTH, and return to the REAL world.</b></span>")
	if(length(objectives))
		owner.announce_objectives()
	play_nice_noises()

/datum/antagonist/dreamer/proc/play_nice_noises()
	if(!owner?.current)
		return
	owner.current.playsound_local(owner.current, ambience, 65, 0, CHANNEL_AMBIENCE)
	last_ambience = world.time

/datum/antagonist/dreamer/on_gain()
	. = ..()
	START_PROCESSING(SSprocessing, src)
	give_wakeup_call()
	give_hallucination_object(owner.current)
	give_stats(owner.current)
	grant_first_wonder_recipe(owner.current)
	greet()

/datum/antagonist/dreamer/on_removal()
	. = ..()
	STOP_PROCESSING(SSprocessing, src)

/datum/antagonist/dreamer/proc/activate_bloodlust()
	if(!owner?.current)
		return
	owner.current.hud_used?.bloodlust?.icon_state = initial(owner.current.hud_used.bloodlust.icon_state)
	owner.current.hud_used?.bloodlust?.alpha = 255

/datum/antagonist/dreamer/proc/deactivate_bloodlust()
	if(!owner?.current)
		return
	owner.current.hud_used?.bloodlust?.alpha = 0

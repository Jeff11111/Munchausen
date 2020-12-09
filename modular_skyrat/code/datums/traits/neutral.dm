//traits with no real impact that can be taken freely
//MAKE SURE THESE DO NOT MAJORLY IMPACT GAMEPLAY. those should be positive or negative traits.
//to be quite honest most of these are very dubious in how "neutral" they are

//no ratatouille
/datum/quirk/no_taste
	name = "Ageusia"
	desc = "You can't taste anything! Toxic food will still poison you."
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = "<span class='notice'>You can't taste anything!</span>"
	lose_text = "<span class='notice'>You can taste again!</span>"
	medical_record_text = "Patient suffers from ageusia and is incapable of tasting food or reagents."

//videogames are art
/datum/quirk/snob
	name = "Snob"
	desc = "You care about the finer things, if a room doesn't look nice its just not really worth it, is it?"
	value = 0
	gain_text = "<span class='notice'>You feel like you understand what things should look like.</span>"
	lose_text = "<span class='notice'>Well who cares about deco anyways?</span>"
	medical_record_text = "Patient seems to be rather stuck up."
	mob_trait = TRAIT_SNOB
	medical_condition = FALSE

//likes feet
/datum/quirk/deviant_tastes
	name = "Deviant Tastes"
	desc = "You dislike food that most people enjoy, and find delicious what they don't."
	value = 0
	gain_text = "<span class='notice'>You start craving something that tastes strange.</span>"
	lose_text = "<span class='notice'>You feel like eating normal food again.</span>"
	medical_record_text = "Patient demonstrates irregular nutrition preferences."

/datum/quirk/deviant_tastes/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/datum/species/species = H.dna.species
	var/liked = species.liked_food
	species.liked_food = species.disliked_food
	species.disliked_food = liked

/datum/quirk/deviant_tastes/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		var/datum/species/species = H.dna.species
		species.liked_food = initial(species.liked_food)
		species.disliked_food = initial(species.disliked_food)

//fucky
/datum/quirk/monochromatic
	name = "Monochromacy"
	desc = "You suffer from full colorblindness, and perceive nearly the entire world in blacks and whites."
	value = 0
	medical_record_text = "Patient is afflicted with almost complete color blindness."

/datum/quirk/monochromatic/add()
	quirk_holder.add_client_colour(/datum/client_colour/monochrome)

/datum/quirk/monochromatic/post_add()
	. = ..()
	if(quirk_holder.mind.assigned_role == "Detective")
		to_chat(quirk_holder, "<span class='boldannounce'>Mmm. Nothing's ever clear on this station. It's all shades of gray...</span>")
		quirk_holder.playsound_local(quirk_holder, 'sound/ambience/ambidet1.ogg', 50, FALSE)

/datum/quirk/monochromatic/remove()
	if(quirk_holder)
		quirk_holder.remove_client_colour(/datum/client_colour/monochrome)

//no like alcol
/datum/quirk/alcohol_lightweight  
	name = "Alcoholic Lightweight"
	desc = "Alcohol really goes straight to your head, gotta be careful with what you drink."
	value = 0
	mob_trait = TRAIT_ALCOHOL_LIGHTWEIGHT
	gain_text = "<span class='notice'>You feel woozy thinking of alcohol.</span>"
	lose_text = "<span class='notice'>You regain your stomach for drinks.</span>"

//synth thing (doing it as an actual species thing would be wayyy harder to do).
/datum/quirk/synthetic
	name = "Synthetic"
	desc = "You're not actually the species you seem to be. You're a synth! You generally function in the same manner as IPCs, but with a organic skin hiding your true self."
	value = 0
	mob_trait = TRAIT_SYNTH
	languagewhitelist = list("Encoded Audio Language")
	var/list/blacklistedspecies = list(/datum/species/synth, /datum/species/android, /datum/species/ipc, /datum/species/synthliz, /datum/species/shadow, /datum/species/plasmaman, /datum/species/jelly, /datum/species/jelly/slime)

/datum/quirk/synthetic/special_requirement_check(mob/living/carbon/human/imbecile)
	. = ..()
	if(imbecile?.dna?.species?.type in blacklistedspecies)
		return FALSE

/datum/quirk/synthetic/post_add()
	sleep(1 SECONDS)
	var/mob/living/carbon/human/H = quirk_holder
	if(istype(H))
		if(!(H.dna.species.type in blacklistedspecies))
			H.set_species(/datum/species/synth) //the synth on_gain stuff handles everything, that's why i made this shit a quirk and not a roundstart race or whatever
			return TRUE
	addtimer(CALLBACK(src, .proc/remove), 1 SECONDS)

/datum/quirk/synthetic/remove()
	var/mob/living/carbon/human/H = quirk_holder
	if(H)
		var/datum/species/thespecies = H.dna.species
		if(thespecies.type == /datum/species/synth)
			var/datum/species/synth/synthspecies = thespecies
			var/datum/species/oldspecies = synthspecies.fake_species
			if(oldspecies)
				H.set_species(oldspecies)
			else
				H.set_species(/datum/species/ipc) //we fall back on IPC if something stinky happens. Shouldn't happe but you know.
				to_chat(H, "<span class='warning'>Uh oh, stinky! Something poopy happened to your fake species! You have been set to an IPC as a fallback.</span>") //shouldn't happen. if it does uh oh.
		else
			to_chat(H, "<span class='warning'>The [H.dna.species.name] species is blacklisted from being a synth. You will stay with the normal, non-synth race. It could mean that Bob Joga broke the code too.</span>")

//uncontrollable laughter
/datum/quirk/joker
	name = "Pseudobulbar Affect"
	desc = "At random intervals, you suffer uncontrollable bursts of laughter."
	value = 0
	medical_record_text = "Patient suffers with sudden and uncontrollable bursts of laughter."
	var/pcooldown = 0
	var/pcooldown_time = 60 SECONDS

/datum/quirk/joker/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	if(H && istype(H))
		var/obj/item/paper/joker/laughing = new(get_turf(H))
		H.put_in_active_hand(laughing)

/obj/item/paper/joker
	name = "disability card"
	icon = 'modular_skyrat/icons/obj/card.dmi'
	icon_state = "joker"
	desc = "Smile, though your heart is aching."
	info = "<i>\
			<div style='border-style:solid;text-align:center;border-width:5px;margin: 20px;margin-bottom:0px'>\
			<div style='margin-top:20px;margin-bottom:20px;font-size:150%;'>\
			Forgive my laughter:<br>\
			I have a condition.\
			</div>\
			</div>\
			</i>\
			<br>\
			<center>\
			<b>\
			MORE ON BACK\
			</b>\
			</center>"
	var/info2 = "<i>\
			<div style='border-style:solid;text-align:center;border-width:5px;margin: 20px;margin-bottom:0px'>\
			<div style='margin-top:20px;margin-bottom:20px;font-size:100%;'>\
			<b>\
			It's a medical condition causing sudden,<br>\
			frequent and uncontrollable laughter that<br>\
			doesn't match how you feel.<br>\
			It can happen in people with a brain injury<br>\
			or certain neurological conditions.<br>\
			</b>\
			</div>\
			</div>\
			</i>\
			<br>\
			<center>\
			<b>\
			KINDLY RETURN THIS CARD\
			</b>\
			</center>"
	var/flipped = FALSE

/obj/item/paper/joker/update_icon()
	..()
	icon_state = "joker"

/obj/item/paper/joker/AltClick(mob/living/carbon/user, obj/item/I)
	if(flipped)
		info = initial(info)
		flipped = FALSE
		to_chat(user, "<span class='notice'>You unflip the card.</span>")
	else
		info = info2
		flipped = TRUE
		to_chat(user, "<span class='notice'>You flip the card.</span>")

/datum/quirk/joker/process()
	if(pcooldown > world.time)
		return
	pcooldown = world.time + pcooldown_time
	var/mob/living/carbon/human/H = quirk_holder
	if(H && istype(H))
		if(H.stat == CONSCIOUS)
			if(prob(20))
				H.emote("laugh")
				addtimer(CALLBACK(H, /mob/proc/emote, "laugh"), 5 SECONDS)
				addtimer(CALLBACK(H, /mob/proc/emote, "laugh"), 10 SECONDS)

//Mime
/datum/quirk/french
	name = "French Jester"
	desc = "Those frivolous jesters know not of true entertainment! You are the superior french man - A mime."
	job_whitelist = list("Clown")
	medical_condition = FALSE

/datum/quirk/french/on_spawn()
	. = ..()
	var/mob/living/carbon/human/retard = quirk_holder
	var/datum/outfit/job/mime/outfit = new()
	retard.equipOutfit(outfit)
	var/datum/job/mime/meme = new()
	meme.assign_skills_stats(retard)
	meme.special_assign_skills_stats(retard)

//Qu'est-ce que c'est?
/datum/quirk/psycho
	name = "Paranoid Schizophrenic"
	desc = "The crew is out to get you. No... You won't let them do it! They won't get you!"
	medical_condition = FALSE

/datum/quirk/psycho/on_spawn()
	. = ..()
	quirk_holder.mind.add_antag_datum(/datum/antagonist/schizoid)
	quirk_holder.mind.announce_objectives()

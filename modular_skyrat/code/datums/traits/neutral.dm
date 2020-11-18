//synth thing (doing it as an actual species thing would be wayyy harder to do).
/datum/quirk/synthetic
	name = "Synthetic"
	desc = "You're not actually the species you seem to be. You're a synth! You generally function in the same manner as IPCs, but with a organic skin hiding your true self."
	value = 0
	mob_trait = TRAIT_SYNTH
	languagewhitelist =list("Encoded Audio Language")
	var/list/blacklistedspecies = list(/datum/species/synth, /datum/species/android, /datum/species/ipc, /datum/species/synthliz, /datum/species/shadow, /datum/species/plasmaman, /datum/species/jelly, /datum/species/jelly/slime)

/datum/quirk/synthetic/add()
	sleep(10)
	var/mob/living/carbon/human/H = quirk_holder
	if(istype(H))
		if(!(H.dna.species.type in blacklistedspecies))
			H.set_species(/datum/species/synth) //the synth on_gain stuff handles everything, that's why i made this shit a quirk and not a roundstart race or whatever
			return TRUE
	addtimer(CALLBACK(src, .proc/remove), 10)

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
				to_chat(H, "<span class='warning'>Uh oh, stinky! Something poopy happened to your fakespecies! You have been set to an IPC as a fallback.</span>") //shouldn't happen. if it does uh oh.
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
	name = "French Clown"
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

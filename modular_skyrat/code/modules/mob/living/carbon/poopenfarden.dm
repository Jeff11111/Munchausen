//Shitting and pissing verbs
/mob/living/carbon/verb/shit()
	set name = "Defecate"
	set category = "IC"
	set desc = "You shouldn't do this while clothed."
	return defecate(TRUE)

/mob/living/carbon/verb/piss()
	set name = "Urinate"
	set category = "IC"
	set desc = "You shouldn't do this while clothed."
	return urinate(TRUE)

/mob/living/carbon/proc/defecate(intentional = FALSE)
	if(defecation < 30)
		if(intentional)
			to_chat(src, "<span class='notice'>I don't have to.</span>")
		return
	if(stat >= DEAD)
		if(intentional)
			to_chat(src, "<span class='notice'>The dead can't crap.</span>")
		return
	var/obj/item/organ/intestines = getorganslot(ORGAN_SLOT_INTESTINES)
	if(!intestines || !intestines.is_working())
		if(intentional)
			to_chat(src, "<span class='warning'>I don't have functional intestines!</span>")
		return
	var/obj/item/clothing/underwear/socks/poopsock = locate() in get_turf(src)
	var/obj/structure/toilet/toiler = locate() in get_turf(src)
	//Decent poop
	if(toiler)
		visible_message("<span class='notice'><b>[src]</b> shits on [toiler].</span>", \
					"<span class='notice'>I take a shit on [toiler]. Sweet relief.")
	//Secret poop
	else if(poopsock && !findtext(poopsock.name, "poop"))
		visible_message("<span class='notice'><b>[src]</b> shits inside \the [poopsock].</span>", \
					"<span class='nicegreen'>I take a shit inside \the [poopsock]. <b>Classic!</b></span>")
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "poop_in_sock", /datum/mood_event/shit_on_sock)
		poopsock.name = "poop sock"
		poopsock.desc = "A sock which has been used for defecation. Vile."
		poopsock.add_atom_colour("#643200", 1)
		poopsock.force += 10
		poopsock.item_flags &= ~NOBLUDGEON
	//Poo on the loo
	else
		visible_message("<span class='boldwarning'><b>[src]</b> poos on the loo!</span>",
					"<span class='notice'>I poo on the loo.</span>")
		var/turf/T = get_turf(src)
		new /obj/item/reagent_containers/food/snacks/shit(T)
	defecation -= rand(60,80)
	playsound(get_turf(src), 'modular_skyrat/sound/effects/poo.ogg', 80)

/mob/living/carbon/proc/urinate(intentional = FALSE)
	if(urination < 30)
		if(intentional)
			to_chat(src, "<span class='notice'>I don't have to.</span>")
		return
	if(stat >= DEAD)
		if(intentional)
			to_chat(src, "<span class='notice'>The dead can't pee.</span>")
		return
	var/obj/item/organ/bladder/bladder = getorganslot(ORGAN_SLOT_BLADDER)
	if(!bladder || !bladder.is_working())
		if(intentional)
			to_chat(src, "<span class='warning'>I don't have a functional bladder!</span>")
		return
	var/obj/item/organ/genital/penis = getorganslot(ORGAN_SLOT_PENIS)
	var/obj/structure/sink/sinker = locate() in get_turf(src)
	var/obj/structure/toilet/toiler = locate() in get_turf(src)
	var/obj/structure/urinal/urinel = locate() in get_turf(src)
	//Gentleman's piss
	if(urinel)
		visible_message("<span class='notice'><b>[src]</b> pisses on [urinel].</span>", \
					"<span class='notice'>I take a piss on [urinel]. Sweet relief.")
	//Decent piss
	else if(toiler)
		visible_message("<span class='notice'><b>[src]</b> pisses on [toiler].</span>", \
					"<span class='notice'>I take a piss on [toiler]. Sweet relief.")
	//Secret piss
	else if(sinker && penis)
		visible_message("<span class='notice'><b>[src]</b> pisses on [sinker].</span>", \
					"<span class='nicegreen'>I take a piss on [sinker]. <b>Classic!</b></span>")
		SEND_SIGNAL(src, COMSIG_ADD_MOOD_EVENT, "pee_in_sink", /datum/mood_event/piss_on_sink)
	//Floor piss
	else
		visible_message("<span class='boldwarning'><b>[src]</b> pisses on the floor!</span>",
					"<span class='notice'>I pee on the floor.</span>")
		var/turf/T = get_turf(src)
		new /obj/effect/decal/cleanable/piss(T)
	urination -= rand(25,50)
	urination = max(0, urination)
	playsound(get_turf(src), 'modular_skyrat/sound/effects/pee.ogg', 60)

/datum/quirk/family_heirloom
	medical_condition = FALSE

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

/datum/quirk/disaster_artist
	name = "Disaster Artist"
	desc = "<span class='warning'>I always manage to wreak havoc on everything I touch.</span>"
	value = -2
	mob_trait = TRAIT_CLUMSY
	medical_record_text = "Patient lacks proper spatial awareness."

/datum/quirk/screwy_mood
	name = "Alexithymia"
	desc = "<span class='warning'>I cannot accurately assess my feelings.</span>"
	value = -1
	mob_trait = TRAIT_SCREWY_MOOD
	medical_record_text = "Patient is incapable of communicating their emotions."

/datum/quirk/hemophiliac
	name = "Hemophiliac"
	desc = "<span class='warning'>My body is bad at coagulating blood. Bleeding will be twice as bad when compared to the average person.</span>"
	value = -3
	mob_trait = TRAIT_HEMOPHILIA
	medical_record_text = "Patient has abnormal blood coagulation behavior."

/datum/quirk/asthmatic
	name = "Asthmatic"
	desc = "<span class='warning'>I have been diagnosed with asthma. I can only run half of what a healthy person can, and running causes me to lose my breath.</span>"
	value = -2
	mob_trait = TRAIT_ASTHMATIC
	medical_record_text = "Patient is asthmatic."

//frail
/datum/quirk/frail
	name = "Frail"
	desc = "<span class='warning'>My whole body is weak! I suffer wounds much more easily than most.</span>"
	value = -3
	mob_trait = TRAIT_EASYLIMBDISABLE
	gain_text = "<span class='danger'>You feel frail.</span>"
	lose_text = "<span class='notice'>You feel sturdy again.</span>"
	medical_record_text = "Patient's body is fragile, and tends to suffer more damage from all sources."

//paper skin
/datum/quirk/paper_skin
	name = "Paper skin"
	desc = "<span class='warning'>My skin is fragile and breaks apart easily. I am susceptible to slash and puncture wounds.</span>"
	value = -2
	mob_trait = TRAIT_EASYCUT
	medical_record_text = "Patient's skin is frail, and  tends to be cut and punctured quite easily."

//hollow bones
/datum/quirk/hollow_bones
	name = "Hollow bones"
	desc = "<span class='warning'>My bones are fragile, and break easily. I am susceptible to blunt wounds.</span>"
	value = -2
	mob_trait = TRAIT_EASYBLUNT
	medical_record_text = "Patient's bones are fragile, and tend to be easily fractured."

//flammable skin
/datum/quirk/flammable_skin
	name = "Flammable skin"
	desc = "<span class='warning'>My skin is quite easy to set on fire. I am susceptible to burn wounds.</span>"
	value = -2
	mob_trait = TRAIT_EASYBURN
	medical_record_text = "Patient's skin is unnaturally flammable, and tends to be easily burnt."

//xavleg
/datum/quirk/xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx
	name = "Xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx"
	desc = "<span class='warning'>This is my name.</span>"

/datum/quirk/xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx/add()
	. = ..()
	quirk_holder.real_name = "Xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx"
	quirk_holder.name = "Xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx"

//poor
/datum/quirk/endebted
	name = "Endebted"
	desc = "<span class='warning'>I owe corporate a lot of money. They took everything out of my account.</span>"

/datum/quirk/endebted/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/card/id/id = H.get_idcard()
	if(id)
		var/datum/bank_account/B = id.registered_account
		B.adjust_money(-B.account_balance)

//hunted
/datum/quirk/hunted
	name = "Hunted"
	desc = "<span class='warning'>I have a secret enemy, I dread that I will know who they are soon...</span>"

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

//fetal alcohol syndrome
/datum/quirk/fas
	name = "Fetal Alcohol Syndrome"
	desc = "<span class='warning'>I have fetal alcohol syndrome. My mother didn't care for me.</span>"

/datum/quirk/fas/on_spawn()
	. = ..()
	for(var/datum/stats/fuck in quirk_holder.mind.mob_stats)
		fuck.level = clamp(fuck.level - 2, MIN_STAT, MAX_STAT)

//nigger
/datum/quirk/nigger
	name = "Nigger"
	desc = "<span class='warning'>My skin is as dark as charcoal.</span>"

/datum/quirk/nigger/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	H.skin_tone = "african2"
	var/firstname = pick("Nigga", "Nigger", "Tyrone", "Brutus", "Uganda", "Nigeria", "Fifty Cent", "Big Smoke", "Carl Johnson", "Black Lives")
	var/lastname = pick("Africa", "Africanus", "Niggerius", "Watermelon", "Watermelonium","Cottonpicker", "George Floyd", "Tupac", "Lamp", "Obama", "Matter")
	H.fully_replace_character_name(H.real_name, "[firstname] [lastname]")

//pure blooded aryan
/datum/quirk/aryan
	name = "Aryan"
	desc = "<span class='warning'>My skin is as white as snow.</span>"

/datum/quirk/aryan/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	H.skin_tone = "albino"
	var/firstname = pick("Hitler", "Adolf", "German", "Prussian-German", "Neo-Nazi", "Holocaust Denial", "Trump", "Racist", "Nordic", "Sigismund", "Fascist")
	var/lastname = pick("Ethnicity", "Christchurch", "For-Chan", "Pol", "White Pride", "Steinhäuser", "Hitler", "Nietzsche", "Skyrim")
	H.fully_replace_character_name(H.real_name, "[firstname] [lastname]")

//british
/datum/quirk/british
	name = "British"
	desc = "<span class='warning'>The tea has completely rotted away my guns.</span>"

/datum/quirk/british/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/bodypart/feefh = H.get_bodypart(BODY_ZONE_HEAD)
	feefh.knock_out_teeth(feefh.max_teeth)

/datum/quirk/anemic
	name = "Anemia stricken"
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

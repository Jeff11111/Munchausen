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
		"in your left pocket" = SLOT_L_STORE,
		"in your right pocket" = SLOT_R_STORE,
		"in your backpack" = SLOT_IN_BACKPACK
	)
	where = H.equip_in_one_of_slots(heirloom, slots, FALSE) || "at your feet"

/datum/quirk/family_heirloom/proc/deleting_heirloom()
	GLOB.family_heirlooms -= heirloom
	UnregisterSignal(heirloom, COMSIG_PARENT_QDELETING)
	heirloom = null

/datum/quirk/disaster_artist
	name = "Disaster Artist"
	desc = "You always manage to wreak havoc on everything you touch."
	value = -2
	mob_trait = TRAIT_CLUMSY
	medical_record_text = "Patient lacks proper spatial awareness."

/datum/quirk/screwy_mood
	name = "Alexithymia"
	desc = "You cannot accurately assess your feelings."
	value = -1
	mob_trait = TRAIT_SCREWY_MOOD
	medical_record_text = "Patient is incapable of communicating their emotions."

/datum/quirk/hemophiliac
	name = "Hemophiliac"
	desc = "Your body is bad at coagulating blood. Bleeding will always be two times worse when compared to the average person."
	value = -3
	mob_trait = TRAIT_HEMOPHILIA
	medical_record_text = "Patient exhibits abnormal blood coagulation behavior."

/datum/quirk/asthmatic
	name = "Asthmatic"
	desc = "You have been diagnosed with asthma. You can only run half of what a healthy person can, and running may cause oxygen damage."
	value = -2
	mob_trait = TRAIT_ASTHMATIC
	medical_record_text = "Patient exhibits asthmatic symptoms."

//frail
/datum/quirk/frail
	name = "Frail"
	desc = "Your whole body is quite weak! You suffer wounds much more easily than most."
	value = -3
	mob_trait = TRAIT_EASYLIMBDISABLE
	gain_text = "<span class='danger'>You feel frail.</span>"
	lose_text = "<span class='notice'>You feel sturdy again.</span>"
	medical_record_text = "Patient's body is fragile, and tends to suffer more damage from all sources."

//paper skin
/datum/quirk/paper_skin
	name = "Paper skin"
	desc = "Your skin is fragile, and breaks apart easily. You are twice as susceptible to slash and puncture wounds."
	value = -2
	mob_trait = TRAIT_EASYCUT
	medical_record_text = "Patient's skin is frail, and  tends to be cut and punctured quite easily."

//hollow bones
/datum/quirk/hollow_bones
	name = "Hollow bones"
	desc = "Your bones are fragile, and break easily. You are twice as susceptible to blunt wounds."
	value = -2
	mob_trait = TRAIT_EASYBLUNT
	medical_record_text = "Patient's bones are fragile, and tend to be easily fractured."

//flammable skin
/datum/quirk/flammable_skin
	name = "Flammable skin"
	desc = "Your skin is quite easy to set on fire. You are twice as susceptible to burn wounds."
	value = -2
	mob_trait = TRAIT_EASYBURN
	medical_record_text = "Patient's skin is unnaturally flammable, and tends to be easily burnt."

//xavleg
/datum/quirk/xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx
	name = "Xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx"
	desc = "Your name is really long."

/datum/quirk/xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx/add()
	. = ..()
	quirk_holder.real_name = "Xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx"
	quirk_holder.name = "Xavlegbmaofffassssitimiwoamndutroabcwapwaeiippohfffx"

//poor
/datum/quirk/endebted
	name = "Endebted"
	desc = "You owe corporate a lot of money. You start the shift with no money on your account."

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
	desc = "You have a secret enemy, you know they'll attack soon."

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
	desc = "For whatever reason, you cannot be revived in any way."
	value = 0
	gain_text = "<span class='notice'>Your spirit gets too scarred to accept revival.</span>"
	lose_text = "<span class='notice'>You can feel your soul healing again.</span>"
	mob_trait = TRAIT_DNR

//fetal alcohol syndrome
/datum/quirk/fas
	name = "Fetal Alcohol Syndrome"
	desc = "Mommy did bath salts when she was pregnant. -2 to every stat."

/datum/quirk/fas/on_spawn()
	. = ..()
	for(var/datum/stats/fuck in quirk_holder.mind.mob_stats)
		fuck.level = clamp(fuck.level - 2, MIN_STAT, MAX_STAT)

//nigger
/datum/quirk/nigger
	name = "Nigger"
	desc = "You skin is as dark as charcoal."

/datum/quirk/nigger/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	H.skin_tone = "african2"
	var/firstname = pick("Nigga", "Nigger", "Tyrone", "Brutus", "Uganda", "Nigeria", "Fifty Cent", "Big Smoke", "Carl Johnson", "Black Lives")
	var/lastname = pick("Africa", "Africanus", "Niggerius", "Watermelon", "Watermelonium","Cottonpicker", "George Floyd", "Tupac", "Lamp", "Obama", "Matter")
	H.name = "[firstname] [lastname]"
	H.real_name = "[firstname] [lastname]"

//pure blooded aryan
/datum/quirk/aryan
	name = "Aryan"
	desc = "You skin is as white as snow."

/datum/quirk/aryan/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	H.skin_tone = "albino"
	var/firstname = pick("Hitler", "Adolf", "German", "Prussian-German", "Neo-Nazi", "Holocaust Denial", "Trump", "Racist", "Nordic", "Sigismund", "Fascist")
	var/lastname = pick("Ethnicity", "Christchurch", "For-Chan", "Pol", "White Pride", "Steinhäuser", "Hitler", "Nietzsche", "Skyrim")
	H.name = "[firstname] [lastname]"
	H.real_name = "[firstname] [lastname]"

//british
/datum/quirk/british
	name = "British"
	desc = "Oi mate! Looks like tha' tea rotted away ya gums!"

/datum/quirk/british/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/bodypart/feefh = H.get_bodypart(BODY_ZONE_HEAD)
	feefh.knock_out_teeth(feefh.max_teeth)

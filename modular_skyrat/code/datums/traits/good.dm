//fists of steel
/datum/quirk/steel_fists
	name = "Fists of steel"
	desc = "You are exceptionally good at unarmed combat. Punching and clawing will deal more damage."
	value = 3
	medical_record_text = "Patient is skilled in hand to hand combat."

/datum/quirk/steel_fists/add()
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = quirk_holder
		if(H && istype(H))
			H.dna.species.punchdamagehigh += 5
			H.dna.species.punchdamagelow += 5
			H.dna.species.punchstunthreshold += 5

//pain man good
//(turns masochist into a proper non-meme quirk)
/datum/quirk/maso
	name = "Masochism"
	desc = "You are wired differently. While pain still has negative impacts on you, it also greatly improves your mood."
	mob_trait = TRAIT_PAINGOOD
	value = 1

//no pain no gain
/datum/quirk/painless
	name = "The Painless"
	desc = "Throughout your whole life you have struggled with feeling no pain. Maybe that is not so bad on this cursed station..."
	mob_trait = TRAIT_NOPAIN

//rich
/datum/quirk/wealthy
	name = "Wealthy"
	desc = "You were born to a very wealthy family! You start the shift with +2k credits."

/datum/quirk/wealthy/on_spawn()
	. = ..()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/card/id/id = H.get_idcard()
	if(id)
		var/datum/bank_account/B = id.registered_account
		B.adjust_money(2000)

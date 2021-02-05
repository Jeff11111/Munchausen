/datum/species/ipc
	species_traits = list(MUTCOLORS_PARTSONLY,NOEYES,NOTRANSSTING,NOZOMBIE,REVIVESBYHEALING,NOHUSK,ROBOTIC_LIMBS,NO_DNA_COPY,HAIR,HAS_FLESH,HAS_BONE,NOAPPENDIX)
	mutant_bodyparts = list("ipc_screen" = "Blank", "ipc_antenna" = "None", "ipc_chassis" = "Morpheus Cyberkinetics(Greyscale)")
	inherent_traits = list(TRAIT_RADIMMUNE,TRAIT_TOXIMMUNE,TRAIT_CLONEIMMUNE,TRAIT_DNC,TRAIT_NOHYDRATION,TRAIT_NOBREATH)
	coldmod = 0.5
	toxmod = 0
	clonemod = 0
	siemens_coeff = 1.2 //Not more because some shocks will outright crit you, which is very unfun
	revivesbyhealreq = 50
	reagent_flags = PROCESS_SYNTHETIC
	mutant_organs = list(/obj/item/organ/cyberimp/arm/power_cord)
	mutantbrain = /obj/item/organ/brain/ipc_positron
	mutantstomach = /obj/item/organ/stomach/robot_ipc
	mutantears = /obj/item/organ/ears/robot_ipc
	mutanttongue = /obj/item/organ/tongue/robot_ipc
	mutantlungs = /obj/item/organ/lungs/robot_ipc
	mutantheart = /obj/item/organ/heart/robot_ipc
	mutantliver = /obj/item/organ/liver/robot_ipc
	mutantkidneys = /obj/item/organ/kidneys/robot_ipc
	mutantspleen = /obj/item/organ/spleen/robot_ipc
	mutantintestines = /obj/item/organ/intestines/robot_ipc
	mutantbladder = /obj/item/organ/bladder/robot_ipc
	exotic_bloodtype = "HF"
	icon_limbs = 'modular_skyrat/icons/mob/ipc/ipc_parts.dmi'
	hair_alpha = 150
	var/saved_screen
	languagewhitelist = list("Encoded Audio Language")
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/ipc

/datum/species/ipc/spec_death(gibbed, mob/living/carbon/C)
	spawn(0)
		saved_screen = C.dna.features["ipc_screen"]
		C.dna.features["ipc_screen"] = "BSOD"
		C.update_body()
		sleep(3 SECONDS)
		C.dna.features["ipc_screen"] = null // Turns off their monitor on death.
		C.update_body()

/datum/species/ipc/on_species_gain(mob/living/carbon/C) // Let's make that IPC actually robotic.
	. = ..()
	var/obj/item/organ/appendix/appendix = C.getorganslot(ORGAN_SLOT_APPENDIX) // Easiest way to remove it.
	if(appendix)
		appendix.Remove(C)
		qdel(appendix)
	var/chassis = C.dna.features["ipc_chassis"]
	var/datum/sprite_accessory/ipc_chassis/chassis_of_choice = GLOB.ipc_chassis_list[chassis]
	if(chassis_of_choice)
		if(chassis_of_choice.color_src)
			C.dna.species.species_traits += MUTCOLORS
		C.dna.species.limbs_id = chassis_of_choice.icon_state
	for(var/obj/item/bodypart/O in C.bodyparts)
		O.synthetic = TRUE
	C.AddComponent(/datum/component/boombox)

/datum/species/ipc/on_species_loss(mob/living/carbon/C)
	. = ..()
	var/datum/component/bingus = C.GetComponent(/datum/component/boombox)
	if(bingus)
		qdel(bingus)

/datum/species/ipc/spec_revival(mob/living/carbon/human/H)
	H.dna.features["ipc_screen"] = "BSOD"
	H.update_body()
	H.say("Reactivating [pick("core systems", "central subroutines", "key functions")]...")
	sleep(3 SECONDS)
	H.say("Reinitializing [pick("personality matrix", "behavior logic", "morality subsystems")]...")
	sleep(3 SECONDS)
	H.say("Finalizing setup...")
	sleep(3 SECONDS)
	H.say("Unit [H.real_name] is fully functional. Have a nice day.")
	H.dna.features["ipc_screen"] = saved_screen
	H.update_body()
	playsound(H, pick('modular_skyrat/sound/effects/95.ogg', 'modular_skyrat/sound/effects/xp.ogg'), 50, FALSE)
	return 

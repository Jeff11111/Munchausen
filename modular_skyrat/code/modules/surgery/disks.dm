
/obj/item/disk/surgery
	name = "Surgery Procedure Disk"
	desc = "A disk that contains advanced surgery procedures, must be loaded into an Operating Console."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)
	var/list/surgery_steps

/obj/item/disk/surgery/debug
	name = "Debug Surgery Disk"
	desc = "A disk that contains all existing surgery procedures."
	icon_state = "datadisk1"
	custom_materials = list(/datum/material/iron=300, /datum/material/glass=100)

/obj/item/disk/surgery/debug/Initialize()
	. = ..()
	surgery_steps = list()
	var/list/req_tech_surgeries = subtypesof(/datum/surgery_step)
	for(var/i in req_tech_surgeries)
		var/datum/surgery_step/bingus = i
		if(initial(bingus.requires_tech))
			surgery_steps += bingus

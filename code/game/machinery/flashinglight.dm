// not sure what I want to use these for yet
/obj/machinery/flashinglight
	name = "flashing light"
	desc = "h"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "bulb"
	var/strobe_color = "#ff3232"
	var/strobe_range = 3
	var/strobe_power = 2
	var/strobe_active = FALSE
	var/strobe_on = FALSE
	var/timeon = 10
	var/timeoff = 20

/obj/machinery/flashinglight/white
	strobe_color = "#ffffff"
	strobe_range = 4
	strobe_power = 4
	timeon = 1
	timeoff = 20

/obj/machinery/flashinglight/Initialize()
	. = ..()
	AddComponent(/datum/component/overlay_lighting, strobe_color, strobe_power, strobe_power, FALSE)

/obj/machinery/flashinglight/attackby(obj/item/I, mob/living/user, params) //delete this later on
	. = ..()
	if(!strobe_active)
		start()
	else
		stop()

/obj/machinery/flashinglight/proc/start()
	strobe_active = TRUE
	turn_on()

/obj/machinery/flashinglight/proc/stop()
	strobe_active = FALSE
	turn_off()

/obj/machinery/flashinglight/proc/turn_on()
	if(strobe_active)
		var/datum/component/overlay_lighting/OL = GetComponent(/datum/component/overlay_lighting)
		OL.turn_on()
		addtimer(CALLBACK(src, .proc/turn_off), timeon)

/obj/machinery/flashinglight/proc/turn_off()
	var/datum/component/overlay_lighting/OL = GetComponent(/datum/component/overlay_lighting)
	OL.turn_off()
	addtimer(CALLBACK(src, .proc/turn_on), timeoff)

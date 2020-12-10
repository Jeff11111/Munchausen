//stamina shit
/obj/screen/staminas
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	name = "fatigue"
	icon_state = "fatigue10"
	screen_loc = ui_stamina
	mouse_opacity = 1
	var/overfatigue = FALSE
	var/mutable_appearance/overfatigue_appearance

/obj/screen/staminas/Initialize()
	. = ..()
	overfatigue_appearance = mutable_appearance(icon, "overfatigue16")

/obj/screen/staminas/Click(location,control,params)
	var/list/paramslist = params2list(params)
	if(paramslist["shift"])
		overfatigue = !overfatigue
		to_chat(usr, "<span class='notice'>My overfatigue is now [overfatigue ? "visible" : "hidden"].</span>")
		update_icon()
		return
	
	if(isliving(usr))
		var/mob/living/L = usr
		var/msg = list("<span class='notice'>*---------*</span>")
		msg += "<span class='info'><b>Fatigue:</b></span>"
		msg += "<span class='notice'>I can stand <b>[L.maxHealth]</b> fatigue loss.</span>"
		msg += "<span class='notice'>I have <b>[L.getStaminaLoss()]</b> fatigue loss.</span>"
		msg += "<span class='info'><b>Overfatigue:</b></span>"
		msg += "<span class='notice'>My overfatigue can stand <b>[L.stambuffer]</b> overfatigue loss.</span>"
		msg += "<span class='notice'>My overfatigue buffer has <b>[L.bufferedstam]</b> overfatigue loss.</span>"
		msg += "<span class='notice'>*---------*</span>"
		to_chat(L, jointext(msg, "\n"))

/obj/screen/staminas/update_overlays()
	. = ..()
	if(overfatigue)
		. += overfatigue_appearance

/obj/screen/staminas/update_icon_state()
	var/mob/living/carbon/user = hud?.mymob
	if(!user)
		return
	
	//Fatigue
	if(user.stat == DEAD || (user.combat_flags & COMBAT_FLAG_HARD_STAMCRIT) || (user.hal_screwyhud in 1 to 2))
		icon_state = "fatigue0"
	else if((user.hal_screwyhud == SCREWYHUD_HEALTHY) || HAS_TRAIT(hud?.mymob, TRAIT_SCREWY_CHECKSELF))
		icon_state = "fatigue16"
	else
		icon_state = "fatigue[clamp(10 - CEILING(user.getStaminaLoss() / 10, 1), 0, 10)]"

	//Over fatigue
	if(user.stat == DEAD || (user.combat_flags & COMBAT_FLAG_HARD_STAMCRIT) || (user.hal_screwyhud in 1 to 2))
		overfatigue_appearance.icon_state = "overfatigue0"
	else if((user.hal_screwyhud == SCREWYHUD_HEALTHY) || HAS_TRAIT(hud?.mymob, TRAIT_SCREWY_CHECKSELF))
		overfatigue_appearance.icon_state = "overfatigue16"
	else
		overfatigue_appearance.icon_state = "overfatigue[clamp(CEILING((1 - (user.bufferedstam / user.stambuffer)) * 10, 1), 0, 16)]"

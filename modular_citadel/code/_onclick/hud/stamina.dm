/datum/hud/var/obj/screen/staminas/staminas
/datum/hud/var/obj/screen/staminabuffer/staminabuffer

/obj/screen/staminas
	icon = 'modular_skyrat/icons/mob/screen_gen.dmi'
	name = "fatigue"
	icon_state = "fatigue16"
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
		to_chat(usr, "<span class='notice'>Your overfatigue is now [overfatigue ? "visible" : "hidden"].</span>")
		update_icon()
		return
	if(isliving(usr))
		var/mob/living/L = usr
		to_chat(L, "<span class='notice'>You have <b>[L.getStaminaLoss()]</b> fatigue loss.<br>Your overfatigue can take <b>[L.stambuffer]</b> fatigue loss.<br>Your overfatigue buffer is <b>[(L.stambuffer*(100/L.stambuffer))-(L.bufferedstam*(100/L.stambuffer))]%</b> full.</span>")

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
		icon_state = "fatigue[clamp(16 - CEILING(user.getStaminaLoss() / 16, 1), 0, 16)]"
	//Over fatigue
	if(user.stat == DEAD || (user.combat_flags & COMBAT_FLAG_HARD_STAMCRIT) || (user.hal_screwyhud in 1 to 2))
		overfatigue_appearance.icon_state = "overfatigue0"
	else if((user.hal_screwyhud == SCREWYHUD_HEALTHY) || HAS_TRAIT(hud?.mymob, TRAIT_SCREWY_CHECKSELF))
		overfatigue_appearance.icon_state = "overfatigue16"
	else
		overfatigue_appearance.icon_state = "overfatigue[clamp(CEILING((user.bufferedstam / user.stambuffer) * 16, 1), 0, 16)]"

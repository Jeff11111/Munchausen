//Sprint button shit
/obj/screen/sprintbutton
	name = "sprint toggle"
	icon = 'modular_skyrat/icons/mob/screen/screen_nigga.dmi'
	icon_state = "act_sprint"
	layer = ABOVE_HUD_LAYER - 0.1
	var/mutable_appearance/flashy

/obj/screen/sprintbutton/Click()
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		H.default_toggle_sprint()

/obj/screen/sprintbutton/update_icon_state()
	var/mob/living/user = hud?.mymob
	if(!istype(user))
		return
	if(user.combat_flags & COMBAT_FLAG_SPRINT_ACTIVE)
		icon_state = "[initial(icon_state)]_on"
	else if(HAS_TRAIT(user, TRAIT_SPRINT_LOCKED))
		icon_state = "[initial(icon_state)]_locked"
	else
		icon_state = initial(icon_state)

/obj/screen/sprintbutton/update_overlays()
	. = ..()
	var/mob/living/carbon/user = hud?.mymob
	if(!istype(user) || !user.client)
		return

	if((user.combat_flags & COMBAT_FLAG_SPRINT_ACTIVE) && user.client.prefs.hud_toggle_flash)
		if(!flashy)
			flashy = mutable_appearance('icons/mob/screen_gen.dmi', "togglehalf_flash")
		if(flashy.color != user.client.prefs.hud_toggle_color)
			flashy.color = user.client.prefs.hud_toggle_color
		. += flashy

//Sprint buffer onscreen code
/obj/screen/sprint_buffer
	name = "sprint buffer"
	icon = 'icons/effects/progessbar.dmi'
	icon_state = "prog_bar_100"

/obj/screen/sprint_buffer/Click()
	if(isliving(usr))
		var/mob/living/L = usr
		var/msg = list("<span class='notice'>*---------*</span>")
		msg += "<span class='notice'>Your sprint buffer's maximum capacity is [L.sprint_buffer_max].</span>"
		msg += "<span class='notice'>It is currently at [L.sprint_buffer], regenerating at [L.sprint_buffer_regen_ds * 10] per second.</span>"
		msg += "<span class='notice'>Sprinting while this is empty will incur a [L.sprint_stamina_cost] stamina cost per tile.</span>"
		msg += "<span class='notice'>*---------*</span>"
		to_chat(L, jointext(msg, "\n"))

/obj/screen/sprint_buffer/proc/update_to_mob(mob/living/L)
	var/amount = 0
	if(L.sprint_buffer_max > 0)
		amount = round(clamp((L.sprint_buffer / L.sprint_buffer_max) * 100, 0, 100), 5)
	icon_state = "prog_bar_[amount]"

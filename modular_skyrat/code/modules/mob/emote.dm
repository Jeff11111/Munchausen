/obj/effect/overlay/emote_popup
	icon = 'modular_skyrat/icons/mob/popup_flicks.dmi'
	icon_state = "combat"
	layer = FLY_LAYER
	plane = GAME_PLANE
	appearance_flags = APPEARANCE_UI_IGNORE_ALPHA | KEEP_APART
	mouse_opacity = 0

/proc/flick_emote_popup_on_mob(mob/M, state, time)
	var/obj/effect/overlay/emote_popup/I = new
	I.icon_state = state
	M.vis_contents += I
	animate(I, alpha = 255, time = 5, easing = BOUNCE_EASING, pixel_y = 10)
	QDEL_IN_CLIENT_TIME(I, time)

/mob/emote(act, m_type = null, message = null, intentional = FALSE)
	. = ..()
	set_typing_indicator(FALSE)

/datum/emote/living/quill
	key = "quill"
	key_third_person = "quills"
	message = "rustles their quills."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)
	sound = 'modular_skyrat/sound/emotes/voxrustle.ogg'

/datum/emote/living/scream/run_emote(mob/living/user, params) //I can't not port this shit, come on.
	sound = null
	var/miming = user.mind ? user.mind.miming : 0
	if(!user.is_muzzled() && !miming)
		user.nextsoundemote = world.time + 7
		if(issilicon(user))
			sound = 'modular_citadel/sound/voice/scream_silicon.ogg'
			if(iscyborg(user))
				var/mob/living/silicon/robot/S = user
				if(S.cell?.charge < 20)
					to_chat(S, "<span class='warning'>Scream module deactivated. Please recharge.</span>")
					return
				S.cell.use(200)
		if(ismonkey(user))
			sound = 'modular_citadel/sound/voice/scream_monkey.ogg'
		if(istype(user, /mob/living/simple_animal/hostile/gorilla))
			sound = 'sound/creatures/gorilla.ogg'
		if(ishuman(user))
			user.adjustOxyLoss(3)
			var/mob/living/carbon/human/H = user
			var/datum/species/userspecies = H.dna.species
			if(H)
				if(userspecies.screamsounds.len)
					sound = pick(userspecies.screamsounds)
				if(H.gender == FEMALE)
					if(userspecies.femalescreamsounds.len)
						sound = pick(userspecies.femalescreamsounds)
		if(isalien(user))
			sound = 'sound/voice/hiss6.ogg'
		LAZYINITLIST(user.alternate_screams)
		if(LAZYLEN(user.alternate_screams))
			sound = pick(user.alternate_screams)
		playsound(user.loc, sound, 50, 1, 4, 1.2)
		message = "screams!"
	else if(miming)
		message = "acts out a scream."
	else
		message = "makes a very loud noise."
	. = ..()

/datum/emote/living/peep
	key = "peep"
	key_third_person = "peeps like a bird"
	message = "peeps like a bird!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)
	sound = 'modular_skyrat/sound/voice/peep_once.ogg'

/datum/emote/living/peep2
	key = "peep2"
	key_third_person = "peeps twice like a bird"
	message = "peeps twice like a bird!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)
	sound = 'modular_citadel/sound/voice/peep.ogg'

/datum/emote/living/quietnoise
	key = "quietnoise"
	key_third_person = "quietnoises"
	message = "makes a quiet noise."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE

/datum/emote/living/loudnoise
	key = "loudnoise"
	key_third_person = "loudnoises"
	message = "makes a loud noise!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE

#define INSULTS_FILE "insult.json"

/mob
	var/nextsoundemote = 1

//Disables the custom emote blacklist from TG that normally applies to slimes.
/datum/emote/living/custom
	mob_type_blacklist_typecache = list(/mob/living/brain)

/datum/emote/living/insult
	key = "insult"
	key_third_person = "insults"
	message = "spews insults."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/insult/run_emote(mob/living/user, params)
	if(user.mind?.miming)
		message = "creatively gesticulates."
	else if(!user.is_muzzled())
		message = pick_list_replacements(INSULTS_FILE, "insult_gen")
	else
		message = "muffles something."
	. = ..()

/datum/emote/living/snap
	key = "snap"
	key_third_person = "snaps"
	message = "snaps their fingers."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/snap/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/snap.ogg', 50, 1, -1)

/datum/emote/living/snap2
	key = "snap2"
	key_third_person = "snaps twice"
	message = "snaps twice."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/snap2/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/snap2.ogg', 50, 1, -1)

/datum/emote/living/snap3
	key = "snap3"
	key_third_person = "snaps thrice"
	message = "snaps thrice."
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = TRUE
	restraint_check = TRUE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/snap3/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/snap3.ogg', 50, 1, -1)

/datum/emote/living/awoo
	key = "awoo"
	key_third_person = "lets out an awoo"
	message = "lets out an awoo!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/awoo/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/awoo.ogg', 50, 1, -1)

/datum/emote/living/nya
	key = "nya"
	key_third_person = "lets out a nya"
	message = "lets out a nya!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/nya/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/nya.ogg', 50, 1, -1)

/datum/emote/living/weh
	key = "weh"
	key_third_person = "lets out a weh"
	message = "lets out a weh!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/weh/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/weh.ogg', 50, 1, -1)

// Skyrat change start
/* MOVED TO MODULAR (modular_skyrat/code/modules/mob/emote.dm)
/datum/emote/living/peep
	key = "peep"
	key_third_person = "peeps like a bird"
	message = "peeps like a bird!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/peep/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/peep.ogg', 50, 1, -1)
*/
// Skyrat change stop

/datum/emote/living/dab
	key = "dab"
	key_third_person = "suddenly hits a dab"
	message = "suddenly hits a dab!"
	emote_type = EMOTE_AUDIBLE
	restraint_check = TRUE

/datum/emote/living/mothsqueak
	key = "msqueak"
	key_third_person = "lets out a tiny squeak"
	message = "lets out a tiny squeak!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/mothsqueak/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/mothsqueak.ogg', 50, 1, -1)

/datum/emote/living/merp
	key = "merp"
	key_third_person = "merps"
	message = "merps!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/merp/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	playsound(user, 'modular_citadel/sound/voice/merp.ogg', 50, 1, -1)

/datum/emote/living/bark
	key = "bark"
	key_third_person = "barks"
	message = "barks!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/bark/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	var/sound = pick('modular_citadel/sound/voice/bark1.ogg', 'modular_citadel/sound/voice/bark2.ogg')
	playsound(user, sound, 50, 1, -1)

/datum/emote/living/squish
	key = "squish"
	key_third_person = "squishes"
	message = "squishes!"
	emote_type = EMOTE_AUDIBLE
	muzzle_ignore = FALSE
	restraint_check = FALSE
	mob_type_allowed_typecache = list(/mob/living/carbon, /mob/living/silicon/pai)

/datum/emote/living/squish/run_emote(mob/living/user, params)
	if(!(. = ..()))
		return
	if(user.nextsoundemote >= world.time)
		return
	user.nextsoundemote = world.time + 7
	var/sound = pick('sound/voice/slime_squish.ogg')
	playsound(user, sound, 50, 1, -1)

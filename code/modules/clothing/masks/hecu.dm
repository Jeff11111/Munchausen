// ported from vg to lumos, now here :)
/obj/item/clothing/mask/gas/hecu
	name = "HECU mask"
	desc = "An ancient gas mask with the letters HECU stamped on the side. Comes with a shouting-activated voice modulator that slowly recharges."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "hecu"
	mob_overlay_icon = 'icons/mob/clothing/mask.dmi'
	anthro_mob_worn_overlay  = 'icons/mob/clothing/mask_muzzled.dmi'
	flags_inv = HIDEFACIALHAIR|HIDEFACE|HIDEEYES
	modifies_speech = TRUE
	var/max_charge = 100
	var/mask_charge = 100
	var/word_cost = 10
	var/word_delay = 7
	var/list/words_to_say = list()
	var/can_say = 0
	var/list/punct_list = list("," , "." , "?" , "!")

	//Big list of words pulled from half life's soldiers, used for both matching with spoken text and part of the sound file's path
	var/list/hecuwords = list(
		"a", "affirmative", "alert", "alien", "all" , "am" , "anything" , "are" , "area" , "ass" , "at" , "away" ,
		"backup" , "bag" , "bastard" , "blow" , "bogies" , "bravo" , "call" , "casualties" , "charlie" , "check" , "checking" , "clear" , "comma" ,
		"command" , "continue" , "control" , "cover" , "creeps" , "damn" , "delta" , "down" , "east" , "echo" , "eliminate" , "everything" , "fall" ,
		"fight" , "fire" , "five" , "force" , "formation" , "four" , "foxtrot" , "freeman" , "get" , "go" , "god" , "going" , "got" , "grenade" , "guard" ,
		"haha" , "have" , "he" , "heavy" , "hell" , "here" , "hold" , "hole" , "hostiles" , "hot" , "i" , "in" , "is" , "kick" ,
		"lay" , "left" , "lets" , "level" , "lookout" , "maintain" , "mission" , "mister" , "mother" , "move" , "movement" , "moves" ,
		"my" , "need" , "negative" , "neutralize" , "neutralized" , "nine" , "no" , "north" , "nothing" , "objective" , "of" , "oh" , "okay" , "one" ,
		"orders" , "our" , "out" , "over" , "patrol" , "people" , "period" , "position" , "post" , "private" , "quiet" , "radio" , "recon" , "request" ,
		"right" , "roger" , "sector" , "secure" , "shit" , "shot" , "sign" , "signs" , "silence" , "sir" , "six" , "some" , "something" , "south" , "squad" ,
		"stay" , "suppressing" , "sweep" , "take" , "tango" , "target" , "team" , "that" , "the" , "there" , "these" , "this" , "those" ,
		"three" , "tight" , "two" , "uh" , "under" , "up" , "we" , "weapons" , "weird" , "west" , "we've" , "will" , "yeah" ,
		"yes" , "yessir" , "you" , "your" , "zero" , "zone" , "zulu" , "meters" , "seven" , "eight" , "hundred" , "to" , "too"
		)

/obj/item/clothing/mask/gas/hecu/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click the mask to see the list of available words.</span>"
	. += "<span class='notice'>Charge: [mask_charge]/[max_charge] </span>"

/obj/item/clothing/mask/gas/hecu/AltClick(mob/user)
	var/message = "Known words: "
	if((user.incapacitated() || !Adjacent(user)))
		return
	for(var/i=1,i<=hecuwords.len,i++)
		message = addtext(message, uppertext(hecuwords[i]), ", ")
	to_chat(user, "[message]")

//Recharging the mask over time
/obj/item/clothing/mask/gas/hecu/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/clothing/mask/gas/hecu/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/mask/gas/hecu/process()
	if(can_say)
		can_say = !can_say
		say_words()
	if(mask_charge >= max_charge)
		return
	mask_charge++

/obj/item/clothing/mask/gas/hecu/handle_speech(datum/source, list/speech_args)
	var/message = speech_args[SPEECH_MESSAGE]
	var/list/word_list = splittext(message," ")

	for(var/i=1,i<=word_list.len,i++)
		if((uppertext(word_list[i]) == "I") || (uppertext(word_list[i]) == "A")) //Stops capitilized 'I' and 'A' from triggering in normal speech
			if(i != word_list.len)
				if(word_list[i + 1] != uppertext(word_list[i + 1]))
					continue
		for(var/x=1,x<=punct_list.len,x++)
			word_list[i] = replacetext(word_list[i] , punct_list[x] , "") //Ignores punctuation.
		for(var/j=1,j<=hecuwords.len,j++)
			if(uppertext(hecuwords[j]) == word_list[i]) //SHOUT a known word to activate
				words_to_say += hecuwords[j]
				can_say = 1
	..()

/obj/item/clothing/mask/gas/hecu/proc/say_words()
	if(words_to_say.len > 0)
		playsound(src.loc, "sound/voice/vox_hecu/_beginning.wav", 40, 0, 4)
		sleep(7)
		for(var/i=1,i<=words_to_say.len,i++)
			if(mask_charge >= word_cost)
				mask_charge -= word_cost
				playsound(src.loc, "sound/voice/vox_hecu/[words_to_say[i]]!.wav", 40, 0, 4)
				sleep(7)
		playsound(src.loc, "sound/voice/vox_hecu/_end.wav", 40, 0, 4)
		words_to_say.Cut()

/datum/component/butchering
	var/speed = 80 //time in deciseconds taken to butcher something
	var/effectiveness = 100 //percentage effectiveness; numbers above 100 yield extra drops
	var/bonus_modifier = 0 //percentage increase to bonus item chance
	var/butcher_sound = 'modular_skyrat/sound/effects/butcher.ogg'
	var/butchering_enabled = TRUE
	var/can_be_blunt = FALSE

/datum/component/butchering/Initialize(_speed, _effectiveness, _bonus_modifier, _butcher_sound, disabled, _can_be_blunt)
	if(_speed)
		speed = _speed
	if(_effectiveness)
		effectiveness = _effectiveness
	if(_bonus_modifier)
		bonus_modifier = _bonus_modifier
	if(_butcher_sound)
		butcher_sound = _butcher_sound
	if(disabled)
		butchering_enabled = FALSE
	if(_can_be_blunt)
		can_be_blunt = _can_be_blunt
	if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/onItemAttack)

/datum/component/butchering/proc/onItemAttack(obj/item/source, mob/living/M, mob/living/user)
	if(user.a_intent != INTENT_HARM)
		return
	if(M.stat == DEAD && (M.butcher_results || M.guaranteed_butcher_results)) //can we butcher it?
		if(butchering_enabled && (can_be_blunt || source.get_sharpness()))
			INVOKE_ASYNC(src, .proc/startButcher, source, M, user)
			return COMPONENT_ITEM_NO_ATTACK

	if(ishuman(M) && source.force && source.get_sharpness())
		var/mob/living/carbon/human/H = M
		if((user.pulling == H && user.grab_state >= GRAB_NECK) && user.zone_selected == BODY_ZONE_PRECISE_NECK)
			if(H.has_status_effect(/datum/status_effect/neck_slice))
				user.show_message("<span class='warning'><b>[H]</b>'s neck has already been already cut, you can't make the bleeding any worse!</span>", 1, \
								"<span class='warning'>Their neck has already been already cut, you can't make the bleeding any worse!</span>")
				return COMPONENT_ITEM_NO_ATTACK
			INVOKE_ASYNC(src, .proc/startNeckSlice, source, H, user)
			return COMPONENT_ITEM_NO_ATTACK

/datum/component/butchering/proc/startButcher(obj/item/source, mob/living/M, mob/living/user)
	to_chat(user, "<span class='notice'>You begin to butcher <b>[M]</b>...</span>")
	playsound(M.loc, butcher_sound, 50, TRUE, -1)
	if(do_mob(user, M, speed) && M.Adjacent(source))
		Butcher(user, M)

/datum/component/butchering/proc/startNeckSlice(obj/item/source, mob/living/carbon/human/H, mob/living/user)
	user.visible_message("<span class='danger'><b>[user]</b> is slitting <b>[H]</b>'s throat!</span>", \
					"<span class='danger'>You start slicing <b>[H]</b>'s throat!</span>", \
					"<span class='notice'>You hear a cutting noise!</span>", ignored_mobs = H)
	H.show_message("<span class='userdanger'>Your throat is being slit by <b>[user]</b>!</span>", 1, \
					"<span class = 'userdanger'>Something is cutting into your neck!</span>", NONE)
	log_combat(user, H, "starts slicing the throat of")

	playsound(H.loc, butcher_sound, 50, TRUE, -1)
	if(do_mob(user, H, clamp(500 / source.force, 30, 100)) && H.Adjacent(source))
		if(H.has_status_effect(/datum/status_effect/neck_slice))
			user.show_message("<span class='warning'><b>[H]</b>'s neck has already been already cut, you can't make the bleeding any worse!</span>", 1, \
							"<span class='warning'>Their neck has already been already cut, you can't make the bleeding any worse!</span>")
			return

		H.visible_message("<span class='danger'><b>[user]</b> slits <b>[H]</b>'s throat!</span>", \
					"<span class='userdanger'><b>[user]</b> slits your throat...</span>")
		log_combat(user, H, "finishes slicing the throat of")
		H.apply_damage(source.force, BRUTE, BODY_ZONE_HEAD, wound_bonus=CANT_WOUND) // easy tiger, we'll get to that in a sec
		var/obj/item/bodypart/slit_throat = H.get_bodypart(BODY_ZONE_PRECISE_NECK)
		if(slit_throat)
			if(!locate(/datum/wound/artery) in slit_throat.wounds)
				var/datum/wound/artery/screaming_through_a_slit_throat = new()
				screaming_through_a_slit_throat.apply_wound(slit_throat)
			if(!locate(/datum/wound/tendon) in slit_throat.wounds)
				var/datum/wound/tendon/gargling_through_a_slit_throat = new()
				gargling_through_a_slit_throat.apply_wound(slit_throat)

/datum/component/butchering/proc/Butcher(mob/living/butcher, mob/living/meat)
	var/meat_quality = 50 + (bonus_modifier/10) //increases through quality of butchering tool, and through if it was butchered in the kitchen or not
	if(istype(get_area(butcher), /area/crew_quarters/kitchen))
		meat_quality = meat_quality + 10
	var/turf/T = meat.drop_location()
	var/final_effectiveness = effectiveness - meat.butcher_difficulty
	var/bonus_chance = max(0, (final_effectiveness - 100) + bonus_modifier) //so 125 total effectiveness = 25% extra chance
	var/list/butchered_items = list()
	for(var/V in meat.butcher_results)
		var/obj/bones = V
		var/amount = meat.butcher_results[bones]
		for(var/_i in 1 to amount)
			if(!prob(final_effectiveness))
				if(butcher)
					to_chat(butcher, "<span class='warning'>You fail to harvest some of the [initial(bones.name)] from [meat].</span>")
			else if(prob(bonus_chance))
				if(butcher)
					to_chat(butcher, "<span class='info'>You harvest some extra [initial(bones.name)] from [meat]!</span>")
				for(var/i in 1 to 2)
					butchered_items += new bones (T)

			else
				butchered_items += new bones (T)
		meat.butcher_results.Remove(bones) //in case you want to, say, have it drop its results on gib
	for(var/V in meat.guaranteed_butcher_results)
		var/obj/sinew = V
		var/amount = meat.guaranteed_butcher_results[sinew]
		for(var/i in 1 to amount)
			butchered_items += new sinew (T)
		meat.guaranteed_butcher_results.Remove(sinew)
	for(var/butchered_item in butchered_items)
		if(isfood(butchered_item))
			var/obj/item/reagent_containers/food/butchered_meat = butchered_item
			butchered_meat.food_quality = meat_quality
	if(butcher)
		meat.visible_message("<span class='notice'>[butcher] butchers [meat].</span>")
	ButcherEffects(meat)
	meat.harvest(butcher)
	meat.gib(FALSE, FALSE, TRUE)

/datum/component/butchering/proc/ButcherEffects(mob/living/meat) //extra effects called on butchering, override this via subtypes
	return

///Special snowflake component only used for the recycler.
/datum/component/butchering/recycler

/datum/component/butchering/recycler/Initialize(_speed, _effectiveness, _bonus_modifier, _butcher_sound, disabled, _can_be_blunt)
	if(!istype(parent, /obj/machinery/recycler)) //EWWW
		return COMPONENT_INCOMPATIBLE
	. = ..()
	if(. == COMPONENT_INCOMPATIBLE)
		return
	RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/onCrossed)

/datum/component/butchering/recycler/proc/onCrossed(datum/source, mob/living/L)
	if(!istype(L))
		return
	var/obj/machinery/recycler/eater = parent
	if(eater.safety_mode || (eater.stat & (BROKEN|NOPOWER))) //I'm so sorry.
		return
	if(L.stat == DEAD && (L.butcher_results || L.guaranteed_butcher_results))
		Butcher(parent, L)

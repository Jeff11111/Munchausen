/obj/item/clothing/shoes
	name = "shoes"
	icon = 'icons/obj/clothing/shoes.dmi'
	desc = "Comfortable-looking shoes."
	gender = PLURAL //Carn: for grammarically correct text-parsing
	var/chained = 0

	body_parts_covered = FEET
	slot_flags = ITEM_SLOT_FEET

	permeability_coefficient = 0.5
	slowdown = SHOES_SLOWDOWN
	var/blood_state = BLOOD_STATE_NOT_BLOODY
	var/list/bloody_shoes = list(BLOOD_STATE_BLOOD = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	var/offset = 0
	var/equipped_before_drop = FALSE

	mutantrace_variation = STYLE_DIGITIGRADE
	var/last_bloodtype = ""	//used to track the last bloodtype to have graced these shoes; makes for better performing footprint shenanigans
	var/last_blood_DNA = ""	//same as last one
	var/last_blood_color = ""

// yeet the component when taped
// made this share functionality with any shoe because its cool i think
/obj/item/clothing/shoes/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/sticky_tape) && GetComponent(/datum/component/squeak))
		var/obj/item/stack/sticky_tape/S = W
		if(S.get_amount() < 5)
			to_chat(user, "<span class='warning'>You need five bits of tape to cover the bottom of the [src]!</span>")
			return FALSE
		else if(S.use_tool(src, user, 30, 5))
			var/datum/component/squeak/squeaky = GetComponent(/datum/component/squeak)
			qdel(squeaky)
			to_chat(user, "<span class='notice'>You tape the bottom of the [src]!</span>")
			return TRUE
	. = ..()

/obj/item/clothing/shoes/ComponentInitialize()
	. = ..()
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, /atom.proc/clean_blood)

/obj/item/clothing/shoes/suicide_act(mob/living/carbon/user)
	if(rand(2)>1)
		user.visible_message("<span class='suicide'>[user] begins tying \the [src] up waaay too tightly! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		var/obj/item/bodypart/l_leg = user.get_bodypart(BODY_ZONE_L_LEG)
		var/obj/item/bodypart/r_leg = user.get_bodypart(BODY_ZONE_R_LEG)
		if(l_leg)
			l_leg.dismember()
			playsound(user,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
		if(r_leg)
			r_leg.dismember()
			playsound(user,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
		return BRUTELOSS
	else//didnt realize this suicide act existed (was in miscellaneous.dm) and didnt want to remove it, so made it a 50/50 chance. Why not!
		user.visible_message("<span class='suicide'>[user] is bashing [user.p_their()] own head in with [src]! Ain't that a kick in the head?</span>")
		for(var/i = 0, i < 3, i++)
			sleep(3)
			playsound(user, 'sound/weapons/genhit2.ogg', 50, 1)
		return(BRUTELOSS)


/obj/item/clothing/shoes/transfer_blood_dna(list/blood_dna, diseases)
	..()
	if(blood_dna.len)
		last_bloodtype = blood_dna[blood_dna[blood_dna.len]]//trust me this works
		last_blood_DNA = blood_dna[blood_dna.len]
		last_blood_color = blood_dna["color"]

/obj/item/clothing/shoes/worn_overlays(isinhands = FALSE, icon_file, used_state, style_flags = NONE)
	. = ..()
	if(!isinhands)
		var/bloody = FALSE
		if(blood_DNA)
			bloody = TRUE
		else
			bloody = bloody_shoes[BLOOD_STATE_BLOOD]

		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedshoe")
		if(bloody)
			var/file2use = style_flags & STYLE_DIGITIGRADE ? 'icons/mob/clothing/feet_digi.dmi' : 'icons/effects/blood.dmi'
			. += mutable_appearance(file2use, "shoeblood", color = last_blood_color)

/obj/item/clothing/shoes/equipped(mob/user, slot)
	. = ..()

	if(offset && slot_flags & slotdefine2slotbit(slot))
		user.pixel_y += offset
		worn_y_dimension -= (offset * 2)
		user.update_inv_shoes()
		equipped_before_drop = TRUE

/obj/item/clothing/shoes/proc/restore_offsets(mob/user)
	equipped_before_drop = FALSE
	user.pixel_y -= offset
	worn_y_dimension = world.icon_size

/obj/item/clothing/shoes/dropped(mob/user)
	if(offset && equipped_before_drop)
		restore_offsets(user)
	. = ..()

/obj/item/clothing/shoes/update_clothes_damaged_state()
	. = ..()
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/obj/item/clothing/shoes/clean_blood(datum/source, strength)
	. = ..()
	bloody_shoes = list(BLOOD_STATE_BLOOD = 0, BLOOD_STATE_OIL = 0, BLOOD_STATE_NOT_BLOODY = 0)
	blood_state = BLOOD_STATE_NOT_BLOODY
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_shoes()

/obj/item/proc/negates_gravity()
	return FALSE

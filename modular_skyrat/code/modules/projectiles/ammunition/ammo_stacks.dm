//Ammo casing interaction code
/obj/item/ammo_casing
	var/obj/item/ammo_box/magazine/ammo_stack = /obj/item/ammo_box/magazine/ammo_stack

/obj/item/ammo_casing/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/AC = I
		if(ammo_stack && AC.ammo_stack && (caliber == AC.caliber) && BB && AC.BB)
			var/obj/item/ammo_box/magazine/ammo_stack/AS = new(get_turf(src))
			AS.name = "[capitalize(caliber)] rounds"
			if(findtext(AC.name, config.punctuation_filter, 1, 1))
				AS.name =  ".[capitalize(caliber)] rounds"
			AS.caliber = caliber
			AS.give_round(src)
			AS.give_round(AC)
			user.transferItemToLoc(src, AS)
			user.transferItemToLoc(AC, AS)
			user.put_in_hands(AS)
			to_chat(user, "<span class='notice'>[src] has been stacked into [AS].</span>")
		else if(!BB || !AC.BB)
			to_chat(user, "<span class='warning'>Fnord... I can't stack spent casings.</span>")
		else if(!ammo_stack)
			to_chat(user, "<span class='warning'>[src] can't be stacked.</span>")
		else if(!AC.ammo_stack)
			to_chat(user, "<span class='warning'>[AC] can't be stacked.</span>")

//The ammo stack itself
/obj/item/ammo_box/magazine/ammo_stack
	name = "ammo stack"
	desc = "A stack of ammo."
	icon = 'modular_skyrat/icons/obj/bobstation/ammo/stacks.dmi'
	icon_state = "nothing"
	max_ammo = 12
	multiple_sprites = FALSE
	start_empty = TRUE
	multiload = FALSE

/obj/item/ammo_box/magazine/ammo_stack/update_overlays()
	..()
	cut_overlays()
	for(var/casing in stored_ammo)
		var/obj/item/ammo_casing/AC = casing
		var/mutable_appearance/comicao = mutable_appearance(AC.icon, AC.icon_state)
		comicao.pixel_x = rand(0, 16)
		comicao.pixel_y = rand(0, 16)
		comicao.transform = comicao.transform.Turn(rand(0, 360))
		add_overlay(comicao)

/obj/item/ammo_box/magazine/ammo_stack/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	while(length(stored_ammo))
		var/obj/item/I = get_round()
		I.forceMove(loc)
		I.throw_at(loc)
	if(!QDELETED(src))
		qdel(src)

/obj/item/ammo_box/magazine/ammo_stack/get_round(keep)
	var/i = ..()
	update_icon()
	return i

/obj/item/ammo_box/magazine/ammo_stack/give_round(obj/item/ammo_casing/R, replace_spent)
	var/i = ..()
	update_icon()
	return i

/obj/item/ammo_box/magazine/ammo_stack/handle_atom_del(atom/A)
	..()
	check_for_del()

/obj/item/ammo_box/magazine/ammo_stack/empty_magazine()
	..()
	check_for_del()

/obj/item/ammo_box/magazine/ammo_stack/proc/check_for_del()
	. = FALSE
	if(ammo_count() <= 0 && !QDELETED(src))
		qdel(src)
		return TRUE

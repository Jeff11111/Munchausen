//ports the changes to the base ammo box from hippie, otherwise the contender wont work
/obj/item/ammo_box/give_round(obj/item/ammo_casing/R, replace_spent = 0)
	// Boxes don't have a caliber type, magazines do. Not sure if it's intended or not, but if we fail to find a caliber, then we fall back to ammo_type.
	if((!R || (caliber && R.caliber != caliber) || (!caliber && R.type != ammo_type)) && (caliber != "all"))
		return FALSE

	if(stored_ammo.len < max_ammo)
		stored_ammo += R
		R.forceMove(src)
		return TRUE
	//for accessibles magazines (e.g internal ones) when full, start replacing spent ammo
	else if(replace_spent)
		for(var/obj/item/ammo_casing/AC in stored_ammo)
			if(!AC.BB)//found a spent ammo
				stored_ammo -= AC
				AC.forceMove(get_turf(src.loc))
				stored_ammo += R
				R.forceMove(src)
				return TRUE
	return FALSE

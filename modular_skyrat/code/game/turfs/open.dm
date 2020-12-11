// Crawling
/turf/open/attack_hand(mob/user)
	. = ..()
	var/mob/living/living_user = user
	if(istype(living_user) && living_user.lying && CHECK_MOBILITY(living_user, MOBILITY_USE) && !living_user.restrained() && !living_user.pinned())
		var/cooldown = 2.5 SECONDS
		if(get_dir(user, src) in GLOB.diagonals)
			cooldown *= 2
		if(living_user.last_move_time + cooldown <= world.time)
			living_user.visible_message("<span class='danger'><b>[living_user]</b> crawls towards [src].</span>", "<span class='danger'>You crawl towards [src].</span>")
			living_user.Move(get_step(living_user, get_dir(living_user, src)), get_dir(living_user, src))

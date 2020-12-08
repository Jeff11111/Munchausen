/mob/living
	var/datum/gunpoint/gunpointing
	var/list/gunpointed = list()
	var/obj/effect/overlay/gunpoint_effect/gp_effect
	var/list/recent_embeds = list()
	var/embed_timer
	var/list/chem_effects = list()
	var/list/chem_effect_sources = list()

/mob/living/proc/wield_active_hand()
	return

/mob/living/proc/on_examine_atom(atom/examined)
	if(!istype(examined) || !client || !examined.on_examined_check())
		return

	if((get_dist(src, examined) > EYE_CONTACT_RANGE) || (stat > CONSCIOUS))
		return
	
	if(!ismob(examined))
		visible_message("<span class='notice'>\The <b>[src]</b> looks at [examined].</span>", "<span class='notice'>I look at [examined].</span>", vision_distance = 4)
	else
		visible_message("<span class='notice'>\The <b>[src]</b> looks at <b>[examined]</b>.</span>", "<span class='notice'>I look at <b>[examined]</b>.</span>", vision_distance = 4)

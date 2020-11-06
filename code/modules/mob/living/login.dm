/mob/living/Login()
	..()
	//Mind updates
	sync_mind()
//SKYRAT CHANGES BEGIN
	if(mind.memory || mind.antag_datums)
		to_chat(src, "<i>[mind.show_memory()]</i>")
//SKYRAT CHANGES END

	//Round specific stuff
	if(SSticker.mode)
		switch(SSticker.mode.name)
			if("sandbox")
				CanBuild()

	update_damage_hud()
	update_health_hud()

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	//Vents
	if(ventcrawler)
		to_chat(src, "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>")

	if(ranged_ability)
		ranged_ability.add_ranged_ability(src, "<span class='notice'>You currently have <b>[ranged_ability]</b> active!</span>")

	set_ssd_indicator(FALSE) //SKYRAT CHANGE - ssd indicator

/obj/machinery/mecha_part_fabricator
	icon = 'icons/obj/robotics.dmi'
	icon_state = "fab-idle"
	name = "exosuit fabricator"
	desc = "Nothing is being built."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 5000
	req_access = list(ACCESS_ROBOTICS)
	circuit = /obj/item/circuitboard/machine/mechfab
	var/time_coeff = 1
	var/component_coeff = 1
	var/datum/techweb/specialized/autounlocking/exofab/stored_research
	var/sync = 0
	var/part_set
	var/datum/design/being_built
	var/list/queue = list()
	var/processing_queue = 0
	var/screen = "main"
	var/temp
	var/offstation_security_levels = TRUE
	var/list/part_sets = list(
								"Cyborg",
								"Ripley",
								"Firefighter",
								"Odysseus",
								"Gygax",
								"Medical-Spec Gygax",
								"Durand",
								"H.O.N.K",
								"Phazon",
								"Exosuit Equipment",
								"Exosuit Ammunition",
								"Cyborg Upgrade Modules",
								"Misc"
								)

/obj/machinery/mecha_part_fabricator/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/multitool_emaggable)

/obj/machinery/mecha_part_fabricator/emag_act()
	. = ..()
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	req_access = list()
	INVOKE_ASYNC(src, .proc/error_action_sucessful)
	return TRUE

/obj/machinery/mecha_part_fabricator/proc/error_action_sucessful()
	say("DB error \[Code 0x00F1\]")
	sleep(10)
	say("Attempting auto-repair...")
	sleep(15)
	say("User DB corrupted \[Code 0x00FA\]. Truncating data structure...")
	sleep(30)
	say("User DB truncated. Please contact your Nanotrasen system operator for future assistance.")

/obj/machinery/mecha_part_fabricator/proc/output_parts_list(set_name)
	var/output = ""
	for(var/v in stored_research.researched_designs)
		var/datum/design/D = SSresearch.techweb_design_by_id(v)
		if(D.build_type & MECHFAB)
			if(!(set_name in D.category))
				continue
			output += "<div class='part'>[output_part_info(D)]<br>\["
			if(check_clearance(D) && check_resources(D))
				output += "<a href='?src=[REF(src)];part=[D.id]'>Build</a> | "
			output += "<a href='?src=[REF(src)];add_to_queue=[D.id]'>Add to queue</a>\]\[<a href='?src=[REF(src)];part_desc=[D.id]'>?</a>\]</div>"
	return output

/obj/machinery/mecha_part_fabricator/proc/check_clearance(datum/design/D)
	if(!(obj_flags & EMAGGED) && (offstation_security_levels || is_station_level(z)) && !ISINRANGE(GLOB.security_level, D.min_security_level, D.max_security_level))
		return FALSE
	return TRUE

/obj/machinery/mecha_part_fabricator/proc/output_part_info(datum/design/D)
	var/clearance = !(obj_flags & EMAGGED) && (offstation_security_levels || is_station_level(z))
	var/sec_text = ""
	if(clearance && (D.min_security_level > SEC_LEVEL_GREEN || D.max_security_level < SEC_LEVEL_DELTA))
		sec_text = " (Allowed security levels: "
		for(var/n in D.min_security_level to D.max_security_level)
			sec_text += NUM2SECLEVEL(n)
			if(n + 1 <= D.max_security_level)
				sec_text += ", "
		sec_text += ") "
	var/output = "[initial(D.name)] (Cost: [output_part_cost(D)]) [sec_text][get_construction_time_w_coeff(D)/10]sec"
	return output

/obj/machinery/mecha_part_fabricator/proc/output_part_cost(datum/design/D)
	var/i = 0
	var/output
	for(var/c in D.materials)
		var/datum/material/M = c
		output += "[i?" | ":null][get_resource_cost_w_coeff(D, M)] [M.name]"
		i++
	return output


/obj/machinery/mecha_part_fabricator/proc/get_resources_w_coeff(datum/design/D)
	var/list/resources = list()
	for(var/R in D.materials)
		var/datum/material/M = R
		resources[M] = get_resource_cost_w_coeff(D, M)
	return resources

/obj/machinery/mecha_part_fabricator/proc/update_queue_on_page()
	send_byjax(usr,"mecha_fabricator.browser","queue",list_queue())
	return

/obj/machinery/mecha_part_fabricator/proc/add_part_set_to_queue(set_name)
	if(set_name in part_sets)
		for(var/v in stored_research.researched_designs)
			var/datum/design/D = SSresearch.techweb_design_by_id(v)
			if(D.build_type & MECHFAB)
				if(set_name in D.category)
					add_to_queue(D)

/obj/machinery/mecha_part_fabricator/proc/add_to_queue(D)
	if(!istype(queue))
		queue = list()
	if(D)
		queue[++queue.len] = D
	return queue.len

/obj/machinery/mecha_part_fabricator/proc/remove_from_queue(index)
	if(!isnum(index) || !ISINTEGER(index) || !istype(queue) || (index<1 || index>queue.len))
		return FALSE
	queue.Cut(index,++index)
	return TRUE

/obj/machinery/mecha_part_fabricator/proc/list_queue()
	var/output = "<b>Queue contains:</b>"
	if(!istype(queue) || !queue.len)
		output += "<br>Nothing"
	else
		output += "<ol>"
		var/i = 0
		for(var/datum/design/D in queue)
			i++
			var/obj/part = D.build_path
			output += "<li[(!check_clearance(D) ||!check_resources(D))?" style='color: #f00;'":null]>"
			output += initial(part.name) + " - "
			output += "[i>1?"<a href='?src=[REF(src)];queue_move=-1;index=[i]' class='arrow'>&uarr;</a>":null] "
			output += "[i<queue.len?"<a href='?src=[REF(src)];queue_move=+1;index=[i]' class='arrow'>&darr;</a>":null] "
			output += "<a href='?src=[REF(src)];remove_from_queue=[i]'>Remove</a></li>"

		output += "</ol>"
		output += "\[<a href='?src=[REF(src)];process_queue=1'>Process queue</a> | <a href='?src=[REF(src)];clear_queue=1'>Clear queue</a>\]"
	return output

/obj/machinery/mecha_part_fabricator/proc/sync()
	temp = "Updating local R&D database..."
	updateUsrDialog()
	sleep(30) //only sleep if called by user

	for(var/obj/machinery/computer/rdconsole/RDC in oview(7,src))
		RDC.stored_research.copy_research_to(stored_research)
		temp = "Processed equipment designs.<br>"
		//check if the tech coefficients have changed
		temp += "<a href='?src=[REF(src)];clear_temp=1'>Return</a>"

		updateUsrDialog()
		say("Successfully synchronized with R&D server.")
		return

	temp = "Unable to connect to local R&D Database.<br>Please check your connections and try again.<br><a href='?src=[REF(src)];clear_temp=1'>Return</a>"
	updateUsrDialog()
	return

/obj/machinery/mecha_part_fabricator/proc/get_resource_cost_w_coeff(datum/design/D, var/datum/material/resource, roundto = 1)
	return round(D.materials[resource]*component_coeff, roundto)

/obj/machinery/mecha_part_fabricator/proc/get_construction_time_w_coeff(datum/design/D, roundto = 1) //aran
	return round(initial(D.construction_time)*time_coeff, roundto)

/obj/machinery/mecha_part_fabricator/ui_interact(mob/user as mob)
	. = ..()
	var/dat, left_part
	user.set_machine(src)
	var/turf/exit = get_step(src,(dir))
	if(exit.density)
		say("Error! Part outlet is obstructed.")
		return
	if(temp)
		left_part = temp
	else if(being_built)
		var/obj/I = being_built.build_path
		left_part = {"<TT>Building [initial(I.name)].<BR>
							Please wait until completion...</TT>"}
	else
		switch(screen)
			if("main")
				left_part = output_available_resources()+"<hr>"
				left_part += "<a href='?src=[REF(src)];sync=1'>Sync with R&D servers</a><hr>"
				for(var/part_set in part_sets)
					left_part += "<a href='?src=[REF(src)];part_set=[part_set]'>[part_set]</a> - \[<a href='?src=[REF(src)];partset_to_queue=[part_set]'>Add all parts to queue</a>\]<br>"
			if("parts")
				left_part += output_parts_list(part_set)
				left_part += "<hr><a href='?src=[REF(src)];screen=main'>Return</a>"
	dat = {"<html>
			  <head>
				<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
				<title>[name] data</title>
				<style>
				.res_name {font-weight: bold; text-transform: capitalize;}
				.red {color: #f00;}
				.part {margin-bottom: 10px;}
				.arrow {text-decoration: none; font-size: 10px;}
				body, table {height: 100%;}
				td {vertical-align: top; padding: 5px;}
				html, body {padding: 0px; margin: 0px;}
				h1 {font-size: 18px; margin: 5px 0px;}
				</style>
				<script language='javascript' type='text/javascript'>
				[js_byjax]
				</script>
				</head><body>
				<body>
				<table style='width: 100%;'>
				<tr>
				<td style='width: 65%; padding-right: 10px;'>
				[left_part]
				</td>
				<td style='width: 35%; background: #ccc;' id='queue'>
				[list_queue()]
				</td>
				<tr>
				</table>
				</body>
				</html>"}
	user << browse(dat, "window=mecha_fabricator;size=1000x430")
	onclose(user, "mecha_fabricator")
	return

/obj/machinery/mecha_part_fabricator/proc/AfterMaterialInsert(item_inserted, id_inserted, amount_inserted)
	var/datum/material/M = id_inserted
	add_overlay("fab-load-[M.name]")
	addtimer(CALLBACK(src, /atom/proc/cut_overlay, "fab-load-[M.name]"), 10)
	updateUsrDialog()

/obj/machinery/mecha_part_fabricator/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "fab-o", "fab-idle", W))
		return TRUE

	if(default_deconstruction_crowbar(W))
		return TRUE

	return ..()

/obj/machinery/mecha_part_fabricator/proc/is_insertion_ready(mob/user)
	if(panel_open)
		to_chat(user, "<span class='warning'>You can't load [src] while it's opened!</span>")
		return FALSE
	if(being_built)
		to_chat(user, "<span class='warning'>\The [src] is currently processing! Please wait until completion.</span>")
		return FALSE

	return TRUE

/obj/machinery/mecha_part_fabricator/offstation
	offstation_security_levels = FALSE
	circuit = /obj/item/circuitboard/machine/mechfab/offstation

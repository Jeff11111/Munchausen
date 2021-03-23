/obj/structure/door_assembly
	name = "airlock assembly"
	icon = 'icons/obj/doors/airlocks/station/public.dmi'
	icon_state = "construction"
	anchored = FALSE
	density = TRUE
	max_integrity = 200
	var/state = AIRLOCK_ASSEMBLY_NEEDS_WIRES
	var/base_name = "airlock"
	var/mineral = null
	var/obj/item/electronics/airlock/electronics = null
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass
	var/glass = 0 // 0 = glass can be installed. 1 = glass is already installed.
	var/created_name = null
	var/heat_proof_finished = 0 //whether to heat-proof the finished airlock
	var/previous_assembly = /obj/structure/door_assembly
	var/noglass = FALSE //airlocks with no glass version, also cannot be modified with sheets
	var/material_type = /obj/item/stack/sheet/metal
	var/material_amt = 4

	var/door_color = ""
	var/glass_color = ""
	var/color_file = 'modular_skyrat/icons/bay/obj/doors/station/color.dmi'
	var/fill_file = 'modular_skyrat/icons/bay/obj/doors/station/fill_steel.dmi'
	var/glass_file = 'modular_skyrat/icons/bay/obj/doors/station/fill_glass.dmi'
	var/panel_file = 'modular_skyrat/icons/bay/obj/doors/station/panel.dmi'

/obj/structure/door_assembly/New()
	update_icon()
	update_name()
	. = ..()

/obj/structure/door_assembly/examine(mob/user)
	. = ..()
	var/doorname = ""
	if(created_name)
		doorname = ", written on it is '[created_name]'"
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				. += "<span class='notice'>The anchoring bolts are <b>wrenched</b> in place, but the maintenance panel lacks <i>wiring</i>.</span>"
			else
				. += "<span class='notice'>The assembly is <b>welded together</b>, but the anchoring bolts are <i>unwrenched</i>.</span>"
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			. += "<span class='notice'>The maintenance panel is <b>wired</b>, but the circuit slot is <i>empty</i>.</span>"
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			. += "<span class='notice'>The circuit is <b>connected loosely</b> to its slot, but the maintenance panel is <i>unscrewed and open</i>.</span>"
	if(!mineral && !glass && !noglass)
		. += "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for glass windows and mineral covers.</span>"
	else if(!mineral && glass && !noglass)
		. += "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for mineral covers.</span>"
	else if(mineral && !glass && !noglass)
		. += "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname]. There are <i>empty</i> slots for glass windows.</span>"
	else
		. += "<span class='notice'>There is a small <i>paper</i> placard on the assembly[doorname].</span>"

/obj/structure/door_assembly/update_overlays()
	. = ..()
	if(door_color)
		. += get_airlock_overlay("construction", color_file)
	else if(!glass)
		var/mutable_appearance/fuck = get_airlock_overlay("construction", fill_file)
		if(door_color)
			fuck.color = door_color
		. += fuck
	else if(glass)
		var/mutable_appearance/fuck = get_airlock_overlay("construction", glass_file)
		if(glass_color)
			fuck.color = glass_color
		. += fuck
	. += get_airlock_overlay("construction[state]", panel_file)

/obj/structure/door_assembly/proc/update_name()
	name = ""
	switch(state)
		if(AIRLOCK_ASSEMBLY_NEEDS_WIRES)
			if(anchored)
				name = "secured "
		if(AIRLOCK_ASSEMBLY_NEEDS_ELECTRONICS)
			name = "wired "
		if(AIRLOCK_ASSEMBLY_NEEDS_SCREWDRIVER)
			name = "near finished "
	name += "[heat_proof_finished ? "heat-proofed " : ""][glass ? "window " : ""][base_name] assembly"

/obj/structure/door_assembly/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		if(!disassembled)
			material_amt = rand(2,4)
		new material_type(T, material_amt)
		if(glass)
			if(disassembled)
				if(heat_proof_finished)
					new /obj/item/stack/sheet/rglass(T)
				else
					new /obj/item/stack/sheet/glass(T)
			else
				new /obj/item/shard(T)
		if(mineral)
			var/obj/item/stack/sheet/mineral/mineral_path = text2path("/obj/item/stack/sheet/mineral/[mineral]")
			new mineral_path(T, 2)
	qdel(src)

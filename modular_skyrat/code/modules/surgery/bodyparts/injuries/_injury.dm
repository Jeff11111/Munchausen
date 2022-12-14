//This is basically the baystation wound datum, which i thought would synergize well with the TG wounds
/****************************************************
				INJURY DATUM
****************************************************/
//Note that the MINIMUM damage before a wound can be applied should correspond to
//the damage amount for the stage with the same name as the wound.
//e.g. /datum/wound/cut/deep should only be applied for 15 damage and up,
//because in it's stages list, "deep cut" = 15.
/datum/injury
	var/current_stage = 0		// number representing the current stage
	var/desc = "wound"			// description of the wound. default in case something borks
	var/damage = 0				// amount of damage this wound causes
	var/bleed_rate = 1			// how much we bleed on each tick
	var/bleed_timer = 0			// ticks of bleeding left
	var/bleed_threshold = 30	// Above this amount wounds you will need to treat the wound to stop bleeding, regardless of bleed_timer
	var/min_damage = 0			// amount of damage the current wound type requires (less means we need to apply the next healing stage)
	var/injury_flags = (INJURY_SOUND_HINTS)	// general flags like INJURY_BANDAGED, INJURY_SALVED
	var/created = 0				// world.time when this wound was created
	var/amount = 1				// number of wounds of this type
	var/germ_level = 0			// amount of germs in the wound
	var/infection_rate = 1		// rate of infection for this wound
	var/fade_away = 2 MINUTES  // time it takes for the injury to fade away once healed up
	var/obj/item/bodypart/parent_bodypart	// the bodypart the wound is on, if on a bodypart
	var/mob/living/carbon/parent_mob // the mob the wound is on, if on a mob

	// These are defined by the wound type and should not be changed here
	var/list/stages				// stages such as "cut", "deep cut", etc.
	var/max_bleeding_stage = 0	// maximum stage at which bleeding should still happen. Beyond this stage bleeding is prevented.
	var/damage_type = WOUND_SLASH	// one of WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE, WOUND_BURN
	var/autoheal_cutoff = 15	// the maximum amount of damage that this wound can have and still autoheal

	// helper lists
	var/list/desc_list = list()
	var/list/damage_list = list()

	// limb status required for this injury
	var/required_status = BODYPART_ORGANIC
	
	// shit that got embedded on this injury
	var/list/embedded_objects
	var/list/embedded_components

/datum/injury/New()
	. = ..()
	created = world.time
	// reading from a list("stage" = damage) is pretty difficult, so build two separate
	// lists from them instead
	for(var/V in stages)
		desc_list += V
		damage_list += stages[V]

/datum/injury/Destroy()
	if(parent_bodypart)
		parent_bodypart.injuries -= src
		parent_bodypart = null
	if(parent_mob)
		UnregisterSignal(parent_mob, COMSIG_MOVABLE_MOVED)
		parent_mob.all_injuries -= src
		parent_mob = null
	embedded_objects = null
	for(var/datum/component/embedded/embedded in embedded_components)
		embedded.safeRemove()
		embedded.injury = null
	embedded_components = null
	. = ..()

//applies the injury on a limb proper
/datum/injury/proc/apply_injury(our_damage, obj/item/bodypart/limb)
	//aaaaaaaaah
	damage = our_damage

	//initialize with the appropriate stage and bleeding ticks
	bleed_timer += our_damage
	init_stage(our_damage)

	if(istype(limb))
		parent_bodypart = limb
		parent_bodypart.injuries += src
		if(parent_bodypart.owner)
			parent_mob = parent_bodypart.owner
			parent_bodypart.owner.all_injuries += src
			RegisterSignal(parent_mob, COMSIG_MOVABLE_MOVED, .proc/on_move)
			sound_hint(parent_mob, parent_mob)

//makes the injury get infected more when the victim is moving around
/datum/injury/proc/on_move(mob/living/carbon/source)
	if(parent_bodypart && prob(10) && infection_check())
		germ_level = clamp(germ_level + infection_rate, 0, INFECTION_LEVEL_THREE)

//special proc for when the parent bodypart receives some damage
/datum/injury/proc/receive_damage(damage_received = 0, pain_received = 0, damage_type = WOUND_BLUNT)
	return FALSE

// returns 1 if there's a next stage, 0 otherwise
/datum/injury/proc/init_stage(initial_damage)
	current_stage = stages.len

	while(current_stage > 1 && damage_list[current_stage-1] <= initial_damage / amount)
		current_stage--

	min_damage = damage_list[current_stage]
	desc = desc_list[current_stage]

// the amount of damage per injury
/datum/injury/proc/wound_damage()
	return (damage / amount)

/datum/injury/proc/can_autoheal()
	if(CHECK_BITFIELD(required_status, BODYPART_ROBOTIC))
		return FALSE
	for(var/obj/item/wpn in embedded_objects)
		if(!wpn.isEmbedHarmless())
			return FALSE
	return (wound_damage() <= autoheal_cutoff) ? TRUE : (is_treated() || parent_bodypart?.limb_flags & BODYPART_HEALS_OVERKILL)

// checks whether the wound has been appropriately treated
/datum/injury/proc/is_treated()
	for(var/obj/item/wpn in embedded_objects)
		if(!wpn.isEmbedHarmless())
			return FALSE
	switch(damage_type)
		if(WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE)
			return (is_bandaged())
		if(WOUND_BURN)
			return (is_salved() || (is_disinfected() && is_bandaged()))

// Checks whether other other can be merged into src.
/datum/injury/proc/can_merge(datum/injury/other)
	if(other.damage_type != damage_type)
		return FALSE
	if(other.type != type)
		return FALSE
	if(other.current_stage != current_stage)
		return FALSE
	if(other.can_autoheal() != can_autoheal())
		return FALSE
	if(other.injury_flags != injury_flags)
		return FALSE
	if(other.parent_bodypart != parent_bodypart)
		return FALSE
	return TRUE

/datum/injury/proc/merge_injury(datum/injury/other)
	embedded_objects = (src.embedded_objects | other.embedded_objects)
	embedded_components = (src.embedded_components | other.embedded_components)
	damage += other.damage
	amount += other.amount
	bleed_timer += other.bleed_timer
	germ_level = max(germ_level, other.germ_level)
	injury_flags |= other.injury_flags
	created = max(created, other.created)	//take the newer created time
	qdel(other)

// checks if wound is considered open for external infections
// untreated cuts (and bleeding bruises) and burns are possibly infectable, chance higher if wound is bigger
/datum/injury/proc/infection_check()
	if(damage < 10)	//small cuts, tiny bruises, and moderate burns shouldn't be infectable.
		return FALSE
	if(is_treated() && damage < 25)	//anything less than a flesh wound (or equivalent) isn't infectable if treated properly
		return FALSE
	if(is_disinfected())
		return FALSE
	if(required_status & BODYPART_ROBOTIC) //Robotic injury
		return FALSE

	if(damage_type == WOUND_BLUNT && !is_bleeding()) //bruises only infectable if bleeding
		return FALSE

	switch(damage_type)
		if(WOUND_BLUNT)
			return prob(damage/2)
		if(WOUND_BURN)
			return prob(damage*2)
		if(WOUND_SLASH)
			return prob(damage)
		if(WOUND_PIERCE)
			return prob(damage*1.25)

	return FALSE

//bleeding from being dragged against the ground
/datum/injury/proc/drag_bleed_amt()
	if(!is_bleeding())
		return FALSE
	return CEILING(get_bleed_rate() * 0.35, 1)

/datum/injury/proc/bandage()
	injury_flags |= INJURY_BANDAGED

/datum/injury/proc/salve()
	injury_flags |= INJURY_SALVED

/datum/injury/proc/disinfect()
	injury_flags |= INJURY_DISINFECTED
	germ_level = 0

// heal the given amount of damage, and if the given amount of damage was more
// than what needed to be healed, return how much heal was left
/datum/injury/proc/heal_damage(amount)
	for(var/obj/item/wpn in embedded_objects)
		if(!wpn.isEmbedHarmless())
			return amount // heal nothing

	var/healed_damage = min(damage, amount)
	amount -= healed_damage
	damage -= healed_damage

	while(wound_damage() < damage_list[current_stage] && current_stage < length(desc_list))
		current_stage++
	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]

	// return amount of healing still leftover, can be used for other wounds
	return amount

// returns whether this wound can absorb the given amount of damage.
// this will prevent large amounts of damage being trapped in less severe wound types
/datum/injury/proc/can_worsen(damage_type, damage)
	if(src.damage_type != damage_type)
		return FALSE	//incompatible damage types

	if(amount > 1)
		return FALSE	//multiple wounds cannot be worsened

	//with 1.5*, a shallow cut will be able to carry at most 30 damage,
	//37.5 for a deep cut
	//52.5 for a flesh wound, etc.
	var/max_wound_damage = 1.5 * damage_list[1]
	if(src.damage + damage > max_wound_damage)
		return FALSE
	
	return TRUE

// closes the wound
/datum/injury/proc/close_injury()
	current_stage = max_bleeding_stage + 1
	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]
	if(damage > min_damage)
		heal_damage(damage-min_damage)
	injury_flags &= ~INJURY_RETRACTED_SKIN
	parent_bodypart?.update_bodypart_damage_state()
	parent_bodypart?.owner?.update_damage_overlays()

// opens the wound and worsens it
/datum/injury/proc/open_injury(damage, retracting = FALSE)
	src.damage += damage
	bleed_timer += damage

	while(current_stage > 1 && damage_list[current_stage-1] < src.damage / amount)
		current_stage--

	desc = desc_list[current_stage]
	min_damage = damage_list[current_stage]
	if(retracting)
		injury_flags |= INJURY_RETRACTED_SKIN
	parent_bodypart?.update_bodypart_damage_state()
	parent_bodypart?.owner?.update_damage_overlays()

// disinfects the wound
/datum/injury/proc/disinfect_injury()
	injury_flags |= INJURY_DISINFECTED
	return TRUE

// undisinfects the wound (differs from infecting the wound)
/datum/injury/proc/undisinfect_injury()
	injury_flags &= ~INJURY_DISINFECTED
	return TRUE

// salves the wound
/datum/injury/proc/salve_injury()
	injury_flags |= INJURY_SALVED
	return TRUE

// unsalves the wound
/datum/injury/proc/unsalve_injury()
	injury_flags &= ~INJURY_SALVED
	return TRUE

// clamps the wound
/datum/injury/proc/clamp_injury()
	injury_flags |= INJURY_CLAMPED
	return TRUE

// unclamps the wound
/datum/injury/proc/unclamp_injury()
	injury_flags &= ~INJURY_CLAMPED
	return TRUE

// bandages the wound
/datum/injury/proc/bandage_injury()
	injury_flags |= INJURY_BANDAGED
	return TRUE

// unbandages the wound
/datum/injury/proc/unbandage_injury()
	injury_flags |= INJURY_BANDAGED
	return TRUE

/datum/injury/proc/is_bleeding()
	for(var/obj/item/thing in embedded_objects)
		if(thing.w_class >= WEIGHT_CLASS_SMALL)
			return FALSE
	if(is_bandaged() || is_clamped())
		return FALSE
	return ((bleed_timer > 0 || wound_damage() > bleed_threshold) && current_stage <= max_bleeding_stage)

/datum/injury/proc/get_bleed_rate()
	if(!is_bleeding())
		return 0
	var/bad_embeddies = 0
	for(var/obj/item/wpn in embedded_objects)
		if(!wpn.isEmbedHarmless() && (wpn.w_class < WEIGHT_CLASS_SMALL))
			bad_embeddies += 1
	return max(0.1, round((bleed_rate * damage)/25 + bad_embeddies, DAMAGE_PRECISION))

/datum/injury/proc/is_surgical()
	if(CHECK_BITFIELD(injury_flags, INJURY_SURGICAL))
		return TRUE
	return FALSE

/datum/injury/proc/is_disinfected()
	if(CHECK_BITFIELD(injury_flags, INJURY_DISINFECTED) && (germ_level <= 0))
		return TRUE
	return FALSE

/datum/injury/proc/is_salved()
	if(CHECK_BITFIELD(injury_flags, INJURY_SALVED))
		return TRUE
	return FALSE

/datum/injury/proc/is_clamped()
	if(CHECK_BITFIELD(injury_flags, INJURY_CLAMPED))
		return TRUE
	return FALSE

/datum/injury/proc/is_bandaged()
	if(CHECK_BITFIELD(injury_flags, INJURY_BANDAGED) || parent_bodypart?.current_gauze)
		return TRUE
	return FALSE

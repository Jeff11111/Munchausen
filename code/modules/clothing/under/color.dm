/obj/item/clothing/under/color
	desc = "A standard issue colored jumpsuit. Variety is the spice of life!"
	dying_key = DYE_REGISTRY_UNDER

/obj/item/clothing/under/color/random
	icon_state = "random_jumpsuit"

/obj/item/clothing/under/color/random/Initialize()
	..()
	var/obj/item/clothing/under/color/C = pick(subtypesof(/obj/item/clothing/under/color) - /obj/item/clothing/under/color/random - /obj/item/clothing/under/color/grey/glorf - /obj/item/clothing/under/color/black/ghost)

	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.equip_to_slot_or_del(new C(H), SLOT_W_UNIFORM) //or else you end up with naked assistants running around everywhere...
	else
		new C(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/clothing/under/color/black
	name = "black jumpsuit"
	icon_state = "black"
	item_state = "bl_suit"
	resistance_flags = NONE

/obj/item/clothing/under/color/black/trackless
	desc = "A black jumpsuit that has its sensors removed."
	has_sensor = NO_SENSORS

/obj/item/clothing/under/color/black/ghost
	item_flags = DROPDEL

/obj/item/clothing/under/color/black/ghost/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/clothing/under/color/black/ghost/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, DROPDEL)
/obj/item/clothing/under/color/grey
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days."
	icon_state = "grey"
	item_state = "gy_suit"

/obj/item/clothing/under/color/grey/glorf
	name = "ancient jumpsuit"
	desc = "A terribly ragged and frayed grey jumpsuit. It looks like it hasn't been washed in over a decade."

/obj/item/clothing/under/color/grey/glorf/run_block(mob/living/owner, atom/object, damage, attack_text, attack_type, armour_penetration, mob/attacker, def_zone, final_block_chance, list/block_return)
	. = ..()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.forcesay(GLOB.hit_appends)

/obj/item/clothing/under/color/blue
	name = "blue jumpsuit"
	icon_state = "blue"
	item_state = "b_suit"

/obj/item/clothing/under/color/green
	name = "green jumpsuit"
	icon_state = "green"
	item_state = "g_suit"

/obj/item/clothing/under/color/orange
	name = "orange jumpsuit"
	desc = "Don't wear this near paranoid enforcers."
	icon_state = "orange"
	item_state = "o_suit"

/obj/item/clothing/under/color/pink
	name = "pink jumpsuit"
	icon_state = "pink"
	desc = "Just looking at this makes you feel <i>fabulous</i>."
	item_state = "p_suit"

/obj/item/clothing/under/color/red
	name = "red jumpsuit"
	icon_state = "red"
	item_state = "r_suit"

/obj/item/clothing/under/color/white
	name = "white jumpsuit"
	icon_state = "white"
	item_state = "w_suit"

/obj/item/clothing/under/color/yellow
	name = "yellow jumpsuit"
	icon_state = "yellow"
	item_state = "y_suit"

/obj/item/clothing/under/color/darkblue
	name = "darkblue jumpsuit"
	icon_state = "darkblue"
	item_state = "b_suit"

/obj/item/clothing/under/color/teal
	name = "teal jumpsuit"
	icon_state = "teal"
	item_state = "b_suit"

/obj/item/clothing/under/color/lightpurple
	name = "purple jumpsuit"
	icon_state = "lightpurple"
	item_state = "p_suit"

/obj/item/clothing/under/color/lightpurple/trackless
	desc = "A magically colored jumpsuit. No sensors are attached!"
	has_sensor = NO_SENSORS

/obj/item/clothing/under/color/darkgreen
	name = "darkgreen jumpsuit"
	icon_state = "darkgreen"
	item_state = "g_suit"

/obj/item/clothing/under/color/lightbrown
	name = "lightbrown jumpsuit"
	icon_state = "lightbrown"
	item_state = "lb_suit"

/obj/item/clothing/under/color/brown
	name = "brown jumpsuit"
	icon_state = "brown"
	item_state = "lb_suit"

/obj/item/clothing/under/color/maroon
	name = "maroon jumpsuit"
	icon_state = "maroon"
	item_state = "r_suit"

/obj/item/clothing/under/color/rainbow
	name = "rainbow jumpsuit"
	desc = "A multi-colored jumpsuit!"
	icon_state = "rainbow"
	item_state = "rainbow"
	can_adjust = FALSE

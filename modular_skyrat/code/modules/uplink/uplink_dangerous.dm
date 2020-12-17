/datum/uplink_item/dangerous/ebonyblade
	name = "Ebony Blade"
	desc = "An artifact that fits the literal description of a traitor, as it gets more powerful the more you kill your own."
	item = /obj/item/ebonyblade
	cost = 5

/datum/uplink_item/dangerous/mehrunesrazor
	name = "Serrated Blade"
	desc = "A dagger. Through it's chaotic will, the user may bring certain death to their target."
	item = /obj/item/kitchen/knife/combat/mehrunes
	cost = 9

/datum/uplink_item/dangerous/bladeofwoe
	name = "Blackened Dagger"
	desc = "A dagger, capable of using your enemies' blood to heal your own ailments."
	item = /obj/item/kitchen/knife/combat/woe
	cost = 8

/datum/uplink_item/dangerous/energybalisong
	name = "Energy Balisong"
	desc = "An advanced, energy tipped version of the classic knife design. Able to do massive backstab damage on targets."
	item = /obj/item/melee/transforming/butterfly/energy
	cost = 8

/datum/uplink_item/dangerous/contender
	name = "Contender Kit"
	desc = "A kit containing a Contender, a double barreled rifle that accepts any kind of ammunition, a swat helmet, a combat knife, and four 7.62mm  bullets to help you."
	item = /obj/item/storage/box/syndie/contender
	cost = 12

/datum/uplink_item/dangerous/rapier
	name = "Rapier"
	desc = "An elegant plastitanium rapier. \
			The rapier comes with its own sheath, and is capable of puncturing through almost any defense. \
			However, due to the size of the blade and obvious nature of the sheath, the weapon stands out as being obviously nefarious."
	item = /obj/item/storage/belt/sabre/rapier
	cost = 10

/datum/uplink_item/dangerous/molagmace
	name = "Will Breaker"
	desc = "A cursed artifact, capable of penetrating all armor and knocking down your targets senseless"
	item = /obj/item/melee/cleric_mace/molagbal
	cost = 8

/datum/uplink_item/dangerous/morphcube
	name = "Morph Cube"
	desc = "Gives you the ability to shapeshift into the currrent scanned animal on the cube."
	item = /obj/item/morphcube
	cost = 8

/datum/uplink_item/dangerous/cxneb
	name = "Dragon's Tooth Non-Eutactic Blade"
	desc = "An illegal modification of a weapon that is functionally identical to the energy sword, \
			the Non-Eutactic Blade (NEB) forges a hardlight blade on-demand, \
	 		generating an extremely sharp, unbreakable edge that is guaranteed to satisfy your every need. \
	 		This particular model has a polychromic hardlight generator, allowing you to murder in style! \
	 		The illegal modifications bring this weapon up to par with the classic energy sword, and also gives it the energy sword's distinctive sounds."
	item = /obj/item/melee/transforming/energy/sword/cx/traitor
	cost = 7

/datum/uplink_item/dangerous/vintorez
	name = "9x39mm Riifle"
	desc = "A fully-loaded MI13 Vintorez replica rifle. \
			This rifle comes pre-installed with an internal suppressor for covert operations."
	item = /obj/item/gun/ballistic/automatic/vintorez
	cost = 12
	include_modes = list(/datum/game_mode/nuclear)

/datum/uplink_item/dangerous/makarov
	name = "Makarov Pistol"
	desc = "A sleek box containing a small, easily concealable handgun that uses 9mm auto rounds in 15-round magazines. The handgun is compatible \
			with suppressors."
	item = /obj/item/storage/box/syndie_kit/makarov
	cost = 6
	exclude_modes = list(/datum/game_mode/nuclear/clown_ops)

// Flags for the item_flags var on /obj/item

#define BEING_REMOVED						(1<<0)
///is this item equipped into an inventory slot or hand of a mob? used for tooltips
#define IN_INVENTORY						(1<<1)
///used for tooltips
#define FORCE_STRING_OVERRIDE				(1<<2)
///Used by security bots to determine if this item is safe for public use.
#define NEEDS_PERMIT						(1<<3)
#define SLOWS_WHILE_IN_HAND					(1<<4)
///Stops you from putting things like an RCD or other items into an ORM or protolathe for materials.
#define NO_MAT_REDEMPTION					(1<<5)
///When dropped, it calls qdel on itself
#define DROPDEL								(1<<6)
///when an item has this it produces no "X has been hit by Y with Z" message in the default attackby()
#define NOBLUDGEON							(1<<7)
///for all things that are technically items but used for various different stuff
#define ABSTRACT							(1<<8)
///When players should not be able to change the slowdown of the item (Speed potions, ect)
#define IMMUTABLE_SLOW          			(1<<9)
///Tool commonly used for surgery: won't attack targets in an active surgical operation on help intent (in case of mistakes)
#define SURGICAL_TOOL						(1<<10)
///Can be worn on certain slots (currently belt and id) that would otherwise require an uniform.
#define NO_UNIFORM_REQUIRED					(1<<11)
///Damage when attacking people is not affected by combat mode.
#define NO_COMBAT_MODE_FORCE_MODIFIER		(1<<12)
/// This item can be used to parry. Only a basic check used to determine if we should proceed with parry chain at all.
#define ITEM_CAN_PARRY						(1<<13)
/// This item can be used in the directional blocking system. Only a basic check used to determine if we should proceed with directional block handling at all.
#define ITEM_CAN_BLOCK						(1<<14)

// Flags for the clothing_flags var on /obj/item/clothing

#define LAVAPROTECT 			(1<<0)
#define STOPSPRESSUREDAMAGE		(1<<1)	//SUIT and HEAD items which stop pressure damage. To stop you taking all pressure damage you must have both a suit and head item with this flag.
#define BLOCK_GAS_SMOKE_EFFECT	(1<<2)	//blocks the effect that chemical clouds would have on a mob --glasses, mask and helmets ONLY!
#define ALLOWINTERNALS		  	(1<<3)	//mask allows internals
#define NOSLIP                  (1<<4)	//prevents from slipping on wet floors, in space etc
#define NOSLIP_ICE				(1<<5)	 //prevents from slipping on frozen floors
#define THICKMATERIAL			(1<<6)	//prevents syringes, parapens and hypos if the external suit or helmet (if targeting head) has this flag. Example: space suits, biosuit, bombsuits, thick suits that cover your body.
#define VOICEBOX_TOGGLABLE 		(1<<7)	//The voicebox in this clothing can be toggled.
#define VOICEBOX_DISABLED 		(1<<8)	//The voicebox is currently turned off.
#define IGNORE_HAT_TOSS			(1<<9)	//Hats with negative effects when worn (i.e the tinfoil hat).
#define SCAN_REAGENTS			(1<<10)	// Allows helmets and glasses to scan reagents.

/// Integrity defines for clothing (not flags but close enough)
#define CLOTHING_PRISTINE	0 // We have no damage on the clothing
#define CLOTHING_DAMAGED	1 // There's some damage on the clothing but it still has at least one functioning bodypart and can be equipped
#define CLOTHING_SHREDDED	2 // The clothing is useless and cannot be equipped unless repaired first

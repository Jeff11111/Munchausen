GLOBAL_LIST_INIT(augment_datums, init_subtypes(/datum/augment))

/// Datum storing information for augmentations
/datum/augment
	/// Display name on the setup
	var/name = "Poopy Fart Code"
	/// If false, it's an organ - If true, it's a limb
	var/limb = FALSE
	/// The organ slot or body zone this occupies
	/// Null means this will not appear at all in the setup
	var/slot = null
	/// The limb or organ to install - The code will handle specifics
	var/obj/item/augmentation = null

/// Proc for applying this nigger on someone
/datum/augment/proc/apply(client/cli, datum/preferences/prefs, mob/living/carbon/C)

/// Proc for adding an augment datum to the preferences file
/datum/augment/proc/add_to_prefs(client/cli, datum/preferences/prefs)
	if(limb)
		prefs.limb_augments[slot] = list("[name]", src)
	else
		prefs.organ_augments[slot] = list("[name]", src)

/// Proc for removing an augment datum from the preferences file
/datum/augment/proc/remove_from_prefs(client/cli, datum/preferences/prefs)
	if(limb)
		prefs.limb_augments -= slot
	else
		prefs.organ_augments -= slot

/datum/keybinding/living/give
	hotkey_keys = list("G")
	name = "give"
	full_name = "Give"
	description = "Offer the item in your active hand to someone else."

/datum/keybinding/living/give/down(client/user)
	var/mob/living/L = user.mob
	L.give()
	return TRUE

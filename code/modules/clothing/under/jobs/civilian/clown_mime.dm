
/obj/item/clothing/under/rank/civilian/mime
	name = "mime's outfit"
	desc = "It's not very colourful."
	icon_state = "mime"
	item_state = "mime"

/obj/item/clothing/under/rank/civilian/mime/skirt
	name = "mime's skirt"
	desc = "It's not very colourful."
	icon_state = "mime_skirt"
	item_state = "mime"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/under/rank/civilian/mime/sexy
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state = "sexymime"
	body_parts_covered = CHEST|GROIN|LEGS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/clown
	name = "jester suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	item_state = "clown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = STYLE_DIGITIGRADE //The clown suit must look funny, no taur alpha masks where possible.

/obj/item/clothing/under/rank/civilian/clown/blue
	name = "blue jester suit"
	desc = "<i>'BLUE HONK!'</i>"
	icon_state = "blueclown"
	item_state = "blueclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/under/rank/civilian/clown/green
	name = "green jester suit"
	desc = "<i>'GREEN HONK!'</i>"
	icon_state = "greenclown"
	item_state = "greenclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/under/rank/civilian/clown/yellow
	name = "yellow jester suit"
	desc = "<i>'YELLOW HONK!'</i>"
	icon_state = "yellowclown"
	item_state = "yellowclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/under/rank/civilian/clown/purple
	name = "purple jester suit"
	desc = "<i>'PURPLE HONK!'</i>"
	icon_state = "purpleclown"
	item_state = "purpleclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/under/rank/civilian/clown/orange
	name = "orange jester suit"
	desc = "<i>'ORANGE HONK!'</i>"
	icon_state = "orangeclown"
	item_state = "orangeclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/under/rank/civilian/clown/rainbow
	name = "rainbow jester suit"
	desc = "<i>'R A I N B O W HONK!'</i>"
	icon_state = "rainbowclown"
	item_state = "rainbowclown"
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/under/rank/civilian/clown/jester
	name = "jester suit"
	desc = "A jolly dress, well suited to entertain any ravenhearter."
	icon_state = "jester"
	can_adjust = FALSE
	mutantrace_variation = STYLE_DIGITIGRADE|USE_TAUR_CLIP_MASK

/obj/item/clothing/under/rank/civilian/clown/jester/alt
	icon_state = "jester2"

/obj/item/clothing/under/rank/civilian/clown/sexy
	name = "sexy-jester suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	item_state = "sexyclown"
	can_adjust = FALSE
	mutantrace_variation = STYLE_DIGITIGRADE|USE_TAUR_CLIP_MASK

/obj/item/clothing/under/rank/civilian/clown/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)

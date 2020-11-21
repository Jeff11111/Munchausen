
/obj/item/clothing/under/rank/cargo/qm
	name = "quartermaster's turtleneck"
	desc = "It's a turtleneck worn by the quartermaster. It's specially designed to prevent back injuries caused by carrying gold."
	icon_state = "qm"
	item_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/qm/skirt
	name = "quartermaster's jumpskirt"
	desc = "It's a jumpskirt worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper."
	icon_state = "qm_skirt"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's gorka"
	desc = "Gorkas! They're comfy and easy to wear!"
	icon_state = "cargo"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "cargo technician's jumpskirt"
	desc = "Skiiiiirts! They're comfy and easy to wear"
	icon_state = "cargo_skirt"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	mutantrace_variation = STYLE_DIGITIGRADE|STYLE_NO_ANTHRO_ICON

/obj/item/clothing/under/rank/cargo/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	//skyrat edit
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 0, "wound" = 10)
	//

/obj/item/clothing/under/rank/cargo/miner/lavaland
	desc = "A hard-wroking uniform for operating in hazardous environments. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	can_adjust = FALSE

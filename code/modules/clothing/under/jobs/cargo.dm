
/obj/item/clothing/under/rank/cargo/qm
	name = "logistics officer's turtleneck"
	desc = "It's a turtleneck worn by the logistics officer. It's specially designed to prevent back injuries caused by carrying gold."
	icon_state = "qm"
	item_state = "lb_suit"

/obj/item/clothing/under/rank/cargo/tech
	name = "cargo technician's gorka"
	desc = "Gorkas - Because supply workers deserve to be cool."
	icon_state = "cargo"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/cargo/miner
	desc = "It's a snappy jumpsuit with a sturdy set of overalls. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 0, "wound" = 10)

/obj/item/clothing/under/rank/cargo/miner/lavaland
	desc = "A hard-wroking uniform for operating in hazardous environments. It is very dirty."
	name = "shaft miner's jumpsuit"
	icon_state = "miner"
	item_state = "miner"
	can_adjust = FALSE

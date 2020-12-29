/** BRUISES **/
/datum/injury/bruise
	stages = list(
		"monumental bruise" = 80,
		"huge bruise" = 50,
		"large bruise" = 30,
		"moderate bruise" = 20,
		"small bruise" = 10,
		"tiny bruise" = 5,
		"tiny hematoma" = 0,
		)

	bleed_threshold = 20
	max_bleeding_stage = 3 //only large bruise and above can bleed.
	autoheal_cutoff = 30
	damage_type = WOUND_BLUNT

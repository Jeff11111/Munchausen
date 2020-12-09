/datum/looping_sound/showering
	start_sound = 'sound/machines/shower/shower_start.ogg'
	start_length = 2
	mid_sounds = list('sound/machines/shower/shower_mid1.ogg'=1,'sound/machines/shower/shower_mid2.ogg'=1,'sound/machines/shower/shower_mid3.ogg'=1)
	mid_length = 10
	end_sound = 'sound/machines/shower/shower_end.ogg'
	volume = 10

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/supermatter
	mid_sounds = list('sound/machines/sm/supermatter1.ogg'=1,'sound/machines/sm/supermatter2.ogg'=1,'sound/machines/sm/supermatter3.ogg'=1)
	mid_length = 10
	volume = 1

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/generator
	start_sound = 'sound/machines/generator/generator_start.ogg'
	start_length = 4
	mid_sounds = list('sound/machines/generator/generator_mid1.ogg'=1, 'sound/machines/generator/generator_mid2.ogg'=1, 'sound/machines/generator/generator_mid3.ogg'=1)
	mid_length = 4
	end_sound = 'sound/machines/generator/generator_end.ogg'
	volume = 40

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/datum/looping_sound/deep_fryer
	start_sound = 'sound/machines/fryer/deep_fryer_immerse.ogg' //my immersions
	start_length = 10
	mid_sounds = list('sound/machines/fryer/deep_fryer_1.ogg' = 1, 'sound/machines/fryer/deep_fryer_2.ogg' = 1)
	mid_length = 2
	end_sound = 'sound/machines/fryer/deep_fryer_emerge.ogg'
	volume = 5

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/microwave
	start_sound = 'sound/machines/microwave/microwave-start.ogg'
	start_length = 10
	mid_sounds = list('sound/machines/microwave/microwave-mid1.ogg'=10, 'sound/machines/microwave/microwave-mid2.ogg'=1)
	mid_length = 10
	end_sound = 'sound/machines/microwave/microwave-end.ogg'
	volume = 90

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/grill
	mid_length = 2
	mid_sounds = list('sound/machines/fryer/deep_fryer_1.ogg' = 1, 'sound/machines/fryer/deep_fryer_2.ogg' = 1)
	volume = 10

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/holopad
	mid_length = 20
	mid_sounds = list('sound/machines/hologram.ogg' = 1)
	volume = 10

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/firealarm
	start_sound = 'sound/machines/firealarmstart.ogg'
	start_length = 18
	mid_sounds = list('sound/machines/firealarmloop.ogg' = 1)
	mid_length = 70
	end_sound = 'sound/machines/firealarmend.ogg'
	volume = 25

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/looping_sound/cryotube
	mid_sounds = list('sound/machines/cryotube.ogg' = 1)
	mid_length = 24
	volume = 25

/datum/looping_sound/server
	mid_sounds = list('sound/machines/tcomms/tcomms_mid1.ogg'=1,'sound/machines/tcomms/tcomms_mid2.ogg'=1,'sound/machines/tcomms/tcomms_mid3.ogg'=1,'sound/machines/tcomms/tcomms_mid4.ogg'=1,\
										'sound/machines/tcomms/tcomms_mid5.ogg'=1,'sound/machines/tcomms/tcomms_mid6.ogg'=1,'sound/machines/tcomms/tcomms_mid7.ogg'=1)
	mid_length = 1.8 SECONDS
	extra_range = -4.5
	volume = 50

/datum/looping_sound/computer
	start_sound = 'sound/machines/computer/computer_start.ogg'
	start_length = 7.2 SECONDS
	start_volume = 10
	mid_sounds = list('sound/machines/computer/computer_mid1.ogg'=1, 'sound/machines/computer/computer_mid2.ogg'=1)
	mid_length = 1.8 SECONDS
	end_sound = 'sound/machines/computer/computer_end.ogg'
	end_volume = 10
	volume = 3
	extra_range = -5.5

/datum/looping_sound/gravgen
	mid_sounds = list('sound/machines/gravgen/gravgen_mid1.ogg'=1,'sound/machines/gravgen/gravgen_mid2.ogg'=1,'sound/machines/gravgen/gravgen_mid3.ogg'=1,'sound/machines/gravgen/gravgen_mid4.ogg'=1,)
	mid_length = 1.8 SECONDS
	volume = 70

/datum/looping_sound/conveyor
	start_sound = 'modular_skyrat/sound/machinery/conveyor_start.ogg'
	start_length = 0.9 SECONDS
	mid_sounds = list('sound/machines/generator/conveyor_loop.ogg'=1)
	mid_length = 3.5 SECONDS
	volume = 40

/datum/looping_sound/recycler
	start_sound = 'modular_skyrat/sound/machinery/trashcompactor_start.ogg'
	start_length = 2.45 SECONDS
	mid_sounds = list('sound/machines/generator/trashcompactor_loop.ogg'=1)
	mid_length = 10.8 SECONDS
	end_sound = 'sound/machines/generator/trashcompactor_end.ogg'
	volume = 60

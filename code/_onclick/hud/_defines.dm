/*
	These defines specificy screen locations.  For more information, see the byond documentation on the screen_loc var.

	The short version:

	Everything is encoded as strings because apparently that's how Byond rolls.

	"1,1" is the bottom left square of the user's screen.  This aligns perfectly with the turf grid.
	"1:2,3:4" is the square (1,3) with pixel offsets (+2, +4); slightly right and slightly above the turf grid.
	Pixel offsets are used so you don't perfectly hide the turf under them, that would be crappy.

	In addition, the keywords NORTH, SOUTH, EAST, WEST and CENTER can be used to represent their respective
	screen borders. NORTH-1, for example, is the row just below the upper edge. Useful if you want your
	UI to scale with screen size.

	The size of the user's screen is defined by client.view (indirectly by world.view), in our case "15x15".
	Therefore, the top right corner (except during admin shenanigans) is at "15,15"
*/

//Lower left, persistent menu
#define ui_inventory "WEST,SOUTH"

//Middle left indicators
#define ui_lingchemdisplay "WEST,CENTER-1:15"
#define ui_lingstingdisplay "WEST:6,CENTER-3:11"
#define ui_devilsouldisplay "WEST:6,CENTER-1:15"

//Lower center, persistent menu
#define ui_id "CENTER-3,SOUTH"
#define ui_belt "CENTER-2,SOUTH"
#define ui_back "CENTER-1,SOUTH"

/proc/ui_hand_position(i)
	var/x_off = (i % 2)
	return"CENTER+[x_off],SOUTH"

/proc/ui_equip_position(mob/M)
	return "CENTER,SOUTH+1"

/proc/ui_swaphand_position(mob/M, which = 1)
	var/x_off = which == 1 ? 0 : 1
	return "CENTER+[x_off],SOUTH+1"

//Widescreen (default location) for pockets
#define ui_storage1 "CENTER+2,SOUTH"
#define ui_storage2 "CENTER+3,SOUTH"

//Non-widescreen
#define ui_boxstorage1 "WEST,SOUTH+7"
#define ui_boxstorage2 "WEST,SOUTH+8"

#define ui_borg_sensor "CENTER-3:15, SOUTH:5"		//borgs
#define ui_borg_lamp "CENTER-4:15, SOUTH:5"			//borgs
#define ui_borg_thrusters "CENTER-5:15, SOUTH:5"	//borgs
#define ui_inv1 "CENTER-2:16,SOUTH:5"				//borgs
#define ui_inv2 "CENTER-1  :16,SOUTH:5"				//borgs
#define ui_inv3 "CENTER  :16,SOUTH:5"				//borgs
#define ui_borg_module "CENTER+1:16,SOUTH:5"		//borgs
#define ui_borg_store "CENTER+2:16,SOUTH:5"			//borgs
#define ui_borg_camera "CENTER+3:21,SOUTH:5"		//borgs
#define ui_borg_album "CENTER+4:21,SOUTH:5"			//borgs
#define ui_borg_language_menu "EAST-1:27,SOUTH+2:8"	//borgs

#define ui_monkey_head "CENTER-5:13,SOUTH:5"	//monkey
#define ui_monkey_mask "CENTER-4:14,SOUTH:5"	//monkey
#define ui_monkey_neck "CENTER-3:15,SOUTH:5"	//monkey
#define ui_monkey_back "CENTER-2:16,SOUTH:5"	//monkey

//#define ui_alien_storage_l "CENTER-2:14,SOUTH:5"//alien
#define ui_alien_storage_r "CENTER+1:18,SOUTH:5"//alien
#define ui_alien_language_menu "EAST-3:26,SOUTH:5" //alien

#define ui_drone_drop "CENTER+1:18,SOUTH:5"     //maintenance drones
#define ui_drone_pull "CENTER+2:2,SOUTH:5"      //maintenance drones
#define ui_drone_storage "CENTER-2:14,SOUTH:5"  //maintenance drones
#define ui_drone_head "CENTER-3:14,SOUTH:5"     //maintenance drones

//Lower right, persistent menu
#define ui_specialattack "EAST-5,SOUTH+1"
#define ui_sleep "EAST-4,SOUTH+1"
#define ui_teach "EAST-4,SOUTH+1"
#define ui_wield "EAST-3,SOUTH+1"
#define ui_resist "EAST-3,SOUTH+1"
#define ui_pull "EAST-2,SOUTH+1"
#define ui_rest "EAST-2,SOUTH+1"
#define ui_throw "EAST-1,SOUTH+1"
#define ui_drop "EAST-1,SOUTH+1"
#define ui_combat_intent "EAST-6,SOUTH"
#define ui_combat_toggle "EAST-5,SOUTH"
#define ui_skills "EAST-4,SOUTH"
#define ui_building "EAST-4,SOUTH"
#define ui_crafting "EAST-4,SOUTH"
#define ui_language_menu "EAST-4,SOUTH"
#define ui_acti "EAST-3,SOUTH"
#define ui_sprint "EAST-2,SOUTH"
#define ui_sprintbufferloc "EAST-2,SOUTH:13"
#define ui_movi "EAST-2,SOUTH"
#define ui_dodge_parry "EAST-1,SOUTH"
#define ui_zonesel "EAST,SOUTH"

//lesser hud idk
#define ui_acti_alt "EAST-1:28,SOUTH:5"

//Borg shit
#define ui_borg_pull "EAST-2:26,SOUTH+1:7"
#define ui_borg_radio "EAST-1:28,SOUTH+1:7"
#define ui_borg_intents "EAST-2:26,SOUTH:5"

//Upper-middle right (alerts)
#define ui_alert1 "EAST,NORTH"
#define ui_alert2 "EAST-1,NORTH"
#define ui_alert3 "EAST,NORTH-1"
#define ui_alert4 "EAST-1,NORTH-1"
#define ui_alert5 "EAST,NORTH-2"
#define ui_alert6 "EAST-1,NORTH-2"

//Middle right (status indicators)
#define ui_internal "EAST:-2,CENTER+2"
#define ui_nutrition "EAST:-2,CENTER+1"
#define ui_hydration "EAST:-2,CENTER+1"
#define ui_fixeye "EAST,CENTER"
#define ui_stamina "EAST,CENTER-1"
#define ui_mood "EAST,CENTER-2"
#define ui_pulse "EAST,CENTER-3"
#define ui_pain	"EAST,CENTER-4"
#define ui_healthdoll "EAST,CENTER-5"

//Middle of the screen
#define ui_fov "CENTER-7,CENTER-7"

//Living
#define ui_living_pull "EAST-1:28,CENTER-2:15"
#define ui_living_health "EAST-1:28,CENTER:15"

//Borgs
#define ui_borg_health "EAST-1:28,CENTER-1:15"		//borgs have the health display where humans have the pressure damage indicator.

//Aliens
#define ui_alien_health "EAST,CENTER-1:15"	//aliens have the health display where humans have the pressure damage indicator.
#define ui_alienplasmadisplay "EAST,CENTER-2:15"
#define ui_alien_queen_finder "EAST,CENTER-3:15"

//Constructs
#define ui_construct_pull "EAST,CENTER-2:15"
#define ui_construct_health "EAST,CENTER:15"  //same as borgs and humans

//AI
#define ui_ai_core "SOUTH:6,WEST"
#define ui_ai_camera_list "SOUTH:6,WEST+1"
#define ui_ai_track_with_camera "SOUTH:6,WEST+2"
#define ui_ai_camera_light "SOUTH:6,WEST+3"
#define ui_ai_crew_monitor "SOUTH:6,WEST+4"
#define ui_ai_crew_manifest "SOUTH:6,WEST+5"
#define ui_ai_alerts "SOUTH:6,WEST+6"
#define ui_ai_announcement "SOUTH:6,WEST+7"
#define ui_ai_shuttle "SOUTH:6,WEST+8"
#define ui_ai_state_laws "SOUTH:6,WEST+9"
#define ui_ai_pda_send "SOUTH:6,WEST+10"
#define ui_ai_pda_log "SOUTH:6,WEST+11"
#define ui_ai_take_picture "SOUTH:6,WEST+12"
#define ui_ai_view_images "SOUTH:6,WEST+13"
#define ui_ai_sensor "SOUTH:6,WEST+14"
#define ui_ai_multicam "SOUTH+1:6,WEST+13"
#define ui_ai_add_multicam "SOUTH+1:6,WEST+14"

//Pop-up inventory
#define ui_shoes "WEST+1,SOUTH"
#define ui_sstore1 "WEST+2,SOUTH"
#define ui_iclothing "WEST,SOUTH+1"
#define ui_oclothing "WEST+1,SOUTH+1"
#define ui_gloves "WEST+2,SOUTH+1"
#define ui_neck "WEST,SOUTH+2"
#define ui_mask "WEST+1,SOUTH+2"
#define ui_glasses "WEST+2,SOUTH+2"
#define ui_inventory_extra "WEST,SOUTH+3"
#define ui_head "WEST+1,SOUTH+3"
#define ui_ears "WEST+2,SOUTH+3"
#define ui_boxers "WEST,SOUTH+4"
#define ui_socks "WEST,SOUTH+5"
#define ui_shirt "WEST,SOUTH+6"
#define ui_ears_extra "WEST+2,SOUTH+4"
#define ui_wrists "WEST+1,SOUTH+4"

//Ghosts
#define ui_ghost_jumptomob "SOUTH,CENTER-1"
#define ui_ghost_orbit "SOUTH,CENTER"
#define ui_ghost_reenter_corpse "SOUTH,CENTER+1"
#define ui_ghost_teleport "SOUTH,CENTER+2"
#define ui_ghost_spawners "SOUTH,CENTER+3"
#define ui_ghost_eventsignup "NORTH-1, WEST"

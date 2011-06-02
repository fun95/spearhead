//+----------------------------------------------------------------------------------------------------------------------------------+
//¦ Call of Duty 4: Modern Warfare                                                                                                   ¦
//¦----------------------------------------------------------------------------------------------------------------------------------¦
//¦ Mod				: [SHIFT]SPEARHEAD INTERNATIONAL FREEZETAG                                                           ¦
//¦ Modifications By		: [SHIFT]Newfie                                                                                      ¦
//+----------------------------------------------------------------------------------------------------------------------------------+
//¦ Colour Codes For RGB	Colour Codes For Text                                                                                ¦
//+----------------------------------------------------------------------------------------------------------------------------------+
//¦ Black  0 0 0		^0 = Black                                                                                           ¦
//¦ White  1 1 1 		^7 = White                                                                                           ¦
//¦ Red    1 0 0		^1 = Red                                                                                             ¦
//¦ Green  0 1 0		^2 = Green                                                                                           ¦
//¦ Blue   0 0 1		^4 = Blue                                                                                            ¦
//¦ Yellow 1 1 0		^3 = Yellow                                                                                          ¦
//¦ 				^5 = Cyan                                                                                            ¦
//¦ 				^6 = pink/Magenta                                                                                    ¦
//+----------------------------------------------------------------------------------------------------------------------------------+

#include shift\_utils;

init()
{
	// Freezetag Variables
	level.scr_gameplay_ftag = getdvarx( "scr_gameplay_ftag", "int", 0, 0, 1 );

	// Misc Variables
	level.scr_OneLeftSoundEvent = getdvarx( "scr_OneLeftSoundEvent", "int", 1, 0, 1 );

	// Show always the minimap in hardcore mode
	level.scr_hud_hardcore_show_minimap = getdvarx( "scr_hardcore_show_minimap", "int", 0, 0, 1 );

	// Show only the compass (North, South, West, East)
	level.scr_hud_hardcore_show_compass = getdvarx( "scr_hardcore_show_compass", "int", 0, 0, 1 );

	// Variables used in menu files
	level.scr_hud_show_inventory = getdvarx( "scr_hud_show_inventory", "int", 0, 0, 2 );

	return;
}

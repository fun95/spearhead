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
	tempvalue = getdvardefault( "ui_gameplay_ftag", "int", 2, 0, 2 );
	if( tempvalue == 2 ) {
		ui_gameplay_ftag = getdvardefault( "scr_gameplay_ftag", "int", 0, 0, 1 );
		setdvar( "ui_gameplay_ftag", ui_gameplay_ftag );
		makeDvarServerInfo( "ui_gameplay_ftag" );
	}

	// Show always the minimap in hardcore mode
	level.scr_hud_hardcore_show_minimap = getdvardefault( "scr_hardcore_show_minimap", "int", 0, 0, 1 );

	// Show only the compass (North, South, West, East)
	level.scr_hud_hardcore_show_compass = getdvardefault( "scr_hardcore_show_compass", "int", 0, 0, 1 );

	// Variables used in menu files
	level.scr_hud_show_inventory = getdvardefault( "scr_hud_show_inventory", "int", 0, 0, 2 );

	// Load the clan tags
	level.scr_clan_tags = getdvardefault( "scr_clan_tags", "string", "" );
	level.scr_clan_tags = strtok( level.scr_clan_tags, " " );

	// Misc Variables
	level.scr_gameplay_ftag = getdvardefault( "ui_gameplay_ftag", "int", 0, 0, 1 );
	level.scr_disable_match_join = getdvardefault( "scr_disable_match_join", "int", 0, 0, 1 );
	precacheShader( "hudStopwatch" );

	// New Compact Dvar values
	level.scr_show_unreal_messages = getdvardefault( "scr_show_unreal_messages", "int", 0, 0, 1 );
	level.scr_clan_member_status = getdvardefault( "scr_clan_member_status", "string", "" );
	level.scr_ftag_defrost_values = getdvardefault( "scr_ftag_defrost_values", "string", "mode0;1;15;0;0;use;0;1" );

	return;
}

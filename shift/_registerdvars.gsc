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
	// Load the clan tags
	level.scr_clan_tags = ( getdvar( "scr_clan_tags" ) == "" );
	level.scr_clan_tags = strtok( level.scr_clan_tags, " " );


	// Set new compact clan member values from single dvar
	level.scr_clan_member_status = getdvar( "scr_clan_member_status" );


	// Set new compact defrost values from single dvar
	level.scr_ftag_defrost_values = getdvardefault( "scr_ftag_defrost_values", "string", "0;1;15;50;0;0;1;use" );
	defaultvalues = strtok( level.scr_ftag_defrost_values, ";" );

	level.scr_ftag_defrost = [];
	level.scr_ftag_defrost["mode"] = int( defaultvalues[0] );
	level.scr_ftag_defrost["respawn"] = int( defaultvalues[1] );
	level.scr_ftag_defrost["time"] = int( defaultvalues[2] ) / 100;
	level.scr_ftag_defrost["dist"] = int( defaultvalues[3] );
	level.scr_ftag_defrost["auto"] = int( defaultvalues[4] );
	level.scr_ftag_defrost["beam"] = int( defaultvalues[5] );
	level.scr_ftag_defrost["cube"] = int( defaultvalues[6] );
	level.scr_ftag_defrost["button"] = defaultvalues[7];


	// Set new compact gameplay values from single dvar
	level.scr_ftag_gameplay_values = getdvardefault( "scr_ftag_gameplay_values", "string", "0;0;10;0;0" );
	defaultvalues = strtok( level.scr_ftag_gameplay_values, ";" );

	level.scr_shift_gameplay = [];
	level.scr_shift_gameplay["ftag"] = int( defaultvalues[0] );
	level.scr_shift_gameplay["spawn"] = int( defaultvalues[1] );
	level.scr_shift_gameplay["clock"] = int( defaultvalues[2] );
	level.scr_shift_gameplay["join"] = int( defaultvalues[3] );
	level.scr_shift_gameplay["unreal"] = int( defaultvalues[4] );


	// Freezetag Variable
	tempvalue = getdvardefault( "ui_gameplay_ftag", "int", 2, 0, 2 );
	if( tempvalue == 2 ) {
		ui_gameplay_ftag = level.scr_shift_gameplay["ftag"];
		setdvar( "ui_gameplay_ftag", ui_gameplay_ftag );
		makeDvarServerInfo( "ui_gameplay_ftag" );
	}


	// Set new compact HUD message values from single dvar
	level.scr_hud_display_options = getdvardefault( "scr_hud_display_options", "string", "0;0;0;0;0;0;0;0;0" );
	defaultvalues = strtok( level.scr_hud_display_options, ";" );

	level.scr_hud_hardcore_show_minimap = int( defaultvalues[0] );
	level.scr_hud_hardcore_show_compass = int( defaultvalues[1] );
	level.scr_hud_show_inventory = int( defaultvalues[2] );

	level.scr_shift_hud = [];
	level.scr_shift_hud["center"] = int( defaultvalues[3] );
	level.scr_shift_hud["left"] = int( defaultvalues[4] );
	level.scr_shift_hud["team"] = int( defaultvalues[5] );
	level.scr_shift_hud["stats"] = int( defaultvalues[6] );
	level.scr_shift_hud["delay"] = int( defaultvalues[7] );
	level.scr_shift_hud["welcome"] = int( defaultvalues[8] );


	// Set new compact annoy feature values from single dvar
	level.scr_annoy_feature_options = getdvardefault( "scr_annoy_feature_options", "string", "0;4000;200;0;0" );
	defaultvalues = strtok( level.scr_annoy_feature_options, ";" );

	level.scr_ftag_annoy = [];
	level.scr_ftag_annoy["warn"] = int( defaultvalues[0] );
	level.scr_ftag_annoy["time"] = int( defaultvalues[1] );
	level.scr_ftag_annoy["dist"] = int( defaultvalues[2] );
	level.scr_ftag_annoy["shots"] = int( defaultvalues[3] );
	level.scr_ftag_annoy["knife"] = int( defaultvalues[4] );


	// Set new compact spectator_options from single dvar
	level.scr_spectator_options = getdvardefault( "scr_spectator_options", "string", "0;0;90;0" );
	defaultvalues = strtok( level.scr_spectator_options, ";" );

	level.scr_shift_spectator = [];
	level.scr_shift_spectator["freespec"] = int( defaultvalues[0] );
	level.scr_shift_spectator["otspec"] = int( defaultvalues[1] );
	level.scr_shift_spectator["ottime"] = int( defaultvalues[2] );
	level.scr_shift_spectator["score"] = int( defaultvalues[3] );


	precacheShader( "hudStopwatch" );


	return;
}
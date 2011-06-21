//+----------------------------------------------------------------------------------------------------------------------------------+
//¦ Call of Duty 4: Modern Warfare                                                                                                   ¦
//¦----------------------------------------------------------------------------------------------------------------------------------¦
//¦ Mod                 : [SHIFT]SPEARHEAD INTERNATIONAL FREEZETAG                                                                   ¦
//¦ Modifications By    : [SHIFT]Newfie                                                                                              ¦
//+----------------------------------------------------------------------------------------------------------------------------------+
//¦ Colour Codes RGB    Colour Codes For Text                                                                                        ¦
//+----------------------------------------------------------------------------------------------------------------------------------+
//¦ Black  0 0 0        ^0 = Black                                                                                                   ¦
//¦ White  1 1 1        ^7 = White                                                                                                   ¦
//¦ Red    1 0 0        ^1 = Red                                                                                                     ¦
//¦ Green  0 1 0        ^2 = Green                                                                                                   ¦
//¦ Blue   0 0 1        ^4 = Blue                                                                                                    ¦
//¦ Yellow 1 1 0        ^3 = Yellow                                                                                                  ¦
//¦                     ^5 = Cyan                                                                                                    ¦
//¦                     ^6 = pink/Magenta                                                                                            ¦
//+----------------------------------------------------------------------------------------------------------------------------------+

#include shift\_utils;

init()
{
	// Set new compact string values from single dvar
	level getMultidvar( "scr_shift_string_values", "string", "hudwelcome;ftagbutton", "none;use" );


	// Set new compact gameplay values from single dvar
	level getMultidvar( "scr_shift_gameplay_values", "int", "gpftag;gphealthbar;gphealth;gpspawn;gpclock;gpjoin;gpunreal", "0;0;0;0;10;0;0" );


	// Set new compact defrost values from single dvar
	level getMultidvar( "scr_shift_ftag_defrost_values", "int", "ftagscore;ftagmode;ftagrespawn;ftagtime;ftagdist;ftagauto;ftagbeam;ftagrotate", "50;0;1;15;50;0;0;1" );


	// Set new compact HUD message values from single dvar
	level getMultidvar( "scr_shift_hud_values", "int", "hudcenter;hudleft;hudteam;hudstats;huddelay", "0;0;0;0;0" );


	// Set new compact annoy feature values from single dvar
	level getMultidvar( "scr_shift_ftag_annoy_values", "int", "annoywarn;annoytime;annoydist;annoyshots;annoyknife", "0;4000;200;0;0" );


	// Set new compact spectator options from single dvar
	level getMultidvar( "scr_shift_spectator_values", "int", "specfree;specot;specottime;specscore", "0;0;90;0" );


	// Freezetag Variable
	if ( getdvar( "ui_gameplay_ftag" ) == "" )
		tempvalue = 2;
	else
		tempvalue = getdvarint( "ui_gameplay_ftag" );

	if( tempvalue == 2 ) {
		ui_gameplay_ftag = level.scr_shift_dvar["gpftag"];
		setdvar( "ui_gameplay_ftag", ui_gameplay_ftag );
		makeDvarServerInfo( "ui_gameplay_ftag" );
	} else {
		level.scr_shift_dvar["gpftag"] = tempvalue;
	}


	// Set new compact Rcon warning message options from single dvar
	level.scr_shift_rcon_warn_player = getdvardefault( "scr_shift_rcon_warn_player", "string", "" );
	defaultvalues = strtok( level.scr_shift_rcon_warn_player, ";" );

	level.scr_shift_rcon_warn_who = [];
	level.scr_shift_rcon_warn_abv = [];
	level.scr_shift_rcon_warn = [];
	
	// Add no custom warning option
	level.scr_shift_rcon_warn_who[0] = "";
	level.scr_shift_rcon_warn_abv[0] = "No Warning Message";
	level.scr_shift_rcon_warn[0] = "";

	// Add all other custom warnings
	for ( i=0; i < defaultvalues.size; i++ ) {
		newElement = level.scr_shift_rcon_warn_abv.size;
		level.scr_shift_rcon_warn_who[newElement] = "player";
		level.scr_shift_rcon_warn_abv[newElement] = defaultvalues[i];
		i++;
		level.scr_shift_rcon_warn[newElement] = defaultvalues[i];
	}

	level.scr_shift_rcon_warn_all = getdvardefault( "scr_shift_rcon_warn_all", "string", "" );
	defaultvalues = strtok( level.scr_shift_rcon_warn_all, ";" );

	// Add all other custom warnings
	for ( i=0; i < defaultvalues.size; i++ ) {
		newElement = level.scr_shift_rcon_warn_abv.size;
		level.scr_shift_rcon_warn_who[newElement] = "all";
		level.scr_shift_rcon_warn_abv[newElement] = defaultvalues[i];
		i++;
		level.scr_shift_rcon_warn[newElement] = defaultvalues[i];
	}


	// Set new compact server message options from single dvar
	level.scr_shift_server_messages = getdvardefault( "scr_shift_server_messages", "string", "0;15" );
	defaultvalues = strtok( level.scr_shift_server_messages, ";" );

	level.scr_shift_server_messages = [];
	level.scr_shift_server_messages["messages"] = int( defaultvalues[0] );
	level.scr_shift_server_messages["msgdelay"] = int( defaultvalues[1] );

	// Add all custom messages
	for ( i=2; i < defaultvalues.size; i++ )
		level.scr_shift_server_messages[level.scr_shift_server_messages.size] = defaultvalues[i];


	// Set new compact banner message options from single dvar
	level.scr_shift_banner_messages = getdvardefault( "scr_shift_banner_messages", "string", "0;15" );
	defaultvalues = strtok( level.scr_shift_banner_messages, ";" );

	level.scr_shift_banner_messages = [];
	level.scr_shift_banner_messages["messages"] = int( defaultvalues[0] );
	level.scr_shift_banner_messages["msgdelay"] = int( defaultvalues[1] );

	// Add all custom messages
	for ( i=2; i < defaultvalues.size; i++ )
		level.scr_shift_banner_messages[level.scr_shift_banner_messages.size] = defaultvalues[i];


	// Set new compact HARDCORE values from single dvar
	level.scr_hud_hardcore_options = getdvardefault( "scr_hud_hardcore_options", "string", "0;0;0" );
	defaultvalues = strtok( level.scr_hud_hardcore_options, ";" );

	level.scr_hud_hardcore_show_minimap = int( defaultvalues[0] );
	level.scr_hud_hardcore_show_compass = int( defaultvalues[1] );
	level.scr_hud_show_inventory = int( defaultvalues[2] );


	precacheShader( "hudStopwatch" );
	precacheShader("overlay_low_health");
	return;
}
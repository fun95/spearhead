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

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

// Function to get extended dvar values
getdvarx( dvarName, dvarType, dvarDefault, minValue, maxValue )
{
	// Check variables from lowest to highest priority

	if ( !isDefined( level.gametype ) ) {
		level.script = toLower( getDvar( "mapname" ) );
		level.gametype = toLower( getDvar( "g_gametype" ) );
		level.serverLoad = getDvar( "_sl_current" );
	}
	
	// scr_variable_name_<load>
	if ( getdvar( dvarName + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.serverLoad;
			
	// scr_variable_name_<gametype>
	if ( getdvar( dvarName + "_" + level.gametype ) != "" )
		dvarName = dvarName + "_" + level.gametype;

	// scr_variable_name_<gametype>_<load>
	if ( getdvar( dvarName + "_" + level.gametype + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.gametype + "_" + level.serverLoad;		

	// scr_variable_name_<mapname>
	if ( getdvar( dvarName + "_" + level.script ) != "" )
		dvarName = dvarName + "_" + level.script;

	// scr_variable_name_<mapname>_<load>
	if ( getdvar( dvarName + "_" + level.script + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.script + "_" + level.serverLoad;

	// scr_variable_name_<gametype>_<mapname>
	if ( getdvar( dvarName + "_" + level.gametype + "_" + level.script ) != "" )
		dvarName = dvarName + "_" + level.gametype + "_" + level.script;

	// scr_variable_name_<gametype>_<mapname>_<load>
	if ( getdvar( dvarName + "_" + level.gametype + "_" + level.script + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.gametype + "_" + level.script + "_" + level.serverLoad;

	return getdvard( dvarName, dvarType, dvarDefault, minValue, maxValue );
}


// Function to get extended dvar values (only with server load)
getdvarl( dvarName, dvarType, dvarDefault, minValue, maxValue, useLoad )
{
	// scr_variable_name_<load>
	if ( isDefined( level.serverLoad ) && useLoad && getdvar( dvarName + "_" + level.serverLoad ) != "" )
		dvarName = dvarName + "_" + level.serverLoad;

	return getdvard( dvarName, dvarType, dvarDefault, minValue, maxValue );
}


// Function to get dvar values (not extended)
getdvard( dvarName, dvarType, dvarDefault, minValue, maxValue )
{
	// Initialize the return value just in case an invalid dvartype is passed
	dvarValue = "";

	// Assign the default value if the dvar is empty
	if ( getdvar( dvarName ) == "" ) {
		dvarValue = dvarDefault;
	} else {
		// If the dvar is not empty then bring the value
		switch ( dvarType ) {
			case "int":
				dvarValue = getdvarint( dvarName );
				break;
			case "float":
				dvarValue = getdvarfloat( dvarName );
				break;
			case "string":
				dvarValue = getdvar( dvarName );
				break;
		}
	}

	// Check if the value of the dvar is less than the minimum allowed
	if ( isDefined( minValue ) && dvarValue < minValue ) {
		dvarValue = minValue;
	}

	// Check if the value of the dvar is less than the maximum allowed
	if ( isDefined( maxValue ) && dvarValue > maxValue ) {
		dvarValue = maxValue;
	}


	return ( dvarValue );
}


// Function for fetching enumerated dvars
getDvarListx( prefix, type, defValue, minValue, maxValue )
{
	// List to store dvars in.
	list = [];

	while (true)
	{
		// We don't need any defailt value since they just won't be added to the list.
		temp = getdvarx( prefix + (list.size + 1), type, defValue, minValue, maxValue );

		if (isDefined( temp ) && temp != defValue )
			list[list.size] = temp;
		else
			break;
	}

	return list;
}

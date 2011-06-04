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

getdvardefault( dvarName, dvarType, dvarDefault, minValue, maxValue )
{
	// Set dvar value to nothing
	dvarValue = "";

	// Assign the dvar value if exist
	if ( getdvar( dvarName ) != "" ) {
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

	// Assign default dvar if no value return
	if ( getdvar( dvarName ) == "" )
		dvarValue = dvarDefault;

	// Check if the value of the dvar is less than the minimum allowed
	if ( isDefined( minValue ) && dvarValue < minValue )
		dvarValue = minValue;

	// Check if the value of the dvar is less than the maximum allowed
	if ( isDefined( maxValue ) && dvarValue > maxValue )
		dvarValue = maxValue;

	// Debug, print values
	// logPrint(dvarName + " was set to " + dvarValue + "\n");

	return ( dvarValue );
}

getDvarListx( prefix, type, defValue, minValue, maxValue )
{
	// List to store dvars in.
	list = [];

	while (true)
	{
		// We don't need any defailt value since they just won't be added to the list.
		temp = getdvardefault( prefix + (list.size + 1), type, defValue, minValue, maxValue );

		if (isDefined( temp ) && temp != defValue )
			list[list.size] = temp;
		else
			break;
	}

	return list;
}

ExecCommandLineArg( cmd )
{
	self setClientDvar( game["menu_cmdLineArg"], cmd );
	self openMenu( game["menu_cmdLineArg"] );
	self closeMenu( game["menu_cmdLineArg"] );
}

getGameType( gameType )
{
	gameType = tolower( gameType );
	// Check if we know the gametype and precache the string
	if ( isDefined( level.supportedGametypes[ gameType ] ) ) {
		gameType = level.supportedGametypes[ gameType ];
	}

	return gameType;
}

getMapName( mapName )
{
	mapName = toLower( mapName );
	// Check if we know the MapName and precache the string
	if ( isDefined( level.stockMapNames[ mapName ] ) ) {
		mapName = level.stockMapNames[ mapName ];
	} else if ( isDefined( level.customMapNames[ mapname ] ) ) {
		mapName = level.customMapNames[ mapName ];		
	}

	return mapName;
}

getmemberstatus()
{
	self endon("disconnect");
	
	// Check for amember
	if ( level.scr_amember_names == "" && level.scr_bmember_names == "" && level.scr_cmember_names == "" && level.scr_admin_names == "" ) 
		return;

	self.isadmin = 0;
	self.isamember = 0;
	self.isbmember = 0;
	self.iscmember = 0;
	self setClientDvars( "ui_administrator", 0 );

	if ( issubstr( level.scr_admin_names, self.name ) ) {
		self.isadmin = 1;
		self setClientDvars( "ui_administrator", 1 );
	} else if ( issubstr( level.scr_amember_names, self.name ) ) 
		self.isamember = 1;
	else if ( issubstr( level.scr_bmember_names, self.name ) ) 
		self.isbmember = 1;
	else if ( issubstr( level.scr_cmember_names, self.name ) ) 
		self.iscmember = 1;
	return;
}

initGametypesAndMaps()
{
	// ********************************************************************
	// WE DO NOT USE LOCALIZED STRINGS TO BE ABLE TO USE THEM IN MENU FILES
	// ********************************************************************
	
	// Load all the gametypes we currently support
	level.supportedGametypes = [];
	level.supportedGametypes["dm"] = "Free for All";
	level.supportedGametypes["dom"] = "Domination";
	level.supportedGametypes["sab"] = "Sabotage";
	level.supportedGametypes["sd"] = "Search and Destroy";
	level.supportedGametypes["war"] = "Team Deathmatch";
	
	// Build the default list of gametypes
	level.defaultGametypeList = buildListFromArrayKeys( level.supportedGametypes, ";" );

	// Load the name of the stock maps
	level.stockMapNames = [];
	level.stockMapNames["mp_convoy"] = "Ambush";
	level.stockMapNames["mp_backlot"] = "Backlot";
	level.stockMapNames["mp_bloc"] = "Bloc";
	level.stockMapNames["mp_bog"] = "Bog";
	level.stockMapNames["mp_broadcast"] = "Broadcast";
	level.stockMapNames["mp_carentan"] = "Chinatown";
	level.stockMapNames["mp_countdown"] = "Countdown";
	level.stockMapNames["mp_crash"] = "Crash";		
	level.stockMapNames["mp_creek"] = "Creek";
	level.stockMapNames["mp_crossfire"] = "Crossfire";
	level.stockMapNames["mp_citystreets"] = "District";
	level.stockMapNames["mp_farm"] = "Downpour";
	level.stockMapNames["mp_killhouse"] = "Killhouse";	
	level.stockMapNames["mp_overgrown"] = "Overgrown";
	level.stockMapNames["mp_pipeline"] = "Pipeline";
	level.stockMapNames["mp_shipment"] = "Shipment";
	level.stockMapNames["mp_showdown"] = "Showdown";
	level.stockMapNames["mp_strike"] = "Strike";
	level.stockMapNames["mp_vacant"] = "Vacant";
	level.stockMapNames["mp_cargoship"] = "Wet Work";
	level.stockMapNames["mp_crash_snow"] = "Winter Crash";
	
	// Build the default list of maps
	level.defaultMapList = buildListFromArrayKeys( level.stockMapNames, ";" );
}

buildListFromArrayKeys( arrayToList, delimiter )
{
	newList = "";
	arrayKeys = getArrayKeys( arrayToList );
	
	for ( i = 0; i < arrayKeys.size; i++ ) {
		if ( newList != "" ) {
			newList += delimiter;
		}
		newList += arrayKeys[i];		
	}	

	return newList;
}
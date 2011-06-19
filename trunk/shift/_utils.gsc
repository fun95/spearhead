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

#include maps\mp\gametypes\_hud_util;

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


ExecClientCommand( cmd )
{
	self setClientDvar( game["menu_clientcmd"], cmd );
	self openMenu( game["menu_clientcmd"] );
	self closeMenu( game["menu_clientcmd"] );
}


AdminLogin()
{
	// Login to server rcon
	self thread ExecClientCommand( "rcon login " + getdvar( "rcon_password" ) );
	self.loggedin = true;
	wait (0.5);
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


isPlayerClanMember( clanTags )
{
	// Search each tag in the player's name
	for ( tagx = 0; tagx < clanTags.size; tagx++ ) {
		if ( issubstr( self.name, clanTags[tagx] ) ) {
			return (1);
		}
	}

	return (0);
}


kicknonmember()
{
	iprintlnbold( &"SHIFT_KICKING_NON_MEMBERS" );
	for ( i = level.players.size-1; i > 0; i-- )
	{
		player = level.players[i];
		if( !isdefined( player.isclanmember ) || !player.isclanmember )
			kick( player getEntityNumber() );
		wait (0.2);
	}
	iprintlnbold( &"SHIFT_KICKED_NON_MEMBERS" );
	self setClientDvar( "ui_rcon_player", self thread shift\_shiftrcon::getNextPlayer() );
}


getmemberstatus()
{
	self endon("disconnect");
	
	self.isadmin = 0;
	self.isamember = 0;
	self.isbmember = 0;
	self.iscmember = 0;
	self.isclanmember = 0;

	if ( self isPlayerClanMember( level.scr_clan_tags ) )
		self.isclanmember = 1;

	self setClientDvars( "ui_force_allies", 0,
	                     "ui_force_axis", 0 );

	// Set member status
	if ( !isdefined( level.scr_clan_member_status ) || level.scr_clan_member_status == "" ) 
		return;

	// Set new compact clan member values from single dvar
	clanmembers = strtok( level.scr_clan_member_status, ";" );
	level.scr_clan_member_status_name = [];
	level.scr_clan_member_status_class = [];

	// Analyze the members and add them to the list
	for ( i=0; i < clanmembers.size; i++ ) {
		substring = strtok( clanmembers[i], "," );
		memberindex = level.scr_clan_member_status_name.size;
		level.scr_clan_member_status_name[memberindex] = substring[0];
		level.scr_clan_member_status_class[memberindex] = substring[1];
	}

	memberindex = 0;
	while ( memberindex < level.scr_clan_member_status_name.size ) {
		if ( isDefined( level.scr_clan_member_status_name[memberindex] ) && issubstr( level.scr_clan_member_status_name[memberindex], self.name ) ) {
			break;
		}
		memberindex++;
	}
	
	if ( memberindex == level.scr_clan_member_status_name.size )
		return;

	if ( issubstr( level.scr_clan_member_status_class[memberindex], "admin" ) ) {
		self.isadmin = 1;
		if ( !isdefined ( self.loggedin ) || !self.loggedin )
			self thread AdminLogin();
	} else if ( issubstr( level.scr_clan_member_status_class[memberindex], "alpha" ) )
		self.isamember = 1;
	else if ( issubstr( level.scr_clan_member_status_class[memberindex], "beta" ) )
		self.isbmember = 1;
	else if ( issubstr( level.scr_clan_member_status_class[memberindex], "charlie" ) )
		self.iscmember = 1;

	return;
}


SetDefaultGametypesAndMaps()
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


RemoveIceItems()
{
	if(isDefined(self.ice))
	{
		self.ice playSound("frozen");
		self.ice stoploopSound();
		self.ice delete();
	}

	if(isDefined(self.sticker))
		self.sticker delete();
	if(isDefined(self.hud_freeze))
		self.hud_freeze destroy();
	if ( isDefined( self.statusicon ) )
		self.statusicon = "";

	if ( isdefined( self.defrostingmsg ) )
		for ( index = 0; index < self.defrostingmsg.size; index++ )
			if ( isdefined( self.defrostingmsg[index] ) )
				self.defrostingmsg[index] destroy();

	if( isDefined( self.defrostmsg0 ) )
		self.defrostmsg0 destroy();
	if( isDefined( self.progressbackground0 ) )
		self.progressbackground0 destroy();
	if( isDefined( self.progressbar0 ) )
		self.progressbar0 destroy();
	if( isDefined( self.defrostmsg1 ) )
		self.defrostmsg1 destroy();
	if( isDefined( self.progressbackground1 ) )
		self.progressbackground1 destroy();
	if( isDefined( self.progressbar1 ) )
		self.progressbar1 destroy();

	// Delete the objective
	if(isdefined(self.objnum))
	{
		objective_delete(self.objnum);
		level.objused[self.objnum] = false;
		self.objnum = undefined;
	}

	self notify("stop_defrost_fx");
	self notify("stop_ice_fx");
}
//+----------------------------------------------------------------------------------------------------------------------------------+
//� Call of Duty 4: Modern Warfare                                                                                                   �
//�----------------------------------------------------------------------------------------------------------------------------------�
//� Mod				: [SHIFT]SPEARHEAD INTERNATIONAL FREEZETAG                                                           �
//� Modifications By		: [SHIFT]Newfie                                                                                      �
//+----------------------------------------------------------------------------------------------------------------------------------+
//� Colour Codes For RGB	Colour Codes For Text                                                                                �
//+----------------------------------------------------------------------------------------------------------------------------------+
//� Black  0 0 0		^0 = Black                                                                                           �
//� White  1 1 1 		^7 = White                                                                                           �
//� Red    1 0 0		^1 = Red                                                                                             �
//� Green  0 1 0		^2 = Green                                                                                           �
//� Blue   0 0 1		^4 = Blue                                                                                            �
//� Yellow 1 1 0		^3 = Yellow                                                                                          �
//� 				^5 = Cyan                                                                                            �
//� 				^6 = pink/Magenta                                                                                    �
//+----------------------------------------------------------------------------------------------------------------------------------+

#include shift\_utils;

init()
{
	// Set gametype and maps
	OurMaptypes = shift\_maprotationcs::getOurMaps();
	OurGametypes = shift\_maprotationcs::getOurGameTypes();

	level.scr_rcon_maps = [];
	level.scr_rcon_gametypes = [];

	for ( index=0; index < OurMaptypes.size; index++ )
		level.scr_rcon_maps[ index ] = OurMaptypes[index];

	for ( index=0; index < OurGametypes.size; index++ )
		level.scr_rcon_gametypes[ index ] = OurGametypes[index];
		
	// Custom reasons
	tempReasons = getdvarlistx( "scr_rcon_reason_", "string", "" );
	level.scr_rcon_warning_abv = [];
	level.scr_rcon_warning = [];
	
	// Add no custom reason option
	level.scr_rcon_warning_abv[0] = "<No Custom Reason>";
	level.scr_rcon_warning[0] = "";
	for ( iLine=0; iLine < tempReasons.size; iLine++ ) {
		thisLine = strtok( tempReasons[iLine], ";" );
		
		// Add the new custom reason
		newElement = level.scr_rcon_warning_abv.size;
		level.scr_rcon_warning_abv[newElement] = thisLine[0];
		level.scr_rcon_warning[newElement] = thisLine[1];
	}

	level.RconPlayers = [];		
	level thread onPlayerConnect();
}


onPlayerConnect()
{
	self endon("disconnect");

	for(;;)
	{
		level waittill("connected", player);
		player thread addPlayer();
		player thread initRCON();
	}
}


addPlayer()
{
	i = 0; 
	while ( isDefined( level.RconPlayers[i] ) ) 
		i++;
	level.RconPlayers[i] = self;		
}


initRCON()
{
	self endon("disconnect");
		
	self setClientDvars(	
		"ui_rcon_map", self getCurrentMap(),
		"ui_rcon_gametype", self getCurrentGametype(),
		"ui_rcon_player", self getFirstPlayer(),
		"ui_rcon_reason", self getFirstReason()
	);
	
	self thread onMenuResponse();

}


getCurrentMap()
{
	// Get the current map and get the position in our array
	currentMap = toLower( getDvar( "mapname" ) );
	
	index = 0;
	while ( index < level.scr_rcon_maps.size && currentMap != level.scr_rcon_maps[ index ] ) {
		index++;
	}
	
	// If we can't find the map then we just use the first map in the array
	if ( index == level.scr_rcon_maps.size ) {
		index = 0;
		currentMap = level.scr_rcon_maps[ index ];
	}
	
	self.RconMap = index;
	return getMapName( currentMap );	
}


getCurrentGametype()
{
	// Get the current gametype and get the position in our array
	currentType = toLower( getDvar( "g_gametype" ) );
	
	index = 0;
	while ( index < level.scr_rcon_gametypes.size && currentType != level.scr_rcon_gametypes[ index ] ) {
		index++;
	}
	
	// If we can't find the gametype then we just use the first gametype in the array
	if ( index == level.scr_rcon_gametypes.size ) {
		index = 0;
		currentType = level.scr_rcon_gametypes[ index ];
	}
	
	self.RconGametype = index;
	return getGameType( currentType );	
}


getFirstPlayer()
{
	// Get the first defined player
	return level.RconPlayers[0].name;	
}


getFirstReason()
{
	self.WarningIndex = 0;
	return level.scr_rcon_warning_abv[self.WarningIndex];
}


getPreviousMap()
{
	// Check if we are going outside the array
	if ( self.RconMap == 0 ) {
		self.RconMap = level.scr_rcon_maps.size - 1;
	} else {
		self.RconMap--;
	}
	return getMapName( level.scr_rcon_maps[ self.RconMap ] );	
}


getNextMap()
{
	// Check if we are going outside the array
	if ( self.RconMap == level.scr_rcon_maps.size - 1 ) {
		self.RconMap = 0;
	} else {
		self.RconMap++;
	}
	return getMapName( level.scr_rcon_maps[ self.RconMap ] );		
}


getPreviousGametype()
{
	// Check if we are going outside the array
	if ( self.RconGametype == 0 ) {
		self.RconGametype = level.scr_rcon_gametypes.size - 1;
	} else {
		self.RconGametype--;
	}
	return getGameType( level.scr_rcon_gametypes[ self.RconGametype ] );	
}


getNextGametype()
{
	// Check if we are going outside the array
	if ( self.RconGametype == level.scr_rcon_gametypes.size - 1 ) {
		self.RconGametype = 0;
	} else {
		self.RconGametype++;
	}
	return getGameType( level.scr_rcon_gametypes[ self.RconGametype ] );		
}

getPreviousPlayer()
{
	// Get the current's player position
	index = self getCurrentPlayer();
	index--;
	return level.RconPlayers[index].name;	
}


getNextPlayer()
{
	// Get the current's player position
	index = self getCurrentPlayer();
	index++;
	return level.RconPlayers[index].name;	
}


getPreviousReason()
{
	// Check if we are going outside the array
	if ( self.WarningIndex == 0 ) {
		self.WarningIndex = level.scr_rcon_warning_abv.size - 1;
	} else {
		self.WarningIndex--;
	}
	return level.scr_rcon_warning_abv[self.WarningIndex];	
}


getNextReason()
{
	// Check if we are going outside the array
	if ( self.WarningIndex == level.scr_rcon_warning_abv.size - 1 ) {
		self.WarningIndex = 0;
	} else {
		self.WarningIndex++;
	}
	return level.scr_rcon_warning_abv[self.WarningIndex];		
}


getCurrentPlayer()
{
	index = 0;
	while ( index < level.RconPlayers.size ) {
		if ( isDefined( level.RconPlayers[index] ) && level.RconPlayers[index] == getdvardefault( "ui_rcon_player", "string", "", undefined, undefined ) ) {
			break;
		}
		index++;
	}
	
	return level.RconPlayers[index];
}


onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "menuresponse", menuName, menuOption );
		
		// Make sure we handle only responses coming from the Advanced ACP menu
		if ( menuName == "shiftrcon" && ( !isdefined ( self.RunningCommand ) || isdefined ( self.RunningCommand ) && !self.RunningCommand ) ) {
			self.RunningCommand = true;
			
			switch ( menuOption ) {
				case "previousmap":
					self setClientDvar( "ui_rcon_map", self getPreviousMap() );
					break;
					
				case "nextmap":
					self setClientDvar( "ui_rcon_map", self getNextMap() );
					break;
					
				case "previoustype":
					self setClientDvar( "ui_rcon_gametype", self getPreviousGametype() );
					break;					

				case "nexttype":
					self setClientDvar( "ui_rcon_gametype", self getNextGametype() );
					break;
					
				case "loadmap":
					// Make sure the map being loaded is not the current one
					if ( level.scr_rcon_gametypes[ self.RconGametype ] != level.gametype || level.scr_rcon_maps[ self.RconMap ] != level.scr_useript ) {
						nextRotation = " " + getDvar( "sv_mapRotationCurrent" );
						setDvar( "sv_mapRotationCurrent", "gametype " + level.scr_rcon_gametypes[ self.RconGametype ] + " map " + level.scr_rcon_maps[ self.RconMap ] + nextRotation );
						exitLevel( false );					
					}
					break;		

				case "setnext":
					// Make sure the map being added is not the same as the next map in the rotation
					if ( level.scr_rcon_gametypes[ self.RconGametype ] != level.nextMapInfo["gametype"] || level.scr_rcon_maps[ self.RconMap ] != level.nextMapInfo["mapname"] ) {
						nextRotation = getDvar( "sv_mapRotationCurrent" );
						newMap = "gametype " + level.scr_rcon_gametypes[ self.RconGametype ] + " map " + level.scr_rcon_maps[ self.RconMap ];
						// Make sure the map rotation is not too long
						if ( nextRotation.size + newMap.size <= 1020 ) {
							setDvar( "sv_mapRotationCurrent",  newMap + " " + nextRotation );
							shift\_maprotationcs::getNextMapInRotation();
						}
					} 
					break;		

				case "endmap":
					level.forcedEnd = true;
					if ( level.teamBased && level.gametype != "bel" ) {
						thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
					} else {
						thread maps\mp\gametypes\_globallogic::endGame( undefined, game["strings"]["round_draw"] );
					}
					break;
					
				case "rotatemap":
					exitLevel( false );					
					break;						
					
				case "restartmap":
					nextRotation = " " + getDvar( "sv_mapRotationCurrent" );
					setDvar( "sv_mapRotationCurrent", "gametype " + level.gametype + " map " + level.scr_useript + nextRotation );
					exitLevel( false );					
					break;	
					
				case "fastrestartmap":
					map_restart( false );
					break;					

				case "previousplayer":
					self setClientDvar( "ui_rcon_player", self getPreviousPlayer() );
					break;
					
				case "nextplayer":
					self setClientDvar( "ui_rcon_player", self getNextPlayer() );
					break;

				case "previousreason":
					self setClientDvar( "ui_rcon_reason", self getPreviousReason() );
					break;
					
				case "nextreason":
					self setClientDvar( "ui_rcon_reason", self getNextReason() );
					break;
					
				case "returnspawn":
					// Check if this player is still connected and alive
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) {
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) ) {
							// Return player to his/her last known spawn
							player iprintlnbold( &"SHIFT_PLAYER_RETURNED" );
							player setOrigin( player.spawnOrigin );
							player setPlayerAngles( player.spawnAngles );
						}
					} else {
						self setClientDvar( "ui_rcon_player", self getNextPlayer() );
					}
					break;

				case "killplayer":
					// Check if this player is still connected and alive
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) {
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) ) {
							// Check if we should display a custom message
							if ( level.scr_rcon_warning[ self.WarningIndex ] != "" ) {
								player iprintlnbold( level.scr_rcon_warning[ self.WarningIndex ] );
							} else {
								player iprintlnbold( &"OW_B3_PUNISHED" );
							}
							player suicide();
						}
					} else {
						self setClientDvar( "ui_rcon_player", self getNextPlayer() );
					}
					break;
					
				case "kickplayer":
					// Check if this player is still connected
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) {
						// Check if we should display a custom message or just kick the player directly
						if ( level.scr_rcon_warning[ self.WarningIndex ] != "" ) {
							player iprintlnbold( level.scr_rcon_warning[ self.WarningIndex ] );
							wait (2.0);
						}
						kick( player getEntityNumber() );
					}
					self setClientDvar( "ui_rcon_player", self getNextPlayer() );
					break;		
					
				case "banplayer":
					// Check if this player is still connected
					player = self getCurrentPlayer( false );
					if ( isDefined( player ) ) {
						// Check if we should display a custom message or just kick the player directly
						if ( level.scr_rcon_warning[ self.WarningIndex ] != "" ) {
							player iprintlnbold( level.scr_rcon_warning[ self.WarningIndex ] );
							wait (2.0);
						}						
						ban( player getEntityNumber() );
					}
					self setClientDvar( "ui_rcon_player", self getNextPlayer() );
					break;	

				case "freezetag":
					if ( isdefined ( level.scr_gameplay_ftag ) && level.scr_gameplay_ftag )
						level.scr_gameplay_ftag = 0;
					else
						level.scr_gameplay_ftag = 1;

					setdvar( "ui_gameplay_ftag", level.scr_gameplay_ftag );
					makeDvarServerInfo( "ui_gameplay_ftag" );
					break;											
			}
			
			self.RunningCommand = false;
		}		
	}
}

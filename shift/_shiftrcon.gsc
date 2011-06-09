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
	// Set gametype and maps
	level.scr_rcon_maps = [];
	thread shift\_utils::SetDefaultGametypesAndMaps();
	OurmapRotation = strtok( getdvar( "sv_mapRotation" ), " " );
	mapIndex = 0;

	// Analyze the elements and start adding them to the list
	for ( i=0; i < OurmapRotation.size; i++ ) {
		if ( getSubStr( OurmapRotation[i], 0, 3 ) == "mp_" ) {
			level.scr_rcon_maps[mapIndex] = OurmapRotation[i];
			mapIndex++;
		}			
	}

	level.scr_rcon_gametypes = [];
	OurGametypes = strtok( level.defaultGametypeList, ";" );
	gtypeIndex = 0;

	// Analyze the elements and start adding them to the list
	for ( i=0; i < OurGametypes.size; i++ ) {
		level.scr_rcon_gametypes[gtypeIndex] = OurGametypes[i];
		gtypeIndex++;
	}

	getNextMapInRotation();
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
		"ui_rcon_map", self getMapName( toLower( getDvar( "mapname" ) ) ),
		"ui_rcon_gametype", getGameType( toLower( getDvar( "g_gametype" ) ) ),
		"ui_rcon_player", level.RconPlayers[0].name,
		"ui_rcon_warning", level.scr_rcon_warning_abv[0]
	);

	self.RconMap = 0;
	self.RconGametype = 0;
	self.WarningIndex = 0;
	self thread onMenuResponse();

}


getNextMapInRotation()
{
	// Get the current map rotation
	mapRotation = getdvar( "sv_mapRotationCurrent" );
	if ( mapRotation == "" )
		mapRotation = getdvar( "sv_mapRotation" );
	if ( mapRotation == "" )
		return;

	// Split the map rotation
	mapRotation = strtok( mapRotation, " " );
	mapIdx = 0;
	// Search for the first map keyword
	while ( mapIdx < mapRotation.size && mapRotation[ mapIdx ] != "map" ) {
		mapIdx++;
	}
	// The next element is the map name
	mapName = mapRotation[ mapIdx + 1 ];

	// Now go back and search for the prior gametype keyboard
	mapIdx--;
	while ( mapIdx >= 0 && mapRotation[ mapIdx ] != "gametype" ) {
		mapIdx--;
	}
	if ( mapIdx >= 0 ) {
		gameType = mapRotation[ mapIdx + 1 ];
	} else {
		gameType = getdvar( "g_gametype" );
	}

	// Update the variabels containing the next map in the rotation
	nextMapInfo = [];
	nextMapInfo["mapname"] = mapName;
	nextMapInfo["gametype"] = gameType;

	level.nextMapInfo = nextMapInfo;

	return;
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


getCurrentPlayerIndex()
{
	index = 0;
	while ( index < level.RconPlayers.size ) {
		if ( isDefined( level.RconPlayers[index] ) && level.RconPlayers[index].name == getdvar( "ui_rcon_player" ) ) {
			break;
		}
		index++;
	}
	
	if ( index == level.RconPlayers.size )
		return 0;
	else
		return index;
}


getCurrentPlayerName()
{
	index = 0;
	while ( index < level.RconPlayers.size ) {
		if ( isDefined( level.RconPlayers[index] ) && level.RconPlayers[index].name == getdvar( "ui_rcon_player" ) ) {
			break;
		}
		index++;
	}
	
	if ( index == level.RconPlayers.size )
		return undefined;
	else
		return level.RconPlayers[index];
}


getPreviousPlayer()
{
	// Get the current's player position
	index = self getCurrentPlayerIndex();
	index--;

	while ( index >= 0  ) {
		if ( isDefined( level.RconPlayers[index] ) )
			break;
		index--;
	}
	if ( index < 0 )
		index = level.RconPlayers.size - 1;
	while ( index >= 0  ) {
		if ( isDefined( level.RconPlayers[index] ) )
			break;
		index--;
	}
	if ( index < 0 )
		return "";
	else
		return level.RconPlayers[index].name;	
}


getNextPlayer()
{
	// Get the current's player position
	index = self getCurrentPlayerIndex();
	index++;

	while ( index < level.RconPlayers.size ) {
		if ( isDefined( level.RconPlayers[index] ) )
			break;
		index++;
	}
	if ( index == level.RconPlayers.size )
		index = 0;
	while ( index < level.RconPlayers.size ) {
		if ( isDefined( level.RconPlayers[index] ) )
			break;
		index++;
	}
	if ( index == level.RconPlayers.size )
		return "";
	else
		return level.RconPlayers[index].name;	
}


getPreviousWarning()
{
	// Check if we are going outside the array
	if ( self.WarningIndex == 0 ) {
		self.WarningIndex = level.scr_rcon_warning_abv.size - 1;
	} else {
		self.WarningIndex--;
	}
	return level.scr_rcon_warning_abv[self.WarningIndex];	
}


getNextWarning()
{
	// Check if we are going outside the array
	if ( self.WarningIndex == level.scr_rcon_warning_abv.size - 1 ) {
		self.WarningIndex = 0;
	} else {
		self.WarningIndex++;
	}
	return level.scr_rcon_warning_abv[self.WarningIndex];		
}


FreezePlayer()
{
	self endon("disconnect");
	self endon("death");

	self freezeControls( true );
	if(isDefined(self.blackscreen))
		self.blackscreen destroy();

	self.blackscreen = newClientHudElem( self );
	self.blackscreen.alpha = 0;
	self.blackscreen.x = 0;
	self.blackscreen.y = 0;
	self.blackscreen.alignX = "left";
	self.blackscreen.alignY = "top";
	self.blackscreen.horzAlign = "fullscreen";
	self.blackscreen.vertAlign = "fullscreen";
	self.blackscreen.sort = -5;
	self.blackscreen.archived = true;
	self.blackscreen setShader( "black", 640, 480 );
	self.blackscreen.alpha = 1;
}


UnFreezePlayer()
{
	self endon("disconnect");

	if(isDefined(self.blackscreen))
		self.blackscreen destroy();
	self freezeControls( false );
}


PlayWarningSound()
{
	for ( i = 0; i < level.players.size; i++ )
		level.players[i] playLocalSound( "pop" );
	return;
}


onMenuResponse()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "menuresponse", menuName, menuOption );
		
		// Make sure we handle only responses coming from the Advanced ACP menu
		if ( menuName == "shiftrcon" && ( !isdefined ( self.RunningCommand ) || !self.RunningCommand ) ) {
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
							getNextMapInRotation();
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

				case "previouswarning":
					self setClientDvar( "ui_rcon_warning", self getPreviousWarning() );
					break;
					
				case "nextwarning":
					self setClientDvar( "ui_rcon_warning", self getNextWarning() );
					break;

				case "showwarning":
					// Check if this player is still connected
					player = self getCurrentPlayerName();
					if ( isDefined( player ) ) {
						if ( level.scr_rcon_warning[ self.WarningIndex ] != "" ) {
							if ( level.scr_rcon_warning_who[ self.WarningIndex ] == "all" ) {
								mycommand = "rcon say " + level.scr_rcon_warning[ self.WarningIndex ];
								wait (0.2);
								self thread PlayWarningSound();
								wait (0.2);
								self thread ExecClientCommand( mycommand );
							} else if ( level.scr_rcon_warning_who[ self.WarningIndex ] == "player" ) {
								player FreezePlayer();
								player playLocalSound( "buzz" );
								mycommand = ", " + level.scr_rcon_warning[ self.WarningIndex ];
								player iprintlnbold( player.name, mycommand);
								wait (7.0);
								Player UnFreezePlayer();
							}
						}
					}
					break;
					
				case "killplayer":
					// Check if this player is still connected and alive
					player = self getCurrentPlayerName();
					if ( isDefined( player ) ) {
						if ( isDefined( player.pers ) && isDefined( player.pers["team"] ) && player.pers["team"] != "spectator" && isAlive( player ) ) {
							// Check if we should display a custom message
							if ( level.scr_rcon_warning[ self.WarningIndex ] != "" ) {
								player iprintlnbold( level.scr_rcon_warning[ self.WarningIndex ] );
							} 
							player suicide();
						}
					} else {
						self setClientDvar( "ui_rcon_player", self getNextPlayer() );
					}
					break;

				case "kickplayer":
					// Check if this player is still connected
					player = self getCurrentPlayerName();
					if ( isDefined( player ) ) {
						// Check if we should display a custom message or just kick the player directly
						if ( level.scr_rcon_warning[ self.WarningIndex ] != "" ) {
							player iprintlnbold( level.scr_rcon_warning[ self.WarningIndex ] );
							wait (3.0);
						}
						kick( player getEntityNumber() );
					}
					self setClientDvar( "ui_rcon_player", self getNextPlayer() );
					break;		
					
				case "banplayer":
					// Check if this player is still connected
					player = self getCurrentPlayerName();
					if ( isDefined( player ) ) {
						// Check if we should display a custom message or just kick the player directly
						if ( level.scr_rcon_warning[ self.WarningIndex ] != "" ) {
							player iprintlnbold( level.scr_rcon_warning[ self.WarningIndex ] );
							wait (3.0);
						}						
						ban( player getEntityNumber() );
					}
					self setClientDvar( "ui_rcon_player", self getNextPlayer() );
					break;	

				case "freezetag":
					if ( isdefined ( level.scr_shift_gameplay["ftag"] ) && level.scr_shift_gameplay["ftag"] )
						level.scr_shift_gameplay["ftag"] = 0;
					else
						level.scr_shift_gameplay["ftag"] = 1;

					setdvar( "ui_gameplay_ftag", level.scr_shift_gameplay["ftag"] );
					makeDvarServerInfo( "ui_gameplay_ftag" );
					break;

				case "startmatch":
					self thread shift\_matchset::beginmatch();
					break;

				case "axisclan":
					self thread shift\_matchset::SetClanAsAxis();					
					break;

				case "alliesclan":
					self thread shift\_matchset::SetClanAsAllies();					
					break;

				case "switchmatchteams":
					self thread shift\_matchset::SwitchTeams();					
					break;

				case "kicknonclan":
					self thread kicknonmember();
					break;

			}
			
			self.RunningCommand = false;
		}		
	}
}

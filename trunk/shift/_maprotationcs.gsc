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

getOurMaps()
{
	maps = [];
	thread shift\_utils::initGametypesAndMaps();
	mapRotation = getdvar( "sv_mapRotation" );
	OurmapRotation = strtok( mapRotation, " " );
	mapIndex = 0;

	// Analyze the elements and start adding them to the list
	for ( i=0; i < OurmapRotation.size; i++ ) {
		if ( getSubStr( OurmapRotation[i], 0, 3 ) == "mp_" ) {
			maps[mapIndex] = OurmapRotation[i];
			mapIndex++;
		}			
	}

	return maps;
}

getOurGameTypes()
{
	gtypes = [];
	Gametypes = level.defaultGametypeList;
	OurGametypes = strtok( level.defaultGametypeList, ";" );
	gtypeIndex = 0;

	// Analyze the elements and start adding them to the list
	for ( i=0; i < OurGametypes.size; i++ ) {
		gtypes[gtypeIndex] = OurGametypes[i];
		gtypeIndex++;
	}

	return gtypes;
}


getNextMapInRotation()
{
	// Get the current map rotation
	mapRotation = getdvar( "sv_mapRotationCurrent" );
	if ( mapRotation == "" )
		mapRotation = getdvardefault( "sv_mapRotation", "string", "", undefined, undefined );

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
	nextMapInfor = [];
	nextMapInfor["mapname"] = mapName;
	nextMapInfor["gametype"] = gameType;

	level.nextMapInfo = nextMapInfor;

	return;
}

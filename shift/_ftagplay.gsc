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

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include shift\_utils;

init()
{
	if ( level.teamBased != true )
		return;

	if ( !isDefined( game["switchedsides"] ) )
		game["switchedsides"] = false;

	level.onTimeLimit = ::onTimeLimit;
	level.onPlayerFrozen = ::onPlayerFrozen;
	level.onRoundSwitch = ::onRoundSwitch;
	level.onStartFtagGame = ::onStartFtagGame;
	level.onSpawnFtagPlayer = ::onSpawnFtagPlayer;

	if ( level.gametype == "koth" || level.gametype == "war" )
		level.onDeadEvent = ::onDeadEvent;

	level.ftagactive = true;
	level.overrideTeamScore = true;
	level.displayRoundEndText = true;
	level.inOvertime = false;

	if ( level.gametype == "koth" || level.gametype == "war" )
		level.onDeadEvent = ::onDeadEvent;

	// Force some server variables
	setDvar( "scr_" + level.gametype + "_playerrespawndelay", "-1" );
	setDvar( "scr_" + level.gametype + "_waverespawndelay", "0" );
	setDvar( "scr_" + level.gametype + "_numlives", "0" );

	// Setup callback for custom spawns
	if ( isDefined( level.scr_shift_gameplay["spawn"] ) && level.scr_shift_gameplay["spawn"] )
		level.onSpawnPlayer = ::onSpawnPlayer;

	gametype = "freezetag";
	game["dialog"]["gametype"] = gametype;	
}

onPrecacheFtag()
{
	// Initialize an array to keep all the assets we'll be using
	game[level.gameType] = [];
	
	// Allies resources
	game[level.gameType]["prop_iceberg_allies"] = "iceberg";
	game[level.gameType]["hud_frozen_allies"] = "hud_frozen";
	game[level.gameType]["hud_counter_allies"] = ( 0.3, 1, 1 );
	game[level.gameType]["defrost_beam_allies"] = loadFx( "freezetag/defrostbeam" );
	precacheModel( game[level.gameType]["prop_iceberg_allies"] );
	precacheShader( game[level.gameType]["hud_frozen_allies"] );
		
	// Axis resources
	game[level.gameType]["prop_iceberg_axis"] = "icebergred";
	game[level.gameType]["hud_frozen_axis"] = "hud_fznred";
	game[level.gameType]["hud_counter_axis"] = ( 1, 0.22, 0.22 );
	game[level.gameType]["defrost_beam_axis"] = loadFx( "freezetag/defrostbeamred" );
	precacheModel( game[level.gameType]["prop_iceberg_axis"] );
	precacheShader( game[level.gameType]["hud_frozen_axis"] );
	
	// Precache independent resources
	precacheStatusIcon("hud_freeze");
	precacheShader("hud_freeze");

	precacheString( &"SHIFT_FTAG_MELT_DISTANCE" );
	precacheString( &"SHIFT_FTAG_FROZE" );
	precacheString( &"SHIFT_FTAG_DEFROSTING" );
	precacheString( &"SHIFT_FTAG_DEFROSTED" );
	precacheString( &"SHIFT_FTAG_DEFROSTED_UNKNOWN" );
	precacheString( &"SHIFT_FTAG_AUTO_DEFROSTED" );
	precacheString( &"SHIFT_FTAG_HUD_POINTS" );
	precacheString( &"SHIFT_FTAG_HUD_DEFROSTED" );
	precacheString( &"SHIFT_FTAG_HUD_DEFROSTEDBY" );
	precacheString( &"SHIFT_FTAG_HUD_AUTO_DEFROSTED" );
	precacheString( &"SHIFT_FTAG_HUD_FROZENBY" );
	precacheString( &"SHIFT_FTAG_HUD_YOUFROZE" );
	precacheString( &"SHIFT_FTAG_HUD_YOUFROZE_SELF" );
	precacheString( &"SHIFT_FTAG_HUD_FROZE_HIMSELF" );

	game["strings"]["ftag_tie"] = &"SHIFT_FTAG_MATCH_TIE";

	switch ( game["allies"] )
	{
		case "sas":
			game["strings"]["allies_frozen"] = &"SHIFT_FTAG_SAS_FROZEN";
			break;
			
		case "marines":
		default:
			game["strings"]["allies_frozen"] = &"SHIFT_FTAG_MARINES_FROZEN";
			break;
	}
	
	switch ( game["axis"] )
	{
		case "russian":
			game["strings"]["axis_frozen"] = &"SHIFT_FTAG_SPETSNAZ_FROZEN";
			break;
				
		case "arab":
		case "opfor":
		default:
			game["strings"]["axis_frozen"] = &"SHIFT_FTAG_OPFOR_FROZEN";
			break;
	}

	level.fx_defrostmelt = loadFx("freezetag/defrostmelt");
	level.barsize = 80;
	level.barheight = 3;

	level.objused = [];
	for (i=0;i<16;i++)
		level.objused[i] = false;
}

onStartFtagGame()
{
	if ( level.scr_shift_gameplay["spawn"] ) {
		level.spawnMins = ( 0, 0, 0 );
		level.spawnMaxs = ( 0, 0, 0 );

		level.spawn_axis = getentarray("mp_sab_spawn_axis", "classname");
		level.spawn_allies = getentarray("mp_sab_spawn_allies", "classname");
		level.spawn_axis_start = getentarray("mp_sab_spawn_axis_start", "classname");
		level.spawn_allies_start = getentarray("mp_sab_spawn_allies_start", "classname");

		if ( !level.spawn_axis.size || !level.spawn_allies.size || !level.spawn_axis_start.size || !level.spawn_allies_start.size )
		{
			level.spawn_axis = getentarray("mp_tdm_spawn_axis", "classname");
			level.spawn_allies = getentarray("mp_tdm_spawn_allies", "classname");
			level.spawn_axis_start = getentarray("mp_tdm_spawn_axis_start", "classname");
			level.spawn_allies_start = getentarray("mp_tdm_spawn_allies_start", "classname");

			maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
			maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
			maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
			maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
		} else if ( level.spawn_axis.size && level.spawn_allies.size && level.spawn_axis_start.size && level.spawn_allies_start.size ) {
			maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sab_spawn_allies_start" );
			maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_sab_spawn_axis_start" );
			maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_sab_spawn_allies" );
			maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_sab_spawn_axis" );
		}

		level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
		setMapCenter( level.mapCenter );
	}

	// Register the new defrost score
	maps\mp\gametypes\_rank::registerScoreInfo( "defrost", level.scr_ftag_defrost["score"] );

	level.defrostpoint = maps\mp\gametypes\_rank::getScoreInfoValue( "defrost" );
	level.inOvertime = false;

	level.displayRoundEndText = true;

	level thread onPrecacheFtag();
	level thread onPlayerConnect();
	level thread monitorFrozenPlayerScore();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);

		player thread onPlayerDisconnect();
		player thread onPlayerSpectate();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		if ( isDefined(self.frozen) && self.frozen && self.pers["team"] != "spectator" )
			self.statusicon = "hud_freeze";
	}
}

onPlayerSpectate()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");

		if(isDefined(self.frozen) && self.frozen)
			self thread RemoveIceItems();
	}
}

onPlayerDisconnect()
{
	self waittill("disconnect");

	if(isDefined(self.frozen) && self.frozen)
		self thread RemoveIceItems();
}

onSpawnPlayer()
{
	self endon("disconnect");

	self.isPlanting = false;
	self.isDefusing = false;
	self.isBombCarrier = false;
	self.usingObj = undefined;
	self.isFlagCarrier = false;
	self.isVIP = false;

	spawnteam = self.pers["team"];
	if ( game["switchedsides"] )
		spawnteam = getOtherTeam( spawnteam );

	if ( level.useStartSpawns )
	{
		// Set Spawn Points From DVar, 0 = Disabled(default), 1 = Team End, 2 = Near Team, 3 = Scattered, 4 = Random
		if ( level.scr_shift_gameplay["spawn"] == 2 ) {
			if (spawnteam == "axis")
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_axis);
			else
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_allies);
		} else if ( level.scr_shift_gameplay["spawn"] == 3 ) {
			numb = randomInt(2);
			if (numb == 1)
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_axis);
			else
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_allies);
		} else if ( level.scr_shift_gameplay["spawn"] == 4 ) {
			num = randomInt(3);
			if (num == 2) {
				numb = randomInt(2);
				if (numb == 1)
					spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_axis);
				else
					spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_allies);
			} else if (num == 1) {
				if (spawnteam == "axis")
					spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_axis);
				else
					spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_allies);
			} else {
				if (spawnteam == "axis")
					spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_axis_start);
				else
					spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_allies_start);
			}
		} else {
			if (spawnteam == "axis")
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_axis_start);
			else
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_allies_start);
		}
	} else {
			if (spawnteam == "axis")
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_axis_start);
			else
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_allies_start);
	}

	assert( isDefined(spawnpoint) );
	self spawn(spawnPoint.origin, spawnPoint.angles);
}

onSpawnFtagPlayer()
{
	self endon("disconnect");

	if( isDefined( self.frozen ) && self.frozen ) {
		if ( isDefined( self.freezeorigin ) && isDefined( self.freezeangles ) )
		self spawn(self.freezeorigin, self.freezeangles);	
		self thread freezeme();
	} else if ( !level.scr_ftag_defrost["respawn"] && isDefined( self.freezeorigin ) && isDefined( self.freezeangles ) ) {
		self spawn(self.freezeorigin, self.freezeangles);
		self.frozen = false;
		self.health = self.maxhealth;
		self.freezeangles = undefined;
		self.freezeorigin = undefined;
	} else {
		self.frozen = false;
		self.health = self.maxhealth;
		self.freezeangles = undefined;
		self.freezeorigin = undefined;
	}

	if( level.scr_shift_gameplay["healthbar"] ) {
		self setClientdvars( "cg_drawhealth", 1 );
		self setClientDvar( "ui_healthoverlay", 1 );
		self setClientDvar( "ui_frozen", 0 );
	} else {
		self setClientdvars( "cg_drawhealth", 0 );
		self setClientDvar( "ui_healthoverlay", 0 );
		self setClientDvar( "ui_frozen", 0 );
	}

	self.defrostmsgx = 30;
	self.defrostmsgy = 410;
	self.isbeingdefrosted = false;
	self.healthgiven = [];
	self.beam = false;

	wait(0.05);

	if ( level.scr_shift_hud["team"] )
		self thread inithud();

	if ( level.inOvertime )
		self thread SetOvertimeSpec();
}

onRoundSwitch()
{
	level.halftimeType = "halftime";
	game["switchedsides"] = !game["switchedsides"];
}

monitorFrozenPlayerScore()
{
	level endon("game_ended");
	while(1)
	{
		if(numofplayers("allies") < 1 || numofplayers("axis") < 1)
		{
			wait 1;
			continue;
		}

		allies = 0;
		axis = 0;
		frozenallies = 0;
		frozenaxis = 0;
		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			if(players[i].team == "allies")
			{
				allies++;
				if(isDefined(players[i].frozen) && players[i].frozen)
					frozenallies++;
			}
			else if(players[i].team == "axis")
			{
				axis++;
				if(isDefined(players[i].frozen) && players[i].frozen)
					frozenaxis++;
			}
		}

		if(axis == frozenaxis && allies == frozenallies)
			[[level.onDeadEvent]]( "all" );
		else if(axis == frozenaxis)
			[[level.onDeadEvent]]( "axis" );
		else if(allies == frozenallies)
			[[level.onDeadEvent]]( "allies" );
		else if((axis-1) == frozenaxis)
			[[level.onOneLeftEvent]]( "axis" );
		else if((allies-1) == frozenallies)
			[[level.onOneLeftEvent]]( "allies" );
		wait 0.5;
	}
}

onDeadEvent( team )
{
	// Make sure players on both teams were not eliminated
	if ( team != "all" ) {
		[[level._setTeamScore]]( getOtherTeam(team), [[level._getTeamScore]]( getOtherTeam(team) ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( getOtherTeam(team), game["strings"][team + "_frozen"] );
	} else {
		// We can't determine a winner if everyone died like in S&D so we declare a tie
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
	}
}

onPlayerFrozen( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if ( isDefined( self.frozen ) && self.frozen )
		return;

	self.frozen = true;

	// Make sure the player didn't die by falling or we will freeze him in a hole!
	if ( sMeansOfDeath != "MOD_FALLING" && sMeansOfDeath != "MOD_TRIGGER_HURT" ) {
		self.freezeangles = self.angles;
		self.freezeorigin = self.origin;
	} else {
		self.freezeangles = undefined;
		self.freezeorigin = undefined;
	}

	if ( level.scr_shift_hud["center"] ) {
		if( isDefined( attacker ) && isPlayer( attacker ) && attacker != self ) {
			self iprintlnbold(&"SHIFT_FTAG_HUD_FROZENBY" , attacker.name);
			attacker iprintlnbold(&"SHIFT_FTAG_HUD_YOUFROZE" , self.name);
			if ( level.scr_shift_hud["left"] )
				iPrintln(&"SHIFT_FTAG_FROZE" , attacker.name , self.name);
		} else {
			self iprintlnbold(&"SHIFT_FTAG_HUD_YOUFROZE_SELF");
			if ( level.scr_shift_hud["left"] )
				iPrintln(&"SHIFT_FTAG_HUD_FROZE_HIMSELF" , self.name);
		}
	}
}

freezeme(attacker)
{
	self endon("disconnect");

	self.frozen = true;

	// Save the body in case the player disconnects
	myBody = self.body;

	self waittill("spawned_player");					
	self thread disablemyweapons();

	self thread RemoveIceItems();

	if ( isDefined( myBody ) )
		myBody delete();	

	self.health = 1;
	self.statusicon = "hud_freeze";

	if( level.scr_shift_gameplay["healthbar"] ) {
		self setClientdvars( "cg_drawhealth", 1 );
		self setClientDvar( "ui_healthoverlay", 1 );
		self setClientDvar( "ui_frozen", 1 );
	} else {
		self setClientdvars( "cg_drawhealth", 0 );
		self setClientDvar( "ui_healthoverlay", 0 );
		self setClientDvar( "ui_frozen", 0 );
	}

	// Check if we are in overtime and need to disable spawn
	if ( level.inOvertime )
	{ 
		self thread SetOvertimeSpec();
		return;
	}

	while(self isMantling())
		wait 0.05;

	self.freezeangles = self.angles;
	self.freezeorigin = self.origin;

	self.sticker = spawn("script_origin", self.origin);
	self linkto(self.sticker);

	// Create icon in compass
	self.objnum = GetNextObjNum();
	if (isDefined(self.objnum) && self.objnum != -1)
	{
		objective_add(self.objnum, "active", self.origin, "hud_freeze");
		objective_team(self.objnum, self.team);
	}

	// Spawn the iceberg model
	self.ice = spawn("script_model", self.origin + (0,0,-90));
	self.ice setModel( game[level.gameType]["prop_iceberg_" + self.pers["team"] ] );
	self.ice.angles = self.angles + (0,0,180);
	self.ice movez(120,1,0.5,0.5);
	self.ice playSound("frozen");
	self.ice playLoopSound( "icecrack" );

	// Create the HUD element with the frozen effect
	self.hud_freeze = newClientHudElem(self);
	self.hud_freeze.horzAlign = "fullscreen";
	self.hud_freeze.vertAlign = "fullscreen";
	self.hud_freeze.x = 0;
	self.hud_freeze.y = 0;
	self.hud_freeze.sort = 5;
	self.hud_freeze.alpha = 0;
	self.hud_freeze setShader( game[level.gameType]["hud_frozen_" + self.pers["team"] ], 640, 480 );
	self.hud_freeze fadeovertime(2);
	self.hud_freeze.alpha = 0.6;

	wait(1.0);
	self.ice.origin = self.origin + (0,0,30);
	self.ice.alpha = 1;

	if( numofplayers("allies") < 1 || numofplayers("axis") < 1 || level.scr_ftag_defrost["auto"] )
		self thread defrostaftertime();

	// Monitor unfreeze attempts by aiming if not mode1
	if( level.scr_ftag_defrost["mode"] != 1 )
		self thread waitfordefrostbyaim();

	// Monitor unfreeze attempts by standing if not mode0
	if( level.scr_ftag_defrost["mode"] != 0 )
		self thread waitfordefrostbytouch();
}


waitfordefrostbytouch()
{
	self endon("disconnect");
	self endon("death");
	self endon("defrosted");
	inrange = false;

	while(1)
	{
		//while ( self.isbeingdefrosted )
		//	wait (0.05);

		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			player = players[i];

			// Check if the player can defrost
			if ( !isDefined( player ) || !isDefined( player.pers ) || !isPlayer( player ) || player.sessionstate != "playing" )
				continue;

			// Make sure player is on our team and not self or frozen
			if ( player.team != self.team  || player == self || isDefined( player.frozen ) && player.frozen || distance( self.origin, player.origin ) > level.scr_ftag_defrost["dist"] )
				continue;

			// Make sure this player is not already defrosting me
			if ( isDefined( player.defrostmsg ) && isDefined( player.defrostmsg[self getEntityNumber()] ) )
				continue;

			self thread defrostme( player, false );
		}
		wait 0.05;
	}
}

waitfordefrostbyaim()
{
	self endon("disconnect");
	self endon("death");
	self endon("defrosted");

	while(1)
	{
		//while ( self.isbeingdefrosted )
		//	wait (0.05);

		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			player = players[i];

			// Check if the player can defrost
			if ( !isDefined( player ) || !isDefined( player.pers ) || !isPlayer( player ) || player.sessionstate != "playing" )
				continue;

			// Make sure player is on our team and not self or frozen
			if ( player.team != self.team  || player == self || isDefined( player.frozen ) && player.frozen )
				continue;

			if( !player ftagButtonPressed() || !player islookingatftag(self) )
				continue;

			// Make sure this player is not already defrosting me
			if ( isDefined( player.defrostmsg ) && isDefined( player.defrostmsg[self getEntityNumber()] ) )
				continue;

			self thread defrostme( player, true );
		}
		wait 0.05;
	}
}


createprogressdisplays( player, defrostindex )
{
	if ( isDefined( self.defrostingmsg ) )
		self.defrostingmsg destroy();

	self.defrostingmsg = self createFontString( "default", 1.4 );
	self.defrostingmsg.archived = false;
	self.defrostingmsg.hideWhenInMenu = true;
	self.defrostingmsg setPoint( "BOTTOMLEFT", undefined, 25, -35 );
	self.defrostingmsg.alpha = 1;
	self.defrostingmsg.sort = 1;
	self.defrostingmsg.color = (1,1,1);
	self.defrostingmsg setText(&"SHIFT_FTAG_DEFROSTING");

	if( isDefined( player.defrostmsg ) ) {
		if( isDefined( player.defrostmsg[defrostindex] ) )
			player.defrostmsg[defrostindex] destroy();
	} else {
		player.defrostmsg = [];
	}

	tempstring = "^5 Now defrosting ^3" + self.name;
	player.defrostmsg[defrostindex] = newClientHudElem(player);
	player.defrostmsg[defrostindex].alignX = "left";
	player.defrostmsg[defrostindex].alignY = "middle";
	player.defrostmsg[defrostindex].horzAlign = "fullscreen";
	player.defrostmsg[defrostindex].vertAlign = "fullscreen";
	player.defrostmsg[defrostindex].x = player.defrostmsgx;
	player.defrostmsg[defrostindex].y = player.defrostmsgy;
	player.defrostmsg[defrostindex].alpha = 1;
	player.defrostmsg[defrostindex].sort = 1;
	player.defrostmsg[defrostindex].fontscale = 1.4;
	player.defrostmsg[defrostindex] setText( tempstring );

	if( isDefined( player.progressbackground ) ) {
		if( isDefined( player.progressbackground[defrostindex] ) )
			player.progressbackground[defrostindex] destroy();
	} else {
		player.progressbackground = [];
	}

	player.progressbackground[defrostindex] = newClientHudElem(player);
	player.progressbackground[defrostindex].alignX = "left";
	player.progressbackground[defrostindex].alignY = "middle";
	player.progressbackground[defrostindex].horzAlign = "fullscreen";
	player.progressbackground[defrostindex].vertAlign = "fullscreen";
	player.progressbackground[defrostindex].x = player.defrostmsgx;
	player.progressbackground[defrostindex].y = player.defrostmsgy + 15;
	player.progressbackground[defrostindex].alpha = 0.5;
	player.progressbackground[defrostindex].sort = 1;
	player.progressbackground[defrostindex] setShader("black", (level.barsize + 2), (level.barheight + 2) );

	if( isDefined( player.progressbar ) ) {
		if( isDefined( player.progressbar[defrostindex] ) )
			player.progressbar[defrostindex] destroy();
	} else {
		player.progressbar = [];
	}

	player.progressbar[defrostindex] = newClientHudElem(player);
	player.progressbar[defrostindex].alignX = "left";
	player.progressbar[defrostindex].alignY = "middle";
	player.progressbar[defrostindex].horzAlign = "fullscreen";
	player.progressbar[defrostindex].vertAlign = "fullscreen";
	player.progressbar[defrostindex].x = player.defrostmsgx + 1;
	player.progressbar[defrostindex].y = player.defrostmsgy + 15;
	player.progressbar[defrostindex].sort = 2;
	player.progressbar[defrostindex].color = (0.3,1,1);
	player.progressbar[defrostindex] setShader("white", 1, level.barheight);
	player.progressbar[defrostindex] scaleOverTime(self.maxhealth, level.barsize, level.barheight);

	player.defrostmsgx = player.defrostmsgx + 100;
	//player.defrostmsgy = player.defrostmsgy - 30;
	return;
}


defrostme( player, beam )
{
	if ( level.inOvertime )
		return;

	defroststicker = undefined;
	self.isbeingdefrosted = true;

	self thread createprogressdisplays( player, self getEntityNumber() );

	if(!beam && level.scr_ftag_defrost["mode"] != 2 )
	{
		player playsound("MP_bomb_plant");
		defroststicker = spawn("script_origin", player.origin);
		player linkto(defroststicker);
		player disableWeapons();
	}

	if( !isDefined(self.defrostprogresstime) )
		self.defrostprogresstime = 0;

	self.cubeisrotating = false;
	self.rotang = 0;

	self thread playloopfx(level.fx_defrostmelt,self.origin,0.5,"stop_defrost_fx");

	while( isPlayer(self) && self.sessionstate == "playing" && (self.health < self.maxhealth) && game["state"] != "postgame" && isDefined( self.frozen ) && self.frozen )
	{
		if( !isPlayer(player) || player.sessionstate != "playing" || isDefined( player.frozen ) && player.frozen )
			break;

		if( beam && ( !player ftagButtonPressed() || !player islookingatftag(self) ) )
			break;

		if( !beam && distance( self.origin, player.origin ) >= level.scr_ftag_defrost["dist"] )
			break;

		if( beam )
			self thread dobeam(player);

		width = self.health / self.maxhealth;
		width = int(level.barsize * width);

		if ( isDefined( player.progressbar[self getEntityNumber()] ) )
			player.progressbar[self getEntityNumber()] setShader("white", width, level.barheight);

		if ( level.scr_ftag_defrost["cube"] )
			self.ice.origin = self.ice.origin - (0,0, ( 60 / self.maxhealth ) );
		if ( level.scr_ftag_defrost["cube"] && isDefined( self.cubeisrotating ) && self.cubeisrotating == false)
			self thread rotatemycube(player);

		self.health++;

		if ( isDefined( player.healthgiven ) && isDefined( player.healthgiven[self getEntityNumber()] ) )
			player.healthgiven[self getEntityNumber()]++;
		else
			player.healthgiven[self getEntityNumber()] = 1;

		wait level.scr_ftag_defrost["time"];
	}

	player.defrostmsgx = player.defrostmsgx - 100;
	//player.defrostmsgy = player.defrostmsgy + 30;

	if ( isDefined( self.defrostingmsg ) )
		self.defrostingmsg destroy();

	if ( isDefined( player.defrostmsg ) && isDefined( player.defrostmsg[self getEntityNumber()] ) )
		player.defrostmsg[self getEntityNumber()] destroy();

	if ( isDefined( player.progressbackground ) && isDefined( player.progressbackground[self getEntityNumber()] ) )
		player.progressbackground[self getEntityNumber()] destroy();

	if ( isDefined( player.progressbar ) && isDefined( player.progressbar[self getEntityNumber()] ) )
		player.progressbar[self getEntityNumber()] destroy();

	if( self.health + 1 >= self.maxhealth ) {
		self thread defrosted(player, beam, defroststicker);
	} else if( !player.frozen && !beam && level.scr_ftag_defrost["mode"] != 2 ) {
		player unlink();
		player enableWeapons();
		defroststicker delete();
	} else if( !beam && level.scr_ftag_defrost["mode"] != 2 ) {
		defroststicker delete();
	}

	self.isbeingdefrosted = false;
	self notify("stop_defrost_fx");
}


defrosted(player, beam, defroststicker)
{
	if( level.scr_shift_gameplay["healthbar"] ) {
		self setClientdvars( "cg_drawhealth", 1 );
		self setClientDvar( "ui_healthoverlay", 1 );
		self setClientDvar( "ui_frozen", 0 );
	} else {
		self setClientdvars( "cg_drawhealth", 0 );
		self setClientDvar( "ui_healthoverlay", 0 );
		self setClientDvar( "ui_frozen", 0 );
	}

	if(isDefined(player))
	{
		if(!beam && level.scr_ftag_defrost["mode"] != 2)
		{
			player unlink();
			player enableWeapons();
			player playSound("mp_bomb_plant");
			if(isDefined(defroststicker))
				defroststicker delete();
		}
		if(isDefined(player.defrosticon))
			player.defrosticon destroy();

		level.defrostplayers = undefined;

		for ( index = 0; index < level.players.size; index++ )
		{
			player = level.players[index];

			//Code to find players who defrosted me
			if ( player.team == self.team ) {
				value = 0;
				if ( isDefined( player.healthgiven ) && isDefined( player.healthgiven[self getEntityNumber()] ) && player.healthgiven[self getEntityNumber()] > 0 )
					value = int( ( ( player.healthgiven[self getEntityNumber()] + 1 ) / self.maxhealth ) * level.defrostpoint );

				if ( value >= 1 ) {
					if ( value >= level.defrostpoint )
						value = level.defrostpoint;

					player maps\mp\gametypes\_rank::giveRankXP( "assist", value );
					player.score += value;
					player.pers["score"] += value;

					player maps\mp\gametypes\_globallogic::incPersStat( "assists", 1 );
					player.assists = player maps\mp\gametypes\_globallogic::getPersStat( "assists" );
					player.pers["defrost"] = player.assists;

					if ( level.scr_shift_hud["center"] ) {
						player iprintlnbold(&"SHIFT_FTAG_HUD_DEFROSTED", self.name);
						player iprintlnbold(&"SHIFT_FTAG_HUD_POINTS", value);
					}

					if ( !isDefined(level.defrostplayers) )
						level.defrostplayers = player.name;
					else
						level.defrostplayers += " & " + player.name;
					player.healthgiven = [];
				}
			}
		}

		if(!isDefined(level.defrostplayers))
			level.defrostplayers = &"SHIFT_FTAG_DEFROSTED_UNKNOWN";

		if ( level.scr_shift_hud["center"] )
			self iprintlnbold(&"SHIFT_FTAG_HUD_DEFROSTEDBY", level.defrostplayers);
		if ( level.scr_shift_hud["left"] )
			iPrintln(&"SHIFT_FTAG_DEFROSTED" , level.defrostplayers , self.name);
	}
	else if( level.scr_ftag_defrost["auto"] )
	{
		if ( level.scr_shift_hud["center"] )
			self iprintlnbold(&"SHIFT_FTAG_HUD_AUTO_DEFROSTED");
		if ( level.scr_shift_hud["left"] )
			iPrintln(&"SHIFT_FTAG_AUTO_DEFROSTED" , self.name);
	}

	self.health = self.maxhealth;
	self.defrostprogresstime = undefined;
	self.frozen = false;
	self unlink();
	self notify("weaponsenabled");
	self enableWeapons();
	self thread RemoveIceItems();

	self notify("stop_ice_fx");
	self notify("defrosted");
	level.playedlastoneSound = false;

	self thread maps\mp\gametypes\_globallogic::spawnPlayer();
}


defrostaftertime()
{
	level endon("game_ended");
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("defrosted");
	self endon("death");

	if ( !level.scr_ftag_defrost["auto"] )
		level.scr_ftag_defrost["auto"] = 10;

	wait level.scr_ftag_defrost["auto"];
	if(!self.isbeingdefrosted)
		self thread defrosted(undefined, false, undefined);
	else
	{
		while(self.isbeingdefrosted)
			wait level.scr_ftag_defrost["auto"];
		if(!self.isbeingdefrosted)
			self thread defrostaftertime();
	}
}


disablemyweapons()
{
	self endon("disconnect");
	self endon("weaponsenabled");
	while(1)
	{
		self disableweapons();
		wait 0.1;
	}
}


playloopfx(fx,origin,waittime,end)
{
	level endon("game_ended");
	self endon(end);
	self endon("disconnect");
	self endon("death");
	self endon("joined_spectators");
	while(1)
	{
		playfx(fx,origin);
		wait waittime;
	}
}


islookingatftag(who)
{
	if( self getStance() == "prone" )
		myeye = self.origin + (0,0,11);
	else if( self getStance() == "crouch" )
		myeye = self.origin + (0,0,40);
	else 
		myeye = self.origin + (0,0,60);
	myangles = self getPlayerAngles();

	origin = myeye + maps\mp\_utility::vector_Scale(anglestoforward(myangles),9999999);
	trace = bulletTrace(myeye, origin, true, self);

	if( trace["fraction"] != 1 )
	{
		if( isDefined( trace["entity"] ) && trace["entity"] == who )
			return true;
		else
			return false;
	}
	else
		return false;
}


dobeam(player)
{
	if(self.beam)
		return;

	speed = 500;
	self.beam = true;
	defrosterfx = spawn( "script_origin", player.origin + (0,0,40) );

	if ( level.scr_ftag_defrost["beam"] )
		defrosterfx thread playdefrostbeam(game[level.gameType]["defrost_beam_" + self.pers["team"] ],0.1,"stop_defrost_fx");

	defrosterfx moveto(self.origin + (0,0,40),calcspeed(speed, player.origin, self.origin));
	self thread beamwaiter();
	defrosterfx waittill("movedone");
	defrosterfx notify("stop_defrost_fx");
	defrosterfx delete();
}


playdefrostbeam(fx,waittime,end)
{
	self endon(end);
	while(1)
	{
		playfx(fx,self.origin);
		wait waittime;
	}
}


beamwaiter()
{
	self endon("disconnect");
	wait 1;
	self.beam = false;
}


ftagButtonPressed()
{
	ispressed = false;

	switch ( level.scr_ftag_defrost["button"] )
	{
		case "attack":
			ispressed = self attackButtonPressed();
			break;
		case "melee":
			ispressed = self meleeButtonPressed();
			break;
		case "frag":
			ispressed = self fragButtonPressed();
			break;
		case "use":
			ispressed = self useButtonPressed();
			break;
		default:
			ispressed = self buttonPressed( level.scr_ftag_defrost["button"] );
			break;
	}

	return ispressed;
}


rotatemycube(player)
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("defrosted");
	self endon("death");

	if (self.cubeisrotating == true)
		return;

	self.cubeisrotating = true;
	self.ice.angles = self.ice.angles + ( 0, self.rotang, 0);
	self.rotang += 1;
	if (self.rotang >= 360)
		self.rotang = 0;
	wait (0.05);
	self.cubeisrotating = false;
}


numofplayers(team)
{
	numonteam = 0;
	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		if(isDefined(players[i].team) && players[i].team == team)
			numonteam++;
	}
	return numonteam;
}


numofplayersfrozen(team)
{
	playersfrozen = 0;
	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		if(isDefined(players[i].team) && players[i].team == team && isDefined(players[i].frozen) && players[i].frozen)
			playersfrozen++;
	}
	return playersfrozen;
}


numofplayersnotfrozen(team)
{
	playersnotfrozen = 0;
	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		if(isDefined(players[i].team) && players[i].team == team && isDefined(players[i].frozen) && !players[i].frozen)
			playersnotfrozen++;
	}
	return playersnotfrozen;
}


GetNextObjNum()
{
	for(i=0;i<16;i++)
	{
		if(level.objused[i] == true)
			continue;

		level.objused[i] = true;
		return (i);
	}
	return -1;
}


calcspeed(speed, origin1, moveto)
{
	dist = distance(origin1, moveto);
	time = (dist / speed);
	return time;
}


inithud()
{
	al_x = -150;
	al_y = 40;
	ax_x = al_x + 64;
	ax_y = al_y;

	numalliesicon = self createIcon( game["icons"]["allies"], 32, 32 );
	numalliesicon setPoint( "TOPRIGHT", undefined, al_x, al_y );
	numalliesicon.archived = true;
	numalliesicon.hideWhenInMenu = true;
	numalliesicon.sort = 1;
	numalliesicon.alpha = 1;

	numfrozenalliesicon = self createIcon( "hud_freeze", 32, 32 );
	numfrozenalliesicon setPoint( "TOPRIGHT", undefined, al_x, al_y + 32 );
	numfrozenalliesicon.archived = true;
	numfrozenalliesicon.hideWhenInMenu = true;
	numfrozenalliesicon.sort = 1;
	numfrozenalliesicon.alpha = 1;

	numaxisicon = self createIcon( game["icons"]["axis"], 32, 32 );
	numaxisicon setPoint( "TOPRIGHT", undefined, ax_x, ax_y );
	numaxisicon.archived = true;
	numaxisicon.hideWhenInMenu = true;
	numaxisicon.sort = 1;
	numaxisicon.alpha = 1;

	numfrozenaxisicon = self createIcon( "hud_freeze", 32, 32 );
	numfrozenaxisicon setPoint( "TOPRIGHT", undefined, ax_x, ax_y + 32 );
	numfrozenaxisicon.archived = true;
	numfrozenaxisicon.hideWhenInMenu = true;
	numfrozenaxisicon.sort = 1;
	numfrozenaxisicon.alpha = 1;

	numallies = self createFontString( "objective", 1.4 );
	numallies.archived = true;
	numallies.hideWhenInMenu = true;
	numallies setPoint( "TOPRIGHT", undefined, al_x + 12, al_y + 8 );
	numallies.sort = 1;
	numallies.alpha = 1;
	numallies.color = (1,1,1);
	numallies setValue( 0 );

	numfrozenallies = self createFontString( "objective", 1.4 );
	numfrozenallies.archived = true;
	numfrozenallies.hideWhenInMenu = true;
	numfrozenallies setPoint( "TOPRIGHT", undefined, al_x + 12, al_y + 40 );
	numfrozenallies.sort = 1;
	numfrozenallies.alpha = 1;
	numfrozenallies.color = (1,1,1);
	numfrozenallies setValue( 0 );

	numaxis = self createFontString( "objective", 1.4 );
	numaxis.archived = true;
	numaxis.hideWhenInMenu = true;
	numaxis setPoint( "TOPRIGHT", undefined, ax_x + 12, ax_y + 8 );
	numaxis.sort = 1;
	numaxis.alpha = 1;
	numaxis.color = (1,1,1);
	numaxis setValue( 0 );

	numfrozenaxis = self createFontString( "objective", 1.4 );
	numfrozenaxis.archived = true;
	numfrozenaxis.hideWhenInMenu = true;
	numfrozenaxis setPoint( "TOPRIGHT", undefined, ax_x + 12, ax_y + 40 );
	numfrozenaxis.sort = 1;
	numfrozenaxis.alpha = 1;
	numfrozenaxis.color = (1,1,1);
	numfrozenaxis setValue( 0 );

	while ( isDefined( self ) && isAlive(self) )	{
		wait (0.05);
		
		numallies setValue(numofplayersnotfrozen("allies"));
		numfrozenallies setValue(numofplayersfrozen("allies"));
		numaxis setValue(numofplayersnotfrozen("axis"));
		numfrozenaxis setValue(numofplayersfrozen("axis"));
	}	
	
	if ( isDefined( numalliesicon ) )
		numalliesicon destroy();
	if ( isDefined( numfrozenalliesicon ) )
		numfrozenalliesicon destroy();
	if ( isDefined( numaxisicon ) )
		numaxisicon destroy();
	if ( isDefined( numfrozenaxisicon ) )
		numfrozenaxisicon destroy();
	if ( isDefined( numallies ) )
		numallies destroy();
	if ( isDefined( numfrozenallies ) )
		numfrozenallies destroy();
	if ( isDefined( numaxis ) )
		numaxis destroy();
	if ( isDefined( numfrozenaxis ) )
		numfrozenaxis destroy();
}


onTimeLimit()
{
	if ( level.inOvertime )
		return;

	thread onOvertime();
}


onOvertime()
{
	level endon ( "game_ended" );

	level.timeLimitOverride = true;
	level.inOvertime = true;

	for ( index = 0; index < level.players.size; index++ )
	{
		player = level.players[index];
		player notify("force_spawn");
		player thread maps\mp\gametypes\_hud_message::oldNotifyMessage( &"MP_SUDDEN_DEATH", &"MP_NO_RESPAWN", undefined, (1, 0, 0), "mp_last_stand" );
		player playLocalSound( "US_1mc_overtime" );
		player thread SetOvertimeSpec();
	}

	thread timeLimitClock_Overtime( level.scr_shift_spectator["ottime"] );
	wait ( level.scr_shift_spectator["ottime"] - 1 );
	self notify("stop_ticking");

	if(numofplayersnotfrozen("axis") == numofplayersnotfrozen("allies"))
		[[level.onDeadEvent]]( "all" );
	else if(numofplayersnotfrozen("axis") < numofplayersnotfrozen("allies"))
		[[level.onDeadEvent]]( "axis" );
	else if(numofplayersnotfrozen("allies") < numofplayersnotfrozen("axis"))
		[[level.onDeadEvent]]( "allies" );
}


timeLimitClock_Overtime( waitTime )
{
	level endon ( "game_ended" );
	level endon("stop_ticking");

	level.playedlastoneSound = false;
	level.OTtimeLeft = waitTime;
	setGameEndTime( getTime() + int(waitTime*1000) );
	clockObject = spawn( "script_origin", (0,0,0) );

	for ( ;; )
	{
		level.OTtimeLeft--;

		if ( level.OTtimeLeft <= 10 || (level.OTtimeLeft <= 30 && level.OTtimeLeft % 2 == 0) )
		{
			// don't play a tick at exactly 0 seconds, that's when something should be happening!
			if ( level.OTtimeLeft <= 0 )
				break;

			clockObject playSound( "ui_mp_timer_countdown" );
		}
		wait ( 1.0 );
	}
	return;
}


SetOvertimeSpec()
{
	if( !level.scr_shift_spectator["otspec"] || !isAlive(self) || !self.frozen || self.team == "spectator" )
		return;

	self suicide();
	self.deaths--;
	self.pers["deaths"] --;
	self.suicides--;
	self.pers["suicides"] --;	

	if (self.deaths <= 0 )
		self.deaths = 0;
	if (self.pers["deaths"] <= 0 )
		self.pers["deaths"] = 0;
	if (self.suicides <= 0 )
		self.suicides = 0;
	if (self.pers["suicides"] <= 0 )
		self.pers["suicides"] = 0;
	if ( level.teambased )
		self updateScores();

	self allowSpectateTeam( self.team, true );
	self allowSpectateTeam( getOtherTeam( self.team ), false );
	self allowSpectateTeam( "freelook", false );
	self allowSpectateTeam( "none", false );

	self.frozen = true;
	self thread RemoveIceItems();
	self.statusicon = "hud_freeze";
}


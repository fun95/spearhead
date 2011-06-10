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
#include shift\_utils;

init()
{
	if ( level.teamBased != true )
		return;

	if ( !isdefined( game["switchedsides"] ) )
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
	if ( isdefined( level.scr_shift_gameplay["spawn"] ) && level.scr_shift_gameplay["spawn"] )
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
	precacheString( &"FTAG_DEFROSTED_UNKNOWN" );
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
	level.barsize = 100;
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

	if ( level.scr_shift_hud["team"] )
		level thread inithud();
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

		if ( isdefined(self.frozen) && self.frozen && self.pers["team"] != "spectator" )
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
		if ( isdefined( self.freezeorigin ) && isdefined( self.freezeangles ) )
		self spawn(self.freezeorigin, self.freezeangles);	
		self thread freezeme();
	} else if ( !level.scr_ftag_defrost["respawn"] && isdefined( self.freezeorigin ) && isdefined( self.freezeangles ) ) {
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

	self setClientdvars( "cg_drawhealth", 0 );
	self setClientDvar( "ui_healthoverlay", 0 );

	self.isdefrosting = false;
	self.isdefrostingsomeone = false;
	self.healthgiven = 0;
	self.healthgiven2 = 0;
	self.beam = false;

	wait(0.05);

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
	if ( isdefined( self.frozen ) && self.frozen )
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
		if( isdefined( attacker ) && isPlayer( attacker ) && attacker != self ) {
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

	self setClientdvars( "cg_drawhealth", 1 );
	self setClientDvar( "ui_healthoverlay", 1 );

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
		while ( self.isdefrosting )
			wait (0.05);

		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			player = players[i];

			// Check if the player can defrost
			if ( !isDefined( player ) || !isDefined( player.pers ) || !isPlayer( player ) || player.sessionstate != "playing" )
				continue;

			// Make sure player is on our team and not self or frozen
			if ( player.team != self.team  || player == self || isdefined( player.frozen ) && player.frozen )
				continue;

			if( distance( self.origin, player.origin ) <= level.scr_ftag_defrost["dist"] )
				inrange = true;
			else
				inrange = false;

			if( !inrange )
				continue;

			// Make sure this player is not already defrosting someone
			if ( isdefined(player.isdefrostingsomeone) && player.isdefrostingsomeone && level.scr_ftag_defrost["mode"] == 2 )
				self thread defrostme2( player, false );
			else if ( !isdefined( player.isdefrostingsomeone ) || !player.isdefrostingsomeone )
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
		while ( self.isdefrosting )
			wait (0.05);

		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			player = players[i];

			// Check if the player can defrost
			if ( !isDefined( player ) || !isDefined( player.pers ) || !isPlayer( player ) || player.sessionstate != "playing" )
				continue;

			// Make sure player is on our team and not self or frozen
			if ( player.team != self.team  || player == self || isdefined( player.frozen ) && player.frozen )
				continue;

			if( !player ftagButtonPressed() || !player islookingatftag(self) )
				continue;

			// Make sure this player is not already defrosting someone
			if ( isdefined(player.isdefrostingsomeone) && player.isdefrostingsomeone && level.scr_ftag_defrost["mode"] == 2 )
				self thread defrostme2( player, true );
			else if ( !isdefined( player.isdefrostingsomeone ) || !player.isdefrostingsomeone )
				self thread defrostme( player, true );
		}
		wait 0.05;
	}
}


createprogressdisplays( player, defrostindex )
{
	if( !isDefined( self.defrostingmsg ) ) {
		self.defrostingmsg = newClientHudElem(self);
		self.defrostingmsg.alignX = "left";
		self.defrostingmsg.alignY = "middle";
		self.defrostingmsg.horzAlign = "fullscreen";
		self.defrostingmsg.vertAlign = "fullscreen";
		self.defrostingmsg.x = 16;
		self.defrostingmsg.y = 435;
		self.defrostingmsg.alpha = 1;
		self.defrostingmsg.sort = 1;
		self.defrostingmsg.fontscale = 1.4;
		self.defrostingmsg setText(&"SHIFT_FTAG_DEFROSTING");
	}
	if( !defrostindex ) {
		if( !isDefined( player.defrostmsg0 ) ) {
			player.defrostmsg0 = newClientHudElem(player);
			player.defrostmsg0.alignX = "left";
			player.defrostmsg0.alignY = "middle";
			player.defrostmsg0.horzAlign = "fullscreen";
			player.defrostmsg0.vertAlign = "fullscreen";
			player.defrostmsg0.x = 30;
			player.defrostmsg0.y = 410;
			player.defrostmsg0.alpha = 1;
			player.defrostmsg0.sort = 1;
			player.defrostmsg0.fontscale = 1.4;
			player.defrostmsg0 setText(&"SHIFT_FTAG_DEFROSTING");
		}

		if( !isDefined( player.progressbackground0 ) ) {
			player.progressbackground0 = newClientHudElem(player);
			player.progressbackground0.alignX = "left";
			player.progressbackground0.alignY = "middle";
			player.progressbackground0.horzAlign = "fullscreen";
			player.progressbackground0.vertAlign = "fullscreen";
			player.progressbackground0.x = 30;
			player.progressbackground0.y = 425;
			player.progressbackground0.alpha = 0.5;
			player.progressbackground0.sort = 1;
			player.progressbackground0 setShader("black", (level.barsize + 2), (level.barheight + 2) );
		}

		if( !isDefined( player.progressbar0 ) ) {
			player.progressbar0 = newClientHudElem(player);
			player.progressbar0.alignX = "left";
			player.progressbar0.alignY = "middle";
			player.progressbar0.horzAlign = "fullscreen";
			player.progressbar0.vertAlign = "fullscreen";
			player.progressbar0.x = 31;
			player.progressbar0.y = 425;
			player.progressbar0.sort = 2;
			player.progressbar0.color = (0.3,1,1);
			player.progressbar0 setShader("white", 1, level.barheight);
			player.progressbar0 scaleOverTime(self.maxhealth, level.barsize, level.barheight);
		}
	} else {
		if( !isDefined( player.defrostmsg1 ) ) {
			player.defrostmsg1 = newClientHudElem(player);
			player.defrostmsg1.alignX = "left";
			player.defrostmsg1.alignY = "middle";
			player.defrostmsg1.horzAlign = "fullscreen";
			player.defrostmsg1.vertAlign = "fullscreen";
			player.defrostmsg1.x = 30;
			player.defrostmsg1.y = 435;
			player.defrostmsg1.alpha = 1;
			player.defrostmsg1.sort = 1;
			player.defrostmsg1.fontscale = 1.4;
			player.defrostmsg1 setText(&"SHIFT_FTAG_DEFROSTING");
		}
	
		if( !isDefined( player.progressbackground1 ) ) {
			player.progressbackground1 = newClientHudElem(player);
			player.progressbackground1.alignX = "left";
			player.progressbackground1.alignY = "middle";
			player.progressbackground1.horzAlign = "fullscreen";
			player.progressbackground1.vertAlign = "fullscreen";
			player.progressbackground1.x = 30;
			player.progressbackground1.y = 450;
			player.progressbackground1.alpha = 0.5;
			player.progressbackground1.sort = 1;
			player.progressbackground1 setShader("black", (level.barsize + 2), (level.barheight + 2) );
		}

		if( !isDefined( player.progressbar1 ) ) {
			player.progressbar1 = newClientHudElem(player);
			player.progressbar1.alignX = "left";
			player.progressbar1.alignY = "middle";
			player.progressbar1.horzAlign = "fullscreen";
			player.progressbar1.vertAlign = "fullscreen";
			player.progressbar1.x = 31;
			player.progressbar1.y = 450;
			player.progressbar1.sort = 2;
			player.progressbar1.color = (0.3,1,1);
			player.progressbar1 setShader("white", 1, level.barheight);
			player.progressbar1 scaleOverTime(self.maxhealth, level.barsize, level.barheight);
		}
	}

	return;
}


defrostme( player, beam )
{
	if ( level.inOvertime )
		return;

	defroststicker = undefined;
	self.isdefrosting = true;
	player.isdefrostingsomeone = true;

	self thread createprogressdisplays( player, 0 );

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


	while( isPlayer(self) && self.sessionstate == "playing" && (self.health < self.maxhealth) && game["state"] != "postgame" && isdefined( self.frozen ) && self.frozen )
	{
		if( !isPlayer(player) || player.sessionstate != "playing" || isdefined( player.frozen ) && player.frozen )
			break;
		if( beam && ( !player ftagButtonPressed() || !player islookingatftag(self) ) )
			break;
		if( !beam && distance( self.origin, player.origin ) >= level.scr_ftag_defrost["dist"] )
			break;

		if( beam )
			self thread dobeam(player);

		width = self.health / self.maxhealth;
		width = int(level.barsize * width);

		if( isDefined( player.progressbar0 ) )
			player.progressbar0 setShader("white", width, level.barheight);

		if ( level.scr_ftag_defrost["cube"] )
			self.ice.origin = self.ice.origin - (0,0, ( 60 / self.maxhealth ) );
		if ( level.scr_ftag_defrost["cube"] && isDefined( self.cubeisrotating ) && self.cubeisrotating == false)
			self thread rotatemycube(player);
		self.health++;
		player.healthgiven++;
		wait level.scr_ftag_defrost["time"];
	}

	if( isDefined( self.defrostingmsg ) )
		self.defrostingmsg destroy();
	if( isDefined( player.defrostmsg0 ) )
		player.defrostmsg0 destroy();
	if( isDefined( player.progressbackground0 ) )
		player.progressbackground0 destroy();
	if( isDefined( player.progressbar0 ) )
		player.progressbar0 destroy();

	player.isdefrostingsomeone = false;

	if( self.health + 1 >= self.maxhealth ) {
		self thread defrosted(player, beam, defroststicker);
	} else if( !player.frozen && !beam && level.scr_ftag_defrost["mode"] != 2 ) {
		player unlink();
		player enableWeapons();
		defroststicker delete();
	} else if( !beam && level.scr_ftag_defrost["mode"] != 2 ) {
		defroststicker delete();
	}

	self.isdefrosting = false;
	self notify("stop_defrost_fx");
}


defrostme2( player, beam )
{
	if ( level.inOvertime )
		return;

	self.isdefrosting = true;
	player.isdefrostingsomeone = true;

	self thread createprogressdisplays( player, 1 );

	if( !isDefined(self.defrostprogresstime) )
		self.defrostprogresstime = 0;

	self.cubeisrotating = false;
	self.rotang = 0;

	self thread playloopfx(level.fx_defrostmelt,self.origin,0.5,"stop_defrost_fx");

	while( isPlayer(self) && self.sessionstate == "playing" && (self.health < self.maxhealth) && game["state"] != "postgame" && isdefined( self.frozen ) && self.frozen )
	{
		if( !isPlayer(player) || player.sessionstate != "playing" || isdefined( player.frozen ) && player.frozen )
			break;
		if( beam && ( !player ftagButtonPressed() || !player islookingatftag(self) ) )
			break;
		if( !beam && distance( self.origin, player.origin ) >= level.scr_ftag_defrost["dist"] )
			break;

		if( beam )
			self thread dobeam(player);

		width = self.health / self.maxhealth;
		width = int(level.barsize * width);

		if( isDefined( player.progressbar1 ) )
			player.progressbar1 setShader("white", width, level.barheight);

		if ( level.scr_ftag_defrost["cube"] )
			self.ice.origin = self.ice.origin - (0,0, ( 60 / self.maxhealth ) );
		if ( level.scr_ftag_defrost["cube"] && isDefined( self.cubeisrotating ) && self.cubeisrotating == false)
			self thread rotatemycube(player);
		self.health++;
		player.healthgiven2++;
		wait level.scr_ftag_defrost["time"];
	}

	if( isDefined( self.defrostingmsg ) )
		self.defrostingmsg destroy();
	if( isDefined( player.defrostmsg1 ) )
		player.defrostmsg1 destroy();
	if( isDefined( player.progressbackground1 ) )
		player.progressbackground1 destroy();
	if( isDefined( player.progressbar1 ) )
		player.progressbar1 destroy();

	player.isdefrostingsomeone = false;

	if( self.health + 1 >= self.maxhealth )
		self thread defrosted( player, false, false );

	self.isdefrosting = false;
	self notify("stop_defrost_fx");
}

defrosted(player, beam, defroststicker)
{
	self setClientdvars( "cg_drawhealth", 0 );
	self setClientDvar( "ui_healthoverlay", 0 );

	if( isDefined(self.defrostingmsg ) )
		self.defrostingmsg destroy();

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
				if ( isdefined( player.healthgiven ) && player.healthgiven > 0 )
					value = int( ( ( player.healthgiven + 1 ) / self.maxhealth ) * level.defrostpoint );
				else if ( isdefined( player.healthgiven2 ) && player.healthgiven2 > 0 )
					value = int( ( ( player.healthgiven2 + 1 ) / self.maxhealth ) * level.defrostpoint );

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

					if ( !isdefined(level.defrostplayers) )
						level.defrostplayers = player.name;
					else
						level.defrostplayers += " & " + player.name;
					player.healthgiven = 0;
					player.healthgiven2 = 0;
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
	if(!self.isdefrosting)
		self thread defrosted(undefined, false, undefined);
	else
	{
		while(self.isdefrosting)
			wait level.scr_ftag_defrost["auto"];
		if(!self.isdefrosting)
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
		if( isdefined( trace["entity"] ) && trace["entity"] == who )
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
	al_x = 530;
	al_y = 45;
	ax_x = al_x + 64;
	ax_y = al_y;

	level.numalliesicon = newHudelem();
	level.numalliesicon.alignX = "center";
	level.numalliesicon.alignY = "middle";
	level.numalliesicon.horzAlign = "fullscreen";
	level.numalliesicon.vertAlign = "fullscreen";
	level.numalliesicon.x = al_x;
	level.numalliesicon.y = al_y;
	level.numalliesicon.sort = 10;
	level.numalliesicon.color = (1,1,1);
	level.numalliesicon setShader(game["icons"]["allies"],32,32);

	level.numallies = newHudelem();
	level.numallies.alignX = "right";
	level.numallies.alignY = "middle";
	level.numallies.horzAlign = "fullscreen";
	level.numallies.vertAlign = "fullscreen";
	level.numallies.x = al_x + 32;
	level.numallies.y = al_y;
	level.numallies.sort = 10;
	level.numallies.color = (1,1,1);
	level.numallies.fontscale = 1.4;
	level.numallies setValue(1);

	level.numfrozenalliesicon = newHudelem();
	level.numfrozenalliesicon.alignX = "center";
	level.numfrozenalliesicon.alignY = "middle";
	level.numfrozenalliesicon.horzAlign = "fullscreen";
	level.numfrozenalliesicon.vertAlign = "fullscreen";
	level.numfrozenalliesicon.x = al_x;
	level.numfrozenalliesicon.y = al_y + 32;
	level.numfrozenalliesicon.sort = 10;
	level.numfrozenalliesicon.color = (1,1,1);
	level.numfrozenalliesicon setShader("hud_freeze",32,32);

	level.numfrozenallies = newHudelem();
	level.numfrozenallies.alignX = "right";
	level.numfrozenallies.alignY = "middle";
	level.numfrozenallies.horzAlign = "fullscreen";
	level.numfrozenallies.vertAlign = "fullscreen";
	level.numfrozenallies.x = al_x + 32;
	level.numfrozenallies.y = al_y + 32;
	level.numfrozenallies.sort = 10;
	level.numfrozenallies.color = (1,1,1);
	level.numfrozenallies.fontscale = 1.4;
	level.numfrozenallies setValue(1);

	level.numaxisicon = newHudelem();
	level.numaxisicon.alignX = "center";
	level.numaxisicon.alignY = "middle";
	level.numaxisicon.horzAlign = "fullscreen";
	level.numaxisicon.vertAlign = "fullscreen";
	level.numaxisicon.x = ax_x;
	level.numaxisicon.y = ax_y;
	level.numaxisicon.sort = 10;
	level.numaxisicon.color = (1,1,1);
	level.numaxisicon setShader(game["icons"]["axis"],32,32);

	level.numaxis = newHudelem();
	level.numaxis.alignX = "right";
	level.numaxis.alignY = "middle";
	level.numaxis.horzAlign = "fullscreen";
	level.numaxis.vertAlign = "fullscreen";
	level.numaxis.x = ax_x + 32;
	level.numaxis.y = ax_y;
	level.numaxis.sort = 10;
	level.numaxis.color = (1,1,1);
	level.numaxis.fontscale = 1.4;
	level.numaxis setValue(1);

	level.numfrozenaxisicon = newHudelem();
	level.numfrozenaxisicon.alignX = "center";
	level.numfrozenaxisicon.alignY = "middle";
	level.numfrozenaxisicon.horzAlign = "fullscreen";
	level.numfrozenaxisicon.vertAlign = "fullscreen";
	level.numfrozenaxisicon.x = ax_x;
	level.numfrozenaxisicon.y = ax_y + 32;
	level.numfrozenaxisicon.sort = 10;
	level.numfrozenaxisicon.color = (1,1,1);
	level.numfrozenaxisicon setShader("hud_freeze",32,32);

	level.numfrozenaxis = newHudelem();
	level.numfrozenaxis.alignX = "right";
	level.numfrozenaxis.alignY = "middle";
	level.numfrozenaxis.horzAlign = "fullscreen";
	level.numfrozenaxis.vertAlign = "fullscreen";
	level.numfrozenaxis.x = ax_x + 32;
	level.numfrozenaxis.y = ax_y + 32;
	level.numfrozenaxis.sort = 10;
	level.numfrozenaxis.color = (1,1,1);
	level.numfrozenaxis.fontscale = 1.4;
	level.numfrozenaxis setValue(1);

	while(1)
	{
		level.numallies setValue(numofplayersnotfrozen("allies"));
		level.numfrozenallies setValue(numofplayersfrozen("allies"));
		level.numaxis setValue(numofplayersnotfrozen("axis"));
		level.numfrozenaxis setValue(numofplayersfrozen("axis"));
		wait 0.1;
	}
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


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
	if ( level.gametype == "dom" || level.gametype == "ftag" )
		return;

	level.onTimeLimit = ::onTimeLimit;
	level.onPlayerFrozen = ::onPlayerFrozen;
	level.onStartFtagGame = ::onStartFtagGame;
	level.onSpawnFtagPlayer = ::onSpawnFtagPlayer;

	if ( level.gametype == "koth" || level.gametype == "war" )
		level.onDeadEvent = ::onDeadEvent;

	level.ftagactive = true;
	level.overrideTeamScore = true;
	level.displayRoundEndText = true;

	level.scr_game_spawn_type = getdvardefault("scr_game_spawn_type","int",0,0,4);
	level.hardcoreMode = getDvarInt( "scr_hardcore" );
	level.oldschool = ( getDvarInt( "scr_oldschool" ) == 1 );

	if ( level.scr_game_spawn_type != 0 )
		level.onSpawnPlayer = ::onSpawnPlayer;

	if ( level.hardcoreMode )
		level.maxhealth = getdvardefault( "scr_player_maxhealth", "int", 30, 1, 500 );
	else if ( level.oldschool )
		level.maxhealth = getdvardefault( "scr_player_maxhealth", "int", 200, 1, 500 );
	else
		level.maxhealth = getdvardefault( "scr_player_maxhealth", "int", 100, 1, 500 );

	// Add more detail to the type of game being played
	if ( isdefined ( level.ftagactive ) && level.ftagactive ) {
		gametype = "freezetag";
		game["dialog"]["gametype"] = gametype;
	}	
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

	// Set multiple defrost values from single dvar
	defrostvalues = strtok( level.scr_ftag_defrost_values, ";" );

	level.defrostmode = int( defrostvalues[0] );
	level.defrostrespawn = int( defrostvalues[1] );
	level.defrosttime = int( defrostvalues[2] );
	level.defrostdistance = int( defrostvalues[3] );
	level.autodefrost = int( defrostvalues[4] );
	level.unfreeze_button = defrostvalues[5];
	level.showdefrostbeam = int( defrostvalues[6] );
	level.rotate_cube = int( defrostvalues[7] );

	level.ftag_sd_spec = getdvardefault("scr_ftag_sd_spec","int",1,0,1);
	level.ftag_sd_time = getdvardefault("scr_ftag_sd_time","int",90,0,999999);
	level.scr_ftag_showteamstatus = getdvardefault("scr_ftag_showteamstatus","int",1,0,1);
	level.scr_ftag_showcentermessage = getdvardefault("scr_ftag_showcentermessage","int",1,0,1);
	level.scr_ftag_showstatusmessage = getdvardefault("scr_ftag_showstatusmessage","int",1,0,1);

	level.thismap = toLower( getDvar( "mapname" ) );
	level.spawn_type_map = getdvardefault("scr_spawn_type_" + level.thismap,"int",0,0,4);

	level.fx_defrostmelt = loadFx("freezetag/defrostmelt");
	level.barsize = 100;
	level.barheight = 3;

	level.objused = [];
	for (i=0;i<16;i++)
		level.objused[i] = false;
}

onStartFtagGame()
{
	if ( level.scr_game_spawn_type != 0 ) {
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

	level.inOvertime = false;

	level.displayRoundEndText = true;

	level thread onPrecacheFtag();
	level thread onPlayerConnect();
	level thread checkforfrozenplayers();

	if ( level.scr_ftag_showteamstatus )
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

	if ( level.spawn_type_map <= 4 || level.spawn_type_map != 0 )
		level.scr_game_spawn_type = level.spawn_type_map;

	if ( level.useStartSpawns )
	{
		// Set Spawn Points From DVar, 0 = Disabled(default), 1 = Team End, 2 = Near Team, 3 = Scattered, 4 = Random
		if ( level.scr_game_spawn_type == 2 ) {
			if (spawnteam == "axis")
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_axis);
			else
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(level.spawn_allies);
		} else if ( level.scr_game_spawn_type == 3 ) {
			numb = randomInt(2);
			if (numb == 1)
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_axis);
			else
				spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(level.spawn_allies);
		} else if ( level.scr_game_spawn_type == 4 ) {
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
	} else if ( !level.defrostrespawn && isdefined( self.freezeorigin ) && isdefined( self.freezeangles ) ) {
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

	self.isdefrosting = false;
	self.isdefrostingsomeone = false;
	self.healthgiven = 0;
	self.healthgiven2 = 0;
	self.beam = false;

	wait(0.05);

	if ( level.inOvertime )
		self thread SetOvertimeSpec();
}

checkforfrozenplayers()
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

	if ( level.scr_ftag_showcentermessage ) {
		if( isdefined( attacker ) && isPlayer( attacker ) && attacker != self ) {
			self iprintlnbold(&"SHIFT_FTAG_HUD_FROZENBY" , attacker.name);
			attacker iprintlnbold(&"SHIFT_FTAG_HUD_YOUFROZE" , self.name);
			if ( level.scr_ftag_showstatusmessage )
				iPrintln(&"SHIFT_FTAG_FROZE" , attacker.name , self.name);
		} else {
			self iprintlnbold(&"SHIFT_FTAG_HUD_YOUFROZE_SELF");
			if ( level.scr_ftag_showstatusmessage )
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

	if( numofplayers("allies") < 1 || numofplayers("axis") < 1 || level.autodefrost )
		self thread defrostaftertime();

	self thread waitfordefrost();
}

waitfordefrost()
{
	level endon("game_ended");
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("defrosted");
	self endon("death");

	wait(1.0);
	self.ice.origin = self.origin + (0,0,30);
	self.ice.alpha = 1;

	while(1)
	{
		players = getentarray("player", "classname");
		for(i=0;i<players.size;i++)
		{
			player = players[i];

			if(self.isdefrosting)
				continue;
			if(isdefined(player.isdefrostingsomeone) && player.isdefrostingsomeone && (level.defrostmode == 0 || level.defrostmode == 1))
				continue;
			if(player.sessionstate != "playing")
				continue;
			if(player.team != self.team)
				continue;
			if(player == self)
				continue;
			if(isdefined(player.frozen) && player.frozen)
				continue;

			if( level.defrostmode == 2 )
			{
				if( !isdefined(player.isdefrostingsomeone) || isdefined(player.isdefrostingsomeone) && !player.isdefrostingsomeone )
				{
					if(distance(self.origin, player.origin) <= 50)
						inrange = true;
					else
						inrange = false;
				} else {
					inrange = false;
				}

				if( inrange ) {
					if (isdefined(player.isdefrostingsomeone) && !player.isdefrostingsomeone)
						self thread defrostme(player);
					else
						self thread defrostme2(player);
				} else if(player ftagButtonPressed() && player islookingatftag(self)) {
					if (isdefined(player.isdefrostingsomeone) && !player.isdefrostingsomeone)
						self thread defrostme(player, true);
					else
						self thread defrostme2(player, true);
				}
			}
			else if( level.defrostmode == 0 )
			{
				if(player ftagButtonPressed() && player islookingatftag(self))
					self thread defrostme(player, true);
			}
			else
			{
				if(level.defrostdist)
				{
					if(distance(self.origin, player.origin) <= level.defrostdist)
						inrange = true;
					else
						inrange = false;
				}
				else
					inrange = true;
				trace = bulletTrace(player.origin + (0,0,10), self.origin + (0,0,10), false, undefined);
				if(inrange && trace["fraction"] == 1)
					self thread defrostmeicon(player);
			}
		}
		wait 0.05;
	}
}

defrostmeicon(player)
{
	if(!isDefined(player.defrosticon))
	{
		player.defrosticon = newClientHudElem(player);
		player.defrosticon.alignX = "center";
		player.defrosticon.alignY = "middle";
		player.defrosticon.x = 320;
		player.defrosticon.y = 340;
		player.defrosticon.sort = 1;
		player.defrosticon setShader("hud_freeze", 64, 64);
	}
	player thread iconchecker(self);

	if(player.frozen || !player ftagButtonPressed() || !player isonground())
		return;

	self thread defrostme(player);
}

defrostme(player, beam)
{
	if ( level.inOvertime )
		return;

	if(!isDefined(beam))
		beam = false;

	defroststicker = undefined;
	self.isdefrosting = true;
	player.isdefrostingsomeone = true;

	if(isDefined(self.defrostmsg))
		self.defrostmsg destroy();

	self setClientDvar( "cg_drawhealth", 1 );

	self.defrostmsg = newClientHudElem(self);
	self.defrostmsg.alignX = "left";
	self.defrostmsg.alignY = "middle";
	self.defrostmsg.horzAlign = "fullscreen";
	self.defrostmsg.vertAlign = "fullscreen";
	self.defrostmsg.x = 30;
	self.defrostmsg.y = 410;
	self.defrostmsg.alpha = 1;
	self.defrostmsg.sort = 1;
	self.defrostmsg.fontscale = 1.4;
	self.defrostmsg setText(&"SHIFT_FTAG_DEFROSTING");

	if(isDefined(player.defrostmsg))
		player.defrostmsg destroy();

	player.defrostmsg = newClientHudElem(player);
	player.defrostmsg.alignX = "left";
	player.defrostmsg.alignY = "middle";
	player.defrostmsg.horzAlign = "fullscreen";
	player.defrostmsg.vertAlign = "fullscreen";
	player.defrostmsg.x = 30;
	player.defrostmsg.y = 410;
	player.defrostmsg.alpha = 1;
	player.defrostmsg.sort = 1;
	player.defrostmsg.fontscale = 1.4;
	player.defrostmsg setText(&"SHIFT_FTAG_DEFROSTING");

	if(isDefined(player.progressbackground))
		player.progressbackground destroy();

	player.progressbackground = newClientHudElem(player);
	player.progressbackground.alignX = "left";
	player.progressbackground.alignY = "middle";
	player.progressbackground.horzAlign = "fullscreen";
	player.progressbackground.vertAlign = "fullscreen";
	player.progressbackground.x = 30;
	player.progressbackground.y = 425;
	player.progressbackground.alpha = 0.5;
	player.progressbackground.sort = 1;
	player.progressbackground setShader("black", (level.barsize + 2), (level.barheight + 2) );

	if(isDefined(player.progressbar))
		player.progressbar destroy();

	player.progressbar = newClientHudElem(player);
	player.progressbar.alignX = "left";
	player.progressbar.alignY = "middle";
	player.progressbar.horzAlign = "fullscreen";
	player.progressbar.vertAlign = "fullscreen";
	player.progressbar.x = 31;
	player.progressbar.y = 425;
	player.progressbar.sort = 2;
	player.progressbar.color = (0.3,1,1);
	player.progressbar setShader("white", 1, level.barheight);
	player.progressbar scaleOverTime(self.maxhealth, level.barsize, level.barheight);

	if(!beam && level.defrostmode != 2 )
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

	while(isPlayer(self) && self.sessionstate == "playing" && (self.health < self.maxhealth) && game["state"] != "postgame")
	{
		if( !isPlayer(player) || player.sessionstate != "playing" || player.frozen || ( !player ftagButtonPressed() && level.defrostmode != 2 ) || ( !player ftagButtonPressed() && beam ) )
			break;
		if(beam)
		{
			self thread dobeam(player);
			if(!player islookingatftag(self))
				break;
		}
		else if ( level.defrostmode == 2 )
		{
			if(distance(self.origin, player.origin) >= 50)
				break;
		}

		width = self.health / self.maxhealth;
		width = int(level.barsize * width);

		if(isDefined(player.progressbar))
			player.progressbar setShader("white", width, level.barheight);

		if (level.rotate_cube == 1)
			self.ice.origin = self.ice.origin - (0,0, ( 60 / self.maxhealth ) );
		if (level.rotate_cube == 1 && isDefined(self.cubeisrotating) && self.cubeisrotating == false)
			self thread rotatemycube(player);
		self.health++;
		player.healthgiven++;
		wait level.defrosttime;
	}

	self setClientDvar( "cg_drawhealth", 1 );

	if(isDefined(self.defrostmsg))
		self.defrostmsg destroy();

	if(isDefined(player.defrostmsg))
		player.defrostmsg destroy();
	if(isDefined(player.progressbackground))
		player.progressbackground destroy();
	if(isDefined(player.progressbar))
		player.progressbar destroy();
	player.isdefrostingsomeone = false;

	if(self.health + 1 >= self.maxhealth)
		self thread defrosted(player, beam, defroststicker);
	else if(!player.frozen && !beam && level.defrostmode != 2)
	{
		player unlink();
		player enableWeapons();
		defroststicker delete();
	}
	else if(!beam && level.defrostmode != 2)
		defroststicker delete();
	self.isdefrosting = false;
	self notify("stop_defrost_fx");
}

defrostme2(player, beam2)
{
	if ( level.inOvertime )
		return;

	if(!isDefined(beam2))
		beam2 = false;

	self.isdefrosting = true;
	player.isdefrostingsomeone = true;

	if(isDefined(self.defrostmsg))
		self.defrostmsg destroy();

	self setClientdvars( "cg_drawhealth", 1, "cg_drawhealthlogo", "hud_freeze" );

	self.defrostmsg = newClientHudElem(self);
	self.defrostmsg.alignX = "left";
	self.defrostmsg.alignY = "middle";
	self.defrostmsg.horzAlign = "fullscreen";
	self.defrostmsg.vertAlign = "fullscreen";
	self.defrostmsg.x = 30;
	self.defrostmsg.y = 410;
	self.defrostmsg.alpha = 1;
	self.defrostmsg.sort = 1;
	self.defrostmsg.fontscale = 1.4;
	self.defrostmsg setText(&"SHIFT_FTAG_DEFROSTING");

	if(isDefined(player.defrostmsg2))
		player.defrostmsg2 destroy();

	player.defrostmsg2 = newClientHudElem(player);
	player.defrostmsg2.alignX = "left";
	player.defrostmsg2.alignY = "middle";
	player.defrostmsg2.horzAlign = "fullscreen";
	player.defrostmsg2.vertAlign = "fullscreen";
	player.defrostmsg2.x = 150;
	player.defrostmsg2.y = 410;
	player.defrostmsg2.alpha = 1;
	player.defrostmsg2.sort = 1;
	player.defrostmsg2.fontscale = 1.4;
	player.defrostmsg2 setText(&"SHIFT_FTAG_DEFROSTING");

	if(isDefined(player.progressbackground2))
		player.progressbackground2 destroy();

	player.progressbackground2 = newClientHudElem(player);
	player.progressbackground2.alignX = "left";
	player.progressbackground2.alignY = "middle";
	player.progressbackground2.horzAlign = "fullscreen";
	player.progressbackground2.vertAlign = "fullscreen";
	player.progressbackground2.x = 150;
	player.progressbackground2.y = 425;
	player.progressbackground2.alpha = 0.5;
	player.progressbackground2.sort = 1;
	player.progressbackground2 setShader("black", (level.barsize + 2), (level.barheight + 2) );

	if(isDefined(player.progressbar2))
		player.progressbar2 destroy();

	player.progressbar2 = newClientHudElem(player);
	player.progressbar2.alignX = "left";
	player.progressbar2.alignY = "middle";
	player.progressbar2.horzAlign = "fullscreen";
	player.progressbar2.vertAlign = "fullscreen";
	player.progressbar2.x = 151;
	player.progressbar2.y = 425;
	player.progressbar2.sort = 2;
	player.progressbar2.color = (0.3,1,1);
	player.progressbar2 setShader("white", 1, level.barheight);
	player.progressbar2 scaleOverTime(level.defrosttime, level.barsize, level.barheight);

	if( !isDefined(self.defrostprogresstime) )
		self.defrostprogresstime = 0;

	self.cubeisrotating = false;
	self.rotang = 0;

	self thread playloopfx(level.fx_defrostmelt,self.origin,0.5,"stop_defrost_fx");		// REMOVED IN CURRENT MOD

	while(isPlayer(self) && self.sessionstate == "playing" && (self.health < self.maxhealth) && game["state"] != "postgame")
	{
		if( !isPlayer(player) || player.sessionstate != "playing" || player.frozen || ( !player ftagButtonPressed() && beam2 ) )
			break;
		if(beam2)
		{
			self thread dobeam(player);
			if(!player islookingatftag(self))
				break;
		}
		else if ( level.defrostmode == 2 )
		{
			if(distance(self.origin, player.origin) >= 50)
				break;
		}

		width = self.health / self.maxhealth;
		width = int(level.barsize * width);

		if(isDefined(player.progressbar2))
			player.progressbar2 setShader("white", width, level.barheight);

		if (level.rotate_cube == 1)
			self.ice.origin = self.ice.origin - (0,0, ( 60 / self.maxhealth ) );
		if (level.rotate_cube == 1 && isDefined(self.cubeisrotating) && self.cubeisrotating == false)
			self thread rotatemycube(player);
		self.health++;
		player.healthgiven2++;
		wait level.defrosttime;
	}

	self setClientDvar( "cg_drawhealth", 1 );

	if(isDefined(self.defrostmsg))
		self.defrostmsg destroy();

	if(isDefined(player.defrostmsg2))
		player.defrostmsg2 destroy();
	if(isDefined(player.progressbackground2))
		player.progressbackground2 destroy();
	if(isDefined(player.progressbar2))
		player.progressbar2 destroy();
	player.isdefrostingsomeone = false;

	if(self.health + 1 >= self.maxhealth)
		self thread defrosted(player, beam2);

	self.isdefrosting = false;
	self notify("stop_defrost_fx");
}

defrosted(player, beam, defroststicker)
{
	self setClientDvar( "cg_drawhealth", 1 );

	if(isDefined(self.defrostmsg))
		self.defrostmsg destroy();

	if(isDefined(player))
	{
		if(!beam && level.defrostmode != 2)
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
			if ( player.team == self.team ) {
				value = 0;
				if ( isdefined( player.healthgiven ) && player.healthgiven > 0 )
					value = int( ( ( player.healthgiven + 1 ) / self.maxhealth ) * 50 );
				else if ( isdefined( player.healthgiven2 ) && player.healthgiven2 > 0 )
					value = int( ( ( player.healthgiven2 + 1 ) / self.maxhealth ) * 50 );

				if ( value >= 1 ) {
					if ( value >= 50 )
						value = 50;

					player thread maps\mp\gametypes\_rank::giveRankXP( "assist", value );
					player.score += value;
					player.pers["score"] += value;

					player maps\mp\gametypes\_rank::giveRankXP( "assist" );
					player maps\mp\gametypes\_globallogic::incPersStat( "assists", 1 );
					player.assists = player maps\mp\gametypes\_globallogic::getPersStat( "assists" );

					if ( level.scr_ftag_showcentermessage ) {
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
			level.defrostplayers = self.name;

		if ( level.scr_ftag_showcentermessage )
			self iprintlnbold(&"SHIFT_FTAG_HUD_DEFROSTEDBY", level.defrostplayers);
		if ( level.scr_ftag_showstatusmessage )
			iPrintln(&"SHIFT_FTAG_DEFROSTED" , level.defrostplayers , self.name);
	}
	else if( level.autodefrost )
	{
		if ( level.scr_ftag_showcentermessage )
			self iprintlnbold(&"SHIFT_FTAG_HUD_AUTO_DEFROSTED");
		if ( level.scr_ftag_showstatusmessage )
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

	if ( !level.autodefrost )
		level.autodefrost = 10;

	wait level.autodefrost;
	if(!self.isdefrosting)
		self thread defrosted(undefined, false, undefined);
	else
	{
		while(self.isdefrosting)
			wait level.autodefrost;
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
	if(level.defrostdist)
	{
		if(distance(self.origin, who.origin) <= level.defrostdist)
			inrange = true;
		else
			inrange = false;
	}
	else
		inrange = true;

	if(inrange)
	{
		if(self getStance() == "prone")
			myeye = self.origin + (0,0,11);
		else if(self getStance() == "crouch")
			myeye = self.origin + (0,0,40);
		else 
			myeye = self.origin + (0,0,60);
		myangles = self getPlayerAngles();
		if(level.defrostdist)
			end = level.defrostdist;
		else
			end = 9999999;
		origin = myeye + maps\mp\_utility::vector_Scale(anglestoforward(myangles),end);
		trace = bulletTrace(myeye, origin, true, self);
		if(trace["fraction"] != 1)
		{
			if(isdefined(trace["entity"]) && trace["entity"] == who)
				return true;
			else
				return false;
		}
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
	defrosterfx = spawn("script_origin", player.origin + (0,0,40));

	if ( level.scr_ftag_showdefrostbeam )
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

	switch ( level.scr_ftag_unfreeze_button )
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
			ispressed = self buttonPressed(level.scr_ftag_unfreeze_button);
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

iconchecker(me)
{
	self notify("stopiconchecker");
	self endon("stopiconchecker");
	self endon("disconnect");

	trace = bulletTrace(me.origin + (0,0,10), self.origin + (0,0,10), false, undefined);
	while(isPlayer(self) && distance(self.origin, me.origin) <= level.defrostdist && self.sessionstate == "playing" && !self.frozen && trace["fraction"] == 1)
	{
		trace = bulletTrace(me.origin + (0,0,10), self.origin + (0,0,10), false, undefined);
		wait 0.05;
	}

	if(isDefined(self.defrosticon))
		self.defrosticon destroy();
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

isHeadShot( sWeapon, sHitLoc, sMeansOfDeath )
{
	return (sHitLoc == "head" || sHitLoc == "helmet") && sMeansOfDeath != "MOD_MELEE" && sMeansOfDeath != "MOD_IMPACT" && !isMG( sWeapon );
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

	thread timeLimitClock_Overtime( level.ftag_sd_time );
	wait (level.ftag_sd_time - 1);
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
	if( level.ftag_sd_spec != 1 || !isAlive(self) || !self.frozen || self.team == "spectator" )
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


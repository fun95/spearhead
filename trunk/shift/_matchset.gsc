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

SwitchTeams()
{
	tempscores = game["teamScores"]["allies"];
	game["teamScores"]["allies"] = game["teamScores"]["axis"];
	game["teamScores"]["axis"] = tempscores;
	level.mytitle = &"SHIFT_TEAM_SWITCH";

	for( i = 0; i < level.players.size; i++ )
	{
		newTeam = undefined;
		player = level.players[i];

		if(player.pers["team"] != "spectator")
		{
			player closeMenu();
			player closeInGameMenu();

			if(isAlive(player))
			{
				player.switching_teams = true;
				player.leaving_team = player.pers["team"];
				if( player.pers["team"] == "allies" )
				{
					newTeam = "axis";
				} else if( player.pers["team"] == "axis" ) {
					newTeam = "allies";
				}

				player unlink();
				player suicide();
				player.deaths--;
				player.pers["deaths"] --;	

				if (player.deaths <= 0 ) {
					player.deaths = 0; }
				if (player.pers["deaths"] <= 0 ) {
					player.pers["deaths"] = 0; }
				if ( level.teambased )
					player updateScores();
			}
			player.freezeorigin = undefined;
			player.freezeangles = undefined;
			player.frozen = false;
			player thread RemoveIceItems();
			player.joining_team = newTeam;
			player.team = newTeam;
			player.pers["team"] = newTeam;
			player.pers["savedmodel"] = undefined;
			player.sessionteam = newTeam;
			player setclientdvar("g_scriptMainMenu", game["menu_class"]);
			player notify("joined_team");
		}
		player thread showmymessage( level.mytitle );
		player playLocalSound( "UK_1mc_switching" );
	}
	return;
}


SetClanAsAllies()
{
	level.mytitle = &"SHIFT_TEAM_SWITCH_ALLIES";

	for( i = 0; i < level.players.size; i++ )
	{
		newTeam = undefined;
		player = level.players[i];

		if(player.pers["team"] != "spectator")
		{
			player closeMenu();
			player closeInGameMenu();
			if(isAlive(player))
			{
				player unlink();
				player suicide();
				player.deaths--;
				player.pers["deaths"] --;	

				if (player.deaths <= 0 ) {
					player.deaths = 0; }
				if (player.pers["deaths"] <= 0 ) {
					player.pers["deaths"] = 0; }
				if ( level.teambased )
					player updateScores();
				player.switching_teams = true;
				player.leaving_team = player.pers["team"];
			}

			// Check if this player is a clan member
			if ( player.isclanmember ) 
			{
				newTeam = "allies";
				player setClientDvars( "ui_force_allies", 1,
				                       "ui_force_axis", 0 );
			} else {
				newTeam = "axis";
				player setClientDvars( "ui_force_allies", 0,
				                       "ui_force_axis", 1 );
			}
			player.freezeorigin = undefined;
			player.freezeangles = undefined;
			player.frozen = false;
			player thread RemoveIceItems();
			player.joining_team = newTeam;
			player.team = newTeam;
			player.pers["team"] = newTeam;
			player.pers["savedmodel"] = undefined;
			player.sessionteam = newTeam;
			player setclientdvar("g_scriptMainMenu", game["menu_class"]);
			player notify("joined_team");
		}
		player thread showmymessage( level.mytitle );
		player playLocalSound( "UK_1mc_switching" );
	}
	return;
}


SetClanAsAxis()
{
	level.mytitle = &"SHIFT_TEAM_SWITCH_AXIS";

	for( i = 0; i < level.players.size; i++ )
	{
		newTeam = undefined;
		player = level.players[i];

		if(player.pers["team"] != "spectator")
		{
			player closeMenu();
			player closeInGameMenu();
			if(isAlive(player))
			{
				player unlink();
				player suicide();
				player.deaths--;
				player.pers["deaths"] --;	

				if (player.deaths <= 0 ) {
					player.deaths = 0; }
				if (player.pers["deaths"] <= 0 ) {
					player.pers["deaths"] = 0; }
				if ( level.teambased )
					player updateScores();
				player.switching_teams = true;
				player.leaving_team = player.pers["team"];
			}
	
			// Check if this player is a clan member
			if ( player.isclanmember ) 
			{
				newTeam = "axis";
				player setClientDvars( "ui_force_allies", 0,
				                       "ui_force_axis", 1 );
			} else {
				newTeam = "allies";
				player setClientDvars( "ui_force_allies", 1,
				                       "ui_force_axis", 0 );
			}
			player.freezeorigin = undefined;
			player.freezeangles = undefined;
			player.frozen = false;
			player thread RemoveIceItems();
			player.joining_team = newTeam;
			player.team = newTeam;
			player.pers["team"] = newTeam;
			player.pers["savedmodel"] = undefined;
			player.sessionteam = newTeam;
			player setclientdvar("g_scriptMainMenu", game["menu_class"]);
			player notify("joined_team");
		}
		player thread showmymessage( level.mytitle );
		player playLocalSound( "UK_1mc_switching" );
	}
	return;
}


showmymessage(mytitle)
{
	self endon ( "disconnect" );
	self notify ( "reset_outcome" );

	while ( self.doingNotify )
		wait 0.05;

	self endon ( "reset_outcome" );

	outcomeTitle = createFontString( "objective", 2 );
	outcomeTitle setPoint( "TOP", undefined, 0, 200 );
	outcomeTitle.glowAlpha = 1;
	outcomeTitle.hideWhenInMenu = false;
	outcomeTitle.archived = false;
	outcomeTitle.glowColor = (0.2, 0.3, 0.7);
	outcomeTitle setText( mytitle );
	outcomeTitle.color = (1, 1, 1);
	outcomeTitle setPulseFX( 80, 8000, 800 );
	self thread resetmyNotify( outcomeTitle );
}


resetmyNotify( outcomeTitle )
{
	self endon ( "disconnect" );
	self waittill ( "reset_outcome" );
	
	if ( isDefined( outcomeTitle ) )
		outcomeTitle destroyElem();
}


beginmatch()
{
	// return if already ending via host quit or victory
	if ( game["state"] == "postgame" || level.gameEnded )
		return;

	game["state"] = "postgame";
	level.gameEndTime = getTime();
	level.gameEnded = true;
	level.inGracePeriod = false;
	level notify ( "game_ended" );

	visionSetNaked( "mpOutro", 0 );
	setGameEndTime( 1 ); // stop/hide the timers

	level thread maps\mp\gametypes\_globallogic::updatePlacement();
	setdvar( "g_deadChat", 0 );

	// freeze players
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		player thread maps\mp\gametypes\_globallogic::freezePlayerForRoundEnd();
		player thread maps\mp\gametypes\_globallogic::roundEndDoF( 4.0 );
		player thread maps\mp\gametypes\_globallogic::freeGameplayHudElems();
		player setClientDvars( "cg_everyoneHearsEveryone", 1 );
		player thread ClearScoresMatch();

		if ( level.teambased )
		{
			[[level._setTeamScore]]("allies", 0 );
			[[level._setTeamScore]]("axis", 0 );
			maps\mp\gametypes\_globallogic::updateTeamScores( "axis", "allies" );
		}
	}

	// Create the HUD elements and wait for the timeout to be over to destroy them
	createHUDelements();

	game["scrim"]["announcelive"] = true;
	level notify ( "restarting" );
	game["state"] = "playing";
	map_restart( true );
	return;
}


createHUDelements()
{
	// Wait for countdown
	level thread maps\mp\gametypes\_globallogic::timeLimitClock_Intermission( level.scr_shift_gameplay["clock"] );
	gameStarts = gettime() + 1000 * level.scr_shift_gameplay["clock"];

	// Create the nice stop watch!
	stopWatch = NewHudElem();
	stopWatch.archived = false;
	stopWatch.hideWhenInMenu = true;
	stopWatch.alignX = "center";
	stopWatch.alignY = "bottom";
	stopWatch.horzAlign = "center";
	stopWatch.vertAlign = "middle";
	stopWatch.sort = 0;
	stopWatch.alpha = 1.0;
	stopWatch.x = 0;
	stopWatch.y = 20;
	stopWatch SetClock( level.scr_shift_gameplay["clock"] + 1, 60, "hudStopwatch", 96, 96 );

	//Create The Text For Match Starts In
	MatchTimerInText = createServerFontString( "objective", 2.4 );
	MatchTimerInText setPoint( "CENTER", "TOP", -40, 100 );
	MatchTimerInText setText( game["strings"]["match_starting_in"] );
	MatchTimerInText.color = ( 1, 1, 0 );
	MatchTimerInText.archived = false;
	MatchTimerInText.hideWhenInMenu = true;

	//Create The Text For Countdown
	MatchTimerInTime = createServerFontString( "objective", 2.4 );
	MatchTimerInTime setParent( MatchTimerInText );
	MatchTimerInTime setPoint( "CENTER", "LEFT", 170, 0 );
	MatchTimerInTime setTimer( level.scr_shift_gameplay["clock"] );
	MatchTimerInTime.color = ( 1, 1, 0 );
	MatchTimerInTime.archived = false;
	MatchTimerInTime.hideWhenInMenu = true;

	while ( gettime() < gameStarts )
		wait (0.05);

	stopWatch destroy();
	MatchTimerInTime destroyElem();
	MatchTimerInText destroyElem();
	return;
}


ClearScoresMatch()
{
	self closeMenu();
	self closeInGameMenu();

	self.pers["score"] = 0;	
	self.score = self.pers["score"];

	self.pers["deaths"] = 0;	
	self.deaths = self.pers["deaths"];

	self.pers["suicides"] = 0;	
	self.suicides = self.pers["suicides"];

	self.pers["kills"] = 0;	
	self.kills = self.pers["kills"];

	self.pers["headshots"] = 0;	
	self.headshots = self.pers["headshots"];

	self.pers["assists"] = 0;	
	self.assists = self.pers["assists"];

	self.pers["teamkills"] = 0;
	self.teamKillPunish = false;

	self.killedPlayers = [];
	self.killedPlayersCurrent = [];
	self.killedBy = [];

	self.leaderDialogQueue = [];
	self.leaderDialogActive = false;
	self.leaderDialogGroups = [];
	self.leaderDialogGroup = "";

	self.cur_kill_streak = 0;
	self.cur_death_streak = 0;
	self.death_streak = self maps\mp\gametypes\_persistence::statGet( "death_streak" );
	self.kill_streak = self maps\mp\gametypes\_persistence::statGet( "kill_streak" );
	self.lastGrenadeSuicideTime = -1;

	self.teamkillsThisRound = 0;

	self.pers["lives"] = level.numLives;

	self.deathCount = 0;

	if ( !isDefined( self.pers["team"] ) || self.pers["team"] == "spectator" )
		self [[level.spawnIntermission]]();

	return;
}

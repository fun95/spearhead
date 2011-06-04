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
	// Get the main module's dvar
	level.scr_allow_statusicons = getdvardefault( "scr_allow_statusicons", "int", 0 , 0, 2 );

	// If the statusicons is not enabled then there's nothing else to do here
	if ( level.scr_allow_statusicons == 0 )
		return;

	// Get member status from dvar
	level.scr_admin_names = getdvardefault( "scr_admin_names", "string", "" );
	level.scr_amember_names = getdvardefault( "scr_amember_names", "string", "" );
	level.scr_bmember_names = getdvardefault( "scr_bmember_names", "string", "" );
	level.scr_cmember_names = getdvardefault( "scr_cmember_names", "string", "" );

	precacheStatusIcon( "hud_status_amem" );  	//A Member
	precacheStatusIcon( "hud_status_bmem" );  	//B Member
	precacheStatusIcon( "hud_status_cmem" );  	//C Member
	precacheStatusIcon( "hud_status_marshal" );	//Administrator

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
		player thread onSpawnPlayer();
		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onPlayerKilled();
		player thread onPlayerDeath();
		player thread onPlayerMelt();
		player thread onUpdateTeamStatus();
		player thread getmemberstatus();
		player thread SetStatusIcon();
	}
}

onUpdateTeamStatus()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("updating_team_status");
		self thread SetStatusIcon();
	}
}

onSpawnPlayer()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned");
		self thread SetStatusIcon();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self thread SetStatusIcon();
	}
}

onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self thread SetStatusIcon();
	}
}

onJoinedSpectators()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_spectators");
		self thread SetStatusIcon();
	}
}

onPlayerKilled()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("killed_player");
		self thread SetStatusIcon();
	}
}

onPlayerDeath()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("death");
		self thread SetStatusIcon();
	}
}

onPlayerMelt()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("defrosted");
		self thread SetStatusIcon();
	}
}

SetStatusIcon()
{
	self endon("disconnect");

	if ( isdefined(level.scr_gameplay_ftag) && level.scr_gameplay_ftag && isdefined(self.frozen) && self.frozen )
		return;

	if ( !self.isadmin && level.scr_allow_statusicons == 2 )
	{
		if ( isdefined(self.isamember) && self.isamember )
			self.statusicon = "hud_status_amem";
		else if ( isdefined(self.isbmember) && self.isbmember )
			self.statusicon = "hud_status_bmem";
		else if ( isdefined(self.iscmember) && self.iscmember )
			self.statusicon = "hud_status_cmem";
	} 
	
	if ( self.isadmin ) 
		self.statusicon = "hud_status_marshal";

	return;
}

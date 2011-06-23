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
	// scr_shift_dvar = new values
	// Load the clan tags
	level.scr_clan_tags = ( getdvar( "scr_clan_tags" ) == "" );
	level.scr_clan_tags = strtok( level.scr_clan_tags, ";" );

	// Set new compact clan member values from single dvar
	level.scr_clan_member_status = getdvar( "scr_clan_member_status" );

	// If the statusicons is not enabled then there's nothing else to do here
	if ( !isdefined( level.scr_clan_member_status ) || level.scr_clan_member_status == "" ) 
		return;

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

	if ( isdefined( level.scr_shift_dvar["gpftag"] ) && level.scr_shift_dvar["gpftag"] && isdefined(self.frozen) && self.frozen )
		return;

	if ( self.isadmin ) 
		self.statusicon = "hud_status_marshal";
	else if ( isdefined(self.isamember) && self.isamember )
		self.statusicon = "hud_status_amem";
	else if ( isdefined(self.isbmember) && self.isbmember )
		self.statusicon = "hud_status_bmem";
	else if ( isdefined(self.iscmember) && self.iscmember )
		self.statusicon = "hud_status_cmem";

	return;
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
	level.scr_clan_member_status_guid = [];
	level.scr_clan_member_status_class = [];

	// Analyze the members and add them to the list
	for ( i=0; i < clanmembers.size; i++ ) {
		substring = strtok( clanmembers[i], "," );
		memberindex = level.scr_clan_member_status_guid.size;
		level.scr_clan_member_status_guid[memberindex] = substring[0];
		level.scr_clan_member_status_class[memberindex] = substring[1];
	}

	memberindex = 0;
	while ( memberindex < level.scr_clan_member_status_guid.size ) {
		if ( isDefined( level.scr_clan_member_status_guid[memberindex] ) && issubstr( level.scr_clan_member_status_guid[memberindex], self getGuid() ) ) {
			break;
		}
		memberindex++;
	}
	
	if ( memberindex == level.scr_clan_member_status_guid.size )
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

	setdvar( "ui_isadmin", self.isadmin );
	makeDvarServerInfo( "ui_isadmin" );

	return;
}
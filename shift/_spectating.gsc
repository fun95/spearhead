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

#include maps\mp\gametypes\_hud_util;
#include shift\_utils;

init()
{
	// If spectator score or Admin spec are not enabled then there's nothing else to do here
	if ( ( !isdefined( level.scr_shift_spectator["score"] ) || !level.scr_shift_spectator["score"] ) && ( !isdefined( level.scr_shift_spectator["freespec"] ) || !level.scr_shift_spectator["freespec"] ) && ( !isdefined( level.scr_shift_gameplay["join"] ) || !level.scr_shift_gameplay["join"] ) )
		return;

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player thread onJoinedTeam();
		player thread onJoinedSpectators();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self RemoveSpectateScore();
	}
}


onJoinedTeam()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("joined_team");
		self RemoveSpectateScore();
	}
}

onJoinedSpectators()
{
	self endon("disconnect");

	wait 5;

	for(;;)
	{
		if( isdefined( self.isadmin ) )
			break;
		wait 1;
	}

	for(;;)
	{
		self waittill("never_joined_team");
		self RemoveSpectateScore();
		if ( isdefined( level.scr_shift_gameplay["join"] ) && level.scr_shift_gameplay["join"] )
			self setSpectateMatch();
		if ( isdefined( level.scr_shift_spectator["score"] ) && level.scr_shift_spectator["score"] )
			self setSpectateScore();
		if ( isdefined( level.scr_shift_spectator["freespec"] ) && level.scr_shift_spectator["freespec"] == 2 )
			self setSpectateFree();
		else if ( isdefined( level.scr_shift_spectator["freespec"] ) && level.scr_shift_spectator["freespec"] == 1 && isdefined( self.isadmin ) && self.isadmin )
			self setSpectateFree();
	}
}

setSpectateFree()
{
	self allowSpectateTeam( "allies", true );
	self allowSpectateTeam( "axis", true );
	self allowSpectateTeam( "freelook", true );
	self allowSpectateTeam( "none", true );
}

setSpectateScore()
{
	self endon ( "disconnect" );
	
	self.leftIcon = createIcon( game["icons"]["allies"], 30, 30 );
	self.leftIcon setPoint( "CENTER", "TOP", -30, 55 );
	self.leftIcon.hideWhenInMenu = true;
	self.leftIcon.archived = false;
	self.leftIcon.alpha = 1;

	self.rightIcon = createIcon( game["icons"]["axis"], 30, 30 );
	self.rightIcon setPoint( "CENTER", "TOP", 30, 55 );
	self.rightIcon.hideWhenInMenu = true;
	self.rightIcon.archived = false;
	self.rightIcon.alpha = 1;

	self.leftScore = createFontString( "objective", 2.0 );
	self.leftScore setParent( self.leftIcon );
	self.leftScore setPoint( "RIGHT", "CENTER", -20, 0 );
	self.leftScore.glowColor = game["colors"]["allies"];
	self.leftScore.glowAlpha = 1;
	self.leftScore setValue( getTeamScore( "allies" ) );
	self.leftScore.hideWhenInMenu = true;
	self.leftScore.archived = false;

	self.rightScore = createFontString( "objective", 2.0 );
	self.rightScore setParent( self.rightIcon );
	self.rightScore setPoint( "LEFT", "CENTER", 20, 0 );
	self.rightScore.glowColor = game["colors"]["axis"];
	self.rightScore.glowAlpha = 1;
	self.rightScore setValue( getTeamScore( "axis" ) );
	self.rightScore.hideWhenInMenu = true;
	self.rightScore.archived = false;
}

setSpectateMatch()
{
	self.matchstatus = createFontString( "objective", 1.4 );
	self.matchstatus setPoint( "CENTER", "TOP", 0, 90 );
	self.matchstatus.glowColor = game["colors"]["allies"];
	self.matchstatus.glowAlpha = 1;
	self.matchstatus setText( game["scrim"]["status"] );
	self.matchstatus.hideWhenInMenu = true;
	self.matchstatus.archived = false;
}

RemoveSpectateScore()
{
	if ( isDefined( self.leftIcon ) )
		self.leftIcon destroyElem();
	if ( isDefined( self.rightIcon ) )
		self.rightIcon destroyElem();
	if ( isDefined( self.leftScore ) )
		self.leftScore destroyElem();
	if ( isDefined( self.rightScore ) )
		self.rightScore destroyElem();
	if ( isDefined( self.matchstatus ) )
		self.matchstatus destroyElem();
}

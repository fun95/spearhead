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
	// Get the main module's dvar
	level.scr_showscore_spectator = getdvardefault( "scr_showscore_spectator", "int", 0, 0, 1 );
	level.scr_allow_free_spectate = getdvardefault( "scr_allow_free_spectate", "int", 0, 0, 2 );

	// If spectator score or Admin spec are not enabled then there's nothing else to do here
	if ( level.scr_showscore_spectator == 0 && level.scr_allow_free_spectate == 0)
		return;

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		player thread getmemberstatus();
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

	for(;;)
	{
		self waittill("never_joined_team");
		self RemoveSpectateScore();
		if ( level.scr_showscore_spectator )
			self setSpectateScore();
		if ( level.scr_allow_free_spectate == 2 )
			self setSpectateFree();
		else if ( level.scr_allow_free_spectate == 1 && isdefined( self.isadmin ) && self.isadmin )
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
}

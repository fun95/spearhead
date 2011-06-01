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
	// Get the main module's dvar
	level.scr_show_unreal_messages = getdvarx( "scr_show_unreal_messages", "int", 0, 0, 2 );
	level.scr_unreal_headshot_sound = getdvarx( "scr_unreal_headshot_sound", "int", 0, 0, 1 );
	level.scr_unreal_firstblood_sound = getdvarx( "scr_unreal_firstblood_sound", "int", 0, 0, 1 );

	// If messages are disabled then there's nothing else to do here
	if ( level.scr_show_unreal_messages == 0 && level.scr_unreal_headshot_sound == 0 && level.scr_unreal_firstblood_sound == 0 )
		return;

	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("spawned_player");
		self thread waitForKill();
	}
}


waitForKill()
{
	self endon("disconnect");	
	
	// Wait for the player to die
	self waittill( "player_killed", eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );

	if( !isDefined( level.firstBloodmessage ) && isDefined(eAttacker) && isPlayer(eAttacker) && eAttacker != self && self.team != eAttacker.team)
	{
		level.firstBloodmessage = true;
		eAttacker.pers["firstblood"]++;

		players = level.players;
		for(i = 0; i < players.size; i++)
			if(players[i] != eAttacker && players[i].pers["team"] != "spectator")
				players[i] thread maps\mp\gametypes\_hud_message::oldNotifyMessage(&"SHIFT_FIRSTBLOOD_REPORT_ALL", eAttacker.name);

		eAttacker thread maps\mp\gametypes\_hud_message::oldNotifyMessage(&"SHIFT_FIRSTBLOOD_REPORT_SELF");
		eAttacker playLocalSound( "firstblood" );
	} else if(sMeansOfDeath == "MOD_HEAD_SHOT") {
		eAttacker thread maps\mp\gametypes\_hud_message::oldNotifyMessage( &"SHIFT_HEADSHOT" );
		eAttacker playLocalSound( "headshot" );
	}

	return;
}
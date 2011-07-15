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

#include shift\_utils;

init()
{
	// If messages are disabled then there's nothing else to do here
	if ( !isdefined( level.scr_shift_dvar["gpunreal"] ) || !level.scr_shift_dvar["gpunreal"] )
		return;

	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for (;;)
	{
		level waittill("connected", player);
		player thread onPlayerKilled();
	}
}


onPlayerKilled()
{
	self endon("disconnect");
	
	for(;;)
	{
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
	}
}

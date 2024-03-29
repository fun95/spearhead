//+----------------------------------------------------------------------------------------------------------------------------------+
//� Call of Duty 4: Modern Warfare                                                                                                   �
//�----------------------------------------------------------------------------------------------------------------------------------�
//� Mod                 : [SHIFT]SPEARHEAD INTERNATIONAL FREEZETAG                                                                   �
//� Modifications By    : [SHIFT]Newfie                                                                                              �
//+----------------------------------------------------------------------------------------------------------------------------------+
//� Colour Codes RGB    Colour Codes For Text                                                                                        �
//+----------------------------------------------------------------------------------------------------------------------------------+
//� Black  0 0 0        ^0 = Black                                                                                                   �
//� White  1 1 1        ^7 = White                                                                                                   �
//� Red    1 0 0        ^1 = Red                                                                                                     �
//� Green  0 1 0        ^2 = Green                                                                                                   �
//� Blue   0 0 1        ^4 = Blue                                                                                                    �
//� Yellow 1 1 0        ^3 = Yellow                                                                                                  �
//�                     ^5 = Cyan                                                                                                    �
//�                     ^6 = pink/Magenta                                                                                            �
//+----------------------------------------------------------------------------------------------------------------------------------+

#include shift\_utils;

init()
{
	if ( !isdefined( level.scr_shift_dvar["gpftag"] ) || !level.scr_shift_dvar["gpftag"] )
		return;

	if ( !isdefined( level.scr_shift_dvar["annoywarn"] ) || !level.scr_shift_dvar["annoywarn"] )
		return;

	if ( ( !isdefined( level.scr_shift_dvar["annoyknife"] ) || !level.scr_shift_dvar["annoyknife"] ) && ( !isdefined( level.scr_shift_dvar["annoyshots"] ) || !level.scr_shift_dvar["annoyshots"] ) )
		return;

	precacheString( &"SHIFT_FTAG_ALREADY_FROZEN_ANNOY" );
	precacheString( &"SHIFT_FTAG_ALREADY_FROZEN" );
	precacheString( &"SHIFT_FTAG_ALREADY_FROZEN2" );
	precacheString( &"SHIFT_FTAG_ALREADY_FROZEN3" );
	precacheString( &"SHIFT_FTAG_ALREADY_FROZEN4" );
	precacheString( &"SHIFT_FTAG_ALREADY_FROZEN5" );
	precacheString( &"SHIFT_FTAG_ALREADY_FROZEN6" );

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	self endon("disconnect");

	for(;;)
	{
		level waittill("connected", player);

		player thread onKilledPlayer();
		player thread onPlayerDamaged();
	}
}

onKilledPlayer()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("player_killed");	
		self.killtime = gettime();
	}
}

onPlayerDamaged()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill( "player_struck", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );

		if ( !isDefined(eAttacker) || !isPlayer(eAttacker) )
			continue;

		if ( !isdefined(eAttacker.knifekilltime) )
			eAttacker.knifekilltime = 0;
		if ( !isdefined(eAttacker.numberofknife) )
			eAttacker.numberofknife = 0;
		if ( !isdefined(eAttacker.numberofshots) )
			eAttacker.numberofshots = 0;

		if ( self.team != eAttacker.team && isdefined(self.frozen) && self.frozen && isdefined(self.killtime) ) {
			if ( gettime() - self.killtime >= level.scr_shift_dvar["annoytime"] ) {
				if ( sMeansOfDeath == "MOD_MELEE" && level.scr_shift_dvar["annoyknife"] > 0 ) {
					if ( gettime() - eAttacker.knifekilltime <= level.scr_shift_dvar["annoytime"] )
						eAttacker.numberofknife ++;
					else if ( eAttacker.knifekilltime == 0 )
						eAttacker.numberofknife ++;
					else
						eAttacker.numberofknife = 0;

					eAttacker.knifekilltime = gettime();
					if ( eAttacker.numberofknife >= level.scr_shift_dvar["annoyknife"] )
						self thread onPlayerEnemyAnnoy(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);
				} else if ( level.scr_shift_dvar["annoyshots"] > 0 ) {
					if(distance(eAttacker.origin, self.origin) <= level.scr_shift_dvar["annoydist"] ) {
						eAttacker.numberofshots ++;
						if ( eAttacker.numberofshots >= level.scr_shift_dvar["annoyshots"] )
							self thread onPlayerEnemyAnnoy(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);
					} else {
						eAttacker.numberofshots = 0;
					}
				}
			}				
		} else if ( self.team == eAttacker.team ) {
			if ( sMeansOfDeath == "MOD_MELEE" && level.scr_shift_dvar["annoyknife"] > 0 ) {
				if ( gettime() - eAttacker.knifekilltime <= level.scr_shift_dvar["annoytime"] )
					eAttacker.numberofknife ++;
				else if ( eAttacker.knifekilltime == 0 )
					eAttacker.numberofknife ++;
				else
					eAttacker.numberofknife = 0;

				eAttacker.knifekilltime = gettime();
				if ( eAttacker.numberofknife >= level.scr_shift_dvar["annoyknife"] )
					self thread onPlayerTeamAnnoy(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);
			} else if ( level.scr_shift_dvar["annoyshots"] > 0 ) {
				if(distance(eAttacker.origin, self.origin) <= level.scr_shift_dvar["annoydist"] ) {
					eAttacker.numberofshots ++;
						if ( eAttacker.numberofshots >= level.scr_shift_dvar["annoyshots"] )
							self thread onPlayerTeamAnnoy(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);
				} else {
					eAttacker.numberofshots = 0;
				}
			}
		}
	}
}

onPlayerEnemyAnnoy(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime)
{
	if (isdefined(self.isannoykill) && self.isannoykill)
		return;

	self.isannoykill = true;
	eAttacker iPrintlnBold(&"SHIFT_FTAG_ALREADY_FROZEN", self.name);
	eAttacker iPrintlnBold(&"SHIFT_FTAG_ALREADY_FROZEN2", self.name);
	self iPrintlnBold(&"SHIFT_FTAG_ALREADY_FROZEN5", eAttacker.name);
	self iPrintlnBold(&"SHIFT_FTAG_ALREADY_FROZEN6");

	eAttacker thread RemoveAnnoyPoints(eInflictor, self, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);
}

onPlayerTeamAnnoy(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime)
{
	if (isdefined(self.isannoykill) && self.isannoykill)
		return;

	self.isannoykill = true;
	eAttacker iPrintlnBold(&"SHIFT_FTAG_ALREADY_FROZEN3");
	eAttacker iPrintlnBold(&"SHIFT_FTAG_ALREADY_FROZEN4", self.name);
	self iPrintlnBold(&"SHIFT_FTAG_ALREADY_FROZEN5", eAttacker.name);
	self iPrintlnBold(&"SHIFT_FTAG_ALREADY_FROZEN6");

	eAttacker thread RemoveAnnoyPoints(eInflictor, self, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);
}

RemoveAnnoyPoints(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime)
{
	level.annoypointloss = maps\mp\gametypes\_rank::getScoreInfoValue( "kill" );
	self thread maps\mp\gametypes\_rank::giveRankXP( "annoy", level.annoypointloss );
	self.score -= level.annoypointloss;
	if (self.score <= 0 ) {
		self.score = 0; }
	self.pers["score"] -= level.annoypointloss;
	if (self.pers["score"] <= 0 ) {
		self.pers["score"] = 0; }

	self playLocalSound( "hahaha" );
	self.kills = self maps\mp\gametypes\_globallogic::getPersStat( "kills" );
	if (self.kills > 0 ) {
		self maps\mp\gametypes\_globallogic::incPersStat( "kills", -1 ); }
	self.kills = self maps\mp\gametypes\_globallogic::getPersStat( "kills" );
	self maps\mp\gametypes\_globallogic::updatePersRatio( "kdratio", "kills", "deaths" );

	self.numberofshots = 0;
	self.numberofknife = 0;

	eAttacker.isannoykill = false;
	iPrintln(&"SHIFT_FTAG_ALREADY_FROZEN_ANNOY" , self.name , eAttacker.name);

	if ( self.pers["team"] == eAttacker.pers["team"] ) {
		self maps\mp\gametypes\_globallogic::incPersStat( "deaths", 1 );
		self.deaths = self maps\mp\gametypes\_globallogic::getPersStat( "deaths" );
		self maps\mp\gametypes\_globallogic::updatePersRatio( "kdratio", "kills", "deaths" );

		self.cur_kill_streak = 0;
		self.cur_death_streak++;

		if ( self.cur_death_streak > self.death_streak )
		{
			self maps\mp\gametypes\_persistence::statSet( "death_streak", self.cur_death_streak );
			self.death_streak = self.cur_death_streak;
		}
	}

	self thread maps\mp\gametypes\_globallogic::Callback_Playerkilled(eInflictor, eAttacker, iDamage, "MOD_PISTOL_BULLET", "usp_silencer_mp", vDir, sHitLoc, psOffsetTime, 1916);
}
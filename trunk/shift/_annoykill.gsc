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
	level.scr_ftag_annoy_warn = getdvardefault("scr_ftag_annoy_warn","int",1,0,1);
	level.scr_ftag_annoy_safezone = getdvardefault("scr_ftag_annoy_safezone","int",4000,1,999999);
	level.ftag_annoy_knife = getdvardefault("scr_ftag_annoy_knife","int",2,0,999999);
	level.ftag_annoy_dist = getdvardefault("scr_ftag_annoy_dist","int",200,1,999999);
	level.ftag_annoy_shots = getdvardefault("scr_ftag_annoy_shots","int",15,0,999999);

	if ( !isdefined(level.scr_gameplay_ftag) || !level.scr_gameplay_ftag )
		return;

	if ( !isdefined(level.scr_ftag_annoy_warn) || !level.scr_ftag_annoy_warn )
		return;

	if ( level.ftag_annoy_knife == 0 && level.ftag_annoy_shots == 0 )
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
			if ( gettime() - self.killtime >= level.scr_ftag_annoy_safezone ) {
				if ( sMeansOfDeath == "MOD_MELEE" && level.ftag_annoy_knife > 0 ) {
					if ( gettime() - eAttacker.knifekilltime <= level.scr_ftag_annoy_safezone )
						eAttacker.numberofknife ++;
					else if ( eAttacker.knifekilltime == 0 )
						eAttacker.numberofknife ++;
					else
						eAttacker.numberofknife = 0;

					eAttacker.knifekilltime = gettime();
					if ( eAttacker.numberofknife >= level.ftag_annoy_knife )
						self thread onPlayerEnemyAnnoy(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);
				} else if ( level.ftag_annoy_shots > 0 ) {
					if(distance(eAttacker.origin, self.origin) <= level.ftag_annoy_dist ) {
						eAttacker.numberofshots ++;
						if ( eAttacker.numberofshots >= level.ftag_annoy_shots )
							self thread onPlayerEnemyAnnoy(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);
					} else {
						eAttacker.numberofshots = 0;
					}
				}
			}				
		} else if ( self.team == eAttacker.team ) {
			if ( sMeansOfDeath == "MOD_MELEE" && level.ftag_annoy_knife > 0 ) {
				if ( gettime() - eAttacker.knifekilltime <= level.scr_ftag_annoy_safezone )
					eAttacker.numberofknife ++;
				else if ( eAttacker.knifekilltime == 0 )
					eAttacker.numberofknife ++;
				else
					eAttacker.numberofknife = 0;

				eAttacker.knifekilltime = gettime();
				if ( eAttacker.numberofknife >= level.ftag_annoy_knife )
					self thread onPlayerTeamAnnoy(eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime);
			} else if ( level.ftag_annoy_shots > 0 ) {
				if(distance(eAttacker.origin, self.origin) <= level.ftag_annoy_dist ) {
					eAttacker.numberofshots ++;
						if ( eAttacker.numberofshots >= level.ftag_annoy_shots )
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
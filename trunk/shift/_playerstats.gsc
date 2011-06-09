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
	if ( !isdefined( level.scr_shift_hud["stats"] ) || !level.scr_shift_hud["stats"] )
		return;

	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
		player thread onPlayerKilled();
	}
}


onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");
		self thread statsonuse();
	}
}


onPlayerKilled()
{
	self endon("disconnect");
	
	for(;;)
	{
		self waittill( "player_killed", eInflictor, eAttacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );

		if(sMeansOfDeath == "MOD_GRENADE_SPLASH")
			eAttacker.pers["grenadekill"]++;
		if(sMeansOfDeath == "MOD_MELEE")
			eAttacker.pers["knifekill"]++;
	}
}


statsonuse()
{
	self endon("disconnect");
	self endon("death");
	self endon( "game_ended" );
	self endon("joined_spectators");

	level.ex_hudstatsuse_xpos = 630;
	level.ex_hudstatsuse_ypos = 130;

	if(!isDefined(self.pers["score"])) self.pers["score"] = 0; 
	if(!isDefined(self.pers["defrost"])) self.pers["defrost"] = 0; 
	if(!isDefined(self.cur_kill_streak)) self.cur_kill_streak = 0; 
	if(!isDefined(self.pers["firstblood"])) self.pers["firstblood"] = 0; 
	if(!isDefined(self.pers["headshots"])) self.pers["headshots"] = 0;
	if(!isDefined(self.pers["knifekill"])) self.pers["knifekill"] = 0;
	if(!isDefined(self.pers["grenadekill"])) self.pers["grenadekill"] = 0;
  
	while(isAlive(self))
	{
		wait (0.05);

		if(self useButtonPressed())
		{
			if(!isdefined(self.hud_statsscore))
			{
				self.hud_statsscore = newClientHudElem(self);
				self.hud_statsscore.x = level.ex_hudstatsuse_xpos;
				self.hud_statsscore.y = level.ex_hudstatsuse_ypos;
				self.hud_statsscore.alignx = "right";
				self.hud_statsscore.aligny = "middle";
				self.hud_statsscore.horzAlign = "fullscreen";
				self.hud_statsscore.vertAlign = "fullscreen";
				self.hud_statsscore.alpha =0.8;
				self.hud_statsscore.fontScale = 1.4;
			}
			self.hud_statsscore.label = &"SHIFT_HUD_SCORE";
			self.hud_statsscore setvalue(self.pers["score"]);

			if(!isdefined(self.hud_statsdefrost))
			{
				self.hud_statsdefrost = newClientHudElem(self);
				self.hud_statsdefrost.x = level.ex_hudstatsuse_xpos;
				self.hud_statsdefrost.y = level.ex_hudstatsuse_ypos + 16;
				self.hud_statsdefrost.alignx = "right";
				self.hud_statsdefrost.aligny = "middle";
				self.hud_statsdefrost.horzAlign = "fullscreen";
				self.hud_statsdefrost.vertAlign = "fullscreen";
				self.hud_statsdefrost.alpha =0.8;
				self.hud_statsdefrost.fontScale = 1.4;
			}
			self.hud_statsdefrost.label = &"SHIFT_HUD_DEFROST";
			self.hud_statsdefrost setvalue(self.pers["defrost"]);

			if(!isdefined(self.hud_statskstreak))
			{
				self.hud_statskstreak = newClientHudElem(self);
				self.hud_statskstreak.x = level.ex_hudstatsuse_xpos;
				self.hud_statskstreak.y = level.ex_hudstatsuse_ypos + 32;
				self.hud_statskstreak.alignx = "right";
				self.hud_statskstreak.aligny = "middle";
				self.hud_statskstreak.horzAlign = "fullscreen";
				self.hud_statskstreak.vertAlign = "fullscreen";
				self.hud_statskstreak.alpha =0.8;
				self.hud_statskstreak.fontScale = 1.4;
			}
			self.hud_statskstreak.label = &"SHIFT_HUD_KILLSTREAK";
			self.hud_statskstreak setvalue(self.cur_kill_streak);

			if(!isdefined(self.hud_statsblood))
			{
				self.hud_statsblood = newClientHudElem(self);
				self.hud_statsblood.x = level.ex_hudstatsuse_xpos;
				self.hud_statsblood.y = level.ex_hudstatsuse_ypos + 48;
				self.hud_statsblood.alignx = "right";
				self.hud_statsblood.aligny = "middle";
				self.hud_statsblood.horzAlign = "fullscreen";
				self.hud_statsblood.vertAlign = "fullscreen";
				self.hud_statsblood.alpha =0.8;
				self.hud_statsblood.fontScale = 1.4;
				self.hud_statsblood.color = (1, 0, 0);
			}
			self.hud_statsblood.label = &"SHIFT_HUD_BLOOD";
			self.hud_statsblood setvalue(self.pers["firstblood"]);

			if(!isdefined(self.hud_statshead))
			{
				self.hud_statshead = newClientHudElem(self);
				self.hud_statshead.x = level.ex_hudstatsuse_xpos;
				self.hud_statshead.y = level.ex_hudstatsuse_ypos + 64;
				self.hud_statshead.alignx = "right";
				self.hud_statshead.aligny = "middle";
				self.hud_statshead.horzAlign = "fullscreen";
				self.hud_statshead.vertAlign = "fullscreen";
				self.hud_statshead.alpha =0.8;
				self.hud_statshead.fontScale = 1.4;
				self.hud_statshead.color = (1, 0, 0);
			}
			self.hud_statshead.label = &"SHIFT_HUD_HEADSHOTS";
			self.hud_statshead setvalue(self.pers["headshots"]);

			if(!isdefined(self.hud_statsknife))
			{
				self.hud_statsknife = newClientHudElem(self);
				self.hud_statsknife.x = level.ex_hudstatsuse_xpos;
				self.hud_statsknife.y = level.ex_hudstatsuse_ypos + 80;
				self.hud_statsknife.alignx = "right";
				self.hud_statsknife.aligny = "middle";
				self.hud_statsknife.horzAlign = "fullscreen";
				self.hud_statsknife.vertAlign = "fullscreen";
				self.hud_statsknife.alpha =0.8;
				self.hud_statsknife.fontScale = 1.4;
				self.hud_statsknife.color = (1, 0, 0);
			}
			self.hud_statsknife.label = &"SHIFT_HUD_KNIFE";
			self.hud_statsknife setvalue(self.pers["knifekill"]);

			if(!isdefined(self.hud_statsnade))
			{
				self.hud_statsnade = newClientHudElem(self);
				self.hud_statsnade.x = level.ex_hudstatsuse_xpos;
				self.hud_statsnade.y = level.ex_hudstatsuse_ypos + 96;
				self.hud_statsnade.alignx = "right";
				self.hud_statsnade.aligny = "middle";
				self.hud_statsnade.horzAlign = "fullscreen";
				self.hud_statsnade.vertAlign = "fullscreen";
				self.hud_statsnade.alpha =0.8;
				self.hud_statsnade.fontScale = 1.4;
				self.hud_statsnade.color = (1, 0, 0);
			}
			self.hud_statsnade.label = &"SHIFT_HUD_NADE";
			self.hud_statsnade setvalue(self.pers["grenadekill"]);
		}
		else
		{
			if(isDefined(self.hud_statsscore)) self.hud_statsscore destroy(); 
			if(isDefined(self.hud_statsdefrost)) self.hud_statsdefrost destroy(); 
			if(isDefined(self.hud_statskstreak)) self.hud_statskstreak destroy(); 
			if(isDefined(self.hud_statsblood)) self.hud_statsblood destroy(); 
			if(isDefined(self.hud_statshead)) self.hud_statshead destroy();
			if(isDefined(self.hud_statsknife)) self.hud_statsknife destroy();
			if(isDefined(self.hud_statsnade)) self.hud_statsnade destroy();
		}
	}
}
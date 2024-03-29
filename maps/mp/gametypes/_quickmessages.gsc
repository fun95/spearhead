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

init()
{
	game["menu_quickcommands"] = "quickcommands";
	game["menu_quickstatements"] = "quickstatements";
	game["menu_quickresponses"] = "quickresponses";
	precacheMenu(game["menu_quickcommands"]);
	precacheMenu(game["menu_quickstatements"]);
	precacheMenu(game["menu_quickresponses"]);
	precacheHeadIcon("talkingicon");

	game["menu_shiftquickcommands"] = "shiftquickcommands";
	game["menu_shiftquickstatements"] = "shiftquickstatements";
	game["menu_shiftquickresponses"] = "shiftquickresponses";
	precacheMenu(game["menu_shiftquickcommands"]);
	precacheMenu(game["menu_shiftquickstatements"]);
	precacheMenu(game["menu_shiftquickresponses"]);
}

quickcommands(response)
{
	self endon ( "disconnect" );
	
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;
	
	switch(response)		
	{
		case "1":
			soundalias = "mp_cmd_followme";
			saytext = &"QUICKMESSAGE_FOLLOW_ME";
			//saytext = "Follow Me!";
			break;

		case "2":
			soundalias = "mp_cmd_movein";
			saytext = &"QUICKMESSAGE_MOVE_IN";
			//saytext = "Move in!";
			break;

		case "3":
			soundalias = "mp_cmd_fallback";
			saytext = &"QUICKMESSAGE_FALL_BACK";
			//saytext = "Fall back!";
			break;

		case "4":
			soundalias = "mp_cmd_suppressfire";
			saytext = &"QUICKMESSAGE_SUPPRESSING_FIRE";
			//saytext = "Suppressing fire!";
			break;

		case "5":
			soundalias = "mp_cmd_attackleftflank";
			saytext = &"QUICKMESSAGE_ATTACK_LEFT_FLANK";
			//saytext = "Attack left flank!";
			break;

		case "6":
			soundalias = "mp_cmd_attackrightflank";
			saytext = &"QUICKMESSAGE_ATTACK_RIGHT_FLANK";
			//saytext = "Attack right flank!";
			break;

		case "7":
			soundalias = "mp_cmd_holdposition";
			saytext = &"QUICKMESSAGE_HOLD_THIS_POSITION";
			//saytext = "Hold this position!";
			break;

		default:
			assert(response == "8");
			soundalias = "mp_cmd_regroup";
			saytext = &"QUICKMESSAGE_REGROUP";
			//saytext = "Regroup!";
			break;
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();	
}

quickstatements(response)
{
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;
	
	switch(response)		
	{
		case "1":
			soundalias = "mp_stm_enemyspotted";
			saytext = &"QUICKMESSAGE_ENEMY_SPOTTED";
			//saytext = "Enemy spotted!";
			break;

		case "2":
			soundalias = "mp_stm_enemiesspotted";
			saytext = &"QUICKMESSAGE_ENEMIES_SPOTTED";
			//saytext = "Enemy down!";
			break;

		case "3":
			soundalias = "mp_stm_iminposition";
			saytext = &"QUICKMESSAGE_IM_IN_POSITION";
			//saytext = "I'm in position.";
			break;

		case "4":
			soundalias = "mp_stm_areasecure";
			saytext = &"QUICKMESSAGE_AREA_SECURE";
			//saytext = "Area secure!";
			break;

		case "5":
			soundalias = "mp_stm_watchsix";
			saytext = &"QUICKMESSAGE_WATCH_SIX";
			//saytext = "Grenade!";
			break;

		case "6":
			soundalias = "mp_stm_sniper";
			saytext = &"QUICKMESSAGE_SNIPER";
			//saytext = "Sniper!";
			break;

		default:
			assert(response == "7");
			soundalias = "mp_stm_needreinforcements";
			saytext = &"QUICKMESSAGE_NEED_REINFORCEMENTS";
			//saytext = "Need reinforcements!";
			break;
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

quickresponses(response)
{
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	switch(response)		
	{
		case "1":
			soundalias = "mp_rsp_yessir";
			saytext = &"QUICKMESSAGE_YES_SIR";
			//saytext = "Yes Sir!";
			break;

		case "2":
			soundalias = "mp_rsp_nosir";
			saytext = &"QUICKMESSAGE_NO_SIR";
			//saytext = "No Sir!";
			break;

		case "3":
			soundalias = "mp_rsp_onmyway";
			saytext = &"QUICKMESSAGE_IM_ON_MY_WAY";
			//saytext = "On my way.";
			break;

		case "4":
			soundalias = "mp_rsp_sorry";
			saytext = &"QUICKMESSAGE_SORRY";
			//saytext = "Sorry.";
			break;

		case "5":
			soundalias = "mp_rsp_greatshot";
			saytext = &"QUICKMESSAGE_GREAT_SHOT";
			//saytext = "Great shot!";
			break;

		default:
			assert(response == "6");
			soundalias = "mp_rsp_comeon";
			saytext = &"QUICKMESSAGE_COME_ON";
			//saytext = "Took long enough!";
			break;
	}

	self saveHeadIcon();
	self doQuickMessage(soundalias, saytext);

	wait 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

shiftquickcommands(response)
{
	self endon ( "disconnect" );
	
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;
	
	switch(response)		
	{
		case "1":
			soundalias = "attack";
			saytext = &"SHIFT_ATTACK";
			break;

		case "2":
			soundalias = "coverme";
			saytext = &"SHIFT_COVER_ME";
			break;

		case "3":
			soundalias = "icoveru";
			saytext = &"SHIFT_I_COVER_YOU";
			break;

		case "4":
			soundalias = "squadcoverfire";
			saytext = &"SHIFT_COVERING_FIRE";
			break;

		case "5":
			soundalias = "grenadetakecover";
			saytext = &"SHIFT_GRENADE";
			break;

		case "6":
			soundalias = "followme";
			saytext = &"SHIFT_FOLLOW_ME";
			break;

		case "7":
			soundalias = "openfire";
			saytext = &"SHIFT_OPEN_FIRE";
			break;

		case "8":
			soundalias = "youtakepoint";
			saytext = &"SHIFT_TAKE_POINT";
			break;

		default:
			assert(response == "9");
			soundalias = "moveonsig";
			saytext = &"SHIFT_MOVE_SIGNAL";
			break;
	}

	self saveHeadIcon();
	self doQUICKMESSAGE(soundalias, saytext);

	wait 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();	
}

shiftquickstatements(response)
{
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	switch(response)		
	{
		case "1":
			soundalias = "allyougot";
			saytext = &"SHIFT_ALL_YOU_GOT";
			break;

		case "2":
			soundalias = "backaftertargetpractice";
			saytext = &"SHIFT_TARGET_PRACTICE";
			break;

		case "3":
			soundalias = "comepreparednext";
			saytext = &"SHIFT_COME_PREPARED";
			break;

		case "4":
			soundalias = "cowards";
			saytext = &"SHIFT_COWARDS";
			break;

		case "5":
			soundalias = "runyellowbelly";
			saytext = &"SHIFT_RUN_YELLOW";
			break;

		case "6":
			soundalias = "wherehiding";
			saytext = &"SHIFT_HIDING";
			break;

		case "7":
			soundalias = "whowantsmore";
			saytext = &"SHIFT_WANTS_MORE";
			break;

		case "8":
			soundalias = "tooeasy";
			saytext = &"SHIFT_TOO_EASY";
			break;

		default:
			assert(response == "9");
			soundalias = "messbest";
			saytext = &"SHIFT_MESS_BEST";
			break;
	}

	self saveHeadIcon();
	self doQuickMessageForAll(soundalias, saytext);

	wait 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

shiftquickresponses(response)
{
	if(!isdefined(self.pers["team"]) || self.pers["team"] == "spectator" || isdefined(self.spamdelay))
		return;

	self.spamdelay = true;

	switch(response)		
	{
		case "1":
			soundalias = "yessir";
			saytext = &"SHIFT_YES_SIR";
			break;

		case "2":
			soundalias = "nosir";
			saytext = &"SHIFT_NO_SIR";
			break;

		case "3":
			soundalias = "thanks";
			saytext = &"SHIFT_THANKS";
			break;

		case "4":
			soundalias = "ioweyouone";
			saytext = &"SHIFT_I_OWE_YOU";
			break;

		case "5":
			soundalias = "goodjob";
			saytext = &"SHIFT_GOOD_JOB";
			break;

		case "6":
			soundalias = "doneit";
			saytext = &"SHIFT_DONE_IT";
			break;

		case "7":
			soundalias = "fireneedhelp";
			saytext = &"SHIFT_TAKING_FIRE";
			break;

		case "8":
			soundalias = "enemyspot";
			saytext = &"SHIFT_ENEMY_SPOTTED";
			break;

		default:
			assert(response == "9");
			soundalias = "wooohoo";
			saytext = &"SHIFT_WOOHOO";
			break;
	}

	self saveHeadIcon();
	self doQUICKMESSAGE(soundalias, saytext);

	wait 2;
	self.spamdelay = undefined;
	self restoreHeadIcon();
}

doQuickMessage( soundalias, saytext )
{
	if(self.sessionstate != "playing")
		return;

	if ( self.pers["team"] == "allies" )
	{
		if ( game["allies"] == "sas" )
			prefix = "UK_";
		else
			prefix = "US_";
	}
	else
	{
		if ( game["axis"] == "russian" )
			prefix = "RU_";
		else
			prefix = "AB_";
	}

	if(isdefined(level.QuickMessageToAll) && level.QuickMessageToAll)
	{
		self.headiconteam = "none";
		self.headicon = "talkingicon";

		self playSound( prefix+soundalias );
		self sayAll(saytext);
	}
	else
	{
		if(self.sessionteam == "allies")
			self.headiconteam = "allies";
		else if(self.sessionteam == "axis")
			self.headiconteam = "axis";
		
		self.headicon = "talkingicon";

		self playSound( prefix+soundalias );
		self sayTeam( saytext );
		self pingPlayer();
	}
}

doQuickMessageForAll( soundalias, saytext )
{
	if(self.sessionstate != "playing")
		return;

	if ( self.pers["team"] == "allies" )
	{
		if ( game["allies"] == "sas" )
			prefix = "UK_";
		else
			prefix = "US_";
	}
	else
	{
		if ( game["axis"] == "russian" )
			prefix = "RU_";
		else
			prefix = "AB_";
	}

	self.headiconteam = "none";
	self.headicon = "talkingicon";

	self playSound( prefix+soundalias );
	self sayAll(saytext);
}

saveHeadIcon()
{
	if(isdefined(self.headicon))
		self.oldheadicon = self.headicon;

	if(isdefined(self.headiconteam))
		self.oldheadiconteam = self.headiconteam;
}

restoreHeadIcon()
{
	if(isdefined(self.oldheadicon))
		self.headicon = self.oldheadicon;

	if(isdefined(self.oldheadiconteam))
		self.headiconteam = self.oldheadiconteam;
}
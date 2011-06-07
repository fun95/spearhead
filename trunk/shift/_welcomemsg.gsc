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
	if ( !isdefined( level.scr_shift_hud["welcome"] ) || !level.scr_shift_hud["welcome"] )
		return;

	if ( !isdefined( level.scr_shift_hud["delay"] ) || !level.scr_shift_hud["delay"] )
		return;

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill("spawned_player");

		if ( game["state"] != "postgame" )
			self thread displaywelcomeMsg();
	}
}

displaywelcomeMsg()
{
	if ( !isDefined(self.pers["welcomeMsgDone"]) )
	{
		wait level.scr_shift_hud["delay"];
		self thread welcomeMsg();
		while (!isDefined(self.pers["welcomeMsgDone"]))
			wait .50;
	}
}

welcomeMsg()
{
	wait .50;
	self iprintlnbold( level.scr_shift_hud["welcome"] + ", " + self.name );
	self.pers["welcomeMsgDone"] = true;
}

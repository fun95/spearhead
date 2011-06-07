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
	level.svr_welcome_msg_delay = getdvardefault( "svr_welcome_msg_delay", "int", 1, 1, 60 );
	level.svr_welcome_msg = getdvardefault( "svr_welcome_msg", "string", undefined, undefined, undefined);
	level.scr_welcome_at_start = getdvardefault( "scr_welcome_at_start", "int", 0, 0, 2 );

	if ( level.scr_welcome_at_start == 0 )
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
	if (level.svr_welcome_msg_delay && !isDefined(self.pers["welcomeMsgDone"]))
	{
		wait level.svr_welcome_msg_delay;
		self thread welcomeMsg();
		while (!isDefined(self.pers["welcomeMsgDone"]))
			wait .50;
	}
}

welcomeMsg()
{
	wait .50;
	if (level.svr_welcome_msg != "")
		self iprintlnbold(level.svr_welcome_msg + ", " + self.name);
	self.pers["welcomeMsgDone"] = true;
}

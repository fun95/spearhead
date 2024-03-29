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
	game["menu_clientcmd"] = "clientcmd";
	precacheMenu( game["menu_clientcmd"] );

	game["menu_shiftrcon"] = "shiftrcon";
	precacheMenu(game["menu_shiftrcon"]);

	game["menu_shiftqmcmd"] = "shiftqmcmd";
	game["menu_shiftqmstm"] = "shiftqmstm";
	game["menu_shiftqmres"] = "shiftqmres";
	precacheMenu(game["menu_shiftqmres"]);
	precacheMenu(game["menu_shiftqmstm"]);
	precacheMenu(game["menu_shiftqmcmd"]);

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onMenuResponse();
	}
}

onMenuResponse()
{
	self endon("disconnect");

	for(;;)
	{
		self waittill( "menuresponse", menu, response);

		if(menu == game["menu_shiftqmcmd"])
			self openMenu( game["menu_shiftqmcmd"] );
		else if(menu == game["menu_shiftqmstm"])
			self openMenu( game["menu_shiftqmstm"] );
		else if(menu == game["menu_shiftqmres"])
			self openMenu( game["menu_shiftqmres"] );

		else if ( !level.console )
		{
			if(menu == game["menu_shiftquickcommands"])
				maps\mp\gametypes\_quickmessages::shiftquickcommands(response);
			else if(menu == game["menu_shiftquickstatements"])
				maps\mp\gametypes\_quickmessages::shiftquickstatements(response);
			else if(menu == game["menu_shiftquickresponses"])
				maps\mp\gametypes\_quickmessages::shiftquickresponses(response);
		}

		if( !isdefined( self.isadmin ) || !self.isadmin )
			continue;

		if ( !isdefined ( self.loggedin ) || !self.loggedin )
			self thread AdminLogin();

		if(  menu == game["menu_shiftrcon"] )
		{
			switch( response )
			{
				case "openmenu":
					self openMenu( game["menu_shiftrcon"] );
					break;		
				default:
					break;
			}
		}
	}
}
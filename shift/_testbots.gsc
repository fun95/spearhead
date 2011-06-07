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
	//Added by [SHIFT]
	level.scr_allow_testclients = getDvarInt( "scr_allow_testclients" );
  
	if ( !level.scr_allow_testclients )
  		return;
  	
  level thread addTestClients();
}


addTestClients()
{
	wait 5;
	
	for (;;) {
		wait (1);
		
		testClients = getdvarInt( "scr_testclients" );
		if ( !testClients )
			continue;
			
		setDvar( "scr_testclients", 0 );
		
		for( i = 0; i < testClients; i++ )	{
			newBot = addTestClient();
	
			if ( !isdefined( newBot ) ) {
				println( "Could not add test client" );
				wait 1;
				break;
			}
				
			newBot.pers["isBot"] = true;
			newBot thread initBotClass();
		}
	}
}


initBotClass()
{
	self endon( "disconnect" );

	while( !isDefined( self.pers ) || !isDefined( self.pers["team"] ) )
		wait(1);
		
	self notify( "menuresponse", game["menu_team"], "autoassign" );

	while( self.pers["team"] == "spectator" )
		wait(1);

	if ( !level.oldschool )	{
		if ( level.rankedMatch ) {
			self notify( "menuresponse", game["menu_changeclass"], "assault_mp" );			
		} else {		
			self notify( "menuresponse", game["menu_changeclass_" + self.pers["team"] ], "assault" );
			wait(1);
			self notify( "menuresponse", game["menu_changeclass"] , "go" );
		}
	}
}
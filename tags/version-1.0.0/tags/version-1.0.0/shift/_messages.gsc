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
#include maps\mp\gametypes\_hud_util;

init()
{
	if ( ( !isdefined( level.scr_shift_server_messages["messages"] ) || !level.scr_shift_server_messages["messages"] ) && ( !isdefined( level.scr_shift_banner_messages["messages"] ) || !level.scr_shift_banner_messages["messages"] ) )
		return;

	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
	{
		level waittill("connecting", player);

		if( isdefined( level.scr_shift_server_messages["messages"] ) && level.scr_shift_server_messages["messages"] && level.scr_shift_server_messages.size > 2 )
			player thread displayServerMessages();
		if( isdefined( level.scr_shift_banner_messages["messages"] ) && level.scr_shift_banner_messages["messages"] && level.scr_shift_banner_messages.size > 2 )
			player thread displayServerBanners();
	}
}


displayServerMessages()
{
	self endon("disconnect");
	MsgIndex = 2;
	
	for(;;)
	{
		wait(0.05);
		
		while ( MsgIndex < level.scr_shift_server_messages.size ) {
			self iPrintLn( level.scr_shift_server_messages[ MsgIndex ] );
			MsgIndex++;
			wait( level.scr_shift_server_messages["msgdelay"] );
		}

		if ( MsgIndex == level.scr_shift_server_messages.size )
			MsgIndex = 2;
	}
}


displayServerBanners() {
	self endon("disconnect");

	// Create the new HUD element
	if ( isDefined( self.hud_server_banner ) )
		self.hud_server_banner destroy();

	self.hud_server_banner = createFontString( "default", 1.4 );
	self.hud_server_banner setPoint( "CENTER", "BOTTOM", 0, -8 );
	self.hud_server_banner.archived = false;
	self.hud_server_banner.hideWhenInMenu = true;
	self.hud_server_banner.alpha = 0;

	BanIndex = 2;
	
	for(;;)
	{
		wait(0.05);
		
		while ( BanIndex < level.scr_shift_banner_messages.size ) {
			self.hud_server_banner setText( level.scr_shift_banner_messages[ BanIndex ] );
			self.hud_server_banner fadeOverTime(1);
			self.hud_server_banner.alpha = 1;

			wait ( level.scr_shift_banner_messages["msgdelay"] / 2 );

			self.hud_server_banner fadeOverTime(1);
			self.hud_server_banner.alpha = 0;
	
			wait ( level.scr_shift_banner_messages["msgdelay"] / 2 );
			BanIndex++;
		}

		if ( BanIndex == level.scr_shift_banner_messages.size )
			BanIndex = 2;
	}
}

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

#include maps\mp\_utility;

init()
{
	// If healthpacks are disabled then there's nothing else to do here
	if ( !isdefined( level.scr_shift_dvar["gphealth"] ) || !level.scr_shift_dvar["gphealth"] )
		return;

	if ( level.hardcoreMode )
		level.HPIncrease = 15;
	else if ( level.oldschool )
		level.HPIncrease = 50;
	else
		level.HPIncrease = 25;

	precacheModel( "hp_medium" );
	level thread onPlayerConnect();
}


onPlayerConnect()
{
	for(;;)
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
		self waittill("death");
		self thread leaveHealthPack();
	}
}


leaveHealthPack()
{
	// Get the victim's origin
	playerOrigin = (self.origin + (50,0,0));

	// Calculate the position and angles to spawn this healthpack
	trace = playerPhysicsTrace( playerOrigin + (0,0,20), playerOrigin - (0,0,2000), false, self.body );
	angleTrace = bulletTrace( playerOrigin + (0,0,20), playerOrigin - (0,0,2000), false, self.body );
	tempAngle = randomfloat( 360 );
	dropOrigin = trace;
	if ( angleTrace["fraction"] < 1 && distance( angleTrace["position"], trace ) < 10.0 )
	{
		forward = (cos( tempAngle ), sin( tempAngle ), 0);
		forward = vectornormalize( forward - vector_scale( angleTrace["normal"], vectordot( forward, angleTrace["normal"] ) ) );
		dropAngles = vectortoangles( forward );
	}
	else
	{
		dropAngles = ( 0, tempAngle, 0);
	}
		
	HPTrigger = spawn( "trigger_radius", dropOrigin, 0, 10, 2 );
	HPModel = spawn( "script_model", dropOrigin );
	HPModel.angles = dropAngles;
	HPModel setModel( "hp_medium" );

	HPTrigger thread waitForPickUp( HPModel );
	HPTrigger thread HPTimedout( HPModel );
}


waitForPickUp( HPModel )
{
	self endon("death");

	HPClaimed = false;

	for (;;)
	{
		self waittill ( "trigger", player );

		if( player.health >= player.maxhealth || HPClaimed || isdefined( self.frozen ) && self.frozen )
			continue;

		HPClaimed = true;

		if ( player.health + level.HPIncrease > player.maxhealth ) {
			player.health = player.maxhealth;
		} else {
			player.health += level.HPIncrease;
		}

		player playLocalSound( "health_pickup_medium" );
		thread HPRemove( self, HPModel );
		return;
	}
}


HPTimedout( HPModel )
{
	self endon("death");

	wait ( 60.0 );
	thread HPRemove( self, HPModel );
}


HPRemove( HPTrigger, HPModel )
{
	HPTrigger delete();
	HPModel delete();
}
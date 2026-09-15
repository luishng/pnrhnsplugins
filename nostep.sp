#include < sourcemod >
#include < sdktools >

#pragma semicolon 1

ConVar sv_footsteps;

public Plugin:myinfo = {
	name = "SilentFeet TR, Auto Team Pick, No Motd & VGUIMenu",
	author = "KINZ",
	description = "www.profig.ml",
	version = "1.2.8",
	url = "www.profig.ml"
}

public OnPluginStart( ) {
    sv_footsteps = FindConVar( "sv_footsteps" );
	
	HookUserMessage( GetUserMessageId( "VGUIMenu" ), TeamMenuHook, true );
	// HookEvent( "player_team", OnPlayerJoinTeam, EventHookMode_Pre );
	HookEvent( "player_spawn", ForceAuto, EventHookMode_Pre );
	
    AddNormalSoundHook( OnNormalSoundPlayed );

    for( new i = 1; i <= MaxClients; i++ ) {
        if( IsClientInGame( i ) && !IsFakeClient( i ) )    OnClientPutInServer( i );
    }
}

public OnClientPutInServer( client ) {
    if( !IsFakeClient( client ) )     
		SendConVarValue( client, sv_footsteps, "0" );
}

public Action:OnNormalSoundPlayed( clients[ 64 ], &numClients, String:sample[ PLATFORM_MAX_PATH ], &entity, &channel, &Float:volume, &level, &pitch, &flags ) {
    if( entity && entity <= MaxClients && ( StrContains(sample, "physics") != -1 || StrContains(sample, "footsteps" ) != -1 ) ) {
        if( GetClientTeam( entity ) == 2 ) {
            return Plugin_Handled;
        }
        else {
            for( new i = 1; i <= MaxClients; i++ ) {
                if( IsClientInGame( i ) ) {
                    clients[ numClients++ ] = i;
                }
            }
            
            return Plugin_Changed;
        }
    }
   
    return Plugin_Continue;
}

// public Action:OnPlayerJoinTeam( Handle:event, const String:name[], bool:dontBroadcast ) {
	// SetEventBroadcast( event, true );
	// return Plugin_Continue;
// }

public ForceAuto( Handle:event, const String:name[ ], bool:dontBroadcast ) {
	new client = GetEventInt( event, "userid" );
	if( !IsClientInGame( client ) || IsFakeClient( client ) )
		return;
	
	ChangeClientTeam( client, GetRandomInt( 2, 3 ) );
}

public Action:TeamMenuHook( UserMsg:msg_id, Handle:msg, const players[], playersNum, bool:reliable, bool:init ) {
	new String:buffermsg[ 64 ];
	if( GetUserMessageType( ) == UM_Protobuf ) {
	
		PbReadString( msg, "name", buffermsg, sizeof( buffermsg ) );
		if( StrEqual( buffermsg, "team" ) && reliable ) {
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}


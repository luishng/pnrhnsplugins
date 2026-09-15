#include < sourcemod >
#include < sdktools >

public OnPluginStart( ) {
	
	HookEvent( "round_end", OnRoundEnd, EventHookMode_Pre );
	HookEvent( "round_start", OnRoundStart, EventHookMode_PostNoCopy );
}

public Action:OnRoundEnd( Handle:event, const String:name[ ], bool:dontBroadcast ) {
    SetConVarInt( FindConVar( "sv_voiceenable" ), 0, true );
}

public Action:OnRoundStart( Handle:event, const String:name[ ], bool:dontBroadcast ) {
	CreateTimer( 3.0, VoiceEnable );
}

public Action:VoiceEnable( Handle:hTimer) {
	SetConVarInt( FindConVar( "sv_voiceenable" ), 1, true );
}
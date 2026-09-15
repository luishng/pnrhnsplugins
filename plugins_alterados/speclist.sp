#include <sourcemod> 
#include <sdkhooks> 

#pragma semicolon 1 

#define SPECMODE_NONE 				0
#define SPECMODE_FIRSTPERSON 		4
#define SPECMODE_3RDPERSON 			5
#define SPECMODE_FREELOOK	 		6

new const String:PLUGIN_VERSION[] = "1.0"; 

public Plugin:myinfo =  
{ 
    name = "Show Spectators", 
    author = "hlstriker", 
    description = "Shows who is spectating a specific player.", 
    version = PLUGIN_VERSION, 
    url = "www.swoobles.com" 
} 

const OBS_MODE_IN_EYE    = 4; 
const OBS_MODE_CHASE    = 5; 

const Float:SPEC_MESSAGE_DELAY = 1.2; 
new Float:g_fNextSpecMessage[MAXPLAYERS+1]; 

new g_iButtonsPressed[MAXPLAYERS+1] = {0,...};
new g_iSpectating[MAXPLAYERS+1]; 

new Handle:g_hUpdateKeyDisplay = INVALID_HANDLE;
new Handle:g_hHudSyncSpec;
new Handle:g_hHudSyncKeys;

public OnMapStart()
{
	g_hUpdateKeyDisplay = CreateTimer(0.1, Timer_UpdateKeyDisplay, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public OnMapEnd()
{
	if(g_hUpdateKeyDisplay != INVALID_HANDLE)
	{
		KillTimer(g_hUpdateKeyDisplay);
		g_hUpdateKeyDisplay = INVALID_HANDLE;
	}
}

public OnPluginStart() 
{ 
    CreateConVar("hls_showspec_version", PLUGIN_VERSION, "Show Spectators Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_PRINTABLEONLY); 
     
    g_hHudSyncSpec = CreateHudSynchronizer();
    g_hHudSyncKeys = CreateHudSynchronizer();
     
    for(new iClient=1; iClient<=MaxClients; iClient++) 
    { 
        if(IsClientConnected(iClient) && !IsFakeClient(iClient)) 
            SDKHook(iClient, SDKHook_PreThink, hook_PreThink); 
    } 
     
    CreateTimer(SPEC_MESSAGE_DELAY, TimerSpecMessage, _, TIMER_REPEAT); 
} 

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	g_iButtonsPressed[client] = buttons;
}

public Action:Timer_UpdateKeyDisplay(Handle:timer, any:data)
{
	UpdateKeyDisplay();
	return Plugin_Continue;
}

public Action:TimerSpecMessage(Handle:hTimer) 
{ 
    new Float:fCurTime = GetEngineTime(); 
    for(new iClient=1; iClient<=MaxClients; iClient++) 
    { 
        if(!IsClientConnected(iClient) || IsPlayerAlive(iClient) || !iClient ) 
            continue; 
         
        if(g_fNextSpecMessage[iClient] > fCurTime) 
            continue; 
         
        BuildSpecMessage(iClient); 
    } 
} 

public OnClientPutInServer(iClient) 
{
	if( 1 <= iClient <= MaxClients && IsClientConnected( iClient ) && !IsFakeClient(iClient))
		SDKHook(iClient, SDKHook_PreThink, hook_PreThink); 
} 

public OnClientDisconnect(client)
{
    SDKUnhook(client, SDKHook_PreThink, hook_PreThink);
	g_iButtonsPressed[client] = 0;
    g_iSpectating[client] = 0;
    g_fNextSpecMessage[client] = 0;
}

public hook_PreThink(iClient) 
{ 
    if(IsPlayerAlive(iClient)) 
        return; 
     
    if(!UpdateSpectatingTarget(iClient)) 
        return; 
     
    BuildSpecMessage(iClient); 
} 

UpdateSpectatingTarget(iClient) 
{ 
    // Return true if the client is spectating a different player. 
     
    switch(GetEntProp(iClient, Prop_Send, "m_iObserverMode")) 
    { 
        case OBS_MODE_IN_EYE, OBS_MODE_CHASE: 
        { 
            new iSpectating = GetEntPropEnt(iClient, Prop_Send, "m_hObserverTarget"); 
            if(iSpectating != g_iSpectating[iClient]) 
            { 
                g_iSpectating[iClient] = iSpectating; 
                return true; 
            } 
        } 
        default: 
        { 
            if(g_iSpectating[iClient]) 
            { 
                // This client was spectating someone, but isn't anymore so clear their message. 
                g_iSpectating[iClient] = 0; 
	            SetHudTextParams(0.1, -1.0, SPEC_MESSAGE_DELAY + 0.1, 255, 255, 255, 255, 0, 0.0, 0.0, 0.0);
	            ShowSyncHudText(iClient, g_hHudSyncSpec, " ");
            } 
        } 
    } 
     
    return false; 
} 

BuildSpecMessage(iClient) { 
    if(iClient > 0) {
        g_fNextSpecMessage[iClient] = GetEngineTime() + SPEC_MESSAGE_DELAY - 0.2; 
            
        if(!IsClientConnected(g_iSpectating[iClient]) || !iClient || IsFakeClient(iClient) || 1 > iClient > MaxClients) 
            return; 
        
        static String:szBuffer[254], iBufLen, String:szName[32]; 
        iBufLen = 0; 
        GetClientName(g_iSpectating[iClient], szName, sizeof(szName)); 
        
        iBufLen += FormatEx(szBuffer[iBufLen], sizeof(szBuffer)-iBufLen, "\nSpectating %s:\n", szName); 

        SetHudTextParams(0.7, 0.1, SPEC_MESSAGE_DELAY + 0.1, 220, 220, 220, 255, 0, 0.0, 0.1, 0.1);

        for(new iSpectator=1; iSpectator<=MaxClients; iSpectator++) 
        { 
            if(!IsClientConnected(iSpectator) || IsPlayerAlive(iSpectator)) 
                continue; 
            
            if(g_iSpectating[iSpectator] != g_iSpectating[iClient]) 
                continue; 
            
            GetClientName(iSpectator, szName, sizeof(szName)); 

            iBufLen += FormatEx(szBuffer[iBufLen], sizeof(szBuffer)-iBufLen, "%s\n", szName);
            
            if(GetEntPropEnt(iSpectator, Prop_Send, "m_hObserverTarget") == g_iSpectating[iClient]){
                ShowSyncHudText(g_iSpectating[iClient], g_hHudSyncSpec, szBuffer); 
            }
        } 

        ShowSyncHudText(iClient, g_hHudSyncSpec, szBuffer);
    }
}

UpdateKeyDisplay()
{
	new iClientToShow, iButtons, iObserverMode;
	
	for(new i=1;i<=MaxClients;i++)
	{
		decl String:sOutput[256];
		sOutput[0] = '\0';
		
		if(IsClientConnected(i))
		{
			// Show own buttons by default
			iClientToShow = i;
			
			// Get target he's spectating
			if((!IsPlayerAlive(i) || IsClientObserver(i)))
			{
				iObserverMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
				if(iObserverMode == SPECMODE_FIRSTPERSON || iObserverMode == SPECMODE_3RDPERSON)
				{
					iClientToShow = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
					
					// Check client index
					if(iClientToShow <= 0 || iClientToShow > MaxClients)
						continue;
				}
				else
				{
					continue; // don't proceed, if in freelook..
				}
			}

			iButtons = g_iButtonsPressed[iClientToShow];

			Format( sOutput, sizeof(sOutput), " \n\t\t%s\t\t\t%s\n\t%s %s %s\t\t%s",
            iButtons & IN_FORWARD ? "W" : ".",
			iButtons & IN_JUMP ? "JUMP" : " -",
			iButtons & IN_MOVELEFT ? " A" : " .",
			iButtons & IN_BACK ? "S" : ".",
			iButtons & IN_MOVERIGHT ? "D" : ".",
			iButtons & IN_DUCK ? "DUCK" : "  -");
			
			if( !IsPlayerAlive( i ) ) {
                SetHudTextParams(0.4, 0.7, 0.1, 220, 220, 220, 255, 0, 0.0, 0.0, 0.0);
                ShowSyncHudText(i, g_hHudSyncKeys, sOutput);
            }
		}
	}
}
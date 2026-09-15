#include <sourcemod>

public Plugin:myinfo = 
{
	name = "[CSGO] Restart Round",
	author = "NiGhT_CSGO & Edited By SaBaToN",
	description = "Restart Round",
	version = "1.0"
}

public OnPluginStart()
{
	RegAdminCmd("sm_rr", Command_rr, ADMFLAG_GENERIC, "Restarting one Match.")
}


public Action:Command_rr(client, args)
{
	if (args < 1)
	{
		new String:AdminName[64];
		GetClientName(client, AdminName, sizeof(AdminName));	
		ServerCommand("mp_restartgame 1");
		PrintToChatAll("\x01[\x05SM\x01] \x04%s \x01proceed restart game in \x041 \x01second", AdminName);
		return Plugin_Handled;
	}
	
	new String:RRTime[32];
	new String:AdminName[64];
	GetCmdArgString(RRTime, sizeof(RRTime)); 
	GetClientName(client, AdminName, sizeof(AdminName));		
	ServerCommand("mp_restartgame %s", RRTime);
	PrintToChatAll("\x01[\x05SM\x01] \x04%s \x01proceed restart game in \x04%s \x01seconds", AdminName, RRTime);
	
	return Plugin_Handled;
}
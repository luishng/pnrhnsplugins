#include <sourcemod>
#include <cstrike>
#include <colorvariables>

new Handle:g_RulesMenu = INVALID_HANDLE

new Handle:sm_rulesmenu_join = INVALID_HANDLE;
new Handle:sm_rulesmenu_announce_player = INVALID_HANDLE;
new Handle:sm_rulesmenu_announce_admin = INVALID_HANDLE;

#define VERSION "1.1"

public Plugin:myinfo =
{
	name = "Simple Rules Menu",
	author = "The.Hardstyle.Bro^_^",
	description = "Showing the rules to player.",
	version = VERSION,
	url = "http://www.sourcemod.net/"
};

public OnPluginStart()
{
	// Exec CFG
	AutoExecConfig(true, "simplerulesmenu");
	
	// Version cvar
	CreateConVar("sm_rulesmenu_version", VERSION, "Defines the version of the Rules Menu installed on this server", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	// Cvars
	sm_rulesmenu_join = CreateConVar("sm_rulesmenu_join", "1", "Enables/disables if a player joins the server to show the rules.");
	sm_rulesmenu_announce_player = CreateConVar("sm_rulesmenu_announce_player", "0", "Announce if a player is checking the rules with a message in chat.");
	sm_rulesmenu_announce_admin = CreateConVar("sm_rulesmenu_announce_admin", "1", "Announce if an admin is using the showrules command with a message in chat.");
	
	// Console command
	RegConsoleCmd("sm_rules", Command_Rules);
	RegConsoleCmd("sm_regras", Command_Rules);

	RegConsoleCmd("sm_bind", Command_Bind);
	RegConsoleCmd("sm_hns", Command_Hns);

	RegConsoleCmd("sm_vip", Command_Vip);
	RegConsoleCmd("sm_mod", Command_Mod);
	RegConsoleCmd("sm_adm", Command_Adm);

	RegConsoleCmd("sm_discord", Command_Discord);
	RegConsoleCmd("sm_grupo", Command_Grupo);

	RegAdminCmd("sm_showrules", Command_ShowRules, ADMFLAG_KICK, "sm_showrules <player> to show the rules");
	
	// Translations init
	LoadTranslations("common.phrases");
	LoadTranslations("simplerules.phrases");
}
 
public OnMapStart()
{
	g_RulesMenu = BuildRulesMenu();
}
 
public OnMapEnd()
{
	if (g_RulesMenu != INVALID_HANDLE)
	{
		CloseHandle(g_RulesMenu);
		g_RulesMenu = INVALID_HANDLE;
	}
}
 
Handle:BuildRulesMenu()
{
	/* Open the file */
	new Handle:file = OpenFile("addons/sourcemod/configs/rules.ini", "rt");
	if (file == INVALID_HANDLE)
	{
		return INVALID_HANDLE;
	}
 
	/* Create the menu Handle */
	new Handle:menu = CreateMenu(Menu_Rules);
	new String:rule[255];
	while (!IsEndOfFile(file) && ReadFileLine(file, rule, sizeof(rule)))
	{
		/* Add it to the menu */
		AddMenuItem(menu, rule, rule);
	}
	/* Make sure we close the file! */
	CloseHandle(file);
 
	/* Finally, set the title */
	SetMenuTitle(menu, "Regras do Servidor:");
 
	return menu;
}

 public OnClientAuthorized(client,const String:auth[])
{
	if (IsFakeClient(client)) 
	{
	return;
	}
	
	if(GetConVarBool(sm_rulesmenu_join))
	{
		DisplayMenu(g_RulesMenu, client, MENU_TIME_FOREVER);
	}
}

public Menu_Rules(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{

	}
}
 

public Action:Command_Rules(client, args)
{
	if (g_RulesMenu == INVALID_HANDLE)
	{
		PrintToConsole(client, "The rules.ini in the sourcemod config directory file was not found!");
		return Plugin_Handled;
	}	
 
	DisplayMenu(g_RulesMenu, client, MENU_TIME_FOREVER);
	if(GetConVarBool(sm_rulesmenu_announce_player))
	{
		// PrintToChatAll("\x04[Regras] \x03%t", "Readrules", client);
	}
	
 	// PrintToChat(client, "\x04[Regras] \x03%t", "Readgood");
	
	return Plugin_Handled;
}

public Action:Command_Hns(client, args)
{
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);
	CPrintToChat(client, "{green}[pNr] {lightred}Hide N' Seek {default}(esconde-esconde).", client);
	CPrintToChat(client, "{green}[pNr] {gold}TR {default}deve fugir de {blue}CT {default}assim que o round inicia, completando spots espalhados pelo mapa.", client);
	CPrintToChat(client, "{green}[pNr] {gold}TR{default}: Seu objetivo é se esconder e segurar o tempo.", client);
	CPrintToChat(client, "{green}[pNr] {blue}CT{default}: Seu objetivo é encontrar e eliminar todos os terroristas antes que o tempo acabe.", client);
	CPrintToChat(client, "{green}[pNr] {grey2}Bom jogo!", client);
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);

	return Plugin_Handled;
}

public Action:Command_Bind(client, args)
{
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);
	CPrintToChat(client, "{green}[pNr] {default}Para facilitar o {lightred}pulo{default}, digite no {purple}console{default}:", client);
	CPrintToChat(client, "{green}[pNr] {gold}bind mwheelup +jump", client);
	CPrintToChat(client, "{green}[pNr] {lightred}e/ou", client);
	CPrintToChat(client, "{green}[pNr] {gold}bind mwheeldown +jump", client);
	CPrintToChat(client, "{green}[pNr] {default}De acordo com a {lightred}preferência{default}!", client);
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);

	return Plugin_Handled;
}

public Action:Command_Vip(client, args)
{
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);
	CPrintToChat(client, "{green}[pNr] {default}O {darkblue}VIP {blue}custa {bluegrey}R$ 10,00{default}. Para mais informações entre em nosso {purple}discord {default}ou {blue}grupo da steam{default}!", client);
	CPrintToChat(client, "{green}[pNr] {default}O {darkblue}VIP {default}possui vários {teamcolor}comandos especiais{default}: {gold}!gloves{default}, {gold}!votekick{default}, {gold}!slay{default},{lightgreen}e muito mais{default}!", client);
	CPrintToChat(client, "{green}[pNr] {default}O {darkblue}VIP {default}recebe {teamcolor}20% {default}a mais de {lightgreen}XP{default}!", client);
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);

	return Plugin_Handled;
}

public Action:Command_Mod(client, args)
{
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);
	CPrintToChat(client, "{green}[pNr] {default}Diferentemente do {blue}VIP {default}o {lightgreen}Mod {gold}não será vendido{default}, {red}mas conquistado{default} pelo {blue}VIP{default}!", client);
	CPrintToChat(client, "{green}[pNr] {default}O {lightgreen}Mod {default}possue mais vantagens que o {blue}VIP{default}. Para mais informações entre em nosso {purple}discord{default}!", client);
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);

	return Plugin_Handled;
}

public Action:Command_Adm(client, args)
{
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);
	CPrintToChat(client, "{green}[pNr] {default}Assim como o {lightgreen}Mod{default}, o {red}Admin {gold}não será vendido{default}! {default}Para se tornar um Admin, você já deve ter sido um {lightgreen}Mod{default}.", client);
	CPrintToChat(client, "{green}[pNr] {default}O {red}Admin {default}possue mais vantagens que o {lightgreen}Mod{default}. Para mais informações entre em nosso {purple}discord{default}!", client);
	CPrintToChat(client, "{green}[pNr] {default}---------------------------------------------------", client);

	return Plugin_Handled;
}

public Action:Command_Discord(client, args)
{
	CPrintToChat(client, "{green}[pNr] {default}Entre em nosso {purple}discord! {red}Link: {lightgreen}https://discord.gg/EteyNcM", client);

	return Plugin_Handled;
}

public Action:Command_Grupo(client, args)
{
	CPrintToChat(client, "{green}[pNr] {default}Entre em nosso {gold}grupo! {red}Link: {lightgreen}https://steamcommunity.com/groups/detranhns", client);

	return Plugin_Handled;
}

public Action:Command_ShowRules(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_showrules <#userid|name>");
		return Plugin_Handled;
	}

	decl String:Arguments[256];
	GetCmdArgString(Arguments, sizeof(Arguments));

	decl String:arg[65];
	new len = BreakString(Arguments, arg, sizeof(arg));
	
	if (len == -1)
	{
		/* Safely null terminate */
		len = 0;
		Arguments[0] = '\0';
	}

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			arg,
			client, 
			target_list, 
			MAXPLAYERS, 
			COMMAND_FILTER_CONNECTED,
			target_name,
			sizeof(target_name),
			tn_is_ml)) > 0)
	{
		
		new rules_self = 0;
		
		for (new i = 0; i < target_count; i++)
		{
			/* Swap everyone else first */
			if (target_list[i] == client)
			{
				rules_self = client;
			}
			else
			{
				DisplayMenu(g_RulesMenu, target_list[i], MENU_TIME_FOREVER);
				if(GetConVarBool(sm_rulesmenu_announce_admin))
				{
					PrintToChatAll("\x04[Regras] \x03%t", "Showrules", client, target_list[i]);
				}
 				PrintToChat(target_list[i], "\x04[Regras] \x03%t", "Readgood");
				LogAction(client, -1, "\"%L\" usou sm_showrules no: \"%L\" ", client, target_list[i]);
			}
		}
		
		if (rules_self)
		{
			DisplayMenu(g_RulesMenu, client, MENU_TIME_FOREVER);
			if(GetConVarBool(sm_rulesmenu_announce_admin))
			{
				PrintToChatAll("\x04[Regras] \x03%t", "Showrules", client);
			}
 			PrintToChat(client, "\x04[Regras] \x03%t", "Readgood");
			LogAction(client, -1, "\"%L\" usou sm_showrules em si mesmo.", client);
		}
	}
	else
	{
		ReplyToTargetError(client, target_count);
	}

	return Plugin_Handled;
}


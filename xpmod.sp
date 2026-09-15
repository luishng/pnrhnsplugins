/*
	Based on Exolent's HideNseek XPMod!

	Author: KINZ

	Chat Commands:
	/xp - Open the main menu of the plugin.

	To-do list
	Talves dar uma geral nos menus! com os \n !
	consertar os erros que estao aparecendo no compiler, Faltam: 6~

	remover todos os comentarios
	
	
	TODO: URGENTE!!
	no RESPAWN E FALL DAMAGE, descobrir pq menu derrubou o server, e procurar mais erros antes de colocar no sv!!
	Fazer igual O HEALTH e colocar separado nao da pra usar TEAM == CT || TEAM T :(

*/

// The prefix in all of the plugin's messages
#define PREFIX "{GRAY}[{PINK}KINZ XP{GRAY}]{NORMAL}"

// If the player hasn't ever been to your server, they will get this much xp to start with
#define ENTRY_XP						500

// Recommended > 2
#define MIN_PLAYERS						3

// These determine if these abilities should be enabled or disabled
// 1 = enabled
// 0 = disabled

#define ENABLE_GRENADE					1
#define ENABLE_FLASHBANG_1				1
#define ENABLE_FLASHBANG_2				1
#define ENABLE_SMOKEGRENADE				1
#define ENABLE_TERR_HEALTH				1
#define ENABLE_CT_HEALTH				1
#define ENABLE_TERR_ARMOR				1
#define ENABLE_CT_ARMOR					1
#define ENABLE_TERR_RESPAWN				1
#define ENABLE_CT_RESPAWN				1
#define ENABLE_TERR_NOFALL				1
#define ENABLE_CT_NOFALL				1

// The maximum level for each ability
#define MAXLEVEL_GRENADE				8
#define MAXLEVEL_FLASHBANG_1			4
#define MAXLEVEL_FLASHBANG_2			4
#define MAXLEVEL_SMOKEGRENADE			4
#define MAXLEVEL_TERR_HEALTH			10
#define MAXLEVEL_CT_HEALTH				5
#define MAXLEVEL_TERR_ARMOR				8
#define MAXLEVEL_CT_ARMOR				6
#define MAXLEVEL_TERR_RESPAWN			3
#define MAXLEVEL_CT_RESPAWN				4
#define MAXLEVEL_TERR_NOFALL			8
#define MAXLEVEL_CT_NOFALL				8

// The xp amount required to buy the first level
#define FIRST_XP_GRENADE				200
#define FIRST_XP_FLASHBANG_1			200
#define FIRST_XP_FLASHBANG_2			200
#define FIRST_XP_SMOKEGRENADE			200
#define FIRST_XP_TERR_HEALTH			200
#define FIRST_XP_CT_HEALTH				200
#define FIRST_XP_TERR_ARMOR				200
#define FIRST_XP_CT_ARMOR				200
#define FIRST_XP_TERR_RESPAWN			10000
#define FIRST_XP_CT_RESPAWN				3000
#define FIRST_XP_TERR_NOFALL			200
#define FIRST_XP_CT_NOFALL				200

// The maximum chance possible for this ability (happens when player has maximum level)
#define CHANCE_MAX_GRENADE				100
#define CHANCE_MAX_FLASHBANG_1			100
#define CHANCE_MAX_FLASHBANG_2			100
#define CHANCE_MAX_SMOKEGRENADE			100
#define CHANCE_MAX_TERR_RESPAWN			45
#define CHANCE_MAX_CT_RESPAWN			100
#define CHANCE_MAX_TERR_NOFALL			80
#define CHANCE_MAX_CT_NOFALL			80

#define IsPlayer(%1) (1 <= %1 <= MaxClients)

#include < sourcemod >

#pragma semicolon 1;

#include < smlib >
#include < cstrike >

#include < sdkhooks >
#include < sdktools >
#include < csgocolors >

// Agradecimentos ao mister q me mandou o HookEvent( "round_start", OnRoundStart, EventHookMode_PostNoCopy ); THX !! :D :D :D

enum _:Grenades {
	NADE_HE,
	NADE_FL1,
	NADE_FL2,
	NADE_SM
};

new const g_nade_enabled[ Grenades ] = {
	ENABLE_GRENADE,
	ENABLE_FLASHBANG_1,
	ENABLE_FLASHBANG_2,
	ENABLE_SMOKEGRENADE
};

new const g_any_nade_enabled = ENABLE_GRENADE + ENABLE_FLASHBANG_1 + ENABLE_FLASHBANG_2 + ENABLE_SMOKEGRENADE;
new const String:g_nade_names[ Grenades ][ ] = {
	"HE Grenade",
	"Flashbang #1",
	"Flashbang #2",
	"Frost Nade"
};

new const String:g_nade_classnames[ Grenades ][ ] = {
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_flashbang",
	"weapon_decoy"
};

new const g_nade_maxlevels[ Grenades ] = {
	MAXLEVEL_GRENADE,
	MAXLEVEL_FLASHBANG_1,
	MAXLEVEL_FLASHBANG_2,
	MAXLEVEL_SMOKEGRENADE
};

new const g_nade_first_xp[ Grenades ] = {
	FIRST_XP_GRENADE,
	FIRST_XP_FLASHBANG_1,
	FIRST_XP_FLASHBANG_2,
	FIRST_XP_SMOKEGRENADE
};

new const g_nade_max_chance[ Grenades ] = {
	CHANCE_MAX_GRENADE,
	CHANCE_MAX_FLASHBANG_1,
	CHANCE_MAX_FLASHBANG_2,
	CHANCE_MAX_SMOKEGRENADE
};

new g_health_enabled[ 2 ] = {
	ENABLE_TERR_HEALTH,
	ENABLE_CT_HEALTH
};

new const g_any_health_enabled = ENABLE_TERR_HEALTH + ENABLE_CT_HEALTH;
new const String:g_health_names[ 2 ][ 40 ] = {
	"T Extra Health",
	"CT Extra Health"
};

new const g_health_maxamount[ 2 ] = {
	100,
	50
};

new const g_health_maxlevels[ 2 ] = {
	MAXLEVEL_TERR_HEALTH,
	MAXLEVEL_CT_HEALTH
};

new const g_health_first_xp[ 2 ] = {
	FIRST_XP_TERR_HEALTH,
	FIRST_XP_CT_HEALTH
};

new const g_armor_enabled[ 2 ] = {
	ENABLE_TERR_ARMOR,
	ENABLE_CT_ARMOR
};

new const g_any_armor_enabled = ENABLE_TERR_ARMOR + ENABLE_CT_ARMOR;
new const String:g_armor_names[ 2 ][ 40 ] = {
	"T Armor",
	"CT Armor"
};

new const g_armor_maxamount[ 2 ] = {
	200,
	150
};

new const g_armor_maxlevels[ 2 ] = {
	MAXLEVEL_TERR_ARMOR,
	MAXLEVEL_CT_ARMOR
};

new const g_armor_first_xp[ 2 ] = {
	FIRST_XP_TERR_ARMOR,
	FIRST_XP_CT_ARMOR
};

new const g_respawn_enabled[ 2 ] = {
	ENABLE_TERR_RESPAWN,
	ENABLE_CT_RESPAWN
};

new const g_any_respawn_enabled = ENABLE_TERR_RESPAWN + ENABLE_CT_RESPAWN;
new const String:g_respawn_names[ 2 ][ 40 ] = {
	"T Respawn Chance",
	"CT Respawn Chance"
};

new const g_respawn_maxlevels[ 2 ] = {
	MAXLEVEL_TERR_RESPAWN,
	MAXLEVEL_CT_RESPAWN
};

new const g_respawn_first_xp[ 2 ] = {
	FIRST_XP_TERR_RESPAWN,
	FIRST_XP_CT_RESPAWN
};

new const g_respawn_max_chance[ 2 ] = {
	CHANCE_MAX_TERR_RESPAWN,
	CHANCE_MAX_CT_RESPAWN
};

new const g_nofall_enabled[ 2 ] = {
	ENABLE_TERR_NOFALL,
	ENABLE_CT_NOFALL
};

new const g_any_nofall_enabled = ENABLE_TERR_NOFALL + ENABLE_CT_NOFALL;
new const String:g_nofall_names[ 2 ][ 40 ] = {
	"T Fall Damage Reducer",
	"CT Fall Damage Reducer"
};

new g_nofall_maxlevels[ 2 ] = {
	MAXLEVEL_TERR_NOFALL,
	MAXLEVEL_CT_NOFALL
};

new g_nofall_first_xp[ 2 ] = {
	FIRST_XP_TERR_NOFALL,
	FIRST_XP_CT_NOFALL
};

new g_nofall_max_chance[ 2 ] = {
	CHANCE_MAX_TERR_NOFALL,
	CHANCE_MAX_CT_NOFALL
};

public Plugin:myinfo = {
	name = "HideNSeek: XP Mod",
	author = "KINZ",
	description = "XP Mod (wannabe 1.6 version) :D",
	version = "1.4.9",
	url = "http://profig.ml"
}

// #define ANY_ABILITY_ENABLED ( g_any_nade_enabled || g_any_health_enabled || g_any_armor_enabled || g_any_respawn_enabled || g_any_nofall_enabled )

new String:g_authid[ MAXPLAYERS + 1 ][ 64 ];

new g_xp[ MAXPLAYERS + 1 ];
new g_Kills[ MAXPLAYERS + 1 ]; // Possivel Zica, nao sei se da pra add g_Kills > 500 KILLS abrir a molotov!!

new g_first_time[ MAXPLAYERS + 1 ];
new bool:g_loaded_data[ MAXPLAYERS + 1 ];

new g_used_revive[ MAXPLAYERS + 1 ];

new g_nade_level[ MAXPLAYERS + 1 ][ Grenades ];
new g_armor_level[ MAXPLAYERS + 1 ][ 2 ];
new g_respawn_level[ MAXPLAYERS + 1 ][ 2 ];
new g_health_level[ MAXPLAYERS + 1 ][ 2 ];
new g_nofall_level[ MAXPLAYERS + 1 ][ 2 ];

new Handle:g_hDatabase = INVALID_HANDLE;

// cvars
new Handle:g_hTimerXP;
new Handle:cvar_xp_suicide = INVALID_HANDLE;
new Handle:cvar_xp_kill = INVALID_HANDLE;
new Handle:cvar_xp_headshot = INVALID_HANDLE;
new Handle:cvar_xp_grenade = INVALID_HANDLE;
new Handle:cvar_xp_survive = INVALID_HANDLE;
new Handle:cvar_xp_win = INVALID_HANDLE;
new Handle:cvar_xp_per_time = INVALID_HANDLE;
new Handle:cvar_xp_interval = INVALID_HANDLE;

public OnMapStart( ) {
	if( GetConVarInt( cvar_xp_per_time ) != 0 ) {
		g_hTimerXP = CreateTimer( GetConVarFloat( cvar_xp_interval ), Timer_Credits, _, TIMER_REPEAT );
	}	
}

public OnMapEnd( ) {
	if( g_hTimerXP != INVALID_HANDLE ) {
		CloseHandle( g_hTimerXP );
		g_hTimerXP = INVALID_HANDLE;
	}
}

public Action:Timer_Credits( Handle:timer ) {
	for( new i = 1; i <= MaxClients; i++ ) {
		if( !IsValidClient( i, true ) )
			continue;

		if( GetClientTeam( i ) == CS_TEAM_SPECTATOR )
			continue;
		
		new iNum = GetClientCount( true );
		if( iNum >= MIN_PLAYERS && GameRules_GetProp( "m_bWarmupPeriod" ) != 1 ) {
			new xp = GetConVarInt( cvar_xp_per_time );
			g_xp[ i ] += xp;
			CPrintToChat( i, "%s Você ganhou {GREEN}%i{NORMAL} de XP por jogar no servidor.", PREFIX, xp );
			return Plugin_Continue;
		}
	}

	return Plugin_Continue;
}

public OnPluginStart( ) {

	RegConsoleCmd( "sm_xp", CmdOpenMenu );
	RegConsoleCmd( "sm_cm", CmdOpenMenu );

	cvar_xp_suicide 		= CreateConVar( "xp_suicide", "25", _, FCVAR_NOTIFY );
	cvar_xp_kill 			= CreateConVar( "xp_kill", "65", _, FCVAR_NOTIFY );
	cvar_xp_headshot 		= CreateConVar( "xp_headshot", "50", _, FCVAR_NOTIFY );
	cvar_xp_grenade 		= CreateConVar( "xp_grenade", "20", _, FCVAR_NOTIFY );
	cvar_xp_survive 		= CreateConVar( "xp_survive", "10", _, FCVAR_NOTIFY );
	cvar_xp_win 		  	= CreateConVar( "xp_win", "15", _, FCVAR_NOTIFY );
	
	cvar_xp_per_time		= CreateConVar( "xp_per_time", "5", _, FCVAR_NOTIFY );
	cvar_xp_interval		= CreateConVar( "xp_interval", "120", _, FCVAR_NOTIFY );

	HookEvent( "round_end", OnRoundEnd );
	HookEvent( "player_death", PlayerDeath );
	HookEvent( "player_spawn", PlayerSpawn );
	HookEvent( "round_start", OnRoundStart, EventHookMode_PostNoCopy );

	ConnectToDatabase( );
}

public Action:OnRoundStart( Handle:hEvent, const String:sName[ ], bool:dontBroadcast ) {
	for( new i = 1; i <= MaxClients; i++ )
		g_used_revive[ i ] = 0;
}

public Action:OnRoundEnd( Handle:hEvent, const String:name [], bool:dontBroadcast ) {
	new hider, seeker, hider_alive;
	for( new i = 1; i <= MaxClients; i++ ) {
		if( IsClientInGame( i ) && IsPlayerAlive( i ) ) {
			switch( GetClientTeam( i ) ) {
				case CS_TEAM_CT: {
					if( !seeker )	{
						seeker = i;
					}
				}
				case CS_TEAM_T:	{
					if( !hider ) {
						hider = i;

						if( !hider_alive && IsPlayerAlive( i ) ) {
							hider_alive = i;
						}
					}
				}
			}

			if( seeker && hider && hider_alive )
				break;
		}
	}

	if( !hider || !seeker )
		return;

	new winner = CS_TEAM_CT;
	if( hider_alive ) {
		winner = CS_TEAM_T;

		new survive = GetConVarInt( cvar_xp_survive );
		for( new iPlayer = 1; iPlayer <= MaxClients; iPlayer++ ) {
			if( IsUserAuthorized( iPlayer ) && IsPlayerAlive( iPlayer ) && GetClientTeam( iPlayer ) == CS_TEAM_T ) {
				g_xp[ iPlayer ] += survive;
				Save( iPlayer );

				CPrintToChat( iPlayer, "%s Você ganhou {GREEN}%i {NORMAL}XP por sobreviver!", PREFIX, survive );
			}
		}
	}

	new win = GetConVarInt( cvar_xp_win );
	for( new iPlayer = 1; iPlayer <= MaxClients; iPlayer++ ) {
		if( IsUserAuthorized( iPlayer ) && IsPlayerAlive( iPlayer ) && GetClientTeam( iPlayer ) == winner ) {
			g_xp[ iPlayer ] += win;
			Save( iPlayer );

			CPrintToChat( iPlayer, "%s Você ganhou {GREEN}%i {NORMAL}XP por ganhar o round!", PREFIX, win );
		}
	}
}

public Action:PlayerDeath( Handle:hEvent, const String:sName[ ], bool:bDontBroadcast ) {
	new iAttacker = GetClientOfUserId( GetEventInt( hEvent, "attacker" ) );
	new iVictim = GetClientOfUserId( GetEventInt( hEvent, "userid" ) );
	new bool:headshot = GetEventBool( hEvent, "headshot" );

	new String:sWeapon[ 64 ];
	GetEventString( hEvent, "weapon", sWeapon, sizeof( sWeapon ) );

	new iNum = GetClientCount( true );
	if( iNum < MIN_PLAYERS ) {
		CPrintToChat( iVictim, "%s Mínimo de %i jogadores são necessários!", PREFIX, MIN_PLAYERS );
		return Plugin_Continue;
	}

	if( ( 1 <= iAttacker <= MaxClients) && iVictim != iAttacker ) {
		if( IsUserAuthorized( iAttacker ) ) {
			new xp = GetConVarInt( cvar_xp_kill );

			if( headshot ) {
				xp += GetConVarInt( cvar_xp_headshot );
			}

			if( StrEqual( sWeapon, "hegrenade", false ) || StrEqual( sWeapon, "molotov", false ) || StrEqual( sWeapon, "decoy", false ) ) {
				xp += GetConVarInt( cvar_xp_grenade );
			}

			g_xp[ iAttacker ] += xp;
			g_Kills[ iAttacker ]++;

			Save( iAttacker );

			CPrintToChat( iAttacker, "%s Você ganhou {GREEN}%i{NORMAL} XP!", PREFIX, xp );

		}

	}
	else if( IsUserAuthorized( iVictim  ) ) {
		new xp = GetConVarInt( cvar_xp_suicide );

		g_xp[ iVictim ] -= xp;
		Save( iVictim );

		CPrintToChat( iVictim, "%s Você perdeu {GREEN}%i{NORMAL} XP!", PREFIX, xp );

		if( !g_used_revive[ iVictim ] ) {
			if( GetClientTeam( iVictim ) == CS_TEAM_T ) {
				new percent = g_respawn_max_chance[ 0 ] * g_respawn_level[ iVictim ][ 0 ] / g_respawn_maxlevels[ 0 ];
				if( GetRandomInt( 1, 100 ) <= percent )	{
					if( HasTeammateAlive( iVictim, CS_TEAM_T ) ) {
						CreateTimer( 0.5, TaskRespawn, iVictim );
						CPrintToChat( iVictim, "%s Você renasceu! ({GREEN}%i%%{NORMAL} de chance)", PREFIX, percent );

						g_used_revive[ iVictim ] = 1;
					}
				}
			}
			else if( GetClientTeam( iVictim ) == CS_TEAM_CT ) {
				new percent = g_respawn_max_chance[ 1 ] * g_respawn_level[ iVictim ][ 1 ] / g_respawn_maxlevels[ 1 ];
				if( GetRandomInt( 1, 100 ) <= percent )	{
					if( HasTeammateAlive( iVictim, CS_TEAM_CT ) ) {
						CreateTimer( 0.5, TaskRespawn, iVictim );
						CPrintToChat( iVictim, "%s Você renasceu! ({GREEN}%i%%{NORMAL} de chance)", PREFIX, percent );

						g_used_revive[ iVictim ] = 1;
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:TaskRespawn( Handle:hTimer, any:iPlayer ) {
	CS_RespawnPlayer( iPlayer );
}

public PlayerSpawn( Handle:hEvent, const String:sName[ ], bool:bDontBroadcast ) {
	new iClid = GetEventInt( hEvent, "userid" );
	new iPlayer = GetClientOfUserId( iClid );

	// if( IsUserAuthorized( iPlayer  ) {
	if( IsClientInGame( iPlayer ) && IsPlayerAlive( iPlayer ) ) {
		CreateTimer( 0.1, SpawnPost, iPlayer );
	}
}

public Action:SpawnPost( Handle:hTimer, any:iPlayer ) {
	if( IsPlayerAlive( iPlayer ) || IsUserAuthorized( iPlayer ) ) {
		if( g_first_time[ iPlayer ] ) {
			CPrintToChat( iPlayer, "%s É a sua primeira vez jogando este HideNSeek XP mod, você ganhou {GREEN}%i{NORMAL} de XP!", PREFIX, ENTRY_XP );
			CPrintToChat( iPlayer, "%s Você ganha XP baseado na sua jogabilidade, e você pode comprar mais niveis no menu.", PREFIX );
			CPrintToChat( iPlayer, "%s Escreva {GREEN}!xp{NORMAL} para ver o que você pode comprar!", PREFIX );

			g_first_time[ iPlayer ] = 0;
		}
		else {
			if( GetClientTeam( iPlayer ) == CS_TEAM_T ) {
				new health = g_health_maxamount[ 0 ] * g_health_level[ iPlayer ][ 0 ] / g_health_maxlevels[ 0 ];
				if( health > 0 ) {
					SetEntProp( iPlayer, Prop_Data, "m_iHealth", 100 + health );
				}
			}
			else if( GetClientTeam( iPlayer ) == CS_TEAM_CT ) {
				new health = g_health_maxamount[ 1 ] * g_health_level[ iPlayer ][ 1 ] / g_health_maxlevels[ 1 ];
				if( health > 0 ) {
					SetEntProp( iPlayer, Prop_Data, "m_iHealth", 100 + health );
				}
			}

			if( GetClientTeam( iPlayer ) == CS_TEAM_T ) {
				if( g_armor_enabled[ 0 ] ) {
					new armorvalue = g_armor_maxamount[ 0 ] * g_armor_level[ iPlayer ][ 0 ] / g_armor_maxlevels[ 0 ];
					if( armorvalue == 0 ) {
						SetEntProp( iPlayer, Prop_Send, "m_ArmorValue", 0 );
					}
					else if( armorvalue < 100 )	{
						SetEntProp( iPlayer, Prop_Send, "m_ArmorValue", armorvalue );
					}
					else {
						SetEntProp( iPlayer, Prop_Send, "m_ArmorValue", armorvalue );
						SetEntProp( iPlayer, Prop_Send, "m_bHasHelmet", 1 );
					}
				}
			}
			else if( GetClientTeam( iPlayer ) == CS_TEAM_CT ) {
				if( g_armor_enabled[ 1 ] ) {
					new armorvalue = g_armor_maxamount[ 1 ] * g_armor_level[ iPlayer ][ 1 ] / g_armor_maxlevels[ 1 ];
					if( armorvalue == 0 ) {
						SetEntProp( iPlayer, Prop_Send, "m_ArmorValue", 0 );
					}
					else if( armorvalue < 100 )	{
						SetEntProp( iPlayer, Prop_Send, "m_ArmorValue", armorvalue );
					}
					else {
						SetEntProp( iPlayer, Prop_Send, "m_ArmorValue", armorvalue );
						SetEntProp( iPlayer, Prop_Send, "m_bHasHelmet", 1 );
					}
				}
			}
		}
		
		if( GameRules_GetProp( "m_bWarmupPeriod" ) != 1 ) {
			CreateTimer( 10.0, GiveNades, iPlayer );
		}
	}
}

public Action:GiveNades( Handle:hTimer, any:iPlayer ) {
	if( !IsClientInGame( iPlayer ) || !IsPlayerAlive( iPlayer ) ) {
		return Plugin_Handled;
	}
	
	if( GetClientTeam( iPlayer ) == CS_TEAM_T ) {
		for( new i = 0; i < Grenades; i++ )	{
			if( g_nade_enabled[ i ] )	{
				new percent = g_nade_max_chance[ i ] * g_nade_level[ iPlayer ][ i ] / g_nade_maxlevels[ i ];
				if( percent > 0 && ( percent == 100 || GetRandomInt( i, 100 ) <= percent ) ) {

					GivePlayerItem( iPlayer, g_nade_classnames[ i ] );

					if( percent < 100 ) {
						CPrintToChat( iPlayer, "%s Você recebeu sua {YELLOW}%s{NORMAL}! ({GREEN}%i%%{NORMAL} de chance)", PREFIX, g_nade_names[ i ], percent );
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public Action:OnTakeDamage( iPlayer, &attacker, &inflictor, &Float:damage, &damagetype ) {
	if( IsPlayerAlive( iPlayer ) && ( damagetype & DMG_FALL) ) {
		if( GetClientTeam( iPlayer ) == CS_TEAM_T ) {
			new percent = g_nofall_max_chance[ 0 ] * g_nofall_level[ iPlayer ][ 0 ] / g_nofall_maxlevels[ 0 ];
			damage = damage * ( 1.0 - ( float( percent ) / 100.0 ) );

			return Plugin_Changed;
		}
		else if( GetClientTeam( iPlayer ) == CS_TEAM_CT ) {
			new percent = g_nofall_max_chance[ 1 ] * g_nofall_level[ iPlayer ][ 1 ] / g_nofall_maxlevels[ 1 ];
			damage = damage * ( 1.0 - ( float( percent ) / 100.0 ) );

			return Plugin_Changed;
		}
	}
	
	return Plugin_Continue;
}

// XP MOD MENUS
public Action:CmdOpenMenu( iPlayer, args ) {
	cmdMainMenu( iPlayer );
	return Plugin_Handled;
}

public cmdMainMenu( iPlayer ) {
	new Handle:hMenu = CreateMenu( MenuMainHandle );
	SetMenuTitle( hMenu, "[KINZ HnS.XP] Main Menu\n \n Seu XP: %i\n ", g_xp[ iPlayer ] );

	AddMenuItem( hMenu, "#choice1", "Ajuda!" );

	if( g_any_nade_enabled ) {
		AddMenuItem( hMenu, "#choice2", "Grenades Menu" );
	}
	if( g_any_health_enabled ) {
		AddMenuItem( hMenu, "#choice3", "Health Menu" );
	}
	if( g_any_armor_enabled ) {
		AddMenuItem( hMenu, "#choice4", "Armor Menu" );
	}
	if( g_any_respawn_enabled ) {
		AddMenuItem( hMenu, "#choice5", "Respawn Menu" );
	}
	if( g_any_nofall_enabled ) {
		AddMenuItem( hMenu, "#choice6", "Fall Damage Menu" );
	}

	SetMenuExitButton( hMenu, true );
	DisplayMenu( hMenu, iPlayer, MENU_TIME_FOREVER );
}

public MenuMainHandle( Handle:hMenu, MenuAction:iAction, iPlayer, iOptions ) {
	if( iAction == MenuAction_Select ) {
		switch( iOptions + 1 ) {
			case 1: { // Help console
				PrintToConsole( iPlayer, "---------------------------------------------------------------------------------------" );
				PrintToConsole( iPlayer, ">> HideNSeek XP Mod é um MOD baseado em experiência" );
				PrintToConsole( iPlayer, ">> Os jogadores ganham pontos de experiência por quão bem eles jogam." );
				PrintToConsole( iPlayer, ">> AÇÕES           							 XP" );
				PrintToConsole( iPlayer, "- Matar									+65" );
				PrintToConsole( iPlayer, "- Matar com BOMBAS							+20" );
				PrintToConsole( iPlayer, "- Matar de HS								+50" );
				PrintToConsole( iPlayer, "- Suicídio								-25" );
				PrintToConsole( iPlayer, "- Sobreviver de TR							+10" );
				PrintToConsole( iPlayer, "- Ganhar o Round							+15" );
				PrintToConsole( iPlayer, ">> Com esses pontos XP, você pode comprar upgrades." );
				PrintToConsole( iPlayer, ">> Para obter uma lista desses upgrades, digite !xp novamente e visualize os outros menus." );
				// PrintToConsole( iPlayer, "-" );
				// PrintToConsole( iPlayer, "- PLUGIN NAME: KINZ HideNseek:XPMod" );
				// PrintToConsole( iPlayer, "- Autor: KINZ" );
				// PrintToConsole( iPlayer, "- Contato KINZ: https://steamcommunity.com/id/8RUNO1/" );
				// PrintToConsole( iPlayer, "- Contato Mister: https://steamcommunity.com/profiles/76561198045654576/" );
				PrintToConsole( iPlayer, "----------------------------------------------------------------------------------------" );

				CPrintToChat( iPlayer, "%s {DARKRED}Atenção: A ajuda foi impressa no console.", PREFIX );
			}
			case 2: { // Grenade Menu
				ShowGrenadesMenu( iPlayer );
			}
			case 3: { // Health Menu
				ShowHealthMenu( iPlayer );
			}
			case 4: {
				ShowArmorMenu( iPlayer );
			}
			case 5: {
				ShowRespawnMenu( iPlayer );
			}
			case 6: {
				ShowNoFallMenu( iPlayer );
			}
		}
	}
	else if( ( iAction == MenuAction_Cancel ) ) {
		CloseHandle( hMenu );
	}

	return 1;
}

public Action:ShowGrenadesMenu( iPlayer ) {
	new Handle:hMenu = CreateMenu( ShowGrenadesMenuHandle );
	SetMenuTitle(hMenu, "[KINZ HnS.XP] Grenades Menu \n \n Nota: Granadas são somente para os Tr's! \n \n Seu XP: %d \n \n ", g_xp[ iPlayer ] );
	new level, xp, percent, String:item[ 128 ], String:info[ 35 ];
	for( new i = 0; i < Grenades; i++ )	{
		if( g_nade_enabled[ i ] )	{
			level = g_nade_level[ iPlayer ][ i ] + 1;
			percent = g_nade_max_chance[ i ] * level / g_nade_maxlevels[ i ];

			if( g_nade_level[ iPlayer ][ i ] < g_nade_maxlevels[ i ] ) {
				xp = g_nade_first_xp[ i ] * ( 1 << ( level - 1 ) );
				FormatEx( item, sizeof( item ) - 1, "%s: Level %i/%i (%i%%) [%i XP]", g_nade_names[ i ], level, g_nade_maxlevels[ i ], percent, xp );
			}
			else {
				FormatEx( item, sizeof( item ) - 1, "%s: Level %i (%i%%) [Máximo!]", g_nade_names[ i ], g_nade_maxlevels[ i ], g_nade_max_chance[ i ] );
			}

			new xpb = g_nade_first_xp[ i ] * ( 1 << g_nade_level[ iPlayer ][ i ] );

			FormatEx( info, ( sizeof info ), "#choice1%d", i + 1 );
			AddMenuItem( hMenu, info, item, ( g_xp[ iPlayer ] < xpb ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT || g_nade_level[ iPlayer ][ i ] == g_nade_maxlevels[ i ] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT ) );
		}
	}

	DisplayMenu( hMenu, iPlayer, 0 );
	return Plugin_Handled;
}

public ShowGrenadesMenuHandle( Handle:hMenu, MenuAction:iAction, iPlayer, iOptions ) {
	if( iAction == MenuAction_Select ) {
		new level = g_nade_level[ iPlayer ][ iOptions ] + 1;
		new xp = g_nade_first_xp[ iOptions ] * ( 1 << ( level - 1 ) );
		new percent = g_nade_max_chance[ iOptions ] * level / g_nade_maxlevels[ iOptions ];

		g_xp[ iPlayer ] -= xp;
		g_nade_level[ iPlayer ][ iOptions ] = level;

 		Save( iPlayer );
		CPrintToChat( iPlayer, "%s Você comprou %s Level %i (%i%%) por {GREEN}%i {NORMAL}XP!", PREFIX, g_nade_names[ iOptions ], level, percent, xp );
		ShowGrenadesMenu( iPlayer );
	}
	else if( ( iAction == MenuAction_Cancel ) ) {
		CmdOpenMenu( iPlayer, 0 );
	}
}

// Health menu

public Action:ShowHealthMenu( iPlayer ) {
	new Handle:hMenu = CreateMenu( ShowHealthMenuHandle );
	SetMenuTitle( hMenu, "[KINZ HnS.XP] Health Menu \n \n Seu XP: %d \n \n", g_xp[ iPlayer ] );

	new level, xp, amount, String:item[ 128 ], String:info[ 35 ];
	for( new i = 0; i < 2; i++ )	{
		if( g_health_enabled[ i ] )	{

			level = g_health_level[ iPlayer ][ i ] + 1;
			amount = g_health_maxamount[ i ] * level / g_health_maxlevels[ i ];

			if( g_health_level[ iPlayer ][ i ] < g_health_maxlevels[ i ] )	{
				xp = g_health_first_xp[ i ] * ( 1 << ( level - 1 ) );
				FormatEx( item, sizeof( item ) - 1, "%s: Level %d/%d (%d HP) [%d XP]", g_health_names[ i ], level, g_health_maxlevels[ i ], amount, xp );
			}
			else {
				FormatEx( item, sizeof( item ) - 1, "%s: Level %d (%d HP) [Máximo!]", g_health_names[ i ], g_health_maxlevels[ i ], g_health_maxamount[ i ] );
			}

			new xpb = g_health_first_xp[ i ] * ( 1 << g_health_level[ iPlayer ][ i ] );

			FormatEx( info, ( sizeof info ), "%d", i );
			AddMenuItem( hMenu, info, item, ( g_xp[ iPlayer ] < xpb ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT || g_health_level[ iPlayer ][ i ] == g_health_maxlevels[ i ] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT ) );
		}
	}

	DisplayMenu( hMenu, iPlayer, 0 );
	return Plugin_Handled;
}

public ShowHealthMenuHandle( Handle:hMenu, MenuAction:iAction, iPlayer, iOptions ) {
	if( iAction == MenuAction_Select ) {
		new level = g_health_level[ iPlayer ][ iOptions ] + 1;
		new xp = g_health_first_xp[ iOptions ] * ( 1 << ( level - 1 ) );
		new amount = g_health_maxamount[ iOptions ] * level / g_health_maxlevels[ iOptions ];

		g_xp[ iPlayer ] -= xp;
		g_health_level[ iPlayer ][ iOptions ] = level;

		Save( iPlayer );
		CPrintToChat( iPlayer, "%s Você comprou %s Level %i (%i HP) por {GREEN}%i {NORMAL}XP!", PREFIX, g_health_names[ iOptions ], level, amount, xp );

		ShowHealthMenu( iPlayer );
	}
	else if( ( iAction == MenuAction_Cancel ) ) {
		CmdOpenMenu( iPlayer, 0 );
	}
}

// Armor menu

public Action:ShowArmorMenu( iPlayer ) {
	new Handle:hMenu = CreateMenu( ShowArmorMenuHandle );
	SetMenuTitle( hMenu, "[KINZ HnS.XP] Armor Menu \n \n Seu XP: %d \n \n ", g_xp[ iPlayer ] );

	new level, xp, amount, String:item[ 128 ], String:info[ 35 ];
	for( new i = 0; i < 2; i++ ) {
		if( g_armor_enabled[ i ] )	{

			level = g_armor_level[ iPlayer ][ i ] + 1;
			amount = g_armor_maxamount[ i ] * level / g_armor_maxlevels[ i ];

			if( g_armor_level[ iPlayer ][ i ] < g_armor_maxlevels[ i ] )	{
				xp = g_armor_first_xp[ i ] * ( 1 << ( level - 1 ) );
				FormatEx( item, sizeof( item ) - 1, "%s: Level %d/%d (%d AP) [%d XP]", g_armor_names[ i ], level, g_armor_maxlevels[ i ], amount, xp );
			}
			else {
				FormatEx( item, sizeof( item ) - 1, "%s: Level %d (%d AP) [Máximo!]", g_armor_names[ i ], g_armor_maxlevels[ i ], g_armor_maxamount[ i ] );
			}

			new xpb = g_armor_first_xp[ i ] * ( 1 << g_armor_level[ iPlayer ][ i ] );

			FormatEx( info, ( sizeof info ), "%d", i );
			AddMenuItem( hMenu, info, item, ( g_xp[ iPlayer ] < xpb ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT || g_armor_level[ iPlayer ][ i ] == g_armor_maxlevels[ i ] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT ) );
		}
	}

	DisplayMenu( hMenu, iPlayer, 0 );
	return Plugin_Handled;
}

public ShowArmorMenuHandle( Handle:hMenu, MenuAction:iAction, iPlayer, iOptions ) {
	if( iAction == MenuAction_Select ) {
		new level = g_armor_level[ iPlayer ][ iOptions ] + 1;
		new xp = g_armor_first_xp[ iOptions ] * ( 1 << ( level - 1 ) );
		new amount = g_armor_maxamount[ iOptions ] * level / g_armor_maxlevels[ iOptions ];

		g_xp[ iPlayer ] -= xp;
		g_armor_level[ iPlayer ][ iOptions ] = level;

		Save( iPlayer );
		CPrintToChat( iPlayer, "%s Você comprou %s Level %i (%i AP) por {GREEN}%i {NORMAL}XP!", PREFIX, g_armor_names[ iOptions ], level, amount, xp );

		ShowArmorMenu( iPlayer );
	}
	else if( ( iAction == MenuAction_Cancel ) ) {
		CmdOpenMenu( iPlayer, 0 );
	}
}

// Respawn chance menu

public Action:ShowRespawnMenu( iPlayer ) {
	new Handle:hMenu = CreateMenu( ShowRespawnMenuHandle );
	SetMenuTitle( hMenu, "[KINZ HnS.XP] Respawn Menu \n \n Seu XP: %d \n \n ", g_xp[ iPlayer ] );

	new level, xp, amount, String:item[ 128 ], String:info[ 35 ];
	for( new i = 0; i < 2; i++ )	{
		if( g_respawn_enabled[ i ] )	{
			level = g_respawn_level[ iPlayer ][ i ] + 1;
			amount = g_respawn_max_chance[ i ] * level / g_respawn_maxlevels[ i ];

			if( g_respawn_level[ iPlayer ][ i ] < g_respawn_maxlevels[ i ] )	{
				xp = g_respawn_first_xp[ i ] * ( 1 << ( level - 1 ) );
				FormatEx( item, sizeof( item ) - 1, "%s: Level %d/%d (%i%%) [%d XP]", g_respawn_names[ i ], level, g_respawn_maxlevels[ i ], amount, xp );
			}
			else {
				FormatEx( item, sizeof( item ) - 1, "%s: Level %d (%i%%) [Máximo!]", g_respawn_names[ i ], g_respawn_maxlevels[ i ], g_respawn_max_chance[ i ] );
			}

			new xpb = g_respawn_first_xp[ i ] * ( 1 << g_respawn_level[ iPlayer ][ i ] );

			FormatEx( info, ( sizeof info ), "%d", i );
			AddMenuItem( hMenu, info, item, ( g_xp[ iPlayer ] < xpb ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT || g_respawn_level[ iPlayer ][ i ] == g_respawn_maxlevels[ i ] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT ) );
		}
	}

	DisplayMenu( hMenu, iPlayer, 0 );
	return Plugin_Handled;
}

public ShowRespawnMenuHandle( Handle:hMenu, MenuAction:iAction, iPlayer, iOptions ) {
	if( iAction == MenuAction_Select ) {
		new level = g_respawn_level[ iPlayer ][ iOptions ] + 1;
		new xp = g_respawn_first_xp[ iOptions ] * ( 1 << ( level - 1 ) );
		new amount = g_respawn_max_chance[ iOptions ] * level / g_respawn_maxlevels[ iOptions ];

		g_xp[ iPlayer ] -= xp;
		g_respawn_level[ iPlayer ][ iOptions ] = level;

		Save( iPlayer );
		CPrintToChat( iPlayer, "%s Você comprou %s Level %i (%i%%) por {GREEN}%i {NORMAL}XP!", PREFIX, g_respawn_names[ iOptions ], level, amount, xp );

		ShowRespawnMenu( iPlayer );
	}
	else if( ( iAction == MenuAction_Cancel ) ) {
		CmdOpenMenu( iPlayer, 0 );
	}
}

// Nofall menu

public Action:ShowNoFallMenu( iPlayer ) {
	new Handle:hMenu = CreateMenu( ShowNoFallMenuHandle );
	SetMenuTitle( hMenu, "[KINZ HnS.XP] Fall Damage Menu \n \n Seu XP: %d \n \n ", g_xp[ iPlayer ] );

	new level, xp, amount, String:item[ 128 ], String:info[ 35 ];
	for( new i = 0; i < 2; i++ )	{
		if( g_nofall_enabled[ i ] )	{

			level = g_nofall_level[ iPlayer ][ i ] + 1;
			amount = g_nofall_max_chance[ i ] * level / g_nofall_maxlevels[ i ];

			if( g_nofall_level[ iPlayer ][ i ] < g_nofall_maxlevels[ i ] )	{
				xp = g_nofall_first_xp[ i ] * ( 1 << ( level - 1 ) );
				FormatEx( item, sizeof( item ) - 1, "%s: Level %d/%d (%i%%) [%d XP]", g_nofall_names[ i ], level, g_nofall_maxlevels[ i ], amount, xp );
			}
			else {
				FormatEx( item, sizeof( item ) - 1, "%s: Level %d (%i%%) [Máximo!]", g_nofall_names[ i ], g_nofall_maxlevels[ i ], g_nofall_max_chance[ i ] );
			}

			new xpb = g_nofall_first_xp[ i ] * ( 1 << g_nofall_level[ iPlayer ][ i ] );

			FormatEx( info, ( sizeof info ), "%d", i );
			AddMenuItem( hMenu, info, item, ( g_xp[ iPlayer ] < xpb ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT || g_nofall_level[ iPlayer ][ i ] == g_nofall_maxlevels[ i ] ? ITEMDRAW_DISABLED : ITEMDRAW_DEFAULT ) );
		}
	}

	DisplayMenu( hMenu, iPlayer, 0 );
	return Plugin_Handled;
}

public ShowNoFallMenuHandle( Handle:hMenu, MenuAction:iAction, iPlayer, iOptions ) {
	if( iAction == MenuAction_Select ) {
		new level = g_nofall_level[ iPlayer ][ iOptions ] + 1;
		new xp = g_nofall_first_xp[ iOptions ] * ( 1 << ( level - 1 ) );
		new amount = g_nofall_max_chance[ iOptions ] * level / g_nofall_maxlevels[ iOptions ];

		g_xp[ iPlayer ] -= xp;
		g_nofall_level[ iPlayer ][ iOptions ] = level;

		Save( iPlayer );
		CPrintToChat( iPlayer, "%s Você comprou %s Level %i (%i%%) por {GREEN}%i {NORMAL}XP!", PREFIX, g_nofall_names[ iOptions ], level, amount, xp );

		ShowNoFallMenu( iPlayer );
	}
	else if( ( iAction == MenuAction_Cancel ) ) {
		CmdOpenMenu( iPlayer, 0 );
	}
}

// ao connectar no servidor e desconexao do player !!
public OnClientPutInServer( iPlayer ) {
	SDKHook( iPlayer, SDKHook_OnTakeDamage, OnTakeDamage );
}

public OnClientPostAdminCheck( iPlayer ) {
	if( !IsFakeClient( iPlayer ) ) {
		GetClientAuthId( iPlayer, AuthId_Steam2, g_authid[ iPlayer ], sizeof( g_authid[ ] ), false );

		Load( iPlayer );
	}
}

public OnClientDisconnect( iPlayer ) {
	GetClientAuthId( iPlayer, AuthId_Steam2, g_authid[ iPlayer ], sizeof( g_authid[ ] ), false );

	Save( iPlayer );

	g_authid[ iPlayer ][ 0 ] = 0;

	g_first_time[ iPlayer ] = 0;
	g_loaded_data[ iPlayer ] = false;
	g_used_revive[ iPlayer ] = 0;
}

// Database Things
ConnectToDatabase( ) {
	if( g_hDatabase != INVALID_HANDLE ) {
		CloseHandle( g_hDatabase );
	}

	g_hDatabase = INVALID_HANDLE;
	SQL_TConnect( SQL_OnConnect, "xpmod" );
}

public SQL_OnConnect( Handle:owner, Handle:hndl, const String:error[ ], any:data ) {
	if( hndl == INVALID_HANDLE ) {
		LogError( "Database failure: %s", error );
	}
	else {
		g_hDatabase = hndl;
		new String:query[ 512 ];

		Format( query, sizeof(query), "CREATE TABLE IF NOT EXISTS `xpmod` (`authid` TEXT, `name` TEXT, `data` TEXT )" );

		if( !SQL_Query( hndl, query ) )	{
			PrintToServer( "Failed to query (error: %s)", error );
		}
		else {
			PrintToServer( "KINZ: Table 'xpmod' created for SQLite!" );
		}
	}
}

Save( iPlayer ) {
	if( !IsUserAuthorized( iPlayer )  ) return;

	new String:data[ 256 ];
	new len = FormatEx( data, sizeof( data ) - 1, "%i", g_xp[ iPlayer ] );

	for( new i = 0; i < Grenades; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_nade_level[ iPlayer ][ i ] );
	}

	for( new i = 0; i < 2; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_health_level[ iPlayer ][ i ]);
	}

	for( new i = 0; i < 2; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_armor_level[ iPlayer ][ i ]);
	}

	for( new i = 0; i < 2; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_respawn_level[ iPlayer ][ i ]);
	}

	for( new i = 0; i < 2; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_nofall_level[ iPlayer ][ i ]);
	}

	len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_Kills[ iPlayer ] );

	new String:sQuery[ 1024 ], String:name[ 64 ], String:sEscapedName[ 129 ];
	GetClientName( iPlayer, name, sizeof( name ) - 1 );

	SQL_EscapeString( g_hDatabase, name, sEscapedName, sizeof sEscapedName );

	if( g_loaded_data[ iPlayer ] ) {
		FormatEx( sQuery, sizeof( sQuery ) - 1, "UPDATE `xpmod` SET `name` = '%s', `data` = '%s' WHERE `authid` = '%s';", sEscapedName, data, g_authid[ iPlayer ] );
	}

	SQL_TQuery( g_hDatabase, QuerySaveData, sQuery, iPlayer );
}

public QuerySaveData( Handle:owner, Handle:hndl, const String:error[ ], any:data ) {
	if( hndl == INVALID_HANDLE ) {
		LogError( "KINZ: Falha ao salvar! %s", error );
	}
}

NewUser( iPlayer ) {
	g_first_time[ iPlayer ] = 1;

	if( !IsUserAuthorized( iPlayer ) ) return;
	g_xp[ iPlayer ] = ENTRY_XP;
	g_Kills[ iPlayer ] = 0;

	new String:data[ 256 ];
	new len = FormatEx( data, sizeof( data ) - 1, "%i", g_xp[ iPlayer ] );

	for( new i = 0; i < Grenades; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_nade_level[ iPlayer ][ i ] );
	}

	for( new i = 0; i < 2; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_health_level[ iPlayer ][ i ]);
	}

	for( new i = 0; i < 2; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_armor_level[ iPlayer ][ i ]);
	}

	for( new i = 0; i < 2; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_respawn_level[ iPlayer ][ i ]);
	}

	for( new i = 0; i < 2; i++ ) {
		len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_nofall_level[ iPlayer ][ i ]);
	}
	
	len += FormatEx( data[ len ], sizeof( data ) - len - 1, " %i", g_Kills[ iPlayer ] );
	
	new String:sQuery[ 1024 ], String:name[ 64 ], String:sEscapedName[ 129 ];
	GetClientName( iPlayer, name, sizeof( name ) - 1 );

	SQL_EscapeString( g_hDatabase, name, sEscapedName, sizeof sEscapedName );

	Format( sQuery, sizeof( sQuery ), "INSERT INTO `xpmod` ( `name`, `authid`, `data` ) VALUES ( '%s', '%s', '%s' )", sEscapedName, g_authid[ iPlayer ], data );
	SQL_TQuery( g_hDatabase, SQL_OnDefaultCallback, sQuery, iPlayer );
}

public SQL_OnDefaultCallback(Handle:hOwner, Handle:hTable, const String:sError[], any:iData) {
    if( hTable == INVALID_HANDLE ) {
        LogError( "Query failed! %s", sError );
        return false;
    }
	else
		g_loaded_data[ iData ] = true;

    return true;
}

Load( iPlayer ) {
	if( g_hDatabase == INVALID_HANDLE ) return;

	new String:sQuery[ 1024 ];
	GetClientAuthId( iPlayer, AuthId_Steam2, g_authid[ iPlayer ], sizeof( g_authid[ ] ), false );

	FormatEx( sQuery, sizeof( sQuery ), "SELECT `data` FROM `xpmod` WHERE `authid` = '%s'", g_authid[ iPlayer ] );
	SQL_TQuery( g_hDatabase, QueryLoadData, sQuery, iPlayer );
}

public QueryLoadData( Handle:owner, Handle:hndl, const String:error[ ], any:iData ) {
	new iPlayer = iData;

	if( !IsClientInGame( iPlayer ) || IsFakeClient( iPlayer ) || !IsUserAuthorized( iPlayer ) ) {
		return;
	}

	if( hndl != INVALID_HANDLE ) {
		if( SQL_GetRowCount( hndl ) ) {
			new String:data[ 256 ];
			while( SQL_FetchRow( hndl ) ) {
				g_xp[ iPlayer ] = SQL_FetchInt( hndl, 0 );
				SQL_FetchString( hndl, 0, data, sizeof( data ) );

				new sPieces[ 32 ][ PLATFORM_MAX_PATH ];
				ExplodeString( data, " ", sPieces, sizeof( sPieces ), sizeof( sPieces[ ] ) );

				for( new j = 0; j < Grenades; j++ )	{
					g_nade_level[ iPlayer ][ j ] = StringToInt( sPieces[ j + 1 ] );
				}

				for( new i = 0; i < 2; i++ ) {
					g_health_level[ iPlayer ][ i ] = StringToInt(sPieces[ i + 5 ]);
					g_armor_level[ iPlayer ][ i ] = StringToInt(sPieces[ i + 7 ]);
					g_respawn_level[ iPlayer ][ i ] = StringToInt(sPieces[ i + 9 ]);
					g_nofall_level[ iPlayer ][ i ] = StringToInt(sPieces[ i + 11 ]);
				}
				
				g_Kills[ iPlayer ] = StringToInt( sPieces[ 13 ] );
				
				g_loaded_data[ iPlayer ] = true;
			}
		}
		else {
			for( new i = 0; i < Grenades; i++ ) {
				g_nade_level[ iPlayer ][ i ] = 0;
			}

			for( new i = 0; i < 2; i++ ) {
				// Aqui!
				g_health_level[ iPlayer ][ i ] = 0;
				g_armor_level[ iPlayer ][ i ] = 0;
				g_nofall_level[ iPlayer ][ i ] = 0;
				g_respawn_level[ iPlayer ][ i ] = 0;
			}

			NewUser( iPlayer );
		}
	}
}

stock bool:IsValidClient( iPlayer, bool:nobots = true ) { 
    if( iPlayer <= 0 || iPlayer > MaxClients || !IsClientConnected( iPlayer ) || ( nobots && IsFakeClient( iPlayer ) ) ) {
        return false; 
    }
    return IsClientInGame( iPlayer ); 
}  

stock IsUserAuthorized( iPlayer ) return IsPlayer( iPlayer ) && IsClientInGame( iPlayer );

HasTeammateAlive( iPlayer, any:iTeam ) {	
	for( new i = 1; i <= MaxClients; i++ ) {
		if( !( IsClientInGame( i ) ) || ( i == iPlayer ) )  continue;

		if( IsPlayerAlive( i ) && GetClientTeam( i ) == iTeam ) {
			return 1;
		}
	}

	return 0;
}

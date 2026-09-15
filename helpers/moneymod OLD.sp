/*
	Based on XPMod

	Chat Commands:
	/xp - Open the main menu of the plugin.

	To-do list
	
	*Adicionar Skins novas.
	* Refazer sistema de dinheiro e abilidades.
	
	12:20 PM - KINZ: arrumar braco do boneco
	fazer moneymod 

% do moneymod bugada refazer sistema de ganhos de "CASH" ate no hns.
		

	Updates List: 
	0.0.0 > +
	
*/

#include < sourcemod >

#pragma semicolon 1;

#include < smlib >
#include < cstrike >

#include < sdkhooks >
#include < sdktools >
#include < clientprefs >
#include < emitsoundany >

#define GREEN 	0x04
#define NORMAL 	0x07
#define GRAY 	0x0A
#define PINK 	0x0E

#define IsPlayer(%1) (1 <= %1 <= MaxClients)

#define ENTRY_XP	15000

#define MoneyKill 10

public Plugin:myinfo = 
{
	name = "MoneyMod",
	author = "KINZ e mister",
	description = "MOneymod?",
	version = "1.0",
	url = ""
}

new bool:g_bFoundHim[MAXPLAYERS+1];
new Handle:g_hTimeToSync[MAXPLAYERS+1];
new Float:g_fTotalWaitTime[MAXPLAYERS+1];

new g_first_time[ MAXPLAYERS + 1 ];

new g_iReward;
new g_iRundy;
new g_iVipBonus[MAXPLAYERS+1];
new g_iVipTotalBonus[MAXPLAYERS+1];
new g_iMoney[MAXPLAYERS+1];
new g_iHud[MAXPLAYERS+1];
new g_iJoinTotal[MAXPLAYERS+1];
new g_iLuckyM[MAXPLAYERS+1];
new g_iStrike[MAXPLAYERS+1];
new g_iStrikeMoney[MAXPLAYERS+1];

new g_iKills[MAXPLAYERS+1];
new g_iPozycja[MAXPLAYERS+1];
new g_iBoxes[MAXPLAYERS+1];
new g_iOpening[MAXPLAYERS+1];
new g_iOwner[2048];
new g_iKilled[2048];
new g_iTotalMoney[MAXPLAYERS+1];
new g_iPoisoned[MAXPLAYERS];
new g_iPoisonedBy[MAXPLAYERS];
new g_iTopZabicia[10];
new g_iTries[MAXPLAYERS+1];
new g_iModel[MAXPLAYERS+1];
new g_iKillsOnSuccess[MAXPLAYERS+1];

/// VIP START ///
new g_iTrail[MAXPLAYERS+1];
new bool:g_bTrail[MAXPLAYERS+1];
new Handle:g_hTrail;

new const String:g_sTrails[6][32] = {
	"Disabled",
	"Aqua",
	"Purple",
	"Orange",
	"White",
	"Red"
};

new const g_iTrails[6][4] = {
	{0, 0, 0, 0},
	{0, 128, 255, 200},
	{255, 0, 128, 200},
	{255, 140, 0, 200},
	{255, 255, 255, 200},
	{255, 0, 16, 200}
};

new const String:g_sModele[5][32] = {
	"Default Skin",
	"Alice Murray",
	"Pokemon Trainers",
	"Pink Panther",
	"Deadpool"
};
/*
new const String:g_sVIPModel[5][128] = {
	"models/player/tm_phoenix.mdl",
	"models/player/alice_murray/alice_murray_new.mdl",
	"models/player/pokemon_trainer/pokemon_trainer.mdl",
	"models/player/pink_panther_t/pink_panther_t.mdl",
	"models/player/custom_player/marvel/deadpool/deadpool_red_v2.mdl"
};*/
/// VIP END ///

//#define g_iIloscMuzyk 24

#define ILOSC_VIPOW 2

//ignore this part xD
/*
new const String:g_sVips[ILOSC_VIPOW][128] = {
	"", 	//31.09
	"" 	//01.10
};
*/

new String:g_sTopNick[10][64];
new String:g_sTopSteamID[10][64];
new String:g_sSteamID[MAXPLAYERS+1][64];
new Float:g_fVipMul[MAXPLAYERS+1];
new Float:g_fLastOpening[MAXPLAYERS+1];
new Float:g_fLastRegen[MAXPLAYERS+1];

new bool:g_bGrenadeImpact[MAXPLAYERS+1];
new bool:g_bSprawdzilRanking[MAXPLAYERS+1];
new bool:g_bVip[MAXPLAYERS+1];
new bool:g_bOffSound[MAXPLAYERS+1];
new bool:g_bJustOpened[MAXPLAYERS+1];
new bool:g_bMozeHS[MAXPLAYERS+1];
//new const String:g_sMoneySound[2][] = { "*Electronic_Game/0xH1AB.mp3", "*Electronic_Game/0xH1AB.mp3" };

//new Handle:g_hCvarMoney[2];
new Handle:g_hDatabase = INVALID_HANDLE; 
new Handle:g_hHudCookie;
new Handle:g_hSoundCookie;

new Handle:g_hModel;
new Handle:g_hMessageTimer[MAXPLAYERS+1];
new Handle:g_hMulTimer[MAXPLAYERS+1];
new Handle:g_hFixStats[MAXPLAYERS+1];
new Handle:g_hPoisoned[MAXPLAYERS+1];
new Handle:g_hRemoveBox[2048];
new Handle:g_hFinalRemoveBox[2048];
#define MAX_BUTTONS 25
new g_LastButtons[MAXPLAYERS+1];

new BeamSprite;

enum {
	HP = 0,
	REGEN,
	FALLDMG,
	KNIFEDODGE,
	NOFLASH,
	LIFESTEAL,
	PKNIFE,
	FNADERADIUS,
	FNADEDUR
}
//0-9
//0-7
#define SKILLE 9
#define SKILLE_LUCKY 7
new g_iSkill[MAXPLAYERS+1][SKILLE];
new g_iLucky[MAXPLAYERS+1][SKILLE_LUCKY];

new const String:g_sPasywne[SKILLE][35] = {
	"Health",
	"HP Regeneration",
	"Fall Damage Reduction",
	"Knife Dodge Chance",
	"No Flash Chance",
	"Lifesteal",
	"Poisonous Stab Chance",
	"Frostgrenade Radius",
	"Frozen Duration Reducer"
};
new const g_iSkillMax[SKILLE] = {
	5,
	5,
	4,
	3,
	3,
	5,
	4,
	3,
	2
};
new const g_iCost[SKILLE] = {
	295,
	275,
	200,
	400,
	425,
	350,
	400,
	400,
	700
};

new const Float:g_fIncreaser[SKILLE] = {
	0.55,
	0.55,
	0.5,
	0.5,
	0.5,
	0.4,
	0.47,
	0.7,
	0.7
};
new const String:g_sPasywneLucky[SKILLE_LUCKY][64] = {
	"Spawn with Kevlar",
	"+50% Flashbang chance",
	"+45% Frostgrenade chance",
	"+7% Knife Critical chance",
	"+10% Knife Armor",
	"+35% Increased Box Drop",
	"DO NOT BUY!!"
};
new const g_iCostLucky[SKILLE_LUCKY] = {
	4575,
	1750,
	900,
	4070,
	4175,
	5000,
	999999,
};

new const String:g_sHud[2][] = {
	"Hinttext (Simple)",
	"Hinttext++ (Full)"
};

new const String:g_sMulF[10][] = {
	"",
	"",
	"Double kill",
	"Tripple kill",
	"Mega kill",
	"Monster kill",
	"Ludicrous kill",
	"Ludicrous kill",
	"Ludicrous kill",
	"Ludicrous kill"
};

new const String:g_sMul[10][] = {
	"",
	"",
	"<font color='#9999FF'>Double kill",
	"<font color='#9966FF'>Tripple kill",
	"<font color='#CC0066'>Mega kill",
	"<font color='#CC0000'>Monster kill",
	"<font color='#FF3300'>Ludicrous kill",
	"<font color='#FF3300'>Ludicrous kill",
	"<font color='#FF3300'>Ludicrous kill",
	"<font color='#FF3300'>Ludicrous kill"
};

new const Float:g_fMul[10] = {
	0.0,
	0.0,
	0.1,
	0.15,
	0.2,
	0.25,
	0.3,
	0.3,
	0.3,
	0.3
};

new const String:g_sSnd[10][] = {
	"",
	"",
	"*Electronic_Game/doublekill.mp3",
	"*Electronic_Game/triplekill.mp3",
	"*Electronic_Game/megakill.mp3",
	"*Electronic_Game/monsterkill.mp3",
	"*Electronic_Game/ludicrouskill.mp3",
	"*Electronic_Game/ludicrouskill.mp3",
	"*Electronic_Game/ludicrouskill.mp3",
	"*Electronic_Game/ludicrouskill.mp3"
};

public OnPluginStart(){
	new pieces[4];
	new longip = GetConVarInt(FindConVar("hostip"));
	
	pieces[0] = (longip >> 24) & 0x000000FF;
	pieces[1] = (longip >> 16) & 0x000000FF;
	pieces[2] = (longip >> 8) & 0x000000FF;
	pieces[3] = longip & 0x000000FF;

	decl String:NetIP[32];
	Format(NetIP, sizeof(NetIP), "%d.%d.%d.%d", pieces[0], pieces[1], pieces[2], pieces[3]);

	HookEvent("player_death", eventDeath, EventHookMode_Pre);
	HookEvent("round_end", eventRoundEnd);
	HookEvent("player_spawn", eventPlayerSpawn);
	HookEvent("player_blind", eventOnPlayerFlash, EventHookMode_Pre);
	HookEvent("round_freeze_end", eventRoundStart, EventHookMode_PostNoCopy);
	HookUserMessage(GetUserMessageId("TextMsg"), HookTextMsg, true);

		//g_hCvarMoney[0] = FindConVar("cash_player_killed_enemy_default");
		//g_hCvarMoney[1] = FindConVar("cash_player_killed_enemy_factor");
		
	g_hHudCookie = RegClientCookie("EGMoneyMod_HudCk", "EGMoneyMod HudCk", CookieAccess_Protected);
	g_hSoundCookie = RegClientCookie("EGMoneyMod_SoundCk", "EGMoneyMod SoundCk", CookieAccess_Protected);

	g_hModel = RegClientCookie("EGMoneyMod_ModelCk", "EGMoneyMod ModelCk", CookieAccess_Protected);
	g_hTrail = RegClientCookie("EGMoneyMod_TrailCk", "VIP Trail", CookieAccess_Protected);
	g_iRundy = 0;
		
	RegConsoleCmd( "sm_cm", cmdMainMenu ); 
	RegConsoleCmd( "sm_rank", cmdRanking );
	RegConsoleCmd( "sm_top", cmdTopMenu );
			
	for(new i = 0 ; i < 10 ; i++){
		FormatEx(g_sTopSteamID[i], 64, "");
		FormatEx(g_sTopNick[i], 64, "");
		g_iTopZabicia[i] = 0;
	}
		
	ConnectToDatabase();
}

public Action:eventRoundStart(Handle:hEvent, const String:sName[], bool:bDontBroadcast){
	pobierzTop10();
	g_iRundy++;
	
	//if(g_iRundy>=2){
		//CreateTimer(0.4, playSound, _, TIMER_FLAG_NO_MAPCHANGE);
	//}
}

pobierzTop10(){	
	if(g_hDatabase != INVALID_HANDLE){
		new String:sQuery[512];
		FormatEx(sQuery, sizeof sQuery,"SELECT * FROM `moneymod` ORDER BY `kills` DESC LIMIT 10");
		
		SQL_TQuery(g_hDatabase, SQL_Top, sQuery);
	}
}

public SQL_Top(Handle:owner, Handle:hndl, const String:error[], any:data) {
	static iZero;
	new iKtory = 0; 
	if ( hndl != INVALID_HANDLE ) { 
		if(SQL_GetRowCount(hndl)){
			//PrintToChatAll("%d", SQL_GetRowCount(hndl));
			
			while(SQL_FetchRow(hndl)){
				SQL_FetchString(hndl, 0, g_sTopSteamID[iKtory], 64);
				SQL_FetchString(hndl, 1, g_sTopNick[iKtory], 64);
				
				g_iTopZabicia[iKtory] = SQL_FetchInt(hndl, 2);
				
				if(strlen(g_sTopNick[iKtory]) < 2) FormatEx(g_sTopNick[iKtory], 64, "UNNAMED");
				
				//PrintToChatAll("%s", g_sTopSteamID[iKtory]);
				
				iKtory++;
				//iKtory++;
			}
		}
	}
	iZero+=1;
	if(iZero==1){
		CreateTimer(15.0, showInfo);
	}
}

public Action:HookTextMsg(UserMsg:iMsgId, Handle:hMsg, const iPlayers[], iPlayersNum, bool:bReliable, bool:bInit){
	new String:sBuffer[512];
	PbReadString(hMsg, "params", sBuffer, sizeof(sBuffer), 0);
	
	if(StrEqual(sBuffer, "#Player_Cash_Award_Killed_Enemy_Generic", false) || StrEqual(sBuffer, "#Player_Cash_Award_Killed_Enemy", false)){
		return Plugin_Handled;
	}
	return Plugin_Continue;
}  

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max){
	CreateNative("getFnadeBonus", _getFnadeBonus);
	CreateNative("getRank", _getRank);
	CreateNative("getFnadeBonusDur", _getFnadeBonusDur);
	CreateNative("pobierzMaxHp", _pobierzMaxHp);
	CreateNative("dodajXP", _dodajXP);
	CreateNative("dodajLP", _dodajLP);
	
	return APLRes_Success;
}

public _dodajXP(Handle:plugin, numParams){
	new iGracz = GetNativeCell(1);
	new iXP = GetNativeCell(2);
	
	g_iMoney[iGracz] += iXP;
	g_iTotalMoney[iGracz] += iXP;
	
	return _:iXP;
}

public _dodajLP(Handle:plugin, numParams){
	new iGracz = GetNativeCell(1);
	new iXP = GetNativeCell(2);
	
	g_iLuckyM[iGracz] += iXP;
	
	return _:iXP;
}

public _getRank(Handle:plugin, numParams){
	new iGracz = GetNativeCell(1);

   /* Return the value */
	return _:g_iPozycja[iGracz];
}

public _getFnadeBonusDur(Handle:plugin, numParams)
{
	new iGracz = GetNativeCell(1);
	
   /* Return the value */
	return _:g_iSkill[iGracz][FNADEDUR];
}

public _getFnadeBonus(Handle:plugin, numParams)
{
	new iGracz = GetNativeCell(1);
	
   /* Return the value */
	return _:g_iSkill[iGracz][FNADERADIUS];
}

public _pobierzMaxHp(Handle:plugin, numParams)
{
	new iGracz = GetNativeCell(1);
	new iMultiplier = g_iSkill[iGracz][HP] > 3 ? 10 : 8;
	new iMaxHP = 100 + (g_iSkill[iGracz][HP] * iMultiplier);
	
   /* Return the value */
	return _:iMaxHP;
}

public OnMapStart( ){
	
	AddFileToDownloadsTable( "models/chicken/chicken.vvd" );
	AddFileToDownloadsTable( "models/chicken/chicken.phy" );
	AddFileToDownloadsTable( "models/chicken/chicken.mdl" );
	AddFileToDownloadsTable( "models/chicken/chicken.dx90.vtx" );
	AddFileToDownloadsTable( "materials/chicken/chicken.vtf" );
	AddFileToDownloadsTable( "materials/chicken/chicken.vmt" );
	
	PrecacheModel( "models/chicken/chicken.mdl" );
	
	BeamSprite = PrecacheModel( "materials/sprites/laserbeam.vmt" );
	
	/*

	AddFileToDownloadsTable("sound/Electronic_Game/0xH1AB.mp3"); 
	PrecacheSound("Electronic_Game/0xH1AB.mp3");
	
	AddFileToDownloadsTable("sound/Electronic_Game/0xH1AA.mp3"); 
	PrecacheSound("Electronic_Game/0xH1AA.mp3"); 
	
	AddFileToDownloadsTable("sound/Electronic_Game/doublekill.mp3"); 
	PrecacheSound("Electronic_Game/doublekill.mp3"); 
	
	AddFileToDownloadsTable("sound/Electronic_Game/triplekill.mp3"); 
	PrecacheSound("Electronic_Game/triplekill.mp3"); 
	
	AddFileToDownloadsTable("sound/Electronic_Game/megakill.mp3"); 
	PrecacheSound("Electronic_Game/megakill.mp3"); 
	
	AddFileToDownloadsTable("sound/Electronic_Game/monsterkill.mp3"); 
	PrecacheSound("Electronic_Game/monsterkill.mp3"); 
	
	AddFileToDownloadsTable("sound/Electronic_Game/ludicrouskill.mp3"); 
	PrecacheSound("Electronic_Game/ludicrouskill.mp3"); 
	
	AddFileToDownloadsTable("sound/Electronic_Game/0xAC.mp3");
	PrecacheSound("Electronic_Game/0xAC.mp3");
	
	AddFileToDownloadsTable("sound/Electronic_Game/0xAM.mp3");
	PrecacheSound("Electronic_Game/0xAM.mp3");
	
	AddFileToDownloadsTable("sound/Electronic_Game/0xCCA.mp3");
	PrecacheSound( "Electronic_Game/0xCCA.mp3");
	
	
	AddFileToDownloadsTable("sound/Electronic_Game/common1.mp3");
	PrecacheSound("Electronic_Game/common1.mp3");
	
	AddFileToDownloadsTable("sound/Electronic_Game/uncommon1.mp3");
	PrecacheSound("Electronic_Game/uncommon1.mp3");
	
	AddFileToDownloadsTable("sound/Electronic_Game/rare1.mp3");
	PrecacheSound("Electronic_Game/rare1.mp3");
		
	BeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");

		
	//PrecacheModel("models/player/kuristaja/nanosuit/nanosuit.mdl");
	PrecacheModel("models/player/pokemon_trainer/pokemon_trainer.mdl");
	PrecacheModel("models/player/kuristaja/octodad/octodad_black.mdl");
	PrecacheModel("models/player/pink_panther_t/pink_panther_t.mdl");
	PrecacheModel("models/player/custom_player/marvel/deadpool/deadpool_red_v2.mdl");
	PrecacheModel("models/player/custom_player/kuristaja/ak/batman/batmanv2.mdl");
	PrecacheModel("models/player/alice_murray/alice_murray_new.mdl");
	
	static const String:sDot[4][] = {
		".dx90.vtx",
		".mdl",
		".phy",
		".vvd"
	};
	
	new String:sPlik[128];
	
	for(new i ; i < 4 ; i++){
		FormatEx(sPlik, sizeof sPlik, "models/player/pokemon_trainer/pokemon_trainer%s", sDot[i]);
	
		AddFileToDownloadsTable(sPlik);
		
		FormatEx(sPlik, sizeof sPlik, "models/player/kuristaja/octodad/octodad_black%s", sDot[i]);
	
		AddFileToDownloadsTable(sPlik);
		
		FormatEx(sPlik, sizeof sPlik, "models/player/kuristaja/octodad/octodad_tuxedo%s", sDot[i]);
	
		AddFileToDownloadsTable(sPlik);
		
		FormatEx(sPlik, sizeof sPlik, "models/player/kuristaja/octodad/octodad_blue%s", sDot[i]);
	
		AddFileToDownloadsTable(sPlik);
		
		FormatEx(sPlik, sizeof sPlik, "models/player/pink_panther_t/pink_panther_t%s", sDot[i]);
	
		AddFileToDownloadsTable(sPlik);
		
		FormatEx(sPlik, sizeof sPlik, "models/player/alice_murray/alice_murray_new%s", sDot[i]);
	
		AddFileToDownloadsTable(sPlik);
	}
	
	//DEADPOOL - Models
	AddFileToDownloadsTable("models/player/custom_player/marvel/deadpool/deadpool_red_v2.mdl");
	AddFileToDownloadsTable("models/player/custom_player/marvel/deadpool/deadpool_red_v2.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/marvel/deadpool/deadpool_red_v2.phy");
	AddFileToDownloadsTable("models/player/custom_player/marvel/deadpool/deadpool_red_v2.vvd");
	AddFileToDownloadsTable("models/player/custom_player/marvel/deadpool/deadpool_arms_red.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/marvel/deadpool/deadpool_arms_red.mdl");
	AddFileToDownloadsTable("models/player/custom_player/marvel/deadpool/deadpool_arms_red.vvd");
	
	//DEADPOOL - Materials
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/body.vmt");
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/body.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/misc.vmt");
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/misc.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/sword.vmt");
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/sword.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/weapon.vmt");
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/weapon.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/body_n.vtf");
	AddFileToDownloadsTable("materials/models/player/custom_player/marvel/deadpool/misc_n.vtf");
	
	//BATMAN - Models
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/ak/batman/batmanv2.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/ak/batman/batmanv2.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/ak/batman/batmanv2.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/ak/batman/batmanv2.vvd");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/ak/batman/batman_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/ak/batman/batman_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/ak/batman/batman_arms.vvd");
	
	//BATMAN - Materials
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_belt_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_cape_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_cape2_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_cowl_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_gloves_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_hardleather_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_head_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_lacquered_underlayer_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_leather_1_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_leather_2_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_metal_1_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_metal_2_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_nanosuit_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_rubber_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_wetline_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/eye_high.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_belt_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_belt_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_cape_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_cape_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_cowl_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_cowl_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_gloves_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_gloves_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_hardleather_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_hardleather_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_head_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_head_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_lacquered_underlayer_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_lacquered_underlayer_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_leather_1_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_Leather_1_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_leather_2_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_leather_2_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_metal_1_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_metal_1_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_metal_2_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_metal_2_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_nanosuit_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_nanosuit_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_rubber_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_rubber_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/batman_bm3_v2_wetline_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/eyes.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/eyes_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/leather_warp.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/ak/batman/nano_warp.vtf");
	
	//PINK PANTHER - Materials
	AddFileToDownloadsTable("materials/models/player/pink_panther/pink_panther_t.vmt");
	AddFileToDownloadsTable("materials/models/player/pink_panther/pink_panther_t.vtf");
	
	//OCTODAD - Materials
	AddFileToDownloadsTable("materials/models/player/kuristaja/octodad/bowtie.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/octodad/bowtie.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/octodad/octodad_black.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/octodad/octodad_black.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/octodad/octodad_blue.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/octodad/octodad_blue.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/octodad/octodad_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/octodad/tophat.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/octodad/tophat_normal.vtf");
	
	//POKEMON TRAINER - Materials
	AddFileToDownloadsTable("materials/models/player/pokemon_trainer/pokemon_trainer.vmt");
	AddFileToDownloadsTable("materials/models/player/pokemon_trainer/pokemon_trainer.vtf");
	AddFileToDownloadsTable("materials/models/player/pokemon_trainer/pokemon_trainer_eyes.vmt");
	AddFileToDownloadsTable("materials/models/player/pokemon_trainer/pokemon_trainer_eyes.vtf");
	
	//ALICE MURRAY - Materials
	AddFileToDownloadsTable("materials/models/player/alice_murray/dress.vmt");
	AddFileToDownloadsTable("materials/models/player/alice_murray/dress.vtf");
	AddFileToDownloadsTable("materials/models/player/alice_murray/dress_bump.vtf");
	AddFileToDownloadsTable("materials/models/player/alice_murray/hair.vmt");
	AddFileToDownloadsTable("materials/models/player/alice_murray/hair.vtf");
	AddFileToDownloadsTable("materials/models/player/alice_murray/lashes.vmt");
	AddFileToDownloadsTable("materials/models/player/alice_murray/lashes.vtf");
	AddFileToDownloadsTable("materials/models/player/alice_murray/legs.vmt");
	AddFileToDownloadsTable("materials/models/player/alice_murray/legs.vtf");
	AddFileToDownloadsTable("materials/models/player/alice_murray/legs_bump.vtf");
	AddFileToDownloadsTable("materials/models/player/alice_murray/skin.vmt");
	AddFileToDownloadsTable("materials/models/player/alice_murray/skin.vtf");
	AddFileToDownloadsTable("materials/models/player/alice_murray/skin_bump.vtf");

	//NANOSUIT - Models
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit.mdl");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit.dx90.vtx");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit.phy");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit.vvd");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit_arms.mdl");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit_arms.vvd");
	
	//NANOSUIT - Materials
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit.mdl");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit.dx90.vtx");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit.phy");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit.vvd");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit_arms.mdl");
	AddFileToDownloadsTable("models/player/kuristaja/nanosuit/nanosuit_arms.vvd");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_arms.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_arms.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_arms_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_arms_vmodel.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_arms2.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_arms2_vmodel.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_hands.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_hands.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_hands_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_hands_vmodel.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_hands2.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_hands2_vmodel.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_helmet.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_helmet.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_helmet_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_helmet_pt.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_helmet_pt.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_helmet2.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_helmet3.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_legs.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_legs.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_legs_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_legs2.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_legs3.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_torso.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_torso.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_torso_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_torso2.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_visor.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_visor.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/nanosuit/nanosuit_visor_normal.vtf");*/
} 

public Action:eventOnPlayerFlash(Handle:hEvent, const String:sName[], bool:bDontBroadcast){
	new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	new iTeam = GetClientTeam(iClient);
	
	if(IsPlayer(iClient) && IsPlayerAlive(iClient)){
		if(iTeam == CS_TEAM_CT){
			if(g_iSkill[iClient][NOFLASH]){
				new iRandom = GetRandomInt(1, 100);
				new iChance = g_iSkill[iClient][NOFLASH] * 12;
				
				if(iRandom <= iChance){
					PrintHintText(iClient, "<font color='#FF8533'><font size='30'>You didnt get flashed (<b>%d</b>%)", iChance);
					SetEntPropFloat(iClient, Prop_Send, "m_flFlashMaxAlpha", 0.5);
					return Plugin_Changed;
				}
			}
		}
	}
	return Plugin_Continue;
}

new Handle:g_hMoze[MAXPLAYERS+1] = INVALID_HANDLE;

public Action:OnPlayerRunCmd(iClient, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon){
	if(GetEntProp(iClient, Prop_Send, "m_iAccount") != g_iMoney[iClient]){
		SetEntProp(iClient, Prop_Send, "m_iAccount", g_iMoney[iClient]);
	}
	new MoveType:MT_MoveType = GetEntityMoveType(iClient);
		
	if(_:MT_MoveType == 9){
		g_bMozeHS[iClient] = false;
			
		if(g_hMoze[iClient] != INVALID_HANDLE){ 
			KillTimer(g_hMoze[iClient]);
			
			g_hMoze[iClient] = INVALID_HANDLE;
		}
	}
	else if(_:MT_MoveType != 9){
		if(g_hMoze[iClient] == INVALID_HANDLE){
			g_hMoze[iClient] = CreateTimer(3.5, tskMoze, iClient);
		}
	}
	for (new i = 0; i < MAX_BUTTONS; i++){
        new button = (1 << i);
        
        if ((buttons & button)){
            if (!(g_LastButtons[iClient] & button)){
                OnButtonPress(iClient, button);
            }
        }
        else if ((g_LastButtons[iClient] & button)){
            OnButtonRelease(iClient, button);
        }
    }
	
	if(g_bVip[iClient] && g_iTrail[iClient]){
		new Float:fVel[3];
		Entity_GetAbsVelocity(iClient, fVel);
		fVel[2] = 0.0;
		
		new Float:fSpeed = GetVectorLength(fVel);
		
		if(fSpeed==0.0){
			g_bTrail[iClient]=true;
		}
		else{
			if(g_bTrail[iClient]){
				g_bTrail[iClient] = false;
				
				BeamFollowCreate(iClient, g_iTrails[g_iTrail[iClient]]);
			}
		}
	}
	
	g_LastButtons[iClient] = buttons;
	
	if(GetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue") == 0.227){
		if(g_iLucky[iClient][6]){
			SetEntPropFloat(iClient, Prop_Data, "m_flLaggedMovementValue", 1.0);
		}
	}
	
	return Plugin_Continue;
}

public Action:tskMoze(Handle:hTimer, any:client){
	g_hMoze[client] = INVALID_HANDLE;
	
	if(1<= client <= MaxClients && IsClientInGame(client)){
		g_bMozeHS[client] = true;
	}
}

public Action:showInfo(Handle:hTimer){
	new Float:fTime;
	new iRandom = GetRandomInt(1, 2);
		
	if(iRandom == 1)
		PrintToChatAll("{GREEN}[XP]{DEFAULT} Buy{LIGHTGREEN} VIP{DEFAULT} to get more features on this server!");
	else if(iRandom == 2)
		PrintToChatAll("{GREEN}[XP]{LIGHTGREEN} %s{DEFAULT} is the best player with{LIGHTGREEN} %d{DEFAULT} kills!", g_sTopNick[0], g_iTopZabicia[0]);
		
	fTime=GetRandomFloat(120.0, 180.0);
	CreateTimer(fTime, showInfo);
} 

public OnClientDisconnect(iClient){
	GetClientAuthId(iClient, AuthId_Steam2, g_sSteamID[iClient], sizeof(g_sSteamID[]), false);
	SavePlayerData(iClient);
	
	g_first_time[ iClient ] = 0;
	
	ResetData(iClient);
	
	SDKUnhook(iClient, SDKHook_PreThink, eventPreThink);
	SDKUnhook(iClient, SDKHook_OnTakeDamage, OnTakeDamage);
}

OnButtonPress(iClient, ibButton){
	return iClient+ibButton;
}

OnButtonRelease(iClient, ibButton){
	if(ibButton & IN_RELOAD/* && g_iLucky[iClient][7]*/){
		new String:sWeaponName[64];
		GetClientWeapon(iClient, sWeaponName, sizeof(sWeaponName));
		
		if(StrEqual(sWeaponName, "weapon_hegrenade") || StrContains(sWeaponName, "flash") != -1){
			g_bGrenadeImpact[iClient] = !g_bGrenadeImpact[iClient];
			
			PrintHintText(iClient, "<font size='40'>Impact Mode: <b>%s<b>", g_bGrenadeImpact[iClient] ? "<font color='#33CC33'>ON" : "<font color='#FF0000'>OFF");
			EmitSoundToClient(iClient, "*Electronic_Game/0xAC.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC);
		}
	}
}

public OnEntityCreated(iEnt, const String:sClassname[]){	
	if(iEnt <= MaxClients || !IsValidEntity(iEnt) || !(StrEqual(sClassname, "hegrenade_projectile") || StrEqual(sClassname, "flashbang_projectile")))
		return;
	
	SDKHook(iEnt, SDKHook_StartTouch, OnGrenadeTouch);
}

public Action:OnGrenadeTouch(iEnt){
	SDKUnhook(iEnt, SDKHook_Spawn, OnGrenadeTouch);
	new Float:fPos[3];
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", fPos);
	new iOwner = GetEntPropEnt(iEnt, Prop_Data, "m_hOwnerEntity");
	if(iOwner && canReceiveData(iOwner) && g_bGrenadeImpact[iOwner]){
		
		SetEntProp(iEnt, Prop_Data, "m_nNextThinkTick", 1); //for smoke
		SetEntProp(iEnt, Prop_Data, "m_takedamage", 2 );
		SetEntProp(iEnt, Prop_Data, "m_iHealth", 1 );
		SDKHooks_TakeDamage(iEnt, 0, 0, 1.0);
	}
	new String:sClass[64];
	GetEntityClassname(iEnt, sClass, sizeof sClass);
	
	if(StrEqual(sClass, "hegrenade_projectile")) LightCreate(fPos, 7);
	if(StrEqual(sClass, "smokegrenade_projectile")) LightCreate(fPos, 77);
	if(StrEqual(sClass, "flashbang_projectile")) LightCreate(fPos, 777);
}

public Action:cmdTopMenu(id, iArgs){
	new String:sTitle[20], String:sStat[2048];
	FormatEx(sTitle, sizeof sTitle, "[MoneyMod] Top10");
	
	FormatEx(sStat, sizeof sStat, "");
	
	new Handle:hPanel = CreatePanel();
	SetPanelTitle(hPanel, sTitle);
	
	for(new i = 0 ; i < 10 ; i++){
		if(strlen(g_sTopNick[i])){
			Format(sStat, sizeof sStat, "%s%d. %s  [%d kills]\n", sStat, i+1, g_sTopNick[i], g_iTopZabicia[i]);
		}
	}
	
	DrawPanelText(hPanel, sStat);
	DrawPanelItem(hPanel, "", ITEMDRAW_SPACER);
	
	DrawPanelItem(hPanel, "Exit");
	
	SendPanelToClient(hPanel, id, HandleTop, 1000);
 
	CloseHandle(hPanel);

	return Plugin_Handled;
}

public HandleTop(Handle:hMenu, MenuAction:action, id, iOpcja){
}

public Action:cmdLuckyMenu(id){
	new Handle:hMenu = CreateMenu(MenuLuckyHandle);
	SetMenuTitle(hMenu, "[MoneyMod] Lucky Points - %dLP\nLUCKY SKILLs MENU", g_iLuckyM[id]);
	
	new String:sSkill[SKILLE_LUCKY][240], String:sNum[64];
	
	for(new i = 0 ; i < SKILLE_LUCKY ; i++){
		if(!g_iLucky[id][i]){
			FormatEx(sSkill[i], sizeof (sSkill[]), "[  ][%d LP] %s", g_iCostLucky[i], g_sPasywneLucky[i]);
		}
		else{
			FormatEx(sSkill[i], sizeof (sSkill[]), "[X] MASTERED - %s", g_sPasywneLucky[i]);
		}
		FormatEx(sNum, (sizeof sNum), "#choice%d", i+1);
		
		AddMenuItem(hMenu, sNum, sSkill[i]);
	}
	
	DisplayMenu(hMenu, id, 0);

	return Plugin_Handled;
}

public MenuLuckyHandle(Handle:hMenu, MenuAction:action, id, iOpcja){
	if (action == MenuAction_Select){
		if(g_iLucky[id][iOpcja]){
			PrintToChat(id, "{GREEN}[XP]{DEFAULT} You mastered {LIGHTGREEN}%s{DEFAULT} already.", g_sPasywneLucky[iOpcja]);
			PrintHintText(id, "<font color='#6633CC'><font size='28'>This is maxed out already");
		}
		else{
			new iKoszt = g_iCostLucky[iOpcja];
			
			if(g_iLuckyM[id] >= iKoszt){
				g_iLuckyM[id] -= iKoszt;
				//fixMoney(id);
				PrintToChat(id, "{GREEN}[XP]{DEFAULT}You just mastered{LIGHTGREEN} %s{DEFAULT} (-%d{LIGHTGREEN}$).", g_sPasywneLucky[iOpcja], iKoszt);
				g_iLucky[id][iOpcja]++;

				PrintHintText(id, "<font color='#6633CC'><font size='28'>Mastered\n<font size='22'><font color='#FFFFFF'><b>%s</b>", g_sPasywneLucky[iOpcja]);
				new Float:vec[3];
				GetClientAbsOrigin(id, vec);
				
				LightCreate(vec);
				
				vec[2] += 10;
				
				if(!g_bOffSound[id])
					EmitAmbientSound("*Electronic_Game/0xAM.mp3", vec, id, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL);	
			}
			else{
				PrintHintText(id, "<font color='#FF8533'><font size='30'>You need<b> %d</b>LP</font>\n<font color='#FFFFFF'><font size='20'>Not enough funds", iKoszt - g_iLuckyM[id]);
				PrintToChat(id, "{GREEN}[XP]{DEFAULT}Not enough{LIGHTGREEN} Lucky Points{DEFAULT}.{LIGHTGREEN} %d{DEFAULT} needed left.", iKoszt - g_iLuckyM[id]);
			}
		}
		cmdLuckyMenu(id);
	}
	else if (action == MenuAction_Cancel){
		cmdMainMenu(id, 0);
	}
	
	//PrintToChat(id, "Test: %d", iOpcja); // wyszlo: -3
	return 1;
}

LightCreate(Float:Pos[3], i=0)   
{  
	new iEntity = CreateEntityByName("light_dynamic");
	DispatchKeyValue(iEntity, "inner_cone", "0");
	DispatchKeyValue(iEntity, "cone", "80");
	DispatchKeyValue(iEntity, "brightness", "1");
	DispatchKeyValueFloat(iEntity, "spotlight_radius", 250.0);
	DispatchKeyValue(iEntity, "pitch", "90");
	DispatchKeyValue(iEntity, "style", "1");
	switch(i){
		case 0: DispatchKeyValue(iEntity, "_light", "255 0 128 200");
		case 1: DispatchKeyValue(iEntity, "_light", "255 0 0 200");
		case 2: DispatchKeyValue(iEntity, "_light", "0 255 16 200");
		case 7: DispatchKeyValue(iEntity, "_light", "255 0 0 64");
		case 77: DispatchKeyValue(iEntity, "_light", "0 128 255 64");
		case 777: DispatchKeyValue(iEntity, "_light", "255 255 255 64");
		case 7777: DispatchKeyValue(iEntity, "_light", "0 255 32 64");
		case 77777: DispatchKeyValue(iEntity, "_light", "255 128 0 64");
	}
	
	DispatchKeyValueFloat(iEntity, "distance", 500.0);
	//EmitSoundToAll("items/nvg_on.wav", iEntity, SNDCHAN_WEAPON);
	CreateTimer(i == 7777 ? 1.0 : 0.17, Delete, iEntity, TIMER_FLAG_NO_MAPCHANGE);
	DispatchSpawn(iEntity);
	TeleportEntity(iEntity, Pos, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(iEntity, "TurnOn");
}

public Action:Delete(Handle:timer, any:entity)
{
	if(IsValidEdict(entity))
		AcceptEntityInput(entity, "kill");
}

public Action:cmdMoneyMenu(id){

	new Handle:hMenu = CreateMenu(MenuMoneyHandle);
	
	SetMenuTitle(hMenu, "[MoneyMod] - %d$\nMONEY MENU", g_iMoney[id]);
	
	
	new String:sSkill[SKILLE][120], String:sNum[35];
	
	for(new i = 0 ; i < SKILLE ; i++){
		if(g_iSkill[id][i] < g_iSkillMax[i]){
			FormatEx(sSkill[i], sizeof (sSkill[]), "[%d$] %s |%d/%d|", g_iCost[i] + (RoundFloat(g_iCost[i] * (g_fIncreaser[i] * g_iSkill[id][i]))), g_sPasywne[i], g_iSkill[id][i], g_iSkillMax[i] );
		}
		else{
			FormatEx(sSkill[i], sizeof (sSkill[]), "Maxed out---%s", g_sPasywne[i]);
		}
		FormatEx(sNum, (sizeof sNum), "#choice%d", i+1);
		
		AddMenuItem(hMenu, sNum, sSkill[i]);
	}
	
	DisplayMenu(hMenu, id, 0);

	return Plugin_Handled;
}

public MenuMoneyHandle(Handle:hMenu, MenuAction:action, id, iOpcja){
	if (action == MenuAction_Select){
		if(g_iSkill[id][iOpcja] >= g_iSkillMax[iOpcja]){
			PrintToChat(id, "{GREEN}[XP]{DEFAULT} Skill {LIGHTGREEN}%s{DEFAULT} is maxed out already.", g_sPasywne[iOpcja]);
			PrintHintText(id, "<font color='#6633CC'><font size='28'>This is maxed out already");
			//PrintHintText(id, "<font color='#6633CC'><font size='40'><b> %d</b>$ more!</font>\n<font color='#FFFFFF'><font size='18'>Not enough funds", iKoszt - g_iMoney[id]);
		}
		else{
			new iKoszt = g_iCost[iOpcja] + (RoundFloat(g_iCost[iOpcja] * (g_fIncreaser[iOpcja] * g_iSkill[id][iOpcja])));
			
			if(g_iMoney[id] >= iKoszt){
				g_iMoney[id] -= iKoszt;
				PrintToChat(id, "{GREEN}[XP]{LIGHTGREEN} %s{DEFAULT} is now level{LIGHTGREEN} %d{DEFAULT} (-%d{LIGHTGREEN}$).", g_sPasywne[iOpcja], g_iSkill[id][iOpcja]+1, iKoszt);
				g_iSkill[id][iOpcja]++;

				PrintHintText(id, "<font color='#6633CC'><font size='20'>Upgraded\n<b>%s</b><font color='#FFFFFF'>(%d)", g_sPasywne[iOpcja], g_iSkill[id][iOpcja]);
				
				new Float:vec[3];
				GetClientAbsOrigin(id, vec);
				
				LightCreate(vec, 2);
				
				vec[2] += 10;
				
				if(!g_bOffSound[id])
					EmitAmbientSound("*Electronic_Game/0xCCA.mp3", vec, id, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.5);	
			}
			else{
				PrintHintText(id, "<font color='#009900'><font size='30'>You need<b> %d</b>$</font>\n<font color='#FFFFFF'><font size='20'>Not enough funds", iKoszt - g_iMoney[id]);
				PrintToChat(id, "{GREEN}[XP]{DEFAULT}Not enough{LIGHTGREEN} $${DEFAULT}.{LIGHTGREEN} %d${DEFAULT} needed left.", iKoszt - g_iMoney[id]);
			}
		}
		cmdMoneyMenu(id);
	}
	else if (action == MenuAction_Cancel){
		cmdMainMenu(id, 0);
	}
	
	//PrintToChat(id, "Test: %d", iOpcja); // wyszlo: -3
	return 1;
}

public Action:cmdModelMenu(id){
	if(g_bVip[id]){
		new Handle:hMenu = CreateMenu(MenuModelHandle);
		
		SetMenuTitle(hMenu, "VIP | T Models");
		new String:sOpcja[256];
		
		FormatEx(sOpcja, 128, "%s Default Skin", g_iModel[id] == 0 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice1", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Alice Murray", g_iModel[id] == 1 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice2", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Pokemon Trainer", g_iModel[id] == 2 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice3", sOpcja);
			
		FormatEx(sOpcja, 128, "%s Pink Panther", g_iModel[id] == 3 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice4", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Deadpool", g_iModel[id] == 4 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice5", sOpcja);
		
		SetMenuExitButton(hMenu, true);
		DisplayMenu(hMenu, id, 0);
	}
	
	return Plugin_Handled;
}

public MenuModelHandle(Handle:hMenu, MenuAction:action, id, iOpcja){
	if (action == MenuAction_Select){
		if(g_iModel[id] != iOpcja){
			g_iModel[id] = iOpcja;
			
			new String:sModel[64];
			IntToString(iOpcja, sModel, sizeof sModel);
			SetClientCookie(id, g_hModel, sModel);
			
			PrintToChat(id, "{GREEN}[XP]{DEFAULT}Your terrorist model has been set to{LIGHTGREEN} %s", g_sModele[iOpcja]);
			
			if(GetClientTeam(id) == CS_TEAM_T){  
				if(g_bVip[id]){
					//SetEntityModel(id, g_sVIPModel[g_iModel[id]]);
					
				}
			}
		}
		
		cmdModelMenu(id);
	}
}

public Action:cmdTrailsMenu(id){
	if(g_bVip[id]){
		new Handle:hMenu = CreateMenu(MenuTrailsHandle);
		
		SetMenuTitle(hMenu, "VIP | Trail Menu");
		new String:sOpcja[256];
		
		FormatEx(sOpcja, 128, "%s No Trail", g_iTrail[id] == 0 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice1", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Aqua trail", g_iTrail[id] == 1 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice2", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Purple trail", g_iTrail[id] == 2 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice3", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Orange trail", g_iTrail[id] == 3 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice4", sOpcja);
			
		FormatEx(sOpcja, 128, "%s White trail", g_iTrail[id] == 4 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice5", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Red Trail", g_iTrail[id] == 5 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice6", sOpcja);
		
		SetMenuExitButton(hMenu, true);
		DisplayMenu(hMenu, id, 0);
	}
	
	return Plugin_Handled;
}

public MenuTrailsHandle(Handle:hMenu, MenuAction:action, id, iOpcja){
	if (action == MenuAction_Select){
		if(g_iTrail[id] != iOpcja){
			g_iTrail[id] = iOpcja;
			
			new String:sTrail[64];
			IntToString(iOpcja, sTrail, sizeof sTrail);
			SetClientCookie(id, g_hTrail, sTrail);
			
			BeamFollowCreate(id, g_iTrails[g_iTrail[id]]);
			PrintToChat(id, "{GREEN}[XP]{DEFAULT} Your TRAIL has been set to{LIGHTGREEN} %s{DEFAULT}. Stop moving to see the new effect.", g_sTrails[iOpcja]);
		}
		cmdTrailsMenu(id);
	}
	if (iOpcja == -3)
		cmdMainMenu(id, 0);
}

/*
public Action:cmdModelMenu(id){
	if(g_bVip[id]){
		new Handle:hMenu = CreateMenu(MenuModelHandle);
		
		SetMenuTitle(hMenu, "[MoneyMod]\nModel Menu");
		new String:sOpcja[256];
		
		FormatEx(sOpcja, 128, "%s Duke Nukem", g_iModel[id] == 0 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice1", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Doctor Trager", g_iModel[id] == 1 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice2", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Pokemon Trainer", g_iModel[id] == 2 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice3", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Octodad", g_iModel[id] == 3 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice4", sOpcja);
			
		FormatEx(sOpcja, 128, "%s Pink Panther", g_iModel[id] == 4 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice5", sOpcja);
		
		FormatEx(sOpcja, 128, "%s Freddy Krueger", g_iModel[id] == 5 ? "[X]" : "[  ]");
		AddMenuItem(hMenu, "#choice6", sOpcja);
		
		SetMenuExitButton(hMenu, true);
		DisplayMenu(hMenu, id, 0);
	}
	else{
		ShowMOTDPanel(id, "VIP", "http://electronic-game.eu/chuj4.html", MOTDPANEL_TYPE_URL);
	}
	
	return Plugin_Handled;
}
*/


/*
public MenuModelHandle(Handle:hMenu, MenuAction:action, id, iOpcja){
	if (action == MenuAction_Select){
		if(iOpcja != g_iModel[id]){
			g_iModel[id] = iOpcja;
			new String:sModel[64];
			IntToString(g_iModel[id], sModel, sizeof sModel);
			
			SetClientCookie(id, g_hModel, sModel);
			
			PrintToChat(id, "{GREEN}[XP]{DEFAULT}Your terrorist model has been set to{LIGHTGREEN} %s", g_sModele[iOpcja]);
		}
		
		cmdModelMenu(id);
	}
	if (iOpcja == -3)
		cmdMainMenu(id, 0);
}
*/

public Action:cmdMainMenu(id, iArgs){
	//g_iMoney[id]+=500;
	//g_bVip[id] = !g_bVip[id];

	new String:sVip[64];
	FormatEx(sVip, sizeof sVip, "VIP Area | Access: [%s]", g_bVip[id] ? "X" : "  ");
	
	new Handle:hMenu = CreateMenu(MenuMainHandle);
	
	SetMenuTitle(hMenu, "[MoneyMod] - %d$\nMAIN MENU", g_iMoney[id]);
	AddMenuItem(hMenu, "#choice1", "Upgrades [$MONEY$]");
	AddMenuItem(hMenu, "#choice2", "Upgrades [LUCK]\n\nSOCIAL");
	AddMenuItem(hMenu, "#choice3", "My position in ranking");
	AddMenuItem(hMenu, "#choice4", "Top 10 players\n\nMISC");
	AddMenuItem(hMenu, "#choice5", "Inventory");
	AddMenuItem(hMenu, "#choice6", sVip);
	AddMenuItem(hMenu, "#choice7", "Settings");
	SetMenuExitButton(hMenu, true);
	DisplayMenu(hMenu, id, 0);
	return Plugin_Handled;
}

public MenuMainHandle(Handle:hMenu, MenuAction:action, id, iOpcja){
	if (action == MenuAction_Select){
		switch(iOpcja+1){
			case 1:{
				cmdMoneyMenu(id);
			}
			case 2:{
				cmdLuckyMenu(id);
			}
			case 3:{
				cmdMainMenu(id, 0);
				cmdRanking(id, 0);
			}
			case 4:{
				cmdTopMenu(id, 0);
			}
			case 5:{
				if(g_iBoxes[id]){
					cmdInvMenu(id);
				}
				else{
					PrintHintText(id, "<font color='#FFAA00'><font size='30'>Your inventory is <b>empty</b>");
					cmdMainMenu(id, 0);
				}
			}
			case 6:{
				if(g_bVip[id]){
					cmdVipMenu(id);
					//cmdModelMenu(id);
					//PrintHintText(id, "<font color='#FFAA00'><font size='20'>Welcome, more features <b>SOON</b>!");
				}
				else{
					PrintHintText(id, "<font color='#FFAA00'><font size='20'>Contact <b>Juhn</b> to buy vip\n<font color='#FFFFFF'><font size='18'>steamcommunity.com/id/zoubiey");
					cmdMainMenu(id, 0);
				}
			}
			case 7:{
				cmdOptionsMenu(id);
			}
		}		
	}
	else if (action == MenuAction_Cancel){
	}
	else if (action == MenuAction_End){
		CloseHandle(hMenu);
	}
	return 1;
}


public Action:cmdInvMenu(id){
	new Handle:hMenu = CreateMenu(MenuInvHandle);
	
	SetMenuTitle(hMenu, "[MoneyMod] - %d$\nInventory", g_iMoney[id]);
	
	new String:sOpcja[2][64];
	FormatEx(sOpcja[0], sizeof sOpcja[] - 1, "Open Box (count: %d)", g_iBoxes[id]);
	AddMenuItem(hMenu, "#choice1", sOpcja[0]);
	SetMenuExitButton(hMenu, true);
	
	DisplayMenu(hMenu, id, 0);
	
	return Plugin_Handled;
}

public MenuInvHandle(Handle:hMenu, MenuAction:action, id, iOpcja){

	if (action == MenuAction_Select){
		switch(iOpcja){
			case 0:{
				if(!g_bJustOpened[id]){
					if(g_iBoxes[id]){
						g_bJustOpened[id]=true;
						g_iOpening[id] = 25;
						g_iBoxes[id]--;
						g_fLastOpening[id] = GetGameTime();
						if(g_iBoxes[id]){
							cmdInvMenu(id);
						}
						else{
							cmdMainMenu(id, 0);
						}
					}
					else{
						cmdMainMenu(id, 0);
					}
				}
				else{
					PrintToChat(id, "{darkred}You are opening BOX already.. just{olive} wait{darkred}!");
					cmdInvMenu(id);
				}
			}
		}		
	}
	if (iOpcja == -3)
		cmdMainMenu(id, 0);
	
	return 1;
}

public Action:cmdOptionsMenu(id){
	new Handle:hMenu = CreateMenu(MenuOptionsHandle);
	
	SetMenuTitle(hMenu, "[MoneyMod] - %d$\nSETTINGS", g_iMoney[id]);
	
	new String:sOpcja[2][64];
	FormatEx(sOpcja[0], sizeof sOpcja[] - 1, "Plugin messages: %s", g_sHud[g_iHud[id]]);
	FormatEx(sOpcja[1], sizeof sOpcja[] - 1, "Emit and receive audio effects: %s", g_bOffSound[id] ? "[  ]" : "[X]");
	AddMenuItem(hMenu, "#choice1", sOpcja[0]);
	AddMenuItem(hMenu, "#choice2", sOpcja[1]);
	SetMenuExitButton(hMenu, true);
	
	DisplayMenu(hMenu, id, 0);
	
	return Plugin_Handled;
}

public MenuOptionsHandle(Handle:hMenu, MenuAction:action, id, iOpcja){

	if (action == MenuAction_Select){
		switch(iOpcja){
			case 0:{
				g_iHud[id] = g_iHud[id] == 1 ? 0 : 1;
				if(AreClientCookiesCached(id)){
					new String:sCookie[2];
					
					IntToString(g_iHud[id], sCookie, sizeof(sCookie));
 
					SetClientCookie(id, g_hHudCookie, sCookie);
				}
				cmdOptionsMenu(id);
			}
			case 1:{				
				cmdOptionsMenu(id);
			}
			case 2:{
				g_bOffSound[id] = !g_bOffSound[id];
				
				if(AreClientCookiesCached(id)){
					new String:sCookie[2];
					
					IntToString(_:g_bOffSound[id], sCookie, sizeof(sCookie));
 
					SetClientCookie(id, g_hSoundCookie, sCookie);
				}
				cmdOptionsMenu(id);
			}
		}		
	}
	if (iOpcja == -3)
		cmdMainMenu(id, 0);
	
	return 1;
}

public ResetData(id){
	if(g_hMessageTimer[id] != INVALID_HANDLE) KillTimer(g_hMessageTimer[id]);
	g_hMessageTimer[id] = INVALID_HANDLE;
	
	if(g_hPoisoned[id] != INVALID_HANDLE) KillTimer(g_hPoisoned[id]);
	g_hPoisoned[id] = INVALID_HANDLE;
	
	if(g_hFixStats[id] != INVALID_HANDLE) KillTimer(g_hFixStats[id]);
	g_hFixStats[id] = INVALID_HANDLE;
	
	if(g_hTimeToSync[id] != INVALID_HANDLE) KillTimer(g_hTimeToSync[id]);
	
	g_hTimeToSync[id] = INVALID_HANDLE;
	
	if(g_hMulTimer[id] != INVALID_HANDLE) KillTimer(g_hMulTimer[id]);
	g_hMulTimer[id] = INVALID_HANDLE;
	
	g_fLastRegen[id] = GetGameTime();
	g_fLastOpening[id] = GetGameTime();
	
	g_bFoundHim[id] = false;
	g_fTotalWaitTime[id] = 0.0;
	for(new i = 0 ; i < SKILLE ; i++)
		g_iSkill[id][i] = 0;
	
	g_iMoney[id] = 0;
	g_iTotalMoney[id] = 0;
	g_iPoisoned[id] = 0;
	g_iPoisonedBy[id] = 0;
	g_iKillsOnSuccess[id] = 0;
	for(new i = 0 ; i < SKILLE_LUCKY ; i++)
		g_iLucky[id][i] = 0;
	
	g_iLuckyM[id] = 0;
	
	g_iKills[id]=0;
	g_iStrike[id]=0;
	g_iStrikeMoney[id]=0;
	
	g_bJustOpened[id]=false;
	g_iOpening[id] = -1;
	g_iBoxes[id]=0;
	
	g_bSprawdzilRanking[id] = false;
	g_iPozycja[id] = 0;
}
/*
public Action:checkDb(Handle:hTimer, any:id){
	g_hTimeToSync[id] = INVALID_HANDLE;
	
	if(canReceiveData(id)){
		if(GetClientTeam(id) == CS_TEAM_CT || GetClientTeam(id) == CS_TEAM_T){
			if(g_bDbInUse){	
				if(g_hTimeToSync[id] != INVALID_HANDLE){
					KillTimer(g_hTimeToSync[id]);
					
					g_hTimeToSync[id] = INVALID_HANDLE;
				}
				new Float:fTime=GetRandomFloat(0.2, 0.7);
				g_fTotalWaitTime[id]+=fTime;
				
				g_hTimeToSync[id] = CreateTimer(fTime, checkDb, id);
				
				PrintToChat(id, "{darkred}Approx wait time: ({blue}%.1f{darkred} second%s)", fTime, FloatAbs(fTime) == 1 ? "" : "s");
				
			}
			else{
				GetPlayerData(id);
				g_iQueue--;
				PrintToChat(id, "{darkred}AUTH[{blue}1{orange}/{blue}2{darkred}] Queue position:{blue} 0{lime} -{olive} Connecting");
			}
		}
	}
	else{
		g_iQueue--;
	}
}
*/

public OnClientPostAdminCheck(id){
	new AdminId:admin = GetUserAdmin(id);
	if(admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom1) == true){
		g_bVip[id] = true;
	}
	else{
		g_bVip[id] = false;
	}
}

public OnClientPutInServer(id){
	GetClientAuthId(id, AuthId_Steam2, g_sSteamID[id], sizeof(g_sSteamID[]), false);
	
	/*
	g_bVip[id]=false;

	for(new i = 0 ; i < ILOSC_VIPOW ; i++){
		if(StrEqual(g_sSteamID[id], g_sVips[i])){
			g_bVip[id]=true;
			break;
		}
	}
	
	new AdminId:admin = GetUserAdmin(id);
	if(admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Custom1) == true){
		g_bVip[id]=true;
	}
	*/
	
	g_iTries[id]=0;
	SDKHook(id, SDKHook_PreThink, eventPreThink);
	SDKHook(id, SDKHook_OnTakeDamage, OnTakeDamage);
	
	ResetData(id);
	GetPlayerData(id);
}

public OnConfigsExecuted(){
	g_iReward = MoneyKill;
}

public eventPlayerSpawn(Handle:hEvent, const String:sName[], bool:bDontBroadcast){
	new iClid = GetEventInt(hEvent, "userid");
	new id = GetClientOfUserId(iClid);
	
	if(canReceiveData(id)){
		SetEntityRenderFx(id, RENDERFX_NONE);
		SetEntityRenderColor(id, 255, 255, 255, 255);
			
		SetEntityRenderMode(id, RENDER_NORMAL);
		
		if(g_hFixStats[id] != INVALID_HANDLE){ 
			KillTimer(g_hFixStats[id]);
					
			g_hFixStats[id] = INVALID_HANDLE;
		}
		
		g_hFixStats[id] = CreateTimer(0.3, fixStaty, id);
	}
}

public Action:eventDeath(Handle:hEvent, const String:sName[], bool:bDontBroadcast){
	new iDane[3], Float:fMul, String:sPName[64];
	fMul = GetRandomFloat(1.4, 2.4);
	
	iDane[0] = GetClientOfUserId(GetEventInt(hEvent, "attacker"));
	iDane[1] = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	iDane[2] = GetClientOfUserId(GetEventInt(hEvent, "assister"));
	
	new iNum = GetClientCount(true);
	
	if(IsPlayer(iDane[2]) && IsClientConnected(iDane[2]) && IsPlayer(iDane[1]) && iDane[1] != iDane[2]){
		if(iNum>=2){
			new Float:fRandom2 = GetRandomFloat(3.0, 8.0);
			
			if(g_bVip[iDane[2]]) fRandom2 *= fMul;
			
			new iFinal = RoundFloat(fRandom2);
			new String:sNamee[64];
			GetClientName(iDane[1], sNamee, sizeof sNamee);
			
			PrintHintText(iDane[2], "<font color='#00CC33'><font size='40'>+<b>%d</b>$</b></font>\n<font color='#006600'><font size='20'>For assisting in killing <b>%s</b>", iFinal, sNamee);
			
			addMoney(iDane[2], iFinal);
		}
	}
	
	if(!(iDane[0] && iDane[1]) || iDane[0] == iDane[1]) return Plugin_Continue;
	if(iNum<2){
		PrintToChat(iDane[0], "Minimum 4 players are needed");
		return Plugin_Continue;
	}
	for(new i = 0 ; i < 3 ; i++){
		if(canReceiveData(iDane[i])){
			if(i==1 && iDane[1] && iDane[0] && iDane[1] != iDane[0] && g_iHud[iDane[0]]){
				GetClientName(iDane[1], sPName, sizeof sPName);
				PrintToChat(iDane[0], "{default}_____________________________");
				PrintToChat(iDane[0], "{darkred}__KILLED {default}%s{darkred}", sPName);
			}
			if(i==0 && iDane[0] != iDane[1]){
				g_iKills[iDane[0]]++;

				if(g_hPoisoned[iDane[1]] != INVALID_HANDLE){
					KillTimer(g_hPoisoned[iDane[1]]);
					g_hPoisoned[iDane[1]] = INVALID_HANDLE;
					g_iPoisoned[iDane[1]] = 0;
					g_iPoisonedBy[iDane[1]] = 0;
				}
				
				if(!g_bVip[iDane[0]]) fMul = 1.00;
				g_fVipMul[iDane[0]]=fMul;
				
				new iAmt = RoundFloat(g_iReward*fMul);
				
				//g_iMoney[iDane[0]] += iAmt;
				g_iVipTotalBonus[iDane[0]] = iAmt;
				g_iVipBonus[iDane[0]] = iAmt - g_iReward;
	
				g_iStrike[iDane[0]]++;
				
				new iFinal = iAmt + RoundFloat(iAmt * g_fMul[g_iStrike[iDane[0]]]);
				g_iStrikeMoney[iDane[0]] += iFinal;
				if(g_iStrike[iDane[0]] < 2){
					new String:sNamee[64];
					GetClientName(iDane[1], sNamee, sizeof sNamee - 1);
					PrintHintText(iDane[0], "<font color='#00CC33'><font size='40'>+<b>%d</b>$</b></font>\n<font color='#006600'><font size='20'>For killing <b>%s</b>", iFinal, sNamee);
				}
				else{
					PrintHintText(iDane[0], "<font color='#00CC33'><font size='40'>+<b>%d</b>$</b> TOTAL</font>\n<font size='20'>You did a <b>%s</b>", g_iStrikeMoney[iDane[0]], g_sMul[g_iStrike[iDane[0]]]);
					new Float:vec[3];
					GetClientAbsOrigin(iDane[0], vec);
					vec[2] += 10;
					
					if(!g_bOffSound[iDane[0]])
						EmitAmbientSound(g_sSnd[g_iStrike[iDane[0]]], vec, iDane[0], SNDLEVEL_RAIDSIREN, SND_NOFLAGS, 0.2);	
				}
				
				if(g_iLucky[iDane[0]][5] || GetRandomInt(1, 100) <= 65){
					new Float:fOrigin[3];
					GetClientAbsOrigin(iDane[1], fOrigin);
					fOrigin[2]-=10.0;
					
					createBox(iDane[0], iDane[1], fOrigin);
				}
				
				addMoney(iDane[0], iFinal);
				//PrintToChatAll("Test: %d", iAmt + RoundFloat(iAmt * g_fMul[g_iStrike[iDane[0]]]));
				
				if(g_hMulTimer[iDane[0]] != INVALID_HANDLE){ 
					KillTimer(g_hMulTimer[iDane[0]]);
					
					g_hMulTimer[iDane[0]] = INVALID_HANDLE;
				}
		
				g_hMulTimer[iDane[0]] = CreateTimer(GetRandomFloat(12.25, 15.0), tskMulFix, iDane[0]);

				if(g_hMessageTimer[iDane[0]] != INVALID_HANDLE){ 
					KillTimer(g_hMessageTimer[iDane[0]]);
					
					g_hMessageTimer[iDane[0]] = INVALID_HANDLE;
					
					//PrintToChat(iDane[0], "{lime}+%s$%d{lime}:{default} %s [{lime}%.2f{default}x multiplier]", g_bVip[iDane[0]] ? "{lime}" : "{default}", g_iVipBonus[iDane[0]], g_bVip[iDane[0]] ? "VIP BONUS" : "NO BONUS", fMul);
					
					if(g_iStrike[iDane[0]] >= 2){
						PrintToChat(iDane[0], "{darkred}KILLSTRIKE MONEY BONUS: {lime}+%d{lime}{default}%s [{darkred}%s{default}]", RoundFloat(g_fMul[g_iStrike[iDane[0]]] * 100.0), '%',g_sMulF[g_iStrike[iDane[0]]]);
					}
				}
			
				g_hMessageTimer[iDane[0]] = CreateTimer(0.2, tskMessageFix, iDane[0]);
				
				if(g_hMulTimer[iDane[1]] != INVALID_HANDLE){ 
					KillTimer(g_hMulTimer[iDane[1]]);
						
					g_hMulTimer[iDane[1]] = INVALID_HANDLE;
			
					g_hMulTimer[iDane[1]] = CreateTimer(0.5, tskMulFix, iDane[1]);
				}
			}
			/*
			//EmitSoundToClient(iDane[0], g_sMoneySound[GetRandomInt(0, 1)], iDane[0]);	
			new iRandom = GetRandomInt(0, 1);
			//ClientCommand(iDane[0], "play %s", g_sMoneySound[iRandom]);

			new Float:vec[3];
			GetClientAbsOrigin(iDane[1], vec);
			vec[2] += 10;
			EmitAmbientSound(g_sMoneySound[iRandom], vec, iDane[1], SNDLEVEL_ROCKET);	
			//PrintToChat(iDane[0], "%s", g_sMoneySound[iRandom]);
			*/
			//EmitSoundToClientAny(iDane[0], "Electronic_Game/0xH1AB.mp3"); 
			
			if(!g_bOffSound[iDane[0]]){
				new Float:vec[3];
				GetClientAbsOrigin(iDane[1], vec);
				vec[2] += 10;
				if(GetRandomInt(1, 100) <= 50){
					EmitAmbientSound("*Electronic_Game/0xH1AB.mp3", vec, iDane[0], SNDLEVEL_RAIDSIREN);	
				}
				else{
					EmitAmbientSound("*Electronic_Game/0xH1AA.mp3", vec, iDane[0], SNDLEVEL_RAIDSIREN);	
				}
			}
			
		}
	}
	return Plugin_Continue;
}

public Action:fixStaty(Handle:hTimer, any:id){
	g_hFixStats[id] = INVALID_HANDLE;
	
	if(canReceiveData(id)){
		
		//if( g_first_time[ id ] )
		//{
			//..g_iMoney[ id ] = ENTRY_XP;
			//
			PrintToChat( id, "%c[%cCASHMOD%c]%c É a sua primeira vez jogando esse HideNSeek CashMod, você ganhou %cR$%i", GRAY, PINK, GRAY, NORMAL, GREEN, ENTRY_XP );
			PrintToChat( id, "%c[%cCASHMOD%c]%c Você ganha cash baseado na sua jogabilidade, Digite %c!cashmod%c para mais informação", GRAY, PINK, GRAY, NORMAL, GREEN, NORMAL );
			PrintToChat( id, "%c[%cCASHMOD%c]%c Escreva %c/cm %cpara ver o que você pode comprar!", GRAY, PINK, GRAY, NORMAL, GREEN, NORMAL );
			
		//	g_first_time[ id ] = 0;
		//}
		if(GetClientTeam(id) == CS_TEAM_CT || GetClientTeam(id) == CS_TEAM_T){
			if(g_bVip[id]){
				if(GetClientTeam(id) == CS_TEAM_T){
					//SetEntityModel(id, g_sVIPModel[g_iModel[id]]);
				}
				else{
					//SetEntityModel(id, "models/player/custom_player/kuristaja/ak/batman/batmanv2.mdl");
				}
				SetEntityRenderColor(id, 255, 255, 255, 255);
			}
			//SetEntProp(id, Prop_Send, "m_iAmmo", 0, 4, 15);
			
			//GivePlayerItem(id, "weapon_awp"); //testing
			
			SetEntProp(id, Prop_Data, "m_iFrags",  g_iKills[id]);
			CS_SetClientContributionScore(id, g_iKills[id]);
			
			if(IsPlayerAlive(id)){
				if(g_iSkill[id][HP]){
					new iMultiplier = g_iSkill[id][HP] > 3 ? 10 : 8;
			
					SetEntProp(id, Prop_Data, "m_iHealth", 100 + (g_iSkill[id][HP] * iMultiplier));
					
					PrintHintText(id, "<font color='#00FF99'><font size='40'>+<b>%d</b> MAXIMUM HP</font>\n<font color='#FFFFFF'><font size='18'>HP skill level <b>%d</b>", g_iSkill[id][HP] * iMultiplier, g_iSkill[id][HP]);
					//SetEntProp(id, Prop_Send, "m_ArmorValue", (g_iSkill[id][KEVLAR] * 25));
				}
				if(g_iLucky[id][0]){
					SetEntProp(id, Prop_Send, "m_ArmorValue", 100);
				}
				if(g_iLucky[id][1]){
					new iSzansa = GetRandomInt(1, 100);
					
					if(iSzansa <= 50){
						GivePlayerItem(id, "weapon_flashbang");
					}
				}
				if(g_iLucky[id][2]){
					new iSzansa = GetRandomInt(1, 100);
					
					if(iSzansa <= 45){
						GivePlayerItem(id, "weapon_smokegrenade");
					}
				}
			}
		}
	}
}

createBox(iOwner, iKilled, Float:fOrigin[3]){	
	new iEnt = CreateEntityByName("prop_physics_override");
	DispatchKeyValue(iEnt, "model", "models/chicken/chicken.mdl");
	
	TeleportEntity(iEnt, fOrigin, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iEnt);
	
	AcceptEntityInput(iEnt, "enablemotion");
	
	SetEntityMoveType(iEnt, MOVETYPE_VPHYSICS);
	SetEntProp(iEnt, Prop_Send, "m_usSolidFlags", 0x0008); 
	SetEntProp(iEnt, Prop_Data, "m_nSolidType", 6);
	SetEntProp(iEnt, Prop_Send, "m_CollisionGroup", 1);
	
	g_iOwner[iEnt] = iOwner;
	g_iKilled[iEnt] = iKilled;
	
	SDKHook(iEnt, SDKHook_Touch, OnBoxTouch);
	
	BeamFollowCreate(iEnt, {0, 255, 32, 128});
	
	TeleportEntity(iEnt, NULL_VECTOR, NULL_VECTOR, Float:{0.0, 0.0, 2000.0});
	
	if(g_hRemoveBox[iEnt] != INVALID_HANDLE){ 
		KillTimer(g_hRemoveBox[iEnt]);
			
		g_hRemoveBox[iEnt] = INVALID_HANDLE;
	}
	if(g_hFinalRemoveBox[iEnt] != INVALID_HANDLE){ 
		KillTimer(g_hFinalRemoveBox[iEnt]);
			
		g_hFinalRemoveBox[iEnt] = INVALID_HANDLE;
	}
	
	g_hRemoveBox[iEnt] = CreateTimer(10.0, tskReBox, iEnt);
}

public Action:tskReBox(Handle:hTimer, any:iEnt){
	g_hRemoveBox[iEnt] = INVALID_HANDLE;
	
	if(IsValidEdict(iEnt) && IsValidEntity(iEnt) && !IsPlayer(iEnt)){
		SetEntityRenderMode(iEnt, RENDER_TRANSALPHA);
		SetEntityRenderFx(iEnt, RENDERFX_EXPLODE);
		SetEntityRenderColor(iEnt, 255, 0, 0, 128);
		
		g_hFinalRemoveBox[iEnt] = CreateTimer(5.0, tskFinalReBox, iEnt);
	}
}

public Action:tskFinalReBox(Handle:hTimer, any:iEnt){
	g_hFinalRemoveBox[iEnt] = INVALID_HANDLE;
	
	if(IsValidEdict(iEnt) && IsValidEntity(iEnt) && !IsPlayer(iEnt)){
		RemoveEdict(iEnt);
	}
}

public OnBoxTouch(iEnt, iGracz){
	if(!IsPlayer(iGracz) || !IsPlayerAlive(iGracz) || iGracz == g_iKilled[iEnt]){ return; }
	
	if(g_iOwner[iEnt] == iGracz){	
		if(g_hRemoveBox[iEnt] != INVALID_HANDLE){ 
			KillTimer(g_hRemoveBox[iEnt]);
				
			g_hRemoveBox[iEnt] = INVALID_HANDLE;
		}
		if(g_hFinalRemoveBox[iEnt] != INVALID_HANDLE){ 
			KillTimer(g_hFinalRemoveBox[iEnt]);
				
			g_hFinalRemoveBox[iEnt] = INVALID_HANDLE;
		}
		
		g_iBoxes[iGracz]++;
		PrintHintText(iGracz, "<font color='#FFAA00'><font size='36'>Collected a <b>BOX</b></font>\n<font size='18'>Total in inventory:<font color='#FFFFFF'><b> %d</b>", g_iBoxes[iGracz]);
		g_iOwner[iEnt]=0;
		g_iKilled[iEnt]=0;
		
		new Float:fPos[3];
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", fPos);
		
		LightCreate(fPos, 7777);
		
		SDKUnhook(iEnt, SDKHook_StartTouch, OnBoxTouch);
		RemoveEdict(iEnt);
	}
	else{
		if(IsClientConnected(g_iOwner[iEnt])){
			new String:sName[64];
			GetClientName(g_iOwner[iEnt], sName, sizeof sName);
			
			PrintHintText(iGracz, "<font color='#C8C800'><font size='36'>This <b>BOX</b> belongs to</font>\n<font color='#FFFFFF'>%s", sName);
		}
		else{
			PrintHintText(iGracz, "<font color='#C8C800'><font size='36'>This <b>BOX</b> doesnt belong to</font>\n<font color='#FFFFFF'>YOU");
		}
	}
}

poisonPlayer(victim, attacker){
	new String:sName[2][64];
	GetClientName(victim, sName[0], sizeof sName[]); GetClientName(attacker, sName[1], sizeof sName[]);
							
	PrintHintText(attacker, "<font color='#AA0000'><font size='34'>Poisonous Stab</font>\n<font size='12'>You poisoned<font color='#FFDFDF'><b> %s</b>", sName[0]);
	PrintHintText(victim, "<font color='#FF0000'><font size='34'>WARNING</font>\n<font size='12'>You have been poisoned by<font color='#FFDFDF'><b> %s</b>", sName[1]);
	g_iPoisoned[victim]=3;
	g_iPoisonedBy[victim]=attacker;
								
	g_hPoisoned[victim] = CreateTimer(2.0, tskPoison, victim);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(IsPlayer(victim)  && IsClientConnected(victim)){
		if(damagetype & DMG_FALL && g_iSkill[victim][FALLDMG]){
			damage -= (damage * (0.2 * float(g_iSkill[victim][FALLDMG])));
		}
		if(IsPlayer(attacker) && canReceiveData(attacker) && GetClientTeam(victim) != GetClientTeam(attacker)){
			if(g_hMulTimer[attacker] != INVALID_HANDLE){ 
				KillTimer(g_hMulTimer[attacker]);
					
				g_hMulTimer[attacker] = INVALID_HANDLE;
			}
		
			g_hMulTimer[attacker] = CreateTimer(GetRandomFloat(12.25, 15.0), tskMulFix, attacker);
			
			if(IsPlayerAlive(attacker)){
				if(g_iSkill[attacker][LIFESTEAL]){
					if(IsPlayerAlive(attacker) && GetClientTeam(attacker) != GetClientTeam(victim)){
						new iMultiplier = g_iSkill[attacker][HP] > 3 ? 10 : 8;
						new iMaxHP = 100 + (g_iSkill[attacker][HP] * iMultiplier);

						new iHp = GetEntProp(attacker, Prop_Data, "m_iHealth");
						new Float:fDmg = (damage * (float(g_iSkill[attacker][LIFESTEAL]) * 0.075));
						new iDmg = RoundFloat(fDmg);
						
						new iDodane = iHp + iDmg;

						if(iDodane < iMaxHP){
							SetEntProp(attacker, Prop_Data, "m_iHealth", iDodane);
						}
						else{
							SetEntProp(attacker, Prop_Data, "m_iHealth", iMaxHP);
						}
							
						//PrintHintText(attacker, "<font color='#EE0000'><font size='34'>LIFESTEAL</font>\n<font color='#FFDFDF'><font size='14'>+<b>%d</b>HP", iDmg);
					}
				}
				if(g_iSkill[attacker][PKNIFE]){
					new String:sWeapon[32];
					GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
		  
					if(StrEqual(sWeapon, "weapon_knife", false) && damagetype == 4100){
						if(g_hPoisoned[victim] == INVALID_HANDLE){ 
							if(GetRandomInt(1, 100) <= (g_iSkill[attacker][PKNIFE]*4.5)){
								poisonPlayer(victim, attacker);
							}
						}
					}
				}
			}
			if(g_iLucky[attacker][3]){
				new String:sWeapon[32];
				GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
		  
				if(StrEqual(sWeapon, "weapon_knife", false) && damagetype == 4100){
					if(GetRandomInt(0, 100) <= 7){
						new iRandom = GetRandomInt(1, 100);
					
						if(iRandom <= 7){
							damage *= GetRandomFloat(1.65,1.8);
						}
						
						new String:sName[2][64];
						GetClientName(attacker, sName[0], sizeof sName[]);
						GetClientName(victim, sName[1], sizeof sName[]);
						
						PrintHintText(victim, "<font color='#FF5E5E'><font size='34'>You got critically hit</font>\n<font color='#FFDFDF'><font size='14'>by<b> %s</b>", sName[0]);
						PrintHintText(attacker, "<font color='#FF5E5E'><font size='34'>Critical Hit</font>\n<font color='#FFDFDF'><font size='14'>you did 1.7xDMG to<b> %s</b>", sName[1]);
					}
				}
			}
		}
		if(g_iLucky[victim][4]){
			if(IsPlayer(attacker)){
				new String:sWeapon[32];
				GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
		  
				if(StrEqual(sWeapon, "weapon_knife", false) && damagetype == 4100){
					damage *= 0.9;
				}
			}
		}
		if(g_iSkill[victim][KNIFEDODGE] && IsPlayer(attacker) && IsClientInGame(attacker)){
			new String:sWeapon[32];
			GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
			
			if(StrEqual(sWeapon, "weapon_knife", false) && damagetype == 4100){
				if(GetRandomInt(1, 100) <= (g_iSkill[victim][KNIFEDODGE]*5)){
					new String:sName[2][64];
					GetClientName(attacker, sName[0], sizeof sName[]);
					GetClientName(victim, sName[1], sizeof sName[]);
				
					PrintHintText(victim, "<font color='#FF5E5E'><font size='34'>You dodged knife damage from</font>\n<font color='#FFDFDF'><font size='14'><b> %s</b>", sName[0]);
					PrintHintText(attacker, "<font color='#180000'><font size='34'>KNIFE DODGE by</font>\n<font color='#FFDFDF'><font size='14'><b>%s</b>", sName[1]);
					
					damage *= 0.0;
					return Plugin_Handled;
				}
			}
		}
	}
	
	return Plugin_Changed;
}

public eventPreThink(id){
	if(g_iSkill[id][REGEN]){
		if(GetGameTime() - g_fLastRegen[id] >= 5.0){
			if(IsPlayerAlive(id)){
				new iMultiplier = g_iSkill[id][HP] > 3 ? 10 : 8;
				new iMaxHP = 100 + (g_iSkill[id][HP] * iMultiplier);
					
				new iHp = GetEntProp(id, Prop_Data, "m_iHealth");
				new iDodane = iHp + g_iSkill[id][REGEN];
					
				//PrintToChatAll("iMult = %d | iMaxHP = %d | iHp = %d | iDodane = %d", iMultiplier, iMaxHP, iHp, iDodane);
					
				if(iDodane < iMaxHP){
					SetEntProp(id, Prop_Data, "m_iHealth", iDodane);
				}
				else{
					SetEntProp(id, Prop_Data, "m_iHealth", iMaxHP);
				}
			}
			g_fLastRegen[id] = GetGameTime();
		}
	}
	new iClient = id;
	if(g_bJustOpened[iClient] && g_iOpening[iClient]>=0){
		if(!IsClientConnected(iClient) || !IsPlayerAlive(iClient)){
			g_bJustOpened[iClient]=false;
			g_iOpening[iClient]=-1;
			g_iBoxes[iClient]++;
			return;
		}
		
		if(GetGameTime() - g_fLastOpening[iClient] >= 0.05){
			g_fLastOpening[iClient] = GetGameTime();
			g_iOpening[iClient]--;
			
			new String:sTab[128];		
			Stworz_PasekOpening(g_iOpening[iClient], 1, 25, sTab, 128);
			
			PrintHintText(iClient, "<font color='#C8C800'>Opening BOX...\n<font size='38'>[<font color='#333366'><b>%s</b><font color='#C8C800'>]", sTab);
		}
		
		if(g_iOpening[iClient]==0){
			new iRandom = GetRandomInt(0, 100);
			new Float:fPos[3];
			GetClientAbsOrigin(iClient, fPos);
			
			if(iRandom <= 8){
				new iRan = GetRandomInt(25, 40);
				new iRanMoney = GetRandomInt(25, 90);
				
				g_iMoney[iClient]+= iRanMoney;
				g_iTotalMoney[iClient]+= iRanMoney;
				g_iLuckyM[iClient]+=iRan;
				
				PrintHintText(iClient, "Holy Shit!!! you found<b><font color='#FF9900'> Rare</b>\n<font size='40'>+<b>%d</b>LP<font color='#FFFFFF'> |<font color='#FF9900'> +<b>%d</b>$", iRan, iRanMoney);
				LightCreate(fPos, 77777);
				
				new Float:vec[3], String:sName[64];
				GetClientAbsOrigin(iClient, vec);
				GetClientName(iClient, sName, sizeof sName);
				
				PrintToChatAll("{darkred}HOLY SHIT!{olive} %s{darkred} has found a {lime}Rare Drop{darkred} inside the box!", sName);
				
				if(!g_bOffSound[iClient])
					EmitAmbientSound("*Electronic_Game/rare1.mp3", vec, iClient, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL);	
			}
			else if(iRandom > 8 && iRandom <= 28){
				new iRan = GetRandomInt(10, 18);
				new iRanMoney = GetRandomInt(15, 35);
				
				g_iMoney[iClient]+= iRanMoney;
				g_iTotalMoney[iClient]+= iRanMoney;
				g_iLuckyM[iClient]+=iRan;
				
				PrintHintText(iClient, "Wow! you found<b><font color='#00C800'> Uncommon</b>\n<font size='40'>+<b>%d</b>LP<font color='#FFFFFF'> |<font color='#00C800'> +<b>%d</b>$", iRan, iRanMoney);
				LightCreate(fPos, 2);
				
				new Float:vec[3];
				GetClientAbsOrigin(iClient, vec);
				
				if(!g_bOffSound[iClient])
					EmitAmbientSound("*Electronic_Game/uncommon1.mp3", vec, iClient, SNDLEVEL_RAIDSIREN, SND_NOFLAGS, SNDVOL_NORMAL);
			}
			else{
				new iTotal;
				new iRan = GetRandomInt(0, 1);
				if(iRan){
					iTotal=GetRandomInt(5, 17);
					g_iMoney[iClient] += iTotal;
					g_iTotalMoney[iClient] += iTotal;
				}
				else{
					iTotal=GetRandomInt(9, 15);
					g_iLuckyM[iClient] += iTotal;
				}
				
				PrintHintText(iClient, "Nice! you found<b> Common</b>\n<font size='40'>+<b>%d</b>%s", iTotal, iRan ? "$" : "LP");
				
				if(!g_bOffSound[iClient])
					EmitSoundToClient(iClient, "*Electronic_Game/common1.mp3", SOUND_FROM_PLAYER, SNDCHAN_STATIC);
			}
			g_iOpening[iClient] = -1;
			g_bJustOpened[iClient]=false;
		}
	}
}

public Action:tskPoison(Handle:hTimer, any:id){
	g_hPoisoned[id] = INVALID_HANDLE;
	
	if(IsClientInGame(g_iPoisonedBy[id]) && IsClientInGame(id) && IsPlayerAlive(id)){
		g_iPoisoned[id]--;
		
		SDKHooks_TakeDamage(id, g_iPoisonedBy[id], g_iPoisonedBy[id], 5.0);
				
		PrintHintText(id, "<font color='#FF0000'><font size='40'>-<b>5</b>HP</b></font>\n<font color='#FFFFFF'><font size='20'>You are poisoned (<b>%d</b> hits left)", g_iPoisoned[id]);
		
		if(g_iPoisoned[id]){
			g_hPoisoned[id] = CreateTimer(1.5, tskPoison, id);
		}
	}
	else{
		g_iPoisoned[id] = 0;
		g_iPoisonedBy[id] = 0;
	}
}

public Action:tskMulFix(Handle:hTimer, any:id){
	g_hMulTimer[id] = INVALID_HANDLE;
	
	if(IsClientInGame(id)){
		if(g_iStrike[id] >= 2){
			new iBonus = RoundFloat(g_iStrikeMoney[id] * g_fMul[g_iStrike[id]]);
			PrintHintText(id, "<font size='40'><b>%d</b> KILLS</b></font>\n<font color='#006600'><font size='18'>Strike ended with <font color='#FF3300'><b>%d</b>$", g_iStrike[id], g_iStrikeMoney[id]+iBonus);
			addMoney(id, iBonus);
		}
	}
	
	g_iStrike[id] = 0;
	g_iStrikeMoney[id] = 0;
}

public Action:tskMessageFix(Handle:hTimer, any:id){
	g_hMessageTimer[id] = INVALID_HANDLE;
	
	if(canReceiveData(id)){
		//PrintToChat(id, "{lime}+%s$%d{lime}:{default} %s [{lime}%.2f{default}x multiplier]", g_bVip[id] ? "{lime}" : "{default}", g_iVipBonus[id], g_bVip[id] ? "VIP BONUS" : "NO BONUS", g_fVipMul[id]);
		
		if(g_iStrike[id] >= 2){
			PrintToChat(id, "{darkred}KILLSTRIKE MONEY BONUS: {lime}+%d{lime}{default}%s [{darkred}%s{default}]", RoundFloat(g_fMul[g_iStrike[id]] * 100.0), '%',g_sMulF[g_iStrike[id]]);
		}
		
		if(g_iHud[id])
			PrintToChat(id, "{darkred}__TOTAL: {default}+{lime}$%d{darkred}", g_iVipTotalBonus[id]);
	}
}

pobierzRanking(id, iShow=1){
	new String:sQuery[256];
	FormatEx(sQuery, sizeof sQuery,"SELECT * FROM `moneymod` ORDER BY `kills` DESC LIMIT 1000");
		
	SQL_TQuery(g_hDatabase, SQL_Ranking, sQuery, id);
	
	if(!iShow)
		PrintToChat(id, "{darkred}Counting your position...");
	
	g_bSprawdzilRanking[id] = true;
}

public Action:cmdRanking(id, iArgs){
	pobierzTop10();
	pobierzRanking(id);
}
//UPDATE `moneymod` SET `kills` = '1000' WHERE `steamid` = 'STEAM_1:0:19550343'
public pokazPozycje(id){
	if(0 < g_iPozycja[id] < 1001){
		PrintToChat(id, "{darkred} Your position in ranking:{olive} %d", g_iPozycja[id]);
	}
	else{
		PrintToChat(id, "{darkred} Your position in ranking:{olive} Below 1000 (unranked)");
	}
}

public SQL_Ranking(Handle:owner, Handle:hndl, const String:error[], any:data) 
{
	new id = data; 
	if ( hndl != INVALID_HANDLE ) { 
		if(SQL_HasResultSet(hndl)){
			new iKtory;
			new String:sSid[64], String:sMojeSid[64];
			GetClientAuthId(id, AuthId_Steam2, sMojeSid, sizeof(sMojeSid), false);
			while(SQL_FetchRow(hndl)){
				iKtory++;
				SQL_FetchString(hndl, 0, sSid, sizeof sSid);
				
				if(StrEqual(sMojeSid, sSid)){
					//PrintToChatAll("LOL: %d", iKtory);
					g_iPozycja[id] = iKtory;
					
					break;
				}
			}
		}
	}
	if(GetClientTeam(id) == CS_TEAM_CT || GetClientTeam(id) == CS_TEAM_T)
		pokazPozycje(id);
}

public Action:eventRoundEnd(Handle:hEvent, const String:sName[], bool:bDontBroadcast){
	for(new i = 1 ; i <= MaxClients ; i++){
		if(IsClientConnected(i) && IsClientInGame(i)){
			GetClientAuthId(i, AuthId_Steam2, g_sSteamID[i], sizeof(g_sSteamID[]), false);
			SavePlayerData(i);
		}
	}
	
	static iRound;
	iRound++;
	if(iRound>2){
		new iC = GetClientCount(true);
		if(iC>=4){
			for(new i = 1 ; i <= 64 ; i++){
				if(IsValidEntity(i) && IsValidEdict(i) && IsClientConnected(i) && GetClientTeam(i) == CS_TEAM_T){
					if(IsPlayerAlive(i)){
						//PrintToChat(i, "{blue}*{lime}[XPMOD]{olive} SURVIVE ROUND AS TT +{lime}%dXP", iBonus);
						PrintToChat(i, "{darkred}You survived round as TT,{LIGHTGREEN} +%d{olive}LP", 15);
						g_iLuckyM[i]+=15;
					}
				}
			}
		}
	}
	
	for(new i = 1 ; i <= MaxClients ; i++){
		if(!canReceiveData(i)){
			continue;
		}
		
		if(g_hMulTimer[i] != INVALID_HANDLE){ 
			KillTimer(g_hMulTimer[i]);
						
			g_hMulTimer[i] = INVALID_HANDLE;
			
			g_hMulTimer[i] = CreateTimer(0.5, tskMulFix, i);
		}
		if(g_hPoisoned[i] != INVALID_HANDLE){
			KillTimer(g_hPoisoned[i]);
			g_hPoisoned[i] = INVALID_HANDLE;
			g_iPoisoned[i] = 0;
			g_iPoisonedBy[i] = 0;
		}
	}
}

stock addMoney(id, iAmt){
	g_iMoney[id]+=iAmt;
	g_iTotalMoney[id]+=iAmt;
}

/* // SÖK
stock BeamFollowCreate(Entity, Color[4]){
	TE_SetupBeamFollow(Entity, BeamSprite,	0, Float:5.0, Float:1.5, Float:1.5, 3, Color);
	TE_SendToAll();	
}
*/

stock max(i,l) return i > l ? i : l; 

stock Stworz_PasekOpening(iCo, iProg, iMax, String:sTab[], iLen){
	new iIle = iCo;
	
	while(--iMax){
		if(iIle>=iProg){
			iIle--;
			Format(sTab, iLen, "%s|", sTab);
		}
		else{
			Format(sTab, iLen, "%s ", sTab);
		}
	}
}

stock Stworz_PasekPostepu(String:sTab[], iLen, const String:sSymbol[], iCoSprawdzic, iIleWymagaJedenStopien=10){
	new iAmt = max(1, iCoSprawdzic), iTimesAdded=0;
	Format(sTab, iLen, "<font color='#006666'>%d<font color='#333366'>", iCoSprawdzic);
	while(((iAmt-=iIleWymagaJedenStopien)>=(1>>iIleWymagaJedenStopien))){
		//PrintToChatAll("Found offset %d out of %d [C = %d]", iTimesAdded, iCoSprawdzic/2, iCoSprawdzic);
		iTimesAdded++;

		Format(sTab, iLen, "|%s|", sTab, sSymbol);
		
	}
	
	//if(iCoSprawdzic==100){
		//ReplaceStringEx(sTab, iLen, "100", "<font color='#00CC66'>DONE<font color='#333366'>");
	//}
	
	return iTimesAdded;
}

stock canReceiveData(id) return IsPlayer(id) && IsClientInGame(id);
stock FakePrecacheSound( const String:szPath[] )AddToStringTable( FindStringTable( "soundprecache" ), szPath );

SavePlayerData(id){
	if(g_iKills[id] && g_bFoundHim[id]){
		new String:sQuery[1024], String:sName[64], String:sEscapedName[129];
		GetClientName(id, sName, sizeof sName);
		
		SQL_EscapeString(g_hDatabase, sName, sEscapedName, sizeof sEscapedName);

		FormatEx(sQuery, sizeof(sQuery), "UPDATE `moneymod` SET `name` = '%s', `kills` = '%d', `totalmoney` = '%d', `money` = '%d', `lpoints` = '%d',\
		 `skill_0` = '%d', `skill_1` = '%d', `skill_2` = '%d', `skill_3` = '%d', `skill_4` = '%d', `skill_5` = '%d', `skill_6` = '%d', `skill_7` = '%d', `skill_8` = '%d', `skill_9` = '%d',\
		 `lf_0` = '%d', `lf_1` = '%d', `lf_2` = '%d', `lf_3` = '%d', `lf_4` = '%d', `lf_5` = '%d', `lf_6` = '%d', `lf_7` = '%d', `boxes` = '%d' WHERE `steamid` = '%s'",
		 sEscapedName, g_iKills[id], g_iTotalMoney[id], g_iMoney[id], g_iLuckyM[id], g_iSkill[id][0], g_iSkill[id][1], g_iSkill[id][2], g_iSkill[id][3], g_iSkill[id][4], g_iSkill[id][5], g_iSkill[id][6],
		  g_iSkill[id][7], g_iSkill[id][8], g_iLucky[id][0], g_iLucky[id][1], g_iLucky[id][2], g_iLucky[id][3], g_iLucky[id][4], g_iLucky[id][5], g_iLucky[id][6], 777, 
		  g_iBoxes[id], g_sSteamID[id]); 
				
		SQL_TQuery(g_hDatabase, SQL_OnSavedPlayerData, sQuery, id);
	}
}  


GetPlayerData(id) {
	if(AreClientCookiesCached(id)){
		new String:sCookie[2];

		GetClientCookie(id, g_hHudCookie, sCookie, sizeof sCookie);
		g_iHud[id] = StringToInt(sCookie);
				
		GetClientCookie(id, g_hSoundCookie, sCookie, sizeof sCookie);
		g_bOffSound[id] = bool:StringToInt(sCookie);
												
		GetClientCookie(id, g_hModel, sCookie, sizeof sCookie);
		g_iModel[id] = StringToInt(sCookie);
		
		GetClientCookie(id, g_hTrail, sCookie, sizeof sCookie);
		g_iTrail[id] = StringToInt(sCookie);
	}
	
	if(g_hDatabase==INVALID_HANDLE) return;
	
	new String:sQuery[1024];
	GetClientAuthId(id, AuthId_Steam2, g_sSteamID[id], sizeof(g_sSteamID[]), false);
	
	FormatEx(sQuery, sizeof(sQuery), "SELECT * FROM `moneymod` WHERE `steamid` = '%s'", g_sSteamID[id]); 			
	SQL_TQuery(g_hDatabase, SQL_OnGetPlayerData, sQuery, id);
}

public SQL_OnGetPlayerData(Handle:owner, Handle:hndl, const String:error[], any:id) {
	if(!IsClientInGame(id) || IsFakeClient(id) || !IsClientAuthorized(id) || g_bFoundHim[id]){
		return;
	}
	
	if (hndl != INVALID_HANDLE) { 
		if(SQL_FetchRow(hndl)){
			g_iKills[id] = g_iTotalMoney[id] = SQL_FetchInt(hndl, 2);
			
			SetEntProp(id, Prop_Data, "m_iFrags",  g_iKills[id]);
			CS_SetClientContributionScore(id, g_iKills[id]);
			
			g_iTotalMoney[id] = SQL_FetchInt(hndl, 3);
			g_iMoney[id] = SQL_FetchInt(hndl, 4);	
			g_iLuckyM[id] = SQL_FetchInt(hndl, 5);
			
			g_iSkill[id][0] = SQL_FetchInt(hndl, 6);
			g_iSkill[id][1] = SQL_FetchInt(hndl, 7);
			g_iSkill[id][2] = SQL_FetchInt(hndl, 8);
			g_iSkill[id][3] = SQL_FetchInt(hndl, 9);
			g_iSkill[id][4] = SQL_FetchInt(hndl, 10);
			g_iSkill[id][5] = SQL_FetchInt(hndl, 11);
			g_iSkill[id][6] = SQL_FetchInt(hndl, 12);
			g_iSkill[id][7] = SQL_FetchInt(hndl, 13);
			g_iSkill[id][8] = SQL_FetchInt(hndl, 14);
			
			g_iLucky[id][0] = SQL_FetchInt(hndl, 16);
			g_iLucky[id][1] = SQL_FetchInt(hndl, 17);
			g_iLucky[id][2] = SQL_FetchInt(hndl, 18);
			g_iLucky[id][3] = SQL_FetchInt(hndl, 19);
			g_iLucky[id][4] = SQL_FetchInt(hndl, 20);
			g_iLucky[id][5] = SQL_FetchInt(hndl, 21);
			g_iLucky[id][6] = SQL_FetchInt(hndl, 22);
			//g_iLucky[id][7] = SQL_FetchInt(hndl, 23);
			
			g_iBoxes[id] = SQL_FetchInt(hndl, 24);
			
			g_iJoinTotal[id] = g_iTotalMoney[id];	
			
			g_bFoundHim[id]=true;
			g_iKillsOnSuccess[id] = g_iKills[id];
			PrintToChat(id, "{darkred}AUTH[{blue}2{orange}/{blue}2{darkred}] Data downloaded, stats set -{lime} FINISHED");
			pobierzRanking(id, 1);
			
			return;
			
		}
		else{
			new String:sQuery[2048], String:sName[64], String:sEscapedName[129];
			GetClientName(id, sName, sizeof sName);
			
			SQL_EscapeString(g_hDatabase, sName, sEscapedName, sizeof sEscapedName);
			
			g_first_time[ id ] = 1;
				
			FormatEx(sQuery, sizeof(sQuery),\
			"INSERT INTO `moneymod` (`steamid`, `name`, `kills`, `totalmoney`, `money`, `lpoints`, `skill_0`, `skill_1`, `skill_2`, `skill_3`, `skill_4`, `skill_5`, `skill_6`, `skill_7`, `skill_8`, `skill_9`, `lf_0`, `lf_1`, `lf_2`, `lf_3`, `lf_4`, `lf_5`, `lf_6`, `lf_7`, `boxes`) VALUES ('%s','%s',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)", g_sSteamID[id], sEscapedName); 
			
			SQL_TQuery(g_hDatabase, SQL_OnInsertPlayerData, sQuery, id);
		}
	}
}


public SQL_OnSavedPlayerData(Handle:owner, Handle:hndl, const String:error[], any:data) { 
	if (hndl == INVALID_HANDLE) { 
		LogError("Save failed! %s", error); 
	} 
} 

public SQL_OnInsertPlayerData(Handle:owner, Handle:hndl, const String:error[], any:id) { 
	if (hndl == INVALID_HANDLE) { 
		LogError("Insert failed! %s", error); 
	} 
	else{
		g_bFoundHim[id]=true;
		g_iKillsOnSuccess[id] = g_iKills[id];
		PrintToChat(id, "{darkred}AUTH[{blue}2{orange}/{blue}2{darkred}] Data downloaded, stats set -{lime} FINISHED");
	}
} 

ConnectToDatabase(){
	if (g_hDatabase != INVALID_HANDLE){
		CloseHandle(g_hDatabase);
	}
	
	g_hDatabase = INVALID_HANDLE;

	SQL_TConnect(SQL_OnConnect, "moneymod"); 
} 

public SQL_OnConnect(Handle:owner, Handle:hndl, const String:error[], any:data) { 
	if(hndl == INVALID_HANDLE){ 
		LogError("Database failure: %s", error); 
	} 
	else{
		g_hDatabase = hndl;
		new String:query[512];
		
		Format(query, sizeof(query), "CREATE TABLE `moneymod` (`steamid` TEXT PRIMARY KEY, `name` TEXT, `kills` INTEGER, `totalmoney` INTEGER, `money` INTEGER, `lpoints` INTEGER, `skill_0` INTEGER, `skill_1` INTEGER, `skill_2` INTEGER, `skill_3` INTEGER, `skill_4` INTEGER, `skill_5` INTEGER, `skill_6` INTEGER, `skill_7` INTEGER, `skill_8` INTEGER, `skill_9` INTEGER, `lf_0` INTEGER, `lf_1` INTEGER, `lf_2` INTEGER,`lf_3` INTEGER,`lf_4` INTEGER,`lf_5` INTEGER,`lf_6` INTEGER, `lf_7` INTEGER, `boxes` INTEGER)");
		if (!SQL_Query(hndl, query))
		{
			PrintToServer("Failed to query (error: %s)", error);
		}
		else
		{
			PrintToServer("[MoneyMod] Table 'moneymod' created for SQLite!");
		}
	}
}

stock TraceToEntity(id){
	new Float:vecClientEyePos[3], Float:vecClientEyeAng[3];
	GetClientEyePosition(id, vecClientEyePos);
	GetClientEyeAngles(id, vecClientEyeAng); 
	
	TR_TraceRayFilter(vecClientEyePos, vecClientEyeAng, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, id);
	if (TR_DidHit(INVALID_HANDLE)){
		new TRIndex = TR_GetEntityIndex(INVALID_HANDLE);
		return TRIndex;
	}
	
	return -1;
}

public bool:TraceRayDontHitSelf(entity, mask, any:data){
	if(entity == data){
		return false; 
	}
	return true;
}

public Action:cmdVipMenu(id){
	if(g_bVip[id]){
		new Handle:hMenu = CreateMenu(MenuVipHandle);
		SetMenuTitle(hMenu, "VIP Menu");
		AddMenuItem(hMenu, "#choice1", "Set Player Model [T]");
		AddMenuItem(hMenu, "#choice2", "Set Player Trail");
		SetMenuExitButton(hMenu, true);
		DisplayMenu(hMenu, id, 0);
	}
	
	return Plugin_Handled;
}

public MenuVipHandle(Handle:hMenu, MenuAction:action, id, iOpcja){
	if (action == MenuAction_Select){
		switch(iOpcja){
			case 0:{
				cmdModelMenu(id);
			}
			case 1:{
				cmdTrailsMenu(id);
			}
		}
	}
}

BeamFollowCreate(Entity, Color[4]){
	TE_SetupBeamFollow(Entity, BeamSprite,	0, Float:1.0, Float:6.0, Float:8.0, 9999, Color);
	TE_SendToAll();
}
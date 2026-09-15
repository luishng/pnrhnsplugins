#include < sourcemod >
#include < sdktools >
#include < sdkhooks >
#include < sdktools_variant_t >
#include < cstrike >
#include < smlib >
#include < csgocolors >

#pragma dynamic 900000 // tentando colocar mais memoria para o bm.

#define TAG			"{GREEN}[pNr Blockmaker]{NORMAL}" //[pNr Blockmaker]
#define MAX_RESOURCES	6
#define MAX_BLOCKS		25
#define VERSION			"0.0.8"

public Plugin:myinfo =
{
	name = "[pNr] BlockMaker",
	author = "KINZ & Mister",
	description = "BlockMaker on CS:GO",
	version = VERSION,
	url = "https://steamcommunity.com/id/8RUNO1/ - https://steamcommunity.com/id/MisterBR/"
}

#define ACCESS ADMFLAG_GENERIC 

new byUnits[MAXPLAYERS+1];
new g_bRotationMode[MAXPLAYERS+1];
//new g_iRespawn; //BUG. bloco de chance de respawn.
new g_iBeamSprite;
new g_iDragEnt[MAXPLAYERS+1];
new g_iOldButtons[MAXPLAYERS+1];

new g_iGravity[MAXPLAYERS+1];
new g_iTempAlpha[MAXPLAYERS+1];
new g_iTempKlocek[MAXPLAYERS+1];

new g_iTempKlr[MAXPLAYERS+1][3];
new g_iTempSize[MAXPLAYERS+1];

new g_iPropped[MAXPLAYERS+1];
new g_iCurrentTele[MAXPLAYERS+1];
new g_iBlockSelection[MAXPLAYERS+1];
new g_iBlocks[2048];
new g_iTeleporters[2048];
new g_iOnTop[2048];
new g_iRotation[2048];
new g_iOnlyT[2048];
new g_iAlpha[2048];
// new g_iRuchomy[2048];
// new g_iOs[2048];
//new g_iTouched[2048];
new g_iBlockSize[2048];
new g_iKlr[2048][3];
new g_iTempColor[2048];

new Float:g_fLastFire[ MAXPLAYERS + 1 ];
new Float:g_fLastTramp[ MAXPLAYERS + 1 ];
new Float:g_fLastSpeed[ MAXPLAYERS + 1 ];
new Float:g_fLastDamage[ MAXPLAYERS + 1 ];

new Float:g_fInv[MAXPLAYERS+1];
new Float:g_fStealth[MAXPLAYERS+1];
new Float:g_fDistance[MAXPLAYERS+1];
new Float:g_fBOS[MAXPLAYERS+1];
new Float:g_fLastHP[MAXPLAYERS+1];
//new Float:g_fKam[MAXPLAYERS+1];
new Float:g_fActChance[MAXPLAYERS+1];

//new Float:g_fLastChance[MAXPLAYERS+1]; BUG.

new Handle:g_hTimer_RemoveEffect[ MAXPLAYERS + 1 ];
new Float:g_fLastDuck[MAXPLAYERS+1];
new Float:g_fSnappingGap[ MAXPLAYERS + 1 ] = { 0.0 , 64.0};
// new Float:g_fRuch[2048];
new Float:g_fProp[2048][2];
new Float:g_fAngles[2048][3];
new Float:g_fChance[MAXPLAYERS+1][2048];
new Float:g_fVec[2048][3];
new Float:g_fGrabOffset[MAXPLAYERS+1][3];

new bool:g_bEnabled;

// new bool:g_bAutoSave = false;

new bool:g_bBoots[MAXPLAYERS+1];
new bool:g_bChance[MAXPLAYERS+1];
new bool:g_bStealth[MAXPLAYERS+1];
new bool:g_bKamuflaz[MAXPLAYERS+1];

new bool:g_bNoFallDmg[ MAXPLAYERS + 1 ] = { false, ... };
new bool:g_bInvCanUse[MAXPLAYERS+1]={true,...};
new bool:g_bSnapping[MAXPLAYERS+1]={false,...};
new bool:g_bInv[MAXPLAYERS+1]={false,...};
new bool:g_bStealthCanUse[MAXPLAYERS+1]={true,...};
new bool:g_bBootsCanUse[MAXPLAYERS+1]={true,...};
new bool:g_bDamage[MAXPLAYERS+1]={false,...};
//new bool:g_bLocked[2048]={false,...};
//new bool:g_bCamCanUse[MAXPLAYERS+1]={true,...};
new bool:g_bStop[2048];
new bool:g_bTeleport[2048];
new bool:g_bTriggered[2048] = {false, ...};

new bool:g_bDeagleCanUse[MAXPLAYERS+1][2048];
new bool:g_bHEgrenadeCanUse[MAXPLAYERS+1][2048];
new bool:g_bFlashbangCanUse[MAXPLAYERS+1][2048];
new bool:g_bSmokegrenadeCanUse[MAXPLAYERS+1][2048];

// Quem Criou o bloco
new String:g_sAutor[ 2048 ][ 64 ];

new String:g_sSciezkaModel[ 5 ][ MAX_BLOCKS + 1 ][ 256 ];

new const String:g_sWeapons[33][] = {
	"weapon_ak47", "weapon_revolver", "weapon_aug", "weapon_bizon", "weapon_deagle", "weapon_awp", "weapon_elite", "weapon_famas", "weapon_fiveseven", "weapon_cz75a",
	"weapon_g3sg1", "weapon_galilar", "weapon_glock", "weapon_hkp2000", "weapon_usp_silencer", "weapon_m249", "weapon_m4a1",
	"weapon_mac10", "weapon_mag7", "weapon_mp7", "weapon_mp9", "weapon_negev", "weapon_nova", "weapon_p250", "weapon_p90", "weapon_sawedoff",
	"weapon_scar20", "weapon_sg556", "weapon_ssg08", "weapon_taser", "weapon_tec9", "weapon_ump45", "weapon_xm1014"
};

new const String:g_sPodFolder[ ] = "pp2016"; //blockbuilder
new const String:INVI_SOUND_PATH[ ] = "*blockbuilder/invincibility.mp3"
new const String:STEALTH_SOUND_PATH[ ] = "*blockbuilder/stealth.mp3"
new const String:BOS_SOUND_PATH[ ] = "*blockbuilder/bootsofspeed.mp3"
// new const String:CAM_SOUND_PATH[ ] = "*blockbuilder/camouflage.mp3"
new const String:TELE_SOUND_PATH[ ] = "*blockbuilder/teleport.mp3"
new const String:FIRE_SOUND_PATH[ ] = "*blockbuilder/flameburst1.wav"
//new const String:ICE_SOUND_PATH[ ]	"*blockbuilder/ice4.mp3"
new const String:RESPAWN_SOUND_PATH[ ] = "*hnsrussian/respawn.mp3"

new const String:g_sHoney[ 4 ][ ] = {
	"*player/footsteps/new/mud_01.wav",
	"*player/footsteps/new/mud_03.wav",
	"*player/footsteps/new/mud_05.wav",
	"*player/footsteps/new/mud_07.wav"
};

new const String:g_sGrenadeWeaponNames[][] = {        
    "weapon_flashbang",        
    "weapon_molotov",
    "weapon_smokegrenade",
    "weapon_hegrenade",
    "weapon_decoy",
    "weapon_incgrenade"
};

enum {
	POLE = 0,
	SMALL,
	NORMAL,
	LARGE,
	XLARGE
}

static const Float:g_fBlockSizes[ 5 ][ 2 ][ 3 ] = {
	{ { -4.25, -32.25, -4.25 }, { 4.25, 32.25, 4.25 } },
    { { -15.97, -16.00, -3.97 }, { 15.97, 16.00, 3.97 } },
    { { -32.25, -32.22, -4.21 }, { 32.25, 32.22, 4.21 } },
    { { -64.25, -64.18, -4.21 }, { 64.25, 64.18, 4.21 } },
    { { -192.22, -192.25, -4.22 }, { 192.22, 192.25, 4.22 } }
};
static const Float:g_fBlockSizes2[ 5 ][ 2 ][ 3 ] = {
	{ { -32.25, -4.25, -4.25 }, { 32.25, 4.25, 4.25 } },
    { { -15.97, -3.97, -16.00 }, { 15.97, 3.97, 16.00 } },
    { { -32.25, -4.21, -32.22 }, { 32.25, 4.21, 32.22 } },
    { { -64.25, -4.21, -64.18 }, { 64.25, 4.21, 64.18 } },
    { { -192.22, -4.22, -192.25 }, { 192.22, 4.22, 192.25 } }
};
static const Float:g_fBlockSizes3[ 5 ][ 2 ][ 3 ] = {
	{ { -4.25, -4.25, -32.25 }, { 4.25, 4.25, 32.25 } },
    { { -3.97, -15.97, -16.00 }, { 3.97, 15.97, 16.00 } },
    { { -4.21, -32.25, -32.22 }, { 4.21, 32.25, 32.22 } },
    { { -4.21, -64.25, -64.18 }, { 4.21, 64.25, 64.18 } },
    { { -4.22, -192.22, -192.25 }, { 4.22, 192.22, 192.25 } }
};
static const g_iRandomColor[ 6 ][ 4 ] = {
	{ 255, 0, 0, 255 },
	{ 0, 255, 0, 255 },
	{ 0, 0, 255, 255 },
	{ 255, 255, 0, 255 },
	{ 0, 255, 255, 255 },
	{ 255, 0, 255, 255 }
}

new Handle:g_hBlocksKV;
// new Handle:g_hAutoSave;

// UNDERKNIFE
new Float:g_fBeforeVel[ MAXPLAYERS + 1 ][ 3 ];
new bool:g_bBhopUsed[ MAXPLAYERS + 1 ];
new Handle:g_hLBhopUsed[ MAXPLAYERS + 1 ];

// END

new Handle:g_hEnabled = INVALID_HANDLE;

new Handle:g_hProps[MAXPLAYERS+1];
new Handle:g_hClientMenu[MAXPLAYERS+1];
new Handle:g_hCol[2048];
new Handle:g_hRender[2048];
// new bool:g_bOnIce[ MAXPLAYERS + 1 ];

new Float:restarttime;

new g_iAmmo;
new g_iPrimaryAmmoType;


public OnPluginStart( ) {
	RegConsoleCmd("sm_bm", Command_BlockBuilder );
	RegConsoleCmd("sm_bb", Command_BlockBuilder );

	RegAdminCmd( "/bm", Command_BlockBuilder, ACCESS );
	RegAdminCmd( "unitmover", Command_UnitMove, ACCESS );

	RegAdminCmd("+grab", cmdGrab, ACCESS);
	RegAdminCmd("-grab", cmdUngrab, ACCESS);
	
	g_hEnabled = CreateConVar( "bm_enabled", "1", "Turns the BM On/Off ( 0 = OFF, 1 = ON )", FCVAR_NOTIFY|FCVAR_PLUGIN, true, 0.0, true, 1.0 );
	HookConVarChange( g_hEnabled, OnCvarChange );
	
	g_bEnabled = true;
	
	HookConVarChange( ( FindConVar( "mp_restartgame" ) ), RestartGameTriggered );
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_death", zH_PlayerDeath);
	HookEvent("player_spawn", PlayerSpawn);
	
	g_iAmmo = FindSendPropOffs("CCSPlayer", "m_iAmmo");
	g_iPrimaryAmmoType = FindSendPropOffs("CBaseCombatWeapon", "m_iPrimaryAmmoType");
		
	// GRANDE CONFIG DO BM LOL
	
	AutoExecConfig( true, "blockmaker" );
}

public OnConfigsExecuted( )
{
	g_bEnabled = GetConVarBool( g_hEnabled );
}

public OnCvarChange( Handle:hConVar, const String:sOldValue[ ], const String:sNewValue[ ] ) {
	decl String:sConVarName[ 64 ];
	GetConVarName( hConVar, sConVarName, sizeof( sConVarName ) );

	if( StrEqual( "bm_enabled", sConVarName ) )
		g_bEnabled = GetConVarBool( hConVar );
}

public RestartGameTriggered(Handle:cvar, const String:oldVal[], const String:newVal[])
{
    restarttime = GetConVarFloat(cvar) - 0.5;

    if(restarttime >= 0)
    {
        SaveBlocks();
    }
}

//VALOR DAS AÇÕES QUE OS BLOCOS FAZEM.. DANO, VELOCIDADE, ...
new const Float:g_fTime2Max[ MAX_BLOCKS ] = { // Tempo Max. VALOR/DANO MAXIMO
	0.0,	// 	"Platform",  0
	0.0,	//	"Glass", 1
	1.0,	//	"Bunnyhop",  2
	3.0,	//	"Delayed Bhop",  3
	0.0,	//	"CT Barrier",  4
	0.0,	//	"T Barrier",  5
	0.0,	//	"No Fall Damage",  6
	0.5,	//	"Honey",  7
	0.0,	//	"Ice",  8
	0.0,	//	"Trampoline",  9
	700.0,	//	"Low Gravity",  10
	10.0,	//	"Healer",  11
	900.0,	// 	"Speed Boost",  12
	60.0,	// 	"Invincibility",  13
	60.0,	// 	"Stealth",  14
	0.0,//60.0,	// 	"Camouflage",  15
	60.0,	// 	"Boots Of Speed",  16
	0.0,	// 	"HE Nade",  17
	0.0,	// 	"FrostNade",  18
	0.0,	// 	"Flash Nade",  19 
	3.0,	// 	"Weapons",  20 
	10.0,	//	"Damage",  21
	10.0,	//	"Fire",  22
	0.0,	// 	"Slap",  23
	0.0		// 	"Death"  24
};				
new const Float:g_fTime2Stopa[MAX_BLOCKS] = { // INCREMENTO DO VALOR/DANO
	0.0,	// 	"Platform",  0
	0.0,	//	"Glass",  1
	0.1,	//	"Bunnyhop",  2
	0.1,	//	"Delayed Bhop",  3
	0.0,	//	"CT Barrier",  4
	0.0,	//	"T Barrier",  5
	0.0,	//	"No Fall Damage",  6
	0.1,	//	"Honey",  7
	0.0,	//	"Ice",  8
	0.0,	//	"Trampoline",  9
	50.0,	//	"Low Gravity",  10
	1.0,	//	"Healer",  11
    75.0,	// 	"Speed Boost",  12
	5.0,	// 	"Invincibility",  13
	5.0,	// 	"Stealth",  14
	0.0,//5.0,	// 	"Camouflage",  15
	5.0,	// 	"Boots Of Speed",  16
	0.0,	// 	"HE Nade",  17
	0.0,	// 	"FrostNade",  18
	0.0,	// 	"Flash Nade",  19 
	1.0,	// 	"Weapons",  20 
	1.0,	//	"Damage",  21
	1.0,	//	"Fire",  22
	0.0,	// 	"Slap",  23
	0.0		// 	"Death"  24
};
new const Float:g_fTime2Def[MAX_BLOCKS] = { // Tempo Padrao. DANO
	0.0,	// 	"Platform",  0
	0.0,	//	"Glass",  1
	1.0,	//	"Bunnyhop",  2
	1.0,	//	"Delayed Bhop",  3
	0.0,	//	"CT Barrier",  4
	0.0,	//	"T Barrier",  5
	0.0,	//	"No Fall Damage",  6
	0.5,	//	"Honey",  7
	0.0,	//	"Ice",  8
	0.0,	//	"Trampoline",  9
	300.0,	//	"Low Gravity",  10
	2.0,	//	"Healer",  11
   750.0,	// 	"Speed Boost",  12
	60.0,	// 	"Invincibility",  13
	60.0,	// 	"Stealth",  14
	0.0,//60.0,	// 	"Camouflage",  15
	60.0,	// 	"Boots Of Speed",  16
	0.0,	// 	"HE Nade",  17
	0.0,	// 	"FrostNade",  18
	0.0,	// 	"Flash Nade",  19 
	1.0,	// 	"Weapons",  20 
	2.0,	//	"Damage",  21
	5.0,	//	"Fire",  22
	0.0,	// 	"Slap",  23
	0.0		// 	"Death"  24
};
new const Float:g_fTime2Min[MAX_BLOCKS] = { // Tempo Min.
	0.0,	// 	"Platform",  0
	0.0,	//	"Glass",  1
	0.1,	//	"Bunnyhop",  2
	0.1,	//	"Delayed Bhop",  3
	0.0,	//	"CT Barrier",  4
	0.0,	//	"T Barrier",  5
	0.0,	//	"No Fall Damage",  6
	0.1,	//	"Honey",  7
	0.0,	//	"Ice",  8
	0.0,	//	"Trampoline",  9
    100.0,	//	"Low Gravity",  10
	1.0,	//	"Healer",  11
    200.0,	// 	"Speed Boost",  12
	5.0,	// 	"Invincibility",  13
	5.0,	// 	"Stealth",  14
	0.0,//5.0,	// 	"Camouflage",  15
	5.0,	// 	"Boots Of Speed",  16
	0.0,	// 	"HE Nade",  17
	0.0,	// 	"FrostNade",  18
	0.0,	// 	"Flash Nade",  19 
	1.0,	// 	"Weapons",  20 
	1.0,	//	"Damage",  21
	1.0,	//	"Fire",  22
	0.0,	// 	"Slap",  23
	0.0		// 	"Death"  24
};

new const String:g_sTime2Nazwa[ MAX_BLOCKS ][ 33 ] = { // Descricao. 2
	"Nenhum",				// 	"Platform",  0
	"Nenhum",				//	"Glass",  1
	"Reaparece em",			//	"Bunnyhop",  2
	"Reaparece em",			//	"Delayed Bhop",  3
	"Nenhum",				//	"CT Barrier",  4
	"Nenhum",				//	"T Barrier",  5
	"Nenhum",				//	"No Fall Damage",  6
	"Velocidade",			//	"Honey",  7
	"Nenhum",				//	"Ice",  8
	"Nenhum",				//	"Trampoline",  9
	"Gravidade",			//	"Low Gravity",  10
	"Vida",					//	"Healer",  11
	"Velocidade",			// 	"Speed Boost",  12
	"Tempo de espera",		// 	"Invincibility",  13
	"Tempo de espera",		// 	"Stealth",  14
	"Nenhum",//"Tempo de espera",		// 	"Camouflage",  15
	"Tempo de espera",		// 	"Boots Of Speed",  16
	"Nenhum",				// 	"HE Nade",  17
	"Nenhum",				// 	"FrostNade",  18
	"Nenhum",				// 	"Flash Nade",  19 
	"Munição",				// 	"Weapons",  20 
	"Nenhum", 					//	"Damage",  21 Dano
	"Dano",					//	"Fire",  22
	"Nenhum",				// 	"Slap",  23
	"Nenhum"				// 	"Death"  24
};
new const g_iOnlyTShow[ MAX_BLOCKS ] = { // Mostra para a opcao 'somente Terroristas'
	0,	// 	"Platform",  0
	0,	//	"Glass",  1
	0,	//	"Bunnyhop",  2
	0,	//	"Delayed Bhop",  3
	0,	//	"CT Barrier",  4
	0,	//	"T Barrier",  5
	0,	//	"No Fall Damage",  6
	0,	//	"Honey",  7
	0,	//	"Ice",  8
	0,	//	"Trampoline",  9
	0,	//	"Low Gravity",  10
	0,	//	"Healer",  11
	0,	// 	"Speed Boost",  12
	0,	// 	"Invincibility",  13
	0,	// 	"Stealth",  14
	0,	// 	"Camouflage",  15
	0,	// 	"Boots Of Speed",  16
	0,	// 	"HE Nade",  17
	0,	// 	"FrostNade",  18
	0,	// 	"Flash Nade",  19 
	0,	// 	"Weapons",  20 
	0,	//	"Damage",  21
	0,	//	"Fire",  22
	0,	// 	"Slap",  23
	0	// 	"Death"  24
};
new const g_iOnTopShow[ MAX_BLOCKS ] = { // Mostra Somente em cima ..
	0,	// 	"Platform",  0
	0,	//	"Glass",  1
	1,	//	"Bunnyhop",  2
	1,	//	"Delayed Bhop",  3
	1,	//	"CT Barrier",  4
	1,	//	"T Barrier",  5
	0,	//	"No Fall Damage",  6
	0,	//	"Honey",  7
	0,	//	"Ice",  8
	1,	//	"Trampoline",  9
	1,	//	"Low Gravity",  10
	1,	//	"Healer",  11
	1,	// 	"Speed Boost",  12
	1,	// 	"Invincibility",  13
	1,	// 	"Stealth",  14
	0,//1,	// 	"Camouflage",  15
	1,	// 	"Boots Of Speed",  16
	1,	// 	"HE Nade",  17
	1,	// 	"FrostNade",  18
	1,	// 	"Flash Nade",  19 
	1,	// 	"Weapons",  20 
	1,	//	"Damage",  21
	1,	//	"Fire",  22
	1,	// 	"Slap",  23
	1	// 	"Death"  24
};

//INTERVALO DE TEMPO QUE AS AÇÕES SÃO DISPARADAS
new const Float:g_fTimeMax[ MAX_BLOCKS ] = { // Tempo máximo dos Blocos. (ONDE CHEGA)
	0.0,	// 	"Platform",  0
	0.0,	//	"Glass",  1
	1.5,	//	"Bunnyhop",  2
	3.0,	//	"Delayed Bhop",  3
	0.0,	//	"CT Barrier",  4
	0.0,	//	"T Barrier",  5
	0.0,	//	"No Fall Damage",  6
	2.5,	//	"Honey",  7
	2.0,	//	"Ice",  8
	800.0,	//	"Trampoline",  9
	1200.0,	//	"Low Gravity",  10
	3.0,	//	"Healer",  11
	600.0,	// 	"Speed Boost",  12
	20.0,	// 	"Invincibility",  13
	20.0,	// 	"Stealth",  14
	0.0,//20.0,	// 	"Camouflage",  15
	20.0,	// 	"Boots Of Speed",  16
	0.0,	// 	"HE Nade",  17
	0.0,	// 	"FrostNade",  18
	0.0,	// 	"Flash Nade",  19 
	35.0,	// 	"Weapons",
	3.0,	//	"Damage",  21
	5.0,	//	"Fire",  22
	0.0,	// 	"Slap",  23
	1.0		// 	"Death"  24
};

new const Float:g_fTimeStopa[ MAX_BLOCKS ] = { // INCREMENTO DO TEMPO
	0.0,	// 	"Platform",  0
	0.0,	//	"Glass",  1
	0.1,	//	"Bunnyhop",  2
	1.0,	//	"Delayed Bhop",  3
	0.0,	//	"CT Barrier",  4
	0.0,	//	"T Barrier",  5
	0.0,	//	"No Fall Damage",  6
	0.5,	//	"Honey",  7
	0.1,	//	"Ice",  8
	50.0,	//	"Trampoline",  9
	100.0,	//	"Low Gravity",  10
	0.25,	//	"Healer",  11
	50.0,	// 	"Speed Boost",  12
	1.0,	// 	"Invincibility",  13
	1.0,	// 	"Stealth",  14
	0.0,//1.0,	// 	"Camouflage",  15
	1.0,	// 	"Boots Of Speed",  16
	0.0,	// 	"HE Nade",  17
	0.0,	// 	"FrostNade",  18
	0.0,	// 	"Flash Nade",  19 
	1.0,	// 	"Weapons",  20 
	0.25,	//	"Damage",  21
	0.25,	//	"Fire",  22
	0.0,	// 	"Slap",  23
	1.0		// 	"Death"  24
};

new const Float:g_fTimeDef[MAX_BLOCKS] = { // Tempo Padrao dos Blocos. (ONDE COMECA)
	0.0,	// 	"Platform",  0
	0.0,	//	"Glass",  1
	0.1,	//	"Bunnyhop",  2
	1.0,	//	"Delayed Bhop",  3
	0.0,	//	"CT Barrier",  4
	0.0,	//	"T Barrier",  5
	0.0,	//	"No Fall Damage",  6
	2.5,	//	"Honey",  7
	0.0,	//	"Ice",  8
	300.0,	//	"Trampoline",  9
	400.0,	//	"Low Gravity",  10
	1.0,	//	"Healer",  11
	260.0,	// 	"Speed Boost",  12
	15.0,	// 	"Invincibility",  13
	15.0,	// 	"Stealth",  14
	0.0,//15.0,	// 	"Camouflage",  15
	15.0,	// 	"Boots Of Speed",  16
	0.0,	// 	"HE Nade",  17
	0.0,	// 	"FrostNade",  18
	0.0,	// 	"Flash Nade",  19 
	0.0,	// 	"Weapons",  20 
	1.0,	//	"Damage",  21
	0.5,	//	"Fire",  22
	0.0,	// 	"Slap",  23
	0.0		// 	"Death"  24
};

new const Float:g_fTimeMin[ MAX_BLOCKS ] = { // Tempo Min (ONDE O MENOR VALOR VAI CHEGAR)
	0.0,	// 	"Platform",  0
	0.0,	//	"Glass",  1
	0.1,	//	"Bunnyhop",  2
	1.0,	//	"Delayed Bhop",  3
	0.0,	//	"CT Barrier",  4
	0.0,	//	"T Barrier",  5
	0.0,	//	"No Fall Damage",  6
	0.5,	//	"Honey",  7
	0.0,	//	"Ice",  8
	300.0,	//	"Trampoline",  9
	200.0,	//	"Low Gravity",  10
	0.25,	//	"Healer",  11
	260.0,	// 	"Speed Boost",  12
	1.0,	// 	"Invincibility",  13
	1.0,	// 	"Stealth",  14
	0.0,//1.0,	// 	"Camouflage",  15
	1.0,	// 	"Boots Of Speed",  16
	0.0,	// 	"HE Nade",  17
	0.0,	// 	"FrostNade",  18
	0.0,	// 	"Flash Nade",  19 
	0.0,	// 	"Weapons",  20 
	0.25,	//	"Damage",  21
	0.25,	//	"Fire",  22
	0.0,	// 	"Slap",  23
	0.0		// 	"Death"  24
};

new const String:g_sTimeNazwa[ MAX_BLOCKS ][ 34 ] = { // Descricao
	"Nenhum",				// 	"Platform",  0
	"Nenhum",				//	"Glass",  1
	"Desaparece em",		//	"Bunnyhop",  2
	"Desaparece em",		//	"Delayed Bhop",  3
	"Nenhum",				//	"CT Barrier",  4
	"Nenhum",				//	"T Barrier",  5
	"Nenhum",				//	"No Fall Damage",  6
	"Nenhum",				//	"Honey",  7
	"Nenhum",				//	"Ice",  8
	"Altura",				//	"Trampoline",  9
	"Nenhum",				//	"Low Gravity",  10
	"Intervalo",			//	"Healer",  11
	"Altura",				// 	"Speed Boost",  12
	"Tempo",				// 	"Invincibility",  13
	"Tempo",				// 	"Stealth",  14
	"Nenhum",//"Tempo",				// 	"Camouflage",  15
	"Tempo",				// 	"Boots Of Speed",  16
	"Nenhum",				// 	"HE Nade",  17
	"Nenhum",				// 	"FrostNade",  18
	"Nenhum",				// 	"Flash Nade",  19 
	"Arma",					// 	"Weapons",  20 
	"Intervalo",			//	"Damage",  21
	"Intervalo",			//	"Fire",  22
	"Nenhum",				// 	"Slap",  23
	"Mata com GodMode"		// 	"Death"  24
};

new const g_iOnTopDef[ MAX_BLOCKS ] = { // Somente em cima Padrao.
	1,	// 	"Platform",  0
	1,	//	"Glass",  1
	1,	//	"Bunnyhop",  2
	1,	//	"Delayed Bhop",  3
	1,	//	"CT Barrier",  4
	1,	//	"T Barrier",  5
	0,	//	"No Fall Damage",  6
	1,	//	"Honey",  7
	1,	//	"Ice",  8
	1,	//	"Trampoline",  9
	1,	//	"Low Gravity",  10
	1,	//	"Healer",  11
	1,	// 	"Speed Boost",  12
	1,	// 	"Invincibility",  13
	1,	// 	"Stealth",  14
	1,	// 	"Camouflage",  15
	1,	// 	"Boots Of Speed",  16
	1,	// 	"HE Nade",  17
	1,	// 	"FrostNade",  18
	1,	// 	"Flash Nade",  19 
	1,	// 	"Weapons",  20 
	1,	//	"Damage",  21
	0,	//	"Fire",  22
	0,	// 	"Slap",  23
	1	// 	"Death"  24
};
new const g_iOnlyTDef[ MAX_BLOCKS ] = { // so para Tr's
	0,	// 	"Platform",  0
	0,	//	"Glass",  1
	0,	//	"Bunnyhop",  2
	0,	//	"Delayed Bhop",  3
	0,	//	"CT Barrier",  4
	0,	//	"T Barrier",  5
	0,	//	"No Fall Damage",  6
	0,	//	"Honey",  7
	0,	//	"Ice",  8
	0,	//	"Trampoline",  9
	0,	//	"Low Gravity",  10
	0,	//	"Healer",  11
	0,	// 	"Speed Boost",  12
	1,	// 	"Invincibility",  13
	1,	// 	"Stealth",  14
	1,	// 	"Camouflage",  15
	1,	// 	"Boots Of Speed",  16
	1,	// 	"HE Nade",  17
	1,	// 	"FrostNade",  18
	1,	// 	"FlashNade",  19 
	1,	// 	"Weapons",  20 
	0,	//	"Damage",  21
	0,	//	"Fire",  22
	0,	// 	"Slap",  23
	0	// 	"Death"  24
};

new const String:g_sBlocks[ MAX_BLOCKS ][ 21 ] = {
	"Platform", 		// 0
	"Glass", 			// 1
	"Bunnyhop", 		// 2
	"Delayed Bhop", 	// 3
	"CT Barrier", 		// 4
	"T Barrier", 		// 5
	"No Fall Damage", 	// 6
	"Honey", 			// 7
	"Ice", 				// 8
	"Trampoline", 		// 9
	"Low Gravity", 		// 10
	"Healer", 			// 11
	"Speed Boost", 		// 12
	"Invincibility", 	// 13
	"Stealth", 			// 14
	"Camouflage Desativado",//"Camouflage", 		// 15
	"Boots Of Speed", 	// 16
	"HE Nade", 			// 17
	"FrostNade", 		// 18
	"Flash Nade", 		// 19 
	"Weapons", 			// 20 
	"Damage Desativado", 			// 21
	"Fire", 			// 22
	"Slap Desativado", 			// 23
	"Death" 			// 24
};

//NOME DOS MDL
new const String:g_sNormalneKlocki[ MAX_BLOCKS + 1 ][ ] = {
	"platform",		// 	"Platform",  0 // detranplatform1
	"glass",			//	"Glass",  1 detranglass
	"bunnyhop",			//	"Bunnyhop",  2 detranbhop
	"bhop_delayed",			//	"Delayed Bhop",  3 detrandelay
	"barrier_ct",		//	"CT Barrier",  4  detranctbarrier
	"barrier_tt",		//	"T Barrier",  5 detrantbarrier
	"nofalldamage",		//	"No Fall Damage",  6 detrannofalldmg
	"honey",			//	"Honey",  7 detranhoney
	"ice1",			//	"Ice",  8 detranice1
	"trampoline",		//	"Trampoline",  9 detrantrampoline
	"gravity",		//	"Low Gravity",  10
	"healer",			//	"Healer",  11
	"speedboost",		// 	"Speed Boost",  12
	"godmode",	// 	"Invincibility",  13
	"stealth",		// 	"Stealth",  14
	"platform",//"detrancamouflage",		// 	"Camouflage",  15
	"boots2",	// 	"Boots Of Speed",  16
	"grenade",			// 	"HE Nade",  17
	"smoke",		// 	"FrostNade",  18
	"flash",		// 	"Flash Nade",  19 
	"weapon",			// 	"Weapons",  20 
	"platform",			//	"Damage",  21
	"damage",			//	"Fire",  22
	"platform",			// 	"Slap",  23
	"death",			// 	"Death"  24
	"platform"				// 	"AWP SKIN BLOCK WEAPON"  24
};

static const String:g_sRozszerzenia[MAX_RESOURCES][] = {
	".mdl",
	".dx90.vtx",
	".phy",
	".vvd",
	".vmt",
	".vtf"
};

public Action:WeaponsMenu( iClient, args ) {
	new Handle:hMenu = CreateMenu( MenuWeapons );
	SetMenuTitle( hMenu, "[pNr] Weapon Block" );
	
	new String:sWeapon[ 64 ];
	for( new i = 0 ; i < 32 ; i++ ) {
		FormatEx( sWeapon, sizeof sWeapon, g_sWeapons[ i ] );
		ReplaceString( sWeapon, sizeof sWeapon, "weapon_", "" );
		AddMenuItem( hMenu, sWeapon, sWeapon );
	}
	
	SetMenuExitButton( hMenu, true );
	DisplayMenu( hMenu, iClient, 9999 );
 
	return Plugin_Handled;
}

public MenuWeapons( Handle:hMenu, MenuAction:action, param1, param2 ) {
	if( action == MenuAction_Select ) {
		new iEnt = g_iTempKlocek[ param1 ];
		
		if( IsValidBlock( iEnt ) ) {
			new String:sInfo[ 64 ];
			GetMenuItem( hMenu, param2, sInfo, sizeof( sInfo ) );
			
			g_fProp[ iEnt ][ 0 ] = float( param2 );
			
			// if( g_fProp[ iEnt ][ 0 ] == 5.0 )
			// {
				// DispatchKeyValue( iEnt, "model", g_sSciezkaModel[ g_iBlockSize[ iEnt ] ][ 25 ] );
				// SetEntityModel( iEnt, g_sSciezkaModel[ g_iBlockSize[ iEnt ] ][ 25 ] );
			// }
			// else 
			// {
			DispatchKeyValue( iEnt, "model", g_sSciezkaModel[ g_iBlockSize[ iEnt ] ][ 20 ] );
			SetEntityModel( iEnt, g_sSciezkaModel[ g_iBlockSize[ iEnt ] ][ 20 ] );
			// }
					
			CPrintToChat( param1, "%s Arma Escolhida: \x03%s", TAG, sInfo );

			DisplayMenu( CreatePropMenu( param1 ), param1, 0 );
		}
		else {
			CPrintToChat( param1, "%s Could not change the weapon! Block missing", TAG );
			DisplayMenu( CreateMainMenu( param1 ), param1, 0 );
		}
	}
	if(action == MenuAction_End){
		CloseHandle(hMenu);
		DisplayMenu(CreateMainMenu(param1), param1, 0);
	}
}

public Action:PlayerSpawn(Handle:hEvent, const String:sName[], bool:bDontBroadcast){
	new userId = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(IsClientConnected(userId)) {
		//g_bLocked[ i ] = false;
		g_iBlocks[ userId ] = -1;
		g_bTriggered[ userId ] = false;
		g_iTeleporters[ userId ] = -1;

		g_iGravity[ userId ] = 0;
		CreateTimer( 0.5, ResetGrav, userId );

		g_fLastHP[ userId ] = GetGameTime( );
		g_fLastDuck[ userId ] = GetGameTime( );
		g_fLastFire[ userId ] = GetGameTime( );
		g_fLastSpeed[ userId ] = GetGameTime( );
		g_fLastTramp[ userId ] = GetGameTime( );
		g_fLastDamage[ userId ] = GetGameTime( );
		
		//g_fLastChance[ i ] = GetGameTime( ); BUG. Respawn chance block

		for( new l = 0 ; l < 2048 ; l++ ) {
			g_bDeagleCanUse[ userId ][ l ] = true;
			g_bHEgrenadeCanUse[ userId ][ l ] = true;
			g_bFlashbangCanUse[ userId ][ l ] = true;
			g_bSmokegrenadeCanUse[ userId ][ l ] = true;
			g_fChance[ userId ][ l ] = 0.0;
		}

		g_fActChance[ userId ] = 0.0;
		g_bChance[ userId ] = false;
		g_iCurrentTele[ userId ] = -1;
		
		g_bBoots[ userId ] = false;
		g_bStealth[ userId ] = false;
		g_bKamuflaz[ userId ] = false;
		
		g_bInvCanUse[ userId ] = true;
		g_bStealthCanUse[ userId ] = true;
		g_bBootsCanUse[ userId ] = true;
		
		if( IsClientInGame( userId ) && IsPlayerAlive( userId ) ) {
			SetEntityRenderMode( userId, RENDER_NORMAL );
			SetEntityRenderFx( userId, RENDERFX_NONE );
			SetEntityRenderColor( userId, 255, 255, 255, 255 );
		}
	}
}

public Action:zH_PlayerDeath(Handle:hEvent, const String:sName[], bool:bDontBroadcast){
	new iOfiara = GetClientOfUserId(GetEventInt(hEvent, "userid"));
			
	if((1 <= iOfiara <= 64) && IsClientConnected(iOfiara)){
		if(g_bChance[iOfiara]){
			new Float:fSzansa = g_fActChance[iOfiara];
			new iRan = GetRandomInt(1, 100);
			if(iRan <= RoundFloat(fSzansa)){
				CreateTimer(0.3, fixSpw, iOfiara, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		if(g_iGravity[iOfiara]){
			g_iGravity[iOfiara]=0;
		}
	}
	
	if( g_iDragEnt[ iOfiara ] )
	{
		ustawRender( g_iDragEnt[ iOfiara ] );
		g_iDragEnt[ iOfiara ] = 0;
	}
}

// public Action:tskAutoSave(Handle:hTimer){
	// g_hAutoSave = INVALID_HANDLE;
	
	// SaveBlocks(true);
	
	// if(g_bAutoSave) g_hAutoSave = CreateTimer(300.0, tskAutoSave);
// }

public Action:fixSpw(Handle:hTimer, any:iOfiara) {
	if(IsClientInGame(iOfiara)){
		decl String:sName[MAX_NAME_LENGTH];
		GetClientName(iOfiara, sName, sizeof(sName));
				
		CS_RespawnPlayer(iOfiara);
		
		new Float:vec[3];
		GetClientAbsOrigin(iOfiara, vec);
		vec[2] += 10;
		EmitAmbientSound(RESPAWN_SOUND_PATH, vec, iOfiara, SNDLEVEL_CONVO);	
		
		CPrintToChatAll("{blue}*{lime}[!!!]{orange} %s had charged Respawn Chance and got respawned! [{lime}%d%c{orange}]", sName, RoundFloat(g_fActChance[iOfiara]), '%');
	}
}

public Action:Command_UnitMove(client, args){	
	if(1 <= client <= MaxClients && IsClientConnected(client) && IsClientInGame(client)) {
		if( !g_bEnabled ) {
			CPrintToChat( client, "%s Você não pode mover o bloco no live.", TAG );
			return Plugin_Handled;
		} 
		else {
			DrawUnitMovePanel( client );
			return Plugin_Handled;
		}

	}
	return Plugin_Handled;
}

public Handle:CreateSurfMenu( iClient )
{
	new Handle:iMenu = CreateMenu( Handler_SurfMenu );
	SetMenuTitle( iMenu, "[pNr] Surf Menu");
	AddMenuItem( iMenu, "0", "1st Side" );
	AddMenuItem( iMenu, "1", "2nd Side \n ");
	
	SetMenuExitBackButton( iMenu, true );
	return iMenu;
}

public Handler_SurfMenu( Handle:iMenu, MenuAction:iAction, iClient, param2 )
{
	if( iAction == MenuAction_Select ) {
		new ent = GetClientAimTarget( iClient, false );
		if( IsValidBlock( ent ) ) {
			new Float:currentEntLocation[ 3 ];
			GetEntPropVector( ent, Prop_Data, "m_angRotation", currentEntLocation );  

			new Float:byUnitsFloat = 60.0;
			new iRot = g_iRotation[ ent ];

			if( param2 == 0 ) {
				if( iRot == 0 || iRot == 1 ) {
					if( IsValidBlock( ent ) ) {
						currentEntLocation[ 0 ] = 0.0;
						currentEntLocation[ 1 ] = 0.0;
						currentEntLocation[ 2 ] = byUnitsFloat;
						
						TeleportEntity( ent, NULL_VECTOR, currentEntLocation, NULL_VECTOR );
					}
					else {
						CPrintToChat( iClient, "%s Mire no bloco primeiro!", TAG );
						DisplayMenu( CreateSurfMenu( iClient ), iClient, 0 );
					}
				}
				else {
					if( IsValidBlock( ent ) ) {
						currentEntLocation[ 1 ] = 90.0;
						currentEntLocation[ 0 ] = -180.0;
						currentEntLocation[ 2 ] = 120.0;
						
						TeleportEntity( ent, NULL_VECTOR, currentEntLocation, NULL_VECTOR );
					}
					else {
						CPrintToChat( iClient, "%s Mire no bloco primeiro!", TAG );
						DisplayMenu( CreateSurfMenu( iClient ), iClient, 0 );
					}
				}
				
				DisplayMenu( CreateSurfMenu( iClient ), iClient, 0 );
			}
			if( param2 == 1 ) {
				if( iRot == 0 || iRot == 1 ) {
					if( IsValidBlock( ent ) ) {
						currentEntLocation[ 0 ] = 0.0;
						currentEntLocation[ 1 ] = 0.0;
						currentEntLocation[ 2 ] = byUnitsFloat * -1.0;
						
						TeleportEntity( ent, NULL_VECTOR, currentEntLocation, NULL_VECTOR );
					}
					else {
						CPrintToChat( iClient, "%s Mire no bloco primeiro!", TAG );
						DisplayMenu( CreateSurfMenu( iClient ), iClient, 0 );
					}
				}
				else {
					if( IsValidBlock( ent ) ) {
						currentEntLocation[ 1 ] = 90.0;
						currentEntLocation[ 0 ] = -180.0;
						currentEntLocation[ 2 ] = -120.0;
						
						TeleportEntity( ent, NULL_VECTOR, currentEntLocation, NULL_VECTOR );
					}
					else {
						CPrintToChat( iClient, "%s Mire no bloco primeiro!", TAG );
						DisplayMenu( CreateSurfMenu( iClient ), iClient, 0 );
					}
				}
					
				DisplayMenu( CreateSurfMenu( iClient ), iClient, 0 );
			}
		} else {
			CPrintToChat( iClient, "%s Mire no bloco primeiro!", TAG );
			DisplayMenu( CreateSurfMenu( iClient ), iClient, 0 );
		}
	}
	else if( ( iAction == MenuAction_Cancel ) || ( param2 == MenuCancel_ExitBack ) ) {
		DisplayMenu( CreateBlockMenu( iClient ), iClient, 0 );
	}
}

DrawUnitMovePanel(iClient){
	new String:sInfo[64], String:sAxis[12];
	
	new Handle:hPanel = CreatePanel();
	SetPanelTitle(hPanel, "[pNr] Movement Menu");
	FormatEx(sInfo, sizeof sInfo, "Level: %.1f\nAXIS", float(byUnits[iClient])/10);
	
	DrawPanelItem(hPanel, sInfo);
	
	for(new i = 0 ; i < 6 ; i++){
		FormatEx(sAxis, sizeof sAxis, "%c%c%s", i / 2 == 0 ? 88 : i/2==1 ? 89 : 90, i%2 ? '+' : '-', i==5? "\nSettings" : "");
		DrawPanelItem(hPanel, sAxis); //ASCII KODY = 88-90	
	}
	FormatEx(sAxis, sizeof sAxis, "%s", !g_bRotationMode[iClient] ? "Position \n " : "Rotation \n ");
	DrawPanelItem(hPanel, sAxis);
	DrawPanelItem(hPanel, "Exit");
	SendPanelToClient(hPanel, iClient, DrawUnitMovePanelHandler, 999);
	
	CloseHandle(hPanel);
}

public DrawUnitMovePanelHandler( Handle:hMenu, MenuAction:action, iClient, iKey ) {
	if( action == MenuAction_Select ) {
		new Float:currentEntLocation[ 3 ];
		new Float:byUnitsFloat = float( byUnits[ iClient ] ) / 5;
		new ent = GetClientAimTarget( iClient, false );			
		
		switch( iKey ) {
			case 1: {
				switch( byUnits[ iClient ] ) {
					case 1: byUnits[ iClient ] = 5;
					case 5:	byUnits[ iClient ] = 10;
					case 10: byUnits[ iClient ] = 80;
					case 120: byUnits[ iClient ] = 320;
					case 330: byUnits[ iClient ] = 640;
					case 660: byUnits[ iClient ] = 1;
					default: byUnits[ iClient ] = 1;
				}
			}
			case 2, 3, 4, 5, 6, 7: { 
				if( IsValidBlock( ent ) ) {
					GetEntPropVector( ent, Prop_Send, !g_bRotationMode[iClient] ? "m_vecOrigin" : "m_angRotation", currentEntLocation );
					
					new iAxis = iKey - 2;
					currentEntLocation[ iAxis / 2 ] = iAxis % 2 ?  currentEntLocation[ iAxis / 2 ] - byUnitsFloat : currentEntLocation[ iAxis / 2 ] + byUnitsFloat;
				}
			}
			case 8: {
				g_bRotationMode[ iClient ] = !g_bRotationMode[ iClient ];
			}
			case 9: { 
				DisplayMenu( CreateBlockMenu( iClient ), iClient, 0 );
			}
		}
		
		if( iKey != 9 )
			DrawUnitMovePanel( iClient );
		
		if( iKey !=1 && iKey !=8 && iKey !=9 ) {
			if( !g_bRotationMode[ iClient ] )
			{
				TeleportEntity( ent, currentEntLocation, NULL_VECTOR, NULL_VECTOR );
			}
			else
			{
				TeleportEntity( ent, NULL_VECTOR, currentEntLocation, NULL_VECTOR );
			}
		}
	}
}

public Action:RoundStart( Handle:event, const String:name[ ], bool:dontBroadcast ) {
	//g_iRespawn=0;//BUG. Bloco chance de respawn.
	
	for( new i = 0; i < 2048; ++i ) {
		//g_bLocked[ i ] = false;
		g_iBlocks[ i ] = -1;
		g_bTriggered[ i ] = false;
		g_iTeleporters[ i ] = -1;
	}
	
	for( new i = 1; i <= MaxClients; ++i ) {
		g_iGravity[ i ] = 0;
		CreateTimer( 0.5, ResetGrav, i );

		// g_bOnIce[ i ] = false;
		g_fLastHP[ i ] = GetGameTime( );
		g_fLastDuck[ i ] = GetGameTime( );
		g_fLastFire[ i ] = GetGameTime( );
		g_fLastSpeed[ i ] = GetGameTime( );
		g_fLastTramp[ i ] = GetGameTime( );
		g_fLastDamage[ i ] = GetGameTime( );
		
		//g_fLastChance[ i ] = GetGameTime( ); BUG. Respawn chance block

		for( new l = 0 ; l < 2048 ; l++ ) {
			g_bDeagleCanUse[ i ][ l ] = true;
			g_bHEgrenadeCanUse[ i ][ l ] = true;
			g_bFlashbangCanUse[ i ][ l ] = true;
			g_bSmokegrenadeCanUse[ i ][ l ] = true;
			g_fChance[ i ][ l ] = 0.0;
		}
		
		g_fActChance[ i ] = 0.0;
		g_bChance[ i ] = false;
		g_iCurrentTele[ i ] = -1;
		
		g_bBoots[ i ] = false;
		g_bStealth[ i ] = false;
		g_bKamuflaz[ i ] = false;
		
		g_bInvCanUse[ i ] = true;
		g_bStealthCanUse[ i ] = true;
		g_bBootsCanUse[ i ] = true;
		
		if( IsClientInGame( i ) && IsPlayerAlive( i ) ) {
			SetEntityRenderMode( i, RENDER_NORMAL );
			SetEntityRenderFx( i, RENDERFX_NONE );
			SetEntityRenderColor( i, 255, 255, 255, 255 );
		}
	}

	LoadBlocks( );
}

public OnClientDisconnect( client ) {
	
	if( g_iDragEnt[ client ] )
	{
		g_iDragEnt[ client ] = 0;
	}
	
	g_iOldButtons[client] = 0;

	SDKUnhook(client, SDKHook_Touch, touchGracza);
	SDKUnhook(client, SDKHook_PreThink, ClientPreThink);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamagePost);
	SDKUnhook(client, SDKHook_WeaponDropPost, Event_WeaponDrop);
	
	g_bBhopUsed[ client ] = false;
	
	StopTimer_RemoveEffect( client );
}

public Event_WeaponDrop( client, weapon ) {

	if ( weapon < 1 ) return;

	if ( !IsValidEntity( weapon ) ) return;

	if ( !KillEntity( weapon ) )
	{
		decl String:wep[32];
		GetEntityClassname( weapon, wep, sizeof( wep ) );

		LogError( "Couldn't delete weapon %s (%i)!", wep, weapon );
	}

	// CreateTimer( 0.05, removeWeapon, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE );
}

stock bool:KillEntity( ent )
{
	return AcceptEntityInput( ent, "Kill" );
}

public OnClientPutInServer(client){
	if(!IsFakeClient(client)){
		g_fDistance[client] = 200.0;

		SDKHook(client, SDKHook_Touch, touchGracza);
		SDKHook(client, SDKHook_PreThink, ClientPreThink);
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamagePost);
		SDKHook(client, SDKHook_WeaponDropPost, Event_WeaponDrop);
		
		g_bSnapping[ client ] = true;
		g_fSnappingGap[ client ] = 0.0
		
		g_bBhopUsed[ client ] = false;
		
		g_bKamuflaz[client] = false
		g_bStealth[client] = false;
		g_bInv[client] = false;
		g_bInvCanUse[client] = true;
		g_bStealthCanUse[client] = true;
		g_bBootsCanUse[client] = true;
		g_bDamage[client] = false;
		
		g_bNoFallDmg[ client ] = false;
		//g_bCamCanUse[client]=true;
		g_bBoots[client]=false;
		g_iTempAlpha[client] = 255;
		g_iTempKlr[client][0] = 255;
		g_iTempKlr[client][1] = 255;
		g_iTempKlr[client][2] = 255;
		
		
		g_iGravity[ client ] = 0;
		
		g_iTempSize[client]=2;
		for(new i = 0 ; i < 2048 ; i++){
			g_bDeagleCanUse[client][i] = true;
			g_bHEgrenadeCanUse[client][i] = true;
			g_bFlashbangCanUse[client][i] = true;
			g_bSmokegrenadeCanUse[client][i] = true;
		}

		g_iCurrentTele[client]=-1;
	}
}

public OnMapStart( ) {

	new ent = -1;
	CreateEntityByName( "shadow_control" );
	while( ( ent = FindEntityByClassname( ent, "shadow_control" ) ) != -1 )
	{ 
		// I hope I'm doing it right 
		// Also may not work because "This feature is only available in the Half Life 2 engine" 
		SetVariantInt( 1 ); 
		AcceptEntityInput( ent, "SetShadowsDisabled" ); 
		
		SetVariantFloat( 0.0 );
		AcceptEntityInput( ent, "SetDistance" );

		KillEntity( ent );
	}
	
	new iEnt = -1;
	CreateEntityByName( "env_cascade_light" );
	while ( ( iEnt = FindEntityByClassname( iEnt, "env_cascade_light" ) ) != -1 )
	{ 
		KillEntity( iEnt );
	}

	FakePrecacheSound( INVI_SOUND_PATH );
	FakePrecacheSound( STEALTH_SOUND_PATH );
	FakePrecacheSound( BOS_SOUND_PATH );
	// FakePrecacheSound( CAM_SOUND_PATH );
	FakePrecacheSound( TELE_SOUND_PATH );
	FakePrecacheSound( FIRE_SOUND_PATH );
	
	PrecacheSound( "sound/blockbuilder/invincibility.mp3", true );
	
	new String:sSciezka[ 256 ];
	for ( new b ; b < MAX_BLOCKS ; b++ ) 
	{
		for ( new p = 0 ; p < 5 ; p++ )
		{
			FormatEx( g_sSciezkaModel[ p ][ b ], 256, "models/%s_%s/%s.mdl", g_sPodFolder, p == 0 ? "pole" : p == 1 ? "small" : p == 2 ? "normal" : p == 3 ? "large" : "xlarge", g_sNormalneKlocki[ b ] );
			PrecacheModel( g_sSciezkaModel[ p ][ b ] );
			
			for ( new l ; l < MAX_RESOURCES ; l++ ) 
			{
				if ( l >= 4 )
				{
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/%s%s", g_sPodFolder, g_sNormalneKlocki[ b ], g_sRozszerzenia[ l ] );
				}
				else 
				{
					FormatEx( sSciezka, sizeof sSciezka, "models/%s_%s/%s%s", g_sPodFolder, p == 0 ? "pole" : p == 1 ? "small" : p == 2 ? "normal" : p == 3 ? "large" : "xlarge", g_sNormalneKlocki[ b ], g_sRozszerzenia[ l ] );
				}
				
				AddFileToDownloadsTable( sSciezka );
				
				if ( p >= 0 && l >= 4 )
				{
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/%s_%s%s", g_sPodFolder, g_sNormalneKlocki[ b ], p == 0 ? "stick" : p == 1 ? "pole" : p == 2 ? "pole" : p == 3 ? "pole" : "pole", g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/deagle%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/deagle_pole%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );

					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/awp%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/awp_pole%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/p250%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/p250_pole%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/tec9%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/tec9_pole%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
										
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/ak47%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/ak47_pole%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/usp%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
					
					FormatEx( sSciezka, sizeof sSciezka, "materials/%s/usp_pole%s", g_sPodFolder, g_sRozszerzenia[ l ] );
					AddFileToDownloadsTable( sSciezka );
				}
			}
		}
	}
	
	for( new x = 0 ; x < 4 ; x++ ) {
		FakePrecacheSound( g_sHoney[ x ] );

		new String:sPrec[ 128 ];
		FormatEx( sPrec, sizeof sPrec, "sound/%s", g_sHoney[ x ] );
		ReplaceString( sPrec, sizeof sPrec, "*", "", false );

		PrecacheSound( sPrec, true );

		AddFileToDownloadsTable( sPrec );
	}
	
	
	
	PrecacheModel( "models/platforms/b-tele.mdl", true );
	PrecacheModel( "models/platforms/r-tele.mdl", true );
	PrecacheModel( "models/player/ctm_gign.mdl" );
	PrecacheModel( "models/player/tm_phoenix.mdl" );
		
	for( new i = 0 ; i < 2048 ; i++ ) {
		// g_iRuchomy[ i ] = 0; 
		g_bTeleport[ i ] = false; 
	}

	DownloadsTable( );

	g_iBeamSprite = PrecacheModel( "materials/sprites/orangelight1.vmt" );
	
	for( new i = 0; i < 2048; ++i )	{
		g_iBlocks[ i ] = -1;
		g_iTeleporters[ i ] = -1;
		g_bTriggered[ i ] = false;
	}
	
	if( g_hBlocksKV != INVALID_HANDLE )	{
		CloseHandle( g_hBlocksKV );
		g_hBlocksKV = INVALID_HANDLE;
	}
	
	new String:SzFile[ 256 ], String:SzMap[ 64 ];
	GetCurrentMap( SzMap, sizeof( SzMap ) );
	BuildPath( Path_SM, SzFile, sizeof( SzFile ), "data/block.%s.txt", SzMap );
	if(FileExists( SzFile ))
	{
		g_hBlocksKV = CreateKeyValues( "Blocks" );
		FileToKeyValues( g_hBlocksKV, SzFile );
	}
}

DownloadsTable( )
{
	AddFileToDownloadsTable("models/platforms/b-tele.mdl");
	AddFileToDownloadsTable("models/platforms/b-tele.dx80.vtx")
	AddFileToDownloadsTable("models/platforms/b-tele.dx90.vtx")
	AddFileToDownloadsTable("models/platforms/b-tele.sw.vtx")
	AddFileToDownloadsTable("models/platforms/b-tele.phy")
	AddFileToDownloadsTable("models/platforms/b-tele.vvd")
	AddFileToDownloadsTable("models/platforms/r-tele.mdl");
	AddFileToDownloadsTable("models/platforms/r-tele.dx80.vtx")
	AddFileToDownloadsTable("models/platforms/r-tele.dx90.vtx")
	AddFileToDownloadsTable("models/platforms/r-tele.sw.vtx")
	AddFileToDownloadsTable("models/platforms/r-tele.phy")
	AddFileToDownloadsTable("models/platforms/r-tele.vvd")

	AddFileToDownloadsTable("materials/models/platforms/glow2.vtf")
	AddFileToDownloadsTable("materials/models/platforms/glow2.vmt")
	AddFileToDownloadsTable("materials/models/platforms/blue_glow1.vmt")
	AddFileToDownloadsTable("materials/models/platforms/blue_glow1.vtf")
	AddFileToDownloadsTable("materials/models/platforms/red_glow1.vtf")
	AddFileToDownloadsTable("materials/models/platforms/red_glow1.vmt")
	AddFileToDownloadsTable("materials/models/platforms/sphere.vmt")
	AddFileToDownloadsTable("materials/models/platforms/sphere.vtf")
	AddFileToDownloadsTable("materials/models/platforms/tape.vmt")
	AddFileToDownloadsTable("materials/models/platforms/tape.vtf")
	
	AddFileToDownloadsTable("sound/blockbuilder/bootsofspeed.mp3" );
	AddFileToDownloadsTable("sound/blockbuilder/stealth.mp3" );
	//AddFileToDownloadsTable("sound/blockbuilder/camouflage.mp3" );
	AddFileToDownloadsTable("sound/blockbuilder/invincibility.mp3" );
	AddFileToDownloadsTable("sound/blockbuilder/teleport.mp3" );
	AddFileToDownloadsTable("sound/blockbuilder/flameburst1.wav" );
}

new bool:g_iSaving=false;

SaveBlocks(bool:msg=false){
	if(g_iSaving){
	}
	else if(!g_iSaving){
		g_iSaving=true;
		
		if(g_hBlocksKV != INVALID_HANDLE)
			CloseHandle(g_hBlocksKV);
		g_hBlocksKV = CreateKeyValues("Blocks");
		KvGotoFirstSubKey(g_hBlocksKV);
		new index = 1, blocks=0,teleporters=0;
		new String:tmp[11];
		new Float:fPos[3], Float:fAng[3];
		
		new Float:fOld[2048][3];
		
		new bool:bPomoz=false;
		new iPomoz = 0;
		for(new i=MaxClients+1;i<2048;++i)
		{
			if(!IsValidEntity(i) || !IsValidBlock(i) || g_iTeleporters[i]==1)
				continue;
			
			GetEntPropVector(i, Prop_Data, "m_vecOrigin", fPos);
			
			IntToString(index, tmp, sizeof(tmp));
			KvJumpToKey(g_hBlocksKV, tmp, true);
			if(g_iTeleporters[i]>1 && IsValidBlock(g_iTeleporters[i]))
			{
				for(new x = MaxClients+1 ; x < 2048 ; ++x){
					if((fPos[0] == fOld[x][0] && fPos[1] == fOld[x][1] && fPos[2] == fOld[x][2]) && (fPos[0] != 0.0 && fPos[1] != 0.0 && fPos[2] != 0.0) && g_iRotation[x] == g_iRotation[i]){
						if(!bPomoz) bPomoz = true;
						
						iPomoz++;
						
						AcceptEntityInput(i, "Kill");
						
						if(IsValidEdict(i)) RemoveEdict(i);
						
						continue;
					}
				}
				
				for(new b = 0 ; b < 3 ; b++)
					fOld[i][b] = fPos[b];
				
				GetEntPropVector(g_iTeleporters[i], Prop_Data, "m_vecOrigin", fAng);
				KvSetNum(g_hBlocksKV, "teleporter", 1);
				KvSetVector(g_hBlocksKV, "entrance", fPos);
				KvSetVector(g_hBlocksKV, "exit", fAng);
				
				KvSetNum(g_hBlocksKV, "klrR", g_iKlr[i][0]);
				KvSetNum(g_hBlocksKV, "klrG", g_iKlr[i][1]);
				KvSetNum(g_hBlocksKV, "klrB", g_iKlr[i][2]);
				
				KvSetNum(g_hBlocksKV, "alpha", g_iAlpha[i]);
				
				teleporters++;
			}
			else
			{	
				for(new x = MaxClients+1 ; x < 2048 ; ++x){
					if((fPos[0] == fOld[x][0] && fPos[1] == fOld[x][1] && fPos[2] == fOld[x][2]) && (fPos[0] != 0.0 && fPos[1] != 0.0 && fPos[2] != 0.0)){
						if(!bPomoz) bPomoz = true;
						
						iPomoz++;
						
						AcceptEntityInput(i, "Kill");
						
						if(IsValidEdict(i)) RemoveEdict(i);
						
						continue;
					}
				}
				
				for(new b = 0 ; b < 3 ; b++)
					fOld[i][b] = fPos[b];
				
				GetEntPropVector(i, Prop_Data, "m_angRotation", fAng);
				KvSetNum(g_hBlocksKV, "blocktype", g_iBlocks[i]);
				KvSetVector(g_hBlocksKV, "position", fPos);
				KvSetVector(g_hBlocksKV, "angles", fAng);
				
				KvSetNum(g_hBlocksKV, "ontop", g_iOnTop[i]);
				
				KvSetNum(g_hBlocksKV, "klrR", g_iKlr[i][0]);
				KvSetNum(g_hBlocksKV, "klrG", g_iKlr[i][1]);
				KvSetNum(g_hBlocksKV, "klrB", g_iKlr[i][2]);
				
				KvSetNum(g_hBlocksKV, "alpha", g_iAlpha[i]);
				
				KvSetNum(g_hBlocksKV, "ttonly", g_iOnlyT[i]);
				KvSetNum(g_hBlocksKV, "rotation", g_iRotation[i]);
				KvSetFloat(g_hBlocksKV, "czasprop1", g_fProp[i][0]);
				KvSetFloat(g_hBlocksKV, "czasprop2", g_fProp[i][1]);
								
				KvSetNum(g_hBlocksKV, "block_size", g_iBlockSize[i]);
				
				KvSetString( g_hBlocksKV, "Creator", g_sAutor[ i ] );
				
				blocks++;
			}
			KvGoBack(g_hBlocksKV);
			index++;
		}
		KvRewind(g_hBlocksKV);
		new String:file[256];
		new String:map[64];

		GetCurrentMap( map, sizeof( map ) );
		BuildPath( Path_SM, file, sizeof( file ), "data/block.%s.txt", map );
		KeyValuesToFile( g_hBlocksKV, file );
		
		if( msg ) {
			new String:sPomoz[ 64 ];
			FormatEx( sPomoz, sizeof sPomoz, "{GREEN}%d {NORMAL}copies", iPomoz );
			CPrintToChatAll( "%s {DARKRED}%d {NORMAL}blocks and {DARKRED}%d {NORMAL}teleports have been saved %s", TAG, blocks, teleporters, bPomoz ? sPomoz : "" );
			
			if( bPomoz ) 
				SaveBlocks( );
		}
		
		g_iSaving = false;
	}
}

LoadBlocks(bool:msg=false){
	if(g_hBlocksKV == INVALID_HANDLE)
		return;
	
	new teleporters=0, blocks=0;
	new Float:fPos[3], Float:fAng[3], iOdGory, iKolor[3], iAlpha, iTOnly;
	KvRewind(g_hBlocksKV);
	KvGotoFirstSubKey(g_hBlocksKV);
	do{
		if(KvGetNum(g_hBlocksKV, "teleporter") == 1){
			KvGetVector(g_hBlocksKV, "entrance", fPos);
			KvGetVector(g_hBlocksKV, "exit", fAng);
			
			iAlpha = KvGetNum(g_hBlocksKV, "alpha");
			
			iKolor[0] = KvGetNum(g_hBlocksKV, "klrR");
			iKolor[1] = KvGetNum(g_hBlocksKV, "klrG");
			iKolor[2] = KvGetNum(g_hBlocksKV, "klrB");
			
			new iEnt = CreateTeleportEntrance(0, fPos);
			new iEnt2 = CreateTeleportExit(0, fAng);
			
			g_iTeleporters[iEnt] = iEnt2;
			
			// if ( iAlpha == 0 )
			// {
				// g_iAlpha[ iEnt ] = 51;
			// }
			// else if ( iAlpha == 254 )
			// {
				// g_iAlpha[ iEnt ] = 255;
			// }
			// else 
			// {
				// g_iAlpha[ iEnt ] = iAlpha
			// }
			g_iAlpha[iEnt] = iAlpha == 0 ? 51 : iAlpha;
						
			ustawRender(iEnt);
			ustawRender(iEnt2);
			
			g_bTeleport[iEnt] = true;
			g_bTeleport[iEnt2] = true;
			
			// g_iRuchomy[iEnt] = 1;
			// g_iOs[iEnt] = 1;
			// g_fRuch[iEnt] = 1.2;
			
			// g_iRuchomy[iEnt2] = 1;
			// g_iOs[iEnt2] = 1;
			// g_fRuch[iEnt2] = 1.2;
			
			teleporters++;
		}
		else{
			iOdGory = KvGetNum(g_hBlocksKV, "ontop");
			iAlpha = KvGetNum(g_hBlocksKV, "alpha");
			
			iKolor[0] = KvGetNum(g_hBlocksKV, "klrR");
			iKolor[1] = KvGetNum(g_hBlocksKV, "klrG");
			iKolor[2] = KvGetNum(g_hBlocksKV, "klrB");
			
			iTOnly = KvGetNum(g_hBlocksKV, "ttonly");
			
			KvGetVector(g_hBlocksKV, "position", fPos);
			KvGetVector(g_hBlocksKV, "angles", fAng);
			
			new blocktype = KvGetNum(g_hBlocksKV, "blocktype")
			
			new iEnt;
			
			iEnt = CreateBlock(0, KvGetNum(g_hBlocksKV, "block_size"), blocktype, fPos, fAng );
			
			// if( blocktype == 20 )
			// {
				// PrintToServer( "BLOCO DE WEAPON! == %i", g_iBlocks[ iEnt ] );
				
				// new iOpt = RoundFloat( KvGetFloat(g_hBlocksKV, "czasprop1") );
				// if( iOpt == 5 ) {
					// DispatchKeyValue( iEnt, "model", g_sSciezkaModel[ KvGetNum( g_hBlocksKV, "block_size") ][ 25 ] );
					// SetEntityModel( iEnt, g_sSciezkaModel[ KvGetNum(g_hBlocksKV, "block_size") ][ 25 ] );
					
				// }
				
				// g_iOnTop[iEnt] = iOdGory;
			
				// g_iAlpha[iEnt] = iAlpha == 0 ? 51 : iAlpha;
				/*
				if ( iAlpha == 0 )
				{
					g_iAlpha[ iEnt ] = 51;
				}
				else if ( iAlpha == 254 )
				{
					g_iAlpha[ iEnt ] = 255;
				}
				else 
				{
					g_iAlpha[ iEnt ] = iAlpha
				}*/
								
				// g_iOnlyT[iEnt] = iTOnly;
				
				// for(new l = 0 ; l < 3 ; l++){
					// g_iKlr[iEnt][l] = iAlpha == 0 ? 51 : iKolor[l];
				// }
				
				// g_fProp[iEnt][1] = KvGetFloat(g_hBlocksKV, "czasprop2");
				// g_iRotation[iEnt] = KvGetNum(g_hBlocksKV, "rotation");
							
				// ustawRender(iEnt);
				
				// KvGetString( g_hBlocksKV, "Creator", g_sAutor[ iEnt ], 128 );
				
			// }
			
			
			g_iOnTop[iEnt] = iOdGory;
			
			// if ( iAlpha == 0 )
			// {
				// g_iAlpha[ iEnt ] = 51;
			// }
			// else if ( iAlpha == 254 )
			// {
				// g_iAlpha[ iEnt ] = 255;
			// }
			// else {
				// g_iAlpha[ iEnt ] = iAlpha
			// }
			
			g_iAlpha[iEnt] = iAlpha == 0 ? 51 : iAlpha;
			
			g_iOnlyT[iEnt] = iTOnly;
			
			for(new l = 0 ; l < 3 ; l++){
				g_iKlr[iEnt][l] = iAlpha == 0 ? 51 : iKolor[l];
			}
			
			g_fProp[iEnt][0] = KvGetFloat(g_hBlocksKV, "czasprop1");
			g_fProp[iEnt][1] = KvGetFloat(g_hBlocksKV, "czasprop2");
			g_iRotation[iEnt] = KvGetNum(g_hBlocksKV, "rotation");
						
			ustawRender(iEnt);
			
			KvGetString( g_hBlocksKV, "Creator", g_sAutor[ iEnt ], 128 );
						
			g_bTeleport[ iEnt ] = false;
			
			blocks++;
		}
	} while (KvGotoNextKey(g_hBlocksKV));
	
	SaveBlocks(false);
	
	if(msg)
		CPrintToChatAll("%s the blocks and teleports were loaded", TAG);
} 

StopTimer_RemoveEffect( iClient )
{
	if(g_hTimer_RemoveEffect[iClient] == INVALID_HANDLE)
		return;
	
	KillTimer(g_hTimer_RemoveEffect[iClient]);
	g_hTimer_RemoveEffect[iClient] = INVALID_HANDLE;
}

StartTimer_RemoveEffect( iClient )
{
	StopTimer_RemoveEffect( iClient );
	g_hTimer_RemoveEffect[ iClient ] = CreateTimer( 0.8, Timer_RemoveEffect, GetClientSerial( iClient ) );
}

public Action:Timer_RemoveEffect( Handle:hTimer, any:iClientSerial )
{
	new iClient = GetClientFromSerial( iClientSerial );
	if( !iClient )
		return;

	g_hTimer_RemoveEffect[ iClient ] = INVALID_HANDLE;

	if(GetEntPropFloat( iClient, Prop_Send, "m_flLaggedMovementValue" ) <= 0.5 )
		SetEntPropFloat( iClient, Prop_Send, "m_flLaggedMovementValue", 1.0 );

	if(GetEntPropFloat( iClient, Prop_Data, "m_flGravity" ) <= 2.5 )
		SetEntPropFloat( iClient, Prop_Data, "m_flGravity", 1.0 );
}

new bool:g_bUsedE[ MAXPLAYERS + 1 ];
new Float:g_fLastClick[ MAXPLAYERS + 1 ];

OnButtonPress( iClient, iButton ) {
	if( iButton & IN_USE && IsPlayerAlive( iClient ) && !g_bUsedE[ iClient ] ){
		if( GetGameTime( ) - g_fLastClick[ iClient ] >= 0.5 ) {
			g_fLastClick[ iClient ] = GetGameTime( );
			g_bUsedE[ iClient ] = true;
		}
	}
}

OnButtonRelease( id, iButton ) {
	if( iButton & IN_USE ) {
		g_bUsedE[ id ] = false;

		new iEnt = GetClientAimTarget( id, false );
		if( IsValidBlock( iEnt ) && g_iTeleporters[ iEnt ] == -1 ) {
			g_iPropped[ id ] = iEnt;
			
			if( g_hProps[ id ] != INVALID_HANDLE ) { 
				KillTimer( g_hProps[ id ] );
				g_hProps[ id ] = INVALID_HANDLE;
			}
			
			if( !strcmp( g_sAutor[ iEnt ], "" ) ) {
				StrCat( g_sAutor[ iEnt ], 63, "Unknown" );
			}
			
			if( g_iBlocks[ iEnt ] == 20 ) { // Weapon
				new iOpt = RoundFloat( g_fProp[ iEnt ][ 0 ] );
				new String:sWeapon[ 64 ];
				FormatEx(sWeapon, sizeof sWeapon, g_sWeapons[ iOpt ] );
				ReplaceString( sWeapon, sizeof sWeapon, "weapon_", "" );
				
				PrintHintText( id, "<font color='#AAAAAA' size='22'>Block Type:<font size='24' color='#00ff00'> %s<br><font color='#AAAAAA' size='22'>Creator:<font size='20' color='#e5d229'> %s", sWeapon, g_sAutor[ iEnt ] );
			}
			else {
				PrintHintText( id, "<font color='#AAAAAA' size='22'>Block Type:<font size='22' color='#6d0114'> %s<br><font color='#AAAAAA' size='22'>Creator:<font size='20' color='#e5d229'> %s", g_sBlocks[ g_iBlocks[ iEnt ] ], g_sAutor[ iEnt ] );
			}
			
			g_hProps[ id ] = CreateTimer( 0.8, printProps, id );
		}
	}
}

stock createRGB( iR, iG, iB ) {  
    return ( ( iR & 0xff ) << 16 ) + ( ( iG & 0xff ) << 8 ) + ( iB & 0xff );
}

public Action:printProps( Handle:hTimer, any:id ) {
	g_hProps[ id ] = INVALID_HANDLE;
	
	if( IsClientInGame( id ) && IsPlayerAlive( id ) ) {
		new iEnt = g_iPropped[ id ];
		
		if( IsValidBlock( iEnt ) ) {
			new iProps = -1;
			
			new String:sOnTop[ 196 ], String:sOnlyT[ 128 ], String:sProp1[ 128 ], String:sProp2[ 128 ];
			new blocktype = g_iBlocks[iEnt];
			
			if( g_iOnlyTShow[ blocktype ] ) {
				FormatEx( sOnlyT, sizeof sOnlyT, "Only Trs: %s<font color='#A8A8A8'>", g_iOnlyT[ iEnt ] ? "<font color='#00fa00'>Yes" : "<font color='#fa0000'>No" );
				iProps++;
			}
			if( g_iOnTopShow[ blocktype ] ) {
				FormatEx( sOnTop, sizeof sOnTop, "%sOnly Top: %s<font color='#A8A8A8'>", strlen( sOnlyT ) ? "\n" : "", g_iOnTop[ iEnt ] ?  "<font color='#00fa00'>Yes" : "<font color='#fa0000'>No" );
				
				if( iProps < 0 )
					iProps++;
			}
			
			if( !( StrContains( g_sTimeNazwa[ blocktype ], "Nenhum", false ) != -1 ) ) {
				if( blocktype == 24 ) { // Death
					FormatEx(sProp1, sizeof sProp1, "%s: %s<font color='#A8A8A8'>", g_sTimeNazwa[blocktype], g_fProp[iEnt][0] >= 1.0 ? "<font color='#00fa00'>Yes" : "<font color='#fa0000'>No");
				}
				else if( blocktype == 20 ) { // Weapon
					new iOpt = RoundFloat( g_fProp[ iEnt ][ 0 ] );
					new String:sWeapon[ 64 ];
					FormatEx(sWeapon, sizeof sWeapon, g_sWeapons[ iOpt ] );
					ReplaceString( sWeapon, sizeof sWeapon, "weapon_", "" );
					
					FormatEx( sProp1, sizeof sProp1, "%s:<font color='#ff9933'> %s<font color='#A8A8A8'>", g_sTimeNazwa[ blocktype ], sWeapon );
				}
				else{
					FormatEx( sProp1, sizeof sProp1, "%s:<font color='#ff9933'> %.1f<font color='#A8A8A8'>", g_sTimeNazwa[ blocktype ], g_fProp[ iEnt ][ 0 ] );
				}
				
				iProps++;
			}
			
			if( !( StrContains( g_sTime2Nazwa[ blocktype ], "Nenhum", false ) != -1 ) ) {
				FormatEx( sProp2, sizeof sProp2, "%s:<font color='#ff9933'> %.1f<font color='#A8A8A8'>", g_sTime2Nazwa[ blocktype ], g_fProp[ iEnt ][ 1 ] );
				iProps++;
			}

			if( iProps >= 0 )
				PrintHintText( id, "<font size='%d'color='#A8A8A8'>%s%s%s%s%s%s", iProps == 0 ? 26 : ( 26 - ( iProps + 1 ) * 4 ), strlen( sProp1 ) ? sProp1 : "", strlen( sProp1 ) ? "\n" : "", strlen( sProp2 ) ? sProp2 : "", strlen( sProp2 ) ? "\n" : "", strlen( sOnlyT ) ? sOnlyT : "", strlen( sOnTop ) ? sOnTop : "" );	
		}
	}
}

stock Float:GetPlayerSpeed(iClient)
{
    new Float:faVelocity[3];
    GetEntPropVector(iClient, Prop_Data, "m_vecVelocity", faVelocity);
    new Float:fSpeed;
    //fSpeed = GetVectorLength(faVelocity, false);
    fSpeed = SquareRoot(faVelocity[0] * faVelocity[0] + faVelocity[1] * faVelocity[1]);    
    new iWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
    if(IsValidEdict(iWeapon)) {
        decl String:sWeaponName[64];
        GetEntityClassname(iWeapon, sWeaponName, sizeof(sWeaponName));
        if(IsWeaponGrenade(sWeaponName))
            fSpeed *= (250.0 / 245.0);
    }
    return fSpeed;
}

stock bool:IsWeaponGrenade(const String:sWeaponName[])
{
    for(new i = 0; i < sizeof(g_sGrenadeWeaponNames); i++)
        if(StrEqual(g_sGrenadeWeaponNames[i], sWeaponName))
            return true;
    return false;
}

new Float:g_fOldVel[ MAXPLAYERS + 1 ][ 3 ];

doSnapping( iClient, ent, Float:fMoveTo[ 3 ] ) {
	new Float:fSnapSize = g_fSnappingGap[ iClient ];
	new Float:vReturn[3];
	new Float:dist;
	new Float:distOld = 9999.9;
	new Float:vTraceStart[3];
	new Float:vTraceEnd[3];

	new trClosest = 0;
	new blockFace;
	
	static Float:fSizeMin[ 3 ], Float:fSizeMax[ 3 ];
	GetEntPropVector( ent, Prop_Send, "m_vecMins", fSizeMin );
	GetEntPropVector( ent, Prop_Send, "m_vecMaxs", fSizeMax );
	
	for(new x = 0 ; x < 3 ; x++) {
		fSizeMin[x] = g_iRotation[ent] == 2 ? g_fBlockSizes3[g_iBlockSize[ent]][0][x] : g_iRotation[ent] == 1 ? g_fBlockSizes2[g_iBlockSize[ent]][0][x] : g_fBlockSizes[g_iBlockSize[ent]][0][x];
		fSizeMax[x] = g_iRotation[ent] == 2 ? g_fBlockSizes3[g_iBlockSize[ent]][1][x] : g_iRotation[ent] == 1 ? g_fBlockSizes2[g_iBlockSize[ent]][1][x] : g_fBlockSizes[g_iBlockSize[ent]][1][x];
	}
	
	new Float:fVec[ 3 ];
	for( new i = 0; i < 6; ++i ) {
		vTraceStart = fMoveTo;

		switch (i)
		{
			case 0: vTraceStart[0] += fSizeMin[0];
			case 1: vTraceStart[0] += fSizeMax[0];
			case 2: vTraceStart[1] += fSizeMin[1];
			case 3: vTraceStart[1] += fSizeMax[1];
			case 4: vTraceStart[2] += fSizeMin[2];
			case 5: vTraceStart[2] += fSizeMax[2];
		}

		vTraceEnd = vTraceStart;

		switch( i )
		{
			case 0: vTraceEnd[0] -= fSnapSize;
			case 1: vTraceEnd[0] += fSnapSize;
			case 2: vTraceEnd[1] -= fSnapSize;
			case 3: vTraceEnd[1] += fSnapSize;
			case 4: vTraceEnd[2] -= fSnapSize;
			case 5: vTraceEnd[2] += fSnapSize;
		}

		new Handle:tr = TR_TraceRayFilterEx(vTraceStart, vTraceEnd, MASK_SHOT, RayType_EndPoint, trNoPlayers, ent);

		if(TR_DidHit(tr)){
			new tr2 = TR_GetEntityIndex(tr);

			TR_GetEndPosition(vReturn, tr);
			if(IsValidBlock(tr2)){
				dist = GetVectorDistance(vTraceStart, vReturn); //this!!
				
				if (dist < distOld){
					trClosest = tr2;
					distOld = dist;
					
					GetEntPropVector(trClosest, Prop_Data, "m_vecOrigin", fVec);
					fVec[i/2] += (i == 0 || i%2 == 0) ? fSizeMax[i/2] : fSizeMin[i/2];
					blockFace = i;
				}
			}
		}
		
		CloseHandle(tr);
	}
	if(IsValidBlock(trClosest)){
		if(g_hRender[trClosest] != INVALID_HANDLE){ 
			KillTimer(g_hRender[trClosest]);
			g_hRender[trClosest] = INVALID_HANDLE;
		}
		else{
			SetEntityRenderColor(trClosest, g_iRandomColor[g_iTempColor[ent]][0], g_iRandomColor[g_iTempColor[ent]][1], g_iRandomColor[g_iTempColor[ent]][2], g_iRandomColor[g_iTempColor[ent]][3]);
		}
		
		////TE_SetupGlowSprite(fVec, g_iBlueGlowSprite, 0.3, fSizes[g_iBlockSize[ent]], 32);
		////TE_SendToAll();
		
		g_hRender[trClosest] = CreateTimer(0.01, trRender, trClosest);
		
		new Float:vOrigin[3];
		GetEntPropVector(trClosest, Prop_Data, "m_vecOrigin", vOrigin);
		
		static Float:fTrSizeMin[ 3 ], Float:fTrSizeMax[ 3 ];
		GetEntPropVector( trClosest, Prop_Send, "m_vecMins", fTrSizeMin );
		GetEntPropVector( trClosest, Prop_Send, "m_vecMaxs", fTrSizeMax );
		
		new Float:currentEntLocation[ 3 ];
		GetEntPropVector( trClosest, Prop_Data, "m_angRotation", currentEntLocation );  
		
		for(new x = 0 ; x < 3 ; x++){
			fTrSizeMin[x] = g_iRotation[trClosest] == 2 ? g_fBlockSizes3[g_iBlockSize[trClosest]][0][x] : g_iRotation[trClosest] == 1 ? g_fBlockSizes2[g_iBlockSize[trClosest]][0][x] : g_fBlockSizes[g_iBlockSize[trClosest]][0][x];
			fTrSizeMax[x] = g_iRotation[trClosest] == 2 ? g_fBlockSizes3[g_iBlockSize[trClosest]][1][x] : g_iRotation[trClosest] == 1 ? g_fBlockSizes2[g_iBlockSize[trClosest]][1][x] : g_fBlockSizes[g_iBlockSize[trClosest]][1][x];
		}

		fMoveTo = vOrigin;
		if (blockFace == 0) fMoveTo[0] += (fTrSizeMax[0] + fSizeMax[0]) + g_fSnappingGap[ iClient ] - 0.6;
		if (blockFace == 1) fMoveTo[0] += (fTrSizeMin[0] + fSizeMin[0]) - g_fSnappingGap[ iClient ] + 0.6;
		if (blockFace == 2) fMoveTo[1] += (fTrSizeMax[1] + fSizeMax[1]) + g_fSnappingGap[ iClient ] - 0.5;
		if (blockFace == 3) fMoveTo[1] += (fTrSizeMin[1] + fSizeMin[1]) - g_fSnappingGap[ iClient ] + 0.5;
		if (blockFace == 4) fMoveTo[2] += (fTrSizeMax[2] + fSizeMax[2]) + g_fSnappingGap[ iClient ] - 0.5;
		if (blockFace == 5) fMoveTo[2] += (fTrSizeMin[2] + fSizeMin[2]) - g_fSnappingGap[ iClient ] + 0.5;
	}
}

public Action:trRender(Handle:hTimer, any:iEnt){
	g_hRender[iEnt] = INVALID_HANDLE;
	
	if(IsValidBlock(iEnt))
		ustawRender(iEnt);
}

public Action:OnPlayerRunCmd( client, &buttons, &impulse, Float:vel[ 3 ], Float:angles[ 3 ], &weapon ) {
	if( g_iDragEnt[ client ] ) {
		if( buttons & IN_ATTACK ) {
			if( g_fDistance[ client ] <= 800.0 ) 
				g_fDistance[ client ] += 5.0;
		}
		else if( buttons & IN_ATTACK2 ) {
			if( g_fDistance[ client ] > 72.0 )
				g_fDistance[ client ] -= 5.0; 
		}
		
		if( IsValidEdict( g_iDragEnt[ client ] ) ) {
			MoveBlock( client );
		}
	}
	
	for( new i = 0; i < 25 ; i++ ) {
		new button = ( 1 << i );
		
		if( ( buttons & button ) ) {
			if( !( g_iOldButtons[ client ] & button ) ) {
				OnButtonPress( client, button );
			}
		}
		else if( ( g_iOldButtons[ client ] & button ) ) {
			OnButtonRelease( client, button );
		}
	}
	
	g_iOldButtons[ client ] = buttons;
	
	if( IsPlayerAlive( client ) ) {
		if( g_iGravity[ client ] && GetEntityFlags( client ) & FL_ONGROUND ) {
			new ground = GetEntPropEnt( client, Prop_Send, "m_hGroundEntity" ); 
			
			if( !( IsValidBlock( ground ) && g_iBlocks[ ground ] == 10 ) ) {
				g_iGravity[ client ] = 0;
				SetEntityGravity( client, 1.0 );
			}
		} 
	}
		
	for( new a = MaxClients + 1; a < 2048; ++a ) {
		if( GetClientTeam( client ) < 2 )
			continue;
		
		if( IsValidBlock( a ) ) {
			new Float:fPos[ 3 ];
			new Float:fPos2[ 3 ];
			GetClientAbsOrigin( client, fPos );
			fPos[ 2 ] += 50.0;
						
			if( g_iBlocks[ a ] == 6 || g_iBlocks[ a ] == 9 || g_iBlocks[ a ] == 12 ) { // NOfall ,speed boost, trampolin
				GetEntPropVector( a, Prop_Data, "m_vecOrigin", fPos2 ); 
				if( GetVectorDistance( fPos, fPos2 ) <= 100.0 ) {
					if( !g_bNoFallDmg[ client ] )
						CreateTimer( 0.2, ResetNoFall, client );
					g_bNoFallDmg[ client ] = true;
				}
			} else 
			
			if((g_iTeleporters[ a ] > 1) && 
				( GetClientTeam(client) == CS_TEAM_CT || GetClientTeam(client) == CS_TEAM_T) && 
					IsPlayerAlive(client)) {
				GetEntPropVector( a, Prop_Data, "m_vecOrigin", fPos2 );
				if( IsValidBlock( g_iTeleporters[ a ] ) ) {
					// CreateTimer( 5.0, AddCollision, client );
					
					if( fPos[ 0 ] - 36.0 < fPos2[ 0 ] < fPos[ 0 ] + 36.0 && fPos[ 1 ] - 36.0 < fPos2[ 1 ] < fPos[ 1 ] + 36.0 && fPos[ 2 ] - 72.0 < fPos2[ 2 ] < fPos[ 2 ] + 72.0 && !( fPos[ 0 ] - 32.0 < fPos2[ 0 ] < fPos[ 0 ] + 32.0 && fPos[ 1 ] - 32.0 < fPos2[ 1 ] < fPos[ 1 ] + 32.0 && fPos[ 2 ] - 64.0 < fPos2[ 2 ] < fPos[ 2 ] + 64.0 ) ) {
						GetEntPropVector( client, Prop_Data, "m_vecVelocity", g_fOldVel[ client ] );
						g_fOldVel[ client ][ 2 ] = g_fOldVel[ client ][ 2 ] > 0.0 ? g_fOldVel[ client ][ 2 ] : g_fOldVel[ client ][ 2 ] * -1.0;
					}
					else if( fPos[ 0 ] - 32.0 < fPos2[ 0 ] < fPos[ 0 ] + 32.0 && fPos[ 1 ] - 32.0 < fPos2[ 1 ] < fPos[ 1 ] + 32.0 && fPos[ 2 ] - 64.0 < fPos2[ 2 ] < fPos[ 2 ] + 64.0 ) {
						
						// SetEntProp( client, Prop_Data, "m_CollisionGroup", 17 );
						// CreateTimer( 0.5, AddCollision, client );
						// SetEntProp( client, Prop_Data, "m_takedamage", 0, 1 );	//Godmode On

						GetEntPropVector( g_iTeleporters[ a ], Prop_Data, "m_vecOrigin", fPos2 );
						// TeleportEntity( client, fPos2, NULL_VECTOR, NULL_VECTOR );
												
						new Float:vec[ 3 ];
						GetClientAbsOrigin( client, vec );
						vec[ 2 ] += 10;
												
						EmitSoundToClient( client, TELE_SOUND_PATH );
						EmitAmbientSound( TELE_SOUND_PATH, vec, client, SNDLEVEL_CONVO );
						
						TeleportEntity( client, fPos2, NULL_VECTOR, g_fOldVel[ client ] );
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

// public Action:AddCollision( Handle:timer, any:client )
// {
	// if ( IsClientInGame( client ) )
	// {
		// SetEntProp( client, Prop_Send, "m_CollisionGroup", 5 );
		// SetEntProp( client, Prop_Data, "m_takedamage", 2, 1 ); //Godmode Off
	// }
// }

// public OnGameFrame( ) {
	// for( new e = ( MaxClients + 1 ) ; e < 1600 ; e ++ ) {	
		// if( IsValidBlock( e ) && g_bTeleport[ e ] ) {
			// new Float:fVec[ 3 ];
			// GetEntPropVector( e, Prop_Data, "m_angRotation", fVec );

			// fVec[ g_iOs[ e ] ] += g_fRuch[ e ];

			// TeleportEntity( e, NULL_VECTOR, fVec, NULL_VECTOR );
		// }
	// }
// }

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	if(entity == data)
		return false;
	return true;
}

public Action:Command_BlockBuilder( client, args ) {	
	if( ( GetUserFlagBits( client ) & ADMFLAG_GENERIC || GetUserFlagBits( client ) & ADMFLAG_ROOT ) ) {
		
		if( !g_bEnabled ) {
			CPrintToChat( client, "%s Você não pode acessar o BM no live!", TAG );
			return Plugin_Handled;
		}
		
		for( new i = MaxClients + 1 ;i < 2048; ++i ) {
			if( !IsValidEntity( i ) || !IsValidBlock( i ) || g_iTeleporters[ i ] == 1 )
				continue;
		}
		
		new Handle:menu = CreateMainMenu( client );
		DisplayMenu( menu, client, 0 ); // FIX, menu desaparece do nada.
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:cmdUngrab( iClient, args ) {
	if( IsValidBlock( g_iDragEnt[ iClient ] ) ) {
		if( isBlockStuck( g_iDragEnt[ iClient ] ) ) {
			new bool:bDeleted = AcceptEntityInput( g_iDragEnt[ iClient ], "Kill" );
	
			if( bDeleted ) {
				CPrintToChat( iClient, "%s Bloco deletado porque ele estava preso!", TAG );
			}
		}
	}

	ustawRender( g_iDragEnt[ iClient ] );
	g_iDragEnt[ iClient ] = 0;
	
	return Plugin_Handled;
}

public Action:cmdGrab( client, args ) {
	if( !IsPlayerAlive( client ) )
		return Plugin_Handled;
	
	if( !g_bEnabled ) {
		CPrintToChat( client, "%s Você não pode mover o bloco no live.", TAG );
		return Plugin_Handled;
	}

	if( g_iDragEnt[ client ] == 0 ) {
		new ent = GetClientAimTarget(client, false);
		
		if(IsValidBlock(ent)){
			new Float:fOrg[2][3];
			setGrabbed(client, ent);
			
			Entity_GetAbsOrigin(ent, fOrg[0]);
			GetClientEyePosition(client,  fOrg[1]);
			
			for(new i = 0 ; i < 3 ; i++)
				fOrg[0][i] -= g_fGrabOffset[client][i];
			
			g_fDistance[client] = GetVectorDistance(fOrg[0], fOrg[1]);		
			g_iTempColor[ent] = GetRandomInt(0, 5);
			
			SetEntityRenderColor(ent, g_iRandomColor[g_iTempColor[ent]][0], g_iRandomColor[g_iTempColor[ent]][1], g_iRandomColor[g_iTempColor[ent]][2], g_iRandomColor[g_iTempColor[ent]][3]);
		}
	}
	return Plugin_Handled;
}

public Action:MenuAccess(client, args){
	new Handle:menu = CreateMenu(MenuHandlerAccess);
	
	SetMenuTitle(menu, "[pNr] Access to BM");
	new iL = 0;
	
	new maxClients = GetMaxClients();
	for (new i=1; i<=maxClients; i++){
		if (!IsClientInGame(i) || IsFakeClient(i)){
			continue;
		}
		new AdminId:admin = GetUserAdmin(i);
		if(admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Generic) == true) continue;
		decl String:name[65];
		GetClientName(i, name, sizeof(name));

		AddMenuItem(menu, name, name);
		iL++;
	}
	
	if(iL<1){
		AddMenuItem(menu, "#no", "No other players");
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 99999);
 
	return Plugin_Handled;
}

public MenuHandlerAccess(Handle:menu, MenuAction:action, param1, param2){
	if (action == MenuAction_Select){
		new String:info[64]
		GetMenuItem(menu, param2, info, sizeof(info))
		
		new maxplayers, target = -1;
		maxplayers = GetMaxClients()
		for (new i=1; i<=maxplayers; i++){
			if (!IsClientConnected(i)){
				continue;
			}
			
			new AdminId:admin = GetUserAdmin(i);
			
			if(admin != INVALID_ADMIN_ID && GetAdminFlag(admin, Admin_Generic) == true) continue;
			
			decl String:other[64]
			GetClientName(i, other, sizeof(other))
			if (StrEqual(info, other))
			{
				target = i;
			}
		}
		
		if(StrEqual(info, "#no")){
			CPrintToChatAll("%s Choose a valid player", TAG);
		}
		else{
			new String:tgtname[64];
			GetClientName(target, tgtname, 64);
			AddUserFlags(target, Admin_Generic);
			
			CPrintToChatAll("%s {DARKRED}%s{NORMAL} was temporarily added to BM!", TAG, tgtname);
		}
		MenuAccess(param1, 0);
	}  
	if ((action == MenuAction_Cancel))
		DisplayMenu(CreateOptionsMenu(param1), param1, 0);
}

setGrabbed(client, ent){
	new Float:fpOrigin[3];
	new Float:fbOrigin[3];
	new Float:iAiming[3];
	new Float:bOrigin[3];

	GetClientEyePosition(client, bOrigin);
	GetAimOrigin(client, iAiming);

	Entity_GetAbsOrigin(client, fpOrigin);
	Entity_GetAbsOrigin(ent, fbOrigin);
	
	g_iDragEnt[ client ] = ent;
	g_fGrabOffset[client][0] = fbOrigin[0] - iAiming[0];
	g_fGrabOffset[client][1] = fbOrigin[1] - iAiming[1];
	g_fGrabOffset[client][2] = fbOrigin[2] - iAiming[2];
}

stock GetAimOrigin(client, Float:hOrigin[3]) {
    new Float:vAngles[3], Float:fOrigin[3];
    GetClientEyePosition(client,fOrigin);
    GetClientEyeAngles(client, vAngles);

    new Handle:trace = TR_TraceRayFilterEx(fOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

    if(TR_DidHit(trace)) 
    {
        TR_GetEndPosition(hOrigin, trace);
        CloseHandle(trace);
        return 1;
    }

    CloseHandle(trace);
    return 0;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask) 
{
    return entity > GetMaxClients();
}

public MoveBlock(client){
	new Float:posent[3];
	Entity_GetAbsOrigin(g_iDragEnt[client], posent);
		
	new Float:playerpos[3];
	GetClientEyePosition(client, playerpos);
		
	new Float:playerangle[3];
	GetClientEyeAngles(client, playerangle);
		
	new Float:final[3];
	AddInFrontOf(client, playerpos, playerangle, g_fDistance[client], final);
		
	if( g_bSnapping[ client ] ) doSnapping( client, g_iDragEnt[ client ], final );
		
	TeleportEntity(g_iDragEnt[client], final, NULL_VECTOR, NULL_VECTOR);
}

stock AddInFrontOf(client, Float:vecOrigin[3], Float:vecAngle[3], Float:units, Float:output[3]){
	new Float:vecAngVectors[3];
	vecAngVectors = vecAngle;
	GetAngleVectors(vecAngVectors, vecAngVectors, NULL_VECTOR, NULL_VECTOR);
	for (new i; i < 3; i++)
	output[i] += vecOrigin[i] + g_fGrabOffset[client][i] + (vecAngVectors[i] * units);
}

public Handle:CreatePropMenu(client)
{
	new Handle:menu = CreateMenu(Handler_Prop);
	SetMenuTitle(menu, "[pNr] Set Properties");
	new iEnt = g_iTempKlocek[client];
	new blocktype = g_iBlocks[iEnt];

	if(g_iOnTopShow[blocktype]){
		if(g_iOnTop[iEnt]){
			AddMenuItem(menu, "0", "On Top Only: Yes");
		}
		else{
			AddMenuItem(menu, "0", "On Top Only: No");
		}
	}
	else{
		AddMenuItem(menu, "0", "", ITEMDRAW_IGNORE );
	}
	
	if(g_iOnlyTShow[blocktype]){
		if(g_iOnlyT[iEnt]){
			AddMenuItem(menu, "1", "Only Trs: Yes");
		}
		else{
			AddMenuItem(menu, "1", "Only Trs: No\n\n");
		}
	}
	else{
		AddMenuItem(menu, "1", "", ITEMDRAW_IGNORE );
	}
	
	if(blocktype == 20){
		new String:sProp[128];
		new iOpt = RoundFloat(g_fProp[iEnt][0]);
		
		new String:sWeapon[64];
		FormatEx(sWeapon, sizeof sWeapon, g_sWeapons[iOpt]);
		ReplaceString(sWeapon, sizeof sWeapon, "weapon_", "");
		
		FormatEx(sProp, sizeof sProp, "%s: %s", g_sTimeNazwa[blocktype], sWeapon);
		
		AddMenuItem(menu, "2", sProp);
	}
	else{
		if(!(StrContains(g_sTimeNazwa[blocktype], "Nenhum", false) != -1)){
			new String:sProp[64];
			if(blocktype == 24){
				FormatEx(sProp, sizeof sProp, "%s: %s", g_sTimeNazwa[blocktype], g_fProp[iEnt][0] >= 1.0 ? "[X]" : "[  ]");
			}
			else{
				FormatEx(sProp, sizeof sProp, "%s: %.2f", g_sTimeNazwa[blocktype], g_fProp[iEnt][0]);
			}
			AddMenuItem(menu, "2", sProp);
		}
		else{
			AddMenuItem(menu, "2", "None", ITEMDRAW_NOTEXT ); 
		}
	}
	
	if(!(StrContains(g_sTime2Nazwa[blocktype], "Nenhum", false) != -1)){
		new String:sProp[64];
		FormatEx(sProp, sizeof sProp, "%s: %.2f", g_sTime2Nazwa[blocktype], g_fProp[iEnt][1]);
		
		AddMenuItem(menu, "2", sProp);
	}
	else{
		AddMenuItem(menu, "2", "None", ITEMDRAW_NOTEXT );
	}
	
	SetMenuExitBackButton(menu, true);
	return menu;
}

public Handler_Prop( Handle:menu, MenuAction:action, client, param2 ) {
	if( action == MenuAction_Select ) {
		new iEnt = g_iTempKlocek[ client ];
		new blocktype = g_iBlocks[ iEnt ];
		
		if( IsValidBlock( iEnt ) ) {
			if( param2 == 0 && g_iOnTopShow[ blocktype ] ) {
				g_iOnTop[ iEnt ] = g_iOnTop[ iEnt ] ? 0 : 1;
			}
			if( param2 == 1 && g_iOnlyTShow[ blocktype ] ) {
				g_iOnlyT[ iEnt ] = g_iOnlyT[ iEnt ] ? 0 : 1;
			}
			if( param2 == 2 && !( StrContains( g_sTimeNazwa[ blocktype ], "Nenhum", false ) != -1 ) ) {
				if( blocktype == 20 ) {
					WeaponsMenu( client, 0 );
					return;
				}
				else {
					g_fProp[ iEnt ][ 0 ] = ( g_fProp[ iEnt ][ 0 ] >= g_fTimeMax[ blocktype ] ) ? g_fTimeMin[ blocktype ] : ( g_fProp[ iEnt ][ 0 ] + g_fTimeStopa[ blocktype ] );
				}
			}
			if( param2 == 3 && !( StrContains( g_sTime2Nazwa[ blocktype ], "Nenhum", false ) != -1 ) )
			{
				g_fProp[ iEnt ][ 1 ] = ( g_fProp[ iEnt ][ 1 ] >= g_fTime2Max[ blocktype ] ) ? g_fTime2Min[ blocktype ] : ( g_fProp[ iEnt ][ 1 ] + g_fTime2Stopa[ blocktype ] );
			}
		}
		else {
			DisplayMenu( CreatePropMenu( client ), client, 0 );
		}
		
		DisplayMenu(CreatePropMenu(client), client, 0);
	}
	else if( ( action == MenuAction_Cancel ) || ( param2 == MenuCancel_ExitBack ) ) {
		DisplayMenu( CreateBlockMenu( client ), client, 0 );
	}
}

public Handle:CreateWlasciwosciMenu(client)
{
	new Handle:menu = CreateMenu(Handler_Wlasciwosci);
	SetMenuTitle(menu, "[pNr] Set Render");
	
	new String:sAlpha[30], String:sKlr[3][30];
	FormatEx(sAlpha, sizeof sAlpha, "Alpha: %d \n ", g_iTempAlpha[client]);
	FormatEx(sKlr[0], sizeof sKlr[], "Red: %d", g_iTempKlr[client][0]);
	FormatEx(sKlr[1], sizeof sKlr[], "Green: %d", g_iTempKlr[client][1]);
	FormatEx(sKlr[2], sizeof sKlr[], "Blue: %d \n", g_iTempKlr[client][2]);

	AddMenuItem(menu, "0", sAlpha);
	
	AddMenuItem(menu, "1", sKlr[0]);
	AddMenuItem(menu, "2", sKlr[1]);
	AddMenuItem(menu, "3", sKlr[2]);
	AddMenuItem(menu, "4", "Reset");
	AddMenuItem(menu, "5", "Apply");
	
	SetMenuExitBackButton(menu, true);
	return menu;
}

public Handler_Wlasciwosci( Handle:menu, MenuAction:action, client, param2 )
{
	if( action == MenuAction_Select ) {
		if( param2 == 0 ) {
			g_iTempAlpha[ client ] = g_iTempAlpha[ client ] >= 255 ? 0 : g_iTempAlpha[ client ] + 51;
		}
		
		if( param2 == 1 || param2 == 2 || param2 == 3 ) {
			g_iTempKlr[ client ][ param2 - 1 ] = g_iTempKlr[ client ][ param2 - 1 ] >= 255 ? 0 : g_iTempKlr[ client ][param2 - 1 ] + 15;
		}
		if( param2 == 4 ) {
			g_iTempAlpha[ client ] 	  = 255;
			g_iTempKlr[ client ][ 0 ] = 255;
			g_iTempKlr[ client ][ 1 ] = 255;
			g_iTempKlr[ client ][ 2 ] = 255;
		}
		if( param2 == 5 ) {
			new iEnt = GetClientAimTarget( client, false );
			if( IsValidBlock( iEnt ) ) {
				for( new i = 0 ; i < 3 ; i++ )
					g_iKlr[ iEnt ][ i ] = g_iTempKlr[ client ][ i ];
				
				g_iAlpha[ iEnt ] = g_iTempAlpha[ client ];
				
				ustawRender( iEnt );
				CPrintToChat( client, "%s Applied Rendering!", TAG );
			}
			else {
				CPrintToChat(client, "%s Mire no bloco primeiro!", TAG);
			}
		}

		DisplayMenu( CreateWlasciwosciMenu( client ), client, 0 );
	}
	else if( ( action == MenuAction_Cancel ) || ( param2 == MenuCancel_ExitBack ) ) {
		DisplayMenu( CreateBlockMenu( client ), client, 0 );
	}
}

CreateTeleportEntrance(client, Float:fPos[3]={0.0, 0.0, 0.0})
{
		new Float:vecDir[3], Float:vecPos[3], Float:viewang[3];
		if(client > 0)
		{
			GetClientEyeAngles(client, viewang);
			GetAngleVectors(viewang, vecDir, NULL_VECTOR, NULL_VECTOR);
			GetClientEyePosition(client, vecPos);
			vecPos[0]+=vecDir[0]*100;
			vecPos[1]+=vecDir[1]*100;
			vecPos[2]+=vecDir[2]*100;
		}
		else
		{
			vecPos = fPos;
		}
		
		new ent = CreateEntityByName("prop_physics_override");
		DispatchKeyValue(ent, "model", "models/platforms/b-tele.mdl");
		TeleportEntity(ent, vecPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(ent);
		
		SetEntityMoveType(ent, MOVETYPE_NONE);
		AcceptEntityInput(ent, "disablemotion");
		SetEntProp(ent, Prop_Data, "m_CollisionGroup", 1); //, 2 zzz tava 1
		
		g_iTeleporters[ent]=1;
		g_iCurrentTele[client]=ent;
		
		// g_iRuchomy[ent] = 1;
		// g_iOs[ent] = 1;
		// g_fRuch[ent] = 1.2;

		SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
		
		SDKHook(ent, SDKHook_Touch, OnStartTouch);
		
		for(new i = 0 ; i < 3 ; i++)
			g_iKlr[ent][i] = 255;

		g_iAlpha[ent] = 255;
		
		return ent;
}

CreateTeleportExit(client, Float:fPos[3]={0.0, 0.0, 0.0})
{
	new Float:vecDir[3], Float:vecPos[3], Float:viewang[3];
	if(client > 0)
	{
		GetClientEyeAngles(client, viewang);
		GetAngleVectors(viewang, vecDir, NULL_VECTOR, NULL_VECTOR);
		GetClientEyePosition(client, vecPos);
		vecPos[0]+=vecDir[0]*100;
		vecPos[1]+=vecDir[1]*100;
		vecPos[2]+=vecDir[2]*100;
	}
	else
	{
		vecPos = fPos;
	}
	
	
	new ent = CreateEntityByName("prop_physics_override");
	DispatchKeyValue(ent, "model", "models/platforms/r-tele.mdl");
	TeleportEntity( ent, vecPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn( ent );
		
	// new m_iRotator = CreateEntityByName("func_rotating");
	// DispatchKeyValueVector(m_iRotator, "origin", vecPos);
	// DispatchKeyValue(m_iRotator, "targetname", "Item" );
	// DispatchKeyValue(m_iRotator, "maxspeed", "200");
	// DispatchKeyValue(m_iRotator, "friction", "0");
	// DispatchKeyValue(m_iRotator, "dmg", "0");
	// DispatchKeyValue(m_iRotator, "solid", "0");
	// DispatchKeyValue(m_iRotator, "spawnflags", "64");
	// DispatchSpawn(m_iRotator);

	// SetVariantString("!activator");
	// AcceptEntityInput(ent, "SetParent", m_iRotator, m_iRotator);
	// AcceptEntityInput(m_iRotator, "Start");

	// SetEntPropEnt(ent, Prop_Send, "m_hEffectEntity", m_iRotator);
		
	SetEntityMoveType(ent, MOVETYPE_NONE);
	AcceptEntityInput(ent, "disablemotion");
	SetEntProp(ent, Prop_Data, "m_CollisionGroup", 1); //, 2
		
	g_iTeleporters[ent]=1;
	
	for(new i = 0 ; i < 3 ; i++)
		g_iKlr[ent][i] = 255;

	g_iAlpha[ent] = 255;
	
	// g_iRuchomy[ent] = 1;
	// g_iOs[ent] = 1;
	// g_fRuch[ent] = 1.2;

	SetEntProp(ent, Prop_Send, "m_usSolidFlags", 0);
	
	return ent;
}

CreateBlock( iClient, iBlockSize, blocktype = 0, Float:fPos[ 3 ] = { 0.0, 0.0, 0.0 }, Float:fAng[ 3 ] = { 0.0, 0.0, 0.0 } )
{
	new Float:vecDir[ 3 ], Float:vecPos[ 3 ], Float:viewang[ 3 ];	
	
	if( iClient > 0 ) {
		GetClientEyeAngles( iClient, viewang );
		GetAngleVectors( viewang, vecDir, NULL_VECTOR, NULL_VECTOR );
		GetClientEyePosition( iClient, vecPos );
		vecPos[ 0 ] += vecDir[ 0 ] * 150;
		vecPos[ 1 ] += vecDir[ 1 ] * 150;		
		vecPos[ 2 ] += vecDir[ 2 ] * 150;
	}
	else {
		vecPos = fPos;
	}
	
	// if ( ( iClient > 0 ? g_iBlockSelection[ iClient ] : blocktype ) == 15 )
	// {
		// new iEnt = CreateEntityByName( "light_dynamic" );	
		// DispatchKeyValue(iEnt, "_light", "255 250 244 200");
		// DispatchKeyValue(iEnt, "brightness", "8");
		// DispatchKeyValue(iEnt, "distance", "250");
		// DispatchKeyValue(iEnt, "style", "0");
		
		// AcceptEntityInput( iEnt, "TurnOn" ); 
		
		// TeleportEntity( iEnt, vecPos, fAng, NULL_VECTOR );
		// DispatchSpawn( iEnt );
	// }
	
	new block_entity = CreateEntityByName( "prop_physics_override" );
		
	DispatchKeyValue( block_entity, "model", g_sSciezkaModel[ iBlockSize ][ ( iClient > 0 ? g_iBlockSelection[ iClient ] : blocktype ) ] );
	
	TeleportEntity( block_entity, vecPos, fAng, NULL_VECTOR );
	DispatchSpawn( block_entity );

	SetEntityMoveType( block_entity, MOVETYPE_NONE );
	AcceptEntityInput( block_entity, "disablemotion" );

	g_iAlpha[ block_entity ] = 255;

	if( ( iClient > 0 ? g_iBlockSelection[ iClient ] : blocktype ) == 1 )
	{
		g_iAlpha[ block_entity ] = 120;
	}
	
	g_iBlocks[ block_entity ] = ( iClient > 0 ? g_iBlockSelection[ iClient ] : blocktype );

	g_iOnTop[ block_entity ] = g_iOnTopDef[ g_iOnTop[ g_iBlocks[ block_entity ] ] ];
	g_iOnlyT[ block_entity ] = g_iOnlyTDef[ g_iBlocks[ block_entity ] ];

	g_fProp[ block_entity ][ 0 ] = g_fTimeDef[ g_iBlocks[ block_entity ] ];
	g_fProp[ block_entity ][ 1 ] = g_fTime2Def[ g_iBlocks[ block_entity ] ];

	SDKHook( block_entity, SDKHook_Touch, OnStartTouch );
	SDKHook( block_entity, SDKHook_EndTouch, OnEndTouch );
	//SDKHook(block_entity, SDKHook_StartTouch, OnFirstTouch);//BUG. Testando

	g_fAngles[ block_entity ] = fAng;
	g_bTeleport[ block_entity ] = false;

	if( iClient ) {
		GetClientName( iClient, g_sAutor[ block_entity ], 64 );
	}

	g_iRotation[ block_entity ] = 0;
	// g_iRuchomy[ block_entity ] = 0;

	for( new i = 0 ; i < 3 ; i++ )
		g_iKlr[ block_entity ][ i ] = 255;

	Entity_GetAbsOrigin( block_entity, g_fVec[ block_entity ] );

	g_iBlockSize[ block_entity ] = iBlockSize;
	ustawRender( block_entity );
	
	if ( isBlockStuck( block_entity ) ) 
	{
		AcceptEntityInput( block_entity, "Kill" );
		if ( iClient )
		{
			CPrintToChat( iClient, "%s Bloco deletado porque ele estava preso!", TAG );
		}
	}

	return block_entity;
}


public ustawRender( iEnt )
{
	if ( IsValidBlock( iEnt ) )
	{
		SetEntityRenderMode(iEnt, RENDER_TRANSALPHA);
		SetEntityRenderColor(iEnt, g_iKlr[iEnt][0], g_iKlr[iEnt][1], g_iKlr[iEnt][2], g_iAlpha[iEnt]);
	}
}

public Action:OnTakeDamage( victim, &attacker, &inflictor, &Float:damage, &damagetype )
{
	if( g_bInv[ victim ] || ( g_bNoFallDmg[ victim ] && damagetype & DMG_FALL ) )
		return Plugin_Handled;
	return Plugin_Continue;
	//return;
}

public Action:ClientPreThink( client ) 
{	
	if ( IsPlayerAlive( client ) ) 
	{
		new Float:fVel[ 3 ];
		GetEntPropVector( client, Prop_Data, "m_vecVelocity", fVel );

		for( new l = 0 ; l < 3 ; l++ ) 
		{
			g_fBeforeVel[ client ][ l ] = fVel[ l ];
		}
	}
}

new g_iBlockTr[ MAXPLAYERS + 1 ];

new Handle:g_hTramp[ MAXPLAYERS + 1 ];

public Action:Trampoline( Handle:hTimer, any:iClient ) {
	new Float:fVelocity[ 3 ];
	new iEnt = g_iBlockTr[ iClient ];
	
	fVelocity[ 0 ] = g_fBeforeVel[ iClient ][ 0 ];
	fVelocity[ 1 ] = g_fBeforeVel[ iClient ][ 1 ];
	fVelocity[ 2 ] = g_fProp[ iEnt ][ 0 ];
	
	TeleportEntity( iClient, NULL_VECTOR, NULL_VECTOR, fVelocity );

	g_hTramp[iClient] = INVALID_HANDLE;
} 

public Action:SpeedBoost( Handle:hTimer, any:client ) {
	
	if( client < 0 )
		return;
	
	new Float:fAngles[3];
	new iEnt = g_iBlockTr[client];
	GetClientEyeAngles(client, fAngles);
				
	new Float:fVelocity[3];
	GetAngleVectors(fAngles, fVelocity, NULL_VECTOR, NULL_VECTOR);
				
	NormalizeVector(fVelocity, fVelocity);
	
	ScaleVector(fVelocity, g_fProp[iEnt][1]);
	fVelocity[2] = g_fProp[iEnt][0];

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
}

new Handle:g_hSprawdz[ MAXPLAYERS + 1 ];

public Action:sprawdzBh(Handle:hTimer, any:iGracz){
	if((1 <= iGracz <= MaxClients) && IsClientInGame(iGracz) && IsPlayerAlive(iGracz)){
		new Float:fVel[3];
		Entity_GetAbsVelocity(iGracz, fVel);
		fVel[2] = 0.0;
		new Float:fSpeed = GetVectorLength(fVel);
				
		if(fSpeed <= 50.0) {
		
			new Float:fOri[3];
			GetEntPropVector(iGracz, Prop_Send, "m_vecOrigin", fOri);
			
			new Float:m_vecMins[3];
			new Float:m_vecMaxs[3];
			GetEntPropVector(iGracz, Prop_Send, "m_vecMins", m_vecMins);
			GetEntPropVector(iGracz, Prop_Send, "m_vecMaxs", m_vecMaxs);
			
			TR_TraceHullFilter(fOri, fOri, m_vecMins, m_vecMaxs, MASK_SOLID, TRDontHitSelf, iGracz);
						
			if( TR_DidHit( ) ) {
				new iEnt = TR_GetEntityIndex( );
				
				if( IsValidBlock( iEnt ) ) {
					switch( g_iBlocks[ iEnt ] )
					{
						case 2: { // BHOP
							g_bTriggered[ iGracz ] = true;
							g_bBhopUsed[ iGracz ] = false;
							CreateTimer( g_fProp[ iEnt ][ 0 ], StartNoBlock, iEnt );
						}
						case 3: { // DELAYED
							g_bTriggered[ iGracz ] = true;
							g_bBhopUsed[ iGracz ] = false;
							CreateTimer( g_fProp[ iEnt ][ 0 ], StartNoBlock, iEnt );
						}
						case 4: { 		// CT Barrier
							if( GetClientTeam( iGracz ) == CS_TEAM_T ) {
								SetEntProp( iEnt, Prop_Data, "m_CollisionGroup", 2 );
								SetEntityRenderMode( iEnt, RENDER_TRANSADD );
								SetEntityRenderColor( iEnt, g_iKlr[ iEnt ][ 0 ], g_iKlr[ iEnt ][ 1 ], g_iKlr[ iEnt ][ 2 ], 117 );	
								CreateTimer( 0.1, StartNoBlock, iEnt );  // acredito que seja assim <--, antigo -->  CreateTimer( 1.0, CancelNoBlock, iEnt ); 
							}
						}
						case 5: { 		// T Barrier
							if( GetClientTeam( iGracz ) == CS_TEAM_CT ) {
								SetEntProp( iEnt, Prop_Data, "m_CollisionGroup", 2 );
								SetEntityRenderMode( iEnt, RENDER_TRANSADD );
								SetEntityRenderColor( iEnt, g_iKlr[ iEnt ][ 0 ], g_iKlr[ iEnt ][ 1 ], g_iKlr[ iEnt ][ 2 ], 117 );	
								CreateTimer( 0.1, StartNoBlock, iEnt ); 
							}
						}
					}
				}
			}
		}
	}

	g_hSprawdz[iGracz] = INVALID_HANDLE;
}

public bool:TRDontHitSelf(entity, mask, any:data)
{
	if (entity == data) return false;
	return true;
}

public touchGracza( client, sciana ) {
	if( !( 1 <= client <= MaxClients ) ) return;
	if( !( IsClientInGame( client ) && IsPlayerAlive( client ) ) ) return;
	
	if( g_hSprawdz[ client ] == INVALID_HANDLE){ 
		g_hSprawdz[ client ] = CreateTimer( 1.0, sprawdzBh, client );
	}
}

public Action:fixCol(Handle:hTimer, any:iEnt){
	g_hCol[iEnt] = INVALID_HANDLE;
	
	g_bStop[iEnt] = false;
}

stock Float:FloatMin(Float:f1, Float:f2) {
	return f1 < f2 ? f1 : f2;
}

/*public OnFirstTouch(ent1, ent2){ //BUG. Testando.
	new client = ent2;
	new block = ent1;
	
	if(client == -1 || block == -1){
		return;
	}
	
	if(!(1 <= client <= MaxClients)) return;
	
	if((g_iOnTop[block] && GetEntityFlags(client) & FL_ONGROUND && GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == block)  || !g_iOnTop[block])
	{	
		if(g_iBlocks[block]==12){
			g_iTouched[block]++;
			if(g_iTouched[block] >= RoundFloat(g_fProp[block][0]) && !g_bTriggered[block]){
				SetEntPropFloat(client, Prop_Send, "m_flStamina", 0.0);
				g_bTriggered[block]=true;
				CreateTimer(0.1, StartNoBlock, block);
				
				return;
			}
			else if(!g_bTriggered[block]){
				PrintHintText(client, "<font size='60'><font color='%s'><b>%d</b></font>", (RoundFloat(g_fProp[block][0])-g_iTouched[block]) > 1 ? "#00FF10" : "#FF1000", (RoundFloat(g_fProp[block][0])-g_iTouched[block]));
			}
		}
	}
}*/

// #define COLLISION_GROUP_PASSABLE_DOOR            1

// #define COLLISION_GROUP_PLAYER              5

public OnStartTouch( iBlock, client ) {	
	if( !( 1 <= client <= MaxClients ) ) return;

	if( ( g_iOnTop[ iBlock ] && GetEntityFlags( client ) & FL_ONGROUND && GetEntPropEnt( client, Prop_Send, "m_hGroundEntity" ) == iBlock ) || !g_iOnTop[ iBlock ] ) 
	{
		switch( g_iBlocks[ iBlock ] )
		{
			case 2: 
			{ 		// BHOP
				if( !g_bTriggered[ iBlock ]) {
					SetEntPropFloat( client, Prop_Send, "m_flStamina", 0.0 );
					g_bTriggered[ iBlock ] = true;
					g_bBhopUsed[ client ] = true;
					
					g_hLBhopUsed[ client ] = CreateTimer( g_fProp[ iBlock ][ 1 ], RemoveUnderknifeEffect, client );
					CreateTimer( g_fProp[ iBlock ][ 0 ], StartNoBlock, iBlock );
				}
				
				// if( g_hLBhopUsed[ client ] == INVALID_HANDLE) {
				// 	g_hLBhopUsed[ client ] = CreateTimer( g_fProp[ iBlock ][ 1 ], RemoveUnderknifeEffect, client );
				// }
			}
			case 3: 
			{ 		// DELAY BHOP
				if( !g_bTriggered[ iBlock ] && g_hLBhopUsed[ client ] == INVALID_HANDLE ) {
					SetEntPropFloat( client, Prop_Send, "m_flStamina", 0.0 );
					g_bTriggered[ iBlock ] = true;
					g_bBhopUsed[ client ] = true;

					g_hLBhopUsed[ client ] = CreateTimer( g_fProp[ iBlock ][ 1 ], RemoveUnderknifeEffect, client );
					CreateTimer( g_fProp[ iBlock ][ 0 ], StartNoBlock, iBlock );
				}

				// if( g_hLBhopUsed[ client ] == INVALID_HANDLE) {
				// 	g_hLBhopUsed[ client ] = CreateTimer( g_fProp[ iBlock ][ 1 ], RemoveUnderknifeEffect, client );
				// }
			}
			case 4: 
			{ 		// CT Barrier
				if( GetClientTeam( client ) == CS_TEAM_T ) {
					SetEntProp( iBlock, Prop_Data, "m_CollisionGroup", 2 );
					SetEntityRenderMode( iBlock, RENDER_TRANSADD );
					SetEntityRenderColor( iBlock, g_iKlr[ iBlock ][ 0 ], g_iKlr[ iBlock ][ 1 ], g_iKlr[ iBlock ][ 2 ], 117 );	
					CreateTimer( 1.0, CancelNoBlock, iBlock );
				}
			}
			case 5: { 		// T Barrier
				if( GetClientTeam( client ) == CS_TEAM_CT ) {
					SetEntProp( iBlock, Prop_Data, "m_CollisionGroup", 2 );
					SetEntityRenderMode( iBlock, RENDER_TRANSADD );
					SetEntityRenderColor( iBlock, g_iKlr[ iBlock ][ 0 ], g_iKlr[ iBlock ][ 1 ], g_iKlr[ iBlock ][ 2 ], 117 );	
					CreateTimer( 1.0, CancelNoBlock, iBlock );
				}
			}
			case 6: 
			{ 		// No Fall Damage 
				g_bNoFallDmg[ client ] = true;
			}
			case 7: 
			{ 		// Honey
				if ( !g_bBoots[ client ] )
				{
					static Float:flLastSound[ MAXPLAYERS + 1 ];
			
					if ( GetEngineTime( ) - 0.5 <= flLastSound[ client ] )
						return;
					
					flLastSound[ client ] = GetEngineTime( );

					StopTimer_RemoveEffect( client );

					SetEntPropFloat( client, Prop_Send, "m_flLaggedMovementValue", g_fProp[ iBlock ][ 1 ] );
					SetEntPropFloat( client, Prop_Data, "m_flGravity", g_fProp[ iBlock ][ 0 ] );
					
					new iRandom = GetRandomInt( 1, 3 );
					if( iRandom ) 
					{
						EmitSoundToClient( client, g_sHoney[ iRandom ] );
					}
					
				}
			}
			case 8: 
			{
				// g_bOnIce[ client ] = true;
			} // ice
			case 9:	
			{ 		// Trampoline
				if( g_hTramp[ client ] == INVALID_HANDLE ) {
					g_bNoFallDmg[ client ] = true;
					g_iBlockTr[ client ] = iBlock;
					g_hTramp[ client ] = CreateTimer( 0.01, Trampoline, client ); 
				}
			}
		    case 10: 
			{		// Low Gravity
				if( !g_iGravity[ client ] ) {
					g_iGravity[ client ] = RoundFloat( g_fProp[ iBlock ][ 0 ] );
					
					SetEntityGravity( client, (  g_fProp[ iBlock ][ 1 ] / 800.0 ) );
				}
			}
		    case 11: 
			{   	// Healer
				if( ( GetGameTime( ) - g_fLastHP[ client ] ) >= g_fProp[ iBlock ][ 0 ] ) {
					new iHp = GetEntProp( client, Prop_Data, "m_iHealth" );
					new iAdd = iHp + RoundFloat( g_fProp[ iBlock ][ 1 ] );

					if( iAdd > 100 ) {
						return;
					}

					if( iAdd > 95 ) {
						SetEntProp( client, Prop_Data, "m_iHealth", 100 );
					}

					SetEntProp( client, Prop_Data, "m_iHealth", iAdd );
					
					g_fLastHP[ client ] = GetGameTime( );
				}
			}
			case 12: 
			{ 		// SpeedBoost
				g_bNoFallDmg[ client ] = true;
				g_iBlockTr[ client ] = iBlock;
				CreateTimer( 0.01, SpeedBoost, client );
			}
			case 13: 
			{ 		// Invincibility
				if( ( g_iOnlyT[ iBlock ] && GetClientTeam( client ) == 2 ) || !g_iOnlyT[ iBlock ] )
				{
					if( g_bInvCanUse[ client ] ) {
						CreateTimer( g_fProp[ iBlock ][ 0 ], ResetInv, client );
						CreateTimer( g_fProp[ iBlock ][ 1 ], ResetInvCooldown, client );
						g_bInv[ client ] = true;
						g_bInvCanUse[ client ] = false;

						if( !g_bStealth[ client ] ) {
							SetEntityRenderMode( client, RENDER_TRANSALPHA );
							SetEntityRenderFx( client, RENDERFX_EXPLODE );
							SetEntityRenderColor( client, 255, 255, 255, 245 );
						}
							
						new time = RoundFloat( g_fProp[ iBlock ][ 0 ] );
						new Handle:packet = CreateDataPack( );
						WritePackCell( packet, client );
						WritePackCell( packet, time );
						WritePackString( packet, "Invincibility" );
						
						EmitSoundToClient( client, INVI_SOUND_PATH, iBlock );
						
						new Float:vec[ 3 ];
						GetClientAbsOrigin( client, vec );
						vec[ 2 ] += 10;
						EmitAmbientSound( INVI_SOUND_PATH, vec, client, SNDLEVEL_CONVO );	
						CreateTimer( 0.1, TimeLeft, packet );
						
						g_fInv[ client ] = GetGameTime( );
					}
					else {
						if( !g_bInv[ client ] )
							PrintHintText( client, "<font size='24'color='#867979'><b>Invencibilidade em:</b><font color='#FA0000'> %d", RoundFloat( ( g_fProp[ iBlock ][ 1 ] - ( GetGameTime( ) - g_fInv[ client ] ) ) ) );
					}
				}
			}
			case 14: 
			{ 		// Stealth
				if( ( g_iOnlyT[ iBlock ] && GetClientTeam( client ) == 2 ) || !g_iOnlyT[ iBlock ] )
				{
					if( g_bStealthCanUse[ client ] ) {
						g_bStealth[ client ] = true;
						CreateTimer( g_fProp[ iBlock ][ 0 ], ResetStealth, client );
						CreateTimer( g_fProp[ iBlock ][ 1 ], ResetStealthCooldown, client );
						SetEntityRenderFx( client, RENDERFX_NONE );
						SetEntityRenderColor( client, 255, 255, 255, 255 );
						
						SetEntityRenderMode( client, RENDER_NONE );
						SDKHook( client, SDKHook_SetTransmit, Stealth_SetTransmit )
						g_bStealthCanUse[ client ] = false;
						
						new time = RoundFloat( g_fProp[ iBlock ][ 0 ] );
						new Handle:packet = CreateDataPack( );
						WritePackCell( packet, client );
						WritePackCell( packet, time );
						WritePackString( packet, "Stealth" );
						
						new Float:vec[ 3 ];
						GetClientAbsOrigin( client, vec );
						vec[ 2 ] += 10;
						
						EmitAmbientSound( STEALTH_SOUND_PATH, vec, client, SNDLEVEL_CONVO );	
						CreateTimer( 0.1, TimeLeft, packet );
						
						g_fStealth[ client ] = GetGameTime( );
					}
					else {
						if( !g_bStealth[ client ] )
							PrintHintText( client, "<b>Invisibilidade em:</b><font color='#FA0000'> %d", RoundFloat( ( g_fProp[ iBlock ][ 1 ] - ( GetGameTime( ) - g_fStealth[ client ] ) ) ) );
					}
				}
			}
			case 15: { }
			// {		// Camouflage
				// if( ( g_iOnlyT[ iBlock ] && GetClientTeam( client ) == 2 ) || !g_iOnlyT[ iBlock ] )
				// {
					// if( g_bCamCanUse[ client ] ) {
						// if( GetClientTeam( client ) == 2 )
							// decl String:m_ModelName1[PLATFORM_MAX_PATH];
							// GetEntPropString(client, Prop_Data, "m_ModelName", m_ModelName1, sizeof(m_ModelName1));
							
							// CPrintToChat( client, "seu model de tr é %s", m_ModelName1 );
							
							// SetEntityModel( client, "models/player/ctm_gign.mdl" );
						// else if( GetClientTeam( client ) == 3 )
							// decl String:m_ModelName2[PLATFORM_MAX_PATH];
							// GetEntPropString(client, Prop_Data, "m_ModelName", m_ModelName2, sizeof(m_ModelName2));
							
							// CPrintToChat( client, "seu model de ct é %s", m_ModelName2 );
							
							// SetEntityModel( client, "models/player/tm_phoenix.mdl" );
											
						// if( GetClientTeam( client ) == 2 )
							// SetEntityModel( client, "models/player/ctm_gign.mdl" );
						// else if( GetClientTeam( client ) == 3 )
							// SetEntityModel( client, "models/player/tm_phoenix.mdl" );
						// g_bCamCanUse[ client ] = false;
						// CreateTimer( g_fProp[ iBlock ][ 0 ], ResetCamouflage, client );
						// CreateTimer( g_fProp[ iBlock ][ 1 ], ResetCamCanUse, client );
						
						// new time = RoundFloat( g_fProp[ iBlock ][ 0 ] );
						// new Handle:packet = CreateDataPack( )
						// WritePackCell( packet, client )
						// WritePackCell( packet, time )
						// WritePackString( packet, "Camouflage" )
						// new Float:vec[ 3 ];
						// GetClientAbsOrigin( client, vec );
						// vec[ 2 ] += 10;
						
						// EmitAmbientSound( CAM_SOUND_PATH, vec, client, SNDLEVEL_CONVO );
						
						// g_bKamuflaz[ client ] = true;
						// CreateTimer( 0.1, TimeLeft, packet );
						// g_fKam[ client ] = GetGameTime( );
					// }
					// else {
						// PrintHintText( client, "<font size='24'color='#867979'><b>Camuflagem em:</b><font color='#FA0000'> %d", RoundFloat((g_fProp[iBlock][1] - (GetGameTime() - g_fKam[client]))));
					// }
				// }
			// }
			case 16: 
			{		// Boots of Speed
				if( ( g_iOnlyT[ iBlock ] && GetClientTeam( client ) == 2 ) || !g_iOnlyT[ iBlock ] )
				{
					if( g_bBootsCanUse[ client ] ) {
						CreateTimer( g_fProp[ iBlock ][ 0 ], ResetBoots, client );
						CreateTimer( g_fProp[ iBlock ][ 1 ], ResetBootsCooldown, client );
						SetEntPropFloat( client, Prop_Data, "m_flLaggedMovementValue", 2.0 );
						g_bBoots[ client ] = true;
						g_bBootsCanUse[ client ] = false;
						
						new time = RoundFloat( g_fProp[ iBlock ][ 0 ] );
						new Handle:packet = CreateDataPack( )
						WritePackCell( packet, client )
						WritePackCell( packet, time )
						WritePackString( packet, "Boots Of Speed" )
						
						new Float:vec[ 3 ];
						GetClientAbsOrigin( client, vec );
						vec[ 2 ] += 10;
						EmitAmbientSound( BOS_SOUND_PATH, vec, client, SNDLEVEL_CONVO );	
						
						CreateTimer( 0.1, TimeLeft, packet );
						g_fBOS[ client ] = GetGameTime( );
					}
					else {
						if( !g_bBoots[ client ] )
							PrintHintText( client, "<font size='24'color='#867979'><b>Botas de Velocidade em:</b><font color='#FA0000'> %d", RoundFloat( ( g_fProp[ iBlock ][ 1 ] - ( GetGameTime( ) - g_fBOS[ client ] ) ) ) );
					}
				}
			}
			case 17: 
			{ 		// HE Nade
				if( ( g_bHEgrenadeCanUse[ client ][ iBlock ] && g_iOnlyT[ iBlock ] && GetClientTeam( client ) == 2 ) || g_bHEgrenadeCanUse[ client ][ iBlock ] && !g_iOnlyT[ iBlock ] )	{
					g_bHEgrenadeCanUse[ client ][ iBlock ] = false;
					
					new iAmmo = GetEntProp( client, Prop_Send, "m_iAmmo", _, 15 );
					GivePlayerItem( client, "weapon_hegrenade" );
					PrintHintText( client, "<font face='Arial'><font size='24'><font color='#A8A8A8'>Você pegou uma <b><font color='#E00000'>HE GRENADE</b></font>!" );
					SetEntProp( client, Prop_Send, "m_iAmmo", iAmmo + 1, 4, 15 );
				}
			}	
			case 18: 
			{		// FrostNade
				if( ( g_bSmokegrenadeCanUse[ client ][ iBlock ] && g_iOnlyT[ iBlock ] && GetClientTeam( client ) == 2 ) || g_bSmokegrenadeCanUse[ client ][ iBlock ] && !g_iOnlyT[ iBlock ] ) {
					GivePlayerItem( client, "weapon_decoy" ); // weapon_snowball
					PrintHintText( client, "<font face='Arial'><font size='24'><font color='#A8A8A8'>Você pegou uma <b><font color='#E00000'>FROSTGRENADE</b></font>!" );
					g_bSmokegrenadeCanUse[ client ][ iBlock ] = false;
				}
			}
			case 19: 
			{ 		// Flash Nade
				if( ( g_bFlashbangCanUse[ client ][ iBlock ] && g_iOnlyT[ iBlock ] && GetClientTeam( client ) == 2 ) || g_bFlashbangCanUse[ client ][ iBlock ] && !g_iOnlyT[ iBlock ] ) { 
					GivePlayerItem( client, "weapon_flashbang" );
					PrintHintText( client, "<font face='Arial'><font size='24'><font color='#A8A8A8'>Você pegou uma <b><font color='#E00000'>FLASHBANG</b></font>!" );
					g_bFlashbangCanUse[ client ][ iBlock ] = false;
				}
			}
			case 20: 
			{ // Weapon iBlock
				if( ( g_bDeagleCanUse[ client ][ iBlock ] && g_iOnlyT[ iBlock ] && GetClientTeam( client ) == 2 ) || g_bDeagleCanUse[ client ][ iBlock ] && !g_iOnlyT[ iBlock ] ) {
					// RemoveWeaponBySlot( client, 0 );
					// RemoveWeaponBySlot( client, 1 );

					new ent = -1;

					new iOpt = RoundFloat( g_fProp[ iBlock ][ 0 ] );

					new String:playerWeapon[ 32 ], String:sWeaponTeste[ 64 ];
					GetClientWeapon( client, playerWeapon, sizeof( playerWeapon ) );
					FormatEx( sWeaponTeste, sizeof sWeaponTeste, g_sWeapons[ iOpt ] );
					
					if( !StrEqual( playerWeapon, sWeaponTeste, false ) ) {
						ent = Client_GiveWeaponAndAmmo( client, g_sWeapons[ iOpt ], true, RoundFloat( g_fProp[ iBlock ][ 1 ] ), 0, 0, 0 );
						SetEntProp( ent, Prop_Data, "m_iClip1", RoundFloat( g_fProp[ iBlock ][ 1 ] ) );
						// SetEntProp( ent, Prop_Data, "m_iClip2", RoundFloat( g_fProp[ iBlock ][ 1 ] ) );
						SetEntData( client, g_iAmmo + ( GetEntData( ent, g_iPrimaryAmmoType ) << 2 ), 0, 4, true );
					}
					else {
						new WeaponIndex = GetEntPropEnt( client, Prop_Data, "m_hActiveWeapon" );
						new CurrentAmmo = GetEntProp( WeaponIndex, Prop_Send, "m_iClip1" );
						if( CurrentAmmo >= 0 ) {
							SetReserveAmmo( client, RoundFloat( g_fProp[ iBlock ][ 1 ] ) );
						}
							// else if( CurrentAmmo == 0 ) {
							// SetEntProp( ent, Prop_Data, "m_iClip1", RoundFloat( g_fProp[ iBlock ][ 1 ] ) );
							// }
					}

					if( iOpt == 5 ) {
						PrintHintTextToAll( "<font size='26'>CUIDADO CTS!!! <b><font size='26'><font color='#FF0000'>%N\n<font color='#00ff2a'><font size='26'>pegou uma <b><font color='#FF0000'>AWP</b></font>!!!", client );
					}
					else {
						new String:sWeapon[ 64 ];
						FormatEx( sWeapon, sizeof sWeapon, g_sWeapons[ iOpt ] );
						ReplaceString( sWeapon, sizeof sWeapon, "weapon_", "" );

						PrintHintText( client, "Você pegou uma <font size='40'><font color='#FF0000'><b>%s</b></font>", sWeapon );
					}

					g_bDeagleCanUse[ client ][ iBlock ] = false;
				}
			}
			case 21: {}
			// {		// Damage
				// if( g_bInv[ client ] ) return;
				// if( ( GetEngineTime( ) - g_fLastDamage[ client ] ) >= g_fProp[ iBlock ][ 0 ] )
				// {
					// if( GetClientHealth( client ) > 0 )
					// {
						// SDKHooks_TakeDamage( client, 0, 0, g_fProp[ iBlock ][ 1 ], DMG_CRUSH );
					// }

					// g_fLastDamage[ client ] = GetEngineTime( );
				// }
			// }
			case 22: 
			{		// Fire
				if( g_bInv[ client ] ) return;
				
				static Float:flLastSound1[ MAXPLAYERS + 1 ];
		
				if( ( GetEngineTime( ) - 0.75 ) <= flLastSound1[ client ] )
					return;
				
				flLastSound1[ client ] = GetEngineTime( );

				EmitSoundToClient( client, FIRE_SOUND_PATH, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.1 );
				
				if( ( GetEngineTime( ) - g_fLastFire[ client ] ) >= g_fProp[ iBlock ][ 0 ] )
				{
					if( GetClientHealth( client ) > 0 )
					{
						SDKHooks_TakeDamage( client, 0, 0, g_fProp[ iBlock ][ 1 ], DMG_BURN );
					}
					
					IgniteEntity( client, g_fProp[ iBlock ][ 0 ] );

					g_fLastFire[ client ] = GetEngineTime( );
				}
			}
			case 23: {}
			// { 		// Slap
				// decl Float:fVelocity[ 3 ];
				// for( new i = 0; i < 2; i++ )
				// {
					// if( GetRandomInt( 0, 1 ) )
						// fVelocity[ i ] = GetRandomFloat( -250.0, -100.0 );
					// else
						// fVelocity[ i ] = GetRandomFloat( 100.0, 250.0 );
				// }
				
				// fVelocity[ 2 ] = GetRandomFloat( 100.0, 400.0 );
				
				// SetEntPropVector( client, Prop_Data, "m_vecBaseVelocity", fVelocity );
				// SetEntPropEnt( client, Prop_Send, "m_hGroundEntity", -1 );
				
				// new iFlags = GetEntityFlags( client );
				// iFlags &= ~FL_ONGROUND;
				// iFlags |= FL_BASEVELOCITY;
				// SetEntityFlags( client, iFlags );
				
				// SDKHooks_TakeDamage( client, iBlock, iBlock, 0.0, DMG_CLUB ); // DMG_CLUB
			// }
			case 24: 
			{ 		// Death
				if( g_fProp[ iBlock ][ 0 ] >= 1.0 ) {
					ForcePlayerSuicide( client );
				}
				else{
					if( !g_bInv[ client ] && GetEntProp( client, Prop_Data, "m_takedamage", 1 ) == 2 ) {
						SDKHooks_TakeDamage( client, iBlock, iBlock, 10000.0 );
					}
				}
			}
		}
	}
}

stock GetReserveAmmo(client)
{
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) return -1;
    
    new ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if(ammotype == -1) return -1;
    
    return GetEntProp(client, Prop_Send, "m_iAmmo", _, ammotype);
}

stock SetReserveAmmo(client, ammo)
{
    new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
    if(weapon < 1) return;
    
    new ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");
    if(ammotype == -1) return;
    
    SetEntProp(client, Prop_Send, "m_iAmmo", ammo, _, ammotype);
}  

// stock HasClientWeapon(client,String:weaponClassname[]){
    
    // if(!Client_IsPlayer(client) || !IsClientInGame(client) || !IsPlayerAlive(client)){
        // return -1;
    // }
    
    // new offset = FindSendPropOffs("CHL2MP_Player", "m_hMyWeapons");
    
    // if(offset < 0){
        // return -1;
    // }
    
    // new entity = -1;
    // new String:classname[32];
    
    // for(new offset_add=0;offset_add<256;offset_add+=4) {
        
        // entity = GetWeaponClassnameByOffset(client,offset_add,classname,sizeof(classname));
        
        // if((entity < 1) || !IsValidEntity(entity)){
            // return -1;
        // }
        
        // if(StrEqual(weaponClassname,classname,false)){
            // return entity;
        // }
    // }
    // return -1;
    
// }  

// stock bool:Client_IsPlayer(entity) {

	// if (entity > GetMaxEntities()) {
		// entity = EntRefToEntIndex(entity);
	// }

	// if (entity >= 1 && entity <= MaxClients) {
		// if (IsValidEntity(entity) && IsClientInGame(entity)) {
			// return true;
		// }
	// }

	// return false;
// }


public Action:OnTouch( iBlock, iOther )
{
	if( !( 1 <= iOther <= MaxClients ) )
		return;
	
	if( g_iBlocks[ iBlock ] == 7 ) { 	// Honey SOM ?
		StopTimer_RemoveEffect( iOther );
	}
}

stock ScreenFade(iClient, iFlags = FFADE_PURGE, iaColor[4] = {0, 0, 0, 0}, iDuration = 0, iHoldTime = 0)
{
	new Handle:hScreenFade = StartMessageOne("Fade", iClient);
	PbSetInt(hScreenFade, "duration", iDuration * 500);
	PbSetInt(hScreenFade, "hold_time", iHoldTime * 500);
	PbSetInt(hScreenFade, "flags", iFlags);
	PbSetColor(hScreenFade, "clr", iaColor);
	EndMessage();
}

public Action:Stealth_SetTransmit(entity, clients)
{
	if(entity == clients)
		return Plugin_Continue;
	return Plugin_Handled;
}

public Action:TimeLeft(Handle:timer, any:pack){
	ResetPack(pack)
	new client = ReadPackCell(pack)
	if(1<=client <= MaxClients && IsClientConnected(client) && !IsFakeClient(client)){
		if(IsClientInGame(client)){
			new time = ReadPackCell(pack)
			time -= 1
			
			if(time > -1){
				new String:effectname[32];
				ReadPackString(pack, effectname, sizeof(effectname))
				
				//PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> [DETRAN]<br><font size='24'color='#867979'><b>%s:</b> %i", effectname, time);
				PrintHintText(client, "<font color='#00AFFF'size='22'><br><font size='24'color='#867979'><b>%s:</b> %i", effectname, time);

				new Handle:packet = CreateDataPack()
				WritePackCell(packet, client)
				WritePackCell(packet, time)
				WritePackString(packet, effectname)
				
				CreateTimer(1.0, TimeLeft, packet)
			}
		}
	}	
}

public Action:ResetGrav( Handle:timer, any:client ) {
	if( IsValidClient( client ) ) {
		SetEntityGravity( client, 1.0 );
	}
}

stock bool:IsValidClient(client) {
	return ((1 <= client <= MaxClients) && IsClientInGame(client));
}  

public OnEndTouch( iBlock, iClient ) {
	if( !( 1 <= iClient <= MaxClients ) ) return;

	else if( g_iBlocks[ iBlock ] == 6 || g_iBlocks[ iBlock ] == 9 || g_iBlocks[ iBlock ] == 12 ) { // NoFall 6 , Tramp 9, speedboost 12
		g_bNoFallDmg[ iClient ] = false;
	}
	else if( g_iBlocks[ iBlock ] == 7 ) { 	// Honey
		if( IsPlayerAlive( iClient ) && IsClientInGame( iClient ) ) 
			StartTimer_RemoveEffect( iClient );
	}
	// else if ( g_iBlocks[ iBlock ] == 8 ) 	// ICE
	// {
	// 	g_bOnIce[ iClient ] = false;
	// }
}

// public Action:ResetCamouflage(Handle:timer, any:client){
	// g_bKamuflaz[client] = false;
	
	// if(!IsClientInGame(client))
		// return Plugin_Stop;
	// if(GetClientTeam(client)==3)
		// SetEntityModel(client, "models/player/ctm_gign.mdl");
	// else if(GetClientTeam(client)==2)
		// SetEntityModel(client, "models/player/tm_phoenix.mdl");
	
	// PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> [DETRAN]<br><font size='24'color='#867979'><b>Camuflagem</b><font color='#FA0000'> foi retirada" );
	// return Plugin_Stop;
// }

// public Action:ResetCamCanUse(Handle:timer, any:client)
// {
	// if(!IsClientInGame(client))
		// return Plugin_Stop;
	// g_bCamCanUse[client]=true;
	
	// return Plugin_Stop;
// }

public Action:StartNoBlock(Handle:timer, any:block)
{
	if(!IsValidBlock(block)) return Plugin_Stop;
	
	SetEntProp(block, Prop_Data, "m_CollisionGroup", 2);
	SetEntityRenderMode(block, RENDER_TRANSADD);
	SetEntityRenderColor(block, g_iKlr[block][0], g_iKlr[block][1], g_iKlr[block][2], 117);
	CreateTimer(g_fProp[block][1], CancelNoBlock, block);
	
	return Plugin_Stop;
}

public Action:CancelNoBlock(Handle:timer, any:block)
{
	if( IsValidBlock( block ) ) {
		SetEntProp( block, Prop_Data, "m_CollisionGroup", 0 );
		ustawRender( block );
	}
	
	//g_iTouched[ block ] = 0;
	g_bTriggered[ block ] = false;
	return Plugin_Stop;
}

public Action:RemoveUnderknifeEffect(Handle:timer, any:client)
{
	if( g_hLBhopUsed[ client ] != INVALID_HANDLE ) { 
		KillTimer( g_hLBhopUsed[ client ] );
		g_hLBhopUsed[ client ] = INVALID_HANDLE;
	}
	
	g_bBhopUsed[ client ] = false;
	return Plugin_Stop;
}

public Action:ResetNoFall(Handle:timer, any:client)
{
	if( !IsClientInGame( client ) )
		return Plugin_Stop;
	g_bNoFallDmg[ client ] = false;
	return Plugin_Stop;
}

public Action:ResetInv(Handle:timer, any:client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;
	g_bInv[client] = false;
	
	//PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> [DETRAN]<br><font size='24'color='#867979'><b>Invensibilidade</b><font color='#FA0000'> acabou!");
	PrintHintText(client, "<font color='#00AFFF'size='22'><font size='24'color='#867979'><b>Sua Invencibilidade</b><font color='#FA0000'> acabou!");
	
	if(!g_bStealth[client]){
		SetEntityRenderFx(client, RENDERFX_NONE);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		
		SetEntityRenderMode(client, RENDER_NORMAL);
	}
	
	return Plugin_Stop;
}

public Action:ResetInvCooldown(Handle:timer, any:client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;

	g_bInvCanUse[client] = true;
	
	return Plugin_Stop;
}

public Action:ResetStealth(Handle:timer, any:client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;
	SetEntityRenderMode(client , RENDER_NORMAL); 
	SDKUnhook(client, SDKHook_SetTransmit, Stealth_SetTransmit);
	
	//PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> [DETRAN]<br><font size='24'color='#867979'><b>Invisibilidade</b><font color='#FA0000'> você é visível novamente!" );
	PrintHintText(client, "<font color='#00AFFF'size='22'><font size='24'color='#867979'><b>Invisibilidade</b><font color='#FA0000'> você é visível novamente!" );
	g_bStealth[client] = false;
	
	if(g_bInv[client]){
		SetEntityRenderMode(client, RENDER_TRANSALPHA);
		SetEntityRenderFx(client, RENDERFX_EXPLODE);
		SetEntityRenderColor(client, 0, 128, 255, 128);
	}
	
	//wznowTrail(client);
	
	return Plugin_Stop;
}

public Action:ResetStealthCooldown(Handle:timer, any:client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;
	g_bStealthCanUse[client] = true;
	
	return Plugin_Stop;
}

public Action:ResetBoots(Handle:timer, any:client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0 );
	
	g_bBoots[client]=false;
	
	//PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> [DETRAN]<br><font size='24'color='#867979'><b>Botas de Velocidade</b><font color='#FA0000'> expirou!");
	PrintHintText(client, "<font color='#00AFFF'size='22'><font size='24'color='#867979'><b>Botas de Velocidade</b><font color='#FA0000'> expirou!");
	
	return Plugin_Stop;
}

public Action:ResetBootsCooldown(Handle:timer, any:client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;
	g_bBootsCanUse[client] = true;

	return Plugin_Stop;
}

public Action:BoostPlayer(Handle:timer, any:pack)
{
	ResetPack(pack)
	new client = ReadPackCell(pack)
	new block = ReadPackCell(pack)
	
	new Float:fAngles[3];
	GetClientEyeAngles(client, fAngles);
	
	new Float:fVelocity[3];
	GetAngleVectors(fAngles, fVelocity, NULL_VECTOR, NULL_VECTOR);
	
	NormalizeVector(fVelocity, fVelocity);
	
	ScaleVector(fVelocity, g_fProp[block][1]);
	fVelocity[2] = g_fProp[block][0];
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
	return Plugin_Stop;
}

// COMECO DO MENU NOVO...
public Handle:CreateTeleportMenu( client ) {
	new Handle:menu = CreateMenu( Handler_Teleport );
	
	new String:sNoClip[ 64 ], String:sGod[ 64 ];
	FormatEx( sNoClip, sizeof sNoClip, "Noclip: %s\n", GetEntityMoveType( client ) != MOVETYPE_NOCLIP ? "Off" : "On" );
	FormatEx( sGod, sizeof sGod, "Godmode: %s \n ", GetEntProp( client, Prop_Data, "m_takedamage", 1 ) == 2 ? "Off" : "On" );
	
	SetMenuTitle( menu, "[pNr] Teleport Menu\n\n" );
	AddMenuItem( menu, "0", "Teleport Start\n" );
	AddMenuItem( menu, "1", "Teleport Destination\n" );
	AddMenuItem( menu, "2", "Swap Teleport Start/Destination\n" );
	AddMenuItem( menu, "3", "Delete Teleport\n" );
	AddMenuItem( menu, "4", "Show Teleport Path \n " );
	AddMenuItem( menu, "5", sNoClip );
	AddMenuItem( menu, "6", sGod );
	AddMenuItem( menu, "7", "Options Menu\n" );
	SetMenuExitBackButton( menu, true );
	return menu;
}
public Handler_Teleport( Handle:menu, MenuAction:action, client, param2 )	{
	if( action == MenuAction_Select ) 	{
		if( param2 == 0 ) {					// Teleport Start
			if( g_iCurrentTele[ client ] == -1 ) {
				CreateTeleportEntrance( client );

				DisplayMenu( CreateTeleportMenu( client ), client, 0 );
			}
			else
				DisplayMenu( CreateTeleportMenu( client ), client, 0 );
		}
		else if( param2 == 1 ) {			// Teleport Destination
			if( g_iCurrentTele[ client ] == -1 )
				CPrintToChat(client, "%s Create the beginning of teleportation first!", TAG);
			else
			{
				g_iTeleporters[ g_iCurrentTele[ client ] ] = CreateTeleportExit( client );
				g_iCurrentTele[ client ] = -1;
			}

			DisplayMenu( CreateTeleportMenu( client ), client, 0 );
		}
		else if( param2 == 2 ) { 		 // Swap Teleport
			new ent = GetClientAimTarget( client, false );
			new entrance = -1;
			new hexit = -1;
			
			if( ent != -1 ) {
				if( g_iTeleporters[ ent ] >= 1 ) {
					if( g_iTeleporters[ ent ] > 1 ) {
						entrance = ent;
						hexit = g_iTeleporters[ ent ];
					}
					else
					{
						for( new i = MaxClients + 1 ; i < 2048 ; ++i ) {
							if( g_iTeleporters[ i ] == ent ) {
								hexit = ent;
								entrance = i;
								break;
							}
						}
					}
					
					if( entrance > 0 && hexit > 0 ) {
						if( IsValidBlock( entrance ) && IsValidBlock( hexit ) ) {
							SetEntityModel( entrance, "models/platforms/r-tele.mdl" );
							SetEntityModel( hexit, "models/platforms/b-tele.mdl" );
							g_iTeleporters[ entrance ] = 1;
							g_iTeleporters[ hexit ] = entrance;
						}
					}
					DisplayMenu( CreateTeleportMenu( client ), client, 0 );
				}
				else{
					DisplayMenu( CreateTeleportMenu( client ), client, 0 );
				}
			}

			DisplayMenu( CreateTeleportMenu( client ), client, 0 );
		} 
		else if( param2 == 3 )	{  		// Delete Teleport
			new ent = GetClientAimTarget( client, false );
			if( IsValidBlock( ent ) ) {
				g_bTeleport[ ent ] = false;
				AcceptEntityInput( ent, "Kill" );
				g_iBlocks[ ent ] = -1;
				
				if( g_iTeleporters[ ent ] >= 1 ) {
					if( g_iTeleporters[ ent ] > 1 && IsValidBlock( g_iTeleporters[ ent ] ) ) {
						AcceptEntityInput( g_iTeleporters[ ent ], "Kill" );
						g_iTeleporters[ g_iTeleporters[ ent ] ] = -1;
					} 
					else if( g_iTeleporters[ ent ] == 1 ) {
						for( new i = MaxClients + 1; i < 2048; ++i ) {
							if( g_iTeleporters[ i ] == ent ) {
								if( IsValidBlock( i ) )
									AcceptEntityInput( i, "Kill" );
								
								g_iTeleporters[ i ] = -1;
								break;
							}
						}
					}
					
					g_iTeleporters[ ent ] = -1;
				}
			}
		} 
		else if( param2 == 4 )	{ 	// Show Teleport Path
			new ent = GetClientAimTarget( client, false );
			if( ent != -1 ) {
				new entrance = -1;
				new hexit = -1;
				if( g_iTeleporters[ ent ] >= 1 ) {
					if( g_iTeleporters[ ent ] > 1 ) {
						entrance = ent;
						hexit = g_iTeleporters[ ent ];
					}
					else {
						for( new i = MaxClients + 1 ; i < 2048 ; ++i ) {
							if( g_iTeleporters[ i ] == ent ) {
								hexit = ent;
								entrance = i;
								break;
							}
						}
					}
					if( entrance > 0 && hexit > 0 ) {
						if( IsValidBlock( entrance ) && IsValidBlock( hexit ) ) {
							new color[ 4 ] = { 255, 0, 0, 255 };
							new Float:pos1[ 3 ], Float:pos2[ 3 ];
							GetEntPropVector( entrance, Prop_Data, "m_vecOrigin", pos1 );
							GetEntPropVector( hexit, Prop_Data, "m_vecOrigin", pos2 );
							TE_SetupBeamPoints( pos2, pos1, g_iBeamSprite, 0, 0, 40, 15.0, 20.0, 20.0, 25, 0.0, color, 10 );
							TE_SendToClient( client );
						}
					}
				}
			}
			else {
				CPrintToChat( client, "%s Aim on the teleport first!", TAG );
			}
		}
		else if( param2 == 5 ) 	// Noclip.
		{
			if( GetEntityMoveType( client ) != MOVETYPE_NOCLIP )
			{
				SetEntityMoveType( client, MOVETYPE_NOCLIP );
			}
			else
			{
				SetEntityMoveType( client, MOVETYPE_ISOMETRIC );
			}
		} 
		else if( param2 == 6 ) 	// GodMode
		{
			if( GetEntProp( client, Prop_Data, "m_takedamage", 1 ) == 2 )
			{
				SetEntProp( client, Prop_Data, "m_takedamage", 0, 1 );
			}
			else
			{
				SetEntProp( client, Prop_Data, "m_takedamage", 2, 1 );
			}
		}
		else if( param2 == 7 ) 	// Options Menu
		{ 
			DisplayMenu( CreateOptionsMenu( client ), client, 0 );
		}
		else if( ( action == MenuAction_Cancel ) && ( param2 == MenuCancel_ExitBack ) )
			DisplayMenu( CreateMainMenu( client ), client, 0 );
		
		if(param2 != 7) {
			DisplayMenu( CreateTeleportMenu( client ), client, 0 );
		}
	}else if( ( action == MenuAction_Cancel ) || ( param2 == MenuCancel_ExitBack ) )
		DisplayMenu( CreateMainMenu(client), client, 0 );
}

public Handle:CreateMainMenu( client )	
{	
	new Handle:menu = CreateMenu( Handler_MainBlockBuilder );
	
	new String:sNoClip[ 64 ], String:sGod[ 64 ];
	FormatEx( sNoClip, sizeof sNoClip, "Noclip: %s", GetEntityMoveType( client ) != MOVETYPE_NOCLIP ? "Off" : "On" );
	FormatEx( sGod, sizeof sGod, "Godmode: %s \n ", GetEntProp( client, Prop_Data, "m_takedamage", 1 ) == 2 ? "Off" : "On" );

	SetMenuTitle( menu, "[pNr] BlockMaker" );
	AddMenuItem( menu, "0", "Block Menu\n" );
	AddMenuItem( menu, "1", "Teleport Menu \n " );
	AddMenuItem( menu, "2", sNoClip );
	AddMenuItem( menu, "3", sGod );
	AddMenuItem( menu, "4", "Options Menu \n " );
	
	SetMenuExitButton( menu, true );
	g_hClientMenu[client] = menu;
	return menu;
}

public Handler_MainBlockBuilder( Handle:menu, MenuAction:action, client, param2 )	{
	if( action == MenuAction_Select )
	{
		new bool:bDisplayMenu = true;
		if( param2 == 0 )		// Blocks Menu.
		{
			bDisplayMenu = false;
			CreateBlockMenu( client );
		} 
		else if( param2 == 1 )	// Teleport Menu.
		{
			bDisplayMenu = false;
			DisplayMenu( CreateTeleportMenu( client ), client, 0 );
		}
		else if( param2 == 2 ) 	// Noclip.
		{
			if( GetEntityMoveType( client ) != MOVETYPE_NOCLIP )
			{
				SetEntityMoveType( client, MOVETYPE_NOCLIP );
			}
			else
			{
				SetEntityMoveType( client, MOVETYPE_ISOMETRIC );
			}
		} 
		else if( param2 == 3 ) 	// GodMode
		{
			if( GetEntProp( client, Prop_Data, "m_takedamage", 1 ) == 2 )
			{
				SetEntProp( client, Prop_Data, "m_takedamage", 0, 1 );
			}
			else
			{
				SetEntProp( client, Prop_Data, "m_takedamage", 2, 1 );
			}
		}
		else if( param2 == 4 ) 	// Options Menu
		{ 
			bDisplayMenu = false;
			DisplayMenu( CreateOptionsMenu( client ), client, 0 );
		} 

		if( bDisplayMenu )
			DisplayMenu( CreateMainMenu( client ), client, 0 ); 
	}
}

Handle:CreateBlockMenu( client, menuPosition = -1 ) {
	new Handle:menu = CreateMenu( Handler_MainBlockMenu );
	new String:sInfo[ 128 ], String:sSize[ 128 ], String:sNoClip[ 64 ], String:sGod[ 64 ];

	// switch( g_iTempSize[ client ] )
	// {
		// case 1: sSize = "Block Size: Small";
		// case 2: sSize = "Block Size: Normal";
		// case 3: sSize = "Block Size: Large";
		// case 4: sSize = "Block Size: Extra Large";
		// case 0: sSize = "Block Size: Pole";
	// }
	
	FormatEx( sSize, sizeof sSize, "Size: %s", g_iTempSize[ client ] == 0 ? "Pole" : g_iTempSize[ client ] == 1 ? "Small" : g_iTempSize[ client ] == 2 ? "Normal" : g_iTempSize[ client ] == 3 ? "Large" : "Extra Large" );

	FormatEx( sNoClip, sizeof sNoClip, "Noclip: %s\n", GetEntityMoveType( client ) != MOVETYPE_NOCLIP ? "Off" : "On" );
	FormatEx( sGod, sizeof sGod, "Godmode: %s \n ", GetEntProp( client, Prop_Data, "m_takedamage", 1 ) == 2 ? "Off" : "On" );
	FormatEx( sInfo, sizeof sInfo, "Block Type: %s\n", g_sBlocks[ g_iBlockSelection[ client ] ] );
	// FormatEx( sSize, sizeof sSize, "%s\n", sSize );

	SetMenuTitle( menu, "[pNr] Block Menu" );
	AddMenuItem( menu, "0", sInfo );
	AddMenuItem( menu, "1", sSize );
	AddMenuItem( menu, "2", "Create Block\n" );
	AddMenuItem( menu, "3", "Delete Block\n" );
	AddMenuItem( menu, "4", "Rotate Block \n " );
	AddMenuItem( menu, "5", sNoClip );

	AddMenuItem( menu, "6", sGod );
	AddMenuItem( menu, "7", "Set Properties\n" );
	AddMenuItem( menu, "8", "Set Render \n " );
	AddMenuItem( menu, "9", "Surf Menu\n" );
	AddMenuItem( menu, "10", "Movement Menu \n " );
	AddMenuItem( menu, "11", "Convert Block\n" );

	AddMenuItem( menu, "12", "Options Menu\n" );
		
	if( menuPosition == -1 ) {
        DisplayMenu( menu, client, MENU_TIME_FOREVER );
	} else {
        DisplayMenuAtItem( menu, client, menuPosition, MENU_TIME_FOREVER );
    }

	//SetMenuExitButton( menu, true );
	return menu;
	
}
public Handler_MainBlockMenu( Handle:menu, MenuAction:action, client, param2 ) {
	if( action == MenuAction_Select )
	{
		new menuPosition = GetMenuSelectionPosition( );
		
		if( param2 == 0 )		// Block Type
		{
			DisplayMenu( CreateBlocksMenu( ), client, 0 );
		}  
		else if( param2 == 1 ) 	// Block Size
		{
			// changeBlockSize( client );
			g_iTempSize[ client ] = g_iTempSize[ client ] == 4 ? 0 : g_iTempSize[ client ] + 1;
			CreateBlockMenu( client, menuPosition ); 
			
		}
		else if( param2 == 2 )	// Create Block.
		{
			CreateBlock( client, g_iTempSize[ client ] );
			
		}
		else if( param2 == 3 ) 	// Delete
		{
			new ent = GetClientAimTarget( client, false );
			if( IsValidBlock( ent ) )
			{
				AcceptEntityInput( ent, "Kill" );
				g_iBlocks[ ent ] = -1;
				// g_iRuchomy[ ent ] = 0;
				// g_iOs[ ent ] = 0;
				// g_fRuch[ ent ] = 0.0;
				if( g_iTeleporters[ ent ] >= 1 )
				{
					if( g_iTeleporters[ ent ] > 1 && IsValidBlock( g_iTeleporters[ ent ] ) )
					{
						AcceptEntityInput(g_iTeleporters[ ent ], "Kill" );
						g_iTeleporters[ g_iTeleporters[ ent ] ] = -1;
					}
					else if( g_iTeleporters[ ent ] == 1 )
					{
						for( new i = MaxClients + 1; i < 2048; ++i )
						{
							if( g_iTeleporters[ i ] == ent )
							{
								if( IsValidBlock( i ) )
									AcceptEntityInput( i, "Kill" );
								
								g_iTeleporters[ i ] = -1;
								break;
							}
						}
					}
					
					g_iTeleporters[ ent ] = -1;
				}
			}
		}		
		else if( param2 == 4 ) 	// Rotate.
		{
			new ent = GetClientAimTarget( client, false );
			if( IsValidBlock( ent ) )
			{
				if( g_iBlockSize[ ent ] == 0 ) {
					new Float:vAng[ 3 ];
					GetEntPropVector( ent, Prop_Data, "m_angRotation", vAng );
					
					if( !vAng[ 0 ] && !vAng[ 1 ] && !vAng[ 2 ] ) {
						vAng[ 1 ] = 90.0;
						g_iRotation[ ent ] = 1;
					}
					else if( !vAng[ 0 ] && vAng[ 1 ] == 90.0 && !vAng[ 2 ] ) {
						vAng[ 2 ] = 90.0;
						g_iRotation[ ent ] = 2;
					}
					else{
						vAng[ 0 ] = 0.0;
						vAng[ 1 ] = 0.0;
						vAng[ 2 ] = 0.0;
						g_iRotation[ ent ] = 0;
					}
					
					g_fAngles[ ent ] = vAng;
					TeleportEntity( ent, NULL_VECTOR, vAng, NULL_VECTOR );
					
				}
				else {
					new Float:vAng[ 3 ];
					GetEntPropVector( ent, Prop_Data, "m_angRotation", vAng );
					
					if( vAng[ 1 ] )	{
						g_iRotation[ ent ] = 0;
						vAng[ 0 ] = 0.0;
						vAng[ 1 ] = 0.0;
						vAng[ 2 ] = 0.0;
					}
					else if( vAng[ 2 ] ) {
						g_iRotation[ ent ] = 2;
						vAng[ 1 ] = 90.0;
						vAng[ 0 ] = -90.0;
					} else {
						g_iRotation[ ent ] = 1;
						vAng[ 2 ] = 90.0;
						vAng[ 0 ] = -90.0;
					}
					
					g_fAngles[ ent ] = vAng;
					TeleportEntity( ent, NULL_VECTOR, vAng, NULL_VECTOR );
				}
			}
			else
			{
				CPrintToChat(client, "%s Mire no bloco primeiro!", TAG);
			}
		} 
		else if( param2 == 5 ) 	// Noclip.
		{
			if( GetEntityMoveType( client ) != MOVETYPE_NOCLIP )
			{
				SetEntityMoveType( client, MOVETYPE_NOCLIP );
			}
			else
			{
				SetEntityMoveType( client, MOVETYPE_ISOMETRIC );
			}
		} 
		else if( param2 == 6 ) 	// GodMode
		{
			if( GetEntProp( client, Prop_Data, "m_takedamage", 1 ) == 2 )
			{
				SetEntProp( client, Prop_Data, "m_takedamage", 0, 1 );
			}
			else
			{
				SetEntProp( client, Prop_Data, "m_takedamage", 2, 1 );
			}
		}
		else if( param2 == 7 ) 	// Set Properties
		{
			new ent = GetClientAimTarget( client, false );
			if( IsValidBlock( ent ) )
			{
				g_iTempKlocek[ client ] = ent;
				DisplayMenu( CreatePropMenu( client ), client, 0 ); 
			}
			else
			{
				CPrintToChat( client, "%s Mire no bloco primeiro!", TAG );
				CreateBlockMenu( client, menuPosition ); 
			}
		}
		else if( param2 == 8 ) { // Set Render
			DisplayMenu( CreateWlasciwosciMenu( client ), client, 0 );
		}		
		else if( param2 == 9 ) //  Surf Menu..
		{
			DisplayMenu( CreateSurfMenu( client ), client, 0 );
		}
		else if( param2 == 10 ) // Unit Menu
		{
			DrawUnitMovePanel( client ); 
		}
		else if( param2 == 11 ) 	// Convert Block.
		{
			new ent = GetClientAimTarget( client, false );
			if( IsValidBlock( ent ) && g_iTeleporters[ ent ] == -1 )
			{
				if( g_iBlockSelection[ client ] == g_iBlocks[ ent ] && g_iTempSize[ client ] == g_iBlockSize[ ent ] )
				{
					CPrintToChat( client, "%s Você está louco!? Este tipo de bloco é o mesmo!", TAG );
				}
				else
				{
					g_iBlocks[ ent ] = g_iBlockSelection[ client ];
					
					g_fProp[ ent ][ 0 ] = g_fTimeDef[ g_iBlocks[ ent ] ];
					g_fProp[ ent ][ 1 ] = g_fTime2Def[ g_iBlocks[ ent ] ];
					g_iOnTop[ ent ] = g_iOnTopDef[ g_iBlocks[ ent ] ];
					g_iOnlyT[ ent ] = g_iOnlyTDef[ g_iBlocks[ ent ] ];
					g_iBlockSize[ ent ] = g_iTempSize[ client ];
					
					DispatchKeyValue( ent, "model", g_sSciezkaModel[ g_iBlockSize[ ent ] ][ g_iBlocks[ ent ] ] );
					SetEntityModel( ent, g_sSciezkaModel[ g_iBlockSize[ ent ] ][ g_iBlocks[ ent ] ] );
				}
			}
			else
			{
				CPrintToChat(client, "%s Mire no bloco primeiro!", TAG);
			}
		}
		else if( param2 ==  12) 	// Options Menu
		{
			DisplayMenu( CreateOptionsMenu( client ), client, 0 );
		}
		
		if( param2 != 0 && param2 != 7 && param2 != 8 && param2 != 9 && param2 != 10 && param2 != 12 )
			CreateBlockMenu( client, menuPosition ); 

	}
	else if( ( action == MenuAction_Cancel ) || ( param2 == MenuCancel_ExitBack ) )
		DisplayMenu( CreateMainMenu( client ), client, 0 );		
}
// changeBlockSize( client ) {
	// switch( g_iTempSize[ client ] )
	// {
		// case 0: g_iTempSize[ client ] = 1;
		// case 1: g_iTempSize[ client ] = 2;
		// case 2: g_iTempSize[ client ] = 3;
		// case 3: g_iTempSize[ client ] = 4;
		// case 4: g_iTempSize[ client ] = 0;
	// }
// }

public Handle:CreateBlocksMenu( ) {
	new Handle:menu = CreateMenu( Handler_Blocks );
	new String:szItem[ 4 ];
	SetMenuTitle( menu, "Blocks Selection\n\n" );
	for( new i; i < MAX_BLOCKS; i++ )
	{
		IntToString( i, szItem, sizeof( szItem ) );
		AddMenuItem( menu, szItem, g_sBlocks[ i ] );
	}
	
	SetMenuExitBackButton( menu, true );
	return menu;
}

public Handler_Blocks( Handle:menu, MenuAction:action, client, param2 ) {
	if( action == MenuAction_Select )
	{
		g_iBlockSelection[ client ] = param2;
		DisplayMenu( CreateBlockMenu( client ), client, 0 );
	}
	else if( ( action == MenuAction_Cancel ) || ( param2 == MenuCancel_ExitBack ) )
		DisplayMenu( CreateBlockMenu( client ), client, 0 );
}

public Handle:CreateOptionsMenu( client ) {
	new Handle:menu = CreateMenu( Handler_Options );
	static String:steamid[ 35 ];

	GetClientAuthId( client, AuthId_Steam2, steamid, sizeof( steamid ) );  

	SetMenuTitle( menu, "[pNr] Options Menu\n" );
	
	if( g_bSnapping[ client ] )
		AddMenuItem(menu, "0", "Snapping: On\n");
	else
		AddMenuItem(menu, "0", "Snapping: Off\n");
	
	new String:sText[256];
	Format(sText, sizeof(sText), "Snapping gap: %.1f \n ", g_fSnappingGap[ client ] );
	AddMenuItem(menu, "1", sText);

	new bRoot = ( GetUserFlagBits( client ) & ADMFLAG_ROOT || GetUserFlagBits( client ) & ReadFlagString( "p" ) ? true : false );
	
	AddMenuItem(menu, "2", "Save Data \n ");
	AddMenuItem(menu, "3", "Give Access To BM \n ", ( bRoot ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED ) );


	if ( StrEqual( steamid, "STEAM_1:1:43488073", false ) || StrEqual( steamid, "STEAM_1:0:42694424", false ) ){
		AddMenuItem(menu, "4", "Delete All Blocks", ( bRoot ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED ) );
		AddMenuItem(menu, "5", "Delete All Teleports\n", ( bRoot ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED ) );
	}

	// if(g_bAutoSave)
		// AddMenuItem(menu, "6", "Autosave every 5 mins: [X]", ( bRoot ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED ) );
	// else
		// AddMenuItem(menu, "6", "Autosave every 5 mins: [  ]", ( bRoot ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED ) );
	
	SetMenuExitBackButton(menu, true);

	return menu;
}

public Handler_Options( Handle:menu, MenuAction:action, client, param2 ) {
	if( action == MenuAction_Select ) {
		if( param2 == 0 ) {
			g_bSnapping[ client ] =! g_bSnapping[ client ];
		}
		else if( param2 == 1 ) {
			g_fSnappingGap[ client ] += 4.0;
			// 40
			if( g_fSnappingGap[ client ] > 64.0 )
			{
				g_fSnappingGap[ client ] = 0.0;
			}
			
			DisplayMenu( CreateOptionsMenu( client ), client, 0 );
		}
		else if( param2 == 2 ) {
			SaveBlocks_Menu( client );
		}
		else if( param2 == 3 ) {
			MenuAccess( client, 0 );	
		}
		else if( param2 == 4 ) {
			DeleteBlocks_Menu( client );
		} 
		else if( param2 == 5 ) {
			DeleteTeleporters_Menu(client);
		}
		// else if( param2 == 6 ) {
			// g_bAutoSave =! g_bAutoSave;
			
			// if( g_hAutoSave != INVALID_HANDLE ) { 
				// KillTimer( g_hAutoSave );
				// g_hAutoSave = INVALID_HANDLE;
			// }

			// if( g_bAutoSave ) g_hAutoSave = CreateTimer( 300.0, tskAutoSave );

			// CPrintToChatAll( "%s Autosave: %s", TAG, g_bAutoSave ? "\x06ON" : "\x02OFF");
		// }
		if ( param2 == 0 )// || param2 == 6 )
			DisplayMenu( CreateOptionsMenu( client ), client, 0 );
	}
	else if( param2 == MenuCancel_ExitBack )
		DisplayMenu( CreateMainMenu( client ), client, 0 );
	else if( action == MenuAction_Cancel )
		DisplayMenu( CreateBlockMenu( client ), client, 0 );
}

stock SaveBlocks_Menu(client)
{
	new Handle:menu = CreateMenu(SaveBlocks_Handler, MenuAction_Select | MenuAction_End | MenuAction_DisplayItem);
	SetMenuTitle(menu, "[pNr] - Save Data");
	AddMenuItem(menu, "X", "Are you sure that you want to SAVE the data? \n ", ITEMDRAW_DISABLED )
	AddMenuItem(menu, "1", "Yes!")
	AddMenuItem(menu, "2", "No!")
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public SaveBlocks_Handler(Handle:menu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			new option = StringToInt(item)
			if(option == 1)
			{
				SaveBlocks(true);
				DisplayMenu(CreateOptionsMenu(client), client, 0);
			}
			else
			{
				DisplayMenu(CreateOptionsMenu(client), client, 0);
			}
		}
		case MenuAction_Cancel:
		{
			DisplayMenu( CreateOptionsMenu( client ), client, 0 );
		}
	}
}

stock DeleteBlocks_Menu(client)
{
	new Handle:menu = CreateMenu(DeleteBlocks_Handler, MenuAction_Select | MenuAction_End | MenuAction_DisplayItem);
	SetMenuTitle(menu, "[pNr] - Delete All Blocks");
	AddMenuItem(menu, "X", "Are you sure that you want to DELETE all blocks? \n "); 
	AddMenuItem(menu, "1", "Yes!")
	AddMenuItem(menu, "2", "No!")
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public DeleteBlocks_Handler(Handle:menu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			new option = StringToInt(item)
			if(option == 1)
			{
				for(new i=MaxClients+1;i<2048;++i)
				{
					if(g_iBlocks[i]!=-1)
					{
						if(IsValidBlock(i))
						{
							AcceptEntityInput(i, "Kill");
						}
						g_iBlocks[i]=-1;
					}
				}
				
				new String:whoDelete[ 64 ];
				GetClientName( client, whoDelete, 64 );
				CPrintToChatAll( "%s {DARKRED}%s{NORMAL} deleted all blocks!", TAG, whoDelete );
			}
			
			DisplayMenu(CreateOptionsMenu(client), client, 0);
		}
		case MenuAction_Cancel:
		{
			DisplayMenu( CreateOptionsMenu( client ), client, 0 );
		}
	}
}

stock DeleteTeleporters_Menu(client)
{
	new Handle:menu = CreateMenu(DeleteTeleporters_Handler, MenuAction_Select | MenuAction_End | MenuAction_DisplayItem);
	SetMenuTitle(menu, "[pNr] - Delete All Teleports");
	AddMenuItem(menu, "X", "Are you sure that you want to DELETE all teleports? \n ", ITEMDRAW_DISABLED)
	AddMenuItem(menu, "1", "Yes!")
	AddMenuItem(menu, "2", "No!")
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public DeleteTeleporters_Handler(Handle:menu, MenuAction:action, client, param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			decl String:item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			new option = StringToInt(item)
			if(option == 1)
			{
				for(new i=MaxClients+1;i<2048;++i)
				{
					if(g_iTeleporters[i]!=-1)
					{
						if(IsValidBlock(i))
						{
							AcceptEntityInput(i, "Kill");
						}
						g_iTeleporters[i]=-1;
					}
				}
				new String:whoDelete[ 64 ];

				GetClientName( client, whoDelete, 64 );
				CPrintToChatAll( "%s {DARKRED}%s{NORMAL} deleted all teleports!", TAG, whoDelete );
			}

			DisplayMenu(CreateOptionsMenu(client), client, 0);
		}
		case MenuAction_Cancel:
		{
			DisplayMenu( CreateOptionsMenu( client ), client, 0 );
		}
	}
}

bool:IsValidBlock(ent){
	if(IsValidEdict(ent) && IsValidEntity(ent)){
		if(MaxClients < ent < 2048){
			if((g_iBlocks[ent] != -1 || g_iTeleporters[ent]!=-1)){
				return true;
			}
		}
	}
	return false;
}

stock FakePrecacheSound( const String:szPath[] ){
	AddToStringTable( FindStringTable( "soundprecache" ), szPath );
}

stock GetCurrentWorkshopMap(String:szMap[], iMapBuf, String:szWorkShopID[], iWorkShopBuf){
	new String:szCurMap[128];
	new String:szCurMapSplit[2][64];
	
	GetCurrentMap(szCurMap, sizeof(szCurMap));
	
	ReplaceString(szCurMap, sizeof(szCurMap), "workshop/", "", false);
	
	ExplodeString(szCurMap, "/", szCurMapSplit, 2, 64);
	
	strcopy(szMap, iMapBuf, szCurMapSplit[1]);
	strcopy(szWorkShopID, iWorkShopBuf, szCurMapSplit[0]);
	g_bInv[client]
}

// stock bool:RemoveWeaponBySlot(iClient, iSlot){
	// new iEntity = GetPlayerWeaponSlot(iClient, iSlot);
	// if(IsValidEdict(iEntity)){
		// RemovePlayerItem(iClient, iEntity);
		// AcceptEntityInput(iEntity, "Kill");
		// return true;
	// }
	// return false;
// }

stock Float:GetClientDistanceToGround(client){
    if(GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == 0)
        return 0.0;
    
    new Float:fOrigin[3], Float:fGround[3];
    GetClientAbsOrigin(client, fOrigin);
    
    fOrigin[2] += 10.0;
    
    TR_TraceRayFilter(fOrigin, Float:{90.0,0.0,0.0}, MASK_PLAYERSOLID, RayType_Infinite, trNoPlayers, client);
    if (TR_DidHit()){
        TR_GetEndPosition(fGround);
        fOrigin[2] -= 10.0;
        return GetVectorDistance(fOrigin, fGround);
    }
    return 0.0;
}

public bool:trNoPlayers(iEnt, iBitMask, any:iData){
	return !(iEnt==iData||1<=iEnt<=MaxClients);
}

public Action:OnTakeDamagePost( iVictim, &attacker, &inflictor, &Float:damage, &damagetype ) {
	if( iVictim && 1 <= iVictim <= MaxClients && IsClientInGame( iVictim ) && attacker && 1 <= attacker <= MaxClients && IsClientInGame( attacker ) && IsPlayerAlive( attacker ) && GetClientTeam( attacker ) == CS_TEAM_CT && GetClientTeam( attacker ) != GetClientTeam( iVictim ) ) {
		new String:sWeapon[ 50 ];
		GetClientWeapon( attacker, sWeapon, sizeof sWeapon );

		if( StrContains( sWeapon, "knife", false ) != -1 && damagetype == 4100 && !g_bInv[ iVictim ] ) {
			if( g_bBhopUsed[ attacker ] && g_bBhopUsed[ iVictim ] ) {
                g_bBhopUsed[ iVictim ] = false;	
            }

			new Float:vOrigin[ 2 ][ 3 ];
			GetEntPropVector( iVictim, Prop_Send, "m_vecOrigin", vOrigin[ 0 ] );
			GetEntPropVector( attacker, Prop_Send, "m_vecOrigin", vOrigin[ 1 ] );
			
			new Float:fRoznica = ( vOrigin[ 0 ][ 2 ] - vOrigin[ 1 ][ 2 ] );
			new Float:fMax;
			if ( g_bBhopUsed[ iVictim ] ) 
			{
				if ( GetEntityFlags( attacker ) & FL_DUCKING ) 
					fMax = 65.0;
				else 
					fMax = 85.0;
        
				if ( fRoznica > fMax ) 
				{
					new String:sKil[ 64 ], String:sOfi[ 64 ];
					GetClientName( attacker, sKil, 64 );
					GetClientName( iVictim, sOfi, 64 );
					 
					damage = 0.0;
					
					SetEntPropFloat( iVictim, Prop_Send, "m_flStamina", 0.0 );
					SetEntPropFloat( iVictim, Prop_Send, "m_flVelocityModifier", 1.0 );

					CPrintToChatAll( "%s {DARKRED}%s {NORMAL}tentou dar underknifing no {LIGHTGREEN}%s", TAG, sKil, sOfi );
					
					return Plugin_Handled;
				} 
			} 
			// else {
			// 	fMax = 32.0;

			// 	vOrigin[ 1 ][ 2 ] += fMax;
		
			// 	if( vOrigin[ 0 ][ 2 ] > vOrigin[ 1 ][ 2 ] ) {
			// 		new String:sKil[ 64 ], String:sOfi[ 64 ];
			// 		GetClientName( attacker, sKil, 64 );
			// 		GetClientName( iVictim, sOfi, 64 );
					
			// 		damage = 0.0;
					
			// 		SetEntPropFloat( iVictim, Prop_Send, "m_flStamina", 0.0 );
			// 		SetEntPropFloat( iVictim, Prop_Send, "m_flVelocityModifier", 1.0 );
					
			// 		CPrintToChatAll( "%s {DARKRED}%s {NORMAL}tentou dar understab no {LIGHTGREEN}%s", TAG, sKil, sOfi );
			// 		return Plugin_Handled;
			// 	} 
			// }		
		}
	}

	return Plugin_Continue;
}

bool:isBlockStuck( iEntity ) {
	new iContent;
	new Float:vOrigin[ 3 ];
	new Float:vPoint[ 3 ];
	new Float:fSizeMin[ 3 ];
	new Float:fSizeMax[ 3 ];

	GetEntPropVector( iEntity, Prop_Send, "m_vecMins", fSizeMin );
	GetEntPropVector( iEntity, Prop_Send, "m_vecMaxs", fSizeMax );

	GetEntPropVector( iEntity, Prop_Send, "m_vecOrigin", vOrigin );
	
	// for(new x = 0 ; x < 3 ; x++) {
		// fSizeMin[x] = g_iRotation[iEntity] == 2 ? g_fBlockSizes3[g_iBlockSize[iEntity]][0][x] : g_iRotation[iEntity] == 1 ? g_fBlockSizes2[g_iBlockSize[iEntity]][0][x] : g_fBlockSizes[g_iBlockSize[iEntity]][0][x];
		// fSizeMax[x] = g_iRotation[iEntity] == 2 ? g_fBlockSizes3[g_iBlockSize[iEntity]][1][x] : g_iRotation[iEntity] == 1 ? g_fBlockSizes2[g_iBlockSize[iEntity]][1][x] : g_fBlockSizes[g_iBlockSize[iEntity]][1][x];
	// }
			
	for( new i = 0; i < 14; ++i ) {
		vPoint = vOrigin;
		
		switch( i )	{
			case 0: { vPoint[ 0 ] += fSizeMax[ 0 ]; vPoint[ 1 ] += fSizeMax[ 1 ]; vPoint[ 2 ] += fSizeMax[ 2 ]; }
			case 1: { vPoint[ 0 ] += fSizeMin[ 0 ]; vPoint[ 1 ] += fSizeMax[ 1 ]; vPoint[ 2 ] += fSizeMax[ 2 ]; }
			case 2: { vPoint[ 0 ] += fSizeMax[ 0 ]; vPoint[ 1 ] += fSizeMin[ 1 ]; vPoint[ 2 ] += fSizeMax[ 2 ]; }
			case 3: { vPoint[ 0 ] += fSizeMin[ 0 ]; vPoint[ 1 ] += fSizeMin[ 1 ]; vPoint[ 2 ] += fSizeMax[ 2 ]; }
			case 4: { vPoint[ 0 ] += fSizeMax[ 0 ]; vPoint[ 1 ] += fSizeMax[ 1 ]; vPoint[ 2 ] += fSizeMin[ 2 ]; }
			case 5: { vPoint[ 0 ] += fSizeMin[ 0 ]; vPoint[ 1 ] += fSizeMax[ 1 ]; vPoint[ 2 ] += fSizeMin[ 2 ]; }
			case 6: { vPoint[ 0 ] += fSizeMax[ 0 ]; vPoint[ 1 ] += fSizeMin[ 1 ]; vPoint[ 2 ] += fSizeMin[ 2 ]; }
			case 7: { vPoint[ 0 ] += fSizeMin[ 0 ]; vPoint[ 1 ] += fSizeMin[ 1 ]; vPoint[ 2 ] += fSizeMin[ 2 ]; }
			
			case 8: { vPoint[ 0 ] += fSizeMax[ 0 ]; }
			case 9: { vPoint[ 0 ] += fSizeMin[ 0 ]; }
			case 10: { vPoint[ 1 ] += fSizeMax[ 1 ]; }
			case 11: { vPoint[ 1 ] += fSizeMin[ 1 ]; }
			case 12: { vPoint[ 2 ] += fSizeMax[ 2 ]; }
			case 13: { vPoint[ 2 ] += fSizeMin[ 2 ]; }
		}
		
		iContent = TR_GetPointContents( vPoint );
		
		if( iContent == CONTENTS_EMPTY || iContent == 0 )	{
			return false;
		}
	}

	return true;
}

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <colors>
#include <smlib>

#define MAX_RESOURCES	6
#define MAX_BLOCKS		31

#define VERSION			"1.2"

public Plugin:myinfo =
{
	name = "BlockMaker",
	author = "diablix",
	description = "<3",
	version = VERSION,
	url = "id/8runo1"
}

#define ACCESS ADMFLAG_GENERIC 

new currentEnt[MAXPLAYERS+1];
new byUnits[MAXPLAYERS+1];
new g_bRotationMode[MAXPLAYERS+1];
new g_BeamSprite;
new g_HaloSprite;
new g_iRespawn;
new g_iBeamSprite;
new g_iDragEnt[MAXPLAYERS+1];
new g_iOldButtons[MAXPLAYERS+1];
new g_iMozePokazac[MAXPLAYERS+1];
new g_iHoney[MAXPLAYERS+1];
new g_iGravity[MAXPLAYERS+1];
new g_iTempAlpha[MAXPLAYERS+1];
new g_iTempKlocek[MAXPLAYERS+1];
new g_iLastObr[MAXPLAYERS+1][2];
new g_iTempKlr[MAXPLAYERS+1][3];
new g_iTempSize[MAXPLAYERS+1];
new g_iTempRuchomy[MAXPLAYERS+1];
new g_iTempOs[MAXPLAYERS+1];
new g_iPropped[MAXPLAYERS+1];
new g_iCurrentTele[MAXPLAYERS+1];
new g_iBlockSelection[MAXPLAYERS+1];
new g_iBlocks[2048];
new g_iTeleporters[2048];
new g_iOnTop[2048];
new g_iRotation[2048];
new g_iOnlyT[2048];
new g_iAlpha[2048];
new g_iRuchomy[2048];
new g_iOs[2048];
new g_iTouched[2048];
new g_iBlockSize[2048];
new g_iKlr[2048][3];
new g_iTempColor[2048];

new Float:g_fLastTramp[MAXPLAYERS+1];
new Float:g_fLastSpeed[MAXPLAYERS+1];
new Float:g_fLastDamage[MAXPLAYERS+1];
new Float:g_fInv[MAXPLAYERS+1];
new Float:g_fStealth[MAXPLAYERS+1];
new Float:g_fDistance[MAXPLAYERS+1];
new Float:g_fBOS[MAXPLAYERS+1];
new Float:g_fLastHP[MAXPLAYERS+1];
new Float:g_fKam[MAXPLAYERS+1];
new Float:g_fActChance[MAXPLAYERS+1];
new Float:g_fLastChance[MAXPLAYERS+1];
new Float:g_fLastDuck[MAXPLAYERS+1];
new Float:g_fTempRuch[MAXPLAYERS+1];
new Float:g_fSnappingGap[MAXPLAYERS+1]={0.0,...};
new Float:g_fRuch[2048];
new Float:g_fProp[2048][2];
new Float:g_fAngles[2048][3];
new Float:g_fChance[MAXPLAYERS+1][2048];
new Float:g_fVec[2048][3];
new Float:g_fGrabOffset[MAXPLAYERS+1][3];
new bool:g_bAutoSave=false;
new bool:g_bHoney[MAXPLAYERS+1];
new bool:g_bBoots[MAXPLAYERS+1];
new bool:g_bOnIce[MAXPLAYERS+1];
new bool:g_bChance[MAXPLAYERS+1];
new bool:g_bStealth[MAXPLAYERS+1];
new bool:g_bKamuflaz[MAXPLAYERS+1];
new bool:g_bJustJumped[MAXPLAYERS+1];
new bool:g_bNoFallDmg[MAXPLAYERS+1]={false,...};
new bool:g_bInvCanUse[MAXPLAYERS+1]={true,...};
new bool:g_bSnapping[MAXPLAYERS+1]={false,...};
new bool:g_bInv[MAXPLAYERS+1]={false,...};
new bool:g_bStealthCanUse[MAXPLAYERS+1]={true,...};
new bool:g_bBootsCanUse[MAXPLAYERS+1]={true,...};
new bool:g_bDamage[MAXPLAYERS+1]={false,...};
new bool:g_bHeal[MAXPLAYERS+1]={false,...};
new bool:g_bLocked[2048]={false,...};
new bool:g_bCamCanUse[MAXPLAYERS+1]={true,...};
new bool:g_bStop[2048];
new bool:g_bTeleport[2048];
new bool:g_bTriggered[2048] = {false, ...};
new bool:g_bXP[MAXPLAYERS+1][2048];
new bool:g_bLP[MAXPLAYERS+1][2048];
new bool:g_bDeagleCanUse[MAXPLAYERS+1][2048];
new bool:g_bHEgrenadeCanUse[MAXPLAYERS+1][2048];
new bool:g_bFlashbangCanUse[MAXPLAYERS+1][2048];
new bool:g_bSmokegrenadeCanUse[MAXPLAYERS+1][2048];
new String:g_sSciezkaModel[4][MAX_BLOCKS][256];

new const String:g_sWeapons[33][] = {
	"weapon_ak47", "weapon_revolver", "weapon_aug", "weapon_bizon", "weapon_deagle", "weapon_awp", "weapon_elite", "weapon_famas", "weapon_fiveseven", "weapon_cz75a",
	"weapon_g3sg1", "weapon_galilar", "weapon_glock", "weapon_hkp2000", "weapon_usp_silencer", "weapon_m249", "weapon_m4a1",
	"weapon_mac10", "weapon_mag7", "weapon_mp7", "weapon_mp9", "weapon_negev", "weapon_nova", "weapon_p250", "weapon_p90", "weapon_sawedoff",
	"weapon_scar20", "weapon_sg556", "weapon_ssg08", "weapon_taser", "weapon_tec9", "weapon_ump45", "weapon_xm1014"
};

new const String:g_sPodFolder[] = "blockmaker";
//new const String:INVI_SOUND_PATH[] = "*hnsrussian/invincibility.mp3"
//new const String:STEALTH_SOUND_PATH[] = "*hnsrussian/stealth.mp3"
//new const String:NUKE_SOUND_PATH[] = "*hnsrussian/nuke.mp3"
//new const String:BOS_SOUND_PATH[] = "*hnsrussian/bootsofspeed.mp3"
//new const String:CAM_SOUND_PATH[] = "*hnsrussian/camouflage.mp3"
//new const String:TELE_SOUND_PATH[] = "*hnsrussian/teleport.mp3"
//new const String:XP_SOUND_PATH[] = "*hnsrussian/exp.mp3"
// const String:RESPAWN_SOUND_PATH[] = "*hnsrussian/respawn.mp3"
//new const String:LAST_SOUND_PATH[] = "*hnsrussian/last.mp3"
new const String:g_sGrenadeWeaponNames[][] = {        
    "weapon_flashbang",        
    "weapon_molotov",
    "weapon_smokegrenade",
    "weapon_hegrenade",
    "weapon_decoy",
    "weapon_incgrenade"
};

new const String:g_sDamage[5][] = {
	"*hnsrussian/d0.mp3",
	"*hnsrussian/d1.mp3",
	"*hnsrussian/d2.mp3",
	"*hnsrussian/c0.mp3",
	"*hnsrussian/c1.mp3"
};

enum {
	POLE = 0,
	SMALL,
	NORMAL,
	LARGE
}

static const Float:g_fBlockSizes[4][2][3] = {
	{{-4.25, -32.25, -4.25}, {4.25, 32.25, 4.25}},
	{{-15.97, -16.00, -3.97}, {15.97, 16.00, 3.97}},
	{{-32.25, -32.22, -4.21}, {32.25, 32.22, 4.21}},
	{{-64.25, -64.18, -4.21}, {64.25, 64.18, 4.21}}
};

static const Float:g_fBlockSizes2[4][2][3] = {
	{{-32.25, -4.25, -4.25}, {32.25, 4.25, 4.25}},
	{{-15.97, -3.97, -16.00}, {15.97, 3.97, 16.00}},
	{{-32.25, -4.21, -32.22}, {32.25, 4.21, 32.22}},
	{{-64.25, -4.21, -64.18}, {64.25, 4.21, 64.18}}
};

static const Float:g_fBlockSizes3[4][2][3] = {
	{{-4.25, -4.25, -32.25}, {4.25, 4.25, 32.25}},
	{{-3.97, -15.97, -16.00}, {3.97, 15.97, 16.00}},
	{{-4.21, -32.25, -32.22}, {4.21, 32.25, 32.22}},
	{{-4.21, -64.25, -64.18}, {4.21, 64.25, 64.18}}
};

static const g_iRandomColor[6][4] = {
	{255, 0, 0, 255},
	{0, 255, 0, 255},
	{0, 0, 255, 255},
	{255, 255, 0, 255},
	{0, 255, 255, 255},
	{255, 0, 255, 255}
}

new Handle:g_hBlocksKV;
new Handle:g_hAutoSave;
new Handle:g_hMiod[MAXPLAYERS+1];
new Handle:g_hProps[MAXPLAYERS+1];
new Handle:g_hClientMenu[MAXPLAYERS+1];
new Handle:g_hCol[2048];
new Handle:g_hRender[2048];

public OnPluginStart(){	
	RegConsoleCmd("sm_bm", Command_BlockBuilder);
	RegConsoleCmd("sm_bb", Command_BlockBuilder);
	
	HookEvent("round_start", RoundStart);
	HookEvent("player_death", zH_PlayerDeath);
	
	RegAdminCmd("sm_saveblocks", Command_Save, ACCESS);
	RegAdminCmd("unit_move", Command_UnitMove, ACCESS);
	RegAdminCmd("unit_surf", Command_UnitSurf, ACCESS);
	RegAdminCmd("unit_edit", Command_UnitEdit, ACCESS);
	RegAdminCmd("block_snap", Command_BlockSnap, ACCESS);
	RegAdminCmd("sm_snapgrid", Command_SnapGrid, ACCESS)
		
	RegAdminCmd("+grab", cmdGrab, ACCESS);
	RegAdminCmd("-grab", cmdUngrab, ACCESS);
}

/*
stock dPrintHintText(id, String:sTekst[], any ...){
	new iLen = strlen(sTekst) + 255;
	char[]sHud = new char[iLen];
	
	VFormat(sHud, iLen, sTekst, 3);
	
	g_bCantSpeedo[id]=true;
	PrintHintText(id, sHud);
	if(g_hSpeedo[id] != INVALID_HANDLE){
		KillTimer(g_hSpeedo[id]);
		g_hSpeedo[id] = INVALID_HANDLE;
	}
	g_hSpeedo[id] = CreateTimer(6.25, tskSpeedo, id);
}*/

public dobierzD(id, iRodzaj){
	new iL;
	iL = iRodzaj == 0 ? GetRandomInt(0, 2) : GetRandomInt(3,4);

	if(iL==g_iLastObr[id][iRodzaj]){
		dobierzD(id, iRodzaj);
	}
	else{
		g_iLastObr[id][iRodzaj] = iL;
	}
}

new const Float:g_fTime2Max[MAX_BLOCKS] = {
	0.0, //plat
	1.0, //bh
	10.0, //obrazenia
	10.0, //leczenie
	0.0, //lod
	0.0, //trampolina
	900.0, //strzalka
	60.0, //niesmiertelnosc
	60.0, //stealth
	0.0, //smierc
	0.0, //ldeath
	0.0, //lbhop
	0.0, //lplat
	0.0, //lhoney
	0.0, //ct barrier
	0.0, //t barrier
	60.0, //boots of speed
	0.0, //glass
	0.0, //grass
	0.0, //no fall damage
	0.0, //honey
	60.0, //kamuflaz
	3.0, //deagle
	0.0, //awp
	0.0, //large awp
	0.0, //he grenade
	0.0, //flash grenade
	0.0, //frost grenade
	3.0, //delayed
	10.0, //respawn
	0.0
};

new const Float:g_fTime2Stopa[MAX_BLOCKS] = {
	0.0, //plat
	0.1, //bh
	1.0, //obrazenia
	1.0, //leczenie
	0.0, //lod
	0.0, //trampolina
	75.0, //strzalka
	5.0, //niesmiertelnosc
	5.0, //stealth
	0.0, //smierc
	0.0, //ldeath
	0.0, //lbhop
	0.0, //lplat
	0.0, //lhoney
	0.0, //ct barrier
	0.0, //t barrier
	5.0, //boots of speed
	0.0, //glass
	0.0, //grass
	0.0, //no fall damage
	0.0, //honey
	5.0, //kamuflaz
	1.0, //deagle
	0.0, //awp
	0.0, //large awp
	0.0, //he grenade
	0.0, //flash grenade
	0.0, //frost grenade
	0.1, //delayed
	1.0, //respawn
	0.0
};

new const Float:g_fTime2Def[MAX_BLOCKS] = {
	0.0, //plat
	1.0, //bh
	2.0, //obrazenia
	2.0, //leczenie
	0.0, //lod
	0.0, //trampolina
	750.0, //strzalka
	60.0, //niesmiertelnosc
	60.0, //stealth
	0.0, //smierc
	0.0, //ldeath
	0.0, //lbhop
	1.0, //lplat
	0.0, //lhoney
	0.0, //ct barrier
	0.0, //t barrier
	60.0, //boots of speed
	0.0, //glass
	0.0, //grass
	0.0, //no fall damage
	0.0, //honey
	60.0, //kamuflaz
	1.0, //deagle
	0.0, //awp
	0.0, //large awp
	0.0, //he grenade
	0.0, //flash grenade
	0.0, //frost grenade
	1.0, //delayed
	1.0, //respawn
	0.0
};

new const Float:g_fTime2Min[MAX_BLOCKS] = {
	0.0, //plat
	0.1, //bh
	1.0, //obrazenia
	1.0, //leczenie
	0.0, //lod
	0.0, //trampolina
	200.0, //strzalka
	5.0, //niesmiertelnosc
	5.0, //stealth
	0.0, //smierc
	0.0, //ldeath
	0.0, //lbhop
	0.0, //lplat
	0.0, //lhoney
	0.0, //ct barrier
	0.0, //t barrier
	5.0, //boots of speed
	0.0, //glass
	0.0, //grass
	0.0, //no fall damage
	0.0, //honey
	5.0, //kamuflaz
	1.0, //deagle
	0.0, //awp
	0.0, //large awp
	0.0, //he grenade
	0.0, //flash grenade
	0.0, //frost grenade
	0.1, //delayed
	1.0, //respawn
	0.0 //xp
};

new const String:g_sTime2Nazwa[MAX_BLOCKS][33] = {
	"None",
	"Restores in", //bh
	"Dmg", //obrazenia
	"HP", //leczenie
	"None",
	"None", //trampolina
	"Speed", //strzalka
	"Cooldown", //niesmiertelnosc
	"Cooldown", //stealth
	"None",
	"None",
	"None", //lbhop
	"None", //lplat
	"None", //lhoney
	"None",
	"None",
	"Cooldown", //boots of speed
	"None",
	"None",
	"None",
	"None", //honey
	"Cooldown", //kamuflaz
	"Ammo",
	"None",
	"None",
	"None",
	"None",
	"None",
	"Restores in",
	"Time interval",
	"None"
};

new const g_iOnlyTShow[MAX_BLOCKS] = {
	0, //plat
	0, //bh
	0, //obrazenia
	0, //leczenie
	0, //lod
	0, //trampolina
	0, //strzalka
	1, //niesmiertelnosc
	1, //stealth
	0, //smierc
	0, //l death
	1, //low gravity
	0, //fire
	0, //slap
	0, //ct barrier
	0, //t barrier
	1, //boots of speed
	0, //glass
	0, //bunnyhop nsd
	0, //no fall damage
	0, //honey
	1, //kamuflaz
	1, //deagle
	0, //awp
	1, //random
	1, //he grenade
	1, //flash grenade
	1, //frost grenade
	0, //delayed
	0,
	0
};

new const g_iOnTopShow[MAX_BLOCKS] = {
	0, //plat
	1, //bh
	1, //obrazenia
	1, //leczenie
	0, //lod
	1, //trampolina
	1, //strzalka
	1, //niesmiertelnosc
	1, //stealth
	1, //smierc
	0, //P2000
	1, //low gravity
	1, //fire
	1, //slap
	0, //ct barrier
	0, //t barrier
	1, //boots of speed
	0, //glass
	0, //bunnyhop nsd
	0, //no fall damage
	0, //honey
	1, //kamuflaz
	1, //deagle
	1, //awp
	1, //random
	1, //he grenade
	1, //flash grenade
	1, //frost grenade
	1, //delayed
	0,
	1
};

new const Float:g_fTimeMax[MAX_BLOCKS] = {
	0.0, //plat
	1.5, //bh
	3.0, //obrazenia
	3.0, //leczenie
	2.0, //lod
	800.0, //trampolina
	600.0, //strzalka
	20.0, //niesmiertelnosc
	20.0, //stealth
	1.0, //smierc
	2.0, //ldeath
	0.0, //lbhop
	5.0, //lplat
	30.0, //lhoney
	0.0, //ct barrier
	0.0, //t barrier
	20.0, //boots of speed
	0.0, //glass
	0.0, //grass
	0.0, //no fall damage
	0.8, //honey
	20.0, //kamuflaz
	35.0, //deagle
	1200.0, //awp
	0.0, //large awp
	0.0, //he grenade
	0.0, //flash grenade
	0.0, //frost grenade
	3.0, //delayed
	100.0,
	30.0
};

new const Float:g_fTimeStopa[MAX_BLOCKS] = {
	0.0, //plat
	0.1, //bh
	0.25, //obrazenia
	0.25, //leczenie
	0.1, //lod
	50.0, //trampolina
	50.0, //strzalka
	1.0, //niesmiertelnosc
	1.0, //stealth
	1.0, //smierc
	0.25, //ldeath
	0.0, //lbhop
	1.0, //lplat
	5.0, //lhoney
	0.0, //ct barrier
	0.0, //t barrier
	1.0, //boots of speed
	0.0, //glass
	0.0, //grass
	0.0, //no fall damage
	0.1, //honey
	1.0, //kamuflaz
	1.0, //deagle
	100.0, //awp
	0.0, //large awp
	0.0, //he grenade
	0.0, //flash grenade
	0.0, //frost grenade
	1.0, //delayed
	5.0,
	5.0
};

new const Float:g_fTimeDef[MAX_BLOCKS] = {
	0.0, //plat
	0.1, //bh
	1.0, //obrazenia
	1.0, //leczenie
	0.0, //lod
	300.0, //trampolina
	260.0, //strzalka
	15.0, //niesmiertelnosc
	15.0, //stealth
	0.0, //smierc
	0.75, //ldeath
	0.0, //lbhop
	3.0, //lplat
	10.0, //lhoney
	0.0, //ct barrier
	0.0, //t barrier
	15.0, //boots of speed
	0.0, //glass
	0.0, //grass
	0.0, //no fall damage
	0.3, //honey
	15.0, //kamuflaz
	0.0, //deagle
	400.0, //awp
	0.0, //large awp
	0.0, //he grenade
	0.0, //flash grenade
	0.0, //frost grenade
	1.0, //delayed
	20.0,
	5.0
};

new const Float:g_fTimeMin[MAX_BLOCKS] = {
	0.0, //plat
	0.1, //bh
	0.25, //obrazenia
	0.25, //leczenie
	0.0, //lod
	300.0, //trampolina
	260.0, //strzalka
	1.0, //niesmiertelnosc
	1.0, //stealth
	0.0, //smierc
	0.25, //ldeath
	0.0, //lbhop
	2.0, //lplat
	5.0, //lhoney
	0.0, //ct barrier
	0.0, //t barrier
	1.0, //boots of speed
	0.0, //glass
	0.0, //grass
	0.0, //no fall damage
	0.1, //honey
	1.0, //kamuflaz
	0.0, //deagle
	200.0, //awp
	0.0, //large awp
	0.0, //he grenade
	0.0, //flash grenade
	0.0, //frost grenade
	1.0, //delayed
	25.0,
	5.0
};

new const String:g_sTimeNazwa[MAX_BLOCKS][34] = {
	"None",
	"Disappears in", //bh
	"Time interval", //obrazenia
	"Time interval", //leczenie
	"Turbo",
	"Up power", //trampolina
	"Up power", //strzalka
	"Time", //niesmiertelnosc
	"Time", //stealth
	"Kills with godmode",
	"Bounce power",
	"None", //lbhop
	"Bounces", //lplat
	"Amount", //lhoney
	"None",
	"None",
	"Time", //boots of speed
	"None",
	"None",
	"None",
	"Speed", //honey
	"Time", //kamuflaz
	"Weapon type",
	"Amount",
	"None",
	"None",
	"None",
	"None",
	"Disappears in",
	"Chance",
	"Amount"
};

new const g_iOnTopDef[MAX_BLOCKS] = {
	1, //plat
	1, //bh
	1, //obrazenia
	1, //leczenie
	1, //lod
	1, //trampolina
	1, //strzalka
	1, //niesmiertelnosc
	1, //stealth
	1, //smierc
	0, //p2000
	1, //low gravity
	1, //fire
	1, //slap
	0, //ct barrier
	0, //t barrier
	1, //boots of speed
	1, //glass
	1, //bunnyhop nsd
	1, //no fall damage
	1, //honey
	1, //kamuflaz
	1, //deagle
	1, //awp
	1, //random
	1, //he grenade
	1, //flash grenade
	1, //frost grenade
	1, //delayed
	1,
	1
};

new const g_iOnlyTDef[MAX_BLOCKS] = {
	0, //plat
	0, //bh
	0, //obrazenia
	0, //leczenie
	0, //lod
	0, //trampolina
	0, //strzalka
	0, //niesmiertelnosc
	0, //stealth
	0, //smierc
	0, //P2000
	0, //low gravity
	0, //fire
	0, //slap
	0, //ct barrier
	0, //t barrier
	0, //boots of speed
	0, //glass
	0, //bunnyhop nsd
	0, //no fall damage
	0, //honey
	0, //kamuflaz
	1, //deagle
	0, //awp
	0, //random
	1, //he grenade
	1, //flash grenade
	1, //frost grenade
	0, //delayed
	1,
	0
};

new const String:g_sBlocks[MAX_BLOCKS][21] = {
	"Platform",
	"Bunnyhop",
	"Damage",
	"Heal",
	"Ice",
	"Trampoline",
	"Speedboost",
	"Invincibility",
	"Stealth",
	"Death",
	"Grenae barrier",
	"Random player respawn",
	"Delayed Bunnyhop++",
	"Lucky Points",
	"CT Barrier",
	"T Barrier",
	"Boots of speed",
	"Glass",
	"Grass",
	"NoFallDamage",
	"Honey",
	"Camouflage",
	"New Weapon",
	"Gravity",
	"SKIP_THIS",
	"HE Grenade",
	"Flashbang",
	"Frostgrenade",
	"Delayed Bunnyhop",
	"Respawn chance",
	"Money"
};

new const String:g_sNormalneKlocki[MAX_BLOCKS][] = {
	"platform",
	"bunnyhop",
	"damage",
	"heal",
	"ice",
	"trampoline",
	"speedboost",
	"invincibility",
	"stealth",
	"death",
	"platform", //4 unused
	"platform", //
	"platform", // 
	"platform", //
	"ct_barrier",
	"tt_barrier",
	"boots",
	"glass",
	"grass",
	"nfd",
	"honey",
	"camouflage",
	"weapon",
	"platform", //old awp
	"platform", //old dgl
	"hegrenade",
	"flashgrenade",
	"frostgrenade",
	"delayedbunnyhop",
	"respawn",
	"money"
};

static const String:g_sRozszerzenia[MAX_RESOURCES][] = {
	".mdl",
	".dx90.vtx",
	".phy",
	".vvd",
	".vmt",
	".vtf"
};

public Action:WeaponsMenu(client, args){
	new Handle:hMenu = CreateMenu(MenuWeapons);
	SetMenuTitle(hMenu, "BM | Choose Weapon");
	
	new String:sWeapon[64];
	for (new i=0 ; i < 32 ; i++){
		FormatEx(sWeapon, sizeof sWeapon, g_sWeapons[i]);
		ReplaceString(sWeapon, sizeof sWeapon, "weapon_", "");
		
		AddMenuItem(hMenu, sWeapon, sWeapon);
	}
	
	SetMenuExitButton(hMenu, true);
	DisplayMenu(hMenu, client, 9999);
 
	return Plugin_Handled
}

public MenuWeapons(Handle:hMenu, MenuAction:action, param1, param2){
	if(action == MenuAction_Select){
		new iEnt = g_iTempKlocek[param1];
		
		if(IsValidBlock(iEnt)){
			new String:sInfo[64];
			GetMenuItem(hMenu, param2, sInfo, sizeof(sInfo));
			
			g_fProp[iEnt][0] = float(param2);
			
			CPrintToChat(param1, "{blue}*{lime}[HNSBM %s]{orange} Weapon chosen:{olive} %s", VERSION, sInfo);
			
			DisplayMenu(CreatePropMenu(param1), param1, 0);
		}
		else{
			CPrintToChat(param1, "{blue}*{lime}[HNSB %s]{orange} Could not change the weapon! Block missing", VERSION);
			DisplayMenu(CreateMainMenu(param1), param1, 0);
		}
	}  
	if(action == MenuAction_End){
		CloseHandle(hMenu);
		DisplayMenu(CreateMainMenu(param1), param1, 0);
	}
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("mozePokazac", _mozePokazac);
	CreateNative("isBlock", _isBlock);
	return APLRes_Success;
}

public _isBlock(Handle:plugin, numParams){
	new iEnt = GetNativeCell(1);
	
	return IsValidBlock(iEnt) ? 1 : 0;
}

public _mozePokazac(Handle:plugin, numParams)
{
	new iGracz = GetNativeCell(1);
	
	return _:g_iMozePokazac[iGracz];
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
}


//public OnMapEnd() SaveBlocks(true);
//public OnPluginEnd() SaveBlocks(true);

public Action:tskAutoSave(Handle:hTimer){
	g_hAutoSave = INVALID_HANDLE;
	
	SaveBlocks(false);
	
	if(g_bAutoSave) g_hAutoSave = CreateTimer(300.0, tskAutoSave);
}

public Action:fixSpw(Handle:hTimer, any:iOfiara){
	if(IsClientInGame(iOfiara)){
		decl String:sName[MAX_NAME_LENGTH];
		GetClientName(iOfiara, sName, sizeof(sName));
				
		CS_RespawnPlayer(iOfiara);
		
		new Float:vec[3];
		GetClientAbsOrigin(iOfiara, vec);
		vec[2] += 10;
		EmitAmbientSound(RESPAWN_SOUND_PATH, vec, iOfiara, SNDLEVEL_RAIDSIREN);	
		
		CPrintToChatAll("{blue}*{lime}[!!!]{orange} %s had charged Respawn Chance and got respawned! [{lime}%d%c{orange}]", sName, RoundFloat(g_fActChance[iOfiara]), '%');
	}
}

public Action:Command_BlockSnap(client, args)
{
	g_bSnapping[client] = !g_bSnapping[client]
	CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Snapping %s!", VERSION, g_bSnapping[client] ? "enabled" : "disabled");
}

public Action:Command_SnapGrid(client, args)
{
	new String:argc[18]
	GetCmdArg(1, argc, sizeof(argc))
	
	g_fSnappingGap[client] = StringToFloat(argc)
}

public Action:Command_Save(client, args){
	SaveBlocks(true);
}

public Action:Command_UnitMove(client, args){
	if(1 <= client <= MaxClients && IsClientConnected(client) && IsClientInGame(client)){
		new Float:vecAngles[3], Float:vecOrigin[3];
		GetClientEyePosition(client, vecOrigin);
		GetClientEyeAngles(client, vecAngles);
		
		new entity = GetClientAimTarget(client, false);
		
		if( (entity && IsValidBlock(entity)) && !(1 <= entity <= MaxClients) ){
			currentEnt[client] = entity;
			DrawUnitMovePanel(client);
			return Plugin_Handled;
		}
		CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Aim on the block first!", VERSION);
		DisplayMenu(CreateMainMenu(client), client, 0);
	}
	
	return Plugin_Handled;
}

public Action:Command_UnitSurf(client, args){
	if(1 <= client <= MaxClients && IsClientConnected(client) && IsClientInGame(client)){
		new Float:vecAngles[3], Float:vecOrigin[3];
		GetClientEyePosition(client, vecOrigin);
		GetClientEyeAngles(client, vecAngles);
		
		new entity = GetClientAimTarget(client, false);
		
		if( (entity && IsValidBlock(entity)) && !(1 <= entity <= MaxClients) ){
			currentEnt[client] = entity;
			DrawSurfPanel(client);
			return Plugin_Handled;
		}
		CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Aim on the block first!", VERSION);
		DisplayMenu(CreateMainMenu(client), client, 0);
	}
	
	return Plugin_Handled;
}

DrawSurfPanel(client)
{
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "BM | Surf menu\n");
	DrawPanelItem(panel, "1st Side");
	DrawPanelItem(panel, "2nd Side");

	DrawPanelItem(panel, "Exit");
	SendPanelToClient(panel, client, DrawSurfPanelHandler, 360);
	
	CloseHandle(panel);
}

public DrawSurfPanelHandler(Handle:menu, MenuAction:action, client, key)
{
	if (action == MenuAction_Select)
	{
		if(!(IsValidEntity(currentEnt[client]) && IsValidEdict(currentEnt[client]))){
			return;
		}
		new Float:currentEntLocation[3];
		GetEntPropVector(currentEnt[client], Prop_Data, "m_angRotation", currentEntLocation);  
		
		
		new Float:byUnitsFloat = 60.0;
		new Dont = false
		new iRot = g_iRotation[currentEnt[client]];
		
		switch(key) 
		{
			//case 1,2,3,4,5,6:
				//currentEntLocation[(key-1)/2] = (key%2 == 0 && key != 1) ? currentEntLocation[(key-1)/2]-10.0 : currentEntLocation[(key-1)/2]+10.0;
			
			case 1: 
			{ 
				if(iRot == 0 || iRot == 1){
					currentEntLocation[0] = 0.0;
					currentEntLocation[1] = 0.0;
					currentEntLocation[2] = byUnitsFloat;
				}
				else{
					currentEntLocation[1] = 90.0;
					currentEntLocation[0] = -180.0; //fine
					currentEntLocation[2] = 120.0;
				}
			}
			case 2: 
			{ 
				if(iRot == 0 || iRot == 1){
					currentEntLocation[0] = 0.0;
					currentEntLocation[1] = 0.0;
					currentEntLocation[2] = byUnitsFloat*-1.0;
				}
				else{
					currentEntLocation[1] = 90.0;
					currentEntLocation[0] = -180.0; //fine
					currentEntLocation[2] = -120.0;
				}
			}
			case 9: 
			{ 
				CreateMainMenu(client);
				Dont = true
			}
		}
		if(!Dont)
			DrawSurfPanel(client);
		
		if(!(key == 8))
		{
			TeleportEntity(currentEnt[client], NULL_VECTOR, currentEntLocation, NULL_VECTOR);
			PrintToChat(client, "%.1f | %.1f | %.1f", currentEntLocation[0], currentEntLocation[1], currentEntLocation[2]);
		}
	}
}

DrawUnitMovePanel(iClient){
	new String:sInfo[64], String:sAxis[12];
	
	new Handle:hPanel = CreatePanel();
	SetPanelTitle(hPanel, "BM | Vectors menu\nPROG");
	FormatEx(sInfo, sizeof sInfo, "Level: %f\nAXIS", float(byUnits[iClient])/10);
	
	DrawPanelItem(hPanel, sInfo);
	
	for(new i = 0 ; i < 6 ; i++){
		FormatEx(sAxis, sizeof sAxis, "%c%c%s", i / 2 == 0 ? 88 : i/2==1 ? 89 : 90, i%2 ? '+' : '-', i==5? "\nSETTINGS" : "");
		DrawPanelItem(hPanel, sAxis); //ASCII KODY = 88-90	
	}
	FormatEx(sAxis, sizeof sAxis, "%s", !g_bRotationMode[iClient] ? "Mode: Position\n___________" : "Mode: Rotation\n___________");
	DrawPanelItem(hPanel, sAxis);
	DrawPanelItem(hPanel, "Exit");
	SendPanelToClient(hPanel, iClient, DrawUnitMovePanelHandler, 999);
	
	CloseHandle(hPanel);
}

public DrawUnitMovePanelHandler(Handle:hMenu, MenuAction:action, iClient, iKey){
	if(action == MenuAction_Select){
		if(!(IsValidEntity(currentEnt[iClient]) && IsValidEdict(currentEnt[iClient]))){
			return;
		}
		
		new Float:currentEntLocation[3];
		new Float:byUnitsFloat = float(byUnits[iClient]) / 10;
		switch(iKey) {
			case 1: {
				switch(byUnits[iClient]){
					case 1:{
						byUnits[iClient] = 5;
					}
					case 5:{
						byUnits[iClient] = 10;
					}
					case 10:{
						byUnits[iClient] = 80;
					}
					case 120:{
						byUnits[iClient] = 320;
					}
					case 330:{
						byUnits[iClient] = 640;
					}
					case 660: {
						byUnits[iClient] = 1;
					}
					default: {
						byUnits[iClient] = 1;
					}
				}
			}
			case 2,3,4,5,6,7: { 
				GetEntPropVector(currentEnt[iClient], Prop_Send, !g_bRotationMode[iClient] ? "m_vecOrigin" : "m_angRotation", currentEntLocation);
				
				new iAxis = iKey-2; // 0-5
				currentEntLocation[iAxis/2] = iAxis%2 ?  currentEntLocation[iAxis/2]-byUnitsFloat : currentEntLocation[iAxis/2]+byUnitsFloat;
			}
			case 8:{
				g_bRotationMode[iClient] = !g_bRotationMode[iClient];
			}
			case 9: { 
				CreateMainMenu(iClient);
			}
		}
		if(iKey!=9)
			DrawUnitMovePanel(iClient);
		
		if(iKey!=1&&iKey!=8&&iKey!=9){
			if(!g_bRotationMode[iClient])
			{
				TeleportEntity(currentEnt[iClient], currentEntLocation, NULL_VECTOR, NULL_VECTOR);
			}
			else
			{
				TeleportEntity(currentEnt[iClient], NULL_VECTOR, currentEntLocation, NULL_VECTOR);
			}
		}
	}
}

public Action:RoundStart(Handle:event, const String:name[], bool:dontBroadcast){
	g_iRespawn=0;
	
	for(new i=0;i<2048;++i){
		g_bLocked[i]=false;
		g_iBlocks[i]=-1;
		g_bTriggered[i]=false;
		g_iTeleporters[i]=-1;
	}
	for(new i=1;i<=MaxClients;++i)
	{
		g_iGravity[i]=0;
		g_iMozePokazac[i] = 1;
		g_bOnIce[i]=false;
		g_fLastHP[i] = GetGameTime();
		g_fLastSpeed[i] = GetGameTime();
		g_fLastTramp[i] = GetGameTime();
		g_fLastDamage[i] = GetGameTime();
		g_fLastChance[i] = GetGameTime();
		g_fLastDuck[i] = GetGameTime();

		for(new l = 0 ; l < 2048 ; l++){
			g_bDeagleCanUse[i][l] = true;
			g_bHEgrenadeCanUse[i][l] = true;
			g_bFlashbangCanUse[i][l] = true;
			g_bSmokegrenadeCanUse[i][l] = true;
			g_bXP[i][l] = true;
			g_bLP[i][l]=true;
			g_fChance[i][l] = 0.0;
		}
		
		g_fActChance[i] = 0.0;
		g_bChance[i] = false;
		g_iHoney[i] = 0;
		g_bHoney[i]=false;
		g_iCurrentTele[i]=-1;
		g_bBoots[i] = false;
		g_bStealth[i] = false;
		g_bKamuflaz[i]=false;
		
		if(IsClientInGame(i) && IsPlayerAlive(i)){
			SetEntityRenderMode(i, RENDER_NORMAL);
			SetEntityRenderFx(i, RENDERFX_NONE);
			SetEntityRenderColor(i, 255, 255, 255, 255);
		}
	}
	
	LoadBlocks();
}

public OnClientDisconnect(client){
	g_iOldButtons[client] = 0;
	SDKUnhook(client, SDKHook_PreThink, ClientPreThink);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamagePost);
}

public OnClientPutInServer(client){
	if(!IsFakeClient(client)){
		g_fDistance[client]=100.0;
		SDKHook(client, SDKHook_PreThink, ClientPreThink);
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamagePost);

		g_bKamuflaz[client]=false
		g_bStealth[client] = false;
		g_bInv[client]=false;
		g_bInvCanUse[client]=true;
		g_bStealthCanUse[client]=true;
		g_bBootsCanUse[client]=true;
		g_bDamage[client]=false;
		g_bHoney[client] =false;
		g_iHoney[client] = 0;
		
		g_bNoFallDmg[client]=false;
		g_bCamCanUse[client]=true;
		g_bBoots[client]=false;
		g_iTempAlpha[client] = 255;
		g_iTempKlr[client][0] = 255;
		g_iTempKlr[client][1] = 255;
		g_iTempKlr[client][2] = 255;
		g_iTempRuchomy[client] = 1;
		g_fTempRuch[client] = 2.0;
		g_iGravity[client]=0;
		g_iTempOs[client] = 1;
		g_iTempSize[client]=2;
		for(new i = 0 ; i < 2048 ; i++){
			g_bDeagleCanUse[client][i] = true;
			g_bHEgrenadeCanUse[client][i] = true;
			g_bFlashbangCanUse[client][i] = true;
			g_bSmokegrenadeCanUse[client][i] = true;
		}

		g_iCurrentTele[client]=-1;
		g_bSnapping[client] = true;
		g_fSnappingGap[client] = 0.0
	}
}

public OnMapStart(){	
	PrecacheSound("sound/hnsrussian/invincibility.mp3", true);
	PrecacheSound("sound/hnsrussian/stealth.mp3", true);
	PrecacheSound("sound/hnsrussian/camouflage.mp3", true);
	PrecacheSound("sound/hnsrussian/invincibility.mp3", true);
	PrecacheSound("sound/hnsrussian/exp.mp3", true);
	PrecacheSound("sound/hnsrussian/last.mp3", true);
	PrecacheSound("sound/hnsrussian/respawn.mp3", true);
	//AddFileToDownloadsTable(g_sFullClickSound);
	//FakePrecacheSound(g_sClickSound);
	for(new p = 0 ; p < 5 ; p++){
		new String:sS[64];
		FormatEx(sS, 64, "sound/hnsrussian/%s%d.mp3", p>2 ? "c" : "d", p>2 ? p-3 : p);
		PrecacheSound(sS, true);
		AddFileToDownloadsTable(sS);
	}

	new String:sSciezka[256];
	for(new b ; b < MAX_BLOCKS ; b++){
		for(new p = 0 ; p < 4 ; p++){
			FormatEx(g_sSciezkaModel[p][b], 256, "models/%s_%s/%s.mdl", g_sPodFolder, p == 0 ? "Pole" : p == 1 ? "Small" : p == 2 ? "Normal" : p == 3 ? "Large" : "xLarge", g_sNormalneKlocki[b]);
			
			PrecacheModel(g_sSciezkaModel[p][b]);
			
			for(new l ; l < MAX_RESOURCES ; l++){
				FormatEx(sSciezka, sizeof sSciezka, "%s/%s_%s/%s%s", l >= 4 ? "materials" : "models", g_sPodFolder, p == 0 ? "Pole" : p == 1 ? "Small" : p == 2 ? "Normal" : p == 3 ? "Large" : "xLarge", g_sNormalneKlocki[b], g_sRozszerzenia[l]);
				
				AddFileToDownloadsTable(sSciezka);
				
				if(p==2 && l>=4){
					FormatEx(sSciezka, sizeof sSciezka, "materials/%s_normal/%s_side%s", g_sPodFolder, g_sNormalneKlocki[b], g_sRozszerzenia[l]);
					
					AddFileToDownloadsTable(sSciezka);
				}
			}
		}
	}
	
	AddFileToDownloadsTable("materials/omnihns_Small/side.vtf");
	AddFileToDownloadsTable("materials/omnihns_Small/side.vmt");
	AddFileToDownloadsTable("materials/omnihns_Pole/side.vtf");
	AddFileToDownloadsTable("materials/omnihns_Pole/side.vmt");
	AddFileToDownloadsTable("materials/omnihns_Large/side.vtf");
	AddFileToDownloadsTable("materials/omnihns_Large/side.vmt");
	PrecacheModel("models/platforms/b-tele.mdl", true);
	PrecacheModel("models/platforms/r-tele.mdl", true);
	PrecacheModel("models/player/ctm_gign.mdl");
	PrecacheModel("models/player/tm_phoenix.mdl");
	
	FakePrecacheSound(INVI_SOUND_PATH);
	FakePrecacheSound(STEALTH_SOUND_PATH);
	FakePrecacheSound(NUKE_SOUND_PATH);
	FakePrecacheSound(BOS_SOUND_PATH);
	FakePrecacheSound(CAM_SOUND_PATH);
	FakePrecacheSound(XP_SOUND_PATH);
	FakePrecacheSound(RESPAWN_SOUND_PATH);
	FakePrecacheSound(LAST_SOUND_PATH);
	
	for(new i = 0 ; i < 2048 ; i++){ g_iRuchomy[i] = 0; g_bTeleport[i] = false; }
	
	for(new x = 0 ; x < 5 ; x++){
		FakePrecacheSound(g_sDamage[x]);
		
		new String:sPrec[128];
		FormatEx(sPrec, sizeof sPrec, "sound/%s", g_sDamage[x]);
		ReplaceString(sPrec, sizeof sPrec, "*", "", false);
		
		PrecacheSound(sPrec, true);
		
		AddFileToDownloadsTable(sPrec);
		
	}
	
	DownloadsTable()
	
	g_iBeamSprite = PrecacheModel("materials/sprites/orangelight1.vmt");
	
	for(new i=0;i<2048;++i)
	{
		g_iBlocks[i]=-1;
		g_iTeleporters[i]=-1;
		g_bTriggered[i]=false;
	}
	
	if(g_hBlocksKV != INVALID_HANDLE)
	{
		CloseHandle(g_hBlocksKV);
		g_hBlocksKV = INVALID_HANDLE;
	}
	
	new String:file[256];
	new String:map[64];
	//new String:id[64];
	//GetCurrentWorkshopMap(map, 65, id, 65)
	GetCurrentMap(map, sizeof(map));
	BuildPath(Path_SM, file, sizeof(file), "data/block.%s.txt", map);
	if(FileExists(file))
	{
		g_hBlocksKV = CreateKeyValues("Blocks");
		FileToKeyValues(g_hBlocksKV, file);
	}
}

DownloadsTable()
{
	//tele
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
	
	AddFileToDownloadsTable("sound/hnsrussian/bootsofspeed.mp3")
	AddFileToDownloadsTable("sound/hnsrussian/stealth.mp3")
	AddFileToDownloadsTable("sound/hnsrussian/camouflage.mp3")
	AddFileToDownloadsTable("sound/hnsrussian/invincibility.mp3")
	//AddFileToDownloadsTable("sound/hnsrussian/teleport.mp3")
	AddFileToDownloadsTable("sound/hnsrussian/exp.mp3");
	AddFileToDownloadsTable("sound/hnsrussian/last.mp3");
	AddFileToDownloadsTable("sound/hnsrussian/respawn.mp3");
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
				
				blocks++;
			}
			KvGoBack(g_hBlocksKV);
			index++;
		}
		KvRewind(g_hBlocksKV);
		new String:file[256];
		new String:map[64];

		GetCurrentMap(map, sizeof(map));
		BuildPath(Path_SM, file, sizeof(file), "data/block.%s.txt", map);
		KeyValuesToFile(g_hBlocksKV, file);
		
		if(msg){
			new String:sPomoz[64];
			FormatEx(sPomoz, sizeof sPomoz, " (DBX_copyFix: {olive}%d{orange} copies)", iPomoz);
			CPrintToChatAll("{blue}*{lime}[HNSBM %s]{orange} ?????????!{green} %d ??????{orange} & {red}%d ??????????{orange}%s", VERSION, blocks, teleporters, bPomoz ? sPomoz : "");
			
			if(bPomoz) 
				SaveBlocks(false);
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
			
			g_iAlpha[iEnt] = iAlpha == 0 ? 255 : iAlpha;
			
			ustawRender(iEnt);
			ustawRender(iEnt2);
			
			g_bTeleport[iEnt] = true;
			g_bTeleport[iEnt2] = true;
			
			g_iRuchomy[iEnt] = 1;
			g_iOs[iEnt] = 1;
			g_fRuch[iEnt] = 1.2;
			
			g_iRuchomy[iEnt2] = 1;
			g_iOs[iEnt2] = 1;
			g_fRuch[iEnt2] = 1.2;
			
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
			
			iEnt = CreateBlock(0, KvGetNum(g_hBlocksKV, "block_size"), blocktype, fPos, fAng);
			
			g_iOnTop[iEnt] = iOdGory;
			
			g_iAlpha[iEnt] = iAlpha == 0 ? 255 : iAlpha;
			
			g_iOnlyT[iEnt] = iTOnly;
			
			for(new l = 0 ; l < 3 ; l++){
				g_iKlr[iEnt][l] = iAlpha == 0 ? 255 : iKolor[l];
			}

			g_fProp[iEnt][0] = KvGetFloat(g_hBlocksKV, "czasprop1");
			g_fProp[iEnt][1] = KvGetFloat(g_hBlocksKV, "czasprop2");
			g_iRotation[iEnt] = KvGetNum(g_hBlocksKV, "rotation");
			
			ustawRender(iEnt);
			
			g_bTeleport[iEnt] = false;
			
			blocks++;
		}
	} while (KvGotoNextKey(g_hBlocksKV));
	
	SaveBlocks(false);
	
	if(msg)
		CPrintToChatAll("{blue}*{lime}[HNSB %s]{orange} ????? ??????????!", VERSION);
} 

new bool:g_bUsedE[MAXPLAYERS+1];
new Float:g_fLastClick[MAXPLAYERS+1];

OnButtonPress(iClient, iButton){
	if(iButton & IN_USE && IsPlayerAlive(iClient) && !g_bUsedE[iClient]){
		if(GetGameTime() - g_fLastClick[iClient] >= 0.5){
			g_fLastClick[iClient] = GetGameTime();
			/*new Float:vec[3];
			GetClientAbsOrigin(iClient, vec);
			vec[2] += 10;	
			EmitAmbientSound(g_sClickSound, vec, iClient, SNDLEVEL_NORMAL, SND_NOFLAGS, 0.7);*/
			g_bUsedE[iClient]=true;
		}
	}
}

OnButtonRelease(id, iButton){
	if(iButton & IN_DUCK){
			if(GetGameTime() - g_fLastDuck[id] >= 0.07){
				new Float:fVec[3];
				Entity_GetAbsVelocity(id, fVec);
					
				fVec[2] = 0.0;
					
				new Float:fSpeed = GetVectorLength(fVec);

				if(GetClientDistanceToGround(id) <= 50.0 && GetClientDistanceToGround(id) >= 10.0){
					
					if(fSpeed<380.0) return;
					
					new Float:fR = 1.051;
					
					fVec[0] *= fR;
					fVec[1] *= fR;
					fVec[2] = FloatAbs(fVec[2]) * 6.37;
					TeleportEntity(id, NULL_VECTOR, NULL_VECTOR, fVec);
				}
				
				g_fLastDuck[id] = GetGameTime();
			}
	}
	if(iButton & IN_USE){
		g_bUsedE[id]=false;

		new iEnt = GetClientAimTarget(id, false);
		if(IsValidBlock(iEnt)){
			g_iPropped[id] = iEnt;
			if(g_hProps[id] != INVALID_HANDLE){ 
				KillTimer(g_hProps[id]);
				g_hProps[id] = INVALID_HANDLE;
			}
			g_hProps[id] = CreateTimer(1.17, printProps, id);
			PrintHintText(id, "<font size='11' color='#ff9933'>Blockmaker<font size='10'><br><br><font size='22' color='#AAAAAA'>\t%s", g_sBlocks[g_iBlocks[iEnt]]);
			//PrintHintText(id, "<font color='#00AFFF'size='22'><b>Diablix BM</b> %s<br><font size='28'color='#AAAAAA'>%s", VERSION, g_sBlocks[g_iBlocks[iEnt]]);
		}
	}
}

stock createRGB(r, g, b)
{  
    return ((r & 0xff) << 16) + ((g & 0xff) << 8) + (b & 0xff);
}

public Action:printProps(Handle:hTimer, any:id){
	g_hProps[id] = INVALID_HANDLE;
	
	if(IsClientInGame(id) && IsPlayerAlive(id)){
		new iEnt = g_iPropped[id];
		
		if(IsValidBlock(iEnt)){
			new iProps=-1;
			new String:sOnTop[196], String:sOnlyT[128], String:sProp1[128], String:sProp2[128];
			new blocktype = g_iBlocks[iEnt];
			
			if(g_iOnlyTShow[blocktype]){
				FormatEx(sOnlyT, sizeof sOnlyT, "OnlyTT: %s<font color='#A8A8A8'>", g_iOnlyT[iEnt] ? "<font color='#00fa00'>Tak" : "<font color='#fa0000'>Nie");
				iProps++;
			}
			if(g_iOnTopShow[blocktype]){
				FormatEx(sOnTop, sizeof sOnTop, "%sOnlyTOP: %s<font color='#A8A8A8'>", strlen(sOnlyT) ? " | " : "", g_iOnTop[iEnt] ?  "<font color='#00fa00'>Tak" : "<font color='#fa0000'>Nie");
				
				if(iProps<0)
					iProps++;
			}
			if(!(StrContains(g_sTimeNazwa[blocktype], "None", false) != -1)){
				if(blocktype == 9){
					FormatEx(sProp1, sizeof sProp1, "%s: %s<font color='#A8A8A8'>", g_sTimeNazwa[blocktype], g_fProp[iEnt][0] >= 1.0 ? "<font color='#00fa00'>Tak" : "<font color='#fa0000'>Nie");
				}
				else if(blocktype == 22){
					new iOpt = RoundFloat(g_fProp[iEnt][0]);
		
					new String:sWeapon[64];
					FormatEx(sWeapon, sizeof sWeapon, g_sWeapons[iOpt]);
					ReplaceString(sWeapon, sizeof sWeapon, "weapon_", "");
					
					FormatEx(sProp1, sizeof sProp1, "%s:<font color='#ff9933'> %s<font color='#A8A8A8'>", g_sTimeNazwa[blocktype], sWeapon);
				}
				else{
					FormatEx(sProp1, sizeof sProp1, "%s:<font color='#ff9933'> %.1f<font color='#A8A8A8'>", g_sTimeNazwa[blocktype], g_fProp[iEnt][0]);
				}
				iProps++;
			}
			
			if(!(StrContains(g_sTime2Nazwa[blocktype], "None", false) != -1)){
				FormatEx(sProp2, sizeof sProp2, "%s:<font color='#ff9933'> %.1f<font color='#A8A8A8'>", g_sTime2Nazwa[blocktype], g_fProp[iEnt][1]);
				iProps++;
			}
/*			
20 - 3
13 - 2
6  - 1
*/
			if(iProps>=0)
				PrintHintText(id, "<font size='%d'color='#A8A8A8'>%s%s%s%s%s%s", iProps == 0 ? 32 : (32 - (iProps+1)*4), strlen(sProp1) ? sProp1 : "", strlen(sProp1) ? "\n" : "", strlen(sProp2) ? sProp2 : "", strlen(sProp2) ? "\n" : "", strlen(sOnlyT) ? sOnlyT : "", strlen(sOnTop) ? sOnTop : "");	
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

new Float:g_fOldVel[MAXPLAYERS+1][3];

doSnapping(ent, Float:fMoveTo[3]){
	new Float:vReturn[3];
	new Float:dist;
	new Float:distOld = 9999.9;
	new Float:vTraceStart[3];
	new Float:vTraceEnd[3];
		
	new trClosest = 0;
	new blockFace;

	new Float:fSizeMin[3];
	new Float:fSizeMax[3];
	
	/* xD
	* static const Float:fSizes[5] = {
		0.2,
		0.25,
		0.4,
		0.6,
		1.0
	};*/
	
	for(new x = 0 ; x < 3 ; x++){
		fSizeMin[x] = g_iRotation[ent] == 2 ? g_fBlockSizes3[g_iBlockSize[ent]][0][x] : g_iRotation[ent] == 1 ? g_fBlockSizes2[g_iBlockSize[ent]][0][x] : g_fBlockSizes[g_iBlockSize[ent]][0][x];
		fSizeMax[x] = g_iRotation[ent] == 2 ? g_fBlockSizes3[g_iBlockSize[ent]][1][x] : g_iRotation[ent] == 1 ? g_fBlockSizes2[g_iBlockSize[ent]][1][x] : g_fBlockSizes[g_iBlockSize[ent]][1][x];
	}
	new Float:fVec[3];
	for (new i = 0; i < 6; ++i){
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
		
		//TE_SetupGlowSprite(fVec, g_iBlueGlowSprite, 0.3, fSizes[g_iBlockSize[ent]], 32);
		//TE_SendToAll();
		
		g_hRender[trClosest] = CreateTimer(0.01, trRender, trClosest);
		
		new Float:vOrigin[3];
		GetEntPropVector(trClosest, Prop_Data, "m_vecOrigin", vOrigin);

		new Float:fTrSizeMin[3];
		new Float:fTrSizeMax[3];
		
		for(new x = 0 ; x < 3 ; x++){
			fTrSizeMin[x] = g_iRotation[trClosest] == 2 ? g_fBlockSizes3[g_iBlockSize[trClosest]][0][x] : g_iRotation[trClosest] == 1 ? g_fBlockSizes2[g_iBlockSize[trClosest]][0][x] : g_fBlockSizes[g_iBlockSize[trClosest]][0][x];
			fTrSizeMax[x] = g_iRotation[trClosest] == 2 ? g_fBlockSizes3[g_iBlockSize[trClosest]][1][x] : g_iRotation[trClosest] == 1 ? g_fBlockSizes2[g_iBlockSize[trClosest]][1][x] : g_fBlockSizes[g_iBlockSize[trClosest]][1][x];
		}

		fMoveTo = vOrigin;

		if (blockFace == 0) fMoveTo[0] += (fTrSizeMax[0] + fSizeMax[0]) - 0.5;
		if (blockFace == 1) fMoveTo[0] += (fTrSizeMin[0] + fSizeMin[0]) + 0.5;
		if (blockFace == 2) fMoveTo[1] += (fTrSizeMax[1] + fSizeMax[1]) - 0.5;
		if (blockFace == 3) fMoveTo[1] += (fTrSizeMin[1] + fSizeMin[1]) + 0.5;
		if (blockFace == 4) fMoveTo[2] += (fTrSizeMax[2] + fSizeMax[2]) - 0.5;
		if (blockFace == 5) fMoveTo[2] += (fTrSizeMin[2] + fSizeMin[2]) + 0.5;
	}
}

public Action:trRender(Handle:hTimer, any:iEnt){
	g_hRender[iEnt] = INVALID_HANDLE;
	
	if(IsValidBlock(iEnt))
		ustawRender(iEnt);
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon){
	if(g_iDragEnt[client]){
		if (buttons & IN_ATTACK){
			if(g_fDistance[client] <= 800.0) g_fDistance[client] +=1.0;
		}
		else if(buttons & IN_ATTACK2){
			if(g_fDistance[client] >= 72.0) g_fDistance[client] -=1.0;
		}
		
		if(IsValidEdict(g_iDragEnt[client])){
			MoveBlock(client);
		}
	}
	for (new i = 0; i < 25 ; i++){
		new button = (1 << i);
		
		if ((buttons & button)){
			if (!(g_iOldButtons[client] & button)){
				OnButtonPress(client, button);
			}
		}
		else if ((g_iOldButtons[client] & button)){
			OnButtonRelease(client, button);
		}
	}
	
	g_iOldButtons[client] = buttons;
	
	if(IsPlayerAlive(client)){
		if(g_iGravity[client] && GetEntityFlags(client) & FL_ONGROUND){
			new ground = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity"); 
			
			if(!(IsValidBlock(ground) && g_iBlocks[ground] == 23)){
				g_iGravity[client]=0;
				SetEntityGravity(client, 1.0);
			}
		}
		if(g_bHoney[client] && GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") != 0.3){
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_fProp[g_iHoney[client]][0]);
		}
		else if(g_bBoots[client] && GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue") != 2.0){
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 2.0);
		}
	
		for(new a=MaxClients+1;a<2048;++a){
			if(GetClientTeam(client)<2)
				continue;
			
			if(IsValidBlock(a)){
				new Float:fPos[3];
				new Float:fPos2[3];
				GetClientAbsOrigin(client, fPos);
				fPos[2]+=50.0;
				
				if(g_iBlocks[a]==19 || g_iBlocks[a] == 5 || g_iBlocks[a] == 6){
					GetEntPropVector(a, Prop_Data, "m_vecOrigin", fPos2);
					if(GetVectorDistance(fPos, fPos2)<=100.0){
						if(!g_bNoFallDmg[client])
							CreateTimer(0.2, ResetNoFall, client);
						g_bNoFallDmg[client]=true;
					}
				} else if(g_iTeleporters[a]>1 && 2<=GetClientTeam(client)<=3){
					GetEntPropVector(a, Prop_Data, "m_vecOrigin", fPos2);
					if(IsValidBlock(g_iTeleporters[a])){
						if(fPos[0] - 36.0 < fPos2[0] < fPos[0] + 36.0 && fPos[1] - 36.0 < fPos2[1] < fPos[1] + 36.0 && fPos[2] - 72.0 < fPos2[2] < fPos[2] + 72.0 && !(fPos[0] - 32.0 < fPos2[0] < fPos[0] + 32.0 && fPos[1] - 32.0 < fPos2[1] < fPos[1] + 32.0 && fPos[2] - 64.0 < fPos2[2] < fPos[2] + 64.0)){
							GetEntPropVector(client, Prop_Data, "m_vecVelocity", g_fOldVel[client]);
							g_fOldVel[client][2] = g_fOldVel[client][2]>0.0 ? g_fOldVel[client][2] : g_fOldVel[client][2]*-1.0;
						}
						else if(fPos[0] - 32.0 < fPos2[0] < fPos[0] + 32.0 && fPos[1] - 32.0 < fPos2[1] < fPos[1] + 32.0 && fPos[2] - 64.0 < fPos2[2] < fPos[2] + 64.0){
							GetEntPropVector(g_iTeleporters[a], Prop_Data, "m_vecOrigin", fPos2);
							TeleportEntity(client, fPos2, NULL_VECTOR, NULL_VECTOR);
							/*new Float:vec[3];
							GetClientAbsOrigin(client, vec);
							vec[2] += 10;
							EmitAmbientSound(TELE_SOUND_PATH, vec, client, SNDLEVEL_RAIDSIREN);	*/
							
							TeleportEntity(client,NULL_VECTOR, NULL_VECTOR, g_fOldVel[client]);
						}
					}
				}
			}
		}
	}
	
	return Plugin_Continue;
}

public OnGameFrame(){
	for(new e = (MaxClients+1) ; e < 1600 ; e ++){
		if(IsValidEdict(e) && g_iBlocks[e]<=0){
			new Float:fPos[3];
			new Float:fPos2[3];

			if(!g_bLocked[e]){
				new String:sClass[64];
				GetEntityClassname(e, sClass, sizeof sClass);
				
				if(StrContains(sClass, "grenade") != -1 || StrContains(sClass, "flash") != -1){
					for(new x = (MaxClients+1) ; x < 2048 ; x ++){
						if(g_iBlocks[x] == 10){
							GetEntPropVector(x, Prop_Data, "m_vecOrigin", fPos2);

							if(fPos[0] - 30.0 < fPos2[0] < fPos[0] + 30.0 && fPos[1] - 30.0 < fPos2[1] < fPos[1] + 30.0 && fPos[2] - 80.0 < fPos2[2] < fPos[2] + 80.0){
								g_bLocked[e]=true;
								new Float:fVelocity[3];
								GetEntPropVector(e, Prop_Data, "m_vecVelocity", fVelocity); 
								ScaleVector(fVelocity, (g_fProp[x][0] * -1.0));
								fVelocity[2] = 0.0;

								TeleportEntity(e, NULL_VECTOR, NULL_VECTOR, fVelocity);
								CreateTimer(0.1, ResetLock, e);
							}
						}
					}
				}
			}
		}
		if(IsValidBlock(e) && g_bTeleport[e]){
			new Float:fVec[3];
			GetEntPropVector(e, Prop_Data, "m_angRotation", fVec);  

			fVec[g_iOs[e]] += g_fRuch[e];
					
			TeleportEntity(e, NULL_VECTOR, fVec, NULL_VECTOR);
		}
	}
}

public Action:ResetLock(Handle:timer, any:client){	
	g_bLocked[client]=false;
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	if(entity == data)
		return false;
	return true;
}

public Action:Command_BlockBuilder(client, args){	
	if((GetUserFlagBits(client) & ADMFLAG_GENERIC || GetUserFlagBits(client) & ADMFLAG_ROOT)){
		for(new i=MaxClients+1;i<2048;++i){
			if(!IsValidEntity(i) || !IsValidBlock(i) || g_iTeleporters[i]==1)
				continue;
				
			if(g_iBlocks[i] == 5 || g_iBlocks[i] == 6){
				if(g_fProp[i][0] < 260.0){
					g_fProp[i][0] = 260.0;
				}
			}
		}
		
		new Handle:menu = CreateMainMenu(client);
		
		DisplayMenu(menu, client, 30); 
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:cmdUngrab(client, args){
	ustawRender(g_iDragEnt[client]);
	g_iDragEnt[client] = 0;
	
	return Plugin_Handled;
}

public Action:cmdGrab(client, args){
	if(g_iDragEnt[client] == 0){
		new ent = GetClientAimTarget(client, false);
		
		if(IsValidBlock(ent)){
			new Float:fOrg[2][3];
			setGrabbed(client, ent);
			
			Entity_GetAbsOrigin(ent, fOrg[0]);
			GetClientEyePosition(client,  fOrg[1]);
			
			for(new i = 0 ; i < 3 ; i++)
				fOrg[0][i] -= g_fGrabOffset[client][i];
			
			g_fDistance[client]=GetVectorDistance(fOrg[0], fOrg[1]);
			
			g_iDragEnt[client] = ent;
			
			g_iTempColor[ent] = GetRandomInt(0, 5);
			
			SetEntityRenderColor(ent, g_iRandomColor[g_iTempColor[ent]][0], g_iRandomColor[g_iTempColor[ent]][1], g_iRandomColor[g_iTempColor[ent]][2], g_iRandomColor[g_iTempColor[ent]][3]);
		}
	}
	return Plugin_Handled;
}

public Action:MenuAccess(client, args){
	new Handle:menu = CreateMenu(MenuHandlerAccess);
	
	SetMenuTitle(menu, "[BM] ???? ?????? ? BM");
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
		AddMenuItem(menu, "#no", "??? ?????? ????? ??????");
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
			CPrintToChatAll("{blue}*{lime}[HNSB %s]{orange} Choose a valid player", VERSION);
		}
		else{
			new String:tgtname[64];
			GetClientName(target, tgtname, 64);
			AddUserFlags(target, Admin_Generic);
			CPrintToChatAll("{blue}*{lime}[HNSB %s]{orange} %s has been added as a temp. builder!", VERSION, tgtname);
		}
		MenuAccess(param1, 0);
	}  
	if ((action == MenuAction_Cancel))
		DisplayMenu(CreateMainMenu(param1), param1, 0);
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
		
	if(g_bSnapping[client]) doSnapping(g_iDragEnt[client], final);
		
	TeleportEntity(g_iDragEnt[client], final, NULL_VECTOR, NULL_VECTOR);
}

stock AddInFrontOf(client, Float:vecOrigin[3], Float:vecAngle[3], Float:units, Float:output[3]){
	new Float:vecAngVectors[3];
	vecAngVectors = vecAngle;
	GetAngleVectors(vecAngVectors, vecAngVectors, NULL_VECTOR, NULL_VECTOR);
	for (new i; i < 3; i++)
	output[i] += vecOrigin[i] + g_fGrabOffset[client][i] + (vecAngVectors[i] * units);
}


stock policzBlocki(){
	new iB=0;
	for(new i=0;i<2048;++i){
		if(IsValidBlock(i)){
			iB++;
		}
	}
	return iB;
}

public Handler_BlockBuilder(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		
		new bool:bDisplayMenu = true;
		if(param2==0)
		{
			bDisplayMenu = false;
			DisplayMenu(CreateBlocksMenu(), client, 0); 
		} else if(param2==1)
		{
			CreateBlock(client, g_iTempSize[client]);
		} else if(param2==2)
		{
			new ent = GetClientAimTarget(client, false);
			if(IsValidBlock(ent))
			{
				if(g_iBlockSize[ent]==0){
					new Float:vAng[3];
					GetEntPropVector(ent, Prop_Data, "m_angRotation", vAng);
					
					//PrintToChatAll("%.1f | %.1f | %.1f", vAng[0], vAng[1], vAng[2]);
					
					if(!vAng[0] && !vAng[1] && !vAng[2]){
						vAng[1] = 90.0;
						g_iRotation[ent]=1;
					}
					else if(!vAng[0] && vAng[1] == 90.0 && !vAng[2]){
						vAng[2] = 90.0;
						g_iRotation[ent]=2;
					}
					else{
						vAng[0] = 0.0;
						vAng[1] = 0.0;
						vAng[2] = 0.0;
						g_iRotation[ent]=0;
					}
					
					g_fAngles[ent] = vAng;
					
					TeleportEntity(ent, NULL_VECTOR, vAng, NULL_VECTOR);
					
				}
				else{
					new Float:vAng[3];
					GetEntPropVector(ent, Prop_Data, "m_angRotation", vAng);
					
					if (vAng[1])
					{
						g_iRotation[ent]=0;
						vAng[0] = 0.0;
						vAng[1] = 0.0;
						vAng[2] = 0.0;
					}
					else if (vAng[2]){
						g_iRotation[ent]=2;
						vAng[1] = 90.0;
						vAng[0] = -90.0;
					}
					else{
						g_iRotation[ent]=1;
						vAng[2] = 90.0;
						vAng[0] = -90.0;
					}
					
					g_fAngles[ent] = vAng;
					
					TeleportEntity(ent, NULL_VECTOR, vAng, NULL_VECTOR);
				}
			}
			else
			{
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Aim on the block first!", VERSION);
			}
		} else if(param2==3)
		{
			new ent = GetClientAimTarget(client, false);
			if(IsValidBlock(ent))
			{
				AcceptEntityInput(ent, "Kill");
				g_iBlocks[ent]=-1;
				g_iRuchomy[ent] = 0;
				g_iOs[ent] = 0;
				g_fRuch[ent] = 0.0;
				if(g_iTeleporters[ent]>=1)
				{
					if(g_iTeleporters[ent]>1 && IsValidBlock(g_iTeleporters[ent]))
					{
						AcceptEntityInput(g_iTeleporters[ent], "Kill");
						g_iTeleporters[g_iTeleporters[ent]] = -1;
					} else if(g_iTeleporters[ent]==1)
					{
						for(new i=MaxClients+1;i<2048;++i)
						{
							if(g_iTeleporters[i]==ent)
							{
								if(IsValidBlock(i))
									AcceptEntityInput(i, "Kill");
								g_iTeleporters[i] = -1;
								break;
							}
						}
					}
					
					g_iTeleporters[ent]=-1;
				}
			}
			else
			{
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Aim on the block first!", VERSION);
			}
		} else if(param2==4)
		{
			g_iTempSize[client] = g_iTempSize[client] == 3 ? 0 : g_iTempSize[client]+1;
		} else if(param2==5)
		{
			if(GetEntityMoveType(client) != MOVETYPE_NOCLIP)
			{
				SetEntityMoveType(client, MOVETYPE_NOCLIP);
			}
			else
			{
				SetEntityMoveType(client, MOVETYPE_ISOMETRIC);
			}
		} else if(param2==6)
		{
			if(GetEntProp(client, Prop_Data, "m_takedamage", 1) == 2)
			{
				SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
			}
			else
			{
				SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			}
		} 
		else if(param2==7)
		{
			new ent = GetClientAimTarget(client, false);
			if(IsValidBlock(ent) && g_iTeleporters[ent]==-1)
			{
				if(g_iBlockSelection[client]==g_iBlocks[ent] && g_iTempSize[client] == g_iBlockSize[ent])
				{
					CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Are you high? Target blocktype is the same!", VERSION);
				}
				else
				{
					g_iBlocks[ent]=g_iBlockSelection[client];
					
					g_fProp[ent][0] = g_fTimeDef[g_iBlocks[ent]];
					g_fProp[ent][1] = g_fTime2Def[g_iBlocks[ent]];
					g_iOnTop[ent] = g_iOnTopDef[g_iBlocks[ent]];
					g_iOnlyT[ent] = g_iOnlyTDef[g_iBlocks[ent]];
					g_iBlockSize[ent] = g_iTempSize[client];
					
					DispatchKeyValue(ent, "model", g_sSciezkaModel[g_iBlockSize[ent]][g_iBlocks[ent]]);
					SetEntityModel(ent,  g_sSciezkaModel[g_iBlockSize[ent]][g_iBlocks[ent]]);
				}
			}
			else
			{
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Aim on the block first!", VERSION);
			}
		} 
		else if(param2==8){
			bDisplayMenu=false;
			DisplayMenu(CreateTeleportMenu(client), client, 0);
		}
		else if(param2==9){
			bDisplayMenu=false;
			DisplayMenu(CreateWlasciwosciMenu(client), client, 0);
		}
		else if(param2==10)
		{
			new ent = GetClientAimTarget(client, false);
			if(IsValidBlock(ent))
			{
				g_iTempKlocek[client] = ent;
				
				bDisplayMenu=false;
				DisplayMenu(CreatePropMenu(client), client, 0); 
			}
			else
			{
				bDisplayMenu=false;
				DisplayMenu(CreateMainMenu(client), client, 0); 
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Aim on the block first!", VERSION);
			}
		}
		else if(param2==11)
		{
			bDisplayMenu=false;
			DisplayMenu(CreateOptionsMenu(client), client, 0);
		}
		if(bDisplayMenu)
			DisplayMenu(CreateMainMenu(client), client, 0); 
	}
}

public Handle:CreateTeleportMenu(client)
{
	new Handle:menu = CreateMenu(Handler_Teleport);
	SetMenuTitle(menu, "BM | Teleport Menu");
	if(g_iCurrentTele[client]==-1)
		AddMenuItem(menu, "0", "Create entrance");
	else
	AddMenuItem(menu, "0", "Undo");
	AddMenuItem(menu, "1", "Create destination");
	AddMenuItem(menu, "2", "Swap entrance/destination");
	AddMenuItem(menu, "3", "Delete teleport");
	AddMenuItem(menu, "4", "Show path");
	SetMenuExitBackButton(menu, true);
	return menu;
}

public Handle:CreateBlocksMenu()
{
	new Handle:menu = CreateMenu(Handler_Blocks);
	new String:szItem[4];
	SetMenuTitle(menu, "BM | Blocks");
	for (new i; i < MAX_BLOCKS; i++)
	{
		IntToString(i, szItem, sizeof(szItem));
		AddMenuItem(menu, szItem, g_sBlocks[i]);
	}
	SetMenuExitBackButton(menu, true);
	return menu;
}

public Handle:CreateMainMenu(client)
{
	new Handle:menu = CreateMenu(Handler_BlockBuilder);
	
	SetMenuTitle(menu, "BM | Main Menu\n");
	
	new String:sInfo[128], String:sSize[128], String:sNoClip[64], String:sGod[64];
	FormatEx(sInfo, sizeof sInfo, "Blocktype: %s", g_sBlocks[g_iBlockSelection[client]]);
	FormatEx(sSize, sizeof sSize, "Block size: %s", g_iTempSize[client] == 0 ? "Pole" : g_iTempSize[client] == 1 ? "Small" : g_iTempSize[client] == 2 ? "Normal" : g_iTempSize[client] == 3 ? "Large" : g_iTempSize[client] == 2 ?"xLarge");
	FormatEx(sNoClip, sizeof sNoClip, "Noclip: %s", GetEntityMoveType(client) != MOVETYPE_NOCLIP ? "[  ]" : "[X]");
	FormatEx(sGod, sizeof sGod, "Godmode: %s", GetEntProp(client, Prop_Data, "m_takedamage", 1) == 2 ? "[  ]" : "[X]");
	
	AddMenuItem(menu, "0", sInfo);
	AddMenuItem(menu, "1", "Create block");
	AddMenuItem(menu, "2", "Rotate block");
	AddMenuItem(menu, "3", "Delete block");
	AddMenuItem(menu, "4", sSize);
	AddMenuItem(menu, "5", sNoClip);
	AddMenuItem(menu, "6", sGod);
	AddMenuItem(menu, "7", "Convert block");
	AddMenuItem(menu, "8", "Teleport menu");
	AddMenuItem(menu, "9", "Rendering menu\n");
	AddMenuItem(menu, "10", "Properties menu");
	AddMenuItem(menu, "11", "Advanced options");
	AddMenuItem(menu, "12", "Moving blocks");
	
	SetMenuExitButton(menu, true);
	g_hClientMenu[client] = menu;
	return menu;
}

public Action:Command_UnitEdit(client, args)
{
	new Float:vecAngles[3], Float:vecOrigin[3];
	GetClientEyePosition(client, vecOrigin);
	GetClientEyeAngles(client, vecAngles);
	
	new entity = GetClientAimTarget(client, false);
	if(IsValidBlock(entity))
	{
		
		g_iTempKlocek[client] = entity;
				
		DisplayMenu(CreatePropMenu(client), client, 0); 
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Handle:CreatePropMenu(client)
{
	new Handle:menu = CreateMenu(Handler_Prop);
	SetMenuTitle(menu, "BM | Properties Menu");
	new iEnt = g_iTempKlocek[client];
	new blocktype = g_iBlocks[iEnt];

	if(g_iOnTopShow[blocktype]){
		if(g_iOnTop[iEnt]){
			AddMenuItem(menu, "0", "On Top Only: [X]");
		}
		else{
			AddMenuItem(menu, "0", "On Top Only: [  ]");
		}
	}
	else{
		AddMenuItem(menu, "0", "None");
	}
	
	if(g_iOnlyTShow[blocktype]){
		if(g_iOnlyT[iEnt]){
			AddMenuItem(menu, "1", "Only TT: [X]");
		}
		else{
			AddMenuItem(menu, "1", "Only TT: [  ]\n\n");
		}
	}
	else{
		AddMenuItem(menu, "1", "None");
	}
	
	if(blocktype == 22){
		new String:sProp[128];
		new iOpt = RoundFloat(g_fProp[iEnt][0]);
		
		new String:sWeapon[64];
		FormatEx(sWeapon, sizeof sWeapon, g_sWeapons[iOpt]);
		ReplaceString(sWeapon, sizeof sWeapon, "weapon_", "");
		
		FormatEx(sProp, sizeof sProp, "%s: %s", g_sTimeNazwa[blocktype], sWeapon);
		
		AddMenuItem(menu, "2", sProp);
	}
	else{
		if(!(StrContains(g_sTimeNazwa[blocktype], "None", false) != -1)){
			new String:sProp[64];
			if(blocktype == 9){
				FormatEx(sProp, sizeof sProp, "%s: %s", g_sTimeNazwa[blocktype], g_fProp[iEnt][0] >= 1.0 ? "[X]" : "[  ]");
			}
			else{
				FormatEx(sProp, sizeof sProp, "%s: %.2f", g_sTimeNazwa[blocktype], g_fProp[iEnt][0]);
			}
			AddMenuItem(menu, "2", sProp);
		}
		else{
			AddMenuItem(menu, "2", "None");
		}
	}
	
	if(!(StrContains(g_sTime2Nazwa[blocktype], "None", false) != -1)){
		new String:sProp[64];
		FormatEx(sProp, sizeof sProp, "%s: %.2f", g_sTime2Nazwa[blocktype], g_fProp[iEnt][1]);
			
		AddMenuItem(menu, "2", sProp);
	}
	else{
		AddMenuItem(menu, "2", "None");
	}
	
	SetMenuExitBackButton(menu, true);
	return menu;
}

public Handler_Prop(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		new iEnt = g_iTempKlocek[client];
		new blocktype = g_iBlocks[iEnt];
		
		if(IsValidBlock(iEnt)){
			if(param2 == 0 && g_iOnTopShow[blocktype])
			{
				g_iOnTop[iEnt] = g_iOnTop[iEnt] ? 0 : 1;
			}
			if(param2 == 1 && g_iOnlyTShow[blocktype])
			{
				g_iOnlyT[iEnt] = g_iOnlyT[iEnt] ? 0 : 1;
			}
			if(param2 == 2 && !(StrContains(g_sTimeNazwa[blocktype], "None", false) != -1)){
				if(blocktype == 22){
					WeaponsMenu(client, 0);
					return;
				}
				else{
					g_fProp[iEnt][0] = (g_fProp[iEnt][0] >= g_fTimeMax[blocktype]) ? g_fTimeMin[blocktype] : (g_fProp[iEnt][0] + g_fTimeStopa[blocktype]);
				}
			}
			if(param2 == 3 && !(StrContains(g_sTime2Nazwa[blocktype], "None", false) != -1))
			{
				g_fProp[iEnt][1] = (g_fProp[iEnt][1] >= g_fTime2Max[blocktype]) ? g_fTime2Min[blocktype] : (g_fProp[iEnt][1] + g_fTime2Stopa[blocktype]);
			}
		}
		else{
			DisplayMenu(CreateMainMenu(client), client, 0);
		}
		
		DisplayMenu(CreatePropMenu(client), client, 0);
	}
	else if ((action == MenuAction_Cancel) && (param2 == MenuCancel_ExitBack))
		DisplayMenu(CreateMainMenu(client), client, 0);
}

public Handle:CreateRuchMenu(client)
{
	new Handle:menu = CreateMenu(Handler_Ruch);
	SetMenuTitle(menu, "BM | Moving blocks");
	
	new String:sWl[3][128];
	FormatEx(sWl[0], sizeof sWl[], "Toggled: %s", g_iTempRuchomy[client] ? "[X]" : "[  ]");
	FormatEx(sWl[1], sizeof sWl[], "Axis: %s", !g_iTempOs[client] ? "X" : (g_iTempOs[client] == 1 ? "Y" : "Z"));
	FormatEx(sWl[2], sizeof sWl[], "Speed: %.1f", g_fTempRuch[client]);
	
	AddMenuItem(menu, "1", sWl[0]);
	AddMenuItem(menu, "2", sWl[1]);
	AddMenuItem(menu, "3", sWl[2]);
	AddMenuItem(menu, "4", "Apply");
	
	SetMenuExitBackButton(menu, true);
	return menu;
}

public Handler_Ruch(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 0)
		{
			g_iTempRuchomy[client] = g_iTempRuchomy[client] ? 0 : 1;
		}
		if(param2 == 1)
		{
			g_iTempOs[client] = g_iTempOs[client] >= 2 ? 0 : g_iTempOs[client] + 1;
		}
		if(param2 == 2)
		{
			g_fTempRuch[client] = g_fTempRuch[client] >= 2.0 ? 0.1 : g_fTempRuch[client] + 0.1;
		}
		if(param2==3){
			new iEnt = GetClientAimTarget(client, false);
			if(IsValidBlock(iEnt))
			{
				g_iRuchomy[iEnt] = g_iTempRuchomy[client];
				g_iOs[iEnt] = g_iTempOs[client];
				g_fRuch[iEnt] = g_fTempRuch[client];

				SetEntProp(iEnt, Prop_Send, "m_usSolidFlags", 152);
				//SetEntProp(iEnt, Prop_Send, "m_CollisionGroup", 11);
				
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Success!", VERSION);
			}
			else
			{
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Aim on the block first!", VERSION);
			}
		}
		
		DisplayMenu(CreateRuchMenu(client), client, 0);
	}
	else if ((action == MenuAction_Cancel) && (param2 == MenuCancel_ExitBack))
		DisplayMenu(CreateMainMenu(client), client, 0);
}

public Handle:CreateWlasciwosciMenu(client)
{
	new Handle:menu = CreateMenu(Handler_Wlasciwosci);
	SetMenuTitle(menu, "BM | Properties Menu");
	
	new String:sAlpha[30], String:sKlr[3][30];
	FormatEx(sAlpha, sizeof sAlpha, "Alpha: %d", g_iTempAlpha[client]);
	FormatEx(sKlr[0], sizeof sKlr[], "Red: %d", g_iTempKlr[client][0]);
	FormatEx(sKlr[1], sizeof sKlr[], "Green: %d", g_iTempKlr[client][1]);
	FormatEx(sKlr[2], sizeof sKlr[], "Blue: %d\n", g_iTempKlr[client][2]);
	/*if(g_iOnTop[g_iTempKlocek[client]]){
		AddMenuItem(menu, "0", "Tylko od gory: Tak");
	}
	else{
		AddMenuItem(menu, "0", "Tylko od gory: Nie");
	}*/
	AddMenuItem(menu, "0", sAlpha);
	
	AddMenuItem(menu, "1", sKlr[0]);
	AddMenuItem(menu, "2", sKlr[1]);
	AddMenuItem(menu, "3", sKlr[2]);
	AddMenuItem(menu, "4", "Reset");
	AddMenuItem(menu, "5", "Apply");
	
	SetMenuExitBackButton(menu, true);
	return menu;
}

public Handler_Wlasciwosci(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 0)
		{
			g_iTempAlpha[client] = g_iTempAlpha[client] >= 255 ? 0 : g_iTempAlpha[client] + 51;
			//g_iOnTop[iEnt] = g_iOnTop[iEnt] ? 0 : 1;
		}
		if(param2 == 1 || param2 == 2 || param2 == 3){
			g_iTempKlr[client][param2-1] = g_iTempKlr[client][param2-1] >= 255 ? 0 : g_iTempKlr[client][param2-1] + 15;
		}
		if(param2 == 4){
			g_iTempAlpha[client] = 255;
			g_iTempKlr[client][0] = 255;
			g_iTempKlr[client][1] = 255;
			g_iTempKlr[client][2] = 255;
		}
		if(param2 == 4){
			
			g_iTempAlpha[client] = 255;
			g_iTempKlr[client][0] = 255;
			g_iTempKlr[client][1] = 255;
			g_iTempKlr[client][2] = 255;
		}
		if(param2==5){
			new iEnt = GetClientAimTarget(client, false);
			if(IsValidBlock(iEnt))
			{
				for(new i = 0 ; i < 3 ; i++)
					g_iKlr[iEnt][i] = g_iTempKlr[client][i];
				
				g_iAlpha[iEnt] = g_iTempAlpha[client];
				
				ustawRender(iEnt);
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Render set!", VERSION);
			}
			else
			{
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Aim on the block first!", VERSION);
			}
		}
		
		DisplayMenu(CreateWlasciwosciMenu(client), client, 0);
	}
	else if ((action == MenuAction_Cancel) && (param2 == MenuCancel_ExitBack))
		DisplayMenu(CreateMainMenu(client), client, 0);
}

public Handle:CreateOptionsMenu(client)
{
	new Handle:menu = CreateMenu(Handler_Options);
	SetMenuTitle(menu, "BM | Options Menu");
	
	if(g_bSnapping[client])
		AddMenuItem(menu, "0", "Snapping: [X]\n\n");
	else
	AddMenuItem(menu, "0", "Snapping: [  ]\n\n");
	
	AddMenuItem(menu, "1", "Save data\n");
	AddMenuItem(menu, "2", "Give access to BM\n");
	AddMenuItem(menu, "3", "Delete all blocks");
	AddMenuItem(menu, "4", "Delete all teleports\n");
	if(g_bAutoSave)
		AddMenuItem(menu, "5", "Autosave every 5 mins [X]");
	else
		AddMenuItem(menu, "5", "Autosave every 5 mins [  ]");
	SetMenuExitBackButton(menu, true);
	return menu;
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
		SetEntProp(ent, Prop_Data, "m_CollisionGroup", 2);
		
		g_iTeleporters[ent]=1;
		g_iCurrentTele[client]=ent;
		
		g_iRuchomy[ent] = 1;
		g_iOs[ent] = 1;
		g_fRuch[ent] = 1.2;

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
	TeleportEntity(ent, vecPos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(ent);
	
	SetEntityMoveType(ent, MOVETYPE_NONE);
	AcceptEntityInput(ent, "disablemotion");
	SetEntProp(ent, Prop_Data, "m_CollisionGroup", 2);
	
	g_iTeleporters[ent]=1;
	
	for(new i = 0 ; i < 3 ; i++)
		g_iKlr[ent][i] = 255;

	g_iAlpha[ent] = 255;
	
	g_iRuchomy[ent] = 1;
	g_iOs[ent] = 1;
	g_fRuch[ent] = 1.2;

	SetEntProp(ent, Prop_Send, "m_usSolidFlags", 152);
	
	return ent;
}

CreateBlock(client, iBlockSize, blocktype=0, Float:fPos[3]={0.0, 0.0, 0.0}, Float:fAng[3]={0.0, 0.0, 0.0})
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
	
	new block_entity = CreateEntityByName("prop_physics_override");
	
	DispatchKeyValue(block_entity, "model", g_sSciezkaModel[iBlockSize][(client>0?g_iBlockSelection[client]:blocktype)]);
	
	TeleportEntity(block_entity, vecPos, fAng, NULL_VECTOR);
	DispatchSpawn(block_entity);
	
	SetEntityMoveType(block_entity, MOVETYPE_NONE);
	AcceptEntityInput(block_entity, "disablemotion");
	
	g_iAlpha[block_entity]=255;
	
	if((client>0?g_iBlockSelection[client]:blocktype) == 10)
	{
		SetEntProp(block_entity, Prop_Data, "m_CollisionGroup", 2);
		g_iAlpha[block_entity] = 96;
	}
	
	if(14 <= (client>0?g_iBlockSelection[client]:blocktype) <= 15)
	{
		SetEntProp(block_entity, Prop_Data, "m_CollisionGroup", 2);
	}
	
	g_iBlocks[block_entity]=(client>0?g_iBlockSelection[client]:blocktype);
	
	g_iOnTop[block_entity] = g_iOnTopDef[g_iOnTop[g_iBlocks[block_entity]]];
	g_iOnlyT[block_entity] = g_iOnlyTDef[g_iBlocks[block_entity]];
	g_fProp[block_entity][0] = g_fTimeDef[g_iBlocks[block_entity]];
	g_fProp[block_entity][1] = g_fTime2Def[g_iBlocks[block_entity]];
	
	SDKHook(block_entity, SDKHook_Touch, OnStartTouch);
	SDKHook(block_entity, SDKHook_EndTouch, OnEndTouch);
	SDKHook(block_entity, SDKHook_StartTouch, OnFirstTouch);
	
	g_fAngles[block_entity]=fAng;
	g_bTeleport[block_entity]=false;
	
	g_iRotation[block_entity]=0;
	g_iRuchomy[block_entity] = 0;
	
	for(new i = 0 ; i < 3 ; i++)
		g_iKlr[block_entity][i] = 255;
	
	Entity_GetAbsOrigin(block_entity, g_fVec[block_entity]);
	//Phys_EnableGravity(block_entity, false);
	
	g_iBlockSize[block_entity] = iBlockSize;
	
	ustawRender(block_entity);
	
	return block_entity;
}

public ustawRender(iEnt){
	SetEntityRenderMode(iEnt, RENDER_TRANSALPHA);
	
	SetEntityRenderColor(iEnt, g_iKlr[iEnt][0], g_iKlr[iEnt][1], g_iKlr[iEnt][2], g_iAlpha[iEnt]);
}

public Action:fixMiod(Handle:hTimer, any:client){
	/*new iFlags = GetUserFlagBits(client);
	
	if(iFlags & FL_ONGROUND){
	new ground = GetEntPropEnt(client, Prop_Send, "m_hGroundEntity"); 
	
	if(!(IsValidBlock(ground) && g_iBlocks[ground] != 20)){
	g_bHoney[client]=false;
	
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
	}*/
	
	g_bHoney[client]=false;
	g_iHoney[client] = 0;
	if(IsValidEntity(client) && IsClientConnected(client))
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	
	g_hMiod[client] = INVALID_HANDLE;
}

public Action:OnTakeDamagePost(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	//PrintToChatAll("%d", damagetype);
	
	if(victim && 1 <= victim <= MaxClients && IsClientInGame(victim) && attacker && 1 <= attacker <= MaxClients && IsClientInGame(attacker) && IsPlayerAlive(attacker) && GetClientTeam(attacker) == CS_TEAM_CT && GetClientTeam(attacker) != GetClientTeam(victim)){
		new String:sWeapon[50];
		GetClientWeapon(attacker, sWeapon, sizeof sWeapon);
		
		//PrintToChatAll("%s", sWeapon);
		
		if(StrContains(sWeapon, "knife", false) != -1 && damagetype == 4100 && !g_bInv[victim]){
			if(g_bJustJumped[victim]){
				new MoveType:MT_MoveType = GetEntityMoveType(victim);
			
				if(_:MT_MoveType != 9){
					new Float:vec[2][3];
					GetEntPropVector(victim, Prop_Send, "m_vecOrigin", vec[0]);
					GetEntPropVector(attacker, Prop_Send, "m_vecOrigin", vec[1]);
					
					new Float:fRoznica = (vec[0][2] - vec[1][2]);
					
					//PrintToChatAll("%.1f", fRoznica);
					
					new Float:fMax;
					
					if(GetEntityFlags(attacker)&FL_DUCKING) fMax = 75.0;
					else fMax = 95.0;
					
					if(fRoznica >= fMax){
						new String:sKil[64], String:sOfi[64];
						GetClientName(attacker, sKil, 64);
						GetClientName(victim, sOfi, 64);
						
						damage = 0.0;
						
						//SetEntDataFloat(victim, g_Friction, 0.0, true);
					
						SetEntPropFloat(victim, Prop_Send, "m_flStamina", 0.0);
						SetEntPropFloat(victim, Prop_Send, "m_flVelocityModifier", 1.0);
						
						CPrintToChatAll("{blue}*{lime}[UK]{olive} %s{orange} Tried to underknife{olive} %s", sKil, sOfi);
						
						return Plugin_Handled;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(g_bInv[victim] || (g_bNoFallDmg[victim] && damagetype & DMG_FALL))
		return Plugin_Handled;
	return Plugin_Continue;
	//return;
}

new Float:g_fBeforeVel[MAXPLAYERS+1][3];

public ClientPreThink(entity){
	if(IsPlayerAlive(entity)){
		//diablix zawsze cos wymysli:D
		if(g_bOnIce[entity]){
			if(GetEntityFlags(entity) & FL_ONGROUND){
				new Float:fVel[3], Float:fJak;
				Entity_GetAbsVelocity(entity, fVel);
				fVel[2] = 0.0;
				new Float:fSpeed = GetVectorLength(fVel);
				
				fJak = (fSpeed/266.0) * 100;
				
				GetEntPropVector(entity, Prop_Data, "m_vecVelocity", fVel);
				
				for(new l = 0 ; l < 2 ; l++){
					fVel[l] += (fVel[l]/fJak);
				}
				
				TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, fVel);
			}
		}
		new Float:fVel[3];
		GetEntPropVector(entity, Prop_Data, "m_vecVelocity", g_fBeforeVel[entity]);
		
		if(fVel[0] != 0.0 || fVel[1] != 0.0){
			for(new i = 0 ; i < 2 ; i++)
				g_fBeforeVel[entity][i] = fVel[i];
		}
	}
}

new g_iBlockTr[MAXPLAYERS+1];

new Handle:g_hSkocz[MAXPLAYERS+1];

public Action:skoczKurwa(Handle:hTimer, any:client){
	new Float:fVelocity[3];
	new iEnt = g_iBlockTr[client];

	fVelocity[0]=g_fBeforeVel[client][0]
	fVelocity[1]=g_fBeforeVel[client][1];
	fVelocity[2]=g_fProp[iEnt][0];	
	if(GetEntityFlags(client) & FL_DUCKING){
		fVelocity[2]+=24.0;
	}

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);

	
	g_hSkocz[client] = INVALID_HANDLE;
} 

public Action:wybijKurwa(Handle:hTimer, any:client){
	new Float:fAngles[3];
	new iEnt = g_iBlockTr[client];
	GetClientEyeAngles(client, fAngles);
				
	new Float:fVelocity[3];
	GetAngleVectors(fAngles, fVelocity, NULL_VECTOR, NULL_VECTOR);
				
	NormalizeVector(fVelocity, fVelocity);
	
	ScaleVector(fVelocity, g_fProp[iEnt][1]);
	fVelocity[2] = g_fProp[iEnt][0];
	if(GetEntityFlags(client) & FL_DUCKING){
		fVelocity[2]+=24.0;
	}
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);
	//Entity_SetAbsVelocity(client, fVelocity);
}

public bool:TRDontHitSelf(entity, mask, any:data)
{
 if (entity == data) return false;
 return true;
}

public Action:fixCol(Handle:hTimer, any:iEnt){
	g_hCol[iEnt] = INVALID_HANDLE;
	
	g_bStop[iEnt] = false;
}

stock Float:FloatMin(Float:f1, Float:f2) return f1 < f2 ? f1 : f2;

GetDeadPlayersCount( iTeam )
{
  new iCount, i; iCount = 0;

  for( i = 1; i <= MaxClients; i++ )
    if( IsClientInGame( i ) && !IsPlayerAlive( i ) && GetClientTeam( i ) == iTeam )
      iCount++;

  return iCount;
}  

public OnFirstTouch(ent1, ent2){
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
}

public OnStartTouch(block, client){	
	if(!(1 <= client <= MaxClients)) return;

	if((g_iOnTop[block] && GetEntityFlags(client) & FL_ONGROUND && GetEntPropEnt(client, Prop_Send, "m_hGroundEntity") == block)  || !g_iOnTop[block]){	
		if(g_iBlocks[block]==4){
			if(!g_bOnIce[client]){
				g_bOnIce[client] = true;
			}
		}
		if(g_iBlocks[block]!=4){
			g_bOnIce[client] = false;
		}
		if(g_iBlocks[block]==5){
				if(g_hSkocz[client] == INVALID_HANDLE){
					g_bNoFallDmg[client]=true;
				
					g_iBlockTr[client] = block;
				
					g_hSkocz[client] = CreateTimer(0.01, skoczKurwa, client);
				}
			
		} 
	
		else if(g_iBlocks[block]==6)
		{	
			g_bNoFallDmg[client]=true;
				
			g_iBlockTr[client] = block;
				
			CreateTimer(0.01, wybijKurwa, client);
		}
		
		else if(g_iBlocks[block]==1)
		{
			if(!g_bTriggered[block]){
				SetEntPropFloat(client, Prop_Send, "m_flStamina", 0.0);
				g_bTriggered[block]=true;
				CreateTimer(g_fProp[block][0], StartNoBlock, block);
			}
		} 
		else if(g_iBlocks[block]==2)
		{
			if(g_bInv[client]) return;
					
			if((GetGameTime() - g_fLastDamage[client]) >= g_fProp[block][0]){
				if(GetClientHealth(client)-RoundFloat(g_fProp[block][1]) > 0)
					SetEntityHealth(client, GetClientHealth(client)-RoundFloat(g_fProp[block][1]));
				else
					ForcePlayerSuicide(client);
				
				dobierzD(client, 0);
				
				EmitSoundToClient(client, g_sDamage[g_iLastObr[client][0]], block);
				
				if(GetRandomInt(1, 100) <= 35){
					dobierzD(client, 1);
					EmitSoundToClient(client, g_sDamage[g_iLastObr[client][1]], block);
					/*new Float:vec[3];
					GetClientAbsOrigin(client, vec);
					vec[2] += 10;
					EmitAmbientSound(g_sDamage[g_iLastObr[client][1]], vec, client, SNDLEVEL_RAIDSIREN);*/
				}
				
				ScreenFade(client, FFADE_IN|FFADE_PURGE|FFADE_MODULATE, {255, 0, 32, 115}, 1, 0);
				
				g_fLastDamage[client] = GetGameTime();
			}
		} 
		else if(g_iBlocks[block]==3)
		{
			if((GetGameTime() - g_fLastHP[client]) >= g_fProp[block][0]){

				new iMaxHP = 100;//pobierzMaxHp(client);

				new iHp = GetEntProp(client, Prop_Data, "m_iHealth");
				
				new iDodane = iHp + RoundFloat(g_fProp[block][1]);

				if(iDodane < iMaxHP){
					SetEntProp(client, Prop_Data, "m_iHealth", iDodane);
				}
				else{
					SetEntProp(client, Prop_Data, "m_iHealth", iMaxHP);
				}
				
				g_fLastHP[client] = GetGameTime();
			}
		}
		else if(g_iBlocks[block]==7)
		{
			if((g_iOnlyT[block] && GetClientTeam(client) == 2) || !g_iOnlyT[block])
			{
				if(g_bInvCanUse[client]){
					CreateTimer(g_fProp[block][0], ResetInv, client);
					CreateTimer(g_fProp[block][1], ResetInvCooldown, client);
					g_bInv[client]=true;
					g_bInvCanUse[client]=false;

					if(!g_bStealth[client]){
						SetEntityRenderMode(client, RENDER_TRANSALPHA);
						SetEntityRenderFx(client, RENDERFX_EXPLODE);
						SetEntityRenderColor(client, 0, 128, 255, 128);
					}
						
					//	CreateLight(client)
					
					new time = RoundFloat(g_fProp[block][0]);
					new Handle:packet = CreateDataPack()
					WritePackCell(packet, client)
					WritePackCell(packet, time)
					WritePackString(packet, "Invincibility")
					//EmitSoundToClient(client, INVI_SOUND_PATH, block)
					new Float:vec[3];
					GetClientAbsOrigin(client, vec);
					vec[2] += 10;
					EmitAmbientSound(INVI_SOUND_PATH, vec, client, SNDLEVEL_RAIDSIREN);	
					//EmitSoundToAll("zombiemod/Music/ZM_Song03.mp3", client, SNDCHAN_AUTO, SNDLEVEL_RAIDSIREN);  
					CreateTimer(0.1, TimeLeft, packet)
					
					g_fInv[client] = GetGameTime();
				}
				else{
					if(!g_bInv[client])
						PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s<br><font size='24'color='#867979'><b>Invincibility in:</b><font color='#FA0000'> %d", VERSION, RoundFloat((g_fProp[block][1] - (GetGameTime() - g_fInv[client]))));
				}
				//PrintHintText(client, "Next use: %f", (60.0 - (GetGameTime() - g_fInv[client])));
			}
		} 
		else if(g_iBlocks[block]==8)
		{
			if((g_iOnlyT[block] && GetClientTeam(client) == 2) || !g_iOnlyT[block])
			{
				if(g_bStealthCanUse[client]){
					g_bStealth[client] = true;
					CreateTimer(g_fProp[block][0], ResetStealth, client);
					CreateTimer(g_fProp[block][1], ResetStealthCooldown, client);
					SetEntityRenderFx(client, RENDERFX_NONE);
					SetEntityRenderColor(client, 255, 255, 255, 255);
					
					SetEntityRenderMode(client, RENDER_NONE);
					SDKHook(client, SDKHook_SetTransmit, Stealth_SetTransmit)
					g_bStealthCanUse[client]=false;
					
					new time = RoundFloat(g_fProp[block][0]);
					new Handle:packet = CreateDataPack()
					WritePackCell(packet, client)
					WritePackCell(packet, time)
					WritePackString(packet, "Stealth")
					new Float:vec[3];
					GetClientAbsOrigin(client, vec);
					vec[2] += 10;
					EmitAmbientSound(STEALTH_SOUND_PATH, vec, client, SNDLEVEL_RAIDSIREN);	
					CreateTimer(0.1, TimeLeft, packet)
					
					g_fStealth[client] = GetGameTime();
				}
				else{
					if(!g_bStealth[client])
						PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s<br><font size='24'color='#867979'><b>Stealth in:</b><font color='#FA0000'> %d", VERSION, RoundFloat((g_fProp[block][1] - (GetGameTime() - g_fStealth[client]))));
				}
			}
		} 
		else if(g_iBlocks[block]==9)
		{	
			if(g_fProp[block][0] >= 1.0){
				ScreenFade(client, FFADE_IN|FFADE_PURGE|FFADE_MODULATE, {0, 0, 0, 255}, 1, 0);
				ForcePlayerSuicide(client);
			}
			else{
				if(!g_bInv[client] && GetEntProp(client, Prop_Data, "m_takedamage", 1) == 2){
					ScreenFade(client, FFADE_IN|FFADE_PURGE|FFADE_MODULATE, {0, 0, 0, 255}, 1, 0);
					ForcePlayerSuicide(client);
				}
			}
		}
		else if(g_iBlocks[block]==11){
			if((g_iOnlyT[block] && GetClientTeam(client) == 2) || !g_iOnlyT[block])
			{
				if(GetDeadPlayersCount(GetClientTeam(client))){
					if(!g_iRespawn){
						new iRandom = -1;
						iRandom = GetRandomDeadPlayer(client, GetClientTeam(client));
						
						if(1 <= iRandom <= MaxClients){
							new String:sName[64];
							GetClientName(client, sName, sizeof sName);
							CS_RespawnPlayer(iRandom);
							
							PrintHintText(client, "You respawned\n<font size='30'><font color='#FF0000'><b>%s</b></font>", sName);
							PrintHintText(iRandom, "You got respawned\n<font size='20'><font color='#FF0000'>Someone used <b>Respawn Block</b></font>");
							
							g_iRespawn=client;
						}
					}
					else{
						if(g_iRespawn!=client){
							PrintHintText(client, "Already used\n<font size='30'><font color='#FF0000'>Wait for next<b> round</b></font>");
						}
					}
				}
				else{
					PrintHintText(client, "Error!\n<font size='20'><font color='#FF0000'>All your teammates are <b>alive</b></font>");
				}
			}
		}
		else if(g_iBlocks[block]==13){
			if(GetClientTeam(client) == 2){
				new iNum = GetClientCount(true);
				
				if(iNum>=6){
					if(g_bLP[client][block]){
						new Float:vec[3];
						GetClientAbsOrigin(client, vec);
						EmitAmbientSound(XP_SOUND_PATH, vec, client, SNDLEVEL_RAIDSIREN);	
						//dodajLP(client, RoundFloat(g_fProp[block][0]));
						PrintHintText(client, "<font color='#FFA500'><font size='40'>+<b>%d</b>LP</b></font>\n<font color='#006600'><font size='18'>For collecting $$ from block", RoundFloat(g_fProp[block][0]));
						TE_SetupBeamRingPoint(vec, 10.0, 420.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.7, 15.0, 6.0, {255, 165, 0, 255}, 10, 0);
						TE_SendToAll();
						g_bLP[client][block] = false;
					}
				}
				else{
					PrintHintText(client, "<font color='#FFA500'><font size='40'>+<b>0</b>LP</b></font>\n<font color='#FF0016'><font size='18'>Min. 6 players required");
				}
			}
		}
		else if(g_iBlocks[block]==14)
		{
			if(GetClientTeam(client)==CS_TEAM_T)
			{
				SetEntProp(block, Prop_Data, "m_CollisionGroup", 2);

				SetEntityRenderMode(block, RENDER_TRANSADD);
				SetEntityRenderColor(block, g_iKlr[block][0], g_iKlr[block][1], g_iKlr[block][2], 117);
				CreateTimer(1.0, CancelNoBlock, block);
			}
		} 
		else if(g_iBlocks[block]==15)
		{
			if(GetClientTeam(client)==CS_TEAM_CT)
			{
				SetEntProp(block, Prop_Data, "m_CollisionGroup", 2);
				
				SetEntityRenderMode(block, RENDER_TRANSADD);
				SetEntityRenderColor(block, g_iKlr[block][0], g_iKlr[block][1], g_iKlr[block][2], 117);
				CreateTimer(1.0, CancelNoBlock, block);
			}
		} 
		else if(g_iBlocks[block]==16)
		{
			if((g_iOnlyT[block] && GetClientTeam(client) == 2) || !g_iOnlyT[block])
			{
				if(g_bBootsCanUse[client]){
					CreateTimer(g_fProp[block][0], ResetBoots, client);
					CreateTimer(g_fProp[block][1], ResetBootsCooldown, client);
					SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 2.0);
					g_bBoots[client]=true;
					g_bBootsCanUse[client]=false;
					
					new time = RoundFloat(g_fProp[block][0]);
					new Handle:packet = CreateDataPack()
					WritePackCell(packet, client)
					WritePackCell(packet, time)
					WritePackString(packet, "Boots Of Speed")
					
					new Float:vec[3];
					GetClientAbsOrigin(client, vec);
					vec[2] += 10;
					EmitAmbientSound(BOS_SOUND_PATH, vec, client, SNDLEVEL_RAIDSIREN);	
					
					CreateTimer(0.1, TimeLeft, packet)
					
					g_fBOS[client] = GetGameTime();
				}
				else{
					if(!g_bBoots[client])
						PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s<br><font size='24'color='#867979'><b>Boots of speed in:</b><font color='#FA0000'> %d", VERSION, RoundFloat((g_fProp[block][1] - (GetGameTime() - g_fBOS[client]))));
				}
			}
		} 
		else if(g_iBlocks[block]==19)
		{
			g_bNoFallDmg[client]=true;
		} 
		else if(g_iBlocks[block]==20)
		{
			if(g_hMiod[client] != INVALID_HANDLE)
			{
				KillTimer(g_hMiod[client]);
			}
			g_hMiod[client] = INVALID_HANDLE;
			g_bHoney[client] = true;
			g_iHoney[client] = block;
			g_hMiod[client] = CreateTimer(0.05, fixMiod, client);
		}
		
		else if(g_iBlocks[block]==21)
		{
			if((g_iOnlyT[block] && GetClientTeam(client) == 2) || !g_iOnlyT[block])
			{
				if(g_bCamCanUse[client]){
					if(GetClientTeam(client)==2)
						SetEntityModel(client, "models/player/ctm_gign.mdl");
					else if(GetClientTeam(client)==3)
						SetEntityModel(client, "models/player/tm_phoenix.mdl");
					g_bCamCanUse[client]=false;
					CreateTimer(g_fProp[block][0], ResetCamouflage, client);
					CreateTimer(g_fProp[block][1], ResetCamCanUse, client);
					
					new time = RoundFloat(g_fProp[block][0]);
					new Handle:packet = CreateDataPack()
					WritePackCell(packet, client)
					WritePackCell(packet, time)
					WritePackString(packet, "Camouflage")
					new Float:vec[3];
					GetClientAbsOrigin(client, vec);
					vec[2] += 10;
					EmitAmbientSound(CAM_SOUND_PATH, vec, client, SNDLEVEL_RAIDSIREN);	
					g_bKamuflaz[client]=true;
					CreateTimer(0.1, TimeLeft, packet)
					g_fKam[client] = GetGameTime();
				}
				else{
					PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s<br><font size='24'color='#867979'><b>Camouflage in:</b><font color='#FA0000'> %d", VERSION, RoundFloat((g_fProp[block][1] - (GetGameTime() - g_fKam[client]))));
				}
			}
		}
		else if(g_iBlocks[block]==22)
		{
			if((g_bDeagleCanUse[client][block] && g_iOnlyT[block] && GetClientTeam(client) == 2) || g_bDeagleCanUse[client][block] && !g_iOnlyT[block])
			{
					RemoveWeaponBySlot(client, 0);
					RemoveWeaponBySlot(client, 1);
					
					new ent = -1;
					
					new iOpt = RoundFloat(g_fProp[block][0]);
					
					ent = GivePlayerItem(client, g_sWeapons[iOpt]);
					
					if(IsValidEntity(ent)){
						SetEntProp(ent, Prop_Data, "m_iClip1", RoundFloat(g_fProp[block][1]));
						SetEntProp(ent, Prop_Send, "m_iPrimaryReserveAmmoCount", 0);
					}
					
					if(iOpt==4){
						PrintHintTextToAll("<font size='36'>%N\n<font size='26'>got <b><font color='#FF0000'>AWP</b></font>!!!", client);
					}
					else{
						new String:sWeapon[64];
						FormatEx(sWeapon, sizeof sWeapon, g_sWeapons[iOpt]);
						ReplaceString(sWeapon, sizeof sWeapon, "weapon_", "");

						PrintHintText(client, "You get\n<font size='40'><font color='#FF0000'><b>%s</b></font>", sWeapon);
					}
					g_bDeagleCanUse[client][block] = false;
			}
		} 
		else if(g_iBlocks[block]==23)
		{
			if(!g_iGravity[client]){
				g_iGravity[client]=RoundFloat(g_fProp[block][0]);	
				
				SetEntityGravity(client, (g_fProp[block][0]/800.0));
			}
		} 
		else if(g_iBlocks[block]==25)
		{
			if((g_bHEgrenadeCanUse[client][block] && g_iOnlyT[block] && GetClientTeam(client) == 2) || g_bHEgrenadeCanUse[client][block] && !g_iOnlyT[block])
			{
				g_bHEgrenadeCanUse[client][block] = false;
				
				new iAmmo = GetEntProp(client, Prop_Send, "m_iAmmo", _, 15);
				GivePlayerItem(client, "weapon_hegrenade");
				PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s\n<font face='Arial'><font size='24'><font color='#A8A8A8'>You've got <b><font color='#E00000'>HE GRENADE</b></font>!", VERSION);

				SetEntProp(client, Prop_Send, "m_iAmmo", iAmmo + 1, 4, 15);
			}
		} 
		else if(g_iBlocks[block]==26)
		{
			if((g_bFlashbangCanUse[client][block] && g_iOnlyT[block] && GetClientTeam(client) == 2) || g_bFlashbangCanUse[client][block] && !g_iOnlyT[block])
			{
					GivePlayerItem(client, "weapon_flashbang");
					PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s\n<font face='Arial'><font size='24'><font color='#A8A8A8'>You've got <b><font color='#E00000'>FLASHBANG</b></font>!", VERSION);
					g_bFlashbangCanUse[client][block] = false;
			}
		} 
		else if(g_iBlocks[block]==27)
		{
			if((g_bSmokegrenadeCanUse[client][block] && g_iOnlyT[block] && GetClientTeam(client) == 2) || g_bSmokegrenadeCanUse[client][block] && !g_iOnlyT[block])
			{
					GivePlayerItem(client, "weapon_decoy");
					PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s\n<font face='Arial'><font size='24'><font color='#A8A8A8'>You've got <b><font color='#E00000'>FROSTGRENADE</b></font>!", VERSION);
					g_bSmokegrenadeCanUse[client][block] = false;
			}
		}
		else if(g_iBlocks[block]==28)
		{
			g_bTriggered[block]=true;
			CreateTimer(g_fProp[block][0], StartNoBlock, block);
		}
		else if(g_iBlocks[block]==29){
			if(GetClientTeam(client) == 2){
				if((GetGameTime() - g_fLastChance[client]) >= g_fProp[block][1]){
					if(g_bChance[client]){
						new String:sMessage[1024], String:sPercent[512];
						Format(sPercent, sizeof sPercent, "\n<font color='#CCCCCC'>Chance:<font color='#66FF66'> %d%c", RoundFloat(g_fProp[block][0]), '%');
						
						Format(sMessage, sizeof sMessage, "<font color='#006699'><b>Blockmaker</b> %s**</font>\n<font face='Arial'><font size='16'>Respawn: <font color='#66FF66'>READY%s", VERSION, sPercent);
						
						PrintHintText(client, sMessage);
					}
					else{
						g_fChance[client][block] = g_fChance[client][block] >= g_fProp[block][0] ? g_fProp[block][0] : g_fChance[client][block] + 1.0;
						
						new String:sMessage[1024], String:sPercent[512];
						Format(sPercent, sizeof sPercent, "\n<font color='#CCCCCC'>Chance:<font color='#996633'> %d%c%c", RoundFloat(g_fProp[block][0]), '%', '%');
						
						Format(sMessage, sizeof sMessage, "<font color='#006699'><b>Blockmaker</b> %s**</font>\n<font size='13'>Respawn: <font color='#CC0000'>NOT READY%s", VERSION, sPercent);
						
						if(g_fChance[client][block] < g_fProp[block][0]){
							Format(sMessage, sizeof sMessage, "%s\n%d%c", sMessage, RoundFloat((g_fChance[client][block]*100.0)/g_fProp[block][0]), '%');
							PrintHintText(client, sMessage);
						}
						else{
							if(!g_bChance[client]){
								g_bChance[client] = true;
								g_fActChance[client] = g_fProp[block][0];
							}
						}
					}
					
					g_fLastChance[client] = GetGameTime();
				}
			}
			else{
				PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s\n<font face='Arial'><font size='24'><font color='#CC0000'>Only for Terrorists!", VERSION);
			}
		}
		else if(g_iBlocks[block]==30){
			if(GetClientTeam(client) == 2){
				new iNum = GetClientCount(true);
				
				if(iNum>=6){
					if(g_bXP[client][block]){
						new Float:vec[3];
						GetClientAbsOrigin(client, vec);
						EmitAmbientSound(XP_SOUND_PATH, vec, client, SNDLEVEL_RAIDSIREN);	
						//dodajXP(client, RoundFloat(g_fProp[block][0]));
						PrintHintText(client, "<font color='#00CC33'><font size='40'>+<b>%d</b>$</b></font>\n<font color='#006600'><font size='18'>For collecting $$ from block", RoundFloat(g_fProp[block][0]));
						TE_SetupBeamRingPoint(vec, 10.0, 420.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.7, 15.0, 6.0, {75, 255, 75, 255}, 10, 0);
						TE_SendToAll();
						g_bXP[client][block] = false;
					}
				}
				else{
					PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s\n<font face='Arial'><font size='24'><font color='#CC0000'>%d players to go!", VERSION, 6-iNum);
				}
			}
		}
	}
}

GetRandomDeadPlayer(id, team) 
{ 
    new clients[MaxClients+1], clientCount;
	
    for (new i = 1; i <= MaxClients; i++)
	{
        if (IsClientInGame(i) && GetClientTeam(i) == team && i != id && !IsPlayerAlive(i))
		{
            clients[clientCount++] = i; 
		}
	}
	
    return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)]; 
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
				//PrintHintText(client, "%s: %i", effectname, time)
				
				PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s<br><font size='24'color='#867979'><b>%s:</b> %i", VERSION, effectname, time);
				new Handle:packet = CreateDataPack()
				WritePackCell(packet, client)
				WritePackCell(packet, time)
				WritePackString(packet, effectname)
				
				CreateTimer(1.0, TimeLeft, packet)
			}
		}
	}	
}

public Action:ResetGrav(Handle:timer, any:client){
	if(IsValidClient(client)){
		SetEntityGravity(client, 1.0)
	}
}

stock bool:IsValidClient(client) {
	return ((1 <= client <= MaxClients) && IsClientInGame(client));
}  

public OnEndTouch(block, client){
	if(!(1 <= client <= MaxClients)) return;

	else if(g_iBlocks[block]==2){
		g_bDamage[client]=false;
	}
	else if(g_iBlocks[block]==3)
	{
		g_bHeal[client]=false;
	}
	else if(g_iBlocks[block]==4){
		g_bOnIce[client] = false;
	}
	else if(g_iBlocks[block]==5 || g_iBlocks[block]==6 || g_iBlocks[block]==19)
	{
		g_bNoFallDmg[client]=false;
	} 
}

public Action:ResetCamouflage(Handle:timer, any:client){
	g_bKamuflaz[client] = false;
	
	if(!IsClientInGame(client))
		return Plugin_Stop;
	if(GetClientTeam(client)==3)
		SetEntityModel(client, "models/player/ctm_gign.mdl");
	else if(GetClientTeam(client)==2)
		SetEntityModel(client, "models/player/tm_phoenix.mdl");
	
	PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s<br><font size='24'color='#867979'><b>Camouflage</b><font color='#FA0000'> off", VERSION);
	return Plugin_Stop;
}

public Action:ResetCamCanUse(Handle:timer, any:client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;
	g_bCamCanUse[client]=true;
	
	return Plugin_Stop;
}

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
	if(IsValidBlock(block)){
		SetEntProp(block, Prop_Data, "m_CollisionGroup", 0);
		ustawRender(block);
	}
	g_iTouched[block]=0;
	g_bTriggered[block]=false;
	return Plugin_Stop;
}

public Action:ResetNoFall(Handle:timer, any:client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;
	g_bNoFallDmg[client] = false;
	return Plugin_Stop;
}

public Action:ResetInv(Handle:timer, any:client)
{
	if(!IsClientInGame(client))
		return Plugin_Stop;
	g_bInv[client] = false;
	
	PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s<br><font size='24'color='#867979'><b>Invincibility</b><font color='#FA0000'> off", VERSION);
	
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
	SDKUnhook(client, SDKHook_SetTransmit, Stealth_SetTransmit)
	PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s<br><font size='24'color='#867979'><b>Stealth</b><font color='#FA0000'> off", VERSION);
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
	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	
	g_bBoots[client]=false;
	
	PrintHintText(client, "<font color='#00AFFF'size='22'><b>Blockmaker</b> %s<br><font size='24'color='#867979'><b>BootsOfSpeed</b><font color='#FA0000'> off", VERSION);
	
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

public Handler_Teleport(Handle:menu, MenuAction:action, client, param2){
	if (action == MenuAction_Select){
		if(param2==0)
		{
			if(g_iCurrentTele[client]==-1)
				CreateTeleportEntrance(client);
			else{
				if(IsValidEdict(g_iCurrentTele[client])){
					AcceptEntityInput(g_iCurrentTele[client], "Kill");
				}
				g_iCurrentTele[client]=-1;
			}
		} 
		else if(param2==1){
			if(g_iCurrentTele[client]==-1)
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Create entrance first!", VERSION);
			else
			{
				g_iTeleporters[g_iCurrentTele[client]]=CreateTeleportExit(client);
				g_iCurrentTele[client]=-1;
			}
		} 
		else if(param2==2){
			new ent = GetClientAimTarget(client, false);
			new entrance = -1;
			new hexit = -1;
			if(g_iTeleporters[ent]>=1){
				if(g_iTeleporters[ent]>1){
					entrance = ent;
					hexit = g_iTeleporters[ent];
				}
				else{
					for(new i=MaxClients+1;i<2048;++i){
						if(g_iTeleporters[i]==ent){
							hexit = ent;
							entrance = i;
							break;
						}
					}
				}
				
				if(entrance > 0 && hexit > 0){
					if(IsValidBlock(entrance) && IsValidBlock(hexit)){
						SetEntityModel(entrance, "models/platforms/r-tele.mdl");
						SetEntityModel(hexit, "models/platforms/b-tele.mdl");
						g_iTeleporters[entrance]=1;
						g_iTeleporters[hexit]=entrance;
					}
				}
			}
		} 
		else if(param2==3){
			new ent = GetClientAimTarget(client, false);
			if(IsValidBlock(ent)){
				g_bTeleport[ent] = false;
				AcceptEntityInput(ent, "Kill");
				g_iBlocks[ent]=-1;
				if(g_iTeleporters[ent]>=1){
					if(g_iTeleporters[ent]>1 && IsValidBlock(g_iTeleporters[ent])){
						AcceptEntityInput(g_iTeleporters[ent], "Kill");
						g_iTeleporters[g_iTeleporters[ent]] = -1;
					} 
					else if(g_iTeleporters[ent]==1){
						for(new i=MaxClients+1;i<2048;++i){
							if(g_iTeleporters[i]==ent){
								if(IsValidBlock(i))
									AcceptEntityInput(i, "Kill");
								
								g_iTeleporters[i] = -1;
								break;
							}
						}
					}
					
					g_iTeleporters[ent]=-1;
				}
			}
		} 
		else if(param2==4){
			new ent = GetClientAimTarget(client, false);
			if(ent!=-1){
				new entrance = -1;
				new hexit = -1;
				if(g_iTeleporters[ent]>=1){
					if(g_iTeleporters[ent]>1){
						entrance = ent;
						hexit = g_iTeleporters[ent];
					}
					else{
						for(new i=MaxClients+1;i<2048;++i){
							if(g_iTeleporters[i]==ent){
								hexit = ent;
								entrance = i;
								break;
							}
						}
					}
					if(entrance > 0 && hexit > 0){
						if(IsValidBlock(entrance) && IsValidBlock(hexit)){
							new color[4]={255, 0, 0, 255};
							new Float:pos1[3], Float:pos2[3];
							GetEntPropVector(entrance, Prop_Data, "m_vecOrigin", pos1);
							GetEntPropVector(hexit, Prop_Data, "m_vecOrigin", pos2);
							TE_SetupBeamPoints(pos2, pos1, g_iBeamSprite, 0, 0, 40, 15.0, 20.0, 20.0, 25, 0.0, color, 10);
							TE_SendToClient(client);
						}
					}
				}
			}
			else{
				CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} Aim on the teleport!", VERSION);
			}
		}
		DisplayMenu(CreateTeleportMenu(client), client, 0);
	}
	else if ((action == MenuAction_Cancel) && (param2 == MenuCancel_ExitBack))
		DisplayMenu(CreateMainMenu(client), client, 0);
}

public Handler_Blocks(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		g_iBlockSelection[client]=param2;

		DisplayMenu(CreateMainMenu(client), client, 0);
	}
	else if ((action == MenuAction_Cancel) && (param2 == MenuCancel_ExitBack))
		DisplayMenu(CreateMainMenu(client), client, 0);
}

public Handler_Options(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 0)
		{
			g_bSnapping[client]=!g_bSnapping[client];
		}
		else if(param2 == 1)
		{
			SaveBlocks(true);
		}
		else if(param2 == 2)
		{
			MenuAccess(client, 0);	
		}
		else if(param2 == 3)
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
		} 
		else if(param2 == 4)
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
		} 
		else if(param2 == 5){
			g_bAutoSave=!g_bAutoSave;
			
			if(g_hAutoSave != INVALID_HANDLE){ 
				KillTimer(g_hAutoSave);
				g_hAutoSave = INVALID_HANDLE;
			}

			if(g_bAutoSave) g_hAutoSave = CreateTimer(300.0, tskAutoSave);
			
			CPrintToChat(client, "{blue}*{lime}[HNSB %s]{orange} AutoSave feature is now %s", VERSION, g_bAutoSave ? "{olive}ON" : "{darkred}OFF");
		}
		if(param2 != 2)
			DisplayMenu(CreateOptionsMenu(client), client, 0);
	}
	else if ((action == MenuAction_Cancel) && (param2 == MenuCancel_ExitBack))
		DisplayMenu(CreateMainMenu(client), client, 0);
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

stock bool:RemoveWeaponBySlot(iClient, iSlot){
	new iEntity = GetPlayerWeaponSlot(iClient, iSlot);
	if(IsValidEdict(iEntity)){
		RemovePlayerItem(iClient, iEntity);
		AcceptEntityInput(iEntity, "Kill");
		return true;
	}
	return false;
}

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
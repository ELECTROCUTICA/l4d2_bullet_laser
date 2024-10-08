#pragma newdecls required

#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#define CVAR_FLAGS		FCVAR_NOTIFY


public int laser_vmt;
public int LaserSwitch[MAXPLAYERS];
// public int LaserColor[MAXPLAYERS][4];
public ColorType LaserColor[MAXPLAYERS];
public ConVar g_hPluginEnabled, g_hAlphaValue, g_hMode, g_hLaserWidth;
public int Alpha = 0;
public int Mode = 0;
public float LaserWidth = 0.0;

public Plugin myinfo = {
    name = "l4d2_Bullet_Laser",
    author = "season of yanhua",
    description = "",
    version = "1.2",
    url = "http://theyanhua.top"
}


public bool CheckEngineVersion() {

    EngineVersion game_ev = GetEngineVersion();

    if (game_ev == Engine_Left4Dead2) {
        return true;
    }
    else {
        return false;
    }

}

public void OnPluginStart() {

    g_hPluginEnabled = CreateConVar("l4d2_laser_enabled", "1", "是否启用插件，1=开启，0=关闭，默认值=1", CVAR_FLAGS);
    g_hAlphaValue = CreateConVar("l4d2_laser_alpha", "24", "设置光束的不透明度,越低越透明,值范围0-255，默认值=24", CVAR_FLAGS);
    g_hMode = CreateConVar("l4d2_laser_mode", "1", "设置光束的射出位置，1=从人物模型的右手射出，2=从人物的眼睛射出，默认值=1", CVAR_FLAGS);
    g_hLaserWidth = CreateConVar("l42d2_laser_width", "0.42", "设置光束的粗细，默认值=0.42", CVAR_FLAGS);

    Alpha = g_hAlphaValue.IntValue;
    Mode = g_hMode.IntValue;
    LaserWidth = g_hLaserWidth.FloatValue;

    AutoExecConfig(true, "l4d2_bullet_laser");

    HookEvent("bullet_impact", Draw_Bullet_Laser);

    RegConsoleCmd("sm_onlaser", Switch_On_Laser, "开启子弹轨迹");
    RegConsoleCmd("sm_offlaser", Switch_Off_Laser, "关闭子弹轨迹");
    RegConsoleCmd("sm_redlaser", Red_Laser, "红色轨迹");
    RegConsoleCmd("sm_greenlaser", Green_Laser, "绿色轨迹");
    RegConsoleCmd("sm_bluelaser", Blue_Laser, "蓝色轨迹");
    RegConsoleCmd("sm_cyanlaser", Cyan_Laser, "青色轨迹");
    RegConsoleCmd("sm_yellowlaser", Yellow_Laser, "黄色轨迹");
    RegConsoleCmd("sm_purplelaser", Purple_Laser, "紫色轨迹");
    RegConsoleCmd("sm_orangelaser", Orange_Laser, "橙色轨迹");


    for (int i = 0; i < MAXPLAYERS; i++) {
        LaserSwitch[i] = -1;
        LaserColor[i] = ENone;
    }

}

public void OnMapStart() {
    laser_vmt = PrecacheModel("materials/sprites/laserbeam.vmt");

    PrintToChatAll("\x03[子弹轨迹显示by-YanHua]\x04子弹轨迹显示默认开启,输入\x03!onlaser\x04开启或输入\x03!offlaser\x04关闭");
}


enum ColorType {
    ERed,
    EOrange,
    EYellow,
    EGreen,
    ECyan,
    EBlue,
    EPurple,
    ENone
}

int[] GetColorType(int client) {
    int ColorArray[4];

    switch (LaserColor[client]) {
        case ERed: {
            ColorArray[0] = 255;
            ColorArray[1] = 0;
            ColorArray[2] = 0;
            ColorArray[3] = Alpha;
            return ColorArray;
        }
        case EOrange: {
            ColorArray[0] = 255;
            ColorArray[1] = 128;
            ColorArray[2] = 1;
            ColorArray[3] = Alpha;
            return ColorArray;
        }
        case EYellow: {
            ColorArray[0] = 255;
            ColorArray[1] = 255;
            ColorArray[2] = 0;
            ColorArray[3] = Alpha;
            return ColorArray;
        }
        case EGreen: {
            ColorArray[0] = 0;
            ColorArray[1] = 255;
            ColorArray[2] = 0;
            ColorArray[3] = Alpha;
            return ColorArray;
        }
        case ECyan: {
            ColorArray[0] = 0;
            ColorArray[1] = 255;
            ColorArray[2] = 255;
            ColorArray[3] = Alpha;
            return ColorArray;
        }
        case EBlue: {
            ColorArray[0] = 0;
            ColorArray[1] = 0;
            ColorArray[2] = 255;
            ColorArray[3] = Alpha;
            return ColorArray;
        }
        case EPurple: {
            ColorArray[0] = 255;
            ColorArray[1] = 0;
            ColorArray[2] = 255;
            ColorArray[3] = Alpha;
            return ColorArray;
        }
        default : {
            ColorArray[0] = 0;
            ColorArray[1] = 0;
            ColorArray[2] = 0;
            ColorArray[3] = Alpha;
            return ColorArray;

        }

    }
}


public void Draw_Bullet_Laser(Handle event, const char[] name, bool Broadcast) {
    if (!CheckEngineVersion()) return;

    if (g_hPluginEnabled.IntValue != 1) return; 
    int client = GetClientOfUserId(GetEventInt(event, "userid"));

    if (LaserSwitch[client] == 0) return;
    if (!IsClientInGame(client) || IsFakeClient(client) || GetClientTeam(client) != 2 || !IsPlayerAlive(client)) return;
    if (LaserColor[client] == ENone) return;

    int weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");


    float vec[3];
    float ang[3];
    
    if (Mode == 1) {
        int attach = LookupEntityAttachment(client, "armR_T");
        GetEntityAttachment(client, attach, vec, ang);
        vec[0] += 0.0;
        vec[1] += 0.0;
        vec[2] += 5.5;
    }
    else if (Mode == 0) {
        GetClientEyePosition(client, vec);
    }
    else {
        return;
    }

    // float player_angle[3];
    // GetClientEyeAngles(client, player_angle);

    float bullet_pos[3];
    bullet_pos[0] = GetEventFloat(event, "x");
    bullet_pos[1] = GetEventFloat(event, "y");
    bullet_pos[2] = GetEventFloat(event, "z");

    //float distance = GetVectorDistance(player_pos, bullet_pos);


    TE_SetupBeamPoints(vec,          //起点
             bullet_pos,           //终点
             laser_vmt,           //光束特效
             0,               //光圈特效
             0,               //渲染起始帧
             0,              //特效帧率
             0.8,              //维持时间
             LaserWidth,              //光束起始宽度
             LaserWidth,              //光束尾端宽度
             1,               //光束消散持续时间
             0.0,               //光束振幅
             GetColorType(client),        //颜色  GetColorType(client)
             0);                //速度


    TE_SendToAll();
}

public void OnClientConnected(int client) {
    if (LaserSwitch[client] != 1 && LaserSwitch[client] != 0) {
        LaserSwitch[client] = 1;
    }
    if (LaserColor[client] == ENone) {
        LaserColor[client] = EGreen;
    }
}

public void OnClientPutInServer(int client) {
    if (IsFakeClient(client)) return;
	CreateTimer(8.0, TimerAnnounce, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);

}


public Action TimerAnnounce(Handle timer, any client) {
    if ((client = GetClientOfUserId(client))) {
        if (IsClientInGame(client)) {
            PrintToChat(client, "\x03[子弹轨迹显示by-YanHua]\x04子弹轨迹显示默认开启,输入\x03!onlaser\x04开启或输入\x03!offlaser\x04关闭");
            PrintToChat(client, "\x03[子弹轨迹显示by-YanHua]\x04子弹轨迹颜色默认为绿色,修改颜色输入\x03!redlaser\x04改为红色，支持红橙黄绿青蓝紫");
        }
    }
    return Plugin_Continue;
}

public Action Switch_On_Laser(int client, int args) {
    if (LaserSwitch[client] == 1) {
        PrintToChat(client, "\x03%N：\x04请不要重复开启", client);
        return Plugin_Continue;
    }
    LaserSwitch[client] = 1;
    PrintToChat(client, "\x03%N：\x04您的子弹轨迹现在开启", client);
    return Plugin_Continue;
}
public Action Switch_Off_Laser(int client, int args) {
    if (LaserSwitch[client] == 0) {
        PrintToChat(client, "\x03%N：\x04请不要重复关闭", client);
        return Plugin_Continue;
    }
    LaserSwitch[client] = 0;
    PrintToChat(client, "\x03%N：\x04您的子弹轨迹现已关闭", client);
    return Plugin_Continue;
}
public Action Red_Laser(int client, int args) {
    LaserColor[client] = ERed;
    PrintToChat(client, "\x03%N：\x04您的子弹轨迹已修改为红色", client);
    return Plugin_Continue;
}
public Action Green_Laser(int client, int args) {
    LaserColor[client] = EGreen;
    PrintToChat(client, "\x03%N：\x04您的子弹轨迹已修改为绿色", client);
    return Plugin_Continue;
}
public Action Blue_Laser(int client, int args) {
    LaserColor[client] = EBlue;
    PrintToChat(client, "\x03%N：\x04您的子弹轨迹已修改为蓝色", client);
    return Plugin_Continue;
}
public Action Cyan_Laser(int client, int args) {
    LaserColor[client] = ECyan;
    PrintToChat(client, "\x03%N：\x04您的子弹轨迹已修改为青色", client);
    return Plugin_Continue;
}
public Action Purple_Laser(int client, int args) {
    LaserColor[client] = EPurple;
    PrintToChat(client, "\x03%N：\x04您的子弹轨迹已修改为紫色", client);
    return Plugin_Continue;
}
public Action Yellow_Laser(int client, int args) {
    LaserColor[client] = EYellow;
    PrintToChat(client, "\x03%N：\x04您的子弹轨迹已修改为黄色", client);
    return Plugin_Continue;
}
public Action Orange_Laser(int client, int args) {
    LaserColor[client] = EOrange;
    PrintToChat(client, "\x03%N：\x04您的子弹轨迹已修改为橙色", client);
    return Plugin_Continue;
}
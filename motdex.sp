#pragma semicolon 1
#pragma newdecls required

Database g_hDatabase;
ConVar g_cvarWebURL;

public Plugin myinfo = 
{
    name        = "Motd Extended",
    author      = "Kyle",
    description = "",
    version     = "1.1",
    url         = "http://steamcommunity.com/id/_xQy_/"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("MotdEx_ShowNormalMotd", Native_ShowNormalMotd);
    CreateNative("MotdEx_ShowHiddenMotd", Native_ShowHiddenMotd);
    CreateNative("MotdEx_RemoveMotd",     Native_RemoveMotd);
    
    return APLRes_Success;
}

public void OnPluginStart()
{
    g_cvarWebURL = CreateConVar("motdex_url", "https://csgogamers.com/webplugin.php?pid=",  "url of web interface");
    AutoExecConfig(true, "MotdEX", "KyleLu");

    char error[512];
    g_hDatabase = SQL_Connect("motdex", true, error, 512);
    if(g_hDatabase == INVALID_HANDLE)
        SetFailState("connect to database failed: %s", error);
    
    if(!SQL_FastQuery(g_hDatabase, "CREATE TABLE IF NOT EXISTS `webinterface` ( `playerid` int(11) unsigned NOT NULL DEFAULT '0', `show` bit(1) NOT NULL DEFAULT b'0', `width` smallint(6) NOT NULL DEFAULT '1268', `height` smallint(6) unsigned NOT NULL DEFAULT '640', `url` varchar(256) NOT NULL DEFAULT 'https://csgogamers.com/', PRIMARY KEY (`playerid`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;"))
        SetFailState("Check TABLE failed!");
    
    RegPluginLibrary("MotdEx");
}

public int Native_ShowNormalMotd(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);

    if(!IsValidClient(client))
        return false;

    // fix fullscreen.
    int width = GetNativeCell(2)-12;
    int height = GetNativeCell(3)-80;
    char m_szUrl[192];

    if(GetNativeString(4, m_szUrl, 192) != SP_ERROR_NONE)
        return false;

    return UrlToWebInterface(client, width, height, m_szUrl, true);
}

public int Native_ShowHiddenMotd(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);

    if(!IsValidClient(client))
        return false;

    char m_szUrl[192];
    if(GetNativeString(2, m_szUrl, 192) != SP_ERROR_NONE)
        return false;

    return UrlToWebInterface(client, 0, 0, m_szUrl, false);
}

public int Native_RemoveMotd(Handle plugin, int numParams)
{
    int client = GetNativeCell(1);

    if(!IsValidClient(client))
        return false;

    return UrlToWebInterface(client, 0, 0, "https://csgogamers.com/", false);
}

bool UrlToWebInterface(int client, int width, int height, const char[] url, bool show)
{
    char m_szQuery[512], m_szEscape[256];
    SQL_EscapeString(g_hDatabase, url, m_szEscape, 256);
    Format(m_szQuery, 512, "INSERT INTO `webinterface` (`playerid`, `show`, `width`, `height`, `url`) VALUES (%d, %b, %d, %d, '%s') ON DUPLICATE KEY UPDATE `url` = VALUES(`url`), `show`=%b, `width`=%d, `height`=%d", GetSteamAccountID(client, false), show, width, height, m_szEscape, show, width, height);
    SQL_TQuery(g_hDatabase, SQLCallback_WebInterface, m_szQuery, client | (view_as<int>(show) << 7), DBPrio_High);
    return true;
}

public void SQLCallback_WebInterface(Handle owner, Handle hndl, const char[] error, int data)
{
    int client = data & 0x7f;
    bool show = (data >> 7) == 1;

    if(!IsValidClient(client))
        return;

    if(hndl == INVALID_HANDLE)
        return;

    ShowMOTDPanelEx(client, show);
}

void ShowMOTDPanelEx(int client, bool show = true)
{
    char url[192];
    g_cvarWebURL.GetString(url, 192);
    Format(url, 192, "%s%d", url, GetSteamAccountID(client, false));

    Handle m_hKv = CreateKeyValues("data");
    KvSetString(m_hKv, "title", "CSGOGAMERS.COM");
    KvSetNum(m_hKv, "type", MOTDPANEL_TYPE_URL);
    KvSetString(m_hKv, "msg", url);
    KvSetNum(m_hKv, "cmd", 0);
    ShowVGUIPanel(client, "info", m_hKv, show);
    CloseHandle(m_hKv);
}

bool IsValidClient(int client)
{
    return (1 <= client <= MaxClients && IsClientInGame(client) && !IsFakeClient(client));
}
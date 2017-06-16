#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <multicolors>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Webshortcuts - Revamp",
	author = "good_live",
	description = "Allows to display a web Page ingame.",
	version = "0.1",
	url = "painlessgaming.eu"
};

StringMap g_hLinks;
ConVar g_cServerId;
ConVar g_cHost;

char g_sHost[256];

Database g_hDatabase = null;

public void OnPluginStart()
{
	g_cServerId = CreateConVar("web_server_id", "1", "The servers id needs to be unique if you have the same shortcuts with different urls on you servers");
	g_cHost = CreateConVar("web_server_host", "http://exampel.com/redirect.php", "The url to the php file");
	
	g_hLinks = new StringMap();
	
	AutoExecConfig(true);
	
	ConnectDatabase();
	
	LoadConfig();
}

public void OnConfigsExecuted()
{
	g_cHost.GetString(g_sHost, sizeof(g_sHost));
}

public void ConnectDatabase()
{
	if(!SQL_CheckConfig("webshortcuts")){
		SetFailState("Couldn't find the database entry 'webshortcuts'!");
	}else{
		Database.Connect(DBConnect_Callback, "webshortcuts");
	}
}

public void DBConnect_Callback(Database db, const char[] error, any data)
{
	if(db == null){
		SetFailState("Database connection failed!: %s", error);
		return;
	}
	
	g_hDatabase = db;
}

void LoadConfig()
{	
	char sPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/webshortcuts.txt");
	
	Handle hFile = OpenFile(sPath, "r");
	
	char sBuffer[512];
	char sData[2][256];
	
	
	if (hFile != null)
	{
		while(ReadFileLine(hFile, sBuffer, sizeof(sBuffer)))
		{
			ExplodeString(sBuffer, " ", sData, 2, 256);
			TrimString(sData[0]);
			TrimString(sData[1]);
			PrintToServer("Registering shortcut: %s %s", sData[0], sData[1]);
			g_hLinks.SetString(sData[0], sData[1], true);
			RegConsoleCmd(sData[0], CMD_OpenLink);
		}
		CloseHandle(hFile);
	}else{
		SetFailState("Couldn't open file %s", sPath);
	}
}

public Action CMD_OpenLink(int client, int args) 
{
	if(g_hDatabase == null)
	{
		CReplyToCommand(client, "The database is not ready yet.");
		return Plugin_Handled;
	}
	char link[256];
	char command[256];
	GetCmdArg(0, command, sizeof(command));
	g_hLinks.GetString(command, link, sizeof(link));
	SaveLink(client, link);
	return Plugin_Handled;
}

void SaveLink(int client, char[] link)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));
	
	char query[1024];
	Format(query, sizeof(query), "INSERT INTO urls (serverid, steamid, url) VALUES (%i, '%s', '%s') ON DUPLICATE KEY UPDATE url='%s'", g_cServerId.IntValue, steamid, link, link);
	
	g_hDatabase.Query(DB_AddLinkCallback, query, GetClientUserId(client));
}

public void DB_AddLinkCallback(Database db, DBResultSet results, const char[] error, any data)
{
	if(strlen(error) > 0 || results == INVALID_HANDLE){
		LogError("Query failed: %s", error);
		return;
	}
	
	int client = GetClientOfUserId(data);

	if(!client)
		return;
	
	OpenLink(client);
}

void OpenLink(int client)
{
	char steamid[64];
	GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid));
	char url[512];
	Format(url, sizeof(url), "%s?serverid=%i&userid=%s", g_sHost, g_cServerId.IntValue, steamid);
	ShowMOTDPanel(client, "Test", url, MOTDPANEL_TYPE_URL);
	ReplyToCommand(client, "[WebShortCuts] Opening Link %s", url);
}

#if defined _MotdEx_INCLUDED
    #endinput
#endif

#define _MotdEx_INCLUDED

public SharedPlugin __pl_MotdEx = 
{
	name = "Motd Extended",
	file = "motdex.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

native void MotdEx_RemoveMotd(int client);
native bool MotdEx_ShowHiddenMotd(int client, const char[] url);
native bool MotdEx_ShowNormalMotd(int client, int width, int height, const char[] url);
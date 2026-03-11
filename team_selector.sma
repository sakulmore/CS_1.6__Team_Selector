#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN_NAME     "Team Selector"
#define PLUGIN_VERSION  "1.0"
#define PLUGIN_AUTHOR   "sakulmore"

new g_szNameT[64] = "Terrorists"
new g_szNameCT[64] = "Counter-Terrorists"
new g_szNameSpec[64] = "Spectators"

new g_pCvarMotd

public plugin_init() {
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
    
    g_pCvarMotd = register_cvar("ts_show_motd", "1")
    
    register_clcmd("chooseteam", "Cmd_ChooseTeam")
    register_clcmd("jointeam", "Cmd_ChooseTeam")
    
    register_message(get_user_msgid("VGUIMenu"), "Msg_VGUIMenu")
    register_message(get_user_msgid("ShowMenu"), "Msg_ShowMenu")
    
    register_message(get_user_msgid("MOTD"), "Msg_MOTD")
    
    LoadConfig()
}

public Cmd_ChooseTeam(id) {
    ShowCustomMenu(id)
    return PLUGIN_HANDLED
}

public Msg_MOTD(msgid, dest, id) {
    if (get_pcvar_num(g_pCvarMotd) == 0) {
        return PLUGIN_HANDLED
    }
    return PLUGIN_CONTINUE
}

public Msg_VGUIMenu(msgid, dest, id) {
    new menuId = get_msg_arg_int(1)
    
    if (menuId == 2) {
        ShowCustomMenu(id)
        return PLUGIN_HANDLED
    }
    if (menuId == 26 || menuId == 27) {
        return PLUGIN_HANDLED
    }
    
    return PLUGIN_CONTINUE
}

public Msg_ShowMenu(msgid, dest, id) {
    new szMenuCode[32]
    get_msg_arg_string(4, szMenuCode, charsmax(szMenuCode))
    
    if (equal(szMenuCode, "Team_Select")) {
        ShowCustomMenu(id)
        return PLUGIN_HANDLED
    }
    if (equal(szMenuCode, "Terrorist_Select") || equal(szMenuCode, "CT_Select")) { 
        return PLUGIN_HANDLED
    }
    
    return PLUGIN_CONTINUE
}

public ShowCustomMenu(id) {
    new menu = menu_create("\yTeam Selector", "MenuHandler_Team")
    
    menu_additem(menu, g_szNameT, "1")
    menu_additem(menu, g_szNameCT, "2")
    menu_additem(menu, g_szNameSpec, "3")
    
    menu_setprop(menu, MPROP_EXITNAME, "Exit")
    
    menu_display(id, menu, 0)
}

public MenuHandler_Team(id, menu, item) {
    if (item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }
    
    new data[6], iName[64], access, callback
    menu_item_getinfo(menu, item, access, data, charsmax(data), iName, charsmax(iName), callback)
    
    new choice = str_to_num(data)
    switch (choice) {
        case 1: {
            engclient_cmd(id, "jointeam", "1")
            engclient_cmd(id, "joinclass", "5")
        }
        case 2: {
            engclient_cmd(id, "jointeam", "2")
            engclient_cmd(id, "joinclass", "5")
        }
        case 3: {
            engclient_cmd(id, "jointeam", "6")
        }
    }
    
    menu_destroy(menu)
    return PLUGIN_HANDLED
}

LoadConfig() {
    new szDataDir[128], szFile[128]
    get_localinfo("amxx_datadir", szDataDir, charsmax(szDataDir))
    formatex(szFile, charsmax(szFile), "%s/teams.cfg", szDataDir)
    
    if (!file_exists(szFile)) {
        new file = fopen(szFile, "wt")
        if (file) {
            fprintf(file, "; Here you can rewrite the names of the teams.%c", 10)
            fprintf(file, ";%c", 10)
            fprintf(file, "Terrorists=^"Terrorists^"%c", 10)
            fprintf(file, "Counter-Terrorists=^"Counter-Terrorists^"%c", 10)
            fprintf(file, "Spectators=^"Spectators^"%c", 10)
            fclose(file)
        }
        return
    }
    
    new file = fopen(szFile, "rt")
    if (file) {
        new szLine[128], szKey[64], szValue[64]
        while (!feof(file)) {
            fgets(file, szLine, charsmax(szLine))
            trim(szLine)
            
            if (szLine[0] == ';' || !szLine[0]) {
                continue
            }
            
            strtok(szLine, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
            trim(szKey)
            trim(szValue)
            remove_quotes(szValue)
            
            if (equal(szKey, "Terrorists")) {
                copy(g_szNameT, charsmax(g_szNameT), szValue)
            } else if (equal(szKey, "Counter-Terrorists")) {
                copy(g_szNameCT, charsmax(g_szNameCT), szValue)
            } else if (equal(szKey, "Spectators")) {
                copy(g_szNameSpec, charsmax(g_szNameSpec), szValue)
            }
        }
        fclose(file)
    }
}
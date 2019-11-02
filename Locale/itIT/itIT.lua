
KiwiItemInfo.Locale["itIT"] = {
	["TOOLTIP_UNIT"] = "Unità: ",
	["TOOLTIP_STACK"] = "Stack:",
	["TOOLTIP_ILVL"] = "iLvl ",
	["TOOLTIP_PRY_EQUIP"] = "Attr.: ",
	["TOOLTIP_PRY_USE"] = "USA: ",
	["TOOLTIP_PRY_CHANCE"] = "PROBABILITÀ : ",
	["TOOLTIP_CMP_AGILITY"] = "[+-]%d+%s[AGILITÀ]+",
	["TOOLTIP_PRY_AGILITY"] = "AGILITÀ",
	["TOOLTIP_IC_AGILITY"] = "Agilità",
	["TOOLTIP_CMP_STAMINA"] = "[+-]%d+%s[STAMINA]+",
	["TOOLTIP_PRY_STAMINA"] = "STAMINA",
	["TOOLTIP_IC_STAMINA"] = "Stamina",
	["TOOLTIP_CMP_STRENGTH"] = "[+-]%d+%s[FORZA]+",
	["TOOLTIP_PRY_STRENGTH"] = "FORZA",
	["TOOLTIP_IC_STRENGTH"] = "Forza",
	["TOOLTIP_CMP_INTELLECT"] = "[+-]%d+%s[Intelletto]+",
	["TOOLTIP_PRY_INTELLECT"] = "INTELLETTO",
	["TOOLTIP_IC_INTELLECT"] = "Intelletto",
	["TOOLTIP_CMP_SPIRIT"] = "[+-]%d+%s[Spirito]+",
	["TOOLTIP_PRY_SPIRIT"] = "SPIRITO",
	["TOOLTIP_IC_SPIRIT"] = "Spirito",
	["TOOLTIP_CMP_ARMOR"] = "%d+%s[ARMATURA]+",
	["TOOLTIP_PRY_ARMOR"] = "ARMATURA",
	["TOOLTIP_IC_ARMOR"] = "Armatura",
	["TOOLTIP_CMP_BLOCK"] = "%d+%s[BLOCCO]+",
	["TOOLTIP_PRY_BLOCK"] = "BLOCCO",
	["TOOLTIP_IC_BLOCK"] = "Blocco",
	["TOOLTIP_CMP_DURABILITY"] = "[DURABILITÀ]+%s%d+%s/%s%d+",
	["TOOLTIP_PRY_DURABILITY"] = "DURABILITÀ",
	["TOOLTIP_IC_DURABILITY"] = "Durabilità",
	["TOOLTIP_CMP_DPS"] = "%(%d+%.%d+%s[DANNI AL SECONDO]+%)",
	["TOOLTIP_PRY_DPS"] = "DANNI AL SECONDO",
	["TOOLTIP_IC_DPS"] = "DAS",
	["TOOLTIP_CMP_DAMAGE"] = "%d+%s%-%s%d+%s[DANNO]+",
	["TOOLTIP_PRY_DAMAGE"] = "DANNO",
	["TOOLTIP_IC_DAMAGE"] = "Danno",
	["TOOLTIP_CMP_DODGE"] = "[+-]%d+%%%s[SCHIVATA]+",
	["TOOLTIP_PRY_DODGE"] = "SCHIVATA",
	["TOOLTIP_IC_DODGE"] = "Schivata",
	["TOOLTIP_CMP_ARCANE"] = "[+-]%d+%s[ARCANA RESISTENZA]+",
	["TOOLTIP_PRY_ARCANE"] = "ARCANA RESISTENZA",
	["TOOLTIP_IC_ARCANE"] = "Arcana Resistenza",
	["TOOLTIP_CMP_FIRE"] = "[+-]%d+%s[RESISTENZA AL FUOCO]+",
	["TOOLTIP_PRY_FIRE"] = "RESISTENZA AL FUOCO",
	["TOOLTIP_IC_FIRE"] = "Resistenza al Fuoco",
	["TOOLTIP_CMP_FROST"] = "[+-]%d+%s[RESISTENZA AL GHIACCIO]+",
	["TOOLTIP_PRY_FROST"] = "RESISTENZA AL GHIACCIO",
	["TOOLTIP_IC_FROST"] = "Resistenza al Ghiaccio",
	["TOOLTIP_CMP_NATURE"] = "[+-]%d+%s[RESISTENZA DELLA NATURA]+",
	["TOOLTIP_PRY_NATURE"] = "RESISTENZA DELLA NATURA",
	["TOOLTIP_IC_NATURE"] = "Resistenza della Natura",
	["TOOLTIP_CMP_SHADOW"] = "[+-]%d+%s[RESISTENZA OMBRA]+",
	["TOOLTIP_PRY_SHADOW"] = "RESISTENZA OMBRA",
	["TOOLTIP_IC_SHADOW"] = "Resistenza Ombra",
	["TOOLTIP_IC_DAMAGE_DELTA"] = " Danno (delta: ",
	["TOOLTIP_ITEM_COMPARE"] = "Kiwi consiglia:",
	["COMMAND_ERROR_ARG_LEN"] = "Kiwi Item Info: numero parametri non valido.",
	["COMMAND_RELOAD"] = "Ricarico KiwiItemInfo...",
	["COMMAND_RELOAD_DONE"] = "Completato! :D Kiwi è vivo!",
	["COMMAND_RESET"] = "Resetto KiwiItemInfo...",
	["COMMAND_VARS_DUMP"] = "Caricamento impostazioni utente...",
	["COMMAND_VARS_DONE"] = "Fatto!",
	["COMMAND_SET_ERROR_BOOLEAN"] = "Kiwi si aspetta un valore booleano (true/false). Scusa.",
	["COMMAND_SET_ERROR_NUMBER"] = "Kiwi si aspetta un numero. Scusa.",
	["COMMAND_SET_ERROR_STRING"] = "Kiwi si aspetta una stringa (words). Scusa.",
	["COMMAND_SET_ERROR_VAR"] = "Kiwi non conosce questa variabile. Scusa.",
	["COMMAND_SET_ERROR_VALUE"] = "Kiwi ha bisogno di avere un valore per la variabile...",
	["COMMAND_SET_ERROR_INDEX"] = "Kiwi ha bisogno di avere la variabile settata...",
	["COMMAND_SEARCH_ARG_LEN"] = "Kiwi Item Info: Numero dei parametri non valido",
	["COMMAND_SEARCH_ONE_HANDED"] = "One-Handed ",
	["COMMAND_SEARCH_TWO_HANDED"] = "Two-Handed ",
	["COMMAND_SEARCH_1H"] = "One",
	["COMMAND_SEARCH_2H"] = "Two",
	["COMMAND_SEARCH_DONE"] = "Kiwi dice `Questo è il tuo oggetto`:",
	["COMMAND_SEARCH_DONE1"] = "Kiwi che figo. Kiwi sto volando! kiwi trovato ",
	["COMMAND_SEARCH_FAIL"] = "Kiwi non riesce a trovare niente! :(",
	["KIWIII_HELP"] = "aiuto",
	["KIWIII_RELOAD"] = "ricaricare",
	["KIWIII_RESET"] = "ripristina",
	["KIWIII_VARS"] = "vars",
	["KIWIII_SET"] = "set",
	["KIWIII_ACI"] = "aci",
	["KIWIII_SEARCH"] = "ricerca",
}


local temp = KiwiItemInfo.Locale["itIT"]

temp["COMMAND_SEARCH_ERROR_DB"] = "Kiwi declines usage of `/kiwiii " .. temp["KIWIII_SEARCH"] .. "` (due to lack of loading the database?)",
temp["KII_BAD_DB"] = "Kiwi's Item Info database wasn't loaded! Not using `/kiwiii " .. temp["KIWIII_SEARCH"] .. "` command.",
temp["KII_HELP"] = "Please run `/kiwiii " .. temp["KIWIII_HELP"] .. "` for a command listing!",
temp["KII_THANKS"] = "Kiwi thanks you for installing KiwiItemInfo " .. KiwiItemInfo._VERSION .. "! <3",
temp["COMMAND_HELP1"] = "Kiwi Item Info " .. KiwiItemInfo._VERSION .. " -- aiuto",
temp["COMMAND_HELP2"] = "https://github.com/tilkinsc/KiwiItemInfo - for issue/bug reports",
temp["COMMAND_HELP3"] = "Manuale: /kiwiii [" .. temp["KIWIII_RELOAD"] .. "] [" .. temp["KIWIII_RESET"]  .. "] [" .. temp["KIWIII_VARS"] .. "] [" .. temp["KIWIII_ACI"] .. "]",
temp["COMMAND_HELP4"] = "               [" .. temp["KIWIII_SET"] .. " variable_name value]",
temp["COMMAND_HELP5"] = "               [" .. temp["KIWIII_SEARCH"] .. " ${=,>,<}num, #Type, @subtype, {itemid, itemname}]",
temp["COMMAND_HELP6"] = "    > |cFF888888" .. temp["KIWIII_HELP"] .. "|r -- for this message",
temp["COMMAND_HELP7"] = "    > |cFF888888" .. temp["KIWIII_RELOAD"] .. "|r -- reloads addon",
temp["COMMAND_HELP8"] = "    > |cFF888888" .. temp["KIWIII_RESET"]  .. "|r -- resets all saved variables, also reloads",
temp["COMMAND_HELP9"] = "    > |cFF888888" .. temp["KIWIII_VARS"] .. "|r -- shows all setting variables",
temp["COMMAND_HELP10"] = "    > |cFF888888" .. temp["KIWIII_SET"] .. "|r -- toggles a setting",
temp["COMMAND_HELP11"] = "        * |cFFBBBBBBvariable_name|r -- variable shown in /kiwiii " .. temp["KIWIII_VARS"],
temp["COMMAND_HELP12"] = "        * |cFFBBBBBBvalue|r -- either true, false, string, or number",
temp["COMMAND_HELP13"] = "    > |cFF888888" .. temp["KIWIII_ACI"] .. "|r -- toggles alwaysCompareItems CVar",
temp["COMMAND_HELP14"] = "    > |cFF888888" .. temp["KIWIII_SEARCH"] .. "|r -- searches through item database for items",
temp["COMMAND_HELP15"] = "        * |cFFBBBBBB${=,>,<}num|r -- show only items of ilvl equal, bigger or smaller than 'num'",
temp["COMMAND_HELP16"] = "        * |cFFBBBBBB#Type|r -- shows by type (Armor, Weapon, etc)",
temp["COMMAND_HELP17"] = "        * |cFFBBBBBB@SubType|r -- shows by subtype (Mail, 1HSwords, 2HSwords, etc)",
temp["COMMAND_HELP18"] = "        * |cFFBBBBBBitemid|r -- search for items",
temp["COMMAND_HELP19"] = "        * |cFFBBBBBBitemname|r -- search for items",



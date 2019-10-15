--[[
 * KiwiItemInfo
 * 
 * MIT License
 * 
 * Copyright (c) 2017-2019 Cody Tilkins
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
--]]



local printi = KiwiItemInfo.printi
local L = KiwiItemInfo.L

KiwiItemInfo.LoadVars = function()
	if(KiwiItemInfo_Vars == nil) then
		KiwiItemInfo_Vars = {
			["vars"] = {}
		}
	end
	for i, v in next, KiwiItemInfo._DEFAULT_VARS do
		if(i ~= "vars" and KiwiItemInfo_Vars[i] == nil) then
			KiwiItemInfo_Vars[i] = v
		end
	end
	for i, v in next, KiwiItemInfo._DEFAULT_VARS.vars do
		if(KiwiItemInfo_Vars.vars[i] == nil) then
			KiwiItemInfo_Vars.vars[i] = v
		end
	end
	-- check if anything removed
	for i, v in next, KiwiItemInfo_Vars do
		if(i ~= "vars" and KiwiItemInfo._DEFAULT_VARS[i] == nil) then
			KiwiItemInfo_Vars[i] = nil
		end
	end
	for i, v in next, KiwiItemInfo_Vars.vars do
		if(KiwiItemInfo._DEFAULT_VARS.vars[i] == nil) then
			KiwiItemInfo_Vars.vars[i] = nil
		end
	end
	KiwiItemInfo_Vars.VERSION = KiwiItemInfo._VERSION
end

-- Disables the plugin
KiwiItemInfo.Disable = function()
	
	SlashCmdList["KIWIITEMINFO_CMD"] = nil
	SLASH_KIWIITEMINFO_CMD1 = nil
	
	GameTooltip:SetScript("OnTooltipSetItem", nil)
	ItemRefTooltip:SetScript("OnTooltipSetItem", nil)
	ShoppingTooltip1:SetScript("OnTooltipSetItem", nil)
	ShoppingTooltip2:SetScript("OnTooltipSetItem", nil)
	ItemRefShoppingTooltip1:SetScript("OnTooltipSetItem", nil)
	ItemRefShoppingTooltip2:SetScript("OnTooltipSetItem", nil)
	
	KiwiItemInfo.EventFrame:UnregisterEvent("MODIFIER_STATE_CHANGED")
	KiwiItemInfo.Events["MODIFIER_STATE_CHANGED"] = nil
	
end

-- Enables the plugin
KiwiItemInfo.Enable = function()
	
	KiwiItemInfo.LoadVars()
	
	if(KiwiItemInfo_Vars["first_run"]) then
		KiwiItemInfo_Vars["first_run"] = false
		
		printi(0, L"KII_THANKS")
		printi(0, L"KII_HELP")
	end
	
	-- ensure database is present, if user wants it
	KiwiItemInfo_Vars["search_cmd_state"] = true
	if(KiwiItemInfo.Database == nil) then
		printi(1, L"KII_BAD_DB")
		KiwiItemInfo_Vars["search_cmd_state"] = false
	end
	
	
	-- commands
	SlashCmdList["KIWIITEMINFO_CMD"] = KiwiItemInfo.Command
	SLASH_KIWIITEMINFO_CMD1 = "/kiwiii"
	
	
	-- tooltip events
	GameTooltip:SetScript("OnTooltipSetItem", KiwiItemInfo.ShowItemInfo)
	ItemRefTooltip:SetScript("OnTooltipSetItem", KiwiItemInfo.ShowItemInfo)
	
	local item_info_compare = function(tooltip)
		KiwiItemInfo.ShowItemInfo(tooltip)
		KiwiItemInfo.SetItemCompare(GameTooltip, "GameTooltipText", tooltip, tooltip:GetName() .. "Text")
	end
	
	ShoppingTooltip1:SetScript("OnTooltipSetItem", item_info_compare)
	ShoppingTooltip2:SetScript("OnTooltipSetItem", item_info_compare)
	ItemRefShoppingTooltip1:SetScript("OnTooltipSetItem", item_info_compare)
	ItemRefShoppingTooltip2:SetScript("OnTooltipSetItem", item_info_compare)
	
	-- bag events
	KiwiItemInfo.Events["MODIFIER_STATE_CHANGED"] = function(key, state)
		if(key == KiwiItemInfo_Vars.vars["flash_hotkey"] and state == 1) then
			KiwiItemInfo.ShowJunk()
			return
		end
	end

	KiwiItemInfo.EventFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
	
end



-- Default event dispatcher
local ADDON_LOADED = function(addon)
	if(addon ~= "KiwiItemInfo") then
		return
	end
	
	KiwiItemInfo.Enable()
end

-- hooks and events
KiwiItemInfo.Events = {
	["ADDON_LOADED"] = ADDON_LOADED
}


local KiwiItemInfo_EventFrame = CreateFrame("Frame")
KiwiItemInfo.EventFrame = KiwiItemInfo_EventFrame

KiwiItemInfo_EventFrame:RegisterEvent("ADDON_LOADED")
KiwiItemInfo_EventFrame:SetScript("OnEvent", function(self, event, ...)
	KiwiItemInfo.Events[event](...)
end)





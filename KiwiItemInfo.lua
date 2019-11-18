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
local L = KiwiItemInfo.LocaleStrings()

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
	
	KiwiItemInfo.EventFrame:UnregisterEvent("MODIFIER_STATE_CHANGED")
	KiwiItemInfo.Events["MODIFIER_STATE_CHANGED"] = nil
	
end

-- Enables the plugin
KiwiItemInfo.Enable = function()
	
	KiwiItemInfo.LoadVars()
	
	if(KiwiItemInfo_Vars["first_run"]) then
		KiwiItemInfo_Vars["first_run"] = false
		
		printi(0, L["KII_THANKS"])
		printi(0, L["KII_HELP"])
	end
	
	-- ensure database is present, if user wants it
	KiwiItemInfo_Vars["search_cmd_state"] = true
	if(KiwiItemInfo.Database == nil) then
		printi(1, L["KII_BAD_DB"])
		KiwiItemInfo_Vars["search_cmd_state"] = false
	end
	
	-- commands
	SlashCmdList["KIWIITEMINFO_CMD"] = KiwiItemInfo.Command
	SLASH_KIWIITEMINFO_CMD1 = "/kiwiii"
	
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
	
	local VarsUI = KiwiItemInfo.VarsUI
	VarsUI.Init()
	VarsUI.AddComponent(3, "Flash Grey Items:",
		function(self)
			self:SetChecked(KiwiItemInfo_Vars.vars["flash_grey_items"])
		end,
		function(self, button, down)
			KiwiItemInfo_Vars.vars["flash_grey_items"] = self:GetChecked()
		end
	)
	VarsUI.AddComponent(2, "Flash Hotkey:",
		function(self)
			self:SetText(KiwiItemInfo_Vars.vars["flash_hotkey"])
		end, 
		function(self)
			self:ClearFocus()
			KiwiItemInfo_Vars.vars["flash_hotkey"] = self:GetText()
		end
	)
	VarsUI.Blank()
	VarsUI.AddComponent(3, "Item Compare On:",
		function(self)
			self:SetChecked(KiwiItemInfo_Vars.vars["item_compare_on"])
		end,
		function(self, button, down)
			KiwiItemInfo_Vars.vars["item_compare_on"] = self:GetChecked()
		end
	)
	VarsUI.AddComponent(3, "Verbose Item Compare:",
		function(self)
			self:SetChecked(KiwiItemInfo_Vars.vars["item_compare_extra"])
		end,
		function(self, button, down)
			KiwiItemInfo_Vars.vars["item_compare_extra"] = self:GetChecked()
		end
	)
	VarsUI.Blank()
	VarsUI.AddComponent(3, "Item Vendor Price:",
		function(self)
			self:SetChecked(KiwiItemInfo_Vars.vars["tooltip_price_on"])
		end,
		function(self, button, down)
			KiwiItemInfo_Vars.vars["tooltip_price_on"] = self:GetChecked()
		end
	)
	VarsUI.Blank()
	VarsUI.AddComponent(3, "Show iLvl:",
		function(self)
			self:SetChecked(KiwiItemInfo_Vars.vars["tooltip_ilvl_on"])
		end,
		function(self, button, down)
			KiwiItemInfo_Vars.vars["tooltip_ilvl_on"] = self:GetChecked()
		end
	)
	VarsUI.AddComponent(3, "Show iLvl On Items:",
		function(self)
			self:SetChecked(not KiwiItemInfo_Vars.vars["ilvl_only_equips"])
		end,
		function(self, button, down)
			KiwiItemInfo_Vars.vars["ilvl_only_equips"] = not self:GetChecked()
		end
	)
	VarsUI.AddComponent(3, "Default iLvl Coloration:",
		function(self)
			self:SetChecked(KiwiItemInfo_Vars.vars["tooltip_ilvl_colors"])
		end,
		function(self, button, down)
			KiwiItemInfo_Vars.vars["tooltip_ilvl_colors"] = self:GetChecked()
		end
	)
	VarsUI.AddComponent(2, "Custom iLvl Color:",
		function(self)
			self:SetText(KiwiItemInfo_Vars.vars["tooltip_ilvl_nocolors_rgb"])
		end, 
		function(self)
			self:ClearFocus()
			local text = self:GetText()
			if(text:match("%d+%s%d+%s%d+") or text:match("%d+%.%d+%s%d+%.%d+%s%d+%.%d+")) then
				KiwiItemInfo_Vars.vars["tooltip_ilvl_nocolors_rgb"] = self:GetText()
			else
				-- TODO: error message
			end
		end
	)
	VarsUI:Hide()
	
	-- tooltip events
	GameTooltip:HookScript("OnTooltipSetItem", KiwiItemInfo.ShowItemInfo)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", KiwiItemInfo.ShowItemInfo)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", KiwiItemInfo.ShowItemInfo)
	ItemRefTooltip:HookScript("OnTooltipSetItem", KiwiItemInfo.ShowItemInfo)
	ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", KiwiItemInfo.ShowItemInfo)
	ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", KiwiItemInfo.ShowItemInfo)
	
	-- item compare
	GameTooltip:HookScript("OnTooltipSetItem", function(tooltip)
		KiwiItemInfo.SetItemCompare(1, tooltip, tooltip:GetName() .. "Text")
	end)
	GameTooltip:HookScript("OnTooltipCleared", function(tooltip)
		KiwiItemInfo.ClearItemCompare(1, tooltip)
	end)
	
	ShoppingTooltip1:HookScript("OnTooltipSetItem", function(tooltip)
		KiwiItemInfo.SetItemCompare(2, tooltip, tooltip:GetName() .. "Text")
		KiwiItemInfo.DisplayItemCompare(GameTooltip, ShoppingTooltip1, 1)
	end)
	ShoppingTooltip1:HookScript("OnTooltipCleared", function(tooltip)
		KiwiItemInfo.ClearItemCompare(2, tooltip)
	end)
	
	ShoppingTooltip2:HookScript("OnTooltipSetItem", function(tooltip)
		KiwiItemInfo.SetItemCompare(3, tooltip, tooltip:GetName() .. "Text")
	end)
	ShoppingTooltip2:HookScript("OnTooltipCleared", function(tooltip)
		KiwiItemInfo.ClearItemCompare(3, tooltip)
	end)
	
	ItemRefTooltip:HookScript("OnTooltipSetItem", function(tooltip)
		KiwiItemInfo.SetItemCompare(4, tooltip, tooltip:GetName() .. "Text")
	end)
	ItemRefTooltip:HookScript("OnTooltipCleared", function(tooltip)
		KiwiItemInfo.ClearItemCompare(4, tooltip)
	end)
	
	ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", function(tooltip)
		KiwiItemInfo.SetItemCompare(5, tooltip, tooltip:GetName() .. "Text")
		KiwiItemInfo.DisplayItemCompare(ItemRefTooltip, ItemRefShoppingTooltip1, 2)
	end)
	ItemRefShoppingTooltip1:HookScript("OnTooltipCleared", function(tooltip)
		KiwiItemInfo.ClearItemCompare(5, tooltip)
	end)
	
	ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", function(tooltip)
		KiwiItemInfo.SetItemCompare(6, tooltip, tooltip:GetName() .. "Text")
		KiwiItemInfo.DisplayItemCompare(ItemRefTooltip, ItemRefShoppingTooltip1, 2)
	end)
	ItemRefShoppingTooltip2:HookScript("OnTooltipCleared", function(tooltip)
		KiwiItemInfo.ClearItemCompare(6, tooltip)
	end)
	
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





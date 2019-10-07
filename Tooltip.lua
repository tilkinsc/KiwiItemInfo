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



-- Adds item data to tooltips
KiwiItemInfo.ShowItemInfo = function(tooltip)
	
	local i_name, i_link = tooltip:GetItem()
	local tooltipName = tooltip:GetName()
	local focus = GetMouseFocus()
	local name = focus:GetName()
	if(i_name == nil or i_name == "" or i_link == nil or i_link == "[]") then
		if(TradeSkillFrame and TradeSkillFrame:IsShown()) then
			if(name and name:find("TradeSkill", 1, 10) == 1) then
				local selection = GetTradeSkillSelectionIndex()
				local reagent = tonumber(name:sub(-1))
				if(reagent ~= nil) then
					i_link = GetTradeSkillReagentItemLink(selection, reagent)
				else
					i_link = GetTradeSkillItemLink(selection)
				end
			end
		elseif(CraftFrame and CraftFrame:IsShown()) then
			if(name and name:find("Craft", 1, 5) == 1) then
				local selection = GetCraftSelectionIndex()
				local reagent = tonumber(name:sub(-1))
				if(reagent ~= nil) then
					i_link = GetCraftReagentItemLink(selection, reagent)
				else
					i_link = GetCraftItemLink(selection)
				end
			end
		end
	end
	
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
			itemStackCount, itemEquipLoc, itemIcon, vendorPrice, itemClassID, itemSubClassID,
			bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(i_link)
	
	if(KiwiItemInfo_Vars.vars["tooltip_price_on"] == true) then
		if(not MerchantFrame:IsShown() and (vendorPrice and vendorPrice > 0)) then
			if(itemStackCount > 1) then
				local count = focus.count or (focus.Count and tonumber(focus.Count:GetText()) or 1)
				itemStackCount = (type(count) == "number") and count or 1
				if(itemStackCount > 1) then
					SetTooltipMoney(tooltip, vendorPrice, nil, "Unit: ")
					SetTooltipMoney(tooltip, vendorPrice * itemStackCount, nil, "Stack:")
				else
					SetTooltipMoney(tooltip, vendorPrice, nil, "")
				end
			else
				SetTooltipMoney(tooltip, vendorPrice, nil, "")
			end
		end
	end
	
	if(KiwiItemInfo_Vars.vars["tooltip_ilvl_on"] == true) then
		if(itemLevel) then
			if(itemType == "Weapon" or itemType == "Armor" or KiwiItemInfo_Vars.vars["ilvl_only_equips"] == false) then
				
				local tooltipiLvl = _G[tooltipName .. "TextRight1"]
				
				local playerLevel = UnitLevel("player")
				
				if(playerLevel <= itemLevel) then
					tooltipiLvl:SetTextColor(0.9375, 0, 0) -- red
				elseif(itemLevel > playerLevel - 3) then
					tooltipiLvl:SetTextColor(0.9375, 0.5, 0) -- orange
				elseif(itemLevel > playerLevel - 5) then
					tooltipiLvl:SetTextColor(0.9375, 0.9375, 0) -- yellow
				elseif(itemLevel > playerLevel - 9) then
					tooltipiLvl:SetTextColor(0, 0.875, 0) -- green
				else
					tooltipiLvl:SetTextColor(0.5, 0.5, 0.5) -- grey
				end
				
				tooltipiLvl:SetText("iLvl " .. itemLevel)
				tooltipiLvl:Show()
			end
		end
	end
	
end

-- Parses tooltip text for item stats
KiwiItemInfo.PryItemStats = function(tooltip, index)
	
	local lines = tooltip:NumLines()
	
	-- basic stats
	local agility = 0
	local stamina = 0
	local strength = 0
	local intellect = 0
	local spirit = 0
	
	-- attack/defense
	local armor = 0
	local block = 0
	local dps = 0
	local min_dmg = 0
	local max_dmg = 0
	local durability = 0
	
	-- special
	local dodge = 0
	local parry = 0
	
	-- resistance
	local arcane_resist = 0
	local fire_resist = 0
	local frost_resist = 0
	local holy_resist = 0
	local nature_resist = 0
	local shadow_resist = 0
	
	-- equips
	local equips = {}
	
	for i=1, lines do
		local v = _G[index .. "Left" .. i]
		if(not v) then
			break
		end
		
		local text = v:GetText()
		if(text) then
			local sp = {string.split(" ", text)}
			
			for i=1, #sp do
				if(sp[i]:find("|c")) then
					sp[i] = sp[i]:sub(11)
				end
				if(sp[i]:find("|r")) then
					sp[i] = sp[i]:sub(1, -3)
				end
			end
			
			if(text:find("Equip: ")) then
				table.insert(equips, table.concat(sp, " "))
			end
			
			-- basic stats
			if(sp[2] == "Agility") then
				agility = tonumber(sp[1])
			elseif(sp[2] == "Stamina") then
				stamina = tonumber(sp[1])
			elseif(sp[2] == "Strength") then
				strength = tonumber(sp[1])
			elseif(sp[2] == "Intellect") then
				intellect = tonumber(sp[1])
			elseif(sp[2] == "Spirit") then
				spirit = tonumber(sp[1])
			
			-- defense
			elseif(sp[2] == "Armor") then
				armor = tonumber(sp[1])
			elseif(sp[2] == "Block") then
				block = tonumber(sp[1])
			elseif(sp[2] == "Durability") then
				durability = tonumber(sp[4])
			
			-- attack
			elseif(text:find("damage per second")) then
				dps = tonumber((sp[1]):sub(2))
			elseif(sp[4] == "Damage") then
				min_dmg = tonumber(sp[1])
				max_dmg = tonumber(sp[3])
			
			-- special
			elseif(sp[2] == "Dodge") then
				dodge = tonumber(string.gsub(sp[1], "%%", ""))
			elseif(sp[2] == "Parry") then
				dodge = tonumber(string.gsub(sp[1], "%%", ""))
			
			-- resistance
			elseif(sp[2] == "Arcane" and sp[3] == "Resistance") then
				arcane_resist = tonumber(sp[1])
			elseif(sp[2] == "Fire" and sp[3] == "Resistance") then
				fire_resist = tonumber(sp[1])
			elseif(sp[2] == "Frost" and sp[3] == "Resistance") then
				frost_resist = tonumber(sp[1])
			elseif(sp[2] == "Holy" and sp[3] == "Resistance") then
				holy_resist = tonumber(sp[1])
			elseif(sp[2] == "Holy" and sp[3] == "Resistance") then
				nature_resist = tonumber(sp[1])
			elseif(sp[2] == "Arcane" and sp[3] == "Resistance") then
				shadow_resist = tonumber(sp[1])
			end
		end
	end
	
	-- basic stats, attack/defense, special, resistence
	return {Agility = agility, Stamina = stamina, Strength = strength, Intellect = intellect, Spirit = spirit},
		   {Armor = armor, Block = block, Durability = durability},
		   {dps = dps, min_dmg = min_dmg, max_dmg = max_dmg},
		   {Dodge = dodge, Parry = parry},
		   {["Arcane Resistance"] = arcane_resist, ["Fire Resistance"] = fire_resist, ["Frost Resistance"] = frost_resist, ["Holy Resistance"] = holy_resist, ["Nature Resistance"] = nature_resist, ["Shadow Resistance"] = shadow_resist},
		   equips
	
end

-- Tacks on to the end of tooltips the differences between two items stats
KiwiItemInfo.SetItemCompare = function(base, base_root, test, test_root)
	
	if(KiwiItemInfo_Vars.vars["item_compare_on"] == false) then
		return
	end
	
	local basic1, def1, att1, special1, resist1, equips1, enchants1 = KiwiItemInfo.PryItemStats(base, base_root)
	local basic2, def2, att2, special2, resist2, equips2, enchants2 = KiwiItemInfo.PryItemStats(test, test_root)
	
	test:AddLine(" ")
	
	test:AddLine("Kiwi says equipping will do this:", 0.06666, 0.6, 0.06666, true)
	
	local line_added = false
	
	
	-- min/max attack
	do
		local min = att1.min_dmg - att2.min_dmg
		local max = att1.max_dmg - att2.max_dmg
		
		if(min ~= 0 or max ~= 0) then
			test:AddLine(((min > 0) and string.format("|cFF00FF00+%s|r", min) or string.format("|cFFFF0000%s|r", min))
						.. " / "
						.. ((max > 0) and string.format("|cFF00FF00+%s|r", max) or string.format("|cFFFF0000%s|r", max))
						.. " Damage (delta: " .. math.abs(max - min) .. ")")
			line_added = true
		end
	end
	
	-- dps
	do
		local calc = att1.dps - att2.dps
		if(calc ~= 0) then
			test:AddLine((calc > 0 and "+" or "") .. calc .. " dps", calc > 0 and 0 or 1, calc > 0 and 1 or 0, 0, true)
			line_added = true
		end
	end
	
	for i, _ in next, def1 do
		local calc = def1[i] - def2[i]
		if(calc ~= 0) then
			line_added = true
			test:AddLine((calc > 0 and "+" or "") .. calc .. " " .. i, calc > 0 and 0 or 1, calc > 0 and 1 or 0, 0, true)
		end
	end
	
	if(line_added) then
		test:AddLine(" ")
		line_added = false
	end
	
	-- basic stats
	for i, _ in next, basic1 do
		local calc = basic1[i] - basic2[i]
		if(calc ~= 0) then
			test:AddLine((calc > 0 and "+" or "") .. calc .. " " .. i, calc > 0 and 0 or 1, calc > 0 and 1 or 0, 0, true)
			line_added = true
		end
	end
	
	if(line_added) then
		test:AddLine(" ")
		line_added = false
	end
	
	-- special
	for i, _ in next, special1 do
		local calc = special1[i] - special1[i]
		if(calc ~= 0) then
			test:AddLine((calc > 0 and "+" or "") .. calc .. " " .. i, calc > 0 and 0 or 1, calc > 0 and 1 or 0, 0, true)
			line_added = true
		end
	end
	
	if(line_added) then
		test:AddLine(" ")
		line_added = false
	end
	
	-- equips
	for i, v in next, equips1 do
		local found = false
		for j, k in next, equips2 do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			test:AddLine(v, 0, 1, 0, true)
		end
	end
	
	for i, v in next, equips2 do
		local found = false
		for j, k in next, equips1 do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			test:AddLine(v, 1, 0, 0, true)
		end
	end
	
end

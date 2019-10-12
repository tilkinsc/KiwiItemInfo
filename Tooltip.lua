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



local L = KiwiItemInfo.L

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
					SetTooltipMoney(tooltip, vendorPrice, nil, L"TOOLTIP_UNIT")
					SetTooltipMoney(tooltip, vendorPrice * itemStackCount, nil, L"TOOLTIP_STACK")
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
				
				tooltipiLvl:SetText(L"TOOLTIP_ILVL" .. itemLevel)
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
	
	-- resistance
	local arcane_resist = 0
	local fire_resist = 0
	local frost_resist = 0
	local holy_resist = 0
	local nature_resist = 0
	local shadow_resist = 0
	
	-- equips
	local equips = {}
	local uses = {}
	
	for i=1, lines do
		local v = _G[index .. "Left" .. i]
		if(not v) then
			break
		end
		
		local raw_text = v:GetText()
		local text = raw_text:upper()
		if(text and #text > 1) then
			
			-- remove line color, if any
			if(text:find("|c", 1, 2) == 1) then
				text = text:sub(11)
			end
			
			-- remove line color return, if any
			if(text:find("|r")) then
				text = text:sub(1, -3)
			end
			
			local tt_agility   = text:match("[+-]%d+%s[" .. L("TOOLTIP_PRY_AGILITY")   .. "]+", 1)
			local tt_stamina   = text:match("[+-]%d+%s[" .. L("TOOLTIP_PRY_STAMINA")   .. "]+", 1)
			local tt_strength  = text:match("[+-]%d+%s[" .. L("TOOLTIP_PRY_STRENGTH")  .. "]+", 1)
			local tt_intellect = text:match("[+-]%d+%s[" .. L("TOOLTIP_PRY_INTELLECT") .. "]+", 1)
			local tt_spirit    = text:match("[+-]%d+%s[" .. L("TOOLTIP_PRY_SPIRIT")    .. "]+", 1)
			
			local tt_armor  = text:match("%d+%s["          .. L("TOOLTIP_PRY_ARMOR")  .. "]+",   1)
			local tt_block  = text:match("%d+%s["          .. L("TOOLTIP_PRY_BLOCK")  .. "]+",   1)
			local tt_dps    = text:match("%(%d+%.%d+%s["   .. L("TOOLTIP_PRY_DPS")    .. "]+%)", 1)
			local tt_damage = text:match("%d+%s%-%s%d+%s[" .. L("TOOLTIP_PRY_DAMAGE") .. "]+",   1)
			
			local tt_durability = text:match("[" .. L("TOOLTIP_PRY_DURABILITY") .. "]+%s%d+%s/%s%d+", 1)
			
			local tt_dodge = text:match("[+-]%d+%%%s[" .. L("TOOLTIP_PRY_DODGE") .. "]+", 1)
			
			local bs_digit = text:gsub("[^(%+%-)%d+]",   "")
			local ss_digit = text:gsub("[^(%+%-)%d+%%]", "")
			local ad_digit = text:gsub("[^%d+]",         "")
			
			local dr_digit = text:gsub("[^%d/%d]", "")
			
			agility   = tt_agility   and tt_agility:find(L"TOOLTIP_PRY_AGILITY")     and (agility + tonumber(bs_digit))   or agility
			stamina   = tt_stamina   and tt_stamina:find(L"TOOLTIP_PRY_STAMINA")     and (stamina + tonumber(bs_digit))   or stamina
			strength  = tt_strength  and tt_strength:find(L"TOOLTIP_PRY_STRENGTH")   and (strength + tonumber(bs_digit))  or strength
			intellect = tt_intellect and tt_intellect:find(L"TOOLTIP_PRY_INTELLECT") and (intellect + tonumber(bs_digit)) or intellect
			spirit    = tt_spirit    and tt_spirit:find(L"TOOLTIP_PRY_SPIRIT")       and (spirit + tonumber(bs_digit))    or spirit
			
			armor = tt_armor and tt_armor:find(L"TOOLTIP_PRY_ARMOR") and (armor + tonumber(ad_digit)) or armor
			block = tt_block and tt_block:find(L"TOOLTIP_PRY_BLOCK") and (block + tonumber(ad_digit)) or block
			
			if(tt_dps and tt_dps:find(L"TOOLTIP_PRY_DPS")) then
				local l = string.split(" ", text)
				l = l:sub(2)
				dps = tt_dps and tt_dps:find(L"TOOLTIP_PRY_DPS") and (dps + tonumber(l)) or dps
			end
			
			if(tt_damage and tt_damage:find(L"TOOLTIP_PRY_DAMAGE")) then
				local l, _, _, r = string.split("- ", text)
				min_dmg = tonumber(l)
				max_dmg = tonumber(r)
			end
			
			if(tt_durability and tt_durability:find(L"TOOLTIP_PRY_DURABILITY")) then
				local l, r = string.split("/", dr_digit)
				durability = (durability + tonumber(r)) or durability
			end
			
			dodge = tt_dodge and tt_dodge:find(L"TOOLTIP_PRY_DODGE") and (dodge + tonumber(ss_digit)) or dodge
			
			if(text:find(L"TOOLTIP_PRY_EQUIP", 1) == 1) then
				table.insert(equips, raw_text)
			end
			
			if(text:find(L"TOOLTIP_PRY_USE", 1) == 1) then
				table.insert(uses, raw_text)
			end
			
		end
		
	end
	
	-- basic stats, attack/defense, special, resistence
	return {dps = dps, min_dmg = min_dmg, max_dmg = max_dmg},
		   {Armor = armor, Block = block, Durability = durability},
	       {Agility = agility, Stamina = stamina, Strength = strength, Intellect = intellect, Spirit = spirit},
		   {Dodge = dodge},
		   {Arcane_Resist = arcane_resist, Fire_Resist = fire_resist, Frost_Resist = frost_resist, Holy_Resist = holy_resist, Nature_Resist = nature_resist, Shadow_Resist = shadow_resist},
		   equips, uses
	
end

-- Tacks on to the end of tooltips the differences between two items stats
KiwiItemInfo.SetItemCompare = function(base, base_root, test, test_root)
	
	if(KiwiItemInfo_Vars.vars["item_compare_on"] == false) then
		return
	end
	
	local att1, def1, basic1, special1, resist1, equips1, uses1 = KiwiItemInfo.PryItemStats(base, base_root)
	local att2, def2, basic2, special2, resist2, equips2, uses2 = KiwiItemInfo.PryItemStats(test, test_root)
	
	test:AddLine(" ")
	
	test:AddLine(L"TOOLTIP_ITEM_COMPARE", 0.06666, 0.6, 0.06666, true)
	
	local line_added = false
	
	
	-- min/max attack
	do
		local min = att1.min_dmg - att2.min_dmg
		local max = att1.max_dmg - att2.max_dmg
		
		if(min ~= 0 or max ~= 0) then
			test:AddLine(((min > 0) and string.format("|cFF00FF00+%s|r", min) or string.format("|cFFFF0000%s|r", min))
						.. " / "
						.. ((max > 0) and string.format("|cFF00FF00+%s|r", max) or string.format("|cFFFF0000%s|r", max))
						.. L("TOOLTIP_IC_DAMAGE_DELTA") .. math.abs(max - min) .. ")")
			line_added = true
		end
	end
	
	-- dps
	do
		local calc = att1.dps - att2.dps
		if(calc ~= 0) then
			test:AddLine((calc > 0 and "+" or "") .. calc .. " " .. L("TOOLTIP_IC_DPS"), calc > 0 and 0 or 1, calc > 0 and 1 or 0, 0, true)
			line_added = true
		end
	end
	
	-- armor/block/durability
	do
		local armor = def1.Armor - def2.Armor
		local block = def1.Block - def2.Block
		local durability = def1.Durability - def2.Durability
		
		if(armor ~= 0) then
			test:AddLine((armor > 0 and "+" or "") .. armor .. " " .. L("TOOLTIP_IC_ARMOR"), armor > 0 and 0 or 1, armor > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(block ~= 0) then
			test:AddLine((block > 0 and "+" or "") .. block .. " " .. L("TOOLTIP_IC_BLOCK"), block > 0 and 0 or 1, block > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(durability ~= 0) then
			test:AddLine((durability > 0 and "+" or "") .. durability .. " " .. L("TOOLTIP_IC_DURABILITY"), durability > 0 and 0 or 1, durability > 0 and 1 or 0, 0, true)
			line_added = true
		end
	end
	
	if(line_added) then
		test:AddLine(" ")
		line_added = false
	end
	
	-- basic stats
	do
		local agility = basic1.Agility - basic2.Agility
		local stamina = basic1.Stamina - basic2.Stamina
		local strength = basic1.Strength - basic2.Strength
		local intellect = basic1.Intellect - basic2.Intellect
		local spirit = basic1.Spirit - basic2.Spirit
		
		if(agility ~= 0) then
			test:AddLine((agility > 0 and "+" or "") .. agility .. " " .. L("TOOLTIP_IC_AGILITY"), agility > 0 and 0 or 1, agility > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(stamina ~= 0) then
			test:AddLine((stamina > 0 and "+" or "") .. stamina .. " " .. L("TOOLTIP_IC_STAMINA"), stamina > 0 and 0 or 1, stamina > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(strength ~= 0) then
			test:AddLine((strength > 0 and "+" or "") .. strength .. " " .. L("TOOLTIP_IC_STRENGTH"), strength > 0 and 0 or 1, strength > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(intellect ~= 0) then
			test:AddLine((intellect > 0 and "+" or "") .. intellect .. " " .. L("TOOLTIP_IC_INTELLECT"), intellect > 0 and 0 or 1, intellect > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(spirit ~= 0) then
			test:AddLine((spirit > 0 and "+" or "") .. spirit .. " " .. L("TOOLTIP_IC_SPIRIT"), spirit > 0 and 0 or 1, spirit > 0 and 1 or 0, 0, true)
			line_added = true
		end
	end
	
	if(line_added) then
		test:AddLine(" ")
		line_added = false
	end
	
	-- special
	do
		local dodge = special1.Dodge - special2.Dodge
		
		if(dodge ~= 0) then
			test:AddLine((dodge > 0 and "+" or "") .. dodge .. "% " .. L("TOOLTIP_IC_DODGE"), dodge > 0 and 0 or 1, dodge > 0 and 1 or 0, 0, true)
			line_added = true
		end
	end
	
	if(line_added) then
		test:AddLine(" ")
		line_added = false
	end
	
	-- TODO: attack power, enchants, recognize 2h unequipping shield/dual wield, probably not set effects
	-- enchants are going to be difficult
	do
		local arcane_resist = resist1.Arcane_Resist - resist2.Arcane_Resist
		local fire_resist = resist1.Fire_Resist - resist2.Fire_Resist
		local frost_resist = resist1.Frost_Resist - resist2.Frost_Resist
		local nature_resist = resist1.Nature_Resist - resist2.Nature_Resist
		local shadow_resist = resist1.Shadow_Resist - resist2.Shadow_Resist
		
		if(arcane_resist ~= 0) then
			test:AddLine((arcane_resist > 0 and "+" or "") .. arcane_resist .. " " .. L("TOOLTIP_IC_ARCANE"), arcane_resist > 0 and 0 or 1, arcane_resist > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(fire_resist ~= 0) then
			test:AddLine((fire_resist > 0 and "+" or "") .. fire_resist .. " " .. L("TOOLTIP_IC_FIRE"), fire_resist > 0 and 0 or 1, fire_resist > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(frost_resist ~= 0) then
			test:AddLine((frost_resist > 0 and "+" or "") .. frost_resist .. " " .. L("TOOLTIP_IC_FROST"), frost_resist > 0 and 0 or 1, frost_resist > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(nature_resist ~= 0) then
			test:AddLine((nature_resist > 0 and "+" or "") .. nature_resist .. " " .. L("TOOLTIP_IC_NATURE"), nature_resist > 0 and 0 or 1, nature_resist > 0 and 1 or 0, 0, true)
			line_added = true
		end
		if(shadow_resist ~= 0) then
			test:AddLine((shadow_resist > 0 and "+" or "") .. shadow_resist .. " " .. L("TOOLTIP_IC_SHADOW"), shadow_resist > 0 and 0 or 1, shadow_resist > 0 and 1 or 0, 0, true)
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
	
	-- uses
	for i, v in next, uses1 do
		local found = false
		for j, k in next, uses2 do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			test:AddLine(v, 0, 1, 0, true)
		end
	end
	
	for i, v in next, uses2 do
		local found = false
		for j, k in next, uses1 do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			test:AddLine(v, 1, 0, 0, true)
		end
	end
	
end

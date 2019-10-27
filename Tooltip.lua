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
	local name = focus and focus:GetName()
	
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
		else
			return
		end
	end
	
	if(i_link == nil or i_link == "[]") then
		return
	end
	
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
			itemStackCount, itemEquipLoc, itemIcon, vendorPrice, itemClassID, itemSubClassID,
			bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(i_link)
	
	if(KiwiItemInfo_Vars.vars["tooltip_price_on"] == true) then
		if(not MerchantFrame:IsShown() and (vendorPrice and vendorPrice > 0)) then
			if(itemStackCount > 1) then
				local count
				if(focus) then
					count = focus.count or (focus.Count and tonumber(focus.Count:GetText())) or 1
				else
					count = 1
				end
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
			
			if(	itemClassID == LE_ITEM_CLASS_WEAPON 
				or itemClassID == LE_ITEM_CLASS_ARMOR
				or KiwiItemInfo_Vars.vars["ilvl_only_equips"] == false
			) then
				
				local tooltipiLvl = _G[tooltipName .. "TextRight1"]
				
				if(KiwiItemInfo_Vars.vars["tooltip_ilvl_colors"]) then
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
				else
					local color = KiwiItemInfo_Vars.vars["tooltip_ilvl_nocolors_rgb"]
					local r, g, b = string.split(" ", color)
					r = tonumber(r) -- probably should pcall this to handle possible UI error
					g = tonumber(g)
					b = tonumber(b)
					r = (r > 1) and (r / 255) or r
					g = (g > 1) and (g / 255) or g
					b = (b > 1) and (b / 255) or b
					tooltipiLvl:SetTextColor(r, g, b)
				end
				
				tooltipiLvl:SetText(L("TOOLTIP_ILVL") .. itemLevel)
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
	local chances = {}
	
	for i=1, lines do
		local v = _G[index .. "Left" .. i]
		if(not v) then
			break
		end
		
		local raw_text = v:GetText()
		local text = raw_text:upper()
		if(text and #text > 1 and text:find("SET: ") == nil) then
			
			-- remove line color, if any
			if(text:find("|c", 1, 2) == 1) then
				text = text:sub(11)
			end
			
			-- remove line color return, if any
			if(text:find("|r")) then
				text = text:sub(1, -3)
			end
			
			local tt_agility   = text:match( L"TOOLTIP_CMP_AGILITY",   1)
			local tt_stamina   = text:match( L"TOOLTIP_CMP_STAMINA" ,  1)
			local tt_strength  = text:match( L"TOOLTIP_CMP_STRENGTH",  1)
			local tt_intellect = text:match( L"TOOLTIP_CMP_INTELLECT", 1)
			local tt_spirit    = text:match( L"TOOLTIP_CMP_SPIRIT",    1)
			
			local tt_armor  = text:match( L"TOOLTIP_CMP_ARMOR", 1)
			local tt_block  = text:match( L"TOOLTIP_CMP_BLOCK", 1)
			
			local tt_durability = text:match( L"TOOLTIP_CMP_DURABILITY", 1)
			
			local tt_dps    = text:match( L"TOOLTIP_CMP_DPS",    1)
			local tt_damage = text:match( L"TOOLTIP_CMP_DAMAGE", 1)
			
			local tt_dodge = text:match( L"TOOLTIP_CMP_DODGE", 1)
			
			local tt_arcane = text:match( L"TOOLTIP_CMP_ARCANE", 1)
			local tt_fire   = text:match( L"TOOLTIP_CMP_FIRE",   1)
			local tt_frost  = text:match( L"TOOLTIP_CMP_FROST",  1)
			local tt_nature = text:match( L"TOOLTIP_CMP_NATURE", 1)
			local tt_shadow = text:match( L"TOOLTIP_CMP_SHADOW", 1)
			
			local bs_digit = text:gsub("[^(%+%-)%d+]",   "")
			local ad_digit = text:gsub("[^%d+]",         "")
			
			agility   = tt_agility   and tt_agility:find(   L"TOOLTIP_PRY_AGILITY" )   and tonumber(bs_digit) or agility
			stamina   = tt_stamina   and tt_stamina:find(   L"TOOLTIP_PRY_STAMINA" )   and tonumber(bs_digit) or stamina
			strength  = tt_strength  and tt_strength:find(  L"TOOLTIP_PRY_STRENGTH" )  and tonumber(bs_digit) or strength
			intellect = tt_intellect and tt_intellect:find( L"TOOLTIP_PRY_INTELLECT" ) and tonumber(bs_digit) or intellect
			spirit    = tt_spirit    and tt_spirit:find(    L"TOOLTIP_PRY_SPIRIT" )    and tonumber(bs_digit) or spirit
			
			armor = tt_armor and tt_armor:find( L"TOOLTIP_PRY_ARMOR" ) and tonumber(ad_digit) or armor
			block = tt_block and tt_block:find( L"TOOLTIP_PRY_BLOCK" ) and tonumber(ad_digit) or block
			
			if(tt_dps and tt_dps:find(L"TOOLTIP_PRY_DPS")) then
				local str = tt_dps:gsub(L"TOOLTIP_PRY_DPS", "")
				local num = str:match("%d+.%d+")
				dps = tonumber(num)
			end
			
			if(tt_damage and tt_damage:find(L"TOOLTIP_PRY_DAMAGE")) then
				local nums = tt_damage:gsub(L"TOOLTIP_PRY_DAMAGE", "")
				local l, r = string.split("-", nums)
				min_dmg = tonumber(l)
				max_dmg = tonumber(r)
			end
			
			if(tt_durability and tt_durability:find(L"TOOLTIP_PRY_DURABILITY")) then
				local nums = tt_durability:gsub(L"TOOLTIP_PRY_DURABILITY", "")
				local l, r = string.split("/", nums)
				durability = tonumber(r)
			end
			
			dodge = tt_dodge and tt_dodge:find(L"TOOLTIP_PRY_DODGE") and tonumber(bs_digit) or dodge
			
			arcane_resist = tt_arcane and tt_arcane:find(L"TOOLTIP_PRY_ARCANE") and tonumber(bs_digit) or arcane_resist
			fire_resist   = tt_fire and tt_fire:find(L"TOOLTIP_PRY_FIRE")       and tonumber(bs_digit) or fire_resist
			frost_resist  = tt_frost and tt_frost:find(L"TOOLTIP_PRY_FROST")    and tonumber(bs_digit) or frost_resist
			nature_resist = tt_nature and tt_nature:find(L"TOOLTIP_PRY_NATURE") and tonumber(bs_digit) or nature_resist
			shadow_resist = tt_shadow and tt_shadow:find(L"TOOLTIP_PRY_SHADOW") and tonumber(bs_digit) or shadow_resist
			
			if(text:find(L"TOOLTIP_PRY_EQUIP", 1) == 1) then
				table.insert(equips, raw_text)
			end
			
			if(text:find(L"TOOLTIP_PRY_USE", 1) == 1) then
				table.insert(uses, raw_text)
			end
			
			if(text:find(L"TOOLTIP_PRY_CHANCE", 1) == 1) then
				table.insert(chances, raw_text)
			end
			
		end
		
	end
	
	-- basic stats, attack/defense, special, resistence
	return {dps = dps, min_dmg = min_dmg, max_dmg = max_dmg},
		   {Armor = armor, Block = block, Durability = durability},
	       {Agility = agility, Stamina = stamina, Strength = strength, Intellect = intellect, Spirit = spirit},
		   {Dodge = dodge},
		   {Arcane_Resist = arcane_resist, Fire_Resist = fire_resist, Frost_Resist = frost_resist, Nature_Resist = nature_resist, Shadow_Resist = shadow_resist},
		   equips, uses, chances
	
end

-- Tacks on to the end of tooltips the differences between two items stats
KiwiItemInfo.SetItemCompare = function(base, base_root, test, test_root)
	
	if(KiwiItemInfo_Vars.vars["item_compare_on"] == false) then
		return
	end
	
	local att1, def1, basic1, special1, resist1, equips1, uses1, chances1 = KiwiItemInfo.PryItemStats(base, base_root)
	local att2, def2, basic2, special2, resist2, equips2, uses2, chances2 = KiwiItemInfo.PryItemStats(test, test_root)
	
	local min_dmg = att1.min_dmg - att2.min_dmg
	local max_dmg = att1.max_dmg - att2.max_dmg
	local dps = att1.dps - att2.dps
	
	local armor = def1.Armor - def2.Armor
	local block = def1.Block - def2.Block
	local durability = def1.Durability - def2.Durability
	
	local agility = basic1.Agility - basic2.Agility
	local stamina = basic1.Stamina - basic2.Stamina
	local strength = basic1.Strength - basic2.Strength
	local intellect = basic1.Intellect - basic2.Intellect
	local spirit = basic1.Spirit - basic2.Spirit
	
	local dodge = special1.Dodge - special2.Dodge
	
	local arcane_resist = resist1.Arcane_Resist - resist2.Arcane_Resist
	local fire_resist = resist1.Fire_Resist - resist2.Fire_Resist
	local frost_resist = resist1.Frost_Resist - resist2.Frost_Resist
	local nature_resist = resist1.Nature_Resist - resist2.Nature_Resist
	local shadow_resist = resist1.Shadow_Resist - resist2.Shadow_Resist
	
	
	local queue = {}
	local dirty = true
	local send_line = function(...)
		table.insert(queue, {...})
		dirty = true
	end
	local blank_if_dirty = function()
		if(dirty) then
			table.insert(queue, {" "})
			dirty = false
		end
	end
	
	test:AddLine(" ")
	test:AddLine(L"TOOLTIP_ITEM_COMPARE", 0.06666, 0.6, 0.06666, true)
	
	-- min/max attack
	if(min_dmg ~= 0 or max_dmg ~= 0) then
		send_line(((min_dmg > 0) and string.format("|cFF00FF00+%s|r", min_dmg) or string.format("|cFFFF0000%s|r", min_dmg))
					.. " / "
					.. ((max_dmg > 0) and string.format("|cFF00FF00+%s|r", max_dmg) or string.format("|cFFFF0000%s|r", max_dmg))
					.. L("TOOLTIP_IC_DAMAGE_DELTA") .. math.abs(max_dmg - min_dmg) .. ")")
	end
	
	-- dps
	if(dps ~= 0) then
		send_line((dps > 0 and "+" or "") .. dps .. " " .. L("TOOLTIP_IC_DPS"), dps > 0 and 0 or 1, dps > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	-- armor/block/durability
	if(armor ~= 0) then
		send_line((armor > 0 and "+" or "") .. armor .. " " .. L("TOOLTIP_IC_ARMOR"), armor > 0 and 0 or 1, armor > 0 and 1 or 0, 0, true)
	end
	if(block ~= 0) then
		send_line((block > 0 and "+" or "") .. block .. " " .. L("TOOLTIP_IC_BLOCK"), block > 0 and 0 or 1, block > 0 and 1 or 0, 0, true)
	end
	if(durability ~= 0) then
		send_line((durability > 0 and "+" or "") .. durability .. " " .. L("TOOLTIP_IC_DURABILITY"), durability > 0 and 0 or 1, durability > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	-- basic stats
	if(agility ~= 0) then
		send_line((agility > 0 and "+" or "") .. agility .. " " .. L("TOOLTIP_IC_AGILITY"), agility > 0 and 0 or 1, agility > 0 and 1 or 0, 0, true)
	end
	if(stamina ~= 0) then
		send_line((stamina > 0 and "+" or "") .. stamina .. " " .. L("TOOLTIP_IC_STAMINA"), stamina > 0 and 0 or 1, stamina > 0 and 1 or 0, 0, true)
	end
	if(strength ~= 0) then
		send_line((strength > 0 and "+" or "") .. strength .. " " .. L("TOOLTIP_IC_STRENGTH"), strength > 0 and 0 or 1, strength > 0 and 1 or 0, 0, true)
	end
	if(intellect ~= 0) then
		send_line((intellect > 0 and "+" or "") .. intellect .. " " .. L("TOOLTIP_IC_INTELLECT"), intellect > 0 and 0 or 1, intellect > 0 and 1 or 0, 0, true)
	end
	if(spirit ~= 0) then
		send_line((spirit > 0 and "+" or "") .. spirit .. " " .. L("TOOLTIP_IC_SPIRIT"), spirit > 0 and 0 or 1, spirit > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	-- special
	if(dodge ~= 0) then
		send_line((dodge > 0 and "+" or "") .. dodge .. "% " .. L("TOOLTIP_IC_DODGE"), dodge > 0 and 0 or 1, dodge > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	-- TODO: attack power, enchants, recognize 2h unequipping shield/dual wield, probably not set effects
	-- enchants are going to be difficult
	if(arcane_resist ~= 0) then
		send_line((arcane_resist > 0 and "+" or "") .. arcane_resist .. " " .. L("TOOLTIP_IC_ARCANE"), arcane_resist > 0 and 0 or 1, arcane_resist > 0 and 1 or 0, 0, true)
	end
	if(fire_resist ~= 0) then
		send_line((fire_resist > 0 and "+" or "") .. fire_resist .. " " .. L("TOOLTIP_IC_FIRE"), fire_resist > 0 and 0 or 1, fire_resist > 0 and 1 or 0, 0, true)
	end
	if(frost_resist ~= 0) then
		send_line((frost_resist > 0 and "+" or "") .. frost_resist .. " " .. L("TOOLTIP_IC_FROST"), frost_resist > 0 and 0 or 1, frost_resist > 0 and 1 or 0, 0, true)
	end
	if(nature_resist ~= 0) then
		send_line((nature_resist > 0 and "+" or "") .. nature_resist .. " " .. L("TOOLTIP_IC_NATURE"), nature_resist > 0 and 0 or 1, nature_resist > 0 and 1 or 0, 0, true)
	end
	if(shadow_resist ~= 0) then
		send_line((shadow_resist > 0 and "+" or "") .. shadow_resist .. " " .. L("TOOLTIP_IC_SHADOW"), shadow_resist > 0 and 0 or 1, shadow_resist > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	-- equips
	for i, v in next, equips1 do
		local found = false
		for j, k in next, equips2 do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			send_line(v, 0, 1, 0, true)
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
			send_line(v, 1, 0, 0, true)
		end
	end
	
	blank_if_dirty()
	
	-- uses
	for i, v in next, uses1 do
		local found = false
		for j, k in next, uses2 do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			send_line(v, 0, 1, 0, true)
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
			send_line(v, 1, 0, 0, true)
		end
	end
	
	blank_if_dirty()
	
	-- chances
	for i, v in next, chances1 do
		local found = false
		for j, k in next, chances2 do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			send_line(v, 0, 1, 0, true)
		end
	end
	
	for i, v in next, chances2 do
		local found = false
		for j, k in next, chances1 do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			send_line(v, 1, 0, 0, true)
		end
	end
	
	if(queue[#queue][1] == " ") then
		table.remove(queue, #queue)
	end
	
	for i, v in pairs(queue) do
		test:AddLine(unpack(v))
	end
	
end

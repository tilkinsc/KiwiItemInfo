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



local L = KiwiItemInfo.LocaleStrings()

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
					SetTooltipMoney(tooltip, vendorPrice, nil, L["TOOLTIP_UNIT"])
					SetTooltipMoney(tooltip, vendorPrice * itemStackCount, nil, L["TOOLTIP_STACK"])
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
				
				tooltipiLvl:SetText(L["TOOLTIP_ILVL"] .. itemLevel)
				tooltipiLvl:Show()
			end
		end
	end
	
end

-- Parses tooltip text for item stats
KiwiItemInfo.PryItemStats = function(tooltip, index)
	
	local lines = tooltip:NumLines()
	if(lines == 0) then
		return
	end
	
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
			
			local tt_agility   = text:match( L["TOOLTIP_CMP_AGILITY"],   1)
			local tt_stamina   = text:match( L["TOOLTIP_CMP_STAMINA"] ,  1)
			local tt_strength  = text:match( L["TOOLTIP_CMP_STRENGTH"],  1)
			local tt_intellect = text:match( L["TOOLTIP_CMP_INTELLECT"], 1)
			local tt_spirit    = text:match( L["TOOLTIP_CMP_SPIRIT"],    1)
			
			local tt_armor  = text:match( L["TOOLTIP_CMP_ARMOR"], 1)
			local tt_block  = text:match( L["TOOLTIP_CMP_BLOCK"], 1)
			
			local tt_durability = text:match( L["TOOLTIP_CMP_DURABILITY"], 1)
			
			local tt_dps    = text:match( L["TOOLTIP_CMP_DPS"],    1)
			local tt_damage = text:match( L["TOOLTIP_CMP_DAMAGE"], 1)
			
			local tt_dodge = text:match( L["TOOLTIP_CMP_DODGE"], 1)
			
			local tt_arcane = text:match( L["TOOLTIP_CMP_ARCANE"], 1)
			local tt_fire   = text:match( L["TOOLTIP_CMP_FIRE"],   1)
			local tt_frost  = text:match( L["TOOLTIP_CMP_FROST"],  1)
			local tt_nature = text:match( L["TOOLTIP_CMP_NATURE"], 1)
			local tt_shadow = text:match( L["TOOLTIP_CMP_SHADOW"], 1)
			
			local bs_digit = text:gsub("[^(%+%-)%d+]",   "")
			local ad_digit = text:gsub("[^%d+]",         "")
			
			agility   = tt_agility   and tt_agility:find(   L["TOOLTIP_PRY_AGILITY"] )   and tonumber(bs_digit) or agility
			stamina   = tt_stamina   and tt_stamina:find(   L["TOOLTIP_PRY_STAMINA"] )   and tonumber(bs_digit) or stamina
			strength  = tt_strength  and tt_strength:find(  L["TOOLTIP_PRY_STRENGTH"] )  and tonumber(bs_digit) or strength
			intellect = tt_intellect and tt_intellect:find( L["TOOLTIP_PRY_INTELLECT"] ) and tonumber(bs_digit) or intellect
			spirit    = tt_spirit    and tt_spirit:find(    L["TOOLTIP_PRY_SPIRIT"] )    and tonumber(bs_digit) or spirit
			
			armor = tt_armor and tt_armor:find( L["TOOLTIP_PRY_ARMOR"] ) and tonumber(ad_digit) or armor
			block = tt_block and tt_block:find( L["TOOLTIP_PRY_BLOCK"] ) and tonumber(ad_digit) or block
			
			if(tt_dps and tt_dps:find(L["TOOLTIP_PRY_DPS"])) then
				local str = tt_dps:gsub(L["TOOLTIP_PRY_DPS"], "")
				local num = str:match("%d+.%d+")
				dps = tonumber(num)
			end
			
			if(tt_damage and tt_damage:find(L["TOOLTIP_PRY_DAMAGE"])) then
				local nums = tt_damage:gsub(L["TOOLTIP_PRY_DAMAGE"], "")
				local l, r = string.split("-", nums)
				min_dmg = tonumber(l)
				max_dmg = tonumber(r)
			end
			
			if(tt_durability and tt_durability:find(L["TOOLTIP_PRY_DURABILITY"])) then
				local nums = tt_durability:gsub(L["TOOLTIP_PRY_DURABILITY"], "")
				local l, r = string.split("/", nums)
				durability = tonumber(r)
			end
			
			dodge = tt_dodge and tt_dodge:find(L["TOOLTIP_PRY_DODGE"]) and tonumber(bs_digit) or dodge
			
			arcane_resist = tt_arcane and tt_arcane:find(L["TOOLTIP_PRY_ARCANE"]) and tonumber(bs_digit) or arcane_resist
			fire_resist   = tt_fire and tt_fire:find(L["TOOLTIP_PRY_FIRE"])       and tonumber(bs_digit) or fire_resist
			frost_resist  = tt_frost and tt_frost:find(L["TOOLTIP_PRY_FROST"])    and tonumber(bs_digit) or frost_resist
			nature_resist = tt_nature and tt_nature:find(L["TOOLTIP_PRY_NATURE"]) and tonumber(bs_digit) or nature_resist
			shadow_resist = tt_shadow and tt_shadow:find(L["TOOLTIP_PRY_SHADOW"]) and tonumber(bs_digit) or shadow_resist
			
			if(text:find(L["TOOLTIP_PRY_EQUIP"], 1) == 1) then
				table.insert(equips, raw_text)
			end
			
			if(text:find(L["TOOLTIP_PRY_USE"], 1) == 1) then
				table.insert(uses, raw_text)
			end
			
			if(text:find(L["TOOLTIP_PRY_CHANCE"], 1) == 1) then
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
local att1, def1, basic1, special1, resist1, equips1, uses1, chances1
local att2, def2, basic2, special2, resist2, equips2, uses2, chances2
local att3, def3, basic3, special3, resist3, equips3, uses3, chances3
local att4, def4, basic4, special4, resist4, equips4, uses4, chances4
local att5, def5, basic5, special5, resist5, equips5, uses5, chances5
local att6, def6, basic6, special6, resist6, equips6, uses6, chances6

KiwiItemInfo.SetItemCompare = function(slot, tooltip, text)
	
	if(KiwiItemInfo_Vars.vars["item_compare_on"] == false) then
		return
	end
	
	local i_name, i_link = tooltip:GetItem()
	if(i_name == nil or i_name == "" or i_link == nil or i_link == "[]") then
		return
	end
	
	local itemClassID = select(12, GetItemInfo(i_link))
	if(itemClassID ~= LE_ITEM_CLASS_ARMOR and itemClassID ~= LE_ITEM_CLASS_WEAPON) then
		return
	end
	
	if(slot == 1) then
		att1, def1, basic1, special1, resist1, equips1, uses1, chances1 = KiwiItemInfo.PryItemStats(tooltip, text)
		return
	end
	if(slot == 2) then
		att2, def2, basic2, special2, resist2, equips2, uses2, chances2 = KiwiItemInfo.PryItemStats(tooltip, text)
		return
	end
	if(slot == 3) then
		att3, def3, basic3, special3, resist3, equips3, uses3, chances3 = KiwiItemInfo.PryItemStats(tooltip, text)
		return
	end
	if(slot == 4) then
		att4, def4, basic4, special4, resist4, equips4, uses4, chances4 = KiwiItemInfo.PryItemStats(tooltip, text)
		return
	end
	if(slot == 5) then
		att5, def5, basic5, special5, resist5, equips5, uses5, chances5 = KiwiItemInfo.PryItemStats(tooltip, text)
		return
	end
	if(slot == 6) then
		att6, def6, basic6, special6, resist6, equips6, uses6, chances6 = KiwiItemInfo.PryItemStats(tooltip, text)
		return
	end
	
end

KiwiItemInfo.ClearItemCompare = function(slot, tooltip)

	if(KiwiItemInfo_Vars.vars["item_compare_on"] == false) then
		return
	end
	
	if(tooltip:IsShown()) then
		return
	end
	
	if(slot == 1) then
		att1, def1, basic1, special1, resist1, equips1, uses1, chances1 = nil
		return
	end
	if(slot == 2) then
		att2, def2, basic2, special2, resist2, equips2, uses2, chances2 = nil
		return
	end
	if(slot == 3) then
		att3, def3, basic3, special3, resist3, equips3, uses3, chances3 = nil
		return
	end
	if(slot == 4) then
		att4, def4, basic4, special4, resist4, equips4, uses4, chances4 = nil
		return
	end
	if(slot == 5) then
		att5, def5, basic5, special5, resist5, equips5, uses5, chances5 = nil
		return
	end
	if(slot == 6) then
		att6, def6, basic6, special6, resist6, equips6, uses6, chances6 = nil
		return
	end
	
end


KiwiItemInfo.ShowEffectiveStats = function(tooltip)
	
	if(KiwiItemInfo_Vars.vars["item_compare_extra"] == false) then
		return
	end
	
	local selection = GetMouseFocus()
	if(selection == nil) then
		return
	end
	
	local name = selection:GetName()
	if(name:find("Character") ~= 1 or not name:find("Slot")) then
		return
	end
	
	if(att1 == nil) then
		return
	end
	
	local _, _, classID = UnitClass("player");
	
	
	local armor = UnitArmor("player")
	armor = armor - 2 * basic1.Agility
	
	local ch_agi, _, ch_agi_pos, ch_agi_neg = UnitStat("player", 2)
	local ch_stm, _, ch_stm_pos, ch_stm_neg = UnitStat("player", 3)
	local ch_str, _, ch_str_pos, ch_str_neg = UnitStat("player", 1)
	local ch_int, _, ch_int_pos, ch_int_neg = UnitStat("player", 4)
	local ch_spt, _, ch_spt_pos, ch_spt_neg = UnitStat("player", 5)
	
	
	local agility_ap_melee = 0
	local agility_ap_range = 0
	local agility_crit = 0
	local agility_dodge = 0
	local agility_catform_ap_melee = 0
	local agility_armor = 2 * basic1.Agility
	local eff_agility_armor = (agility_armor / (2 * ch_agi_pos)) * 100
	
	local stamina_health = 10 * basic1.Stamina
	local eff_stamina_health = (stamina_health / (10 * ch_stm_pos)) * 100
	
	local strength_ap_melee = 0
	local strength_block = 0
	
	local intellect_mana = 0
	local intellect_crit = 0
	
	local spirit_hpt = 0
	local spirit_mpt = 0
	
	local arcane_resist_p = 0.238095238 * resist1.Arcane_Resist
	local fire_resist_p = 0.238095238 * resist1.Fire_Resist
	local frost_resist_p = 0.238095238 * resist1.Frost_Resist
	local nature_resist_p = 0.238095238 * resist1.Nature_Resist
	local shadow_resist_p = 0.238095238 * resist1.Shadow_Resist
	
	local eff_arcane_resist_p = (resist1.Arcane_Resist / UnitResistance("player", 6)) * 100
	local eff_fire_resist_p = (resist1.Fire_Resist / UnitResistance("player", 2)) * 100
	local eff_frost_resist_p = (resist1.Frost_Resist / UnitResistance("player", 4)) * 100
	local eff_nature_resist_p = (resist1.Nature_Resist / UnitResistance("player", 3)) * 100
	local eff_shadow_resist_p = (resist1.Shadow_Resist / UnitResistance("player", 5)) * 100
	
	local eff_agility_ap_melee = 0
	local eff_agility_ap_range = 0
	local eff_agility_crit = 0
	local eff_agility_dodge = 0
	local eff_agility_catform_ap_melee = 0
	
	local eff_strength_ap_melee = 0
	local eff_strength_block = 0
	
	local eff_intellect_mana = 0
	local eff_intellect_crit = 0
	
	local eff_spirit_hpt = 0
	local eff_spirit_mpt = 0
	
	
	
	if(classID == 1) then -- warrior
		agility_ap_range = 2 * basic1.Agility
		eff_agility_ap_range = (agility_ap_range / (2 * ch_agi_pos)) * 100
		
		agility_crit = 0.05 * basic1.Agility
		eff_agility_crit  = (agility_crit / (0.05 * ch_agi_pos)) * 100
		
		agility_dodge = 0.05 * basic1.Agility
		eff_agility_dodge = (agility_dodge / (0.05 * ch_agi_pos)) * 100
		
		
		strength_ap_melee = 2 * basic1.Strength
		eff_strength_ap_melee = (strength_ap_melee / (2 * ch_str_pos)) * 100
		
		strength_block = 0.05 * basic1.Strength
		eff_strength_block = (strength_block / (0.05 * ch_str_pos)) * 100
		
		
		spirit_hpt = 0.80 * basic1.Spirit
		eff_spirit_hpt = (spirit_hpt / (0.80 * ch_spt_pos)) * 100
	elseif(classID == 2) then -- paladin
		agility_crit = 0.05 * basic1.Agility
		eff_agility_crit  = (agility_crit / (0.05 * ch_agi_pos)) * 100
		
		agility_dodge = 0.05 * basic1.Agility
		eff_agility_dodge = (agility_dodge / (0.05 * ch_agi_pos)) * 100
		
		
		strength_ap_melee = 2 * basic1.Strength
		eff_strength_ap_melee = (strength_ap_melee / (2 * ch_str_pos)) * 100
		
		strength_block = 0.05 * basic1.Strength
		eff_strength_block = (strength_block / (0.05 * ch_str_pos)) * 100
		
		
		intellect_mana = 15 * basic1.Intellect
		eff_intellect_mana = (intellect_mana / (15 * ch_int_pos)) * 100
		
		intellect_crit = 0.033898305 * basic1.Intellect
		eff_intellect_crit = (intellect_crit / (0.033898305 * ch_int_pos)) * 100
		
		
		spirit_hpt = 0.80 * basic1.Spirit
		eff_spirit_hpt = (spirit_hpt / (0.80 * ch_spt_pos)) * 100
		
		spirit_mpt = 0.20 * basic1.Spirit
		eff_spirit_mpt = (spirit_mpt / (0.20 * ch_spt_pos)) * 100
	elseif(classID == 3) then -- hunter
		agility_ap_melee = 1 * basic1.Agility
		eff_agility_ap_melee = (agility_ap_melee / (1 * ch_agi_pos)) * 100
		
		agility_ap_range = 2 * basic1.Agility
		eff_agility_ap_range = (agility_ap_range / (2 * ch_agi_pos)) * 100
		
		agility_crit = 0.018867924 * basic1.Agility
		eff_agility_crit = (agility_crit / (0.018867924 * ch_agi_pos)) * 100
		
		agility_dodge = 0.037735849 * basic1.Agility
		eff_agility_dodge = (agility_dodge / (0.037735849 * ch_agi_pos)) * 100
		
		
		strength_ap_melee = 1 * basic1.Strength
		eff_strength_ap_melee = (strength_ap_melee / (1 * ch_str_pos)) * 100
		
		
		intellect_mana = 15 * basic1.Intellect
		eff_intellect_mana = (intellect_mana / (15 * ch_int_pos)) * 100
		
		
		spirit_hpt = 1.0 * basic1.Spirit
		eff_spirit_hpt = (spirit_hpt / (1.0 * ch_spt_pos)) * 100
		
		spirit_mpt = 0.20 * basic1.Spirit
		eff_spirit_mpt = (spirit_mpt / (0.20 * ch_spt_pos)) * 100
	elseif(classID == 4) then -- rogue
		agility_ap_melee = 1 * basic1.Agility
		eff_agility_ap_melee = (agility_ap_melee / (1 * ch_agi_pos)) * 100
		
		agility_ap_range = 2 * basic1.Agility
		eff_agility_ap_range = (agility_ap_range / (2 * ch_agi_pos)) * 100
		
		agility_crit = 0.03448275 * basic1.Agility
		eff_agility_crit = (agility_crit / (0.03448275 * ch_agi_pos)) * 100
		
		agility_dodge = 0.06896551 * basic1.Agility
		eff_agility_dodge = (agility_dodge / (0.06896551 * ch_agi_pos)) * 100
		
		
		strength_ap_melee = 1 * basic1.Strength
		eff_strength_ap_melee = (strength_ap_melee / (1 * ch_str_pos)) * 100
		
		
		spirit_hpt = 0.60 * basic1.Spirit
		eff_spirit_hpt = (spirit_hpt / (0.60 * ch_spt_pos)) * 100
	elseif(classID == 5) then -- priest
		agility_crit = 0.05 * basic1.Agility
		eff_agility_crit  = (agility_crit / (0.05 * ch_agi_pos)) * 100
		
		agility_dodge = 0.05 * basic1.Agility
		eff_agility_dodge = (agility_dodge / (0.05 * ch_agi_pos)) * 100
		
		
		strength_ap_melee = 2 * basic1.Strength
		eff_strength_ap_melee = (strength_ap_melee / (2 * ch_str_pos)) * 100
		
		
		intellect_mana = 15 * basic1.Intellect
		eff_intellect_mana = (intellect_mana / (15 * ch_int_pos)) * 100
		
		intellect_crit = 0.0168918918 * basic1.Intellect
		eff_intellect_crit = (intellect_crit / (0.0168918918 * ch_int_pos)) * 100
		
		
		spirit_hpt = 1.0 * basic1.Spirit
		eff_spirit_hpt = (spirit_hpt / (1.0 * ch_spt_pos)) * 100
		
		spirit_mpt = 0.25 * basic1.Spirit
		eff_spirit_mpt = (spirit_mpt / (0.25 * ch_spt_pos)) * 100
	elseif(classID == 7) then -- shaman
		agility_crit = 0.05 * basic1.Agility
		eff_agility_crit  = (agility_crit / (0.05 * ch_agi_pos)) * 100
		
		agility_dodge = 0.05 * basic1.Agility
		eff_agility_dodge = (agility_dodge / (0.05 * ch_agi_pos)) * 100
		
		
		strength_ap_melee = 2 * basic1.Strength
		eff_strength_ap_melee = (strength_ap_melee / (2 * ch_str_pos)) * 100
		
		strength_block = 0.05 * basic1.Strength
		eff_strength_block = (strength_block / (0.05 * ch_str_pos)) * 100
		
		
		intellect_mana = 15 * basic1.Intellect
		eff_intellect_mana = (intellect_mana / (15 * ch_int_pos)) * 100
		
		intellect_crit = 0.016806722 * basic1.Intellect
		eff_intellect_crit = (intellect_crit / (0.016806722 * ch_int_pos)) * 100
		
		
		spirit_hpt = 1.1 * basic1.Spirit
		eff_spirit_hpt = (spirit_hpt / (1.1 * ch_spt_pos)) * 100
		
		spirit_mpt = 0.20 * basic1.Spirit
		eff_spirit_mpt = (spirit_mpt / (0.20 * ch_spt_pos)) * 100
	elseif(classID == 8) then -- mage
		agility_crit = 0.05 * basic1.Agility
		eff_agility_crit  = (agility_crit / (0.05 * ch_agi_pos)) * 100
		
		agility_dodge = 0.05 * basic1.Agility
		eff_agility_dodge = (agility_dodge / (0.05 * ch_agi_pos)) * 100
		
		
		strength_ap_melee = 2 * basic1.Strength
		eff_strength_ap_melee = (strength_ap_melee / (2 * ch_str_pos)) * 100
		
		
		intellect_mana = 15 * basic1.Intellect
		eff_intellect_mana = (intellect_mana / (15 * ch_int_pos)) * 100
		
		intellect_crit = 0.016806722 * basic1.Intellect
		eff_intellect_crit = (intellect_crit / (0.016806722 * ch_int_pos)) * 100
		
		
		spirit_hpt = 1.0 * basic1.Spirit
		eff_spirit_hpt = (spirit_hpt / (1.0 * ch_spt_pos)) * 100
		
		spirit_mpt = 0.25 * basic1.Spirit
		eff_spirit_mpt = (spirit_mpt / (0.25 * ch_spt_pos)) * 100
	elseif(classID == 9) then -- warlock
		agility_crit = 0.05 * basic1.Agility
		eff_agility_crit  = (agility_crit / (0.05 * ch_agi_pos)) * 100
		
		agility_dodge = 0.05 * basic1.Agility
		eff_agility_dodge = (agility_dodge / (0.05 * ch_agi_pos)) * 100
		
		
		strength_ap_melee = 2 * basic1.Strength
		eff_strength_ap_melee = (strength_ap_melee / (2 * ch_str_pos)) * 100
		
		
		intellect_mana = 15 * basic1.Intellect
		eff_intellect_mana = (intellect_mana / (15 * ch_int_pos)) * 100
		
		intellect_crit = 0.016501650 * basic1.Intellect
		eff_intellect_crit = (intellect_crit / (0.016501650 * ch_int_pos)) * 100
		
		
		spirit_hpt = 0.7 * basic1.Spirit
		eff_spirit_hpt = (spirit_hpt / (0.7 * ch_spt_pos)) * 100
		
		spirit_mpt = 0.25 * basic1.Spirit
		eff_spirit_mpt = (spirit_mpt / (0.25 * ch_spt_pos)) * 100
	elseif(classID == 11) then -- druid
		agility_crit = 0.05 * basic1.Agility
		eff_agility_crit  = (agility_crit / (0.05 * ch_agi_pos)) * 100
		
		agility_dodge = 0.05 * basic1.Agility
		eff_agility_dodge = (agility_dodge / (0.05 * ch_agi_pos)) * 100
		
		agility_catform_ap_melee = 1 * basic1.Agility
		eff_agility_catform_ap_melee = (agility_catform_ap_melee / (1 * ch_agi_pos)) * 100
		
		
		strength_ap_melee = 2 * basic1.Strength
		eff_strength_ap_melee = (strength_ap_melee / (2 * ch_str_pos)) * 100
		
		
		intellect_mana = 15 * basic1.Intellect
		eff_intellect_mana = (intellect_mana / (15 * ch_int_pos)) * 100
		
		intellect_crit = 0.016666666 * basic1.Intellect
		eff_intellect_crit = (intellect_crit / (0.016666666 * ch_int_pos)) * 100
		
		
		spirit_hpt = 0.9 * basic1.Spirit
		eff_spirit_hpt = (spirit_hpt / (0.9 * ch_spt_pos)) * 100
		
		spirit_mpt = 0.20 * basic1.Spirit
		eff_spirit_mpt = (spirit_mpt / (0.20 * ch_spt_pos)) * 100
	end
	
	local eff_armor = (def1.Armor / armor) * 100
	
	local eff_agi = (basic1.Agility / ch_agi_pos) * 100
	local eff_stm = (basic1.Stamina / ch_stm_pos) * 100
	local eff_str = (basic1.Strength / ch_str_pos) * 100
	local eff_int = (basic1.Intellect / ch_int_pos) * 100
	local eff_spt = (basic1.Spirit / ch_spt_pos) * 100
	
	
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
	
	blank_if_dirty()
	
	if(agility_ap_melee ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_M_AP"] .. string.format("|cFFEFEF00%s|r", tostring(agility_ap_melee) .. " (" .. (agility_ap_melee < 0 and "-" or "+") .. tostring(agility_ap_melee/14):match("%d+%.?%d?%d?") .. " DPS)"), 1, 1, 1, true)
	end
	if(agility_ap_range ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_R_AP"] .. string.format("|cFFEFEF00%s|r", tostring(agility_ap_range) .. " (" .. (agility_ap_range < 0 and "-" or "+") .. tostring(agility_ap_range/14):match("%d+%.?%d?%d?") .. " DPS)"), 1, 1, 1, true)
	end
	if(agility_crit ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_CRIT"] .. string.format("|cFFEFEF00%s|r", tostring(agility_crit):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
	end
	if(agility_dodge ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_DODGE"] .. string.format("|cFFEFEF00%s|r", tostring(agility_dodge):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
	end
	if(agility_armor ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_AR"] .. string.format("|cFFEFEF00%s|r", tostring(agility_armor)), 1, 1, 1, true)
	end
	if(agility_catform_ap_melee ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_M_CAT_AP"] .. string.format("|cFFEFEF00%s|r", tostring(agility_catform_ap_melee) .. " (" .. (agility_catform_ap_melee < 0 and "-" or "+") .. tostring(agility_catform_ap_melee/14):match("%d+%.?%d?%d?") .. " DPS)"), 1, 1, 1, true)
	end
	if(stamina_health ~= 0) then
		send_line(L["TOOLTIP_EX_STM_HP"] .. string.format("|cFFEFEF00%s|r", tostring(stamina_health)), 1, 1, 1, true)
	end
	if(strength_ap_melee ~= 0) then
		send_line(L["TOOLTIP_EX_STR_M_AP"] .. string.format("|cFFEFEF00%s|r", tostring(strength_ap_melee) .. " (" .. (strength_ap_melee < 0 and "-" or "+") .. tostring(strength_ap_melee/14):match("%d+%.?%d?%d?") .. " DPS)"), 1, 1, 1, true)
	end
	if(strength_block ~= 0) then
		send_line(L["TOOLTIP_EX_STR_BLOCK"] .. string.format("|cFFEFEF00%s|r", tostring(strength_block):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
	end
	if(intellect_mana ~= 0) then
		send_line(L["TOOLTIP_EX_INT_MANA"] .. string.format("|cFFEFEF00%s|r", tostring(intellect_mana)), 1, 1, 1, true)
	end
	if(intellect_crit ~= 0) then
		send_line(L["TOOLTIP_EX_INT_CRIT"] .. string.format("|cFFEFEF00%s|r", tostring(intellect_crit):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
	end
	if(spirit_hpt ~= 0) then
		send_line(L["TOOLTIP_EX_SPT_HP5"] .. string.format("|cFFEFEF00%s|r", tostring(spirit_hpt):match("%d+%.?%d?%d?")), 1, 1, 1, true)
	end
	if(spirit_mpt ~= 0) then
		send_line(L["TOOLTIP_EX_SPT_MP5"] .. string.format("|cFFEFEF00%s|r", tostring(spirit_mpt):match("%d+%.?%d?%d?")), 1, 1, 1, true)
	end
	if(arcane_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_ARCANE"] .. string.format("|cFFEFEF00%s|r", tostring(arcane_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
	end
	if(fire_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_FIRE"] .. string.format("|cFFEFEF00%s|r", tostring(fire_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
	end
	if(frost_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_FROST"] .. string.format("|cFFEFEF00%s|r", tostring(frost_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
	end
	if(nature_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_NATURE"] .. string.format("|cFFEFEF00%s|r", tostring(nature_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
	end
	if(shadow_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_SHADOW"] .. string.format("|cFFEFEF00%s|r", tostring(shadow_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
	end
	
	blank_if_dirty()
	
	send_line(L["TOOLTIP_ITEM_CONTRIB"], 0, 1, 0, false)
	
	if(eff_armor ~= 0) then
		send_line(L["TOOLTIP_IC_ARMOR"] .. ": " .. string.format("|cFFEFEF00%s|r", tostring(eff_armor):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	
	if(eff_agi ~= 0) then
		send_line(L["TOOLTIP_IC_AGILITY"] .. ": " .. string.format("|cFFEFEF00%s|r", tostring(eff_agi):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_stm ~= 0) then
		send_line(L["TOOLTIP_IC_STAMINA"] .. ": " .. string.format("|cFFEFEF00%s|r", tostring(eff_stm):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_str ~= 0) then
		send_line(L["TOOLTIP_IC_STRENGTH"] .. ": " .. string.format("|cFFEFEF00%s|r", tostring(eff_str):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_int ~= 0) then
		send_line(L["TOOLTIP_IC_INTELLECT"] .. ": " .. string.format("|cFFEFEF00%s|r", tostring(eff_int):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_spt ~= 0) then
		send_line(L["TOOLTIP_IC_SPIRIT"] .. ": " .. string.format("|cFFEFEF00%s|r", tostring(eff_spt):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	
	blank_if_dirty()
	
	if(eff_agility_ap_melee ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_M_AP"] .. string.format("|cFFEFEF00%s|r", tostring(eff_agility_ap_melee):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_agility_ap_range ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_R_AP"] .. string.format("|cFFEFEF00%s|r", tostring(eff_agility_ap_range):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_agility_crit ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_CRIT"] .. string.format("|cFFEFEF00%s|r", tostring(eff_agility_crit):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_agility_dodge ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_DODGE"] .. string.format("|cFFEFEF00%s|r", tostring(eff_agility_dodge):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_agility_armor ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_AR"] .. string.format("|cFFEFEF00%s|r", tostring(eff_agility_armor):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_agility_catform_ap_melee ~= 0) then
		send_line(L["TOOLTIP_EX_AGI_M_CAT_AP"] .. string.format("|cFFEFEF00%s|r", tostring(eff_agility_catform_ap_melee):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_stamina_health ~= 0) then
		send_line(L["TOOLTIP_EX_STM_HP"] .. string.format("|cFFEFEF00%s|r", tostring(eff_stamina_health):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_strength_ap_melee ~= 0) then
		send_line(L["TOOLTIP_EX_STR_M_AP"] .. string.format("|cFFEFEF00%s|r", tostring(eff_strength_ap_melee):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_strength_block ~= 0) then
		send_line(L["TOOLTIP_EX_STR_BLOCK"] .. string.format("|cFFEFEF00%s|r", tostring(eff_strength_block):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_intellect_mana ~= 0) then
		send_line(L["TOOLTIP_EX_INT_MANA"] .. string.format("|cFFEFEF00%s|r", tostring(eff_intellect_mana):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_intellect_crit ~= 0) then
		send_line(L["TOOLTIP_EX_INT_CRIT"] .. string.format("|cFFEFEF00%s|r", tostring(eff_intellect_crit):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_spirit_hpt ~= 0) then
		send_line(L["TOOLTIP_EX_SPT_HP5"] .. string.format("|cFFEFEF00%s|r", tostring(eff_spirit_hpt):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_spirit_mpt ~= 0) then
		send_line(L["TOOLTIP_EX_SPT_MP5"] .. string.format("|cFFEFEF00%s|r", tostring(eff_spirit_mpt):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	
	
	blank_if_dirty()
	
	
	if(eff_arcane_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_ARCANE"] .. string.format("|cFFEFEF00%s|r", tostring(eff_arcane_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_fire_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_FIRE"] .. string.format("|cFFEFEF00%s|r", tostring(eff_fire_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_frost_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_FROST"] .. string.format("|cFFEFEF00%s|r", tostring(eff_frost_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_nature_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_NATURE"] .. string.format("|cFFEFEF00%s|r", tostring(eff_nature_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	if(eff_shadow_resist_p ~= 0) then
		send_line(L["TOOLTIP_EX_RES_SHADOW"] .. string.format("|cFFEFEF00%s|r", tostring(eff_shadow_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, false)
	end
	
	if(queue[#queue][1] == " ") then
		table.remove(queue, #queue)
	end
	
	for i, v in pairs(queue) do
		tooltip:AddLine(unpack(v))
	end
	
end

KiwiItemInfo.DisplayItemCompare = function(base_tooltip, tooltip, sel)
	
	if(KiwiItemInfo_Vars.vars["item_compare_on"] == false) then
		return
	end
	
	do
		local selection = GetMouseFocus()
		if(selection ~= nil) then
			local name = selection:GetName()
			if(name and name:find("Character") == 1 and name:find("Slot")) then
				return
			end
		end
	end
	
	local att_a, def_a, basic_a, special_a, resist_a, equips_a, uses_a, chances_a
	local att_b, def_b, basic_b, special_b, resist_b, equips_b, uses_b, chances_b
	local att_c, def_c, basic_c, special_c, resist_c, equips_c, uses_c, chances_c
	if(sel == 1) then
		att_a, def_a, basic_a, special_a, resist_a, equips_a, uses_a, chances_a = att1, def1, basic1, special1, resist1, equips1, uses1, chances1
		att_b, def_b, basic_b, special_b, resist_b, equips_b, uses_b, chances_b = att2, def2, basic2, special2, resist2, equips2, uses2, chances2
		att_c, def_c, basic_c, special_c, resist_c, equips_c, uses_c, chances_c = att3, def3, basic3, special3, resist3, equips3, uses3, chances3
	elseif(sel == 2) then
		att_a, def_a, basic_a, special_a, resist_a, equips_a, uses_a, chances_a = att4, def4, basic4, special4, resist4, equips4, uses4, chances4
		att_b, def_b, basic_b, special_b, resist_b, equips_b, uses_b, chances_b = att5, def5, basic5, special5, resist5, equips5, uses5, chances5
		att_c, def_c, basic_c, special_c, resist_c, equips_c, uses_c, chances_c = att6, def6, basic6, special6, resist6, equips6, uses6, chances6
	end
	
	if(att_a == nil or att_b == nil) then
		return
	end
	
	local double_replace = false
	local _, basei_link = base_tooltip:GetItem()
		local base_itemSubClassID = select(13, GetItemInfo(basei_link))
		if(base_itemSubClassID == LE_ITEM_WEAPON_SWORD2H
				or base_itemSubClassID == LE_ITEM_WEAPON_AXE2H
				or base_itemSubClassID == LE_ITEM_WEAPON_MACE2H
				or base_itemSubClassID == LE_ITEM_WEAPON_POLEARM
				or base_itemSubClassID == LE_ITEM_WEAPON_STAFF
				or base_itemSubClassID == LE_ITEM_WEAPON_BOWS
				or base_itemSubClassID == LE_ITEM_WEAPON_GUNS
				or base_itemSubClassID == LE_ITEM_WEAPON_FISHINGPOLE) then
		if(GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot")) ~= nil
				and GetInventoryItemLink("player", GetInventorySlotInfo("SecondaryHandSlot")) ~= nil) then
			double_replace = true
		end
	end
	if(double_replace and att_c == nil) then
		return
	end
	
	local min_dmg = att_a.min_dmg - att_b.min_dmg
	local max_dmg = att_a.max_dmg - att_b.max_dmg
	local dps = att_a.dps - att_b.dps
	
	local armor = def_a.Armor - def_b.Armor
	local block = def_a.Block - def_b.Block
	local durability = def_a.Durability - def_b.Durability
	
	local agility = basic_a.Agility - basic_b.Agility
	local stamina = basic_a.Stamina - basic_b.Stamina
	local strength = basic_a.Strength - basic_b.Strength
	local intellect = basic_a.Intellect - basic_b.Intellect
	local spirit = basic_a.Spirit - basic_b.Spirit
	
	local dodge = special_a.Dodge - special_b.Dodge
	
	local arcane_resist = resist_a.Arcane_Resist - resist_b.Arcane_Resist
	local fire_resist = resist_a.Fire_Resist - resist_b.Fire_Resist
	local frost_resist = resist_a.Frost_Resist - resist_b.Frost_Resist
	local nature_resist = resist_a.Nature_Resist - resist_b.Nature_Resist
	local shadow_resist = resist_a.Shadow_Resist - resist_b.Shadow_Resist
	
	if(double_replace and att_c ~= nil) then
		min_dmg = min_dmg - att_c.min_dmg
		max_dmg = max_dmg - att_c.max_dmg
		dps = dps - att_c.dps
		
		armor = armor - def_c.Armor
		block = block - def_c.Block
		durability = durability - def_c.Durability
		
		agility = agility - basic_c.Agility
		stamina = stamina - basic_c.Stamina
		strength = strength - basic_c.Strength
		intellect = intellect - basic_c.Intellect
		spirit = spirit - basic_c.Spirit
		
		dodge = dodge - special_c.Dodge
		
		arcane_resist = arcane_resist - resist_c.Arcane_Resist
		fire_resist = fire_resist - resist_c.Fire_Resist
		frost_resist = frost_resist - resist_c.Frost_Resist
		nature_resist = nature_resist - resist_c.Nature_Resist
		shadow_resist = shadow_resist - resist_c.Shadow_Resist
	end
	if(sel == 2) then
		durability = 0
	end
	
	local _, _, classID = UnitClass("player");
	
	local agility_ap_melee = 0
	local agility_ap_range = 0
	local agility_crit = 0
	local agility_dodge = 0
	local agility_catform_ap_melee = 0
	local agility_armor = 2 * agility
	
	local stamina_health = 10 * stamina
	
	local strength_ap_melee = 0
	local strength_block = 0
	
	local intellect_mana = 0 -- 15 * intellect
	local intellect_crit = 0
	
	local spirit_hpt = 0
	local spirit_mpt = 0
	
	local arcane_resist_p = 0.238095238 * arcane_resist
	local fire_resist_p = 0.238095238 * fire_resist
	local frost_resist_p = 0.238095238 * frost_resist
	local nature_resist_p = 0.238095238 * nature_resist
	local shadow_resist_p = 0.238095238 * shadow_resist
	
	
	if(classID == 1) then -- warrior
		agility_ap_range = 2 * agility
		agility_crit = 0.05 * agility
		agility_dodge = 0.05 * agility
		
		strength_ap_melee = 2 * strength
		strength_block = 0.05 * strength
		
		spirit_hpt = 0.80 * spirit
	elseif(classID == 2) then -- paladin
		agility_crit = 0.05 * agility
		agility_dodge = 0.05 * agility
		
		strength_ap_melee = 2 * strength
		strength_block = 0.05 * strength
		
		intellect_mana = 15 * intellect
		intellect_crit = 0.033898305 * intellect
		
		spirit_hpt = 0.80 * spirit
		spirit_mpt = 0.20 * spirit
	elseif(classID == 3) then -- hunter
		agility_ap_melee = 1 * agility
		agility_ap_range = 2 * agility
		agility_crit = 0.018867924 * agility
		agility_dodge = 0.037735849 * agility
		
		strength_ap_melee = 1 * strength
		
		intellect_mana = 15 * intellect
		
		spirit_hpt = 1.0 * spirit
		spirit_mpt = 0.20 * spirit
	elseif(classID == 4) then -- rogue
		agility_ap_melee = 1 * agility
		agility_ap_range = 2 * agility
		agility_crit = 0.03448275 * agility
		agility_dodge = 0.06896551 * agility
		
		strength_ap_melee = 1 * strength
		
		spirit_hpt = 0.60 * spirit
	elseif(classID == 5) then -- priest
		agility_crit = 0.05 * agility
		agility_dodge = 0.05 * agility
		
		strength_ap_melee = 2 * strength
		
		intellect_mana = 15 * intellect
		intellect_crit = 0.0168918918 * intellect
		
		spirit_hpt = 1.0 * spirit
		spirit_mpt = 0.25 * spirit
	elseif(classID == 7) then -- shaman
		agility_crit = 0.05 * agility
		agility_dodge = 0.05 * agility
		
		strength_ap_melee = 2 * strength
		strength_block = 0.05 * strength
		
		intellect_mana = 15 * intellect
		intellect_crit = 0.016806722 * intellect
		
		spirit_hpt = 1.1 * spirit
		spirit_mpt = 0.20 * spirit
	elseif(classID == 8) then -- mage
		agility_crit = 0.05 * agility
		agility_dodge = 0.05 * agility
		
		strength_ap_melee = 2 * strength
		
		intellect_mana = 15 * intellect
		intellect_crit = 0.016806722 * intellect
		
		spirit_hpt = 1.0 * spirit
		spirit_mpt = 0.25 * spirit
	elseif(classID == 9) then -- warlock
		agility_crit = 0.05 * agility
		agility_dodge = 0.05 * agility
		
		strength_ap_melee = 2 * strength
		
		intellect_mana = 15 * intellect
		intellect_crit = 0.016501650 * intellect
		
		spirit_hpt = 0.7 * spirit
		spirit_mpt = 0.25 * spirit
	elseif(classID == 11) then -- druid
		agility_crit = 0.05 * agility
		agility_dodge = 0.05 * agility
		agility_catform_ap_melee = 1 * agility
		
		strength_ap_melee = 2 * strength
		
		intellect_mana = 15 * intellect
		intellect_crit = 0.016666666 * intellect
		
		spirit_hpt = 0.9 * spirit
		spirit_mpt = 0.20 * spirit
	end
	
	
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
	
	tooltip:AddLine(" ")
	tooltip:AddLine(L["TOOLTIP_ITEM_COMPARE"], 0.06666, 0.6, 0.06666, false)
	
	-- min/max attack
	if(min_dmg ~= 0 or max_dmg ~= 0) then
		send_line(((min_dmg > 0) and string.format("|cFF00FF00+%s|r", min_dmg) or string.format("|cFFFF0000%s|r", min_dmg))
					.. " / "
					.. ((max_dmg > 0) and string.format("|cFF00FF00+%s|r", max_dmg) or string.format("|cFFFF0000%s|r", max_dmg))
					.. L["TOOLTIP_IC_DAMAGE_DELTA"] .. math.abs(max_dmg - min_dmg) .. ")")
	end
	
	-- dps
	if(dps ~= 0) then
		send_line((dps > 0 and "+" or "") .. dps .. " " .. L["TOOLTIP_IC_DPS"], dps > 0 and 0 or 1, dps > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	-- armor/block/durability
	if(armor ~= 0) then
		send_line((armor > 0 and "+" or "") .. armor .. " " .. L["TOOLTIP_IC_ARMOR"], armor > 0 and 0 or 1, armor > 0 and 1 or 0, 0, true)
	end
	if(block ~= 0) then
		send_line((block > 0 and "+" or "") .. block .. " " .. L["TOOLTIP_IC_BLOCK"], block > 0 and 0 or 1, block > 0 and 1 or 0, 0, true)
	end
	if(durability ~= 0) then
		send_line((durability > 0 and "+" or "") .. durability .. " " .. L["TOOLTIP_IC_DURABILITY"], durability > 0 and 0 or 1, durability > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	-- basic stats
	if(agility ~= 0) then
		send_line((agility > 0 and "+" or "") .. agility .. " " .. L["TOOLTIP_IC_AGILITY"], agility > 0 and 0 or 1, agility > 0 and 1 or 0, 0, true)
	end
	if(stamina ~= 0) then
		send_line((stamina > 0 and "+" or "") .. stamina .. " " .. L["TOOLTIP_IC_STAMINA"], stamina > 0 and 0 or 1, stamina > 0 and 1 or 0, 0, true)
	end
	if(strength ~= 0) then
		send_line((strength > 0 and "+" or "") .. strength .. " " .. L["TOOLTIP_IC_STRENGTH"], strength > 0 and 0 or 1, strength > 0 and 1 or 0, 0, true)
	end
	if(intellect ~= 0) then
		send_line((intellect > 0 and "+" or "") .. intellect .. " " .. L["TOOLTIP_IC_INTELLECT"], intellect > 0 and 0 or 1, intellect > 0 and 1 or 0, 0, true)
	end
	if(spirit ~= 0) then
		send_line((spirit > 0 and "+" or "") .. spirit .. " " .. L["TOOLTIP_IC_SPIRIT"], spirit > 0 and 0 or 1, spirit > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	-- special
	if(dodge ~= 0) then
		send_line((dodge > 0 and "+" or "") .. dodge .. "% " .. L["TOOLTIP_IC_DODGE"], dodge > 0 and 0 or 1, dodge > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	-- TODO: attack power, enchants, probably not set effects
	-- enchants are going to be difficult
	if(arcane_resist ~= 0) then
		send_line((arcane_resist > 0 and "+" or "") .. arcane_resist .. " " .. L["TOOLTIP_IC_ARCANE"], arcane_resist > 0 and 0 or 1, arcane_resist > 0 and 1 or 0, 0, true)
	end
	if(fire_resist ~= 0) then
		send_line((fire_resist > 0 and "+" or "") .. fire_resist .. " " .. L["TOOLTIP_IC_FIRE"], fire_resist > 0 and 0 or 1, fire_resist > 0 and 1 or 0, 0, true)
	end
	if(frost_resist ~= 0) then
		send_line((frost_resist > 0 and "+" or "") .. frost_resist .. " " .. L["TOOLTIP_IC_FROST"], frost_resist > 0 and 0 or 1, frost_resist > 0 and 1 or 0, 0, true)
	end
	if(nature_resist ~= 0) then
		send_line((nature_resist > 0 and "+" or "") .. nature_resist .. " " .. L["TOOLTIP_IC_NATURE"], nature_resist > 0 and 0 or 1, nature_resist > 0 and 1 or 0, 0, true)
	end
	if(shadow_resist ~= 0) then
		send_line((shadow_resist > 0 and "+" or "") .. shadow_resist .. " " .. L["TOOLTIP_IC_SHADOW"], shadow_resist > 0 and 0 or 1, shadow_resist > 0 and 1 or 0, 0, true)
	end
	
	blank_if_dirty()
	
	if(KiwiItemInfo_Vars.vars["item_compare_extra"] == true) then
		
		if(agility_ap_melee ~= 0) then
			send_line(L["TOOLTIP_EX_AGI_M_AP"] .. string.format("|cFFEFEF00%s|r", tostring(agility_ap_melee) .. " (" .. (agility_ap_melee < 0 and "-" or "+") .. tostring(agility_ap_melee/14):match("%d+%.?%d?%d?") .. " DPS)"), 1, 1, 1, true)
		end
		if(agility_ap_range ~= 0) then
			send_line(L["TOOLTIP_EX_AGI_R_AP"] .. string.format("|cFFEFEF00%s|r", tostring(agility_ap_range) .. " (" .. (agility_ap_range < 0 and "-" or "+") .. tostring(agility_ap_range/14):match("%d+%.?%d?%d?") .. " DPS)"), 1, 1, 1, true)
		end
		if(agility_crit ~= 0) then
			send_line(L["TOOLTIP_EX_AGI_CRIT"] .. string.format("|cFFEFEF00%s|r", tostring(agility_crit):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
		end
		if(agility_dodge ~= 0) then
			send_line(L["TOOLTIP_EX_AGI_DODGE"] .. string.format("|cFFEFEF00%s|r", tostring(agility_dodge):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
		end
		if(agility_armor ~= 0) then
			send_line(L["TOOLTIP_EX_AGI_AR"] .. string.format("|cFFEFEF00%s|r", tostring(agility_armor)), 1, 1, 1, true)
		end
		if(agility_catform_ap_melee ~= 0) then
			send_line(L["TOOLTIP_EX_AGI_M_CAT_AP"] .. string.format("|cFFEFEF00%s|r", tostring(agility_catform_ap_melee) .. " (" .. (agility_catform_ap_melee < 0 and "-" or "+") .. tostring(agility_catform_ap_melee/14):match("%d+%.?%d?%d?") .. " DPS)"), 1, 1, 1, true)
		end
		if(stamina_health ~= 0) then
			send_line(L["TOOLTIP_EX_STM_HP"] .. string.format("|cFFEFEF00%s|r", tostring(stamina_health)), 1, 1, 1, true)
		end
		if(strength_ap_melee ~= 0) then
			send_line(L["TOOLTIP_EX_STR_M_AP"] .. string.format("|cFFEFEF00%s|r", tostring(strength_ap_melee) .. " (" .. (strength_ap_melee < 0 and "-" or "+") .. tostring(strength_ap_melee/14):match("%d+%.?%d?%d?") .. " DPS)"), 1, 1, 1, true)
		end
		if(strength_block ~= 0) then
			send_line(L["TOOLTIP_EX_STR_BLOCK"] .. string.format("|cFFEFEF00%s|r", tostring(strength_block):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
		end
		if(intellect_mana ~= 0) then
			send_line(L["TOOLTIP_EX_INT_MANA"] .. string.format("|cFFEFEF00%s|r", tostring(intellect_mana)), 1, 1, 1, true)
		end
		if(intellect_crit ~= 0) then
			send_line(L["TOOLTIP_EX_INT_CRIT"] .. string.format("|cFFEFEF00%s|r", tostring(intellect_crit):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
		end
		if(spirit_hpt ~= 0) then
			send_line(L["TOOLTIP_EX_SPT_HP5"] .. string.format("|cFFEFEF00%s|r", tostring(spirit_hpt):match("%d+%.?%d?%d?")), 1, 1, 1, true)
		end
		if(spirit_mpt ~= 0) then
			send_line(L["TOOLTIP_EX_SPT_MP5"] .. string.format("|cFFEFEF00%s|r", tostring(spirit_mpt):match("%d+%.?%d?%d?")), 1, 1, 1, true)
		end
		if(arcane_resist_p ~= 0) then
			send_line(L["TOOLTIP_EX_RES_ARCANE"] .. string.format("|cFFEFEF00%s|r", tostring(arcane_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
		end
		if(fire_resist_p ~= 0) then
			send_line(L["TOOLTIP_EX_RES_FIRE"] .. string.format("|cFFEFEF00%s|r", tostring(fire_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
		end
		if(frost_resist_p ~= 0) then
			send_line(L["TOOLTIP_EX_RES_FROST"] .. string.format("|cFFEFEF00%s|r", tostring(frost_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
		end
		if(nature_resist_p ~= 0) then
			send_line(L["TOOLTIP_EX_RES_NATURE"] .. string.format("|cFFEFEF00%s|r", tostring(nature_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
		end
		if(shadow_resist_p ~= 0) then
			send_line(L["TOOLTIP_EX_RES_SHADOW"] .. string.format("|cFFEFEF00%s|r", tostring(shadow_resist_p):match("%d+%.?%d?%d?") .. "%"), 1, 1, 1, true)
		end
		
		blank_if_dirty()
	end
	
	-- equips
	for i, v in next, equips_a do
		local found = false
		for j, k in next, equips_b do
			if(v == k) then
				found = true
			end
		end
		if(double_replace) then
			for j, k in next, equips_c do
				if(v == k) then
					found = true
				end
			end
		end
		if(not found) then
			send_line(v, 0, 1, 0, true)
		end
	end
	
	for i, v in next, equips_b do
		local found = false
		for j, k in next, equips_a do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			send_line(v, 1, 0, 0, true)
		end
	end
	if(double_replace) then
		for i, v in next, equips_c do
			local found = false
			for j, k in next, equips_a do
				if(v == k) then
					found = true
				end
			end
			if(not found) then
				send_line(v, 1, 0, 0, true)
			end
		end
	end
	
	blank_if_dirty()
	
	-- uses
	for i, v in next, uses_a do
		local found = false
		for j, k in next, uses_b do
			if(v == k) then
				found = true
			end
		end
		if(double_replace) then
			for j, k in next, uses_c do
				if(v == k) then
					found = true
				end
			end
		end
		if(not found) then
			send_line(v, 0, 1, 0, true)
		end
	end
	
	for i, v in next, uses_b do
		local found = false
		for j, k in next, uses_a do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			send_line(v, 1, 0, 0, true)
		end
	end
	if(double_replace) then
		for i, v in next, uses_c do
			local found = false
			for j, k in next, uses_a do
				if(v == k) then
					found = true
				end
			end
			if(not found) then
				send_line(v, 1, 0, 0, true)
			end
		end
	end
	
	blank_if_dirty()
	
	-- chances
	for i, v in next, chances_a do
		local found = false
		for j, k in next, chances_b do
			if(v == k) then
				found = true
			end
		end
		if(double_replace) then
			for j, k in next, chances_c do
				if(v == k) then
					found = true
				end
			end
		end
		if(not found) then
			send_line(v, 0, 1, 0, true)
		end
	end
	
	for i, v in next, chances_b do
		local found = false
		for j, k in next, chances_a do
			if(v == k) then
				found = true
			end
		end
		if(not found) then
			send_line(v, 1, 0, 0, true)
		end
	end
	if(double_replace) then
		for i, v in next, chances_c do
			local found = false
			for j, k in next, chances_a do
				if(v == k) then
					found = true
				end
			end
			if(not found) then
				send_line(v, 1, 0, 0, true)
			end
		end
	end
	
	if(queue[#queue][1] == " ") then
		table.remove(queue, #queue)
	end
	
	for i, v in pairs(queue) do
		tooltip:AddLine(unpack(v))
	end
	
end


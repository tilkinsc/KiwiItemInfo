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


-- helper functions
local printi = function(type, ...)
	print((type == 0) and (KiwiItemInfo_Vars["text_print"] .. table.concat({...}, "  ") .. "|r")
		or (type == 1) and (KiwiItemInfo_Vars["text_warning"] .. table.concat({...}, "  ") .. "|r")
		or (type == 2) and (KiwiItemInfo_Vars["text_error"] .. table.concat({...}, "  ") .. "|r")
		or "")
end



-- Public table for macro usage
KiwiItemInfo = {}


-- Searches through the item database and returns a table of items that match args given
-- Prefer to use this function, as `KiwiItemInfo_Save` can be corrupted by writes (readonly)
-- Returns only 1 item (full copy) in a table if number or string is matched exact to the item name
-- Returns a table of all partial string matches (full copies)
-- Returns nil on item not found
-- Usage: /run KiwiItemIfno:GetItem(itemName/itemId/itemLink)
KiwiItemInfo.GetItem = function(self, id)
	
	if(type(id) == "number") then
		
		for i, v in next, KiwiItemInfo_Save do
			if(v.id == id) then
				return {{
					itemName = i,
					itemSubType = v.SubType,
					itemLevel = v.Level,
					id = v.id,
					itemStackCount = v.StackCount,
					itemRarity = v.Rarity,
					itemMinLevel = v.MinLevel,
					itemSellPrice = v.ellPrice,
					itemTexture = v.Texture,
					itemType = v.Type,
					itemLink = v.Link,
					itemEquipLoc = v.EquipLoc
				}}
			end
		end
		
		return nil -- itemId search
	end
	
	if(type(id) == "string") then
		
		if(KiwiItemInfo_Save[id]) then
			local v = KiwiItemInfo_Save[id]
			return {{
						itemName = id,
						itemSubType = v.SubType,
						itemLevel = v.Level,
						id = v.id,
						itemStackCount = v.StackCount,
						itemRarity = v.Rarity,
						itemMinLevel = v.MinLevel,
						itemSellPrice = v.SellPrice,
						itemTexture = v.Texture,
						itemType = v.Type,
						itemLink = v.Link,
						itemEquipLoc = v.EquipLoc
					}}
		end
		
		if(string.find(id, "|c")) then
			for i, v in next, KiwiItemInfo_Save do
				if(v.itemLink == id) then
					return {{
						itemName = i,
						itemSubType = v.SubType,
						itemLevel = v.Level,
						id = v.id,
						itemStackCount = v.StackCount,
						itemRarity = v.Rarity,
						itemMinLevel = v.MinLevel,
						itemSellPrice = v.SellPrice,
						itemTexture = v.Texture,
						itemType = v.Type,
						itemLink = v.Link,
						itemEquipLoc = v.EquipLoc
					}}
				end
			end
			
			return nil -- itemLink search
		end
		
		local stack = {}
		
		for i, v in next, KiwiItemInfo_Save do
			if(string.find(i, id)) then
				table.insert(stack, {
					itemName = i,
					itemSubType = v.SubType,
					itemLevel = v.Level,
					id = v.id,
					itemStackCount = v.StackCount,
					itemRarity = v.Rarity,
					itemMinLevel = v.MinLevel,
					itemSellPrice = v.SellPrice,
					itemTexture = v.Texture,
					itemType = v.Type,
					itemLink = v.Link,
					itemEquipLoc = v.EquipLoc
				})
			end
		end
		
		return #stack > 0 and stack or nil -- itemName search
	end
	
end

-- Booleans if any bag slot is open
local TestBagOpen = function(self)
	
	for i=0, NUM_BAG_SLOTS do
		if(IsBagOpen(i)) then
			return true
		end
	end
	
	return false
end



-- Shows junk items in inventory
local ShowJunk = function(self)
	
	if(not TestBagOpen()) then
		return
	end
	
	local itemList = {}
	
	for slot=0, NUM_BAG_SLOTS do
		for index=1, GetContainerNumSlots(slot) do
			
			local item = GetContainerItemID(slot, index)
			
			if(item) then
				
				local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
					itemStackCount, itemEquipLoc, itemIcon, vendorPrice, itemClassID, itemSubClassID,
					bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(item)
				
				if(vendorPrice > 0 and itemRarity == 0) then
					table.insert(itemList, {slot = slot, index = index})
				end
			end
			
		end
	end
	
	for i=1, #itemList do
		
		local frame = _G["ContainerFrame" .. (itemList[i].slot + 1) .. "Item" .. (GetContainerNumSlots(itemList[i].slot) + 1 - itemList[i].index)]
		
		if(frame and frame:IsShown()) then
			frame.NewItemTexture:SetAtlas("bags-glow-orange")
			frame.NewItemTexture:Show()
			frame.newitemglowAnim:Play()
		end
		
	end
	
end



-- Adds item data to tooltips
local ShowItemInfo = function(tooltip)
	
	if(MerchantFrame:IsShown()) then
		return
	end
	
	local _, tt_itemLink = tooltip:GetItem()
	if(not tt_itemLink) then
		return
	end
	
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
			itemStackCount, itemEquipLoc, itemIcon, vendorPrice, itemClassID, itemSubClassID,
			bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(tt_itemLink)
	
	if(not vendorPrice or vendorPrice <= 0) then
		return
	end
	
	if(itemStackCount > 1) then
		if(tooltip:GetName() == "GameTooltip") then
			local container = GetMouseFocus()
			local object = container:GetObjectType()
			
			local count = container.count or (object == "CheckButton" and tonumber(container.Count:GetText()) or 1)
			itemStackCount = type(count) == "number" and count or 1
		end
		SetTooltipMoney(tooltip, vendorPrice, nil, "Unit: ")
		SetTooltipMoney(tooltip, vendorPrice * itemStackCount, nil, "Stack:")
	else
		SetTooltipMoney(tooltip, vendorPrice, nil, "")
	end
	
	local tooltipName = tooltip:GetName()
	if(itemType == "Weapon" or itemType == "Armor") then
		
		local tooltipiLvl
		if(tooltipName == "GameTooltip") then
			tooltipiLvl = _G[tooltipName .. "TextRight1"]
		else
			tooltipiLvl = _G[tooltipName .. "TextRight2"]
		end
		
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

local pry_item_stats = function(tooltip, index)
	
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
			print("Kiwi Item Info: Error! Not more lines!")
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

local set_item_upgrades = function(base, base_root, test, test_root)
	
	local basic1, def1, att1, special1, resist1, equips1, enchants1 = pry_item_stats(base, base_root)
	local basic2, def2, att2, special2, resist2, equips2, enchants2 = pry_item_stats(test, test_root)
	
	test:AddLine(" ")
	
	test:AddLine("Kiwi says equipping will do this:", 0.06666, 0.6, 0.06666, true)
	
	local line_added = false
	
	
	-- min/max attack
	do
		local min = att1.min_dmg - att2.min_dmg
		local max = att1.max_dmg - att2.max_dmg
		
		if(min ~= 0 or max ~= 0) then
			test:AddLine((min > 0 and ("|cFF00FF00+" .. min) or ("|cFFFF0000" .. min)) .. "|r" .. " / " .. (max > 0 and ("|cFF00FF00+" .. max) or ("|cFFFF0000" .. max)) .. "|r" .. " |cFFFFFFFFDamage|r")
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




-- Handles all key events
local OnKeyEvent = function(key, state)
	
	if(key == "LCTRL" and state == 1) then
		ShowJunk()
		return
	end
	
end



-- Prints out item info from a specific-formatted string, is a command
local KiwiiiCommand = function(msg)
	
	if(msg:find("help", 1) == 1 or msg == "") then
		printi(0, "Kiwi Item Info -- help")
		printi(0, "https://github.com/tilkinsc/KiwiItemInfo - for issue/bug reports")
		print("    Usage: /kiwiii [reload] [search ${=,>,<}num, #Type, @subtype, {itemid, itemname}]")
		print("     > help -- for this message")
		print("     > reload -- reloads plugin")
		print("     > search -- searches through item database for items")
		print("       * ${=,>,<}num -- show only item levels num of operation")
		print("       * #Type -- shows by type (Armor, Weapon, etc)")
		print("       * @SubType -- shows by subtype (Mail, Shields, 1HSwords, 2HSwords)")
		print("       * itemid -- search for items")
		print("       * itemname -- search for items")
		return
	end
	
	if(msg:find("reload", 1) == 1) then
		printi(2, "Reloading KiwiItemInfo...")
		KiwiItemInfo:Disable()
		KiwiItemInfo:Enable()
		printi(0, "All done! :D Kiwi is functioning!")
		return
	end
	
	
	-- split message into arguments
	local args = {string.split(" ", msg)}
	if(#args < 1) then
		printi(2, "Kiwi Item Info: Invalid argument length.")
		return
	end
	
	
	if(args[1] == "search") then
		
		if(KiwiItemInfo_Vars["kiwiii_search_cmd_state"] == false) then
			printi(2, "Kiwi declines usage of `/kiwiii search` due to lack of loading the database.")
			return
		end
		
		-- collect arguments
		local enable_ilvl_search = false
		local ilvl_operation = nil
		local ilvl_search = nil
		
		local enable_type_search = false
		local type_search = nil
		
		local enable_subtype_search = false
		local subtype_search = nil
		
		local tester = nil
		
		for i=2, #args do
			local arg = args[i]
			
			if(arg:find("%$", 1)) then
				
				if(#arg < 3) then
					printi(2, "Kiwi Item Info: Invalid argument length to argument", arg, "!")
					return
				end
				
				enable_ilvl_search = true
				ilvl_operation = arg:sub(2, 2)
				ilvl_search = tonumber(arg:sub(3))
				
			elseif(arg:find("#", 1)) then
				
				enable_type_search = true
				type_search = arg:sub(2):gsub("%u", " %1"):trim()
				
			elseif(arg:find("@", 1)) then
				
				enable_subtype_search = true
				
				subtype_search = arg:sub(2)
				subtype_search = subtype_search:gsub("1H", "One-Handed ")
				subtype_search = subtype_search:gsub("2H", "Two-Handed ")
				if(not subtype_search:find("One", 1) and not subtype_search:find("Two")) then
					subtype_search = subtype_search:gsub("%u", " %1"):trim()
				end
				
			else
				tester = table.concat(args, " ", i, #args):trim()
				
				local num_test = tonumber(tester)
				tester = num_test and num_test or tester
				
				break
			end
			
		end
		
		
		-- easy way out, nil if failed, item if success
		local direct_try = (function()
			
			if(not type(tester) == "string") then
				return
			end
			
			local dt = KiwiItemInfo_Save[tester]
			
			if(dt) then
				if(enable_type_search and not (dt.Type == type_search)) then
					return
				end
				
				if(enable_subtype_search and not (dt.SubType == subtype_search)) then
					return
				end
				
				if(enable_ilvl_search and (
								ilvl_operation == "=" and (dt.Level ~= ilvl_search)
							or	ilvl_operation == ">" and (dt.Level <= ilvl_search)
							or	ilvl_operation == "<" and (dt.Level >= ilvl_search)
							or	false)) then
					return
				end
				
				return dt
			end
			
		end)()
		
		if(direct_try) then
			printi(0, "Kiwi says `this is your item`:")
			print(direct_try.Link)
			return
		end
		
		
		
		-- the hard way
		local tester_operands
		if(type(tester) == "string") then
			tester_operands = {string.split(" ", tester)}
		end
		
		local count = 0
		local success
		for i, v in next, KiwiItemInfo_Save do
			success = true
			
			if(enable_type_search and not (v.Type == type_search)) then
				success = false
			end
			
			if(enable_subtype_search and not (v.SubType == subtype_search)) then
				success = false
			end
			
			if(enable_ilvl_search and (
							ilvl_operation == "=" and (v.Level ~= ilvl_search)
						or	ilvl_operation == ">" and (v.Level <= ilvl_search)
						or	ilvl_operation == "<" and (v.Level >= ilvl_search)
						or	false)) then
				success = false
			end
			
			if(tester) then
				if(type(tester) == "number") then
					if(v.Id ~= tester) then
						success = false
					end
				else
					local required_operands = #tester_operands
					
					for _, name in next, tester_operands do
						if(i:find(name)) then
							required_operands = required_operands - 1
						end
					end
					
					if(required_operands > 0) then
						success = false
					end
				end
			end
			
			if(success) then
				count = count + 1
				print(v.Link)
			end
		end
		
		if(count > 0) then
			printi(0, "Kiwi so cool. Kiwi so fly. kiwi found", count, "items.")
		else
			printi(2, "Kiwi couldn't find any items! :(")
		end
		
		return
	end
	
end




KiwiItemInfo.Disable = function(self)
	
	GameTooltip:SetScript("OnTooltipSetItem", nil)
	ItemRefTooltip:SetScript("OnTooltipSetItem", nil)
	ShoppingTooltip1:SetScript("OnTooltipSetItem", nil)
	ShoppingTooltip2:SetScript("OnTooltipSetItem", nil)
	
	SlashCmdList["KIWIITEMINFO_LOOKUP"] = nil
	SLASH_KIWIITEMINFO_LOOKUP1 = nil
	
	KiwiItemInfo.EventFrame:UnregisterEvent("MODIFIER_STATE_CHANGED")
	KiwiItemInfo.Events["MODIFIER_STATE_CHANGED"] = nil
	
end

KiwiItemInfo.Enable = function(self)
	
	if(not KiwiItemInfo_Vars) then
		
		KiwiItemInfo_Vars = {
			["text_error"] = "|cFFFF0000",
			["text_print"] = "|cFF0FFF0F",
			["text_warning"] = "|cFF00CC22",
			["kiwiii_search_cmd_state"] = true
		}
		
		printi(0, "Kiwi thanks you for installing KiwiItemInfo! <3")
	end
	
	-- ensure database is present, if user wants it
	KiwiItemInfo_Vars["kiwiii_search_cmd_state"] = true
	if(not KiwiItemInfo_Save) then
		printi(1, "Kiwi's Item Info database wasn't loaded! Not using `/kiwiii` command.")
		KiwiItemInfo_Vars["kiwiii_search_cmd_state"] = false
	end
	
	
	-- commands
	SlashCmdList["KIWIITEMINFO_CMD"] = KiwiiiCommand
	SLASH_KIWIITEMINFO_CMD1 = "/kiwiii"
	
	
	-- tooltip events
	GameTooltip:SetScript("OnTooltipSetItem", ShowItemInfo)
	ItemRefTooltip:SetScript("OnTooltipSetItem", ShowItemInfo)
	
	ShoppingTooltip1:SetScript("OnTooltipSetItem", function(tooltip)
		ShowItemInfo(tooltip)
		set_item_upgrades(GameTooltip, "GameTooltipText", tooltip, tooltip:GetName() .. "Text")
	end)
	
	ShoppingTooltip2:SetScript("OnTooltipSetItem", function(tooltip)
		ShowItemInfo(tooltip)
		set_item_upgrades(GameTooltip, "GameTooltipText", tooltip, tooltip:GetName() .. "Text")
	end)
	
	
	-- bag events
	KiwiItemInfo.Events["MODIFIER_STATE_CHANGED"] = OnKeyEvent
	KiwiItemInfo.EventFrame:RegisterEvent("MODIFIER_STATE_CHANGED")
	
end



local ADDON_LOADED = function(addon)
	if(addon ~= "KiwiItemInfo") then
		return
	end
	
	KiwiItemInfo:Enable()
end

-- hooks and events
KiwiItemInfo.Events = {
	["ADDON_LOADED"] = ADDON_LOADED
}


local KiwiItemInfo_Frame = CreateFrame("Frame")
KiwiItemInfo.EventFrame = KiwiItemInfo_Frame
KiwiItemInfo_Frame:RegisterEvent("ADDON_LOADED")
KiwiItemInfo_Frame:SetScript("OnEvent", function(self, event, ...)
	KiwiItemInfo.Events[event](...)
end)

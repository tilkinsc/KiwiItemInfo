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
	print(string.format(
			(type == 0) and KiwiItemInfo_Vars["text_print"] or (type == 1) and KiwiItemInfo_Vars["text_warning"] or (type == 2) and KiwiItemInfo_Vars["text_error"],
			table.concat({...}, "  ")))
end



-- Public table for macro usage
KiwiItemInfo = {}
KiwiItemInfo._VERSION = "2.1.1"

local DEFAULT_VARS = {
	["VERSION"] = "2.1.1",
	["text_error"] = "|cFFFF0000%s|r",
	["text_print"] = "|cFF0FFF0F%s|r",
	["text_warning"] = "|cFF00CC22%s|r",
	["search_cmd_state"] = true,
	["vars"] = {
		["flash_grey_items"] = true,
		["ilvl_only_equips"] = true,
		["item_compare_on"] = true,
		["tooltip_price_on"] = true,
		["tooltip_ilvl_on"] = true
	}
}


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
	
	local tooltipName = tooltip:GetName()
	local _, i_link = tooltip:GetItem()
	
	if(not i_link or i_link == "[]") then
		i_link = KiwiItemInfo:GetItem(_G[tooltipName .. "TextLeft1"]:GetText())[1].itemLink
	end
	
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
			itemStackCount, itemEquipLoc, itemIcon, vendorPrice, itemClassID, itemSubClassID,
			bindType, expacID, itemSetID, isCraftingReagent = GetItemInfo(i_link)
	
	if(KiwiItemInfo_Vars.vars["tooltip_price_on"] == true) then
		if(not MerchantFrame:IsShown() and (vendorPrice and vendorPrice > 0)) then
			if(itemStackCount > 1) then
				if(tooltipName == "GameTooltip") then
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
		end
	end
	
	if(KiwiItemInfo_Vars.vars["tooltip_ilvl_on"] == true) then
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

-- Parses tooltip text for item stats
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

-- Tacks on to the end of tooltips the differences between two items stats
local set_item_upgrades = function(base, base_root, test, test_root)
	
	if(KiwiItemInfo_Vars.vars["item_compare_on"] == false) then
		return
	end
	
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




-- Handles all key events
local OnKeyEvent = function(key, state)
	
	if(key == "LCTRL" and state == 1) then
		ShowJunk()
		return
	end
	
end



-- Prints out item info from a specific-formatted string, is a command
local KiwiiiCommand = function(msg)
	
	-- split message into arguments
	local args = {string.split(" ", msg)}
	if(#args < 1) then
		printi(2, "Kiwi Item Info: Invalid argument length.")
		return
	end
	
	-- help message
	if(args[1] == "help" or msg == "") then
		printi(0, "Kiwi Item Info " .. KiwiItemInfo._VERSION .. " -- help")
		printi(0, "https://github.com/tilkinsc/KiwiItemInfo - for issue/bug reports")
		print("Usage: /kiwiii [reload] [reset] [vars]")
		print("               [set variable_name value]")
		print("               [search ${=,>,<}num, #Type, @subtype, {itemid, itemname}]")
		print("    > |cFF888888help|r -- for this message")
		print("    > |cFF888888reload|r -- reloads plugin")
		print("    > |cFF888888reset|r -- resets all saved variables, also reloads")
		print("    > |cFF888888vars|r -- shows all setting variables")
		print("    > |cFF888888set|r -- toggles a setting")
		print("        * |cFFBBBBBBvariable_name|r -- variable shown in /kiwiii vars")
		print("        * |cFFBBBBBBvalue|r -- either true, false, string, or number")
		print("    > |cFF888888search|r -- searches through item database for items")
		print("        * |cFFBBBBBB${=,>,<}num|r -- show only item levels num of operation")
		print("        * |cFFBBBBBB#Type|r -- shows by type (Armor, Weapon, etc)")
		print("        * |cFFBBBBBB@SubType|r -- shows by subtype (Mail, 1HSwords, 2HSwords, etc)")
		print("        * |cFFBBBBBBitemid|r -- search for items")
		print("        * |cFFBBBBBBitemname|r -- search for items")
		return
	end
	
	-- reload plugin
	if(args[1] == "reload") then
		printi(2, "Reloading KiwiItemInfo...")
		KiwiItemInfo:Disable()
		KiwiItemInfo:Enable()
		printi(0, "All done! :D Kiwi is functioning!")
		return
	end
	
	-- hard reset of plugin
	if(args[1] == "reset") then
		printi(2, "Resetting KiwiItemInfo...")
		KiwiItemInfo:Disable()
		KiwiItemInfo_Vars = nil
		KiwiItemInfo:Enable()
		printi(0, "All done! :D Kiwi is functioning!")
		return
	end
	
	-- displays variables user can change
	if(args[1] == "vars") then
		printi(2, "Dumping user settings...")
		for i, v in next, KiwiItemInfo_Vars.vars do
			print("   >", "|cFF888888" .. i .. "|r", "=", (v == true) and ("|cFF00FF00" .. tostring(v) .. "|r") or (v == false) and ("|cFFFF0000" .. tostring(v) .. "|r") or v)
		end
		printi(0, "All done!")
		return
	end
	
	-- sets variables the user can change
	if(args[1] == "set") then
		if(args[2]) then
			if(args[3]) then
				local var = KiwiItemInfo_Vars.vars[args[2]]
				if(var ~= nil) then
					
					local val
					if(tonumber(args[3])) then
						val = tonumber(args[3])
					elseif(args[3] == "true") then
						val = true
					elseif(args[3] == "false") then
						val = false
					else -- string
						val = table.concat(args, " ", 3, #args)
					end
					
					if(type(var) == "boolean") then
						if(type(val) == "boolean") then
							KiwiItemInfo_Vars.vars[args[2]] = val
						else
							printi(2, "Kiwi expects a boolean value (true/false). Sorry.")
							return
						end
					elseif(type(var) == "number") then
						if(type(val) == "number") then
							KiwiItemInfo_Vars.vars[args[2]] = val
						else
							printi(2, "Kiwi expects a number value. Sorry.")
							return
						end
					elseif(type(var) == "string") then
						if(type(val) == "string") then
							KiwiItemInfo_Vars.vars[args[2]] = val
						else
							printi(2, "Kiwi expects a string value (words). Sorry.")
							return
						end
					end
				else
					printi(2, "Kiwi doesn't have such a variable. Sorry.")
					return
				end
			else
				printi(2, "Kiwi needs a value to set to the variable...")
				return
			end
		else
			printi(2, "Kiwi needs a variable to set...")
			return
		end
		return
	end
	
	-- Searches for items in db
	if(args[1] == "search") then
		
		if(KiwiItemInfo_Vars["search_cmd_state"] == false) then
			printi(2, "Kiwi declines usage of `/kiwiii search` (due to lack of loading the database?)")
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



-- Disables the plugin
KiwiItemInfo.Disable = function(self)
	
	GameTooltip:SetScript("OnTooltipSetItem", nil)
	ItemRefTooltip:SetScript("OnTooltipSetItem", nil)
	ShoppingTooltip1:SetScript("OnTooltipSetItem", nil)
	ShoppingTooltip2:SetScript("OnTooltipSetItem", nil)
	
	SlashCmdList["KIWIITEMINFO_CMD"] = nil
	SLASH_KIWIITEMINFO_CMD1 = nil
	
	KiwiItemInfo.EventFrame:UnregisterEvent("MODIFIER_STATE_CHANGED")
	KiwiItemInfo.Events["MODIFIER_STATE_CHANGED"] = nil
	
end

-- Enables the plugin
KiwiItemInfo.Enable = function(self)
	
	if(not KiwiItemInfo_Vars) then
		
		KiwiItemInfo_Vars = DEFAULT_VARS
		
		printi(0, "Kiwi thanks you for installing KiwiItemInfo " .. KiwiItemInfo._VERSION .. "! <3")
		printi(0, "Please run `/kiwiii help` for a command listing!")
	else
		if(KiwiItemInfo_Vars.VERSION ~= KiwiItemInfo._VERSION) then
			-- check if anything is new
			for i, v in next, DEFAULT_VARS do
				if(i ~= "vars" and not KiwiItemInfo_Vars[i]) then
					KiwiItemInfo_Vars[i] = v
				end
			end
			for i, v in next, DEFAULT_VARS.vars do
				if(not KiwiItemInfo_Vars.vars[i]) then
					KiwiItemInfo_Vars.vars[i] = v
				end
			end
			-- check if anything removed
			for i, v in next, KiwiItemInfo_Vars do
				if(i ~= "vars" and not DEFAULT_VARS[i]) then
					KiwiItemInfo_Vars[i] = nil
				end
			end
			for i, v in next, KiwiItemInfo_Vars.vars do
				if(not DEFAULT_VARS.vars[i]) then
					KiwiItemInfo_Vars.vars[i] = nil
				end
			end
			KiwiItemInfo_Vars.VERSION = KiwiItemInfo._VERSION
		end
	end
	
	-- ensure database is present, if user wants it
	KiwiItemInfo_Vars["search_cmd_state"] = true
	if(not KiwiItemInfo_Save) then
		printi(1, "Kiwi's Item Info database wasn't loaded! Not using `/kiwiii` command.")
		KiwiItemInfo_Vars["search_cmd_state"] = false
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



-- Default event dispatcher
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


local KiwiItemInfo_EventFrame = CreateFrame("Frame")
KiwiItemInfo.EventFrame = KiwiItemInfo_EventFrame
KiwiItemInfo_EventFrame:RegisterEvent("ADDON_LOADED")
KiwiItemInfo_EventFrame:SetScript("OnEvent", function(self, event, ...)
	KiwiItemInfo.Events[event](...)
end)


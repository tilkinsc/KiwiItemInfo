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
					itemSubType = v.itemSubType,
					itemLevel = v.itemLevel,
					id = v.id,
					itemStackCount = v.itemStackCount,
					itemRarity = v.itemRarity,
					itemMinLevel = v.itemMinLevel,
					itemSellPrice = v.itemSellPrice,
					itemTexture = v.itemTexture,
					itemType = v.itemType,
					itemLink = v.itemLink,
					itemEquipLoc = v.itemEquipLoc
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
						itemSubType = v.itemSubType,
						itemLevel = v.itemLevel,
						id = v.id,
						itemStackCount = v.itemStackCount,
						itemRarity = v.itemRarity,
						itemMinLevel = v.itemMinLevel,
						itemSellPrice = v.itemSellPrice,
						itemTexture = v.itemTexture,
						itemType = v.itemType,
						itemLink = v.itemLink,
						itemEquipLoc = v.itemEquipLoc
					}}
		end
		
		if(string.find(id, "|c")) then
			for i, v in next, KiwiItemInfo_Save do
				if(v.itemLink == id) then
					return {{
						itemName = i,
						itemSubType = v.itemSubType,
						itemLevel = v.itemLevel,
						id = v.id,
						itemStackCount = v.itemStackCount,
						itemRarity = v.itemRarity,
						itemMinLevel = v.itemMinLevel,
						itemSellPrice = v.itemSellPrice,
						itemTexture = v.itemTexture,
						itemType = v.itemType,
						itemLink = v.itemLink,
						itemEquipLoc = v.itemEquipLoc
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
					itemSubType = v.itemSubType,
					itemLevel = v.itemLevel,
					id = v.id,
					itemStackCount = v.itemStackCount,
					itemRarity = v.itemRarity,
					itemMinLevel = v.itemMinLevel,
					itemSellPrice = v.itemSellPrice,
					itemTexture = v.itemTexture,
					itemType = v.itemType,
					itemLink = v.itemLink,
					itemEquipLoc = v.itemEquipLoc
				})
			end
		end
		
		return #stack > 0 and stack or nil -- itemName search
	end
	
end

-- Booleans if any bag slot is open
KiwiItemInfo.TestBagOpen = function(self)
	
	for i=0, NUM_BAG_SLOTS do
		if(IsBagOpen(i)) then
			return true
		end
	end
	
	return false
end



-- Shows junk items in inventory
KiwiItemInfo.ShowJunk = function(self)
	
	if(not KiwiItemInfo:TestBagOpen()) then
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



-- Adds item data to tooltips in inventory
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
	
	local container = GetMouseFocus()
	local object = container:GetObjectType()
	
	local count = container.count or (object == "CheckButton" and tonumber(container.Count:GetText()) or 1)
	count = type(count) == "number" and count or 1
	
	if(count > 1) then
		SetTooltipMoney(tooltip, vendorPrice, nil, "Unit: ")
		SetTooltipMoney(tooltip, vendorPrice * count, nil, "Stack:")
	else
		SetTooltipMoney(tooltip, vendorPrice, nil, "")
	end
	
	if(itemType == "Weapon" or itemType == "Armor") then
		-- f00000	rgb 240   0   0		red
		-- f08000	rgb 240 128   0		orange
		-- f0f000	rgb 240 240   0		yellow
		-- 00e000	rgb   0 224   0		green
		-- 808080	rgb 128 128 128		grey
		
		local playerLevel = UnitLevel("player")
		
		if(playerLevel <= itemLevel) then
			GameTooltipTextRight1:SetTextColor(0.9375, 0, 0) -- red
		elseif(itemLevel > playerLevel - 3) then
			GameTooltipTextRight1:SetTextColor(0.9375, 0.5, 0) -- orange
		elseif(itemLevel > playerLevel - 6) then
			GameTooltipTextRight1:SetTextColor(0.9375, 0.9375, 0) -- yellow
		elseif(itemLevel > playerLevel - 9) then
			GameTooltipTextRight1:SetTextColor(0, 0.875, 0) -- green
		else
			GameTooltipTextRight1:SetTextColor(0.5, 0.5, 0.5) -- grey
		end
		
		GameTooltipTextRight1:SetText("iLvl " .. itemLevel)
		GameTooltipTextRight1:Show()
	end
	
end

-- Adds item data to tooltips on links
local ShowRefItemInfo = function(tooltip)
	
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
		SetTooltipMoney(tooltip, vendorPrice, nil, "Unit: ")
		SetTooltipMoney(tooltip, vendorPrice * itemStackCount, nil, "Stack:")
	else
		SetTooltipMoney(tooltip, vendorPrice, nil, "")
	end
	
	if(itemType == "Weapon" or itemType == "Armor") then
		-- f00000	rgb 240   0   0		red
		-- f08000	rgb 240 128   0		orange
		-- f0f000	rgb 240 240   0		yellow
		-- 00e000	rgb   0 224   0		green
		-- 808080	rgb 128 128 128		grey
		
		local playerLevel = UnitLevel("player")
		
		if(playerLevel <= itemLevel) then
			ItemRefTooltipTextRight1:SetTextColor(0.9375, 0, 0) -- red
		elseif(itemLevel > playerLevel - 3) then
			ItemRefTooltipTextRight1:SetTextColor(0.9375, 0.5, 0) -- orange
		elseif(itemLevel > playerLevel - 5) then
			ItemRefTooltipTextRight1:SetTextColor(0.9375, 0.9375, 0) -- yellow
		elseif(itemLevel > playerLevel - 9) then
			ItemRefTooltipTextRight1:SetTextColor(0, 0.875, 0) -- green
		else
			ItemRefTooltipTextRight1:SetTextColor(0.5, 0.5, 0.5) -- grey
		end
		
		ItemRefTooltipTextRight1:SetText("iLvl " .. itemLevel)
		ItemRefTooltipTextRight1:Show()
	end
	
end

-- Handles all key events
local OnKeyEvent = function(key, state)
	
	if(key == "LCTRL" and state == 1) then
		KiwiItemInfo:ShowJunk()
		return
	end
	
end



-- Prints out item info from a specific-formatted string, is a command
local KiwiiiCommand = function(msg)
	
	if(msg:find("help", 1) or msg == "") then
		printi(0, "Kiwi Item Info -- help")
		printi(0, "https://github.com/tilkinsc/PoliteKiwi - for issue/bug reports")
		print("    Usage: /kiwiii [on, off, reload] [search ${=,>,<}num, #Type, {itemid, itemname}]")
		print("     > help -- for this message")
		print("     > reload -- reloads plugin")
		print("     > search -- searches through item database for items")
		print("       * ${=,>,<}num -- show only item levels num of operation")
		print("       * #Type -- shows by type (Mail, Cloth, Book, Consumable, Quest, etc)")
		print("       * itemid -- search for items")
		print("       * itemname -- search for items")
		return
	end
	
	if(msg:find("reload", 1)) then
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
				tester = table.concat(args, "", i, #args)
				
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
				if(enable_type_search and not (dt.itemType == type_search)) then
					return
				end
				
				if(enable_subtype_search and not (dt.itemSubType == subtype_search)) then
					return
				end
				
				if(enable_ilvl_search and (
								ilvl_operation == "=" and (dt.itemLevel ~= ilvl_search)
							or	ilvl_operation == ">" and (dt.itemLevel <= ilvl_search)
							or	ilvl_operation == "<" and (dt.itemLevel >= ilvl_search)
							or	false)) then
					return
				end
				
				return dt
			end
			
		end)()
		
		if(direct_try) then
			printi(0, "Kiwi says `this is your item`:")
			print(direct_try.itemLink)
			return
		end
		
		
		-- the hard way
		local count = 0
		local success
		for i, v in next, KiwiItemInfo_Save do
			success = true
			
			if(enable_type_search and not (v.itemType == type_search)) then
				success = false
			end
			
			if(enable_subtype_search and not (v.itemSubType == subtype_search)) then
				success = false
			end
			
			if(enable_ilvl_search and (
							ilvl_operation == "=" and (v.itemLevel ~= ilvl_search)
						or	ilvl_operation == ">" and (v.itemLevel <= ilvl_search)
						or	ilvl_operation == "<" and (v.itemLevel >= ilvl_search)
						or	false)) then
				success = false
			end
			
			if(tester and not i:find(tester)) then
				success = false
			end
			
			if(success) then
				count = count + 1
				print(v.itemLink)
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
	
	if(KiwiItemInfo_Save) then
		KiwiItemInfo.EventFrame:UnregisterEvent("MODIFIER_STATE_CHANGED")
		KiwiItemInfo.Events["MODIFIER_STATE_CHANGED"] = nil
	end
	
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
		printi(1, "Kiwi's Item Info database wasn't loaded! Not using /kiwiii command.")
		KiwiItemInfo_Vars["kiwiii_search_cmd_state"] = false
	end
	
	
	-- commands
	SlashCmdList["KIWIITEMINFO_LOOKUP"] = KiwiiiCommand
	SLASH_KIWIITEMINFO_LOOKUP1 = "/kiwiii"
	
	
	-- tooltip events
	GameTooltip:SetScript("OnTooltipSetItem", ShowItemInfo)
	ItemRefTooltip:SetScript("OnTooltipSetItem", ShowRefItemInfo)
	
	
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

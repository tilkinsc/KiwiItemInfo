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

-- Public table for macro usage
ItemInfo = {}


-- Booleans if any bag is open
ItemInfo.TestBagOpen = function(self)
	for i=0, NUM_BAG_SLOTS do
		if(IsBagOpen(i)) then
			return true
		end
	end
	
	return false
end



-- Shows junk items in inventory
ItemInfo.ShowJunk = function(self)
	
	if(not ItemInfo:TestBagOpen()) then
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
	
	local count
	if(object == "Button") then
		count = container.count
	elseif(object == "CheckButton") then
		count = container.count or tonumber(container.Count:GetText())
	end
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
		elseif(itemLevel > playerLevel - 5) then
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
local OnKeyEvent = function(self, event, key, state)
	
	if(key == "LCTRL" and state == 1) then
		ItemInfo:ShowJunk()
		return
	end
	
end



-- hooks and events
GameTooltip:HookScript("OnTooltipSetItem", ShowItemInfo)
ItemRefTooltip:HookScript("OnTooltipSetItem", ShowRefItemInfo)

local f = CreateFrame("Frame")
f:RegisterEvent("MODIFIER_STATE_CHANGED")
f:SetScript("OnEvent", OnKeyEvent)


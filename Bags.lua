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



-- Booleans if any bag slot is open
KiwiItemInfo.TestBagOpen = function()
	
	for i=0, NUM_BAG_SLOTS do
		if(IsBagOpen(i)) then
			return true
		end
	end
	
	return false
end

-- Shows junk items in inventory
KiwiItemInfo.ShowJunk = function()
	
	if(KiwiItemInfo_Vars.vars["flash_grey_items"] == false) then
		return
	end
	
	if(not KiwiItemInfo.TestBagOpen()) then
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


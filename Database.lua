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



-- Returns a table of items found with given input: itemName/itemLink/itemId
KiwiItemInfo.GetItem = function(id)
	
	local Database = KiwiItemInfo.Database
	
	if(type(id) == "number") then
		
		for i, v in next, Database do
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
		
		return nil
	end
	
	if(type(id) == "string") then
		
		-- Check by name
		if(Database[id]) then
			local v = Database[id]
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
		
		-- Check by link
		if(string.find(id, "|c", 1, 2) == 1) then
			for i, v in next, Database do
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
			
			return nil
		end
		
		-- Build a stack of all results that match
		local stack = {}
		
		for i, v in next, Database do
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
		
		return #stack > 0 and stack or nil
	end
	
end

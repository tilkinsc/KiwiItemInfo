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



local printi = KiwiItemInfo.printi

-- Prints out item info from a specific-formatted string, is a command
KiwiItemInfo.Command = function(msg)
	
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
		KiwiItemInfo.Disable()
		KiwiItemInfo.Enable()
		printi(0, "All done! :D Kiwi is functioning!")
		return
	end
	
	-- hard reset of plugin
	if(args[1] == "reset") then
		printi(2, "Resetting KiwiItemInfo...")
		KiwiItemInfo.Disable()
		KiwiItemInfo_Vars = nil
		KiwiItemInfo.Enable()
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
			
			local dt = KiwiItemInfo.Database[tester]
			
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
		for i, v in next, KiwiItemInfo.Database do
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

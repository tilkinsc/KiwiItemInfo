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
local L = KiwiItemInfo.LocaleStrings()
local LF = KiwiItemInfo.LF

-- Prints out item info from a specific-formatted string, is a command
KiwiItemInfo.Command = function(msg)
	
	-- split message into arguments
	local args = {string.split(" ", msg)}
	if(#args < 1) then -- TODO:
		printi(2, L["COMMAND_ERROR_ARG_LEN"])
		return
	end
	
	-- VarsUI
	if(args[1] == "") then
		KiwiItemInfo.VarsUI.Show()
		return
	end
	
	-- help message
	if(args[1] == L["KIWIII_HELP"] or args[1] == LF("KIWIII_HELP")) then
		printi(0, L["COMMAND_HELP1"])
		printi(0, L["COMMAND_HELP2"])
		for i=3, 19 do
			print(L["COMMAND_HELP" .. i])
		end
		return
	end
	
	-- reload plugin
	if(args[1] == L["KIWIII_RELOAD"] or args[1] == LF("KIWIII_RELOAD")) then
		printi(2, L["COMMAND_RELOAD"])
		KiwiItemInfo.Disable()
		KiwiItemInfo.Enable()
		printi(0, L["COMMAND_RELOAD_DONE"])
		return
	end
	
	-- hard reset of plugin
	if(args[1] == L["KIWIII_RESET"] or args[1] == LF("KIWIII_RESET")) then
		printi(2, L["COMMAND_RESET"])
		KiwiItemInfo.Disable()
		KiwiItemInfo_Vars = nil
		KiwiItemInfo.Enable()
		printi(0, L["COMMAND_RELOAD_DONE"])
		return
	end
	
	-- displays variables user can change
	if(args[1] == L["KIWIII_VARS"] or args[1] == LF("KIWIII_VARS")) then
		printi(2, L["COMMAND_VARS_DUMP"])
		for i, v in next, KiwiItemInfo_Vars.vars do
			print("   >", "|cFF888888" .. i .. "|r", "=", (v == true) and ("|cFF00FF00" .. tostring(v) .. "|r") or (v == false) and ("|cFFFF0000" .. tostring(v) .. "|r") or v)
		end
		printi(0, L["COMMAND_VARS_DONE"])
		return
	end
	
	-- sets variables the user can change
	if(args[1] == L["KIWIII_SET"] or args[1] == LF("KIWIII_SET")) then
		if(args[2]) then
			if(args[3]) then
				local var = KiwiItemInfo_Vars.vars[args[2]]
				if(var ~= nil) then
					
					local val
					if(type(var) == "boolean" and args[3] == "true") then
						val = true
					elseif(type(var) == "boolean" and args[3] == "false") then
						val = false
					elseif(type(var) == "number" and tonumber(args[3])) then
						val = tonumber(args[3])
					else -- string
						val = table.concat(args, " ", 3, #args):trim()
					end
					
					if(type(var) == "boolean") then
						if(type(val) == "boolean") then
							KiwiItemInfo_Vars.vars[args[2]] = val
						else
							printi(2, L["COMMAND_SET_ERROR_BOOLEAN"])
							return
						end
					elseif(type(var) == "number") then
						if(type(val) == "number") then
							KiwiItemInfo_Vars.vars[args[2]] = val
						else
							printi(2, L["COMMAND_SET_ERROR_NUMBER"])
							return
						end
					elseif(type(var) == "string") then
						if(type(val) == "string") then
							KiwiItemInfo_Vars.vars[args[2]] = val
						else
							printi(2, L["COMMAND_SET_ERROR_STRING"])
							return
						end
					end
				else
					printi(2, L["COMMAND_SET_ERROR_VAR"])
					return
				end
			else
				printi(2, L["COMMAND_SET_ERROR_VALUE"])
				return
			end
		else
			printi(2, L["COMMAND_SET_ERROR_INDEX"])
			return
		end
		return
	end
	
	-- Toggles CVar alwaysCompareItems
	if(args[1] == L["KIWIII_ACI"] or args[1] == LF("KIWIII_ACI")) then
		local cvar = GetCVar("alwaysCompareItems")
		SetCVar("alwaysCompareItems", cvar == "1" and 0 or 1)
	end
	
	-- Searches for items in db
	if(args[1] == L["KIWIII_SEARCH"] or args[1] == LF("KIWIII_SEARCH")) then
		
		if(KiwiItemInfo_Vars["search_cmd_state"] == false) then
			printi(2, L["COMMAND_SEARCH_ERROR_DB"])
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
					printi(2, L["COMMAND_SEARCH_ARG_LEN"], arg, "!")
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
				subtype_search = subtype_search:gsub("1H", L["COMMAND_SEARCH_ONE_HANDED"])
				subtype_search = subtype_search:gsub("2H", L["COMMAND_SEARCH_TWO_HANDED"])
				if(not subtype_search:find(L["COMMAND_SEARCH_1H"], 1) and not subtype_search:find(L["COMMAND_SEARCH_2H"])) then
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
			printi(0, L["COMMAND_SEARCH_DONE"])
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
			printi(0, L["COMMAND_SEARCH_DONE1"], count)
		else
			printi(2, L["COMMAND_SEARCH_FAIL"])
		end
		
		return
	end
	
end

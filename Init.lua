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


local version = GetAddOnMetadata("KiwiItemInfo", "Version")

KiwiItemInfo = {}
KiwiItemInfo._VERSION = version
KiwiItemInfo._DEFAULT_VARS = {
	["VERSION"] = version,
	["first_run"] = true,
	["text_error"] = "|cFFFF0000%s|r",
	["text_print"] = "|cFF0FFF0F%s|r",
	["text_warning"] = "|cFF00CC22%s|r",
	["search_cmd_state"] = true,
	["vars"] = {
		["flash_grey_items"] = true,
		["flash_hotkey"] = "LCTRL",
		["ilvl_only_equips"] = true,
		["item_compare_on"] = true,
		["tooltip_price_on"] = true,
		["tooltip_ilvl_on"] = true
	}
}

KiwiItemInfo.printi = function(type, ...)
	print(string.format(
				(type == 0) and KiwiItemInfo_Vars["text_print"]
					or (type == 1) and KiwiItemInfo_Vars["text_warning"]
					or (type == 2) and KiwiItemInfo_Vars["text_error"],
				table.concat({...}, "  ")
			)
		)
end



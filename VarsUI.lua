
local VarsUI = {}


local background
local scroll
local content
local elements
local font


local label_width = 190
local edit_width = 100

local padding_l = 10
local padding_v = -5

local height = 0


VarsUI.Init = function()
	table.insert(UISpecialFrames, "KiwiItemInfoKIWIIIFrame")
	background = CreateFrame("Frame", "KiwiItemInfoKIWIIIFrame", UIParent, "BasicFrameTemplate")
	background.TitleText:SetText("Kiwi Item Info Vars")
	background:SetSize(300, 300)
	background:SetPoint("CENTER")
	scroll = CreateFrame("ScrollFrame", nil, background, "UIPanelScrollFrameTemplate")
	scroll:SetSize(273, 270)
	scroll:SetPoint("TOPLEFT", 0, -25)
	content = CreateFrame("Frame", nil, background, nil)
	content:SetSize(300, 300)
	content:SetPoint("TOPLEFT")
	scroll:SetScrollChild(content)
	
	font = CreateFont("KiwiVarsUIFont")
	font:CopyFontObject(GameFontWhite)
	font:SetJustifyH("LEFT")
	
	elements = {}
	
	scroll:SetScript("OnSizeChanged", function(frame, width, height)
		content:SetWidth(width)
		content:SetHeight(height)
	end)
	
	VarsUI.Background = background
	VarsUI.Scroll = scroll
	VarsUI.Content = content
end

VarsUI.AddComponent = function(type, text, show, action)
	local fr
	
	if(type == 1) then -- number
		fr = CreateFrame("EditBox", nil, content)
		fr:SetNumeric(true)
		fr:SetAutoFocus(false)
		fr:SetFontObject(font)
		fr:SetSize(edit_width, 25)
		fr:SetPoint("TOPLEFT", padding_l + label_width, height)
		fr.Text = fr:CreateFontString()
		fr.Text:SetParent(fr)
		fr.Text:SetFontObject(font)
		fr.Text:SetSize(label_width, 25)
		fr.Text:SetPoint("LEFT", -label_width, 0)
		fr.Text:SetText(text)
		
		fr.OnShow = show
		fr.OnHide = function(self) self:ClearFocus() end
		fr:SetScript("OnEnterPressed", action)
		fr:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
		fr:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
		
		height = height - 25 - padding_v
		table.insert(elements, fr)
	elseif(type == 2) then -- string
		fr = CreateFrame("EditBox", nil, content)
		fr:SetAutoFocus(false)
		fr:SetFontObject(font)
		fr:SetSize(edit_width, 25)
		fr:SetPoint("TOPLEFT", padding_l + label_width, height)
		fr.Text = fr:CreateFontString()
		fr.Text:SetParent(fr)
		fr.Text:SetFontObject(font)
		fr.Text:SetSize(label_width, 25)
		fr.Text:SetPoint("LEFT", -label_width, 0)
		fr.Text:SetText(text)
		
		fr.OnShow = show
		fr.OnHide = function(self) self:ClearFocus() end
		fr:SetScript("OnEnterPressed", action)
		fr:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
		fr:SetScript("OnTabPressed", function(self) self:ClearFocus() end)
		
		height = height - 25 - padding_v
		table.insert(elements, fr)
	elseif(type == 3) then -- boolean
		fr = CreateFrame("CheckButton", nil, content, "ChatConfigCheckButtonTemplate")
		fr:SetSize(25, 25)
		fr:SetPoint("TOPLEFT", padding_l + label_width, height)
		fr.Text:SetFontObject(font)
		fr.Text:SetSize(label_width, 25)
		fr.Text:SetPoint("LEFT", -label_width, 0)
		fr.Text:SetText(text)
		
		fr.OnShow = show
		fr:SetScript("OnClick", action)
		
		height = height - 25 - padding_v
		table.insert(elements, fr)
	end
	
	return fr, #elements
end

VarsUI.Blank = function()
	height = height - 15
end

VarsUI.Show = function()
	for i, v in next, elements do
		if(v.OnShow) then
			v.OnShow(v)
		end
	end
	background:SetParent(UIParent)
	background:Show()
end

VarsUI.Hide = function()
	for i, v in next, elements do
		if(v.OnHide) then
			v.OnHide(v)
		end
	end
	background:Hide()
	background:SetParent(nil)
end

KiwiItemInfo.VarsUI = VarsUI

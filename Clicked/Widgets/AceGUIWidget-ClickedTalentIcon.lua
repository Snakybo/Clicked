--[[-----------------------------------------------------------------------------
A heading with a checkbox
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedTalentIcon"

--- @class ClickedTalentIcon : AceGUIWidget
--- @field private frame Button
--- @field private image Texture

local Type, Version = "ClickedTalentIcon", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Button_OnClick(frame, button)
	frame.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedTalentIcon
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:SetHeight(110)
	self:SetWidth(110)
	self:SetImage(nil)
	self:SetImageSize(64, 64)
	self:SetColor(1, 1, 1, 1)
end

function Methods:SetImage(path, ...)
	local image = self.image
	image:SetTexture(path)

	if image:GetTexture() then
		local n = select("#", ...)
		if n == 4 or n == 8 then
			image:SetTexCoord(...)
		else
			image:SetTexCoord(0, 1, 0, 1)
		end
	end
end

function Methods:SetImageSize(width, height)
	self.image:SetWidth(width)
	self.image:SetHeight(height)
end

--- @param r number
--- @param g number
--- @param b number
--- @param a number
function Methods:SetColor(r, g, b, a)
	self.image:SetVertexColor(r, g, b, a)
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnClick", Button_OnClick)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	label:SetPoint("BOTTOMLEFT")
	label:SetPoint("BOTTOMRIGHT")
	label:SetJustifyH("CENTER")
	label:SetJustifyV("TOP")
	label:SetHeight(18)

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetWidth(64)
	image:SetHeight(64)
	image:SetPoint("TOP", 0, -5)

	local widget = {
		label = label,
		image = image,
		frame = frame,
		type  = Type
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

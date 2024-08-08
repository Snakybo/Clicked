--[[-----------------------------------------------------------------------------
Icon Widget
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedHorizontalIcon"

--- @class ClickedHorizontalIcon : AceGUIWidget
--- @field private image Texture
--- @field private label FontString

local Type, Version = "ClickedHorizontalIcon", 1
local AceGUI = LibStub("AceGUI-3.0", true)

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

--- @class ClickedHorizontalIcon
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:SetHeight(16)
	self:SetWidth(110)
	self:SetLabel()
	self:SetImage(nil)
	self:SetImageSize(16, 16)
end

--- @param text? string
function Methods:SetLabel( text)
	if text and text ~= "" then
		self.label:Show()
		self.label:SetText(text)
	else
		self.label:Hide()
	end
end

--- @param path? string
--- @param ... number
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

--- @param width number
--- @param height number
function Methods:SetImageSize(width, height)
	self.image:SetWidth(width)
	self.image:SetHeight(height)
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

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetWidth(64)
	image:SetHeight(64)
	image:SetPoint("LEFT", 3, -2)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	label:SetPoint("LEFT", image, "RIGHT", 5, 0)
	label:SetJustifyH("LEFT")
	label:SetJustifyV("MIDDLE")
	label:SetHeight(18)

	local widget = {
		label = label,
		image = image,
		frame = frame,
		type = Type
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedKeyVisualizerButton"

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUILayoutType
--- | "ClickedKeys"

--- @class ClickedKeyVisualizerButton : AceGUIWidget
--- @field private key KeyButton
--- @field private visible boolean
--- @field private highlight boolean

--- @class ClickedInternal
local Addon = select(2, ...)

local Type, Version = "ClickedKeyVisualizerButton", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

AceGUI:RegisterLayout("ClickedKeys", function(content, children)
	local totalWidth = 0
	local totalHeight = 0

	local keys = {}
	local last = {
		x = 0,
		y = 0,
		w = 0,
		h = 0
	}

	for i = 1, #children do
		--- @type ClickedKeyVisualizerButton
		local child = children[i]

		local frame = child.frame
		frame:ClearAllPoints()

		local key = child:GetKey()

		if key ~= nil then
			local relativeTo = key.relativeTo  ~= nil and keys[key.relativeTo] or last

			local w = key.width or relativeTo.w
			local h = key.height or relativeTo.h
			local x = (key.x or relativeTo.x + relativeTo.w) + (key.xOffset or 0)
			local y = (key.y or relativeTo.y) + (key.yOffset or 0)

			child:SetWidth(w)
			child:SetHeight(h)
			frame:SetPoint("TOPLEFT", content, "TOPLEFT", x, -y)

			last = {
				frame = frame,
				x = x,
				y = y,
				w = w,
				h = h
			}
			keys[key:GetId()] = last

			if child:IsVisible() then
				totalWidth = math.max(totalWidth, x + w)
				totalHeight = math.max(totalHeight, y + h)

				frame:Show()
			else
				frame:Hide()
			end
		end
	end

	Addon:SafeCall(content.obj.LayoutFinished, content.obj, totalWidth, totalHeight)
end)

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function UpdateImageSize(image, width, height)
	local size = math.min(width, height) - 5
	image:SetSize(size, size)
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

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @class ClickedKeyVisualizerButton
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:SetKey()
	self:SetIcon()
	self:SetVisible(true)
	self:SetHighlight(false)
end

--- @param key? KeyButton
function Methods:SetKey(key)
	--- @diagnostic disable-next-line: assign-type-mismatch
	self.key = key
	self.keyName:SetText(key ~= nil and key:GetAbbreviation() or nil)
	self.frame:SetAlpha(key ~= nil and (key.disabled and 0.25 or 1) or 1)

end

--- @param icon string|integer|nil
function Methods:SetIcon(icon)
	self.image:SetTexture(icon)
	UpdateImageSize(self.image, self.frame:GetWidth(), self.frame:GetHeight())
end

--- @param visible boolean
function Methods:SetVisible(visible)
	self.visible = visible

	if self.visible then
		self.frame:Show()
	else
		self.frame:Hide()
	end
end

--- @param highlight boolean
function Methods:SetHighlight(highlight)
	self.highlight = highlight

	if self.highlight then
		self.frame:SetBackdropBorderColor(0, 1, 0, 1)
	else
		self.frame:SetBackdropBorderColor(1, 1, 1, 1)
	end
end

--- @return KeyButton?
function Methods:GetKey()
	return self.key
end

--- @return boolean
function Methods:IsVisible()
	return self.visible
end

--- @return boolean
function Methods:IsHighlighted()
	return self.highlight
end

--- @protected
--- @param width integer
function Methods:OnWidthSet(width)
	UpdateImageSize(self.image, width, self.frame:GetHeight())
end

--- @protected
--- @param height integer
function Methods:OnHeightSet(height)
	UpdateImageSize(self.image, self.frame:GetWidth(), height)
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local name = "ClickedKeyVisualizerButton" .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Button", name, UIParent, "TooltipBorderedFrameTemplate") --[[@as Button]]
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)

	local keyName = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal") --[[@as FontString]]
	keyName:ClearAllPoints()
	keyName:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -6)
	keyName:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -6)
	keyName:SetHeight(15)
	keyName:SetJustifyV("TOP")

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetPoint("CENTER", frame, "CENTER")

	--- @class ClickedKeyVisualizerButton
	local widget = {
		type  = Type,
		keyName  = keyName,
		image = image,
		frame = frame
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

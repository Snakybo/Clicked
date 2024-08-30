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
	local GRID_SIZE = 45
	local PADDING_SIZE = 2

	local totalWidth = 0
	local totalHeight = 0

	local keys = {}
	local last = {
		relX = 0,
		relY = 0,
		relW = 0,
		relH = 0
	}

	for i = 1, #children do
		--- @type ClickedKeyVisualizerButton
		local child = children[i]

		local frame = child.frame
		frame:ClearAllPoints()

		local key = child:GetKey()

		if key ~= nil then
			local anchor = key.relativeTo and keys[key.relativeTo] or last

			-- Get the relative position from the configuration
			local relX = key.x or anchor.relX + anchor.relW + (key.xOffset or 0)
			local relY = key.y or anchor.relY + (key.yOffset or 0)
			local relW = key.width or 1
			local relH = key.height or 1

			-- Apply standard padding
			local padX = relX * PADDING_SIZE
			local padY = relY * PADDING_SIZE
			local padW = (relW - 1) * PADDING_SIZE
			local padH = (relH - 1) * PADDING_SIZE

			-- Convert relative position to absolute position
			local x = Round(relX * GRID_SIZE + padX)
			local y = Round(relY * GRID_SIZE + padY)
			local w = Round(relW * GRID_SIZE + padW)
			local h = Round(relH * GRID_SIZE + padH)

			last = {
				frame = frame,
				relX = relX,
				relY = relY,
				relW = relW,
				relH = relH
			}
			keys[key:GetId()] = last

			child:SetWidth(w)
			child:SetHeight(h)
			frame:SetPoint("TOPLEFT", content, "TOPLEFT", x, -y)

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
	self:SetActionCount(0)
end

--- @param key? KeyButton
function Methods:SetKey(key)
	self.key = key --- @diagnostic disable-line: inject-field
	self.keyName:SetText(key ~= nil and key:GetAbbreviation() or nil)
	self.frame:SetAlpha(key ~= nil and (key.disabled and 0.5 or 1) or 1)
end

function Methods:SetActionCount(count)
	if count > 1 then
		self.extraActionCount:SetText("+" .. (count - 1))
		self.extraActionCount:Show()
	else
		self.extraActionCount:Hide()
	end
end

--- @param icon string|integer|nil
function Methods:SetIcon(icon)
	self.image:SetTexture(icon)
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
		self.background:SetVertexColor(0, 1, 0, 1)
	else
		self.background:SetVertexColor(1, 1, 1, 1)
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

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local name = "ClickedKeyVisualizerButton" .. AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", name, UIParent) --[[@as Frame]]
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)

	local background = frame:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints()

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		background:SetTexture("Interface/HUD/UIActionBar");
		background:SetTexCoord(0.707031, 0.886719, 0.248047, 0.291992)
		background:SetTextureSliceMargins(8, 8, 8, 8)
		background:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
	else
		background:SetTexture("Interface/Buttons/ui-quickslot2")
		background:SetTextureSliceMargins(20, 20, 20, 20)
		background:SetTexCoord(0.2, 0.8, 0.2, 0.8)
		background:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
	end

	local image = frame:CreateTexture(nil, "ARTWORK")
	image:SetPoint("CENTER")
	image:SetSize(46, 45)

	local backgroundMask

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		backgroundMask = frame:CreateMaskTexture(nil, "BACKGROUND")
		backgroundMask:SetPoint("CENTER", 0, -0.5)
		backgroundMask:SetTexture("Interface/HUD/UIActionBarIconFrameMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
		backgroundMask:SetTexCoord(0, 1, 0, 1)
		backgroundMask:SetSize(60, 61)
		image:AddMaskTexture(backgroundMask)
	end

	local keyName = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray") --[[@as FontString]]
	keyName:ClearAllPoints()
	keyName:SetPoint("TOP", 0, -5)
	keyName:SetHeight(10)

	local extraActionCount = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray") --[[@as FontString]]
	extraActionCount:ClearAllPoints()
	extraActionCount:SetPoint("BOTTOMRIGHT", -3, 4)
	extraActionCount:SetHeight(10)
	extraActionCount:SetJustifyH("RIGHT")

	--- @class ClickedKeyVisualizerButton
	local widget = {
		type  = Type,
		background = background,
		backgroundMask = backgroundMask,
		keyName  = keyName,
		extraActionCount = extraActionCount,
		image = image,
		frame = frame
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

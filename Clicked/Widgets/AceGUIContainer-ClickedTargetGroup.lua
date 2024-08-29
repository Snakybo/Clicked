--[[-----------------------------------------------------------------------------
Reorderable inline group widget
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedTargetGroup"

local Type, Version = "ClickedTargetGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

--- @param parent Frame
--- @param texture string
--- @param callback fun(frame: Frame)
--- @return Button
local function CreateButton(parent, texture, callback)
	texture = [[Interface\AddOns\Clicked\Media\Textures\]] .. texture .. ".tga"

	local frame = CreateFrame("Button", nil, parent)
	frame:SetScript("OnClick", callback)
	frame:SetSize(16, 16)

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetSize(16, 16)
	image:SetPoint("CENTER")
	image:SetTexture(texture)

	return frame
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function MoveDown_OnClick(frame)
	frame.obj:Fire("OnMoveDown")
	AceGUI:ClearFocus()
end

local function MoveUp_OnClick(frame)
	frame.obj:Fire("OnMoveUp")
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedTargetGroup
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:SetWidth(300)
	self:SetHeight(100)
	self:SetMoveUpButton(false)
	self:SetMoveDownButton(false)
end

--- @param enabled boolean
function Methods:SetMoveUpButton(enabled)
	if enabled then
		self.moveUp:Show()
	else
		self.moveUp:Hide()
	end
end

--- @param enabled boolean
function Methods:SetMoveDownButton(enabled)
	if enabled then
		self.moveDown:Show()
	else
		self.moveDown:Hide()
	end
end

--- @protected
--- @param height number
function Methods:LayoutFinished(_, height)
	self:SetHeight(height or 0)
end

--- @protected
--- @param width number
function Methods:OnWidthSet(width)
	local content = self.content
	content:SetWidth(width)
	content.width = width
end

--- @protected
--- @param height number
function Methods:OnHeightSet(height)
	local content = self.content
	content:SetHeight(height)
	content.height = height
end

--[[ Constructor ]]--

local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")

	local moveUp = CreateButton(frame, "ui_arrow_up", MoveUp_OnClick)
	moveUp:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, 0)

	local moveDown = CreateButton(frame, "ui_arrow_down", MoveDown_OnClick)
	moveDown:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)

	-- Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 0, 0)
	content:SetPoint("BOTTOMRIGHT")

	--- @class ClickedTargetGroup : AceGUIContainer
	local widget = {
		frame = frame,
		content = content,
		moveUp = moveUp,
		moveDown = moveDown,
		type = Type
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	--- @diagnostic disable-next-line: inject-field
	moveDown.obj, moveUp.obj = widget, widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

--[[-----------------------------------------------------------------------------
Reorderable inline group widget
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedReorderableInlineGroup"

--- @class ClickedReorderableInlineGroup : AceGUIInlineGroup
--- @field private moveDown Button
--- @field private moveUp Button

local Type, Version = "ClickedReorderableInlineGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

--- @param widget any
--- @param texture string
--- @param callback function
--- @return Button
local function CreateButton(widget, texture, callback)
	texture = [[Interface\AddOns\Clicked\Media\Textures\]] .. texture .. ".tga"

	local frame = CreateFrame("Button", nil, widget.frame)
	frame.obj = widget
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

local function UpdateButtonOffsets(frame)
	local self = frame.obj

	frame:SetScript("OnUpdate", nil)

	self.moveUp:ClearAllPoints()

	if self.moveDown:IsShown() then
		self.moveUp:SetPoint("RIGHT", self.moveDown, "LEFT", -2, 0)
	else
		self.moveUp:SetPoint("TOPRIGHT", self.frame, "TOPRIGHT", -6, 0)
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedReorderableInlineGroup
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:BaseOnAcquire()

	self:SetMoveUpButton(false)
	self:SetMoveDownButton(false)
end

--- @param self ClickedReorderableInlineGroup
--- @param enabled boolean
function Methods:SetMoveUpButton(enabled)
	if enabled then
		self.moveUp:Show()
	else
		self.moveUp:Hide()
	end

	self.frame:SetScript("OnUpdate", UpdateButtonOffsets)
end

--- @param self ClickedReorderableInlineGroup
--- @param enabled boolean
function Methods:SetMoveDownButton(enabled)
	if enabled then
		self.moveDown:Show()
	else
		self.moveDown:Hide()
	end

	self.frame:SetScript("OnUpdate", UpdateButtonOffsets)
end

--[[ Constructor ]]--

local function Constructor()
	--- @class ClickedReorderableInlineGroup
	local widget = AceGUI:Create("InlineGroup")
	widget.type = Type

	widget.moveDown = CreateButton(widget, "ui_arrow_down", MoveDown_OnClick)
	widget.moveDown:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT", -6, 0)
	widget.moveUp = CreateButton(widget, "ui_arrow_up", MoveUp_OnClick)
	widget.moveUp:SetPoint("RIGHT", widget.moveDown, "LEFT", -2, 0)

	--- @private
	widget.BaseOnAcquire = widget.OnAcquire

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

--[[-----------------------------------------------------------------------------
Reorderable inline group widget
-------------------------------------------------------------------------------]]

local Type, Version = "ClickedReorderableInlineGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
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
local function OnAcquire(self)
	self:BaseOnAcquire()

	self:SetMoveUpButton(false)
	self:SetMoveDownButton(false)
end

local function SetMoveUpButton(self, enabled)
	if enabled then
		self.moveUp:Show()
	else
		self.moveUp:Hide()
	end

	self.frame:SetScript("OnUpdate", UpdateButtonOffsets)
end

local function SetMoveDownButton(self, enabled)
	if enabled then
		self.moveDown:Show()
	else
		self.moveDown:Hide()
	end

	self.frame:SetScript("OnUpdate", UpdateButtonOffsets)
end

--[[ Constructor ]]--

local function Constructor()
	local widget = AceGUI:Create("InlineGroup")
	widget.type = Type

	local frame = widget.frame

	widget.moveDown = CreateButton(widget, "ui_arrow_down", MoveDown_OnClick)
	widget.moveDown:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, 0)

	widget.moveUp = CreateButton(widget, "ui_arrow_up", MoveUp_OnClick)
	widget.moveUp:SetPoint("RIGHT", widget.moveDown, "LEFT", -2, 0)

	widget.SetMoveUpButton = SetMoveUpButton
	widget.SetMoveDownButton = SetMoveDownButton

	widget.BaseOnAcquire = widget.OnAcquire
	widget.OnAcquire = OnAcquire

	return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

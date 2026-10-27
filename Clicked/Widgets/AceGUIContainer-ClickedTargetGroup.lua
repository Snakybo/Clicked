-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

--[[-----------------------------------------------------------------------------
A reorderable container for managing target groups
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedTargetGroup", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

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

--- @alias AceGUIWidgetType
--- | "ClickedTargetGroup"

--- @class ClickedTargetGroup : AceGUIContainer
--- @field public frame Frame&{obj: self}
--- @field public content Frame&{obj: self}
--- @field protected moveUp Button&{obj: self}
--- @field protected moveDown Button&{obj: self}
local ClickedTargetGroup = {}

--- @protected
function ClickedTargetGroup:OnAcquire()
	self:SetWidth(300)
	self:SetHeight(100)
	self:SetMoveUpButton(false)
	self:SetMoveDownButton(false)
end

--- @param enabled boolean
function ClickedTargetGroup:SetMoveUpButton(enabled)
	if enabled then
		self.moveUp:Show()
	else
		self.moveUp:Hide()
	end
end

--- @param enabled boolean
function ClickedTargetGroup:SetMoveDownButton(enabled)
	if enabled then
		self.moveDown:Show()
	else
		self.moveDown:Hide()
	end
end

--- @protected
--- @param width number?
--- @param height number?
function ClickedTargetGroup:LayoutFinished(width, height)
	self:SetHeight(height or 0)
end

--- @protected
--- @param width number
function ClickedTargetGroup:OnWidthSet(width)
	local content = self.content
	content:SetWidth(width)
	content.width = width
end

--- @protected
--- @param height number
function ClickedTargetGroup:OnHeightSet(height)
	local content = self.content
	content:SetHeight(height)
	content.height = height
end

--- @protected
--- @param frame Frame&{obj: ClickedTargetGroup}
function ClickedTargetGroup.MoveDown_OnClick(frame)
	frame.obj:Fire("OnMoveDown")
	AceGUI:ClearFocus()
end

--- @protected
--- @param frame Frame&{obj: ClickedTargetGroup}
function ClickedTargetGroup.MoveUp_OnClick(frame)
	frame.obj:Fire("OnMoveUp")
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")

	local moveUp = CreateButton(frame, "ui_arrow_up", ClickedTargetGroup.MoveUp_OnClick)
	moveUp:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -16, 0)

	local moveDown = CreateButton(frame, "ui_arrow_down", ClickedTargetGroup.MoveDown_OnClick)
	moveDown:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)

	-- Container Support
	local content = CreateFrame("Frame", nil, frame)
	content:SetPoint("TOPLEFT", 0, 0)
	content:SetPoint("BOTTOMRIGHT")

	--- @class ClickedTargetGroup
	local widget = {
		frame = frame,
		content = content,
		moveUp = moveUp,
		moveDown = moveDown,
		type = TYPE
	}

	for method, func in pairs(ClickedTargetGroup) do
		widget[method] = func
	end

	moveDown.obj = widget
	moveUp.obj = widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

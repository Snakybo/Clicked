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
A small extension of the default AceGUI TreeGroup widget which tracks the content
width and height.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedKeyVisualizerTreeGroup", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedKeyVisualizerTreeGroup"

--- @class ClickedKeyVisualizerTreeGroup.Status : AceGUITreeGroupStatus
--- @field contentWidth? integer
--- @field contentHeight? integer

--- @class ClickedKeyVisualizerTreeGroup : AceGUITreeGroup
--- @field public localstatus ClickedKeyVisualizerTreeGroup.Status
--- @field protected status? ClickedKeyVisualizerTreeGroup.Status
local ClickedKeyVisualizerTreeGroup = {}

--- @return integer
function ClickedKeyVisualizerTreeGroup:GetContentWidth()
	local status = self.status or self.localstatus
	return status.contentWidth or 0
end

--- @return integer
function ClickedKeyVisualizerTreeGroup:GetContentHeight()
	local status = self.status or self.localstatus
	return status.contentHeight or 0
end

--- @protected
--- @param width integer?
--- @param height integer?
function ClickedKeyVisualizerTreeGroup:LayoutFinished(width, height)
	self:TreeGroupLayoutFinished(width, height)

	local status = self.status or self.localstatus
	status.contentWidth = width
	status.contentHeight = height
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	--- @class ClickedKeyVisualizerTreeGroup
	local widget = AceGUI:Create("TreeGroup")
	widget.type = TYPE

	--- @private
	widget.TreeGroupLayoutFinished = widget.LayoutFinished

	for method, func in pairs(ClickedKeyVisualizerTreeGroup) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

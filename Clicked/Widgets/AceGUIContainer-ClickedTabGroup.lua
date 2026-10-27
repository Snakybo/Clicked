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
A small extension to the AceGUI TabGroup container, which allows for automatic
re-selection of tabs once they become available again.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedTabGroup", 3
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedTabGroup"

--- @class ClickedTabGroup : AceGUITabGroup
local ClickedTabGroup = {}

--- @param tabs AceGUITabGroupTab[]
function ClickedTabGroup:SetTabs(tabs)
	self:TabGroupSetTabs(tabs)

	local status = self.status or self.localstatus

	for _, v in ipairs(self.tabs) do
		---@diagnostic disable-next-line: undefined-field
		v:SetSelected(v.value == status.selected)
	end
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedTabGroup
	local widget = AceGUI:Create("TabGroup")
	widget.type = TYPE

	--- @private
	widget.TabGroupSetTabs = widget.SetTabs

	for method, func in pairs(ClickedTabGroup) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

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
local AceGUI = LibStub("AceGUI-3.0")

if (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedTabGroup"

--- @class ClickedTabGroup : AceGUITabGroup
--- @field public content Frame&{obj: self}
--- @field public frame Frame&{obj: self}
--- @field public type string
--- @field protected tabs (AceGUITabGroupTab&{SetSelected: fun(self: Button, selected: boolean)})[]
--- @field private TabGroupSetTabs fun(self: AceGUITabGroup, tabs: AceGUITabGroupTab[])
local ClickedTabGroup = {}

--- @param tabs AceGUITabGroupTab[]
function ClickedTabGroup:SetTabs(tabs)
	self:TabGroupSetTabs(tabs)

	local status = self.status or self.localstatus

	for _, v in ipairs(self.tabs) do
		v:SetSelected(v.value == status.selected)
	end
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

--- @return ClickedTabGroup
local function Constructor()
	--- @class ClickedTabGroup
	local widget = AceGUI:Create("TabGroup")
	widget.type = TYPE
	widget.TabGroupSetTabs = widget.SetTabs

	for method, func in pairs(ClickedTabGroup) do
		widget[method] = func
	end

	--- TEMP: This cast can be removed once https://github.com/TradeSkillMaster/wowlua-ls/pull/65 is merged
	return AceGUI:RegisterAsContainer(widget) --[[@as ClickedTabGroup]]
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

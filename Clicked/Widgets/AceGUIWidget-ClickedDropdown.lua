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
A small extension to the standard AceGUI Dropdown widget that adds support
for customizing the label color.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedDropdown", 3
local AceGUI = LibStub("AceGUI-3.0")

if (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedDropdown"

--- @class ClickedDropdown<K, V> : AceGUIDropdown
--- @field public frame Frame&{obj: self}
--- @field public type string
--- @field public SetValue fun(self: self, key: K)
--- @field public SetList fun(self: self, list: table<K, V>, order: K[])
--- @field public AddItem fun(self: self, key: K, value: V)
--- @field public SetItemValue fun(self: self, key: K, value: V)
--- @field public SetItemDisabled fun(self: self, key: K, flag: boolean)
--- @field private DropDownOnAcquire fun(self: AceGUIDropdown)
local ClickedDropdown = {}

--- @protected
function ClickedDropdown:OnAcquire()
	self:DropDownOnAcquire()

	self:SetLabelColor(NORMAL_FONT_COLOR)
end

--- @param color ColorMixin
function ClickedDropdown:SetLabelColor(color)
	self.label:SetTextColor(color:GetRGBA())
end

--- @return fun(table: AceGUIDropdownItemBase[], i?: integer): number, AceGUIDropdownItemBase
--- @return AceGUIDropdownItemBase[]
--- @return number
function ClickedDropdown:IterateItems()
	--- @diagnostic disable-next-line: unknown-return-type
	return self.pullout:IterateItems()
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

--- @return ClickedDropdown
local function Constructor()
	--- @class ClickedDropdown
	local widget = AceGUI:Create("Dropdown")
	widget.type = TYPE
	widget.DropDownOnAcquire = widget.OnAcquire

	for method, func in pairs(ClickedDropdown) do
		widget[method] = func
	end

	--- TEMP: This cast can be removed once https://github.com/TradeSkillMaster/wowlua-ls/pull/65 is merged
	return AceGUI:RegisterAsWidget(widget) --[[@as ClickedDropdown]]
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

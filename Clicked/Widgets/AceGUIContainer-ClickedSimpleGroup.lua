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
A copy of the default AceGUI SimpleGroup container.

Custom implementation to enfore it being invisible because the regular version
is skinned by ElvUI and AddOnSkins.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedSimpleGroup", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedSimpleGroup"

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	--- @class ClickedSimpleGroup : AceGUISimpleGroup
	local widget = AceGUI:Create("SimpleGroup")
	widget.type = TYPE

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

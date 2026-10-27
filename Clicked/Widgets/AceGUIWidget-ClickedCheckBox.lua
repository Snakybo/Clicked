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
A small extension to the standard AceGUI CheckBox widget that adds support
for customizing the label color.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedCheckBox", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedCheckBox"

--- @class ClickedCheckBox : AceGUICheckBox
local ClickedCheckBox = {}

--- @protected
function ClickedCheckBox:OnAcquire()
	self:CheckBoxOnAcquire()

	self:SetLabelColor(WHITE_FONT_COLOR)
	self:SetLabel("")
end

--- @param color ColorMixin
function ClickedCheckBox:SetLabelColor(color)
	self.text:SetTextColor(color:GetRGBA())
end

local function Constructor()
	--- @class ClickedCheckBox
	local widget = AceGUI:Create("CheckBox")
	widget.type = TYPE

	--- @private
	widget.CheckBoxOnAcquire = widget.OnAcquire

	for method, func in pairs(ClickedCheckBox) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

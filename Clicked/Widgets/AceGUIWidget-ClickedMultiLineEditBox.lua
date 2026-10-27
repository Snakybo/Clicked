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
A multi-line editbox widget, similar to the standard AceGUI multi-line editbox
but with an additional label color.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedMultiLineEditBox", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedMultiLineEditBox"

--- @class ClickedMultiLineEditBox : AceGUIMultiLineEditBox
--- @field public frame Frame&{obj: self}
--- @field protected editBox EditBox&{obj: self}
--- @field protected button Button&UIPanelButtonTemplate&{obj: self}
--- @field protected label FontString&{obj: self}
--- @field protected scrollFrame ScrollFrame&UIPanelScrollFrameTemplate&{obj: self}
--- @field protected scrollBar UIPanelScrollFrameTemplate_ScrollBar&{obj: self}
--- @field protected scrollBG Frame&BackdropTemplate&{obj: self}
--- @field protected entered boolean?
local Methods = {}

function Methods:OnAcquire()
	self:MultiLineEditBoxOnAcquire()

	self:SetLabelColor(NORMAL_FONT_COLOR)
end

--- @param color ColorMixin
function Methods:SetLabelColor(color)
	self.label:SetTextColor(color:GetRGBA())
end

local function Constructor()
	--- @class ClickedMultiLineEditBox
	local widget = AceGUI:Create("MultiLineEditBox")
	widget.type = TYPE

	--- @private
	widget.MultiLineEditBoxOnAcquire = widget.OnAcquire

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	widget.label.obj = widget
	widget.scrollBar.obj = widget
	widget.scrollBG.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

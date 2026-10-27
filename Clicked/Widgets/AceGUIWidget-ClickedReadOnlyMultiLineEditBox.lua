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
A simple multi-line editbox that is read-only.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedReadOnlyMultilineEditBox", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedReadOnlyMultilineEditBox"

--- @class ClickedReadOnlyMultilineEditBox : ClickedMultiLineEditBox
--- @field protected text string
local ClickedReadOnlyMultilineEditBox = {}

--- @protected
function ClickedReadOnlyMultilineEditBox:OnAcquire()
	self.editBox:SetText("")
	self:SetDisabled(false)
	self:SetWidth(200)
	self.button:Hide()
	self:SetNumLines(0)
	self.entered = nil
	self:SetMaxLetters(0)
end

--- @param text string
function ClickedReadOnlyMultilineEditBox:SetText(text)
	self.editBox:SetText(text)
	self.text = text
end

--- @param from? number
--- @param to? number
function ClickedReadOnlyMultilineEditBox:HighlightText(from, to)
	self.editBox:HighlightText(from, to)
end

--- @protected
--- @param frame EditBox&{obj: ClickedReadOnlyMultilineEditBox}
function ClickedReadOnlyMultilineEditBox.EditBox_OnChar(frame)
	local self = frame.obj
	self.editBox:SetText(self.text)
end

--- @protected
--- @param frame EditBox&{obj: ClickedReadOnlyMultilineEditBox}
function ClickedReadOnlyMultilineEditBox.EditBox_OnTextChanged(frame)
	local self = frame.obj
	self.editBox:SetText(self.text)
end

local function Constructor()
	--- @class ClickedReadOnlyMultilineEditBox
	local widget = AceGUI:Create("ClickedMultiLineEditBox")
	widget.type = TYPE

	local editBox = widget.editBox
	editBox:SetScript("OnChar", ClickedReadOnlyMultilineEditBox.EditBox_OnChar)
	editBox:SetScript("OnTextChanged", ClickedReadOnlyMultilineEditBox.EditBox_OnTextChanged)

	for method, func in pairs(ClickedReadOnlyMultilineEditBox) do
		widget[method] = func
	end

	widget.DisableButton = nil

	return widget
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

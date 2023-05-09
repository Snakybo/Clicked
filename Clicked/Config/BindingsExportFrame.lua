-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
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

local AceGUI = LibStub("AceGUI-3.0")

--- @class ClickedInternal
local _, Addon = ...

local frame

--- @param target Binding|Group
--- @param type "group"|"binding"
function Addon:BindingExportFrame_Open(target, type)
	if frame ~= nil and frame:IsVisible() then
		return
	end

	local serialized

	if type == "group" then
		--- @cast target Group
		serialized = Clicked:SerializeGroup(target)
	elseif type == "binding" then
		--- @cast target Binding
		serialized = Clicked:SerializeBinding(target)
	else
		error("bad argument #2, expected group or binding but got " .. type)
	end

	frame = AceGUI:Create("ClickedTopLevelFrame") --[[@as AceGUIFrame]]

	if type == "group" then
		frame:SetTitle(Addon.L["Export Group"])
		frame:SetStatusText(string.format(Addon.L["Exporting '%s'"], target.name))
	elseif type == "binding" then
		frame:SetTitle(Addon.L["Export Binding"])
		frame:SetStatusText(string.format(Addon.L["Exporting '%s'"], Addon:GetBindingNameAndIcon(target)))
	end

	frame:EnableResize(false)
	frame:SetWidth(600)
	frame:SetHeight(400)
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
	end)

	local textField = AceGUI:Create("MultiLineEditBox") --[[@as AceGUIMultiLineEditBox]]
	textField:SetFullHeight(true)
	textField:SetFullWidth(true)
	textField:SetNumLines(18)
	textField:SetLabel(Addon.L["Copy and share this text"])
	textField:DisableButton(true)
	textField:SetText(serialized)
	textField:SetCallback("OnTextChanged", function()
		textField:SetText(serialized)
		textField:SetFocus()
		textField:HighlightText()
	end)
	textField:SetFocus()
	textField:HighlightText()

	frame:AddChild(textField)
end

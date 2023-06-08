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
local Addon = select(2, ...)

local frame

--- @param data string
--- @param title string
--- @param statusText string
--- @return AceGUIFrame?
local function OpenFrame(data, title, statusText)
	if frame ~= nil and frame:IsVisible() then
		return nil
	end

	frame = AceGUI:Create("ClickedFrame") --[[@as ClickedFrame]]
	frame:MoveToFront()
	frame:SetTitle(title)
	frame:SetStatusText(statusText)
	frame:EnableResize(false)
	frame:SetWidth(600)
	frame:SetHeight(400)
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		frame = nil
	end)

	local textField = AceGUI:Create("MultiLineEditBox") --[[@as AceGUIMultiLineEditBox]]
	textField:SetFullHeight(true)
	textField:SetFullWidth(true)
	textField:SetNumLines(18)
	textField:SetLabel(Addon.L["Copy and share this text"])
	textField:DisableButton(true)
	textField:SetText(data)
	textField:SetCallback("OnTextChanged", function()
		textField:SetText(data)
		textField:SetFocus()
		textField:HighlightText()
	end)
	textField:SetFocus()
	textField:HighlightText()

	frame:AddChild(textField)

	return frame
end

-- Private addon API

--- @class ExportFrame
local ExportFrame = {}

--- @param target Group
function ExportFrame:ExportGroup(target)
	local serialized = Clicked:SerializeGroup(target)
	OpenFrame(serialized, Addon.L["Export Group"], string.format(Addon.L["Exporting '%s'"], target.name))
end

--- @param target Binding
function ExportFrame:ExportBinding(target)
	local serialized = Clicked:SerializeBinding(target)
	OpenFrame(serialized, Addon.L["Export Binding"], string.format(Addon.L["Exporting '%s'"], Addon:GetBindingNameAndIcon(target)))
end

--- @param target Profile
function ExportFrame:ExportProfile(target)
	local serialized = Clicked:SerializeProfile(target, true, false)
	OpenFrame(serialized, Addon.L["Export Profile"], string.format(Addon.L["Exporting '%s'"], Addon.db:GetCurrentProfile()))
end

Addon.ExportFrame = ExportFrame

-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
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

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @enum BindingConfigExportStringPageMode
Addon.BindingConfig.ExportStringModes = {
	BINDING_GROUP = 0,
	PROFILE = 1
}

--- @class BindingConfigExportStringPage : BindingConfigPage
--- @field private mode BindingConfigExportStringPageMode
--- @field private target DataObject|Profile
--- @field private serialized string
Addon.BindingConfig.ExportStringPage = {}

--- @protected
--- @param mode BindingConfigExportStringPageMode
--- @param target DataObject|Profile
function Addon.BindingConfig.ExportStringPage:Show(mode, target)
	assert(mode ~= nil)
	assert(target ~= nil)

	self.mode = mode
	self.target = target

	if mode == Addon.BindingConfig.ExportStringModes.BINDING_GROUP then
		--- @cast target DataObject
		self.serialized = Clicked:SerializeDataObject(target)
	elseif mode == Addon.BindingConfig.ExportStringModes.PROFILE then
		--- @cast target Profile
		self.serialized = Clicked:SerializeProfile(target, true, false)
	end
end

--- @protected
function Addon.BindingConfig.ExportStringPage:Hide()
	self.mode = nil
	self.target = nil
end

--- @protected
function Addon.BindingConfig.ExportStringPage:Redraw()
	local target = self.target

	do
		local widget = AceGUI:Create("MultiLineEditBox") --[[@as AceGUIMultiLineEditBox]]
		widget:SetFullHeight(true)
		widget:SetFullWidth(true)
		widget:SetNumLines(18)

		if self.mode == Addon.BindingConfig.ExportStringModes.BINDING_GROUP then
			--- @cast target DataObject

			if target.type == Clicked.DataObjectType.BINDING then
				--- @cast target Binding
				widget:SetLabel(string.format(Addon.L["Exporting binding '%s'"], Addon:GetBindingNameAndIcon(target)))
			elseif target.type == Clicked.DataObjectType.GROUP then
				--- @cast target Group
				widget:SetLabel(string.format(Addon.L["Exporting group '%s'"], target.name))
			end
		elseif self.mode == Addon.BindingConfig.ExportStringModes.PROFILE then
			--- @cast target Profile
			widget:SetLabel(string.format(Addon.L["Exporting profile '%s'"], Addon.db:GetCurrentProfile()))
		end

		widget:DisableButton(true)
		widget:SetText(self.serialized)
		widget:SetCallback("OnTextChanged", function()
			widget:SetText(self.serialized)
			widget:SetFocus()
			widget:HighlightText()
		end)
		widget:SetFocus()
		widget:HighlightText()

		self.container:AddChild(widget)
	end
end

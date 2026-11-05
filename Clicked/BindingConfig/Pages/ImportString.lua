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

local AceGUI = LibStub("AceGUI-3.0")

--- @class Addon
local Addon = select(2, ...)

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigImportStringPage : BindingConfigPage
--- @field private importText? string
--- @field private reviewData? DataExport
local ImportStringPage = {}

Addon.BindingConfig.ImportStringPage = ImportStringPage

--- @protected
--- @param data DataExport
--- @param sender? string
function ImportStringPage:Show(data, sender)
	if sender ~= nil then
		self.importText = string.format(Addon.L["Imported Clicked profile from %s"], sender)
	end

	self.reviewData = data
end

--- @protected
function ImportStringPage:Hide()
	self.importText = nil
	self.reviewData = nil
end

--- @protected
function ImportStringPage:Redraw()
	do
		--- @param widget AceGUIEditBox
		--- @param event string
		--- @param text string
		local function OnTextChanged(widget, event, text)
			if text == self.importText then
				return
			end

			local success, data = Clicked:Deserialize(text)

			if not success then
				local requireRedraw = self.reviewData ~= nil

				self.importText = data
				self.reviewData = nil

				if requireRedraw then
					self.controller:RedrawPage()
				else
					widget:SetText(data)
					widget:HighlightText()
					widget:SetFocus()
				end
			else
				self.reviewData = data

				if #data.groups == 1 then
					self.importText = string.format(Addon.L["Importing group '%s' with %s bindings"], data.groups[1].name, tostring(#data.bindings))
				elseif #data.groups > 1 then
					self.importText = string.format(Addon.L["Importing %d groups with a total of %d bindings"], #data.groups, #data.bindings)
				elseif #data.bindings == 1 then
					self.importText = string.format(Addon.L["Importing binding '%s'"], Addon:GetBindingNameAndIcon(data.bindings[1]))
				elseif #data.bindings > 1 then
					self.importText = string.format(Addon.L["Importing %d bindings"], #data.bindings)
				end

				self.controller:RedrawPage()
			end
		end

		local widget = AceGUI:Create("EditBox")
		widget:SetFullWidth(true)
		widget:SetLabel(Addon.L["Paste import string here"])
		widget:DisableButton(true)
		widget:SetText(self.importText or "")

		if self.importText == nil then
			widget:SetFocus()
		elseif  self.importText ~= nil and self.reviewData == nil then
			widget:HighlightText()
			widget:SetFocus()
		end

		widget:SetCallback("OnTextChanged", OnTextChanged)

		self.container:AddChild(widget)
	end

	self:RedrawToReview()
end

--- @private
function ImportStringPage:RedrawToReview()
	local data = self.reviewData
	if data == nil then
		return
	end

	--- @type ClickedBindingImportList
	local tree

	--- @type ImportFlags
	local importFlags = bit.bor(Clicked.ImportFlags.KEYBINDS, Clicked.ImportFlags.BINDINGS)

	--- @type AceGUIButton
	local importButton

	do
		importButton = AceGUI:Create("Button")
		importButton:SetText(Addon.L["Import"])
		importButton:SetRelativeWidth(0.3)
		importButton:SetCallback("OnClick", function()
			local review = self.reviewData
			if review == nil then
				return
			end

			local success, result = Clicked:Import(review, importFlags)
			if not success then
				Clicked:LogWarning(result)
			else
				if #review.groups > 0 then
					Addon.BindingConfig.Window:Select(result[review.groups[1].uid])
					Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_GROUP)
				elseif #review.bindings > 0 then
					Addon.BindingConfig.Window:Select(result[review.bindings[1].uid])
					Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_BINDING)
				else
					Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_NEW)
				end
			end
		end)

		self.container:AddChild(importButton)
	end

	do
		--- @param widget ClickedDropdown
		--- @param event string
		--- @param key integer
		--- @param checked boolean
		local function OnValueChanged(widget, event, key, checked)
			if checked then
				importFlags = bit.bor(importFlags, key)
			else
				importFlags = bit.band(importFlags, bit.bnot(key))
			end

			if key == Clicked.ImportFlags.KEYBINDS then
				tree:ShowKeybinds(checked)
			elseif key == Clicked.ImportFlags.BINDINGS then
				if not checked then
					tree.frame:Hide()

					importFlags = bit.band(importFlags, bit.bnot(Clicked.ImportFlags.KEYBINDS))
					importFlags = bit.band(importFlags, bit.bnot(Clicked.ImportFlags.OVERWRITE))

					widget:SetItemValue(Clicked.ImportFlags.KEYBINDS, false)
					widget:SetItemValue(Clicked.ImportFlags.OVERWRITE, false)

					widget:SetItemDisabled(Clicked.ImportFlags.KEYBINDS, true)
					widget:SetItemDisabled(Clicked.ImportFlags.OVERWRITE, true)
				else
					tree.frame:Show()

					widget:SetItemDisabled(Clicked.ImportFlags.KEYBINDS, false)
					widget:SetItemDisabled(Clicked.ImportFlags.OVERWRITE, false)
				end
			end

			importButton:SetDisabled(importFlags == 0)
		end

		--- @return table<integer, string>, integer[]
		local function CreateOptions()
			local options = {
				[Clicked.ImportFlags.BINDINGS] = Addon.L["Import bindings"],
				[Clicked.ImportFlags.KEYBINDS] = Addon.L["Import keybinds"],
			}

			local order = {
				Clicked.ImportFlags.BINDINGS,
				Clicked.ImportFlags.KEYBINDS,
			}

			if data.options ~= nil then
				options[Clicked.ImportFlags.ADDON_OPTIONS] = Addon.L["Import addon options"]
				table.insert(order, Clicked.ImportFlags.ADDON_OPTIONS)
			end

			if data.isProfile then
				options[Clicked.ImportFlags.OVERWRITE] = Addon.L["Overwrite current profile (dangerous)"]
				table.insert(order, Clicked.ImportFlags.OVERWRITE)
			end

			return options, order
		end

		local widget = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown]]
		widget:SetList(CreateOptions())
		widget:SetMultiselect(true)
		widget:SetRelativeWidth(0.7)
		widget:SetCallback("OnValueChanged", OnValueChanged)

		for _, item in widget.pullout:IterateItems() do
			local id = item.userdata.value

			if id ~= nil then
				widget:SetItemValue(id, bit.band(importFlags, id) ~= 0)
			end
		end

		self.container:AddChild(widget)
	end

	do
		tree = AceGUI:Create("ClickedBindingImportList") --[[@as ClickedBindingImportList]]
		tree:SetFullWidth(true)
		tree:SetFullHeight(true)
		tree:SetItems(data)

		self.container:AddChild(tree)
	end
end

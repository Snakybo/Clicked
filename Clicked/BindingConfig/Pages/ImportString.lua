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

--- @param mode BindingConfigImportStringPageMode
--- @param text string
--- @return boolean
--- @return ExportProfile|ShareData|string
local function OnTextChanged(mode, text)
	if mode == Addon.BindingConfig.ImportStringModes.BINDING_GROUP then
		local success, data = Clicked:Deserialize(text, true)

		if not success then
			return false, data --[[@as string]]
		end

		if data.type ~= "binding" and data.type ~= "group" then
			return false, Addon.L["Invalid import string: Expected a binding or group"]
		end

		return true, data --[[@as ShareData]]
	elseif mode == Addon.BindingConfig.ImportStringModes.PROFILE then
		local success, data = Clicked:Deserialize(text, true)

		if not success then
			return false, data --[[@as string]]
		end

		if data.type ~= "profile" then
			return false, Addon.L["Invalid import string: Expected a profile"]
		end

		return true, data --[[@as ExportProfile]]
	end

	return false, "Invalid mode: " .. mode
end

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @enum BindingConfigImportStringPageMode
Addon.BindingConfig.ImportStringModes = {
	BINDING_GROUP = 0,
	PROFILE = 1,
	PROFILE_COMM = 2
}

--- @class BindingConfigImportStringPage : BindingConfigPage
--- @field private mode BindingConfigImportStringPageMode
--- @field private importText? string
--- @field private reviewData? ExportProfile|ShareData
--- @field private importKeybinds boolean
Addon.BindingConfig.ImportStringPage = {}

--- @protected
--- @param mode BindingConfigImportStringPageMode
--- @param ... any
function Addon.BindingConfig.ImportStringPage:Show(mode, ...)
	assert(mode ~= nil)
	self.mode = mode

	if mode == Addon.BindingConfig.ImportStringModes.PROFILE_COMM then
		self.importText = string.format(Addon.L["Imported Clicked profile from %s"], select(2, ...))
		self.reviewData = select(1, ...)
	end

	self.importKeybinds = true
end

--- @protected
function Addon.BindingConfig.ImportStringPage:Hide()
	self.mode = nil
	self.importText = nil
	self.reviewData = nil
end

--- @protected
function Addon.BindingConfig.ImportStringPage:Redraw()
	do
		local widget = AceGUI:Create("EditBox") --[[@as AceGUIEditBox]]
		widget:SetFullWidth(true)
		widget:SetLabel(Addon.L["Paste import string here"])
		widget:DisableButton(true)
		widget:SetText(self.importText or "")
		widget:SetDisabled(self.mode == Addon.BindingConfig.ImportStringModes.PROFILE_COMM)

		if self.importText == nil then
			widget:SetFocus()
		elseif  self.importText ~= nil and self.reviewData == nil then
			widget:HighlightText()
			widget:SetFocus()
		end

		widget:SetCallback("OnTextChanged", function(_, _, text)
			if text == self.importText then
				return
			end

			local success, data = OnTextChanged(self.mode, text)

			if not success then
				--- @cast data string

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
				--- @cast data -string

				self.reviewData = data

				if self.mode == Addon.BindingConfig.ImportStringModes.BINDING_GROUP then
					--- @cast data ShareData

					if data.type == "group" then
						self.importText = string.format(Addon.L["Importing group '%s' with %d bindings"], data.group.name, #data.group.bindings)
					elseif data.type == "binding" then
						self.importText = string.format(Addon.L["Importing binding '%s'"], Addon:GetBindingNameAndIcon(data.binding))
					end
				elseif self.mode == Addon.BindingConfig.ImportStringModes.PROFILE then
					--- @cast data ExportProfile

					self.importText = string.format(Addon.L["Importing %d groups with a total of %d bindings"], #data.groups, #data.bindings)
				end

				self.controller:RedrawPage()
			end
		end)

		self.container:AddChild(widget)
	end

	self:RedrawToReview()
end

--- @private
function Addon.BindingConfig.ImportStringPage:RedrawToReview()
	local data = self.reviewData

	if data == nil then
		return
	end

	--- @type ClickedBindingImportList
	local tree

	if data.type == "profile" then
		--- @cast data ExportProfile

		if not data.lightweight then
			local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
			widget:SetText("|cffe31919This is a full profile export, importing this will overwrite your user settings|r")
			widget:SetFullWidth(true)
			widget:SetFontObject(GameFontHighlightSmall)

			self.container:AddChild(widget)
		end
	end

	do
		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Import"])
		widget:SetAutoWidth(true)
		widget:SetCallback("OnClick", function()
			local review = self.reviewData
			if review == nil then
				return
			end

			if not self.importKeybinds then
				if review.type == "group" then
					--- @cast data ShareData

					for _, binding in ipairs(review.group.bindings) do
						binding.keybind = ""
					end
				elseif review.type == "binding" then
					--- @cast data ShareData

					review.binding.keybind = ""
				elseif review.type == "profile" then
					--- @cast data ExportProfile

					for _, binding in ipairs(review.bindings) do
						binding.keybind = ""
					end
				else
					error("Unknown data type: " .. review.type)
				end
			end

			local type = review.type
			Clicked:Import(review)

			if type == "group" then
				Addon.BindingConfig.Window:Select(review.group.uid)
			elseif type == "binding" then
				Addon.BindingConfig.Window:Select(review.binding.uid)
			elseif type == "profile" then
				if #review.groups > 0 then
					Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_GROUP)
					Addon.BindingConfig.Window:Select(review.groups[1].uid)
				elseif #review.bindings > 0 then
					Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_BINDING)
					Addon.BindingConfig.Window:Select(review.bindings[1].uid)
				else
					Addon.BindingConfig.Window:SetPage(Addon.BindingConfig.Window.PAGE_NEW)
				end
			end
		end)

		self.container:AddChild(widget)
	end

	do
		local widget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
		widget:SetLabel(Addon.L["Import keybinds"])
		widget:SetValue(self.importKeybinds)
		widget:SetCallback("OnValueChanged", function(_, _, value)
			self.importKeybinds = value
			tree:ShowKeybinds(value)
		end)

		self.container:AddChild(widget)
	end

	do
		--- @type ShareData[]
		local items

		if self.mode == Addon.BindingConfig.ImportStringModes.BINDING_GROUP then
			--- @cast data ShareData

			items = { data }
		elseif self.mode == Addon.BindingConfig.ImportStringModes.PROFILE or self.mode == Addon.BindingConfig.ImportStringModes.PROFILE_COMM then
			--- @cast data ExportProfile

			items = {}

			--- @type table<string,ShareData.Group>
			local groups = {}

			for _, current in ipairs(data.groups) do
				local group = CopyTable(current) --[[@as ShareData.Group]]
				group.bindings = {}

				--- @type ShareData
				local item = {
					version = data.version,
					type = "group",
					group = group
				}

				groups[current.uid] = item.group
				table.insert(items, item)
			end

			for _, current in ipairs(data.bindings) do
				local group = current.parent ~= nil and groups[current.parent] or nil

				if group ~= nil then
					table.insert(group.bindings, current)
				else
					--- @type ShareData
					local item = {
						version = data.version,
						type = "binding",
						binding = current
					}

					table.insert(items, item)
				end
			end
		end

		tree = AceGUI:Create("ClickedBindingImportList") --[[@as ClickedBindingImportList]]
		tree:SetFullWidth(true)
		tree:SetFullHeight(true)
		tree:SetItems(items)

		if not self.importKeybinds then
			tree:ShowKeybinds(false)
		end

		self.container:AddChild(tree)
	end
end

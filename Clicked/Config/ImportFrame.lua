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

local STATE_IMPORT = 1
local STATE_REVIEW = 2

local currentState

local frame
local tabGroup

local importType
local importTextCallback

-- import tab
--- @type string?
local importText

-- review tab
--- @type ShareData|ExportProfile?
local reviewData
--- @type boolean
local reviewImportKeybinds

local function GetTabs()
	return {
		{
			text = Addon.L["Import"],
			value = STATE_IMPORT
		},
		{
			text = Addon.L["Review"],
			value = STATE_REVIEW,
			disabled = currentState < STATE_REVIEW
		}
	}
end

--- @param state integer
local function SetState(state)
	if state == currentState then
		return
	end

	currentState = state

	tabGroup:SetTabs(GetTabs())

	local status = tabGroup.status or tabGroup.localstatus
	if status.selected ~= state then
		tabGroup:SelectTab(state)
	end
end

--- @param container AceGUIContainer
local function BuildImportTab(container)
	local textField = AceGUI:Create("MultiLineEditBox") --[[@as AceGUIMultiLineEditBox]]
	textField:SetFullHeight(true)
	textField:SetFullWidth(true)
	textField:SetNumLines(17)
	textField:SetLabel(Addon.L["Paste import string here"])
	textField:DisableButton(true)
	textField:SetFocus()
	textField:SetText(importText or "")
	textField:SetCallback("OnTextChanged", function(_, _, text)
		local success, data = importTextCallback(text)

		if not success then
			textField:SetText(data)
			textField:SetFocus()
			textField:HighlightText()

			importText = nil
			reviewData = nil

			SetState(STATE_IMPORT)
		else
			importText = text
			reviewData = data

			SetState(STATE_REVIEW)
		end
	end)

	container:AddChild(textField)
end

---@param container AceGUIContainer
local function BuildReviewTab(container)
	if reviewData == nil then
		error("Cannot open review tab without data")
	end

	local negativeHeight = 0

	do
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]

		if importType == "binding_group" then
			--- @cast reviewData ShareData

			if reviewData.type == "group" then
				widget:SetText(string.format(Addon.L["Importing group '%s' with %d bindings"], reviewData.group.name, #reviewData.group.bindings))
			elseif reviewData.type == "binding" then
				widget:SetText(string.format(Addon.L["Importing binding '%s'"], Addon:GetBindingNameAndIcon(reviewData.binding)))
			end
		elseif importType == "profile" then
			--- @cast reviewData ExportProfile

			widget:SetText(string.format(Addon.L["Importing %d groups with a total of %d bindings"], #reviewData.groups, #reviewData.bindings))
		end

		widget:SetFullWidth(true)
		widget:SetFontObject(GameFontHighlight)

		container:AddChild(widget)
	end

	if reviewData.type == "profile" then
		--- @cast reviewData ExportProfile

		if not reviewData.lightweight then
			local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
			widget:SetText("|cffe31919This is a full profile export, importing this will overwrite your user settings|r")
			widget:SetFullWidth(true)
			widget:SetFontObject(GameFontHighlightSmall)

			container:AddChild(widget)

			negativeHeight = 23 -- pixel perfect so that the bottom of the import button stays the same amount of pixels from the edge
		end
	end

	local tree
	do
		--- @type ShareData[]
		local items

		if importType == "binding_group" then
			--- @cast reviewData ShareData

			items = { reviewData }
		elseif importType == "profile" then
			--- @cast reviewData ExportProfile

			items = {}

			--- @type table<string,ShareData.Group>
			local groups = {}

			for _, current in ipairs(reviewData.groups) do
				local group = Addon:DeepCopyTable(current) --[[@as ShareData.Group]]
				group.bindings = {}

				--- @type ShareData
				local item = {
					version = reviewData.version,
					type = "group",
					group = group
				}

				groups[current.uid] = item.group
				table.insert(items, item)
			end

			for _, current in ipairs(reviewData.bindings) do
				local group = current.parent ~= nil and groups[current.parent] or nil

				if group ~= nil then
					table.insert(group.bindings, current)
				else
					--- @type ShareData
					local item = {
						version = reviewData.version,
						type = "binding",
						binding = current
					}

					table.insert(items, item)
				end
			end
		end

		tree = AceGUI:Create("ClickedBindingImportList") --[[@as ClickedBindingImportList]]
		tree:SetFullWidth(true)
		tree:SetHeight(440 - negativeHeight)
		tree:SetItems(items)

		if not reviewImportKeybinds then
			tree:ShowKeybinds(false)
		end

		container:AddChild(tree)
	end

	do
		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Import"])
		widget:SetAutoWidth(true)
		widget:SetCallback("OnClick", function()
			if not reviewImportKeybinds then
				if reviewData.type == "group" then
					--- @cast reviewData ShareData

					for _, binding in ipairs(reviewData.group.bindings) do
						binding.keybind = ""
					end
				elseif reviewData.type == "binding" then
					--- @cast reviewData ShareData

					reviewData.binding.keybind = ""
				elseif reviewData.type == "profile" then
					--- @cast reviewData ExportProfile

					for _, binding in ipairs(reviewData.bindings) do
						binding.keybind = ""
					end
				else
					error("Unknwon data type: " .. reviewData.type)
				end
			end

			Clicked:Import(reviewData)
			frame:Hide()
		end)

		container:AddChild(widget)
	end

	do
		local widget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
		widget:SetLabel(Addon.L["Import keybinds"])
		widget:SetValue(reviewImportKeybinds)
		widget:SetCallback("OnValueChanged", function(_, _, value)
			reviewImportKeybinds = value
			tree:ShowKeybinds(value)
		end)

		container:AddChild(widget)
	end
end

local function OnTabSelected(container, _, tab)
	container:ReleaseChildren()

	if tab == STATE_IMPORT then
		BuildImportTab(container)
	elseif tab == STATE_REVIEW then
		BuildReviewTab(container)
	end

	container:DoLayout()
end

--- @param title string
--- @param statusText string
--- @param type "binding_group"|"profile"
--- @param onTextCallback fun(text: string): boolean, any
--- @return AceGUIFrame?
local function OpenFrame(title, statusText, type, onTextCallback)
	if frame ~= nil and frame:IsVisible() then
		return
	end

	currentState = nil
	importText = nil
	reviewData = nil
	reviewImportKeybinds = true

	importType = type
	importTextCallback = onTextCallback

	frame = AceGUI:Create("ClickedFrame") --[[@as ClickedFrame]]
	frame:MoveToFront()
	frame:SetTitle(title)
	frame:SetStatusText(statusText)
	frame:EnableResize(false)
	frame:SetWidth(400)
	frame:SetHeight(600)
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
		frame = nil
	end)

	tabGroup = AceGUI:Create("TabGroup") --[[@as AceGUITabGroup]]
	tabGroup:SetCallback("OnGroupSelected", OnTabSelected)
	tabGroup:SetLayout("Flow")
	tabGroup:SetFullWidth(true)
	tabGroup:SetFullHeight(true)

	SetState(STATE_IMPORT)

	frame:AddChild(tabGroup)
end

-- Private addon API

--- @class ImportFrame
local ImportFrame = {}

function ImportFrame:ImportBindingOrGroup()
	local function OnImportText(text)
		local success, data = Clicked:Deserialize(text, true)

		if not success then
			return false, data --[[@as string]]
		end

		if data.type ~= "binding" and data.type ~= "group" then
			return false, Addon.L["Invalid import string: Expected a binding or group"]
		end

		return true, data --[[@as ShareData]]
	end

	local title = Addon.L["Import Bindings"]
	local status = string.format(Addon.L["Importing bindings into: %s"], Addon.db:GetCurrentProfile())

	OpenFrame(title, status, "binding_group", OnImportText)
end

function ImportFrame:ImportProfile()
	local function OnImportText(text)
		local success, data = Clicked:Deserialize(text, true)

		if not success then
			return false, data --[[@as string]]
		end

		if data.type ~= "profile" then
			return false, Addon.L["Invalid import string: Expected a profile"]
		end

		return true, data --[[@as ExportProfile]]
	end

	local title = Addon.L["Import Profile"]
	local status = string.format(Addon.L["Replacing bindings in profile: %s"], Addon.db:GetCurrentProfile())

	OpenFrame(title, status, "profile", OnImportText)
end

--- @param success boolean
--- @param data string|ExportProfile|ShareData
--- @param sender string
function ImportFrame:ImportProfileFromComm(success, data, sender)
	local function OnImportText()
		return success, data
	end

	local title = Addon.L["Import Profile"]
	local status = string.format(Addon.L["Replacing bindings in profile: %s"], Addon.db:GetCurrentProfile())

	OpenFrame(title, status, "profile", OnImportText)

	if success then
		importText = string.format(Addon.L["Imported Clicked profile from %s"], sender)
		reviewData = data --[[@as ExportProfile]]

		SetState(STATE_REVIEW)
	end
end

Addon.ImportFrame = ImportFrame

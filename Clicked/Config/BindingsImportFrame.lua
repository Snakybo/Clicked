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

local STATE_IMPORT = 1
local STATE_REVIEW = 2

local currentState

local frame
local tabGroup

-- import tab
--- @type string?
local importText

-- review tab
--- @type ShareData?
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
		local success, data = Clicked:Deserialize(text)

		if success then
			importText = text
			reviewData = data --[[@as ShareData]]

			SetState(STATE_REVIEW)
		else
			textField:SetText(data --[[@as string]])
			textField:SetFocus()
			textField:HighlightText()

			importText = nil
			reviewData = nil

			SetState(STATE_IMPORT)
		end
	end)

	container:AddChild(textField)
end

---@param container AceGUIContainer
local function BuildReviewTab(container)
	if reviewData == nil then
		error("Cannot open review tab without data")
	end

	do
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]

		if reviewData.type == "group" then
			widget:SetText(string.format(Addon.L["Importing group '%s' with %d bindings"], reviewData.group.name, #reviewData.group.bindings))
		elseif reviewData.type == "binding" then
			widget:SetText(string.format(Addon.L["Importing binding '%s'"], Addon:GetBindingNameAndIcon(reviewData.binding)))
		end

		widget:SetFullWidth(true)
		widget:SetFontObject(GameFontHighlight)

		container:AddChild(widget)
	end

	local tree
	do
		tree = AceGUI:Create("ClickedBindingImportList") --[[@as ClickedBindingImportList]]
		tree:SetFullWidth(true)
		tree:SetHeight(440)
		tree:SetItems(reviewData)

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
					for _, binding in ipairs(reviewData.group.bindings) do
						binding.keybind = ""
					end
				elseif reviewData.type == "binding" then
					reviewData.binding.keybind = ""
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

function Addon:BindingImportFrame_Open()
	if frame ~= nil and frame:IsVisible() then
		return
	end

	currentState = nil
	importText = nil
	reviewData = nil
	reviewImportKeybinds = true

	frame = AceGUI:Create("ClickedTopLevelFrame") --[[@as AceGUIFrame]]
	frame:SetTitle(Addon.L["Import Bindings"])
	frame:SetStatusText(string.format(Addon.L["Importing bindings into: %s"], Addon.db:GetCurrentProfile()))
	frame:EnableResize(false)
	frame:SetWidth(400)
	frame:SetHeight(600)
	frame:SetLayout("Flow")
	frame:SetCallback("OnClose", function(widget)
		AceGUI:Release(widget)
	end)

	tabGroup = AceGUI:Create("TabGroup") --[[@as AceGUITabGroup]]
	tabGroup:SetCallback("OnGroupSelected", OnTabSelected)
	tabGroup:SetLayout("Flow")
	tabGroup:SetFullWidth(true)
	tabGroup:SetFullHeight(true)

	SetState(STATE_IMPORT)

	frame:AddChild(tabGroup)
end

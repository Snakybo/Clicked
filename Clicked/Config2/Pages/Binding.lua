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

--- @class BindingConfigTab
--- @field public container AceGUIContainer
--- @field public bindings Binding[]
--- @field public Show fun(self: BindingConfigTab, container: AceGUIContainer)
--- @field public Hide fun(self: BindingConfigTab)
--- @field public Redraw fun(self: BindingConfigTab, container: AceGUIContainer, binding: Binding)

--- @class BindingConfigTabImpl
--- @field public title string
--- @field public implementation BindingConfigTab
--- @field public hidden? fun(binding: DataObject):boolean

local AceGUI = LibStub("AceGUI-3.0")

--- @class ClickedInternal
local Addon = select(2, ...)

Addon.BindingConfig = Addon.BindingConfig or {}

local Helpers = Addon.BindingConfig.Helpers

--- @class BindingConfigBindingPage : BindingConfigPage
--- @field public targets Binding[]
--- @field private tabStatus { selected: string? }
--- @field private tabs { [string]: BindingConfigTabImpl }
--- @field private currentTab? string
Addon.BindingConfig.BindingPage = {
	keepTreeSelection = true,
	tabStatus = {},
	tabs = {
		action = {
			title = "Action",
			implementation = CreateFromMixins(Addon.BindingConfig.BindingActionTab)
		},
		target = {
			title = "Targets",
			implementation = CreateFromMixins(Addon.BindingConfig.BindingTargetTab)
		},
		load = {
			title = "Load conditions",
			implementation = CreateFromMixins(Addon.BindingConfig.BindingConditionTab)
		},
		macro ={
			title = "Macro conditions",
			implementation = CreateFromMixins(Addon.BindingConfig.BindingConditionTab)
		},
		status = {
			title = "Status",
			implementation = CreateFromMixins(Addon.BindingConfig.BindingStatusTab)
		}
	}
}

function Addon.BindingConfig.BindingPage:Show()
end

function Addon.BindingConfig.BindingPage:Hide()
	local currentTabId = self.currentTab

	if currentTabId ~= nil then
		local tab = self.tabs[currentTabId].implementation

		Addon:SafeCall(tab.Hide, tab)

		tab.container = nil
		tab.bindings = nil
	end
end

function Addon.BindingConfig.BindingPage:Redraw()
	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			return #binding.keybind > 0 and Addon:SanitizeKeybind(binding.keybind) or Addon.L["UNBOUND"]
		end

		local hasMixedValues, mixedValueText = Helpers:GetMixedValues(self.targets, ValueSelector)

		--- @return boolean
		local function SupportsUnusedModifiers()
			if hasMixedValues then
				return false
			end

			if Addon.db.profile.options.bindUnassignedModifiers and Addon:IsUnmodifiedKeybind(self.targets[1].keybind) then
				return #Addon:GetUnusedModifierKeyKeybinds(self.targets[1].keybind, Addon:GetActiveBindings()) > 0
			end

			return false
		end

		--- @return string
		--- @return string?
		local function GetTooltipText()
			local subtext = Addon.L["Click and press a key to bind, or right click to unbind."]

			if SupportsUnusedModifiers() then
				subtext = subtext .. "\n\n" .. Addon.L["Key combination also bound in combination with unassigned modifiers"]
			end

			if mixedValueText ~= nil then
				subtext = subtext .. "\n\n" .. mixedValueText
			end

			return Addon.L["Key"], subtext
		end

		--- @param widget ClickedKeybinding
		--- @param key string
		local function OnKeyChanged(widget, _, key)
			for _, target in ipairs(self.targets) do
				target.keybind = key

				Addon:EnsureSupportedTargetModes(target.targets, key, target.actionType)
				Clicked:ReloadBinding(target, true)
			end

			hasMixedValues, mixedValueText = Helpers:GetMixedValues(self.targets, ValueSelector)
			widget:SetMarker(SupportsUnusedModifiers())
		end

		local widget = AceGUI:Create("ClickedKeybinding") --[[@as ClickedKeybinding]]
		widget:SetFullWidth(true)
		widget:SetCallback("OnKeyChanged", OnKeyChanged)
		widget:SetKey(hasMixedValues and Helpers.MIXED_VALUE_TEXT or Addon:SanitizeKeybind(self.targets[1].keybind))
		widget:SetMarker(SupportsUnusedModifiers())

		Helpers:RegisterTooltip(widget, GetTooltipText)

		self.container:AddChild(widget)
	end

	self:CreateTabGroup()
end

function Addon.BindingConfig.BindingPage:OnBindingReload()
end

--- @private
function Addon.BindingConfig.BindingPage:CreateTabGroup()
	--- @param container AceGUIContainer
	--- @param group string
	local function OnTabGroupSelected(container, _, group)
		local currentTab = self.currentTab

		if currentTab == group then
			return
		end

		if currentTab ~= nil then
			local tab = self.tabs[currentTab].implementation

			Addon:SafeCall(tab.Hide, tab)

			tab.container = nil
			tab.bindings = nil

			self.currentTab = nil
		end

		local newTab = self.tabs[group]

		if newTab ~= nil then
			local tab = newTab.implementation

			self.currentTab = group

			Addon:SafeCall(tab.Show, tab)

			tab.container = container
			tab.bindings = self.targets

			Addon:SafeCall(tab.Redraw, tab)
		end
	end

	--- @param tab BindingConfigTabImpl
	local function IsHidden(tab)
		if tab.hidden == nil then
			return false
		end

		return Addon:SafeCall(tab.hidden, tab, self.targets)
	end

	--- @type AceGUITabGroupTab[]
	local tabs = {}

	--- @type string[]
	local availableTabs = {}

	for id, tab in pairs(self.tabs) do
		if not IsHidden(tab) then
			table.insert(tabs, {
				text = Addon.L[tab.title],
				value = id
			})
			table.insert(availableTabs, id)
		end
	end

	if not tContains(availableTabs, self.tabStatus.selected) then
		self.tabStatus.selected = availableTabs[1]
	end

	local widget = AceGUI:Create("ClickedTabGroup") --[[@as ClickedTabGroup]]
	widget:SetFullWidth(true)
	widget:SetFullHeight(true)
	widget:SetLayout("Flow")
	widget:SetTabs(tabs)
	widget:SetStatusTable(self.tabStatus)
	widget:SetCallback("OnGroupSelected", OnTabGroupSelected)
	widget:SelectTab(self.tabStatus.selected)

	self.container:AddChild(widget)
end

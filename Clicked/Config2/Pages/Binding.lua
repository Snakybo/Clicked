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
--- @field public order integer
--- @field public implementation BindingConfigTab
--- @field public filter? fun(bindings: Binding[]):Binding[]

local AceGUI = LibStub("AceGUI-3.0")

--- @class ClickedInternal
local Addon = select(2, ...)

local Helpers = Addon.BindingConfig.Helpers

local BT_SPELL = Addon.BindingTypes.SPELL
local BT_ITEM = Addon.BindingTypes.ITEM
local BT_MACRO = Addon.BindingTypes.MACRO
local BT_UNIT_SELECT = Addon.BindingTypes.UNIT_SELECT
local BT_UNIT_MENU = Addon.BindingTypes.UNIT_MENU
local BT_APPEND = Addon.BindingTypes.APPEND
local BT_CANCELAURA = Addon.BindingTypes.CANCELAURA

--- @param bindings Binding[]
--- @param bindingTypes string[]
--- @return Binding[]
local function FilterBindingsByActionType(bindings, bindingTypes)
	--- @type Binding[]
	local result = {}

	--- @param item Binding
	--- @return boolean
	local function Predicate(item)
		return tContains(bindingTypes, item.actionType)
	end

	for _, binding in ipairs(bindings) do
		if Predicate(binding) then
			table.insert(result, binding)
		end
	end

	return result
end

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigBindingPage : BindingConfigPage
--- @field public targets Binding[]
--- @field private tabWidget ClickedTabGroup
--- @field private tabStatus { selected: string? }
--- @field private tabs { [string]: BindingConfigTabImpl }
--- @field private currentTab? string
Addon.BindingConfig.BindingPage = {
	keepTreeSelection = true,
	tabStatus = {},
	tabs = {
		action = {
			title = "Action",
			order = 1,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingActionTab),
			filter = function(bindings)
				local bindingTypes = { BT_SPELL, BT_ITEM, BT_MACRO, BT_APPEND, BT_CANCELAURA }
				return FilterBindingsByActionType(bindings, bindingTypes)
			end
		},
		target = {
			title = "Targets",
			order = 2,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingTargetTab),
			filter = function(bindings)
				local bindingTypes = { BT_SPELL, BT_ITEM, BT_MACRO, BT_UNIT_SELECT, BT_UNIT_MENU }
				return FilterBindingsByActionType(bindings, bindingTypes)
			end
		},
		load = {
			title = "Load conditions",
			order = 3,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingConditionTab)
		},
		macro ={
			title = "Macro conditions",
			order = 4,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingConditionTab),
			filter = function(bindings)
				local bindingTypes = { BT_SPELL, BT_ITEM, BT_UNIT_SELECT, BT_UNIT_MENU, BT_APPEND, BT_CANCELAURA }
				return FilterBindingsByActionType(bindings, bindingTypes)
			end
		},
		status = {
			title = "Status",
			order = 5,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingStatusTab),
			filter = function(bindings)
				local bindingTypes = { BT_SPELL, BT_ITEM, BT_MACRO, BT_APPEND, BT_CANCELAURA }

				--- @type Binding[]
				local result = {}

				for _, binding in ipairs(FilterBindingsByActionType(bindings, bindingTypes)) do
					-- TODO: Maybe we can retrieve this from the tree status?
					if Clicked:IsBindingLoaded(binding) then
						table.insert(result, binding)
					end
				end

				return result
			end
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
	self:UpdateTabGroup()
end

--- Update the available tabs in the tab group widget
---
--- @private
function Addon.BindingConfig.BindingPage:UpdateTabGroup()
	local tabs = self:GetAvailableTabs()

	local selected = self.tabStatus.selected
	if selected == nil or not ContainsIf(tabs, function(tab) return tab.value == self.tabStatus.selected end) then
		selected = tabs[1].value
	end

	self.tabWidget:SetTabs(tabs)

	if selected ~= self.tabStatus.selected then
		self.tabWidget:SelectTab(selected)
	end
end

--- Create the tab group widget.
---
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

	local tabs = self:GetAvailableTabs()

	local selected = self.tabStatus.selected
	if selected == nil or not ContainsIf(tabs, function(tab) return tab.value == self.tabStatus.selected end) then
		selected = tabs[1].value
	end

	self.tabWidget = AceGUI:Create("ClickedTabGroup") --[[@as ClickedTabGroup]]
	self.tabWidget:SetFullWidth(true)
	self.tabWidget:SetFullHeight(true)
	self.tabWidget:SetLayout("Flow")
	self.tabWidget:SetTabs(tabs)
	self.tabWidget:SetStatusTable(self.tabStatus)
	self.tabWidget:SetCallback("OnGroupSelected", OnTabGroupSelected)
	self.tabWidget:SelectTab(selected)

	self.container:AddChild(self.tabWidget)
end

--- Get all available tabs for the current targets.
---
--- @private
--- @return AceGUITabGroupTab[] tabs The available tabs for use in the `AceGUITabGroup` widget.
function Addon.BindingConfig.BindingPage:GetAvailableTabs()
	--- @param tab BindingConfigTabImpl
	local function IsHidden(tab)
		if tab.filter == nil then
			return false
		end

		local _, filtered = Addon:SafeCall(tab.filter, self.targets)
		return #filtered == 0
	end

	--- @type { [string]: integer }
	local keys = {}

	--- @type string[]
	local order = {}

	for id, tab in pairs(self.tabs) do
		keys[id] = tab.order
		table.insert(order, id)
	end

	table.sort(order, function(left, right)
		return keys[left] < keys[right]
	end)

	--- @type AceGUITabGroupTab[]
	local tabs = {}

	for _, id in ipairs(order) do
		local tab = self.tabs[id]

		if not IsHidden(tab) then
			table.insert(tabs, {
				text = Addon.L[tab.title],
				value = id
			})
		end
	end

	return tabs
end

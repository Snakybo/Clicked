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
--- @field public controller BindingConfigBindingPage
--- @field public Show? fun(self: BindingConfigTab, container: AceGUIContainer)
--- @field public Hide? fun(self: BindingConfigTab)
--- @field public Redraw? fun(self: BindingConfigTab, container: AceGUIContainer, binding: Binding)
--- @field public OnBindingReload? fun(self: BindingConfigTab, relevant: boolean, changed: integer[])

--- @class BindingConfigTabImpl
--- @field public title string
--- @field public order integer
--- @field public implementation BindingConfigTab
--- @field public filter? fun(bindings: Binding[]):Binding[]

local AceGUI = LibStub("AceGUI-3.0")

--- @class ClickedInternal
local Addon = select(2, ...)

local Helpers = Addon.BindingConfig.Helpers

local BT_SPELL = Clicked.ActionType.SPELL
local BT_ITEM = Clicked.ActionType.ITEM
local BT_MACRO = Clicked.ActionType.MACRO
local BT_UNIT_SELECT = Clicked.ActionType.UNIT_SELECT
local BT_UNIT_MENU = Clicked.ActionType.UNIT_MENU
local BT_APPEND = Clicked.ActionType.APPEND
local BT_CANCELAURA = Clicked.ActionType.CANCELAURA

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

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigBindingPage : BindingConfigPage
--- @field public targets Binding[]
--- @field private tabWidget ClickedTabGroup
--- @field private tabStatus { selected: string? }
--- @field private tabs { [string]: BindingConfigTabImpl }
--- @field private currentTab? string
--- @field private filteredTargets { [string]: Binding[] }
--- @field private scrollFrame? AceGUIScrollFrame
--- @field private scrollFrameStatus { scrollvalue: number }
Addon.BindingConfig.BindingPage = {
	keepTreeSelection = true,
	tabStatus = {},
	tabs = {
		action = {
			title = "Action",
			order = 1,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingActionTab),
			filter = function(bindings)
				local bindingTypes = { BT_SPELL, BT_ITEM, BT_CANCELAURA }
				return FilterBindingsByActionType(bindings, bindingTypes)
			end
		},
		action_unit = {
			title = "Action",
			order = 2,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingUnitActionTab),
			filter = function(bindings)
				local bindingTypes = { BT_UNIT_SELECT, BT_UNIT_MENU }
				return FilterBindingsByActionType(bindings, bindingTypes)
			end
		},
		macro = {
			title = "Macro",
			order = 3,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingMacroTab),
			filter = function(bindings)
				local bindingTypes = { BT_MACRO, BT_APPEND }
				return FilterBindingsByActionType(bindings, bindingTypes)
			end
		},
		target = {
			title = "Targets",
			order = 10,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingTargetTab),
			filter = function(bindings)
				local bindingTypes = { BT_SPELL, BT_ITEM, BT_UNIT_SELECT, BT_UNIT_MENU }
				return FilterBindingsByActionType(bindings, bindingTypes)
			end
		},
		load = {
			title = "Load conditions",
			order = 20,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingConditionTab, {
				content = Addon.Condition.Registry:GetConditionSet("load")
			})
		},
		load_macro ={
			title = "Macro conditions",
			order = 21,
			implementation = CreateFromMixins(Addon.BindingConfig.BindingConditionTab, {
				content = Addon.Condition.Registry:GetConditionSet("macro")
			}),
			filter = function(bindings)
				local bindingTypes = { BT_SPELL, BT_ITEM, BT_CANCELAURA }
				return FilterBindingsByActionType(bindings, bindingTypes)
			end
		},
		status = {
			title = "Status",
			order = 30,
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
	},
	filteredTargets = {},
	scrollFrameStatus = {}
}

--- @protected
function Addon.BindingConfig.BindingPage:Hide()
	local currentTab = self.currentTab

	if currentTab ~= nil then
		local tab = self.tabs[currentTab].implementation
		Addon:SafeCall(tab.Hide, tab)

		tab.container = nil
		tab.bindings = nil
		tab.controller = nil

		self.currentTab = nil
	end

	table.wipe(self.filteredTargets)

	self.tabWidget = nil
	self.scrollFrame = nil
end

--- @protected
function Addon.BindingConfig.BindingPage:Redraw()
	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			return #binding.keybind > 0 and Addon:SanitizeKeybind(binding.keybind) or Addon.L["UNBOUND"]
		end

		--- @type boolean, fun():boolean
		local hasMixedValues, updateCb

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

		--- @return string[]
		local function GetTooltipText()
			local lines = { Addon.L["Key"], Addon.L["Click and press a key to bind, or right click to unbind."] }

			if SupportsUnusedModifiers() then
				table.insert(lines, "")
				table.insert(lines, Addon.L["Key combination also bound in combination with unassigned modifiers"])
			end

			return lines
		end

		--- @param widget ClickedKeybinding
		--- @param key string
		local function OnKeyChanged(widget, _, key)
			for _, target in ipairs(self.targets) do
				target.keybind = key

				Addon:ReloadBinding(target, "keybind")
				Addon:ReloadBinding(target, "targets")
			end

			updateCb()
			widget:SetMarker(SupportsUnusedModifiers())
		end

		local widget = AceGUI:Create("ClickedKeybinding") --[[@as ClickedKeybinding]]
		widget:SetFullWidth(true)
		widget:SetCallback("OnKeyChanged", OnKeyChanged)
		widget:SetMarker(SupportsUnusedModifiers())

		hasMixedValues, updateCb = Helpers:HandleWidget(widget, self.targets, ValueSelector, GetTooltipText)

		self.container:AddChild(widget)
	end

	self:CreateTabGroup()
end

--- @protected
--- @param relevant boolean
--- @param changed integer[]
function Addon.BindingConfig.BindingPage:OnBindingReload(relevant, changed)
	self:UpdateTabGroup()

	local currentTab = self.currentTab

	if currentTab ~= nil then
		local impl = self.tabs[currentTab].implementation
		Addon:SafeCall(impl.OnBindingReload, impl, relevant, changed)
	end
end

--- Redraw the currently active tab
---
--- @param full? boolean
function Addon.BindingConfig.BindingPage:RedrawTab(full)
	local currentTab = self.currentTab

	if currentTab ~= nil then
		local impl = self.tabs[currentTab].implementation
		local createScrollFrame = full or self.scrollFrame == nil
		local currentScrollValue = self.scrollFrameStatus.scrollvalue or 0

		if createScrollFrame then
			self.tabWidget:ReleaseChildren()

			self.scrollFrame = AceGUI:Create("ScrollFrame") --[[@as AceGUIScrollFrame]]
			self.scrollFrame:SetLayout("Flow")
			self.scrollFrame:SetFullWidth(true)
			self.scrollFrame:SetFullHeight(true)
			self.scrollFrame:SetStatusTable(self.scrollFrameStatus)

			impl.container = self.scrollFrame
		else
			self.scrollFrame:ReleaseChildren()
		end

		Addon:SafeCall(impl.Redraw, impl)

		if createScrollFrame then
			self.tabWidget:AddChild(self.scrollFrame)
		else
			self.scrollFrame:SetScroll(currentScrollValue)
		end
	end
end

--- @private
--- Activate a tab group by its ID.
---
--- If there's a tab group currently active, it will be hidden and the new tab group will be shown.
---
--- @param group string
function Addon.BindingConfig.BindingPage:ActivateTabGroup(group)
	local currentTab = self.currentTab

	if currentTab ~= nil then
		local tab = self.tabs[currentTab].implementation
		Addon:SafeCall(tab.Hide, tab)

		tab.container = nil
		tab.bindings = nil
		tab.controller = nil

		self.currentTab = nil
	end

	local newTab = self.tabs[group]
	self.currentTab = group

	local impl = newTab.implementation
	impl.bindings = self.filteredTargets[group] or self.targets
	impl.controller = self

	Addon:SafeCall(impl.Show, impl)
	self:RedrawTab(true)
end

--- @private
--- Update the available tabs in the tab group widget
function Addon.BindingConfig.BindingPage:UpdateTabGroup()
	self:FilterBindings()
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

--- @private
--- Create the tab group widget.
function Addon.BindingConfig.BindingPage:CreateTabGroup()
	--- @param group string
	local function OnTabGroupSelected(_, _, group)
		local currentTab = self.currentTab
		if currentTab == group then
			return
		end

		self:ActivateTabGroup(group)
	end

	self:FilterBindings()
	local tabs = self:GetAvailableTabs()

	local selected = self.tabStatus.selected
	if selected == nil or not ContainsIf(tabs, function(tab) return tab.value == self.tabStatus.selected end) then
		selected = tabs[1].value
	end

	self.tabWidget = AceGUI:Create("ClickedTabGroup") --[[@as ClickedTabGroup]]
	self.tabWidget:SetFullWidth(true)
	self.tabWidget:SetFullHeight(true)
	self.tabWidget:SetLayout("Flow")
	self.tabWidget:SetStatusTable(self.tabStatus)
	self.tabWidget:SetTabs(tabs)
	self.tabWidget:SetCallback("OnGroupSelected", OnTabGroupSelected)

	if selected ~= self.tabStatus.selected then
		self.tabWidget:SelectTab(selected)
	else
		self:ActivateTabGroup(selected)
	end

	self.container:AddChild(self.tabWidget)
end

--- @private
--- Get all available tabs for the current targets.
---
--- @return AceGUITabGroupTab[] tabs The available tabs for use in the `AceGUITabGroup` widget.
function Addon.BindingConfig.BindingPage:GetAvailableTabs()
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
		local targets = self.filteredTargets[id] or self.targets

		if #targets > 0 then
			table.insert(tabs, {
				text = Addon.L[tab.title],
				value = id
			})
		end
	end

	return tabs
end

--- @private
--- Filter bindings for all tabs.
function Addon.BindingConfig.BindingPage:FilterBindings()
	table.wipe(self.filteredTargets)

	for id, tab in pairs(self.tabs) do
		if tab.filter ~= nil then
			local _, filtered = Addon:SafeCall(tab.filter, self.targets)
			self.filteredTargets[id] = filtered
		end
	end
end

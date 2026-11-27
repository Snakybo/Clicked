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

local Helpers = Addon.BindingConfig.Helpers
local Utils = Addon.Condition.Utils

--- @param drawer DrawerConfig
--- @return string[]
local function GetValueTooltipText(drawer)
	--- @type string[]
	local result = { Addon.L[drawer.label] }
	local tooltip = drawer.tooltip

	if type(tooltip) == "string" then
		table.insert(result, tooltip)
	elseif type(tooltip) == "table" then
		for _, line in ipairs(tooltip) do
			table.insert(result, line)
		end
	end

	return result
end

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingSelectConditionDrawer : BindingConditionDrawer
--- @field private checkbox ClickedCheckBox
--- @field private dropdown? ClickedDropdown
--- @field private dropdownCb? fun(): boolean
--- @field private negated? ClickedCheckBox
--- @correlated dropdown, dropdownCb
local Drawer = {}

--- @protected
function Drawer:Draw()
	local drawer = self.condition.drawer --[[@as SelectDrawerConfig]]
	local mode = drawer.mode or "single"
	local isMultiselect = mode ~= "single"

	--- @param binding Binding
	--- @return boolean
	local function IsEnabled(binding)
		return Utils.HasEnabledFlag(Utils.GetLoadCondition(binding, self.condition))
	end

	local isAnyEnabled = FindInTableIf(self.bindings, IsEnabled) ~= nil

	self.checkbox = Helpers:DrawConditionToggle(self.container, self.bindings, self.fieldName, self.condition, self.requestRedraw)

	if not isAnyEnabled then
		return
	end

	--- @type table<SimpleConditionValue, string>, SimpleConditionValue[]
	local items, order = self.requestAvailableValues()

	--- @param load LoadCondition<SimpleConditionValue>
	--- @return SimpleConditionValue[]
	local function GetValues(load)
		--- @type SimpleConditionValue[]
		local result = {}

		if mode == "bitmask" then
			local mask = Utils.UnpackLoadOption(load)[1] --[[@as integer?]] or 0

			for _, flag in ipairs(order) do
				--- @cast flag integer
				if bit.band(mask, flag) > 0 then
					table.insert(result, flag)
				end
			end

			return result
		end

		local values = Utils.UnpackLoadOption(load)

		for _, value in ipairs(order) do
			if tContains(values, value) then
				table.insert(result, value)
			end
		end

		for _, value in ipairs(values) do
			if not tContains(order, value) then
				Clicked:LogDebug("Selected load option {condition}:{option} is not in list of available values: {options}", self.condition.id, value,
					order)
			end
		end

		return result
	end

	--- @param load LoadCondition<SimpleConditionValue>
	--- @param values SimpleConditionValue[]
	local function SetValues(load, values)
		if mode == "bitmask" then
			local mask = 0

			for _, flag in ipairs(values) do
				--- @cast flag integer
				mask = bit.bor(mask, flag)
			end

			load.value = mask
		else
			Utils.SetLoadOptionValues(load, values)
		end
	end

	--- @param binding Binding
	--- @return LoadCondition<SimpleConditionValue>
	local function GetLoad(binding)
		return Utils.GetLoadCondition(binding, self.condition) --[[@as LoadCondition<SimpleConditionValue>]]
	end

	-- dropdown
	do
		local changed = false

		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			if not IsEnabled(binding) then
				return Helpers.IGNORE_VALUE
			end

			local values = GetValues(GetLoad(binding))

			if isMultiselect then
				if #values == 0 then
					return Addon.L["Nothing"]
				elseif #values == #order then
					return Addon.L["Everything"]
				end
			end

			--- @type string[]
			local result = {}

			for _, value in ipairs(values) do
				table.insert(result, items[value] or tostring(value))
			end

			return table.concat(result, ", ")
		end

		--- @param binding Binding
		--- @return "\001"|SimpleConditionValue|SimpleConditionValue[]
		local function GetRawValue(binding)
			if not IsEnabled(binding) then
				return Helpers.IGNORE_VALUE
			end

			local values = GetValues(GetLoad(binding))

			if isMultiselect then
				return values
			end

			if values[1] ~= nil then
				return values[1]
			end

			return Helpers.IGNORE_VALUE
		end

		--- @return string[]
		local function GetTooltipText()
			return GetValueTooltipText(drawer)
		end

		--- @param widget ClickedDropdown
		--- @param event string
		--- @param value SimpleConditionValue
		--- @param enabled? boolean
		local function OnValueChanged(widget, event, value, enabled)
			for _, binding in ipairs(self.bindings) do
				local load = GetLoad(binding)

				if Utils.HasEnabledFlag(load) then
					local values = GetValues(load)

					if not isMultiselect then
						values = { value }
					elseif enabled then
						if not tContains(values, value) then
							table.insert(values, value)
						end
					else
						for i = #values, 1, -1 do
							if values[i] == value then
								table.remove(values, i)
							end
						end
					end

					SetValues(load, values)
					Utils.SetLoadCondition(binding, self.condition, load)

					if isMultiselect then
						changed = true
					else
						Addon:ReloadBinding(binding, self.fieldName)
					end
				end
			end

			if not isMultiselect then
				self.requestRedraw(true)
			end
		end

		local function OnClosed()
			if changed then
				for _, binding in ipairs(self.bindings) do
					if IsEnabled(binding) then
						Addon:ReloadBinding(binding, self.fieldName)
					end
				end

				self.requestRedraw(true)
				changed = false
			end
		end

		self.dropdown = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown]]
		self.dropdown:SetCallback("OnValueChanged", OnValueChanged)
		self.dropdown:SetCallback("OnClosed", OnClosed)
		self.dropdown:SetList(items, order)
		self.dropdown:SetRelativeWidth(0.5)
		self.dropdown:SetMultiselect(isMultiselect)

		local _, cb = Helpers:HandleWidget(self.dropdown, self.bindings, ValueSelector, GetTooltipText, GetRawValue)
		self.dropdownCb = cb

		self.container:AddChild(self.dropdown)
	end

	-- negate
	self.negated = Helpers:DrawNegateToggle(self.container, self.bindings, self.fieldName, self.condition, self.requestRedraw)
end

--- @protected
function Drawer:Update()
	if self.dropdown ~= nil then
		self.dropdown:SetList(self.requestAvailableValues())
		self.dropdownCb()
	end
end

Addon.BindingConfig.BindingConditionDrawers = Addon.BindingConfig.BindingConditionDrawers or {}
Addon.BindingConfig.BindingConditionDrawers["select"] = Drawer

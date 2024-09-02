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

local Helpers = Addon.BindingConfig.Helpers

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingSelectConditionDrawer : BindingConditionDrawer
--- @field private checkbox ClickedCheckBox
--- @field private dropdown? ClickedDropdown
--- @field private dropdownCb? fun():boolean
--- @field private negated? ClickedCheckBox
local Drawer = {}

--- @protected
function Drawer:Draw()
	local drawer = self.condition.drawer

	local isAnyEnabled = FindInTableIf(self.bindings, function(binding)
		--- @type SimpleLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()
		return load.selected
	end) ~= nil

	self.checkbox = Helpers:DrawConditionToggle(self.container, self.bindings, self.fieldName, self.condition, self.requestRedraw)

	if not isAnyEnabled then
		return
	end

	-- dropdown
	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type SimpleLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()

			if type(load.value) == "string" then
				return load.value
			elseif type(load.value) == "boolean" then
				return load.value and Addon.L["Enabled"] or Addon.L["Disabled"]
			end

			return tostring(load.value)
		end

		--- @param binding Binding
		--- @return any
		local function GetRawValue(binding)
			local load = binding.load[self.fieldName] or self.condition.init()
			return load.value
		end

		--- @return string[]
		local function GetTooltipText()
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

		--- @param value string
		local function OnValueChanged(_, _, value)
			for _, binding in ipairs(self.bindings) do
				--- @type SimpleLoadOption
				local load = binding.load[self.fieldName] or self.condition.init()

				if load.selected then
					load.value = value
					binding.load[self.fieldName] = load
					Addon:ReloadBinding(binding, self.fieldName)
				end
			end

			self.requestRedraw()
		end

		self.dropdown = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown]]
		self.dropdown:SetCallback("OnValueChanged", OnValueChanged)
		self.dropdown:SetList(self.requestAvailableValues())
		self.dropdown:SetRelativeWidth(0.5)

		local _, cb = Helpers:HandleWidget(self.dropdown, self.bindings, ValueSelector, GetTooltipText, GetRawValue)
		self.dropdownCb = cb

		self.container:AddChild(self.dropdown)
	end

	-- negate
	self.negated = Helpers:DrawNegateToggle(self.container, self.bindings, self.fieldName, self.condition, self.requestRedraw)
end

--- @protected
function Drawer:Update()
	self.dropdown:SetList(self.requestAvailableValues())
	self.dropdownCb()
end

Addon.BindingConfig.BindingConditionDrawers = Addon.BindingConfig.BindingConditionDrawers or {}
Addon.BindingConfig.BindingConditionDrawers["select"] = Drawer

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
local Drawer = {}

--- @protected
function Drawer:Draw()
	local drawer = self.condition.drawer

	local isAnyEnabled = FindInTableIf(self.bindings, function(binding)
		--- @type SimpleLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()
		return load.selected
	end) ~= nil

	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type SimpleLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return load.selected and Addon.L["Enabled"] or Addon.L["Disabled"]
		end

		--- @param binding Binding
		--- @return boolean?
		local function GetEnabledState(binding)
			--- @type SimpleLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return load.selected
		end

		--- @param value boolean|nil
		local function OnValueChanged(_, _, value)
			--- @cast value boolean

			for _, binding in ipairs(self.bindings) do
				--- @type SimpleLoadOption
				local load = binding.load[self.fieldName] or self.condition.init()
				load.selected = value
				binding.load[self.fieldName] = load

				Clicked:ReloadBinding(binding, true)
			end

			self.requestRedraw()
		end

		self.checkbox = AceGUI:Create("ClickedCheckBox") --[[@as ClickedCheckBox]]
		self.checkbox:SetType("checkbox")
		self.checkbox:SetCallback("OnValueChanged", OnValueChanged)

		if isAnyEnabled then
			self.checkbox:SetRelativeWidth(0.5)
		else
			self.checkbox:SetFullWidth(true)
		end

		Helpers:HandleWidget(self.checkbox, self.bindings, ValueSelector, Addon.L[drawer.label], GetEnabledState)

		self.container:AddChild(self.checkbox)
	end

	if isAnyEnabled then
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type SimpleLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return load.value
		end

		--- @param value string
		local function OnValueChanged(_, _, value)
			for _, binding in ipairs(self.bindings) do
				--- @type SimpleLoadOption
				local load = binding.load[self.fieldName] or self.condition.init()

				if load.selected then
					load.value = value
					binding.load[self.fieldName] = load
					Clicked:ReloadBinding(binding, true)
				end
			end

			self.requestRedraw()
		end

		self.dropdown = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown]]
		self.dropdown:SetCallback("OnValueChanged", OnValueChanged)
		self.dropdown:SetList(self.requestAvailableValues())
		self.dropdown:SetRelativeWidth(0.5)

		local _, cb = Helpers:HandleWidget(self.dropdown, self.bindings, ValueSelector, Addon.L[drawer.label])
		self.dropdownCb = cb

		self.container:AddChild(self.dropdown)
	end
end

--- @protected
function Drawer:Update()
	self.dropdown:SetList(self.requestAvailableValues())
	self.dropdownCb()
end

Addon.BindingConfig.BindingConditionDrawers = Addon.BindingConfig.BindingConditionDrawers or {}
Addon.BindingConfig.BindingConditionDrawers["select"] = Drawer

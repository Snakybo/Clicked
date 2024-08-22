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

--- @class BindingInputConditionDrawer : BindingConditionDrawer
--- @field private checkbox ClickedCheckBox
--- @field private editbox? ClickedEditBox
local Drawer = {}

--- @protected
function Drawer:Draw()
	local drawer = self.condition.drawer --[[@as InputDrawerConfig]]

	local isAnyEnabled = FindInTableIf(self.bindings, function(binding)
		--- @type SimpleLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()
		return load.selected
	end) ~= nil

	-- toggle
	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type SimpleLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return load.selected and Addon.L["Enabled"] or Addon.L["Disabled"]
		end

		--- @param binding Binding
		--- @return boolean
		local function GetEnabledState(binding)
			--- @type SimpleLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return load.selected
		end

		--- @param value boolean
		local function OnValueChanged(_, _, value)
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

		Helpers:HandleWidget(self.checkbox, self.bindings, ValueSelector, Addon.L[drawer.label], nil, GetEnabledState)

		self.container:AddChild(self.checkbox)
	end

	-- editbox
	if isAnyEnabled then
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type SimpleLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return load.value
		end

		--- @param widget ClickedEditBox
		--- @param value string
		local function OnTextChanged(widget, _, value)
			if drawer.validate ~= nil then
				value = drawer.validate(value, false)
				widget:SetText(value)
			end
		end

		--- @param value string
		local function OnEnterPressed(_, _, value)
			value = string.trim(value)

			if drawer.validate ~= nil then
				value = drawer.validate(value, true)
			end

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

		self.editbox = AceGUI:Create("ClickedEditBox") --[[@as ClickedEditBox]]
		self.editbox:SetCallback("OnTextChanged", OnTextChanged)
		self.editbox:SetCallback("OnEnterPressed", OnEnterPressed)
		self.editbox:SetRelativeWidth(0.5)

		Helpers:HandleWidget(self.editbox, self.bindings, ValueSelector, Addon.L[drawer.label])

		self.container:AddChild(self.editbox)
	end
end

Addon.BindingConfig.BindingConditionDrawers = Addon.BindingConfig.BindingConditionDrawers or {}
Addon.BindingConfig.BindingConditionDrawers["input"] = Drawer

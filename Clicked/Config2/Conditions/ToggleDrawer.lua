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

--- @class BindingToggleConditionDrawer : BindingConditionDrawer
--- @field private checkbox ClickedCheckBox
local Drawer = {}

--- @protected
function Drawer:Draw()
	local drawer = self.condition.drawer

	-- toggle
	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type boolean
			local load = binding.load[self.fieldName]
			return load and Addon.L["Enabled"] or Addon.L["Disabled"]
		end

		--- @param binding Binding
		--- @return boolean
		local function GetEnabledState(binding)
			return binding.load[self.fieldName]
		end

		--- @param value boolean
		local function OnValueChanged(_, _, value)
			for _, binding in ipairs(self.bindings) do
				binding.load[self.fieldName] = value
				Clicked:ReloadBinding(binding, true)
			end

			self.requestRedraw()
		end

		self.checkbox = AceGUI:Create("ClickedCheckBox") --[[@as ClickedCheckBox]]
		self.checkbox:SetType("checkbox")
		self.checkbox:SetCallback("OnValueChanged", OnValueChanged)
		self.checkbox:SetFullWidth(true)

		Helpers:HandleWidget(self.checkbox, self.bindings, ValueSelector, Addon.L[drawer.label], GetEnabledState)

		self.container:AddChild(self.checkbox)
	end
end

Addon.BindingConfig.BindingConditionDrawers = Addon.BindingConfig.BindingConditionDrawers or {}
Addon.BindingConfig.BindingConditionDrawers["toggle"] = Drawer

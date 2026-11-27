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

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigUnitActionTab : BindingConfigTab
local BindingUnitActionTab = {}

Addon.BindingConfig.BindingUnitActionTab = BindingUnitActionTab

--- @protected
function BindingUnitActionTab:Redraw()
	local combat = Addon.Condition.Registry:GetConditionById("combat")

	-- combat
	do
		--- @type table<string, string>
		local items = {
			always = Addon.L["Always"],
			ic = Addon.L["In combat"],
			ooc = Addon.L["Not in combat"],
		}

		local order = { "always", "ic", "ooc" }

		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			local value = Utils.GetBooleanValue(Utils.GetLoadCondition(binding, combat))

			if value ~= nil then
				return value and Addon.L["In combat"] or Addon.L["Not in combat"]
			end

			return Addon.L["Always"]
		end

		--- @param binding Binding
		--- @return string
		local function GetRawValue(binding)
			local value = Utils.GetBooleanValue(Utils.GetLoadCondition(binding, combat))

			if value == nil then
				return "always"
			end

			return value and "ic" or "ooc"
		end

		--- @param widget ClickedDropdown<string, string>
		--- @param event string
		--- @param value string
		local function OnValueChanged(widget, event, value)
			for _, binding in ipairs(self.bindings) do
				local load = Utils.GetLoadCondition(binding, combat)

				Utils.SetFlag(load, Clicked.LoadConditionStates.ENABLED, value ~= "always")
				Utils.SetFlag(load, Clicked.LoadConditionStates.NEGATED, false)

				if value ~= "always" then
					load.value = value == "ic"
				end

				Utils.SetLoadCondition(binding, combat, load)
				Addon:ReloadBinding(binding)
			end

			self.controller:RedrawTab()
		end

		local widget = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown<string, string>]]
		widget:SetCallback("OnValueChanged", OnValueChanged)
		widget:SetList(items, order)
		widget:SetFullWidth(true)

		Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Combat"], GetRawValue)

		self.container:AddChild(widget)
	end

	-- performance warning
	do
		--- @param binding Binding
		--- @return boolean
		local function IsCombatUnselected(binding)
			return not Utils.HasEnabledFlag(Utils.GetLoadCondition(binding, combat))
		end

		local hide = FindInTableIf(self.bindings, IsCombatUnselected)

		if not hide then
			local widget = AceGUI:Create("Label")
			widget:SetText("\n" .. Addon.L["Combat state checks for this binding require additional processing when entering and leaving combat and may cause slight performance degradation."] .. "\n")
			widget:SetFullWidth(true)

			self.container:AddChild(widget)
		end
	end
end

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

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigUnitActionTab : BindingConfigTab
Addon.BindingConfig.BindingUnitActionTab = {}

--- @protected
function Addon.BindingConfig.BindingUnitActionTab:Redraw()
	-- combat
	do
		local items = {
			always = Addon.L["Always"],
			ic = Addon.L["In combat"],
			ooc = Addon.L["Not in combat"],
		}

		local order = { "always", "ic", "ooc" }

		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			local load = binding.load.combat or Addon.Condition.Utils.CreateLoadOption(true)

			if load.selected then
				return load.value and Addon.L["In combat"] or Addon.L["Not in combat"]
			end

			return Addon.L["Always"]
		end

		--- @param binding Binding
		--- @return string
		local function GetRawValue(binding)
			local load = binding.load.combat or Addon.Condition.Utils.CreateLoadOption(true)
			return load.selected and (load.value and "ic" or "ooc") or "always"
		end

		--- @param value string
		local function OnValueChanged(_, _, value)
			for _, binding in ipairs(self.bindings) do
				local load = binding.load.combat or Addon.Condition.Utils.CreateLoadOption(true)

				if value == "always" then
					load.selected = false
				elseif value == "ic" then
					load.selected = true
					load.value = true
				elseif value == "ooc" then
					load.selected = true
					load.value = false
				end

				binding.load.combat = load
				Addon:ReloadBinding(binding)
			end

			self.controller:RedrawTab()
		end

		local widget = AceGUI:Create("ClickedDropdown") --[[@as AceGUIDropdown]]
		widget:SetCallback("OnValueChanged", OnValueChanged)
		widget:SetList(items, order)
		widget:SetFullWidth(true)

		Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Combat"], GetRawValue)

		self.container:AddChild(widget)
	end

	-- performance warning
	do
		local hide = FindInTableIf(self.bindings, function(binding)
			local load = binding.load.combat or Addon.Condition.Utils.CreateLoadOption(true)
			return not load.selected
		end)

		if not hide then
			local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
			widget:SetText("\n" .. Addon.L["Combat state checks for this binding require additional processing when entering and leaving combat and may cause slight performance degradation."] .. "\n")
			widget:SetFullWidth(true)

			self.container:AddChild(widget)
		end
	end
end

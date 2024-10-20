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
--- @field private editbox? ClickedEditBox|ClickedAutoFillEditBox
--- @field private negated? ClickedCheckBox
local Drawer = {}

--- @protected
function Drawer:Draw()
	local drawer = self.condition.drawer --[[@as InputDrawerConfig]]

	local isAnyEnabled = FindInTableIf(self.bindings, function(binding)
		--- @type SimpleLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()
		return load.selected
	end) ~= nil

	self.checkbox = Helpers:DrawConditionToggle(self.container, self.bindings, self.fieldName, self.condition, self.requestRedraw)

	if not isAnyEnabled then
		return
	end

	-- editbox
	do
		local items = self.requestAvailableValues()

		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type SimpleLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			local spellId = tonumber(load.value)

			if items ~= nil and spellId ~= nil then
				for _, item in ipairs(items) do
					if spellId == item.spellId then
						return item.text
					end
				end
			end

			return load.value
		end

		--- @param widget ClickedEditBox
		--- @param value string
		--- @param previousValue string
		local function OnTextChanged(widget, _, value, previousValue)
			if drawer.validate ~= nil then
				widget:SetText(drawer.validate(value, previousValue, false))
			end
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
		--- @param previousValue string
		local function OnEnterPressed(_, _, value, previousValue)
			value = string.trim(value)

			if drawer.validate ~= nil then
				value = drawer.validate(value, previousValue, true)
			end

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

		local function OnSelect(_, _, value, match)
			local spellId = (match ~= nil and match.spellId ~= nil) and tostring(match.spellId) or value

			for _, binding in ipairs(self.bindings) do
				--- @type SimpleLoadOption
				local load = binding.load[self.fieldName] or self.condition.init()

				if load.selected then
					load.value = spellId
					binding.load[self.fieldName] = load
					Addon:ReloadBinding(binding, self.fieldName)
				end
			end
		end

		if items ~= nil then
			local error = FindInTableIf(self.bindings, function(binding)
				--- @type SimpleLoadOption
				local load = binding.load[self.fieldName] or self.condition.init()

				return load.selected and FindInTableIf(items, function(item)
					return item.spellId == load.value
				end) == nil
			end) == nil

			self.editbox = AceGUI:Create("ClickedAutoFillEditBox") --[[@as ClickedAutoFillEditBox]]
			self.editbox:SetInputError(error)
			self.editbox:SetValues(items)
			self.editbox:SetCallback("OnSelect", OnSelect)
		else
			self.editbox = AceGUI:Create("ClickedEditBox") --[[@as ClickedEditBox]]
		end

		self.editbox:SetCallback("OnTextChanged", OnTextChanged)
		self.editbox:SetCallback("OnEnterPressed", OnEnterPressed)
		self.editbox:SetRelativeWidth(0.5)

		Helpers:HandleWidget(self.editbox, self.bindings, ValueSelector, GetTooltipText)

		self.container:AddChild(self.editbox)
	end

	-- negate
	self.negated = Helpers:DrawNegateToggle(self.container, self.bindings, self.fieldName, self.condition, self.requestRedraw)
end

Addon.BindingConfig.BindingConditionDrawers = Addon.BindingConfig.BindingConditionDrawers or {}
Addon.BindingConfig.BindingConditionDrawers["input"] = Drawer

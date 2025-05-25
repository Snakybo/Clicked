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

--- @alias TooltipTextValue string|string[]|fun(widget: AceGUIWidget):string[]

--- @class ClickedInternal
local Addon = select(2, ...)

local MIXED_TEXT_COLOR =  BLUE_FONT_COLOR
local MAX_MIXED_VALUES_DISPLAYED = 9

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigUtil
Addon.BindingConfig.Helpers = {
	MIXED_VALUE_TEXT_COLOR = MIXED_TEXT_COLOR,
	MIXED_VALUE_TEXT = MIXED_TEXT_COLOR:WrapTextInColorCode("..."),
	IGNORE_VALUE = "\001"
}

--- Register a tooltip for a widget.
---
--- The `text` parameter can either be a string, or a function that returns one or two strings.
---
--- The `subtext` parameter is optional and only used when `text` is a string. If `text` is a function, the subtext is provided by the second return value
--- of the function.
---
--- @param widget AceGUIWidget
--- @param text TooltipTextValue
function Addon.BindingConfig.Helpers:RegisterTooltip(widget, text)
	local function OnEnter()
		--- @type string[]
		local lines

		if type(text) == "function" then
			lines = text(widget)
		elseif type(text) == "table" then
			lines = text
		else
			lines = { text }
		end

		--- @diagnostic disable-next-line: invisible
		Addon:ShowTooltip(widget.frame, lines[1], #lines > 1 and table.concat(lines, "\n", 2) or nil)
	end

	local function OnLeave()
		Addon:HideTooltip()
	end

	widget:SetCallback("OnEnter", OnEnter)
	widget:SetCallback("OnLeave", OnLeave)
end

--- Check if the given targets have mixed values, or if they are all identical.
---
--- If there are mixed values, a string is returned that contains information about the various values, for use in a tooltip. If there are no mixed values and
--- the function returns false, it will return nil as the second return value
---
--- @generic T : DataObject
--- @param targets T[]
--- @param valueSelector fun(target: T):string?
--- @return boolean hasMixedValues `true` if the targets have mixed values; `false` otherwise.
--- @return string? mixedValueText The text to display in a tooltip, if there are mixed values.
function Addon.BindingConfig.Helpers:GetMixedValues(targets, valueSelector)
	if #targets <= 1 then
		return false
	end

	--- @type { name: string, value: string }[]
	local values = {}

	for _, obj in ipairs(targets) do
		--- @type string
		local name

		if obj.type == Clicked.DataObjectType.BINDING then
			--- @cast obj Binding
			name = Addon:GetBindingNameAndIcon(obj)
		elseif obj.type == Clicked.DataObjectType.GROUP then
			--- @cast obj Group
			name = Addon:GetGroupNameAndIcon(obj)
		end

		local value = valueSelector(obj)

		if value ~= self.IGNORE_VALUE then
			table.insert(values, {
				name = name,
				value = value
			})
		end
	end

	local result = true

	for i = 2, #values do
		if values[i].value ~= values[1].value then
			result = false
			break
		end
	end

	if result then
		return false
	end

	table.sort(values, function(left, right)
		return left.name < right.name
	end)

	local lines = {}

	for i = 1, math.min(#values, MAX_MIXED_VALUES_DISPLAYED) do
		local tooltipValue = values[i].value

		if #tooltipValue > 20 then
			tooltipValue = tooltipValue:sub(1, 20) .. "..."
		end

		table.insert(lines, MIXED_TEXT_COLOR:WrapTextInColorCode(values[i].name .. ": " .. tooltipValue))
	end

	if #values > MAX_MIXED_VALUES_DISPLAYED then
		local remaining = #values - MAX_MIXED_VALUES_DISPLAYED
		table.insert(lines, MIXED_TEXT_COLOR:WrapTextInColorCode(string.format(Addon.L["+%d more"], remaining)))
	end

	return true, table.concat(lines, "\n")
end

--- @generic T : DataObject
--- @param widget AceGUIWidget
--- @param targets T[]
--- @param valueSelector fun(target: T):string?
--- @param tooltip TooltipTextValue
--- @param rawValueSelector? fun(target: T):any
--- @return boolean
--- @return fun():boolean
function Addon.BindingConfig.Helpers:HandleWidget(widget, targets, valueSelector, tooltip, rawValueSelector)
	--- @return string[]
	local function GetTooltipText()
		--- @type string[]
		local lines

		if type(tooltip) == "function" then
			lines = tooltip(widget)
		elseif type(tooltip) == "table" then
			lines = tooltip
		else
			lines = { tooltip }
		end

		local hasMixedValues, mixedValueText = self:GetMixedValues(targets, valueSelector)

		if hasMixedValues then
			table.insert(lines, "")
			table.insert(lines, mixedValueText)
		end

		return lines
	end

	--- @return any
	local function GetRawValue()
		for _, obj in ipairs(targets) do
			if rawValueSelector ~= nil then
				local result = rawValueSelector(obj)
				if result ~= self.IGNORE_VALUE then
					return result
				end
			end

			local result = valueSelector(obj)
			if result ~= self.IGNORE_VALUE then
				return result
			end
		end

		return nil
	end

	--- @return boolean
	local function UpdateCallback()
		local hasMixedValues = self:GetMixedValues(targets, valueSelector)
		local label = GetTooltipText()[1]

		if widget.type == "ClickedCheckBox" then
			--- @cast widget ClickedCheckBox|ClickedToggleHeading

			widget:SetLabel(label)

			if hasMixedValues then
				widget:SetValue(false)
				widget:SetLabelColor(self.MIXED_VALUE_TEXT_COLOR)
			else
				widget:SetValue(GetRawValue())
				widget:SetLabelColor(WHITE_FONT_COLOR)
			end
		elseif widget.type == "ClickedAutoFillEditBox" or widget.type == "ClickedEditBox" or widget.type == "ClickedMultiLineEditBox" then
			--- @cast widget ClickedAutoFillEditBox|ClickedEditBox

			widget:SetLabel(label)

			if hasMixedValues then
				widget:SetText("")
				widget:SetLabelColor(self.MIXED_VALUE_TEXT_COLOR)
			else
				widget:SetText(GetRawValue())
				widget:SetLabelColor(NORMAL_FONT_COLOR)
			end
		elseif widget.type == "ClickedKeybinding" then
			--- @cast widget ClickedKeybinding

			if hasMixedValues then
				widget:SetKey(self.MIXED_VALUE_TEXT)
			else
				widget:SetKey(valueSelector(targets[1]) --[[@as string]])
			end
		elseif widget.type == "ClickedDropdown" then
			--- @cast widget ClickedDropdown

			widget:SetLabel(label)

			if hasMixedValues then
				widget:SetValue("")
				widget:SetLabelColor(self.MIXED_VALUE_TEXT_COLOR)
			else
				local value = GetRawValue()

				-- assume it's an array if `[1]` is not nil
				if widget:GetMultiselect() and value[1] ~= nil then
					--- @diagnostic disable-next-line: undefined-field
					for _, item in widget.pullout:IterateItems() do
						local id = item.userdata.value

						--- @diagnostic disable-next-line: param-type-mismatch
						widget:SetItemValue(id, tContains(value, id))
					end
				else
					widget:SetValue(GetRawValue())
					widget:SetLabelColor(NORMAL_FONT_COLOR)
				end
			end
		elseif widget.type == "ClickedToggleHeading" then
			--- @cast widget ClickedToggleHeading

			widget:SetText(label)

			if hasMixedValues then
				widget:SetValue(false)
				widget:SetLabelColor(self.MIXED_VALUE_TEXT_COLOR)
			else
				widget:SetValue(GetRawValue())
				widget:SetLabelColor(NORMAL_FONT_COLOR)
			end
		end

		return hasMixedValues
	end

	self:RegisterTooltip(widget, GetTooltipText)

	return UpdateCallback(), UpdateCallback
end

--- @param container AceGUIContainer
--- @param bindings Binding[]
--- @param fieldName string
--- @param condition Condition
--- @param onValueChanged fun()
--- @return ClickedCheckBox
function Addon.BindingConfig.Helpers:DrawConditionToggle(container, bindings, fieldName, condition, onValueChanged)
	--- @type boolean
	local hasMixedValues

	--- @param binding Binding
	--- @return string
	local function ValueSelector(binding)
		--- @type SimpleLoadOption
		local load = binding.load[fieldName] or condition.init()
		return load.selected and Addon.L["Enabled"] or Addon.L["Disabled"]
	end

	--- @param binding Binding
	--- @return boolean?
	local function GetEnabledState(binding)
		--- @type SimpleLoadOption
		local load = binding.load[fieldName] or condition.init()
		return load.selected
	end

	--- @return string[]
	local function GetTooltipText()
		if hasMixedValues then
			return { Addon.L[condition.drawer.label] }
		end

		local options = {
			["false"] = Addon.L["Off"],
			["true"] = Addon.L["On"]
		}

		local order = { "false", "true" }

		local selectedStr = tostring(GetEnabledState(bindings[1]))
		options[selectedStr] = "|cff00ff00" .. options[selectedStr] .. "|r"

		local result = ""

		for _, v in ipairs(order) do
			if not Addon:IsNilOrEmpty(result) then
				result = result .. " - "
			end

			result = result .. options[v]
		end

		return { Addon.L[condition.drawer.label], result }
	end

	--- @param value boolean|nil
	local function OnValueChanged(_, _, value)
		--- @cast value boolean

		for _, binding in ipairs(bindings) do
			--- @type SimpleLoadOption
			local load = binding.load[fieldName] or condition.init()
			load.selected = value
			binding.load[fieldName] = load
			Addon:ReloadBinding(binding, fieldName)
		end

		onValueChanged()
	end

	local checkbox = AceGUI:Create("ClickedCheckBox") --[[@as ClickedCheckBox]]
	checkbox:SetType("checkbox")
	checkbox:SetCallback("OnValueChanged", OnValueChanged)

	local isAnyEnabled = FindInTableIf(bindings, function(binding)
		--- @type SimpleLoadOption
		local load = binding.load[fieldName] or condition.init()
		return load.selected
	end) ~= nil

	if isAnyEnabled then
		checkbox:SetRelativeWidth(0.5)
	else
		checkbox:SetFullWidth(true)
	end

	hasMixedValues = self:HandleWidget(checkbox, bindings, ValueSelector, GetTooltipText, GetEnabledState)
	container:AddChild(checkbox)
	return checkbox
end

--- @param container AceGUIContainer
--- @param bindings Binding[]
--- @param fieldName string
--- @param condition Condition
--- @param onValueChanged fun()
--- @return ClickedCheckBox?
function Addon.BindingConfig.Helpers:DrawNegateToggle(container, bindings, fieldName, condition, onValueChanged)
	if not condition.drawer.negatable then
		return nil
	end

	do
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetRelativeWidth(0.5)
		container:AddChild(widget)
	end

	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type NegatableLoadOption
			local load = binding.load[fieldName] or condition.init()
			return load.negated and Addon.L["Inverted"] or Addon.L["Not inverted"]
		end

		local function GetEnabledState(binding)
			--- @type NegatableLoadOption
			local load = binding.load[fieldName] or condition.init()
			return load.negated and true or false
		end

		--- @param value boolean
		local function OnValueChanged(_, _, value)
			for _, binding in ipairs(bindings) do
				--- @type NegatableLoadOption
				local load = binding.load[fieldName] or condition.init()

				if load.selected then
					-- TODO: Set this to nil if false
					load.negated = value
					binding.load[fieldName] = load
					Addon:ReloadBinding(binding, fieldName)
				end
			end

			onValueChanged()
		end

		local negated = AceGUI:Create("ClickedCheckBox") --[[@as ClickedCheckBox]]
		negated:SetCallback("OnValueChanged", OnValueChanged)
		negated:SetRelativeWidth(0.5)

		self:HandleWidget(negated, bindings, ValueSelector, Addon.L["Invert"], GetEnabledState)

		container:AddChild(negated)
		return negated
	end
end

--- @param container AceGUIContainer
--- @param bindings Binding[]
--- @param fieldName string
--- @param condition Condition
--- @param onValueChanged fun()
--- @return ClickedCheckBox
function Addon.BindingConfig.Helpers:DrawMultiselectConditionToggle(container, bindings, fieldName, condition, onValueChanged)
	--- @type boolean
	local hasMixedValues

	--- @param state `0`|`1`|`2`
	--- @return boolean?
	local function IndexToValue(state)
		if state == 1 then
			return true
		elseif state == 2 then
			return nil
		end

		return false
	end

	--- @param value? boolean
	--- @return `0`|`1`|`2`
	local function ValueToIndex(value)
		if value == false then
			return 0
		elseif value == true then
			return 1
		else
			return 2
		end
	end

	--- @param binding Binding
	--- @return string
	local function ValueSelector(binding)
		--- @type MultiselectLoadOption
		local load = binding.load[fieldName] or condition.init()

		if load.selected == 0 then
			return Addon.L["Disabled"]
		elseif load.selected == 1 then
			return Addon.L["Single"]
		else
			return Addon.L["Multiple"]
		end
	end

	--- @param binding Binding
	--- @return boolean?
	local function GetEnabledState(binding)
		--- @type MultiselectLoadOption
		local load = binding.load[fieldName] or condition.init()
		return IndexToValue(load.selected)
	end

	--- @return string[]
	local function GetTooltipText()
		if hasMixedValues then
			return { Addon.L[condition.drawer.label] }
		end

		local options = {
			["0"] = Addon.L["Off"],
			["1"] = Addon.L["Single"],
			["2"] = Addon.L["Multiple"]
		}

		local order = { "0", "1", "2" }

		local selectedStr = tostring(bindings[1].load[fieldName].selected)
		options[selectedStr] = "|cff00ff00" .. options[selectedStr] .. "|r"

		local result = ""

		for _, v in ipairs(order) do
			if not Addon:IsNilOrEmpty(result) then
				result = result .. " - "
			end

			result = result .. options[v]
		end

		return { Addon.L[condition.drawer.label], result }
	end

	--- @param value boolean|nil
	local function OnValueChanged(_, _, value)
		local index = ValueToIndex(value)

		for _, binding in ipairs(bindings) do
			--- @type MultiselectLoadOption
			local load = binding.load[fieldName] or condition.init()
			load.selected = index
			binding.load[fieldName] = load
			Addon:ReloadBinding(binding, fieldName)
		end

		onValueChanged()
	end

	local checkbox = AceGUI:Create("ClickedCheckBox") --[[@as ClickedCheckBox]]
	checkbox:SetType("checkbox")
	checkbox:SetCallback("OnValueChanged", OnValueChanged)
	checkbox:SetTriState(true)

	local isAnyEnabled = FindInTableIf(bindings, function(binding)
		--- @type MultiselectLoadOption
		local load = binding.load[fieldName] or condition.init()
		return load.selected > 0
	end) ~= nil

	if isAnyEnabled then
		checkbox:SetRelativeWidth(0.5)
	else
		checkbox:SetFullWidth(true)
	end

	hasMixedValues = self:HandleWidget(checkbox, bindings, ValueSelector, GetTooltipText, GetEnabledState)
	container:AddChild(checkbox)
	return checkbox
end

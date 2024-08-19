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

--- @class ClickedInternal
local Addon = select(2, ...)

Addon.BindingConfig = Addon.BindingConfig or {}

local MIXED_TEXT_COLOR =  BLUE_FONT_COLOR
local MAX_MIXED_VALUES_DISPLAYED = 9

-- Private addon API

--- @class BindingConfigUtil
Addon.BindingConfig.Helpers = {
	MIXED_VALUE_TEXT_COLOR = MIXED_TEXT_COLOR,
	MIXED_VALUE_TEXT = MIXED_TEXT_COLOR:WrapTextInColorCode("...")
}

--- Register a tooltip for a widget.
---
--- The `text` parameter can either be a string, or a function that returns one or two strings.
---
--- The `subtext` parameter is optional and only used when `text` is a string. If `text` is a function, the subtext is provided by the second return value
--- of the function.
---
--- @param widget AceGUIWidget
--- @param text fun(widget: AceGUIWidget):string, string?|string
--- @param subtext string?
function Addon.BindingConfig.Helpers:RegisterTooltip(widget, text, subtext)
	--- @type (fun(widget: AceGUIWidget):string, string?)?
	local callback = type(text) == "function" and text or nil

	local function OnEnter()
		if callback ~= nil then
			text, subtext = callback(widget)
		end

		--- @cast text string
		--- @diagnostic disable-next-line: invisible
		Addon:ShowTooltip(widget.frame, text, subtext)
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
--- @param valueSelector fun(target: T):string
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

		table.insert(values, {
			name = name,
			value = valueSelector(obj)
		})
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
		table.insert(lines, MIXED_TEXT_COLOR:WrapTextInColorCode(values[i].name .. ": " .. values[i].value))
	end

	if #values > MAX_MIXED_VALUES_DISPLAYED then
		local remaining = #values - MAX_MIXED_VALUES_DISPLAYED
		table.insert(lines, MIXED_TEXT_COLOR:WrapTextInColorCode(string.format(Addon.L["+%d more"], remaining)))
	end

	return true, table.concat(lines, "\n")
end

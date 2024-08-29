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

--- @class SimpleLoadOption
--- @field public selected boolean
--- @field public value any
--- @field public negated? boolean

--- @class MultiselectLoadOption
--- @field public selected `0`|`1`|`2`
--- @field public single any
--- @field public multiple any[]
--- @field public negated? boolean

--- @class TalentLoadOption
--- @field public selected boolean
--- @field public entries { operation: "AND"|"OR", negated?: boolean, value: any }[]

--- @class ClickedInternal
local Addon = select(2, ...)

-- Private addon API

Addon.Condition = Addon.Condition or {}

--- @class ConditionUtilities
Addon.Condition.Utils = {}

--- @alias NegatableLoadOption SimpleLoadOption|MultiselectLoadOption

--- @param default any
--- @return SimpleLoadOption
function Addon.Condition.Utils.CreateLoadOption(default)
	--- @type SimpleLoadOption
	return {
		selected = false,
		value = default
	}
end

--- @param default any
--- @return MultiselectLoadOption
function Addon.Condition.Utils.CreateMultiselectLoadOption(default)
	--- @type MultiselectLoadOption
	return {
		selected = 0,
		single = default,
		multiple = {
			default
		}
	}
end

--- @param default any
--- @return TalentLoadOption
function Addon.Condition.Utils.CreateTalentLoadOption(default)
	--- @type TalentLoadOption
	return {
		selected = false,
		entries = {
			{
				operation = "AND",
				value = default
			}
		}
	}
end

--- @param option SimpleLoadOption
--- @return any?
function Addon.Condition.Utils.UnpackSimpleLoadOption(option)
	if option.selected then
		return option.value
	end
end

--- @param option MultiselectLoadOption
--- @return any[]?
function Addon.Condition.Utils.UnpackMultiselectLoadOption(option)
	if option.selected == 1 then
		return { option.single }
	elseif option.selected == 2 then
		return option.multiple
	end
end

--- @param option TalentLoadOption
--- @return any[][]?
function Addon.Condition.Utils.UnpackTalentLoadOption(option)
	if option.selected then
		--- @type any[]
		local result = {}

		--- @type any
		local current = {}
		table.insert(result, current)

		for _, entry in ipairs(option.entries) do
			if entry.operation == "OR" and #current > 0 then
				current = {}
				table.insert(result, current)
			end

			table.insert(current, entry.value)
		end

		return result
	end
end

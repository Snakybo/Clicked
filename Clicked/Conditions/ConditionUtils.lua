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
--- @field public entries TalentLoadOptionEntry[]

--- @class TalentLoadOptionEntry
--- @field public operation "AND"|"OR"
--- @field public negated? boolean
--- @field public value any

local LibTalentInfo = LibStub("LibTalentInfo-1.0")

-- Deprecated in 5.5.0
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization

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

	return nil
end

--- @param option MultiselectLoadOption
--- @return any[]?
function Addon.Condition.Utils.UnpackMultiselectLoadOption(option)
	if option.selected == 1 then
		return { option.single }
	elseif option.selected == 2 then
		return option.multiple
	end

	return nil
end

--- @param option TalentLoadOption
--- @return TalentLoadOptionEntry[][]?
function Addon.Condition.Utils.UnpackTalentLoadOption(option)
	if option.selected then
		--- @type TalentLoadOptionEntry[][]
		local result = {}

		--- @type TalentLoadOptionEntry[]
		local current = {}
		table.insert(result, current)

		for _, entry in ipairs(option.entries) do
			if entry.operation == "OR" and #current > 0 then
				current = {}
				table.insert(result, current)
			end

			table.insert(current, entry)
		end

		return result
	end

	return nil
end

--- @param classNames string[]
--- @return string[]
function Addon.Condition.Utils.GetRelevantClasses(classNames)
	local result = CopyTable(classNames)

	if #classNames == 0 then
		local classFileName = select(2, UnitClass("player"))
		table.insert(result, classFileName)
	end

	return result
end

--- @param classNames string[]
--- @param specIndices integer[]
--- @return integer[]
function Addon.Condition.Utils.GetRelevantSpecializationIds(classNames, specIndices)
	local result = {}

	if #classNames == 0 then
		classNames[1] = select(2, UnitClass("player"))
	end

	if #specIndices == 0 then
		if #classNames == 1 and classNames[1] == select(2, UnitClass("player")) then
			if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
				specIndices[1] = GetSpecialization()
			else
				specIndices[1] = GetPrimaryTalentTree()
			end
		else
			for _, class in ipairs(classNames) do
				local specs = LibTalentInfo:GetSpecializations(class)

				for specIndex in ipairs(specs) do
					table.insert(specIndices, specIndex)
				end
			end
		end
	end

	for i = 1, #classNames do
		local specs = LibTalentInfo:GetSpecializations(classNames[i])

		for j = 1, #specIndices do
			local specIndex = specIndices[j]

			table.insert(result, specs[specIndex].id)
		end
	end

	return result
end

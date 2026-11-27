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

local LibTalentTome = LibStub("LibTalentTome")

--- @class Addon
local Addon = select(2, ...)

-- Private addon API

Addon.Condition = Addon.Condition or {}

--- @class ConditionUtilities
Addon.Condition.Utils = {}

--- @param flags LoadConditionStates|LoadCondition?
--- @param flag LoadConditionStates
--- @return boolean
local function HasFlag(flags, flag)
	if flags == nil then
		return false
	end

	if type(flags) == "table" then
		flags = flags.state or 0
	end

	return bit.band(flags, flag) > 0
end

--- @param option LoadCondition
--- @param flag LoadConditionStates
--- @param enabled boolean
function Addon.Condition.Utils.SetFlag(option, flag, enabled)
	if enabled then
		option.state = bit.bor(option.state or 0, flag)
	else
		option.state = bit.band(option.state or 0, bit.bnot(flag))
	end
end

--- @param flags LoadConditionStates|LoadCondition?
--- @return boolean
function Addon.Condition.Utils.HasEnabledFlag(flags)
	return HasFlag(flags, Clicked.LoadConditionStates.ENABLED)
end

--- @param flags LoadConditionStates|LoadCondition?
--- @return boolean
function Addon.Condition.Utils.HasNegatedFlag(flags)
	return HasFlag(flags, Clicked.LoadConditionStates.NEGATED)
end

--- Get the selected values of a load condition as a list, regardless of whether it is enabled.
---
--- @generic T
--- @param option LoadCondition<T>
--- @return T[]
function Addon.Condition.Utils.UnpackLoadOption(option)
	assert(option ~= nil, "bad argument #1, expected LoadCondition but got nil")

	local values = option.value

	if values == nil then
		return {}
	elseif type(values) == "table" then
		return CopyTable(values)
	end

	return { values }
end

--- Store a list of values in the `value` field of a load condition. A list containing a single non-table value is stored as that value.
---
--- @generic T
--- @param option LoadCondition<T>
--- @param values T[]
function Addon.Condition.Utils.SetLoadOptionValues(option, values)
	if #values == 1 and type(values[1]) ~= "table" then
		option.value = values[1]
	else
		option.value = values
	end
end

--- Get the effective value of a boolean condition, taking negation into account. Returns `nil` if the condition is not enabled.
---
--- @param option? LoadCondition<boolean>
--- @return boolean?
function Addon.Condition.Utils.GetBooleanValue(option)
	if not Addon.Condition.Utils.HasEnabledFlag(option) then
		return nil
	end

	--- @cast option LoadCondition<boolean>
	local value = Addon.Condition.Utils.UnpackLoadOption(option)[1] ~= false
	return value ~= Addon.Condition.Utils.HasNegatedFlag(option)
end

--- @generic T
--- @param condition Condition<T>
--- @return T
function Addon.Condition.Utils.GetDefaultValue(condition)
	if type(condition.init) == "function" then
		return condition.init()
	end

	return condition.init
end

--- Create a new, disabled, load condition with the default value of the specified condition.
---
--- @generic T
--- @param condition Condition<T>
--- @return LoadCondition<T>
function Addon.Condition.Utils.CreateLoadCondition(condition)
	return Clicked:CreateLoadCondition(Addon.Condition.Utils.GetDefaultValue(condition))
end

--- Get the stored load condition of a binding. If the binding does not have a value for this condition, a new default value is returned, which is not stored
--- in the binding. Use `SetLoadCondition` to store it.
---
--- @generic T
--- @param binding Binding
--- @param condition Condition<T>
--- @return LoadCondition<T>
function Addon.Condition.Utils.GetLoadCondition(binding, condition)
	--- @type table<string, LoadCondition>?
	local storage

	if condition.storage == "conditionals" then
		storage = binding.conditionals --[[@as table<string, LoadCondition>?]]
	else
		storage = binding.load --[[@as table<string, LoadCondition>?]]
	end

	--- @type LoadCondition?
	local result = storage ~= nil and storage[condition.id] or nil

	if result == nil then
		return Addon.Condition.Utils.CreateLoadCondition(condition)
	end

	return result
end

--- @generic T
--- @param binding Binding
--- @param condition Condition<T>
--- @param option LoadCondition<T>
function Addon.Condition.Utils.SetLoadCondition(binding, condition, option)
	if condition.storage == "conditionals" then
		binding.conditionals = binding.conditionals or {}
		binding.conditionals[condition.id] = option
	else
		binding.load = binding.load or {}
		binding.load[condition.id] = option
	end
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
			if Addon.EXPANSION_LEVEL < Addon.Expansion.MOP then
				local numSpecs = LibTalentTome:GetNumSpecializations(classNames[1])

				for i = 1, numSpecs do
					specIndices[i] = i
				end
			else
				specIndices[1] = C_SpecializationInfo.GetSpecialization()
			end
		else
			for i = 1, #classNames do
				local numSpecs = LibTalentTome:GetNumSpecializations(classNames[i])

				for j = 1, numSpecs do
					specIndices[j] = j
				end
			end
		end
	end

	for i = 1, #classNames do
		for j = 1, #specIndices do
			local spec = LibTalentTome:GetSpecializationAt(classNames[i], specIndices[j])

			if spec ~= nil and not spec.initial then
				table.insert(result, spec.id)
			end
		end
	end

	return result
end

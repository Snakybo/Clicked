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

Addon.Condition = Addon.Condition or {}

--- @class DrawerConfig
--- @field public type string
--- @field public label string
--- @field public availableValues? fun(...):...

--- @class InputDrawerConfig : DrawerConfig
--- @field public negatable? boolean
--- @field public validate? fun(value: string):string?

--- @class Condition
--- @field public id string
--- @field public init fun():any
--- @field public drawer DrawerConfig
--- @field public dependencies? string[]
--- @field public disabled? boolean|fun():boolean
--- @field public unpack fun(option: any):any?

--- @class RuntimeConditionSet
--- @field public config Condition[]
--- @field public map table<string, Condition>
--- @field public dependencyGraph table<string, string[]>

do
	--- @type table<string, RuntimeConditionSet>
	local registry = {}

	--- @param config Condition[]
	--- @return table<string, string[]>
	local function BuildDependencyGraph(config)
		--- @type { [string]: string[] }
		local result = {}

		for _, condition in ipairs(config) do
			--- @type string[]
			local dependencies = {}

			for _, other in ipairs(config) do
				if other.dependencies ~= nil and tContains(other.dependencies, condition.id) then
					table.insert(dependencies, other.id)
				end
			end

			result[condition.id] = dependencies
		end

		return result
	end

	--- @class ConditionRegistry
	Addon.Condition.Registry = {}

	--- @param id string
	--- @param config Condition[]
	function Addon.Condition.Registry:RegisterConditionConfig(id, config)
		local map = {}

		for _, condition in ipairs(config) do
			map[condition.id] = condition
		end

		registry[id] = {
			config = config,
			map = map,
			dependencyGraph = BuildDependencyGraph(config)
		}
	end

	--- @param id string
	--- @return RuntimeConditionSet
	function Addon.Condition.Registry:GetConditionSet(id)
		local result = registry[id]
		assert(result, "Condition set with ID " .. id .. " does not exist")
		return result
	end

	--- @return RuntimeConditionSet[]
	function Addon.Condition.Registry:GetConditionSets()
		--- @type RuntimeConditionSet[]
		local result = {}

		for _, set in pairs(registry) do
			table.insert(result, set)
		end

		return result
	end
end

do
	--- @class ConditionUtilities
	Addon.Condition.Utilities = {}

	--- @param default any
	--- @return SimpleLoadOption
	function Addon.Condition.Utilities.CreateLoadOption(default)
		--- @class SimpleLoadOption
		--- @field public selected boolean
		--- @field public value any
		--- @field public negated? boolean
		return {
			selected = false,
			value = default
		}
	end

	--- @param default any
	--- @return MultiselectLoadOption
	function Addon.Condition.Utilities.CreateMultiselectLoadOption(default)
		--- @class MultiselectLoadOption
		--- @field public selected `0`|`1`|`2`
		--- @field public single any
		--- @field public multiple any[]
		return {
			selected = 0,
			single = default,
			multiple = {
				default
			}
		}
	end

	function Addon.Condition.Utilities.CreateTalentLoadOption(default)
		--- @class TalentLoadOption
		--- @field public selected boolean
		--- @field public entries { operation: "AND"|"OR", negated?: boolean, value: any }[]
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
	function Addon.Condition.Utilities.UnpackSimpleLoadOption(option)
		if option.selected then
			return option.value
		end
	end

	--- @param option MultiselectLoadOption
	--- @return any[]?
	function Addon.Condition.Utilities.UnpackMultiselectLoadOption(option)
		if option.selected == 1 then
			return { option.single }
		elseif option.selected == 2 then
			return option.multiple
		end
	end

	--- @param option TalentLoadOption
	--- @return any[][]?
	function Addon.Condition.Utilities.UnpackTalentLoadOption(option)
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
end

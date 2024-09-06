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

--- @class DrawerConfig
--- @field public type string
--- @field public label string
--- @field public tooltip? string|string[]
--- @field public negatable? boolean
--- @field public availableValues? fun(...):...

--- @class InputDrawerConfig : DrawerConfig
--- @field public validate? fun(previousValue: string, value: string, final: boolean):string

--- @class Condition
--- @field public id string
--- @field public init fun():any
--- @field public drawer DrawerConfig
--- @field public dependencies? string[]
--- @field public disabled? boolean|fun():boolean
--- @field public unpack fun(option: any):any?

--- @class LoadCondition : Condition
--- @field public testOnEvents? string[]
--- @field public test fun(value: any):boolean

--- @class RuntimeConditionSet
--- @field public config Condition[]
--- @field public map table<string, Condition>
--- @field public dependencyGraph table<string, string[]>

--- @class ClickedInternal
local Addon = select(2, ...)

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

-- Private addon API

Addon.Condition = Addon.Condition or {}

--- @class ConditionRegistry
--- @field private registry table<string, RuntimeConditionSet>
Addon.Condition.Registry = {
	registry = {}
}

--- @param id string
--- @param config Condition[]
function Addon.Condition.Registry:RegisterConditionConfig(id, config)
	local enabled = {}
	local map = {}

	for _, condition in ipairs(config) do
		if not condition.disabled then
			table.insert(enabled, condition)
			map[condition.id] = condition
		end
	end

	self.registry[id] = {
		config = enabled,
		map = map,
		dependencyGraph = BuildDependencyGraph(enabled)
	}
end

--- @param id string
--- @return RuntimeConditionSet
function Addon.Condition.Registry:GetConditionSet(id)
	local result = self.registry[id]
	assert(result, "Condition set with ID " .. id .. " does not exist")
	return result
end

--- @return RuntimeConditionSet[]
function Addon.Condition.Registry:GetConditionSets()
	--- @type RuntimeConditionSet[]
	local result = {}

	for _, set in pairs(self.registry) do
		table.insert(result, set)
	end

	return result
end

--- @param id string
--- @return Condition?
function Addon.Condition.Registry:GetConditionById(id)
	for _, set in pairs(self.registry) do
		local condition = set.map[id]

		if condition ~= nil then
			return condition
		end
	end

	return nil
end

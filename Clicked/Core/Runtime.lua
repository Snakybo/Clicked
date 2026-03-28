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

--- @class Addon
local Addon = select(2, ...)

--- @type Keybind2[]
local registry = {}

--- @param type ActionType2
--- @return Keybind2
function Clicked2:CreateKeybind(type)
	--- @type Keybind2
	local result = {
		uid = self:GetNextUid(),
		priority = 0,
		key = "",
		type = type,
		sets = {}
	}

	table.insert(registry, result)

	self:SendMessage("CLICKED_KEYBIND_CREATED", result)
	return result
end

--- @param type string
--- @return ActionSet
function Clicked2:CreateActionSet(type)
	--- @type ActionSet
	local result = {
		type = type,
		actions = {}
	}

	self:SendMessage("CLICKED_ACTION_SET_CREATED", result)
	return result
end

--- @generic T : Action2
--- @param prototype T
--- @return T
function Clicked2:CreateAction(prototype)
	--- @type Action2
	local base = {
		flags = 0,
		load = {}
	}

	local result = Mixin(base, prototype)

	self:SendMessage("CLICKED_ACTION_CREATED", result)
	return result
end

--- @param keybind integer|Keybind2
--- @return Keybind2
function Clicked2:CloneKeybind(keybind)
	if type(keybind) == "integer" then
		for _, other in ipairs(registry) do
			if other.uid == keybind then
				keybind = other
				break
			end
		end
	end

	local result = CopyTable(keybind) --[[@as Keybind2]]
	result.uid = self:GetNextUid()

	table.insert(registry, result)

	self:SendMessage("CLICKED_KEYBIND_CREATED", result)
	return result
end

--- @param set ActionSet
--- @return ActionSet
function Clicked2:CloneActionSet(set)
	local result = CopyTable(set) --[[@as ActionSet]]

	self:SendMessage("CLICKED_ACTION_SET_CREATED", result)
	return result
end

--- @generic T : Action2
--- @param action T
--- @return T
function Clicked2:CloneAction(action)
	local result = CopyTable(action) --[[@as Action2]]

	self:SendMessage("CLICKED_ACTION_CREATED", result)
	return result
end

--- @param uid integer|Keybind2
--- @return boolean
function Clicked2:DeleteKeybind(uid)
	if type(uid) == "table" then
		uid = uid.uid
	end

	for i, keybind in ipairs(registry) do
		if keybind.uid == uid then
			table.remove(registry, i)
			self:SendMessage("CLICKED_KEYBIND_DELETED", uid)
			return true
		end
	end

	return false
end

---@generic T : table, V
---@return fun(table: V[], i?: integer): integer, V
---@return T
---@return integer i
function Clicked2:IterateRegistry()
	return ipairs(registry)
end

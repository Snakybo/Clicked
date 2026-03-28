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

--- @class ActionSets : ClickedModule, AceEvent-3.0
--- @field private uidIndex table<integer, ActionSet>
local Prototype = {
	uidIndex = {}
}

--- @protected
function Prototype:OnInitialize()
	self:RegisterMessage("CLICKED_DB_RELOADED", self.CLICKED_DB_RELOADED, self)
end

--- @param type string
--- @param parent Keybind2
--- @return ActionSet
function Prototype:Create(type, parent)
	Addon.Datastore:Load()

	--- @type ActionSet
	local result = {
		parent = parent,
		uid = Clicked2:GetNextUid(),
		type = type,
		actions = {}
	}

	table.insert(parent.sets, result)
	self.uidIndex[result.uid] = result

	self:SendMessage("CLICKED_ACTION_SET_CREATED", result)
	self:LogDebug("Created {type} action set with parent ID {parentUid}", type, parent.uid)

	return result
end

--- @param set integer|ActionSet
--- @param parent? Keybind2
--- @return ActionSet
function Prototype:Clone(set, parent)
	set = type(set) == "number" and self:GetById(set) or set

	if set == nil then
		return self:LogFatal("Attempted to clone non-existent action set")
	end

	Addon.Datastore:Load()

	local originalParent = set.parent
	local originalActions = set.actions

	set.parent = nil
	set.actions = {}

	local success, result = pcall(function()
		local result = CopyTable(set) --[[@as ActionSet]]
		result.parent = parent or originalParent
		result.uid = Clicked2:GetNextUid()

		for i = 1, #originalActions do
			Addon.Actions:Clone(originalActions[i], result)
		end

		table.insert(result.parent.sets, result)
		self.uidIndex[result.uid] = result

		self:SendMessage("CLICKED_ACTION_SET_CREATED", result)
		return result
	end)

	set.parent = originalParent
	set.actions = originalActions

	if not success then
		error(result)
	end

	return result
end

--- @param set integer|ActionSet
--- @param parent Keybind2
--- @param position? integer
function Prototype:Move(set, parent, position)
	set = type(set) == "number" and self:GetById(set) or set

	if set == nil then
		return
	end

	Addon.Datastore:Load()

	Addon.TableRemoveItem(set.parent.sets, set)
	set.parent = parent
	table.insert(parent.sets, position, set)

	self:SendMessage("CLICKED_ACTION_SET_MOVED", set)
end

--- @param set integer|ActionSet
function Prototype:Delete(set)
	set = type(set) == "number" and self:GetById(set) or set

	if set == nil then
		return false
	end

	Addon.Datastore:Load()

	for i = #set.actions, 1, -1 do
		Addon.Actions:Delete(set.actions[i])
	end

	Addon.TableRemoveItem(set.parent.sets, set)
	self.uidIndex[set.uid] = nil

	self:SendMessage("CLICKED_ACTION_SET_DELETED", set.uid)
	return true
end

--- @param uid? integer
--- @return ActionSet?
function Prototype:GetById(uid)
	if uid == nil then
		return nil
	end

	Addon.Datastore:Load()
	return self.uidIndex[uid]
end

--- @private
--- @param db DBSchema
function Prototype:CLICKED_DB_RELOADED(db)
	table.wipe(self.uidIndex)

	--- @param keybind Keybind2
	local function Add(keybind)
		for _, set in pairs(keybind.sets) do
			self.uidIndex[set.uid] = set
		end
	end

	for _, keybind in pairs(db.profile.keybinds) do
		Add(keybind)
	end

	for _, keybind in pairs(db.global.keybinds) do
		Add(keybind)
	end
end

--- @type ActionSets
Addon.ActionSets = Clicked2:NewModule("ActionSets", Prototype, "AceEvent-3.0")

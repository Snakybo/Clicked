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

--- @enum UnitFlags
Clicked2.UnitFlags = {
	ALIVE = 1,
	DEAD = 2,
	FRIEND = 4,
	HOSTILE = 8
}

--- @enum LoadConditionFlags
Clicked2.LoadConditionFlags = {
	ENABLED = 1,
	NEGATED = 2,
	MULTI = 4
}

--- @class Actions : ClickedModule, AceEvent-3.0
--- @field private uidIndex table<integer, Action2>
local Prototype =  {
	uidIndex = {}
}

--- @protected
function Prototype:OnInitialize()
	self:RegisterMessage("CLICKED_DB_RELOADED", self.CLICKED_DB_RELOADED, self)
end

--- @generic T : Action2
--- @param factory ActionHandler|string
--- @param parent ActionSet
--- @return T
--- @overload fun(self: Actions, parent: ActionSet): T
function Prototype:Create(factory, parent)
	Addon.Datastore:Load()

	if parent == nil and type(factory) == "table" then
		parent = factory --[[@as ActionSet]]
		factory = parent.type
	end

	--- @type Action2
	local result = {
		parent = parent,
		uid = Clicked2:GetNextUid(),
		flags = 0,
		load = {},
		conditionals = {}
	}

	if type(factory) == "string" then
		factory = Clicked2.ActionLibrary:Get(factory)
	end

	if factory == nil then
		return self:LogFatal("Attempted to create action with unknown prototype {prototype}", factory)
	end

	result = factory.Create(result)

	table.insert(parent.actions, result)
	self.uidIndex[result.uid] = result

	self:SendMessage("CLICKED_ACTION_CREATED", result)
	self:LogDebug("Created action with ID {uid} and parent ID {parentUid}", result.uid, parent.parent.uid)

	return result
end

--- @generic T : Action2
--- @param action T
--- @param parent? ActionSet
--- @return T
function Prototype:Clone(action, parent)
	action = type(action) == "number" and self:GetById(action) or action

	if action == nil then
		return self:LogFatal("Attempted to clone non-existent action")
	end

	Addon.Datastore:Load()

	local originalParent = action.parent
	local originalLoad = action.load
	local originalConditionals = action.conditionals

	action.parent = nil
	action.load = {}
	action.conditionals = {}

	local success, result = pcall(function()
		local result = CopyTable(action) --[[@as Action2]]
		result.parent = parent or originalParent
		result.uid = Clicked2:GetNextUid()

		for k, v in pairs(originalLoad) do
			if Prototype.HasLoadConditionEnabledFlag(v.state) then
				result.load[k] = CopyTable(v)
			end
		end

		for k, v in pairs(originalConditionals) do
			if Prototype.HasLoadConditionEnabledFlag(v.state) then
				result.conditionals[k] = CopyTable(v)
			end
		end

		table.insert(result.parent.actions, result)
		self.uidIndex[result.uid] = result

		self:SendMessage("CLICKED_ACTION_CREATED", result)
		return result
	end)

	action.parent = originalParent
	action.load = originalLoad
	action.conditionals = originalConditionals

	if not success then
		error(result)
	end

	return result
end

--- @param action integer|Action2
--- @param parent ActionSet
--- @param position? integer
function Prototype:Move(action, parent, position)
	action = type(action) == "number" and self:GetById(action) or action

	if action == nil then
		return
	end

	Addon.Datastore:Load()

	Addon.TableRemoveItem(action.parent.actions, action)
	action.parent = parent
	table.insert(parent.actions, position, action)

	self:SendMessage("CLICKED_ACTION_MOVED", action)
end

--- @param action integer|Action2
--- @return boolean
function Prototype:Delete(action)
	action = type(action) == "number" and self:GetById(action) or action

	if action == nil then
		return false
	end

	Addon.Datastore:Load()

	Addon.TableRemoveItem(action.parent.actions, action)
	self.uidIndex[action.uid] = nil

	self:SendMessage("CLICKED_ACTION_DELETED", action.uid)
	return true
end

--- @param action integer|Action2
--- @param update ActionUpdate
function Prototype:Update(action, update)
	action = type(action) == "number" and self:GetById(action) or action

	if action == nil then
		return
	end

	Addon.Datastore:Load()

	if Addon.DataUtils.UpdateObject(action, update) then
		self:SendMessage("CLICKED_ACTION_UPDATED", action)
	end
end

--- @param uid? integer
--- @return Action2?
function Prototype:GetById(uid)
	if uid == nil then
		return nil
	end

	Addon.Datastore:Load()
	return self.uidIndex[uid]
end

--- @private
--- @param db DBSchema
function Prototype:CLICKED_DB_RELOADED(_, db)
	table.wipe(self.uidIndex)

	--- @param keybind Keybind2
	local function Add(keybind)
		for _, set in pairs(keybind.sets) do
			for _, action in pairs(set.actions) do
				self.uidIndex[action.uid] = action
			end
		end
	end

	for _, keybind in pairs(db.profile.keybinds) do
		Add(keybind)
	end

	for _, keybind in pairs(db.global.keybinds) do
		Add(keybind)
	end
end

--- @param flags UnitFlags
--- @return boolean
function Prototype.HasUnitAliveFlag(flags)
	return bit.band(flags, Clicked2.UnitFlags.ALIVE) ~= 0
end

--- @param flags UnitFlags
--- @return boolean
function Prototype.HasUnitDeadFlag(flags)
	return bit.band(flags, Clicked2.UnitFlags.DEAD) ~= 0
end

--- @param flags UnitFlags
--- @return boolean
function Prototype.HasUnitFriendFlag(flags)
	return bit.band(flags, Clicked2.UnitFlags.FRIEND) ~= 0
end

--- @param flags UnitFlags
--- @return boolean
function Prototype.HasUnitHostileFlag(flags)
	return bit.band(flags, Clicked2.UnitFlags.HOSTILE) ~= 0
end

--- @param flags LoadConditionFlags
--- @return boolean
function Prototype.HasLoadConditionEnabledFlag(flags)
	return bit.band(flags, Clicked2.LoadConditionFlags.ENABLED) ~= 0
end

--- @param flags LoadConditionFlags
--- @return boolean
function Prototype.HasLoadConditionNegatedFlag(flags)
	return bit.band(flags, Clicked2.LoadConditionFlags.NEGATED) ~= 0
end

--- @param flags LoadConditionFlags
--- @return boolean
function Prototype.HasLoadConditionMultiFlag(flags)
	return bit.band(flags, Clicked2.LoadConditionFlags.MULTI) ~= 0
end

--- @type Actions
Addon.Actions = Clicked2:NewModule("Actions", Prototype, "AceEvent-3.0")

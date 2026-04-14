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

--- @class Groups : ClickedModule, AceEvent-3.0
--- @field private registry Group[]
--- @field private uidIndex table<integer, Group>
local Prototype = {
	registry = {},
	uidIndex = {}
}

--- @protected
function Prototype:OnInitialize()
	self:RegisterMessage("CLICKED_DB_RELOADED", self.CLICKED_DB_RELOADED, self)
end

--- @param scope Scope
--- @return Group
function Prototype:Create(scope)
	Addon.Datastore:Load()

	--- @type Group
	local result = {
		uid = Clicked2:GetNextUid(),
		name = "",
		icon = "",
		scope = scope,
		children = {}
	}

	table.insert(self.registry, result)
	self.uidIndex[result.uid] = result

	self:SendMessage("CLICKED_GROUP_CREATED", result)
	self:LogDebug("Created {scope#Scope} group with ID {uid}", scope, result.uid)

	return result
end

--- @param group integer|Group
--- @return Group
function Prototype:Clone(group)
	group = type(group) == "number" and self:GetById(group) or group

	if group == nil then
		return self:LogFatal("Attempted to clone non-existent group")
	end

	Addon.Datastore:Load()

	local result = CopyTable(group) --[[@as Group]]
	result.uid = Clicked2:GetNextUid()
	table.wipe(result.children)

	for _, keybind in ipairs(group.children) do
		Addon.Keybinds:Clone(keybind, result)
	end

	table.insert(self.registry, result)
	self.uidIndex[result.uid] = result

	self:SendMessage("CLICKED_GROUP_CREATED", result)
	return result
end

--- @param group integer|Group
--- @param parent Scope
function Prototype:Move(group, parent)
	group = type(group) == "number" and self:GetById(group) or group

	if group == nil then
		return
	end

	Addon.Datastore:Load()

	if group.scope == Clicked2.Scope.VIRTUAL and parent ~= Clicked2.Scope.VIRTUAL then
		return self:LogError("Cannot move a virtual group to a persistent scope")
	elseif group.scope ~= Clicked2.Scope.VIRTUAL and parent == Clicked2.Scope.VIRTUAL then
		return self:LogError("Cannot move a persistent group to a virtual scope")
	end

	group.scope = parent

	for _, keybind in ipairs(group.children) do
		Addon.Keybinds:Move(keybind, group)
	end

	self:SendMessage("CLICKED_GROUP_MOVED", group)
end

--- @param group integer|Group
--- @return boolean
function Prototype:Delete(group)
	group = type(group) == "number" and self:GetById(group) or group

	if group == nil then
		return false
	end

	Addon.Datastore:Load()

	for _, keybind in ipairs(group.children) do
		Addon.Keybinds:Delete(keybind)
	end

	Addon.TableRemoveItem(self.registry, group)
	self.uidIndex[group.uid] = nil

	self:SendMessage("CLICKED_GROUP_DELETED", group.uid)
	return true
end

--- @param group integer|Group
--- @param update GroupUpdate
function Prototype:Update(group, update)
	group = type(group) == "number" and self:GetById(group) or group

	if group == nil then
		return
	end

	Addon.Datastore:Load()

	if Addon.DataUtils.UpdateObject(group, update) then
		self:SendMessage("CLICKED_GROUP_UPDATED", group)
	end
end

---@generic T : table, V
---@return fun(table: V[], i?: integer): integer, V
---@return T
---@return integer i
function Prototype:Iterate()
	Addon.Datastore:Load()
	return ipairs(self.registry)
end

--- @param uid? integer
--- @return Group?
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
	table.wipe(self.registry)
	table.wipe(self.uidIndex)

	--- @param group Group
	local function Add(group)
		self.uidIndex[group.uid] = group
		table.insert(self.registry, group)
	end

	for _, group in pairs(db.profile.groups) do
		Add(group)
	end

	for _, group in pairs(db.global.groups) do
		Add(group)
	end
end

--- @type Groups
Addon.Groups = Clicked2:NewModule("Groups", Prototype, "AceEvent-3.0")

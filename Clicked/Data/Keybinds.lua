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

--- @enum ActionType2
Clicked2.ActionType2 = {
	GLOBAL = 1,
	CLICKCAST = 2
}

--- @class Keybinds : ClickedModule, AceEvent-3.0
--- @field private registry Keybind2[]
--- @field private uidIndex table<integer, Keybind2>
--- @field private keyIndex table<string, Keybind2[]>
local Prototype = {
	registry = {},
	uidIndex = {},
	keyIndex = {}
}

--- @param actionType ActionType2
--- @param parent Group|Scope
--- @return Keybind2
function Prototype:Create(actionType, parent)
	Addon.Datastore:Load()

	--- @type Keybind2
	local result = {
		uid = Clicked2:GetNextUid(),
		scope = nil,
		priority = 0,
		key = "",
		type = actionType,
		sets = {}
	}

	if type(parent) == "number" then
		result.scope = parent
	else
		result.scope = parent.scope
		result.parent = parent.uid
		table.insert(parent.children, result)
	end

	table.insert(self.registry, result)
	table.insert(self:GetKeyIndex(result.key), result)
	self.uidIndex[result.uid] = result

	self:SendMessage("CLICKED_KEYBIND_CREATED", result)
	self:LogDebug("Created {scope#Scope} {type#ActionType} keybind with ID {uid}", result.scope, actionType, result.uid)

	return result
end

--- @param keybind integer|Keybind2
--- @param parent? Group|Scope
--- @return Keybind2
function Prototype:Clone(keybind, parent)
	keybind = type(keybind) == "number" and self:GetById(keybind) or keybind

	if keybind == nil then
		return self:LogFatal("Attempted to clone non-existent keybind")
	end

	Addon.Datastore:Load()

	local originalSets = keybind.sets

	keybind.sets = {}

	local success, result = pcall(function()
		local result = CopyTable(keybind) --[[@as Keybind2]]
		result.uid = Clicked2:GetNextUid()

		if parent ~= nil then
			result.parent = nil

			self:Move(result, parent)
		elseif result.parent ~= nil then
			parent = Addon.Groups:GetById(result.parent)

			if parent ~= nil then
				table.insert(parent.children, result)
			end
		end

		for i = 1, #originalSets do
			Addon.ActionSets:Clone(originalSets[i], result)
		end

		table.insert(self.registry, result)
		table.insert(self:GetKeyIndex(result.key), result)
		self.uidIndex[result.uid] = result

		self:SendMessage("CLICKED_KEYBIND_CREATED", result)
		return result
	end)

	keybind.sets = originalSets

	if not success then
		error(result)
	end

	return result
end

--- @param keybind integer|Keybind2
--- @param parent Group|Scope
function Prototype:Move(keybind, parent)
	keybind = type(keybind) == "number" and self:GetById(keybind) or keybind

	if keybind == nil then
		return
	end

	Addon.Datastore:Load()

	local targetScope = type(parent) == "number" and parent or parent.scope

	if keybind.scope == Clicked2.Scope.VIRTUAL and targetScope ~= Clicked2.Scope.VIRTUAL then
		return self:LogError("Cannot move a virtual keybind to a persistent scope")
	elseif keybind.scope ~= Clicked2.Scope.VIRTUAL and targetScope == Clicked2.Scope.VIRTUAL then
		return self:LogError("Cannot move a persistent keybind to a virtual scope")
	end

	if type(parent) == "number" then
		--- @cast parent Scope

		local group = Addon.Groups:GetById(keybind.parent)
		if group ~= nil then
			Addon.TableRemoveItem(group.children, keybind)
		end

		keybind.scope = parent
		keybind.parent = nil
	else
		--- @cast parent Group

		if parent.uid ~= keybind.parent then
			local group = Addon.Groups:GetById(keybind.parent)
			if group ~= nil then
				Addon.TableRemoveItem(group.children, keybind)
			end

			table.insert(parent.children, keybind)
		end

		keybind.scope = parent.scope
		keybind.parent = parent.uid
	end

	self:SendMessage("CLICKED_KEYBIND_MOVED", keybind)
end

--- @param keybind integer|Keybind2
--- @return boolean
function Prototype:Delete(keybind)
	keybind = type(keybind) == "number" and self:GetById(keybind) or keybind

	if keybind == nil then
		return false
	end

	Addon.Datastore:Load()

	for i = #keybind.sets, 1, -1 do
		Addon.ActionSets:Delete(keybind.sets[i])
	end

	local group = Addon.Groups:GetById(keybind.parent)
	if group ~= nil then
		Addon.TableRemoveItem(group.children, keybind)
	end

	Addon.TableRemoveItem(self.registry, keybind)
	Addon.TableRemoveItem(self:GetKeyIndex(keybind.key), keybind)
	self.uidIndex[keybind.uid] = nil

	self:SendMessage("CLICKED_KEYBIND_DELETED", keybind.uid)
	return true
end

--- @param keybind integer|Keybind2
--- @param update KeybindUpdate
function Prototype:Update(keybind, update)
	keybind = type(keybind) == "number" and self:GetById(keybind) or keybind

	if keybind == nil then
		return
	end

	Addon.Datastore:Load()

	local hooks = {
		key = function(original, new)
			Addon.TableRemoveItem(self:GetKeyIndex(original), keybind)
			table.insert(self:GetKeyIndex(new), keybind)
		end
	}

	if Addon.DataUtils.UpdateObject(keybind, update, hooks) then
		self:SendMessage("CLICKED_KEYBIND_UPDATED", keybind)
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
--- @return Keybind2?
function Prototype:GetById(uid)
	if uid == nil then
		return nil
	end

	Addon.Datastore:Load()
	return self.uidIndex[uid]
end

--- @param key string
--- @return Keybind2[]
function Prototype:GetByKey(key)
	Addon.Datastore:Load()
	return self.keyIndex[key] or {}
end

--- @private
--- @param key? string
--- @return Keybind2[]
function Prototype:GetKeyIndex(key)
	key = key or ""

	local result = self.keyIndex[key]

	if result == nil then
		result = {}
		self.keyIndex[key] = result
	end

	return result
end

--- @private
--- @param db DBSchema
function Prototype:CLICKED_DB_RELOADED(_, db)
	table.wipe(self.registry)
	table.wipe(self.uidIndex)
	table.wipe(self.keyIndex)

	--- @param keybind Keybind2
	local function Add(keybind)
		self.uidIndex[keybind.uid] = keybind
		self.keyIndex[keybind.key] = self.keyIndex[keybind.key] or {}
		table.insert(self.keyIndex[keybind.key], keybind)
		table.insert(self.registry, keybind)
	end

	for _, keybind in pairs(db.profile.keybinds) do
		Add(keybind)
	end

	for _, keybind in pairs(db.global.keybinds) do
		Add(keybind)
	end
end

--- @type Keybinds
Addon.Keybinds = Clicked2:NewModule("Keybinds", Prototype, "AceEvent-3.0")

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

local LibLog = LibStub("LibLog-1.0")

--- @class Addon
local Addon = select(2, ...)

--- @enum Scope
Clicked2.Scope = {
	PROFILE = 1,
	GLOBAL = 2,
	VIRTUAL = 3
}

--- @class Datastore : ClickedModule, AceEvent-3.0
local Prototype = {}

--- @return DBSchema
local function GetDatabaseDefaults()
	local group = {
		--- @type Group
		["**"] = {
			uid = nil,
			name = "",
			icon = "",
			scope = nil,
			children = {}
		}
	}

	local loadConditionSet = {
		--- @type LoadCondition
		["**"] = {
			state = 0
		}
	}

	local action = {
		--- @type Action2
		["**"] = Mixin({
			parent = nil,
			uid = nil,
			flags = 0,
			load = loadConditionSet
		}, Clicked2.ActionLibrary:GetDatabaseDefaults())
	}

	local actionSet = {
	--- @type ActionSet
		["**"] = {
			parent = nil,
			uid = nil,
			type = nil,
			actions = action
		}
	}

	local keybind = {
		--- @type Keybind2
		["**"] = {
			uid = nil,
			priority = 0,
			key = "",
			type = nil,
			parent = nil,
			scope = nil,
			sets = actionSet
		}
	}

	--- @type DBSchema
	return {
		global = {
			options = {
				onKeyDown = true,
				bindUnassignedModifiers = false,
				autoBindActionBar = false,
				minimap = {
					hide = false,
					lock = false,
					minimapPos = 0
				},
				ignoreSelfCastWarning = false,
				disableInHouse = true
			},
			keyVisualizer = {
				showOnlyLoadedBindings = true,
				highlightEmptyKeys = false
			},
			blacklist = {},
			nextUid = 1,
			logLevel = LibLog.LogLevel.INFO,
			version = nil,
			groups = group,
			keybinds = keybind,
		},
		profile = {
			version = nil,
			groups = group,
			keybinds = keybind,
		}
	}
end

--- @param groups Group[]
--- @param keybinds Keybind2[]
--- @param scope Scope
local function AppendRuntimeData(groups, keybinds, scope)
	--- @type table<integer, Keybind2[]>
	local groupChildren = {}

	for _, keybind in pairs(keybinds) do
		if keybind.parent ~= nil then
			groupChildren[keybind.parent] = groupChildren[keybind.parent] or {}
			table.insert(groupChildren[keybind.parent], keybind)
		end

		keybind.scope = scope

		for _, set in pairs(keybind.sets) do
			set.parent = keybind

			for _, action in pairs(set.actions) do
				action.parent = set
			end
		end
	end

	for _, group in ipairs(groups) do
		group.scope = scope
		group.children = groupChildren[group.uid] or {}
	end
end

--- @param groups Group[]
--- @param keybinds Keybind2[]
local function RemoveRuntimeData(groups, keybinds)
	for _, keybind in pairs(keybinds) do
		keybind.scope = nil

		for _, set in pairs(keybind.sets) do
			set.parent = nil

			for _, action in pairs(set.actions) do
				action.parent = nil
			end
		end
	end

	for _, group in pairs(groups) do
		group.scope = nil
		group.children = nil
	end
end

--- @protected
function Prototype:OnInitialize()
	self:RegisterMessage("CLICKED_KEYBIND_CREATED", self.CLICKED_KEYBIND_CREATED, self)
	self:RegisterMessage("CLICKED_KEYBIND_DELETED", self.CLICKED_KEYBIND_DELETED, self)
	self:RegisterMessage("CLICKED_GROUP_CREATED", self.CLICKED_GROUP_CREATED, self)
	self:RegisterMessage("CLICKED_GROUP_DELETED", self.CLICKED_GROUP_DELETED, self)

	self:LogDebug("Initialized datastore module")
end

function Prototype:UpdateDatabaseDefaults()
	if Addon.db == nil then
		return
	end

	Addon.db:RegisterDefaults(GetDatabaseDefaults())
end

--- @private
--- @param keybind Keybind2
function Prototype:CLICKED_KEYBIND_CREATED(keybind)
	if keybind.scope == Clicked2.Scope.VIRTUAL then
		return self:LogVerbose("Ignoring virtual keybind with ID {uid}", keybind.uid)
	end

	if keybind.scope == Clicked2.Scope.PROFILE then
		table.insert(Addon.db.profile.keybinds, keybind)
	elseif keybind.scope == Clicked2.Scope.GLOBAL then
		table.insert(Addon.db.global.keybinds, keybind)
	else
		return self:LogError("Invalid keybind scope {scope#Scope} for keybind with ID {uid}", keybind.scope, keybind.uid)
	end
end

--- @private
--- @param uid integer
function Prototype:CLICKED_KEYBIND_DELETED(uid)
	--- @param keybind Keybind2
	local function Predicate(keybind)
		return keybind.uid == uid
	end

	if Addon.TableRemovePredicate(Addon.db.profile.keybinds, Predicate) then
		return
	end

	if Addon.TableRemovePredicate(Addon.db.global.keybinds, Predicate) then
		return
	end
end

function Prototype:CLICKED_GROUP_CREATED(group)
	if group.scope == Clicked2.Scope.VIRTUAL then
		return self:LogVerbose("Ignoring virtual group with ID {uid}", group.uid)
	end

	if group.scope == Clicked2.Scope.PROFILE then
		table.insert(Addon.db.profile.groups, group)
	elseif group.scope == Clicked2.Scope.GLOBAL then
		table.insert(Addon.db.global.groups, group)
	else
		return self:LogError("Invalid group scope {scope#Scope} for group with ID {uid}", group.scope, group.uid)
	end
end

function Prototype:CLICKED_GROUP_DELETED(uid)
	--- @param group Group
	local function Predicate(group)
		return group.uid == uid
	end

	if Addon.TableRemovePredicate(Addon.db.profile.groups, Predicate) then
		return
	end

	if Addon.TableRemovePredicate(Addon.db.global.groups, Predicate) then
		return
	end
end

function Prototype:Load()
	if Addon.db == nil then
		local defaultProfile = select(2, UnitClass("player"))

		Addon.db = LibStub("AceDB-3.0"):New("Clicked2DB", GetDatabaseDefaults(), defaultProfile) --[[@as AceDBObject-3.0|DBSchema]]
		Addon.db.RegisterCallback(self, "OnProfileChanged", "Reload")
		Addon.db.RegisterCallback(self, "OnProfileCopied", "Reload")
		Addon.db.RegisterCallback(self, "OnProfileReset", "Reload")
		Addon.db.RegisterCallback(self, "OnDatabaseShutdown", "Shutdown")

		Clicked2:SetLogLevelFromConfigTable(Addon.db.global)
		Clicked2:AddLogEnum("Scope", Clicked2.Scope)
		Clicked2:AddLogEnum("ActionType", Clicked2.ActionType2)

		self:Reload()
	end
end

--- @private
function Prototype:Reload()
	self:LogDebug("Reloading database from saved variables")

	Addon:Upgrade()

	AppendRuntimeData(Addon.db.global.groups, Addon.db.global.keybinds, Clicked2.Scope.GLOBAL)
	AppendRuntimeData(Addon.db.profile.groups, Addon.db.profile.keybinds, Clicked2.Scope.PROFILE)

	self:SendMessage("CLICKED_DB_RELOADED", Addon.db)
end

--- @private
function Prototype:Shutdown()
	self:LogDebug("Shutting down datastore, wiping runtime-only data")

	RemoveRuntimeData(Addon.db.global.groups, Addon.db.global.keybinds)
	RemoveRuntimeData(Addon.db.profile.groups, Addon.db.profile.keybinds)
end

--- @return integer
function Clicked2:GetNextUid()
	local uid = Addon.db.global.nextUid
	Addon.db.global.nextUid = uid + 1
	return uid
end

--- @type Datastore
Addon.Datastore = Clicked2:NewModule("Datastore", Prototype, "AceEvent-3.0")

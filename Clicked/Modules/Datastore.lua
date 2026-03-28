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

--- @class DatastoreModule : AceModule, AceEvent-3.0, LibLog-1.0.Logger
local Prototype = {}

local defaultGroup = {
	--- @type Group2
	["*"] = {
		uid = nil,
		name = "",
		icon = ""
	}
}

local defaultKeybind = {
	--- @type Keybind2
	["*"] = {
		uid = nil,
		priority = 0,
		key = "",
		type = nil,
		parent = nil,
		sets = {
		--- @type ActionSet
			["*"] = {
				type = nil,
				actions = {
					--- @type Action2
					["*"] = {
						flags = 0,
						load = {
							--- @type LoadConditionSet
							["*"] = {
								state = 0
							}
						}
					}
				}
			}
		}
	}
}

--- @type DBSchema
local defaults = {
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
		groups = defaultGroup,
		keybinds = defaultKeybind,
	},
	profile = {
		version = nil,
		groups = defaultGroup,
		keybinds = defaultKeybind,
	}
}

--- @protected
function Prototype:OnInitialize()
	self:RegisterMessage("CLICKED_KEYBIND_CREATED", self.CLICKED_KEYBIND_CREATED, self)
	self:RegisterMessage("CLICKED_KEYBIND_DELETED", self.CLICKED_KEYBIND_DELETED, self)

	self:LogDebug("Initialized datastore module")
end

--- @private
--- @param keybind Keybind2
function Prototype:CLICKED_KEYBIND_CREATED(keybind)
	-- TODO: Add keybind to datastore
end

--- @private
--- @param uid integer
function Prototype:CLICKED_KEYBIND_DELETED(uid)
	-- TODO: Remove keybind from datastore
end

function Prototype:InitializeDatastore()
	local defaultProfile = select(2, UnitClass("player"))

	Addon.db = LibStub("AceDB-3.0"):New("Clicked2DB", defaults, defaultProfile) --[[@as AceDBObject-3.0|DBSchema]]
	Addon.db.RegisterCallback(self, "OnProfileChanged", "Reload")
	Addon.db.RegisterCallback(self, "OnProfileCopied", "Reload")
	Addon.db.RegisterCallback(self, "OnProfileReset", "Reload")

	self:Reload()
end

function Prototype:Reload()
	self:LogDebug("Reloading database from saved variables")

	Addon:UpgradeDatabase()

	Clicked2:SetLogLevelFromConfigTable(Addon.db.global)

	self:SendMessage("CLICKED_DB_RELOADED", Addon.db)
end

function Clicked2:GetNextUid()
	local uid = Addon.db.global.nextUid
	Addon.db.global.nextUid = uid + 1
	return uid
end

Addon.Datastore = Clicked2:NewModule("Datastore", Prototype, "AceEvent-3.0")

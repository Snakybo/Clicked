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

local LibDBIcon = LibStub("LibDBIcon-1.0")

-- Deprecated in 5.5.0
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization

--- @class ClickedInternal
local Addon = select(2, ...)

--- @enum DataObjectType
Clicked.DataObjectType = {
	BINDING = 1,
	GROUP = 2
}

--- @enum DataObjectScope
Clicked.DataObjectScope = {
	PROFILE = 1,
	GLOBAL = 2
}

Addon.DISABLE_GLOBAL_SCOPE = false

--@non-debug@
  -- Addon.DISABLE_GLOBAL_SCOPE = false
--@end-non-debug@

--- @class DataObjectLookup
--- @field public uid table<integer,DataObject>
--- @field public keybind table<string,Binding[]>
--- @field public parent table<integer,Binding[]>
--- @field public actionType table<ActionType,Binding[]>
--- @field public scope table<DataObjectScope,DataObject[]>
--- @field public deleted integer[]
local lookupTable = {
	uid = {},
	keybind = {},
	parent = {},
	actionType = {},
	scope = {},
	deleted = {}
}

-- Local support functions

--- @param default string|boolean
--- @return Binding.LoadOption
local function GetLoadOptionTemplate(default)
	--- @type Binding.LoadOption
	local template = {
		selected = false,
		value = default
	}

	return template
end

--- @return Binding.LoadOption
local function GetNegatableLoadOptionTemplate()
	return GetLoadOptionTemplate(true)
end
--- @param default number|string
--- @return Binding.TriStateLoadOption
local function GetTriStateLoadOptionTemplate(default)
	--- @type Binding.TriStateLoadOption
	local template = {
		selected = 0,
		single = default,
		multiple = {
			default
		}
	}

	return template
end

--- @param default number|string
--- @return Binding.NegatableTriStateLoadOption
local function GetNegatableTriStateLoadOptionTemplate(default)
	local template = GetTriStateLoadOptionTemplate(default) --[[@as Binding.NegatableTriStateLoadOption]]
	template.negated = false

	return template
end

--- @param default string
--- @return Binding.MutliFieldLoadOption
local function GetMultiFieldLoadOptionTemplate(default)
	--- @type Binding.MutliFieldLoadOption
	local template = {
		selected = false,
		entries = {
			{
				operation = "AND",
				negated = false,
				value = default
			}
		}
	}

	return template
end

--- @return Binding.NegatableStringLoadOption
local function GetNegatableStringLoadOptionTemplate()
	--- @type Binding.NegatableStringLoadOption
	local template = {
		selected = false,
		negated = false,
		value = ""
	}

	return template
end

-- Public addon API

--- Get the default values for a Clicked profile.
---
--- @return AceDBObject-3.0
function Clicked:GetDatabaseDefaults()
	local database = {
		global = {
			version = nil,
			groups = {},
			bindings = {},
			nextUid = 1,
			keyVisualizer = {
				lastKeyboardLayout = nil,
				lastKeyboardSize = nil,
				showOnlyLoadedBindings = true,
				highlightEmptyKeys = false
			}
		},
		profile = {
			version = nil,
			options = {
				onKeyDown = false,
				tooltips = false,
				bindUnassignedModifiers = false,
				autoBindActionBar = false,
				minimap = {
					hide = false
				},
				ignoreSelfCastWarning = false,
				disableInHouse = true
			},
			groups = {},
			bindings = {},
			blacklist = {},
		}
	}

	return database
end

--- Reload the database, this should be called after high-level profile changes have been made, such as switching the active profile, or importing a proifle.
function Clicked:ReloadDatabase()
	Addon:UpgradeDatabase()

	if Addon.db.profile.options.minimap.hide then
		LibDBIcon:Hide("Clicked")
	else
		LibDBIcon:Show("Clicked")
	end

	Addon.BlacklistOptions:Refresh()
	Addon:RequestItemLoadForBindings()
	Addon:ReloadBindings()
end

--- Create a new binding group. Groups are purely cosmetic and have no additional impact on binding functionality.
---
--- @return Group
function Clicked:CreateGroup()
	--- @type Group
	--- @diagnostic disable-next-line: missing-fields
	local group = {
		type = Clicked.DataObjectType.GROUP,
		name = Addon.L["New Group"],
		displayIcon = "Interface\\ICONS\\INV_Misc_QuestionMark"
	}

	Addon:RegisterDataObject(group)
	return group
end

--- Create a new binding. This will create and return a new binding, however it will not automatically reload the active bindings, after configuring the
--- returned binding (to make it loadable), manually reload the active bindings using `ReloadBindings`.
---
--- @param scope? DataObjectScope
--- @return Binding
function Clicked:CreateBinding(scope)
	local binding = Addon:GetNewBindingTemplate()

	Addon:RegisterDataObject(binding, scope)
	return binding
end

--- Delete a data object and all children.
---
--- @param object DataObject
--- @returns boolean
function Clicked:DeleteDataObject(object)
	assert(type(object) == "table", "bad argument #1, expected table but got " .. type(object))

	local function Delete(tbl, uid)
		for i, obj in ipairs(tbl) do
			if obj.uid == uid then
				table.remove(tbl, i)
				return true
			end
		end

		return false
	end

	--- @type DataObject[]
	local queue = { object }

	--- @type DataObject[]
	local deleted = {}

	while #queue > 0 do
		--- @type DataObject
		local current = table.remove(queue, 1)
		local db = Addon:GetContainingDatabase(current)

		if current.type == Clicked.DataObjectType.GROUP then
			if Delete(db.groups, current.uid) then
				table.insert(lookupTable.deleted, object.uid)
				table.insert(deleted, current)

				for _, binding in ipairs(Clicked:GetByParent(current.uid)) do
					table.insert(queue, binding)
				end
			end
		elseif current.type == Clicked.DataObjectType.BINDING then
			if Delete(db.bindings, current.uid) then
				table.insert(lookupTable.deleted, object.uid)
				table.insert(deleted, current)
			end
		end
	end

	for _, current in ipairs(deleted) do
		if current.type == Clicked.DataObjectType.BINDING then
			--- @cast current Binding
			Addon:ReloadBinding(current)
		elseif current.type == Clicked.DataObjectType.GROUP then
			Addon:UpdateLookupTable(current)
			Addon.BindingConfig.Window:RedrawTree()
		end
	end

	return deleted
end

--- Attempt to get a binding or group with the specified identifier.
---
--- @param identifier? integer
--- @return DataObject?
function Clicked:GetByUid(identifier)
	if identifier == nil then
		return nil
	end

	return lookupTable.uid[identifier]
end

--- @param key? string
--- @return Binding[]
function Clicked:GetByKey(key)
	if key == nil then
		return {}
	end

	return lookupTable.keybind[key] or {}
end

--- @param scope DataObjectScope
--- @return DataObject[]
function Clicked:GetByScope(scope)
	return lookupTable.scope[scope] or {}
end

--- Get a list of all bindings that are part of the specified group.
---
--- @param identifier? integer
--- @return Binding[]
function Clicked:GetByParent(identifier)
	if identifier == nil then
		return {}
	end

	return lookupTable.parent[identifier] or {}
end

--- Get a list of all bindings that are part of the specified group.
---
--- @param type ActionType
--- @return Binding[]
function Clicked:GetByActionType(type)
	return lookupTable.actionType[type] or {}
end

--- Iterate trough all configured groups. This function can be used in a `for in` loop.
function Clicked:IterateGroups()
	--- @type Group[]
	local result = {}

	for _, group in ipairs(Addon.db.profile.groups) do
		table.insert(result, group)
	end

	if not Addon.DISABLE_GLOBAL_SCOPE then
		for _, group in ipairs(Addon.db.global.groups) do
			table.insert(result, group)
		end
	end

	return ipairs(result)
end

--- Iterate through all configured bindings, this will also include any bindings avaialble in the current profile that are not currently loaded. This function
--- can be used in a `for in` loop.
function Clicked:IterateConfiguredBindings()
	--- @type Binding[]
	local result = {}

	for _, binding in ipairs(Addon.db.profile.bindings) do
		table.insert(result, binding)
	end

	if not Addon.DISABLE_GLOBAL_SCOPE then
		for _, binding in ipairs(Addon.db.global.bindings) do
			table.insert(result, binding)
		end
	end

	return ipairs(result)
end

--@debug@

--- @param from string
function Clicked:UpgradeDatabase(from)
	Addon:UpgradeDatabase(from)
	Addon:ReloadBindings()
end

--@end-debug@

-- Private addon API

--- Update the data object lookup table
---
--- This will cache all data objects in a lookup table, this is used to quickly find bindings and groups by keybind, parent, action type or scope.
---
--- This will come at the cost of memory, but will greatly improve performance when searching for bindings or groups.
---
--- @param obj? DataObject
function Addon:UpdateLookupTable(obj)
	if obj ~= nil then
		Clicked:LogVerbose("Updating binding lookup table for {uid}", obj.uid)
	else
		Clicked:LogVerbose("Updating binding lookup table")
	end

	--- @type DataObject[]
	local queue = {}
	local clean = obj == nil

	if obj == nil then
		table.wipe(lookupTable.uid)
		table.wipe(lookupTable.keybind)
		table.wipe(lookupTable.parent)
		table.wipe(lookupTable.actionType)
		table.wipe(lookupTable.scope)
		table.wipe(lookupTable.deleted)

		for _, configured in Clicked:IterateConfiguredBindings() do
			table.insert(queue, configured)
		end

		for _, group in Clicked:IterateGroups() do
			table.insert(queue, group)
		end
	else
		table.insert(queue, obj)
	end

	--- @generic K
	--- @param tbl table<K,DataObject[]>
	--- @param key K
	--- @param value DataObject
	local function UpdateLookupTable(tbl, key, value)
		if not clean then
			for _, array in pairs(tbl) do
				if Addon:TableRemoveItem(array, value) then
					break
				end
			end
		end

		if not Addon:IsNilOrEmpty(key) then
			tbl[key] = tbl[key] or {}
			table.insert(tbl[key], value)
		end
	end

	--- @param tbl table<any,DataObject[]>
	--- @param value DataObject
	local function DeleteFromLookupTable(tbl, value)
		for _, array in pairs(tbl) do
			if Addon:TableRemoveItem(array, value) then
				break
			end
		end
	end

	while #queue > 0 do
		--- @type DataObject
		local current = table.remove(queue, 1)

		if tContains(lookupTable.deleted, current.uid) then
			lookupTable.uid[current.uid] = nil

			Addon:TableRemoveItem(lookupTable.deleted, current.uid)

			if current.type == Clicked.DataObjectType.BINDING then
				--- @cast current Binding
				DeleteFromLookupTable(lookupTable.keybind, current)
				DeleteFromLookupTable(lookupTable.parent, current)
				DeleteFromLookupTable(lookupTable.actionType, current)
			end

			DeleteFromLookupTable(lookupTable.scope, current)
		else
			lookupTable.uid[current.uid] = current

			if current.type == Clicked.DataObjectType.BINDING then
				--- @cast current Binding
				UpdateLookupTable(lookupTable.keybind, current.keybind, current)
				UpdateLookupTable(lookupTable.parent, current.parent, current)
				UpdateLookupTable(lookupTable.actionType, current.actionType, current)
			end

			UpdateLookupTable(lookupTable.scope, current.scope, current)
		end
	end
end

--- @return Binding
function Addon:GetNewBindingTemplate()
	--- @type Binding
	--- @diagnostic disable-next-line: missing-fields
	local template = {
		actionType = Clicked.ActionType.SPELL,
		type = Clicked.DataObjectType.BINDING,
		keybind = "",
		parent = nil,
		action = {
			spellValue = "",
			itemValue = "",
			macroValue = "",
			macroName = Addon.L["Run custom macro"],
			macroIcon = [[Interface\ICONS\INV_Misc_QuestionMark]],
			auraName = "",
			executionOrder = 1,
			spellMaxRank = false,
			interrupt = false,
			startAutoAttack = false,
			startPetAttack = false,
			stopSpellTarget = true,
			cancelQueuedSpell = false,
			cancelForm = false,
			targetUnitAfterCast = false,
			preventToggle = false
		},
		targets = {
			hovercast = {
				hostility = Addon.TargetHostility.ANY,
				vitals = Addon.TargetVitals.ANY
			},
			regular = {
				Addon:GetNewBindingTargetTemplate()
			},
			hovercastEnabled = false,
			regularEnabled = true
		},
		load = {
			never = false,
			class = GetTriStateLoadOptionTemplate(select(2, UnitClass("player"))),
			race = GetTriStateLoadOptionTemplate(select(2, UnitRace("player"))),
			playerNameRealm = GetLoadOptionTemplate(UnitName("player") --[[@as string]]),
			combat = GetNegatableLoadOptionTemplate(),
			spellKnown = GetLoadOptionTemplate(""),
			inGroup = GetLoadOptionTemplate(Addon.GroupState.PARTY_OR_RAID),
			playerInGroup = GetLoadOptionTemplate(""),
			form = GetNegatableTriStateLoadOptionTemplate(1),
			pet = GetNegatableLoadOptionTemplate(),
			stealth = GetNegatableLoadOptionTemplate(),
			mounted = GetNegatableLoadOptionTemplate(),
			outdoors = GetNegatableLoadOptionTemplate(),
			swimming = GetNegatableLoadOptionTemplate(),
			instanceType = GetTriStateLoadOptionTemplate("NONE"),
			zoneName = GetLoadOptionTemplate(""),
			equipped = GetLoadOptionTemplate(""),
			bonusbar = GetNegatableStringLoadOptionTemplate(),
			bar = GetNegatableStringLoadOptionTemplate(),
			channeling = GetNegatableStringLoadOptionTemplate(),
			flying = GetNegatableLoadOptionTemplate(),
			dynamicFlying = GetNegatableLoadOptionTemplate(),
			flyable = GetNegatableLoadOptionTemplate(),
			advancedFlyable = GetNegatableLoadOptionTemplate(),
			specialization = GetTriStateLoadOptionTemplate(1),
			specRole = GetTriStateLoadOptionTemplate(""),
			talent = GetMultiFieldLoadOptionTemplate(""),
			pvpTalent = GetMultiFieldLoadOptionTemplate(""),
			warMode = GetNegatableLoadOptionTemplate()
		}
	}

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
		local specIndex = GetSpecialization()
		specIndex = specIndex == 5 and 1 or specIndex -- Initial spec
		template.load.specialization = GetTriStateLoadOptionTemplate(specIndex)
		template.load.specRole = GetTriStateLoadOptionTemplate(specIndex)
	elseif Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
		--- @type number
		local specIndex = GetPrimaryTalentTree()
		template.load.specialization = GetTriStateLoadOptionTemplate(specIndex)
	end

	return template
end

--- @return Binding.Target
function Addon:GetNewBindingTargetTemplate()
	--- @type Binding.Target
	local template = {
		unit = Addon.TargetUnit.DEFAULT,
		hostility = Addon.TargetHostility.ANY,
		vitals = Addon.TargetVitals.ANY
	}

	return template
end

function Addon:GetNextUid()
	local uid = Addon.db.global.nextUid
	Addon.db.global.nextUid = uid + 1
	return uid
end

--- Change the scope of a binding or entire group.
--- This will re-register the binding (or group) within the target database.
---
---@param item DataObject
---@param scope DataObjectScope
function Addon:ChangeDataObjectScope(item, scope)
	assert(type(item) == "table", "bad argument #1, expected table but got " .. type(item))
	assert(type(scope) == "number", "bad argument #1, expected number but got " .. type(scope))

	if item.uid == nil then
		return Clicked:LogFatal("Can only change the scope of a binding or group")
	end

	if item.scope == scope then
		return
	end

	--- @type DataObject[]
	local queue = { item }

	while #queue > 0 do
		--- @type DataObject
		local current = table.remove(queue, 1)

		if current.type == Clicked.DataObjectType.GROUP then
			--- @cast current Group
			for _, binding in ipairs(Clicked:GetByParent(current.uid)) do
				table.insert(queue, binding)
			end
		end

		current.scope = scope

		if current.type == Clicked.DataObjectType.BINDING then
			--- @cast current Binding
			local parent = Clicked:GetByUid(current.parent)

			if parent ~= nil and parent.scope ~= scope then
				current.parent = nil
			end
		end

		if scope == Clicked.DataObjectScope.PROFILE and current.type == Clicked.DataObjectType.GROUP then
			table.insert(Addon.db.profile.groups, current)
			Addon:TableRemoveItem(Addon.db.global.groups, current)
		elseif scope == Clicked.DataObjectScope.GLOBAL and current.type == Clicked.DataObjectType.GROUP then
			table.insert(Addon.db.global.groups, current)
			Addon:TableRemoveItem(Addon.db.profile.groups, current)
		elseif scope == Clicked.DataObjectScope.PROFILE and current.type == Clicked.DataObjectType.BINDING then
			table.insert(Addon.db.profile.bindings, current)
			Addon:TableRemoveItem(Addon.db.global.bindings, current)
		elseif scope == Clicked.DataObjectScope.GLOBAL and current.type == Clicked.DataObjectType.BINDING then
			table.insert(Addon.db.global.bindings, current)
			Addon:TableRemoveItem(Addon.db.profile.bindings, current)
		end

		self:UpdateLookupTable(current)
	end

	Addon.BindingConfig.Window:RedrawTree()
end

--- Change the parent of a binding.
---
--- @param item Binding
--- @param parent Group|integer?
function Addon:ChangeDataObjectParent(item, parent)
	assert(type(item) == "table", "bad argument #1, expected table but got " .. type(item))

	if item.type ~= Clicked.DataObjectType.BINDING then
		return
	end

	--- @type Group?
	local parentObject

	if type(parent) == "table" then
		--- @cast parent Group
		item.parent = parent.uid
		parentObject = parent
	else
		--- @cast parent integer?
		item.parent = parent
		parentObject = Clicked:GetByUid(parent) --[[@as Group?]]
	end

	if parentObject ~= nil and item.scope ~= parentObject.scope then
		self:ChangeDataObjectScope(item, parentObject.scope)
	end

	self:UpdateLookupTable(item)
	Addon.BindingConfig.Window:RedrawTree()
end

--- Replace the contents of a binding with another binding.
---
--- This will replace almost all properties of the original binding with the properties of the replacement binding. Notable exceptions are:
--- - The UID of the original binding will be preserved.
--- - The keybind of the original binding will be preserved.
--- - The parent of the original binding will be preserved.
--- - The scope of the original binding will be preserved.
---
--- @param original Binding
--- @param replacement Binding
function Addon:ReplaceBindingContents(original, replacement)
	assert(type(original) == "table", "bad argument #1, expected table but got " .. type(original))
	assert(type(replacement) == "table", "bad argument #2, expected table but got " .. type(replacement))

	replacement.parent = original.parent
	replacement.scope = original.scope
	replacement.uid = original.uid
	replacement.keybind = original.keybind

	for index, binding in Clicked:IterateConfiguredBindings() do
		if binding.uid == original.uid then
			Addon.db.profile.bindings[index] = replacement
			break
		end
	end
end

--- @param object DataObject
--- @param scope? DataObjectScope
function Addon:RegisterDataObject(object, scope)
	assert(type(object) == "table", "bad argument #1, expected table but got " .. type(object))

	object.uid = object.uid or self:GetNextUid()
	object.scope = scope or Clicked.DataObjectScope.PROFILE

	local db = self:GetContainingDatabase(object)

	if object.type == Clicked.DataObjectType.GROUP then
		Clicked:LogDebug("Registering group {uid} in scope {scope}", object.uid, object.scope)
		table.insert(db.groups, object)
	elseif object.type == Clicked.DataObjectType.BINDING then
		Clicked:LogDebug("Registering binding {uid} in scope {scope}", object.uid, object.scope)
		table.insert(db.bindings, object)
	end

	self:UpdateLookupTable(object)
end

--- @generic T : DataObject
--- @param original T
--- @return T
function Addon:CloneDataObject(original)
	assert(type(original) == "table", "bad argument #1, expected table but got " .. type(original))

	--- @generic T : DataObject
	--- @param obj T
	--- @return T
	local function Clone(obj)
		local clone = CopyTable(obj)
		clone.uid = nil
		return clone
	end

	if original.type == Clicked.DataObjectType.GROUP then
		--- @cast original Group
		local clone = Clone(original)
		clone.name = clone.name .. " - " .. Addon.L["copy"]
		self:RegisterDataObject(clone, original.scope)

		for _, binding in ipairs(Clicked:GetByParent(original.uid)) do
			local cloneBinding = Clone(binding)
			cloneBinding.parent = clone.uid
			cloneBinding.keybind = ""

			self:RegisterDataObject(cloneBinding, original.scope)
			self:ReloadBinding(cloneBinding, true)
		end

		return clone
	elseif original.type == Clicked.DataObjectType.BINDING then
		--- @cast original Binding
		local clone = Clone(original)
		clone.keybind = ""

		self:RegisterDataObject(clone, original.scope)
		self:ReloadBinding(clone, true)

		return clone
	end

	return nil
end

--- @param item DataObject
--- @return table
function Addon:GetContainingDatabase(item)
	assert(type(item) == "table", "bad argument #1, expected table but got " .. type(item))

	if item.scope == Clicked.DataObjectScope.GLOBAL then
		return Addon.db.global
	elseif item.scope == Clicked.DataObjectScope.PROFILE then
		return Addon.db.profile
	else
		return Clicked:LogFatal("Unknown binding scope {scope}", item.scope)
	end
end

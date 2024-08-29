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

local LibDBIcon = LibStub("LibDBIcon-1.0")

--- @class ClickedInternal
local Addon = select(2, ...)

--- @class DataObjectLookup
--- @field public uid table<integer,DataObject>
--- @field public keybind table<string,Binding[]>
--- @field public parent table<integer,Binding[]>
--- @field public actionType table<BindingType,Binding[]>
--- @field public scope table<BindingScope,DataObject[]>
local lookupTable = {
	uid = {},
	keybind = {},
	parent = {},
	actionType = {},
	scope = {}
}

--- @enum DataObjectType
Clicked.DataObjectType = {
	BINDING = 1,
	GROUP = 2
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
				minimap = {
					hide = false
				},
				ignoreSelfCastWarning = false
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
	Clicked:ReloadBindings(true)
end

--- Create a new binding group. Groups are purely cosmetic and have no additional impact on binding functionality.
---
--- @return Group
function Clicked:CreateGroup()
	--- @type Group
	local group = {
		type = Clicked.DataObjectType.GROUP,
		name = Addon.L["New Group"],
		displayIcon = "Interface\\ICONS\\INV_Misc_QuestionMark"
	}

	Addon:RegisterGroup(group, Addon.BindingScope.PROFILE)
	return group
end

--- Delete a binding group. If the group is not empty, it will also delete all child-bindings.
---
--- @param group Group
--- @returns boolean
function Clicked:DeleteGroup(group)
	assert(type(group) == "table", "bad argument #1, expected table but got " .. type(group))

	local db = Addon:GetContainingDatabase(group)
	local deleted = false

	for i, e in ipairs(db.groups) do
		if e.uid == group.uid then
			table.remove(db.groups, i)
			deleted = true
			break
		end
	end

	if deleted then
		for i = #db.bindings, 1, -1 do
			local binding = db.bindings[i]

			if binding.parent == group.uid then
				table.remove(db.bindings, i)
			end
		end

		self:ReloadBindings(true)
		return true
	end

	return false
end

--- Update the data object lookup table
---
--- This will cache all data objects in a lookup table, this is used to quickly find bindings and groups by keybind, parent, action type or scope.
---
--- This will come at the cost of memory, but will greatly improve performance when searching for bindings or groups.
---
--- @param obj? DataObject
function Addon:UpdateLookupTable(obj)
	--- @type DataObject[]
	local queue = {}
	local clean = obj == nil

	if obj == nil then
		table.wipe(lookupTable.uid)
		table.wipe(lookupTable.keybind)
		table.wipe(lookupTable.parent)
		table.wipe(lookupTable.actionType)
		table.wipe(lookupTable.scope)

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

	while #queue > 0 do
		--- @type DataObject
		local current = table.remove(queue, 1)

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

--- @param scope BindingScope
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
--- @param type BindingType
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

	for _, group in ipairs(Addon.db.global.groups) do
		table.insert(result, group)
	end

	return ipairs(result)
end

--- Create a new binding. This will create and return a new binding, however it will not automatically reload the active bindings, after configuring the
--- returned binding (to make it loadable), manually reload the active bindings using `ReloadBindings`.
---
--- @return Binding
--- @see Clicked#ReloadBindings
function Clicked:CreateBinding()
	local binding = Addon:GetNewBindingTemplate()

	Addon:RegisterBinding(binding, Addon.BindingScope.PROFILE)
	return binding
end

--- Delete a binding. If the binding exists it will delete it from the database, if the binding is currently loaded, it will automatically reload the active
--- bindings.
---
--- @param binding Binding The binding to delete
--- @returns boolean
function Clicked:DeleteBinding(binding)
	assert(type(binding) == "table", "bad argument #1, expected table but got " .. type(binding))

	local db = Addon:GetContainingDatabase(binding)
	local deleted = false

	for index, item in ipairs(db.bindings) do
		if binding.uid == item.uid then
			table.remove(db.bindings, index)
			deleted = true
			break
		end
	end

	if deleted then
		self:ReloadBindings(true)
		return true
	end

	return false
end

--- Iterate through all configured bindings, this will also include any bindings avaialble in the current profile that are not currently loaded. This function
--- can be used in a `for in` loop.
function Clicked:IterateConfiguredBindings()
	--- @type Binding[]
	local result = {}

	for _, binding in ipairs(Addon.db.profile.bindings) do
		table.insert(result, binding)
	end

	for _, binding in ipairs(Addon.db.global.bindings) do
		table.insert(result, binding)
	end

	return ipairs(result)
end

--@debug@

--- @param from string
function Clicked:UpgradeDatabase(from)
	Addon:UpgradeDatabase(from)
	Clicked:ReloadBindings(true)
end

--@end-debug@

-- Private addon API

--- @return Binding
function Addon:GetNewBindingTemplate()
	--- @type Binding
	local template = {
		actionType = Addon.BindingTypes.SPELL,
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
			cancelQueuedSpell = false,
			cancelForm = false,
			targetUnitAfterCast = false
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
			channeling = GetNegatableStringLoadOptionTemplate(),
			flying = GetNegatableLoadOptionTemplate(),
			dynamicFlying = GetNegatableLoadOptionTemplate(),
			flyable = GetNegatableLoadOptionTemplate(),
			advancedFlyable = GetNegatableLoadOptionTemplate(),
			specialization = GetTriStateLoadOptionTemplate(1),
			talent = GetMultiFieldLoadOptionTemplate(""),
			pvpTalent = GetMultiFieldLoadOptionTemplate(""),
			warMode = GetNegatableLoadOptionTemplate()
		}
	}

	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.MOP then
		local specIndex = GetSpecialization()
		specIndex = specIndex == 5 and 1 or specIndex -- Initial spec
		template.load.specialization = GetTriStateLoadOptionTemplate(specIndex)
	elseif Addon.EXPANSION_LEVEL >= Addon.EXPANSION.CATA then
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
		unit = Addon.TargetUnits.DEFAULT,
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
---@param scope BindingScope
function Addon:ChangeScope(item, scope)
	assert(type(item) == "table", "bad argument #1, expected table but got " .. type(item))
	assert(type(scope) == "number", "bad argument #1, expected number but got " .. type(scope))

	if item.uid == nil then
		error("Can only change the scope of a binding or group")
	end

	if item.scope == scope then
		return
	end

	if item.type == Clicked.DataObjectType.GROUP then
		--- @cast item Group

		local id = item.uid
		local bindings = Clicked:GetByParent(id)

		if Clicked:DeleteGroup(item) then
			self:RegisterGroup(item, scope)

			for _, binding in ipairs(bindings) do
				self:RegisterBinding(binding, scope)
				binding.parent = item.uid
			end
		end
	else
		--- @cast item Binding

		if Clicked:DeleteBinding(item) then
			self:RegisterBinding(item, scope)
			item.parent = nil
		end
	end
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
			Clicked:ReloadBinding(binding, true)
			break
		end
	end
end

--- @param binding Binding
--- @param scope BindingScope
function Addon:RegisterBinding(binding, scope)
	assert(type(binding) == "table", "bad argument #1, expected table but got " .. type(binding))

	binding.uid = binding.uid or self:GetNextUid()
	binding.scope = scope

	if scope == Addon.BindingScope.GLOBAL then
		table.insert(Addon.db.global.bindings, binding)
	elseif scope == Addon.BindingScope.PROFILE then
		table.insert(Addon.db.profile.bindings, binding)
	else
		error("Unknown binding scope " .. scope)
	end

	Clicked:ReloadBinding(binding, true)
end

--- @param group Group
--- @param scope BindingScope
function Addon:RegisterGroup(group, scope)
	assert(type(group) == "table", "bad argument #1, expected table but got " .. type(group))

	group.uid = group.uid or self:GetNextUid()
	group.scope = scope

	if scope == Addon.BindingScope.GLOBAL then
		table.insert(Addon.db.global.groups, group)
	elseif scope == Addon.BindingScope.PROFILE then
		table.insert(Addon.db.profile.groups, group)
	else
		error("Unknown binding scope " .. scope)
	end

	self:UpdateLookupTable(group)
end

--- @param original Binding
--- @return Binding
function Addon:CloneBinding(original)
	assert(type(original) == "table", "bad argument #1, expected table but got " .. type(original))

	local clone = CopyTable(original)
	clone.uid = nil
	clone.keybind = ""

	self:RegisterBinding(clone, original.scope)
	return clone
end

--- @param item DataObject
--- @return table
function Addon:GetContainingDatabase(item)
	assert(type(item) == "table", "bad argument #1, expected table but got " .. type(item))

	if item.scope == Addon.BindingScope.GLOBAL then
		return Addon.db.global
	elseif item.scope == Addon.BindingScope.PROFILE then
		return Addon.db.profile
	else
		error("Unknown binding scope " .. item.scope)
	end
end

-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
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

local TYPE_BINDING = 1
local TYPE_GROUP = 2

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
				}
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
		type = TYPE_GROUP,
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

--- Attempt to get a binding group with the specified identifier.
---
--- @param identifier integer
--- @return Group?
function Clicked:GetGroupById(identifier)
	assert(type(identifier) == "number", "bad argument #1, expected number but got " .. type(identifier))

	for _, group in self:IterateGroups() do
		if group.uid == identifier then
			return group
		end
	end

	return nil
end

--- Get a list of all bindings that are part of the specified group.
---
--- @param identifier integer
--- @return Binding[]
function Clicked:GetBindingsInGroup(identifier)
	assert(type(identifier) == "number", "bad argument #1, expected number but got " .. type(identifier))

	--- @type Binding[]
	local bindings = {}

	for _, binding in self:IterateConfiguredBindings() do
		if binding.parent == identifier then
			table.insert(bindings, binding)
		end
	end

	return bindings
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
		type = TYPE_BINDING,
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
		},
		integrations = {
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

	if self:IsGroup(item) then
		--- @cast item Group

		local id = item.uid
		local bindings = Clicked:GetBindingsInGroup(id)

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

--- @param original Binding
--- @param replacement Binding
function Addon:ReplaceBinding(original, replacement)
	assert(type(original) == "table", "bad argument #1, expected table but got " .. type(original))
	assert(type(replacement) == "table", "bad argument #2, expected table but got " .. type(replacement))

	for index, binding in Clicked:IterateConfiguredBindings() do
		if binding == original then
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
end

--- @param original Binding
--- @return Binding
function Addon:CloneBinding(original)
	assert(type(original) == "table", "bad argument #1, expected table but got " .. type(original))

	local clone = Addon:DeepCopyTable(original)
	clone.uid = nil
	clone.keybind = ""
	clone.integrations = {}

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

--- Check if the specified string is a group identifier.
---
--- @param item DataObject
--- @return boolean
function Addon:IsGroup(item)
	assert(type(item) == "table", "bad argument #1, expected table but got " .. type(item))
	return item.type == TYPE_GROUP
end

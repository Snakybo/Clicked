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

local GROUP_IDENTIFIER_PREFIX = "group-"
local BINDING_IDENTIFIER_PREFIX = "binding-"

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
	--- @type AceDBObject-3.0
	local database = {
		global = {
			version = nil,
			groups = {},
			bindings = {},
			nextGroupId = 1,
			nextBindingId = 1
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
			nextGroupId = 1,
			nextBindingId = 1
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
		name = Addon.L["New Group"],
		displayIcon = "Interface\\ICONS\\INV_Misc_QuestionMark",
	}

	Addon:RegisterGroup(group, Addon.BindingScope.PROFILE)
	return group
end

--- Delete a binding group. If the group is not empty, it will also delete all child-bindings.
---
--- @param group Group
function Clicked:DeleteGroup(group)
	assert(type(group) == "table", "bad argument #1, expected table but got " .. type(group))

	local db = Addon:GetContainingDatabase(group)

	for i, e in ipairs(db.groups) do
		if e.identifier == group.identifier then
			table.remove(db.groups, i)
			break
		end
	end

	for i = #db.bindings, 1, -1 do
		local binding = db.bindings[i]

		if binding.parent == group.identifier then
			table.remove(db.bindings, i)
		end
	end

	self:ReloadBindings(true)
end

--- Attempt to get a binding group with the specified identifier.
---
--- @param identifier string
--- @return Group?
function Clicked:GetGroupById(identifier)
	assert(type(identifier) == "string", "bad argument #1, expected string but got " .. type(identifier))

	for _, group in self:IterateGroups() do
		if group.identifier == identifier then
			return group
		end
	end

	return nil
end

--- Get a list of all bindings that are part of the specified group.
---
--- @param identifier string
--- @return Binding[]
function Clicked:GetBindingsInGroup(identifier)
	assert(type(identifier) == "string", "bad argument #1, expected string but got " .. type(identifier))

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
	--- @type Group
	local result = {}

	for _, binding in ipairs(Addon.db.profile.groups) do
		table.insert(result, binding)
	end

	for _, binding in ipairs(Addon.db.global.groups) do
		table.insert(result, binding)
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
function Clicked:DeleteBinding(binding)
	assert(type(binding) == "table", "bad argument #1, expected table but got " .. type(binding))

	local db = Addon:GetContainingDatabase(binding)

	for index, item in ipairs(db.bindings) do
		if binding.identifier == item.identifier then
			table.remove(db.bindings, index)
			break
		end
	end

	self:ReloadBindings(true)
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
		type = Addon.BindingTypes.SPELL,
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
			convertValueToId = true,
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
			flyable = GetNegatableLoadOptionTemplate(),
			advancedFlyable = GetNegatableLoadOptionTemplate(),
			specialization = GetTriStateLoadOptionTemplate(1),
			talent = GetTriStateLoadOptionTemplate(1),
			pvpTalent = GetTriStateLoadOptionTemplate(1),
			warMode = GetNegatableLoadOptionTemplate()
		},
		integrations = {
		}
	}

	if Addon:IsGameVersionAtleast("RETAIL") then
		--- @type number
		local specIndex = GetSpecialization()

		-- Initial spec
		if specIndex == 5 then
			specIndex = 1
		end

		template.load.specialization = GetTriStateLoadOptionTemplate(specIndex)
		template.load.talent = GetMultiFieldLoadOptionTemplate("")
	elseif Addon:IsGameVersionAtleast("WOTLK") then
		local specIndex = GetActiveTalentGroup()
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

--- @param scope BindingScope
--- @return string
--- @return integer
function Addon:GetNextBindingIdentifier(scope)
	scope = scope or Addon.BindingScope.PROFILE

	local identifier

	if scope == Addon.BindingScope.GLOBAL then
		identifier = Addon.db.global.nextBindingId
		Addon.db.global.nextBindingId = identifier + 1
	elseif scope == Addon.BindingScope.PROFILE then
		identifier = Addon.db.profile.nextBindingId
		Addon.db.profile.nextBindingId = identifier + 1
	else
		error("Unknown binding scope " .. scope)
	end

	return scope .. "-" .. BINDING_IDENTIFIER_PREFIX .. identifier, identifier
end

--- @param scope BindingScope
--- @return string
--- @return integer
function Addon:GetNextGroupIdentifier(scope)
	scope = scope or Addon.BindingScope.PROFILE

	local identifier

	if scope == Addon.BindingScope.GLOBAL then
		identifier = Addon.db.global.nextGroupId
		Addon.db.global.nextGroupId = identifier + 1
	elseif scope == Addon.BindingScope.PROFILE then
		identifier = Addon.db.profile.nextGroupId
		Addon.db.profile.nextGroupId = identifier + 1
	else
		error("Unknown binding scope " .. scope)
	end

	return scope .. "-" .. GROUP_IDENTIFIER_PREFIX .. identifier, identifier
end

--- Change the scope of a binding or entire group.
--- This will re-register the binding (or group) within the target database.
---
---@param item Binding|Group
---@param scope BindingScope
function Addon:ChangeScope(item, scope)
	assert(type(item) == "table", "bad argument #1, expected table but got " .. type(item))
	assert(type(scope) == "number", "bad argument #1, expected number but got " .. type(scope))

	if item.identifier == nil then
		error("Can only change the scope of a binding or group")
	end

	if item.scope == scope then
		return
	end

	if self:IsGroup(item) then
		--- @cast item Group

		local id = item.identifier
		local bindings = Clicked:GetBindingsInGroup(id)

		Clicked:DeleteGroup(item)
		self:RegisterGroup(item, scope)

		for _, binding in ipairs(bindings) do
			self:RegisterBinding(binding, scope)
			binding.parent = item.identifier
		end
	else
		--- @cast item Binding

		Clicked:DeleteBinding(item)
		self:RegisterBinding(item, scope)
		item.parent = nil
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

	binding.identifier = self:GetNextBindingIdentifier(scope)
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

	group.identifier = self:GetNextGroupIdentifier(scope)
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
	clone.keybind = ""
	clone.integrations = {}

	self:RegisterBinding(clone, original.scope)
	return clone
end

--- @param item Binding|Group
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
--- @param item Binding|Group
--- @return boolean
function Addon:IsGroup(item)
	assert(type(item) == "table", "bad argument #1, expected table but got " .. type(item))
	return string.find(item.identifier, GROUP_IDENTIFIER_PREFIX) ~= nil
end

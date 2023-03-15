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
local _, Addon = ...

-- Local support functions

--- @param default string|boolean
--- @return Binding.LoadOption
local function GetLoadOptionTemplate(default)
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
--- @return Binding.NegatableTriStateLoadOption
local function GetNegatableTriStateLoadOptionTemplate(default)
	local template = {
		selected = 0,
		negated = false,
		single = default,
		multiple = {
			default
		}
	}

	return template
end

--- @param default number|string
--- @return Binding.TriStateLoadOption
local function GetTriStateLoadOptionTemplate(default)
	local template = {
		selected = 0,
		single = default,
		multiple = {
			default
		}
	}

	return template
end

--- @param default string|boolean
--- @return Binding.MutliFieldLoadOption
local function GetMultiFieldLoadOptionTemplate(default)
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
--- @return Database
function Clicked:GetDatabaseDefaults()
	local database = {
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
	Addon:UpgradeDatabaseProfile(Addon.db.profile)

	if Addon.db.profile.options.minimap.hide then
		LibDBIcon:Hide("Clicked")
	else
		LibDBIcon:Show("Clicked")
	end

	Addon:BlacklistOptions_Refresh()
	Clicked:ReloadBindings(true)
end

--- Create a new binding group. Groups are purely cosmetic and have no additional impact on binding functionality.
--- @return Group
function Clicked:CreateGroup()
	local identifier = Addon.db.profile.nextGroupId
	Addon.db.profile.nextGroupId = Addon.db.profile.nextGroupId + 1

	local group = {
		name = Addon.L["New Group"],
		displayIcon = "Interface\\ICONS\\INV_Misc_QuestionMark",
		identifier = "group-" .. identifier
	}

	table.insert(Addon.db.profile.groups, group)

	return group
end

--- Delete a binding group. If the group is not empty, it will also delete all child-bindings.
--- @param group Group
function Clicked:DeleteGroup(group)
	assert(type(group) == "table", "bad argument #1, expected table but got " .. type(group))

	for i, e in ipairs(Addon.db.profile.groups) do
		if e.identifier == group.identifier then
			table.remove(Addon.db.profile.groups, i)
			break
		end
	end

	for i = #Addon.db.profile.bindings, 1, -1 do
		local binding = Addon.db.profile.bindings[i]

		if binding.parent == group.identifier then
			table.remove(Addon.db.profile.bindings, i)
		end
	end
end

--- Attempt to get a binding group with the specified identifier.
--- @param identifier string
--- @return Group
function Clicked:GetGroupById(identifier)
	assert(type(identifier) == "string", "bad argument #1, expected string but got " .. type(identifier))

	for _, group in ipairs(Addon.db.profile.groups) do
		if group.identifier == identifier then
			return group
		end
	end

	return nil
end

--- Iterate trough all configured groups. This function can be used in a `for in` loop.
---
--- @return function iterator
--- @return table t
--- @return number i
function Clicked:IterateGroups()
	return ipairs(Addon.db.profile.groups)
end

--- Create a new binding. This will create and return a new binding, however it will not automatically reload the active bindings, after configuring the
--- returned binding (to make it loadable), manually reload the active bindings using `ReloadBindings`.
---
--- @return Binding
--- @see Clicked#ReloadBindings
function Clicked:CreateBinding()
	local binding = Addon:GetNewBindingTemplate()
	table.insert(Addon.db.profile.bindings, binding)

	return binding
end

--- Delete a binding. If the binding exists it will delete it from the database, if the binding is currently loaded, it will automatically reload the active
--- bindings.
--- @param binding Binding The binding to delete
function Clicked:DeleteBinding(binding)
	assert(Addon:IsBindingType(binding), "bad argument #1, expected Binding but got " .. type(binding))

	for index, other in ipairs(Addon.db.profile.bindings) do
		if other == binding then
			table.remove(Addon.db.profile.bindings, index)
			break
		end
	end
end

--- Iterate through all configured bindings, this will also include any bindings avaialble in the current profile that are not currently loaded. This function
--- can be used in a `for in` loop.
--- @return function iterator
--- @return table t
--- @return number i
function Clicked:IterateConfiguredBindings()
	return ipairs(Addon.db.profile.bindings)
end

--@debug@

--- @param from string
function Clicked:UpgradeDatabase(from)
	Addon:UpgradeDatabaseProfile(Addon.db.profile, from)
	Clicked:ReloadBindings(true)
end

--@end-debug@

-- Private addon API

--- @return Binding
function Addon:GetNewBindingTemplate()
	local template = {
		type = Addon.BindingTypes.SPELL,
		identifier = Addon:GetNextBindingIdentifier(),
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
			playerNameRealm = GetLoadOptionTemplate(UnitName("player")),
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
	local template = {
		unit = Addon.TargetUnits.DEFAULT,
		hostility = Addon.TargetHostility.ANY,
		vitals = Addon.TargetVitals.ANY
	}

	return template
end

--- @return integer
function Addon:GetNextBindingIdentifier()
	local identifier = Addon.db.profile.nextBindingId
	Addon.db.profile.nextBindingId = identifier + 1

	return identifier
end

--- @param original Binding
--- @param replacement Binding
function Addon:ReplaceBinding(original, replacement)
	assert(Addon:IsBindingType(original), "bad argument #1, expected Binding but got " .. type(original))
	assert(Addon:IsBindingType(replacement), "bad argument #2, expected Binding but got " .. type(replacement))

	for index, binding in ipairs(Addon.db.profile.bindings) do
		if binding == original then
			Addon.db.profile.bindings[index] = replacement
			Clicked:ReloadBinding(binding, true)
			break
		end
	end
end

---@param original Binding
---@return Binding
function Addon:CloneBinding(original)
	assert(Addon:IsBindingType(original), "bad argument #1, expected Binding but got " .. type(original))

	local clone = Addon:DeepCopyTable(original)
	clone.identifier = Addon:GetNextBindingIdentifier()
	clone.keybind = ""
	clone.integrations = {}

	table.insert(Addon.db.profile.bindings, clone)
	Clicked:ReloadBinding(clone, true)

	return clone
end

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
				bindUnassignedModifiers = true,
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
	Clicked:ReloadActiveBindings()
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
--- returned binding (to make it loadable), manually reload the active bindings using `ReloadActiveBindings`.
---
--- @return Binding
--- @see Clicked#ReloadActiveBindings
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
	Clicked:ReloadActiveBindings()
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
	Addon.db.profile.nextBindingId = Addon.db.profile.nextBindingId + 1

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
			Clicked:ReloadActiveBindings()
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
	Clicked:ReloadActiveBindings()

	return clone
end

--- Upgrade the version of the specified profile to the latest version, this process is incremental and will upgrade a profile with intermediate steps of all
--- versions in between the input version and the current version.
---
--- For example, if the current version is `0.17` and the input profile is `0.14`, it will incrementally upgrade by going `0.14`->`0.15`->`0.16`->`0.17`.
--- This will ensure support for even very old profiles.
---
--- @param profile table
--- @param from string|nil
function Addon:UpgradeDatabaseProfile(profile, from)
	from = from or profile.version

	-- Don't use any constants in this function to prevent breaking the updater
	-- when the value of a constant changes. Always use direct values that are
	-- read from the database.

	if from == nil then
		-- Incredible hack because I accidentially removed the serialized version
		-- number in 0.12.0. This will check for all the characteristics of a 0.12
		-- profile to determine if it's an existing profile, or a new profile.
		local function IsProfileFrom_0_12()
			if profile.bindings and profile.bindings.next and profile.bindings.next > 1 then
				return true
			end

			if profile.groups and profile.groups.next and profile.groups.next > 1 then
				return true
			end

			if profile.blacklist and #profile.blacklist > 0 then
				return true
			end

			return false
		end

		local function IsProfileFrom_0_4()
			if profile.bindings and #profile.bindings > 0 then
				return true
			end

			return false
		end

		if IsProfileFrom_0_12() then
			from = "0.12.0"
		elseif IsProfileFrom_0_4() then
			from = "0.4.0"
		else
			profile.version = Clicked.VERSION
			return
		end
	end

	if from == Clicked.VERSION then
		return
	end

	local function FinalizeVersionUpgrade(newVersion)
		print(Addon:GetPrefixedAndFormattedString(Addon.L["Upgraded profile from version %s to version %s"], from or "UNKNOWN", newVersion))
		profile.version = newVersion
		from = newVersion
	end

	-- version 0.4.x to 0.5.0
	if string.sub(from, 1, 3) == "0.4" then
		for _, binding in ipairs(profile.bindings) do
			if #binding.targets > 0 and binding.targets[1].unit == "GLOBAL" then
				binding.targetingMode = "GLOBAL"
				binding.targets = {
					{
						unit = "TARGET",
						type = "ANY"
					}
				}
			else
				binding.targetingMode = "DYNAMIC_PRIORITY"
			end

			binding.load.inGroup = {
				selected = false,
				state = "IN_GROUP_PARTY_OR_RAID"
			}

			binding.load.playerInGroup = {
				selected = false,
				player = ""
			}
		end

		FinalizeVersionUpgrade("0.5.0")
	end

	-- version 0.5.x to 0.6.0
	if string.sub(from, 1, 3) == "0.5" then
		for _, binding in ipairs(profile.bindings) do
			binding.load.stance = {
				selected = 0,
				single = 1,
				multiple = {
					1
				}
			}

			binding.load.talent = {
				selected = 0,
				single = 1,
				multiple = {
					1
				}
			}
		end

		FinalizeVersionUpgrade("0.6.0")
	end

	-- version 0.6.x to 0.7.0
	if string.sub(from, 1, 3) == "0.6" then
		profile.blacklist = {}

		for _, binding in ipairs(profile.bindings) do
			binding.primaryTarget = {
				unit = binding.targets[1].unit,
				hostility = binding.targets[1].type
			}

			binding.secondaryTargets = binding.targets
			table.remove(binding.secondaryTargets, 1)

			for _, target in ipairs(binding.secondaryTargets) do
				target.hostility = target.type
				target.type = nil
			end

			if binding.type == "MACRO" then
				binding.primaryTarget = {
					unit = "GLOBAL",
					hostility = "ANY"
				}
			elseif binding.type == "UNIT_SELECT" or binding.type == "UNIT_MENU" then
				binding.primaryTarget = {
					unit = "HOVERCAST",
					hostility = "ANY"
				}
			else
				if binding.targetingMode == "HOVERCAST" then
					binding.primaryTarget = {
						unit = "HOVERCAST",
						hostility = "ANY"
					}
				elseif binding.targetingMode == "GLOBAL" then
					binding.primaryTarget = {
						unit = "GLOBAL",
						hostility = "ANY"
					}
				end
			end

			-- Run this sanity check last, to force any bindings using the left
			-- or right mouse buttons to be HOVERCAST.
			if binding.keybind == "BUTTON1" or binding.keybind == "BUTTON2" then
				binding.primaryTarget = {
					unit = "HOVERCAST",
					hostility = binding.primaryTarget.hostility
				}
			end

			binding.action.stopcasting = binding.action.stopCasting
			binding.action.stopCasting = nil

			binding.action.macrotext = binding.action.macro
			binding.action.macro = nil

			binding.action.macroMode = "FIRST"

			binding.targets = nil
			binding.targetingMode = nil
		end

		FinalizeVersionUpgrade("0.7.0")
	end

	-- version 0.7.x to 0.8.0
	if string.sub(from, 1, 3) == "0.7" then
		for _, binding in ipairs(profile.bindings) do
			binding.primaryTarget.vitals = "ANY"

			if binding.primaryTarget.unit == "GLOBAL" then
				binding.primaryTarget.unit = "DEFAULT"
			end

			for _, target in ipairs(binding.secondaryTargets) do
				if target.unit == "GLOBAL" then
					target.unit = "DEFAULT"
				end

				target.vitals = "ANY"
			end

			binding.load.combat.value = binding.load.combat.state
			binding.load.combat.state = nil

			binding.load.spellKnown.value = binding.load.spellKnown.spell
			binding.load.spellKnown.spell = nil

			binding.load.inGroup.value = binding.load.inGroup.state
			binding.load.inGroup.state = nil

			binding.load.playerInGroup.value = binding.load.playerInGroup.player
			binding.load.playerInGroup.player = nil

			binding.load.pet = {
				selected = false,
				value = "ACTIVE"
			}

			if Addon:IsGameVersionAtleast("RETAIL") then
				binding.load.pvpTalent = {
					selected = 0,
					single = 1,
					multiple = {
						1
					}
				}

				binding.load.warMode = {
					selected = false,
					value = "IN_WAR_MODE"
				}
			end

			binding.actions = {
				spell = {
					displayName = binding.action.spell,
					displayIcon = "",
					value = binding.action.spell,
					interruptCurrentCast = binding.action.stopcasting
				},
				item = {
					displayName = binding.action.item,
					displayIcon = "",
					value = binding.action.item,
					interruptCurrentCast = binding.action.stopcasting
				},
				macro = {
					displayName = "",
					displayIcon = "",
					value = binding.action.macrotext,
					mode = binding.action.macroMode
				},
				unitSelect = {
					displayName = "",
					displayIcon = ""
				},
				unitMenu = {
					displayName = "",
					displayIcon = ""
				}
			}

			binding.action = nil
			binding.icon = nil
		end

		profile.options = {
			onKeyDown = false
		}

		FinalizeVersionUpgrade("0.8.0")
	end

	-- 0.8.x to 0.9.0
	if string.sub(from, 1, 3) == "0.8" then
		for _, binding in ipairs(profile.bindings) do
			binding.load.form = {
				selected = 0,
				single = 1,
				multiple = {
					1
				}
			}
			binding.load.stance = nil

			binding.actions.spell.startAutoAttack = true
			binding.actions.item.startAutoAttack = true
			binding.actions.item.stopCasting = nil
		end

		Addon:ShowInformationPopup("Clicked: Binding stance/shapeshift form load options have been reset, sorry for the inconvenience.")

		FinalizeVersionUpgrade("0.9.0")
	end

	-- 0.9.x to 0.10.0
	if string.sub(from, 1, 3) == "0.9" then
		profile.bindings.next = 1

		for _, binding in ipairs(profile.bindings) do
			binding.actions.spell.startAutoAttack = nil
			binding.actions.item.startAutoAttack = nil

			binding.identifier = profile.bindings.next
			profile.bindings.next = profile.bindings.next + 1

			local class = select(2, UnitClass("player"))
			binding.load.class = {
				selected = 0,
				single = class,
				multiple = {
					class
				}
			}

			local race = select(2, UnitRace("player"))
			binding.load.race = {
				selected = 0,
				single = race,
				multiple = {
					race
				}
			}

			binding.load.playerNameRealm = {
				selected = false,
				value = UnitName("player")
			}
		end

		profile.groups = {
			next = 1
		}

		FinalizeVersionUpgrade("0.10.0")
	end

	-- 0.10.x to 0.11.0
	if string.sub(from, 1, 4) == "0.10" then
		for _, binding in ipairs(profile.bindings) do
			local hovercast = {
				enabled = false,
				hostility = "ANY",
				vitals = "ANY"
			}

			local regular = {
				enabled = false
			}

			if binding.primaryTarget.unit == "HOVERCAST" then
				hovercast.enabled = true
				hovercast.hostility = binding.primaryTarget.hostility
				hovercast.vitals = binding.primaryTarget.vitals

				table.insert(regular, {
					unit = "DEFAULT",
					hostility = "ANY",
					vitals = "ANY"
				})
			else
				if binding.primaryTarget.unit == "MOUSEOVER" and Addon:IsMouseButton(binding.keybind) then
					hovercast.enabled = true
					hovercast.hostility = binding.primaryTarget.hostility
					hovercast.vitals = binding.primaryTarget.vitals
				end

				regular.enabled = true
				table.insert(regular, binding.primaryTarget)

				for _, target in ipairs(binding.secondaryTargets) do
					table.insert(regular, target)
				end
			end

			if binding.type == Addon.BindingTypes.MACRO then
				while #regular > 0 do
					table.remove(regular, 1)
				end

				regular[1] = Addon:GetNewBindingTargetTemplate()

				hovercast.hostility = Addon.TargetHostility.ANY
				hovercast.vitals = Addon.TargetVitals.ANY
			end

			binding.targets = {
				hovercast = hovercast,
				regular = regular
			}

			binding.primaryTarget = nil
			binding.secondaryTargets = nil
		end

		for _, group in ipairs(profile.groups) do
			group.displayIcon = group.icon
			group.icon = nil
		end

		FinalizeVersionUpgrade("0.11.0")
	end

	-- 0.11.x to 0.12.0
	if string.sub(from, 1, 4) == "0.11" then
		for _, binding in ipairs(profile.bindings) do
			binding.action = {
				spellValue = binding.actions.spell.value,
				itemValue = binding.actions.item.value,
				macroValue = binding.actions.macro.value,
				macroMode = binding.actions.macro.mode,
				interrupt = binding.type == Addon.BindingTypes.SPELL and binding.actions.spell.interruptCurrentCast or binding.type == Addon.BindingTypes.ITEM and binding.actions.item.interruptCurrentCast or false,
				allowStartAttack = true
			}

			binding.cache = {
				displayName = "",
				displayIcon = ""
			}

			binding.actions = nil
		end

		FinalizeVersionUpgrade("0.12.0")
	end

	-- 0.12.x to 0.13.0
	if string.sub(from, 1, 4) == "0.12" then
		for _, binding in ipairs(profile.bindings) do
			binding.action.cancelQueuedSpell = false
		end

		FinalizeVersionUpgrade("0.13.0")
	end

	-- 0.13.x to 0.14.0
	if string.sub(from, 1, 4) == "0.13" then
		for _, binding in ipairs(profile.bindings) do
			binding.load.covenant = {
				selected = 0,
				single = 1,
				multiple = {
					1
				}
			}

			binding.action.targetUnitAfterCast = false
		end

		FinalizeVersionUpgrade("0.14.0")
	end

	-- 0.14.x to 0.15.0
	if string.sub(from, 1, 4) == "0.14" then
		for _, binding in ipairs(profile.bindings) do
			binding.load.instanceType = {
				selected = 0,
				single = "NONE",
				multiple = {
					"NONE"
				}
			}
		end

		FinalizeVersionUpgrade("0.15.0")
	end

	-- 0.15.x to 0.16.0
	if string.sub(from, 1, 4) == "0.15" then
		profile.options.tooltips = false

		for _, binding in ipairs(profile.bindings) do
			binding.integrations = {}
		end

		FinalizeVersionUpgrade("0.16.0")
	end

	-- 0.16.x to 0.17.0
	if string.sub(from, 1, 4) == "0.16" then
		profile.options.minimap = profile.minimap
		profile.minimap = nil

		FinalizeVersionUpgrade("0.17.0")
	end

	-- 0.17.x to 1.0.0
	if string.sub(from, 1, 4) == "0.17" then
		for _, binding in ipairs(profile.bindings) do
			binding.action.macroName = Addon.L["Run custom macro"]
			binding.action.macroIcon = [[Interface\ICONS\INV_Misc_QuestionMark]]

			if binding.type == Addon.BindingTypes.MACRO then
				binding.action.macroName = binding.cache.displayName
				binding.action.macroIcon = binding.cache.displayIcon
			end

			binding.action.executionOrder = 1

			binding.load.combat.value = binding.load.combat.value == "IN_COMBAT"
			binding.load.pet.value = binding.load.pet.value == "ACTIVE"

			if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
				binding.load.warMode.value = binding.load.warMode.value == "IN_WAR_MODE"

				binding.load.flying = {
					selected = false,
					value = true
				}

				binding.load.flyable = {
					selected = false,
					value = true
				}
			end

			binding.load.stealth = {
				selected = false,
				value = true
			}

			binding.load.mounted = {
				selected = false,
				value = true
			}

			binding.load.outdoors = {
				selected = false,
				value = true
			}

			binding.load.swimming = {
				selected = false,
				value = true
			}

			binding.load.zoneName = {
				selected = false,
				value = ""
			}

			binding.cache = nil
		end

		local function GetRelatedBindings(binding)
			local result = {}

			for _, other in ipairs(profile.bindings) do
				if other ~= binding and other.keybind == binding.keybind and other.type ~= "APPEND" and other.action.macroMode ~= "APPEND" then
					table.insert(result, other)
				end
			end

			return ipairs(result)
		end

		for _, binding in ipairs(profile.bindings) do
			if binding.type == Addon.BindingTypes.MACRO then
				if binding.action.macroMode == "FIRST" then
					for _, other in GetRelatedBindings(binding) do
						other.action.executionOrder = other.action.executionOrder + 1
					end
				elseif binding.action.macroMode == "LAST" then
					local last = 0

					for _, other in GetRelatedBindings(binding) do
						if other.action.executionOrder > last then
							last = other.action.executionOrder
						end
					end

					binding.action.executionOrder = last + 1
				elseif binding.action.macroMode == "Append" then
					binding.type = "APPEND"
				end

			end

			binding.action.macroMode = nil
		end

		FinalizeVersionUpgrade("1.0.0")
	end

	-- 1.0.x to 1.1.0
	if string.sub(from, 1, 3) == "1.0" then
		for _, binding in ipairs(profile.bindings) do
			binding.targets.regularEnabled = binding.targets.regular.enabled
			binding.targets.regular.enabled = nil

			binding.targets.hovercastEnabled = binding.targets.hovercast.enabled
			binding.targets.hovercast.enabled = nil
		end

		profile.nextGroupId = profile.groups.next
		profile.groups.next = nil

		profile.nextBindingId = profile.bindings.next
		profile.bindings.next = nil

		FinalizeVersionUpgrade("1.1.0")
	end

	-- 1.1.x to 1.2.0
	if string.sub(from, 1, 3) == "1.1" then
		for _, binding in ipairs(profile.bindings) do
			binding.load.equipped = {
				selected = false,
				value = ""
			}
		end

		FinalizeVersionUpgrade("1.2.0")
	end

	-- 1.2.x to 1.3.0
	if string.sub(from, 1, 3) == "1.2" then
		for _, binding in ipairs(profile.bindings) do
			binding.action.startAutoAttack = binding.action.allowStartAttack
			binding.action.startPetAttack = false

			binding.action.allowStartAttack = nil
		end

		FinalizeVersionUpgrade("1.3.0")
	end

	-- 1.3.x to 1.4.0
	if string.sub(from, 1, 3) == "1.3" then
		for _, binding in ipairs(profile.bindings) do
			binding.load.channeling = {
				selected = false,
				negated = false,
				value = ""
			}

			-- Somehow `load.never` could potentially be nil in some magical circumstances..
			-- This should make sure that doesn't happen.
			if binding.load.never == nil then
				binding.load.never = false
			end
		end

		FinalizeVersionUpgrade("1.4.0")
	end

	-- 1.4.x to 1.5.0
	if string.sub(from, 1, 3) == "1.4" then
		for _, binding in ipairs(profile.bindings) do
			binding.load.flying = binding.load.flying or {
				selected = false,
				value = false
			}

			binding.load.flyable = binding.load.flyable or {
				selected = false,
				value = false
			}

			binding.load.specialization = binding.load.specialization or {
				selected = 0,
				single = 1,
				multiple = {
					1
				}
			}

			binding.load.talent = binding.load.talent or {
				selected = 0,
				single = 1,
				multiple = {
					1
				}
			}

			binding.load.pvpTalent = binding.load.pvpTalent or {
				selected = 0,
				single = 1,
				multiple = {
					1
				}
			}

			binding.load.warMode = binding.load.warMode or {
				selected = false,
				value = true
			}
		end

		FinalizeVersionUpgrade("1.5.0")
	end

	-- 1.5.x to 1.6.0
	if string.sub(from, 1, 3) == "1.5" then
		for _, binding in ipairs(profile.bindings) do
			binding.action.convertValueToId = true
		end

		FinalizeVersionUpgrade("1.6.0")
	end

	-- 1.6.x to 1.7.0
	if string.sub(from, 1, 3) == "1.6" then
		for _, binding in ipairs(profile.bindings) do
			binding.action.auraName = ""
		end

		FinalizeVersionUpgrade("1.7.0")
	end

	-- 1.7.x to 1.8.0
	if string.sub(from, 1, 3) == "1.7" then
		for _, binding in ipairs(profile.bindings) do
			binding.load.covenant = nil
			binding.load.form.negated = false
		end

		profile.options.bindUnassignedModifiers = true

		FinalizeVersionUpgrade("1.8.0")
	end

	profile.version = Clicked.VERSION
end

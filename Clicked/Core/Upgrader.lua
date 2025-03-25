---@diagnostic disable: undefined-field, assign-type-mismatch, inject-field, missing-fields

--- @class ClickedInternal
local Addon = select(2, ...)

Addon.DATA_VERSION = 13

local upgradeData = {}

-- Local support functions

local function errorhandler(err)
	return geterrorhandler()(err)
end

local function safecall(func, ...)
	if func then
		return xpcall(func, errorhandler, ...)
	end
end

--- @param profile Profile
--- @param from string
local function UpgradeLegacy(profile, from)
	local function FinalizeVersionUpgrade(newVersion)
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

			if Addon.EXPANSION_LEVEL >= Addon.Expansion.BFA then
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

			if binding.type == Clicked.ActionType.MACRO then
				while #regular > 0 do
					table.remove(regular, 1)
				end

				regular[1] = {
					unit = "DEFAULT",
					hostility = "ANY",
					vitals = "ANY"
				}

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
				interrupt = binding.type == Clicked.ActionType.SPELL and binding.actions.spell.interruptCurrentCast or binding.type == Clicked.ActionType.ITEM and binding.actions.item.interruptCurrentCast or false,
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

			if binding.type == Clicked.ActionType.MACRO then
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
			if binding.type == Clicked.ActionType.MACRO then
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

	-- 1.8.0 to 1.8.1
	if string.sub(from, 1, 5) == "1.8.0" then
		for _, binding in ipairs(profile.bindings) do
			if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
				if binding.load.talent.selected ~= 0 then
					binding.load.class.selected = 1
					binding.load.specialization.selected = 1
				end
			end
		end

		FinalizeVersionUpgrade("1.8.1")
	end

	-- 1.8.1 to 1.8.2
	if string.sub(from, 1, 5) == "1.8.1" then
		for _, binding in ipairs(profile.bindings) do
			if binding.identifier >= profile.nextBindingId then
				profile.nextBindingId = binding.identifier + 1
			end
		end

		for _, group in ipairs(profile.groups) do
			local groupId = tonumber(string.match(group.identifier, "(%d+)"))

			if groupId >= profile.nextGroupId then
				profile.nextGroupId = groupId + 1
			end
		end

		FinalizeVersionUpgrade("1.8.2")
		profile.version = 1
	end
end

--- @param db table
--- @param from integer
local function Upgrade(db, from)
	if from < 2 then
		for _, binding in ipairs(db.bindings) do
			binding.action.cancelForm = false

			if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
				binding.load.talent = {
					selected = false,
					entries = {
						{
							operation = "AND",
							negated = false,
							value = ""
						}
					}
				}

				Addon:ShowInformationPopup("Clicked: Binding talent load options have been reset, sorry for the inconvenience.")
			end
		end
	end

	if from < 3 then
		for _, binding in ipairs(db.bindings) do
			binding.load.advancedFlyable = {
				selected = false,
				value = true
			}
		end
	end

	if from < 4 then
		for _, binding in ipairs(db.bindings) do
			binding.scope = 1
			binding.identifier = "1-binding-" .. binding.identifier

			if not Addon:IsNilOrEmpty(binding.parent) then
				binding.parent = "1-" .. binding.parent
			end
		end

		for _, group in ipairs(db.groups) do
			group.scope = 1
			group.identifier = "1-" .. group.identifier
		end
	end

	if from < 5 then
		for _, binding in ipairs(db.bindings) do
			binding.load.bonusbar = {
				selected = false,
				negated = false,
				value = ""
			}
		end
	end

	if from < 6 then
		for _, binding in ipairs(db.bindings) do
			if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
				if #binding.load.talent.entries > 1 and binding.load.talent.entries[1].operation == "OR" then
					binding.load.talent.entries[1].operation = "AND"
				end

				binding.load.pvpTalent = {
					selected = false,
					entries = {
						{
							operation = "AND",
							negated = false,
							value = ""
						}
					}
				}

				Addon:ShowInformationPopup("Clicked: Binding PvP talent load options have been reset, sorry for the inconvenience.")
			end
		end
	end

	if from < 7 then
		for _, binding in ipairs(db.bindings) do
			if Addon.EXPANSION_LEVEL <= Addon.Expansion.CATA then
				binding.load.talent = {
					selected = false,
					entries = {
						{
							operation = "AND",
							negated = false,
							value = ""
						}
					}
				}

				if Addon.EXPANSION_LEVEL > Addon.Expansion.CLASSIC then
					Addon:ShowInformationPopup("Clicked: Binding talent load options have been reset, sorry for the inconvenience.")
				end
			end
		end
	end

	if from < 9 then
		Addon.db.global.nextUid = Addon.db.global.nextUid or 1

		local map = {}

		for _, group in ipairs(db.groups) do
			group.uid = Addon.db.global.nextUid
			Addon.db.global.nextUid = Addon.db.global.nextUid + 1

			map[group.identifier] = group.uid
			group.identifier = nil

			group.type = 2
		end

		for _, binding in ipairs(db.bindings) do
			if binding.parent ~= nil then
				binding.parent = map[binding.parent]
			end

			binding.uid = Addon.db.global.nextUid
			Addon.db.global.nextUid = Addon.db.global.nextUid + 1

			binding.identifier = nil

			binding.actionType = binding.type
			binding.type = 1
		end

		db.nextGroupId = nil
		db.nextBindingId = nil
	end

	if from < 10 then
		for _, binding in ipairs(db.bindings) do
			binding.load.dynamicFlying = {
				selected = false,
				value = true
			}
		end
	end

	if from < 11 then
		for _, binding in ipairs(db.bindings) do
			binding.integrations = nil
		end
	end

	if from < 12 then
		for _, binding in ipairs(db.bindings) do
			binding.load.bar = {
				selected = false,
				negated = false,
				value = ""
			}

			binding.load.specRole = {
				selected = 0,
				single = "DAMAGER",
				multiple = {
					"DAMAGER"
				}
			}

			binding.action.stopSpellTarget = true
		end
	end

	if from < 13 then
		upgradeData[13] = upgradeData[13] or {}
		upgradeData[13].seen = upgradeData[13].seen or {}

		local orphans = {}

		for i, binding in ipairs(db.bindings) do
			local function HasParent(group)
				return binding.parent == group.uid
			end

			if upgradeData[13].seen[binding.uid] then
				if binding.parent == nil or FindInTableIf(db.groups, HasParent) then
					binding.uid = Addon.db.global.nextUid
					Addon.db.global.nextUid = binding.uid + 1
				else
					table.insert(orphans, i)
				end
			elseif binding.parent ~= nil and not FindInTableIf(db.groups, HasParent) then
				binding.parent = nil
			end

			upgradeData[13].seen[binding.uid] = true
		end

		table.sort(orphans, function(a, b) return a > b end)
		for _, i in ipairs(orphans) do
			table.remove(db.bindings, i)
		end
	end
end

-- Private addon API

--- Upgrade the version of the specified profile to the latest version, this process is incremental and will upgrade a profile with intermediate steps of all
--- versions in between the input version and the current version.
---
--- Due to compatibility, this function supports both a string version number and a numeric data version. Up until 1.8.2, the version number was used to
--- upgrade. Starting at 1.8.2, the profile version number has been replaced with a data version, decoupling the semver from the data.
---
--- For example, if the current version is `0.17` and the input profile is `0.14`, it will incrementally upgrade by going `0.14`->`0.15`->`0.16`->`0.17`.
--- This will ensure support for even very old profiles.
---
--- @param from? string|integer
function Addon:UpgradeDatabase(from)
	-- Don't use any constants in this function to prevent breaking the updater
	-- when the value of a constant changes. Always use direct values that are
	-- read from the database.

	table.wipe(upgradeData)

	if not Addon.DISABLE_GLOBAL_SCOPE then
		local src = from or Addon.db.global.version or Addon.DATA_VERSION

		if type(src) == "number" then
			safecall(Upgrade, Addon.db.global, src)
			Addon.db.global.version = Addon.DATA_VERSION
		end
	end

	do
		local src = from or Addon.db.profile.version

		if src == nil then
			-- Incredible hack because I accidentially removed the serialized version
			-- number in 0.12.0. This will check for all the characteristics of a 0.12
			-- profile to determine if it's an existing profile, or a new profile.
			local function IsProfileFrom_0_12()
				if Addon.db.profile.bindings and Addon.db.profile.bindings.next and Addon.db.profile.bindings.next > 1 then
					return true
				end

				if Addon.db.profile.groups and Addon.db.profile.groups.next and Addon.db.profile.groups.next > 1 then
					return true
				end

				if Addon.db.profile.blacklist and #Addon.db.profile.blacklist > 0 then
					return true
				end

				return false
			end

			local function IsProfileFrom_0_4()
				if Addon.db.profile.bindings and #Addon.db.profile.bindings > 0 then
					return true
				end

				return false
			end

			if IsProfileFrom_0_12() then
				src = "0.12.0"
			elseif IsProfileFrom_0_4() then
				src = "0.4.0"
			else
				Addon.db.profile.version = Addon.DATA_VERSION
				return
			end
		end

		if type(src) == "string" then
			safecall(UpgradeLegacy, Addon.db.profile, src)
			src = Addon.db.profile.version
		end

		safecall(Upgrade, Addon.db.profile, src)
		Addon.db.profile.version = Addon.DATA_VERSION
	end
end

local LibDBIcon = LibStub("LibDBIcon-1.0")

--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

-- Local support functions

--- @param default string
--- @return Binding.LoadOption
local function GetLoadOptionTemplate(default)
	local template = {
		selected = false,
		value = default
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
				minimap = {
					hide = false
				}
			},
			groups = {
				next = 1
			},
			bindings = {
				next = 1
			},
			blacklist = {}
		}
	}

	return database
end

--- Reload the database, this should be called after high-level profile changes have been made, such as switching the active profile, or importing a proifle.
function Clicked:ReloadDatabase()
	Clicked:UpgradeDatabaseProfile(Addon.db.profile)

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
	local identifier = Addon.db.profile.groups.next
	Addon.db.profile.groups.next = Addon.db.profile.groups.next + 1

	local group = {
		name = L["New Group"],
		displayIcon = "Interface\\ICONS\\INV_Misc_QuestionMark",
		identifier = "group-" .. identifier
	}

	table.insert(Addon.db.profile.groups, group)

	Addon:BindingConfig_Redraw()

	return group
end

--- Delete a binding group. If the group is not empty, it will also delete all child-bindings.
--- @param group Group
function Clicked:DeleteGroup(group)
	assert(type(group) == "table", "bad argument #1, expected table but got " .. type(group))

	local shouldReloadBindings = false

	for i, e in ipairs(Addon.db.profile.groups) do
		if e.identifier == group.identifier then
			table.remove(Addon.db.profile.groups, i)
			break
		end
	end

	for i = #Addon.db.profile.bindings, 1, -1 do
		local binding = Addon.db.profile.bindings[i]

		if binding.parent == group.identifier then
			shouldReloadBindings = true
			table.remove(Addon.db.profile.bindings, i)
		end
	end

	Addon:BindingConfig_Redraw()

	if shouldReloadBindings then
		Clicked:ReloadActiveBindings()
	end
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

			if Addon:CanBindingLoad(binding) then
				Clicked:ReloadActiveBindings()
			end

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

--- Upgrade the version of the specified profile to the latest version, this process is incremental and will upgrade a profile with intermediate steps of all
--- versions in between the input version and the current version.
---
--- For example, if the current version is `0.17` and the input profile is `0.14`, it will incrementally upgrade by going `0.14`->`0.15`->`0.16`->`0.17`.
--- This will ensure support for even very old profiles.
---
--- @param profile table
--- @param from string|nil
function Clicked:UpgradeDatabaseProfile(profile, from)
	from = from or profile.version

	-- Don't use any constants in this function to prevent breaking the updater
	-- when the value of a constant changes. Always use direct values that are
	-- read from the database.

	if from == nil then
		-- Incredible hack because I accidentially removed the serialized version
		-- number in 0.12.0. This will check for all the characteristics of a 0.12
		-- profile to determine if it's an existing profile, or a new profile.
		local function IsProfileFrom_0_12()
			if profile.bindings and profile.bindings.next > 1 then
				return true
			end

			if profile.groups and profile.groups.next > 1 then
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
		print(Addon:GetPrefixedAndFormattedString(L["Upgraded profile from version %s to version %s"], from or "UNKNOWN", newVersion))
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

			if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
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

	-- 0.17.x to 0.18.0
	if string.sub(from, 1, 4) == "0.17" then
		for _, binding in ipairs(profile.bindings) do
			binding.action.macroName = ""
			binding.action.macroIcon = [[Interface\ICONS\INV_Misc_QuestionMark]]

			if binding.type == Addon.BindingTypes.MACRO then
				binding.action.macroName = binding.cache.displayName
				binding.action.macroIcon = binding.cache.displayIcon
			end

			binding.cache = nil
		end

		FinalizeVersionUpgrade("0.18.0")
	end

	profile.version = Clicked.VERSION
end

-- Private addon API

---
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
			macroName = L["Run custom macro"],
			macroIcon = [[Interface\ICONS\INV_Misc_QuestionMark]],
			macroMode = Addon.MacroMode.FIRST,
			interrupt = false,
			allowStartAttack = true,
			cancelQueuedSpell = false,
			targetUnitAfterCast = false
		},
		targets = {
			hovercast = {
				enabled = false,
				hostility = Addon.TargetHostility.ANY,
				vitals = Addon.TargetVitals.ANY
			},
			regular = {
				enabled = true,
				Addon:GetNewBindingTargetTemplate()
			}
		},
		load = {
			never = false,
			class = GetTriStateLoadOptionTemplate(select(2, UnitClass("player"))),
			race = GetTriStateLoadOptionTemplate(select(2, UnitRace("player"))),
			playerNameRealm = GetLoadOptionTemplate(UnitName("player")),
			combat = GetLoadOptionTemplate(Addon.CombatState.IN_COMBAT),
			spellKnown = GetLoadOptionTemplate(""),
			inGroup = GetLoadOptionTemplate(Addon.GroupState.PARTY_OR_RAID),
			playerInGroup = GetLoadOptionTemplate(""),
			form = GetTriStateLoadOptionTemplate(1),
			pet = GetLoadOptionTemplate(Addon.PetState.ACTIVE),
			instanceType = GetTriStateLoadOptionTemplate("NONE")
		},
		integrations = {
		}
	}

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		--- @type number
		local specIndex = GetSpecialization()

		-- Initial spec
		if specIndex == 5 then
			specIndex = 1
		end

		template.load.specialization = GetTriStateLoadOptionTemplate(specIndex)
		template.load.talent = GetTriStateLoadOptionTemplate(1)
		template.load.pvpTalent = GetTriStateLoadOptionTemplate(1)
		template.load.warMode = GetLoadOptionTemplate(Addon.WarModeState.IN_WAR_MODE)

		--- @type number
		local covenantId = C_Covenants.GetActiveCovenantID()

		-- No covenant selected
		if covenantId == 0 then
			covenantId = 1
		end

		template.load.covenant = GetTriStateLoadOptionTemplate(covenantId)
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
	local identifier = Addon.db.profile.bindings.next
	Addon.db.profile.bindings.next = Addon.db.profile.bindings.next + 1

	return identifier
end

--- @param original Binding
--- @param replacement Binding
function Addon:ReplaceBinding(original, replacement)
	assert(Addon:IsBindingType(original) "bad argument #1, expected Binding but got " .. type(original))
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

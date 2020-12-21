local LibDBIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

Clicked.EVENT_GROUPS_CHANGED = "CLICKED_GROUPS_CHANGED"

local function GetLoadOptionTemplate(default)
	return {
		selected = false,
		value = default
	}
end

local function GetTriStateLoadOptionTemplate(default)
	return {
		selected = 0,
		single = default,
		multiple = {
			default
		}
	}
end

function Clicked:GetDatabaseDefaults()
	return {
		profile = {
			version = nil,
			options = {
				onKeyDown = false
			},
			groups = {
				next = 1
			},
			bindings = {
				next = 1
			},
			blacklist = {},
			minimap = {
				hide = false
			}
		}
	}
end

function Clicked:ReloadDatabase()
	self:UpgradeDatabaseProfile(Clicked.db.profile)

	if self.db.profile.minimap.hide then
		LibDBIcon:Hide("Clicked")
	else
		LibDBIcon:Show("Clicked")
	end

	self:ReloadBlacklist()
	self:ReloadActiveBindings()
end

function Clicked:GetNewBindingTemplate()
	local template = {
		type = Clicked.BindingTypes.SPELL,
		identifier = self:GetNextBindingIdentifier(),
		keybind = "",
		action = {
			spellValue = "",
			itemValue = "",
			macroValue = "",
			macroMode = Clicked.MacroMode.FIRST,
			interrupt = false,
			allowStartAttack = true,
			cancelQueuedSpell = false
		},
		targets = {
			hovercast = {
				enabled = false,
				hostility = Clicked.TargetHostility.ANY,
				vitals = Clicked.TargetVitals.ANY
			},
			regular = {
				enabled = true,
				self:GetNewBindingTargetTemplate()
			}
		},
		load = {
			never = false,
			class = GetTriStateLoadOptionTemplate(select(2, UnitClass("player"))),
			race = GetTriStateLoadOptionTemplate(select(2, UnitRace("player"))),
			playerNameRealm = GetLoadOptionTemplate(UnitName("player")),
			combat = GetLoadOptionTemplate(Clicked.CombatState.IN_COMBAT),
			spellKnown = GetLoadOptionTemplate(""),
			inGroup = GetLoadOptionTemplate(Clicked.GroupState.PARTY_OR_RAID),
			playerInGroup = GetLoadOptionTemplate(""),
			form = GetTriStateLoadOptionTemplate(1),
			pet = GetLoadOptionTemplate(Clicked.PetState.ACTIVE)
		},
		cache = {
			displayName = "",
			displayIcon = ""
		}
	}

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		local specIndex = GetSpecialization()

		-- Initial spec
		if specIndex == 5 then
			specIndex = 1
		end

		template.load.specialization = GetTriStateLoadOptionTemplate(specIndex)
		template.load.talent = GetTriStateLoadOptionTemplate(1)
		template.load.pvpTalent = GetTriStateLoadOptionTemplate(1)
		template.load.warMode = GetLoadOptionTemplate(Clicked.WarModeState.IN_WAR_MODE)
	end

	return template
end

function Clicked:GetNewBindingTargetTemplate()
	return {
		unit = Clicked.TargetUnits.DEFAULT,
		hostility = Clicked.TargetHostility.ANY,
		vitals = Clicked.TargetVitals.ANY
	}
end

function Clicked:GetNextBindingIdentifier()
	local identifier = self.db.profile.bindings.next
	self.db.profile.bindings.next = self.db.profile.bindings.next + 1

	return identifier
end

function Clicked:CreateNewGroup()
	local identifier = self.db.profile.groups.next
	self.db.profile.groups.next = self.db.profile.groups.next + 1

	local group = {
		name = L["New Group"],
		displayIcon = "Interface\\ICONS\\INV_Misc_QuestionMark",
		identifier = "group-" .. identifier
	}

	table.insert(self.db.profile.groups, group)
	self:SendMessage(self.EVENT_GROUPS_CHANGED)

	return group
end

function Clicked:DeleteGroup(group)
	local shouldReloadBindings = false

	for i, e in ipairs(self.db.profile.groups) do
		if e.identifier == group.identifier then
			table.remove(self.db.profile.groups, i)
			break
		end
	end

	for i = #self.db.profile.bindings, 1, -1 do
		local binding = self.db.profile.bindings[i]

		if binding.parent == group.identifier then
			shouldReloadBindings = true
			table.remove(self.db.profile.bindings, i)
		end
	end

	self:SendMessage(self.EVENT_GROUPS_CHANGED)

	if shouldReloadBindings then
		self:ReloadActiveBindings()
	end
end

function Clicked:IterateGroups()
	return ipairs(self.db.profile.groups)
end

function Clicked:CreateNewBinding(silent)
	local binding = self:GetNewBindingTemplate()
	table.insert(self.db.profile.bindings, binding)

	if not silent then
		self:ReloadActiveBindings()
	end

	return binding
end

function Clicked:DeleteBinding(binding)
	for index, other in ipairs(self.db.profile.bindings) do
		if other == binding then
			table.remove(self.db.profile.bindings, index)
			self:ReloadActiveBindings()
			break
		end
	end
end

function Clicked:SetBindingAt(index, binding)
	self.db.profile.bindings[index] = binding
	self:ReloadActiveBindings()
end

function Clicked:GetBindingAt(index)
	return self.db.profile.bindings[index]
end

function Clicked:GetNumConfiguredBindings()
	return #self.db.profile.bindings
end

function Clicked:IterateConfiguredBindings()
	return ipairs(self.db.profile.bindings)
end

function Clicked:GetBindingIndex(binding)
	for i, e in ipairs(self.db.profile.bindings) do
		if e == binding then
			return i
		end
	end

	return 0
end

--- Get the active action of a binding configuration. The data for spells, items,
--- and macros is all saved in separate data structures. This function will return
--- the correct data structure for the current `type` of the binding.
---
--- @param binding table
--- @return table
function Clicked:GetActiveBindingValue(binding)
	if binding.type == Clicked.BindingTypes.SPELL then
		return binding.action.spellValue
	end

	if binding.type == Clicked.BindingTypes.ITEM then
		return binding.action.itemValue
	end

	if binding.type == Clicked.BindingTypes.MACRO then
		return binding.action.macroValue
	end

	return nil
end

function Clicked:GetBindingCache(binding)
	return binding.cache
end

function Clicked:InvalidateCache(cache)
	cache.displayName = ""
	cache.displayIcon = ""
end

-- Don't use any constants in this function to prevent breaking the updater
-- when the value of a constant changes. Always use direct values that are
-- read from the database.

function Clicked:UpgradeDatabaseProfile(profile, from)
	from = from or profile.version

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
			profile.version = self.VERSION
			return
		end
	end

	if from == self.VERSION then
		return
	end

	local function FinalizeVersionUpgrade(newVersion)
		print(self:GetPrefixedAndFormattedString(L["Upgraded profile from version %s to version %s"], from or "UNKNOWN", newVersion))
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

		self:ShowInformationPopup("Clicked: Binding stance/shapeshift form load options have been reset, sorry for the inconvenience.")

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
				if binding.primaryTarget.unit == "MOUSEOVER" and Clicked:IsMouseButton(binding.keybind) then
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

			if binding.type == Clicked.BindingTypes.MACRO then
				while #regular > 0 do
					table.remove(regular, 1)
				end

				regular[1] = Clicked:GetNewBindingTargetTemplate()

				hovercast.hostility = Clicked.TargetHostility.ANY
				hovercast.vitals = Clicked.TargetVitals.ANY
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
				interrupt = binding.type == Clicked.BindingTypes.SPELL and binding.actions.spell.interruptCurrentCast or binding.type == Clicked.BindingTypes.ITEM and binding.actions.item.interruptCurrentCast or false,
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

	profile.version = self.VERSION
end

---@diagnostic disable: undefined-field, assign-type-mismatch, inject-field, missing-fields

--- @class Addon
local Addon = select(2, ...)

Addon.DATA_VERSION = 14

local upgradeData = {}

--- @param globalDb table
--- @param db table
--- @param scope "GLOBAL"|"PROFILE"
--- @param from integer
local function UpgradeV2(globalDb, db, scope, from)
	--- @param migration integer
	local function Notify(migration)
		Clicked2:LogVerbose("Applying {scope} migration {migration}", scope, migration)
	end

	if from < 2 then
		Notify(2)

		for _, binding in ipairs(db.bindings) do
			binding.action.cancelForm = false

			if Addon.EXPANSION >= Addon.Expansion.DF then
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
		Notify(3)

		for _, binding in ipairs(db.bindings) do
			binding.load.advancedFlyable = {
				selected = false,
				value = true
			}
		end
	end

	if from < 4 then
		Notify(4)

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
		Notify(5)

		for _, binding in ipairs(db.bindings) do
			binding.load.bonusbar = {
				selected = false,
				negated = false,
				value = ""
			}
		end
	end

	if from < 6 then
		Notify(6)

		for _, binding in ipairs(db.bindings) do
			if Addon.EXPANSION >= Addon.Expansion.DF then
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
		Notify(7)

		for _, binding in ipairs(db.bindings) do
			if Addon.EXPANSION <= Addon.Expansion.CATA then
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

				if Addon.EXPANSION > Addon.Expansion.CLASSIC then
					Addon:ShowInformationPopup("Clicked: Binding talent load options have been reset, sorry for the inconvenience.")
				end
			end
		end
	end

	if from < 9 then
		Notify(9)

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
		Notify(10)

		for _, binding in ipairs(db.bindings) do
			binding.load.dynamicFlying = {
				selected = false,
				value = true
			}
		end
	end

	if from < 11 then
		Notify(11)

		for _, binding in ipairs(db.bindings) do
			binding.integrations = nil
		end
	end

	if from < 12 then
		Notify(12)

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
		Notify(13)

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

	if from < 14 then
		Notify(14)

		local FLAG_NONE = 0

		local FLAG_LOAD_ENABLED = 1
		local FLAG_LOAD_NEGATED = 2
		local FLAG_LOAD_MULTI = 4

		local FLAG_SPELL_INCLUDE_SUBTEXT = 1
		local FLAG_SPELL_MAX_RANK = 2
		local FLAG_SPELL_PREVENT_TOGGLE = 4

		local FLAG_UNIT_ALIVE = 1
		local FLAG_UNIT_DEAD = 2
		local FLAG_UNIT_FRIEND = 4
		local FLAG_UNIT_HOSTILE = 8

		local groups = {}
		local keybinds = {}
		local sets = {}
		local setOrders = {}

		local actionTypeMap = {
			SPELL = "CastAction",
			ITEM = "UseAction",
			CANCELAURA = "CancelAuraAction",
			TARGET = "TargetAction",
			MACRO = "MacroAction",
			APPEND = "AppendAction",
			MENU = "UnitMenuAction"
		}

		local optionTypeMap = {
			targetUnitAfterCast = "TargetAction",
			cancelForm = "CancelFormAction",
			cancelQueuedSpell = "CancelQueuedSpellAction",
			startPetAttack = "PetAttackAction",
			startAutoAttack = "StartAttackAction",
			stopSpellTarget = "StopSpellTargetAction",
			interrupt = "StopCastingAction"
		}

		local function GetNextUid()
			local result = globalDb.nextUid or 0
			globalDb.nextUid = result + 1
			return result
		end

		local function GetOrAddKeybind(binding, type)
			local id = type .. " " .. (binding.parent or "0") .. " " .. binding.keybind

			if keybinds[id] == nil then
				keybinds[id] = {
					uid = GetNextUid(),
					parent = binding.parent ~= nil and groups[binding.parent] or nil,
					priority = 0,
					key = binding.keybind,
					type = type,
					sets = {}
				}

				table.insert(db.keybinds, keybinds[id])
			end

			return keybinds[id]
		end

		local function GetOrAddSet(binding, keybind)
			local id = binding.uid .. " " .. binding.actionType .. " " .. keybind.type .. " " .. binding.action.executionOrder

			if sets[id] == nil then
				sets[id] = {
					parent = keybind,
					uid = GetNextUid(),
					type = actionTypeMap[binding.actionType],
					actions = {}
				}

				setOrders[sets[id]] = binding.action.executionOrder

				table.insert(keybind.sets, sets[id])
				table.sort(keybind.sets, function(a, b)
					return setOrders[a] < setOrders[b]
				end)
			end

			return sets[id]
		end

		local function GetOrAddOptionSet(binding, keybind, option)
			for i = 1, #keybind.sets do
				local set = keybind.sets[i]

				if set.type == optionTypeMap[option] then
					return set
				end
			end

			local set = {
				parent = keybind,
				uid = GetNextUid(),
				type = optionTypeMap[option],
				actions = {}
			}

			setOrders[set] = -100
			table.insert(keybind.sets, 1, set)

			return set
		end

		local function CreateFlags(target)
			if target.unit == nil or target.unit == "DEFAULT" then
				return 0
			end

			local flags = FLAG_NONE

			if target.vitals == "ALIVE" then
				flags = bit.bor(flags, FLAG_UNIT_ALIVE)
			elseif target.vitals == "DEAD" then
				flags = bit.bor(flags, FLAG_UNIT_DEAD)
			end

			if target.hostility == "HELP" then
				flags = bit.bor(flags, FLAG_UNIT_FRIEND)
			elseif target.hostility == "HARM" then
				flags = bit.bor(flags, FLAG_UNIT_HOSTILE)
			end

			return flags
		end

		local function CreateLoadConditions(binding)
			local function FromBoolean(value)
				if not value then
					return nil
				end

				return {
					state = value and FLAG_LOAD_ENABLED or FLAG_NONE,
					single = value
				}
			end

			local function FromLoadOption(value)
				if not value.selected then
					return nil
				end

				return {
					state = value.selected and FLAG_LOAD_ENABLED or FLAG_NONE,
					single = value.value
				}
			end

			local function FromTriStateLoadOption(value)
				if value.selected == 0 then
					return nil
				end

				local result = {
					state = value.selected > 0 and FLAG_LOAD_ENABLED or FLAG_NONE,
					single = value.single,
					multiple = value.multiple
				}

				if #result.multiple == 1 then
					if value.selected == 2 then
						result.single = result.multiple[1]
					end

					result.multiple = nil
				elseif value.selected == 2 then
					result.state = bit.bor(result.state, FLAG_LOAD_MULTI)
				end

				return result
			end

			local function FromNegatableTriStateLoadOption(value)
				local result = FromTriStateLoadOption(value)

				if result ~= nil and value.negated then
					result.state = bit.bor(result.state, FLAG_LOAD_NEGATED)
				end

				return result
			end

			local function FromMultiFieldLoadOption(value)
				if not value.selected then
					return nil
				end

				local result = {
					state = value.selected and FLAG_LOAD_ENABLED or FLAG_NONE,
					multiple = {{}}
				}

				for _, entry in ipairs(value.entries) do
					if entry.operation == "OR" then
						table.insert(result.multiple, {})
					end

					local item = (entry.negated and "!" or "") .. entry.value
					table.insert(result.multiple[#result.multiple], item)
				end

				return result
			end

			local function FromNegatableStringLoadOption(value)
				if not value.selected then
					return nil
				end

				local result = {
					state = value.selected and FLAG_LOAD_ENABLED or FLAG_NONE,
					single = value.value
				}

				if value.negated then
					result.state = bit.bor(result.state, FLAG_LOAD_NEGATED)
				end

				return result
			end

			return {
				never = FromBoolean(binding.load.never),
				class = FromTriStateLoadOption(binding.load.class),
				race = FromTriStateLoadOption(binding.load.race),
				playerNameRealm = FromLoadOption(binding.load.playerNameRealm),
				combat = FromLoadOption(binding.load.combat),
				spellKnown = FromLoadOption(binding.load.spellKnown),
				inGroup = FromLoadOption(binding.load.inGroup),
				playerInGroup = FromLoadOption(binding.load.playerInGroup),
				form = FromNegatableTriStateLoadOption(binding.load.form),
				pet = FromLoadOption(binding.load.pet),
				stealth = FromLoadOption(binding.load.stealth),
				mounted = FromLoadOption(binding.load.mounted),
				outdoors = FromLoadOption(binding.load.outdoors),
				swimming = FromLoadOption(binding.load.swimming),
				flying = FromLoadOption(binding.load.flying),
				dynamicFlying = FromLoadOption(binding.load.dynamicFlying),
				flyable = FromLoadOption(binding.load.flyable),
				advancedFlyable = FromLoadOption(binding.load.advancedFlyable),
				instanceType = FromTriStateLoadOption(binding.load.instanceType),
				zoneName = FromLoadOption(binding.load.zoneName),
				equipped = FromLoadOption(binding.load.equipped),
				specialization = FromTriStateLoadOption(binding.load.specialization),
				specRole = FromTriStateLoadOption(binding.load.specRole),
				talent = FromMultiFieldLoadOption(binding.load.talent),
				pvpTalent = FromMultiFieldLoadOption(binding.load.pvpTalent),
				warMode = FromLoadOption(binding.load.warMode),
				channeling = FromNegatableStringLoadOption(binding.load.channeling),
				bonusbar = FromNegatableStringLoadOption(binding.load.bonusbar),
				bar = FromNegatableStringLoadOption(binding.load.bar),
			}
		end

		local function CreateAction(set, binding, flags, target)
			local action = {
				parent = set,
				uid = GetNextUid(),
				flags = CreateFlags(flags),
				load = CreateLoadConditions(binding),
				target = target
			}

			if binding.actionType == "SPELL" then
				if type(binding.action.spellValue) == "number" then
					action.spellName = C_Spell.GetSpellName(binding.action.spellValue)
					action.spellId = binding.action.spellValue
				elseif type(binding.action.spellValue) == "string" then
					action.spellName = binding.action.spellValue
					action.spellId = C_Spell.GetSpellIDForSpellIdentifier(binding.action.spellValue) or 0
				end

				action.spellFlags = FLAG_NONE

				if binding.action.spellIncludeSubtext then
					action.spellFlags = bit.bor(action.spellFlags, FLAG_SPELL_INCLUDE_SUBTEXT)
				end

				if binding.action.spellMaxRank then
					action.spellFlags = bit.bor(action.spellFlags, FLAG_SPELL_MAX_RANK)
				end

				if binding.action.preventToggle then
					action.spellFlags = bit.bor(action.spellFlags, FLAG_SPELL_PREVENT_TOGGLE)
				end
			elseif binding.actionType == "ITEM" then
				if type(binding.action.itemValue) == "number" then
					local item

					if binding.action.itemValue <= NUM_INVSLOTS then
						item = Item:CreateFromEquipmentSlot(binding.action.itemValue)
					else
						item = Item:CreateFromItemID(binding.action.itemValue)
					end

					if not item:IsItemEmpty() then
						item:ContinueOnItemLoad(function()
							action.itemName = item:GetItemName()
						end)
					end

					action.itemId = binding.action.itemValue
				elseif type(binding.action.itemValue) == "string" then
					action.itemName = binding.action.itemValue
					action.itemId = C_Item.GetItemIDForItemInfo(binding.action.itemValue) or 0
				end
			elseif binding.actionType == "MACRO" then
				action.macroName = binding.action.macroName
				action.macroIcon = binding.action.macroIcon
				action.macroText = binding.action.macroValue
			elseif binding.actionType == "CANCELAURA" then
				action.auraName = binding.action.auraName
			elseif binding.actionType == "APPEND" then
				action.typeOverride = "AppendAction"
				action.appendText = binding.action.macroValue
			end

			return action
		end

		local function CreateOptionAction(set, binding, flags, target)
			local action = {
				parent = set,
				uid = GetNextUid(),
				flags = CreateFlags(flags),
				load = CreateLoadConditions(binding),
				target = target
			}

			return action
		end

		local function SortActions(actions)
			local function HasHostility(action)
				return bit.band(action.flags, bit.bor(FLAG_UNIT_FRIEND, FLAG_UNIT_HOSTILE)) > 0
			end

			local function HasVitals(action)
				return bit.band(action.flags, bit.bor(FLAG_UNIT_ALIVE, FLAG_UNIT_DEAD)) > 0
			end

			local function HasLoad(action, key)
				if action.load[key] == nil then
					return false
				end

				return bit.band(action.load[key].state, FLAG_LOAD_ENABLED) > 0
			end

			local function GetLoad(action, key)
				if not HasLoad(action, key) then
					return ""
				end

				if bit.band(action.load[key].state, FLAG_LOAD_MULTI) > 0 then
					local result = {}

					for i = 1, #action.load[key].multiple do
						table.insert(result, action.load[key].multiple[i])
					end

					return table.concat(result, "/")
				end

				return tostring(action.load[key].single)
			end

			local function SortFunc(left, right)
				--- @type { left: any, right: any, value: any, comparison: "eq"|"gt"|"neq" }[]
				local priority = {
					-- 1. Mouseover targets always come first
					{ left = left.target, right = right.target, value = "@mouseover", comparison = "eq" },
					{ left = left.target, right = right.target, value = "@mouseovertarget", comparison = "eq" },

					-- 2. Macro conditions take precedence over actions that don't specify them explicitly
					{ left = HasHostility(left), right = HasHostility(right), value = true, comparison = "eq" },
					{ left = HasVitals(left), right = HasVitals(right), value = true, comparison = "eq" },
					{ left = HasLoad(left, "combat"), right = HasLoad(right, "combat"), value = true, comparison = "eq" },
					{ left = GetLoad(left, "form"), right = GetLoad(right, "form"), value = 0, comparison = "gt" },
					{ left = HasLoad(left, "pet"), right = HasLoad(right, "pet"), value = true, comparison = "eq" },
					{ left = HasLoad(left, "stealth"), right = HasLoad(right, "stealth"), value = true, comparison = "eq" },
					{ left = HasLoad(left, "mounted"), right = HasLoad(right, "mounted"), value = true, comparison = "eq" },
					{ left = HasLoad(left, "outdoors"), right = HasLoad(right, "outdoors"), value = true, comparison = "eq" },
					{ left = HasLoad(left, "swimming"), right = HasLoad(right, "swimming"), value = true, comparison = "eq" },
					{ left = HasLoad(left, "flying"), right = HasLoad(right, "flying"), value = true, comparison = "eq" },
					{ left = HasLoad(left, "dynamicFlying"), right = HasLoad(right, "dynamicFlying"), value = true, comparison = "eq" },
					{ left = HasLoad(left, "flyable"), right = HasLoad(right, "flyable"), value = true, comparison = "eq" },
					{ left = HasLoad(left, "advancedFlyable"), right = HasLoad(right, "advancedFlyable"), value = true, comparison = "eq" },
					{ left = GetLoad(left, "bonusbar"), right = GetLoad(right, "bonusbar"), value = 0, comparison = "gt" },
					{ left = GetLoad(left, "bar"), right = GetLoad(right, "bar"), value = 0, comparison = "gt" },

					-- 3. Any actions that do not meet any of the criteria in this list will be placed here

					-- 4. The player, cursor, and default targets will always come last
					{ left = left.target, right = right.target, value = nil, comparison = "neq" },
					{ left = left.target, right = right.target, value = "@cursor", comparison = "neq" },
					{ left = left.target, right = right.target, value = "@player", comparison = "neq" },
				}

				for _, item in ipairs(priority) do
					local l = item.left
					local r = item.right
					local v = item.value
					local c = item.comparison

					if c == "neq" then
						c = "eq"

						local t = l
						l = r
						r = t
					end

					if c == "eq" then
						if l == v and r ~= v then
							return true
						end

						if l ~= v and r == v then
							return false
						end
					elseif c == "gt" then
						l = l and #l or 0
						r = r and #r or 0

						if l > v and r == v then
							return true
						end

						if l == v and r > v then
							return false
						end
					end
				end

				return left.uid < right.uid
			end

			table.sort(actions, SortFunc)
		end

		if scope == "GLOBAL" then
			globalDb.nextUid = 1
		end

		db.keybinds = {}

		for _, group in ipairs(db.groups) do
			local originalUid = group.uid

			group.icon = group.displayIcon
			group.displayIcon = nil
			group.type = nil
			group.scope = nil
			group.uid = GetNextUid()

			groups[originalUid] = group.uid
		end

		for _, binding in ipairs(db.bindings) do
			if binding.targets.hovercastEnabled then
				local keybind = GetOrAddKeybind(binding, 2)
				local target = Mixin({}, binding.targets.hovercast, {
					unit = "MOUSEOVER"
				})

				for k in pairs(optionTypeMap) do
					if binding.action[k] then
						local optionSet = GetOrAddOptionSet(binding, keybind, k)
						local optionAction = CreateOptionAction(optionSet, binding, target, "@mouseover")

						table.insert(optionSet.actions, optionAction)
					end
				end

				local set = GetOrAddSet(binding, keybind)
				local action = CreateAction(set, binding, target, "@mouseover")

				table.insert(set.actions, action)
			end

			if binding.targets.regularEnabled and #binding.targets.regular > 0 then
				local targetMap = {
					DEFAULT = nil,
					PLAYER = "@player",
					TARGET = "@target",
					TARGET_OF_TARGET = "@targettarget",
					PET = "@pet",
					PET_TARGET = "@pettarget",
					PARTY1 = "@party1",
					PARTY2 = "@party2",
					PARTY3 = "@party3",
					PARTY4 = "@party4",
					PARTY5 = "@party5",
					FOCUS = "@focus",
					MOUSEOVER = "@mouseover",
					MOUSEOVER_TARGET = "@mouseovertarget",
					CURSOR = "@cursor"
				}

				local keybind = GetOrAddKeybind(binding, 1)

				for k in pairs(optionTypeMap) do
					if binding.action[k] then
						for _, target in ipairs(binding.targets.regular) do
							local optionSet = GetOrAddOptionSet(binding, keybind, k)
							local optionAction = CreateOptionAction(optionSet, binding, target, target.unit ~= nil and targetMap[target.unit] or nil)

							table.insert(optionSet.actions, optionAction)
						end
					end
				end

				local set = GetOrAddSet(binding, keybind)

				for _, target in ipairs(binding.targets.regular) do
					local action = CreateAction(set, binding, target, target.unit ~= nil and targetMap[target.unit] or nil)
					table.insert(set.actions, action)
				end
			end
		end

		for _, keybind in pairs(keybinds) do
			for _, set in pairs(keybind.sets) do
				SortActions(set.actions)
			end
		end

		db.bindings = nil
	end
end

--- @param profile table
--- @param from string
local function UpgradeV1(profile, from)
	--- @param migration string
	local function Notify(migration)
		Clicked2:LogVerbose("Applying {scope#Scope} migration {migration}", Clicked2.Scope.PROFILE, migration)
	end

	local function FinalizeVersionUpgrade(newVersion)
		profile.version = newVersion
		from = newVersion
	end

	-- version 0.4.x to 0.5.0
	if string.sub(from, 1, 3) == "0.4" then
		Notify("0.5.0")

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
		Notify("0.6.0")

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
		Notify("0.7.0")

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
		Notify("0.8.0")

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

			if Addon.EXPANSION >= Addon.Expansion.BFA then
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
		Notify("0.9.0")

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
		Notify("0.10.0")

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
		Notify("0.11.0")

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

			if binding.type == Clicked2.ActionType.MACRO then
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
		Notify("0.12.0")

		for _, binding in ipairs(profile.bindings) do
			binding.action = {
				spellValue = binding.actions.spell.value,
				itemValue = binding.actions.item.value,
				macroValue = binding.actions.macro.value,
				macroMode = binding.actions.macro.mode,
				interrupt = binding.type == Clicked2.ActionType.SPELL and binding.actions.spell.interruptCurrentCast or binding.type == Clicked2.ActionType.ITEM and binding.actions.item.interruptCurrentCast or false,
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
		Notify("0.13.0")

		for _, binding in ipairs(profile.bindings) do
			binding.action.cancelQueuedSpell = false
		end

		FinalizeVersionUpgrade("0.13.0")
	end

	-- 0.13.x to 0.14.0
	if string.sub(from, 1, 4) == "0.13" then
		Notify("0.14.0")

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
		Notify("0.15.0")

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
		Notify("0.16.0")

		profile.options.tooltips = false

		for _, binding in ipairs(profile.bindings) do
			binding.integrations = {}
		end

		FinalizeVersionUpgrade("0.16.0")
	end

	-- 0.16.x to 0.17.0
	if string.sub(from, 1, 4) == "0.16" then
		Notify("0.17.0")

		profile.options.minimap = profile.minimap
		profile.minimap = nil

		FinalizeVersionUpgrade("0.17.0")
	end

	-- 0.17.x to 1.0.0
	if string.sub(from, 1, 4) == "0.17" then
		Notify("1.0.0")

		for _, binding in ipairs(profile.bindings) do
			binding.action.macroName = Addon.L["Run custom macro"]
			binding.action.macroIcon = [[Interface\ICONS\INV_Misc_QuestionMark]]

			if binding.type == Clicked2.ActionType.MACRO then
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
			if binding.type == Clicked2.ActionType.MACRO then
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
		Notify("1.1.0")

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
		Notify("1.2.0")

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
		Notify("1.3.0")

		for _, binding in ipairs(profile.bindings) do
			binding.action.startAutoAttack = binding.action.allowStartAttack
			binding.action.startPetAttack = false

			binding.action.allowStartAttack = nil
		end

		FinalizeVersionUpgrade("1.3.0")
	end

	-- 1.3.x to 1.4.0
	if string.sub(from, 1, 3) == "1.3" then
		Notify("1.4.0")

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
		Notify("1.5.0")

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
		Notify("1.6.0")

		for _, binding in ipairs(profile.bindings) do
			binding.action.convertValueToId = true
		end

		FinalizeVersionUpgrade("1.6.0")
	end

	-- 1.6.x to 1.7.0
	if string.sub(from, 1, 3) == "1.6" then
		Notify("1.7.0")

		for _, binding in ipairs(profile.bindings) do
			binding.action.auraName = ""
		end

		FinalizeVersionUpgrade("1.7.0")
	end

	-- 1.7.x to 1.8.0
	if string.sub(from, 1, 3) == "1.7" then
		Notify("1.8.0")

		for _, binding in ipairs(profile.bindings) do
			binding.load.covenant = nil
			binding.load.form.negated = false
		end

		profile.options.bindUnassignedModifiers = true

		FinalizeVersionUpgrade("1.8.0")
	end

	-- 1.8.0 to 1.8.1
	if string.sub(from, 1, 5) == "1.8.0" then
		Notify("1.8.1")

		for _, binding in ipairs(profile.bindings) do
			if Addon.EXPANSION >= Addon.Expansion.DF then
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
		Notify("1.8.2")

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

--- @param from? string|integer
function Addon:Upgrade(from)
	table.wipe(upgradeData)

	if not Addon.DISABLE_GLOBAL_SCOPE then
		local src = from or Addon.db.global.version or Addon.DATA_VERSION

		if xpcall(UpgradeV2, geterrorhandler(), Addon.db.global, Addon.db.global, "GLOBAL", src) then
			Addon.db.global.version = Addon.DATA_VERSION
		end
	end

	do
		local src = from or Addon.db.profile.version

		if src == nil then
			-- Incredible hack because I accidentially removed the serialized version number in 0.12.0. This will check for all the characteristics of a 0.12
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

		if type(src) == "string" and xpcall(UpgradeV1, geterrorhandler(), Addon.db.profile, src) then
			src = Addon.db.profile.version
		end

		if xpcall(UpgradeV2, geterrorhandler(), Addon.db.global, Addon.db.profile, "PROFILE", src) then
			Addon.db.profile.version = Addon.DATA_VERSION
		end
	end
end

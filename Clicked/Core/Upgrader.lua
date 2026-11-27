---@diagnostic disable: undefined-field, assign-type-mismatch, inject-field, missing-fields, unknown-local-type, unknown-param-type, unknown-return-type

--- @class Addon
local Addon = select(2, ...)

Addon.DATA_VERSION = 20

local upgradeData = {}

-- Local support functions

--- @param db table
--- @param global table
--- @param from integer
--- @param type "profile"|"global"
--- @param cache table
--- @return boolean
local function Upgrade(db, global, from, type, cache)
	-- Clicked maintains a two year profile upgrade policy, meaning that it is only capable of upgrading profiles from versions released within the last two
	-- years. If a profile is older than that, the user can either use an intermediate version to upgrade their profile step by step, or delete the profile and
	-- create a new one.
	--
	-- Since WoW expansions release approximately every two years, it's safe to assume that a profile older than that is at least one expansion behind, and
	-- likely requires significant effort anyway as abilities tend to change a lot.

	if from < 12 then
		local message = Addon.L["Cannot upgrade profile. Clicked supports profile upgrades for all versions released in the last two years, you can either revert to an earlier version to upgrade your profile, before updating to this version, or delete the profile and create a new one."]
		Clicked:LogError(message)
		return false
	end

	if from < 13 then -- 2025-03-25
		upgradeData[13] = upgradeData[13] or {}
		upgradeData[13].seen = upgradeData[13].seen or {}

		local orphans = {}

		for i, binding in ipairs(db.bindings) do
			--- @param group table
			--- @return boolean
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

		--- @param left integer
		--- @param right integer
		--- @return boolean
		local function SortFunc(left, right)
			return left > right
		end

		table.sort(orphans, SortFunc)
		for _, i in ipairs(orphans) do
			table.remove(db.bindings, i)
		end
	end

	if from < 14 then -- 2026-07-22
		for _, binding in ipairs(db.bindings) do
			if binding.actionType == "UNIT_MENU" or binding.actionType == "UNIT_SELECT" or binding.keybind == "BUTTON1" or binding.keybind == "BUTTON2" then
				binding.targets.hovercastEnabled = true
			end
		end
	end

	if from < 15 then -- 2026-07-23
		for _, binding in ipairs(db.bindings) do
			if binding.actionType == "UNIT_SELECT" then
				cache["15_foundTargetBinding"] = true
			elseif binding.actionType == "UNIT_MENU" then
				cache["15_foundMenuBinding"] = true
			end
		end

		if type == "profile" then
			local function GetLoadOptionTemplate(default)
				local template = {
					selected = false,
					value = default
				}

				return template
			end

			local function GetNegatableLoadOptionTemplate()
				return GetLoadOptionTemplate(true)
			end

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

			local function GetNegatableTriStateLoadOptionTemplate(default)
				local template = GetTriStateLoadOptionTemplate(default)
				template.negated = false

				return template
			end

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

			local function GetNegatableStringLoadOptionTemplate()
				local template = {
					selected = false,
					negated = false,
					value = ""
				}

				return template
			end

			--- @param actionType string
			--- @param key string
			local function CreateBinding(actionType, key)
				local uid = global.nextUid
				global.nextUid = global.nextUid + 1

				return {
					uid = uid,
					actionType = actionType,
					type = 1,
					scope = 1,
					keybind = key,
					action = {
						spellValue = "",
						itemValue = "",
						macroValue = "",
						macroName = Addon.L["Run custom macro"],
						macroIcon = [[Interface\ICONS\INV_Misc_QuestionMark]],
						auraName = "",
						executionOrder = 1,
						spellMaxRank = false,
						spellIncludeSubtext = false,
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
						hovercastEnabled = true,
						regularEnabled = false
					},
					load = {
						never = false,
						class = GetTriStateLoadOptionTemplate(select(2, UnitClass("player"))),
						race = GetTriStateLoadOptionTemplate(select(2, UnitRace("player"))),
						playerNameRealm = GetLoadOptionTemplate(UnitName("player") --[[@as string]]),
						combat = GetNegatableLoadOptionTemplate(),
						spellKnown = GetLoadOptionTemplate(""),
						inGroup = GetLoadOptionTemplate("IN_GROUP_PARTY_OR_RAID"),
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
			end

			if not cache["15_foundTargetBinding"] then
				local binding = CreateBinding("UNIT_SELECT", "BUTTON1")
				table.insert(db.bindings, binding)
			end

			if not cache["15_foundMenuBinding"] then
				local binding = CreateBinding("UNIT_MENU", "BUTTON2")
				table.insert(db.bindings, binding)
			end
		end
	end

	if from < 16 then -- 2026-09-26
		for _, binding in ipairs(db.bindings) do
			binding.load.ruleset = binding.load.ruleset or {
				selected = 0,
				single = "NORMAL",
				multiple = {
					"NORMAL"
				}
			}

			binding.load.groupRole = binding.load.groupRole or {
				selected = 0,
				single = "NONE",
				multiple = {
					"NONE"
				}
			}
		end
	end

	if from < 17 then -- 2026-10-19
		if type == "profile" and global.options == nil then
			global.options = db.options
			global.blacklist = db.blacklist
		end

		if type == "profile" then
			db.options = nil
			db.blacklist = nil
		end
	end

	if from < 18 then -- 2026-11-06
		for _, binding in ipairs(db.bindings) do
			binding.load.advflyable = binding.load.advFlyable
		end
	end

	if from < 19 then -- 2026-11-09
		for _, binding in ipairs(db.bindings) do
			binding.load.advFlyable = nil
		end
	end

	if from < 20 then -- 2026-11-15
		local FLAG_LOAD_ENABLED = 1
		local FLAG_LOAD_NEGATED = 2

		local function GetSelectedValues(value)
			if value.selected == 2 then
				return value.multiple or {}
			end

			return { value.single }
		end

		local function ToFlags(values, map)
			local result = 0

			for _, item in ipairs(values) do
				if map[item] ~= nil then
					result = bit.bor(result, map[item])
				end
			end

			return result
		end

		local function FromBoolean(value)
			if not value then
				return nil
			end

			return {
				state = FLAG_LOAD_ENABLED,
				value = true
			}
		end

		local function FromLoadOption(value)
			if value == nil or not value.selected then
				return nil
			end

			return {
				state = FLAG_LOAD_ENABLED,
				value = value.value
			}
		end

		local function FromNegatableStringLoadOption(value)
			if value == nil or not value.selected then
				return nil
			end

			local values = {}

			for item in string.gmatch(value.value or "", "([^/]+)") do
				item = string.trim(item)

				if #item > 0 then
					table.insert(values, item)
				end
			end

			return {
				state = value.negated and bit.bor(FLAG_LOAD_ENABLED, FLAG_LOAD_NEGATED) or FLAG_LOAD_ENABLED,
				value = #values > 1 and values or (values[1] or "")
			}
		end

		local function FromInGroup(value)
			if value == nil or not value.selected then
				return nil
			end

			local FLAG_SOLO = 1
			local FLAG_PARTY = 2
			local FLAG_RAID = 4

			local map = {
				IN_GROUP_PARTY_OR_RAID = bit.bor(FLAG_PARTY, FLAG_RAID),
				IN_GROUP_PARTY = FLAG_PARTY,
				IN_GROUP_RAID = FLAG_RAID,
				IN_GROUP_SOLO = FLAG_SOLO
			}

			return {
				state = FLAG_LOAD_ENABLED,
				value = map[value.value] or bit.bor(FLAG_PARTY, FLAG_RAID)
			}
		end

		local function FromTriStateFlags(value, map)
			if value == nil or value.selected == nil or value.selected == 0 then
				return nil
			end

			return {
				state = FLAG_LOAD_ENABLED,
				value = ToFlags(GetSelectedValues(value), map)
			}
		end

		local function FromInstanceType(value)
			return FromTriStateFlags(value, {
				NONE = 1,
				PARTY = 2,
				RAID = 4,
				PVP = 8,
				ARENA = 16,
				SCENARIO = 32
			})
		end

		local function FromRole(value)
			return FromTriStateFlags(value, {
				NONE = 1,
				DAMAGER = 2,
				TANK = 4,
				HEALER = 8
			})
		end

		local function FromRuleset(value)
			return FromTriStateFlags(value, {
				NORMAL = 1,
				PVP = 2,
				RP = 4,
				HARDCORE = 8
			})
		end

		local function FromTriStateLoadOption(value)
			if value == nil or value.selected == nil or value.selected == 0 then
				return nil
			end

			local values = GetSelectedValues(value)

			return {
				state = value.negated and bit.bor(FLAG_LOAD_ENABLED, FLAG_LOAD_NEGATED) or FLAG_LOAD_ENABLED,
				value = #values == 1 and values[1] or CopyTable(values)
			}
		end

		local function FromZoneNames(value)
			if value == nil or not value.selected then
				return nil
			end

			local result = {
				state = FLAG_LOAD_ENABLED,
				value = {}
			}

			for name in string.gmatch(value.value or "", "([^;]+)") do
				local negate = string.sub(name, 1, 1) == "!"

				table.insert(result.value, {
					name = negate and string.sub(name, 2) or name,
					negate = negate
				})
			end

			return result
		end

		local function FromTalent(value)
			if value == nil or not value.selected then
				return nil
			end

			local current = {}

			local result = {
				state = FLAG_LOAD_ENABLED,
				value = { current }
			}

			for _, entry in ipairs(value.entries or {}) do
				if entry.operation == "OR" and #current > 0 then
					current = {}
					table.insert(result.value, current)
				end

				table.insert(current, {
					name = entry.value or "",
					negate = entry.negated and true or false
				})
			end

			return result
		end

		for _, binding in ipairs(db.bindings) do
			local load = binding.load or {}

			binding.conditionals = {
				form = FromTriStateLoadOption(load.form),
				combat = FromLoadOption(load.combat),
				pet = FromLoadOption(load.pet),
				stealth = FromLoadOption(load.stealth),
				mounted = FromLoadOption(load.mounted),
				outdoors = FromLoadOption(load.outdoors),
				swimming = FromLoadOption(load.swimming),
				flying = FromLoadOption(load.flying),
				dynamicFlying = FromLoadOption(load.dynamicFlying),
				flyable = FromLoadOption(load.flyable),
				channeling = FromNegatableStringLoadOption(load.channeling),
				bonusbar = FromNegatableStringLoadOption(load.bonusbar),
				bar = FromNegatableStringLoadOption(load.bar)
			}

			binding.load = {
				never = FromBoolean(load.never),
				class = FromTriStateLoadOption(load.class),
				race = FromTriStateLoadOption(load.race),
				nameRealm = FromLoadOption(load.playerNameRealm),
				spellKnown = FromLoadOption(load.spellKnown),
				groupType = FromInGroup(load.inGroup),
				playerInGroup = FromLoadOption(load.playerInGroup),
				instanceType = FromInstanceType(load.instanceType),
				specialization = FromTriStateLoadOption(load.specialization),
				specRole = FromRole(load.specRole),
				groupRole = FromRole(load.groupRole),
				zoneName = FromZoneNames(load.zoneName),
				talent = FromTalent(load.talent),
				pvpTalent = FromTalent(load.pvpTalent),
				warMode = FromLoadOption(load.warMode),
				ruleset = FromRuleset(load.ruleset),
				equipped = FromLoadOption(load.equipped),
				runeEquipped = FromLoadOption(load.runeEquipped)
			}
		end
	end

	return true
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
--- @param from? integer
function Addon:UpgradeDatabase(from)
	-- Don't use any constants in this function to prevent breaking the updater
	-- when the value of a constant changes. Always use direct values that are
	-- read from the database.

	table.wipe(upgradeData)

	local cache = {}

	local src = from or Addon.db.global.version or Addon.DATA_VERSION

	if type(src) == "string" then
		local message = Addon.L["Cannot upgrade profile. Clicked supports profile upgrades for all versions released in the last two years, you can either revert to an earlier version to upgrade your profile, before updating to this version, or delete the profile and create a new one."]
		Clicked:LogError(message)
	else
		local _, success = Addon:SafeCall(Upgrade, Addon.db.global, Addon.db.global, src, "global", cache)
		if success then
			Addon.db.global.version = Addon.DATA_VERSION
		end
	end

	do
		src = from or Addon.db.profile.version

		if type(src) == "string" then
			local message = Addon.L["Cannot upgrade profile. Clicked supports profile upgrades for all versions released in the last two years, you can either revert to an earlier version to upgrade your profile, before updating to this version, or delete the profile and create a new one."]
			Clicked:LogError(message)
		else
			local _, success = Addon:SafeCall(Upgrade, Addon.db.profile, Addon.db.global, src, "profile", cache)
			if success then
				Addon.db.profile.version = Addon.DATA_VERSION
			end
		end
	end
end

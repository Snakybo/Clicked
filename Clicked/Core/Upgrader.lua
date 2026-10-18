---@diagnostic disable: undefined-field, assign-type-mismatch, inject-field, missing-fields

--- @class Addon
local Addon = select(2, ...)

Addon.DATA_VERSION = 16

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

--- @param db table
--- @param global table
--- @param from integer
--- @param type "profile"|"global"
--- @param cache table
local function Upgrade(db, global, from, type, cache)
	-- Clicked maintains a two year profile upgrade policy, meaning that it is only capable of upgrading profiles from versions released within the last two
	-- years. If a profile is older than that, the user can either use an intermediate version to upgrade their profile step by step, or delete the profile and
	-- create a new one.
	--
	-- Since WoW expansions release approximately every two years, it's safe to assume that a profile older than that is at least one expansion behind, and
	-- likely requires significant effort anyway as abilities tend to change a lot.

	if from < 12 then
		local message = Addon.L["Cannot upgrade profile. Clicked supports profile upgrades for all versions released in the last two years, you can either revert to an earlier version to upgrade your profile, before updating to this version, or delete the profile and create a new one."]
		return Clicked:LogError(message)
	end

	if from < 13 then -- 2025-03-25
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

			local function GetNegatableStringLoadOptionTemplate()
				local template = {
					selected = false,
					negated = false,
					value = ""
				}

				return template
			end

			local function CreateBinding(type, key)
				local uid = global.nextUid
				global.nextUid = global.nextUid + 1

				return {
					uid = uid,
					actionType = type,
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

	if not Addon.DISABLE_GLOBAL_SCOPE then
		local src = from or Addon.db.global.version or Addon.DATA_VERSION

		if type(src) == "string" then
			local message = Addon.L["Cannot upgrade profile. Clicked supports profile upgrades for all versions released in the last two years, you can either revert to an earlier version to upgrade your profile, before updating to this version, or delete the profile and create a new one."]
			Clicked:LogError(message)
		else
			safecall(Upgrade, Addon.db.global, Addon.db.global, src, "global", cache)
			Addon.db.global.version = Addon.DATA_VERSION
		end
	end

	do
		local src = from or Addon.db.profile.version

		if type(src) == "string" then
			local message = Addon.L["Cannot upgrade profile. Clicked supports profile upgrades for all versions released in the last two years, you can either revert to an earlier version to upgrade your profile, before updating to this version, or delete the profile and create a new one."]
			Clicked:LogError(message)
		else
			safecall(Upgrade, Addon.db.profile, Addon.db.global, src, "profile", cache)
			Addon.db.profile.version = Addon.DATA_VERSION
		end
	end
end

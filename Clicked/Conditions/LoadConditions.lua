-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
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

--- @class ClickedInternal
local Addon = select(2, ...)

-- Deprecated in 5.5.0
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization

local Utils = Addon.Condition.Utils

--- @type LoadCondition[]
local config = {
	{
		id = "never",
		drawer = {
			type = "toggle",
			label = "Never",
		},
		init = function()
			return false
		end,
		--- @param option boolean
		unpack = function(option)
			return option
		end,
		--- @param value boolean
		test = function(value)
			return not value
		end
	},
	{
		id = "playerNameRealm",
		drawer = { --- @type InputDrawerConfig
			type = "input",
			negatable = false,
			label = "Player Name-Realm"
		},
		init = function()
			return Utils.CreateLoadOption(UnitName("player") .. "-" .. GetRealmName())
		end,
		unpack = Utils.UnpackSimpleLoadOption,
		--- @param value string
		test = function(value)
			local name = UnitName("player")
			local realm = GetRealmName()
			return value == name or value == name .. "-" .. realm
		end
	},
	{
		id = "race",
		drawer = {
			type = "multiselect",
			label = "Race",
			availableValues = function()
				return Addon:GetLocalizedRaces()
			end
		},
		init = function()
			local _, englishName = UnitRace("player")
			return Utils.CreateMultiselectLoadOption(englishName)
		end,
		unpack = Utils.UnpackMultiselectLoadOption,
		--- @param value string[]
		test = function(value)
			local _, raceName = UnitRace("player")
			return tContains(value, raceName)
		end
	},
	{
		id = "class",
		drawer = {
			type = "multiselect",
			label = "Class",
			availableValues = function()
				return Addon:GetLocalizedClasses()
			end
		},
		init = function()
			local _, classFileName = UnitClass("player")
			return Utils.CreateMultiselectLoadOption(classFileName)
		end,
		unpack = Utils.UnpackMultiselectLoadOption,
		--- @param value string[]
		test = function(value)
			local _, classFileName = UnitClass("player")
			return tContains(value, classFileName)
		end
	},
	{
		id = "specialization",
		drawer = {
			type = "multiselect",
			label = "Talent specialization",
			--- @param class string[]
			availableValues = function(class)
				if #class == 0 then
					class[1] = select(2, UnitClass("player"))
				end

				return Addon:GetLocalizedSpecializations(class)
			end
		},
		dependencies = { "class" },
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.CATA,
		init = function()
			if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
				local specIndex = GetSpecialization()
				return Utils.CreateMultiselectLoadOption(specIndex == 5 and 1 or specIndex)
			else
				return Utils.CreateMultiselectLoadOption(GetPrimaryTalentTree())
			end
		end,
		unpack = Utils.UnpackMultiselectLoadOption,
		testOnEvents = { "PLAYER_TALENT_UPDATE" },
		--- @param value number[]
		test = function(value)
			if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
				local specIndex = GetSpecialization()
				return tContains(value, specIndex == 5 and 1 or specIndex)
			else
				return tContains(value, GetPrimaryTalentTree())
			end
		end
	},
	{
		id = "specRole",
		drawer = {
			type = "multiselect",
			label = "Specialization role",
			availableValues = function()
				return {
					DAMAGER = Addon.L["DPS"],
					TANK = Addon.L["Tank"],
					HEALER = Addon.L["Healer"]
				}, {
					"DAMAGER",
					"TANK",
					"HEALER"
				}
			end
		},
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.MOP,
		init = function()
			local role = GetSpecializationRole(GetSpecialization()) or "DAMAGER"
			return Utils.CreateMultiselectLoadOption(role)
		end,
		unpack = Utils.UnpackMultiselectLoadOption,
		testOnEvents = { "PLAYER_TALENT_UPDATE" },
		--- @param value string[]
		test = function(value)
			local role = GetSpecializationRole(GetSpecialization())
			return tContains(value, role)
		end
	},
	{
		id = "talent",
		drawer = {
			type = "talent",
			label = "Talent",
			--- @param class string[]
			--- @param specialization integer[]
			availableValues = function(class, specialization)
				if Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
					local specIds = Utils.GetRelevantSpecializationIds(class, specialization)
					return Addon:GetLocalizedTalents(specIds)
				else
					local classes = Utils.GetRelevantClasses(class)
					return Addon:GetLocalizedTalents(classes)
				end
			end
		},
		dependencies = { "class", "specialization" },
		init = function()
			return Utils.CreateTalentLoadOption("")
		end,
		unpack = Utils.UnpackTalentLoadOption,
		testOnEvents = { "CHARACTER_POINTS_CHANGED", "PLAYER_TALENT_UPDATE", "TRAIT_CONFIG_CREATED", "TRAIT_CONFIG_UPDATED" },
		--- @param value TalentLoadOptionEntry[][]
		test = function(value)
			if not Addon:IsTalentCacheReady() then
				return false
			end

			for _, compound in ipairs(value) do
				local valid = true

				for _, talent in ipairs(compound) do
					local name = talent.value
					local selected = Addon:IsTalentSelected(name)

					if #name > 0 and (selected and talent.negated or not selected and not talent.negated) then
						valid = false
						break
					end
				end

				if valid then
					return true
				end
			end

			return false
		end
	},
	{
		id = "pvpTalent",
		drawer = {
			type = "talent",
			label = "PvP talent",
			--- @param class string[]
			--- @param specialization integer[]
			availableValues = function(class, specialization)
				local specIds = Utils.GetRelevantSpecializationIds(class, specialization)
				return Addon:GetLocalizedPvPTalents(specIds)
			end
		},
		dependencies = { "class", "specialization" },
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.BFA,
		init = function()
			return Utils.CreateTalentLoadOption("")
		end,
		unpack = Utils.UnpackTalentLoadOption,
		testOnEvents = { "PLAYER_PVP_TALENT_UPDATE" },
		--- @param value TalentLoadOptionEntry[][]
		test = function(value)
			local cache = {}

			do
				local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(1);

				if slotInfo ~= nil and slotInfo.availableTalentIDs then
					for _, id in ipairs(slotInfo.availableTalentIDs) do
						local _, name, _, selected, _, _, _, _, _, known, grantedByAura = GetPvpTalentInfoByID(id)

						if selected or known or grantedByAura then
							cache[name] = true
						end
					end
				end
			end

			if next(cache) == nil then
				return false
			end

			for _, compound in ipairs(value) do
				local valid = true

				for _, talent in ipairs(compound) do
					local name = talent.value
					local selected = cache[name]

					if #name > 0 and (selected and talent.negated or not selected and not talent.negated) then
						valid = false
						break
					end
				end

				if valid then
					return true
				end
			end

			return false
		end
	},
	{
		id = "warMode",
		drawer = {
			type = "select",
			label = "War Mode",
			availableValues = function()
				return {
					[true] = Addon.L["War Mode enabled"],
					[false] = Addon.L["War Mode disabled"]
				}, { true, false}
			end
		},
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.BFA,
		init = function()
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption,
		testOnEvents = { "PLAYER_FLAGS_CHANGED" },
		--- @param value boolean
		test = function(value)
			return value == C_PvP.IsWarModeDesired()
		end
	},
	{
		id = "instanceType",
		drawer = {
			type = "multiselect",
			label = "Instance type",
			availableValues = function()
				local items = {
					NONE = Addon.L["No Instance"],
					PARTY = Addon.L["Dungeon"],
					RAID = Addon.L["Raid"]
				}

				local order = {
					"NONE",
					"PARTY",
					"RAID"
				}

				if Addon.EXPANSION_LEVEL >= Addon.Expansion.BC then
					items["PVP"] = Addon.L["Battleground"]
					items["ARENA"] = Addon.L["Arena"]

					table.insert(order, "PVP")
					table.insert(order, "ARENA")
				end

				if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
					items["SCENARIO"] = Addon.L["Scenario"]
					table.insert(order, 2, "SCENARIO")
				end

				return items, order
			end
		},
		init = function()
			return Utils.CreateMultiselectLoadOption("NONE")
		end,
		unpack = Utils.UnpackMultiselectLoadOption,
		testOnEvents = { "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA" },
		--- @param value string[]
		test = function(value)
			local _, instanceType = IsInInstance()

			for _, current in ipairs(value) do
				-- Convert to lowercase as that is what `IsInInstance` returns
				current = string.lower(current)

				if current == instanceType then
					return true
				end
			end

			return false
		end
	},
	{
		id = "zoneName",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Zone name(s)",
			tooltip = {
				string.format(Addon.L["Semicolon separated, use an exclamation mark (%s) to negate a zone condition, for example:"], "|r!|cffffffff"),
				"",
				string.format(Addon.L["%s will be active if you're not in Oribos"], "|r!" .. Addon.L["Oribos"] .. "|cffffffff"),
				string.format(Addon.L["%s will be active if you're in Durotar or Orgrimmar"], "|r" .. Addon.L["Durotar"] .. ";" .. Addon.L["Orgrimmar"] .. "|cffffffff")
			}
		},
		init = function()
			return Utils.CreateLoadOption("")
		end,
		unpack = Utils.UnpackSimpleLoadOption,
		testOnEvents = { "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA" },
		--- @param value string
		test = function(value)
			local zones = {
				GetRealZoneText(),
				GetSubZoneText() or ""
			}

			for zone in string.gmatch(value, "([^;]+)") do
				local negate = false

				if string.sub(zone, 0, 1) == "!" then
					negate = true
					zone = string.sub(zone, 2)
				end

				if (negate and not tContains(zones, zone)) or (not negate and tContains(zones, zone)) then
					return true
				end
			end

			return false
		end
	},
	{
		id = "spellKnown",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Spell known"
		},
		init = function()
			return Utils.CreateLoadOption("")
		end,
		unpack = Utils.UnpackSimpleLoadOption,
		testOnEvents = Addon.EXPANSION_LEVEL > Addon.Expansion.CLASSIC and
			{ "PLAYER_TALENT_UPDATE", "PLAYER_LEVEL_CHANGED", "LEARNED_SPELL_IN_TAB", "TRAIT_CONFIG_CREATED", "TRAIT_CONFIG_UPDATED" } or
			{ "PLAYER_TALENT_UPDATE", "PLAYER_LEVEL_CHANGED", "LEARNED_SPELL_IN_TAB", "TRAIT_CONFIG_CREATED", "TRAIT_CONFIG_UPDATED", "RUNE_UPDATED", "PLAYER_EQUIPMENT_CHANGED" },
		test = function(value)
			local spell = C_Spell.GetSpellInfo(value)
			return spell ~= nil and IsSpellKnownOrOverridesKnown(spell.spellID) or false
		end
	},
	{
		id = "inGroup",
		drawer = {
			type = "select",
			label = "In group",
			availableValues = function()
				return {
					IN_GROUP_PARTY_OR_RAID = Addon.L["In a party or raid group"],
					IN_GROUP_PARTY = Addon.L["In a party"],
					IN_GROUP_RAID = Addon.L["In a raid group"],
					IN_GROUP_SOLO = Addon.L["Not in a group"]
				}, {
					"IN_GROUP_PARTY_OR_RAID",
					"IN_GROUP_PARTY",
					"IN_GROUP_RAID",
					"IN_GROUP_SOLO"
				}
			end
		},
		init = function()
			return Utils.CreateLoadOption(Addon.GroupState.PARTY_OR_RAID)
		end,
		unpack = Utils.UnpackSimpleLoadOption,
		testOnEvents = { "GROUP_ROSTER_UPDATE" },
		--- @param value GroupState
		test = function(value)
			if value == Addon.GroupState.SOLO and GetNumGroupMembers() > 0 then
				return false
			elseif value == Addon.GroupState.PARTY_OR_RAID and GetNumGroupMembers() == 0 then
				return false
			elseif value == Addon.GroupState.PARTY and (GetNumSubgroupMembers() == 0 or IsInRaid()) then
				return false
			elseif value == Addon.GroupState.RAID and not IsInRaid() then
				return false
			end

			return true
		end
	},
	{
		id = "playerInGroup",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Player in group"
		},
		init = function()
			return Utils.CreateLoadOption("")
		end,
		unpack = Utils.UnpackSimpleLoadOption,
		testOnEvents = { "GROUP_ROSTER_UPDATE" },
		--- @param value string
		test = function(value)
			if value == UnitName("player") then
				return true
			else
				local unit = IsInRaid() and "raid" or "party"

				for i = 1, GetNumGroupMembers() do
					local name = UnitName(unit .. i)
					if name == value then
						return true
					end
				end
			end

			return false
		end
	},
	{
		id = "equipped",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Item equipped",
			tooltip = Addon.L["This will not update when in combat, so swapping weapons or shields during combat does not work."],
			validate = function(value)
				local type = LinkUtil.ExtractLink(value)
				if type ~= nil and type ~= "item" then
					return value
				end

				local name = C_Item.GetItemNameByID(value)
				if name ~= nil then
					return name
				end

				return value
			end
		},
		init = function()
			return Utils.CreateLoadOption("")
		end,
		unpack = Utils.UnpackSimpleLoadOption,
		testOnEvents = { "PLAYER_EQUIPMENT_CHANGED" },
		--- @param value string
		test = function(value)
			return C_Item.IsEquippedItem(value)
		end
	},
	{
		id = "runeEquipped",
		drawer = {
			type = "input",
			label = "Rune equipped",
			availableValues = function()
				--- @type ClickedAutoFillEditBox.Option[]
				local result = {}

				C_Engraving:ClearAllCategoryFilters();
				C_Engraving.RefreshRunesList()

				for _, category in ipairs(C_Engraving.GetRuneCategories(false, false)) do
					for _, engraving in ipairs(C_Engraving.GetRunesForCategory(category, false)) do
						table.insert(result, {
							text = engraving.name,
							icon = engraving.iconTexture,
							spellId = engraving.skillLineAbilityID
						})
					end
				end

				return result
			end
		},
		disabled = Addon.EXPANSION_LEVEL > Addon.Expansion.CLASSIC or C_Engraving == nil,
		init = function()
			return Utils.CreateLoadOption("")
		end,
		unpack = Utils.UnpackSimpleLoadOption,
		testOnEvents = { "RUNE_UPDATED", "PLAYER_EQUIPMENT_CHANGED" },
		--- @param value string
		test = function(value)
			local spellId = tonumber(value)
			if spellId == nil then
				return false
			end

			return C_Engraving.IsRuneEquipped(spellId)
		end
	}
}

Addon.Condition.Registry:RegisterConditionConfig("load", config)

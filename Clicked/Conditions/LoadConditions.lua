-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
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

--- @class Addon
local Addon = select(2, ...)

local LibTalentTome = LibStub("LibTalentTome")

local Utils = Addon.Condition.Utils

--- @enum GroupTypes
Addon.GroupTypes = {
	SOLO = 1,
	PARTY = 2,
	RAID = 4
}

--- @enum InstanceTypes
Addon.InstanceTypes = {
	NONE = 1,
	PARTY = 2,
	RAID = 4,
	PVP = 8,
	ARENA = 16,
	SCENARIO = 32
}

--- @enum Roles
Addon.Roles = {
	NONE = 1,
	DAMAGER = 2,
	TANK = 4,
	HEALER = 8
}

--- @enum Rulesets
Addon.Rulesets = {
	NORMAL = 1,
	PVP = 2,
	RP = 4,
	HARDCORE = 8
}

--- @param value integer
--- @param flag? integer
--- @return boolean
local function HasValueFlag(value, flag)
	return flag ~= nil and bit.band(value, flag) > 0
end

--- @param flags table<string, integer>
--- @param key? string
--- @return integer?
local function GetFlag(flags, key)
	if key == nil then
		return nil
	end

	--- @type integer?
	local result = flags[key]
	return result
end

--- @param option LoadCondition<ZoneNameValue>
--- @return string
local function FormatZoneNames(option)
	--- @type string[]
	local result = {}

	for _, zone in ipairs(Utils.UnpackLoadOption(option)) do
		if not Addon:IsNilOrEmpty(zone.name) then
			table.insert(result, (zone.negate and "!" or "") .. zone.name)
		end
	end

	return table.concat(result, ";")
end

--- @param option LoadCondition<ZoneNameValue>
--- @param text string
local function ParseZoneNames(option, text)
	--- @type ZoneNameValue[]
	local result = {}

	for zone in string.gmatch(text, "([^;]+)") do
		local negate = string.sub(zone, 1, 1) == "!"

		table.insert(result, {
			name = negate and string.sub(zone, 2) or zone,
			negate = negate
		})
	end

	option.value = result
end

--- @return TalentValue[][]
local function CreateTalentCompounds()
	return {
		{
			{
				name = "",
				negate = false
			}
		}
	}
end

--- @param compounds TalentValue[][]
--- @param getActiveTalent fun(self: LibTalentTome, name: string): LibTalentTome.ActiveTalent?
--- @return boolean
local function TestTalentCompounds(compounds, getActiveTalent)
	for _, compound in ipairs(compounds) do
		local valid = true

		for _, talent in ipairs(compound) do
			local name = talent.name
			local selected = getActiveTalent(LibTalentTome, name)

			if #name > 0 and (selected ~= nil and talent.negate or selected == nil and not talent.negate) then
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

--- @type RuntimeLoadCondition[]
local config = {
	{
		id = "never",
		drawer = {
			type = "toggle",
			label = "Never",
		},
		init = true,
		--- @return boolean
		test = function()
			return false
		end
	},
	{
		id = "nameRealm",
		drawer = { --- @type InputDrawerConfig
			type = "input",
			negatable = false,
			label = Addon:IsForever() and "Player Name" or "Player Name-Realm",
			tooltip = Addon:IsForever() and {
				string.format(Addon.L["Enter a first name, or a first and last name. Use an asterisk (%s) to match any first or last name, for example:"], "|r*|cffffffff"),
				"",
				string.format(Addon.L["%s will be active on any character named %s"], "|rAnduin|cffffffff", "Anduin"),
				string.format(Addon.L["%s will be active on %s only"], "|rAnduin Wrynn|cffffffff", "Anduin Wrynn"),
				string.format(Addon.L["%s will be active on any character with the last name %s"], "|r* Wrynn|cffffffff", "Wrynn")
			} or nil
		},
		init = function()
			if Addon:IsForever() then
				return Addon:GetPlayerName()
			else
				return Addon:GetPlayerName() .. "-" .. GetRealmName()
			end
		end,
		--- @return string, string
		state = function()
			return Addon:GetPlayerName(), GetRealmName() or ""
		end,
		--- @param values string[]
		--- @param fullName string
		--- @param realm string
		--- @return boolean
		test = function(values, fullName, realm)
			local value = values[1]
			local name, surname = string.match(fullName, "^(%S+) (%S+)$")
			name = name or fullName

			if value == name or value == name .. "-" .. realm then
				return true
			end

			if surname == nil then
				return false
			end

			local first, last = string.match(value, "^(%S+)%s+(%S+)$")
			return first ~= nil and (first == "*" or first == name) and (last == "*" or last == surname)
		end
	},
	{
		id = "race",
		--- @type SelectDrawerConfig
		drawer = {
			type = "select",
			mode = "multiple",
			label = "Race",
			availableValues = function()
				--- @type table<string, string>
				local items = {}

				--- @type string[]
				local order = {}

				for _, race in ipairs(LibTalentTome:GetUniqueRaces()) do
					items[race.fileName] = race.name
					table.insert(order, race.fileName)
				end

				table.sort(order)

				return items, order
			end
		},
		init = function()
			local _, englishName = UnitRace("player")
			return englishName
		end,
		--- @return string
		state = function()
			local _, raceName = UnitRace("player")
			return raceName
		end,
		--- @param value string[]
		--- @param race string
		--- @return boolean
		test = function(value, race)
			return tContains(value, race)
		end
	},
	{
		id = "class",
		--- @type SelectDrawerConfig
		drawer = {
			type = "select",
			mode = "multiple",
			label = "Class",
			availableValues = function()
				--- @type table<string, string>
				local items = {}

				--- @type string[]
				local order = {}

				for _, class in ipairs(LibTalentTome:GetClasses()) do
					local _, _, _, color = GetClassColor(class.fileName)
					items[class.fileName] = string.format("|c%s%s|r", color, class.name)
					table.insert(order, class.fileName)
				end

				table.sort(order)

				return items, order
			end
		},
		init = function()
			local _, classFileName = UnitClass("player")
			return classFileName
		end,
		--- @return string
		state = function()
			local _, classFileName = UnitClass("player")
			return classFileName
		end,
		--- @param value string[]
		--- @param class string
		--- @return boolean
		test = function(value, class)
			return tContains(value, class)
		end
	},
	{
		id = "specialization",
		--- @type SelectDrawerConfig
		drawer = {
			type = "select",
			mode = "multiple",
			label = "Talent specialization",
			--- @param class string[]
			--- @return table<integer, string>, integer[]
			availableValues = function(class)
				--- @type table<integer, string>
				local items = {}

				--- @type integer[]
				local order = {}

				if #class == 0 then
					class[1] = select(2, UnitClass("player"))
				end

				if #class == 1 then
					local specs = LibTalentTome:GetSpecializations(class[1])

					for index, spec in pairs(specs) do
						if not spec.initial then
							items[index] = Addon:GetTextureString(spec.name, spec.icon)
							table.insert(order, index)
						end
					end
				else
					local max = 0

					-- Find class with the most specializations out of all available classes
					if #class == 0 then
						for _, current in ipairs(LibTalentTome:GetClasses()) do
							max = math.max(max, LibTalentTome:GetNumSpecializations(current))
						end
					-- Find class with the most specializations out of the selected classes
					else
						for i = 1, #class do
							max = math.max(max, LibTalentTome:GetNumSpecializations(class[i]))
						end
					end

					for i = 1, max do
						local key = i

						items[key] = string.format(Addon.L["Specialization %s"], i)
						table.insert(order, key)
					end
				end

				return items, order
			end
		},
		dependencies = { "class" },
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.CATA,
		init = function()
			if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
				local specIndex = C_SpecializationInfo.GetSpecialization()
				return specIndex == 5 and 1 or specIndex
			else
				return GetPrimaryTalentTree()
			end
		end,
		testOnEvents = { "ActiveTalentsChanged" },
		--- @return integer
		state = function()
			if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
				local specIndex = C_SpecializationInfo.GetSpecialization()
				return specIndex == 5 and 1 or specIndex
			end

			return GetPrimaryTalentTree()
		end,
		--- @param value number[]
		--- @param spec integer
		--- @return boolean
		test = function(value, spec)
			return tContains(value, spec)
		end
	},
	{
		id = "specRole",
		--- @type SelectDrawerConfig
		drawer = {
			type = "select",
			mode = "bitmask",
			label = "Specialization role",
			availableValues = function()
				return {
					[Addon.Roles.DAMAGER] = Addon.L["DPS"],
					[Addon.Roles.TANK] = Addon.L["Tank"],
					[Addon.Roles.HEALER] = Addon.L["Healer"]
				}, {
					Addon.Roles.DAMAGER,
					Addon.Roles.TANK,
					Addon.Roles.HEALER
				}
			end
		},
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.MOP,
		init = function()
			local role = GetSpecializationRole(C_SpecializationInfo.GetSpecialization())
			return GetFlag(Addon.Roles, role) or Addon.Roles.DAMAGER
		end,
		testOnEvents = { "ActiveTalentsChanged" },
		--- @return integer?
		state = function()
			return GetFlag(Addon.Roles, GetSpecializationRole(C_SpecializationInfo.GetSpecialization()))
		end,
		--- @param value integer[]
		--- @param role? integer
		--- @return boolean
		test = function(value, role)
			return HasValueFlag(value[1], role)
		end
	},
	{
		id = "talent",
		drawer = {
			type = "talent",
			label = "Talent",
			--- @param class string[]
			--- @param specialization integer[]
			--- @return LibTalentTome.Talent[]
			availableValues = function(class, specialization)
				local specIds = Utils.GetRelevantSpecializationIds(class, specialization)

				--- @type LibTalentTome.Talent[]
				local result = {}

				--- @type table<string, boolean>
				local seen = {}

				for _, specId in ipairs(specIds) do
					for _, talent in ipairs(LibTalentTome:GetTalents(specId)) do
						if not seen[talent.name] then
							seen[talent.name] = true
							table.insert(result, talent)
						end
					end
				end

				return result
			end
		},
		dependencies = { "class", "specialization" },
		init = CreateTalentCompounds,
		testOnEvents = { "ActiveTalentsChanged" },
		--- @param value TalentValue[][]
		--- @return boolean
		test = function(value)
			if not LibTalentTome:AreTalentsInitialized() then
				return false
			end

			return TestTalentCompounds(value, LibTalentTome.GetActiveTalentByName)
		end
	},
	{
		id = "pvpTalent",
		drawer = {
			type = "talent",
			label = "PvP talent",
			--- @param class string[]
			--- @param specialization integer[]
			--- @return LibTalentTome.Talent[]|false
			availableValues = function(class, specialization)
				if not LibTalentTome:ArePvpTalentsInitialized() then
					return false

				end
				local specIds = Utils.GetRelevantSpecializationIds(class, specialization)

				--- @type LibTalentTome.Talent[]
				local result = {}

				--- @type table<string, boolean>
				local seen = {}

				for _, specId in ipairs(specIds) do
					for _, talent in ipairs(LibTalentTome:GetPvpTalents(specId)) do
						if not seen[talent.name] then
							seen[talent.name] = true
							table.insert(result, talent)
						end
					end
				end

				return result
			end
		},
		dependencies = { "class", "specialization" },
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.BFA,
		init = CreateTalentCompounds,
		testOnEvents = { "ActivePvpTalentsChanged" },
		--- @param value TalentValue[][]
		--- @return boolean
		test = function(value)
			return TestTalentCompounds(value, LibTalentTome.GetActivePvpTalentByName)
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
				}, { true, false }
			end
		},
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.BFA,
		init = true,
		testOnEvents = { "PLAYER_FLAGS_CHANGED" },
		--- @return boolean
		state = function()
			return C_PvP.IsWarModeDesired()
		end,
		--- @param value boolean[]
		--- @param warMode boolean
		--- @return boolean
		test = function(value, warMode)
			return value[1] == warMode
		end
	},
	{
		id = "ruleset",
		--- @type SelectDrawerConfig
		drawer = {
			type = "select",
			mode = "bitmask",
			label = "Ruleset",
			availableValues = function()
				return {
					[Addon.Rulesets.NORMAL] = Addon.L["Normal"],
					[Addon.Rulesets.PVP] = Addon.L["PvP"],
					[Addon.Rulesets.RP] = Addon.L["RP"],
					[Addon.Rulesets.HARDCORE] = Addon.L["Hardcore"]
				}, {
					Addon.Rulesets.NORMAL,
					Addon.Rulesets.PVP,
					Addon.Rulesets.RP,
					Addon.Rulesets.HARDCORE
				}
			end
		},
		disabled = not Addon:IsForever(),
		init = function()
			return GetFlag(Addon.Rulesets, Addon:GetRuleset())
		end,
		--- @return integer?
		state = function()
			return GetFlag(Addon.Rulesets, Addon:GetRuleset())
		end,
		--- @param value integer[]
		--- @param current? integer
		--- @return boolean
		test = function(value, current)
			return HasValueFlag(value[1], current)
		end
	},
	{
		id = "instanceType",
		--- @type SelectDrawerConfig
		drawer = {
			type = "select",
			mode = "bitmask",
			label = "Instance type",
			availableValues = function()
				--- @type table<integer, string>
				local items = {
					[Addon.InstanceTypes.NONE] = Addon.L["No Instance"],
					[Addon.InstanceTypes.PARTY] = Addon.L["Dungeon"],
					[Addon.InstanceTypes.RAID] = Addon.L["Raid"]
				}

				--- @type integer[]
				local order = {
					Addon.InstanceTypes.NONE,
					Addon.InstanceTypes.PARTY,
					Addon.InstanceTypes.RAID
				}

				if Addon.EXPANSION_LEVEL >= Addon.Expansion.TBC then
					items[Addon.InstanceTypes.PVP] = Addon.L["Battleground"]
					items[Addon.InstanceTypes.ARENA] = Addon.L["Arena"]

					table.insert(order, Addon.InstanceTypes.PVP)
					table.insert(order, Addon.InstanceTypes.ARENA)
				end

				if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
					items[Addon.InstanceTypes.SCENARIO] = Addon.L["Scenario"]
					table.insert(order, 2, Addon.InstanceTypes.SCENARIO)
				end

				return items, order
			end
		},
		init = Addon.InstanceTypes.NONE,
		testOnEvents = { "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA" },
		--- @return integer?
		state = function()
			local _, instanceType = IsInInstance()

			-- `IsInInstance` returns lowercase values
			return GetFlag(Addon.InstanceTypes, instanceType ~= nil and string.upper(instanceType) or nil)
		end,
		--- @param value integer[]
		--- @param instanceType? integer
		--- @return boolean
		test = function(value, instanceType)
			return HasValueFlag(value[1], instanceType)
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
			},
			format = FormatZoneNames,
			parse = ParseZoneNames
		},
		--- @return ZoneNameValue[]
		init = function()
			return {}
		end,
		testOnEvents = { "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA" },
		--- @return string, string
		state = function()
			return GetRealZoneText(), GetSubZoneText() or ""
		end,
		--- @param value ZoneNameValue[]
		--- @param realZoneText string
		--- @param subZoneText string
		--- @return boolean
		test = function(value, realZoneText, subZoneText)
			local zones = {
				realZoneText,
				subZoneText
			}

			for _, zone in ipairs(value) do
				if not Addon:IsNilOrEmpty(zone.name) and tContains(zones, zone.name) ~= zone.negate then
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
		init = "",
		testOnEvents = { "ActiveTalentsChanged", "ActivePvpTalentsChanged", "PLAYER_LEVEL_CHANGED", "LEARNED_SPELL_IN_TAB", "LEARNED_SPELL_IN_SKILL_LINE", "RUNE_UPDATED", "PLAYER_EQUIPMENT_CHANGED" },
		--- @param value string[]
		--- @return boolean
		test = function(value)
			local spell = C_Spell.GetSpellInfo(value[1])
			return spell ~= nil and IsSpellKnownOrOverridesKnown(spell.spellID, false) or false
		end
	},
	{
		id = "groupType",
		--- @type SelectDrawerConfig
		drawer = {
			type = "select",
			mode = "bitmask",
			label = "In group",
			availableValues = function()
				return {
					[Addon.GroupTypes.SOLO] = Addon.L["Not in a group"],
					[Addon.GroupTypes.PARTY] = Addon.L["In a party"],
					[Addon.GroupTypes.RAID] = Addon.L["In a raid group"]
				}, {
					Addon.GroupTypes.SOLO,
					Addon.GroupTypes.PARTY,
					Addon.GroupTypes.RAID
				}
			end
		},
		init = bit.bor(Addon.GroupTypes.PARTY, Addon.GroupTypes.RAID),
		testOnEvents = { "GROUP_ROSTER_UPDATE" },
		--- @return integer
		state = function()
			if IsInRaid() then
				return Addon.GroupTypes.RAID
			elseif GetNumSubgroupMembers() > 0 then
				return Addon.GroupTypes.PARTY
			end

			return Addon.GroupTypes.SOLO
		end,
		--- @param value integer[]
		--- @param groupType integer
		--- @return boolean
		test = function(value, groupType)
			return HasValueFlag(value[1], groupType)
		end
	},
	{
		id = "groupRole",
		--- @type SelectDrawerConfig
		drawer = {
			type = "select",
			mode = "bitmask",
			label = "Group role",
			availableValues = function()
				return {
					[Addon.Roles.NONE] = Addon.L["No role"],
					[Addon.Roles.DAMAGER] = Addon.L["DPS"],
					[Addon.Roles.TANK] = Addon.L["Tank"],
					[Addon.Roles.HEALER] = Addon.L["Healer"]
				}, {
					Addon.Roles.NONE,
					Addon.Roles.DAMAGER,
					Addon.Roles.TANK,
					Addon.Roles.HEALER
				}
			end
		},
		disabled = not Addon:IsForever(),
		init = function()
			return GetFlag(Addon.Roles, UnitGroupRolesAssigned("player")) or Addon.Roles.NONE
		end,
		testOnEvents = { "PLAYER_ROLES_ASSIGNED", "GROUP_ROSTER_UPDATE" },
		--- @return integer?
		state = function()
			return GetFlag(Addon.Roles, UnitGroupRolesAssigned("player"))
		end,
		--- @param value integer[]
		--- @param role? integer
		--- @return boolean
		test = function(value, role)
			return HasValueFlag(value[1], role)
		end
	},
	{
		id = "playerInGroup",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Player in group"
		},
		init = "",
		testOnEvents = { "GROUP_ROSTER_UPDATE" },
		--- @param values string[]
		--- @return boolean
		test = function(values)
			local value = values[1]

			if value == UnitName("player") then
				return true
			else
				local unit = IsInRaid() and "raid" or "party"

				for i = 1, GetNumGroupMembers() do
					local name = UnitName(unit .. i)

					if not issecretvalue(name) and name == value then
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
		init = "",
		testOnEvents = { "PLAYER_EQUIPMENT_CHANGED" },
		--- @param value string[]
		--- @return boolean
		test = function(value)
			return C_Item.IsEquippedItem(value[1])
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
		init = "",
		testOnEvents = { "RUNE_UPDATED", "PLAYER_EQUIPMENT_CHANGED" },
		--- @param value string[]
		--- @return boolean
		test = function(value)
			local spellId = tonumber(value[1])
			if spellId == nil then
				return false
			end

			return C_Engraving.IsRuneEquipped(spellId)
		end
	}
}

Addon.Condition.Registry:RegisterConditionConfig("load", "load", config)

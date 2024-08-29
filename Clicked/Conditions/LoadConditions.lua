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

local LibTalentInfo = LibStub("LibTalentInfo-1.0")
local LibTalentInfoClassic = LibStub("LibTalentInfoClassic-1.0")

--- @class ClickedInternal
local Addon = select(2, ...)

local Utilities = Addon.Condition.Utilities

--- @param classNames string[]
--- @param specIndices integer[]
--- @return integer[]
local function GetRelevantSpecializationIds(classNames, specIndices)
	local specializationIds = {}

	if #classNames == 0 then
		classNames[1] = select(2, UnitClass("player"))
	end

	if #specIndices == 0 then
		if #classNames == 1 and classNames[1] == select(2, UnitClass("player")) then
			if Addon.EXPANSION_LEVEL > Addon.EXPANSION.CATA then
				specIndices[1] = GetSpecialization()
			else
				specIndices[1] = GetPrimaryTalentTree()
			end
		else
			for _, class in ipairs(classNames) do
				if Addon.EXPANSION_LEVEL > Addon.EXPANSION.CATA then
					local specs = LibTalentInfo:GetClassSpecIDs(class)

					for specIndex in pairs(specs) do
						table.insert(specIndices, specIndex)
					end
				else
					local specs = LibTalentInfoClassic:GetClassSpecializations(class)

					for specIndex in pairs(specs) do
						table.insert(specIndices, specIndex)
					end
				end
			end
		end
	end

	for i = 1, #classNames do
		local class = classNames[i]

		if Addon.EXPANSION_LEVEL > Addon.EXPANSION.CATA then
			local specs = LibTalentInfo:GetClassSpecIDs(class)

			for j = 1, #specIndices do
				local specIndex = specIndices[j]
				local specId = specs[specIndex]

				table.insert(specializationIds, specId)
			end
		else
			local specs = LibTalentInfoClassic:GetClassSpecializations(class)

			for j = 1, #specIndices do
				local specIndex = specIndices[j]
				local spec = specs[specIndex]

				table.insert(specializationIds, spec.id)
			end
		end
	end

	return specializationIds
end

--- @type Condition[]
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
	},
	{
		id = "playerNameRealm",
		drawer = { --- @type InputDrawerConfig
			type = "input",
			negatable = false,
			label = "Player Name-Realm"
		},
		init = function()
			return Utilities.CreateLoadOption(UnitName("player") .. "-" .. GetRealmName())
		end,
		unpack = Utilities.UnpackSimpleLoadOption
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
			return Utilities.CreateMultiselectLoadOption(englishName)
		end,
		unpack = Utilities.UnpackMultiselectLoadOption
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
			return Utilities.CreateMultiselectLoadOption(classFileName)
		end,
		unpack = Utilities.UnpackMultiselectLoadOption
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

				if Addon.EXPANSION_LEVEL > Addon.EXPANSION.DF then
					return Addon:GetLocalizedSpecializations(class)
				else
					return Addon:Cata_GetLocalizedSpecializations(class)
				end
			end
		},
		dependencies = { "class" },
		disabled = Addon.EXPANSION_LEVEL < Addon.EXPANSION.CATA,
		init = function()
			if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.MOP then
				local specIndex = GetSpecialization()
				return Utilities.CreateMultiselectLoadOption(specIndex == 5 and 1 or specIndex)
			else
				return Utilities.CreateMultiselectLoadOption(GetPrimaryTalentTree())
			end
		end,
		unpack = Utilities.UnpackMultiselectLoadOption
	},
	{
		id = "talent",
		drawer = {
			type = "talent",
			label = "Talent",
			--- @param class string[]
			--- @param specialization integer[]
			availableValues = function(class, specialization)
				local specIds = GetRelevantSpecializationIds(class, specialization)

				if Addon.EXPANSION_LEVEL > Addon.EXPANSION.CATA then
					return Addon:GetLocalizedTalents(specIds)
				else
					return Addon:Cata_GetLocalizedTalents(specIds)
				end
			end
		},
		dependencies = { "class", "specialization" },
		disabled = Addon.EXPANSION_LEVEL < Addon.EXPANSION.CATA,
		init = function()
			return Utilities.CreateTalentLoadOption("")
		end,
		unpack = Utilities.UnpackTalentLoadOption
	},
	{
		id = "pvpTalent",
		drawer = {
			type = "talent",
			label = "PvP talent",
			--- @param class string[]
			--- @param specialization integer[]
			availableValues = function(class, specialization)
				local specIds = GetRelevantSpecializationIds(class, specialization)
				return Addon:GetLocalizedPvPTalents(specIds)
			end
		},
		dependencies = { "class", "specialization" },
		disabled = Addon.EXPANSION_LEVEL < Addon.EXPANSION.BFA,
		init = function()
			return Utilities.CreateTalentLoadOption("")
		end,
		unpack = Utilities.UnpackTalentLoadOption
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
		disabled = Addon.EXPANSION_LEVEL < Addon.EXPANSION.BFA,
		init = function()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
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

				if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.BC then
					items["PVP"] = Addon.L["Battleground"]
					items["ARENA"] = Addon.L["Arena"]

					table.insert(order, "PVP")
					table.insert(order, "ARENA")
				end

				if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.MOP then
					items["SCENARIO"] = Addon.L["Scenario"]
					table.insert(order, 2, "SCENARIO")
				end

				return items, order
			end
		},
		init = function()
			return Utilities.CreateMultiselectLoadOption("NONE")
		end,
		unpack = Utilities.UnpackMultiselectLoadOption
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
			return Utilities.CreateLoadOption("")
		end,
		unpack = Utilities.UnpackSimpleLoadOption,
	},
	{
		id = "spellKnown",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Spell known"
		},
		init = function()
			return Utilities.CreateLoadOption("")
		end,
		unpack = Utilities.UnpackSimpleLoadOption,
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
			return Utilities.CreateLoadOption(Addon.GroupState.PARTY_OR_RAID)
		end,
		unpack = Utilities.UnpackSimpleLoadOption,
	},
	{
		id = "playerInGroup",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Player in group"
		},
		init = function()
			return Utilities.CreateLoadOption("")
		end,
		unpack = Utilities.UnpackSimpleLoadOption,
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
				if type ~= "item" then
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
			return Utilities.CreateLoadOption("")
		end,
		unpack = Utilities.UnpackSimpleLoadOption,
	}
}

Addon.Condition.Registry:RegisterConditionConfig("load", config)

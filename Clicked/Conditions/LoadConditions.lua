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
		unpack = Utilities.UnpackSimpleLoadOption,
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
		unpack = Utilities.UnpackMultiselectLoadOption,
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
		unpack = Utilities.UnpackMultiselectLoadOption,
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
		unpack = Utilities.UnpackMultiselectLoadOption,
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
		unpack = Utilities.UnpackTalentLoadOption,
	}
}

Addon.Condition.Registry:RegisterConditionConfig("load", config)

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
		id = "form",
		drawer = {
			type = "multiselect",
			label = "Form / Stance",
			negatable = true,
			availableValues = function(class, specialization)
				local specIds = GetRelevantSpecializationIds(class, specialization)

				if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.DF then
					return Addon:GetLocalizedForms(specIds)
				else
					return Addon:Classic_GetLocalizedForms(class)
				end
			end
		},
		dependencies = { "class", "specialization" },
		init = function()
			return Utilities.CreateMultiselectLoadOption(1)
		end,
		unpack = Utilities.UnpackMultiselectLoadOption,
	},
	{
		id = "combat",
		drawer = {
			type = "select",
			label = "Combat",
			availableValues = function()
				return {
					[true] = Addon.L["In combat"],
					[false] = Addon.L["Not in combat"]
				}, { true, false }
			end
		},
		init = function()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "pet",
		drawer = {
			type = "select",
			label = "Pet",
			availableValues = function()
				return {
					[true] = Addon.L["Pet"],
					[false] = Addon.L["No pet"]
				}, { true, false }
			end
		},
		init = function()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "stealth",
		drawer = {
			type = "select",
			label = "Stealth",
			availableValues = function()
				return {
					[true] = Addon.L["Stealthed"],
					[false] = Addon.L["Not stealthed"]
				}, { true, false }
			end
		},
		init = function ()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "mounted",
		drawer = {
			type = "select",
			label = "Mounted",
			availableValues = function()
				return {
					[true] = Addon.L["Mounted"],
					[false] = Addon.L["Not mounted"]
				}, { true, false }
			end
		},
		init = function ()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "outdoors",
		drawer = {
			type = "select",
			label = "Outdoors",
			availableValues = function()
				return {
					[true] = Addon.L["Outdoors"],
					[false] = Addon.L["Indoors"]
				}, { true, false }
			end
		},
		init = function ()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "swimming",
		drawer = {
			type = "select",
			label = "Swimming",
			availableValues = function()
				return {
					[true] = Addon.L["Swimming"],
					[false] = Addon.L["Not swimming"]
				}, { true, false }
			end
		},
		init = function ()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "channeling",
		drawer = {
			type = "input",
			label = "Channeling",
			negatable = true
		},
		init = function ()
			return Utilities.CreateLoadOption("")
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "flying",
		disabled = Addon.EXPANSION_LEVEL < Addon.EXPANSION.BC,
		drawer = {
			type = "select",
			label = "Flying",
			availableValues = function()
				return {
					[true] = Addon.L["Flying"],
					[false] = Addon.L["Not flying"]
				}, { true, false }
			end
		},
		init = function ()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "dynamicFlying",
		disabled = Addon.EXPANSION_LEVEL < Addon.EXPANSION.DF,
		drawer = {
			type = "select",
			label = "Skyriding",
			availableValues = function()
				return {
					[true] = Addon.L["Skyriding"],
					[false] = Addon.L["Not skyriding"]
				}, { true, false }
			end
		},
		init = function ()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "flyable",
		disabled = Addon.EXPANSION_LEVEL < Addon.EXPANSION.BC,
		drawer = {
			type = "select",
			label = "Flyable",
			availableValues = function()
				return {
					[true] = Addon.L["Flyable"],
					[false] = Addon.L["Not flyable"]
				}, { true, false }
			end
		},
		init = function ()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "advancedFlyable",
		disabled = Addon.EXPANSION_LEVEL < Addon.EXPANSION.DF,
		drawer = {
			type = "select",
			label = "Advanced flyable",
			availableValues = function()
				return {
					[true] = Addon.L["Advanced flyable"],
					[false] = Addon.L["Not advanced flyable"]
				}, { true, false }
			end
		},
		init = function ()
			return Utilities.CreateLoadOption(true)
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	},
	{
		id = "bonusbar",
		disabled = Addon.EXPANSION_LEVEL < Addon.EXPANSION.CATA,
		drawer = {
			type = "input",
			label = "Bonus bar",
			negatable = true
		},
		init = function ()
			return Utilities.CreateLoadOption("")
		end,
		unpack = Utilities.UnpackSimpleLoadOption
	}
}

Addon.Condition.Registry:RegisterConditionConfig("macro", config)

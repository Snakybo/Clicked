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

local LibStanceDance = LibStub("LibStanceDance")

local Utils = Addon.Condition.Utils

--- @param option LoadCondition<string>
--- @return string
local function FormatMultipleValues(option)
	return table.concat(Utils.UnpackLoadOption(option), "/")
end

--- @param option LoadCondition<string>
--- @param text string
local function ParseMultipleValues(option, text)
	--- @type string[]
	local result = {}

	for value in string.gmatch(text, "([^/]+)") do
		value = string.trim(value)

		if #value > 0 then
			table.insert(result, value)
		end
	end

	Utils.SetLoadOptionValues(option, #result > 0 and result or { "" })
end

--- @param value string
--- @param previousValue string
--- @return string
local function ValidatePageNumbers(value, previousValue)
	return string.find(value, "^[%d/]*$") ~= nil and value or previousValue
end

--- @type MacroCondition[]
local config = {
	{
		id = "form",
		--- @type SelectDrawerConfig
		drawer = {
			type = "select",
			mode = "multiple",
			label = "Form / Stance",
			negatable = true,
			availableValues = function(class, specialization)
				local specIds = Utils.GetRelevantSpecializationIds(class, specialization)

				--- @type table<integer, string>
				local items = {
					Addon.L["None"]
				}

				--- @type integer[]
				local order = {
					1
				}

				--- @type table<integer, { name: string, icon: integer, seen: integer }>
				local forms = {}

				for _, specId in ipairs(specIds) do
					for i, form in ipairs(LibStanceDance:GetForms(specId)) do
						local current = forms[i]

						if current == nil then
							forms[i] = {
								name = form.name,
								icon = form.icon,
								seen = 1
							}
						elseif current.name == form.name and current.icon == form.icon then
							current.seen = current.seen + 1
						end
					end
				end

				for i = 1, #forms do
					local key = #order + 1
					local current = forms[i]

					if current.seen == #specIds then
						items[key] = Addon:GetTextureString(current.name, current.icon)
					else
						items[key] = string.format(Addon.L["Stance %s"], i)
					end

					table.insert(order, key)
				end

				return items, order
			end
		},
		dependencies = { "class", "specialization" },
		init = 1,
		unpack = function(option)
			return Addon:GetAvailableShapeshiftForms(option)
		end,
		conditionals = "form"
	},
	{
		id = "combat",
		drawer = {
			type = "select",
			label = "Combat",
			availableValues = function()
				return {
					[true] = Addon.L["Yes"],
					[false] = Addon.L["No"]
				}, { true, false }
			end
		},
		init = true,
		conditionals = "combat"
	},
	{
		id = "pet",
		drawer = {
			type = "select",
			label = "Pet",
			availableValues = function()
				return {
					[true] = Addon.L["Yes"],
					[false] = Addon.L["No"]
				}, { true, false }
			end
		},
		init = true,
		conditionals = "pet",
		isUnit = true
	},
	{
		id = "stealth",
		drawer = {
			type = "select",
			label = "Stealth",
			availableValues = function()
				return {
					[true] = Addon.L["Yes"],
					[false] = Addon.L["No"]
				}, { true, false }
			end
		},
		init = true,
		conditionals = "stealth"
	},
	{
		id = "mounted",
		drawer = {
			type = "select",
			label = "Mounted",
			availableValues = function()
				return {
					[true] = Addon.L["Yes"],
					[false] = Addon.L["No"]
				}, { true, false }
			end
		},
		init = true,
		conditionals = "mounted"
	},
	{
		id = "outdoors",
		drawer = {
			type = "select",
			label = "Outdoors",
			availableValues = function()
				return {
					[true] = Addon.L["Yes"],
					[false] = Addon.L["No"]
				}, { true, false }
			end
		},
		init = true,
		conditionals = function()
			return "outdoors", "indoors"
		end
	},
	{
		id = "swimming",
		drawer = {
			type = "select",
			label = "Swimming",
			availableValues = function()
				return {
					[true] = Addon.L["Yes"],
					[false] = Addon.L["No"]
				}, { true, false }
			end
		},
		init = true,
		conditionals = "swimming"
	},
	{
		id = "channeling",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Channeling",
			negatable = true,
			tooltip = Addon.L["Separate multiple values with a slash (/)."],
			format = FormatMultipleValues,
			parse = ParseMultipleValues
		},
		init = "",
		conditionals = "channeling"
	},
	{
		id = "flying",
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.TBC,
		drawer = {
			type = "select",
			label = "Flying",
			availableValues = function()
				return {
					[true] = Addon.L["Yes"],
					[false] = Addon.L["No"]
				}, { true, false }
			end
		},
		init = true,
		conditionals = "flying"
	},
	{
		id = "flyable",
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.TBC,
		drawer = {
			type = "select",
			label = "Flyable",
			availableValues = function()
				return {
					[true] = Addon.L["Yes"],
					[false] = Addon.L["No"]
				}, { true, false }
			end
		},
		init = true,
		conditionals = "flyable"
	},
	{
		id = "dynamicFlying",
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.DF,
		drawer = {
			type = "select",
			label = "Dynamic flying",
			availableValues = function()
				return {
					[true] = Addon.L["Yes"],
					[false] = Addon.L["No"]
				}, { true, false }
			end
		},
		init = true,
		conditionals = "bonusbar:5"
	},
	{
		id = "bonusbar",
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.CATA and not Addon:IsForever(),
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Bonus bar",
			negatable = true,
			validate = ValidatePageNumbers,
			tooltip = {
				Addon.L["Enter the bonus bar page number."],
				Addon.L["Separate multiple values with a slash (/)."]
			},
			format = FormatMultipleValues,
			parse = ParseMultipleValues
		},
		init = "",
		conditionals = "bonusbar"
	},
	{
		id = "bar",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Action bar page",
			negatable = true,
			validate = ValidatePageNumbers,
			tooltip = {
				Addon.L["Enter the action bar page number."],
				Addon.L["Separate multiple values with a slash (/)."]
			},
			format = FormatMultipleValues,
			parse = ParseMultipleValues
		},
		init = "",
		ignoreEmptyValues = true,
		conditionals = "bar"
	}
}

Addon.Condition.Registry:RegisterConditionConfig("macro", "conditionals", config)

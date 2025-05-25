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

local Utils = Addon.Condition.Utils

--- @type Condition[]
local config = {
	{
		id = "form",
		drawer = {
			type = "multiselect",
			label = "Form / Stance",
			negatable = true,
			availableValues = function(class, specialization)
				local specIds = Utils.GetRelevantSpecializationIds(class, specialization)

				if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
					return Addon:GetLocalizedForms(specIds)
				else
					return Addon:GetLocalizedForms(class)
				end
			end
		},
		dependencies = { "class", "specialization" },
		init = function()
			return Utils.CreateMultiselectLoadOption(1)
		end,
		unpack = Utils.UnpackMultiselectLoadOption,
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
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
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
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
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
		init = function()
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
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
		init = function()
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
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
		init = function()
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
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
		init = function()
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
	},
	{
		id = "channeling",
		drawer = {
			type = "input",
			label = "Channeling",
			negatable = true
		},
		init = function()
			return Utils.CreateLoadOption("")
		end,
		unpack = Utils.UnpackSimpleLoadOption
	},
	{
		id = "flying",
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.BC,
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
		init = function()
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
	},
	{
		id = "dynamicFlying",
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.DF,
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
		init = function()
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
	},
	{
		id = "flyable",
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.BC,
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
		init = function()
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
	},
	{
		id = "advancedFlyable",
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.DF,
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
		init = function()
			return Utils.CreateLoadOption(true)
		end,
		unpack = Utils.UnpackSimpleLoadOption
	},
	{
		id = "bonusbar",
		disabled = Addon.EXPANSION_LEVEL < Addon.Expansion.CATA,
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Bonus bar",
			negatable = true,
			validate = function(value, previousValue)
				return (#value == 0 or tonumber(value) ~= nil) and value or previousValue
			end,
			tooltip = "Enter the bonus bar page number."
		},
		init = function()
			return Utils.CreateLoadOption("")
		end,
		unpack = Utils.UnpackSimpleLoadOption
	},
	{
		id = "bar",
		--- @type InputDrawerConfig
		drawer = {
			type = "input",
			label = "Action bar page",
			negatable = true,
			validate = function(value, previousValue)
				return (#value == 0 or tonumber(value) ~= nil) and value or previousValue
			end,
			tooltip = "Enter the action bar page number."
		},
		init = function()
			return Utils.CreateLoadOption("")
		end,
		unpack = Utils.UnpackSimpleLoadOption
	}
}

Addon.Condition.Registry:RegisterConditionConfig("macro", config)

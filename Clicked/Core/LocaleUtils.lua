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

local LibTalentTome = LibStub("LibTalentTome")
local LibStanceDance = LibStub("LibStanceDance")

--- @class Addon
local Addon = select(2, ...)

-- Private addon API

--- Stip color codes from a string
---
--- @param str string
--- @return string
function Addon:StripColorCodes(str)
	str = string.gsub(str, "|c%x%x%x%x%x%x%x%x", "")
	str = string.gsub(str, "|c%x%x %x%x%x%x%x", "") -- the trading parts colour has a space instead of a zero for some weird reason
	str = string.gsub(str, "|r", "")

	return str
end

--- Construct a localized string with a summary of the target setting.
---
--- For example:
--- - Friendly Mouseover target
--- - Friendly Dead Target
--- - Hostile Alive Target
---
--- @param target Binding.Target
--- @return string
function Addon:GetLocalizedTargetString(target)
	--- @type string[]
	local result = {}

	if Addon:CanUnitBeHostile(target.unit) and target.hostility ~= Addon.TargetHostility.ANY then
		local hostility = Addon:GetLocalizedTargetHostility()
		table.insert(result, hostility[target.hostility])
	end

	if Addon:CanUnitBeDead(target.unit) and target.vitals ~= Addon.TargetVitals.ANY then
		local vitals = Addon:GetLocalizedTargetVitals()
		table.insert(result, vitals[target.vitals])
	end

	if target.unit ~= nil then
		local units = Addon:GetLocalizedTargetUnits()
		table.insert(result, units[target.unit])
	end

	return table.concat(result, " ")
end

--- Get a localized list of all available target units for a binding.
---
--- @return table<string,string> items
--- @return string[] order
function Addon:GetLocalizedTargetUnits()
	--- @type table<string,string>
	local items = {}

	--- @type string[]
	local order

	items[Addon.TargetUnit.DEFAULT] = Addon.L["Default"]
	items[Addon.TargetUnit.PLAYER] = Addon.L["Player (you)"]
	items[Addon.TargetUnit.TARGET] = Addon.L["Target"]
	items[Addon.TargetUnit.TARGET_OF_TARGET] = Addon.L["Target of target"]
	items[Addon.TargetUnit.MOUSEOVER] = Addon.L["Mouseover"]
	items[Addon.TargetUnit.MOUSEOVER_TARGET] = Addon.L["Target of mouseover"]
	items[Addon.TargetUnit.CURSOR] = Addon.L["Cursor"]
	items[Addon.TargetUnit.PET] = Addon.L["Pet"]
	items[Addon.TargetUnit.PET_TARGET] = Addon.L["Pet target"]
	items[Addon.TargetUnit.PARTY_1] = Addon.L["Party %s"]:format("1")
	items[Addon.TargetUnit.PARTY_2] = Addon.L["Party %s"]:format("2")
	items[Addon.TargetUnit.PARTY_3] = Addon.L["Party %s"]:format("3")
	items[Addon.TargetUnit.PARTY_4] = Addon.L["Party %s"]:format("4")
	items[Addon.TargetUnit.PARTY_5] = Addon.L["Party %s"]:format("5")

	order = {
		Addon.TargetUnit.DEFAULT,
		Addon.TargetUnit.PLAYER,
		Addon.TargetUnit.TARGET,
		Addon.TargetUnit.TARGET_OF_TARGET,
		Addon.TargetUnit.MOUSEOVER,
		Addon.TargetUnit.MOUSEOVER_TARGET,
		Addon.TargetUnit.CURSOR,
		Addon.TargetUnit.PET,
		Addon.TargetUnit.PET_TARGET,
		Addon.TargetUnit.PARTY_1,
		Addon.TargetUnit.PARTY_2,
		Addon.TargetUnit.PARTY_3,
		Addon.TargetUnit.PARTY_4,
		Addon.TargetUnit.PARTY_5
	}

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.TBC or Addon:IsForever() then
		items[Addon.TargetUnit.FOCUS] = Addon.L["Focus"]
		table.insert(order, 7, Addon.TargetUnit.FOCUS)
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
		items[Addon.TargetUnit.ARENA_1] = Addon.L["Arena %s"]:format("1")
		items[Addon.TargetUnit.ARENA_2] = Addon.L["Arena %s"]:format("2")
		items[Addon.TargetUnit.ARENA_3] = Addon.L["Arena %s"]:format("3")
		table.insert(order, Addon.TargetUnit.ARENA_1)
		table.insert(order, Addon.TargetUnit.ARENA_2)
		table.insert(order, Addon.TargetUnit.ARENA_3)
	end

	return items, order
end

--- Get a localized list of all available target hostility settings.
---
--- @return table<string,string> items
--- @return string[] order
function Addon:GetLocalizedTargetHostility()
	--- @type table<string,string>
	local items = {
		[Addon.TargetHostility.ANY] = Addon.L["Friendly, Hostile"],
		[Addon.TargetHostility.HELP] = Addon.L["Friendly"],
		[Addon.TargetHostility.HARM] = Addon.L["Hostile"]
	}

	--- @type string[]
	local order = {
		Addon.TargetHostility.ANY,
		Addon.TargetHostility.HELP,
		Addon.TargetHostility.HARM
	}

	return items, order
end

--- Get a localized list of all available target vitals settings.
---
--- @return table<string,string> items
--- @return string[] order
function Addon:GetLocalizedTargetVitals()
	--- @type table<string,string>
	local items = {
		[Addon.TargetVitals.ANY] = Addon.L["Alive, Dead"],
		[Addon.TargetVitals.ALIVE] = Addon.L["Alive"],
		[Addon.TargetVitals.DEAD] = Addon.L["Dead"]
	}

	--- @type string[]
	local order = {
		Addon.TargetVitals.ANY,
		Addon.TargetVitals.ALIVE,
		Addon.TargetVitals.DEAD
	}

	return items, order
end

--- @param scope DataObjectScope
function Addon:GetLocalizedScope(scope)
	if scope == Clicked.DataObjectScope.GLOBAL then
		return Addon.L["Global"]
	end

	if scope == Clicked.DataObjectScope.PROFILE then
		local defaultProfiles = {
			["Default"] = Addon.L["Default"],
			[Addon.db.keys.char] = Addon.db.keys.char,
			[Addon.db.keys.realm] = Addon.db.keys.realm,
			[Addon.db.keys.class] = UnitClass("player")
		}

		local profile = Addon.db:GetCurrentProfile()
		return defaultProfiles[profile] or profile
	end

	Clicked:LogError("Unknown binding scope: {scope}", scope)
end

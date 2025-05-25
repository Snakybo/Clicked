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

--- @enum ExpansionLevel
Addon.Expansion = {
	CLASSIC = 1,
	BC = 2,
	WOTLK = 3,
	CATA = 4,
	MOP = 5,
	WOD = 6,
	LEGION = 7,
	BFA = 8,
	SL = 9,
	DF = 10,
	TWW = 11,
}

--- @type ExpansionLevel
Addon.EXPANSION_LEVEL = nil

---@debug@
-- luacheck: ignore
---@diagnostic disable-next-line: lowercase-global
function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			-- luacheck: ignore
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end
---@end-debug@

--- @param err any
--- @return function
local function errorhandler(err)
	return geterrorhandler()(err)
end

--- @param func? function
--- @param ... any
--- @return boolean status
--- @return ...
function Addon:SafeCall(func, ...)
	if func ~= nil then
		return xpcall(func, errorhandler, ...)
	end

	return false
end

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
	Addon.EXPANSION_LEVEL = Addon.Expansion.TWW
elseif WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
	Addon.EXPANSION_LEVEL = Addon.Expansion.MOP
elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then
	Addon.EXPANSION_LEVEL = Addon.Expansion.CATA
elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
	Addon.EXPANSION_LEVEL = Addon.Expansion.WOTLK
elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then
	Addon.EXPANSION_LEVEL = Addon.Expansion.BC
elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
	Addon.EXPANSION_LEVEL = Addon.Expansion.CLASSIC
end

--- Check if the user is running a development build of the addon.
---
--- @return boolean
function Addon:IsDevelopmentBuild()
--@debug@
	if Clicked.VERSION == "development" then
		return true
	end
--@end-debug@
	return false
end

-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
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

--- Check if the game client is running the retail version of the API.
---
--- @return boolean
function Addon:IsRetail()
	return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
end

--- Check if the game client is running the Classic version of the API.
---
--- @return boolean
function Addon:IsClassic()
	return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

--- Check if the game client is running the Burning Crusade version of the API.
---
--- @return boolean
function Addon:IsBC()
	return WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
end

--- Check if the game client is running the Wrath of the Lich King version of the API.
---
--- @return boolean
function Addon:IsWotLK()
	return WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC
end

--- Check if the game client is running the Cataclysm version of the API.
---
--- @return boolean
function Addon:IsCata()
	return WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC
end

--- Check if the client version is at least the specified version, for example `IsAtLeast("BC")` will return `true` on both the BC and Retail versions of the
--- game, but `false` on Classic.
---
--- @param version "RETAIL"|"CLASSIC"|"BC"|"WOTLK"|"CATA"
--- @return boolean
function Addon:IsGameVersionAtleast(version)
	local isRetail = Addon:IsRetail()
	local isCata = isRetail or Addon:IsCata()
	local isWOTLK = isCata or Addon:IsWotLK()
	local isBC = isWOTLK or Addon:IsBC()
	local isClassic = isBC or Addon:IsClassic()

	if version == "RETAIL" and isRetail then
		return true
	elseif version == "WOTLK" and isWOTLK then
		return true
	elseif version == "BC" and isBC then
		return true
	elseif version == "CLASSIC" and isClassic then
		return true
	end

	return false
end

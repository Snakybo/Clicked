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

--- @class Clicked : AceAddon, AceEvent-3.0, LibLog-1.0.Logger
Clicked2 = LibStub("AceAddon-3.0"):NewAddon("Clicked2", "AceEvent-3.0", "LibLog-1.0")
Clicked2.VERSION = C_AddOns.GetAddOnMetadata("Clicked2", "Version")

Clicked2:SetDefaultModuleLibraries("LibLog-1.0")
Clicked2:LogVerbose("Initializing Clicked")

--@debug@
if Clicked2.VERSION == "@project-version@" then
	Clicked2.VERSION = "development"
	Clicked2:LogVerbose("Detected development version")
end
--@end-debug@

--- @class Addon
local Addon = select(2, ...)
Addon.L = LibStub("AceLocale-3.0"):GetLocale("Clicked2")

--- @enum Expansion
Addon.Expansion = {
	CLASSIC = 1,
	TBC = 2,
	WOTLK = 3,
	CATA = 4,
	MOP = 5,
	WOD = 6,
	LEGION = 7,
	BFA = 8,
	SL = 9,
	DF = 10,
	TWW = 11,
	MN = 12,
}

do
	--- @type { [Expansion]: { min: integer, max: integer } }
	local interfaceVersionMap ={
		[Addon.Expansion.CLASSIC] = { min = 10000, max = 20000 },
		[Addon.Expansion.TBC] = { min = 20000, max = 30000 },
		[Addon.Expansion.WOTLK] = { min = 30000, max = 40000 },
		[Addon.Expansion.CATA] = { min = 40000, max = 50000 },
		[Addon.Expansion.MOP] = { min = 50000, max = 60000 },
		[Addon.Expansion.WOD] = { min = 60000, max = 70000 },
		[Addon.Expansion.LEGION] = { min = 70000, max = 80000 },
		[Addon.Expansion.BFA] = { min = 80000, max = 90000 },
		[Addon.Expansion.SL] = { min = 90000, max = 100000 },
		[Addon.Expansion.DF] = { min = 100000, max = 110000 },
		[Addon.Expansion.TWW] = { min = 110000, max = 120000 },
		[Addon.Expansion.MN] = { min = 120000, max = 130000 },
	}

	local interfaceVersion = select(4, GetBuildInfo())

	--- @param projectId integer
	--- @param range { min: integer, max: integer }
	--- @return boolean
	local function IsExpansion(projectId, range)
		if WOW_PROJECT_ID ~= projectId then
			return false
		end

		return interfaceVersion >= range.min and interfaceVersion < range.max
	end

	--- @return Expansion
	local function GetExpansionLevel()
		if IsExpansion(WOW_PROJECT_MAINLINE, interfaceVersionMap[Addon.Expansion.MN]) then
			return Addon.Expansion.MN
		elseif IsExpansion(WOW_PROJECT_MISTS_CLASSIC, interfaceVersionMap[Addon.Expansion.MOP]) then
			return Addon.Expansion.MOP
		elseif IsExpansion(WOW_PROJECT_CATACLYSM_CLASSIC, interfaceVersionMap[Addon.Expansion.CATA]) then
			return Addon.Expansion.CATA
		elseif IsExpansion(WOW_PROJECT_WRATH_CLASSIC, interfaceVersionMap[Addon.Expansion.WOTLK]) then
			return Addon.Expansion.WOTLK
		elseif IsExpansion(WOW_PROJECT_BURNING_CRUSADE_CLASSIC, interfaceVersionMap[Addon.Expansion.TBC]) then
			return Addon.Expansion.TBC
		elseif IsExpansion(WOW_PROJECT_CLASSIC, interfaceVersionMap[Addon.Expansion.CLASSIC]) then
			return Addon.Expansion.CLASSIC
		end

		return Clicked2:LogFatal("Unable to determine expansion level for game flavor {projectId} and interface version {interfaceVersion}",
			WOW_PROJECT_ID, interfaceVersion)
	end

	Addon.EXPANSION = GetExpansionLevel()
	Clicked2:LogVerbose("Detected expansion {expansion}", Addon.EXPANSION)
end

--- @param func? fun(...): ...
--- @param ... any
--- @return boolean status
--- @return ...
function Addon:SafeCall(func, ...)
	if func ~= nil then
		return xpcall(func, geterrorhandler(), ...)
	end

	return false
end

--- Check if the user is running a development build of the addon.
---
--- @return boolean
function Addon:IsDevelopmentBuild()
--@debug@
	if Clicked2.VERSION == "development" then
		return true
	end
--@end-debug@

	return false
end

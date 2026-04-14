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

--- @enum CastActionFlags
Clicked2.CastActionFlags = {
	INCLUDE_SUBTEXT = 1,
	IS_MAX_RANK = 2,
	PREVENT_TOGGLE = 4
}

--- @class CastAction : Action2
--- @field public spellName string
--- @field public spellId? integer
--- @field public spellFlags CastActionFlags

--- @class CastActionHandler : ActionHandler
local Prototype = {}

--- @param action Action2
--- @return CastAction
function Prototype.Create(action)
	--- @cast action CastAction

	action.spellName = ""
	action.spellFlags = 0

	return action
end

--- @return table
function Prototype.GetDatabaseDefaults()
	return {
		spellName = "",
		spellFlags = 0,
	}
end

Clicked2.ActionLibrary:Register("CastAction", Prototype)

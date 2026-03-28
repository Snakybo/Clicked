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

--- @class StopSpellTargetAction : Action2

--- @class StopSpellTargetActionHandler : ActionHandler
local Prototype = {}

--- @param action Action2
--- @return StopSpellTargetAction
function Prototype.Create(action)
	--- @cast action StopSpellTargetAction

	return action
end

Clicked2.ActionLibrary:Register("StopSpellTargetAction", Prototype)

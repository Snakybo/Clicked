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

--- @class AppendAction : Action2
--- @field public appendText string

--- @class AppendActionHandler : ActionHandler
local Prototype = {}

--- @param action Action2
--- @return AppendAction
function Prototype.Create(action)
	--- @cast action AppendAction

	action.typeOverride = "AppendAction"
	action.appendText = ""

	return action
end

--- @return table
function Prototype.GetDatabaseDefaults()
	return {
		appendText = ""
	}
end

Clicked2.ActionLibrary:Register("AppendAction", Prototype)

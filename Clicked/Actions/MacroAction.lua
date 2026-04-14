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

--- @class MacroAction : Action2
--- @field public macroName string
--- @field public macroIcon string
--- @field public macroText string

--- @class MacroActionHandler : ActionHandler
local Prototype = {}

--- @param action Action2
--- @return MacroAction
function Prototype.Create(action)
	--- @cast action MacroAction

	action.macroName = ""
	action.macroIcon = "Interface\\ICONS\\INV_Misc_QuestionMark"
	action.macroText = ""

	return action
end

--- @return table
function Prototype.GetDatabaseDefaults()
	return {
		macroName = "",
		macroIcon = "Interface\\ICONS\\INV_Misc_QuestionMark",
		macroText = ""
	}
end

Clicked2.ActionLibrary:Register("MacroAction", Prototype)

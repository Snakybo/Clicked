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

--- @type boolean
local requiresCombatProcess = false

-- Local support functions

-- Private addon API

--- @param commands Command[]
function Addon:ProcessCommands(commands)
	if InCombatLockdown() then
		return
	end

	--- @type Keybind[]
	local newClickCastFrameKeybinds = {}

	--- @type table<string,string>
	local newClickCastFrameAttributes = {}

	--- @type Keybind[]
	local newMacroFrameHandlerKeybinds = {}

	--- @type table<string,string>
	local newMacroFrameHandlerAttributes = {}

	-- Unregister all current keybinds
	requiresCombatProcess = false

	for _, command in ipairs(commands) do
		local attributes = {}

		local targetKeybinds
		local targetAttributes

		local keybind = {
			key = command.keybind,
			identifier = command.suffix
		}

		Addon:CreateCommandAttributes(attributes, command, command.prefix, command.suffix)

		if command.hovercast then
			targetKeybinds = newClickCastFrameKeybinds
			targetAttributes = newClickCastFrameAttributes
		else
			targetKeybinds = newMacroFrameHandlerKeybinds
			targetAttributes = newMacroFrameHandlerAttributes
		end

		-- If this is a mouse button there is no need to run `SetBindingClick` as it will capture mouse
		-- input anyway. There is also a bug (?) that causes the mouse to lock up if the user clicks just
		-- outside of the unit frame, and then drags the cursor into the unit frame before the game hides it.
		-- If that happens the user is forced to /reload as the cursor is stuck in camera-rotation mode.
		-- See: #37
		if not command.hovercast or not Addon:IsMouseButton(keybind.key) then
			table.insert(targetKeybinds, keybind)
		end

		for attribute, value in pairs(attributes) do
			targetAttributes[attribute] = value
		end

		if (command.action == Addon.CommandType.TARGET or command.action == Addon.CommandType.MENU) and command.data ~= nil then
			requiresCombatProcess = true
		end
	end

	Addon:StatusOutput_UpdateMacroHandlerAttributes(newMacroFrameHandlerAttributes)
	Addon:StatusOutput_UpdateHovercastAttributes(newClickCastFrameAttributes)

	Clicked2:SendMessage("CLICKED_GLOBAL_CAST_ATTRIBUTES_CHANGED", newMacroFrameHandlerKeybinds, newMacroFrameHandlerAttributes)
	Clicked2:SendMessage("CLICKED_CLICK_CAST_ATTRIBUTES_CHANGED", newClickCastFrameKeybinds, newClickCastFrameAttributes)
end

--- Get whether re-procesing of active bindings should happen when entering and leaving combat.
---
---@return boolean
function Addon:IsCombatProcessRequired()
	return requiresCombatProcess
end

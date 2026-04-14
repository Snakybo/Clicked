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

--- @param handler ActionHandler
--- @return boolean
local function HasDatabaseDefaults(handler)
	return type(handler.GetDatabaseDefaults) == "function"
end

--- @class ActionLibrary
--- @field private library table<string, ActionHandler>
local Prototype = {
	library = {}
}

--- @param type string
--- @param handler ActionHandler
function Prototype:Register(type, handler)
	self.library[type] = handler

	if HasDatabaseDefaults(handler) then
		Addon.Datastore:UpdateDatabaseDefaults()
	end
end

--- @param type string
--- @return ActionHandler
function Prototype:Get(type)
	local result = self.library[type]
	if result == nil then
		return Clicked2:LogError("Cannot find action handler for type {type}", type)
	end

	return result
end

--- @return table
function Prototype:GetDatabaseDefaults()
	local result = {}

	for _, handler in pairs(self.library) do
		if HasDatabaseDefaults(handler) then
			local success, defaults = Addon.SafeCall(handler.GetDatabaseDefaults)

			if success then
				result = Mixin(result, defaults)
			end
		end
	end

	return result
end

Clicked2.ActionLibrary = Prototype

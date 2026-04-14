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

--- @class DataUtils
local Prototype = {}

--- @param object table
--- @param update table
--- @param hooks? table<string, fun(original: unknown, new: unknown)>
--- @return boolean
function Prototype.UpdateObject(object, update, hooks)
	local dirty = false

	for key, value in pairs(update) do
		local original = object[key]

		if type(original) == "table" and type(value) == "table" then
			if hooks ~= nil and hooks[key] ~= nil then
				hooks[key](original, value)
			end

			for key2, value2 in pairs(value) do
				local original2 = original[key2]

				if hooks ~= nil and hooks[key .. "." .. key2] ~= nil then
					hooks[key .. "." .. key2](original2, value2)
				end

				original[key2] = value2
				dirty = true
			end
		else
			if original ~= value then
				if hooks ~= nil and hooks[key] ~= nil then
					hooks[key](original, value)
				end

				object[key] = value
				dirty = true
			end
		end
	end

	return dirty
end

Addon.DataUtils = Prototype

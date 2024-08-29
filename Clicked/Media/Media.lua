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

local LSM = LibStub("LibSharedMedia-3.0");

--- @class ClickedInternal
local Addon = select(2, ...)

Addon.Media = {
	FONT_MONO = "JetBrains Mono Regular"
}

local basePath = [[Interface\AddOns\Clicked\Media\]]
local fontPath = basePath .. [[Fonts\]]

LSM:Register("font", Addon.Media.FONT_MONO, fontPath .. "JetBrainsMonoNL-Regular.ttf", LSM.LOCALE_BIT_western + LSM.LOCALE_BIT_ruRU)

-- Private addon API

--- @param object any
function Addon.Media:UseMonoFont(object)
	local path = LSM:Fetch("font", Addon.Media.FONT_MONO)

	if path == nil then
		return
	end

	-- AceGUIWidget
	if object.editBox ~= nil then
		object = object.editBox
	end

	-- EditBox
	if object.SetFont ~= nil then
		--- @cast object EditBox
		object:SetFont(path, 12, "")
	end
end

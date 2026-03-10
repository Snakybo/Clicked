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

--- @class (partial) Addon
local Addon = select(2, ...)

-- Private addon API

--- @param frame Frame
--- @return boolean
function Addon:IsFrameBlacklisted(frame)
	if frame == nil then
		return false
	end

	local blacklist = Addon.db.profile.blacklist
	local name = frame:GetName()

	return blacklist[name]
end

-- Public addon API

--- Ensure that a frame is registered for mouse clicks and scrollwheel events. This will override the `RegisterForClicks` and `EnableMouseWheel` properties on
--- the frame. Because Clicked supports both on-down and on-up casting, if your addon provides built-in click behaviour, you may have to add in support for
--- this too.
---

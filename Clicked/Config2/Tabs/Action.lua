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

--- @class ClickedInternal
local Addon = select(2, ...)

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigActionTab : BindingConfigTab
Addon.BindingConfig.BindingActionTab = {}

function Addon.BindingConfig.BindingActionTab:Show()
end

function Addon.BindingConfig.BindingActionTab:Hide()
end

function Addon.BindingConfig.BindingActionTab:Redraw()
end

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

--- @class ConfigWindowModule : AceModule, AceEvent-3.0, LibLog-1.0.Logger, SlashCommandHandler
local Prototype = {}

--- @protected
function Prototype:OnInitialize()
	self:RegisterEvent("PLAYER_REGEN_DISABLED", self.PLAYER_REGEN_DISABLED, self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED, self)

	self:LogDebug("Initialized config window module")
end

--- @param args string[]
--- @return boolean
function Prototype:HandleSlashCommand(args)
	if #args == 0 then
		if InCombatLockdown() then
			self.openConfigPending = true
			self:LogWarning(Addon.L["Binding configuration will open once you leave combat."])
		else
			Addon.BindingConfig.Window:Open()
		end
	end

	return false
end

--- @private
function Prototype:PLAYER_REGEN_DISABLED()
	self.openConfigPending = Addon.BindingConfig.Window:IsOpen()

	Addon.BindingConfig.Window:Close()
end

--- @private
function Prototype:PLAYER_REGEN_ENABLED()
	if self.openConfigPending then
		Addon.BindingConfig.Window:Open()
		self.openConfigPending = false
	end
end

Clicked2:NewModule("ConfigWindow", Prototype, "AceEvent-3.0")

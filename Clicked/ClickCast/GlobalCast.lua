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

--- @class GlobalCastHeader : Button, SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerShowHideTemplate

--- @class Addon
local Addon = select(2, ...)

--- @class GlobalCastModule : ClickedModule, AceEvent-3.0
--- @field public frame GlobalCastHeader
local Prototype = {}

--- @protected
function Prototype:OnInitialize()
	do
		self.frame = CreateFrame("Button", "ClickedGlobalCast", UIParent, "SecureActionButtonTemplate,SecureHandlerStateTemplate,SecureHandlerShowHideTemplate")
		self.frame:SetAttribute("useOnkeyDown", true)
		self.frame:SetAttribute("pressAndHoldAction", true)
		self.frame:SetAttribute("_onshow", [[
			self:RunAttribute("clicked-set")
		]])
		self.frame:SetAttribute("_onhide", [[
			self:RunAttribute("clicked-unset")
		]])
		self.frame:SetAttribute("clicked-set", [[
			if not self:IsShown() then
				return
			end

			if self:GetAttribute("state-petbattle") == "enabled" then
				return
			end

			if self:GetAttribute("state-vehicleui") == "enabled" then
				return
			end

			if self:GetAttribute("state-possessbar") == "enabled" then
				return
			end

			if self:GetAttribute("state-overridebar") == "enabled" then
				return
			end

			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				local identifier = identifiers[i]

				self:SetBindingClick(true, keybind, self, identifier)
			end
		]])
		self.frame:SetAttribute("clicked-unset", [[
			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				self:ClearBinding(keybind)
			end
		]])

		Addon.AttributeHandler:UpdateRestrictedEnvironment(self.frame)

		self.frame:Hide()

		if Addon.EXPANSION >= Addon.Expansion.WOTLK then
			self:CreateStateDriverAttribute("vehicleui", "[vehicleui] enabled; disabled")
		end

		if Addon.EXPANSION >= Addon.Expansion.MOP then
			self:CreateStateDriverAttribute("petbattle", "[petbattle] enabled; disabled")
		end

		self:CreateStateDriverAttribute("possessbar", "[possessbar] enabled; disabled")
		self:CreateStateDriverAttribute("overridebar", "[overridebar] enabled; disabled")

		Addon.ClickCast:RegisterClicks(self.frame)
	end

	self:RegisterMessage("CLICKED_GLOBAL_CAST_ATTRIBUTES_CHANGED", self.CLICKED_GLOBAL_CAST_ATTRIBUTES_CHANGED, self)

	self:LogDebug("Initialized global-cast module")
end

--- @private
--- @param state string
--- @param condition string
function Prototype:CreateStateDriverAttribute(state, condition)
	self.frame:SetAttribute("_onstate-" .. state, [[
		if not self:IsShown() then
			return
		end

		if newstate == "enabled" then
			self:RunAttribute("clicked-clear-bindings")
		else
			self:RunAttribute("clicked-register-bindings")
		end
	]])

	RegisterStateDriver(self.frame, state, condition)
end

--- @private
function Prototype:CLICKED_GLOBAL_CAST_ATTRIBUTES_CHANGED(_, keybinds, newAttributes)
	Addon.Perf.StartSegment("GlobalCast_EventHandler")

	self.frame:Hide()

	Addon.AttributeHandler:UpdateRestrictedEnvironment(self.frame, keybinds)
	Addon.AttributeHandler:ApplyAttributes(self.frame, newAttributes)

	self.frame:Show()

	Addon.Perf.StopSegment("GlobalCast_EventHandler")
end

--- @type GlobalCastModule
Addon.GlobalCast = Clicked2:NewModule("GlobalCast", Prototype, "AceEvent-3.0")

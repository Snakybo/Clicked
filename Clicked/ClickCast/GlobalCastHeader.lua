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

--- @param state string
--- @param condition string
local function CreateStateDriverAttribute(state, condition)
	Addon.globalCastHeader:SetAttribute("_onstate-" .. state, [[
		if not self:IsShown() then
			return
		end

		if newstate == "enabled" then
			self:RunAttribute("clicked-clear-bindings")
		else
			self:RunAttribute("clicked-register-bindings")
		end
	]])

	RegisterStateDriver(Addon.globalCastHeader, state, condition)
end

--- @class GlobalCastHeaderModule : AceModule, AceEvent-3.0, LibLog-1.0.Logger
local Prototype = {}

--- @protected
function Prototype:OnInitialize()
	Addon.globalCastHeader = CreateFrame("Button", "ClickedGlobalCast", UIParent, "SecureActionButtonTemplate,SecureHandlerStateTemplate,SecureHandlerShowHideTemplate")
	Addon.globalCastHeader:SetAttribute("useOnkeyDown", true)
	Addon.globalCastHeader:SetAttribute("pressAndHoldAction", true)
	Addon.globalCastHeader:SetAttribute("_onshow", [[
		self:RunAttribute("clicked-set")
	]])
	Addon.globalCastHeader:SetAttribute("_onhide", [[
		self:RunAttribute("clicked-unset")
	]])
	Addon.globalCastHeader:SetAttribute("clicked-set", [[
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
	Addon.globalCastHeader:SetAttribute("clicked-unset", [[
		for i = 1, table.maxn(keybinds) do
			local keybind = keybinds[i]
			self:ClearBinding(keybind)
		end
	]])

	Addon.ClickCast:UpdateRestrictedEnvironment(Addon.globalCastHeader)

	Addon.globalCastHeader:Hide()

	if Addon.EXPANSION >= Addon.Expansions.WOTLK then
		CreateStateDriverAttribute("vehicleui", "[vehicleui] enabled; disabled")
	end

	if Addon.EXPANSION >= Addon.Expansions.MOP then
		CreateStateDriverAttribute("petbattle", "[petbattle] enabled; disabled")
	end

	CreateStateDriverAttribute("possessbar", "[possessbar] enabled; disabled")
	CreateStateDriverAttribute("overridebar", "[overridebar] enabled; disabled")

	Clicked2:RegisterFrameClicks(Addon.globalCastHeader)

	self:RegisterMessage("CLICKED_GLOBAL_CAST_ATTRIBUTES_CHANGED", self.CLICKED_GLOBAL_CAST_ATTRIBUTES_CHANGED, self)

	self:LogDebug("Initialized global-cast header module")
end

--- @private
function Prototype:CLICKED_GLOBAL_CAST_ATTRIBUTES_CHANGED(_, keybinds, newAttributes)
	Addon.globalCastHeader:Hide()

	Addon.ClickCast:UpdateRestrictedEnvironment(Addon.globalCastHeader, keybinds)
	Addon.ClickCast:ApplyAttributes(Addon.globalCastHeader, newAttributes)

	Addon.globalCastHeader:Show()
end

Clicked2:NewModule("GlobalCastHeader", Prototype, "AceEvent-3.0")

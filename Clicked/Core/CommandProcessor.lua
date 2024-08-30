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

Addon.MACRO_FRAME_HANDLER_NAME = "ClickedMacroFrameHandler"

--- @type Button
local macroFrameHandler

--- @type boolean
local requiresCombatProcess = false

-- Local support functions

--- @param frame Frame
--- @param state string
--- @param condition string
local function CreateStateDriverAttribute(frame, state, condition)
	frame:SetAttribute("_onstate-" .. state, [[
		if not self:IsShown() then
			return
		end

		if newstate == "enabled" then
			self:RunAttribute("clicked-clear-bindings")
		else
			self:RunAttribute("clicked-register-bindings")
		end
	]])

	RegisterStateDriver(frame, state, condition)
end

local function EnsureMacroFrameHandler()
	if macroFrameHandler ~= nil then
		return
	end

	macroFrameHandler = CreateFrame("Button", Addon.MACRO_FRAME_HANDLER_NAME, UIParent, "SecureActionButtonTemplate,SecureHandlerStateTemplate,SecureHandlerShowHideTemplate") --[[@as Button]]
	macroFrameHandler:Hide()

	-- set required data first
	macroFrameHandler:SetAttribute("clicked-keybinds", "")
	macroFrameHandler:SetAttribute("clicked-identifiers", "")

	-- register OnShow and OnHide handlers to ensure bindings are registered
	macroFrameHandler:SetAttribute("_onshow", [[
		self:RunAttribute("clicked-register-bindings")
	]])

	macroFrameHandler:SetAttribute("_onhide", [[
		self:RunAttribute("clicked-clear-bindings")
	]])

	-- attempt to register a binding, this will also check if the binding
	-- is currently allowed to be active (e.g. not in a vehicle or pet battle)
	macroFrameHandler:SetAttribute("clicked-register-bindings", [[
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

		local keybinds = self:GetAttribute("clicked-keybinds")
		local identifiers = self:GetAttribute("clicked-identifiers")

		if strlen(keybinds) > 0 then
			keybinds = table.new(strsplit("\001", keybinds))
			identifiers = table.new(strsplit("\001", identifiers))

			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				local identifier = identifiers[i]

				self:SetBindingClick(true, keybind, self, identifier)
			end
		end
	]])

	-- unregister a binding
	macroFrameHandler:SetAttribute("clicked-clear-bindings", [[
		local keybinds = self:GetAttribute("clicked-keybinds")

		if strlen(keybinds) > 0 then
			keybinds = table.new(strsplit("\001", keybinds))

			for i = 1, table.maxn(keybinds) do
				local keybind = keybinds[i]
				self:ClearBinding(keybind)
			end
		end
	]])

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.WOTLK then
		CreateStateDriverAttribute(macroFrameHandler, "vehicleui", "[vehicleui] enabled; disabled")
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
		CreateStateDriverAttribute(macroFrameHandler, "petbattle", "[petbattle] enabled; disabled")
	end

	CreateStateDriverAttribute(macroFrameHandler, "possessbar", "[possessbar] enabled; disabled")
	CreateStateDriverAttribute(macroFrameHandler, "overridebar", "[overridebar] enabled; disabled")

	Addon:UpdateMacroFrameHandlerPressType()
	Clicked:RegisterFrameClicks(macroFrameHandler, false)
end

-- Private addon API

--- @param keybinds Keybind[]
--- @param attributes string[]
function Addon:UpdateMacroFrameHandler(keybinds, attributes)
	local split = {
		keybinds = {},
		identifiers = {}
	}

	for _, keybind in ipairs(keybinds) do
		table.insert(split.keybinds, keybind.key)
		table.insert(split.identifiers, keybind.identifier)
	end

	macroFrameHandler:SetAttribute("clicked-keybinds", table.concat(split.keybinds, "\001"))
	macroFrameHandler:SetAttribute("clicked-identifiers", table.concat(split.identifiers, "\001"))

	Addon:SetPendingFrameAttributes(macroFrameHandler, attributes)
	Addon:ApplyAttributesToFrame(macroFrameHandler)
end

function Addon:UpdateMacroFrameHandlerPressType()
	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF then
		local value = not Addon.db.profile.options.onKeyDown
		macroFrameHandler:SetAttribute("pressAndHoldAction", value)
	end
end

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

	EnsureMacroFrameHandler()

	-- Unregister all current keybinds
	macroFrameHandler:Hide()
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
	Addon:UpdateMacroFrameHandler(newMacroFrameHandlerKeybinds, newMacroFrameHandlerAttributes)

	-- Register all new keybinds
	macroFrameHandler:Show()

	Addon:StatusOutput_UpdateHovercastAttributes(newClickCastFrameAttributes)
	Addon:UpdateClickCastHeader(newClickCastFrameKeybinds)
	Addon:UpdateClickCastFrames(newClickCastFrameAttributes)
end

--- Get whether re-procesing of active bindings should happen when entering and leaving combat.
---
---@return boolean
function Addon:IsCombatProcessRequired()
	return requiresCombatProcess
end

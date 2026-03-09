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

local HAS_TYPE_RELEASE = Addon.EXPANSION >= Addon.Expansions.DF or Addon.EXPANSION == Addon.Expansions.TBC

--- @class ClickCastModule : AceModule, AceEvent-3.0, LibLog-1.0.Logger
local Prototype = {}

--- @protected
function Prototype:OnInitialize()
	--- @type table<Frame, table<string, string>>
	self.frameCache = {}

	--- @type { frame: Button, addon: string }[]
	self.registerClicksQueue = {}

	self:RegisterEvent("PLAYER_ENTERING_WORLD", self.PLAYER_ENTERING_WORLD, self)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED, self)
	self:RegisterEvent("ADDON_LOADED", self.ADDON_LOADED, self)

	self:LogDebug("Initialized click-cast module")
end

--- @param frame Frame
--- @param attributes? table<string,string>
function Prototype:ApplyAttributes(frame, attributes)
	if frame == nil then
		return
	end

	--- @type table<string, string>
	local pending = {}

	if attributes ~= nil then
		for key, value in pairs(attributes) do
			if not Addon.db.profile.options.onKeyDown and HAS_TYPE_RELEASE and frame == Addon.globalCastHeader then
				key = string.gsub(key, "^type", "typerelease")
			end

			pending[key] = value
		end
	end

	local applied = self.frameCache[frame] or {}

	for key in pairs(applied) do
		if pending[key] == nil then
			self:LogVerbose("Clearing attribute {attribute} from frame {frameName}", key, frame:GetName())
			frame:SetAttribute(key, nil)
		end
	end

	for key, value in pairs(pending) do
		if value ~= applied[key] then
			self:LogVerbose("Setting attribute {attribute} to {value} on {frameName}", key, value, frame:GetName())
			frame:SetAttribute(key, value)
		end
	end

	self.frameCache[frame] = pending
end

--- @param frame Frame
--- @param keybinds? Keybind[]
function Prototype:UpdateRestrictedEnvironment(frame, keybinds)
	--- @type string[]
	local keys = {}

	--- @type string[]
	local identifiers = {}

	if keybinds ~= nil then
		for _, keybind in ipairs(keybinds) do
			local key = string.gsub(keybind.key, "\\", "\\\\")
			local identifier = string.gsub(keybind.identifier, "\\", "\\\\")

			table.insert(keys, key)
			table.insert(identifiers, identifier)
		end
	end

	--- @type string
	local command

	if keybinds == nil or #keybinds == 0 then
		command = [[
			keybinds = table.new()
			identifiers = table.new()
		]]
	else
		command = string.format([[
			keybinds = table.new(%s)
			identifiers = table.new(%s)
		]], "\"" .. table.concat(keys, "\", \"") .. "\"",
		    "\"" .. table.concat(identifiers, "\", \"") .. "\"")
	end

	--- @diagnostic disable-next-line: undefined-field
	frame:Execute(command)
end

--- @param frame Button
function Prototype:RegisterFrameClicks(frame)
	if frame == nil or frame.RegisterForClicks == nil then
		return
	end

	if InCombatLockdown() or not self.initialized then
		self.registerClicksQueue = self.registerClicksQueue or {}

		table.insert(self.registerClicksQueue, frame)
		return
	end

	frame:RegisterForClicks(Addon.db.profile.options.onKeyDown and "AnyDown" or "AnyUp")
	frame:EnableMouseWheel(true)

	self:LogVerbose("Registered clicks for frame {frameName}", frame:GetName())
end

--- @private
function Prototype:ProcessQueue()
	if InCombatLockdown() then
		return
	end

	do
		local queue = self.registerClicksQueue
		self.registerClicksQueue = {}

		for _, frame in ipairs(queue) do
			Clicked2:RegisterFrameClicks(frame)
		end
	end
end

--- @private
function Prototype:PLAYER_ENTERING_WORLD()
	self.initialized = true

	self:ProcessQueue()
end

--- @private
function Prototype:PLAYER_REGEN_ENABLED()
	self:ProcessQueue()
end

--- @private
function Prototype:ADDON_LOADED()
	self:ProcessQueue()
end

--- @param frame Button
function Clicked2:RegisterFrameClicks(frame)
	Prototype:RegisterFrameClicks(frame)
end

--- @type ClickCastModule
Addon.ClickCast = Clicked2:NewModule("ClickCast", Prototype, "AceEvent-3.0")

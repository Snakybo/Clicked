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

local HAS_TYPE_RELEASE = Addon.EXPANSION >= Addon.Expansion.DF or Addon.EXPANSION == Addon.Expansion.TBC

--- @class AttributeHandlerModule : ClickedModule
local Prototype = {}

--- @protected
function Prototype:OnInitialize()
	--- @type table<Frame, table<string, string>>
	self.frameCache = {}

	self:LogDebug("Initialized attribute handler module")
end

--- @param frame Frame
--- @param attributes? table<string,string>
function Prototype:ApplyAttributes(frame, attributes)
	if frame == nil then
		return
	end

	Addon.Perf.StartSegment("AttributeHandler_ApplyAttributes")

	--- @type table<string, string>
	local pending = {}

	if attributes ~= nil then
		for key, value in pairs(attributes) do
			if not Addon.db.profile.options.onKeyDown and HAS_TYPE_RELEASE and frame == Addon.GlobalCast.frame then
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

	Addon.Perf.StopSegment("AttributeHandler_ApplyAttributes")
end

--- @param frame Frame
--- @param keybinds? Keybind[]
function Prototype:UpdateRestrictedEnvironment(frame, keybinds)
	Addon.Perf.StartSegment("AttributeHandler_UpdateRestrictedEnvironment")

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

	Addon.Perf.StopSegment("AttributeHandler_UpdateRestrictedEnvironment")
end

--- @type AttributeHandlerModule
Addon.AttributeHandler = Clicked2:NewModule("AttributeHandler", Prototype)

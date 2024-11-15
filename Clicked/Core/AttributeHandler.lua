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

local frameCache = {}

-- Local support functions

--- @param frame table
local function EnsureCache(frame)
	if frameCache[frame] ~= nil then
		return
	end

	frameCache[frame] = {
		pending = {},
		applied = {}
	}
end

--- @param register table<string,string>
--- @param prefix string
--- @param type string
--- @param suffix string
--- @param value string
local function CreateAttribute(register, prefix, type, suffix, value)
	prefix = prefix or ""
	suffix = suffix or ""

	if #prefix > 0 then
		prefix = prefix .. "-"
	end

	if #suffix > 0 and tonumber(suffix) == nil then
		suffix = "-" .. suffix
	end

	local key = prefix .. type .. suffix
	register[key] = value
end

--- @param data boolean
--- @return boolean
local function IsCombatStatusValid(data)
	if data == nil then
		return true
	end

	if data == true and Addon:IsPlayerInCombat() then
		return true
	end

	if data == false and not Addon:IsPlayerInCombat() then
		return true
	end

	return false
end

-- Private addon API

--- @param frame table
--- @param attributes table<string,string>
function Addon:SetPendingFrameAttributes(frame, attributes)
	if frame == nil then
		return
	end

	EnsureCache(frame)

	local requiresGsub = not Addon.db.profile.options.onKeyDown and frame ~= _G[Addon.MACRO_FRAME_HANDLER_NAME]
	local requiresMenu = frame:GetAttribute("*type2") == "menu"

	for key, value in pairs(attributes) do
		if requiresGsub then
			key = string.gsub(key, "typerelease", "type")
		end

		-- Some unit frames use "menu" instead of "togglemenu", an easy way to make sure we use the correct variant is to look at *type2 and check whether that
		-- is set to `menu`. If it is, we use "menu" instead.
		if value == "togglemenu" and requiresMenu then
			value = "menu"
		end

		frameCache[frame].pending[key] = value
	end
end

--- @param frame Frame
function Addon:ApplyAttributesToFrame(frame)
	if frame == nil or frameCache[frame] == nil then
		return
	end

	local applied = frameCache[frame].applied
	local pending = frameCache[frame].pending

	frameCache[frame].applied = pending
	frameCache[frame].pending = {}

	for key in pairs(applied) do
		if pending[key] == nil then
			frame:SetAttribute(key, nil)
		end
	end

	for key, value in pairs(pending) do
		if value ~= applied[key] then
			frame:SetAttribute(key, value)
		end
	end
end

--- @param register table<string,string>
--- @param command Command
--- @param prefix string
--- @param suffix string
function Addon:CreateCommandAttributes(register, command, prefix, suffix)
	if command.keybind == "" then
		return
	end

	if command.action == Addon.CommandType.TARGET then
		local value = IsCombatStatusValid(command.data) and "target" or ""
		CreateAttribute(register, prefix, "type", suffix, value)
	elseif command.action == Addon.CommandType.MENU then
		local value = IsCombatStatusValid(command.data) and "togglemenu" or ""
		CreateAttribute(register, prefix, "type", suffix, value)
	elseif command.action == Addon.CommandType.MACRO then
		local attributeType = "type"

		if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF and not Addon.db.profile.options.onKeyDown then
			attributeType = "typerelease"
		end

		CreateAttribute(register, prefix, attributeType, suffix, "macro")
		CreateAttribute(register, prefix, "macrotext", suffix, command.data)
	else
		error("Unhandled action type: " .. command.action)
	end
end

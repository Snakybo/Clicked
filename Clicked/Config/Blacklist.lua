-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
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

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--- @class ClickedInternal
local _, Addon = ...

local UNIT_FRAME_ADDON_MAPPING = {
	["ElvUI"] = {
		name = Addon:GetColorizedString(Addon.L["ElvUI"], "ff1784d1"),
		"ElvUF_*"
	},
	["Grid2"] = {
		name = Addon.L["Grid2"],
		"Grid2*"
	},
	["Vuhdo"] = {
		name = Addon:GetColorizedString(Addon.L["VuhDo"], "ffffe566"),
		"Vd%dH%d*"
	},
	["Gladius"] = {
		name = "Gladius",
		"GladiusButtonarena%d"
	},
	["GladiusEx"] = {
		name = "GladiusEx",
		"GladiusExSecureButtonarena%d",
		"GladiusExSecureButtonparty%d"
	},
	["Blizzard"] = {
		name = "Blizzard",
		"Boss%dTargetFrame",
		"CompactRaidFrame%d",
		"CompactPartyFrameMember%d",
		"FocusFrame",
		"FocusFrameToT",
		"PetFrame",
		"PlayerFrame",
		"TargetFrame",
		"TargetFrameToT"
	}
}

local config
local panel
local values = {}

-- Local support functions

--- @param name string
--- @return string
local function GetUnitFrameSource(name)
	local nameSource = nil

	for source, frames in pairs(UNIT_FRAME_ADDON_MAPPING) do
		for _, frame in ipairs(frames) do
			if string.match(name, frame) then
				return UNIT_FRAME_ADDON_MAPPING[source].name
			end
		end
	end

	if nameSource == nil then
		return Addon.L["Other"]
	end
end

--- @param name string
--- @param enabled boolean
local function SetDropdownItem(name, enabled)
	local source = GetUnitFrameSource(name)
	local index = 0

	values[source] = values[source] or {}

	for i, item in ipairs(values[source]) do
		if item == name then
			index = i
			break
		end
	end

	if enabled and index == 0 then
		table.insert(values[source], name)
	elseif not enabled and index > 0 then
		table.remove(values[source], index)
	end
end

--- @param name string
--- @param enabled boolean
local function SetSelectedItem(name, enabled)
	local args = config.args

	if enabled then
		args[name] = {
			name = function()
				local source = GetUnitFrameSource(name)
				local numChildren = #Addon:GetBlacklistGroupItems(name) - 1
				local result = source .. ": " .. name

				if numChildren > 0 then
					result = result .. " |cff808080(plus " .. numChildren .. " children)|r"
				end

				return result
			end,
			desc = function()
				local result = {}

				for _, frame in ipairs(Addon:GetBlacklistGroupItems(name)) do
					table.insert(result, "- " .. frame)
				end

				table.sort(result)

				return table.concat(result, "\n")
			end,
			type = "toggle",
			width = "full",
			order = 3,
			set = function(_, value)
				if not value then
					Addon.db.profile.blacklist[name] = nil
					args[name] = nil

					SetDropdownItem(name, true)

					Addon:UpdateClickCastHeaderBlacklist()
					Clicked:ReloadActiveBindings()
				end
			end,
			get = function()
				return Addon.db.profile.blacklist[name] or false
			end
		}
	else
		args[name] = nil
	end
end

-- Private addon API

--- Set the name of the blacklist group the frame belongs to.
---
--- @param frame Frame
--- @return string?
function Addon:SetBlacklistGroup(frame, group)
	frame:SetAttribute("clicked-blacklist-group", group)
end

--- Get the name of the blacklist group the frame belongs to.
---
--- @param frame Frame
--- @return string?
function Addon:GetBlacklistGroup(frame)
	local group = frame:GetAttribute("clicked-blacklist-group")

	if group ~= nil then
		return group
	end

	if frame.GetName then
		return frame:GetName()
	end

	return nil
end

--- Get the names of all frames within a blacklist group
--- @param group any
--- @return string[]
function Addon:GetBlacklistGroupItems(group)
	local result = {}

	for _, frame in Clicked:IterateClickCastFrames() do
		if Addon:GetBlacklistGroup(frame) == group then
			table.insert(result, frame:GetName())
		end
	end

	return result
end

function Addon:BlacklistOptions_Initialize()
	config = {
		type = "group",
		name = Addon.L["Frame Blacklist"],
		args = {
			help = {
				type = "description",
				name = Addon.L["If you want to exclude certain unit frames from click-cast functionality, you can tick the boxes next to each item in order to blacklist them. This will take effect immediately."],
				order = 0
			},
			selector = {
				type = "select",
				name = Addon.L["Add a unit frame"],
				width = "full",
				order = 1,
				values = function()
					local result = {}

					for source, frames in pairs(values) do
						result[source] = "s|" .. source

						for _, frame in ipairs(frames) do
							local numChildren = #Addon:GetBlacklistGroupItems(frame) - 1

							if numChildren > 0 then
								result[frame] = frame .. " |cff808080(plus " .. numChildren .. " children)|r"
							else
								result[frame] = frame
							end
						end
					end

					return result
				end,
				sorting = function()
					local result = {}
					local current = 1

					table.sort(values)

					for source, frames in pairs(values) do
						result[current] = source

						table.sort(frames)

						for i, frame in ipairs(frames) do
							result[current + i] = frame
						end

						current = current + #frames
					end

					return result
				end,
				itemControl = "Clicked-Blacklist-Dropdown-Item",
				set = function(_, val)
					if val ~= "_NIL_" then
						Addon.db.profile.blacklist[val] = true

						SetSelectedItem(val, true)
						SetDropdownItem(val, false)

						Addon:UpdateClickCastHeaderBlacklist()
						Clicked:ReloadActiveBindings()
					end
				end,
				get = function()
					return ""
				end
			},
			selected = {
				type = "header",
				name = Addon.L["Selected"],
				order = 2
			}
		}
	}

	for _, frame in Clicked:IterateClickCastFrames() do
		Addon:BlacklistOptions_RegisterFrame(frame)
	end

	AceConfig:RegisterOptionsTable("Clicked/Blacklist", config)
	panel = AceConfigDialog:AddToBlizOptions("Clicked/Blacklist", Addon.L["Frame Blacklist"], "Clicked")
end

function Addon:BlacklistOptions_Open()
	InterfaceOptionsFrame_OpenToCategory(panel)
	InterfaceOptionsFrame_OpenToCategory(panel)
end

function Addon:BlacklistOptions_Refresh()
	for _, frame in Clicked:IterateClickCastFrames() do
		Addon:BlacklistOptions_RegisterFrame(frame)
	end
end

--- @param frame Frame
function Addon:BlacklistOptions_RegisterFrame(frame)
	local group = Addon:GetBlacklistGroup(frame)

	if group ~= nil then
		SetSelectedItem(group, Addon.db.profile.blacklist[group])
		SetDropdownItem(group, not Addon.db.profile.blacklist[group])
	end
end

--- @param frame table
function Addon:BlacklistOptions_UnregisterFrame(frame)
	local group = Addon:GetBlacklistGroup(frame)

	if group ~= nil then
		SetSelectedItem(group, false)
		SetDropdownItem(group, false)
	end
end

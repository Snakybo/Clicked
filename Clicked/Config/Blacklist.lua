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

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--- @class ClickedInternal
local Addon = select(2, ...)

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
		"CompactArenaFrameMember%d",
		"CompactArenaFramePet%d",
		"CompactPartyFrameMember%d",
		"CompactPartyFramePet%d",
		"FocusFrame",
		"FocusFrameToT",
		"PetFrame",
		"PlayerFrame",
		"PartyMemberFrame%d",
		"TargetFrame",
		"TargetFrameToT"
	}
}

local config
local values = {}

-- Local support functions

--- @class BlacklistOptions
local BlacklistOptions = {}

function BlacklistOptions:Initialize()
	config = self:CreateOptionsTable()

	AceConfig:RegisterOptionsTable("Clicked/Blacklist", config)
	AceConfigDialog:AddToBlizOptions("Clicked/Blacklist", Addon.L["Frame Blacklist"], "Clicked")

	self:Refresh()
end

--- Set the name of the blacklist group the frame belongs to.
---
--- @param frame Frame
--- @return string?
function BlacklistOptions:SetBlacklistGroup(frame, group)
	frame:SetAttribute("clicked-blacklist-group", group)
end

--- Get the name of the blacklist group the frame belongs to.
---
--- @param frame Frame
--- @return string?
function BlacklistOptions:GetBlacklistGroup(frame)
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
function BlacklistOptions:GetBlacklistGroupItems(group)
	local result = {}

	for _, frame in Clicked:IterateClickCastFrames() do
		if self:GetBlacklistGroup(frame) == group then
			table.insert(result, frame:GetName())
		end
	end

	return result
end

function BlacklistOptions:Refresh()
	for _, frame in Clicked:IterateClickCastFrames() do
		self:RegisterFrame(frame)
	end

	for name, state in pairs(Addon.db.profile.blacklist) do
		self:SetSelectedItem(name, state)
		self:SetDropdownItem(name, not state)
	end
end

--- @param frame Frame
function BlacklistOptions:RegisterFrame(frame)
	local group = self:GetBlacklistGroup(frame)

	if group ~= nil then
		self:SetSelectedItem(group, Addon.db.profile.blacklist[group])
		self:SetDropdownItem(group, not Addon.db.profile.blacklist[group])
	end
end

--- @private
--- @return AceConfig.OptionsTable
function BlacklistOptions:CreateOptionsTable()
	return {
		type = "group",
		name = Addon.L["Frame Blacklist"],
		args = {
			help1 = {
				type = "description",
				name = Addon.L["The frame blacklist can be used if you want to exclude specific unit frames from click-cast functionality."],
				order = 0
			},
			spacer1 = {
				type = "description",
				name = "",
				order = 1
			},
			help2 = {
				type = "description",
				name = Addon.L["To add a unit frame to the blacklist, simply select it from the dropdown below. To remove a unit frame from the blacklist, uncheck the box next to the item."],
				order = 2,
			},
			spacer2 = {
				type = "description",
				name = "",
				order = 3
			},
			help3 = {
				type = "description",
				name = Addon.L["This will take effect immediately, however may require a UI reload if a unit frame is pass-through by default."],
				order = 4,
			},
			selector = {
				type = "select",
				name = Addon.L["Add a unit frame"],
				width = "full",
				order = 10,
				values = function()
					local result = {}

					for source, frames in pairs(values) do
						result[source] = "s|" .. source

						for _, frame in ipairs(frames) do
							local numChildren = #self:GetBlacklistGroupItems(frame) - 1

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

						current = current + #frames + 1
					end

					return result
				end,
				itemControl = "Clicked-Blacklist-Dropdown-Item",
				set = function(_, val)
					if val ~= "_NIL_" then
						Addon.db.profile.blacklist[val] = true

						self:SetSelectedItem(val, true)
						self:SetDropdownItem(val, false)

						Clicked:UnregisterClickCastFrame(val)
						Clicked:ProcessActiveBindings()
					end
				end,
				get = function()
					return ""
				end
			},
			selected = {
				type = "header",
				name = Addon.L["Selected"],
				order = 20
			}
		}
	}
end

--- @private
--- @param name string
--- @return string
function BlacklistOptions:GetUnitFrameSource(name)
	for source, frames in pairs(UNIT_FRAME_ADDON_MAPPING) do
		for _, frame in ipairs(frames) do
			if string.match(name, frame) then
				return UNIT_FRAME_ADDON_MAPPING[source].name
			end
		end
	end

	return Addon.L["Other"]
end

--- @private
--- @param name string
--- @param enabled boolean
function BlacklistOptions:SetDropdownItem(name, enabled)
	local source = self:GetUnitFrameSource(name)
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

--- @private
--- @param name string
--- @param enabled boolean
function BlacklistOptions:SetSelectedItem(name, enabled)
	local args = config.args

	if enabled then
		args[name] = {
			name = function()
				local source = self:GetUnitFrameSource(name)
				local numChildren = #self:GetBlacklistGroupItems(name) - 1
				local result = source .. ": " .. name

				if numChildren > 0 then
					result = result .. " |cff808080(plus " .. numChildren .. " children)|r"
				end

				return result
			end,
			desc = function()
				local result = {}

				for _, frame in ipairs(self:GetBlacklistGroupItems(name)) do
					table.insert(result, "- " .. frame)
				end

				table.sort(result)

				return table.concat(result, "\n")
			end,
			type = "toggle",
			width = "full",
			order = 30,
			set = function(_, value)
				if not value then
					Addon.db.profile.blacklist[name] = nil
					args[name] = nil

					self:SetDropdownItem(name, true)

					Clicked:RegisterClickCastFrame(name)
					Clicked:ProcessActiveBindings()
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

Addon.BlacklistOptions = BlacklistOptions

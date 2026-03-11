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

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--- @class Addon
local Addon = select(2, ...)

local GROUP_ATTRIBUTE_KEY = "clicked-blacklist-group"

--- @type { [string]: { name: string, patterns: string[] } }
local UNIT_FRAME_ADDON_MAPPING = {
	["ElvUI"] = {
		name = Addon:GetColorizedString(Addon.L["ElvUI"], "ff1784d1"),
		patterns = {
			"ElvUF_*"
		}
	},
	["Grid2"] = {
		name = Addon.L["Grid2"],
		patterns = {
			"Grid2*"
		}
	},
	["Vuhdo"] = {
		name = Addon:GetColorizedString(Addon.L["VuhDo"], "ffffe566"),
		patterns = {
			"Vd%dH%d*"
		}
	},
	["Gladius"] = {
		name = "Gladius",
		patterns = {
			"GladiusButtonarena%d"
		}
	},
	["GladiusEx"] = {
		name = "GladiusEx",
		patterns = {
			"GladiusExSecureButtonarena%d",
			"GladiusExSecureButtonparty%d"
		}
	},
	["Blizzard"] = {
		name = "Blizzard",
		patterns = {
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
}

--- @class BlacklistModule : ClickedModule, AceEvent-3.0
local Prototype = {}

--- @protected
function Prototype:OnInitialize()
	--- @type AceConfig.OptionsTable
	self.config = {
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
					--- @type table<string, string>
					local result = {}

					for source, frames in pairs(self.values) do
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
					--- @type string[]
					local result = {}

					local sources = {}
					for source in pairs(self.values) do
						table.insert(sources, source)
					end

					table.sort(sources)

					for _, source in ipairs(sources) do
						table.insert(result, source)

						local children = CopyTable(self.values[source])
						table.sort(children)

						for _, frame in ipairs(children) do
							table.insert(result, frame)
						end
					end

					return result
				end,
				itemControl = "Clicked-Blacklist-Dropdown-Item",
				set = function(_, val)
					if val ~= "_NIL_" then
						Addon.db.profile.blacklist[val] = true

						self:SetSelectedItem(val, true)
						self:SetDropdownItem(val, false)

						Addon.ClickCast:UnregisterFrame(val)
						Clicked2:ProcessActiveBindings()
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

	--- @type table<string, string[]>
	self.values = {}

	self:RegisterMessage("CLICKED_DATABASE_RELOADED", self.CLICKED_DATABASE_RELOADED, self)
	self:RegisterMessage("CLICKED_CLICKCAST_FRAME_REGISTERED", self.CLICKED_CLICKCAST_FRAME_REGISTERED, self)

	AceConfig:RegisterOptionsTable("Clicked2/Blacklist", self.config)
	AceConfigDialog:AddToBlizOptions("Clicked2/Blacklist", Addon.L["Frame Blacklist"], "Clicked2")

	self:Refresh()

	self:LogDebug("Initialized blacklist module")
end

--- @param frame Frame
--- @return boolean
function Prototype:IsFrameBlacklisted(frame)
	if frame == nil then
		return false
	end

	local blacklist = Addon.db.profile.blacklist
	local name = frame:GetName()

	return blacklist[name]
end

--- @private
--- @param group string
--- @return string[]
function Prototype:GetBlacklistGroupItems(group)
	--- @type string[]
	local result = {}

	for _, frame in Addon.ClickCast:IterateFrames() do
		if frame:GetName() ~= group and Clicked2:GetBlacklistGroup(frame) == group then
			table.insert(result, frame:GetName())
		end
	end

	return result
end

--- @private
function Prototype:Refresh()
	for _, frame in Addon.ClickCast:IterateFrames() do
		self:RegisterFrame(frame)
	end

	for name, state in pairs(Addon.db.profile.blacklist) do
		self:SetSelectedItem(name, state)
		self:SetDropdownItem(name, not state)
	end
end

--- @private
--- @param frame Frame
function Prototype:RegisterFrame(frame)
	local group = Clicked2:GetBlacklistGroup(frame)

	if group ~= nil then
		self:SetSelectedItem(group, Addon.db.profile.blacklist[group])
		self:SetDropdownItem(group, not Addon.db.profile.blacklist[group])
	end
end

--- @private
--- @param name string
--- @return string
function Prototype:GetUnitFrameSource(name)
	for source, frames in pairs(UNIT_FRAME_ADDON_MAPPING) do
		for _, frame in ipairs(frames.patterns) do
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
function Prototype:SetDropdownItem(name, enabled)
	local source = self:GetUnitFrameSource(name)
	local index = 0

	self.values[source] = self.values[source] or {}

	for i, item in ipairs(self.values[source]) do
		if item == name then
			index = i
			break
		end
	end

	if enabled and index == 0 then
		table.insert(self.values[source], name)
	elseif not enabled and index > 0 then
		table.remove(self.values[source], index)
	end
end

--- @private
--- @param name string
--- @param enabled boolean
function Prototype:SetSelectedItem(name, enabled)
	local args = self.config.args

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

					Addon.ClickCast:RegisterFrame(name)
					Clicked2:ProcessActiveBindings()
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

--- @private
function Prototype:CLICKED_DATABASE_RELOADED()
	self:Refresh()
end

--- @private
function Prototype:CLICKED_CLICKCAST_FRAME_REGISTERED(_, frame)
	self:RegisterFrame(frame)
end

--- @type BlacklistModule
Addon.Blacklist = Clicked2:NewModule("Blacklist", Prototype, "AceEvent-3.0")

--- @param frame Frame
--- @param group? string
function Clicked2:SetBlacklistGroup(frame, group)
	frame:SetAttribute(GROUP_ATTRIBUTE_KEY, group)
end

--- @param frame Frame
--- @return string?
function Clicked2:GetBlacklistGroup(frame)
	local group = frame:GetAttribute(GROUP_ATTRIBUTE_KEY)
	if group ~= nil then
		return group
	end

	if frame.GetName then
		return frame:GetName()
	end

	return nil
end

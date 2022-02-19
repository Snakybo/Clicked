local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local UNIT_FRAME_ADDON_MAPPING = {
	["ElvUI"] = {
		name = Addon:GetColorizedString(L["ElvUI"], "ff1784d1"),
		"ElvUF_*"
	},
	["Grid2"] = {
		name = L["Grid2"],
		"Grid2*"
	},
	["Vuhdo"] = {
		name = Addon:GetColorizedString(L["VuhDo"], "ffffe566"),
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
		"CompactRaidFrame%dBuff%d",
		"CompactRaidFrame%dDebuff%d",
		"CompactRaidFrame%dDispellDebuff%d",
		"FocusFrame",
		"FocusFrameToT",
		"PartyMemberFrame%d",
		"PartyMemberFrame%dPetFrame",
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
		return L["Other"]
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
			name = GetUnitFrameSource(name) .. ":" .. name,
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

function Addon:BlacklistOptions_Initialize()
	config = {
		type = "group",
		name = L["Frame Blacklist"],
		args = {
			help = {
				type = "description",
				name = L["If you want to exclude certain unit frames from click-cast functionality, you can tick the boxes next to each item in order to blacklist them. This will take effect immediately."],
				order = 0
			},
			selector = {
				type = "select",
				name = L["Add a unit frame"],
				width = "full",
				order = 1,
				values = function()
					local result = {}

					for source, frames in pairs(values) do
						result[source] = "s|" .. source

						for _, frame in ipairs(frames) do
							result[frame] = frame
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
				name = L["Selected"],
				order = 2
			}
		}
	}

	for _, frame in Clicked:IterateClickCastFrames() do
		Addon:BlacklistOptions_RegisterFrame(frame)
	end

	AceConfig:RegisterOptionsTable("Clicked/Blacklist", config)
	panel = AceConfigDialog:AddToBlizOptions("Clicked/Blacklist", L["Frame Blacklist"], "Clicked")
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

--- @param frame table
function Addon:BlacklistOptions_RegisterFrame(frame)
	local name = frame.GetName and frame:GetName()

	if name ~= nil then
		SetSelectedItem(name, Addon.db.profile.blacklist[name])
		SetDropdownItem(name, not Addon.db.profile.blacklist[name])
	end
end

--- @param frame table
function Addon:BlacklistOptions_UnregisterFrame(frame)
	local name = frame.GetName and frame:GetName()

	if name ~= nil then
		SetSelectedItem(name, false)
		SetDropdownItem(name, false)
	end
end

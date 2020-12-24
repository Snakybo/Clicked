local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local UNIT_FRAME_ADDON_MAPPING = {
	["ElvUI"] = {
		name = Clicked:GetColorizedString(L["ElvUI"], "ff1784d1"),
		"ElvUF_*"
	},
	["Grid2"] = {
		name = L["Grid2"],
		"Grid2*"
	},
	["Vuhdo"] = {
		name = Clicked:GetColorizedString(L["VuhDo"], "ffffe566"),
		"Vd%dH%d*"
	},
	["Gladius"] = {
		name = "Gladius",
		"GladiusButtonarena%d"
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
		return OTHER
	end
end

local module = {
	["Initialize"] = function(self)
		self.values = {}

		self.config = {
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
					values = function(info)
						local result = {}

						for source, frames in pairs(self.values) do
							result[source] = "s|" .. source

							for _, frame in ipairs(frames) do
								result[frame] = frame
							end
						end

						return result
					end,
					sorting = function(info)
						local result = {}
						local current = 1

						table.sort(self.values)

						for source, frames in pairs(self.values) do
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
					set = function(info, val)
						if val ~= "_NIL_" then
							Clicked.db.profile.blacklist[val] = true

							self:SetSelectedItem(val, true)
							self:SetDropdownItem(val, false)

							Clicked:UpdateClickCastHeaderBlacklist()
							Clicked:ReloadActiveBindings()
						end
					end,
					get = function(info)
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
			self:OnFrameRegistered(frame)
		end

		AceConfig:RegisterOptionsTable("Clicked/Blacklist", self.config)
		self.interfaceOptionsTab = AceConfigDialog:AddToBlizOptions("Clicked/Blacklist", L["Frame Blacklist"], "Clicked")
	end,

	["Register"] = function(self)
		Clicked:RegisterMessage(Clicked.EVENT_CLICK_CAST_FRAME_REGISTERED, function(event, frame)
			self:OnFrameRegistered(frame)
		end)

		Clicked:RegisterMessage(Clicked.EVENT_CLICK_CAST_FRAME_UNREGISTERED, function(event, frame)
			self:OnFrameUnregistered(frame)
		end)
	end,

	["Unregister"] = function(self)
		Clicked:UnregisterMessage(Clicked.EVENT_CLICK_CAST_FRAME_REGISTERED)
		Clicked:UnregisterMessage(Clicked.EVENT_CLICK_CAST_FRAME_UNREGISTERED)
	end,

	["OnChatCommandReceived"] = function(self, args)
		for _, arg in ipairs(args) do
			if arg == "blacklist" then
				InterfaceOptionsFrame_OpenToCategory(self.interfaceOptionsTab)
				InterfaceOptionsFrame_OpenToCategory(self.interfaceOptionsTab)
				break
			end
		end
	end,

	["SetDropdownItem"] = function(self, name, enabled)
		local source = GetUnitFrameSource(name)
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
	end,

	["SetSelectedItem"] = function(self, name, enabled)
		local args = self.config.args

		if enabled then
			args[name] = {
				name = GetUnitFrameSource(name) .. ":" .. name,
				type = "toggle",
				width = "full",
				order = 3,
				set = function(info, value)
					if not value then
						Clicked.db.profile.blacklist[name] = nil
						args[name] = nil

						self:SetDropdownItem(name, true)

						Clicked:UpdateClickCastHeaderBlacklist()
						Clicked:ReloadActiveBindings()
					end
				end,
				get = function(info)
					return Clicked.db.profile.blacklist[name] or false
				end
			}
		else
			args[name] = nil
		end
	end,

	["OnFrameRegistered"] = function(self, frame)
		local name = frame:GetName()

		self:SetSelectedItem(name, Clicked.db.profile.blacklist[name])
		self:SetDropdownItem(name, not Clicked.db.profile.blacklist[name])
	end,

	["OnFrameUnregistered"] = function(self, frame)
		local name = frame:GetName()

		self:SetSelectedItem(name, false)
		self:SetDropdownItem(name, false)
	end
}

function Clicked:ReloadBlacklist()
	for _, frame in Clicked:IterateClickCastFrames() do
		module:OnFrameRegistered(frame)
	end
end

Clicked:RegisterModule("BlacklistConfig", module)

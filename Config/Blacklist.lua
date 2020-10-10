local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local UNIT_FRAME_ADDON_MAPPING = {
	["INTERFACE_UI_BLACKLIST_SOURCE_ELVUI"] = {
		"ElvUF_*"
	},
	["INTERFACE_UI_BLACKLIST_SOURCE_GRID2"] = {
		"Grid2*"
	},
	["INTERFACE_UI_BLACKLIST_SOURCE_VUHDO"] = {
		"Vd%dH%d*"
	},
	["INTERFACE_UI_BLACKLIST_SOURCE_GLADIUS"] = {
		"GladiusButtonarena%d"
	},
	["INTERFACE_UI_BLACKLIST_SOURCE_BLIZZARD"] = {
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
				return L[source]
			end
		end
	end

	if nameSource == nil then
		return L["INTERFACE_UI_BLACKLIST_SOURCE_UNKNOWN"]
	end
end

local module = {
	["Initialize"] = function(self)
		self.values = {}

		self.config = {
			type = "group",
			name = L["INTERFACE_UI_TITLE_BLACKLIST"],
			args = {
				help = {
					type = "description",
					name = L["INTERFACE_UI_BLACKLIST_HELP"],
					order = 0
				},
				selector = {
					type = "select",
					name = L["INTERFACE_UI_BLACKLIST_ADD"],
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
							self.blacklist[val] = true

							self:SetSelectedItem(val, true)
							self:SetDropdownItem(val, false)

							Clicked:ReloadActiveBindings()
						end
					end,
					get = function(info)
						return ""
					end
				},
				selected = {
					type = "header",
					name = L["INTERFACE_UI_BLACKLIST_HEADER_SELECTED"],
					order = 2
				}
			}
		}

		self.blacklist = Clicked.db.profile.blacklist

		for _, frame in Clicked:IterateClickCastFrames() do
			self:OnFrameRegistered(frame)
		end

		AceConfig:RegisterOptionsTable("Clicked/Blacklist", self.config)
		self.interfaceOptionsTab = AceConfigDialog:AddToBlizOptions("Clicked/Blacklist", L["INTERFACE_UI_TITLE_BLACKLIST"], "Clicked")
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
				name = string.format(L["INTERFACE_UI_BLACKLIST_FRAME_NAME"], GetUnitFrameSource(name), name),
				type = "toggle",
				width = "full",
				order = 3,
				set = function(info, value)
					if not value then
						self.blacklist[name] = nil
						args[name] = nil

						self:SetDropdownItem(name, true)
						Clicked:ReloadActiveBindings()
					end
				end,
				get = function(info)
					return self.blacklist[name] or false
				end
			}
		else
			args[name] = nil
		end
	end,

	["OnFrameRegistered"] = function(self, frame)
		local name = frame:GetName()

		self:SetSelectedItem(name, self.blacklist[name])
		self:SetDropdownItem(name, not self.blacklist[name])
	end,

	["OnFrameUnregistered"] = function(self, frame)
		local name = frame:GetName()

		self:SetSelectedItem(name, false)
		self:SetDropdownItem(name, false)
	end
}

Clicked:RegisterModule("BlacklistConfig", module)

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local module = {
	["Initialize"] = function(self)
		self.config = {
			type = "group",
			name = L["OPT_BLACKLIST_TITLE"],
			args = {
				help = {
					type = "description",
					name = L["OPT_BLACKLIST_HELP"],
					order = 0
				}
			}
		}

		self.blacklist = Clicked.db.profile.blacklist

		for _, frame in Clicked:IterateClickCastFrames() do
			self:OnFrameRegistered(frame)
		end

		AceConfig:RegisterOptionsTable("Clicked/Blacklist", self.config)
		self.interfaceOptionsTab = AceConfigDialog:AddToBlizOptions("Clicked/Blacklist", L["OPT_BLACKLIST_TITLE"], "Clicked")
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

	["OnFrameRegistered"] = function(self, frame)
		local args = self.config.args
		local name = frame:GetName()

		args[name] = {
			name = name,
			type = "toggle",
			width = "double",
			hidden = false,
			set = function(info, value)
				if value then
					self.blacklist[name] = true
				else
					self.blacklist[name] = nil
				end

				Clicked:ReloadActiveBindings()
			end,
			get = function(info)
				return self.blacklist[name] or false
			end
		}
	end,

	["OnFrameUnregistered"] = function(self, frame)
		local args = self.config.args
		local name = frame:GetName()

		args[name].hidden = true
	end
}

Clicked:RegisterModule("BlacklistConfig", module)

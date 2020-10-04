local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local module = {
	["Initialize"] = function(self)
		local config = {
			type = "group",
			name = L["ADDON_NAME"],
			args = {
				minimapIcon = {
					name = L["INTERFACE_UI_GENERAL_MINIMAP_ICON_NAME"],
					desc = L["INTERFACE_UI_GENERAL_MINIMAP_ICON_DESCRIPTION"],
					type = "toggle",
					order = 1,
					width = "full",
					set = function(info, val)
						Clicked.db.profile.minimap.hide = not val

						if val then
							LibDBIcon:Show("Clicked")
						else
							LibDBIcon:Hide("Clicked")
						end
					end,
					get = function(info)
						return not Clicked.db.profile.minimap.hide
					end
				},
				onKeyDown = {
					name = L["INTERFACE_UI_GENERAL_CAST_ON_KEY_DOWN_NAME"],
					desc = L["INTERFACE_UI_GENERAL_CAST_ON_KEY_DOWN_DESCRIPTION"],
					type = "toggle",
					order = 2,
					width = "full",
					set = function(info, val)
						Clicked.db.profile.options.onKeyDown = val

						for _, frame in Clicked:IterateClickCastFrames() do
							Clicked:RegisterFrameClicks(frame)
						end

						for _, frame in Clicked:IterateMacroHandlerFrames() do
							Clicked:RegisterFrameClicks(frame)
						end

						Clicked:ShowInformationPopup(L["INTERFACE_UI_GENERAL_POPUP_CAST_ON_KEY_DOWN"])
					end,
					get = function(info)
						return Clicked.db.profile.options.onKeyDown
					end
				}
			}
		}

		AceConfig:RegisterOptionsTable("Clicked", config)
		self.options = AceConfigDialog:AddToBlizOptions("Clicked", L["INTERFACE_UI_TITLE_GENERAL"])

		AceConfig:RegisterOptionsTable("Clicked/Profile", AceDBOptions:GetOptionsTable(Clicked.db))
		self.profile = AceConfigDialog:AddToBlizOptions("Clicked/Profile", L["INTERFACE_UI_TITLE_PROFILES"], "Clicked")
	end,

	["OnChatCommandReceived"] = function(self, args)
		for _, arg in ipairs(args) do
			if arg == "profile" then
				InterfaceOptionsFrame_OpenToCategory(self.profile)
				InterfaceOptionsFrame_OpenToCategory(self.profile)
				break
			end
		end
	end,
}

Clicked:RegisterModule("AddonConfig", module)

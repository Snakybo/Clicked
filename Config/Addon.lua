local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local module = {
	["Initialize"] = function(self)
		local config = {
			type = "group",
			name = L["NAME"],
			args = {
				minimapIcon = {
					name = L["OPT_GENERAL_MINIMAP_NAME"],
					desc = L["OPT_GENERAL_MINIMAP_DESC"],
					type = "toggle",
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
				}
			}
		}
	
		AceConfig:RegisterOptionsTable("Clicked", config)
		self.options = AceConfigDialog:AddToBlizOptions("Clicked", L["NAME"])
	
		AceConfig:RegisterOptionsTable("Clicked/Profile", AceDBOptions:GetOptionsTable(Clicked.db))
		self.profile = AceConfigDialog:AddToBlizOptions("Clicked/Profile", L["OPT_PROFILES_NAME"], "Clicked")
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

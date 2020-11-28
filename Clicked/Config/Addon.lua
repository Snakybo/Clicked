local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local module = {
	["Initialize"] = function(self)
		local config = {
			type = "group",
			name = L["Clicked"],
			args = {
				minimapIcon = {
					name = L["Enable minimap icon"],
					desc = L["Enable or disable the minimap icon."],
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
					name = L["Cast on key down rather than key up"],
					desc = L["This option will make bindings trigger on the 'down' portion of a button press rather than the 'up' portion."],
					type = "toggle",
					order = 2,
					width = "full",
					set = function(info, val)
						Clicked.db.profile.options.onKeyDown = val

						for _, frame in Clicked:IterateClickCastFrames() do
							Clicked:RegisterFrameClicks(frame)
						end

						Clicked:RegisterFrameClicks(_G[Clicked.MACRO_FRAME_HANDLER_NAME])
						Clicked:ShowInformationPopup(L["If you are using custom unit frames you may have to adjust a setting within the unit frame configuration panel to enable support for this, and potentially even a UI reload."])
					end,
					get = function(info)
						return Clicked.db.profile.options.onKeyDown
					end
				}
			}
		}

		AceConfig:RegisterOptionsTable("Clicked", config)
		self.options = AceConfigDialog:AddToBlizOptions("Clicked", L["Clicked"])

		AceConfig:RegisterOptionsTable("Clicked/Profile", AceDBOptions:GetOptionsTable(Clicked.db))
		self.profile = AceConfigDialog:AddToBlizOptions("Clicked/Profile", L["Profiles"], "Clicked")
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

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")
local LibDBIcon = LibStub("LibDBIcon-1.0")

function Clicked:RegisterAddonConfig()
	local config = {
		type = "group",
		name = "Clicked",
		args = {
			minimapIcon = {
				name = "Enable Minimap Icon",
				desc = "Enable or disable the minimap icon",
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
	local profile = AceDBOptions:GetOptionsTable(self.db)

	AceConfig:RegisterOptionsTable("Clicked_AddonOptions", config)
	AceConfigDialog:AddToBlizOptions("Clicked_AddonOptions", "Clicked")

	AceConfig:RegisterOptionsTable("Clicked_AddonOptions_Profile", profile)
	AceConfigDialog:AddToBlizOptions("Clicked_AddonOptions_Profile", "Profiles", config)
end

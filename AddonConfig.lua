local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

function Clicked:RegisterAddonConfig()
    local profile = AceDBOptions:GetOptionsTable(self.db)

    AceConfig:RegisterOptionsTable("Clicked_AddonOptions", profile)
    AceConfigDialog:AddToBlizOptions("Clicked_AddonOptions", "Clicked")
end

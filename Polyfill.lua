--- @meta

--- @class EngravingData
--- @field skillLineAbilityID number
--- @field itemEnchantmentID number
--- @field name string
--- @field iconTexture number
--- @field equipmentSlot Enum.InventoryType
--- @field level number
--- @field learnedAbilitySpellIDs number[]

--- @param category number
--- @param ownedOnly boolean
--- @return EngravingData[] engravingInfo
function C_Engraving.GetRunesForCategory(category, ownedOnly)
end

--- @class AceConfig.OptionsTable
--- @field public plugins? table<string, table<string, AceConfig.OptionsTable>>

--- @param text string
--- @return ...string?
function LinkUtil.ExtractLink(text)
end

--- @class AceGUI-3.0
local AceGUI = {}

--- @param type string
--- @return number?
function AceGUI:GetWidgetVersion(type)
end

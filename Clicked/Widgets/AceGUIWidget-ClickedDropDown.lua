--[[-----------------------------------------------------------------------------
Clicked DropDown Widget
Adds support for setting of icons and texts in one command using the following
format: |icon:PATH\\TO\\ICONS|text:Some Text
-------------------------------------------------------------------------------]]
--- @type ClickedInternal
local _, Addon = ...

local Type, Version = "ClickedDropDown", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- exported
local function SetText(self, text)
	local t = Addon:GetDataFromString(text, "text")

	if text ~= nil and #text > 0 and t == nil then
		t = text
	end

	self.text:SetText(t)
end

--[[ Constructor ]]--

local function Constructor()
	local dropdown = AceGUI:Create("Dropdown")
	dropdown.type = Type

	dropdown.SetText = SetText

	return dropdown
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

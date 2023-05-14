--[[-----------------------------------------------------------------------------
Clicked DropDown Widget
Adds support for setting of icons and texts in one command using the following
format: |icon:PATH\\TO\\ICONS|text:Some Text
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedDropdown"

--- @class ClickedDropdown : AceGUIDropdown
--- @field public pullout any

local Type, Version = "ClickedDropdown", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

--- @class ClickedInternal
local Addon = select(2, ...)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--- @class ClickedDropdown
local Methods = {}

function Methods:SetText(text)
	local t = Addon:GetDataFromString(text, "text")

	if text ~= nil and #text > 0 and t == nil then
		t = text
	end

	self.text:SetText(t)
end

--[[ Constructor ]]--

local function Constructor()
	--- @class ClickedDropdown
	local widget = AceGUI:Create("Dropdown")
	widget.type = Type

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

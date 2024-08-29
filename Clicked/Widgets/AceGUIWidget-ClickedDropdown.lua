--[[-----------------------------------------------------------------------------
TabGroup Container
Container that uses tabs on top to switch between groups.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedDropdown"

local Type, Version = "ClickedDropdown", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]


--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedDropdown : AceGUIDropdown
local Methods = {}

function Methods:OnAcquire()
	self:BaseOnAcquire()

	self:SetLabelColor(NORMAL_FONT_COLOR)
end

--- @param color ColorMixin
function Methods:SetLabelColor(color)
	self.label:SetTextColor(color:GetRGBA())
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedDropdown
	local widget = AceGUI:Create("Dropdown") --[[@as AceGUIDropdown]]
	widget.type = Type

	--- @private
	widget.BaseOnAcquire = widget.OnAcquire

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

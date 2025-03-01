--[[-----------------------------------------------------------------------------
TabGroup Container
Container that uses tabs on top to switch between groups.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedCheckBox"

local Type, Version = "ClickedCheckBox", 1
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

--- @class ClickedCheckBox : AceGUICheckBox
local Methods = {}

function Methods:OnAcquire()
	self:BaseOnAcquire()

	self:SetLabelColor(WHITE_FONT_COLOR)
	self:SetLabel("")
end

--- @param color ColorMixin
function Methods:SetLabelColor(color)
	self.text:SetTextColor(color:GetRGBA())
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedCheckBox
	local widget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
	widget.type = Type

	--- @private
	widget.BaseOnAcquire = widget.OnAcquire

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

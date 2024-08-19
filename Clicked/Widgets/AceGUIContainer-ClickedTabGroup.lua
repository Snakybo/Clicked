--[[-----------------------------------------------------------------------------
TabGroup Container
Container that uses tabs on top to switch between groups.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedTabGroup"

local Type, Version = "ClickedTabGroup", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedTabGroup : AceGUITabGroup
local Methods = {}

--- @param tabs AceGUITabGroupTab[]
function Methods:SetTabs(tabs)
	self:BaseSetTabs(tabs)

	local status = self.status or self.localstatus

	for _, v in ipairs(self.tabs) do
		--- @diagnostic disable-next-line: undefined-field
		v:SetSelected(v.value == status.selected)
	end
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedTabGroup
	local widget = AceGUI:Create("TabGroup") --[[@as AceGUITabGroup]]
	widget.type = Type

	--- @private
	widget.BaseSetTabs = widget.SetTabs

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedKeyVisualizerTreeGroup"

local Type, Version = "ClickedKeyVisualizerTreeGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedKeyVisualizerTreeGroup
local Methods = {}

--- @return integer
function Methods:GetContentWidth()
	--- @diagnostic disable-next-line: undefined-field
	local status = self.status or self.localstatus
	return status.contentWidth or 0
end

--- @return integer
function Methods:GetContentHeight()
	--- @diagnostic disable-next-line: undefined-field
	local status = self.status or self.localstatus
	return status.contentHeight or 0
end

--- @protected
--- @param width integer
--- @param height integer
function Methods:LayoutFinished(width, height)
	self:OriginalLayoutFinished(width, height)

	--- @diagnostic disable-next-line: undefined-field
	local status = self.status or self.localstatus
	status.contentWidth = width
	status.contentHeight = height
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	--- @class ClickedKeyVisualizerTreeGroup : AceGUITreeGroup
	local widget = AceGUI:Create("TreeGroup")
	widget.type = Type

	widget.OriginalLayoutFinished = widget.LayoutFinished

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

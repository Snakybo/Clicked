--[[-----------------------------------------------------------------------------
SimpleGroup Container
Simple container widget that just groups widgets.

Custom implementation to enfore it being invisible because the regular
version is skinned by ElvUI and AddOnSkins.
-------------------------------------------------------------------------------]]
local Type, Version = "ClickedSimpleGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local widget = AceGUI:Create("SimpleGroup")
	widget.type = Type

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

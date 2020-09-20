--[[-----------------------------------------------------------------------------
EditBox Widget

Adds OnFocusGained and OnFocusLost callbacks.
-------------------------------------------------------------------------------]]
local Type, Version = "ClickedEditBox", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function EditBox_OnEscapePressed(frame)
	local self = frame.obj
	AceGUI:ClearFocus()
	self:Fire("OnEscapePressed")
end

local function EditBox_OnFocusGained(frame)
	local self = frame.obj
	AceGUI:SetFocus(self)
	self:Fire("OnFocusGained")
end

local function EditBox_OnFocusLost(frame)
	local self = frame.obj
	AceGUI:ClearFocus(self)
	self:Fire("OnFocusLost")
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local widget = AceGUI:Create("EditBox")
	widget.type = type

	local editbox = widget.editbox
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnEditFocusGained", EditBox_OnFocusGained)
	editbox:SetScript("OnEditFocusLost", EditBox_OnFocusLost)

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

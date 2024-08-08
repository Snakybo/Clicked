--[[-----------------------------------------------------------------------------
Clicked read-only multi line edit box
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedReadOnlyMultilineEditBox"

--- @class ClickedReadOnlyMultilineEditBox : AceGUIMultiLineEditBox

local Type, Version = "ClickedReadOnlyMultilineEditBox", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function EditBox_OnChar(frame)
	local self = frame.obj
	self.editBox:SetText(self.text)
end

local function EditBox_OnTextChanged(frame)
	local self = frame.obj
	self.editBox:SetText(self.text)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedReadOnlyMultilineEditBox
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self.editBox:SetText("")
	self:SetDisabled(false)
	self:SetWidth(200)
	self:SetNumLines(0)
	self:SetMaxLetters(0)
	self.entered = nil
end

--- @param text string
function Methods:SetText(text)
	self.editBox:SetText(text)
	self.text = text
end

--- @param from? number
--- @param to? number
function Methods:HighlightText(from, to)
	self.editBox:HighlightText(from, to)
end

--- @private
--- @param _ boolean
function Methods:DisableButton(_)
	error("ClickedReadOnlyMultilineEditBox:DisableButton() - Not implemented", 2)
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	--- @class ClickedReadOnlyMultilineEditBox
	local widget = AceGUI:Create("MultiLineEditBox")
	widget.type = Type
	widget:DisableButton(true)

	local editBox = widget.editBox
	editBox:SetScript("OnChar", EditBox_OnChar)
	editBox:SetScript("OnTextChanged", EditBox_OnTextChanged)

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

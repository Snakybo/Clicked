--[[-----------------------------------------------------------------------------
Clicked read-only multi line edit box
-------------------------------------------------------------------------------]]
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
local methods = {
	["OnAcquire"] = function(self)
		self.editBox:SetText("")
		self:SetDisabled(false)
		self:SetWidth(200)
		self:SetNumLines()
		self.entered = nil
		self:SetMaxLetters(0)
	end,

	["SetText"] = function(self, text)
		self.editBox:SetText(text)
		self.text = text
	end,

	["HighlightText"] = function(self, from, to)
		self.editBox:HighlightText(from, to)
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local widget = AceGUI:Create("MultiLineEditBox")
	widget.type = Type
	widget:DisableButton(true)

	local editBox = widget.editBox
	editBox:SetScript("OnChar", EditBox_OnChar)
	editBox:SetScript("OnTextChanged", EditBox_OnTextChanged)

	widget.DisableButton = nil

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

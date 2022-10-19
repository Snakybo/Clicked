--[[-----------------------------------------------------------------------------
SearchBox Widget

Adds OnFocusGained and OnFocusLost callbacks.
-------------------------------------------------------------------------------]]
--- @class ClickedInternal
local _, Addon = ...

local Type, Version = "ClickedSearchBox", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function ActivatePlaceholder(frame)
	local self = frame.obj

	if not self.isPlaceholderActive then
		frame:SetText(self.placeholder)

		self.searchTerm = ""
		self.isPlaceholderActive = true

		self:Fire("SearchTermChanged", self.searchTerm)
	end
end

local function ClearPlaceholder(frame)
	local self = frame.obj

	if self.isPlaceholderActive then
		frame:SetText("")
		self.isPlaceholderActive = false
	end
end

local function EditBox_OnEscapePressed(frame)
	local self = frame.obj
	AceGUI:ClearFocus()

	ActivatePlaceholder(frame)
	self:Fire("OnEscapePressed")
end

local function EditBox_OnFocusGained(frame)
	local self = frame.obj
	AceGUI:SetFocus(self)

	ClearPlaceholder(frame)
	self:Fire("OnFocusGained")
end

local function EditBox_OnFocusLost(frame)
	local self = frame.obj
	AceGUI:ClearFocus(self)

	if self.searchTerm == "" then
		ActivatePlaceholder(frame)
	end

	self:Fire("OnFocusLost")
end

local function EditBox_OnTextChanged(frame)
	local self = frame.obj
	local value = Addon:TrimString(frame:GetText())

	if not self.isPlaceholderActive and tostring(value) ~= tostring(self.searchTerm) then
		self.searchTerm = value
		self:Fire("SearchTermChanged", value)
	end
end

local function EditBox_OnEnter(frame)
	local self = frame.obj

	if not Addon:IsStringNilOrEmpty(self.tooltipHeader) then
		Addon:ShowTooltip(frame, self.tooltipHeader, self.tooltipSubtext)
	end
end

local function EditBox_OnLeave(frame)
	local self = frame.obj

	if not Addon:IsStringNilOrEmpty(self.tooltipHeader) then
		Addon:HideTooltip()
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local function OnAquire(self)
	self:OnAquireOriginal()
	self:ClearSearchTerm()

	self.tooltipHeader = nil
	self.tooltipSubtext = nil
end

local function OnRelease(self)
	self:OnReleaseOriginal()

	self.isPlaceholderActive = true
	self.placeholder = "Search..."
end

local function SetPlaceholderText(self, text)
	self.placeholder = text

	if self.isPlaceholderActive then
		self:SetText(text)
	end
end

local function ClearSearchTerm(self)
	self:SetText(self.placeholder)

	self.isPlaceholderActive = true

	if self.searchTerm ~= "" then
		self.searchTerm = ""
		self:Fire("SearchTermChanged", self.searchTerm)
	end
end

local function SetTooltipText(self, header, subtext)
	self.tooltipHeader = header
	self.tooltipSubtext = subtext
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local widget = AceGUI:Create("EditBox")
	widget.type = type
	widget.searchTerm = ""
	widget.placeholder = "Search..."
	widget.isPlaceholderActive = true

	local editbox = widget.editbox
	editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editbox:SetScript("OnEditFocusGained", EditBox_OnFocusGained)
	editbox:SetScript("OnEditFocusLost", EditBox_OnFocusLost)
	editbox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	editbox:SetScript("OnEnter", EditBox_OnEnter)
	editbox:SetScript("OnLeave", EditBox_OnLeave)

	widget:SetText(widget.placeholder)

	widget.OnAquireOriginal = widget.OnAquire
	widget.OnAquire = OnAquire
	widget.OnReleaseOriginal = widget.OnRelease
	widget.OnRelease = OnRelease
	widget.SetPlaceholderText = SetPlaceholderText
	widget.ClearSearchTerm = ClearSearchTerm
	widget.SetTooltipText = SetTooltipText

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

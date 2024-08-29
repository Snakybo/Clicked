--[[-----------------------------------------------------------------------------
SearchBox Widget

Adds OnFocusGained and OnFocusLost callbacks.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedSearchBox"

--- @class ClickedSearchBox : AceGUIEditBox
--- @field private searchTerm string
--- @field private placeholder string
--- @field private isPlaceholderActive boolean
--- @field private tooltipHeader? string
--- @field private tooltipSubtext? string

--- @class ClickedInternal
local Addon = select(2, ...)

local Type, Version = "ClickedSearchBox", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function EditBox_OnEscapePressed(frame)
	local self = frame.obj
	AceGUI:ClearFocus()

	self:ActivatePlaceholder()
	self:Fire("OnEscapePressed")
end

local function EditBox_OnFocusGained(frame)
	local self = frame.obj
	AceGUI:SetFocus(self)

	self:ClearPlaceholder()
	self:Fire("OnFocusGained")
end

local function EditBox_OnFocusLost(frame)
	local self = frame.obj
	AceGUI:ClearFocus()

	if self.searchTerm == "" then
		self:ActivatePlaceholder()
	end

	self:Fire("OnFocusLost")
end

local function EditBox_OnTextChanged(frame)
	local self = frame.obj
	local value = string.trim(frame:GetText())

	if not self.isPlaceholderActive and tostring(value) ~= tostring(self.searchTerm) then
		self.searchTerm = value
		self:Fire("SearchTermChanged", value)
	end
end

local function EditBox_OnEnter(frame)
	local self = frame.obj

	if not Addon:IsNilOrEmpty(self.tooltipHeader) then
		Addon:ShowTooltip(frame, self.tooltipHeader, self.tooltipSubtext)
	end
end

local function EditBox_OnLeave(frame)
	local self = frame.obj

	if not Addon:IsNilOrEmpty(self.tooltipHeader) then
		Addon:HideTooltip()
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedSearchBox
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:BaseOnAcquire()
	self:ClearSearchTerm()

	self.tooltipHeader = nil
	self.tooltipSubtext = nil
end

--- @protected
function Methods:OnRelease()
	self:BaseOnRelease()

	self.isPlaceholderActive = true
	self.placeholder = "Search..."
end

--- @param text string
function Methods:SetPlaceholderText(text)
	self.placeholder = text

	if self.isPlaceholderActive then
		self:SetText(text)
	end
end

--- @return string
function Methods:GetPlaceholderText()
	return self.placeholder
end

--- @return string
function Methods:GetSearchTerm()
	return self.searchTerm
end

function Methods:ClearSearchTerm()
	self:SetText(self.placeholder)

	self.isPlaceholderActive = true

	if self.searchTerm ~= "" then
		self.searchTerm = ""
		self:Fire("SearchTermChanged", self.searchTerm)
	end
end

--- @param header? string
--- @param subtext? string
function Methods:SetTooltipText(header, subtext)
	self.tooltipHeader = header
	self.tooltipSubtext = subtext
end

--- @private
function Methods:ActivatePlaceholder()
	if not self.isPlaceholderActive then
		self.editbox:SetText(self.placeholder)

		self.searchTerm = ""
		self.isPlaceholderActive = true

		self:Fire("SearchTermChanged", self.searchTerm)
	end
end

--- @private
function Methods:ClearPlaceholder()
	if self.isPlaceholderActive then
		self.editbox:SetText("")
		self.isPlaceholderActive = false
	end
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	--- @class ClickedSearchBox
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

	--- @private
	widget.BaseOnAcquire = widget.OnAcquire

	--- @private
	widget.BaseOnRelease = widget.OnRelease

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

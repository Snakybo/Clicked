-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

--[[-----------------------------------------------------------------------------
An editbox widget that adds search-specific functionality, including placeholder
text, tooltips, and search term tracking.
-------------------------------------------------------------------------------]]

--- @class Addon
local Addon = select(2, ...)

local TYPE, VERSION = "ClickedSearchBox", 3
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedSearchBox"

--- @class ClickedSearchBox : AceGUIEditBox
--- @field public frame Frame&{obj: self}
--- @field protected editbox EditBox&InputBoxTemplate&{obj: self}
--- @field protected label FontString&{obj: self}
--- @field protected button Button&UIPanelButtonTemplate&{obj: self}
--- @field protected searchTerm string
--- @field protected placeholder string
--- @field protected isPlaceholderActive boolean
--- @field protected tooltipHeader? string
--- @field protected tooltipSubtext? string
--- @field protected tooltipShown boolean
local ClickedSearchBox = {}

--- @protected
function ClickedSearchBox:OnAcquire()
	self:EditBoxOnAcquire()
	self:ClearSearchTerm()

	self.searchTerm = ""
	self.placeholder = "Search..."
	self.isPlaceholderActive = true

	self.tooltipHeader = nil
	self.tooltipSubtext = nil

	self:SetText(self.placeholder)
end

--- @protected
function ClickedSearchBox:OnRelease()
	self:EditBoxOnRelease()

	self.isPlaceholderActive = true
	self.placeholder = "Search..."
end

--- @param text string
function ClickedSearchBox:SetPlaceholderText(text)
	self.placeholder = text

	if self.isPlaceholderActive then
		self:SetText(text)
	end
end

--- @return string
function ClickedSearchBox:GetPlaceholderText()
	return self.placeholder
end

--- @return string
function ClickedSearchBox:GetSearchTerm()
	return self.searchTerm
end

function ClickedSearchBox:ClearSearchTerm()
	self:SetText(self.placeholder)

	self.isPlaceholderActive = true

	if self.searchTerm ~= "" then
		self.searchTerm = ""
		self:Fire("SearchTermChanged", self.searchTerm)
	end
end

--- @param header? string
--- @param subtext? string
function ClickedSearchBox:SetTooltipText(header, subtext)
	self.tooltipHeader = header
	self.tooltipSubtext = subtext

	if self.tooltipShown and (self.tooltipHeader == nil or self.tooltipHeader == "") then
		Addon:HideTooltip()
		self.tooltipShown = false
	end
end

--- @protected
function ClickedSearchBox:ActivatePlaceholder()
	if not self.isPlaceholderActive then
		self.editbox:SetText(self.placeholder)

		self.searchTerm = ""
		self.isPlaceholderActive = true

		self:Fire("SearchTermChanged", self.searchTerm)
	end
end

--- @protected
function ClickedSearchBox:ClearPlaceholder()
	if self.isPlaceholderActive then
		self.editbox:SetText("")
		self.isPlaceholderActive = false
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedSearchBox}
function ClickedSearchBox.EditBox_OnEscapePressed(frame)
	local self = frame.obj
	AceGUI:ClearFocus()

	self:ActivatePlaceholder()
	self:Fire("OnEscapePressed")
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedSearchBox}
function ClickedSearchBox.EditBox_OnFocusGained(frame)
	local self = frame.obj
	AceGUI:SetFocus(self)

	self:ClearPlaceholder()
	self:Fire("OnFocusGained")
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedSearchBox}
function ClickedSearchBox.EditBox_OnFocusLost(frame)
	local self = frame.obj
	AceGUI:ClearFocus()

	if self.searchTerm == "" then
		self:ActivatePlaceholder()
	end

	self:Fire("OnFocusLost")
end


--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedSearchBox}
function ClickedSearchBox.EditBox_OnTextChanged(frame)
	local self = frame.obj
	local value = string.trim(frame:GetText())

	if not self.isPlaceholderActive and tostring(value) ~= tostring(self.searchTerm) then
		self.searchTerm = value
		self:Fire("SearchTermChanged", value)
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedSearchBox}
function ClickedSearchBox.EditBox_OnEnter(frame)
	local self = frame.obj

	if not self.tooltipShown and self.tooltipHeader ~= nil and self.tooltipHeader ~= "" then
		self.tooltipShown = true
		Addon:ShowTooltip(frame, self.tooltipHeader, self.tooltipSubtext)
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedSearchBox}
function ClickedSearchBox.EditBox_OnLeave(frame)
	local self = frame.obj

	if self.tooltipShown then
		Addon:HideTooltip()
		self.tooltipShown = false
	end
end

local function Constructor()
	--- @class ClickedSearchBox
	local widget = AceGUI:Create("EditBox")
	widget.type = TYPE

	local editbox = widget.editbox
	editbox:SetScript("OnEscapePressed", ClickedSearchBox.EditBox_OnEscapePressed)
	editbox:SetScript("OnEditFocusGained", ClickedSearchBox.EditBox_OnFocusGained)
	editbox:SetScript("OnEditFocusLost", ClickedSearchBox.EditBox_OnFocusLost)
	editbox:SetScript("OnTextChanged", ClickedSearchBox.EditBox_OnTextChanged)
	editbox:SetScript("OnEnter", ClickedSearchBox.EditBox_OnEnter)
	editbox:SetScript("OnLeave", ClickedSearchBox.EditBox_OnLeave)

	--- @private
	widget.EditBoxOnAcquire = widget.OnAcquire

	--- @private
	widget.EditBoxOnRelease = widget.OnRelease

	for method, func in pairs(ClickedSearchBox) do
		widget[method] = func
	end

	widget.label.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

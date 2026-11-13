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
A simple icon with a horizontal label.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedHorizontalIcon", 3
local AceGUI = LibStub("AceGUI-3.0")

if (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedHorizontalIcon"

--- @class ClickedHorizontalIcon : AceGUIWidget
--- @field public frame Button&{obj: self}
--- @field public type string
--- @field protected image Texture
--- @field protected label FontString
local ClickedHorizontalIcon = {}

--- @protected
function ClickedHorizontalIcon:OnAcquire()
	self:SetHeight(16)
	self:SetWidth(110)
	self:SetLabel()
	self:SetImage(nil)
	self:SetImageSize(16, 16)
end

--- @param text? string
function ClickedHorizontalIcon:SetLabel( text)
	if text and text ~= "" then
		self.label:Show()
		self.label:SetText(text)
	else
		self.label:Hide()
	end
end

--- @param path? string|integer
--- @param ... number
function ClickedHorizontalIcon:SetImage(path, ...)
	local image = self.image

	image:SetTexture(path)

	if image:GetTexture() then
		local n = select("#", ...)

		if n == 4 or n == 8 then
			image:SetTexCoord(...)
		else
			image:SetTexCoord(0, 1, 0, 1)
		end
	end
end

--- @param width number
--- @param height number
function ClickedHorizontalIcon:SetImageSize(width, height)
	self.image:SetWidth(width)
	self.image:SetHeight(height)
end

--- @protected
--- @param frame Button&{obj: ClickedHorizontalIcon}
function ClickedHorizontalIcon.Frame_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

--- @protected
--- @param frame Button&{obj: ClickedHorizontalIcon}
function ClickedHorizontalIcon.Frame_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

--- @protected
--- @param frame Button&{obj: ClickedHorizontalIcon}
--- @param button string
function ClickedHorizontalIcon.Frame_OnClick(frame, button)
	frame.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

--- @return ClickedHorizontalIcon
local function Constructor()
	--- @class ClickedHorizontalIcon
	local widget = {}
	widget.type = TYPE

	local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", ClickedHorizontalIcon.Frame_OnEnter)
	frame:SetScript("OnLeave", ClickedHorizontalIcon.Frame_OnLeave)
	frame:SetScript("OnClick", ClickedHorizontalIcon.Frame_OnClick)
	frame.obj = widget

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetWidth(64)
	image:SetHeight(64)
	image:SetPoint("LEFT", 3, -2)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	label:SetPoint("LEFT", image, "RIGHT", 5, 0)
	label:SetJustifyH("LEFT")
	label:SetJustifyV("MIDDLE")
	label:SetHeight(18)

	widget.frame = frame
	widget.label = label
	widget.image = image

	for method, func in pairs(ClickedHorizontalIcon) do
		widget[method] = func
	end

	--- TEMP: This cast can be removed once https://github.com/TradeSkillMaster/wowlua-ls/pull/65 is merged
	return AceGUI:RegisterAsWidget(widget) --[[@as ClickedHorizontalIcon]]
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

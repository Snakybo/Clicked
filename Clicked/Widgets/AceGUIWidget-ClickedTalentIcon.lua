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
A talent icon widget, similar to AceGUI's icon widget, but without a label and
customizable vertex colors.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedTalentIcon", 2
local AceGUI = LibStub("AceGUI-3.0")

if (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedTalentIcon"

--- @class ClickedTalentIcon : AceGUIWidget
--- @field public frame Button&{obj: self}
--- @field public type string
--- @field protected label FontString&{obj: self}
--- @field protected image Texture&{obj: self}
local ClickedTalentIcon = {}

--- @protected
function ClickedTalentIcon:OnAcquire()
	self:SetHeight(110)
	self:SetWidth(110)
	self:SetImage(nil)
	self:SetImageSize(64, 64)
	self:SetColor(1, 1, 1, 1)
end

--- @param path? string|integer
--- @param ... number
function ClickedTalentIcon:SetImage(path, ...)
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

--- @param width integer
--- @param height integer
function ClickedTalentIcon:SetImageSize(width, height)
	self.image:SetWidth(width)
	self.image:SetHeight(height)
end

--- @param r number
--- @param g number
--- @param b number
--- @param a number
function ClickedTalentIcon:SetColor(r, g, b, a)
	self.image:SetVertexColor(r, g, b, a)
end

--- @protected
--- @param frame Frame&{obj: ClickedTalentIcon}
function ClickedTalentIcon.Frame_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

--- @protected
--- @param frame Frame&{obj: ClickedTalentIcon}
function ClickedTalentIcon.Frame_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

--- @protected
--- @param frame Frame&{obj: ClickedTalentIcon}
--- @param button string
function ClickedTalentIcon.Frame_OnClick(frame, button)
	frame.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

--- @return ClickedTalentIcon
local function Constructor()
	--- @class ClickedTalentIcon
	local widget = {}
	widget.type = TYPE

	local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()
	frame.obj = widget

	frame:EnableMouse(true)
	frame:SetScript("OnEnter", ClickedTalentIcon.Frame_OnEnter)
	frame:SetScript("OnLeave", ClickedTalentIcon.Frame_OnLeave)
	frame:SetScript("OnClick", ClickedTalentIcon.Frame_OnClick)

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlight")
	label:SetPoint("BOTTOMLEFT")
	label:SetPoint("BOTTOMRIGHT")
	label:SetJustifyH("CENTER")
	label:SetJustifyV("TOP")
	label:SetHeight(18)
	label.obj = widget

	local image = frame:CreateTexture(nil, "BACKGROUND")
	image:SetWidth(64)
	image:SetHeight(64)
	image:SetPoint("TOP", 0, -5)
	image.obj = widget

	widget.frame = frame
	widget.label = label
	widget.image = image

	for method, func in pairs(ClickedTalentIcon) do
		widget[method] = func
	end

	--- TEMP: This cast can be removed once https://github.com/TradeSkillMaster/wowlua-ls/pull/65 is merged
	return AceGUI:RegisterAsWidget(widget) --[[@as ClickedTalentIcon]]
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

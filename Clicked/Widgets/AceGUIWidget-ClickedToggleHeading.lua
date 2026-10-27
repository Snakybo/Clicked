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
A heading similar to AceGUI's Heading widget, but with an in-line togglable checkbox.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedToggleHeading", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedToggleHeading"

--- @class ClickedToggleHeading : AceGUIWidget
--- @field public frame Button&{obj: self}
--- @field protected label FontString&{obj: self}
--- @field protected checkbg Texture&{obj: self}
--- @field protected check Texture&{obj: self}
--- @field protected highlight Texture&{obj: self}
--- @field protected left Texture&{obj: self}
--- @field protected right Texture&{obj: self}
--- @field protected center Texture&{obj: self}
--- @field protected disabled boolean
--- @field protected checked boolean
local ClickedToggleHeading = {}

--- @protected
function ClickedToggleHeading:OnAcquire()
	self:SetHeight(24)
	self:SetText("")
	self:SetValue(false)
	self:SetDisabled(false)
	self:SetLabelColor(NORMAL_FONT_COLOR)
end

--- @param text string
function ClickedToggleHeading:SetText(text)
	self.label:SetText(text)

	if text and text ~= "" then
		self.right:Show()
	else
		self.right:Hide()
	end
end

--- @param disabled boolean
function ClickedToggleHeading:SetDisabled(disabled)
	self.disabled = disabled

	if disabled then
		self.frame:Disable()
		self.label:SetTextColor(0.5, 0.5, 0.5)
		self.check:SetDesaturated(true)
	else
		self.frame:Enable()
		self.label:SetTextColor(1, 1, 1)
		self.check:SetDesaturated(false)
	end
end

--- @param value boolean
function ClickedToggleHeading:SetValue(value)
	local check = self.check

	self.checked = value

	if value then
		check:SetDesaturated(false)
		check:Show()
	else
		check:SetDesaturated(false)
		check:Hide()
	end

	self:SetDisabled(self.disabled)
end

--- @param color ColorMixin
function ClickedToggleHeading:SetLabelColor(color)
	self.label:SetTextColor(color:GetRGBA())
end

--- @return boolean
function ClickedToggleHeading:GetValue()
	return self.checked
end

function ClickedToggleHeading:ToggleChecked()
	self:SetValue(not self:GetValue())
end

--- @protected
--- @param frame Frame&{obj: ClickedToggleHeading}
function ClickedToggleHeading.Frame_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

--- @protected
--- @param frame Frame&{obj: ClickedToggleHeading}
function ClickedToggleHeading.Frame_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

--- @protected
--- @param frame Frame&{obj: ClickedToggleHeading}
function ClickedToggleHeading.Frame_OnMouseDown(frame)
	AceGUI:ClearFocus()
end

--- @protected
--- @param frame Frame&{obj: ClickedToggleHeading}
function ClickedToggleHeading.Frame_OnMouseUp(frame)
	local self = frame.obj

	if not self.disabled then
		self:ToggleChecked()

		if self.checked then
			PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		else -- for both nil and false (tristate)
			PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
		end

		self:Fire("OnValueChanged", self.checked)
	end
end

local function Constructor()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnEnter", ClickedToggleHeading.Frame_OnEnter)
	frame:SetScript("OnLeave", ClickedToggleHeading.Frame_OnLeave)
	frame:SetScript("OnMouseDown", ClickedToggleHeading.Frame_OnMouseDown)
	frame:SetScript("OnMouseUp", ClickedToggleHeading.Frame_OnMouseUp)

	local checkbg = frame:CreateTexture(nil, "ARTWORK")
	checkbg:SetWidth(24)
	checkbg:SetHeight(24)
	checkbg:SetPoint("LEFT", 14, -1)
	checkbg:SetTexture(130755) -- Interface\\Buttons\\UI-CheckBox-Up

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOP")
	label:SetPoint("BOTTOM")
	label:SetJustifyH("CENTER")
	label:SetHeight(18)

	local check = frame:CreateTexture(nil, "OVERLAY")
	check:SetAllPoints(checkbg)
	check:SetTexture(130751) -- Interface\\Buttons\\UI-CheckBox-Check

	local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetTexture(130753) -- Interface\\Buttons\\UI-CheckBox-Highlight
	highlight:SetBlendMode("ADD")
	highlight:SetAllPoints(checkbg)

	local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetHeight(8)
	left:SetPoint("LEFT", 3, 0)
	left:SetPoint("RIGHT", checkbg, "LEFT", -3, 0)
	left:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	left:SetTexCoord(0.81, 0.94, 0.5, 1)

	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetHeight(8)
	right:SetPoint("RIGHT", -3, 0)
	right:SetPoint("LEFT", label, "RIGHT", 5, 0)
	right:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	right:SetTexCoord(0.81, 0.94, 0.5, 1)

	local center = frame:CreateTexture(nil, "BACKGROUND")
	center:SetHeight(8)
	center:SetPoint("LEFT", checkbg, "RIGHT", 3, 1)
	center:SetPoint("RIGHT", label, "LEFT", -5, 1)
	center:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	center:SetTexCoord(0.81, 0.94, 0.5, 1)

	--- @class ClickedToggleHeading
	local widget = {
		frame     = frame,
		label     = label,
		checkbg   = checkbg,
		check     = check,
		highlight = highlight,
		left      = left,
		right     = right,
		center    = center,
		checked   = false,
		disabled  = false,
		type      = TYPE
	}

	for method, func in pairs(ClickedToggleHeading) do
		widget[method] = func
	end

	widget.checkbg.obj = widget
	widget.label.obj = widget
	widget.check.obj = widget
	widget.highlight.obj = widget
	widget.left.obj = widget
	widget.right.obj = widget
	widget.center.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

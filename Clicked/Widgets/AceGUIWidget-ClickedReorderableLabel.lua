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
A reorderable label widget with up and down buttons for reordering, customizable
text, and optional image support.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedReorderableLabel", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedReorderableLabel"

--- @class ClickedReorderableLabel : AceGUIWidget
--- @field public frame Button&{obj: self}
--- @field protected label FontString&{obj: self}
--- @field protected image Texture&{obj: self}
--- @field protected up Button&{obj: self}
--- @field protected down Button&{obj: self}
--- @field protected resizing boolean
--- @field protected imageShown boolean
local ClickedReorderableLabel = {}

--- @protected
function ClickedReorderableLabel:OnAcquire()
	self.resizing = true

	self:SetWidth(200)
	self:SetText()
	self:SetImage(nil)
	self:SetImageSize(16, 16)
	self:SetColor()
	self:SetFontObject(nil)
	self:SetJustifyH("LEFT")
	self:SetJustifyV("TOP")

	self.resizing = false
	self:UpdateAnchor()
end

--- @protected
function ClickedReorderableLabel:OnWidthSet()
	self:UpdateAnchor()
end

--- @param text? string
function ClickedReorderableLabel:SetText(text)
	self.label:SetText(text)
	self:UpdateAnchor()
end

--- @param r? number
--- @param g? number
--- @param b? number
function ClickedReorderableLabel:SetColor(r, g, b)
	r = r or 1
	g = g or 1
	b = b or 1

	self.label:SetVertexColor(r, g, b)
end

--- @param path? string|number
--- @param ... number
function ClickedReorderableLabel:SetImage(path, ...)
	local image = self.image

	image:SetTexture(path)

	if image:GetTexture() then
		self.imageShown = true
		local n = select("#", ...)
		if n == 4 or n == 8 then
			image:SetTexCoord(...)
		else
			image:SetTexCoord(0, 1, 0, 1)
		end
	else
		self.imageShown = false
	end

	self:UpdateAnchor()
end

--- @param font any
--- @param height any
--- @param flags any
function ClickedReorderableLabel:SetFont(font, height, flags)
	self.label:SetFont(font, height, flags)
	self:UpdateAnchor()
end

--- @param font any
function ClickedReorderableLabel:SetFontObject(font)
	self:SetFont((font or GameFontHighlightSmall):GetFont())
end

--- @param width number
--- @param height number
function ClickedReorderableLabel:SetImageSize(width, height)
	self.image:SetWidth(width)
	self.image:SetHeight(height)
	self:UpdateAnchor()
end

--- @param justifyH JustifyHorizontal
function ClickedReorderableLabel:SetJustifyH(justifyH)
	self.label:SetJustifyH(justifyH)
end

--- @param justifyV JustifyVertical
function ClickedReorderableLabel:SetJustifyV(justifyV)
	self.label:SetJustifyV(justifyV)
end

--- @param enabled boolean
function ClickedReorderableLabel:SetMoveUpButton(enabled)
	if enabled then
		self.up:Show()
	else
		self.up:Hide()
	end

	self.frame:SetScript("OnUpdate", function()
		self.frame:SetScript("OnUpdate", nil)
		self:UpdateAnchor()
	end)
end

--- @param enabled boolean
function ClickedReorderableLabel:SetMoveDownButton(enabled)
	if enabled then
		self.down:Show()
	else
		self.down:Hide()
	end

	self.frame:SetScript("OnUpdate", function()
		self.frame:SetScript("OnUpdate", nil)
		self:UpdateAnchor()
	end)
end

--- @protected
function ClickedReorderableLabel:UpdateAnchor()
	if self.resizing then return end
	local frame = self.frame
	local width = frame:GetWidth() or 0
	local image = self.image
	local label = self.label
	local up = self.up
	local down = self.down
	local height

	up:ClearAllPoints()
	down:ClearAllPoints()
	label:ClearAllPoints()
	image:ClearAllPoints()

	if self.imageShown then
		local imagewidth = image:GetWidth()

		image:SetPoint("TOPLEFT", 12, 0)
		label:SetPoint("TOPLEFT", image, "TOPRIGHT", 4, 0)

		up:SetPoint("LEFT", label, "RIGHT")

		if up:IsShown() then
			down:SetPoint("LEFT", up, "RIGHT", 4, 0)
		else
			down:SetPoint("LEFT", label, "RIGHT")
		end

		label:SetWidth(width - imagewidth - 52)
		height = math.max(image:GetHeight(), label:GetStringHeight())
	else
		height = label:GetStringHeight()
		label:SetWidth(width)
	end

	-- avoid zero-height labels, since they can used as spacers
	if not height or height == 0 then
		height = 1
	end

	self.resizing = true
	frame:SetHeight(height)
	frame.height = height --- @diagnostic disable-line: inject-field
	self.resizing = false
end

--- @protected
--- @param frame Button&{obj: ClickedReorderableLabel}
--- @param button string
function ClickedReorderableLabel.Frame_OnClick(frame, button)
	frame.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

--- @protected
--- @param frame Button&{obj: ClickedReorderableLabel}
function ClickedReorderableLabel.Up_OnClick(frame)
	frame.obj:Fire("OnMoveUp")
	AceGUI:ClearFocus()
end

--- @protected
--- @param frame Button&{obj: ClickedReorderableLabel}
function ClickedReorderableLabel.Down_OnClick(frame)
	frame.obj:Fire("OnMoveDown")
	AceGUI:ClearFocus()
end

local function Constructor()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", ClickedReorderableLabel.Frame_OnClick)

	local up = CreateFrame("Button", nil, frame)
	up:SetSize(16, 16)
	up:SetScript("OnClick", ClickedReorderableLabel.Up_OnClick)

	local upImage = up:CreateTexture(nil, "BACKGROUND")
	upImage:SetSize(16, 16)
	upImage:SetPoint("CENTER")
	upImage:SetTexture([[Interface\Addons\Clicked\Media\Textures\ui_arrow_up.tga]])

	local down = CreateFrame("Button", nil, frame)
	down:SetSize(16, 16)
	down:SetScript("OnClick", ClickedReorderableLabel.Down_OnClick)

	local downImage = down:CreateTexture(nil, "BACKGROUND")
	downImage:SetSize(16, 16)
	downImage:SetPoint("CENTER")
	downImage:SetTexture([[Interface\Addons\Clicked\Media\Textures\ui_arrow_down.tga]])

	local image = frame:CreateTexture(nil, "BACKGROUND")

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")

	--- @class ClickedReorderableLabel
	local widget = {
		label      = label,
		image      = image,
		up         = up,
		down       = down,
		frame      = frame,
		imageShown = false,
		resizing   = false,
		type       = TYPE
	}

	for method, func in pairs(ClickedReorderableLabel) do
		widget[method] = func
	end

	widget.up.obj = widget
	widget.down.obj = widget
	widget.image.obj = widget
	widget.label.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

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
A keyboard button widget, representing a single key with an optional background
icon, and action count.
-------------------------------------------------------------------------------]]

--- @class Addon
local Addon = select(2, ...)

local TYPE, VERSION = "ClickedKeyVisualizerButton", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedKeyVisualizerButton"

--- @alias AceGUILayoutType
--- | "ClickedKeys"

--- @class ClickedKeyVisualizerButton : AceGUIWidget
--- @field public frame Frame&{obj: self}
--- @field protected background Texture&{obj: self}
--- @field protected backgroundMask MaskTexture&{obj: self}?
--- @field protected key KeyButton?
--- @field protected visible boolean
--- @field protected highlight boolean
local ClickedKeyVisualizerButton = {}

--- @protected
function ClickedKeyVisualizerButton:OnAcquire()
	self:SetKey()
	self:SetIcon()
	self:SetVisible(true)
	self:SetHighlight(false)
	self:SetActionCount(0)
end

--- @param key? KeyButton
function ClickedKeyVisualizerButton:SetKey(key)
	self.key = key
	self.keyName:SetText(key ~= nil and key:GetAbbreviation() or nil)
	self.frame:SetAlpha(key ~= nil and (key.disabled and 0.5 or 1) or 1)
end

function ClickedKeyVisualizerButton:SetActionCount(count)
	if count > 1 then
		self.extraActionCount:SetText("+" .. (count - 1))
		self.extraActionCount:Show()
	else
		self.extraActionCount:Hide()
	end
end

--- @param icon string|integer|nil
function ClickedKeyVisualizerButton:SetIcon(icon)
	self.image:SetTexture(icon)
end

--- @param visible boolean
function ClickedKeyVisualizerButton:SetVisible(visible)
	self.visible = visible

	if self.visible then
		self.frame:Show()
	else
		self.frame:Hide()
	end
end

--- @param highlight boolean
function ClickedKeyVisualizerButton:SetHighlight(highlight)
	self.highlight = highlight

	if self.highlight then
		self.background:SetVertexColor(0, 1, 0, 1)
	else
		self.background:SetVertexColor(1, 1, 1, 1)
	end
end

--- @return KeyButton?
function ClickedKeyVisualizerButton:GetKey()
	return self.key
end

--- @return boolean
function ClickedKeyVisualizerButton:IsVisible()
	return self.visible
end

--- @return boolean
function ClickedKeyVisualizerButton:IsHighlighted()
	return self.highlight
end

--- @protected
--- @param frame Frame&{obj: ClickedKeyVisualizerButton}
function ClickedKeyVisualizerButton.Frame_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

--- @protected
--- @param frame Frame&{obj: ClickedKeyVisualizerButton}
function ClickedKeyVisualizerButton.Frame_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local name = "ClickedKeyVisualizerButton" .. AceGUI:GetNextWidgetNum(TYPE)

	local frame = CreateFrame("Frame", name, UIParent)
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", ClickedKeyVisualizerButton.Frame_OnEnter)
	frame:SetScript("OnLeave", ClickedKeyVisualizerButton.Frame_OnLeave)

	local background = frame:CreateTexture(nil, "BACKGROUND")
	background:SetAllPoints()

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF or Addon:IsForever() then
		background:SetTexture("Interface/HUD/UIActionBar");
		background:SetTexCoord(0.707031, 0.886719, 0.248047, 0.291992)
		background:SetTextureSliceMargins(8, 8, 8, 8)
		background:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
	else
		background:SetTexture("Interface/Buttons/ui-quickslot2")
		background:SetTextureSliceMargins(20, 20, 20, 20)
		background:SetTexCoord(0.2, 0.8, 0.2, 0.8)
		background:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
	end

	local image = frame:CreateTexture(nil, "ARTWORK")
	image:SetPoint("CENTER")
	image:SetSize(46, 45)

	--- @type MaskTexture?
	local backgroundMask

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.DF or Addon:IsForever() then
		backgroundMask = frame:CreateMaskTexture(nil, "BACKGROUND")
		backgroundMask:SetPoint("CENTER", 0, -0.5)
		backgroundMask:SetTexture("Interface/HUD/UIActionBarIconFrameMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE");
		backgroundMask:SetTexCoord(0, 1, 0, 1)
		backgroundMask:SetSize(60, 61)
		image:AddMaskTexture(backgroundMask)
	end

	local keyName = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
	keyName:ClearAllPoints()
	keyName:SetPoint("TOP", 0, -5)
	keyName:SetHeight(10)

	local extraActionCount = frame:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
	extraActionCount:ClearAllPoints()
	extraActionCount:SetPoint("BOTTOMRIGHT", -3, 4)
	extraActionCount:SetHeight(10)
	extraActionCount:SetJustifyH("RIGHT")

	--- @class ClickedKeyVisualizerButton
	local widget = {
		type  = TYPE,
		background = background,
		backgroundMask = backgroundMask,
		keyName  = keyName,
		extraActionCount = extraActionCount,
		image = image,
		frame = frame,
		highlight = false,
		visible = false,
	}

	for method, func in pairs(ClickedKeyVisualizerButton) do
		widget[method] = func
	end

	widget.background.obj = widget

	if backgroundMask ~= nil then
		backgroundMask.obj = widget
	end

	return AceGUI:RegisterAsWidget(widget)
end

--- @param content Frame&{ obj: AceGUIWidget&{ LayoutFinished: fun(self: AceGUIWidget, totalWidth: number, totalHeight: number)? } }
--- @param children AceGUIWidget[]
local function Layout(content, children)
	local GRID_SIZE = 45
	local PADDING_SIZE = 2

	local totalWidth = 0
	local totalHeight = 0

	local keys = {}
	local last = {
		relX = 0,
		relY = 0,
		relW = 0,
		relH = 0
	}

	for i = 1, #children do
		--- @type ClickedKeyVisualizerButton
		local child = children[i]

		local frame = child.frame
		frame:ClearAllPoints()

		local key = child:GetKey()

		if key ~= nil then
			local id = key:GetId()

			if id ~= nil then
				local anchor = key.relativeTo and keys[key.relativeTo] or last

				-- Get the relative position from the configuration
				local relX = key.x or anchor.relX + anchor.relW + (key.xOffset or 0)
				local relY = key.y or anchor.relY + (key.yOffset or 0)
				local relW = key.width or 1
				local relH = key.height or 1

				-- Apply standard padding
				local padX = relX * PADDING_SIZE
				local padY = relY * PADDING_SIZE
				local padW = (relW - 1) * PADDING_SIZE
				local padH = (relH - 1) * PADDING_SIZE

				-- Convert relative position to absolute position
				local x = Round(relX * GRID_SIZE + padX)
				local y = Round(relY * GRID_SIZE + padY)
				local w = Round(relW * GRID_SIZE + padW)
				local h = Round(relH * GRID_SIZE + padH)

				last = {
					frame = frame,
					relX = relX,
					relY = relY,
					relW = relW,
					relH = relH
				}
				keys[id] = last

				child:SetWidth(w)
				child:SetHeight(h)
				frame:SetPoint("TOPLEFT", content, "TOPLEFT", x, -y)

				if child:IsVisible() then
					totalWidth = math.max(totalWidth, x + w)
					totalHeight = math.max(totalHeight, y + h)

					frame:Show()
				else
					frame:Hide()
				end
			end
		end
	end

	Addon:SafeCall(content.obj.LayoutFinished, content.obj, totalWidth, totalHeight)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)
AceGUI:RegisterLayout("ClickedKeys", Layout)

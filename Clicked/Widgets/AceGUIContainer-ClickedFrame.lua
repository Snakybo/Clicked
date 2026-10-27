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
Simple frame widget extension to add support for closing the frame on escape.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedFrame", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedFrame"

--- @class ClickedFrame.Status : AceGUIFrameStatus
--- @field minWidth? integer
--- @field minHeight? integer

--- @class ClickedFrame : AceGUIFrame
--- @field protected localstatus ClickedFrame.Status
--- @field protected status? ClickedFrame.Status
local ClickedFrame = {}

--- @protected
function ClickedFrame:OnAcquire()
	self:FrameOnAcquire()

	self:SetMinWidth()
	self:SetMinHeight()

	self.frame:SetFrameStrata("HIGH")
end

function ClickedFrame:MoveToFront()
	self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
end

--- @param width? integer
function ClickedFrame:SetMinWidth(width)
	local status = self.status or self.localstatus
	status.minWidth = width
end

--- @param height? integer
function ClickedFrame:SetMinHeight(height)
	local status = self.status or self.localstatus
	status.minHeight = height
end

--- @protected
--- @param width integer
function ClickedFrame:OnWidthSet(width)
	local status = self.status or self.localstatus

	if status.minWidth ~= nil then
		width = math.max(width, status.minWidth)
	end

	self:FrameOnWidthSet(width)
end

--- @protected
--- @param height integer
function ClickedFrame:OnHeightSet(height)
	local status = self.status or self.localstatus

	if status.minHeight ~= nil then
		height = math.max(height, status.minHeight)
	end

	self:FrameOnHeightSet(height)
end

--- @protected
--- @param frame Frame&{obj: ClickedFrame}
--- @param key string
function ClickedFrame.Frame_OnKeyDown(frame, key)
	if InCombatLockdown() then
		return
	end

	if key == "ESCAPE" then
		frame:SetPropagateKeyboardInput(false)
		frame:Hide()
	else
		frame:SetPropagateKeyboardInput(true)
	end
end

--- @protected
--- @param frame Frame&{obj: ClickedFrame}
function ClickedFrame.Frame_OnReceiveDrag(frame)
	local self = frame.obj

	self:Fire("OnReceiveDrag")
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedFrame : AceGUIFrame
	local widget = AceGUI:Create("Frame")
	widget.type = TYPE

	widget.frame:SetScript("OnKeyDown",  ClickedFrame.Frame_OnKeyDown)
	widget.frame:SetScript("OnReceiveDrag", ClickedFrame.Frame_OnReceiveDrag)

	--- @private
	widget.FrameOnAcquire = widget.OnAcquire

	--- @private
	widget.FrameOnWidthSet = widget.OnWidthSet

	--- @private
	widget.FrameOnHeightSet = widget.OnHeightSet

	for method, func in pairs(ClickedFrame) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

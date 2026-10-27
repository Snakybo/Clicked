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
A keybinding widget, similar to the standard AceGUI keybinding widget, but
allows for binding of BUTTON1 and BUTTON2, as well as a nicer user experience
where the button has to be activated prior to listening for inputs.
-------------------------------------------------------------------------------]]

--- @class Addon
local Addon = select(2, ...)

local TYPE, VERSION = "ClickedKeybinding", 4
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedKeybinding"

--- @class ClickedKeybinding : AceGUIKeybinding
--- @field public frame Frame&{obj: self}
--- @field protected button Button&UIPanelButtonTemplate&{obj: self}
--- @field protected label FontString&{obj: self}
--- @field protected msgframe Frame&BackdropTemplate&{obj: self}
--- @field protected alignoffset integer
--- @field protected key string
--- @field protected hasMarker boolean
--- @field protected waitingForKey boolean
--- @field protected lastClickTime number
local ClickedKeybinding = {}

ClickedKeybinding.IGNORE_KEYS = {
	["UNKNOWN"] = true,
	["LSHIFT"] = true, ["LCTRL"] = true, ["LALT"] = true, ["LMETA"] = true,
	["RSHIFT"] = true, ["RCTRL"] = true, ["RALT"] = true, ["RMETA"] = true,
	["SHIFT"] = true, ["CTRL"] = true, ["ALT"] = true, ["META"] = true
}

--- @protected
function ClickedKeybinding:OnAcquire()
	self:KeybindingOnAcquire()
	self.key = ""
	self.hasMarker = false
end

--- @param key string
function ClickedKeybinding:SetKey(key)
	self.key = key
	self:UpdateText()
end

--- @return string
function ClickedKeybinding:GetKey()
	return self.key
end

--- @param marker boolean
function ClickedKeybinding:SetMarker(marker)
	self.hasMarker = marker
	self:UpdateText()
end

--- @protected
function ClickedKeybinding:UpdateText()
	local key = self.key
	local hasMarker = self.hasMarker
	local button = self.button

	if (key or "") == "" then
		button:SetText(NOT_BOUND)
		button:SetNormalFontObject("GameFontNormal")
	else
		button:SetText(hasMarker and (key .. "*") or key)
		button:SetNormalFontObject("GameFontHighlight")
	end
end

--- @param key string
--- @return string?
function ClickedKeybinding:GenerateChord(key)
	if self.IGNORE_KEYS[key] then
		return nil
	end

	local chord = {}

	if IsAltKeyDown() then
		table.insert(chord, "ALT")
	end

	if IsControlKeyDown() then
		table.insert(chord, "CTRL")
	end

	if IsShiftKeyDown() then
		table.insert(chord, "SHIFT")
	end

	if IsMetaKeyDown() then
		table.insert(chord, "META")
	end

	table.insert(chord, key)

	return table.concat(chord, "-")
end

--- @protected
function ClickedKeybinding:EnableKeyCapture()
	self.button:EnableKeyboard(true)
	self.button:EnableMouseWheel(true)
	self.button:EnableGamePadButton(true)
	self.button:LockHighlight()

	self.waitingForKey = true
	self.button:SetText(Addon.L["Press any key or ESC to cancel"])
end

--- @protected
function ClickedKeybinding:DisableKeyCapture()
	self.button:EnableKeyboard(false)
	self.button:EnableMouseWheel(false)
	self.button:EnableGamePadButton(false)
	self.button:UnlockHighlight()

	self.waitingForKey = false
	self.lastClickTime = GetTime()
	self:UpdateText()
end

--- @protected
--- @param frame Button&UIPanelButtonTemplate&{obj: ClickedKeybinding}
--- @param button string
function ClickedKeybinding.Button_OnClick(frame, button)
	local self = frame.obj
	local passed = GetTime() - (self.lastClickTime or 0)

	if button == "LeftButton" then
		if not self.waitingForKey and passed > 0.01 then
			self:EnableKeyCapture()
		end
	elseif button == "RightButton" then
		if not self.waitingForKey and passed > 0.01 then
			self:SetKey("")
			self:Fire("OnKeyChanged", "")
		end
	end

	AceGUI:ClearFocus()
end

--- @protected
--- @param frame Button&UIPanelButtonTemplate&{obj: ClickedKeybinding}
--- @param key string
function ClickedKeybinding.Button_OnKeyDown(frame, key)
	local self = frame.obj

	if self.waitingForKey then
		if key == "ESCAPE" then
			self:DisableKeyCapture()
			return
		end

		local chord = self:GenerateChord(key)

		if chord ~= nil then
			self:DisableKeyCapture()

			if not self.disabled then
				self:SetKey(chord)
				self:Fire("OnKeyChanged", chord)
			end
		end
	end
end

--- @protected
--- @param frame Button&UIPanelButtonTemplate&{obj: ClickedKeybinding}
--- @param button string
function ClickedKeybinding.Button_OnMouseDown(frame, button)
	if button == "LeftButton" then
		button = "BUTTON1"
	elseif button == "RightButton" then
        button = "BUTTON2"
    elseif button == "MiddleButton" then
		button = "BUTTON3"
	elseif string.match(button, "Button%d") then
		button = string.upper(button)
	end

	ClickedKeybinding.Button_OnKeyDown(frame, button)
end

--- @protected
--- @param frame Button&UIPanelButtonTemplate&{obj: ClickedKeybinding}
--- @param direction integer
function ClickedKeybinding.Button_OnMouseWheel(frame, direction)
	local button

	if direction >= 0 then
		button = "MOUSEWHEELUP"
	else
		button = "MOUSEWHEELDOWN"
	end

	ClickedKeybinding.Button_OnKeyDown(frame, button)
end

local function Constructor()
	--- @class ClickedKeybinding
	local widget = AceGUI:Create("Keybinding")
	widget.type = TYPE

	local button = widget.button
	button:SetScript("OnClick", ClickedKeybinding.Button_OnClick)
	button:SetScript("OnKeyDown", ClickedKeybinding.Button_OnKeyDown)
	button:SetScript("OnMouseDown", ClickedKeybinding.Button_OnMouseDown)
	button:SetScript("OnMouseWheel", ClickedKeybinding.Button_OnMouseWheel)
	button:SetScript("OnGamePadButtonDown", ClickedKeybinding.Button_OnKeyDown)

	--- @private
	widget.KeybindingOnAcquire = widget.OnAcquire

	for method, func in pairs(ClickedKeybinding) do
		widget[method] = func
	end

	widget.label.obj = widget
	widget.msgframe.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

--[[-----------------------------------------------------------------------------
Clicked Keybinding Widget
Set Keybindings in the Config UI.
-------------------------------------------------------------------------------]]
local Type, Version = "ClickedKeybinding", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- WoW APIs
local IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown = IsShiftKeyDown, IsControlKeyDown, IsAltKeyDown

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Keybinding_OnClick(frame, button)
	if button == "LeftButton" then
		local self = frame.obj
		local passed = GetTime() - (self.lastClickTime or 0)

		if not self.waitingForKey and passed > 0.01 then
			frame:EnableKeyboard(true)
			frame:EnableMouseWheel(true)
			self.msgframe:Show()
			frame:LockHighlight()
			self.waitingForKey = true
		end
	end
	AceGUI:ClearFocus()
end

local ignoreKeys = {
	["UNKNOWN"] = true,
	["LSHIFT"] = true, ["LCTRL"] = true, ["LALT"] = true,
	["RSHIFT"] = true, ["RCTRL"] = true, ["RALT"] = true,
}

local function Keybinding_OnKeyDown(frame, key)
	local self = frame.obj

	if self.waitingForKey then
		local keyPressed = key

		if keyPressed == "ESCAPE" then
			keyPressed = ""
		else
			if ignoreKeys[keyPressed] then return end
			if IsShiftKeyDown() then
				keyPressed = "SHIFT-"..keyPressed
			end
			if IsControlKeyDown() then
				keyPressed = "CTRL-"..keyPressed
			end
			if IsAltKeyDown() then
				keyPressed = "ALT-"..keyPressed
			end
		end

		frame:EnableKeyboard(false)
		frame:EnableMouseWheel(false)
		self.msgframe:Hide()
		frame:UnlockHighlight()
		self.waitingForKey = nil
		self.lastClickTime = GetTime()

		if not self.disabled then
			self:SetKey(keyPressed)
			self:Fire("OnKeyChanged", keyPressed)
		end
	end
end

local function Keybinding_OnMouseDown(frame, button)
	if button == "LeftButton" then
		button = "BUTTON1"
	elseif button == "RightButton" then
        button = "BUTTON2"
    elseif button == "MiddleButton" then
		button = "BUTTON3"
	elseif button == "Button4" then
		button = "BUTTON4"
	elseif button == "Button5" then
		button = "BUTTON5"
	end
	Keybinding_OnKeyDown(frame, button)
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local keybinding = AceGUI:Create("Keybinding")
	keybinding.type = Type

	local button = keybinding.button
	button:SetScript("OnClick", Keybinding_OnClick)
	button:SetScript("OnKeyDown", Keybinding_OnKeyDown)
	button:SetScript("OnMouseDown", Keybinding_OnMouseDown)

	local msgframe = keybinding.msgframe
	local msg = msgframe.msg
	msg:SetText(L["CFG_UI_BINDING_SET_TOOLTIP"])

	return keybinding
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

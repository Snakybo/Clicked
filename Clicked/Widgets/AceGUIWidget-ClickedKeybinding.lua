--[[-----------------------------------------------------------------------------
Clicked Keybinding Widget
Set Keybindings in the Config UI.
-------------------------------------------------------------------------------]]

--- @class ClickedKeybinding : AceGUIKeybinding
--- @field public SetMarker fun(marker:boolean)

local Type, Version = "ClickedKeybinding", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function UpdateText(frame)
	local key = frame.key
	local hasMarker = frame.hasMarker
	local button = frame.button

	if (key or "") == "" then
		button:SetText(NOT_BOUND)
		button:SetNormalFontObject("GameFontNormal")
	else
		button:SetText(hasMarker and (key .. "*") or key)
		button:SetNormalFontObject("GameFontHighlight")
	end
end

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
			frame:LockHighlight()
			self.waitingForKey = true
		end
	end
	AceGUI:ClearFocus()
end

local ignoreKeys = {
	["UNKNOWN"] = true,
	["LSHIFT"] = true, ["LCTRL"] = true, ["LALT"] = true, ["LMETA"] = true,
	["RSHIFT"] = true, ["RCTRL"] = true, ["RALT"] = true, ["RMETA"] = true
}

local function Keybinding_OnKeyDown(frame, key)
	local self = frame.obj

	if self.waitingForKey then
		local keyPressed = key

		if keyPressed == "ESCAPE" then
			keyPressed = ""
		else
			if ignoreKeys[keyPressed] then
				return
			end

			if IsMetaKeyDown ~= nil and IsMetaKeyDown() then
				keyPressed = "META-" .. keyPressed
			end

			if IsShiftKeyDown() then
				keyPressed = "SHIFT-" .. keyPressed
			end

			if IsControlKeyDown() then
				keyPressed = "CTRL-" .. keyPressed
			end

			if IsAltKeyDown() then
				keyPressed = "ALT-" .. keyPressed
			end
		end

		frame:EnableKeyboard(false)
		frame:EnableMouseWheel(false)
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
	elseif string.match(button, "Button%d") then
		button = string.upper(button)
	end

	Keybinding_OnKeyDown(frame, button)
end

local function Keybinding_OnMouseWheel(frame, direction)
	local button

	if direction >= 0 then
		button = "MOUSEWHEELUP"
	else
		button = "MOUSEWHEELDOWN"
	end

	Keybinding_OnKeyDown(frame, button)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

local methods = {
	--- @param self ClickedKeybinding
	["OnAcquire"] = function(self)
		self:BaseOnAcquire()
		self.key = ""
		self.hasMarker = false
	end,

	--- @param self ClickedKeybinding
	--- @param key string
	["SetKey"] = function(self, key)
		self.key = key
		UpdateText(self)
	end,

	--- @param self ClickedKeybinding
	--- @return string
	["GetKey"] = function(self)
		return self.key
	end,

	--- @param self ClickedKeybinding
	--- @param marker boolean
	["SetMarker"] = function(self, marker)
		self.hasMarker = marker
		UpdateText(self)
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local widget = AceGUI:Create("Keybinding")
	widget.type = Type

	local button = widget.button
	button:SetScript("OnClick", Keybinding_OnClick)
	button:SetScript("OnKeyDown", Keybinding_OnKeyDown)
	button:SetScript("OnMouseDown", Keybinding_OnMouseDown)
	button:SetScript("OnMouseWheel", Keybinding_OnMouseWheel)

	widget.BaseOnAcquire = widget.OnAcquire

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return widget
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

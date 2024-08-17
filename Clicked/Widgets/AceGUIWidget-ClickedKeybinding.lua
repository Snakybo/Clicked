--[[-----------------------------------------------------------------------------
Clicked Keybinding Widget
Set Keybindings in the Config UI.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedKeybinding"

--- @class ClickedKeybinding : AceGUIKeybinding

--- @class ClickedInternal
local Addon = select(2, ...)

local Type, Version = "ClickedKeybinding", 3
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local ignoreKeys = {
	["UNKNOWN"] = true,
	["LSHIFT"] = true, ["LCTRL"] = true, ["LALT"] = true, ["LMETA"] = true,
	["RSHIFT"] = true, ["RCTRL"] = true, ["RALT"] = true, ["RMETA"] = true,
	["SHIFT"] = true, ["CTRL"] = true, ["ALT"] = true, ["META"] = true
}

--- @param key string
--- @return string?
local function GenerateChord(key)
	if ignoreKeys[key] then
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

local function EnableKeyCapture(frame)
	local self = frame.obj

	frame:EnableKeyboard(true)
	frame:EnableMouseWheel(true)
	frame:LockHighlight()

	self.waitingForKey = true
	self.button:SetText(Addon.L["Press any key or ESC to cancel"])
end

local function DisableKeyCapture(frame)
	local self = frame.obj

	frame:EnableKeyboard(false)
	frame:EnableMouseWheel(false)
	frame:UnlockHighlight()

	self.waitingForKey = nil
	self.lastClickTime = GetTime()
	self:UpdateText()
end

local function SetKey(self, key)
	self:SetKey(key)
	self:Fire("OnKeyChanged", key)
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Keybinding_OnClick(frame, button)
	local self = frame.obj
	local passed = GetTime() - (self.lastClickTime or 0)

	if button == "LeftButton" then
		if not self.waitingForKey and passed > 0.01 then
			EnableKeyCapture(frame)
		end
	elseif button == "RightButton" then
		if not self.waitingForKey and passed > 0.01 then
			SetKey(self, "")
		end
	end

	AceGUI:ClearFocus()
end

local function Keybinding_OnKeyDown(frame, key)
	local self = frame.obj

	if self.waitingForKey then
		if key == "ESCAPE" then
			DisableKeyCapture(frame)
			return
		end

		local chord = GenerateChord(key)

		if chord ~= nil then
			DisableKeyCapture(frame)

			if not self.disabled then
				self:SetKey(chord)
				self:Fire("OnKeyChanged", chord)
			end
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

--- @class ClickedKeybinding
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:BaseOnAcquire()
	self.key = ""
	self.hasMarker = false
end

--- @param key string
function Methods:SetKey(key)
	self.key = key
	self:UpdateText()
end

--- @return string
function Methods:GetKey()
	return self.key
end

--- @param marker boolean
function Methods:SetMarker(marker)
	self.hasMarker = marker
	self:UpdateText()
end

--- @private
function Methods:UpdateText()
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


--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedKeybinding
	local widget = AceGUI:Create("Keybinding")
	widget.type = Type

	local button = widget.button
	button:SetScript("OnClick", Keybinding_OnClick)
	button:SetScript("OnKeyDown", Keybinding_OnKeyDown)
	button:SetScript("OnMouseDown", Keybinding_OnMouseDown)
	button:SetScript("OnMouseWheel", Keybinding_OnMouseWheel)

	--- @private
	widget.BaseOnAcquire = widget.OnAcquire

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

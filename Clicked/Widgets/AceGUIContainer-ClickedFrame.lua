--[[-----------------------------------------------------------------------------
Simple frame widget extension to add support for closing the frame on escape.
-------------------------------------------------------------------------------]]

local Type, Version = "ClickedFrame", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Frame_OnKeyDown(frame, key)
	if key == "ESCAPE" then
		frame:SetPropagateKeyboardInput(false)
		frame:Hide()
	else
		frame:SetPropagateKeyboardInput(true)
	end
end

local function Frame_OnReceiveDrag(frame)
	local self = frame.obj

	self:Fire("OnReceiveDrag")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local function OnAquire(self)
	self:BaseOnAcquire()

	self.frame:SetFrameStrata("HIGH")
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	local widget = AceGUI:Create("Frame")
	widget.type = Type

	local frame = widget.frame
	frame:SetScript("OnKeyDown", Frame_OnKeyDown)
	frame:SetScript("OnReceiveDrag", Frame_OnReceiveDrag)

	widget.BaseOnAcquire = widget.OnAcquire
	widget.OnAcquire = OnAquire

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

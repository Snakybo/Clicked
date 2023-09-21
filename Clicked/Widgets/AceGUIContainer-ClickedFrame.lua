--[[-----------------------------------------------------------------------------
Simple frame widget extension to add support for closing the frame on escape.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedFrame"

local Type, Version = "ClickedFrame", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Frame_OnKeyDown(frame, key)
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

local function Frame_OnReceiveDrag(frame)
	local self = frame.obj

	self:Fire("OnReceiveDrag")
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedFrame : AceGUIFrame
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:BaseOnAcquire()

	self.frame:SetFrameStrata("HIGH")
end

function Methods:MoveToFront()
	self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedFrame
	local widget = AceGUI:Create("Frame")
	widget.type = Type

	local frame = widget.frame
	frame:SetScript("OnKeyDown", Frame_OnKeyDown)
	frame:SetScript("OnReceiveDrag", Frame_OnReceiveDrag)

	--- @private
	widget.BaseOnAcquire = widget.OnAcquire

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

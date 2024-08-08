--[[-----------------------------------------------------------------------------
Simple frame widget extension to add support for closing the frame on escape.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedFrame"

--- @class ClickedFrameStatus : AceGUIFrameStatus
--- @field minWidth? integer
--- @field minHeight? integer

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

	self:SetMinWidth()
	self:SetMinHeight()

	self.frame:SetFrameStrata("HIGH")
end

function Methods:MoveToFront()
	self.frame:SetFrameStrata("FULLSCREEN_DIALOG")
end

--- @param width? integer
function Methods:SetMinWidth(width)
	local status = self.status or self.localstatus
	status.minWidth = width
end

--- @param height? integer
function Methods:SetMinHeight(height)
	local status = self.status or self.localstatus
	status.minHeight = height
end

--- @protected
--- @param width integer
function Methods:OnWidthSet(width)
	local status = self.status or self.localstatus

	if status.minWidth ~= nil then
		width = math.max(width, status.minWidth)
	end

	self:BaseOnWidthSet(width)
end

--- @protected
--- @param height integer
function Methods:OnHeightSet(height)
	local status = self.status or self.localstatus

	if status.minHeight ~= nil then
		height = math.max(height, status.minHeight)
	end

	self:BaseOnHeightSet(height)
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedFrame : AceGUIFrame
	--- @field protected localstatus ClickedFrameStatus
	--- @field protected status? ClickedFrameStatus
	local widget = AceGUI:Create("Frame")
	widget.type = Type

	local frame = widget.frame
	frame:SetScript("OnKeyDown", Frame_OnKeyDown)
	frame:SetScript("OnReceiveDrag", Frame_OnReceiveDrag)

	--- @private
	widget.BaseOnAcquire = widget.OnAcquire

	--- @private
	widget.BaseOnWidthSet = widget.OnWidthSet

	--- @private
	widget.BaseOnHeightSet = widget.OnHeightSet

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

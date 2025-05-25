--[[-----------------------------------------------------------------------------
TabGroup Container
Container that uses tabs on top to switch between groups.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedEditBox"

local Type, Version = "ClickedEditBox", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function ShowButton(self)
	if not self.disablebutton then
		self.button:Show()
		self.editbox:SetTextInsets(0, 20, 3, 3)
	end
end

local function HideButton(self)
	self.button:Hide()
	self.editbox:SetTextInsets(0, 0, 3, 3)
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function EditBox_OnEnterPressed(frame)
	local self = frame.obj
	local cancel = self:Fire("OnEnterPressed", frame:GetText(), self.startText)

	if not cancel then
		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		HideButton(self)
	end
end

local function EditBox_OnReceiveDrag(frame)
	local self = frame.obj
	local type, id, info, extra = GetCursorInfo()
	local name

	if type == "item" then
		name = info
	elseif type == "spell" then
		--- @diagnostic disable-next-line: param-type-mismatch
		name = C_Spell.GetSpellName(extra)
	elseif type == "macro" then
		--- @diagnostic disable-next-line: param-type-mismatch
		name = GetMacroInfo(id)
	end

	if name then
		local startText = frame:GetText()
		self:SetText(name)
		self:Fire("OnEnterPressed", name, startText)
		ClearCursor()
		HideButton(self)
		AceGUI:ClearFocus()
	end
end

local function EditBox_OnTextChanged(frame)
	local self = frame.obj
	local value = frame:GetText()
	if tostring(value) ~= tostring(self.lasttext) then
		self:Fire("OnTextChanged", value, self.lasttext)
		self.lasttext = value
		ShowButton(self)
	end
end

local function EditBox_OnFocusGained(frame)
	local self = frame.obj
	AceGUI:SetFocus(self)
	self.startText = frame:GetText()
end

local function Button_OnClick(frame)
	local editbox = frame.obj.editbox
	editbox:ClearFocus()
	EditBox_OnEnterPressed(editbox)
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedEditBox : AceGUIEditBox
--- @field private startText string
local Methods = {}

function Methods:OnAcquire()
	self:BaseOnAcquire()

	self:SetLabelColor(NORMAL_FONT_COLOR)
end

--- @param text string
function Methods:SetText(text)
	if text ~= self:GetText() then
		local cursor = self.editbox:GetUTF8CursorPosition()
		self:BaseSetText(text)

		if self.editbox:HasFocus() then
			self.editbox:SetCursorPosition(cursor - 1)
		end
	end
end

--- @param color ColorMixin
function Methods:SetLabelColor(color)
	self.label:SetTextColor(color:GetRGBA())
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]

local function Constructor()
	--- @class ClickedEditBox
	local widget = AceGUI:Create("EditBox") --[[@as AceGUIEditBox]]
	widget.type = Type

	widget.editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	widget.editbox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	widget.editbox:SetScript("OnReceiveDrag", EditBox_OnReceiveDrag)
	widget.editbox:SetScript("OnMouseDown", EditBox_OnReceiveDrag)
	widget.editbox:SetScript("OnEditFocusGained", EditBox_OnFocusGained)

	widget.button:SetScript("OnClick", Button_OnClick)

	--- @private
	widget.BaseOnAcquire = widget.OnAcquire

	--- @private
	widget.BaseSetText = widget.SetText

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

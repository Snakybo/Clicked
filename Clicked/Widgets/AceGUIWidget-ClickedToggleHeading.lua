--[[-----------------------------------------------------------------------------
A heading with a checkbox
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedToggleHeading"

--- @class ClickedToggleHeading : AceGUIWidget
--- @field private frame Button
--- @field private label FontString
--- @field private checkbg Texture
--- @field private check Texture
--- @field private highlight Texture
--- @field private left Texture
--- @field private right Texture
--- @field private center Texture

local Type, Version = "ClickedToggleHeading", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function CheckBox_OnMouseDown()
	AceGUI:ClearFocus()
end

local function CheckBox_OnMouseUp(frame)
	local self = frame.obj

	if not self.disabled then
		self:ToggleChecked()

		if self.checked then
			PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		else -- for both nil and false (tristate)
			PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
		end

		self:Fire("OnValueChanged", self.checked)
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedToggleHeading
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:SetHeight(24)
	self:SetText("")
	self:SetValue(false)
	self:SetDisabled(false)
	self:SetLabelColor(NORMAL_FONT_COLOR)
end

--- @param text string
function Methods:SetText(text)
	self.label:SetText(text)

	if text and text ~= "" then
		self.right:Show()
	else
		self.right:Hide()
	end
end

--- @param disabled boolean
function Methods:SetDisabled(disabled)
	self.disabled = disabled

	if disabled then
		self.frame:Disable()
		self.label:SetTextColor(0.5, 0.5, 0.5)

		SetDesaturation(self.check, true)
	else
		self.frame:Enable()
		self.label:SetTextColor(1, 1, 1)

		SetDesaturation(self.check, false)
	end
end

--- @param value boolean
function Methods:SetValue(value)
	local check = self.check

	self.checked = value

	if value then
		SetDesaturation(check, false)
		check:Show()
	else
		SetDesaturation(check, false)
		check:Hide()
	end

	self:SetDisabled(self.disabled)
end

--- @param color ColorMixin
function Methods:SetLabelColor(color)
	self.label:SetTextColor(color:GetRGBA())
end

--- @return boolean
function Methods:GetValue()
	return self.checked
end

function Methods:ToggleChecked()
	self:SetValue(not self:GetValue())
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnMouseDown", CheckBox_OnMouseDown)
	frame:SetScript("OnMouseUp", CheckBox_OnMouseUp)

	local checkbg = frame:CreateTexture(nil, "ARTWORK")
	checkbg:SetWidth(24)
	checkbg:SetHeight(24)
	checkbg:SetPoint("LEFT", 14, -1)
	checkbg:SetTexture(130755) -- Interface\\Buttons\\UI-CheckBox-Up

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("TOP")
	label:SetPoint("BOTTOM")
	label:SetJustifyH("CENTER")
	label:SetHeight(18)

	local check = frame:CreateTexture(nil, "OVERLAY")
	check:SetAllPoints(checkbg)
	check:SetTexture(130751) -- Interface\\Buttons\\UI-CheckBox-Check

	local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetTexture(130753) -- Interface\\Buttons\\UI-CheckBox-Highlight
	highlight:SetBlendMode("ADD")
	highlight:SetAllPoints(checkbg)

	local left = frame:CreateTexture(nil, "BACKGROUND")
	left:SetHeight(8)
	left:SetPoint("LEFT", 3, 0)
	left:SetPoint("RIGHT", checkbg, "LEFT", -3, 0)
	left:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	left:SetTexCoord(0.81, 0.94, 0.5, 1)

	local right = frame:CreateTexture(nil, "BACKGROUND")
	right:SetHeight(8)
	right:SetPoint("RIGHT", -3, 0)
	right:SetPoint("LEFT", label, "RIGHT", 5, 0)
	right:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	right:SetTexCoord(0.81, 0.94, 0.5, 1)

	local center = frame:CreateTexture(nil, "BACKGROUND")
	center:SetHeight(8)
	center:SetPoint("LEFT", checkbg, "RIGHT", 3, 1)
	center:SetPoint("RIGHT", label, "LEFT", -5, 1)
	center:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
	center:SetTexCoord(0.81, 0.94, 0.5, 1)

	local widget = {
		frame      = frame,
		label  = label,
		checkbg   = checkbg,
		check     = check,
		highlight = highlight,
		left      = left,
		right     = right,
		center    = center,
		type       = Type
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

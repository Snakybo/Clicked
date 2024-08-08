--[[-----------------------------------------------------------------------------
InteractiveLabel Widget
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedReorderableLabel"

--- @class ClickedReorderableLabel : AceGUIWidget
--- @field private label FontString
--- @field private image Texture
--- @field private up Button
--- @field private down Button
--- @field private resizing boolean
--- @field private imageShown boolean

local Type, Version = "ClickedReorderableLabel", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

local function Label_OnClick(frame, button)
	frame.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

local function MoveUp_OnClick(frame)
	frame.obj:Fire("OnMoveUp")
	AceGUI:ClearFocus()
end

local function MoveDown_OnClick(frame)
	frame.obj:Fire("OnMoveDown")
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedReorderableLabel
local Methods = {}

--- @protected
function Methods:OnAcquire()
	-- set the flag to stop constant size updates
	self.resizing = true
	-- height is set dynamically by the text and image size
	self:SetWidth(200)
	self:SetText()
	self:SetImage(nil)
	self:SetImageSize(16, 16)
	self:SetColor()
	self:SetFontObject()
	self:SetJustifyH("LEFT")
	self:SetJustifyV("TOP")

	self.resizing = nil
	self:UpdateAnchor()
end

--- @protected
function Methods:OnWidthSet()
	self:UpdateAnchor()
end

--- @param text? string
function Methods:SetText(text)
	self.label:SetText(text)
	self:UpdateAnchor()
end

--- @param r? number
--- @param g? number
--- @param b? number
function Methods:SetColor(r, g, b)
	if not (r and g and b) then
		r, g, b = 1, 1, 1
	end
	self.label:SetVertexColor(r, g, b)
end

--- @param path? string|number
--- @param ... number
function Methods:SetImage(path, ...)
	local image = self.image

	image:SetTexture(path)

	if image:GetTexture() then
		self.imageShown = true
		local n = select("#", ...)
		if n == 4 or n == 8 then
			image:SetTexCoord(...)
		else
			image:SetTexCoord(0, 1, 0, 1)
		end
	else
		self.imageShown = nil
	end

	self:UpdateAnchor()
end

--- @param font any
--- @param height any
--- @param flags any
function Methods:SetFont(font, height, flags)
	self.label:SetFont(font, height, flags)
	self:UpdateAnchor()
end

--- @param font any
function Methods:SetFontObject(font)
	self:SetFont((font or GameFontHighlightSmall):GetFont())
end

--- @param width number
--- @param height number
function Methods:SetImageSize(width, height)
	self.image:SetWidth(width)
	self.image:SetHeight(height)
	self:UpdateAnchor()
end

--- @param justifyH JustifyHorizontal
function Methods:SetJustifyH(justifyH)
	self.label:SetJustifyH(justifyH)
end

--- @param justifyV JustifyVertical
function Methods:SetJustifyV(justifyV)
	self.label:SetJustifyV(justifyV)
end

--- @param enabled boolean
function Methods:SetMoveUpButton(enabled)
	if enabled then
		self.up:Show()
	else
		self.up:Hide()
	end

	self.frame:SetScript("OnUpdate", function()
		self.frame:SetScript("OnUpdate", nil)
		self:UpdateAnchor()
	end)
end

--- @param enabled boolean
function Methods:SetMoveDownButton(enabled)
	if enabled then
		self.down:Show()
	else
		self.down:Hide()
	end

	self.frame:SetScript("OnUpdate", function()
		self.frame:SetScript("OnUpdate", nil)
		self:UpdateAnchor()
	end)
end

--- @private
function Methods:UpdateAnchor()
	if self.resizing then return end
	local frame = self.frame
	local width = frame:GetWidth() or 0
	local image = self.image
	local label = self.label
	local up = self.up
	local down = self.down
	local height

	up:ClearAllPoints()
	down:ClearAllPoints()
	label:ClearAllPoints()
	image:ClearAllPoints()

	if self.imageShown then
		local imagewidth = image:GetWidth()

		image:SetPoint("TOPLEFT", 12, 0)
		label:SetPoint("TOPLEFT", image, "TOPRIGHT", 4, 0)

		up:SetPoint("LEFT", label, "RIGHT")

		if up:IsShown() then
			down:SetPoint("LEFT", up, "RIGHT", 4, 0)
		else
			down:SetPoint("LEFT", label, "RIGHT")
		end

		label:SetWidth(width - imagewidth - 52)
		height = math.max(image:GetHeight(), label:GetStringHeight())
	else
		height = label:GetStringHeight()
		label:SetWidth(width)
	end

	-- avoid zero-height labels, since they can used as spacers
	if not height or height == 0 then
		height = 1
	end

	self.resizing = true
	frame:SetHeight(height)
	frame.height = height --- @diagnostic disable-line: inject-field
	self.resizing = nil
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", Label_OnClick)

	local up = CreateFrame("Button", nil, frame)
	up:SetSize(16, 16)
	up:SetScript("OnClick", MoveUp_OnClick)

	local upImage = up:CreateTexture(nil, "BACKGROUND")
	upImage:SetSize(16, 16)
	upImage:SetPoint("CENTER")
	upImage:SetTexture([[Interface\Addons\Clicked\Media\Textures\ui_arrow_up.tga]])

	local down = CreateFrame("Button", nil, frame)
	down:SetSize(16, 16)
	down:SetScript("OnClick", MoveDown_OnClick)

	local downImage = down:CreateTexture(nil, "BACKGROUND")
	downImage:SetSize(16, 16)
	downImage:SetPoint("CENTER")
	downImage:SetTexture([[Interface\Addons\Clicked\Media\Textures\ui_arrow_down.tga]])

	local image = frame:CreateTexture(nil, "BACKGROUND")

	local label = frame:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")

	local widget = {
		label = label,
		image = image,
		up = up,
		down = down,
		frame = frame,
		type = Type
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	up.obj = widget
	down.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

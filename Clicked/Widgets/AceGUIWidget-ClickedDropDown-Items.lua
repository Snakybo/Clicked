--- @class ClickedInternal
local Addon = select(2, ...)

local AceGUI = LibStub("AceGUI-3.0")
local IBLib = LibStub("AceGUI-3.0-DropDown-ItemBase") --[[@as AceGUI-3.0-DropDown-ItemBase]]

do
	--- @class ClickedToggleDropdownItem : AceGUIDropdownItemBase, AceGUIWidget
	--- @field private icon Texture

	local widgetType = "Clicked-Dropdown-Item-Toggle-Icon"
	local widgetVersion = 1

	local ICON_SIZE = 12
	local ICON_MARGIN = 4

	local function Frame_OnClick(frame)
		local self = frame.obj

		if self.disabled then
			return
		end

		self.value = not self.value

		if self.value then
			PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		else
			PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
		end

		self:UpdateToggle()
		self:Fire("OnValueChanged", self.value)
	end

	--- @class ClickedToggleDropdownItem
	local Methods = {}

	--- @private
	function Methods:UpdateToggle()
		if self.value then
			self.check:Show()
		else
			self.check:Hide()
		end
	end

	--- @protected
	function Methods:OnRelease()
		IBLib:GetItemBase().OnRelease(self)
		self:SetValue(nil)
	end

	--- @param text string
	function Methods:SetText(text)
		local i = Addon:GetDataFromString(text, "icon")
		local t = Addon:GetDataFromString(text, "text")

		if text ~= nil and #text > 0 and t == nil then
			t = text
		end

		--- @diagnostic disable-next-line: param-type-mismatch
		self.icon:SetTexture(i)
		self.text:SetText(t)

		if i ~= nil then
			self.text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 18 + ICON_SIZE + ICON_MARGIN, 0)
		else
			self.text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 18, 0)
		end
	end

	--- @param value any
	function Methods:SetValue(value)
		self.value = value
		self:UpdateToggle()
	end

	--- @return any
	function Methods:GetValue()
		return self.value
	end

	local function Constructor()
		--- @class ClickedToggleDropdownItem
		local widget = IBLib:GetItemBase().Create(widgetType)
		local frame = widget.frame

		widget.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 18 + ICON_SIZE + ICON_MARGIN, 0)
		widget.highlight:SetPoint("LEFT", frame, "LEFT", 5 + ICON_SIZE + ICON_MARGIN)

		local icon = frame:CreateTexture(nil, "OVERLAY")
		icon:SetWidth(ICON_SIZE)
		icon:SetHeight(ICON_SIZE)
		icon:SetPoint("LEFT", frame, "LEFT", 3 + widget.check:GetWidth(), 0)
		widget.icon = icon

		widget.frame:SetScript("OnClick", Frame_OnClick)

		for method, func in pairs(Methods) do
			widget[method] = func
		end

		AceGUI:RegisterAsWidget(widget)
		return widget
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion + IBLib:GetItemBase().version)
end

do
	--- @class ClickedBlackListDropdownItem : AceGUIDropdownItemBase, AceGUIWidget
	--- @field private left Texture
	--- @field private right Texture

	local widgetType = "Clicked-Blacklist-Dropdown-Item"
	local widgetVersion = 1

	local function Frame_OnClick(frame)
		local self = frame.obj

		if self.disabled then
			return
		end

		self.value = not self.value

		if self.value then
			PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		else
			PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
		end

		self:UpdateToggle()
		self:Fire("OnValueChanged", self.value)
	end

	--- @class ClickedBlackListDropdownItem
	local Methods = {}

	--- @private
	function Methods:UpdateToggle()
		if self.value then
			self.check:Show()
		else
			self.check:Hide()
		end
	end

	--- @protected
	function Methods:OnRelease()
		IBLib:GetItemBase().OnRelease(self)
		self:SetValue(nil)
	end

	--- @param disabled boolean
	function Methods:SetDisabled(disabled)
		IBLib:GetItemBase().SetDisabled(self, disabled)
		self.useHighlight = not self.isHeader
	end

	--- @param text string
	function Methods:SetText(text)
		if type(text) == "string" then
			if string.sub(text, 1, 2) == "s|" then
				self.isHeader = true
				text = string.sub(text, 3)
			else
				self.isHeader = false
			end
		end

		IBLib:GetItemBase().SetText(self, text)

		if self.isHeader then
			self.useHighlight = false

			self.text:ClearAllPoints()
			self.text:SetPoint("TOP")
			self.text:SetPoint("BOTTOM")
			self.text:SetJustifyH("CENTER")

			self.left:SetPoint("RIGHT", self.text, "LEFT", -10, 0)
			self.left:Show()

			self.right:SetPoint("LEFT", self.text, "RIGHT", 10, 0)
			self.right:Show()

			self.frame:SetScript("OnClick", nil)
		else
			self.useHighlight = true

			self.text:ClearAllPoints()
			self.text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 18, 0)
			self.text:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -8, 0)
			self.text:SetJustifyH("LEFT")

			self.left:Hide()
			self.right:Hide()

			self.frame:SetScript("OnClick", Frame_OnClick)
		end
	end

	--- @param value any
	function Methods:SetValue(value)
		self.value = value
		self:UpdateToggle()
	end

	--- @return any
	function Methods:GetValue()
		return self.value
	end

	local function Constructor()
		--- @class ClickedBlackListDropdownItem
		--- @diagnostic disable-next-line: undefined-field
		local widget = IBLib:GetItemBase().Create(widgetType)

		widget.left = widget.frame:CreateTexture(nil, "OVERLAY")
		widget.left:SetHeight(1)
		widget.left:SetColorTexture(.5, .5, .5)
		widget.left:SetPoint("LEFT", widget.frame, "LEFT", 10, 0)
		widget.left:SetPoint("RIGHT", widget.text, "LEFT", -10, 0)
		widget.left:Hide()

		widget.right = widget.frame:CreateTexture(nil, "OVERLAY")
		widget.right:SetHeight(1)
		widget.right:SetColorTexture(.5, .5, .5)
		widget.right:SetPoint("LEFT", widget.text, "RIGHT", 10, 0)
		widget.right:SetPoint("RIGHT", widget.frame, "RIGHT", -10, 0)
		widget.right:Hide()

		for method, func in pairs(Methods) do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion + IBLib:GetItemBase().version)
end

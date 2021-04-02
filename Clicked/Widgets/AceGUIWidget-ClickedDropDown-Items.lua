--- @type ClickedInternal
local _, Addon = ...

local AceGUI = LibStub("AceGUI-3.0")
local IBLib = LibStub("AceGUI-3.0-DropDown-ItemBase")

do
	local widgetType = "Clicked-Dropdown-Item-Toggle-Icon"
	local widgetVersion = 1

	local ICON_SIZE = 12
	local ICON_MARGIN = 4

	local function UpdateToggle(self)
		if self.value then
			self.check:Show()
		else
			self.check:Hide()
		end
	end

	local function OnRelease(self)
		IBLib:GetItemBase().OnRelease(self)
		self:SetValue(nil)
	end

	local function Frame_OnClick(this)
		local self = this.obj
		if self.disabled then return end
		self.value = not self.value
		if self.value then
			PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		else
			PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
		end
		UpdateToggle(self)
		self:Fire("OnValueChanged", self.value)
	end

	-- exported
	local function SetText(self, text)
		local i = Addon:GetDataFromString(text, "icon")
		local t = Addon:GetDataFromString(text, "text")

		if text ~= nil and #text > 0 and t == nil then
			t = text
		end

		self.icon:SetTexture(i)
		self.text:SetText(t)

		if i ~= nil then
			self.text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 18 + ICON_SIZE + ICON_MARGIN, 0)
		else
			self.text:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 18, 0)
		end
	end

	-- exported
	local function SetValue(self, value)
		self.value = value
		UpdateToggle(self)
	end

	-- exported
	local function GetValue(self)
		return self.value
	end

	local function Constructor()
		local self = IBLib:GetItemBase().Create(widgetType)
		local frame = self.frame

		self.text:SetPoint("TOPLEFT", frame, "TOPLEFT", 18 + ICON_SIZE + ICON_MARGIN, 0)
		self.highlight:SetPoint("LEFT", frame, "LEFT", 5 + ICON_SIZE + ICON_MARGIN)

		local icon = frame:CreateTexture("OVERLAY")
		icon:SetWidth(ICON_SIZE)
		icon:SetHeight(ICON_SIZE)
		icon:SetPoint("LEFT", frame, "LEFT", 3 + self.check:GetWidth(), 0)
		self.icon = icon

		self.frame:SetScript("OnClick", Frame_OnClick)

		self.SetText = SetText
		self.SetValue = SetValue
		self.GetValue = GetValue
		self.OnRelease = OnRelease

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion + IBLib:GetItemBase().version)
end

do
	local widgetType = "Clicked-Blacklist-Dropdown-Item"
	local widgetVersion = 1

	local function UpdateToggle(self)
		if self.value then
			self.check:Show()
		else
			self.check:Hide()
		end
	end

	local function OnRelease(self)
		IBLib:GetItemBase().OnRelease(self)
		self:SetValue(nil)
	end

	-- exported, override
	local function SetDisabled(self, disabled)
		IBLib:GetItemBase().SetDisabled(self, disabled)
		self.useHighlight = not self.isHeader
	end

	local function Frame_OnClick(this)
		local self = this.obj
		if self.disabled then return end
		self.value = not self.value
		if self.value then
			PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		else
			PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
		end
		UpdateToggle(self)
		self:Fire("OnValueChanged", self.value)
	end

	local function SetText(self, text)
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

	-- exported
	local function SetValue(self, value)
		self.value = value
		UpdateToggle(self)
	end

	-- exported
	local function GetValue(self)
		return self.value
	end

	local function Constructor()
		local self = IBLib:GetItemBase().Create(widgetType)

		self.left = self.frame:CreateTexture(nil, "OVERLAY")
		self.left:SetHeight(1)
		self.left:SetColorTexture(.5, .5, .5)
		self.left:SetPoint("LEFT", self.frame, "LEFT", 10, 0)
		self.left:SetPoint("RIGHT", self.text, "LEFT", -10, 0)
		self.left:Hide()

		self.right = self.frame:CreateTexture(nil, "OVERLAY")
		self.right:SetHeight(1)
		self.right:SetColorTexture(.5, .5, .5)
		self.right:SetPoint("LEFT", self.text, "RIGHT", 10, 0)
		self.right:SetPoint("RIGHT", self.frame, "RIGHT", -10, 0)
		self.right:Hide()

		self.SetText = SetText
		self.SetValue = SetValue
		self.GetValue = GetValue
		self.OnRelease = OnRelease
		self.SetDisabled = SetDisabled

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion + IBLib:GetItemBase().version)
end

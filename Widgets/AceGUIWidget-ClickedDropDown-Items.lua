local AceGUI = LibStub("AceGUI-3.0")
local IBLib = LibStub("AceGUI-3.0-DropDown-ItemBase")

do
	local widgetType = "Dropdown-Item-Toggle-Icon"
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

	local function Frame_OnClick(this, button)
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
	local function SetValue(self, value)
		self.value = value
		UpdateToggle(self)
	end

	-- exported
	local function GetValue(self)
		return self.value
	end

	local function Constructor()
		local ICON_SIZE = 12
		local ICON_MARGIN = 4

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

		self.SetValue = SetValue
		self.GetValue = GetValue
		self.OnRelease = OnRelease

		AceGUI:RegisterAsWidget(self)
		return self
	end

	AceGUI:RegisterWidgetType(widgetType, Constructor, widgetVersion + IBLib:GetItemBase().version)
end
-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local AceGUI = LibStub("AceGUI-3.0")
local IBLib = LibStub("AceGUI-3.0-DropDown-ItemBase")

--- @class AceGUIDropdownItemBase : AceGUIWidget
--- @field public frame Button&{obj: self}
--- @field protected check Texture
--- @field protected text FontString
--- @field protected highlight Texture
--- @field protected sub Texture
--- @field protected pullout AceGUIWidget?
--- @field protected disabled boolean
--- @field protected useHighlight boolean
--- @field protected specialOnEnter boolean
--- @field protected specialOnLeave boolean
--- @field public SetText fun(self: self, text: string)
--- @field public GetText fun(self: self): string
--- @field public SetDisabled fun(self: self, disabled: boolean)
--- @field public SetPoint fun(self: self, ...: any)
--- @field public Show fun(self: self)
--- @field public Hide fun(self: self)

do
	local TYPE, VERSION = "Clicked-Blacklist-Dropdown-Item", 2

	--- @class ClickedBlackListDropdownItem : AceGUIDropdownItemBase
	--- @field protected left Texture
	--- @field protected right Texture
	--- @field protected isHeader boolean
	--- @field protected value boolean?
	local ClickedBlackListDropdownItem = {}

	--- @protected
	function ClickedBlackListDropdownItem:UpdateToggle()
		if self.value then
			self.check:Show()
		else
			self.check:Hide()
		end
	end

	--- @protected
	function ClickedBlackListDropdownItem:OnRelease()
		IBLib:GetItemBase().OnRelease(self)
		self:SetValue(nil)
	end

	--- @param disabled boolean
	function ClickedBlackListDropdownItem:SetDisabled(disabled)
		IBLib:GetItemBase().SetDisabled(self, disabled)
		self.useHighlight = not self.isHeader
	end

	--- @param text string
	function ClickedBlackListDropdownItem:SetText(text)
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

			self.frame:SetScript("OnClick", ClickedBlackListDropdownItem.Frame_OnClick)
		end
	end

	--- @param value boolean?
	function ClickedBlackListDropdownItem:SetValue(value)
		self.value = value
		self:UpdateToggle()
	end

	--- @return boolean?
	function ClickedBlackListDropdownItem:GetValue()
		return self.value
	end

	--- @protected
	--- @param frame Button&{obj: ClickedBlackListDropdownItem}
	function ClickedBlackListDropdownItem.Frame_OnClick(frame)
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

	local function Constructor()
		--- @class ClickedBlackListDropdownItem
		local widget = IBLib:GetItemBase().Create(TYPE)

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

		for method, func in pairs(ClickedBlackListDropdownItem) do
			widget[method] = func
		end

		return AceGUI:RegisterAsWidget(widget)
	end

	AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION + IBLib:GetItemBase().version)
end

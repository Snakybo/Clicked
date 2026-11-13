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

--[[-----------------------------------------------------------------------------
An extension of the standard AceGUI editbox widget with additional functionality
related to drag-and-drop.
-------------------------------------------------------------------------------]]

local TYPE, VERSION = "ClickedEditBox", 3
local AceGUI = LibStub("AceGUI-3.0")

if (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

--- @alias AceGUIWidgetType
--- | "ClickedEditBox"

--- @class ClickedEditBox : AceGUIEditBox
--- @field public frame Frame&{obj: self}
--- @field public type string
--- @field protected editbox EditBox&InputBoxTemplate&{obj: self}
--- @field protected label FontString
--- @field protected button Button&UIPanelButtonTemplate&{obj: self}
--- @field protected startText string
--- @field protected lasttext string
--- @field private EditBoxOnAcquire fun(self: AceGUIEditBox)
--- @field private EditBoxSetText fun(self: AceGUIEditBox, text: string)
local ClickedEditBox = {}

function ClickedEditBox:OnAcquire()
	self:EditBoxOnAcquire()

	self:SetLabelColor(NORMAL_FONT_COLOR)
end

--- @param text string
function ClickedEditBox:SetText(text)
	if text ~= self:GetText() then
		local cursor = self.editbox:GetUTF8CursorPosition()
		self:EditBoxSetText(text)

		if self.editbox:HasFocus() then
			self.editbox:SetCursorPosition(cursor - 1)
		end
	end
end

--- @param color ColorMixin
function ClickedEditBox:SetLabelColor(color)
	self.label:SetTextColor(color:GetRGBA())
end

--- @protected
function ClickedEditBox:ShowButton()
	if not self.disablebutton then
		self.button:Show()
		self.editbox:SetTextInsets(0, 20, 3, 3)
	end
end

--- @protected
function ClickedEditBox:HideButton()
	self.button:Hide()
	self.editbox:SetTextInsets(0, 0, 3, 3)
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedEditBox}
function ClickedEditBox.EditBox_OnEnterPressed(frame)
	local self = frame.obj
	local cancel = self:Fire("OnEnterPressed", frame:GetText(), self.startText) --[[@as boolean]]

	if not cancel then
		PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
		self:HideButton()
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedEditBox}
function ClickedEditBox.EditBox_OnReceiveDrag(frame)
	local self = frame.obj
	local infoType = GetCursorInfo()
	local name

	if infoType == "item" then
		local _, itemId = GetCursorInfo()
		name = C_Item.GetItemNameByID(itemId)
	elseif infoType == "spell" then
		local _, _, _, spellId = GetCursorInfo()
		name = C_Spell.GetSpellName(spellId --[[@as integer]])
	elseif infoType == "macro" then
		local _, index = GetCursorInfo()
		name = GetMacroInfo(index)
	end

	if name then
		local startText = frame:GetText()
		self:SetText(name)
		self:Fire("OnEnterPressed", name, startText)
		ClearCursor()
		self:HideButton()
		AceGUI:ClearFocus()
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedEditBox}
function ClickedEditBox.EditBox_OnTextChanged(frame)
	local self = frame.obj
	local value = frame:GetText()
	if tostring(value) ~= tostring(self.lasttext) then
		self:Fire("OnTextChanged", value, self.lasttext)
		self.lasttext = value
		self:ShowButton()
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedEditBox}
function ClickedEditBox.EditBox_OnFocusGained(frame)
	local self = frame.obj
	AceGUI:SetFocus(self)
	self.startText = frame:GetText()
end

--- @protected
--- @param frame Button&{obj: ClickedEditBox}
function ClickedEditBox.Button_OnClick(frame)
	local editbox = frame.obj.editbox
	editbox:ClearFocus()
	ClickedEditBox.EditBox_OnEnterPressed(editbox)
end

--- @return ClickedEditBox
local function Constructor()
	--- @class ClickedEditBox
	local widget = AceGUI:Create("EditBox")
	widget.type = TYPE
	widget.EditBoxOnAcquire = widget.OnAcquire
	widget.EditBoxSetText = widget.SetText

	widget.editbox:SetScript("OnEnterPressed", ClickedEditBox.EditBox_OnEnterPressed)
	widget.editbox:SetScript("OnTextChanged", ClickedEditBox.EditBox_OnTextChanged)
	widget.editbox:SetScript("OnReceiveDrag", ClickedEditBox.EditBox_OnReceiveDrag)
	widget.editbox:SetScript("OnMouseDown", ClickedEditBox.EditBox_OnReceiveDrag)
	widget.editbox:SetScript("OnEditFocusGained", ClickedEditBox.EditBox_OnFocusGained)

	widget.button:SetScript("OnClick", ClickedEditBox.Button_OnClick)

	for method, func in pairs(ClickedEditBox) do
		widget[method] = func
	end

	--- TEMP: This cast can be removed once https://github.com/TradeSkillMaster/wowlua-ls/pull/65 is merged
	return AceGUI:RegisterAsWidget(widget) --[[@as ClickedEditBox]]
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

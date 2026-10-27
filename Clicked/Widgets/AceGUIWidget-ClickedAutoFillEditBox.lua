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
A simple edit box with auto-fill and text completion capabilities.
-------------------------------------------------------------------------------]]

-- Deprecated in 11.0.0
local GetSpellBookItemName = C_SpellBook.GetSpellBookItemName or GetSpellBookItemName

--- @class Addon
local Addon = select(2, ...)

local TYPE, VERSION = "ClickedAutoFillEditBox", 2
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(TYPE) or 0) >= VERSION then
	return
end

local ATTACH_ABOVE = "above"
local ATTACH_BELOW = "below"

--- @alias AceGUIWidgetType
--- | "ClickedAutoFillEditBox"

--- @class ClickedAutoFillEditBox.Option
--- @field public prefix string?
--- @field public text string
--- @field public icon integer
--- @field public spellId integer?
--- @field public custom boolean?

--- @class ClickedAutoFillEditBox.Match : ClickedAutoFillEditBox.Option
--- @field public score number

--- @class ClickedAutoFillEditBox.Button : Button
--- @field public icon Texture
--- @field public obj ClickedAutoFillEditBox.Match

--- @class ClickedAutoFillEditBox : AceGUIEditBox
--- @field public frame Frame&{obj: self}
--- @field protected editbox EditBox&InputBoxTemplate&{obj: self}
--- @field protected values ClickedAutoFillEditBox.Option[]
--- @field protected lasttext string
--- @field protected tempValue integer?
--- @field protected buttons ClickedAutoFillEditBox.Button[]
--- @field protected selected integer
--- @field protected selectedOption ClickedAutoFillEditBox.Option?
--- @field protected matches ClickedAutoFillEditBox.Match[]
--- @field protected numButtons integer
--- @field protected offset integer
--- @field protected highlight boolean
--- @field protected isInputError boolean
--- @field protected isShowingAll boolean
--- @field protected strict boolean
--- @field protected pullout Frame
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self:EditBoxOnAcquire()

	self.values = {}
	self.tempValue = nil
	self.matches = {}
	self.selected = 1
	self.selectedOption = nil
	self.numButtons = 10
	self.offset = 0
	self.highlight = true
	self.strict = true
	self.isInputError = false
	self.isShowingAll = false

	self.pullout:SetParent(UIParent)
	self.pullout:SetFrameLevel(self.frame:GetFrameLevel() + 1)
	self.pullout:Hide()

	self:SetLabelColor(NORMAL_FONT_COLOR)
	self:DisableButton(true)
end

--- @protected
function Methods:OnRelease()
	self:EditBoxOnRelease()
	self:HideAutoCompleteBox()
end

--- @param values ClickedAutoFillEditBox.Option[]
function Methods:SetValues(values)
	self.values = CopyTable(values)

	if self:IsAutoCompleteBoxVisible() then
		self:ShowPrediction()
	end
end

--- @param value ClickedAutoFillEditBox.Option
--- @param showPrediction? boolean
function Methods:SetTemporaryValue(value, showPrediction)
	if self.tempValue ~= nil then
		self.values[self.tempValue] = value
	else
		table.insert(self.values, value)
		self.tempValue = #self.values
	end

	if showPrediction and self:IsAutoCompleteBoxVisible() then
		self:ShowPrediction()
	end
end

--- @param showPrediction? boolean
function Methods:ClearTemporaryValue(showPrediction)
	if self.tempValue ~= nil then
		table.remove(self.values, self.tempValue)
		self.tempValue = nil
	end

	if showPrediction and self:IsAutoCompleteBoxVisible() then
		self:ShowPrediction()
	end
end

--- @return ClickedAutoFillEditBox.Option[]
function Methods:GetValues()
	return self.values
end

--- @param count integer
function Methods:SetMaxVisibleValues(count)
	self.numButtons = count
	self:ShowPrediction()
end

--- @return integer
function Methods:GetMaxVisibleValues()
	return self.numButtons
end

--- @param enabled boolean
function Methods:SetTextHighlight(enabled)
	self.highlight = enabled
	self:UpdateHighlight()
end

--- @return boolean
function Methods:HasTextHighlight()
	return self.highlight
end

--- @param index integer
function Methods:SetSelectedIndex(index)
	if index < self:GetFirstVisibleButtonIndex() or index > self:GetLastVisibleButtonIndex() then
		return
	end

	self.selected = index
	self:UpdateHighlight()
end

--- @return integer
function Methods:GetSelectedIndex()
	return self.selected
end

--- @param isInputError boolean
function Methods:SetInputError(isInputError)
	self.isInputError = isInputError
	self:SetText(self:GetText())
end

--- @return boolean
function Methods:IsInputError()
	return self.isInputError
end

function Methods:ClearFocus()
	self.editbox:ClearFocus()
end

--- @param width integer
function Methods:OnWidthSet(width)
	self.pullout:SetWidth(width)
end

--- @param text string
function Methods:SetText(text)
	if self:IsInputError() and text ~= nil then
		text = "|cffff1a1a" .. text .. "|r"
	end

	self:EditBoxSetText(text)
end

--- @param strict boolean
function Methods:SetStrictMode(strict)
	self.strict = strict
end

--- @protected
--- @return ClickedAutoFillEditBox.Button
function Methods:CreateButton()
	local type = TYPE .. "Button"
	local num = AceGUI:GetNextWidgetNum(type)

	local button = CreateFrame("Button", type .. num, self.pullout, "AutoCompleteButtonTemplate") --[[@as ClickedAutoFillEditBox.Button]]
	button:EnableMouse(true)

	local icon = button:CreateTexture(nil, "OVERLAY")
	icon:SetPoint("LEFT", 12, 1)
	icon:SetSize(12, 12)
	button.icon = icon

	button:GetFontString():SetPoint("LEFT", 28, 0)
	button:GetFontString():SetWidth(self.pullout:GetWidth() - 40)
	button:GetFontString():SetJustifyH("LEFT")
	button:GetFontString():SetHeight(14)

	button:SetScript("OnClick", function()
		self:HideAutoCompleteBox()
		self:SelectButton(button)
	end)

	button:SetScript("OnEnter",function()
		for i, current in ipairs(self.buttons) do
			if button == current then
				self:SetSelectedIndex(i)
				break
			end
		end
	end)

	return button
end

--- @protected
function Methods:UpdateButtons()
	local function CreateMoreButton(index)
		local button = self.buttons[index]

		button:SetText("...")
		button:Disable()

		button.icon:SetTexture(nil)
	end

	local matches = self:GetMatches()
	local count = math.min(self:GetMaxVisibleValues(), #matches)
	local nextButton = 1

	if self:GetOffset() > 0 then
		CreateMoreButton(1)
		nextButton = nextButton + 1
	end

	for i = 1, count do
		local button = self.buttons[nextButton]
		local matchIndex = self:GetOffset() + i

		if button == nil then
			button = self:CreateButton()

			self.buttons[nextButton] = button
			button:SetParent(self.pullout)
			button:SetFrameLevel(self.pullout:GetFrameLevel() + 1)
			button:ClearAllPoints()

			if i == 1 then
				button:SetPoint("TOPRIGHT", 0, -10)
				button:SetPoint("TOPLEFT", 0, -10)
			else
				button:SetPoint("TOPRIGHT", self.buttons[nextButton - 1], "BOTTOMRIGHT", 0, 0)
				button:SetPoint("TOPLEFT", self.buttons[nextButton - 1], "BOTTOMLEFT", 0, 0)
			end
		end

		button.obj = matches[matchIndex]
		local text = matches[matchIndex].text
		local prefix = matches[matchIndex].prefix

		if prefix ~= nil then
			text = text .. " (" .. prefix .. ")"
		end

--@debug@
		if not self.isShowingAll then
			text = "[" .. string.format("%.2f", matches[matchIndex].score) .. "] " .. text
		end
--@end-debug@

		button:SetText(text)

		button.icon:SetTexture(matches[matchIndex].icon)
		button.icon:SetTexCoord(0, 1, 0, 1)

		button:Enable()
		button:Show()

		nextButton = nextButton + 1
	end

	for i = count + 1, #self.buttons do
		self.buttons[i]:Hide()
	end

	if #matches > self:GetOffset() + self:GetMaxVisibleValues() then
		CreateMoreButton(self:GetMaxVisibleValues())
	end
end

--- @protected
--- @param button? ClickedAutoFillEditBox.Button
function Methods:SelectButton(button)
	if button == nil then
		return
	end

	self:Select(button.obj)
end

--- @protected
function Methods:HideAutoCompleteBox()
	if not self:IsAutoCompleteBoxVisible() then
		return
	end

	self.pullout:ClearAllPoints()
	self.pullout:Hide()
	self.pullout.attachTo = nil
end

--- @protected
--- @param height integer
--- @return string
function Methods:FindAttachmentPoint(height)
	if self.frame:GetBottom() - height <= AUTOCOMPLETE_DEFAULT_Y_OFFSET + 10 then
		return ATTACH_ABOVE
	end

	return ATTACH_BELOW
end

--- @protected
function Methods:ShowPrediction()
	local text =  self:GetText()

	if strlenutf8(text) == 0 then
		self:HideAutoCompleteBox()
		return
	end

	if self.editbox:GetUTF8CursorPosition() > strlenutf8(text) then
		self:HideAutoCompleteBox()
		return
	end

	if tonumber(text) ~= nil then
		self:HideAutoCompleteBox()

		for _, value in ipairs(self:GetValues()) do
			if value.spellId ~= nil and value.spellId == tonumber(text) then
				self:Select(value)
				break
			end
		end
	else
		local options = self:GetValues()

		-- if not self.strict then
		-- 	if options[#options].custom then
		-- 		options[#options].text = text
		-- 	else
		-- 		table.insert(options, {
		-- 			text = text,
		-- 			icon = "inv_misc_questionmark",
		-- 			custom = true
		-- 		})
		-- 	end
		-- end

		local matches = self:FindMatches(text, options)

		if #matches > 0 then
			self.isShowingAll = false
			self:SetMatches(matches)
			self:ShowPullout()
		else
			self:ShowAll()
		end
	end
end

--- @protected
function Methods:ShowAll()
	if #self:GetValues() == 0 then
		return
	end

	--- @type ClickedAutoFillEditBox.Match[]
	local matches = {}

	for _, value in ipairs(self:GetValues()) do
		--- @cast value ClickedAutoFillEditBox.Match
		value.score = 0
		table.insert(matches, value)
	end

	--- @param l ClickedAutoFillEditBox.Match
	--- @param r ClickedAutoFillEditBox.Match
	--- @return boolean
	local function SortFunc(l, r)
		return l.text < r.text
	end

	table.sort(matches, SortFunc)

	self.isShowingAll = true
	self:SetMatches(matches)
	self:ShowPullout()
end

--- @protected
function Methods:ShowPullout()
	local matchCount = #self:GetMatches()

	if matchCount == 0 then
		self:HideAutoCompleteBox()
		return
	end

	local buttonHeight = self.buttons[1]:GetHeight()
	local baseHeight = 32

	local height = baseHeight + math.max(buttonHeight * math.min(matchCount, self:GetMaxVisibleValues()), 14)
	local attachTo = self:FindAttachmentPoint(height)
	local pullout = self.pullout

	if pullout.attachTo ~= attachTo then
		if attachTo == ATTACH_ABOVE then
			pullout:ClearAllPoints();
			pullout:SetPoint("BOTTOMLEFT", self.frame, "TOPLEFT")
		elseif attachTo == ATTACH_BELOW then
			pullout:ClearAllPoints();
			pullout:SetPoint("TOPLEFT", self.frame, "BOTTOMLEFT")
		end

		pullout.attachTo = attachTo
	end

	if not self:IsAutoCompleteBoxVisible() then
		self.selected = 1
	end

	pullout:SetHeight(height)
	pullout:Show()
end

--- @protected
function Methods:UpdateHighlight()
	for i = 1, #self.buttons do
		self.buttons[i]:UnlockHighlight()
	end

	if self:HasTextHighlight() and self:GetSelectedButton() ~= nil then
		self:GetSelectedButton():LockHighlight()
	end
end

--- @param value string|ClickedAutoFillEditBox.Option
function Methods:Select(value)
	local option = nil
	local text

	if value == nil then
		text = ""
	elseif type(value) ~= "string" then
		option = value
		text = value.text
	else
		text = value
	end

	self.editbox:SetText(text)
	self.editbox:SetCursorPosition(strlen(text))

	self:Fire("OnSelect", text, option)
	self.selectedOption = value --[[@as ClickedAutoFillEditBox.Option?]]

	AceGUI:ClearFocus()
end

--- @param color ColorMixin
function Methods:SetLabelColor(color)
	self.label:SetTextColor(color:GetRGBA())
end

--- @return string
function Methods:GetText()
	return Addon:StripColorCodes(self:EditBoxGetText())
end

--- @protected
--- @return boolean
function Methods:IsAutoCompleteBoxVisible()
	return self.pullout:IsShown()
end

--- @protected
--- @param matches ClickedAutoFillEditBox.Match[]
function Methods:SetMatches(matches)
	self.matches = matches
	self:SetOffset(0)
end

--- @private
--- @return ClickedAutoFillEditBox.Match[]
function Methods:GetMatches()
	return self.matches
end

--- @protected
--- @param offset integer
function Methods:SetOffset(offset)
	if offset < 0 then
		offset = 0
	elseif offset > math.max(#self:GetMatches() - self:GetMaxVisibleValues(), 0) then
		offset = math.max(#self:GetMatches() - self:GetMaxVisibleValues(), 0)
	end

	self.offset = offset
	self:UpdateButtons()
end

--- @protected
--- @return integer
function Methods:GetOffset()
	return self.offset
end

--- @protected
--- @return integer
function Methods:GetFirstVisibleButtonIndex()
	for i = 1, #self.buttons do
		if self.buttons[i]:IsShown() and self.buttons[i]:IsEnabled() then
			return i
		end
	end

	return 0
end

--- @protected
--- @return integer
function Methods:GetLastVisibleButtonIndex()
	for i = #self.buttons, 1, -1 do
		if self.buttons[i]:IsShown() and self.buttons[i]:IsEnabled() then
			return i
		end
	end

	return 0
end

--- @protected
--- @return ClickedAutoFillEditBox.Button
function Methods:GetSelectedButton()
	local selected = self:GetSelectedIndex()

	if selected > 0 and selected <= self:GetLastVisibleButtonIndex() then
		return self.buttons[selected]
	end

	return self.buttons[self:GetFirstVisibleButtonIndex()]
end

--- @protected
--- @param direction integer
function Methods:MoveCursor(direction)
	if self:IsAutoCompleteBoxVisible() then
		local next = self:GetSelectedIndex() + direction

		if next < self:GetFirstVisibleButtonIndex() then
			self:SetOffset(self:GetOffset() - 1)
		elseif next > self:GetLastVisibleButtonIndex() then
			self:SetOffset(self:GetOffset() + 1)
		else
			self:SetSelectedIndex(next)
		end
	end
end

--- @protected
--- @param input string
--- @param match string
--- @param caseSensitive boolean
--- @return number
function Methods:ScoreMatch(input, match, caseSensitive)
	return 1 - Addon.StringUtils:GetAverageDistance(input, match, caseSensitive)
end

--- Find and sort matches of the input string.
---
--- @protected
--- @param text string
--- @param values ClickedAutoFillEditBox.Option[]
--- @return ClickedAutoFillEditBox.Match[]
function Methods:FindMatches(text, values)
	if text == nil or text == "" or #values == 0 then
		return {}
	end

	--- @type ClickedAutoFillEditBox.Match[]
	local matches = {}

	for _, value in ipairs(values) do
		--- @cast value ClickedAutoFillEditBox.Match
		value.score = self:ScoreMatch(text, value.text, false)
		table.insert(matches, value)
	end

	--- @param l ClickedAutoFillEditBox.Match
	--- @param r ClickedAutoFillEditBox.Match
	--- @return boolean
	local function SortFunc(l, r)
		-- Sort by scores
		if l.score > r.score then
			return true
		end

		if l.score < r.score then
			return false
		end

		-- Sort alphabetically
		return l.text < r.text
	end

	table.sort(matches, SortFunc)

	for i = #matches, 1, -1 do
		if matches[i].score < 0.5 then
			table.remove(matches, i)
		end
	end

	return matches
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedAutoFillEditBox}
function Methods.EditBox_OnTabPressed(frame)
	local self = frame.obj

	self:MoveCursor(IsShiftKeyDown() and -1 or 1)
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedAutoFillEditBox}
--- @param key string
function Methods.EditBox_OnArrowPressed(frame, key)
	local self = frame.obj

	if key == "UP" then
		self:MoveCursor(-1);
	elseif key == "DOWN" then
		self:MoveCursor(1);
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedAutoFillEditBox}
function Methods.EditBox_OnEnterPressed(frame)
	local self = frame.obj

	if self:IsAutoCompleteBoxVisible() then
		self:HideAutoCompleteBox()
		self:SelectButton(self:GetSelectedButton())
	else
		local text = self:GetText()

		if strlenutf8(text) == 0 then
			self:Select("")
		else
			self:Select(self.strict and self.selectedOption or text)
		end
	end

	self.EditBoxOnEnterPressed(frame)
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedAutoFillEditBox}
--- @param userInput boolean
function Methods.EditBox_OnTextChanged(frame, userInput)
	local self = frame.obj

	self.EditBoxOnTextChanged(frame, userInput)

	if userInput then
		self:ShowPrediction()
	end

	self:UpdateHighlight()
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedAutoFillEditBox}
function Methods.EditBox_OnReceiveDrag(frame)
	local self = frame.obj
	local type, id, info = GetCursorInfo()
	local name

	if type == "item" then
		name = info
	elseif type == "spell" then
		--- @cast id number
		name = GetSpellBookItemName(id, Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Player or BOOKTYPE_SPELL)
	elseif type == "petaction" then
		--- @cast id number
		name = GetSpellBookItemName(id, Enum.SpellBookSpellBank and Enum.SpellBookSpellBank.Pet or BOOKTYPE_PET)
	end

	if name then
		self:SetText(tostring(name))
		self:Fire("OnEnterPressed", name)
		ClearCursor()
		AceGUI:ClearFocus()
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedAutoFillEditBox}
function Methods.EditBox_OnEscapePressed(frame)
	local self = frame.obj

	self:SetText(self.selectedOption ~= nil and self.selectedOption.text or "")
	AceGUI:ClearFocus()
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedAutoFillEditBox}
--- @param text string
function Methods.EditBox_OnChar(frame, text)
	local self = frame.obj

	if IsLeftShiftKeyDown() and text == " " then
		frame:SetText(self.lasttext)
		self:ShowAll()
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedAutoFillEditBox}
function Methods.EditBox_OnFocusGained(frame)
	local self = frame.obj

	self.EditBoxOnFocusGained(frame)

	if strlenutf8(self:GetText()) == 0 then
		self:ShowAll()
	else
		self:ShowPrediction()
	end
end

--- @protected
--- @param frame EditBox&InputBoxTemplate&{obj: ClickedAutoFillEditBox}
function Methods.EditBox_OnFocusLost(frame)
	local self = frame.obj

	if strlenutf8(self:GetText()) == 0 then
		self:SetText("")
	elseif self:IsAutoCompleteBoxVisible() then
		self:SetText(self.selectedOption ~= nil and self.selectedOption.text or "")
	end

	local function CloseWhenAble()
		if not IsMouseButtonDown("LeftButton") then
			self:HideAutoCompleteBox()
			return
		end

		C_Timer.After(0.01, CloseWhenAble)
	end

	CloseWhenAble()
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	--- @class ClickedAutoFillEditBox
	local widget = AceGUI:Create("EditBox")
	widget.type = TYPE

	widget.values = {}
	widget.matches = {}
	widget.buttons = {}
	widget.selected = 1
	widget.selectedOption = nil
	widget.numButtons = 10
	widget.offset = 0
	widget.highlight = true
	widget.strict = true
	widget.isInputError = false
	widget.isShowingAll = false

	--- @private
	widget.EditBoxOnAcquire = widget.OnAcquire
	--- @private
	widget.EditBoxOnRelease = widget.OnRelease
	--- @private
	widget.EditBoxSetText = widget.SetText
	--- @private
	widget.EditBoxGetText = widget.GetText
	--- @private
	widget.EditBoxOnFocusGained = widget.editbox:GetScript("OnEditFocusGained")
	--- @private
	widget.EditBoxOnEnterPressed = widget.editbox:GetScript("OnEnterPressed")
	--- @private
	widget.EditBoxOnTextChanged = widget.editbox:GetScript("OnTextChanged")

	widget.editbox:SetScript("OnTabPressed",  Methods.EditBox_OnTabPressed)
	widget.editbox:SetScript("OnEnterPressed", Methods.EditBox_OnEnterPressed)
	widget.editbox:SetScript("OnTextChanged", Methods.EditBox_OnTextChanged)
	widget.editbox:SetScript("OnReceiveDrag", Methods.EditBox_OnReceiveDrag)
	widget.editbox:SetScript("OnEscapePressed", Methods.EditBox_OnEscapePressed)
	widget.editbox:SetScript("OnArrowPressed", Methods.EditBox_OnArrowPressed)
	widget.editbox:SetScript("OnChar", Methods.EditBox_OnChar)
	widget.editbox:SetScript("OnEditFocusGained", Methods.EditBox_OnFocusGained)
	widget.editbox:SetScript("OnEditFocusLost", Methods.EditBox_OnFocusLost)
	widget.editbox:SetAltArrowKeyMode(false)

	local pullout = CreateFrame("Frame", nil, UIParent, "TooltipBackdropTemplate") --[[@as Frame]]
	pullout:SetFrameStrata("FULLSCREEN_DIALOG")
	pullout:SetClampedToScreen(true)

	widget.pullout = pullout

	local helpText = pullout:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	helpText:SetPoint("BOTTOMLEFT", 28, 10)
	helpText:SetText(Addon.L["Use (shift-) tab to navigate"])

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(TYPE, Constructor, VERSION)

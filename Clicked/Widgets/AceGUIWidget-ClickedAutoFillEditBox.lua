--[[-----------------------------------------------------------------------------
EditBox Widget
-------------------------------------------------------------------------------]]

--- @class ClickedAutoFillEditBox : AceGUIEditBox
--- @field public pullout Frame
--- @field public SetValues fun(values:table[])
--- @field public GetValues fun():table[]
--- @field public SetMaxVisibleValues fun(count:integer)
--- @field public GetMaxVisibleValues fun():integer
--- @field public SetTextHighlight fun(enabled:boolean)
--- @field public HasTextHighlight fun():boolean
--- @field public SetSelectedIndex fun(index:integer)
--- @field public GetSelectedIndex fun():integer
--- @field public SetInputError fun(isInputError:boolean)
--- @field public IsInputError fun():boolean

--- @class ClickedInternal
local _, Addon = ...

local Type, Version = "ClickedAutoFillEditBox", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

local ATTACH_ABOVE = "above"
local ATTACH_BELOW = "below"

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

--- Find the longest common subsequence between two strings.
--- @type fun(source:string, target:string):string
local LongestCommonSubsequence

do
	local matrix = {}
	local charsCache = {}

	--- @param str string
	--- @param index integer
	--- @return string
	local function CharAt(str, index)
		if charsCache[str] == nil then
			charsCache[str] = {}
		end

		if charsCache[str][index] == nil then
			charsCache[str][index] = Addon:CharAt(str, index)
		end

		return charsCache[str][index]
	end

	--- Create an identity matrix.
	---
	--- @param source string
	--- @param target string
	--- @return integer[][]
	local function InitializeMatrix(source, target)
		for i = 1, #source + 1 do
			matrix[i] = {}
			matrix[i][1] = 0
		end

		for j = 1, #target + 1 do
			matrix[1][j] = 0
		end

		for i = 2, #source + 1 do
			for j = 2, #target + 1 do
				if CharAt(source, i - 1) == CharAt(target, j - 1) then
					matrix[i][j] = matrix[i - 1][j - 1] + 1
				else
					matrix[i][j] = math.max(matrix[i][j - 1], matrix[i - 1][j])
				end
			end
		end
	end

	--- Find the longest common subsequence by backtracking over the specified strings.
	---
	--- @param source string
	--- @param target string
	--- @param i integer
	--- @param j integer
	--- @return string
	local function Backtrack(source, target, i, j)
		if i == 1 or j == 1 then
			return ""
		end

		if CharAt(source, i - 1) == CharAt(target, j - 1) then
			return Backtrack(source, target, i - 1, j - 1) .. CharAt(source, i - 1)
		end

		if matrix[i][j - 1] > matrix[i - 1][j] then
			return Backtrack(source, target, i, j - 1)
		else
			return Backtrack(source, target, i - 1, j)
		end
	end

	--- Find the longest common subsequence between two strings.
	---
	--- @param source string
	--- @param target string
	function LongestCommonSubsequence(source, target)
		InitializeMatrix(source, target)
		return Backtrack(source, target, #source, #target)
	end
end

--- comment
---
--- @param input string
--- @param match string
--- @param caseSensitive boolean
--- @return number
local function ScoreMatch(input, match, caseSensitive)
	if not caseSensitive then
		input = string.upper(input)
		match = string.upper(match)
	end

	-- Check for a full match
	if input == match then
		return 0
	end

	return 1 - (#LongestCommonSubsequence(input, match) / math.min(#input, #match))
end

--- Find and sort matches of the input string.
---
--- @param text string
--- @param values table[]
--- @param count integer
--- @return table[]
local function FindMatches(text, values, count)
	if text == nil or text == "" or #values == 0 then
		return {}
	end

	local matches = {}
	local result = {}

	for _, value in ipairs(values) do
		table.insert(matches, {
			value = value,
			score = ScoreMatch(text, value.text, false)
		})
	end

	local findCache = {}

	local function SortFunc(l, r)
		-- Sort by scores
		if l.score < r.score then
			return true
		end

		if l.score > r.score then
			return false
		end

		-- Sort by absolute substrings
		findCache[text] = findCache[text] or string.upper(text)
		findCache[l.value.text] = findCache[l.value.text] or string.find(string.upper(l.value.text), findCache[text])
		findCache[r.value.text] = findCache[r.value.text] or string.find(string.upper(r.value.text), findCache[text])

		if findCache[l.value.text] and not findCache[r.value.text] then
			return true
		end

		if not findCache[l.value.text] and findCache[r.value.text] then
			return false
		end

		-- Sort alphabetically
		return l.value.text < r.value.text
	end

	table.sort(matches, SortFunc)

	for _, match in ipairs(matches) do
		if match.score <= 0.5 then
			local value = match.value
			value.score = match.score

			table.insert(result, value)
		end

		-- Only return the first entry if the score is 0 (we have a full match)
		if match.score == 0 then
			break
		end

		-- Only return `count` number of matches
		if #result >= count then
			break
		end
	end

	return result
end

--- Check if the auto-complete box is currently visible.
---
--- @param self ClickedAutoFillEditBox
--- @return boolean
local function IsAutoCompleteBoxVisible(self)
	return self.pullout:IsShown()
end

--- Get the index of the last visible button.
---
--- @param self ClickedAutoFillEditBox
--- @return integer
local function GetLastVisibleButtonIndex(self)
	for i = #self.buttons, 1, -1 do
		if self.buttons[i]:IsShown() and self.buttons[i]:IsEnabled() then
			return i
		end
	end

	return 0
end

--- Get the currently selected button.
---
--- @param self ClickedAutoFillEditBox
--- @return Button
local function GetSelectedButton(self)
	local selected = self:GetSelectedIndex()

	if selected > 0 and selected <= GetLastVisibleButtonIndex(self) then
		return self.buttons[selected]
	end

	return self.buttons[1]
end

--- Move the cursor in the given direction.
---
--- @param self ClickedAutoFillEditBox
--- @param direction integer
local function MoveCursor(self, direction)
	if IsAutoCompleteBoxVisible(self) then
		local next = self:GetSelectedIndex() + direction
		local last = GetLastVisibleButtonIndex(self)

		if next <= 0 then
			next = last
		elseif next > last then
			next = 1
		end

		self:SetSelectedIndex(next)
	end
end

--- Update the highlight state of the buttons.
---
--- @param self ClickedAutoFillEditBox
local function UpdateHighlight(self)
	for i = 1, #self.buttons do
		self.buttons[i]:UnlockHighlight()
	end

	if self:HasTextHighlight() and GetSelectedButton(self) ~= nil then
		GetSelectedButton(self):LockHighlight()
	end
end

--- Select the specified text.
---
--- @param self ClickedAutoFillEditBox
--- @param text string
local function Select(self, text)
	self.editbox:SetText(text)
	self.editbox:SetCursorPosition(strlen(text))

	self:Fire("OnSelect", text)
	self.originalText = text

	AceGUI:ClearFocus(self)
end

--- Select the specified button.
---
--- @param self ClickedAutoFillEditBox
--- @param button Button?
local function SelectButton(self, button)
	if button == nil then
		return
	end

	Select(self, button.obj)
end

--- Hide the auto-complete box.
---
--- @param self ClickedAutoFillEditBox
local function HideAutoCompleteBox(self)
	if not IsAutoCompleteBoxVisible(self) then
		return
	end

	self.pullout:ClearAllPoints()
	self.pullout:Hide()
	self.pullout.attachTo = nil
end

--- Hide the auto-complete box.
---
--- @param self ClickedAutoFillEditBox
--- @param height integer
--- @return string
local function FindAttachmentPoint(self, height)
	if self.frame:GetBottom() - height <= AUTOCOMPLETE_DEFAULT_Y_OFFSET + 10 then
		return ATTACH_ABOVE
	end

	return ATTACH_BELOW
end

local function CreateButton(self)
	local type = Type .. "Button"
	local num = AceGUI:GetNextWidgetNum(type)

	local button = CreateFrame("Button", type .. num, self.pullout, "AutoCompleteButtonTemplate")
	button:EnableMouse(true)
	button.obj = self

	local icon = button:CreateTexture(nil, "OVERLAY")
	icon:SetPoint("LEFT", 12, 1)
	icon:SetSize(12, 12)
	button.icon = icon

	button:GetFontString():SetPoint("LEFT", 28, 0)
	button:GetFontString():SetWidth(self.pullout:GetWidth() - 40)
	button:GetFontString():SetJustifyH("LEFT")
	button:GetFontString():SetHeight(14)

	button:SetScript("OnClick", function()
		HideAutoCompleteBox(self)
		SelectButton(self, button)
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

--- comment
---
--- @param self ClickedAutoFillEditBox
--- @param matches table[]
local function UpdateButtons(self, matches)
	local count = math.min(self:GetMaxVisibleValues(), #matches)

	for i = 1, count do
		local button = self.buttons[i]

		if button == nil then
			button = CreateButton(self)

			self.buttons[i] = button
			button:SetParent(self.pullout)
			button:SetFrameLevel(self.pullout:GetFrameLevel() + 1)
			button:ClearAllPoints()

			if i == 1 then
				button:SetPoint("TOPRIGHT", 0, -10)
				button:SetPoint("TOPLEFT", 0, -10)
			else
				button:SetPoint("TOPRIGHT", self.buttons[i - 1], "BOTTOMRIGHT", 0, 0)
				button:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT", 0, 0)
			end
		end

		button.obj = matches[i].text
		local text = matches[i].text

--@debug@
		text = "[" .. string.format("%.2f", 1 - matches[i].score) .. "] " .. text
--@end-debug@

		button:SetText(text)

		button.icon:SetTexture(matches[i].icon)
		button.icon:SetTexCoord(0, 1, 0, 1)

		button:Show()
	end

	for i = count + 1, #self.buttons do
		self.buttons[i]:Hide()
	end

	if #matches > self:GetMaxVisibleValues() then
		local button = self.buttons[self:GetMaxVisibleValues()]

		button:SetText("...")
		button:Disable()

		button.icon:SetTexture(nil)
	end
end

--- Update the state of the auto-complete box.
---
--- @param self ClickedAutoFillEditBox
local function Rebuild(self)
	if strlenutf8(self:GetText()) == 0 then
		HideAutoCompleteBox(self)
		return
	end

	local text = self:GetText()
	local pullout = self.pullout

	if self.editbox:GetUTF8CursorPosition() > strlenutf8(text) then
		HideAutoCompleteBox(self)
		return
	end

	if tonumber(text) ~= nil then
		HideAutoCompleteBox(self)

		for _, value in ipairs(self:GetValues()) do
			if value.spellId == tonumber(text) then
				Select(self, value.text)
				break
			end
		end
	else
		local matches = FindMatches(text, self:GetValues(), self:GetMaxVisibleValues() + 1)
		UpdateButtons(self, matches)

		if #matches == 0 then
			HideAutoCompleteBox(self)
			return
		end

		local buttonHeight = self.buttons[1]:GetHeight()
		local baseHeight = 32

		local height = baseHeight + math.max(buttonHeight * math.min(#matches, self:GetMaxVisibleValues()), 14)
		local attachTo = FindAttachmentPoint(self, height)

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

		if not IsAutoCompleteBoxVisible(self) then
			self.selected = 1
		end

		pullout:SetHeight(height)
		pullout:Show()
	end
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function EditBox_OnTabPressed(frame)
	local self = frame.obj

	MoveCursor(self, IsShiftKeyDown() and -1 or 1)
end

local function EditBox_OnArrowPressed(frame, key)
	local self = frame.obj

	if key == "UP" then
		return MoveCursor(self, -1);
	elseif key == "DOWN" then
		return MoveCursor(self, 1);
	end
end

local function EditBox_OnEnterPressed(frame)
	local self = frame.obj

	if IsAutoCompleteBoxVisible(self) then
		HideAutoCompleteBox(self)
		SelectButton(self, GetSelectedButton(self))
	end

	self.BaseOnTextChanged(frame)
end

local function EditBox_OnTextChanged(frame, userInput)
	local self = frame.obj

	self.BaseOnTextChanged(frame)

	if userInput then
		Rebuild(self)
	end

	UpdateHighlight(self)
end

local function EditBox_OnEscapePressed(frame)
	local self = frame.obj

	if IsAutoCompleteBoxVisible(self) then
		self:SetText(self.originalText)
		HideAutoCompleteBox(self)
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:BaseOnAcquire()

		self.values = {}
		self.selected = 1
		self.numButtons = 10
		self.originalText = ""
		self.highlight = true
		self.isInputError = false

		self.pullout:SetParent(UIParent)
		self.pullout:SetFrameLevel(self.frame:GetFrameLevel() + 1)
		self.pullout:Hide()

		self:DisableButton(true)
	end,

	["OnRelease"] = function(self)
		self:BaseOnRelease()

		HideAutoCompleteBox(self)
	end,

	["SetValues"] = function(self, values)
		self.values = values

		if IsAutoCompleteBoxVisible(self) then
			Rebuild(self)
		end
	end,

	["GetValues"] = function(self)
		return self.values
	end,

	["SetMaxVisibleValues"] = function(self, count)
		self.numButtons = count
		Rebuild(self)
	end,

	["GetMaxVisibleValues"] = function(self)
		return self.numButtons
	end,

	["SetTextHighlight"] = function(self, enabled)
		self.highlight = enabled
		UpdateHighlight(self)
	end,

	["HasTextHighlight"] = function(self)
		return self.highlight
	end,

	["SetSelectedIndex"] = function(self, index)
		if index <= 0 or index > GetLastVisibleButtonIndex(self) then
			return
		end

		self.selected = index
		UpdateHighlight(self)
	end,

	["GetSelectedIndex"] = function(self)
		return self.selected
	end,

	["SetInputError"] = function(self, isInputError)
		self.isInputError = isInputError
		self:SetText(self:GetText())
	end,

	["IsInputError"] = function(self)
		return self.isInputError
	end,

	["ClearFocus"] = function(self)
		if IsAutoCompleteBoxVisible(self) then
			self:SetText(self.originalText)
			HideAutoCompleteBox(self)
		end
	end,

	["SetWidth"] = function(self, width)
		self:BaseSetWidth(width)
		self.pullout:SetWidth(width)
	end,

	["SetText"] = function(self, text, isOriginal)
		if isOriginal then
			self.originalText = text
		end

		if self:IsInputError() and text ~= nil then
			text = "|cffff1a1a" .. text .. "|r"
		end

		self:BaseSetText(text)
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local widget = AceGUI:Create("EditBox")
	widget.type = Type
	widget.values = {}
	widget.buttons = {}
	widget.selected = 1
	widget.numButtons = 10
	widget.originalText = ""
	widget.highlight = true
	widget.isInputError = false

	widget.BaseOnAcquire = widget.OnAcquire
	widget.BaseOnRelease = widget.OnRelease
	widget.BaseSetWidth = widget.SetWidth
	widget.BaseSetText = widget.SetText
	widget.BaseOnEnterPressed = widget.editbox:GetScript("OnEnterPressed")
	widget.BaseOnTextChanged = widget.editbox:GetScript("OnTextChanged")

	widget.editbox:SetScript("OnTabPressed", EditBox_OnTabPressed)
	widget.editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	widget.editbox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	widget.editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	widget.editbox:SetScript("OnArrowPressed", EditBox_OnArrowPressed)
	widget.editbox:SetAltArrowKeyMode(false)

	local pullout = CreateFrame("Frame", nil, UIParent, "TooltipBackdropTemplate")
	pullout:SetFrameStrata("FULLSCREEN_DIALOG")
	pullout:SetClampedToScreen(true)
	widget.pullout = pullout

	local helpText = pullout:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	helpText:SetPoint("BOTTOMLEFT", 28, 10)
	helpText:SetText("Press Tab")

	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

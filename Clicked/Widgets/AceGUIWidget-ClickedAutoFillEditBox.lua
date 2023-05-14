--[[-----------------------------------------------------------------------------
EditBox Widget
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedAutoFillEditBox"

--- @class ClickedAutoFillEditBox : AceGUIEditBox
--- @field private values TalentInfo[]
--- @field private buttons Button[]
--- @field private selected integer
--- @field private numButtons integer
--- @field private originalText string
--- @field private highlight boolean
--- @field private isInputError boolean
--- @field private pullout Frame

--- @class ClickedAutoFillEditBox.Match : TalentInfo
--- @field public value string
--- @field public score number

--- @class ClickedAutoFillEditBox.Button : Button
--- @field public icon Texture

--- @class ClickedInternal
local Addon = select(2, ...)

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
--- @param values TalentInfo[]
--- @param count integer
--- @return ClickedAutoFillEditBox.Match[]
local function FindMatches(text, values, count)
	if text == nil or text == "" or #values == 0 then
		return {}
	end

	--- @type ClickedAutoFillEditBox.Match[]
	local matches = {}
	--- @type ClickedAutoFillEditBox.Match[]
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

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function EditBox_OnTabPressed(frame)
	local self = frame.obj

	self:MoveCursor(self, IsShiftKeyDown() and -1 or 1)
end

local function EditBox_OnArrowPressed(frame, key)
	local self = frame.obj

	if key == "UP" then
		return self:MoveCursor(-1);
	elseif key == "DOWN" then
		return self:MoveCursor(1);
	end
end

local function EditBox_OnEnterPressed(frame)
	local self = frame.obj

	if self:IsAutoCompleteBoxVisible() then
		self:HideAutoCompleteBox()
		self:SelectButton(self:GetSelectedButton())
	end

	self.BaseOnTextChanged(frame)
end

local function EditBox_OnTextChanged(frame, userInput)
	local self = frame.obj

	self.BaseOnTextChanged(frame)

	if userInput then
		self:Rebuild()
	end

	self:UpdateHighlight()
end

local function EditBox_OnEscapePressed(frame)
	local self = frame.obj

	if self:IsAutoCompleteBoxVisible() then
		self:SetText(self.originalText)
		self:HideAutoCompleteBox()
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]

--- @class ClickedAutoFillEditBox
local Methods = {}

--- @protected
function Methods:OnAcquire()
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
end

--- @protected
function Methods:OnRelease()
	self:BaseOnRelease()
	self:HideAutoCompleteBox()
end

--- @param values TalentInfo[]
function Methods:SetValues(values)
	self.values = values

	if self:IsAutoCompleteBoxVisible() then
		self:Rebuild()
	end
end

--- @return TalentInfo[]
function Methods:GetValues()
	return self.values
end

--- @param count integer
function Methods:SetMaxVisibleValues(count)
	self.numButtons = count
	self:Rebuild()
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
	if index <= 0 or index > self:GetLastVisibleButtonIndex() then
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
	if self:IsAutoCompleteBoxVisible() then
		self:SetText(self.originalText)
		self:HideAutoCompleteBox()
	end
end

--- @param width integer
function Methods:SetWidth(width)
	self:BaseSetWidth(width)
	self.pullout:SetWidth(width)
end

--- @param text string
--- @param isOriginal? boolean
function Methods:SetText(text, isOriginal)
	if isOriginal then
		self.originalText = text
	end

	if self:IsInputError() and text ~= nil then
		text = "|cffff1a1a" .. text .. "|r"
	end

	self:BaseSetText(text)
end

--- @private
--- @return ClickedAutoFillEditBox.Button
function Methods:CreateButton()
	local type = Type .. "Button"
	local num = AceGUI:GetNextWidgetNum(type)

	local button = CreateFrame("Button", type .. num, self.pullout, "AutoCompleteButtonTemplate") --[[@as ClickedAutoFillEditBox.Button]]
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

--- @private
--- @param matches ClickedAutoFillEditBox.Match[]
function Methods:UpdateButtons(matches)
	local count = math.min(self:GetMaxVisibleValues(), #matches)

	for i = 1, count do
		local button = self.buttons[i]

		if button == nil then
			button = self:CreateButton()

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

		button:Enable()
		button:Show()
	end

	for i = count + 1, #self.buttons do
		self.buttons[i]:Hide()
	end

	if #matches > self:GetMaxVisibleValues() then
		local button = self.buttons[self:GetMaxVisibleValues()]

		button:SetText("...")
		button:Disable()

		--- @diagnostic disable-next-line: undefined-field
		button.icon:SetTexture(nil)
	end
end

--- @private
--- @param button? Button
function Methods:SelectButton(button)
	if button == nil then
		return
	end

	--- @diagnostic disable-next-line: undefined-field
	self:Select(button.obj)
end

--- @private
function Methods:HideAutoCompleteBox()
	if not self:IsAutoCompleteBoxVisible() then
		return
	end

	self.pullout:ClearAllPoints()
	self.pullout:Hide()
	self.pullout.attachTo = nil
end

--- @private
--- @param height integer
--- @return string
function Methods:FindAttachmentPoint(height)
	if self.frame:GetBottom() - height <= AUTOCOMPLETE_DEFAULT_Y_OFFSET + 10 then
		return ATTACH_ABOVE
	end

	return ATTACH_BELOW
end

--- @private
function Methods:Rebuild()
	if strlenutf8(self:GetText()) == 0 then
		self:HideAutoCompleteBox()
		return
	end

	local text = self:GetText()
	local pullout = self.pullout

	if self.editbox:GetUTF8CursorPosition() > strlenutf8(text) then
		self:HideAutoCompleteBox()
		return
	end

	if tonumber(text) ~= nil then
		self:HideAutoCompleteBox()

		for _, value in ipairs(self:GetValues()) do
			if value.spellId == tonumber(text) then
				self:Select(value.text)
				break
			end
		end
	else
		local matches = FindMatches(text, self:GetValues(), self:GetMaxVisibleValues() + 1)
		self:UpdateButtons(matches)

		if #matches == 0 then
			self:HideAutoCompleteBox()
			return
		end

		local buttonHeight = self.buttons[1]:GetHeight()
		local baseHeight = 32

		local height = baseHeight + math.max(buttonHeight * math.min(#matches, self:GetMaxVisibleValues()), 14)
		local attachTo = self:FindAttachmentPoint(height)

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
end

--- @private
function Methods:UpdateHighlight()
	for i = 1, #self.buttons do
		self.buttons[i]:UnlockHighlight()
	end

	if self:HasTextHighlight() and self:GetSelectedButton() ~= nil then
		self:GetSelectedButton():LockHighlight()
	end
end

--- @private
--- @param text string
function Methods:Select(text)
	self.editbox:SetText(text)
	self.editbox:SetCursorPosition(strlen(text))

	self:Fire("OnSelect", text)
	self.originalText = text

	AceGUI:ClearFocus()
end

--- @private
--- @return boolean
function Methods:IsAutoCompleteBoxVisible()
	return self.pullout:IsShown()
end

--- @private
--- @return integer
function Methods:GetLastVisibleButtonIndex()
	for i = #self.buttons, 1, -1 do
		if self.buttons[i]:IsShown() and self.buttons[i]:IsEnabled() then
			return i
		end
	end

	return 0
end

--- @private
--- @return Button
function Methods:GetSelectedButton()
	local selected = self:GetSelectedIndex()

	if selected > 0 and selected <= self:GetLastVisibleButtonIndex() then
		return self.buttons[selected]
	end

	return self.buttons[1]
end

--- @private
--- @param direction integer
function Methods:MoveCursor(direction)
	if self:IsAutoCompleteBoxVisible() then
		local next = self:GetSelectedIndex() + direction
		local last = self:GetLastVisibleButtonIndex()

		if next <= 0 then
			next = last
		elseif next > last then
			next = 1
		end

		self:SetSelectedIndex(next)
	end
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	--- @class ClickedAutoFillEditBox
	local widget = AceGUI:Create("EditBox")
	widget.type = Type

	widget.values = {}
	widget.buttons = {}
	widget.selected = 1
	widget.numButtons = 10
	widget.originalText = ""
	widget.highlight = true
	widget.isInputError = false

	--- @private
	widget.BaseOnAcquire = widget.OnAcquire
	--- @private
	widget.BaseOnRelease = widget.OnRelease
	--- @private
	widget.BaseSetWidth = widget.SetWidth
	--- @private
	widget.BaseSetText = widget.SetText
	--- @private
	widget.BaseOnEnterPressed = widget.editbox:GetScript("OnEnterPressed")
	--- @private
	widget.BaseOnTextChanged = widget.editbox:GetScript("OnTextChanged")

	widget.editbox:SetScript("OnTabPressed", EditBox_OnTabPressed)
	widget.editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	widget.editbox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	widget.editbox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	widget.editbox:SetScript("OnArrowPressed", EditBox_OnArrowPressed)
	widget.editbox:SetAltArrowKeyMode(false)

	local pullout = CreateFrame("Frame", nil, UIParent, "TooltipBackdropTemplate") --[[@as Frame]]
	pullout:SetFrameStrata("FULLSCREEN_DIALOG")
	pullout:SetClampedToScreen(true)

	widget.pullout = pullout

	local helpText = pullout:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
	helpText:SetPoint("BOTTOMLEFT", 28, 10)
	helpText:SetText("Press Tab")

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

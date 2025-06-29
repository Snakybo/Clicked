--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedBindingImportList"

--- @class ClickedBindingImportList : AceGUIWidget
--- @field private lines table
--- @field private buttons Button[]
--- @field private status ClickedBindingImportList.Status?
--- @field private localstatus ClickedBindingImportList.Status
--- @field private tree ClickedBindingImportList.Item[]
--- @field private treeframe Frame
--- @field private scrollbar Slider
--- @field private showScroll boolean
--- @field private showKeybinds boolean

--- @class ClickedBindingImportList.Status
--- @field public scrollvalue number
--- @field public groups { [string]: boolean }

--- @class ClickedBindingImportList.Button : Button
--- @field public isMoving boolean
--- @field public toggle Button
--- @field public text FontString

--- @class ClickedBindingImportList.Item
--- @field public title string
--- @field public icon string|number
--- @field public children ClickedBindingImportList.Item[]?

--- @class ClickedBindingImportList.BindingItem : ClickedTreeGroupItem
--- @field public binding Binding
--- @field public keybind string

--- @class ClickedBindingImportList.GroupItem : ClickedTreeGroupItem
--- @field public group Group

--- @class ClickedInternal
local Addon = select(2, ...)

local Type, Version = "ClickedBindingImportList", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

-- Recycling functions

--- @type fun(): ClickedBindingImportList.Line
local new
--- @type fun(item: ClickedBindingImportList.Line)
local del

do
	local pool = setmetatable({},{__mode='k'})
	function new()
		local t = next(pool)
		if t then
			pool[t] = nil
			return t
		else
			return {}
		end
	end
	function del(t)
		for k in pairs(t) do
			t[k] = nil
		end
		pool[t] = true
	end
end

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function TreeSortAlphabetical(left, right)
	return (left.name or "") < (right.name or "")
end

local function TreeSortKeybind(left, right)
	if left.binding.keybind ~= nil and right.binding.keybind ~= nil then
		return Addon:CompareBindings(left.binding, right.binding)
	end

	return TreeSortAlphabetical(left, right)
end

local function FirstFrameUpdate(frame)
	local self = frame.obj
	frame:SetScript("OnUpdate", nil)
	self:RefreshTree()
end

local function UpdateButton(button, line, canExpand, isExpanded)
	local toggle = button.toggle

	button.treeline = line
	button.identifier = line.identifier
	button.binding = line.binding
	button.group = line.group

	button:SetNormalFontObject("GameFontNormal")
	button:SetHighlightFontObject("GameFontHighlight")

	button.text:ClearAllPoints()
	button.text:SetPoint("TOPLEFT", (line.icon and 28 or 0) + 8 * line.level, -1)
	button.text:SetText(line.title or "")

	if line.showKeybinds and not Addon:IsNilOrEmpty(line.keybind) then
		button.keybind:SetPoint("BOTTOMLEFT", (line.icon and 28 or 0) + 8 * line.level, 1)
		button.keybind:SetText(line.keybind or "")
		button.keybind:Show()
	else
		button.keybind:Hide()
	end

	if line.icon then
		button.icon:SetTexture(line.icon)
		button.icon:SetPoint("TOPLEFT", 8 * line.level, 1)
	else
		button.icon:SetTexture(nil)
	end

	button.icon:SetTexCoord(0, 1, 0, 1)

	if canExpand then
		if not isExpanded then
			toggle:SetNormalTexture(130838) -- Interface\\Buttons\\UI-PlusButton-UP
			toggle:SetPushedTexture(130836) -- Interface\\Buttons\\UI-PlusButton-DOWN
		else
			toggle:SetNormalTexture(130821) -- Interface\\Buttons\\UI-MinusButton-UP
			toggle:SetPushedTexture(130820) -- Interface\\Buttons\\UI-MinusButton-DOWN
		end
		toggle:Show()
	else
		toggle:Hide()
	end
end

local function AddLine(self, v, tree, level, parent)
	--- @class ClickedBindingImportList.Line
	local line = new()
	line.binding = v.binding
	line.group = v.group
	line.title = v.title
	line.keybind = v.keybind
	line.icon = v.icon
	line.tree = tree
	line.level = level
	line.parent = parent
	line.showKeybinds = self.showKeybinds
	line.identifier = line.group ~= nil and line.group.uid or line.binding.uid

	if v.children ~= nil then
		line.hasChildren = true
	else
		line.hasChildren = nil
	end

	self.lines[#self.lines + 1] = line

	return line
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Expand_OnClick(frame)
	local button = frame.button
	local self = button.obj
	local status = (self.status or self.localstatus).groups
	status[button.identifier] = not status[button.identifier]
	self:RefreshTree()
end

local function OnScrollValueChanged(frame, value)
	if frame.obj.noupdate then return end
	local self = frame.obj
	local status = self.status or self.localstatus
	status.scrollvalue = floor(value + 0.5)
	self:RefreshTree()
end

local function Tree_OnSizeChanged(frame)
	frame.obj:RefreshTree()
end

local function Tree_OnMouseWheel(frame, delta)
	local self = frame.obj
	if self.showScroll then
		local scrollbar = self.scrollbar
		local min, max = scrollbar:GetMinMaxValues()
		local value = scrollbar:GetValue()
		local newvalue = math.min(max, math.max(min,value - delta))
		if value ~= newvalue then
			scrollbar:SetValue(newvalue)
		end
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @class ClickedBindingImportList
local Methods = {}

--- @private
function Methods:OnAcquire()
	self.frame:SetScript("OnUpdate", FirstFrameUpdate)

	self.showScroll = true
	self.showKeybinds = true
end

--- @private
function Methods:OnRelease()
	self.status = nil
	self.tree = nil

	self.frame:SetScript("OnUpdate", nil)

	for k, v in pairs(self.localstatus) do
		if k == "groups" then
			for k2 in pairs(v) do
				v[k2] = nil
			end
		else
			self.localstatus[k] = nil
		end
	end

	self.localstatus.scrollvalue = 0
end

--- @param fromOnUpdate? boolean
function Methods:RefreshTree(fromOnUpdate)
	local buttons = self.buttons
	local lines = self.lines

	for _, button in ipairs(buttons) do
		button:Hide()
	end

	while lines[1] do
		local t = table.remove(lines)

		for k in pairs(t) do
			t[k] = nil
		end

		del(t)
	end

	if self.tree == nil then
		return
	end

	local status = self.status or self.localstatus
	local groupstatus = status.groups
	local treeframe = self.treeframe

	self:BuildLevel(self.tree, 1)

	local numlines = #lines
	local maxlines = math.floor(((self.treeframe:GetHeight() or 0) - 15) / 28)

	if maxlines <= 0 then
		return
	end

	if self.frame:GetParent() == UIParent and not fromOnUpdate then
		self.frame:SetScript("OnUpdate", FirstFrameUpdate)
		return
	end

	local first
	local last

	if numlines <= maxlines then
		--the whole tree fits in the frame
		status.scrollvalue = 0
		self:ShowScroll(false)
		first = 1
		last = numlines
	else
		self:ShowScroll(true)
		--scrolling will be needed
		self.noupdate = true
		self.scrollbar:SetMinMaxValues(0, numlines - maxlines)

		--check if we are scrolled down too far
		if numlines - status.scrollvalue < maxlines then
			status.scrollvalue = numlines - maxlines
		end

		self.noupdate = nil
		first, last = status.scrollvalue + 1, status.scrollvalue + maxlines

		if self.scrollbar:GetValue() ~= status.scrollvalue then
			self.scrollbar:SetValue(status.scrollvalue)
		end
	end

	local buttonNum = 1
	local previous = nil

	for i = first, last do
		local line = lines[i]
		local button = buttons[buttonNum]

		if button == nil then
			button = self:CreateButton()
			buttons[buttonNum] = button

			button:SetParent(treeframe)
		end

		button:SetFrameLevel(treeframe:GetFrameLevel() + 1)
		button:ClearAllPoints()

		if previous == nil then
			button:SetPoint("TOPLEFT", 0, -10)
			button:SetPoint("TOPRIGHT", self.showScroll and -22 or 0, -10)
		else
			button:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT", 0, 0)
			button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
		end

		UpdateButton(button, line, line.hasChildren, groupstatus[line.identifier])
		button:Show()

		buttonNum = buttonNum + 1
		previous = button
	end
end

--- @param tree any
--- @param level any
--- @param parent any
function Methods:BuildLevel(tree, level, parent)
	local groups = (self.status or self.localstatus).groups

	for _, v in ipairs(tree) do
		if v.children ~= nil then
			local line = AddLine(self, v, tree, level, parent)

			if groups[line.identifier] then
				self:BuildLevel(v.children, level + 1, line)
			end
		else
			AddLine(self, v, tree, level, parent)
		end
	end
end

function Methods:CreateButton()
	local type = "ClickedBindingImportButton"
	local num = AceGUI:GetNextWidgetNum(type)
	local button = CreateFrame("Button", string.format(type .. "%d", num), self.treeframe, "OptionsListButtonTemplate") --[[@as ClickedBindingImportList.Button]]
	button.obj = self --- @diagnostic disable-line: inject-field

	local icon = button:CreateTexture(nil, "OVERLAY")
	icon:SetWidth(26)
	icon:SetHeight(26)
	icon:SetPoint("TOPLEFT", 8, 0)
	button.icon = icon --- @diagnostic disable-line: inject-field

	button.text:SetHeight(14) -- Prevents text wrapping

	local keybind = button:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	keybind:SetHeight(14) -- Prevents text wrapping
	keybind:SetFont("Fonts\\FRIZQT__.TTF", 10)
	button.keybind = keybind --- @diagnostic disable-line: inject-field

	button:SetHeight(28)

	button:SetScript("OnClick", nil)
	button:SetScript("OnDoubleClick", nil)
	button:SetScript("OnEnter",nil)
	button:SetScript("OnLeave",nil)
	button:SetScript("OnDragStart", nil)
	button:SetScript("OnDragStop", nil)
	button:SetScript("OnHide", nil)

	button.toggle.button = button --- @diagnostic disable-line: inject-field
	button.toggle:SetScript("OnClick", Expand_OnClick)

	return button
end

--- @param show boolean
function Methods:ShowScroll(show)
	self.showScroll = show

	local button = nil

	for _, b in ipairs(self.buttons) do
		if b:IsEnabled() and b:IsShown() then
			button = b
			break
		end
	end

	if show then
		self.scrollbar:Show()

		if button ~= nil then
			button:SetPoint("TOPRIGHT", self.treeframe, "TOPRIGHT", -22, -10)
		end
	else
		self.scrollbar:Hide()

		if button ~= nil then
			button:SetPoint("TOPRIGHT", self.treeframe, "TOPRIGHT", 0, -10)
		end
	end
end

--- @param data ShareData[]
function Methods:SetItems(data)
	local groups = (self.status or self.localstatus).groups

	self.tree = {}

	--- @param binding Binding
	--- @param parent table
	local function CreateBindingItem(binding, parent)
		local title, icon = Addon:GetBindingNameAndIcon(binding)

		--- @type ClickedBindingImportList.BindingItem
		local item = {
			uid = binding.uid,
			binding = binding,
			title = title,
			icon = icon,
			keybind = #binding.keybind > 0 and Addon:SanitizeKeybind(binding.keybind) or "",
		}

		table.insert(parent, item)
	end

	--- @param group ShareData.Group
	local function CreateGroupItem(group)

		--- @type ClickedBindingImportList.GroupItem
		local item = {
			uid = group.uid,
			group = group,
			title = group.name,
			icon = group.displayIcon,
			children = {}
		}

		for _, binding in ipairs(group.bindings) do
			CreateBindingItem(binding, item.children)
		end

		table.sort(item.children, TreeSortKeybind)
		table.insert(self.tree, item)

		groups[group.uid] = true
	end

	for _, current in ipairs(data) do
		if current.type == "group" then
			CreateGroupItem(current.group)
		elseif current.type == "binding" then
			CreateBindingItem(current.binding, self.tree)
		end
	end

	self:RefreshTree()
end

--- @param show boolean
function Methods:ShowKeybinds(show)
	self.showKeybinds = show
	self:RefreshTree()
end

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local PaneBackdrop  = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", nil, UIParent)

	local treeframe = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	treeframe:SetPoint("TOPLEFT")
	treeframe:SetPoint("BOTTOMRIGHT")
	treeframe:EnableMouseWheel(true)
	treeframe:SetBackdrop(PaneBackdrop)
	treeframe:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	treeframe:SetBackdropBorderColor(0.4, 0.4, 0.4)
	treeframe:SetScript("OnUpdate", FirstFrameUpdate)
	treeframe:SetScript("OnSizeChanged", Tree_OnSizeChanged)
	treeframe:SetScript("OnMouseWheel", Tree_OnMouseWheel)

	local scrollbar = CreateFrame("Slider", ("ClickedBindingImportList%dScrollBar"):format(num), treeframe, "UIPanelScrollBarTemplate")
	scrollbar:SetScript("OnValueChanged", nil)
	scrollbar:SetPoint("TOPRIGHT", -10, -26)
	scrollbar:SetPoint("BOTTOMRIGHT", -10, 26)
	scrollbar:SetMinMaxValues(0,0)
	scrollbar:SetValueStep(1)
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)
	scrollbar:SetScript("OnValueChanged", OnScrollValueChanged)

	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(scrollbar --[[@as ScriptRegion]])
	scrollbg:SetColorTexture(0,0,0,0.4)

	local widget = {
		frame= frame,
		lines = {},
		buttons = {},
		localstatus = { scrollvalue = 0, groups = {} },
		treeframe = treeframe,
		scrollbar = scrollbar,
		showScroll = true,
		showKeybinds = true,
		type = Type
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	treeframe.obj = widget
	scrollbar.obj = widget

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

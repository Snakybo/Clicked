--[[-----------------------------------------------------------------------------
TreeGroup Container
Container that uses a tree control to switch between groups.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedTreeGroup"

--- @class ClickedTreeGroupItem
--- @field public uid integer
--- @field public title string
--- @field public subtitle? string
--- @field public icon? string|integer
--- @field public enabled? boolean
--- @field public children? ClickedTreeGroupItem[]

--- @class ClickedTreeGroupRuntimeItem : ClickedTreeGroupItem
--- @field public level integer
--- @field public parent? ClickedTreeGroupItem
--- @field public lastFilter? string
--- @field public isFiltered boolean
--- @field public isFolded? boolean
--- @field public isAnyChildVisible? boolean
--- @field public isAnyChildEnabled? boolean

--- @class ClickedTreeGroupStatus
--- @field public scrollValue? number
--- @field public selected? integer[]
--- @field public dragging? integer[]
--- @field public scrollToSelection? boolean

--- @class ClickedTreeGroupButton : Button
--- @field public uid integer
--- @field public obj ClickedTreeGroup
--- @field public toggle Button
--- @field public icon Texture
--- @field public title FontString
--- @field public subtitle FontString
--- @field public selected boolean

--- @class ClickedInternal
local Addon = select(2, ...)

local Type, Version = "ClickedTreeGroup", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

local GREY_FONT_COLOR = { r = 0.75, g = 0.75, b = 0.75, a = 0.5 }
local MAX_FLOATING_BUTTONS = 3

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

--- @param frame Frame
local function FirstFrameUpdate(frame)
	frame:SetScript("OnUpdate", nil)

	--- @class ClickedTreeGroup
	local self = frame.obj --- @diagnostic disable-line: undefined-field
	self:RefreshTree(nil, true)
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]

--- @param button Button
local function Expand_OnClick(button)
	--- @type ClickedTreeGroupButton
	button = button.button --- @diagnostic disable-line: undefined-field

	--- @class ClickedTreeGroup
	local self = button.obj

	local item = self.treeLookup[button.uid]
	if item ~= nil then
		item.isFolded = not item.isFolded
	end

	self:RefreshTree()
end

--- @param button ClickedTreeGroupButton
--- @param key string
local function Button_OnClick(button, key)
	--- @class ClickedTreeGroup
	local self = button.obj
	local status = self.status or self.localstatus

	if key == "RightButton" then
		local ids = status.selected or {}

		if not tContains(ids, button.uid) then
			ids = { button.uid }
		end

		self:Fire("OnButtonContext", ids, button)
	else
		self:Fire("OnButtonClick", button.uid, button.selected)

		if IsShiftKeyDown() then
			local to = self:FindLineIndex(button.uid) or #self.lines
			local from = self:FindLineIndex(status.selected[1]) or to

			--- @type integer[]
			local selected = {}

			if to >= from then
				for i = from, to do
					if self.lines[i].uid > 0 then
						table.insert(selected, self.lines[i].uid)
					end
				end
			else
				for i = from, to, -1 do
					if self.lines[i].uid > 0 then
						table.insert(selected, self.lines[i].uid)
					end
				end
			end

			self:Select(selected)
		else
			if IsControlKeyDown() then
				if not button.selected then
					self:AddSelection(button.uid)
				else
					self:RemoveSelection(button.uid)
				end
			else
				self:Select(button.uid)
			end
		end
	end

	AceGUI:ClearFocus()
end

--- @param button ClickedTreeGroupButton
local function Button_OnDoubleClick(button)
	--- @class ClickedTreeGroup
	local self = button.obj

	local item = self.treeLookup[button.uid]
	if item ~= nil then
		item.isFolded = not item.isFolded
	end

	self:RefreshTree()
end

--- @param button ClickedTreeGroupButton
local function Button_OnEnter(button)
	--- @class ClickedTreeGroup
	local self = button.obj

	if button:IsDragging() then
		return
	end

	self:Fire("OnButtonEnter", button.uid, button)
end

--- @param button ClickedTreeGroupButton
local function Button_OnLeave(button)
	--- @class ClickedTreeGroup
	local self = button.obj

	if button:IsDragging() then
		return
	end

	self:Fire("OnButtonLeave", button.uid, button)

	Addon:HideTooltip()
end

--- @param button ClickedTreeGroupButton
local function Button_OnDragStart(button)
	--- @class ClickedTreeGroup
	local self = button.obj
	local status = self.status or self.localstatus

	if tContains(status.selected, button.uid) then
		status.dragging = { unpack(status.selected) }

		-- Remove all children of selected items from the dragging list, as they will be moved with the parent
		for i = #status.dragging, 1, -1 do
			local item = self.treeLookup[status.dragging[i]]

			-- Make sure the button is folded in when we start dragging, otherwise its children will have nothing to attach to
			if item.children ~= nil then
				item.isFolded = true
			end

			if item ~= nil and item.parent ~= nil and tContains(status.dragging, item.parent.uid) then
				table.remove(status.dragging, i)
			end
		end
	else
		status.dragging = { button.uid }
	end

	button:StartMoving()
	button:SetFrameLevel(self.treeFrame:GetFrameLevel() + math.min(#status.dragging, MAX_FLOATING_BUTTONS) + 2)
	button.toggle:Hide()

	Addon:HideTooltip()

	self.dragging = true
	self:RefreshTree()
end

--- @param button ClickedTreeGroupButton
local function Button_OnDragStop(button)
	--- @class ClickedTreeGroup
	local self = button.obj
	local status = self.status or self.localstatus

	if not button:IsDragging() then
		return
	end

	button:StopMovingOrSizing()
	button:SetUserPlaced(false)

	--- @type integer?
	local newParent = nil

	--- @type BindingScope
	local newScope = Addon.BindingScope.PROFILE

	--- @type ClickedTreeGroupRuntimeItem
	--- @diagnostic disable-next-line: assign-type-mismatch
	local scopeItem = self.treeLookup[Addon:GetScopeUid(newScope)]

	--- @type ClickedTreeGroupRuntimeItem?
	local groupItem = nil

	--- @type ClickedTreeGroupRuntimeItem?
	local updateItem = nil

	for _, btn in ipairs(self.buttons) do
		if btn:IsEnabled() and btn:IsShown() and btn:IsMouseOver(0, 0) and not tContains(status.dragging, btn.uid) then
			local scope = Addon:GetScopeFromUid(btn.uid)
			if scope ~= nil then
				newScope = scope
				scopeItem = self.treeLookup[btn.uid]
				break
			else
				local obj = Clicked:GetByUid(btn.uid)

				if obj ~= nil then
					newScope = obj.scope
					scopeItem = self.treeLookup[Addon:GetScopeUid(newScope)]

					if obj.type == Clicked.DataObjectType.BINDING then
						--- @cast obj Binding
						newParent = obj.parent
						groupItem = self.treeLookup[obj.parent or Addon:GetScopeUid(newScope)]
					elseif obj.type == Clicked.DataObjectType.GROUP then
						--- @cast obj Group
						newParent = obj.uid
						groupItem = self.treeLookup[obj.uid]
					end

					break
				end
			end
		end
	end

	for _, uid in ipairs(status.dragging) do
		local obj = Clicked:GetByUid(uid)

		if obj ~= nil then
			local item = self.treeLookup[uid]

			if obj.scope ~= newScope then
				Addon:ChangeScope(obj, newScope)
			end

			if obj.type == Clicked.DataObjectType.BINDING then
				--- @cast obj Binding

				obj.parent = newParent

				local parent = groupItem or scopeItem

				if item ~= nil and item ~= parent then
					Addon:TableRemoveItem(item.parent.children, item)
					table.insert(parent.children, item)

					updateItem = updateItem or parent
				end
			elseif obj.type == Clicked.DataObjectType.GROUP then
				--- @cast obj Group

				if item ~= nil and item ~= scopeItem then
					Addon:TableRemoveItem(item.parent.children, item)
					table.insert(scopeItem.children, item)

					updateItem = scopeItem
				end
			end
		end
	end

	table.wipe(status.dragging)
	self.dragging = false

	if updateItem ~= nil then
		self:UpdateTreeItems(updateItem.children, updateItem.level + 1, updateItem)
	end

	self:RefreshTree()
end

--- @param button ClickedTreeGroupButton
local function Button_OnHide(button)
	button:StopMovingOrSizing()
end

--- @param slider Slider
--- @param value number
local function OnScrollValueChanged(slider, value)
	--- @class ClickedTreeGroup
	local self = slider.obj --- @diagnostic disable-line: undefined-field

	if self.blockUpdate then
		return
	end

	local status = self.status or self.localstatus
	status.scrollValue = math.floor(value + 0.5)

	self:RefreshTree()
	AceGUI:ClearFocus()
end

--- @param frame Frame
local function Tree_OnSizeChanged(frame)
	--- @class ClickedTreeGroup
	local self = frame.obj --- @diagnostic disable-line: undefined-field

	self:RefreshTree()
end

--- @param frame Frame
--- @param delta number
local function Tree_OnMouseWheel(frame, delta)
	--- @class ClickedTreeGroup
	local self = frame.obj --- @diagnostic disable-line: undefined-field

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

--- @class ClickedTreeGroup : AceGUIContainer
--- @field private status? ClickedTreeGroupStatus
--- @field private localstatus ClickedTreeGroupStatus
--- @field private tree? ClickedTreeGroupRuntimeItem[]
--- @field private treeLookup { [integer]: ClickedTreeGroupRuntimeItem }
--- @field private sortMethod? fun(left: ClickedTreeGroupItem, right: ClickedTreeGroupItem): boolean
--- @field private filter? string
--- @field private scrollbar Slider
--- @field private border Frame|BackdropTemplate
--- @field private showScroll? boolean
--- @field private treeFrame Frame|BackdropTemplate
--- @field private lines ClickedTreeGroupRuntimeItem[]
--- @field private buttons ClickedTreeGroupButton[]
--- @field private blockUpdate? boolean
--- @field private dragging? boolean
local Methods = {}

--- @protected
function Methods:OnAcquire()
	self.frame:SetScript("OnUpdate", FirstFrameUpdate)
end

--- @protected
function Methods:OnRelease()
	self.status = nil
	self.tree = nil
	self.dragging = nil
	self.sortMethod = nil
	self.filter = nil
	self.frame:SetScript("OnUpdate", nil)
	self.localstatus = { selected = {}, dragging = {}, scrollValue = 0 }

	table.wipe(self.lines)
	table.wipe(self.treeLookup)
end

--- @private
--- @return ClickedTreeGroupButton
function Methods:CreateButton()
	local num = AceGUI:GetNextWidgetNum("ClickedTreeGroup2Button")

	local button = CreateFrame("Button", ("ClickedTree2Button%d"):format(num), self.treeFrame, "OptionsListButtonTemplate") --[[@as ClickedTreeGroupButton]]
	button:RegisterForDrag("LeftButton")
	button:SetMovable(true)
	button.obj = self

	local icon = button:CreateTexture(nil, "OVERLAY")
	icon:SetWidth(26)
	icon:SetHeight(26)
	icon:SetPoint("TOPLEFT", 8, 0)
	button.icon = icon

	local title = button.text --- @diagnostic disable-line: undefined-field
	title:SetHeight(14)
	button.title = title

	local subtitle = button:CreateFontString(nil, "OVERLAY", "GameTooltipText")
	subtitle:SetHeight(14) -- Prevents text wrapping
	subtitle:SetFont("Fonts\\FRIZQT__.TTF", 10)
	button.subtitle = subtitle

	button:SetHeight(28)

	button:SetScript("OnClick",Button_OnClick)
	button:SetScript("OnDoubleClick", Button_OnDoubleClick)
	button:SetScript("OnEnter",Button_OnEnter)
	button:SetScript("OnLeave",Button_OnLeave)
	button:SetScript("OnDragStart", Button_OnDragStart)
	button:SetScript("OnDragStop", Button_OnDragStop)
	button:SetScript("OnHide", Button_OnHide)

	button.toggle.button = button --- @diagnostic disable-line: inject-field
	button.toggle:SetScript("OnClick",Expand_OnClick)

	return button
end

--- @param status? ClickedTreeGroupStatus
function Methods:SetStatusTable(status)
	self.status = status

	if status ~= nil then
		status.selected = status.selected or {}
		status.dragging = status.dragging or {}
		status.scrollValue = status.scrollValue or 0
	end
end

--- @param method fun(left: ClickedTreeGroupItem, right: ClickedTreeGroupItem): boolean
function Methods:SetSortMethod(method)
	self.sortMethod = method
end

--- @param filter? string
function Methods:SetFilter(filter)
	self.filter = filter ~= nil and string.lower(filter) or nil

	self:UpdateTreeItems(self.tree)
end

--- @param tree ClickedTreeGroupItem[]
function Methods:SetTree(tree)
	self.tree = tree

	table.wipe(self.treeLookup)

	self:UpdateTreeItems(tree)
end

--- @param scrollToSelection? boolean
--- @param fromOnUpdate? boolean
function Methods:RefreshTree(scrollToSelection, fromOnUpdate)
	local buttons = self.buttons

	for i = 1, #buttons do
		if not self.dragging or not buttons[i]:IsDragging() then
			buttons[i]:Hide()
		end
	end

	local tree = self.tree
	if tree == nil then
		return
	end

	local status = self.status or self.localstatus
	status.scrollToSelection = status.scrollToSelection or scrollToSelection

	if not fromOnUpdate and self.frame:GetScript("OnUpdate") ~= nil then
		return
	end

	if self.frame:GetParent() == UIParent and not fromOnUpdate then
		self.frame:SetScript("OnUpdate", FirstFrameUpdate)
		return
	end

	self:UpdateLines()

	local lines = self.lines

	local numlines = #self.lines
	local maxlines = math.floor(((self.treeFrame:GetHeight() or 0) - 20) / 28)

	if maxlines <= 0 then
		return
	end

	--- @type integer
	local first

	--- @type integer
	local last

	scrollToSelection = status.scrollToSelection
	status.scrollToSelection = nil

	if numlines <= maxlines then
		status.scrollValue = 0
		self:ShowScroll(false)

		first = 1
		last = numlines
	else
		self:ShowScroll(true)

		self.blockUpdate = true
		self.scrollbar:SetMinMaxValues(0, numlines - maxlines)

		if numlines - status.scrollValue < maxlines then
			status.scrollValue = numlines - maxlines
		end

		self.blockUpdate = nil

		first = status.scrollValue + 1
		last = status.scrollValue + maxlines

		if scrollToSelection and #status.selected > 0 then
			--- @type integer?
			local target = self:FindLineIndex(status.selected[#status.selected])

			if target ~= nil and (target < first or target > last) then
				if target < first then
					status.scrollValue = target - 1
				else
					status.scrollValue = target - maxlines
				end

				first = status.scrollValue + 1
				last = status.scrollValue + maxlines
			end
		end

		if self.scrollbar:GetValue() ~= status.scrollValue then
			self.scrollbar:SetValue(status.scrollValue)
		end
	end

	--- @type Button
	local previousButton = nil
	local nextButton = 1
	local nextLine = first

	--- @return ClickedTreeGroupRuntimeItem?
	local function GetNextUndraggedLine()
		local line = lines[nextLine]

		if not self.dragging then
			nextLine = nextLine + 1
			return line
		end

		while line ~= nil and tContains(status.dragging, line.uid) do
			nextLine = nextLine + 1
			line = lines[nextLine]
		end

		nextLine = nextLine + 1
		return line
	end

	--- @return ClickedTreeGroupButton
	local function GetButton()
		local button = buttons[nextButton]

		if self.dragging then
			while button ~= nil and button:IsDragging() do
				nextButton = nextButton + 1
				button = buttons[nextButton]
			end
		end

		if button == nil then
			button = self:CreateButton()
			buttons[nextButton] = button
			button:SetParent(self.treeFrame --[[@as Frame]])
		end

		nextButton = nextButton + 1
		return button
	end

	if self.dragging then
		--- @type integer
		local draggingUid = nil

		--- @type Button
		local previous = nil

		for i = 1, #self.buttons do
			if self.buttons[i]:IsDragging() then
				previous = self.buttons[i]
				draggingUid = previous.uid
				break
			end
		end

		if previous ~= nil then
			local index = 1

			for _, uid in ipairs(self.status.dragging) do
				local line = self.treeLookup[uid]

				if line ~= nil and line.uid ~= draggingUid then
					local button = GetButton()

					button:SetFrameLevel(self.treeFrame:GetFrameLevel() + math.min(#self.status.dragging, MAX_FLOATING_BUTTONS) + 2 - index)

					button:SetAlpha(0.5 - (index * 0.15))
					button:ClearAllPoints()
					button:SetPoint("TOPLEFT", previous, "TOPLEFT", 2, -2)
					button:SetPoint("TOPRIGHT", previous, "TOPRIGHT", 2, -2)

					self:UpdateButton(button, line)

					button.toggle:Hide()
					button:Show()

					previous = button
					index = index + 1
				end

				-- Only show three floating buttons at most
				if index > 3 then
					break
				end
			end
		end
	end

	for _ = first, last do
		local line = GetNextUndraggedLine()
		if line == nil then
			break
		end

		local button = GetButton()

		button:SetFrameLevel(self.treeFrame:GetFrameLevel() + 1)
		button:SetAlpha(1)
		button:ClearAllPoints()

		if previousButton == nil then
			if self.showScroll then
				button:SetPoint("TOPRIGHT", -22, -10)
				button:SetPoint("TOPLEFT", 0, -10)
			else
				button:SetPoint("TOPRIGHT", 0, -10)
				button:SetPoint("TOPLEFT", 0, -10)
			end
		else
			button:SetPoint("TOPRIGHT", previousButton, "BOTTOMRIGHT", 0, 0)
			button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, 0)
		end

		previousButton = button

		self:UpdateButton(button, line)
		button:Show()
	end
end

--- @param uid integer|integer[]
--- @param force? boolean
function Methods:Select(uid, force)
	local status = self.status or self.localstatus

	--- @type integer[]
	local selected = type(uid) == "table" and uid or { uid }

	if force or not Addon:TableEquivalent(status.selected, selected) then
		status.selected = selected

		self:RefreshTree(true)
		self:Fire("OnGroupSelected", selected)
	end
end

--- @param uid integer|integer[]
function Methods:AddSelection(uid)
	local status = self.status or self.localstatus

	--- @type integer[]
	local selected = type(uid) == "table" and uid or { uid }
	local changed = false

	for _, selectedUid in ipairs(selected) do
		if not tContains(status.selected, selectedUid) then
			table.insert(status.selected, selectedUid)
			changed = true
		end
	end

	if changed then
		self:RefreshTree()
		self:Fire("OnGroupSelected", status.selected)
	end
end

--- @param uid integer|integer[]
function Methods:RemoveSelection(uid)
	local status = self.status or self.localstatus

	--- @type integer[]
	local removed = type(uid) == "table" and uid or { uid }
	local changed = false

	for i = #status.selected, 1, -1 do
		if tContains(removed, status.selected[i]) then
			table.remove(status.selected, i)
			changed = true
		end
	end

	if changed then
		self:RefreshTree()
		self:Fire("OnGroupSelected", status.selected)
	end
end

--- @private
function Methods:UpdateLines()
	table.wipe(self.lines)

	local tree = self.tree
	if tree == nil then
		return
	end

	--- @param children ClickedTreeGroupRuntimeItem[]
	local function BuildLevel(children)
		for _, item in ipairs(children) do
			if item.children == nil and not item.isFiltered then
				table.insert(self.lines, item)
			elseif item.children ~= nil and (item.level == 1 or not item.isFiltered or item.isAnyChildVisible) then
				table.insert(self.lines, item)

				if not item.isFolded then
					if self.sortMethod ~= nil then
						table.sort(item.children, self.sortMethod)
					end

					BuildLevel(item.children)
				end
			end
		end
	end

	if self.sortMethod ~= nil then
		table.sort(tree, self.sortMethod)
	end

	BuildLevel(tree)
end

--- @private
--- @param button ClickedTreeGroupButton
--- @param line ClickedTreeGroupRuntimeItem
function Methods:UpdateButton(button, line)
	local status = self.status or self.localstatus

	button.uid = line.uid

	if tContains(status.selected, line.uid) then
		button:LockHighlight()
		button.selected = true
	else
		button:UnlockHighlight()
		button.selected = false
	end

	button:SetNormalFontObject("GameFontNormal")
	button:SetHighlightFontObject("GameFontHighlight")

	local inset = 8 * (line.level - 1)

	if line.level == 1 then
		button:EnableMouse(false)

		button.title:ClearAllPoints()
		button.title:SetPoint("LEFT", 8, -1)
		button.title:SetText(line.title)

		button.subtitle:Hide()
	else
		button:EnableMouse(true)

		button.title:ClearAllPoints()
		button.title:SetPoint("TOPLEFT", (line.icon and 28 or 0) + inset, -1)
		button.title:SetText(line.title)

		button.subtitle:SetPoint("BOTTOMLEFT", (line.icon and 28 or 0) + inset, 1)
		button.subtitle:SetText(line.subtitle)
		button.subtitle:Show()
	end

	local disabled = false

	if line.level > 1 then
		if line.children ~= nil then
			disabled = not line.isAnyChildEnabled
		else
			disabled = not line.enabled
		end
	end

	if disabled then
		button.title:SetTextColor(GREY_FONT_COLOR.r, GREY_FONT_COLOR.g, GREY_FONT_COLOR.b, GREY_FONT_COLOR.a)
		button.subtitle:SetTextColor(GREY_FONT_COLOR.r, GREY_FONT_COLOR.g, GREY_FONT_COLOR.b, GREY_FONT_COLOR.a)
	else
		button.title:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.a)
		button.subtitle:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.a)
	end

	if line.icon ~= nil then
		if disabled then
			button.icon:SetVertexColor(GREY_FONT_COLOR.r, GREY_FONT_COLOR.g, GREY_FONT_COLOR.b, GREY_FONT_COLOR.a)
		else
			button.icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
		end

		button.icon:SetDesaturated(disabled)
		button.icon:SetTexture(line.icon)
		button.icon:SetPoint("TOPLEFT", inset, 1)
	else
		button.icon:SetTexture(nil)
	end

	if line.children ~= nil then
		if line.isFolded then
			button.toggle:SetNormalTexture(130838) -- Interface\\Buttons\\UI-PlusButton-UP
			button.toggle:SetPushedTexture(130836) -- Interface\\Buttons\\UI-PlusButton-DOWN
		else
			button.toggle:SetNormalTexture(130821) -- Interface\\Buttons\\UI-MinusButton-UP
			button.toggle:SetPushedTexture(130820) -- Interface\\Buttons\\UI-MinusButton-DOWN
		end

		button.toggle:Show()
	else
		button.toggle:Hide()
	end
end

--- @private
--- @param tree? ClickedTreeGroupRuntimeItem[]
--- @param level? integer
--- @param parent? ClickedTreeGroupRuntimeItem
function Methods:UpdateTreeItems(tree, level, parent)
	if tree == nil then
		return
	end

	level = level or 1

	local isAnyChildVisible = false
	local isAnyChildEnabled = false

	for _, item in ipairs(tree) do
		item.level = level
		item.parent = parent
		item.isFiltered = self:IsFiltered(item)

		self.treeLookup[item.uid] = item

		isAnyChildVisible = isAnyChildVisible or not item.isFiltered
		isAnyChildEnabled = isAnyChildEnabled or item.enabled or false

		if item.children ~= nil then
			if item.isFolded == nil then
				item.isFolded = level > 1
			end

			self:UpdateTreeItems(item.children, level + 1, item)
		end
	end

	if parent ~= nil then
		parent.isAnyChildVisible = isAnyChildVisible
		parent.isAnyChildEnabled = isAnyChildEnabled
	end
end

--- @private
--- @param uid integer
--- @return integer?
function Methods:FindLineIndex(uid)
	for i, line in ipairs(self.lines) do
		if line.uid == uid then
			return i
		end
	end

	return nil
end

--- @private
--- @param item ClickedTreeGroupRuntimeItem
--- @return boolean
function Methods:IsFiltered(item)
	if self.filter == item.lastFilter then
		return item.isFiltered
	end

	item.lastFilter = self.filter

	if Addon:IsNilOrEmpty(self.filter) then
		return false
	end

	--- @param fields string[]
	--- @return boolean
	local function Find(fields)
		for _, str in ipairs(fields) do
			if not Addon:IsNilOrEmpty(str) and string.find(string.lower(str), self.filter, 1, true) ~= nil then
				return false
			end
		end

		return true
	end

	return Find({
		item.title,
		item.subtitle,
--@debug@
		tostring(item.uid),
--@end-debug@
	})
end

--- @private
function Methods:ShowScroll(show)
	self.showScroll = show

	local button = nil

	for i = 1, #self.buttons do
		local btn = self.buttons[i]

		if btn:IsEnabled() and btn:IsShown() and not btn:IsDragging() then
			button = btn
			break
		end
	end

	if show then
		self.scrollbar:Show()

		if button ~= nil then
			button:SetPoint("TOPRIGHT", self.treeFrame, "TOPRIGHT", -22, -10)
		end
	else
		self.scrollbar:Hide()

		if button ~= nil then
			button:SetPoint("TOPRIGHT", self.treeFrame, "TOPRIGHT", 0, -10)
		end
	end
end

--- @protected
function Methods:OnWidthSet(width)
	local content = self.content
	local contentwidth = width - self.treeFrame:GetWidth() - 20

	if contentwidth < 0 then
		contentwidth = 0
	end

	content:SetWidth(contentwidth)
	content.width = contentwidth --- @diagnostic disable-line: inject-field
end

--- @protected
function Methods:OnHeightSet( height)
	local content = self.content
	local contentheight = height - 20
	if contentheight < 0 then
		contentheight = 0
	end
	content:SetHeight(contentheight)
	content.height = contentheight --- @diagnostic disable-line: inject-field
end

--- @protected
function Methods:LayoutFinished(_, height)
	self:SetHeight((height or 0) + 20)
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

	local treeFrame = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	treeFrame:SetPoint("TOPLEFT")
	treeFrame:SetPoint("BOTTOMLEFT")
	treeFrame:SetWidth(325)
	treeFrame:EnableMouseWheel(true)
	treeFrame:SetBackdrop(PaneBackdrop)
	treeFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	treeFrame:SetBackdropBorderColor(0.4, 0.4, 0.4)
	treeFrame:SetScript("OnSizeChanged", Tree_OnSizeChanged)
	treeFrame:SetScript("OnMouseWheel", Tree_OnMouseWheel)

	local scrollbar = CreateFrame("Slider", ("AceConfigDialogTreeGroup%dScrollBar"):format(num), treeFrame, "UIPanelScrollBarTemplate")
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

	local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	border:SetPoint("TOPLEFT", treeFrame, "TOPRIGHT")
	border:SetPoint("BOTTOMRIGHT")
	border:SetBackdrop(PaneBackdrop)
	border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	border:SetBackdropBorderColor(0.4, 0.4, 0.4)

	--Container Support
	local content = CreateFrame("Frame", nil, border)
	content:SetPoint("TOPLEFT", 10, -10)
	content:SetPoint("BOTTOMRIGHT", -10, 10)

	--- @type ClickedTreeGroup
	local widget = {
		frame = frame,
		lines = {},
		buttons = {},
		treeLookup = {},
		localstatus = { selected = {}, dragging = {}, scrollValue = 0 },
		treeFrame = treeFrame,
		scrollbar = scrollbar --[[@as Slider]],
		border = border,
		content = content,
		type = Type
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	treeFrame.obj, scrollbar.obj = widget, widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

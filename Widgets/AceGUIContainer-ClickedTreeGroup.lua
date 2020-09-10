--[[-----------------------------------------------------------------------------
Clicked TreeGroup Container
Container that uses a tree control to switch between groups.
-------------------------------------------------------------------------------]]
local Type, Version = "ClickedTreeGroup", 2

local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local next, pairs, ipairs, assert, type = next, pairs, ipairs, assert, type
local floor = floor
local tremove, unpack = table.remove, unpack

-- WoW APIs
local UIParent = UIParent

-- Global vars/functions that we don't upvalue since they might get hooked, or upgraded
-- List them here for Mikk's FindGlobals script
-- GLOBALS: FONT_COLOR_CODE_CLOSE

-- Recycling functions
local new, del
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

local DEFAULT_TREE_WIDTH = 210
local DEFAULT_TREE_SIZABLE = false

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function GetButtonUniqueValue(line)
	local parent = line.parent
	if parent and parent.value then
		return GetButtonUniqueValue(parent).."\001"..line.value
	else
		return line.value
	end
end

local function UpdateButton(button, treeline, selected, canExpand, isExpanded)
	local toggle = button.toggle
	local text1 = treeline.text1 or ""
	local text2 = treeline.text2 or ""
	local text3 = treeline.text3 or ""
	local icon = treeline.icon
	local iconCoords = treeline.iconCoords
	local level = treeline.level
	local value = treeline.value
	local uniquevalue = treeline.uniquevalue
	local disabled = treeline.disabled

	button.treeline = treeline
	button.value = value
	button.uniquevalue = uniquevalue
	if selected then
		button:LockHighlight()
		button.selected = true
	else
		button:UnlockHighlight()
		button.selected = false
	end
	button.level = level
	if ( level == 1 ) then
		button:SetNormalFontObject("GameFontNormal")
		button:SetHighlightFontObject("GameFontHighlight")
		button.text1:SetPoint("TOPLEFT", (icon and 28 or 0) + 8, -1)
		button.text2:SetPoint("BOTTOMLEFT", (icon and 28 or 0) + 8, 1)
		button.text3:SetPoint("BOTTOMRIGHT", -8, 1)
	else
		button:SetNormalFontObject("GameFontHighlightSmall")
		button:SetHighlightFontObject("GameFontHighlightSmall")
		button.text1:SetPoint("TOPLEFT", (icon and 28 or 0) + 8 * level, -1)
		button.text2:SetPoint("BOTTOMLEFT", (icon and 28 or 0) + 8 * level, 1)
		button.text3:SetPoint("BOTTOMRIGHT", -8 * level, 1)
	end

	if disabled then
		button:EnableMouse(false)
		button.text1:SetText("|cff808080"..text1..FONT_COLOR_CODE_CLOSE)
		button.text2:SetText("|cff808080"..text2..FONT_COLOR_CODE_CLOSE)
		button.text3:SetText("|cff808080"..text3..FONT_COLOR_CODE_CLOSE)
	else
		button.text1:SetText(text1)
		button.text2:SetText(text2)
		button.text3:SetText(text3)
		button:EnableMouse(true)
	end

	if icon then
		button.icon:SetTexture(icon)
		button.icon:SetPoint("LEFT", 8 * level, (level == 1) and 0 or 1)
	else
		button.icon:SetTexture(nil)
	end

	if iconCoords then
		button.icon:SetTexCoord(unpack(iconCoords))
	else
		button.icon:SetTexCoord(0, 1, 0, 1)
	end

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

local function ShouldDisplayLevel(tree)
	local result = false
	for k, v in ipairs(tree) do
		if v.children == nil and v.visible ~= false then
			result = true
		elseif v.children then
			result = result or ShouldDisplayLevel(v.children)
		end
		if result then return result end
	end
	return false
end

local function addLine(self, v, tree, level, parent)
	local line = new()
	line.value = v.value
	line.text1 = v.text1
	line.text2 = v.text2
	line.text3 = v.text3
	line.icon = v.icon
	line.iconCoords = v.iconCoords
	line.disabled = v.disabled
	line.tree = tree
	line.level = level
	line.parent = parent
	line.visible = v.visible
	line.uniquevalue = GetButtonUniqueValue(line)
	if v.children then
		line.hasChildren = true
	else
		line.hasChildren = nil
	end
	self.lines[#self.lines+1] = line
	return line
end

--fire an update after one frame to catch the treeframes height
local function FirstFrameUpdate(frame)
	local self = frame.obj
	frame:SetScript("OnUpdate", nil)
	self:RefreshTree(nil, true)
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Button_OnEnter(frame)
	local self = frame.obj
	self:Fire("OnButtonEnter", frame.uniquevalue, frame)

	if self.enabletooltips then
		local tooltip = AceGUI.tooltip
		tooltip:SetOwner(frame, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint("LEFT",frame,"RIGHT")
		tooltip:SetText(frame.tooltipText or frame.text1:GetText() or "", 1, .82, 0, true)

		tooltip:Show()
	end
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:TreeOnAcquire()
		self:SetTreeWidth(DEFAULT_TREE_WIDTH, DEFAULT_TREE_SIZABLE)
	end,

	["OnRelease"] = function(self)
		self:TreeOnRelease()

		self.localstatus.treewidth = DEFAULT_TREE_WIDTH
		self.localstatus.treesizable = DEFAULT_TREE_SIZABLE
	end,

	["CreateButton"] = function(self)
		local button = self:TreeCreateButton()

		button:SetHeight(28)
		button:SetScript("OnEnter",Button_OnEnter)

		local icon = button.icon
		icon:SetWidth(26)
		icon:SetHeight(26)
		icon:SetPoint("TOPLEFT", 8, 0)

		local text1 = button.text
		text1:SetHeight(14) -- Prevents text wrapping
		button.text1 = text1

		local text2 = button:CreateFontString(button, "OVERLAY", "GameTooltipText")
		text2:SetHeight(14) -- Prevents text wrapping
		text2:SetFont("Fonts\\FRIZQT__.TTF", 10)
		button.text2 = text2

		local text3 = button:CreateFontString(button, "OVERLAY", "GameTooltipText")
		text3:SetHeight(14) -- Prevents text wrapping
		text3:SetFont("Fonts\\FRIZQT__.TTF", 10)
		button.text3 = text3

		return button
	end,

	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")

		if not status.treewidth then
			status.treewidth = DEFAULT_TREE_WIDTH
		end

		if status.treesizable == nil then
			status.treesizable = DEFAULT_TREE_SIZABLE
		end

		self:TreeSetStatusTable(status)
	end,

	["BuildLevel"] = function(self, tree, level, parent)
		local groups = (self.status or self.localstatus).groups

		for i, v in ipairs(tree) do
			if v.children then
				if not self.filter or ShouldDisplayLevel(v.children) then
					local line = addLine(self, v, tree, level, parent)
					if groups[line.uniquevalue] then
						self:BuildLevel(v.children, level+1, line)
					end
				end
			elseif v.visible ~= false or not self.filter then
				addLine(self, v, tree, level, parent)
			end
		end
	end,

	["RefreshTree"] = function(self,scrollToSelection,fromOnUpdate)
		local buttons = self.buttons
		local lines = self.lines

		for i, v in ipairs(buttons) do
			v:Hide()
		end
		while lines[1] do
			local t = tremove(lines)
			for k in pairs(t) do
				t[k] = nil
			end
			del(t)
		end

		if not self.tree then return end
		--Build the list of visible entries from the tree and status tables
		local status = self.status or self.localstatus
		local groupstatus = status.groups
		local tree = self.tree

		local treeframe = self.treeframe

		status.scrollToSelection = status.scrollToSelection or scrollToSelection	-- needs to be cached in case the control hasn't been drawn yet (code bails out below)

		self:BuildLevel(tree, 1)

		local numlines = #lines

		local maxlines = (floor(((self.treeframe:GetHeight()or 0) - 20 ) / 28))
		if maxlines <= 0 then return end

		if self.frame:GetParent() == UIParent and not fromOnUpdate then
			self.frame:SetScript("OnUpdate", FirstFrameUpdate)
			return
		end

		local first, last

		scrollToSelection = status.scrollToSelection
		status.scrollToSelection = nil

		if numlines <= maxlines then
			--the whole tree fits in the frame
			status.scrollvalue = 0
			self:ShowScroll(false)
			first, last = 1, numlines
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
			first, last = status.scrollvalue+1, status.scrollvalue + maxlines
			--show selection?
			if scrollToSelection and status.selected then
				local show
				for i,line in ipairs(lines) do	-- find the line number
					if line.uniquevalue==status.selected then
						show=i
					end
				end
				if not show then
					-- selection was deleted or something?
				elseif show>=first and show<=last then
					-- all good
				else
					-- scrolling needed!
					if show<first then
						status.scrollvalue = show-1
					else
						status.scrollvalue = show-maxlines
					end
					first, last = status.scrollvalue+1, status.scrollvalue + maxlines
				end
			end
			if self.scrollbar:GetValue() ~= status.scrollvalue then
				self.scrollbar:SetValue(status.scrollvalue)
			end
		end

		local buttonnum = 1
		for i = first, last do
			local line = lines[i]
			local button = buttons[buttonnum]
			if not button then
				button = self:CreateButton()

				buttons[buttonnum] = button
				button:SetParent(treeframe)
				button:SetFrameLevel(treeframe:GetFrameLevel()+1)
				button:ClearAllPoints()
				if buttonnum == 1 then
					if self.showscroll then
						button:SetPoint("TOPRIGHT", -22, -10)
						button:SetPoint("TOPLEFT", 0, -10)
					else
						button:SetPoint("TOPRIGHT", 0, -10)
						button:SetPoint("TOPLEFT", 0, -10)
					end
				else
					button:SetPoint("TOPRIGHT", buttons[buttonnum-1], "BOTTOMRIGHT",0,0)
					button:SetPoint("TOPLEFT", buttons[buttonnum-1], "BOTTOMLEFT",0,0)
				end
			end

			UpdateButton(button, line, status.selected == line.uniquevalue, line.hasChildren, groupstatus[line.uniquevalue] )
			button:Show()
			buttonnum = buttonnum + 1
		end
	end,

	["SetTreeWidth"] = function(self, treewidth, resizable)
		if not resizable then
			if type(treewidth) == 'number' then
				resizable = false
			elseif type(treewidth) == 'boolean' then
				resizable = treewidth
				treewidth = DEFAULT_TREE_WIDTH
			else
				resizable = false
				treewidth = DEFAULT_TREE_WIDTH
			end
		end
		self.treeframe:SetWidth(treewidth)
		self.dragger:EnableMouse(resizable)

		local status = self.status or self.localstatus
		status.treewidth = treewidth
		status.treesizable = resizable

		-- recalculate the content width
		if status.fullwidth then
			self:OnWidthSet(status.fullwidth)
		end
	end,

	["GetTreeWidth"] = function(self)
		local status = self.status or self.localstatus
		return status.treewidth or DEFAULT_TREE_WIDTH
	end,
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local tree = AceGUI:Create("TreeGroup")
	tree.type = Type
	tree.treeframe:SetWidth(DEFAULT_TREE_WIDTH)

	tree.TreeOnAcquire = tree.OnAcquire
	tree.TreeOnRelease = tree.OnRelease
	tree.TreeCreateButton = tree.CreateButton
	tree.TreeSetStatusTable = tree.SetStatusTable

	for method, func in pairs(methods) do
		tree[method] = func
	end

	return tree
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

--[[-----------------------------------------------------------------------------
Clicked TreeGroup Container
Container that uses a tree control to switch between groups.
-------------------------------------------------------------------------------]]

local Type, Version = "ClickedTreeGroup", 3
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

local KEYBIND_ORDER_LIST = {
	"BUTTON1", "BUTTON2", "BUTTON3", "BUTTON4", "BUTTON5", "MOUSEWHEELUP", "MOUSEWHEELDOWN",
	"`", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
	"NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS", "NUMPADPLUS", "NUMPADDECIMAL",
	"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"TAB", "CAPSLOCK", "INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN", "[", "]", "\\", ";", "'", ",", ".", "/"
}

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

local DEFAULT_TREE_WIDTH = 300
local DEFAULT_TREE_SIZABLE = false

local contextMenuFrame = CreateFrame("Frame", "ClickedContextMenu", UIParent, "UIDropDownMenuTemplate")

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function GetKeybindIndex(keybind)
	local mods = {}
	local result = ""

	for match in string.gmatch(keybind, "[^-]+") do
		table.insert(mods, match)
		result = match
	end

	table.remove(mods, #mods)

	local index = #KEYBIND_ORDER_LIST + 1
	local found = false

	for i = 1, #KEYBIND_ORDER_LIST do
		if KEYBIND_ORDER_LIST[i] == result then
			index = i
			found = true
			break
		end
	end

	-- register this unknown keybind for this session
	if not found then
		table.insert(KEYBIND_ORDER_LIST, result)
	end

	for i = 1, #mods do
		if mods[i] == "CTRL" then
			index = index + 1000
		end

		if mods[i] == "ALT" then
			index = index + 10000
		end

		if mods[i] == "SHIFT" then
			index = index + 100000
		end
	end

	return index
end

local function TreeSortFunc(left, right)
	if left.binding.keybind == "" and right.binding.keybind ~= "" then
		return false
	end

	if left.binding.keybind ~= "" and right.binding.keybind == "" then
		return true
	end

	if left.binding.keybind == "" and right.binding.keybind == "" then
		return left.value < right.value
	end

	if left.binding.keybind == right.binding.keybind then
		return left.value < right.value
	end

	return GetKeybindIndex(left.binding.keybind) < GetKeybindIndex(right.binding.keybind)
end

local function UpdateItemVisual(item, binding)
	local data = Clicked:GetActiveBindingAction(binding)

	local label = ""
	local icon = ""

	if binding.type == Clicked.BindingTypes.SPELL then
		label = L["BINDING_UI_TREE_LABEL_CAST"]
		icon = select(3, GetSpellInfo(data.value))
	elseif binding.type == Clicked.BindingTypes.ITEM then
		label = L["BINDING_UI_TREE_LABEL_USE"]
		icon = select(10, GetItemInfo(data.value))
	elseif binding.type == Clicked.BindingTypes.MACRO then
		label = L["BINDING_UI_TREE_LABEL_RUN_MACRO"]

		if #data.displayName > 0 then
			label = data.displayName
		end
	elseif binding.type == Clicked.BindingTypes.UNIT_SELECT then
		label = L["BINDING_UI_TREE_LABEL_TARGET_UNIT"]
	elseif binding.type == Clicked.BindingTypes.UNIT_MENU then
		label = L["BINDING_UI_TREE_LABEL_UNIT_MENU"]
	end

	if data.value ~= nil then
		item.title = string.format(label, data.value)
	else
		item.title = label
	end

	if icon ~= nil and #tostring(icon) > 0 then
		item.icon = icon
	elseif data.displayIcon ~= nil and #tostring(data.displayIcon) > 0 then
		item.icon = data.displayIcon
	end

	data.displayName = item.title
	data.displayIcon = item.icon

	item.keybind = #binding.keybind > 0 and binding.keybind or L["BINDING_UI_TREE_KEYBIND_UNBOUND"]
end

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
	local title = treeline.title or ""
	local keybind = treeline.keybind or ""
	local icon = treeline.icon
	local iconCoords = treeline.iconCoords
	local level = treeline.level
	local value = treeline.value
	local uniquevalue = treeline.uniquevalue
	local disabled = treeline.disabled
	local binding = treeline.binding

	button.treeline = treeline
	button.value = value
	button.uniquevalue = uniquevalue
	button.binding = binding

	if selected then
		button:LockHighlight()
		button.selected = true
	else
		button:UnlockHighlight()
		button.selected = false
	end
	button.level = level

	button:SetNormalFontObject("GameFontNormal")
	button:SetHighlightFontObject("GameFontHighlight")

	local format = "%s"

	if disabled then
		button:EnableMouse(false)
		format = "|cff808080%s" .. FONT_COLOR_CODE_CLOSE
	else
		button:EnableMouse(true)
	end

	button.title:ClearAllPoints()
	button.title:SetPoint("TOPLEFT", (icon and 28 or 0) + 8 * level, -1)
	button.title:SetText(string.format(format, title))

	button.keybind:SetPoint("BOTTOMLEFT", (icon and 28 or 0) + 8 * level, 1)
	button.keybind:SetText(string.format(format, keybind))
	button.keybind:Show()

	if icon then
		button.icon:SetTexture(icon)
		button.icon:SetPoint("TOPLEFT", 8 * level, 1)
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
	line.binding = v.binding
	line.title = v.title
	line.keybind = v.keybind
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

local function BuildUniqueValue(...)
	local n = select('#', ...)
	if n == 1 then
		return ...
	else
		return (...).."\001"..BuildUniqueValue(select(2,...))
	end
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Expand_OnClick(frame)
	local button = frame.button
	local self = button.obj
	local status = (self.status or self.localstatus).groups
	status[button.uniquevalue] = not status[button.uniquevalue]
	self:RefreshTree()
end

local function Button_OnClick(frame, button)
	local self = frame.obj

	if button == "LeftButton" then
		self:Fire("OnClick", frame.uniquevalue, frame.selected)
		if not frame.selected then
			self:SetSelected(frame.uniquevalue)
			frame.selected = true
			frame:LockHighlight()
			self:RefreshTree()
		end
		AceGUI:ClearFocus()
	elseif button == "RightButton" then
		local inCombat = InCombatLockdown()

		local menu = {
			{
				text = L["BINDING_UI_BUTTON_COPY"],
				notCheckable = true,
				disabled = inCombat,
				func = function()
					self.bindingCopyBuffer = Clicked:DeepCopyTable(frame.binding)
				end
			},
			{
				text = L["BINDING_UI_BUTTON_PASTE"],
				notCheckable = true,
				disabled = inCombat or self.bindingCopyBuffer == nil,
				func = function()
					local clone = Clicked:DeepCopyTable(self.bindingCopyBuffer)
					clone.keybind = frame.binding.keybind

					Clicked:SetBindingAt(frame.value, clone)
				end
			},
			{
				text = L["BINDING_UI_BUTTON_DUPLICATE"],
				notCheckable = true,
				disabled = inCombat,
				func = function()
					local clone = Clicked:DeepCopyTable(frame.binding)
					clone.keybind = ""

					local index = Clicked:GetNumConfiguredBindings() + 1
					Clicked:SetBindingAt(index, clone)

					self:SelectByValue(index)
				end
			},
			{
				text = L["BINDING_UI_BUTTON_DELETE"],
				notCheckable = true,
				disabled = inCombat,
				func = function()
					local function OnConfirm()
						if InCombatLockdown() then
							print(L["MSG_BINDING_UI_READ_ONLY_MODE"])
							return
						end

						local next = nil

						if self:GetSelectedBinding() == frame.binding then
							local index = nil

							for i, e in ipairs(self.tree) do
								if e.binding == frame.binding then
									index = i
									break
								end
							end

							if index + 1 <= #self.tree then
								next = self.tree[index + 1].binding
							elseif index - 1 >= 1 then
								next = self.tree[index - 1].binding
							end
						end

						Clicked:DeleteBinding(frame.binding)

						if next ~= nil then
							for _, e in ipairs(self.tree) do
								if e.binding == next then
									self:SelectByValue(e.value)
									break
								end
							end
						end
					end

					if IsShiftKeyDown() then
						OnConfirm()
					else
						local data = Clicked:GetActiveBindingAction(frame.binding)

						local msg = L["BINDING_UI_POPUP_DELETE_BINDING_LINE_1"] .. "\n\n"
						msg = msg .. L["BINDING_UI_POPUP_DELETE_BINDING_LINE_2"]:format(frame.binding.keybind, data.displayName)

						Clicked:ShowConfirmationPopup(msg, function()
							OnConfirm()
						end)
					end
				end
			}
		}

		EasyMenu(menu, contextMenuFrame, frame, 0, 0, "MENU")
	end
end

local function Button_OnDoubleClick(button)
	local self = button.obj
	local status = (self.status or self.localstatus).groups
	status[button.uniquevalue] = not status[button.uniquevalue]
	self:RefreshTree()
end

local function Button_OnEnter(frame)
	local self = frame.obj
	self:Fire("OnButtonEnter", frame.uniquevalue, frame)

	if self.enabletooltips and frame.title ~= nil and frame.binding ~= nil then
		local tooltip = AceGUI.tooltip
		local binding = frame.binding

		local data = Clicked:GetActiveBindingAction(binding)
		local text = data.displayName

		if binding.type == Clicked.BindingTypes.MACRO then
			if #data.displayName > 0 then
				text = data.displayName .. "\n\n"
				text = text .. L["BINDING_UI_TREE_TOOLTIP_MACRO"] .. "\n|cFFFFFFFF"
			else
				text = "";
			end

			text = text .. data.value .. "|r"
		end

		text = text .. "\n\n"

		text = text .. L["BINDING_UI_TREE_TOOLTIP_TARGETS"] .. "\n"
		text = text .. "|cFFFFFFFF1. " .. Clicked:GetLocalizedTargetString(binding.primaryTarget)

		for i, target in ipairs(binding.secondaryTargets) do
			text = text .. "\n" .. (i + 1) .. ". " .. Clicked:GetLocalizedTargetString(target)
		end

		text = text .. "|r"

		tooltip:SetOwner(frame, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint("RIGHT", frame, "LEFT")
		tooltip:SetText(text or "", 1, 0.82, 0, 1, true)
		tooltip:Show()
	end
end

local function Button_OnLeave(frame)
	local self = frame.obj
	self:Fire("OnButtonLeave", frame.uniquevalue, frame)

	if self.enabletooltips and frame.title ~= nil then
		local tooltip = AceGUI.tooltip
		tooltip:Hide()
	end
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
	if self.showscroll then
		local scrollbar = self.scrollbar
		local min, max = scrollbar:GetMinMaxValues()
		local value = scrollbar:GetValue()
		local newvalue = math.min(max, math.max(min,value - delta))
		if value ~= newvalue then
			scrollbar:SetValue(newvalue)
		end
	end
end

local function Dragger_OnLeave(frame)
	frame:SetBackdropColor(1, 1, 1, 0)
end

local function Dragger_OnEnter(frame)
	frame:SetBackdropColor(1, 1, 1, 0.8)
end

local function Dragger_OnMouseDown(frame)
	local treeframe = frame:GetParent()
	treeframe:StartSizing("RIGHT")
end

local function Dragger_OnMouseUp(frame)
	local treeframe = frame:GetParent()
	local self = treeframe.obj
	local treeframeParent = treeframe:GetParent()
	treeframe:StopMovingOrSizing()
	--treeframe:SetScript("OnUpdate", nil)
	treeframe:SetUserPlaced(false)
	--Without this :GetHeight will get stuck on the current height, causing the tree contents to not resize
	treeframe:SetHeight(0)
	treeframe:ClearAllPoints()
	treeframe:SetPoint("TOPLEFT", treeframeParent, "TOPLEFT",0,0)
	treeframe:SetPoint("BOTTOMLEFT", treeframeParent, "BOTTOMLEFT",0,0)

	local status = self.status or self.localstatus
	status.treewidth = treeframe:GetWidth()

	treeframe.obj:Fire("OnTreeResize",treeframe:GetWidth())
	-- recalculate the content width
	treeframe.obj:OnWidthSet(status.fullwidth)
	-- update the layout of the content
	treeframe.obj:DoLayout()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetTreeWidth(DEFAULT_TREE_WIDTH, DEFAULT_TREE_SIZABLE)
		self:EnableButtonTooltips(true)
		self.frame:SetScript("OnUpdate", FirstFrameUpdate)
	end,

	["OnRelease"] = function(self)
		self.status = nil
		self.tree = nil
		self.bindingCopyBuffer = nil

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
		self.localstatus.treewidth = DEFAULT_TREE_WIDTH
		self.localstatus.treesizable = DEFAULT_TREE_SIZABLE
	end,

	["EnableButtonTooltips"] = function(self, enable)
		self.enabletooltips = enable
	end,

	["CreateButton"] = function(self)
		local num = AceGUI:GetNextWidgetNum("TreeGroupButton")
		local button = CreateFrame("Button", ("ClickedTreeButton%d"):format(num), self.treeframe, "OptionsListButtonTemplate")
		button.obj = self

		local icon = button:CreateTexture(nil, "OVERLAY")
		icon:SetWidth(26)
		icon:SetHeight(26)
		icon:SetPoint("TOPLEFT", 8, 0)
		button.icon = icon

		local title = button.text
		title:SetHeight(14) -- Prevents text wrapping
		button.title = title
		button.text = nil

		local keybind = button:CreateFontString(button, "OVERLAY", "GameTooltipText")
		keybind:SetHeight(14) -- Prevents text wrapping
		keybind:SetFont("Fonts\\FRIZQT__.TTF", 10)
		button.keybind = keybind

		button:SetHeight(28)

		button:SetScript("OnClick",Button_OnClick)
		button:SetScript("OnDoubleClick", Button_OnDoubleClick)
		button:SetScript("OnEnter",Button_OnEnter)
		button:SetScript("OnLeave",Button_OnLeave)

		button.toggle.button = button
		button.toggle:SetScript("OnClick",Expand_OnClick)

		return button
	end,

	["SetStatusTable"] = function(self, status)
		assert(type(status) == "table")
		self.status = status
		if not status.groups then
			status.groups = {}
		end
		if not status.scrollvalue then
			status.scrollvalue = 0
		end
		if not status.treewidth then
			status.treewidth = DEFAULT_TREE_WIDTH
		end
		if status.treesizable == nil then
			status.treesizable = DEFAULT_TREE_SIZABLE
		end
		self:SetTreeWidth(status.treewidth,status.treesizable)
		self:RefreshTree()
	end,

	["SetSearchHandler"] = function(self, handler)
		if handler == self.searchHandler then
			return
		end

		if self.searchHandler ~= nil then
			self.searchHandler:SetCallback("SearchTermChanged", nil)
		end

		self.searchHandler = handler
		self.searchHandler:SetCallback("SearchTermChanged", function()
			self:RefreshTree()
		end)

		self:RefreshTree()
	end,

	["ConstructTree"] = function(self, filter)
		local status = self.status or self.localstatus
		self.filter = filter
		self.tree = {}

		for index, binding in Clicked:IterateConfiguredBindings() do
			local item = {
				value = index,
				binding = binding,
				icon = "Interface\\ICONS\\INV_Misc_QuestionMark"
			}

			UpdateItemVisual(item, binding)
			table.insert(self.tree, item)
		end

		table.sort(self.tree, TreeSortFunc)

		self:RefreshTree()

		if #self.tree > 0 and status.selected == nil then
			self:SelectByValue(self.tree[1].value)
		elseif #self.tree > 0 and status.selected ~= nil then
			self:SelectByValue(status.selected)
		elseif #self.tree == 0 then
			self:SelectByValue("")
		end
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

		for _, v in ipairs(buttons) do
			v:Hide()
		end

		while lines[1] do
			local t = table.remove(lines)
			for k in pairs(t) do
				t[k] = nil
			end
			del(t)
		end

		if not self.tree then return end

		--Build the list of visible entries from the tree and status tables
		local status = self.status or self.localstatus
		local groupstatus = status.groups
		local tree = {}

		if self.searchHandler ~= nil then
			for _, item in ipairs(self.tree) do
				local data = Clicked:GetActiveBindingAction(item.binding)
				local strings = {}

				table.insert(strings, data.displayName)
				table.insert(strings, data.value)

				if item.binding.keybind ~= "" then
					table.insert(strings, item.binding.keybind)
				end

				for i = 1, #strings do
					if strings[i] ~= nil and strings[i] ~= "" then
						local str = string.lower(strings[i])
						local pattern = string.lower(self.searchHandler.searchTerm)

						if string.find(str, pattern, 1, true) ~= nil then
							table.insert(tree, item)
							break
						end
					end
				end
			end
		else
			tree = self.tree
		end

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

		local buttonNum = 1
		local previous = nil

		for i = first, last do
			local line = lines[i]
			local button = buttons[buttonNum]

			if button == nil then
				button = self:CreateButton()
				buttons[buttonNum] = button

				button:SetParent(treeframe)
				button:SetFrameLevel(treeframe:GetFrameLevel() + 1)
				button:ClearAllPoints()

				if previous == nil then
					if self.showscroll then
						button:SetPoint("TOPRIGHT", -22, -10)
						button:SetPoint("TOPLEFT", 0, -10)
					else
						button:SetPoint("TOPRIGHT", 0, -10)
						button:SetPoint("TOPLEFT", 0, -10)
					end
				else
					button:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT", 0, 0)
					button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
				end
			end

			UpdateButton(button, line, status.selected == line.uniquevalue, line.hasChildren, groupstatus[line.uniquevalue])
			button:Show()

			buttonNum = buttonNum + 1
			previous = button
		end
	end,

	["SetSelected"] = function(self, value)
		local status = self.status or self.localstatus
		if status.selected ~= value then
			status.selected = value
			self:Fire("OnGroupSelected", value)
		end
	end,

	["Select"] = function(self, uniquevalue, ...)
		self.filter = false
		local status = self.status or self.localstatus
		local groups = status.groups
		local path = {...}
		for i = 1, #path do
			groups[table.concat(path, "\001", 1, i)] = true
		end
		status.selected = uniquevalue
		self:RefreshTree(true)
		self:Fire("OnGroupSelected", uniquevalue)
	end,

	["SelectByPath"] = function(self, ...)
		self:Select(BuildUniqueValue(...), ...)
	end,

	["SelectByValue"] = function(self, uniquevalue)
		self:Select(uniquevalue, ("\001"):split(uniquevalue))
	end,

	["SelectByBinding"] = function(self, binding)
		for _, item in ipairs(self.tree) do
			if item.binding == binding then
				self:SelectByValue(item.value)
				return
			end
		end
	end,

	["ShowScroll"] = function(self, show)
		self.showscroll = show
		if show then
			self.scrollbar:Show()
			if self.buttons[1] then
				self.buttons[1]:SetPoint("TOPRIGHT", self.treeframe,"TOPRIGHT",-22,-10)
			end
		else
			self.scrollbar:Hide()
			if self.buttons[1] then
				self.buttons[1]:SetPoint("TOPRIGHT", self.treeframe,"TOPRIGHT",0,-10)
			end
		end
	end,

	["OnWidthSet"] = function(self, width)
		local content = self.content
		local treeframe = self.treeframe
		local status = self.status or self.localstatus
		status.fullwidth = width

		local contentwidth = width - status.treewidth - 20
		if contentwidth < 0 then
			contentwidth = 0
		end
		content:SetWidth(contentwidth)
		content.width = contentwidth

		local maxtreewidth = math.min(400, width - 50)

		if maxtreewidth > 100 and status.treewidth > maxtreewidth then
			self:SetTreeWidth(maxtreewidth, status.treesizable)
		end
		treeframe:SetMaxResize(maxtreewidth, 1600)
	end,

	["OnHeightSet"] = function(self, height)
		local content = self.content
		local contentheight = height - 20
		if contentheight < 0 then
			contentheight = 0
		end
		content:SetHeight(contentheight)
		content.height = contentheight
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

	["GetSelectedBinding"] = function(self)
		local status = self.status or self.localstatus
		local selected = status.selected

		if selected == nil then
			return nil
		end

		local path = { ("\001"):split(selected) }

		if #path > 0 then
			local last = path[#path]
			local value = tonumber(last)

			for i = 1, #self.tree do
				local item = self.tree[i]

				if item.value == value then
					return item.binding
				end
			end
		end

		return nil
	end,

	["GetNeighbouringBinding"] = function(self, offset)
		local status = self.status or self.localstatus
		local selected = status.selected

		if selected == nil then
			return nil
		end

		local path = { ("\001"):split(selected) }

		local function IndexOf(array, value)
			for i = 1, #array do
				local item = array[i]

				if item.value == value then
					return i
				end
			end

			return 0
		end

		return self.tree[IndexOf(self.tree, path[#path]) + offset]
	end,

	["LayoutFinished"] = function(self, width, height)
		if self.noAutoHeight then return end
		self:SetHeight((height or 0) + 20)
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local PaneBackdrop  = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

local DraggerBackdrop  = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = nil,
	tile = true, tileSize = 16, edgeSize = 1,
	insets = { left = 3, right = 3, top = 7, bottom = 7 }
}

local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", nil, UIParent)

	local treeframe = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
	treeframe:SetPoint("TOPLEFT")
	treeframe:SetPoint("BOTTOMLEFT")
	treeframe:SetWidth(DEFAULT_TREE_WIDTH)
	treeframe:EnableMouseWheel(true)
	treeframe:SetBackdrop(PaneBackdrop)
	treeframe:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	treeframe:SetBackdropBorderColor(0.4, 0.4, 0.4)
	treeframe:SetResizable(true)
	treeframe:SetMinResize(100, 1)
	treeframe:SetMaxResize(400, 1600)
	treeframe:SetScript("OnUpdate", FirstFrameUpdate)
	treeframe:SetScript("OnSizeChanged", Tree_OnSizeChanged)
	treeframe:SetScript("OnMouseWheel", Tree_OnMouseWheel)

	local dragger = CreateFrame("Frame", nil, treeframe, BackdropTemplateMixin and "BackdropTemplate" or nil)
	dragger:SetWidth(8)
	dragger:SetPoint("TOP", treeframe, "TOPRIGHT")
	dragger:SetPoint("BOTTOM", treeframe, "BOTTOMRIGHT")
	dragger:SetBackdrop(DraggerBackdrop)
	dragger:SetBackdropColor(1, 1, 1, 0)
	dragger:SetScript("OnEnter", Dragger_OnEnter)
	dragger:SetScript("OnLeave", Dragger_OnLeave)
	dragger:SetScript("OnMouseDown", Dragger_OnMouseDown)
	dragger:SetScript("OnMouseUp", Dragger_OnMouseUp)

	local scrollbar = CreateFrame("Slider", ("AceConfigDialogTreeGroup%dScrollBar"):format(num), treeframe, "UIPanelScrollBarTemplate")
	scrollbar:SetScript("OnValueChanged", nil)
	scrollbar:SetPoint("TOPRIGHT", -10, -26)
	scrollbar:SetPoint("BOTTOMRIGHT", -10, 26)
	scrollbar:SetMinMaxValues(0,0)
	scrollbar:SetValueStep(1)
	scrollbar:SetValue(0)
	scrollbar:SetWidth(16)
	scrollbar:SetScript("OnValueChanged", OnScrollValueChanged)

	local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(scrollbar)
	scrollbg:SetColorTexture(0,0,0,0.4)

	local border = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
	border:SetPoint("TOPLEFT", treeframe, "TOPRIGHT")
	border:SetPoint("BOTTOMRIGHT")
	border:SetBackdrop(PaneBackdrop)
	border:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	border:SetBackdropBorderColor(0.4, 0.4, 0.4)

	--Container Support
	local content = CreateFrame("Frame", nil, border)
	content:SetPoint("TOPLEFT", 10, -10)
	content:SetPoint("BOTTOMRIGHT", -10, 10)

	-- Respect ElvUI skinning
	if GetAddOnEnableState(UnitName("player"), "ElvUI") == 2 then
		local E = unpack(ElvUI);

		if E and E.private.skins and E.private.skins.ace3Enable then
			local S = E:GetModule("Skins")

			content:GetParent():SetTemplate('Transparent')
			treeframe:SetTemplate('Transparent')
			S:HandleScrollBar(scrollbar)
		end
	end

	local widget = {
		frame         = frame,
		lines         = {},
		levels        = {},
		buttons       = {},
		hasChildren   = {},
		localstatus   = { groups = { }, scrollvalue = 0 },
		filter        = false,
		searchHandler = nil,
		treeframe     = treeframe,
		dragger       = dragger,
		scrollbar     = scrollbar,
		border        = border,
		content       = content,
		type          = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end
	treeframe.obj, dragger.obj, scrollbar.obj = widget, widget, widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

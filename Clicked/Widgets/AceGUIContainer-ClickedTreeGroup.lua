--[[-----------------------------------------------------------------------------
Clicked TreeGroup Container
Container that uses a tree control to switch between groups.
-------------------------------------------------------------------------------]]
--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local Type, Version = "ClickedTreeGroup", 3
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

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

local DEFAULT_TREE_WIDTH = 325
local DEFAULT_TREE_SIZABLE = false
local GREY_FONT_COLOR = {r=0.75, g=0.75, b=0.75, a=0.5}

local contextMenuFrame = CreateFrame("Frame", "ClickedContextMenu", UIParent, "UIDropDownMenuTemplate")

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function TreeSortAlphabetical(left, right)
	if left.children ~= nil and right.children == nil then
		return true
	end

	if left.children == nil and right.children ~= nil then
		return false
	end

	if left.children ~= nil and right.children ~= nil then
		local leftHasAnyActive = false
		local rightHasAnyActive = false

		for _, child in Clicked:IterateConfiguredBindings() do
			if child.parent == left.group.identifier and Addon:CanBindingLoad(child) then
				leftHasAnyActive = true
			elseif child.parent == right.group.identifier and Addon:CanBindingLoad(child) then
				rightHasAnyActive = true
			end

			if leftHasAnyActive and rightHasAnyActive then
				break
			end
		end

		if leftHasAnyActive and not rightHasAnyActive then
			return true
		elseif not leftHasAnyActive and rightHasAnyActive then
			return false
		end
	end

	if left.binding ~= nil and right.binding ~= nil then
		local lLoad = Addon:CanBindingLoad(left.binding)
		local rLoad = Addon:CanBindingLoad(right.binding)

		if lLoad and not rLoad then
			return true
		end

		if not lLoad and rLoad then
			return false
		end

		local lName = Addon:GetSimpleSpellOrItemInfo(left.binding) or Addon:GetBindingValue(left.binding)
		local rName = Addon:GetSimpleSpellOrItemInfo(right.binding) or Addon:GetBindingValue(right.binding)

		return (lName or "") < (rName or "")
	end

	return left.title < right.title
end

local function TreeSortKeybind(left, right)
	if left.children ~= nil and right.children == nil then
		return true
	end

	if left.children == nil and right.children ~= nil then
		return false
	end

	if left.binding ~= nil and right.binding ~= nil then
		return Addon:CompareBindings(left.binding, right.binding)
	end

	return TreeSortAlphabetical(left, right)
end

--- @param item table
--- @param binding Binding
local function UpdateBindingItemVisual(item, binding)
	item.title, item.icon = Addon:GetBindingNameAndIcon(binding)
	item.keybind = #binding.keybind > 0 and Addon:SanitizeKeybind(binding.keybind) or L["UNBOUND"]
end

local function UpdateGroupItemVisual(item, group)
	local label = L["New Group"]
	local icon = item.icon

	if not Addon:IsStringNilOrEmpty(group.name) then
		label = group.name
	end

	if (type(group.displayIcon) == "string" and not Addon:IsStringNilOrEmpty(group.displayIcon)) or
	   (type(group.displayIcon) == "number" and group.displayIcon > 0) then
		icon = group.displayIcon
	end

	item.title = label
	item.icon = icon

	group.name = label
	group.displayIcon = icon
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
	local group = treeline.group

	button.treeline = treeline
	button.value = value
	button.uniquevalue = uniquevalue
	button.binding = binding
	button.group = group

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

	local desaturate = false

	if binding ~= nil and not Addon:CanBindingLoad(binding) then
		desaturate = true
	elseif group ~= nil then
		desaturate = true
		for _, child in Clicked:IterateConfiguredBindings() do
			if child.parent == group.identifier and Addon:CanBindingLoad(child) then
				desaturate = false
				break
			end
		end
	end

	if desaturate then
		-- dim text colors
		button.title:SetTextColor(GREY_FONT_COLOR.r, GREY_FONT_COLOR.g, GREY_FONT_COLOR.b, GREY_FONT_COLOR.a)
		button.keybind:SetTextColor(GREY_FONT_COLOR.r, GREY_FONT_COLOR.g, GREY_FONT_COLOR.b, GREY_FONT_COLOR.a)
	else
		-- reset back to default colors
		button.title:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		button.keybind:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end

	if icon then

		if desaturate then
			button.icon:SetVertexColor(GREY_FONT_COLOR.r, GREY_FONT_COLOR.g, GREY_FONT_COLOR.b, GREY_FONT_COLOR.a)
		else
			button.icon:SetVertexColor(1.0, 1.0, 1.0, 1.0)
		end

		button.icon:SetDesaturated(desaturate)
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
	for _, v in ipairs(tree) do
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
	line.group = v.group
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

		local menu = {}

		if frame.binding ~= nil then
			table.insert(menu, {
				text = L["Copy Data"],
				notCheckable = true,
				disabled = inCombat,
				func = function()
					self.bindingCopyBuffer = Addon:DeepCopyTable(frame.binding)
				end
			})

			table.insert(menu, {
				text = L["Paste Data"],
				notCheckable = true,
				disabled = inCombat or self.bindingCopyBuffer == nil,
				func = function()
					if frame.binding ~= nil then
						local clone = Addon:DeepCopyTable(self.bindingCopyBuffer)
						clone.identifier = frame.binding.identifier
						clone.keybind = frame.binding.keybind
						clone.integrations = frame.binding.integrations

						Addon:ReplaceBinding(frame.binding, clone)
					end
				end
			})

			table.insert(menu, {
				text = L["Duplicate"],
				notCheckable = true,
				disabled = inCombat,
				func = function()
					local clone = Addon:CloneBinding(frame.binding)
					self:SelectByBindingOrGroup(clone)
				end
			})

			do
				local convertTo = {
					text = L["Convert to"],
					hasArrow = true,
					notCheckable = true,
					menuList = {}
				}

				local function AddConvertToOption(type, label)
					if frame.binding.type == type then
						return
					end

					table.insert(convertTo.menuList, {
						text = label,
						notCheckable = true,
						disabled = inCombat,
						func = function()
							self:SelectByBindingOrGroup(frame.binding)

							frame.binding.type = type

							Addon:EnsureSupportedTargetModes(frame.binding.targets, frame.binding.keybind, type)
							Clicked:ReloadActiveBindings()

							contextMenuFrame:Hide()
						end
					})
				end

				table.insert(menu, convertTo)

				AddConvertToOption(Addon.BindingTypes.SPELL, L["Cast a spell"])
				AddConvertToOption(Addon.BindingTypes.ITEM, L["Use an item"])
				AddConvertToOption(Addon.BindingTypes.UNIT_SELECT, L["Target the unit"])
				AddConvertToOption(Addon.BindingTypes.UNIT_MENU, L["Open the unit menu"])
				AddConvertToOption(Addon.BindingTypes.MACRO, L["Run a macro"])
				AddConvertToOption(Addon.BindingTypes.APPEND, L["Append a binding segment"])
			end
		end

		table.insert(menu, {
			text = L["Delete"],
			notCheckable = true,
			disabled = inCombat,
			func = function()
				local function OnConfirm()
					if InCombatLockdown() then
						Addon:NotifyCombatLockdown()
						return
					end

					if frame.binding ~= nil then
						Clicked:DeleteBinding(frame.binding)
					elseif frame.group ~= nil then
						Clicked:DeleteGroup(frame.group)
					end

					Clicked:ReloadActiveBindings()
				end

				if IsShiftKeyDown() then
					OnConfirm()
				else
					local msg = nil

					if frame.binding ~= nil then
						local name = Addon:GetSimpleSpellOrItemInfo(frame.binding) or Addon:GetBindingValue(frame.binding)

						msg = L["Are you sure you want to delete this binding?"] .. "\n\n"
						msg = msg .. frame.binding.keybind .. " " .. (name or "")
					elseif frame.group ~= nil then
						local count = 0

						for _, e in Clicked:IterateConfiguredBindings() do
							if e.parent == frame.group.identifier then
								count = count + 1
							end
						end

						msg = L["Are you sure you want to delete this group and ALL bindings it contains? This will delete %s bindings."]:format(count) .. "\n\n"
						msg = msg .. frame.group.name
					end

					Addon:ShowConfirmationPopup(msg, function()
						OnConfirm()
					end)
				end
			end
		})

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

	if frame.isMoving then
		return
	end

	self:Fire("OnButtonEnter", frame.uniquevalue, frame)

	if self.enabletooltips and frame.title ~= nil and frame.binding ~= nil then
		local tooltip = AceGUI.tooltip

		--- @type Binding
		local binding = frame.binding
		local text = Addon:GetBindingNameAndIcon(binding)

		text = text .. "\n\n"
		text = text .. L["Targets"] .. "\n"

		if binding.targets.hovercastEnabled then
			local str = Addon:GetLocalizedTargetString(binding.targets.hovercast)

			if #str > 0 then
				str = str .. " "
			end

			str = str .. L["Unit frame"]
			text = text .. "|cFFFFFFFF* " .. str .. "|r\n"
		end

		if binding.targets.regularEnabled then
			for i, target in ipairs(binding.targets.regular) do
				local str = Addon:GetLocalizedTargetString(target)
				text = text .. "|cFFFFFFFF" .. i .. ". " .. str .. "|r\n"
			end
		end

		text = text .. "\n"
		text = text .. (Addon:CanBindingLoad(binding) and L["Loaded"] or L["Unloaded"])

		if IsShiftKeyDown() then
			text = text .. string.format(" (%s)", binding.identifier)
		end

		tooltip:SetOwner(frame, "ANCHOR_NONE")
		tooltip:ClearAllPoints()
		tooltip:SetPoint("RIGHT", frame, "LEFT")
		tooltip:SetText(text or "", 1, 0.82, 0, 1, true)
		tooltip:Show()
	end
end

local function Button_OnLeave(frame)
	local self = frame.obj

	if frame.isMoving then
		return
	end

	self:Fire("OnButtonLeave", frame.uniquevalue, frame)

	if self.enabletooltips and frame.title ~= nil then
		local tooltip = AceGUI.tooltip
		tooltip:Hide()
	end
end

local function Button_OnDragStart(frame)
	local self = frame.obj

	if frame.binding == nil then
		return
	end

	frame:StartMoving()
	frame:SetFrameLevel(frame:GetParent():GetFrameLevel() + 2)
	frame.isMoving = true

	if self.enabletooltips then
		local tooltip = AceGUI.tooltip
		tooltip:Hide()
	end

	self:RefreshTree()
end

local function Button_OnDragStop(frame)
	local self = frame.obj

	if frame.binding == nil then
		return
	end

	frame:StopMovingOrSizing()
	frame:SetUserPlaced(false)
	frame.isMoving = false

	local newParent = nil

	for _, button in ipairs(self.buttons) do
		if button ~= frame and button:IsEnabled() and button:IsShown() and button:IsMouseOver(0, 0) then
			if button.group ~= nil then
				newParent = button.group.identifier
				break
			elseif button.binding ~= nil then
				newParent = button.binding.parent
				break
			end
		end
	end

	if newParent ~= frame.binding.parent then
		local currentBinding = frame.binding
		frame.binding.parent = newParent

		self:ConstructTree()
		self:SelectByBindingOrGroup(currentBinding)
	else
		self:RefreshTree()
	end
end

local function Button_OnHide(frame)
	if frame.isMoving then
		frame:StopMovingOrSizing()
		frame.isMoving = false
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

local function Searchbar_OnSearchTermChanged(handler)
	local treeframe = handler.frame:GetParent()
	local self = treeframe.obj

	self:ConstructTree()
end

local function Sort_OnClick(frame)
	local self = frame.obj

	AceGUI:ClearFocus()
	PlaySound(852) -- SOUNDKIT.IG_MAINMENU_OPTION

	if self.sortMode == 1 then
		self.sortLabel:SetText(L["ABC"])
		self.sortMode = 2
	else
		self.sortLabel:SetText(L["Key"])
		self.sortMode = 1
	end

	self.sortButton:SetWidth(self.sortLabel:GetStringWidth() + 30)

	self:BuildCache()
	self:RefreshTree()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
--- @class ClickedTreeGroup
local Methods = {}

function Methods:OnAcquire()
	self:SetTreeWidth(DEFAULT_TREE_WIDTH, DEFAULT_TREE_SIZABLE)
	self:EnableButtonTooltips(true)
	self.frame:SetScript("OnUpdate", FirstFrameUpdate)

	self.searchbar:ClearSearchTerm()
	self.sortLabel:SetText(L["Key"])
	self.sortButton:SetWidth(self.sortLabel:GetStringWidth() + 30)
	self.sortMode = 1
end

function Methods:OnRelease()
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
end

function Methods:EnableButtonTooltips(enable)
	self.enabletooltips = enable
end

function Methods:CreateButton()
	local num = AceGUI:GetNextWidgetNum("TreeGroupButton")
	local button = CreateFrame("Button", ("ClickedTreeButton%d"):format(num), self.treeframe, "OptionsListButtonTemplate")
	button:RegisterForDrag("LeftButton")
	button:SetMovable(true)
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
	button:SetScript("OnDragStart", Button_OnDragStart)
	button:SetScript("OnDragStop", Button_OnDragStop)
	button:SetScript("OnHide", Button_OnHide)

	button.toggle.button = button
	button.toggle:SetScript("OnClick",Expand_OnClick)

	return button
end

function Methods:SetStatusTable(status)
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
end

function Methods:ConstructTree(filter)
	local status = self.status or self.localstatus
	self.filter = filter
	self.tree = {}
	self.treeCache = self.tree

	for _, group in Clicked:IterateGroups() do
		local item = {
			value = group.identifier,
			group = group,
			icon = "Interface\\ICONS\\INV_Misc_QuestionMark",
			children = {}
		}

		UpdateGroupItemVisual(item, group)

		table.insert(self.tree, item)
	end

	for _, binding in Clicked:IterateConfiguredBindings() do
		local item = {
			value = "binding-" .. binding.identifier,
			binding = binding,
			icon = "Interface\\ICONS\\INV_Misc_QuestionMark"
		}

		UpdateBindingItemVisual(item, binding)

		if binding.parent == nil then
			table.insert(self.tree, item)
		else
			for _, e in ipairs(self.tree) do
				if e.value == binding.parent then
					item.parent = e
					table.insert(e.children, item)
					break
				end
			end
		end
	end

	self:BuildCache()
	self:RefreshTree()

	if #self.tree > 0 and status.selected == nil then
		self:SelectByValue(self.tree[1].value)
	elseif #self.tree > 0 and status.selected ~= nil then
		self:SelectByValue(status.selected)
	elseif #self.tree == 0 then
		self:SelectByValue("")
	end
end

function Methods:BuildLevel(tree, level, parent)
	local groups = (self.status or self.localstatus).groups

	for _, v in ipairs(tree) do
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
end

function Methods:BuildCache()
	if self.tree == nil then
		self.treeCache = nil
		return
	end

	local tree = {}

	if not Addon:IsStringNilOrEmpty(self.searchbar.searchTerm) then
		local function IsItemValidWithSearchQuery(item)
			local strings = {}

			if item.binding ~= nil then
				local value = Addon:GetSimpleSpellOrItemInfo(item.binding) or Addon:GetBindingValue(item.binding)

				if (type(value) == "string" and not Addon:IsStringNilOrEmpty(value)) or
					(type(value) == "number" and value > 0) then
					table.insert(strings, value)
				end

				if item.binding.type == Addon.BindingTypes.MACRO or item.binding.type == Addon.BindingTypes.APPEND then
					table.insert(strings, item.binding.action.macroName)
				end

				if item.binding.keybind ~= "" then
					table.insert(strings, item.binding.keybind)
				end
			elseif item.group ~= nil then
				table.insert(strings, item.title)
			end

			for i = 1, #strings do
				if strings[i] ~= nil and strings[i] ~= "" then
					local str = string.lower(strings[i])
					local pattern = string.lower(self.searchbar.searchTerm)

					if string.find(str, pattern, 1, true) ~= nil then
						return true
					end
				end
			end

			return false
		end

		local function TableContains(tbl, item)
			for _, child in ipairs(tbl) do
				if child == item then
					return true
				end
			end

			return false
		end

		local open = { unpack(self.tree) }

		while #open > 0 do
			local next = open[1]
			table.remove(open, 1)

			if IsItemValidWithSearchQuery(next) then
				local current = next

				while current ~= nil do
					local parent = current.parent

					if parent == nil then
						if current.children ~= nil then
							current.children2 = current.children2 or {}
						end

						if not TableContains(tree, current) then
							table.insert(tree, current)
						end
					else
						parent.children2 = parent.children2 or {}

						if not TableContains(parent.children2, current) then
							table.insert(parent.children2, current)
						end
					end

					current = parent
				end
			end

			if next.children ~= nil then
				for i = 1, #next.children do
					table.insert(open, next.children[i])
				end
			end
		end

		open = { unpack(self.tree) }

		while #open > 0 do
			local next = open[1]
			table.remove(open, 1)

			if next.children2 ~= nil then
				next.children = next.children2
				next.children2 = nil
			end

			if next.children ~= nil then
				for i = 1, #next.children do
					table.insert(open, next.children[i])
				end
			end
		end
	else
		tree = self.tree
	end

	if self.sortMode == 1 then
		table.sort(tree, TreeSortKeybind)

		for _, item in ipairs(tree) do
			if item.children ~= nil then
				table.sort(item.children, TreeSortKeybind)
			end
		end
	else
		table.sort(tree, TreeSortAlphabetical)

		for _, item in ipairs(tree) do
			if item.children ~= nil then
				table.sort(item.children, TreeSortAlphabetical)
			end
		end
	end

	self.treeCache = tree
end

function Methods:RefreshTree(scrollToSelection,fromOnUpdate)
	local buttons = self.buttons
	local lines = self.lines

	for _, v in ipairs(buttons) do
		if not v.isMoving then
			v:Hide()
		end
	end

	while lines[1] do
		local t = table.remove(lines)
		for k in pairs(t) do
			t[k] = nil
		end
		del(t)
	end

	if not self.tree then
		return
	end

	--Build the list of visible entries from the tree and status tables
	local status = self.status or self.localstatus
	local groupstatus = status.groups
	local treeframe = self.treeframe

	status.scrollToSelection = status.scrollToSelection or scrollToSelection	-- needs to be cached in case the control hasn't been drawn yet (code bails out below)

	self:BuildLevel(self.treeCache, 1)

	local numlines = #lines

	local maxlines = (floor(((self.treeframe:GetHeight()or 0) - 46 ) / 28))
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
		end

		if not button.isMoving then
			button:SetFrameLevel(treeframe:GetFrameLevel() + 1)
			button:ClearAllPoints()

			if previous == nil then
				if self.showscroll then
					button:SetPoint("TOPRIGHT", -22, -36)
					button:SetPoint("TOPLEFT", 0, -36)
				else
					button:SetPoint("TOPRIGHT", 0, -36)
					button:SetPoint("TOPLEFT", 0, -36)
				end
			else
				button:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT", 0, 0)
				button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, 0)
			end

			UpdateButton(button, line, status.selected == line.uniquevalue, line.hasChildren, groupstatus[line.uniquevalue])
			button:Show()
		end

		buttonNum = buttonNum + 1

		if not button.isMoving then
			previous = button
		end
	end
end

function Methods:Redraw()
	local status = self.status or self.localstatus
	self:Fire("OnGroupSelected", status.selected)
end

function Methods:SetSelected(value)
	local status = self.status or self.localstatus
	if status.selected ~= value then
		status.selected = value
		self:Fire("OnGroupSelected", value)
	end
end

function Methods:Select(uniquevalue, ...)
	self.filter = false
	local status = self.status or self.localstatus
	local groups = status.groups
	local path = {...}

	for i = 1, #path do
		local group = table.concat(path, "\001", 1, i)

		if string.find(group, "\001") then
			groups[group] = true
		end
	end

	status.selected = uniquevalue
	self:RefreshTree(true)
	self:Fire("OnGroupSelected", uniquevalue)
end

function Methods:SelectByPath(...)
	self:Select(BuildUniqueValue(...), ...)
end

function Methods:SelectByValue(uniquevalue)
	self:Select(uniquevalue, ("\001"):split(uniquevalue))
end

function Methods:SelectByBindingOrGroup(item)
	local open = { unpack(self.tree) }

	while #open > 0 do
		local next = open[1]
		table.remove(open, 1)

		if (next.binding == item and next.binding.parent == nil) or next.group == item then
			self:SelectByValue(next.value)
			break
		elseif next.binding == item then
			local parent = next.binding.parent
			local value = parent .. "\001" .. next.value

			self:SelectByValue(value)
			break
		end

		if next.children ~= nil then
			for i = 1, #next.children do
				table.insert(open, next.children[i])
			end
		end
	end
end

function Methods:ShowScroll(show)
	self.showscroll = show

	local button = nil

	for _, b in ipairs(self.buttons) do
		if b:IsEnabled() and b:IsShown() and not b.isMoving then
			button = b
			break
		end
	end

	if show then
		self.scrollbar:Show()

		if button ~= nil then
			button:SetPoint("TOPRIGHT", self.treeframe,"TOPRIGHT",-22,-10)
		end

		self.sortButton:SetPoint("TOPRIGHT", self.treeframe, -30, -7)
	else
		self.scrollbar:Hide()

		if button ~= nil then
			button:SetPoint("TOPRIGHT", self.treeframe,"TOPRIGHT",0,-10)
		end

		self.sortButton:SetPoint("TOPRIGHT", self.treeframe, -8, -7)
	end
end

function Methods:OnWidthSet(width)
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
end

function Methods:OnHeightSet(height)
	local content = self.content
	local contentheight = height - 20
	if contentheight < 0 then
		contentheight = 0
	end
	content:SetHeight(contentheight)
	content.height = contentheight
end

function Methods:SetTreeWidth(treewidth, resizable)
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
end

function Methods:GetTreeWidth()
	local status = self.status or self.localstatus
	return status.treewidth or DEFAULT_TREE_WIDTH
end

function Methods:GetSelectedItem()
	local status = self.status or self.localstatus

	if status.selected == nil then
		return nil
	end

	local path = { ("\001"):split(status.selected) }
	local current = self.tree

	for i = 1, #path do
		local value = path[i]

		if current ~= nil then
			for _, e in ipairs(current) do
				if e.value == value then
					if i == #path then
						current = e
					else
						current = e.children
					end
				end
			end
		end
	end

	return current
end

function Methods:LayoutFinished(_, height)
	if self.noAutoHeight then return end
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

local DraggerBackdrop  = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = nil,
	tile = true, tileSize = 16, edgeSize = 1,
	insets = { left = 3, right = 3, top = 7, bottom = 7 }
}

local function Constructor()
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", nil, UIParent)

	local treeframe = CreateFrame("Frame", nil, frame, "BackdropTemplate")
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

	local sortButton = CreateFrame("Button", nil, treeframe, "UIPanelButtonTemplate")
	sortButton:EnableMouse(true)
	sortButton:SetScript("OnClick", Sort_OnClick)
	sortButton:SetPoint("TOPRIGHT", treeframe, -8, -7)
	sortButton:SetWidth(75)

	local sortLabel = sortButton:GetFontString()
	sortLabel:ClearAllPoints()
	sortLabel:SetPoint("TOPLEFT", 15, -1)
	sortLabel:SetPoint("BOTTOMRIGHT", -15, 1)
	sortLabel:SetJustifyV("MIDDLE")

	local searchbar = AceGUI:Create("ClickedSearchBox")
	searchbar:DisableButton(true)
	searchbar:SetPlaceholderText(L["Search..."])
	searchbar:SetCallback("SearchTermChanged", Searchbar_OnSearchTermChanged)

	searchbar.frame:SetParent(treeframe)
	searchbar.frame:ClearAllPoints()
	searchbar.frame:SetPoint("TOPLEFT", treeframe, 8, -4)
	searchbar.frame:SetPoint("TOPRIGHT", sortButton, "TOPLEFT")
	searchbar.frame:Show()

	local dragger = CreateFrame("Frame", nil, treeframe, "BackdropTemplate")
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

	local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
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

			if Addon:IsGameVersionAtleast("BC") then
				S:HandleButton(sortButton, true)
			else
				S:HandleButton(sortButton, true, nil, true)
			end
		end
	end

	local widget = {
		frame= frame,
		lines = {},
		buttons       = {},
		hasChildren   = {},
		localstatus   = { groups = { }, scrollvalue = 0 },
		filter        = false,
		treeframe     = treeframe,
		dragger       = dragger,
		scrollbar     = scrollbar,
		searchbar     = searchbar,
		sortButton    = sortButton,
		sortLabel     = sortLabel,
		sortMode      = 1,
		border        = border,
		content       = content,
		type          = Type
	}
	for method, func in pairs(Methods) do
		widget[method] = func
	end
	treeframe.obj, dragger.obj, scrollbar.obj, sortButton.obj = widget, widget, widget, widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

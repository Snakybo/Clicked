--[[-----------------------------------------------------------------------------
Clicked TreeGroup Container
Container that uses a tree control to switch between groups.
-------------------------------------------------------------------------------]]

--- @diagnostic disable-next-line: duplicate-doc-alias
--- @alias AceGUIWidgetType
--- | "ClickedTreeGroup"

--- @class ClickedTreeGroup : AceGUIContainer
--- @field private lines ClickedTreeGroup.Line[]
--- @field private buttons ClickedTreeGroup.Button[]
--- @field private localstatus ClickedTreeGroup.Status
--- @field private status ClickedTreeGroup.Status?
--- @field private tree ClickedTreeGroup.Item[]
--- @field private treeframe Frame|BackdropTemplate
--- @field private dragger Frame|BackdropTemplate
--- @field private scrollbar Slider
--- @field private searchbar ClickedSearchBox
--- @field private sortButton Button
--- @field private sortLabel FontString
--- @field private sortMode `1`|`2`
--- @field private border Texture

--- @class ClickedTreeGroup.Button : Button
--- @field public isMoving boolean
--- @field public toggle Button
--- @field public icon Texture
--- @field public title FontString
--- @field public keybind FontString
--- @field public binding Binding?
--- @field public group Group?
--- @field public scope BindingScope

--- @class ClickedTreeGroup.Item
--- @field public value integer
--- @field public title string
--- @field public visible boolean
--- @field public scope BindingScope
--- @field public type "scope"|"group"|"binding"
--- @field public parent ClickedTreeGroup.Item?
--- @field public children ClickedTreeGroup.Item[]?

--- @class ClickedTreeGroup.GroupItem : ClickedTreeGroup.Item
--- @field public group Group
--- @field public canLoad boolean

--- @class ClickedTreeGroup.BindingItem : ClickedTreeGroup.Item
--- @field public name string
--- @field public icon string|integer
--- @field public keybind string
--- @field public binding Binding
--- @field public canLoad boolean

--- @class ClickedTreeGroup.Status
--- @field public groups { [string]: boolean }
--- @field public scrollvalue number
--- @field public selected string?
--- @field public treewidth number?
--- @field public treesizable boolean?
--- @field public fullwidth number?

--- @class ClickedInternal
local Addon = select(2, ...)

local Type, Version = "ClickedTreeGroup", 3
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)

if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then
	return
end

-- Recycling functions

--- @type fun(): ClickedTreeGroup.Line
local new

--- @type fun(item: ClickedTreeGroup.Line)
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

local DEFAULT_TREE_WIDTH = 325
local DEFAULT_TREE_SIZABLE = false
local GREY_FONT_COLOR = {r=0.75, g=0.75, b=0.75, a=0.5}

local contextMenuFrame = CreateFrame("Frame", "ClickedContextMenu", UIParent, "UIDropDownMenuTemplate")

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]

local function EasyMenu_Initialize(_, level, menuList)
    for index = 1, #menuList do
        local value = menuList[index]

        if value.text then
            value.index = index;
            UIDropDownMenu_AddButton(value, level);
        end
    end
end

local function EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
    if displayMode == "MENU" then
        menuFrame.displayMode = displayMode;
    end

    UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList);
    ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay);
end

--- @param left ClickedTreeGroup.Item
--- @param right ClickedTreeGroup.Item
--- @return boolean
local function TreeSortAlphabetical(left, right)
	if left.scope > right.scope then
		return true
	end

	if left.scope < right.scope then
		return false
	end

	if left.children ~= nil and right.children == nil then
		return true
	end

	if left.children == nil and right.children ~= nil then
		return false
	end

	if left.type == "group" and right.type == "group" then
		--- @cast left ClickedTreeGroup.GroupItem
		--- @cast right ClickedTreeGroup.GroupItem

		if left.children ~= nil and right.children ~= nil then
			if left.canLoad and not right.canLoad then
				return true
			elseif not left.canLoad and right.canLoad then
				return false
			end
		end
	elseif left.type == "binding" and right.type == "binding" then
		--- @cast left ClickedTreeGroup.BindingItem
		--- @cast right ClickedTreeGroup.BindingItem

		if left.canLoad and not right.canLoad then
				return true
			end

		if not left.canLoad and right.canLoad then
			return false
		end

		return (left.title or "") < (right.title or "")
	end

	return left.title < right.title
end

--- @param left ClickedTreeGroup.Item
--- @param right ClickedTreeGroup.Item
--- @return boolean
local function TreeSortKeybind(left, right)
	if left.scope > right.scope then
		return true
	end

	if left.scope < right.scope then
		return false
	end

	if left.children ~= nil and right.children == nil then
		return true
	end

	if left.children == nil and right.children ~= nil then
		return false
	end

	if left.type == "binding" and right.type == "binding" then
		--- @cast left ClickedTreeGroup.BindingItem
		--- @cast right ClickedTreeGroup.BindingItem

		if left.binding ~= nil and right.binding ~= nil then
			return Addon:CompareBindings(left.binding, right.binding, left.canLoad, right.canLoad)
		end
	end

	return TreeSortAlphabetical(left, right)
end

--- @param item ClickedTreeGroup.GroupItem
--- @param group Group
local function UpdateGroupItemVisual(item, group)
	local label = Addon.L["New Group"]
	local icon = item.icon

	if not Addon:IsStringNilOrEmpty(group.name) then
		label = group.name
	end

	if (type(group.displayIcon) == "string" and not Addon:IsStringNilOrEmpty(group.displayIcon --[[@as string]])) or
	   (type(group.displayIcon) == "number" and group.displayIcon > 0) then
		icon = group.displayIcon
	end

	item.title = label
	item.icon = icon

	group.name = label
	group.displayIcon = icon
end

--- @param line ClickedTreeGroup.Line
--- @return string
local function GetButtonUniqueValue(line)
	local parent = line.parent
	if parent and parent.value then
		return GetButtonUniqueValue(parent).."\001"..line.value
	else
		return line.value
	end
end

--- @param item ClickedTreeGroup.Item
local function SetVisibleRecursive(item)
	local current = item

	while current ~= nil do
		current.visible = true
		current = current.parent
	end
end

--- @param item ClickedTreeGroup.Item
--- @param search string
--- @return boolean
local function IsItemValidWithSearchQuery(item, search)
	if Addon:IsStringNilOrEmpty(search) then
		return true
	end

	local strings = {}

	local prefix = string.match(search, "(.*):")
	local suffix = string.match(search, ":(.*)")

	if item.type == "binding" then
		--- @cast item ClickedTreeGroup.BindingItem

		if prefix == nil then
			if (type(item.name) == "string" and not Addon:IsStringNilOrEmpty(item.name)) or
				(type(item.name) == "number" and item.name > 0) then
				table.insert(strings, { value = item.name })
			end

			if item.binding.actionType == Addon.BindingTypes.MACRO or item.binding.actionType == Addon.BindingTypes.APPEND then
				table.insert(strings, { value = item.binding.action.macroName })
			end
		end

		if prefix == nil or string.lower(prefix) == "k" then
			if item.binding.keybind ~= "" then
				table.insert(strings, { value = item.binding.keybind, exact = true })
			end
		end
	elseif item.type == "group" then
		--- @cast item ClickedTreeGroup.GroupItem

		if prefix == nil then
			table.insert(strings, { value = item.title })
		end
	end

	for i = 1, #strings do
		if strings[i] ~= nil and strings[i].value ~= "" then
			local str = string.lower(strings[i].value)
			local pattern = string.lower(suffix or search)

			if strings[i].exact then
				if str == pattern then
					return true
				end
			else
				if string.find(str, pattern, 1, true) ~= nil then
					return true
				end
			end
		end
	end

	return false
end

--- @param button ClickedTreeGroup.Button
--- @param treeline ClickedTreeGroup.Line
--- @param selected boolean
--- @param canExpand boolean
--- @param isExpanded boolean
local function UpdateButton(button, treeline, selected, canExpand, isExpanded)
	local toggle = button.toggle
	local title = treeline.title or ""
	local keybind = treeline.keybind or ""
	local icon = treeline.icon
	local level = treeline.level
	local value = treeline.value
	local uniquevalue = treeline.uniquevalue
	local binding = treeline.binding
	local group = treeline.group

	local isScope = treeline.type == "scope"

	button.treeline = treeline
	button.value = value
	button.uniquevalue = uniquevalue
	button.binding = binding
	button.group = group
	button.scope = treeline.scope

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

	if isScope then
		button:EnableMouse(false)
	else
		button:EnableMouse(true)
	end

	if isScope then
		button.title:ClearAllPoints()
		button.title:SetPoint("LEFT", 8, -1)
		button.title:SetText(string.format(format, title))

		button.keybind:Hide()
	else
		button.title:ClearAllPoints()
		button.title:SetPoint("TOPLEFT", (icon and 28 or 0) + 8 * level, -1)
		button.title:SetText(string.format(format, title))

		button.keybind:SetPoint("BOTTOMLEFT", (icon and 28 or 0) + 8 * level, 1)
		button.keybind:SetText(string.format(format, keybind))
		button.keybind:Show()
	end

	local desaturate = false

	if binding ~= nil and not Clicked:IsBindingLoaded(binding) then
		desaturate = true
	elseif group ~= nil then
		desaturate = true
		for _, child in Clicked:IterateConfiguredBindings() do
			if child.parent == group.uid and Clicked:IsBindingLoaded(child) then
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
		button.title:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, NORMAL_FONT_COLOR.a)
		button.keybind:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.a)
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

--fire an update after one frame to catch the treeframes height
local function FirstFrameUpdate(frame)
	local self = frame.obj
	frame:SetScript("OnUpdate", nil)
	self:RefreshTree(nil, true)
end

--- @param ... any
--- @return string
local function BuildUniqueValue(...)
	local n = select('#', ...)
	if n == 1 then
		return tostring(...)
	else
		return tostring(...) .. "\001" .. BuildUniqueValue(select(2, ...))
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
				text = Addon.L["Copy Data"],
				notCheckable = true,
				disabled = inCombat,
				func = function()
					self.bindingCopyBuffer = Addon:DeepCopyTable(frame.binding)
				end
			})

			table.insert(menu, {
				text = Addon.L["Paste Data"],
				notCheckable = true,
				disabled = inCombat or self.bindingCopyBuffer == nil,
				func = function()
					if frame.binding ~= nil then
						local clone = Addon:DeepCopyTable(self.bindingCopyBuffer)
						clone.parent = frame.parent
						clone.uid = frame.binding.uid
						clone.keybind = frame.binding.keybind
						clone.integrations = frame.binding.integrations

						Addon:ReplaceBinding(frame.binding, clone)
					end
				end
			})

			table.insert(menu, {
				text = Addon.L["Duplicate"],
				notCheckable = true,
				disabled = inCombat,
				func = function()
					local clone = Addon:CloneBinding(frame.binding)
					self:SelectByBindingOrGroup(clone)
				end
			})

			do
				local convertTo = {
					text = Addon.L["Convert to"],
					hasArrow = true,
					notCheckable = true,
					menuList = {}
				}

				local function AddConvertToOption(type, label)
					if frame.binding.actionType == type then
						return
					end

					table.insert(convertTo.menuList, {
						text = label,
						notCheckable = true,
						disabled = inCombat,
						func = function()
							self:SelectByBindingOrGroup(frame.binding)

							frame.binding.actionType = type

							Addon:EnsureSupportedTargetModes(frame.binding.targets, frame.binding.keybind, type)
							Clicked:ReloadBinding(frame.binding, true)

							contextMenuFrame:Hide()
						end
					})
				end

				table.insert(menu, convertTo)

				AddConvertToOption(Addon.BindingTypes.SPELL, Addon.L["Cast a spell"])
				AddConvertToOption(Addon.BindingTypes.ITEM, Addon.L["Use an item"])
				AddConvertToOption(Addon.BindingTypes.CANCELAURA, Addon.L["Cancel an aura"])
				AddConvertToOption(Addon.BindingTypes.UNIT_SELECT, Addon.L["Target the unit"])
				AddConvertToOption(Addon.BindingTypes.UNIT_MENU, Addon.L["Open the unit menu"])
				AddConvertToOption(Addon.BindingTypes.MACRO, Addon.L["Run a macro"])
				AddConvertToOption(Addon.BindingTypes.APPEND, Addon.L["Append a binding segment"])
			end
		end

		do
			local changeScope = {
				text = Addon.L["Change scope"],
				hasArrow = true,
				notCheckable = true,
				menuList = {}
			}

			local function AddOption(scope, label)
				table.insert(changeScope.menuList, {
					text = label,
					disabled = inCombat,
					checked = (frame.binding or frame.group).scope == scope,
					func = function()
						Addon:ChangeScope(frame.binding or frame.group, scope)
						self:ConstructTree()

						contextMenuFrame:Hide()
					end
				})
			end

			table.insert(menu, changeScope)

			AddOption(Addon.BindingScope.GLOBAL, Addon.L["Global"])
			AddOption(Addon.BindingScope.PROFILE, Addon.L["Profile"])
		end

		table.insert(menu, {
			text = Addon.L["Share"],
			notCheckable = true,
			disabled = inCombat,
			func = function ()
				if frame.group ~= nil then
					Addon.ExportFrame:ExportGroup(frame.group)
				elseif frame.binding ~= nil then
					Addon.ExportFrame:ExportBinding(frame.binding)
				end
			end
		})

		table.insert(menu, {
			text = Addon.L["Delete"],
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
				end

				if IsShiftKeyDown() then
					OnConfirm()
				else
					local msg = nil

					if frame.binding ~= nil then
						msg = Addon.L["Are you sure you want to delete this binding?"] .. "\n\n"
						msg = msg .. frame.binding.keybind .. " " .. (frame.name or "")
					elseif frame.group ~= nil then
						local count = 0

						for _, e in Clicked:IterateConfiguredBindings() do
							if e.parent == frame.group.uid then
								count = count + 1
							end
						end

						msg = Addon.L["Are you sure you want to delete this group and ALL bindings it contains? This will delete %s bindings."]:format(count) .. "\n\n"
						msg = msg .. frame.group.name
					end

					Addon:ShowConfirmationPopup(msg, function()
						OnConfirm()
					end)
				end
			end
		})

		-- TODO: Rewrite this to not use EasyMenu when it's propegated to all clients
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
		--- @type Binding
		local binding = frame.binding
		local text = Addon:GetBindingNameAndIcon(binding)

		text = text .. "\n\n"
		text = text .. Addon.L["Targets"] .. "\n"

		if Addon:IsHovercastEnabled(binding) then
			local str = Addon:GetLocalizedTargetString(binding.targets.hovercast)

			if #str > 0 then
				str = str .. " "
			end

			str = str .. Addon.L["Unit frame"]
			text = text .. "|cFFFFFFFF* " .. str .. "|r\n"
		end

		if Addon:IsMacroCastEnabled(binding) then
			for i, target in ipairs(binding.targets.regular) do
				local str = Addon:GetLocalizedTargetString(target)
				text = text .. "|cFFFFFFFF" .. i .. ". " .. str .. "|r\n"
			end
		end

		text = text .. "\n"
		text = text .. (Clicked:IsBindingLoaded(binding) and Addon.L["Loaded"] or Addon.L["Unloaded"])

		if IsShiftKeyDown() then
			text = text .. string.format(" (%s)", binding.uid)
		end

		Addon:ShowTooltip(frame, text, nil, "RIGHT", "LEFT")
	end
end

local function Button_OnLeave(frame)
	local self = frame.obj

	if frame.isMoving then
		return
	end

	self:Fire("OnButtonLeave", frame.uniquevalue, frame)

	if self.enabletooltips and frame.title ~= nil then
		Addon:HideTooltip()
	end
end

local function Button_OnDragStart(frame)
	local self = frame.obj

	if frame.binding == nil and frame.group == nil then
		return
	end

	frame:StartMoving()
	frame:SetFrameLevel(frame:GetParent():GetFrameLevel() + 2)
	frame.isMoving = true

	if self.enabletooltips then
		Addon:HideTooltip()
	end

	self:RefreshTree()
end

local function Button_OnDragStop(frame)
	local self = frame.obj

	frame:StopMovingOrSizing()
	frame:SetUserPlaced(false)
	frame.isMoving = false

	--- @type string|integer?
	local newParent = -1
	local newScope = nil

	for _, button in ipairs(self.buttons) do
		if button ~= frame and button:IsEnabled() and button:IsShown() and button:IsMouseOver(0, 0) then
			if button.group ~= nil then
				newParent = button.group.uid
				newScope = button.group.scope
				break
			elseif button.binding ~= nil then
				newParent = button.binding.parent
				newScope = button.binding.scope
				break
			elseif button.scope ~= nil then
				newParent = nil
				newScope = button.scope
				break
			end
		end
	end

	local modifiedItem = nil

	if frame.binding ~= nil then
		local binding = frame.binding

		if newScope ~= nil and newScope ~= binding.scope then
			Addon:ChangeScope(binding, newScope)
			modifiedItem = binding
		end

		if newParent ~= -1 and newParent ~= binding.parent then
			binding.parent = newParent
			modifiedItem = binding
		end
	elseif frame.group ~= nil then
		local group = frame.group

		if newScope ~= nil and newScope ~= group.scope then
			Addon:ChangeScope(group, newScope)
			modifiedItem = group
		end
	end

	if modifiedItem ~= nil then
		self:ConstructTree()
		self:SelectByBindingOrGroup(modifiedItem)
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
		self.sortLabel:SetText(Addon.L["ABC"])
		self.sortMode = 2
	else
		self.sortLabel:SetText(Addon.L["Key"])
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

--- @protected
function Methods:OnAcquire()
	self:SetTreeWidth(DEFAULT_TREE_WIDTH, DEFAULT_TREE_SIZABLE)
	self:EnableButtonTooltips(true)
	self.frame:SetScript("OnUpdate", FirstFrameUpdate)

	self.searchbar:ClearSearchTerm()
	self.sortLabel:SetText(Addon.L["Key"])
	self.sortButton:SetWidth(self.sortLabel:GetStringWidth() + 30)
	self.sortMode = 1
end

--- @protected
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

--- @param enable boolean
function Methods:EnableButtonTooltips(enable)
	self.enabletooltips = enable
end

--- @private
--- @return ClickedTreeGroup.Button
function Methods:CreateButton()
	local num = AceGUI:GetNextWidgetNum("TreeGroupButton")

	local button = CreateFrame("Button", ("ClickedTreeButton%d"):format(num), self.treeframe, "OptionsListButtonTemplate") --[[@as ClickedTreeGroup.Button]]
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

	local keybind = button:CreateFontString(nil, "OVERLAY", "GameTooltipText")
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

--- @param status table
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

function Methods:ConstructTree()
	local status = self.status or self.localstatus
	local groupstatus = status.groups

	local scopes = {}

	local function GetScopeList(scope)
		return scopes[scope]
	end

	self.tree = {}

	for _, scope in pairs(Addon.BindingScope) do
		--- @type ClickedTreeGroup.Item
		local item = {
			value = scope,
			title = Addon:GetLocalizedScope(scope),
			scope = scope,
			type = "scope",
			visible = true,
			children = {}
		}

		scopes[scope] = item.children
		groupstatus[item.value] = true

		table.insert(self.tree, item)
	end

	for _, group in Clicked:IterateGroups() do
		--- @type ClickedTreeGroup.GroupItem
		local item = {
			value = group.uid,
			group = group,
			icon = "Interface\\ICONS\\INV_Misc_QuestionMark",
			type = "group",
			scope = group.scope,
			children = {},
			canLoad = false
		}

		UpdateGroupItemVisual(item, group)

		table.insert(GetScopeList(group.scope), item)
	end

	for _, binding in Clicked:IterateConfiguredBindings() do
		local title, icon = Addon:GetBindingNameAndIcon(binding)

		--- @type ClickedTreeGroup.BindingItem
		local item = {
			value = binding.uid,
			name = Addon:GetSimpleSpellOrItemInfo(binding) or tostring(Addon:GetBindingValue(binding)),
			title = title,
			type = "binding",
			icon = icon,
			keybind = #binding.keybind > 0 and Addon:SanitizeKeybind(binding.keybind) or Addon.L["UNBOUND"],
			binding = binding,
			scope = binding.scope,
			canLoad = Clicked:IsBindingLoaded(binding)
		}

		local root = GetScopeList(binding.scope)

		if binding.parent == nil then
			table.insert(root, item)
		else
			for _, e in ipairs(root) do
				if e.value == binding.parent then
					item.parent = e
					e.canLoad = e.canLoad or item.canLoad
					table.insert(e.children, item)
					break
				end
			end
		end
	end

	self:BuildCache()
	self:RefreshTree()

	if #self.tree > 0 and #self.tree[1].children > 0 and status.selected == nil then
		self:SelectByPath(self.tree[1].value, self.tree[1].children[1].value)
	elseif #self.tree > 0 and status.selected ~= nil then
		self:SelectByValue(status.selected)
	elseif #self.tree == 0 then
		self:SelectByValue("")
	end
end

--- @private
--- @param tree ClickedTreeGroup.Item[]
--- @param level integer
--- @param parent? ClickedTreeGroup.Line
function Methods:BuildLevel(tree, level, parent)
	local groups = (self.status or self.localstatus).groups

	for _, v in ipairs(tree) do
		if v.visible or v.type == "scope" then
			if v.children then
				local line = self:AddLine(v, tree, level, parent)

				if groups[line.uniquevalue] then
					self:BuildLevel(v.children, level+1, line)
				end
			else
				self:AddLine(v, tree, level, parent)
			end
		end
	end
end

--- @private
function Methods:BuildCache()
	if self.tree == nil then
		return
	end

	do
		local open = { unpack(self.tree) }

		while #open > 0 do
			local next = open[1]
			table.remove(open, 1)

			-- Only search for bindings and not groups
			if next.children == nil then
				if IsItemValidWithSearchQuery(next, self.searchbar:GetSearchTerm()) then
					SetVisibleRecursive(next)
				end
			else
				if #next.children == 0 then
					if Addon:IsStringNilOrEmpty(self.searchbar:GetSearchTerm()) then
						SetVisibleRecursive(next)
					end
				else
					for i = 1, #next.children do
						table.insert(open, next.children[i])
					end
				end
			end
		end
	end

	do
		local sortFunc = self.sortMode == 1 and TreeSortKeybind or TreeSortAlphabetical

		--- @type ClickedTreeGroup.Item[]
		local queue = { unpack(self.tree) }

		while #queue > 0 do
			--- @type ClickedTreeGroup.Item
			local current = table.remove(queue, 1)

			if current.children ~= nil then
				for _, child in ipairs(current.children) do
					table.insert(queue, child)
				end

				table.sort(current.children, sortFunc)
			end
		end
	end
end

--- @private
--- @param scrollToSelection? boolean
--- @param fromOnUpdate? boolean
function Methods:RefreshTree(scrollToSelection, fromOnUpdate)
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

	self:BuildLevel(self.tree, 1)

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
		if scrollToSelection and status.selected ~= nil then
			local show
			for i,line in ipairs(lines) do
				if line.uniquevalue == status.selected then
					show = i
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

--- @param value? string
function Methods:SetSelected(value)
	local status = self.status or self.localstatus
	if status.selected ~= value then
		status.selected = value
		self:Fire("OnGroupSelected", value)
	end
end

--- @param uniqueValue string
--- @param ... string
function Methods:Select(uniqueValue, ...)
	local status = self.status or self.localstatus
	local groups = status.groups
	local path = {...}

	for i = 1, #path - 1 do
		local group = table.concat(path, "\001", 1, i)

		if string.find(group, "\001") then
			groups[group] = true
		end
	end

	status.selected = uniqueValue
	self:RefreshTree(true)
	self:Fire("OnGroupSelected", uniqueValue)
end

--- @param ... any
function Methods:SelectByPath(...)
	self:Select(BuildUniqueValue(...), ...)
end

--- @param uniqueValue string
function Methods:SelectByValue(uniqueValue)
	self:Select(uniqueValue, strsplit("\001", uniqueValue))
end

--- @param item DataObject
function Methods:SelectByBindingOrGroup(item)
	local open = { unpack(self.tree) }

	while #open > 0 do
		local next = open[1]
		table.remove(open, 1)

		if next.type == "binding" then
			--- @cast next ClickedTreeGroup.BindingItem
			if next.binding == item and next.binding.parent == nil then
				self:SelectByPath(next.scope, next.value)
				break
			elseif next.binding == item then
				self:SelectByPath(next.scope, next.binding.parent, next.value)
				break
			end
		elseif next.type == "group" then
			--- @cast next ClickedTreeGroup.GroupItem

			if next.group == item then
				self:SelectByPath(next.scope, next.value)
				break
			end
		end

		if next.children ~= nil then
			for i = 1, #next.children do
				table.insert(open, next.children[i])
			end
		end
	end
end

--- @param show boolean
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

--- @param treewidth number
--- @param resizable? boolean
--- @overload fun(self:ClickedTreeGroup, resizable: boolean)
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

--- @return number
function Methods:GetTreeWidth()
	local status = self.status or self.localstatus
	return status.treewidth or DEFAULT_TREE_WIDTH
end

--- @return ClickedTreeGroup.Item?
function Methods:GetSelectedItem()
	local status = self.status or self.localstatus

	if status.selected == nil then
		return nil
	end

	local path = { strsplit("\001", status.selected) }
	local current = { children = self.tree }

	for i = 1, #path do
		local value = tonumber(path[i])

		if current ~= nil then
			for _, e in ipairs(current.children) do
				if e.value == value then
					current = e
					break
				end
			end
		end
	end

	return current
end

--- @private
--- @param v ClickedTreeGroup.Item
--- @param tree ClickedTreeGroup.Item[]
--- @param level integer
--- @param parent? ClickedTreeGroup.Line
--- @return ClickedTreeGroup.Line
function Methods:AddLine(v, tree, level, parent)
	--- @class ClickedTreeGroup.Line
	local line = new()
	line.value = v.value

	if v.type == "binding" then
		--- @cast v ClickedTreeGroup.BindingItem
		line.binding = v.binding
		line.keybind = v.keybind
	elseif v.type == "group" then
		--- @cast v ClickedTreeGroup.GroupItem
		line.group = v.group
	end

	line.title = v.title
	line.icon = v.icon
	line.tree = tree
	line.level = level
	line.type = v.type
	line.parent = parent
	line.visible = v.visible
	line.scope = v.scope
	line.uniquevalue = GetButtonUniqueValue(line)
	if v.children then
		line.hasChildren = true
	else
		line.hasChildren = nil
	end
	self.lines[#self.lines+1] = line
	return line
end

--- @protected
--- @param width number
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

	treeframe:SetResizeBounds(100, 1, maxtreewidth, 1600)
end

--- @protected
--- @param height number
function Methods:OnHeightSet(height)
	local content = self.content
	local contentheight = height - 20
	if contentheight < 0 then
		contentheight = 0
	end
	content:SetHeight(contentheight)
	content.height = contentheight
end


--- @protected
--- @param _ number
--- @param height number
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
	treeframe --[[@as BackdropTemplate]]:SetBackdrop(PaneBackdrop)
	treeframe --[[@as BackdropTemplate]]:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	treeframe --[[@as BackdropTemplate]]:SetBackdropBorderColor(0.4, 0.4, 0.4)
	treeframe:SetResizable(true)
	treeframe:SetResizeBounds(100, 1, 400, 1600)
	treeframe:SetScript("OnUpdate", FirstFrameUpdate)
	treeframe:SetScript("OnSizeChanged", Tree_OnSizeChanged)
	treeframe:SetScript("OnMouseWheel", Tree_OnMouseWheel)

	local sortButton = CreateFrame("Button", nil, treeframe, "UIPanelButtonTemplate")
	sortButton:EnableMouse(true)
	sortButton:SetScript("OnClick", Sort_OnClick)
	sortButton:SetPoint("TOPRIGHT", treeframe, -8, -7)
	sortButton:SetWidth(75)

	--- @type FontString?
	local sortLabel = sortButton:GetFontString()
	if sortLabel ~= nil then
		sortLabel:ClearAllPoints()
		sortLabel:SetPoint("TOPLEFT", 15, -1)
		sortLabel:SetPoint("BOTTOMRIGHT", -15, 1)
		sortLabel:SetJustifyV("MIDDLE")
	end

	--- @class ClickedTreeGroup.SearchBox : ClickedSearchBox
	local searchbar = AceGUI:Create("ClickedSearchBox")
	searchbar:DisableButton(true)
	searchbar:SetPlaceholderText(Addon.L["Search..."])
	searchbar:SetCallback("SearchTermChanged", Searchbar_OnSearchTermChanged)

	local tooltipSubtext = Addon.L["Prefix your search with k: to search for a specific key only, for example:"]
	tooltipSubtext = tooltipSubtext .. "\n- " .. Addon.L["k:Q will only show bindings bound to Q"]
	tooltipSubtext = tooltipSubtext .. "\n- " .. Addon.L["k:ALT-A will only show bindings bound to ALT-A"]
	searchbar:SetTooltipText(Addon.L["Search Filters"], tooltipSubtext)

	searchbar.frame:SetParent(treeframe)
	searchbar.frame:ClearAllPoints()
	searchbar.frame:SetPoint("TOPLEFT", treeframe, 8, -4)
	searchbar.frame:SetPoint("TOPRIGHT", sortButton, "TOPLEFT")
	searchbar.frame:Show()

	local dragger = CreateFrame("Frame", nil, treeframe, "BackdropTemplate")
	dragger:SetWidth(8)
	dragger:SetPoint("TOP", treeframe, "TOPRIGHT")
	dragger:SetPoint("BOTTOM", treeframe, "BOTTOMRIGHT")
	dragger --[[@as BackdropTemplate]]:SetBackdrop(DraggerBackdrop)
	dragger --[[@as BackdropTemplate]]:SetBackdropColor(1, 1, 1, 0)
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
	border --[[@as BackdropTemplate]]:SetBackdrop(PaneBackdrop)
	border --[[@as BackdropTemplate]]:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	border --[[@as BackdropTemplate]]:SetBackdropBorderColor(0.4, 0.4, 0.4)

	--Container Support
	local content = CreateFrame("Frame", nil, border)
	content:SetPoint("TOPLEFT", 10, -10)
	content:SetPoint("BOTTOMRIGHT", -10, 10)

	local widget = {
		frame= frame,
		lines = {},
		buttons = {},
		localstatus = { groups = { }, scrollvalue = 0 },
		treeframe = treeframe,
		dragger = dragger,
		scrollbar = scrollbar,
		searchbar = searchbar,
		sortButton = sortButton,
		sortLabel = sortLabel,
		sortMode = 1,
		border = border,
		content = content,
		type = Type
	}

	for method, func in pairs(Methods) do
		widget[method] = func
	end

	treeframe.obj, dragger.obj, scrollbar.obj, sortButton.obj = widget, widget, widget, widget

	return AceGUI:RegisterAsContainer(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)

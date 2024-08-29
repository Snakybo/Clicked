-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2024  Kevin Krol
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

--- @class BindingConfigPage
--- @field public controller BindingConfigWindow
--- @field public container AceGUIContainer
--- @field public targets? DataObject[]
--- @field public keepTreeSelection? boolean
--- @field public Show? fun(self: BindingConfigPage)
--- @field public Hide? fun(self: BindingConfigPage)
--- @field public Redraw? fun(self: BindingConfigPage)
--- @field public OnBindingReload? fun(self: BindingConfigPage)

--- @class BindingConfigPageImpl
--- @field public title string
--- @field public implementation BindingConfigPage

local AceGUI = LibStub("AceGUI-3.0")

--- @class ClickedInternal
local Addon = select(2, ...)

local SEARCH_FILTER_APPLY_DELAY = 0.1

local contextMenuFrame = CreateFrame("Frame", "ClickedContextMenu", UIParent, "UIDropDownMenuTemplate")

--- @param selected integer[]
--- @return DataObject[]
--- @return boolean
local function FilterTargets(selected)
	if #selected == 0 then
		return selected, false
	end

	--- @type DataObject[]
	local result = {}

	--- @type DataObjectType?
	local allowedType = nil
	local containsIllegal = false

	for _, uid in ipairs(selected) do
		local obj = Clicked:GetByUid(uid)

		if obj ~= nil then
			allowedType = allowedType or obj.type

			if obj.type == allowedType then
				table.insert(result, obj)
			else
				containsIllegal = true
			end
		end
	end

	return result, containsIllegal
end

--- @param left ClickedTreeGroup2RuntimeItem
--- @param right ClickedTreeGroup2RuntimeItem
--- @return boolean
local function SortByName(left, right)
	local leftScope = Addon:GetScopeFromUid(left.uid)
	local rightScope = Addon:GetScopeFromUid(right.uid)

	local leftObj = Clicked:GetByUid(left.uid)
	local rightObj = Clicked:GetByUid(right.uid)

	leftScope = leftScope or leftObj.scope --- @diagnostic disable-line: need-check-nil
	rightScope = rightScope or rightObj.scope --- @diagnostic disable-line: need-check-nil

	-- Sort by scope
	if leftScope > rightScope then
		return true
	end

	if leftScope < rightScope then
		return false
	end

	-- Groups go above bindings
	if left.children ~= nil and right.children == nil then
		return true
	end

	if left.children == nil and right.children ~= nil then
		return false
	end

	if leftObj ~= nil and rightObj ~= nil then
		if leftObj.type == Clicked.DataObjectType.GROUP and rightObj.type == Clicked.DataObjectType.GROUP then
			--- @cast leftObj Group
			--- @cast rightObj Group

			-- Enabled groups go above disabled groups
			if left.isAnyChildEnabled and not right.isAnyChildEnabled then
				return true
			end

			if not left.isAnyChildEnabled and right.isAnyChildEnabled then
				return false
			end
		elseif leftObj.type == Clicked.DataObjectType.BINDING and rightObj.type == Clicked.DataObjectType.BINDING then
			--- @cast leftObj Binding
			--- @cast rightObj Binding

			-- Enabled bindings go above disabled bindings
			if left.enabled and not right.enabled then
				return true
			end

			if not left.enabled and right.enabled then
				return false
			end
		end
	end

	if left.title < right.title then
		return true
	end

	if left.title > right.title then
		return false
	end

	return left.uid < right.uid
end

--- @param left ClickedTreeGroup2RuntimeItem
--- @param right ClickedTreeGroup2RuntimeItem
--- @return boolean
local function SortByKey(left, right)
	local leftScope = Addon:GetScopeFromUid(left.uid)
	local rightScope = Addon:GetScopeFromUid(right.uid)

	local leftObj = Clicked:GetByUid(left.uid)
	local rightObj = Clicked:GetByUid(right.uid)

	leftScope = leftScope or leftObj.scope --- @diagnostic disable-line: need-check-nil
	rightScope = rightScope or rightObj.scope --- @diagnostic disable-line: need-check-nil

	-- Sort by scope
	if leftScope > rightScope then
		return true
	end

	if leftScope < rightScope then
		return false
	end

	-- Groups go above bindings
	if left.children ~= nil and right.children == nil then
		return true
	end

	if left.children == nil and right.children ~= nil then
		return false
	end

	if leftObj ~= nil and rightObj ~= nil then
		if leftObj.type == Clicked.DataObjectType.GROUP and rightObj.type == Clicked.DataObjectType.GROUP then
			--- @cast leftObj Group
			--- @cast rightObj Group

			-- Enabled groups go above disabled groups
			if left.isAnyChildEnabled and not right.isAnyChildEnabled then
				return true
			end

			if not left.isAnyChildEnabled and right.isAnyChildEnabled then
				return false
			end
		elseif leftObj.type == Clicked.DataObjectType.BINDING and rightObj.type == Clicked.DataObjectType.BINDING then
			--- @cast leftObj Binding
			--- @cast rightObj Binding

			return Addon:CompareBindings(leftObj, rightObj, left.enabled, right.enabled)
		end
	end

	if left.title < right.title then
		return true
	end

	if left.title > right.title then
		return false
	end

	return left.uid < right.uid
end

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigWindow
--- @field private frame? ClickedFrame
--- @field private pages { [string]: BindingConfigPage }
--- @field private pageStack { page: string, payload: any[] }[]
--- @field private currentPage? string
--- @field private sortMode "key"|"name"
--- @field private tree ClickedTreeGroup2Item[]
--- @field private treeItems { [integer]: ClickedTreeGroup2Item }
--- @field private treeStatus ClickedTreeGroup2Status
--- @field private redrawTimer? TimerCallback
--- @field private bindingCopyTarget? integer
--- @field private wereBindingsReloaded? boolean
Addon.BindingConfig.Window = {
	PAGE_BINDING = "binding",
	PAGE_EXPORT_STRING = "exportString",
	PAGE_GROUP = "group",
	PAGE_ICON_SELECT = "iconSelect",
	PAGE_IMPORT_STRING = "importString",
	PAGE_NEW = "new",
	pages = {
		binding = Addon.BindingConfig.BindingPage,
		exportString = Addon.BindingConfig.ExportStringPage,
		group = Addon.BindingConfig.GroupPage,
		iconSelect = Addon.BindingConfig.IconSelectPage,
		importString = Addon.BindingConfig.ImportStringPage,
		new = Addon.BindingConfig.NewPage
	},
	pageStack = {},
	sortMode = "key",
	tree = {},
	treeItems = {},
	treeStatus = {}
}

function Addon.BindingConfig.Window:Open()
	if self:IsOpen() then
		return
	end

	self:CreateFrame()

	self:DrawHeader()

	self:CreateOrUpdateTree()
	self:CreateTreeFrame()
end

function Addon.BindingConfig.Window:Close()
	if not self:IsOpen() then
		return
	end

	self.frame:Hide()

	table.wipe(self.tree)
	table.wipe(self.treeItems)
end

function Addon.BindingConfig.Window:IsOpen()
	return self.frame ~= nil and self.frame:IsVisible()
end

--- @param page string|BindingConfigPage
--- @param ... any
function Addon.BindingConfig.Window:SetPage(page, ...)
	local target = self:GetPage(page)
	if target == nil then
		return
	end

	table.wipe(self.pageStack)
	self.pageStack[1] = { page = target, payload = { ... } }

	self:ActivatePage()
end

--- @param page string|BindingConfigPage
--- @param ... any
function Addon.BindingConfig.Window:PushPage(page, ...)
	local target = self:GetPage(page)
	if target == nil then
		return
	end

	for i = 1, #self.pageStack do
		if self.pageStack[i] == target then
			table.remove(self.pageStack, i)
			break
		end
	end

	table.insert(self.pageStack, { page = target, payload = { ... } })
	self:ActivatePage()
end

--- @param page? string|BindingConfigPage
function Addon.BindingConfig.Window:PopPage(page)
	local target = self:GetPage(page)

	if #self.pageStack == 1 then
		if self.currentPage == target then
			self:Close()
		end

		return
	end

	if target == nil then
		table.remove(self.pageStack)
		self:ActivatePage()
		return
	end

	for i = #self.pageStack, 1, -1 do
		if self.pageStack[i].page == target then
			table.remove(self.pageStack, i)

			if target == self.currentPage then
				self:ActivatePage()
			end

			break
		end
	end
end

function Addon.BindingConfig.Window:OnBindingReload()
	self.wereBindingsReloaded = true
	self:RedrawTree()
end

function Addon.BindingConfig.Window:RedrawTree()
	if not self:IsOpen() or self.redrawTimer ~= nil then
		return
	end

	self.redrawTimer = C_Timer.NewTimer(0, function()
		self.redrawTimer = nil

		self:CreateOrUpdateTree()
		self.treeWidget:SetTree(self.tree)

		--- @type integer[]
		local selected = CopyTable(self.treeStatus.selected or {})
		local selecctionChanged = false

		for i = #selected, 1, -1 do
			if self.treeItems[selected[i]] == nil then
				table.remove(selected, i)
				selecctionChanged = true
			end
		end

		if selecctionChanged then
			self.treeWidget:Select(selected)
		else
			self.treeWidget:RefreshTree()
		end

		self:HandleOnBindingReload()
	end)
end

function Addon.BindingConfig.Window:RedrawPage()
	local currentPage = self.currentPage

	if currentPage ~= nil then
		local impl = self.pages[currentPage]

		self.treeWidget:ReleaseChildren()
		Addon:SafeCall(impl.Redraw, impl)
	end

	self.frame:SetStatusText(string.format("%s | %s", Clicked.VERSION, Addon.db:GetCurrentProfile()))
end

--- @private
function Addon.BindingConfig.Window:HandleOnBindingReload()
	if self.wereBindingsReloaded then
		self.wereBindingsReloaded = false

		local currentPage = self.currentPage

		if currentPage ~= nil then
			local impl = self.pages[currentPage]
			Addon:SafeCall(impl.OnBindingReload, impl)
		end
	end
end

--- @private
function Addon.BindingConfig.Window:DrawHeader()
	-- create binding button
	do
		local function OnClick()
			self:SetPage(self.PAGE_NEW)
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["New"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetAutoWidth(true)

		self.frame:AddChild(widget)
	end

	-- import button
	do
		local function OnClick()
			self:SetPage(self.PAGE_IMPORT_STRING, Addon.BindingConfig.ImportStringModes.BINDING_GROUP)
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Import"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetAutoWidth(true)

		self.frame:AddChild(widget)
	end

	local line = AceGUI:Create("ClickedSimpleGroup") --[[@as ClickedSimpleGroup]]
	line:SetFullWidth(true)
	line:SetLayout("Table")
	line:SetUserData("table", {
		columns = { 0, 0, 1, 0 },
		spaceH = 1
	})

	self.frame:AddChild(line)

	-- Search bar
	do
		--- @type TimerCallback?
		local redrawTimer = nil

		local function OnSearchTermChanged(_, _, text)
			if redrawTimer ~= nil then
				redrawTimer:Cancel()
				redrawTimer = nil
			end

			redrawTimer = C_Timer.NewTimer(SEARCH_FILTER_APPLY_DELAY, function()
				redrawTimer = nil
				self.treeWidget:SetFilter(text)
				self.treeWidget:RefreshTree()
			end)

		end

		local tooltipSubtext = Addon.L["You can search for a title or keybind"]

		local widget = AceGUI:Create("ClickedSearchBox") --[[@as ClickedSearchBox]]
		widget:DisableButton(true)
		widget:SetPlaceholderText(Addon.L["Search..."])
		widget:SetCallback("SearchTermChanged", OnSearchTermChanged)
		widget:SetTooltipText(Addon.L["Search Filters"], tooltipSubtext)
		widget:SetWidth(250)

		line:AddChild(widget)
	end

	-- Sort by
	do
		--- @param widget AceGUIButton
		local function OnClick(widget)
			self.sortMode = self.sortMode == "key" and "name" or "key"

			widget:SetText(self.sortMode == "key" and Addon.L["Key"] or Addon.L["ABC"])

			self.treeWidget:SetSortMethod(self.sortMode == "key" and SortByKey or SortByName)
			self.treeWidget:RefreshTree()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(self.sortMode == "key" and Addon.L["Key"] or Addon.L["ABC"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetWidth(75)

		line:AddChild(widget)
	end

	-- Spacer
	do
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetText("")

		line:AddChild(widget)
	end

	-- Visualize button
	do
		local function OnClick()
			self:Close()
			Addon.KeyVisualizer:Open()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Show on keyboard"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)
	end
end

--- @private
function Addon.BindingConfig.Window:ActivatePage()
	-- If the window is not open, open it first, we'll get back here a second time
	if not self:IsOpen() then
		self:Open()
		return
	end

	local currentPage = self.currentPage

	if currentPage ~= nil then
		local page = self.pages[currentPage]
		Addon:SafeCall(page.Hide, page)

		page.controller = nil
		page.container = nil
		page.targets = nil

		self.currentPage = nil
	end

	local newPage = self.pageStack[#self.pageStack]
	self.currentPage = newPage.page

	local impl = self.pages[newPage.page]
	impl.controller = self
	impl.container = self.treeWidget
	impl.targets = FilterTargets(self.treeStatus.selected)

	Addon:SafeCall(impl.Show, impl, unpack(newPage.payload or {}))
	self:RedrawPage()

	if #self.pageStack == 1 and not impl.keepTreeSelection then
		self.treeWidget:Select({})
	end
end

--- @private
--- @param page? string|BindingConfigPage
--- @return string?
function Addon.BindingConfig.Window:GetPage(page)
	if type(page) == "string" then
		return page
	end

	for id, p in pairs(self.pages) do
		if p == page then
			return id
		end
	end

	return nil
end

--- @private
function Addon.BindingConfig.Window:CreateFrame()
	--- @param container AceGUIContainer
	local function OnClose(container)
		local currentPage = self.currentPage

		if currentPage ~= nil then
			local page = self.pages[currentPage]
			Addon:SafeCall(page.Hide, page)

			page.controller = nil
			page.container = nil
			page.targets = nil

			self.currentPage = nil
		end

		container:ReleaseChildren()
		contextMenuFrame:Hide()

		self.bindingCopyTarget = nil
		self.frame = nil
	end

	local function OnReceiveDrag()
		local type, p2, _, p4 = GetCursorInfo()

		--- @type BindingType
		local actionType

		--- @type integer
		local id

		if type == "item" then
			actionType = Addon.BindingTypes.ITEM
			id = p2 --[[@as integer]]
		elseif type == "spell" then
			actionType = Addon.BindingTypes.SPELL
			id = p4 --[[@as integer]]
		elseif type == "petaction" then
			actionType = Addon.BindingTypes.SPELL
			id = p2 --[[@as integer]]
		elseif type == "macro" then
			actionType = Addon.BindingTypes.MACRO
			id = p2 --[[@as integer]]
		end

		if actionType ~= nil then
			local binding = Clicked:CreateBinding()
			binding.actionType = actionType

			if binding.actionType == Addon.BindingTypes.SPELL then
				binding.action.spellValue = id
			elseif binding.actionType == Addon.BindingTypes.ITEM then
				binding.action.itemValue = id
			elseif binding.actionType == Addon.BindingTypes.MACRO then
				local name, icon, content = GetMacroInfo(id)
				binding.action.macroName = name
				binding.action.macroIcon = icon
				binding.action.macroValue = content
			end

			Clicked:ReloadBinding(binding, true)

			ClearCursor()
		end
	end

	self.frame = AceGUI:Create("ClickedFrame") --[[@as ClickedFrame]]
	self.frame:SetCallback("OnClose", OnClose)
	self.frame:SetCallback("OnReceiveDrag", OnReceiveDrag)
	self.frame:SetTitle(Addon.L["Clicked Binding Configuration"])
	self.frame:SetLayout("Flow")
	self.frame:SetWidth(900)
	self.frame:SetHeight(600)
end

--- @private
function Addon.BindingConfig.Window:CreateOrUpdateTree()
	table.wipe(self.tree)

	--- @type { [integer]: DataObject[] }
	local hierarchy = {}

	--- @type table<integer, boolean>
	local existing = {}
	for k in pairs(self.treeItems) do
		if k > 0 then
			existing[k] = true
		end
	end

	for _, group in Clicked:IterateGroups() do
		local parent = Addon:GetScopeUid(group.scope)
		hierarchy[parent] = hierarchy[parent] or {}
		table.insert(hierarchy[parent], group)
	end

	for _, binding in Clicked:IterateConfiguredBindings() do
		local parent = binding.parent or Addon:GetScopeUid(binding.scope)
		hierarchy[parent] = hierarchy[parent] or {}
		table.insert(hierarchy[parent], binding)
	end

	for _, scope in pairs(Addon.BindingScope) do
		local uid = Addon:GetScopeUid(scope)

		--- @type ClickedTreeGroup2Item
		self.treeItems[uid] = self.treeItems[uid] or {
			uid = uid,
			title = Addon:GetLocalizedScope(scope),
			children = {}
		}

		table.wipe(self.treeItems[uid].children)

		--- @type integer[]
		local queue = { uid }

		while #queue > 0 do
			local current = table.remove(queue, 1)
			local children = self.treeItems[current].children --[[@as ClickedTreeGroup2Item[]]

			if hierarchy[current] ~= nil then
				for _, item in ipairs(hierarchy[current]) do
					existing[item.uid] = nil

					if item.type == Clicked.DataObjectType.BINDING then
						--- @cast item Binding

						local title, icon = Addon:GetBindingNameAndIcon(item)

						local data = self.treeItems[item.uid]
						if data == nil then
							data = {
								uid = item.uid,
								title = title,
								subtitle = #item.keybind > 0 and Addon:SanitizeKeybind(item.keybind) or Addon.L["UNBOUND"],
								icon = icon,
								enabled = Clicked:IsBindingLoaded(item)
							}

							self.treeItems[item.uid] = data
						else
							data.title = title
							data.subtitle = #item.keybind > 0 and Addon:SanitizeKeybind(item.keybind) or Addon.L["UNBOUND"]
							data.icon = icon
							data.enabled = Clicked:IsBindingLoaded(item)
						end

						table.insert(children, data)
					elseif item.type == Clicked.DataObjectType.GROUP then
						--- @cast item Group

						local title, icon = Addon:GetGroupNameAndIcon(item)

						--- @type ClickedTreeGroup2Item
						local data = self.treeItems[item.uid]
						if data == nil then
							data = {
								uid = item.uid,
								title = title,
								icon = icon,
								children = {}
							}

							self.treeItems[item.uid] = data
						else
							data.title = title
							data.icon = icon
							table.wipe(data.children)
						end

						table.insert(children, data)
						table.insert(queue, item.uid)
					end
				end
			end
		end

		table.insert(self.tree, self.treeItems[uid])
	end

	for uid in pairs(existing) do
		local item = self.treeItems[uid] --[[@as ClickedTreeGroup2RuntimeItem]]

		if item.parent ~= nil then
			for i = 1, #item.parent.children do
				if item.parent.children[i].uid == uid then
					table.remove(item.parent.children, i)
					break
				end
			end
		end

		self.treeItems[uid] = nil
	end
end

--- @private
function Addon.BindingConfig.Window:CreateTreeFrame()
	--- @return integer[]
	local function FindSelectedItems()
		if #self.treeStatus.selected > 0 then
			return self.treeStatus.selected
		end

		--- @type ClickedTreeGroup2Item[]
		local queue = { }

		for _, item in ipairs(self.tree) do
			table.insert(queue, item)
		end

		while #queue > 0 do
			--- @type ClickedTreeGroup2Item
			local current = table.remove(queue, 1)

			if current.uid > 0 then
				return { current.uid }
			end

			for _, child in ipairs(current.children) do
				table.insert(queue, child)
			end
		end

		return {}
	end

	--- @param selected integer[]
	local function OnGroupSelected(_, _, selected)
		local targets = FilterTargets(selected)

		if #targets > 0 then
			self:SetPage(targets[1].type == Clicked.DataObjectType.BINDING and self.PAGE_BINDING or self.PAGE_GROUP)
		else
			local page = self.pageStack[#self.pageStack].page

			if page == self.PAGE_BINDING or page == self.PAGE_GROUP then
				self:SetPage(self.PAGE_NEW)
			end
		end

		contextMenuFrame:Hide()
	end

	--- @param uid integer
	--- @param button Button
	local function OnButtonEnter(_, _, uid, button)
		local obj = Clicked:GetByUid(uid)
		if obj == nil then
			return
		end

		local text = ""
		local subtext = nil

		if obj.type == Clicked.DataObjectType.BINDING then
			--- @cast obj Binding

			text = Addon:GetBindingNameAndIcon(obj)

			subtext = Addon.L["Targets"] .. "\n"

			if Addon:IsHovercastEnabled(obj) then
				local str = Addon:GetLocalizedTargetString(obj.targets.hovercast)

				if #str > 0 then
					str = str .. " "
				end

				str = str .. Addon.L["Unit frame"]
				subtext = subtext .. "* " .. str .. "\n"
			end

			if Addon:IsMacroCastEnabled(obj) then
				for i, target in ipairs(obj.targets.regular) do
					local str = Addon:GetLocalizedTargetString(target)
					subtext = subtext .. i .. ". " .. str .. "\n"
				end
			end

			subtext = subtext .. "\n"
			subtext = subtext .. (self.treeItems[uid].enabled and Addon.L["Loaded"] or Addon.L["Unloaded"])
		elseif obj.type == Clicked.DataObjectType.GROUP then
			--- @cast obj Group

			text = Addon:GetGroupNameAndIcon(obj)

			local bindings = Clicked:GetByParent(uid)
			local numLoaded = 0

			for _, binding in ipairs(bindings) do
				if self.treeItems[binding.uid].enabled then
					numLoaded = numLoaded + 1
				end
			end

			subtext = string.format(Addon.L["%d loaded bindings"], numLoaded)
		end

		if IsShiftKeyDown() then
			subtext = subtext .. string.format("\nuid: %d", obj.uid)
		end

		Addon:ShowTooltip(button, text, subtext, "RIGHT", "LEFT")
	end

	--- @param uid integer
	--- @param button Button
	local function OnButtonContext(_, _, uid, button)
		local obj = Clicked:GetByUid(uid)
		if obj == nil then
			return
		end

		if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.TWW then
			MenuUtil.CreateContextMenu(UIParent, function(_, rootDescription)
				if obj.type == Clicked.DataObjectType.BINDING then
					--- @cast obj Binding

					rootDescription:CreateButton(Addon.L["Copy Data"], function()
						self.bindingCopyTarget = uid
					end)

					rootDescription:CreateButton(Addon.L["Paste Data"], function()
						local source = Clicked:GetByUid(self.bindingCopyTarget)

						if source ~= nil then
							--- @cast source Binding
							local clone = CopyTable(source)
							Addon:ReplaceBindingContents(obj, clone)
						end
					end):SetEnabled(self.bindingCopyTarget ~= nil)

					rootDescription:CreateButton(Addon.L["Duplicate"], function()
						local clone = Addon:CloneBinding(obj)
						self.treeWidget:Select(clone.uid)
					end)

					do
						local submenu = rootDescription:CreateButton(Addon.L["Convert to"])

						local function CreateOption(type, label)
							if obj.actionType == type then
								return
							end

							submenu:CreateButton(label, function()
								obj.actionType = type

								Addon:EnsureSupportedTargetModes(obj.targets, obj.keybind, type)
								Clicked:ReloadBinding(obj, true)
								self.treeWidget:Select(obj.uid)
							end)
						end

						CreateOption(Addon.BindingTypes.SPELL, Addon.L["Cast a spell"])
						CreateOption(Addon.BindingTypes.ITEM, Addon.L["Use an item"])
						CreateOption(Addon.BindingTypes.CANCELAURA, Addon.L["Cancel an aura"])
						CreateOption(Addon.BindingTypes.UNIT_SELECT, Addon.L["Target the unit"])
						CreateOption(Addon.BindingTypes.UNIT_MENU, Addon.L["Open the unit menu"])
						CreateOption(Addon.BindingTypes.MACRO, Addon.L["Run a macro"])
						CreateOption(Addon.BindingTypes.APPEND, Addon.L["Append a binding segment"])
					end
				end

				do
					local submenu = rootDescription:CreateButton(Addon.L["Change scope"])

					local function CreateOption(scope, label)
						submenu:CreateRadio(label, function()
							return obj.scope == scope
						end, function()
							Addon:ChangeScope(obj, scope)

							self:CreateOrUpdateTree()
							self.treeWidget:Select(obj.uid)
						end)
					end

					CreateOption(Addon.BindingScope.GLOBAL, Addon.L["Global"])
					CreateOption(Addon.BindingScope.PROFILE, Addon.L["Profile"])
				end

				rootDescription:CreateButton(Addon.L["Share"], function()
					self:SetPage(self.PAGE_EXPORT_STRING, Addon.BindingConfig.ExportStringModes.BINDING_GROUP, obj)
				end)

				rootDescription:CreateButton(Addon.L["Delete"], function()
					local function OnConfirm()
						if InCombatLockdown() then
							return
						end

						if obj.type == Clicked.DataObjectType.BINDING then
							--- @cast obj Binding
							Clicked:DeleteBinding(obj)
						elseif obj.type == Clicked.DataObjectType.GROUP then
							--- @cast obj Group
							Clicked:DeleteGroup(obj)
						end
					end

					if IsShiftKeyDown() then
						OnConfirm()
					else
						--- @type string
						local msg

						if obj.type == Clicked.DataObjectType.BINDING then
							--- @cast obj Binding
							msg = Addon.L["Are you sure you want to delete this binding?"] .. "\n\n"
							msg = msg .. obj.keybind .. " " .. Addon:GetBindingNameAndIcon(obj)
						elseif obj.type == Clicked.DataObjectType.GROUP then
							--- @cast obj Group
							local bindings = Clicked:GetByParent(obj.uid)

							msg = Addon.L["Are you sure you want to delete this group and ALL bindings it contains? This will delete %s bindings."]:format(#bindings) .. "\n\n"
							msg = msg .. Addon:GetGroupNameAndIcon(obj)
						end

						Addon:ShowConfirmationPopup(msg, OnConfirm)
					end
				end)
			end)
		else
			local menu = {}

			if obj.type == Clicked.DataObjectType.BINDING then
				--- @cast obj Binding

				table.insert(menu, {
					text = Addon.L["Copy Data"],
					notCheckable = true,
					func = function()
						self.bindingCopyTarget = uid
					end
				})

				table.insert(menu, {
					text = Addon.L["Paste Data"],
					notCheckable = true,
					disabled = self.bindingCopyTarget == nil,
					func = function()
						local source = Clicked:GetByUid(self.bindingCopyTarget)

						if source ~= nil then
							--- @cast source Binding
							local clone = CopyTable(source)
							Addon:ReplaceBindingContents(obj, clone)
						end
					end
				})

				table.insert(menu, {
					text = Addon.L["Duplicate"],
					notCheckable = true,
					func = function()
						local clone = Addon:CloneBinding(obj)
						self.treeWidget:Select(clone.uid)
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
						if obj.actionType == type then
							return
						end

						table.insert(convertTo.menuList, {
							text = label,
							notCheckable = true,
							func = function()
								obj.actionType = type

								Addon:EnsureSupportedTargetModes(obj.targets, obj.keybind, type)
								Clicked:ReloadBinding(obj, true)
								self.treeWidget:Select(obj.uid)

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
						checked = obj.scope == scope,
						func = function()
							Addon:ChangeScope(obj, scope)

							self:CreateOrUpdateTree()
							self.treeWidget:Select(obj.uid)

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
				func = function ()
					self:SetPage(self.PAGE_EXPORT_STRING, Addon.BindingConfig.ExportStringModes.BINDING_GROUP, obj)
				end
			})

			table.insert(menu, {
				text = Addon.L["Delete"],
				notCheckable = true,
				func = function()
					local function OnConfirm()
						if InCombatLockdown() then
							return
						end

						if obj.type == Clicked.DataObjectType.BINDING then
							--- @cast obj Binding
							Clicked:DeleteBinding(obj)
						elseif obj.type == Clicked.DataObjectType.GROUP then
							--- @cast obj Group
							Clicked:DeleteGroup(obj)
						end
					end

					if IsShiftKeyDown() then
						OnConfirm()
					else
						--- @type string
						local msg

						if obj.type == Clicked.DataObjectType.BINDING then
							--- @cast obj Binding
							msg = Addon.L["Are you sure you want to delete this binding?"] .. "\n\n"
							msg = msg .. obj.keybind .. " " .. Addon:GetBindingNameAndIcon(obj)
						elseif obj.type == Clicked.DataObjectType.GROUP then
							--- @cast obj Group
							local bindings = Clicked:GetByParent(obj.uid)

							msg = Addon.L["Are you sure you want to delete this group and ALL bindings it contains? This will delete %s bindings."]:format(#bindings) .. "\n\n"
							msg = msg .. Addon:GetGroupNameAndIcon(obj)
						end

						Addon:ShowConfirmationPopup(msg, OnConfirm)
					end
				end
			})

			EasyMenu(menu, contextMenuFrame, button, 0, 0, "MENU")
		end
	end

	self.treeWidget = AceGUI:Create("ClickedTreeGroup2") --[[@as ClickedTreeGroup2]]
	self.treeWidget:SetLayout("Flow")
	self.treeWidget:SetFullWidth(true)
	self.treeWidget:SetFullHeight(true)
	self.treeWidget:SetCallback("OnGroupSelected", OnGroupSelected)
	self.treeWidget:SetCallback("OnButtonEnter", OnButtonEnter)
	self.treeWidget:SetCallback("OnButtonContext", OnButtonContext)
	self.treeWidget:SetStatusTable(self.treeStatus)
	self.treeWidget:SetSortMethod(self.sortMode == "key" and SortByKey or SortByName)
	self.treeWidget:SetTree(self.tree)

	if #self.pageStack == 0 then
		local selected = FindSelectedItems()
		local objects = FilterTargets(selected)

		if #objects > 0 then
			self.treeWidget:Select(selected, true)
		else
			self:SetPage(self.PAGE_NEW)
		end
	else
		local page = self.pageStack[#self.pageStack].page

		if page == self.PAGE_BINDING or page == self.PAGE_GROUP then
			local selected = FindSelectedItems()
			self.treeWidget:Select(selected, true)
		else
			self:ActivatePage()
		end
	end

	self.frame:AddChild(self.treeWidget)
end

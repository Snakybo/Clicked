local AceConsole = LibStub("AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

local GUI = Clicked.GUI

local KEYBIND_ORDER_LIST = {
	"BUTTON1", "BUTTON2", "BUTTON3", "BUTTON4", "BUTTON5", "MOUSEWHEELUP", "MOUSEWHEELDOWN",
	"`", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "-", "=",
	"NUMPAD0", "NUMPAD1", "NUMPAD2", "NUMPAD3", "NUMPAD4", "NUMPAD5", "NUMPAD6", "NUMPAD7", "NUMPAD8", "NUMPAD9", "NUMPADDIVIDE", "NUMPADMULTIPLY", "NUMPADMINUS", "NUMPADPLUS", "NUMPADDECIMAL",
	"F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
	"TAB", "CAPSLOCK", "INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN", "[", "]", "\\", ";", "'", ",", ".", "/"
}

local spellbookButtons = {}
local options = {}

-- Utility functions

local function ClearOptionsTable()
	options = {
		root = nil,
		item = nil,
		tab = {},
		tree = {
			status = {},
			items = {},
			container = nil
		},
		widgets = {}
	}
end

local function GetSelectedItem(original, items)
	if #items == 0 then
		return nil
	end

	local selected = original
	
	if selected ~= nil then
		local exists = false

		for _, item in ipairs(items) do
			if item.value == selected then
				exists = true
				break
			end
		end

		if not exists then
			selected = nil
		end
	end

	if selected == nil then
		selected = items[1].value
	end

	return selected
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

	if Clicked:IsBindingActive(left.binding) and not Clicked:IsBindingActive(right.binding) then
		return true
	end

	if not Clicked:IsBindingActive(left.binding) and Clicked:IsBindingActive(right.binding) then
		return false
	end

	local function GetKeybindKey(bind)
		local mods = {}
		local result = ""

		for match in string.gmatch(bind, "[^-]+") do
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

	return GetKeybindKey(left.binding.keybind) < GetKeybindKey(right.binding.keybind)
end

local function ConstructTreeViewItem(index, binding)
	local item = {}

	item.value = index
	item.binding = binding
	item.icon = "Interface\\ICONS\\INV_Misc_QuestionMark"

	if binding.type == Clicked.TYPE_SPELL then
		item.text1 = "Cast " .. (binding.action.spell or "")
		item.icon = select(3, GetSpellInfo(binding.action.spell)) or item.icon
	elseif binding.type == Clicked.TYPE_ITEM then
		item.text1 = "Use " .. (binding.action.item or "")
		item.icon = select(10, GetItemInfo(binding.action.item)) or item.icon
	elseif binding.type == Clicked.TYPE_MACRO then
		item.text1 = "Run Custom Macro"
	elseif binding.type == Clicked.TYPE_UNIT_SELECT then
		item.text1 = "Target the unit"
	elseif binding.type == Clicked.TYPE_UNIT_MENU then
		item.text1 = "Open the unit menu"
	end

	item.text2 = binding.keybind

	if Clicked:IsBindingActive(binding) then
		item.text3 = "L"
	else
		item.text3 = "U"
	end

	return item
end

local function ConstructTreeView()
	local items = {}

	for index, binding in ipairs(Clicked.bindings) do
		local item = ConstructTreeViewItem(index, binding)
		table.insert(items, item)
	end

	table.sort(items, TreeSortFunc)
	
	options.tree.items = items
end

-- Spell book integration

local function EnableSpellbookHandlers(handler)
	if not SpellBookFrame:IsVisible() then
		return
	end

	if InCombatLockdown() then
		return
	end

	if #spellbookButtons == 0 then
		for i = 1, 12 do
			local parent = _G["SpellButton" .. i]
			local button = CreateFrame("Button", "ClickedSpellbookButton" .. i, parent, "ClickedSpellbookButtonTemplate")
			button.parent = parent
			button:RegisterForClicks("LeftButtonUp")
			button:SetID(parent:GetID())

			spellbookButtons[i] = button
		end
	end

	for _, button in ipairs(spellbookButtons) do
		if button.parent:IsEnabled() then
			button:SetScript("OnClick", function(self)
				local slot = SpellBook_GetSpellBookSlot(self:GetParent())
				local name = GetSpellBookItemName(slot, SpellBookFrame.bookType)

				if name ~= nil and name ~= "" then
					handler(name)
				end
			end)
			button:SetScript("OnEnter", function(self)
				if self.parent:IsEnabled() then
					SpellButton_OnEnter(self.parent)
				else
					self:GetHighlightTexture():Hide()
				end
			end)
			button:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			button:Show()
		end
	end
end

local function DisableSpellbookHandlers()
	GameTooltip:Hide()

	for _, button in ipairs(spellbookButtons) do
		button:SetScript("OnClick", nil)
		button:SetScript("OnEnter", nil)
		button:SetScript("OnLeave", nil)
		button:Hide()
	end
end

-- Binding action page and components

local function DrawSpellSelection(container, action)
	-- target spell text
	do
		local widget = GUI:EditBox("Target Spell", "OnEnterPressed", action, "spell")
		widget:SetRelativeWidth(0.75)

		container:AddChild(widget)
	end

	-- pick from spellbook button
	do
		local function OnClick()
			if not InCombatLockdown() then
				SpellBookFrame:HookScript("OnHide", function()
					DisableSpellbookHandlers()
				end)

				ShowUIPanel(SpellBookFrame)

				EnableSpellbookHandlers(function(name)
					if not InCombatLockdown() then
						action.spell = name
						Clicked:ReloadActiveBindings()

						HideUIPanel(SpellBookFrame)
					end
				end)
			end
		end

		local function OnEnter(widget)
			local tooltip = AceGUI.tooltip

			tooltip:SetOwner(widget.frame, "ANCHOR_NONE")
			tooltip:ClearAllPoints()
			tooltip:SetPoint("LEFT", widget.frame, "RIGHT")
			tooltip:SetText(text or "Click on a spell book entry to select it", 1, 0.82, 0, true)
			tooltip:Show()
		end

		local function OnLeave()
			local tooltip = AceGUI.tooltip
			tooltip:Hide()
		end

		local widget = GUI:Button("Select", OnClick)
		widget:SetRelativeWidth(0.25)
		widget:SetCallback("OnEnter", OnEnter)
		widget:SetCallback("OnLeave", OnLeave)

		container:AddChild(widget)
	end

	-- interrupt cast toggle
	do
		local widget = GUI:CheckBox("Interrupt current cast?", action, "stopCasting")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end
end

local function DrawItemSelection(container, action)
	-- target item text
	do
		local widget = GUI:EditBox("Target Item", "OnEnterPressed", action, "item")
		widget:SetRelativeWidth(0.75)

		container:AddChild(widget)
	end

	-- pick from inventory button
	do
		local function OnClick()
		end

		local widget = GUI:Button("Select", OnClick)
		widget:SetRelativeWidth(0.25)
		widget:SetDisabled(true)

		container:AddChild(widget)
	end

	-- interrupt cast toggle
	do
		local widget = GUI:CheckBox("Interrupt current cast?", action, "stopCasting")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end
end

local function DrawMacroSelection(container, action)
	-- macro text field
	do
		local widget = GUI:MultilineEditBox("Macro Text", "OnEnterPressed", action, "macro")
		widget:SetFullWidth(true)
		widget:SetFullHeight(true)

		container:AddChild(widget)
	end
end

local function DrawTargetSelection(container, binding)
	local function DrawTargetUnitDropdown(target, index)
		local function OnValueChanged(frame, event, value)
			if not InCombatLockdown()then
				if index == 0 then
					local new = Clicked:GetNewBindingTargetTemplate()
					new.unit = value
					table.insert(binding.targets, new)
				elseif value == "_DELETE" then
					table.remove(binding.targets, index)
				else
					if value == Clicked.TARGET_UNIT_GLOBAL then
						local new = Clicked:GetNewBindingTargetTemplate()
						new.unit = value
						binding.targets = { new }
					else
						target.unit = value
					end
				end

				Clicked:ReloadActiveBindings()
			else
				if index ~= 0 then
					widget:SetValue(unit)
				else
					widget:SetValue("_NONE")
				end
			end
		end

		local items = {
			PLAYER = "Player (you)",
			TARGET = "Target",
			--MOUSEOVER_FRAME = "Mouseover (unit frame)",
			MOUSEOVER = "Mouseover (unit frame and 3D world)",
			FOCUS = "Focus",
			PARTY_1 = "Party 1",
			PARTY_2 = "Party 2",
			PARTY_3 = "Party 3",
			PARTY_4 = "Party 4",
			PARTY_5 = "Party 5"
		}

		local order = {
			"PLAYER",
			"TARGET",
			--"MOUSEOVER_FRAME",
			"MOUSEOVER",
			"FOCUS",
			"PARTY_1",
			"PARTY_2",
			"PARTY_3",
			"PARTY_4",
			"PARTY_5"
		}

		if index == 1 then
			items["GLOBAL"] = "None (global)"
			table.insert(order, 1, "GLOBAL")
		elseif index == 0 then
			items["_NONE"] = ""
			table.insert(order, 1, "_NONE")
		else
			items["_DELETE"] = "<Remove this option>"
			table.insert(order, "_DELETE")
		end

		local widget = GUI:Dropdown("On this target", items, order, target, "unit")
		widget:SetCallback("OnValueChanged", OnValueChanged)
		
		if index > 1 then
			widget:SetLabel("Or")
		end

		if Clicked:CanBindingTargetUnitBeHostile(target.unit) then
			widget:SetRelativeWidth(0.5)
		else
			widget:SetRelativeWidth(1)
		end

		container:AddChild(widget)
	end

	local function DrawTargetTypeDropdown(target)
		local items = {
			ANY = "Either friendly or hostile",
			HELP = "Friendly",
			HARM = "Hostile"
		}

		local order = {
			"ANY",
			"HELP",
			"HARM"
		}

		local widget = GUI:Dropdown("If it is", items, order, target, "type")
		widget:SetRelativeWidth(0.5)

		container:AddChild(widget)
	end

	for i, target in ipairs(binding.targets) do
		DrawTargetUnitDropdown(target, i)

		if Clicked:CanBindingTargetUnitBeHostile(target.unit) then
			DrawTargetTypeDropdown(target)
		end
	end

	if #binding.targets == 0 or (binding.targets[1].unit ~= Clicked.TARGET_UNIT_GLOBAL and binding.targets[#binding.targets].unit ~= Clicked.TARGET_UNIT_PLAYER) then
		DrawTargetUnitDropdown({ unit = "_NONE" }, 0)
	end
end

local function DrawBindingActionPage(container, binding)
	-- action help label
	do
		local widget = GUI:Label(container, "Here you can configure the action that will be performed when the key has been pressed.")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	if Clicked:IsRestrictedKeybind(binding.keybind) then
		-- restricted keybind help label
		do
			local widget = GUI:Label("Note: Bindings using the left or right mouse button are considered 'restricted' and will always be cast on the targeted unit frame.")
			widget:SetFullWidth(true)
			
			container:AddChild(widget)
		end
	end

	-- action dropdown
	do
		local items = {
			SPELL = "Cast a spell",
			ITEM = "Use an item",
			MACRO = "Run a macro",
			UNIT_SELECT = "Target the unit",
			UNIT_MENU = "Open the unit menu"
		}

		local order = {
			"SPELL",
			"ITEM",
			"MACRO",
			"UNIT_SELECT",
			"UNIT_MENU"
		}

		local widget = GUI:Dropdown("When the keybind has been pressed", items, order, binding, "type")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	if binding.type == Clicked.TYPE_SPELL then
		DrawSpellSelection(container, binding.action)
	elseif binding.type == Clicked.TYPE_ITEM then
		DrawItemSelection(container, binding.action)
	elseif binding.type == Clicked.TYPE_MACRO then
		DrawMacroSelection(container, binding.action)
	end

	if not Clicked:IsRestrictedKeybind(binding.keybind) then
		if binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM then
			DrawTargetSelection(container, binding)
		end
	end
end

-- Binding load options page and components

local function DrawLoadNeverSelection(container, load)
	-- never load toggle
	do
		local widget = GUI:CheckBox("Never load", load, "never")
		widget:SetFullWidth(true)
		
		container:AddChild(widget)
	end
end

local function DrawLoadSpecialization(container, specialization)
	local function GetSpecializations()
		local result = {}

		local numSpecs = GetNumSpecializations()

		for i = 1, numSpecs do
			local _, name = GetSpecializationInfo(i)
			table.insert(result, name)
		end

		return result
	end

	-- spec toggle
	do
		local widget = GUI:TristateCheckBox("Specialization", specialization, "selected")
		widget:SetTriState(true)

		if specialization.selected == 0 then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end

		container:AddChild(widget)
	end

	if specialization.selected == 1 then
		-- spec (single)
		do
			local items = GetSpecializations()
			local order = nil

			local widget = GUI:Dropdown(nil, items, order, specialization, "single")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	elseif specialization.selected == 2 then
		-- spec (multiple)
		do
			local items = GetSpecializations()
			local order = nil

			local widget = GUI:MultiselectDropdown(nil, items, order, specialization, "multiple")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

local function DrawLoadCombat(container, combat)
	-- combat toggle
	do
		local widget = GUI:CheckBox("Combat", combat, "selected")
		
		if not combat.selected then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end
		
		container:AddChild(widget)
	end

	-- combat state
	if combat.selected then
		do
			local items = {
				IN_COMBAT = "In combat",
				NOT_IN_COMBAT = "Not in combat"
			}

			local order = nil

			local widget = GUI:Dropdown(nil, items, order, combat, "state")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

local function DrawLoadSpellKnown(container, spellKnown)
	-- spell known toggle
	do
		local widget = GUI:CheckBox("Spell Known", spellKnown, "selected")
		
		if spellKnown.selected == 0 then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end

		container:AddChild(widget)
	end

	if spellKnown.selected then
		-- spell known
		do
			local widget = GUI:EditBox(nil, "OnEnterPressed", spellKnown, "spell")
			widget:SetRelativeWidth(0.5)
			
			container:AddChild(widget)
		end
	end
end

local function DrawBindingLoadOptionsPage(container, binding)
	local load = binding.load
	
	DrawLoadNeverSelection(container, load)
	DrawLoadSpecialization(container, load.specialization)
	DrawLoadCombat(container, load.combat)
	DrawLoadSpellKnown(container, load.spellKnown)
end

-- Main binding frame

local function DrawBinding(container)
	local item = options.item
	local binding = item.binding

	-- keybinding button
	do
		local widget = GUI:KeybindingButton(nil, binding, "keybind")
		widget:SetRelativeWidth(0.75)

		container:AddChild(widget)
	end

	-- delete button
	do
		local function OnClick()
			if InCombatLockdown() then
				return
			end

			local index

			for i, other in ipairs(options.tree.items) do
				if other == item then
					index = i
					break
				end
			end

			Clicked:DeleteBinding(item.binding)
			
			local items = options.tree.items
			local selected = nil

			if index <= #items then
				selected = items[index]
			elseif index - 1 >= 1 then
				selected = items[index - 1]
			end

			if selected ~= nil then
				options.tree.container:SelectByValue(selected.value)
			end
		end

		local widget = GUI:Button("Delete", OnClick)
		widget:SetRelativeWidth(0.25)

		container:AddChild(widget)
	end

	-- tabs
	do
		local function OnGroupSelected(container, event, group)
			local scrollFrame = AceGUI:Create("ScrollFrame")
			scrollFrame:SetLayout("Flow")
			
			container:AddChild(scrollFrame)

			if group == "action" then
				DrawBindingActionPage(scrollFrame, binding)
			elseif group == "load" then
				DrawBindingLoadOptionsPage(scrollFrame, binding)
			end
		end

		local items = {
			{
				text = "Action",
				value = "action"
			},
			{
				text = "Load Options",
				value = "load"
			}
		}

		local selected = GetSelectedItem(options.tab.selected, items)

		local widget = GUI:TabGroup(items, OnGroupSelected)		
		widget:SetStatusTable(options.tab)
		widget:SelectTab(selected)
		
		container:AddChild(widget)
	end
end

-- Main frame

local function DrawHeader(container)
	-- create binding button
	do
		local function OnClick()
			if InCombatLockdown() then
				return
			end

			Clicked:CreateNewBinding()
			options.tree.container:SelectByValue(#Clicked.bindings)
		end

		local widget = GUI:Button("Create Binding", OnClick)
		widget:SetWidth(210) -- coming from AceGUIContainer-ClickedTreeGroup

		container:AddChild(widget)
	end
end

local function DrawTreeView(container)
	ConstructTreeView()

	local selected = GetSelectedItem(options.tree.status.selected, options.tree.items)

	-- tree view
	do
		local function OnGroupSelected(container, event, group)
			container:ReleaseChildren()
			DisableSpellbookHandlers()

			local previous = options.item

			for _, item in ipairs(options.tree.items) do
				if item.value == group then
					options.item = item
					break
				end
			end

			if previous ~= nil and previous.value ~= options.item.value then
				options.tab = {}
			end

			DrawBinding(container)
		end

		local function OnButtonEnter(container, event, group, frame)
			local tooltip = AceGUI.tooltip
			local text = frame.text:GetText()
			local binding

			for i = 1, #options.tree.items do
				if options.tree.items[i].value == group then
					binding = options.tree.items[i].binding
					break
				end
			end

			if binding ~= nil then
				if binding.type == Clicked.TYPE_MACRO then
					text = binding.action.macro
				end

				text = text .. "\n\n"

				if Clicked:IsBindingActive(binding) then
					text = text .. "Loaded"
				else
					text = text .. "Not Loaded"
				end
			end

			tooltip:SetOwner(frame, "ANCHOR_NONE")
			tooltip:ClearAllPoints()
			tooltip:SetPoint("RIGHT", frame, "LEFT")
			tooltip:SetText(text or "", 1, 0.82, 0, true)
			tooltip:Show()
		end

		local function OnButtonLeave(container, event, group, frame)
			local tooltip = AceGUI.tooltip
			tooltip:Hide()
		end

		local widget = AceGUI:Create("ClickedTreeGroup")
		options.tree.container = widget

		widget:SetLayout("Flow")
		widget:SetFullWidth(true)
		widget:SetFullHeight(true)
		widget:SetTree(options.tree.items)
		widget:EnableButtonTooltips(false)
		widget:SetStatusTable(options.tree.status)
		widget:SetCallback("OnGroupSelected", OnGroupSelected)
		widget:SetCallback("OnButtonEnter", OnButtonEnter)
		widget:SetCallback("OnButtonLeave", OnButtonLeave)

		if selected ~= nil then
			widget:SelectByValue(selected)
		end

		container:AddChild(widget)
	end
end

-- Event handlers

local function OnGUIUpdateEvent()
	if options.root == nil or not options.root:IsVisible() then
		return
	end

	Clicked:ReloadActiveBindings()
end

local function OnBindingsChangedEvent()
	if options.root == nil or not options.root:IsVisible() then
		return
	end
	
	ConstructTreeView()
	options.tree.container:SetTree(options.tree.items)

	local selected = GetSelectedItem(options.tree.status.selected, options.tree.items)

	if selected ~= nil then
		options.tree.container:SelectByValue(selected)
	else
		options.tree.container:ReleaseChildren()
	end
end

function Clicked:OpenBindingConfig()
	if options.root ~= nil and options.root:IsVisible() then
		return
	end

	-- root frame
	do
		local function OnClose(container)
			AceGUI:Release(container)
			ClearOptionsTable()
		end

		local function OnKeyDown(self, key)
			if key == "ESCAPE" then
				self:SetPropagateKeyboardInput(false)
				self:Hide()
			else
				self:SetPropagateKeyboardInput(true)
			end
		end

		local widget = AceGUI:Create("Frame")
		options.root = widget

		widget:SetCallback("OnClose", OnClose)
		widget:SetTitle("Clicked Binding Config")
		widget:SetLayout("Flow")

		widget.frame:SetScript("OnKeyDown", OnKeyDown)
	end

	DrawHeader(options.root)
	DrawTreeView(options.root)
end

function Clicked:RegisterBindingConfig()
	self:RegisterMessage(GUI.EVENT_UPDATE, OnGUIUpdateEvent)
	self:RegisterMessage(self.EVENT_BINDINGS_CHANGED, OnBindingsChangedEvent)

	AceConsole:RegisterChatCommand("clicked", function()
		self:OpenBindingConfig()
	end)

	ClearOptionsTable()
end

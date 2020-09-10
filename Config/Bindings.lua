local AceConsole = LibStub("AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

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
local bindingCopyBuffer = nil

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
		refreshHeaderFunc = nil
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
		item.text1 = L["CFG_UI_TREE_LABEL_CAST"]:format(binding.action.spell or "")
		item.icon = select(3, GetSpellInfo(binding.action.spell)) or item.icon
	elseif binding.type == Clicked.TYPE_ITEM then
		item.text1 = L["CFG_UI_TREE_LABEL_USE"]:format(binding.action.item or "")
		item.icon = select(10, GetItemInfo(binding.action.item)) or item.icon
	elseif binding.type == Clicked.TYPE_MACRO then
		item.text1 = L["CFG_UI_TREE_LABEL_RUN_MACRO"]
	elseif binding.type == Clicked.TYPE_UNIT_SELECT then
		item.text1 = L["CFG_UI_TREE_LABEL_TARGET_UNIT"]
	elseif binding.type == Clicked.TYPE_UNIT_MENU then
		item.text1 = L["CFG_UI_TREE_LABEL_UNIT_MENU"]
	end

	item.text2 = binding.keybind

	if Clicked:IsBindingActive(binding) then
		item.text3 = L["CFG_UI_TREE_LOAD_STATE_LOADED"]
	else
		item.text3 = L["CFG_UI_TREE_LOAD_STATE_UNLOADED"]
	end

	return item
end

local function ConstructTreeView()
	local items = {}

	for index, binding in Clicked:IterateConfiguredBindings() do
		local item = ConstructTreeViewItem(index, binding)
		table.insert(items, item)
	end

	table.sort(items, TreeSortFunc)

	options.tree.items = items
end

local function CanBindingTargetingModeChange(binding)
	if Clicked:IsRestrictedKeybind(binding.keybind) then
		return false
	end

	return binding.type == Clicked.TYPE_SPELL or binding.type == Clicked.TYPE_ITEM
end

local function DeepCopy(original)
	if original == nil then
		return nil
	end

	local result = {}

	for k, v in pairs(original) do
		if type(v) == "table" then
			v = DeepCopy(v)
		end

		result[k] = v
	end

	return result
end

-- Spell book integration

local function EnableSpellbookHandlers()
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

				if not InCombatLockdown() and options.item ~= nil and name ~= nil then
					local binding = options.item.binding

					if binding.type == Clicked.TYPE_SPELL then
						binding.action.spell = name
						HideUIPanel(SpellBookFrame)
						Clicked:ReloadActiveBindings()
					end
				end
			end)
			button:SetScript("OnEnter", function(self)
				SpellButton_OnEnter(self.parent)
			end)
			button:SetScript("OnLeave", function(self)
				SpellButton_OnLeave(self.parent)
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
		local widget = GUI:EditBox(L["CFG_UI_ACTION_TARGET_SPELL"], "OnEnterPressed", action, "spell")
		widget:SetRelativeWidth(0.6)

		container:AddChild(widget)
	end

	-- pick from spellbook button
	do
		local function OnClick()
			if not InCombatLockdown() then
				SpellBookFrame:HookScript("OnHide", function()
					DisableSpellbookHandlers()
				end)

				SpellBookFrame.bookType = BOOKTYPE_SPELL

				if not SpellBookFrame:IsVisible() then
					ShowUIPanel(SpellBookFrame)
				else
					SpellBookFrame_Update();
				end

				EnableSpellbookHandlers()
			end
		end

		local function OnEnter(widget)
			local tooltip = AceGUI.tooltip

			tooltip:SetOwner(widget.frame, "ANCHOR_NONE")
			tooltip:ClearAllPoints()
			tooltip:SetPoint("LEFT", widget.frame, "RIGHT")
			tooltip:SetText(L["CFG_UI_ACTION_TARGET_SPELL_BOOK_HELP"], 1, 0.82, 0, true)
			tooltip:Show()
		end

		local function OnLeave()
			local tooltip = AceGUI.tooltip
			tooltip:Hide()
		end

		local widget = GUI:Button(L["CFG_UI_ACTION_TARGET_SPELL_BOOK"], OnClick)
		widget:SetRelativeWidth(0.4)
		widget:SetCallback("OnEnter", OnEnter)
		widget:SetCallback("OnLeave", OnLeave)

		container:AddChild(widget)
	end

	-- interrupt cast toggle
	do
		local widget = GUI:CheckBox(L["CFG_UI_ACTION_INTERRUPT_CURRENT_CAST"], action, "stopCasting")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end
end

local function DrawItemSelection(container, action)
	-- target item text
	do
		local function OnEnterPressed(frame, event, value)
			local item = select(5, string.find(value, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?"))

			if item ~= nil and item ~= "" then
				value = GetItemInfo(item)
			end

			value = Clicked:Trim(value)
			GUI:Serialize(frame, event, value)
		end

		local widget = GUI:EditBox(L["CFG_UI_ACTION_TARGET_ITEM"], "OnEnterPressed", action, "item")
		widget:SetCallback("OnEnterPressed", OnEnterPressed)
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	-- interrupt cast toggle
	do
		local widget = GUI:CheckBox(L["CFG_UI_ACTION_INTERRUPT_CURRENT_CAST"], action, "stopCasting")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end
end

local function DrawMacroSelection(container, action)
	-- macro text field
	do
		local widget = GUI:MultilineEditBox(L["CFG_UI_ACTION_MACRO_TEXT"], "OnEnterPressed", action, "macro")
		widget:SetFullWidth(true)
		widget:SetFullHeight(true)

		container:AddChild(widget)
	end
end

local function DrawModeSelection(container, binding)
	local items = {
		DYNAMIC_PRIORITY = L["CFG_UI_ACTION_TARGETING_MODE_DYNAMIC"],
		HOVERCAST = L["CFG_UI_ACTION_TARGETING_MODE_HOVERCAST"],
		GLOBAL = L["CFG_UI_ACTION_TARGETING_MODE_GLOBAL"]
	}

	local order = {
		"DYNAMIC_PRIORITY",
		"HOVERCAST",
		"GLOBAL"
	}

	local widget = GUI:Dropdown(L["CFG_UI_ACTION_TARGETING_MODE"], items, order, binding, "targetingMode")
	widget:SetFullWidth(true)

	container:AddChild(widget)
end

local function DrawTargetSelection(container, binding)
	local function DrawTargetUnitDropdown(target, index, count)
		local function OnValueChanged(frame, event, value)
			if not InCombatLockdown()then
				if index == 0 then
					local new = Clicked:GetNewBindingTargetTemplate()
					new.unit = value
					table.insert(binding.targets, new)
				elseif value == "_DELETE" then
					table.remove(binding.targets, index)
				else
					target.unit = value

					local last = nil

					for i, t in ipairs(binding.targets) do
						local unit = t.unit

						if not Clicked:CanBindingTargetHaveFollowUp(unit) then
							last = i
							break
						end
					end

					if last ~= nil then
						for i = 1, #binding.targets - last do
							table.remove(binding.targets, #binding.targets)
						end
					end
				end

				Clicked:ReloadActiveBindings()
			else
				if index ~= 0 then
					frame:SetValue(target.unit)
				else
					frame:SetValue("_NONE")
				end
			end
		end

		local items = {
			PLAYER = L["CFG_UI_ACTION_TARGET_UNIT_PLAYER"],
			TARGET = L["CFG_UI_ACTION_TARGET_UNIT_TARGET"],
			MOUSEOVER = L["CFG_UI_ACTION_TARGET_UNIT_MOUSEOVER"],
			FOCUS = L["CFG_UI_ACTION_TARGET_UNIT_FOCUS"],
			CURSOR = L["CFG_UI_ACTION_TARGET_UNIT_CURSOR"],
			PARTY_1 = L["CFG_UI_ACTION_TARGET_UNIT_PARTY"]:format("1"),
			PARTY_2 = L["CFG_UI_ACTION_TARGET_UNIT_PARTY"]:format("2"),
			PARTY_3 = L["CFG_UI_ACTION_TARGET_UNIT_PARTY"]:format("3"),
			PARTY_4 = L["CFG_UI_ACTION_TARGET_UNIT_PARTY"]:format("4"),
			PARTY_5 = L["CFG_UI_ACTION_TARGET_UNIT_PARTY"]:format("5")
		}

		local order = {
			"PLAYER",
			"TARGET",
			"MOUSEOVER",
			"FOCUS",
			"CURSOR",
			"PARTY_1",
			"PARTY_2",
			"PARTY_3",
			"PARTY_4",
			"PARTY_5"
		}

		if index == 0 then
			items["_NONE"] = L["CFG_UI_ACTION_TARGET_UNIT_NONE"]
			table.insert(order, 1, "_NONE")
		elseif count > 1 then
			items["_DELETE"] = L["CFG_UI_ACTION_TARGET_UNIT_REMOVE"]
			table.insert(order, "_DELETE")
		end

		local widget = GUI:Dropdown(L["CFG_UI_ACTION_TARGET_UNIT"], items, order, target, "unit")
		widget:SetCallback("OnValueChanged", OnValueChanged)

		if index ~= 1 then
			widget:SetLabel(L["CFG_UI_ACTION_TARGET_UNIT_EXTRA"])
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
			ANY = L["CFG_UI_ACTION_TARGET_TYPE_ANY"],
			HELP = L["CFG_UI_ACTION_TARGET_TYPE_FRIEND"],
			HARM = L["CFG_UI_ACTION_TARGET_TYPE_HARM"]
		}

		local order = {
			"ANY",
			"HELP",
			"HARM"
		}

		local widget = GUI:Dropdown(L["CFG_UI_ACTION_TARGET_TYPE"], items, order, target, "type")
		widget:SetRelativeWidth(0.5)

		container:AddChild(widget)
	end

	for i, target in ipairs(binding.targets) do
		DrawTargetUnitDropdown(target, i, #binding.targets)

		if Clicked:CanBindingTargetUnitBeHostile(target.unit) then
			DrawTargetTypeDropdown(target)
		end
	end

	local last = binding.targets[#binding.targets]

	if last == nil or Clicked:CanBindingTargetHaveFollowUp(last.unit) then
		DrawTargetUnitDropdown({ unit = "_NONE" }, 0, #binding.targets)
	end
end

local function DrawBindingActionPage(container, binding)
	-- action help label
	do
		local widget = GUI:Label(container, L["CFG_UI_ACTION_HELP"])
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	-- action dropdown
	do
		local items = {
			SPELL = L["CFG_UI_ACTION_TYPE_SPELL"],
			ITEM = L["CFG_UI_ACTION_TYPE_ITEM"],
			MACRO = L["CFG_UI_ACTION_TYPE_MACRO"],
			UNIT_SELECT = L["CFG_UI_ACTION_TYPE_UNIT_TARGET"],
			UNIT_MENU = L["CFG_UI_ACTION_TYPE_UNIT_MENU"]
		}

		local order = {
			"SPELL",
			"ITEM",
			"MACRO",
			"UNIT_SELECT",
			"UNIT_MENU"
		}

		local widget = GUI:Dropdown(L["CFG_UI_ACTION_TYPE"], items, order, binding, "type")
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

	if CanBindingTargetingModeChange(binding) then
		DrawModeSelection(container, binding)

		if binding.targetingMode == Clicked.TARGETING_MODE_DYNAMIC_PRIORITY then
			DrawTargetSelection(container, binding)
		end
	elseif Clicked:IsRestrictedKeybind(binding.keybind) then
		-- restricted keybind help label
		local widget = GUI:Label(L["CFG_UI_ACTION_RESTRICTED"])
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end
end

-- Binding load options page and components

local function DrawLoadNeverSelection(container, load)
	-- never load toggle
	do
		local widget = GUI:CheckBox(L["CFG_UI_LOAD_NEVER"] , load, "never")
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
		local widget = GUI:TristateCheckBox(L["CFG_UI_LOAD_SPECIALIZATION"], specialization, "selected")
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
		local widget = GUI:CheckBox(L["CFG_UI_LOAD_COMBAT"], combat, "selected")

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
				IN_COMBAT = L["CFG_UI_LOAD_COMBAT_TRUE"],
				NOT_IN_COMBAT = L["CFG_UI_LOAD_COMBAT_FALSE"]
			}

			local order = {
				"IN_COMBAT",
				"NOT_IN_COMBAT"
			}

			local widget = GUI:Dropdown(nil, items, order, combat, "state")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

local function DrawLoadSpellKnown(container, spellKnown)
	-- spell known toggle
	do
		local widget = GUI:CheckBox(L["CFG_UI_LOAD_SPELL_KNOWN"], spellKnown, "selected")

		if not spellKnown.selected then
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

local function DrawLoadInGroup(container, inGroup)
	-- in group toggle
	do
		local widget = GUI:CheckBox(L["CFG_UI_LOAD_IN_GROUP"], inGroup, "selected")

		if not inGroup.selected then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end

		container:AddChild(widget)
	end

	-- in group state
	if inGroup.selected then
		do
			local items = {
				IN_GROUP_PARTY_OR_RAID = L["CFG_UI_LOAD_IN_GROUP_PARTY_OR_RAID"],
				IN_GROUP_PARTY = L["CFG_UI_LOAD_IN_GROUP_PARTY"],
				IN_GROUP_RAID = L["CFG_UI_LOAD_IN_GROUP_RAID"],
				IN_GROUP_SOLO = L["CFG_UI_LOAD_IN_GROUP_SOLO"]
			}

			local order = {
				"IN_GROUP_PARTY_OR_RAID",
				"IN_GROUP_PARTY",
				"IN_GROUP_RAID",
				"IN_GROUP_SOLO"
			}

			local widget = GUI:Dropdown(nil, items, order, inGroup, "state")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

local function DrawLoadPlayerInGroup(container, playerInGroup)
	-- player in group toggle
	do
		local widget = GUI:CheckBox(L["CFG_UI_LOAD_PLAYER_IN_GROUP"], playerInGroup, "selected")

		if not playerInGroup.selected then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end

		container:AddChild(widget)
	end

	if playerInGroup.selected then
		-- player in group
		do
			local widget = GUI:EditBox(nil, "OnEnterPressed", playerInGroup, "player")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

local function DrawLoadInStance(container, stance)
	local function GetStances()
		local result = { L["CFG_UI_LOAD_STANCE_NONE"] }

		local numStances = GetNumShapeshiftForms()

		for i = 1, numStances do
			local _, _, _, spellId = GetShapeshiftFormInfo(i)
			local name = GetSpellInfo(spellId)

			table.insert(result, name)
		end

		return result
	end

	-- stance toggle
	do
		local widget = GUI:TristateCheckBox(L["CFG_UI_LOAD_STANCE"], stance, "selected")
		widget:SetTriState(true)

		if stance.selected == 0 then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end

		container:AddChild(widget)
	end

	if stance.selected == 1 then
		-- stance (single)
		do
			local items = GetStances()
			local order = nil

			local widget = GUI:Dropdown(nil, items, order, stance, "single")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	elseif stance.selected == 2 then
		-- stance (multiple)
		do
			local items = GetStances()
			local order = nil

			local widget = GUI:MultiselectDropdown(nil, items, order, stance, "multiple")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

local function DrawBindingLoadOptionsPage(container, binding)
	local load = binding.load

	DrawLoadNeverSelection(container, load)

	if Clicked.WOW_MAINLINE_RELEASE then
		DrawLoadSpecialization(container, load.specialization)
	end

	DrawLoadCombat(container, load.combat)
	DrawLoadSpellKnown(container, load.spellKnown)
	DrawLoadInGroup(container, load.inGroup)
	DrawLoadPlayerInGroup(container, load.playerInGroup)

	if GetNumShapeshiftForms() > 0 then
		DrawLoadInStance(container, load.stance)
	end
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
			else
				options.item = nil
			end

			if options.refreshHeaderFunc ~= nil then
				options.refreshHeaderFunc()
			end
		end

		local widget = GUI:Button(L["CFG_UI_BINDING_DELETE"], OnClick)
		widget:SetRelativeWidth(0.25)

		container:AddChild(widget)
	end

	-- tabs
	do
		-- luacheck: ignore container
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
				text = L["CFG_UI_ACTION"],
				value = "action"
			},
			{
				text = L["CFG_UI_LOAD"],
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
	local line = AceGUI:Create("SimpleGroup")
	line:SetFullWidth(true)
	line:SetLayout("table")
	line:SetUserData("table", { columns = { 1, 0, 0} })

	container:AddChild(line)

	-- create binding button
	do
		local function OnClick()
			if InCombatLockdown() then
				return
			end

			Clicked:CreateNewBinding()
			options.tree.container:SelectByValue(Clicked:GetNumConfiguredBindings())
		end

		local widget = GUI:Button(L["CFG_UI_BINDING_CREATE"], OnClick)
		widget:SetWidth(210) -- from AceGUIContainer-ClickedTreeGroup

		line:AddChild(widget)
	end

	local copyBindingButton
	local pasteBindingButton

	-- copy binding button
	do
		local function OnClick()
			local original = options.item.binding

			-- create a deep copy of the binding so that any modifications
			-- after the copy was made aren't reflected in the copy behavior
			bindingCopyBuffer = nil
			bindingCopyBuffer = DeepCopy(original)

			if options.refreshHeaderFunc ~= nil then
				options.refreshHeaderFunc()
			end
		end

		local widget = GUI:Button(L["CFG_UI_BINDING_COPY"], OnClick)
		widget:SetWidth(100)
		widget:SetDisabled(options.item == nil or options.item.binding == nil)

		line:AddChild(widget)

		copyBindingButton = widget
	end

	-- paste binding button
	do
		local function OnClick()
			local original = options.item.binding

			-- copy the buffer again to prevent dirtying it
			local clone = DeepCopy(bindingCopyBuffer)
			clone.keybind = original.keybind

			Clicked:SetBindingAt(options.item.value, clone)
		end

		local widget = GUI:Button(L["CFG_UI_BINDING_PASTE"], OnClick)
		widget:SetWidth(100)
		widget:SetDisabled(bindingCopyBuffer == nil)

		line:AddChild(widget)

		pasteBindingButton = widget
	end

	options.refreshHeaderFunc = function()
		copyBindingButton:SetDisabled(options.item == nil or options.item.binding == nil)
		pasteBindingButton:SetDisabled(options.item == nil or options.item.binding == nil or bindingCopyBuffer == nil)
	end
end

local function DrawTreeView(container)
	ConstructTreeView()

	local selected = GetSelectedItem(options.tree.status.selected, options.tree.items)

	-- tree view
	do
		-- luacheck: ignore container
		local function OnGroupSelected(container, event, group)
			container:ReleaseChildren()

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

			if options.refreshHeaderFunc ~= nil then
				options.refreshHeaderFunc()
			end

			DrawBinding(container)
		end

		-- luacheck: ignore container
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
					text = text .. L["CFG_UI_TREE_TOOLTIP_LOAD_STATE_LOADED"]
				else
					text = text .. L["CFG_UI_TREE_TOOLTIP_LOAD_STATE_UNLOADED"]
				end
			end

			tooltip:SetOwner(frame, "ANCHOR_NONE")
			tooltip:ClearAllPoints()
			tooltip:SetPoint("RIGHT", frame, "LEFT")
			tooltip:SetText(text or "", 1, 0.82, 0, true)
			tooltip:Show()
		end

		-- luacheck: ignore container
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

	if options.refreshHeaderFunc ~= nil then
		options.refreshHeaderFunc()
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
			DisableSpellbookHandlers()
			ClearOptionsTable()

			bindingCopyBuffer = nil
		end

		local function OnKeyDown(widget, key)
			if key == "ESCAPE" then
				widget:SetPropagateKeyboardInput(false)
				widget:Hide()
			else
				widget:SetPropagateKeyboardInput(true)
			end
		end

		local widget = AceGUI:Create("Frame")
		options.root = widget

		widget:SetCallback("OnClose", OnClose)
		widget:SetTitle(L["CFG_UI_TITLE"])
		widget:SetLayout("Flow")

		widget.frame:SetScript("OnKeyDown", OnKeyDown)
	end

	DrawHeader(options.root)
	DrawTreeView(options.root)
end

function Clicked:RegisterBindingConfig()
	self:RegisterMessage(GUI.EVENT_UPDATE, OnGUIUpdateEvent)
	self:RegisterMessage(self.EVENT_BINDINGS_CHANGED, OnBindingsChangedEvent)

	AceConsole:RegisterChatCommand("clicked", self.OpenBindingConfig)
	AceConsole:RegisterChatCommand("cc", self.OpenBindingConfig)

	ClearOptionsTable()
end

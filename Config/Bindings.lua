local AceGUI = LibStub("AceGUI-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
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
local module

-- reset on close
local bindingCopyBuffer
local searchTerm

-- Utility functions

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
	local data = Clicked:GetActiveBindingAction(binding)
	local item = {}

	item.value = index
	item.index = index
	item.binding = binding
	item.icon = "Interface\\ICONS\\INV_Misc_QuestionMark"

	-- update display name and icon
	do
		local label = ""
		local icon = ""

		if binding.type == Clicked.BindingTypes.SPELL then
			label = L["CFG_UI_TREE_LABEL_CAST"]
			icon = select(3, GetSpellInfo(data.value))
		elseif binding.type == Clicked.BindingTypes.ITEM then
			label = L["CFG_UI_TREE_LABEL_USE"]
			icon = select(10, GetItemInfo(data.value))
		elseif binding.type == Clicked.BindingTypes.MACRO then
			label = L["CFG_UI_TREE_LABEL_RUN_MACRO"]

			if #data.displayName > 0 then
				label = data.displayName
			end
		elseif binding.type == Clicked.BindingTypes.UNIT_SELECT then
			label = L["CFG_UI_TREE_LABEL_TARGET_UNIT"]
		elseif binding.type == Clicked.BindingTypes.UNIT_MENU then
			label = L["CFG_UI_TREE_LABEL_UNIT_MENU"]
		end

		if data.value ~= nil then
			item.text1 = string.format(label, data.value)
		else
			item.text1 = label
		end

		if icon ~= nil and #tostring(icon) > 0 then
			item.icon = icon
		elseif data.displayIcon ~= nil and #tostring(data.displayIcon) > 0 then
			item.icon = data.displayIcon
		end

		data.displayName = item.text1
		data.displayIcon = item.icon
	end

	item.text2 = #binding.keybind > 0 and binding.keybind or L["CFG_UI_BINDING_UNBOUND"]

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
		local valid = true

		if searchTerm ~= nil and searchTerm ~= "" then
			local data = Clicked:GetActiveBindingAction(binding)
			local strings = {}

			valid = false

			table.insert(strings, data.displayName)
			table.insert(strings, data.value)

			if binding.keybind ~= nil and binding.keybind ~= "" then
				table.insert(strings, binding.keybind)
			end

			for i = 1, #strings do
				if strings[i] ~= nil and strings[i] ~= "" then
					local str = string.lower(strings[i])
					local pattern = string.lower(searchTerm)

					if string.find(str, pattern, 1, true) ~= nil then
						valid = true
						break
					end
				end
			end
		end

		if valid then
			local item = ConstructTreeViewItem(index, binding)
			table.insert(items, item)
		end
	end

	table.sort(items, TreeSortFunc)

	for i = 1, #items do
		items[i].index = i
	end

	options.tree.items = items
end

local function CanBindingTargetUnitChange(binding)
	if Clicked:IsRestrictedKeybind(binding.keybind) then
		return false
	end

	return binding.type == Clicked.BindingTypes.SPELL or binding.type == Clicked.BindingTypes.ITEM
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

local function GetPrimaryBindingTargetUnit(unit, keybind, type)
	if Clicked:IsRestrictedKeybind(keybind) then
		return Clicked.TargetUnits.HOVERCAST
	end

	if type == Clicked.BindingTypes.UNIT_SELECT then
		return Clicked.TargetUnits.HOVERCAST
	end

	if type == Clicked.BindingTypes.UNIT_MENU then
		return Clicked.TargetUnits.HOVERCAST
	end

	if type == Clicked.BindingTypes.MACRO then
		return Clicked.TargetUnits.GLOBAL
	end

	return unit
end

local function ShowConfirmationPopup(message, func, ...)
	local frame = AceConfigDialog.popup

	frame:Show()
	frame.text:SetText(message)

	local height = 61 + frame.text:GetHeight()
	frame:SetHeight(height)

	frame.accept:ClearAllPoints()
	frame.accept:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -6, 16)
	frame.cancel:Show()

	local t = {...}
	local tCount = select("#", ...)

	frame.accept:SetScript("OnClick", function(self)
		func(unpack(t, 1, tCount))
		frame:Hide()
		self:SetScript("OnClick", nil)
		frame.cancel:SetScript("OnClick", nil)
	end)

	frame.cancel:SetScript("OnClick", function(self)
		frame:Hide()
		self:SetScript("OnClick", nil)
		frame.accept:SetScript("OnClick", nil)
	end)
end

-- Spell book integration

local function OverrideSpellBookVisuals(button)
	if not spellbookButtons.enabled then
		return
	end

	local name = button:GetName();

	if name == nil then
		return
	end

	if button.SpellHighlightTexture ~= nil then
		button.SpellHighlightTexture:Hide()
	end

	if _G[name.."AutoCastable"] ~= nil then
		_G[name.."AutoCastable"]:Hide();
	end
end

local function EnableSpellbookHandlers()
	if options.root == nil or not options.root:IsVisible() then
		return
	end

	if spellbookButtons.enabled then
		return
	end

	spellbookButtons.enabled = true

	ShowUIPanel(SpellBookFrame)

	for i = 1, SPELLS_PER_PAGE do
		local button = spellbookButtons[i]
		local parent = button:GetParent()

		if parent:IsEnabled() then
			button:Show()
			OverrideSpellBookVisuals(parent)
		end
	end
end

local function DisableSpellbookHandlers()
	if not spellbookButtons.enabled then
		return
	end

	spellbookButtons.enabled = false

	for i = 1, SPELLS_PER_PAGE do
		local button = spellbookButtons[i]
		local parent = button:GetParent()

		if parent:IsEnabled() then
			SpellButton_UpdateButton(parent)
			button:Hide()
		end
	end

	HideUIPanel(SpellBookFrame)
	GameTooltip:Hide()
end

local function CreateSpellbookHandlers()
	if #spellbookButtons > 0 then
		return
	end

	for i = 1, SPELLS_PER_PAGE do
		local parent = _G["SpellButton" .. i]
		local button = CreateFrame("Button", nil, parent, "ClickedSpellbookButtonTemplate")

		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button:SetID(parent:GetID())

		button:SetScript("OnEnter", function(self, motion)
			if parent:IsEnabled() then
				SpellButton_OnEnter(parent, motion)
			end
		end)

		button:SetScript("OnLeave", function(self)
			if parent:IsEnabled() then
				SpellButton_OnLeave(parent)
			end
		end)

		button:SetScript("OnClick", function(self)
			if parent:IsEnabled() and not parent.isPassive then
				local slot = SpellBook_GetSpellBookSlot(parent)
				local name = GetSpellBookItemName(slot, SpellBookFrame.bookType)

				if not InCombatLockdown() and options.item ~= nil and name ~= nil then
					local binding = options.item.binding
					local data = Clicked:GetActiveBindingAction(binding)

					if binding.type == Clicked.BindingTypes.SPELL then
						data.value = name
						HideUIPanel(SpellBookFrame)
						Clicked:ReloadActiveBindings()
					end
				end
			end
		end)

		-- Respect ElvUI skinning
		if GetAddOnEnableState(UnitName("player"), "ElvUI") == 2 then
			local E = ElvUI[1]

			if E and E.private and E.private.skins and E.private.skins.blizzard and E.private.skins.blizzard.enable and E.private.skins.blizzard.spellbook then
				button:StripTextures()

				if E.private.skins.parchmentRemoverEnable then
					button:SetHighlightTexture("")
				else
					button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.3)
				end
			end
		end

		spellbookButtons[i] = button
	end

	SpellBookFrame:HookScript("OnHide", DisableSpellbookHandlers)

	hooksecurefunc("SpellButton_UpdateButton", OverrideSpellBookVisuals)
end

-- Common draw functions

local function DrawDropdownLoadOption(container, title, items, order, data)
	-- enabled toggle
	do
		local widget = GUI:CheckBox(title, data, "selected")

		if not data.selected then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end

		container:AddChild(widget)
	end

	-- state
	if data.selected then
		do
			local widget = GUI:Dropdown(nil, items, order, nil, data, "value")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

local function DrawEditFieldLoadOption(container, title, data)
	-- spell known toggle
	do
		local widget = GUI:CheckBox(title, data, "selected")

		if not data.selected then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end

		container:AddChild(widget)
	end

	if data.selected then
		-- spell known
		do
			local widget = GUI:EditBox(nil, "OnEnterPressed", data, "value")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

-- luacheck: ignore options
local function DrawTristateLoadOption(container, title, options, data)
	-- enabled toggle
	do
		local widget = GUI:TristateCheckBox(title, data, "selected")
		widget:SetTriState(true)

		if data.selected == 0 then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end

		container:AddChild(widget)
	end

	local items = {}
	local icons = {}

	for i = 1, #options do
		items[i] = options[i].text
		icons[i] = options[i].icon
	end

	local widget
	local itemType = "Dropdown-Item-Toggle"

	if #icons > 0 then
		itemType = "Dropdown-Item-Toggle-Icon"
	end

	if data.selected == 1 then -- single option variant
		widget = GUI:Dropdown(nil, items, nil, itemType, data, "single")
	elseif data.selected == 2 then -- multiple option variant
		-- luacheck: ignore widget
		local function UpdateText(widget)
			local selected = {}
			local text

			for _, item in widget.pullout:IterateItems() do
				if item.type == itemType then
					if item:GetValue() then
						table.insert(selected, item:GetText())
					end
				end
			end

			if #selected == 0 then
				text = "Nothing"
			elseif #selected == 1 then
				text = selected[1]
			elseif #selected == #items then
				text = "Everything"
			else
				text = "Mixed..."
			end

			widget:SetText(text)
		end

		widget = GUI:MultiselectDropdown(nil, items, nil, itemType, data, "multiple")
		widget.ClickedUpdateText = UpdateText
		widget:ClickedUpdateText()

		for _, item in widget.pullout:IterateItems() do
			if item.type == itemType then
				item:SetCallback("OnValueChanged", function()
					 widget:ClickedUpdateText()
				end)
			end
		end
	end

	if widget ~= nil then
		widget:SetRelativeWidth(0.5)

		container:AddChild(widget)

		if #icons > 0 then
			for i, item in widget.pullout:IterateItems() do
				local icon = item.icon

				if icon ~= nil then
					icon:SetTexture(icons[i] or "Interface\\ICONS\\INV_Misc_QuestionMark")
				end
			end
		end
	end
end

-- Binding action page and components

local function DrawSpellSelection(container, action)
	-- target spell
	do
		local group = GUI:InlineGroup(L["CFG_UI_ACTION_TARGET_SPELL"])
		container:AddChild(group)

		-- edit box
		do
			local function OnEnterPressed(frame, event, value)
				value = GUI:TrimString(value)

				if value ~= action.value then
					action.displayIcon = "" -- invalidate the cached icon
				end

				GUI:Serialize(frame, event, value)
			end

			local widget = GUI:EditBox(nil, "OnEnterPressed", action, "value")
			widget:SetCallback("OnEnterPressed", OnEnterPressed)
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		-- pick from spellbook button
		do
			local function OnClick()
				if not InCombatLockdown() then
					CreateSpellbookHandlers()
					EnableSpellbookHandlers()
				end
			end

			local function OnEnter(widget)
				local tooltip = AceGUI.tooltip

				tooltip:SetOwner(widget.frame, "ANCHOR_NONE")
				tooltip:ClearAllPoints()
				tooltip:SetPoint("LEFT", widget.frame, "RIGHT")
				tooltip:SetText(L["CFG_UI_ACTION_TARGET_SPELL_BOOK_HELP"], 1, 0.82, 0, 1, true)
				tooltip:Show()
			end

			local function OnLeave()
				local tooltip = AceGUI.tooltip
				tooltip:Hide()
			end

			local widget = GUI:Button(L["CFG_UI_ACTION_TARGET_SPELL_BOOK"], OnClick)
			widget:SetFullWidth(true)
			widget:SetCallback("OnEnter", OnEnter)
			widget:SetCallback("OnLeave", OnLeave)

			group:AddChild(widget)
		end
	end

	-- additional options
	do
		local group = GUI:InlineGroup(L["CFG_UI_ACTION_OPTIONS"])
		container:AddChild(group)

		-- interrupt cast toggle
		do
			local widget = GUI:CheckBox(L["CFG_UI_ACTION_OPTIONS_INTERRUPT_CURRENT_CAST"], action, "interruptCurrentCast")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end
	end
end

local function DrawItemSelection(container, action)
	-- target item
	do
		local group = GUI:InlineGroup(L["CFG_UI_ACTION_TARGET_ITEM"])
		container:AddChild(group)

		-- target item
		do
			local function OnEnterPressed(frame, event, value)
				local item = select(5, string.find(value, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?"))

				if item ~= nil and item ~= "" then
					value = GetItemInfo(item)
				end

				value = GUI:TrimString(value)

				if value ~= action.value then
					action.displayIcon = "" -- invalidate the cached icon
				end

				GUI:Serialize(frame, event, value)
			end

			local widget = GUI:EditBox(nil, "OnEnterPressed", action, "value")
			widget:SetCallback("OnEnterPressed", OnEnterPressed)
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		-- help text
		do
			local widget = GUI:Label("\n" .. L["CFG_UI_ACTION_TARGET_ITEM_HELP"])
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end
	end

	-- additional options
	do
		local group = GUI:InlineGroup(L["CFG_UI_ACTION_OPTIONS"])
		container:AddChild(group)

		-- interrupt cast toggle
		do
			local widget = GUI:CheckBox(L["CFG_UI_ACTION_OPTIONS_INTERRUPT_CURRENT_CAST"], action, "stopCasting")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end
	end
end

local function DrawMacroSelection(container, keybind, action)
	-- macro name and icon
	do
		local group = GUI:InlineGroup(L["CFG_UI_ACTION_MACRO_NAME_ICON"])
		container:AddChild(group)

		-- name text field
		do
			local widget = GUI:EditBox(nil, "OnEnterPressed", action, "displayName")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		-- icon field
		do
			local widget = GUI:EditBox(nil, "OnEnterPressed", action, "displayIcon")
			--widget:SetRelativeWidth(0.7)
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		-- icon button
		-- do
		-- 	local widget = GUI:Button(L["CFG_UI_ACTION_MACRO_ICON_SELECT"], function() end)
		-- 	widget:SetRelativeWidth(0.3)
		-- 	widget:SetDisabled(true)

		-- 	group:AddChild(widget)
		-- end
	end

	-- macro text
	do
		local group = GUI:InlineGroup(L["CFG_UI_ACTION_MACRO_TEXT"])
		container:AddChild(group)

		-- help text
		if Clicked:IsRestrictedKeybind(keybind) then
			local widget = GUI:Label(L["CFG_UI_ACTION_MACRO_HOVERCAST_HELP"] .. "\n")
			widget:SetFullWidth(true)
			group:AddChild(widget)
		end

		-- macro text field
		do
			local widget = GUI:MultilineEditBox(nil, "OnEnterPressed", action, "value")
			widget:SetFullWidth(true)
			widget:SetNumLines(8)

			group:AddChild(widget)
		end
	end

	-- additional options
	do
		local group = GUI:InlineGroup(L["CFG_UI_ACTION_OPTIONS"])
		container:AddChild(group)

		-- macro mode toggle
		do
			local items = {
				FIRST = L["CFG_UI_ACTION_OPTIONS_MACRO_MODE_FIRST"],
				LAST = L["CFG_UI_ACTION_OPTIONS_MACRO_MODE_LAST"],
				APPEND = L["CFG_UI_ACTION_OPTIONS_MACRO_MODE_APPEND"]
			}

			local order = {
				"FIRST",
				"LAST",
				"APPEND"
			}

			local widget = GUI:Dropdown(nil, items, order, nil, action, "macroMode")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		if action.macroMode == Clicked.MacroMode.APPEND then
			local widget = GUI:Label("\n" .. L["CFG_UI_ACTION_OPTIONS_MACRO_MODE_APPEND_HELP"])
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end
	end
end

local function DrawBindingActionPage(container, binding)
	-- action dropdown
	do
		local function OnValueChanged(frame, event, value)
			binding.primaryTarget.unit = GetPrimaryBindingTargetUnit(binding.primaryTarget.unit, binding.keybind, value)
			GUI:Serialize(frame, event, value)
		end

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

		local group = GUI:InlineGroup(L["CFG_UI_ACTION_TYPE"])
		container:AddChild(group)

		do
			local widget = GUI:Dropdown(nil, items, order, nil, binding, "type")
			widget:SetCallback("OnValueChanged", OnValueChanged)
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		if binding.type == Clicked.BindingTypes.MACRO then
			local widget = GUI:Label("\n" .. L["CFG_UI_ACTION_TYPE_MACRO_HELP"])
			widget:SetFullWidth(true)
			group:AddChild(widget)
		end
	end

	local data = Clicked:GetActiveBindingAction(binding)

	if binding.type == Clicked.BindingTypes.SPELL then
		DrawSpellSelection(container, data)
	elseif binding.type == Clicked.BindingTypes.ITEM then
		DrawItemSelection(container, data)
	elseif binding.type == Clicked.BindingTypes.MACRO then
		DrawMacroSelection(container, binding.keybind, data)
	end
end

-- Binding target page and components

local function GetCommonTargetUnits()
	local items = {
		PLAYER = L["CFG_UI_ACTION_TARGET_UNIT_PLAYER"],
		GLOBAL = L["CFG_UI_ACTION_TARGET_UNIT_GLOBAL"],
		TARGET = L["CFG_UI_ACTION_TARGET_UNIT_TARGET"],
		TARGET_OF_TARGET = L["CFG_UI_ACTION_TARGET_UNIT_TARGETTARGET"],
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
		"GLOBAL",
		"TARGET",
		"TARGET_OF_TARGET",
		"MOUSEOVER",
		"FOCUS",
		"CURSOR",
		"PARTY_1",
		"PARTY_2",
		"PARTY_3",
		"PARTY_4",
		"PARTY_5"
	}

	return items, order
end

local function GetPrimaryTargetUnits()
	local items, order = GetCommonTargetUnits()
	items["HOVERCAST"] = L["CFG_UI_ACTION_TARGET_UNIT_HOVERCAST"]
	table.insert(order, 5, "HOVERCAST")

	return items, order
end

local function DrawTargetSelectionPrimaryUnit(container, binding, target)
	if Clicked:IsRestrictedKeybind(binding.keybind) then
		local widget = GUI:Label(L["CFG_UI_ACTION_RESTRICTED"] .. "\n")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	local items, order = GetPrimaryTargetUnits()
	local widget = GUI:Dropdown(nil, items, order, nil, target, "unit")
	widget:SetFullWidth(true)
	widget:SetDisabled(not CanBindingTargetUnitChange(binding))

	container:AddChild(widget)
end

local function DrawTargetSelectionUnit(container, binding, index, target)
	local function OnValueChanged(frame, event, value)
		if not InCombatLockdown() then
			if value == "_DELETE_" then
				table.remove(binding.secondaryTargets, index)
			else
				target.unit = value

				local last = nil

				for i, t in ipairs(binding.secondaryTargets) do
					if not Clicked:CanUnitHaveFollowUp(t.unit) then
						last = i
						break
					end
				end

				if last ~= nil then
					for i = 1, #binding.secondaryTargets - last do
						table.remove(binding.secondaryTargets, #binding.secondaryTargets)
					end
				end
			end

			Clicked:ReloadActiveBindings()
		else
			frame:SetValue(target.unit)
		end
	end

	local items, order = GetCommonTargetUnits()
	items["_DELETE_"] = L["CFG_UI_ACTION_TARGET_UNIT_REMOVE"]
	table.insert(order, "_DELETE_")

	local widget = GUI:Dropdown(nil, items, order, nil, target, "unit")
	widget:SetCallback("OnValueChanged", OnValueChanged)
	widget:SetFullWidth(true)

	container:AddChild(widget)
end

local function DrawTargetSelectionNewUnit(container, binding)
	local function OnValueChanged(frame, event, value)
		if not InCombatLockdown() then
			if value == "_NONE_" then
				return
			end

			local new = Clicked:GetNewBindingTargetTemplate()
			new.unit = value

			table.insert(binding.secondaryTargets, new)

			Clicked:ReloadActiveBindings()
		else
			frame:SetValue("_NONE_")
		end
	end

	local items, order = GetCommonTargetUnits()
	items["_NONE_"] = L["CFG_UI_ACTION_TARGET_UNIT_NONE"]
	table.insert(order, 1, "_NONE_")

	local widget = GUI:Dropdown(nil, items, order, nil, { unit = "_NONE_" }, "unit")
	widget:SetCallback("OnValueChanged", OnValueChanged)
	widget:SetFullWidth(true)

	container:AddChild(widget)
end

local function DrawTargetSelectionHostility(container, target)
	local items = {
		ANY = L["CFG_UI_ACTION_TARGET_HOSTILITY_ANY"],
		HELP = L["CFG_UI_ACTION_TARGET_HOSTILITY_FRIEND"],
		HARM = L["CFG_UI_ACTION_TARGET_HOSTILITY_HARM"]
	}

	local order = {
		"ANY",
		"HELP",
		"HARM"
	}

	local widget = GUI:Dropdown(nil, items, order, nil, target, "hostility")
	widget:SetFullWidth(true)

	container:AddChild(widget)
end

local function DrawTargetSelectionVitals(container, target)
	local items = {
		ANY = L["CFG_UI_ACTION_TARGET_VITALS_ANY"],
		ALIVE = L["CFG_UI_ACTION_TARGET_VITALS_ALIVE"],
		DEAD = L["CFG_UI_ACTION_TARGET_VITALS_DEAD"]
	}

	local order = {
		"ANY",
		"ALIVE",
		"DEAD"
	}

	local widget = GUI:Dropdown(nil, items, order, nil, target, "vitals")
	widget:SetFullWidth(true)

	container:AddChild(widget)
end

local function DrawBindingTargetPage(container, binding)
	-- primary target
	do
		local function ShouldShowHostility()
			if binding.type == Clicked.BindingTypes.UNIT_SELECT then
				return false
			end

			if binding.type == Clicked.BindingTypes.UNIT_MENU then
				return false
			end

			if binding.type == Clicked.BindingTypes.MACRO then
				return false
			end

			if Clicked:CanUnitBeHostile(binding.primaryTarget.unit) then
				return true
			end

			if binding.primaryTarget.unit == Clicked.TargetUnits.HOVERCAST then
				return true
			end

			return false
		end

		local group = GUI:InlineGroup(L["CFG_UI_ACTION_TARGET_UNIT"])
		container:AddChild(group)

		DrawTargetSelectionPrimaryUnit(group, binding, binding.primaryTarget)

		if ShouldShowHostility() then
			DrawTargetSelectionHostility(group, binding.primaryTarget)
		end

		if Clicked:CanUnitBeDead(binding.primaryTarget.unit) then
			DrawTargetSelectionVitals(group, binding.primaryTarget)
		end
	end

	if Clicked:CanUnitHaveFollowUp(binding.primaryTarget.unit) then
		-- secondary targets
		for index, target in ipairs(binding.secondaryTargets) do
			local group = GUI:InlineGroup(L["CFG_UI_ACTION_TARGET_UNIT_EXTRA"])
			container:AddChild(group)

			DrawTargetSelectionUnit(group, binding, index, target)

			if Clicked:CanUnitBeHostile(target.unit) then
				DrawTargetSelectionHostility(group, target)
			end

			if Clicked:CanUnitBeDead(target.unit) then
				DrawTargetSelectionVitals(group, target)
			end

			if not Clicked:CanUnitHaveFollowUp(target.unit) then
				break
			end
		end

		-- new target
		do
			local last

			if #binding.secondaryTargets > 0 then
				last = binding.secondaryTargets[#binding.secondaryTargets]
			else
				last = binding.primaryTarget
			end

			if Clicked:CanUnitHaveFollowUp(last.unit) then
				local group = GUI:InlineGroup(L["CFG_UI_ACTION_TARGET_UNIT_EXTRA"])
				container:AddChild(group)

				DrawTargetSelectionNewUnit(group, binding)
			end
		end
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
	-- luacheck: ignore options
	local options = {}

	for i = 1, GetNumSpecializations() do
		local _, name, _, icon = GetSpecializationInfo(i)

		table.insert(options, {
			text = name,
			icon = icon
		})
	end

	DrawTristateLoadOption(container, L["CFG_UI_LOAD_SPECIALIZATION"], options, specialization)
end

local function DrawLoadTalent(container, talent)
	-- luacheck: ignore options
	local options = {}

	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			local _, name, texture = GetTalentInfo(tier, column, 1)

			table.insert(options, {
				text = name,
				icon = texture
			})
		end
	end

	DrawTristateLoadOption(container, L["CFG_UI_LOAD_TALENT"], options, talent)
end

local function DrawLoadPvPTalent(container, talent)
	-- luacheck: ignore options
	local options = {}

	local function CreateFromPvpTalentId(id)
		local name, icon = select(2, GetPvpTalentInfoByID(id))

		table.insert(options, {
			text = name,
			icon = icon
		})
	end

	local function CreateFromSlotInfo(slot, inverse)
		local slotInfo = C_SpecializationInfo.GetPvpTalentSlotInfo(slot)

		if slotInfo then
			local talents = slotInfo.availableTalentIDs

			for _, id in ipairs(talents) do
				CreateFromPvpTalentId(id)
			end
		end
	end

	CreateFromSlotInfo(1, true)
	CreateFromSlotInfo(2, false)

	if next(options) then
		DrawTristateLoadOption(container, L["CFG_UI_LOAD_PVP_TALENT"], options, talent)
	end
end

local function DrawLoadWarMode(container, warMode)
	local items = {
		IN_WAR_MODE = L["CFG_UI_LOAD_WAR_MODE_TRUE"],
		NOT_IN_WAR_MODE = L["CFG_UI_LOAD_WAR_MODE_FALSE"]
	}

	local order = {
		"IN_WAR_MODE",
		"NOT_IN_WAR_MODE"
	}

	DrawDropdownLoadOption(container, L["CFG_UI_LOAD_WAR_MODE"], items, order, warMode)
end

local function DrawLoadCombat(container, combat)
	local items = {
		IN_COMBAT = L["CFG_UI_LOAD_COMBAT_TRUE"],
		NOT_IN_COMBAT = L["CFG_UI_LOAD_COMBAT_FALSE"]
	}

	local order = {
		"IN_COMBAT",
		"NOT_IN_COMBAT"
	}

	DrawDropdownLoadOption(container, L["CFG_UI_LOAD_COMBAT"], items, order, combat)
end

local function DrawLoadSpellKnown(container, spellKnown)
	DrawEditFieldLoadOption(container, L["CFG_UI_LOAD_SPELL_KNOWN"], spellKnown)
end

local function DrawLoadInGroup(container, inGroup)
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

	DrawDropdownLoadOption(container, L["CFG_UI_LOAD_IN_GROUP"], items, order, inGroup)
end

local function DrawLoadPlayerInGroup(container, playerInGroup)
	DrawEditFieldLoadOption(container, L["CFG_UI_LOAD_PLAYER_IN_GROUP"], playerInGroup)
end

local function DrawLoadInStance(container, stance)
	-- luacheck: ignore options
	local options = { }

	table.insert(options, {
		text = L["CFG_UI_LOAD_STANCE_NONE"],
		icon = nil
	})

	for i = 1, GetNumShapeshiftForms() do
		local _, _, _, spellId = GetShapeshiftFormInfo(i)
		local name, _, icon = GetSpellInfo(spellId)

		table.insert(options, {
			text = name,
			icon = icon
		})
	end

	DrawTristateLoadOption(container, L["CFG_UI_LOAD_STANCE"], options, stance)
end

local function DrawBindingLoadOptionsPage(container, binding)
	local load = binding.load

	DrawLoadNeverSelection(container, load)

	if not Clicked:IsClassic() then
		DrawLoadSpecialization(container, load.specialization)
		DrawLoadTalent(container, load.talent)
		DrawLoadPvPTalent(container, load.pvpTalent)
		DrawLoadWarMode(container, load.warMode)
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
		local function OnKeyChanged(frame, event, value)
			binding.primaryTarget.unit = GetPrimaryBindingTargetUnit(binding.primaryTarget.unit, value, binding.type)
			GUI:Serialize(frame, event, value)
		end

		local widget = GUI:KeybindingButton(nil, binding, "keybind")
		widget:SetCallback("OnKeyChanged", OnKeyChanged)
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	-- tabs
	do
		-- luacheck: ignore container
		local function OnGroupSelected(container, event, group)
			local scrollFrame = AceGUI:Create("ScrollFrame")
			local scrollFrameValue = options.tabScroll.scrollvalue or 0
			scrollFrame:SetLayout("Flow")
			scrollFrame:SetStatusTable(options.tabScroll)

			container:AddChild(scrollFrame)

			if group == "action" then
				DrawBindingActionPage(scrollFrame, binding)
			elseif group == "target" then
				DrawBindingTargetPage(scrollFrame, binding)
			elseif group == "load" then
				DrawBindingLoadOptionsPage(scrollFrame, binding)
			end

			scrollFrame:DoLayout()
			scrollFrame:SetScroll(scrollFrameValue)
		end

		local items = {
			{
				text = L["CFG_UI_ACTION"],
				value = "action"
			},
			{
				text = L["CFG_UI_TARGET"],
				value = "target"
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
	local deleteBindingButton
	local duplicateBindingButton
	local copyBindingButton
	local pasteBindingButton

	local line = AceGUI:Create("ClickedSimpleGroup")
	line:SetFullWidth(true)
	line:SetLayout("table")
	line:SetUserData("table", { columns = { 0, 0, 1, 0, 0, 0} })

	container:AddChild(line)

	-- search box
	do
		local isPlaceholderActive = true

		local function OnFocusGained(frame)
			if searchTerm == nil or searchTerm == "" then
				frame:SetText("")
			end

			isPlaceholderActive = false
		end

		local function OnFocusLost(frame)
			if searchTerm == nil or searchTerm == "" then
				frame:SetText(L["CFG_UI_BINDING_SEARCH_PLACEHOLDER"])
				isPlaceholderActive = true
			end
		end

		local function OnTextChanged(frame, event, value)
			if isPlaceholderActive then
				return
			end

			searchTerm = GUI:TrimString(value)
			module:Redraw()
		end

		local function OnEnterPressed(frame, event, value)
			if isPlaceholderActive then
				return
			end

			searchTerm = GUI:TrimString(value)
			frame:SetText(searchTerm)
			module:Redraw()
		end

		local function OnEscapePressed(frame)
			if isPlaceholderActive then
				return
			end

			searchTerm = ""
			frame:SetText(L["CFG_UI_BINDING_SEARCH_PLACEHOLDER"])
			module:Redraw()
		end

		local widget = AceGUI:Create("ClickedEditBox")
		widget:SetCallback("OnFocusGained", OnFocusGained)
		widget:SetCallback("OnFocusLost", OnFocusLost)
		widget:SetCallback("OnTextChanged", OnTextChanged)
		widget:SetCallback("OnEnterPressed", OnEnterPressed)
		widget:SetCallback("OnEscapePressed", OnEscapePressed)
		widget:DisableButton(true)
		widget:SetText(L["CFG_UI_BINDING_SEARCH_PLACEHOLDER"])
		widget:SetWidth(280)

		line:AddChild(widget)
	end

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
		widget:SetAutoWidth(true)

		line:AddChild(widget)
	end

	-- delete binding button
	do
		local function OnConfirm(item)
			if InCombatLockdown() then
				return
			end

			local binding = item.binding
			local index = item.index
			local isCurrent = options.item == item

			Clicked:DeleteBinding(binding)

			if options.tree.items ~= nil then
				if isCurrent then
					local items = options.tree.items
					local selected = items[index]

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
				end
			else
				options.item = nil
			end

			options.refreshHeaderFunc()
		end

		local function OnClick()
			local item = options.item

			if IsShiftKeyDown() then
				OnConfirm(item)
			else
				local msg = L["CFG_UI_BINDING_DELETE_CONFIRM_LINE1"] .. "\n\n"
				msg = msg .. L["CFG_UI_BINDING_DELETE_CONFIRM_LINE2"]:format(item.text2, item.text1)

				ShowConfirmationPopup(msg, OnConfirm, item)
			end
		end

		local widget = GUI:Button(L["CFG_UI_BINDING_DELETE"], OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)

		deleteBindingButton = widget
	end

	-- duplicate binding button
	do
		local function OnClick()
			local clone = DeepCopy(options.item.binding)
			clone.keybind = ""

			local index = Clicked:GetNumConfiguredBindings() + 1
			Clicked:SetBindingAt(index, clone)

			options.tree.container:SelectByValue(index)
			options.refreshHeaderFunc()
		end

		local widget = GUI:Button(L["CFG_UI_BINDING_DUPLICATE"], OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)

		duplicateBindingButton = widget
	end

	-- copy binding button
	do
		local function OnClick()
			-- create a deep copy of the binding so that any modifications
			-- after the copy was made aren't reflected in the copy behavior
			bindingCopyBuffer = nil
			bindingCopyBuffer = DeepCopy(options.item.binding)

			options.refreshHeaderFunc()
		end

		local widget = GUI:Button(L["CFG_UI_BINDING_COPY"], OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)

		copyBindingButton = widget
	end

	-- paste binding button
	do
		local function OnClick()
			-- copy the buffer again to prevent dirtying it
			local clone = DeepCopy(bindingCopyBuffer)
			clone.keybind = options.item.binding.keybind

			Clicked:SetBindingAt(options.item.value, clone)
		end

		local widget = GUI:Button(L["CFG_UI_BINDING_PASTE"], OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)

		pasteBindingButton = widget
	end

	options.refreshHeaderFunc = function()
		local hasItemSelected = options.item ~= nil and options.item.binding ~= nil

		deleteBindingButton:SetDisabled(not hasItemSelected)
		duplicateBindingButton:SetDisabled(not hasItemSelected)
		copyBindingButton:SetDisabled(not hasItemSelected)
		pasteBindingButton:SetDisabled(not hasItemSelected or bindingCopyBuffer == nil)
	end
end

local function DrawTreeView(container)
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
				local data = Clicked:GetActiveBindingAction(binding)

				text = data.displayName

				if binding.type == Clicked.BindingTypes.MACRO then
					if #data.displayName > 0 then
						text = data.displayName .. "\n\n"
						text = text .. L["CFG_UI_TREE_TOOLTIP_MACRO"] .. "\n|cFFFFFFFF"
					else
						text = "";
					end

					text = text .. data.value .. "|r"
				end

				text = text .. "\n\n"

				local function GetTargetLine(target)
					local units = GetPrimaryTargetUnits()

					local hostility = {
						ANY = "",
						HELP = L["CFG_UI_ACTION_TARGET_HOSTILITY_FRIEND"],
						HARM = L["CFG_UI_ACTION_TARGET_HOSTILITY_HARM"]
					}

					local result = ""

					if Clicked:CanUnitBeHostile(target.unit) and target.hostility ~= Clicked.TargetHostility.ANY then
						result = hostility[target.hostility] .. " "
					end

					result = result .. units[target.unit]
					return result
				end

				text = text .. L["CFG_UI_TREE_TOOLTIP_TARGETS"] .. "\n"
				text = text .. "|cFFFFFFFF1. " .. GetTargetLine(binding.primaryTarget)

				for i, target in ipairs(binding.secondaryTargets) do
					text = text .. "\n" .. (i + 1) .. ". " .. GetTargetLine(target)
				end

				text = text .. "|r\n\n"

				if Clicked:IsBindingActive(binding) then
					text = text .. L["CFG_UI_TREE_TOOLTIP_LOAD_STATE_LOADED"]
				else
					text = text .. L["CFG_UI_TREE_TOOLTIP_LOAD_STATE_UNLOADED"]
				end
			end

			tooltip:SetOwner(frame, "ANCHOR_NONE")
			tooltip:ClearAllPoints()
			tooltip:SetPoint("RIGHT", frame, "LEFT")
			tooltip:SetText(text or "", 1, 0.82, 0, 1, true)
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
		widget:EnableButtonTooltips(false)
		widget:SetStatusTable(options.tree.status)
		widget:SetCallback("OnGroupSelected", OnGroupSelected)
		widget:SetCallback("OnButtonEnter", OnButtonEnter)
		widget:SetCallback("OnButtonLeave", OnButtonLeave)

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

local function OnUnitAura(event, unit)
	if options.root == nil or not options.root:IsVisible() then
		return
	end

	if unit == "player" then
		ConstructTreeView()
		options.tree.container:SetTree(options.tree.items)
	end
end

local function RedrawBindingConfig()
	if options.root == nil or not options.root:IsVisible() then
		return
	end

	ConstructTreeView()
	options.tree.container:SetTree(options.tree.items)
	options.root:SetStatusText(L["CFG_UI_STATUS_TEXT"]:format(Clicked.VERSION, Clicked.db:GetCurrentProfile()))

	local selected = GetSelectedItem(options.tree.status.selected, options.tree.items)

	if selected ~= nil then
		options.tree.container:SelectByValue(selected)
	else
		options.tree.container:ReleaseChildren()
		options.item = nil
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

			searchTerm = ""
			bindingCopyBuffer = nil
		end

		local widget = AceGUI:Create("Frame")
		widget:SetCallback("OnClose", OnClose)
		widget:SetTitle(L["CFG_UI_TITLE"])
		widget:SetLayout("Flow")
		widget:SetWidth(800)
		widget:SetHeight(600)

		options = {
			root = widget,
			item = nil,
			tab = {},
			tabScroll = {},
			tree = {
				status = {},
				items = {},
				container = nil
			},
			refreshHeaderFunc = nil
		}
	end

	DrawHeader(options.root)
	DrawTreeView(options.root)

	RedrawBindingConfig()
end

module = {
	--["Initialize"] = nil,

	["Register"] = function(self)
		Clicked:RegisterMessage(GUI.EVENT_UPDATE, OnGUIUpdateEvent)
		Clicked:RegisterMessage(Clicked.EVENT_BINDINGS_CHANGED, RedrawBindingConfig)
		Clicked:RegisterEvent("UNIT_AURA", OnUnitAura)
	end,

	["Unregister"] = function(self)
		Clicked:UnregisterMessage(GUI.EVENT_UPDATE)
		Clicked:UnregisterMessage(Clicked.EVENT_BINDINGS_CHANGED)
		Clicked:UnregisterEvent("UNIT_AURA")
	end,

	["Redraw"] = function(self)
		RedrawBindingConfig()
	end,

	["OnChatCommandReceived"] = function(self, args)
		if #args == 0 then
			Clicked:OpenBindingConfig()
		end
	end
}

Clicked:RegisterModule("BindingConfig", module)

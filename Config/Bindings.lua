local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

local GUI = Clicked.GUI
local Module = {}

local ITEM_TEMPLATE_SIMPLE_BINDING = "SIMPLE_BINDING"
local ITEM_TEMPLATE_CLICKCAST_BINDING = "CLICKCAST_BINDING"
local ITEM_TEMPLATE_HEALER_BINDING = "HEALER_BINDING"
local ITEM_TEMPLATE_GROUP = "GROUP"

local spellbookButtons = {}
local spellFlyOutButtons = {}

-- reset on close
local didOpenSpellbook

-- Utility functions

local function CanBindingTargetUnitChange(binding)
	if Clicked:IsRestrictedKeybind(binding.keybind) then
		return false
	end

	return binding.type == Clicked.BindingTypes.SPELL or binding.type == Clicked.BindingTypes.ITEM or binding.type == Clicked.BindingTypes.MACRO
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
		return Clicked.TargetUnits.DEFAULT
	end

	return unit
end

-- Spell book integration

local function OnSpellBookButtonClick(name)
	if Module:GetCurrentBinding() == nil or name == nil then
		return
	end

	if InCombatLockdown() then
		print(L["MSG_BINDING_UI_READ_ONLY_MODE"])
		return
	end

	local binding = Module:GetCurrentBinding()
	local data = Clicked:GetActiveBindingAction(binding)

	if binding.type == Clicked.BindingTypes.SPELL then
		data.value = name
		HideUIPanel(SpellBookFrame)
		Clicked:ReloadActiveBindings()
	end
end

local function HijackSpellBookButtons(base)
	if didOpenSpellbook and not SpellBookFrame:IsShown() then
		GameTooltip:Hide()
		didOpenSpellbook = false
	end

	for i = 1, SPELLS_PER_PAGE do
		local parent = _G["SpellButton" .. i]
		local button = spellbookButtons[i]
		local shouldUpdate = base == nil or base == parent

		if button == nil then
			button = CreateFrame("Button", nil, parent, "ClickedSpellbookButtonTemplate")

			button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			button:SetID(parent:GetID())

			button:SetScript("OnEnter", function(self, motion)
				SpellButton_OnEnter(parent, motion)
			end)

			button:SetScript("OnLeave", function(self)
				SpellButton_OnLeave(parent)
			end)

			button:SetScript("OnClick", function(self, btn)
				local slot = SpellBook_GetSpellBookSlot(parent);
				local name = GetSpellBookItemName(slot, SpellBookFrame.bookType)
				OnSpellBookButtonClick(name)
			end)

			-- Respect ElvUI skinning
			if GetAddOnEnableState(UnitName("player"), "ElvUI") == 2 then
				local E = unpack(ElvUI)

				if E and E.private.skins and E.private.skins.blizzard and E.private.skins.blizzard.enable and E.private.skins.blizzard.spellbook then
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

		if shouldUpdate then
			local canShow = true

			if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
				canShow = false
			else
				local slot, slotType = SpellBook_GetSpellBookSlot(parent);
				canShow = canShow and slot ~= nil and slot <= MAX_SPELLS
				canShow = canShow and slotType ~= nil and slotType ~= "FLYOUT"
				canShow = canShow and didOpenSpellbook
				canShow = canShow and Module.root ~= nil and Module.root:IsVisible()
				canShow = canShow and SpellBookFrame:IsShown()
				canShow = canShow and parent:IsEnabled()
				canShow = canShow and not parent.isPassive
			end

			if canShow then
				button:Show()

				local name = parent:GetName();

				if name ~= nil then
					if parent.SpellHighlightTexture ~= nil then
						parent.SpellHighlightTexture:Hide()
					end

					if _G[name.."AutoCastable"] ~= nil then
						_G[name.."AutoCastable"]:Hide();
					end
				end
			else
				button:Hide()
			end
		end
	end
end

local function HijackSpellBookFlyoutButtons()
	if Module.root == nil or not Module.root:IsVisible() then
		return
	end

	if SpellBookFrame:IsShown() and SpellFlyout:IsShown() then
		local id = 1
		local flyoutButton = _G["SpellFlyoutButton" .. id]

		while flyoutButton ~= nil do
			local parent = flyoutButton
			local button = spellFlyOutButtons[id]

			if button == nil then
				button = CreateFrame("Button", nil, parent, "ClickedSpellbookButtonTemplate")

				button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
				button:SetID(parent:GetID())

				button:SetScript("OnEnter", function(self, motion)
					SpellFlyoutButton_SetTooltip(parent);
				end)

				button:SetScript("OnLeave", function(self)
					GameTooltip:Hide();
				end)

				button:SetScript("OnClick", function(self)
					local name = GetSpellInfo(parent.spellID);
					OnSpellBookButtonClick(name)
				end)

				spellFlyOutButtons[id] = button
			end

			if parent:IsEnabled() then
				button:Show()
			else
				button:Hide()
			end

			id = id + 1
			flyoutButton = _G["SpellFlyoutButton" .. id]
		end
	else
		for i = 1, #spellFlyOutButtons do
			local button = spellFlyOutButtons[i]
			button:Hide()
		end
	end
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

local function DrawTristateLoadOption(container, title, items, order, data)
	assert(type(data) == "table", "bad argument #5, expected table but got " .. type(data))

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

	local widget
	local itemType = "Clicked-Dropdown-Item-Toggle-Icon"

	if data.selected == 1 then -- single option variant
		widget = GUI:Dropdown(nil, items, order, itemType, data, "single")
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

			widget:SetText(string.format("<text=%s>", text))
		end

		widget = GUI:MultiselectDropdown(nil, items, order, itemType, data, "multiple")
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
	end
end

-- Binding action page and components

local function DrawSpellSelection(container, action)
	-- target spell
	do
		local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_SELECTED_SPELL"])
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
				if InCombatLockdown() then
					print(L["MSG_BINDING_UI_READ_ONLY_MODE"])
					return
				end

				didOpenSpellbook = true

				if SpellBookFrame:IsShown() then
					HijackSpellBookButtons(nil)
				else
					ShowUIPanel(SpellBookFrame)
				end
			end

			local function OnEnter(widget)
				local tooltip = AceGUI.tooltip

				tooltip:SetOwner(widget.frame, "ANCHOR_NONE")
				tooltip:ClearAllPoints()
				tooltip:SetPoint("LEFT", widget.frame, "RIGHT")
				tooltip:SetText(L["BINDING_UI_PAGE_ACTION_HELP_SPELL_BOOK"], 1, 0.82, 0, 1, true)
				tooltip:Show()
			end

			local function OnLeave()
				local tooltip = AceGUI.tooltip
				tooltip:Hide()
			end

			local widget = GUI:Button(L["BINDING_UI_BUTTON_FROM_SPELLBOOK"], OnClick)
			widget:SetFullWidth(true)
			widget:SetCallback("OnEnter", OnEnter)
			widget:SetCallback("OnLeave", OnLeave)

			group:AddChild(widget)
		end
	end
end

local function DrawItemSelection(container, action)
	-- target item
	do
		local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_SELECTED_ITEM"])
		container:AddChild(group)

		-- target item
		do
			local function OnEnterPressed(frame, event, value)
				local item = select(5, string.find(value, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?"))

				if item ~= nil and item ~= "" then
					local info = GetItemInfo(item)

					if info ~= nil then
						value = info
					end
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
			local widget = GUI:Label("\n" .. L["BINDING_UI_PAGE_ACTION_HELP_ITEM_SHIFT_CLICK"])
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end
	end
end

local function DrawMacroSelection(container, binding, keybind, action)
	-- macro name and icon
	do
		local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_LABEL_MACRO_NAME_ICON"])
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
		-- 	local widget = GUI:Button(L["BINDING_UI_BUTTON_SELECT"], function() end)
		-- 	widget:SetRelativeWidth(0.3)
		-- 	widget:SetDisabled(true)

		-- 	group:AddChild(widget)
		-- end
	end

	-- macro text
	do
		local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_SELECTED_MACRO"])
		container:AddChild(group)

		-- help text
		if binding.primaryTarget.unit == Clicked.TargetUnits.HOVERCAST then
			local widget = GUI:Label(L["BINDING_UI_PAGE_ACTION_HELP_HOVERCAST"] .. "\n")
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
		local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_LABEL_ADDITIONAL_OPTIONS"])
		container:AddChild(group)

		-- macro mode toggle
		do
			local items = {
				FIRST = L["BINDING_UI_PAGE_ACTION_MACRO_MODE_FIRST"],
				LAST = L["BINDING_UI_PAGE_ACTION_MACRO_MODE_LAST"],
				APPEND = L["BINDING_UI_PAGE_ACTION_MACRO_MODE_APPEND"]
			}

			local order = {
				"FIRST",
				"LAST",
				"APPEND"
			}

			local widget = GUI:Dropdown(nil, items, order, nil, action, "mode")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		if action.macroMode == Clicked.MacroMode.APPEND then
			local widget = GUI:Label("\n" .. L["BINDING_UI_PAGE_ACTION_HELP_MACRO_MODE_APPEND"])
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end
	end
end

local function DrawAdditionalSpellItemOptions(container, action)
	local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_LABEL_ADDITIONAL_OPTIONS"])
	container:AddChild(group)

	-- interrupt cast toggle
	do
		local widget = GUI:CheckBox(L["BINDING_UI_PAGE_ACTION_ADDITIONAL_OPTIONS_INTERRUPT_CURRENT_CAST"], action, "interruptCurrentCast")
		widget:SetFullWidth(true)

		group:AddChild(widget)
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
			SPELL = L["BINDING_UI_PAGE_ACTION_TYPE_SPELL"],
			ITEM = L["BINDING_UI_PAGE_ACTION_TYPE_ITEM"],
			MACRO = L["BINDING_UI_PAGE_ACTION_TYPE_MACRO"],
			UNIT_SELECT = L["BINDING_UI_PAGE_ACTION_TYPE_UNIT_TARGET"],
			UNIT_MENU = L["BINDING_UI_PAGE_ACTION_TYPE_UNIT_MENU"]
		}

		local order = {
			"SPELL",
			"ITEM",
			"MACRO",
			"UNIT_SELECT",
			"UNIT_MENU"
		}

		local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_LABEL_TYPE"])
		container:AddChild(group)

		do
			local widget = GUI:Dropdown(nil, items, order, nil, binding, "type")
			widget:SetCallback("OnValueChanged", OnValueChanged)
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end
	end

	local data = Clicked:GetActiveBindingAction(binding)

	if binding.type == Clicked.BindingTypes.SPELL then
		DrawSpellSelection(container, data)
		DrawAdditionalSpellItemOptions(container, data)
	elseif binding.type == Clicked.BindingTypes.ITEM then
		DrawItemSelection(container, data)
		DrawAdditionalSpellItemOptions(container, data)
	elseif binding.type == Clicked.BindingTypes.MACRO then
		DrawMacroSelection(container, binding, binding.keybind, data)
	end
end

-- Binding target page and components

local function DrawTargetSelectionPrimaryUnit(container, binding, target)
	if Clicked:IsRestrictedKeybind(binding.keybind) then
		local widget = GUI:Label(L["BINDING_UI_PAGE_ACTION_HELP_RESTRICTED_KEYBIND"] .. "\n")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	local items, order = Clicked:GetLocalizedTargetUnits()
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
			print(L["MSG_BINDING_UI_READ_ONLY_MODE"])
		end
	end

	local items, order = Clicked:GetLocalizedTargetUnits()
	items["_DELETE_"] = L["BINDING_UI_PAGE_TARGETS_UNIT_REMOVE"]
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
			print(L["MSG_BINDING_UI_READ_ONLY_MODE"])
		end
	end

	local items, order = Clicked:GetLocalizedTargetUnits(true)
	items["_NONE_"] = L["BINDING_UI_PAGE_TARGETS_UNIT_NONE"]
	table.insert(order, "_NONE_")

	local widget = GUI:Dropdown(nil, items, order, nil, { unit = "_NONE_" }, "unit")
	widget:SetCallback("OnValueChanged", OnValueChanged)
	widget:SetFullWidth(true)

	container:AddChild(widget)
end

local function DrawTargetSelectionHostility(container, target)
	local items, order = Clicked:GetLocalizedTargetHostility()
	local widget = GUI:Dropdown(nil, items, order, nil, target, "hostility")
	widget:SetFullWidth(true)

	container:AddChild(widget)
end

local function DrawTargetSelectionVitals(container, target)
	local items, order = Clicked:GetLocalizedTargetVitals()
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

		local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_LABEL_TARGETS_UNIT"])
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
			local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_LABEL_TARGETS_UNIT_EXTRA"])
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
				local group = GUI:InlineGroup(L["BINDING_UI_PAGE_ACTION_LABEL_TARGETS_UNIT_EXTRA"])
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
		local widget = GUI:CheckBox(L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_NEVER"] , load, "never")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end
end

local function DrawLoadClass(container, class)
	local items, order = Clicked:GetLocalizedClasses()
	DrawTristateLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_CLASS"], items, order, class)
end

local function DrawLoadRace(container, race)
	local items, order = Clicked:GetLocalizedRaces()
	DrawTristateLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_RACE"], items, order, race)
end

local function DrawLoadSpecialization(container, specialization, classNames)
	local items, order = Clicked:GetLocalizedSpecializations(classNames)
	DrawTristateLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_SPECIALIZATION"], items, order, specialization)
end

local function DrawLoadTalent(container, talent, specIds)
	local items, order = Clicked:GetLocalizedTalents(specIds)
	DrawTristateLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_TALENT"], items, order, talent)
end

local function DrawLoadPvPTalent(container, talent, specIds)
	local items, order = Clicked:GetLocalizedPvPTalents(specIds)
	DrawTristateLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_PVP_TALENT"], items, order, talent)
end

local function DrawLoadWarMode(container, warMode)
	local items = {
		IN_WAR_MODE = L["BINDING_UI_PAGE_LOAD_OPTIONS_WAR_MODE_TRUE"],
		NOT_IN_WAR_MODE = L["BINDING_UI_PAGE_LOAD_OPTIONS_WAR_MODE_FALSE"]
	}

	local order = {
		"IN_WAR_MODE",
		"NOT_IN_WAR_MODE"
	}

	DrawDropdownLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_WAR_MODE"], items, order, warMode)
end

local function DrawLoadPlayerNameRealm(container, playerNameRealm)
	DrawEditFieldLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_PLAYER_NAME_REALM"], playerNameRealm)
end

local function DrawLoadCombat(container, combat)
	local items = {
		IN_COMBAT = L["BINDING_UI_PAGE_LOAD_OPTIONS_COMBAT_TRUE"],
		NOT_IN_COMBAT = L["BINDING_UI_PAGE_LOAD_OPTIONS_COMBAT_FALSE"]
	}

	local order = {
		"IN_COMBAT",
		"NOT_IN_COMBAT"
	}

	DrawDropdownLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_COMBAT"], items, order, combat)
end

local function DrawLoadSpellKnown(container, spellKnown)
	DrawEditFieldLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_SPELL_KNOWN"], spellKnown)
end

local function DrawLoadInGroup(container, inGroup)
	local items = {
		IN_GROUP_PARTY_OR_RAID = L["BINDING_UI_PAGE_LOAD_OPTIONS_IN_GROUP_PARTY_OR_RAID"],
		IN_GROUP_PARTY = L["BINDING_UI_PAGE_LOAD_OPTIONS_IN_GROUP_PARTY"],
		IN_GROUP_RAID = L["BINDING_UI_PAGE_LOAD_OPTIONS_IN_GROUP_RAID"],
		IN_GROUP_SOLO = L["BINDING_UI_PAGE_LOAD_OPTIONS_IN_GROUP_SOLO"]
	}

	local order = {
		"IN_GROUP_PARTY_OR_RAID",
		"IN_GROUP_PARTY",
		"IN_GROUP_RAID",
		"IN_GROUP_SOLO"
	}

	DrawDropdownLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_IN_GROUP"], items, order, inGroup)
end

local function DrawLoadPlayerInGroup(container, playerInGroup)
	DrawEditFieldLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_PLAYER_IN_GROUP"], playerInGroup)
end

local function DrawLoadInStance(container, form, specIds)
	local label = L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_STANCE"]

	if specIds == nil then
		specIds = {}
		specIds[1] = GetSpecializationInfo(GetSpecialization())
	end

	if #specIds == 1 then
		local spec = specIds[1]

		-- Balance Druid, Feral Druid, Guardian Druid, Restoration Druid
		if spec == 102 or spec == 103 or spec == 104 or spec == 105 then
			label = L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_FORM"]
		end
	end

	local items, order = Clicked:GetLocalizedForms(specIds)
	DrawTristateLoadOption(container, label, items, order, form)
end

local function DrawLoadPet(container, pet)
	local items = {
		ACTIVE = L["BINDING_UI_PAGE_LOAD_OPTIONS_PET_ACTIVE"],
		INACTIVE = L["BINDING_UI_PAGE_LOAD_OPTIONS_PET_INACTIVE"],
	}

	local order = {
		"ACTIVE",
		"INACTIVE"
	}

	DrawDropdownLoadOption(container, L["BINDING_UI_PAGE_LOAD_OPTIONS_LABEL_PET"], items, order, pet)
end

local function DrawBindingLoadOptionsPage(container, binding)
	local load = binding.load

	DrawLoadNeverSelection(container, load)
	DrawLoadPlayerNameRealm(container, load.playerNameRealm)
	DrawLoadClass(container, load.class)
	DrawLoadRace(container, load.race)

	if not Clicked:IsClassic() then
		local specializationIds = {}
		local classNames = Clicked:GetTriStateLoadOptionValue(load.class)

		do
			local specIndices = Clicked:GetTriStateLoadOptionValue(load.specialization)

			if specIndices == nil then
				specIndices = {}

				if classNames == nil or #classNames == 1 and classNames[1] == select(2, UnitClass("player")) then
					specIndices[1] = GetSpecialization()
				else
					for _, class in ipairs(classNames) do
						local numSpecs = #LibTalentInfo:GetClassSpecIDs(class)

						for i = 1, numSpecs do
							table.insert(specIndices, i)
						end
					end
				end
			end

			if classNames == nil then
				classNames = {}
				classNames[1] = select(2, UnitClass("player"))
			end

			for i = 1, #classNames do
				local class = classNames[i]
				local specIds = LibTalentInfo:GetClassSpecIDs(class)

				for j = 1, #specIndices do
					local specIndex = specIndices[j]
					local specId = specIds[specIndex]

					table.insert(specializationIds, specId)
				end
			end
		end

		DrawLoadSpecialization(container, load.specialization, classNames)
		DrawLoadTalent(container, load.talent, specializationIds)
		DrawLoadPvPTalent(container, load.pvpTalent, specializationIds)
		DrawLoadInStance(container, load.form, specializationIds)
		DrawLoadWarMode(container, load.warMode)
	end

	DrawLoadCombat(container, load.combat)
	DrawLoadSpellKnown(container, load.spellKnown)
	DrawLoadInGroup(container, load.inGroup)
	DrawLoadPlayerInGroup(container, load.playerInGroup)
	DrawLoadPet(container, load.pet)
end

-- Binding status page and components

local function DrawBindingStatusPage(container, binding)
	if binding.type ~= Clicked.BindingTypes.SPELL and binding.type ~= Clicked.BindingTypes.ITEM and binding.type ~= Clicked.BindingTypes.MACRO then
		return
	end

	if  not Clicked:CanBindingLoad(binding) then
		local widget = GUI:Label(L["BINDING_UI_PAGE_STATUS_NOT_LOADED"], "medium")
		widget:SetFullWidth(true)
		container:AddChild(widget)
	else
		local bindings = {}

		for keybind, buckets in Clicked:IterateActiveBindings() do
			if keybind == binding.keybind then
				local bucket = binding.primaryTarget.unit == Clicked.TargetUnits.HOVERCAST and buckets.hovercast or buckets.regular

				for _, other in ipairs(bucket) do
					table.insert(bindings, other)
				end
			end
		end

		-- output self text field
		do
			local widget = AceGUI:Create("ClickedReadOnlyMultilineEditBox")
			widget:SetLabel(L["BINDING_UI_PAGE_STATUS_GENERATED_LOCAL"])
			widget:SetText(Clicked:GetMacroForBindings({ binding }))
			widget:SetFullWidth(true)
			widget:SetNumLines(5)

			container:AddChild(widget)
		end

		-- output of full macro
		do
			local widget = AceGUI:Create("ClickedReadOnlyMultilineEditBox")
			widget:SetLabel(L["BINDING_UI_PAGE_STATUS_GENERATED_FULL"])
			widget:SetText(Clicked:GetMacroForBindings(bindings))
			widget:SetFullWidth(true)
			widget:SetNumLines(8)

			container:AddChild(widget)
		end

		if #bindings > 1 then
			do
				local widget = AceGUI:Create("Heading")
				widget:SetFullWidth(true)
				widget:SetText(L["BINDING_UI_PAGE_STATUS_GENERATED_RELATIVES"]:format(#bindings - 1))

				container:AddChild(widget)
			end

			for _, other in ipairs(bindings) do
				if other ~= binding then
					local action = Clicked:GetActiveBindingAction(other)

					do
						local function OnClick()
							Module.tree:SelectByBindingOrGroup(other)
						end

						local widget = AceGUI:Create("InteractiveLabel")
						widget:SetFontObject(GameFontHighlight)
						widget:SetText(action.displayName)
						widget:SetImage(action.displayIcon)
						widget:SetFullWidth(true)
						widget:SetCallback("OnClick", OnClick)

						container:AddChild(widget)
					end
				end
			end
		end
	end
end

-- Group page

local function DrawGroup(container)
	local group = Module:GetCurrentGroup()

	local parent = GUI:InlineGroup(L["BINDING_UI_PAGE_GROUP_LABEL_GOUP_NAME_ICON"])
	container:AddChild(parent)

	-- name text field
	do
		local widget = GUI:EditBox(nil, "OnEnterPressed", group, "name")
		widget:SetFullWidth(true)

		parent:AddChild(widget)
	end

	-- icon field
	do
		local widget = GUI:EditBox(nil, "OnEnterPressed", group, "icon")
		--widget:SetRelativeWidth(0.7)
		widget:SetFullWidth(true)

		parent:AddChild(widget)
	end

	-- icon button
	-- do
	-- 	local widget = GUI:Button(L["BINDING_UI_BUTTON_SELECT"], function() end)
	-- 	widget:SetRelativeWidth(0.3)
	-- 	widget:SetDisabled(true)

	-- 	group:AddChild(widget)
	-- end
end

-- Item templates

local function CreateFromItemTemplate(identifier)
	if identifier == ITEM_TEMPLATE_SIMPLE_BINDING then
		local binding = Clicked:CreateNewBinding()

		Module.tree:SelectByBindingOrGroup(binding)
	elseif identifier == ITEM_TEMPLATE_CLICKCAST_BINDING then
		local binding = Clicked:CreateNewBinding()
		binding.primaryTarget.unit = Clicked.TargetUnits.HOVERCAST

		Module.tree:SelectByBindingOrGroup(binding)
	elseif identifier == ITEM_TEMPLATE_HEALER_BINDING then
		local binding = Clicked:CreateNewBinding()
		binding.primaryTarget.unit = Clicked.TargetUnits.MOUSEOVER
		binding.primaryTarget.hostility = Clicked.TargetHostility.HELP

		binding.secondaryTargets[1] = Clicked:GetNewBindingTargetTemplate()
		binding.secondaryTargets[1].unit = Clicked.TargetUnits.TARGET
		binding.secondaryTargets[1].hostility = Clicked.TargetHostility.HELP

		binding.secondaryTargets[2] = Clicked:GetNewBindingTargetTemplate()
		binding.secondaryTargets[2].unit = Clicked.TargetUnits.PLAYER

		Module.tree:SelectByBindingOrGroup(binding)
	elseif identifier == ITEM_TEMPLATE_GROUP then
		local group = Clicked:CreateNewGroup()

		Module.tree:SelectByBindingOrGroup(group)
	end
end

local function DrawItemTemplate(container, identifier, name, description)
	local group = GUI:InlineGroup(name)

	container:AddChild(group)

	do
		local widget = GUI:Label(description, "medium")
		widget:SetRelativeWidth(0.79)
		group:AddChild(widget)
	end

	do
		local function OnClick()
			CreateFromItemTemplate(identifier)
		end

		local widget = GUI:Button(L["BINDING_UI_BUTTON_CREATE"], OnClick)
		widget:SetRelativeWidth(0.2)
		group:AddChild(widget)
	end
end

-- Main binding frame

local function DrawBinding(container)
	local binding = Module:GetCurrentBinding()

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
			scrollFrame:SetLayout("Flow")

			container:AddChild(scrollFrame)

			if group == "action" then
				DrawBindingActionPage(scrollFrame, binding)
			elseif group == "target" then
				DrawBindingTargetPage(scrollFrame, binding)
			elseif group == "conditions" then
				DrawBindingLoadOptionsPage(scrollFrame, binding)
			elseif group == "status" then
				DrawBindingStatusPage(scrollFrame, binding)
			end

			scrollFrame:DoLayout()
		end

		local items = {
			{
				text = L["BINDING_UI_PAGE_TITLE_ACTIONS"],
				value = "action"
			},
			{
				text = L["BINDING_UI_PAGE_TITLE_TARGETS"],
				value = "target"
			},
			{
				text = L["BINDING_UI_PAGE_TITLE_CONDITIONS"],
				value = "conditions"
			},
			{
				text = L["BINDING_UI_PAGE_TITLE_STATUS"],
				value = "status"
			}
		}

		local widget = GUI:TabGroup(items, OnGroupSelected)
		widget:SetStatusTable(Module.tab)
		widget:SelectTab(Module.tab.selected)

		container:AddChild(widget)
	end
end

local function DrawItemTemplateSelector(container)
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("Flow")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)

	container:AddChild(scrollFrame)

	do
		local widget = GUI:Label(L["BINDING_UI_PAGE_TITLE_TEMPLATE"], "large")
		scrollFrame:AddChild(widget)
	end

	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_GROUP, L["BINDING_UI_PAGE_TEMPLATE_TITLE_GROUP"], L["BINDING_UI_PAGE_TEMPLATE_DESCRIPTION_GROUP"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_SIMPLE_BINDING, L["BINDING_UI_PAGE_TEMPLATE_TITLE_SIMPLE_BINDING"], L["BINDING_UI_PAGE_TEMPLATE_DESCRIPTION_SIMPLE_BINDING"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_CLICKCAST_BINDING, L["BINDING_UI_PAGE_TEMPLATE_TITLE_CLICKCAST_BINDING"], L["BINDING_UI_PAGE_TEMPLATE_DESCRIPTION_CLICKCAST_BINDING"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_HEALER_BINDING, L["BINDING_UI_PAGE_TEMPLATE_TITLE_HEALER_BINDING"], L["BINDING_UI_PAGE_TEMPLATE_DESCRIPTION_HEALER_BINDING"])

	scrollFrame:DoLayout()
end

-- Main frame

local function DrawHeader(container)
	local line = AceGUI:Create("ClickedSimpleGroup")
	line:SetWidth(300)
	line:SetLayout("table")
	line:SetUserData("table", { columns = { 0, 1} })

	container:AddChild(line)

	-- create binding button
	do
		local function OnClick()
			Module.tree:SelectByValue("")
		end

		local widget = GUI:Button(L["BINDING_UI_BUTTON_NEW"], OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)
	end

	-- search box
	do
		Module.searchBox = AceGUI:Create("ClickedSearchBox")
		Module.searchBox:DisableButton(true)
		Module.searchBox:SetPlaceholderText(L["BINDING_UI_SEARCHBOX_PLACEHOLDER"])
		Module.searchBox:SetFullWidth(true)

		line:AddChild(Module.searchBox)
	end
end

local function DrawTreeContainer(container, event, group)
	container:ReleaseChildren()

	if Module:GetCurrentBinding() ~= nil then
		DrawBinding(container)
	elseif Module:GetCurrentGroup() ~= nil then
		DrawGroup(container)
	else
		DrawItemTemplateSelector(container)
	end
end

local function DrawTreeView(container)
	-- tree view
	do
		Module.tree = AceGUI:Create("ClickedTreeGroup")
		Module.tree:SetLayout("Flow")
		Module.tree:SetFullWidth(true)
		Module.tree:SetFullHeight(true)
		Module.tree:SetCallback("OnGroupSelected", DrawTreeContainer)
		Module.tree:SetSearchHandler(Module.searchBox)

		container:AddChild(Module.tree)
	end
end

-- Event handlers

local function OnGUIUpdateEvent()
	if Module.root == nil or not Module.root:IsVisible() then
		return
	end

	Clicked:ReloadActiveBindings()
end

local function OnBindingsChangedEvent()
	Module:Redraw()
end

function Clicked:OpenBindingConfig()
	if Module.root ~= nil and Module.root:IsVisible() then
		return
	end

	-- root frame
	do
		local function OnClose(container)
			AceGUI:Release(container)

			if didOpenSpellbook then
				HideUIPanel(SpellBookFrame)
			end
		end

		Module.root = AceGUI:Create("Frame")
		Module.root:SetCallback("OnClose", OnClose)
		Module.root:SetTitle(L["BINDING_UI_FRAME_TITLE"])
		Module.root:SetLayout("Flow")
		Module.root:SetWidth(800)
		Module.root:SetHeight(600)

		Module.tab = {
			selected = "action"
		}
	end

	if InCombatLockdown() then
		print(L["MSG_BINDING_UI_READ_ONLY_MODE"])
	end

	DrawHeader(Module.root)
	DrawTreeView(Module.root)

	Module:Redraw()
end

function Module:Initialize()
	SpellBookFrame:HookScript("OnHide", function()
		HijackSpellBookButtons(nil)
	end)

	hooksecurefunc("SpellButton_UpdateButton", HijackSpellBookButtons)

	if not Clicked:IsClassic() then
		hooksecurefunc(SpellFlyout, "Toggle", HijackSpellBookFlyoutButtons)
		hooksecurefunc("SpellFlyout_Toggle", HijackSpellBookFlyoutButtons)
	end
end

function Module:Register()
	Clicked:RegisterMessage(GUI.EVENT_UPDATE, OnGUIUpdateEvent)
	Clicked:RegisterMessage(Clicked.EVENT_BINDINGS_CHANGED, OnBindingsChangedEvent)
	Clicked:RegisterMessage(Clicked.EVENT_GROUPS_CHANGED, OnBindingsChangedEvent)
end

function Module:Unregister()
	Clicked:UnregisterMessage(GUI.EVENT_UPDATE)
	Clicked:UnregisterMessage(Clicked.EVENT_BINDINGS_CHANGED)
	Clicked:UnregisterMessage(Clicked.EVENT_GROUPS_CHANGED)
end

function Module:Redraw()
	if self.root == nil or not self.root:IsVisible() then
		return
	end

	self.root:SetStatusText(L["BINDING_UI_FRAME_STATUS_TEXT"]:format(Clicked.VERSION, Clicked.db:GetCurrentProfile()))
	self.tree:ConstructTree()
end

function Module:GetCurrentBinding()
	local item = self.tree:GetSelectedItem()

	if item ~= nil then
		return item.binding
	end

	return nil
end

function Module:GetCurrentGroup()
	local item = self.tree:GetSelectedItem()

	if item ~= nil then
		return item.group
	end

	return nil
end

function Module:OnChatCommandReceived(args)
	if #args == 0 then
		Clicked:OpenBindingConfig()
	end
end

Clicked:RegisterModule("BindingConfig", Module)

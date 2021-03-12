local AceGUI = LibStub("AceGUI-3.0")
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local ITEM_TEMPLATE_SIMPLE_BINDING = "SIMPLE_BINDING"
local ITEM_TEMPLATE_CLICKCAST_BINDING = "CLICKCAST_BINDING"
local ITEM_TEMPLATE_HEALER_BINDING = "HEALER_BINDING"
local ITEM_TEMPLATE_CUSTOM_MACRO = "CUSTOM_MACRO"
local ITEM_TEMPLATE_GROUP = "GROUP"

local spellbookButtons = {}
local spellFlyOutButtons = {}

local iconCache = nil
local showIconPicker = false

local root
local tree
local tab

-- reset on close
local didOpenSpellbook

-- Utility functions

local function GetCurrentBinding()
	local item = tree:GetSelectedItem()

	if item ~= nil then
		return item.binding
	end

	return nil
end

local function GetCurrentGroup()
	local item = tree:GetSelectedItem()

	if item ~= nil then
		return item.group
	end

	return nil
end

local function UpdateRequiredTargetModesForBinding(targets, keybind, type)
	local hovercast = targets.hovercast
	local regular = targets.regular

	if Addon:IsRestrictedKeybind(keybind) or type == Addon.BindingTypes.UNIT_SELECT or type == Addon.BindingTypes.UNIT_MENU then
		hovercast.enabled = true
		regular.enabled = false
	end

	if type == Addon.BindingTypes.MACRO then
		while #regular > 0 do
			table.remove(regular, 1)
		end

		regular[1] = Addon:GetNewBindingTargetTemplate()

		hovercast.hostility = Addon.TargetHostility.ANY
		hovercast.vitals = Addon.TargetVitals.ANY
	end
end

local function CanEnableHovercastTargetMode(binding)
	return true
end

local function CanEnableRegularTargetMode(binding)
	if Addon:IsRestrictedKeybind(binding.keybind) or binding.type == Addon.BindingTypes.UNIT_SELECT or binding.type == Addon.BindingTypes.UNIT_MENU then
		return false
	end

	return true
end

local function GetTriStateLoadOptionValue(option)
	if option.selected == 1 then
		return { option.single }
	elseif option.selected == 2 then
		return { unpack(option.multiple) }
	end

	return nil
end

local function ParseItemLink(link, ...)
	local allowed = { ... }

	local function IsAllowed(type)
		if #allowed == 0 then
			return true
		end

		for _, arg in ipairs(allowed) do
			if arg == type then
				return true
			end
		end

		return false
	end

	local _, _, _, type, id = string.find(link, "|?c?f?f?(%x*)|?H?([^:]*):?(%d+):?(%d*):?(%d*):?(%d*):?(%d*):?(%d*):?(%-?%d*):?(%-?%d*):?(%d*):?(%d*):?(%-?%d*)|?h?%[?([^%[%]]*)%]?|?h?|?r?")
	local result = nil

	if type == "talent" and IsAllowed("talent") then
		local spellId = select(6, GetTalentInfoByID(id, 1))

		if spellId ~= nil then
			result = GetSpellInfo(spellId)
		end
	elseif type == "item" and IsAllowed("item") then
		result = Addon:GetItemInfo(id)
	elseif type == "spell" and IsAllowed("spell") then
		result = GetSpellInfo(id)
	end

	return result
end

-- Tooltips

local function ShowTooltip(widget, text, subText)
	local tooltip = AceGUI.tooltip

	if subText ~= nil then
		text = text .. "\n|cffffffff" .. subText .. "|r"
	end

	tooltip:SetOwner(widget.frame, "ANCHOR_NONE")
	tooltip:ClearAllPoints()
	tooltip:SetPoint("BOTTOMLEFT", widget.frame, "TOPLEFT")
	tooltip:SetText(text, true)
	tooltip:Show()
end

local function HideTooltip()
	local tooltip = AceGUI.tooltip
	tooltip:Hide()
end

local function RegisterTooltip(widget, text, subText)
	local function OnEnter()
		ShowTooltip(widget, text, subText)
	end

	local function OnLeave()
		HideTooltip()
	end

	widget:SetCallback("OnEnter", OnEnter)
	widget:SetCallback("OnLeave", OnLeave)
end

-- Spell book integration

local function OnSpellBookButtonClick(name)
	if GetCurrentBinding() == nil or name == nil then
		return
	end

	if InCombatLockdown() then
		Addon:NotifyCombatLockdown()
		return
	end

	local binding = GetCurrentBinding()

	if binding.type == Addon.BindingTypes.SPELL then
		binding.action.spellValue = name
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
				local name, subName = GetSpellBookItemName(slot, SpellBookFrame.bookType)

				if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC and not Addon:IsStringNilOrEmpty(subName) then
					name = string.format("%s(%s)", name, subName)
				end

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
				canShow = canShow and root ~= nil and root:IsVisible()
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
	if root == nil or not root:IsVisible() then
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

-- Icon picker

local function EnsureIconCache()
	local addon = "ClickedMedia"

	if iconCache == nil then
		if not IsAddOnLoaded(addon) then
			local loaded, reason = LoadAddOn(addon)

			if not loaded then
				if reason == "DISABLED" then
					EnableAddOn(addon, true)
					LoadAddOn(addon)
				else
					error("Unable to load " .. addon ": " .. reason)
				end
			end
		end

		if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
			iconCache = ClickedMedia:GetRetailIcons()
		elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
			iconCache = ClickedMedia:GetClassicIcons()
		end
	end

	if iconCache == nil then
		error("Unable to load icons")
	end

	table.sort(iconCache)
end

local function DrawIconPicker(container, data)
	EnsureIconCache()

	local searchBox

	do
		local widget = AceGUI:Create("ClickedSearchBox")
		widget:DisableButton(true)
		widget:SetPlaceholderText(L["Search..."])
		widget:SetRelativeWidth(0.75)
		searchBox = widget

		container:AddChild(widget)
	end

	do
		local function OnClick()
			tree:Redraw()
		end

		local widget = Addon:GUI_Button(CANCEL, OnClick)
		widget:SetRelativeWidth(0.25)

		container:AddChild(widget)
	end

	do
		-- luacheck: ignore container
		local function OnIconSelected(container, event, value)
			data.displayIcon = value
			Addon:BindingConfig_Redraw()
		end

		local scrollFrame = AceGUI:Create("ClickedIconSelectorList")
		scrollFrame:SetLayout("Flow")
		scrollFrame:SetFullWidth(true)
		scrollFrame:SetFullHeight(true)
		scrollFrame:SetIcons(iconCache)
		scrollFrame:SetSearchHandler(searchBox)
		scrollFrame:SetCallback("OnIconSelected", OnIconSelected)

		container:AddChild(scrollFrame)
	end
end

-- Common draw functions

local function DrawDropdownLoadOption(container, title, items, order, data)
	-- enabled toggle
	do
		local widget = Addon:GUI_CheckBox(title, data, "selected")

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
			local widget = Addon:GUI_Dropdown(nil, items, order, nil, data, "value")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

local function DrawEditFieldLoadOption(container, title, data)
	-- spell known toggle
	do
		local widget = Addon:GUI_CheckBox(title, data, "selected")

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
			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", data, "value")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

local function DrawTristateLoadOption(container, title, items, order, data)
	assert(type(data) == "table", "bad argument #5, expected table but got " .. type(data))

	-- enabled toggle
	do
		local widget = Addon:GUI_TristateCheckBox(title, data, "selected")
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
		widget = Addon:GUI_Dropdown(nil, items, order, itemType, data, "single")
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

		widget = Addon:GUI_MultiselectDropdown(nil, items, order, itemType, data, "multiple")
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

local function DrawSpellSelection(container, action, cache)
	-- target spell
	do
		local group = Addon:GUI_InlineGroup(L["Target Spell"])
		container:AddChild(group)

		-- edit box
		do
			local function OnEnterPressed(frame, event, value)
				value = Addon:TrimString(value)

				wipe(cache)
				Addon:GUI_Serialize(frame, event, value)
			end

			local function OnTextChanged(frame, event, value)
				local spell = ParseItemLink(value, "spell", "talent")

				if spell ~= nil then
					wipe(cache)
					Addon:GUI_Serialize(frame, event, spell)
				end
			end

			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", action, "spellValue")
			widget:SetCallback("OnEnterPressed", OnEnterPressed)
			widget:SetCallback("OnTextChanged", OnTextChanged)
			widget:SetFullWidth(true)

			RegisterTooltip(widget, L["Target Spell"], L["Enter the spell name or spell ID."])

			group:AddChild(widget)
		end

		-- pick from spellbook button
		do
			local function OnClick()
				if InCombatLockdown() then
					Addon:NotifyCombatLockdown()
					return
				end

				didOpenSpellbook = true

				if SpellBookFrame:IsShown() then
					HijackSpellBookButtons(nil)
				else
					ShowUIPanel(SpellBookFrame)
				end
			end

			local widget = Addon:GUI_Button(L["Pick from spellbook"], OnClick)
			widget:SetFullWidth(true)

			RegisterTooltip(widget, L["Click on a spell book entry to select it."])

			group:AddChild(widget)
		end
	end
end

local function DrawItemSelection(container, action, cache)
	-- target item
	do
		local group = Addon:GUI_InlineGroup(L["Target Item"])
		container:AddChild(group)

		-- target item
		do
			local function OnEnterPressed(frame, event, value)
				value = Addon:TrimString(value)

				wipe(cache)
				Addon:GUI_Serialize(frame, event, value)
			end

			local function OnTextChanged(frame, event, value)
				local item = ParseItemLink(value, "item")

				if item ~= nil then
					wipe(cache)
					Addon:GUI_Serialize(frame, event, item)
				end
			end

			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", action, "itemValue")
			widget:SetCallback("OnEnterPressed", OnEnterPressed)
			widget:SetCallback("OnTextChanged", OnTextChanged)
			widget:SetFullWidth(true)

			RegisterTooltip(widget, L["Target Item"], L["Enter an item name, item ID, or equipment slot number."] .. "\n\n" .. L["If the input field is empty you can also shift-click an item from your bags to auto-fill."])

			group:AddChild(widget)
		end
	end
end

local function DrawMacroSelection(container, targets, action, cache)
	-- macro name and icon
	do
		local group = Addon:GUI_InlineGroup(L["Macro Name and Icon (optional)"])
		container:AddChild(group)

		-- name text field
		do
			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", cache, "displayName")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		-- icon field
		do
			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", cache, "displayIcon")
			widget:SetRelativeWidth(0.7)

			group:AddChild(widget)
		end

		-- icon button
		do
			local function OpenIconPicker()
				showIconPicker = true
				tree:Redraw()
			end

			local widget = Addon:GUI_Button(L["Select"], OpenIconPicker)
			widget:SetRelativeWidth(0.3)

			group:AddChild(widget)
		end
	end

	-- macro text
	do
		local group = Addon:GUI_InlineGroup(L["Macro Text"])
		container:AddChild(group)

		-- help text
		if targets.hovercast.enabled and not targets.regular.enabled then
			local widget = Addon:GUI_Label(L["This macro will only execute when hovering over unit frames, in order to interact with the selected target use the [@mouseover] conditional."] .. "\n")
			widget:SetFullWidth(true)
			group:AddChild(widget)
		end

		-- macro text field
		do
			local widget = Addon:GUI_MultilineEditBox(nil, "OnEnterPressed", action, "macroValue")
			widget:SetFullWidth(true)
			widget:SetNumLines(8)

			group:AddChild(widget)
		end
	end

	-- additional options
	do
		local group = Addon:GUI_InlineGroup(L["Options"])
		container:AddChild(group)

		-- macro mode toggle
		do
			local items = {
				FIRST = L["Run first (default)"],
				LAST = L["Run last"],
				APPEND = L["Append after bindings (super advanced)"]
			}

			local order = {
				"FIRST",
				"LAST",
				"APPEND"
			}

			local widget = Addon:GUI_Dropdown(nil, items, order, nil, action, "macroMode")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		if action.macroMode == Addon.MacroMode.APPEND then
			local msg = {
				L["This mode will directly append the macro text onto an automatically generated command generated by other bindings using the specified keybind. Generally, this means that it will be the last section of an '/use' command."],
				L["With this mode you're not writing a macro command. You're adding parts to an already existing command, so writing '/use Holy Light' will not work, in order to cast Holy Light simply type 'Holy Light'."]
			}

			local widget = Addon:GUI_Label("\n" .. table.concat(msg, "\n\n"))
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end
	end
end

local function DrawSharedSpellItemOptions(container, binding)
	local function IsSharedDataSet(key)
		for _, other in Clicked:IterateActiveBindings() do
			if other ~= binding and other.keybind == binding.keybind then
				if other.action[key] then
					return true
				end
			end
		end

		return false
	end

	local function CreateCheckbox(group, label, tooltipText, key)
		local isUsingShared = false

		local function OnValueChanged(frame, event, value)
			if value == false and isUsingShared then
				value = true
			end

			binding.action[key] = value
			Clicked:ReloadActiveBindings()
		end

		local widget = AceGUI:Create("CheckBox")
		widget:SetType("checkbox")
		widget:SetLabel(label)
		widget:SetCallback("OnValueChanged", OnValueChanged)
		widget:SetFullWidth(true)

		RegisterTooltip(widget, label, tooltipText)

		if binding.action[key] then
			widget:SetValue(true)
		else
			if Addon:CanBindingLoad(binding) and IsSharedDataSet(key) then
				widget:SetTriState(true)
				widget:SetValue(nil)
				isUsingShared = true
			end
		end

		group:AddChild(widget)
	end

	local group = Addon:GUI_InlineGroup(L["Shared Options"])
	container:AddChild(group)

	CreateCheckbox(group, L["Interrupt current cast"], L["Allow this binding to cancel any spells that are currently being cast."], "interrupt")
	CreateCheckbox(group, L["Allow starting of auto attacks"], L["Allow this binding to start auto attacks, useful for any damaging abilities."], "allowStartAttack")
	CreateCheckbox(group, L["Override queued spell"], L["Allow this binding to override a spell that is queued by the lag-tolerance system, should be reserved for high-priority spells."], "cancelQueuedSpell")
	CreateCheckbox(group, L["Target on cast"], L["Targets the unit you are casting on."], "targetUnitAfterCast")
end

local function DrawIntegrationsOptions(container, binding)
	local group = Addon:GUI_InlineGroup(L["External Integrations"])
	local hasAnyChildren = false

	-- weakauras export
	if Addon:IsWeakAurasIntegrationEnabled() then
		local function OnClick()
			Addon:CreateWeakAurasIcon(binding)
		end

		local widget = AceGUI:Create("InteractiveLabel")
		widget:SetImage([[Interface\AddOns\WeakAuras\Media\Textures\icon]])
		widget:SetImageSize(16, 16)
		widget:SetText(string.format("%s (%s)", L["Create WeakAura"], L["Beta"]))
		widget:SetCallback("OnClick", OnClick)
		widget:SetFullWidth(true)
		widget:SetDisabled(not Addon:HasBindingValue(binding))

		group:AddChild(widget)

		hasAnyChildren = true
	end

	if hasAnyChildren then
		container:AddChild(group)
	end
end

local function DrawBindingActionPage(container, binding, cache)
	-- action dropdown
	do
		local function OnValueChanged(frame, event, value)
			wipe(cache)

			UpdateRequiredTargetModesForBinding(binding.targets, binding.keybind, value)
			Addon:GUI_Serialize(frame, event, value)
		end

		local items = {
			SPELL = L["Cast a spell"],
			ITEM = L["Use an item"],
			MACRO = L["Run a macro (advanced)"],
			UNIT_SELECT = L["Target the unit"],
			UNIT_MENU = L["Open the unit menu"]
		}

		local order = {
			"SPELL",
			"ITEM",
			"MACRO",
			"UNIT_SELECT",
			"UNIT_MENU"
		}

		local group = Addon:GUI_InlineGroup(L["Action"])
		container:AddChild(group)

		do
			local widget = Addon:GUI_Dropdown(nil, items, order, nil, binding, "type")
			widget:SetCallback("OnValueChanged", OnValueChanged)
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end
	end

	if binding.type == Addon.BindingTypes.SPELL then
		DrawSpellSelection(container, binding.action, binding.cache)
		DrawSharedSpellItemOptions(container, binding)
		DrawIntegrationsOptions(container, binding)
	elseif binding.type == Addon.BindingTypes.ITEM then
		DrawItemSelection(container, binding.action, binding.cache)
		DrawSharedSpellItemOptions(container, binding)
		DrawIntegrationsOptions(container, binding)
	elseif binding.type == Addon.BindingTypes.MACRO then
		DrawMacroSelection(container, binding.targets, binding.action, binding.cache)
	end
end

-- Binding target page and components

local function DrawTargetSelectionUnit(container, targets, enabled, index)
	local target

	local function OnValueChanged(frame, event, value)
		if not InCombatLockdown() then
			if value == "_NONE_" then
				return
			elseif value == "_DELETE_" then
				table.remove(targets, index)
			else
				if index == 0 then
					local new = Addon:GetNewBindingTargetTemplate()
					new.unit = value

					if #targets > 0 then
						local last = targets[#targets]

						new.hostility = last.hostility
						new.vitals = last.vitals
					end

					table.insert(targets, new)
				else
					target.unit = value
				end
			end

			Clicked:ReloadActiveBindings()
		else
			if index == 0 then
				frame:SetValue("_NONE_")
			else
				frame:SetValue(target.unit)
			end

			Addon:NotifyCombatLockdown()
		end
	end

	local items, order = Addon:GetLocalizedTargetUnits()

	if index == 0 then
		target = {
			unit = "_NONE_"
		}

		items["_NONE_"] = L["<No one>"]
		table.insert(order, "_NONE_")
	else
		target = targets[index]

		if #targets > 1 then
			items["_DELETE_"] = L["<Remove this target>"]
			table.insert(order, "_DELETE_")
		end
	end

	local widget = Addon:GUI_Dropdown(nil, items, order, nil, target, "unit")
	widget:SetFullWidth(true)
	widget:SetCallback("OnValueChanged", OnValueChanged)
	widget:SetDisabled(not enabled)

	container:AddChild(widget)
end

local function DrawTargetSelectionHostility(container, enabled, target)
	local items, order = Addon:GetLocalizedTargetHostility()
	local widget = Addon:GUI_Dropdown(nil, items, order, nil, target, "hostility")
	widget:SetFullWidth(true)
	widget:SetDisabled(not enabled)

	container:AddChild(widget)
end

local function DrawTargetSelectionVitals(container, enabled, target)
	local items, order = Addon:GetLocalizedTargetVitals()
	local widget = Addon:GUI_Dropdown(nil, items, order, nil, target, "vitals")
	widget:SetFullWidth(true)
	widget:SetDisabled(not enabled)

	container:AddChild(widget)
end

local function DrawBindingTargetPage(container, binding)
	if Addon:IsRestrictedKeybind(binding.keybind) then
		local widget = Addon:GUI_Label(L["The left and right mouse button can only activate when hovering over unit frames."] .. "\n", "medium")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	local isMacro = binding.type == Addon.BindingTypes.MACRO

	-- hovercast targets
	do
		local hovercast = binding.targets.hovercast

		do
			local widget = Addon:GUI_ToggleHeading(L["Unit Frame Target"], hovercast, "enabled")
			widget:SetDisabled(not CanEnableHovercastTargetMode(binding))
			container:AddChild(widget)
		end

		DrawTargetSelectionHostility(container, hovercast.enabled and not isMacro, hovercast)
		DrawTargetSelectionVitals(container, hovercast.enabled and not isMacro, hovercast)
	end

	-- regular targets
	do
		local regular = binding.targets.regular

		do
			local widget = Addon:GUI_ToggleHeading(L["Binding Targets"], regular, "enabled")
			widget:SetDisabled(not CanEnableRegularTargetMode(binding))
			container:AddChild(widget)
		end

		if isMacro then
			local group = Addon:GUI_InlineGroup(L["On this target"])
			container:AddChild(group)

			DrawTargetSelectionUnit(group, regular, false, 1)
		else
			local enabled = regular.enabled

			-- existing targets
			for i, target in ipairs(regular) do
				local function OnMove(frame, event)
					if event == "OnMoveUp" then
						local temp = regular[i - 1]
						regular[i - 1] = regular[i]
						regular[i] = temp
					elseif event == "OnMoveDown" then
						local temp = regular[i + 1]
						regular[i + 1] = regular[i]
						regular[i] = temp
					end

					Clicked:ReloadActiveBindings()
				end

				local label = i == 1 and L["On this target"] or enabled and L["Or"] or L["Or (inactive)"]
				local group = Addon:GUI_ReorderableInlineGroup(label)
				group:SetMoveUpButton(i > 1)
				group:SetMoveDownButton(i < #regular)
				group:SetCallback("OnMoveDown", OnMove)
				group:SetCallback("OnMoveUp", OnMove)
				container:AddChild(group)

				if not binding.targets.hovercast.enabled and target.unit == Addon.TargetUnits.MOUSEOVER and Addon:IsMouseButton(binding.keybind) then
					local widget = Addon:GUI_Label(L["Bindings using a mouse button and the Mouseover target will not activate when hovering over a unit frame, enable the Unit Frame Target to enable unit frame clicks."] .. "\n")
					widget:SetFullWidth(true)

					group:AddChild(widget)
				end

				DrawTargetSelectionUnit(group, regular, enabled, i)

				if Addon:CanUnitBeHostile(target.unit) then
					DrawTargetSelectionHostility(group, enabled, target)
				end

				if Addon:CanUnitBeDead(target.unit) then
					DrawTargetSelectionVitals(group, enabled, target)
				end
			end

			-- new target
			do
				local group = Addon:GUI_InlineGroup(enabled and L["Or"] or L["Or (inactive)"])
				container:AddChild(group)

				DrawTargetSelectionUnit(group, regular, enabled, 0)
			end
		end
	end
end

-- Binding load options page and components

local function DrawLoadNeverSelection(container, load)
	-- never load toggle
	do
		local widget = Addon:GUI_CheckBox(L["Never load"] , load, "never")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end
end

local function DrawLoadClass(container, class)
	local items, order = Addon:GetLocalizedClasses()
	DrawTristateLoadOption(container, CLASS, items, order, class)
end

local function DrawLoadRace(container, race)
	local items, order = Addon:GetLocalizedRaces()
	DrawTristateLoadOption(container, RACE, items, order, race)
end

local function DrawLoadSpecialization(container, specialization, classNames)
	local items, order = Addon:GetLocalizedSpecializations(classNames)
	DrawTristateLoadOption(container, L["Talent specialization"], items, order, specialization)
end

local function DrawLoadTalent(container, talent, specIds)
	local items, order = Addon:GetLocalizedTalents(specIds)
	DrawTristateLoadOption(container, L["Talent selected"], items, order, talent)
end

local function DrawLoadPvPTalent(container, talent, specIds)
	local items, order = Addon:GetLocalizedPvPTalents(specIds)
	DrawTristateLoadOption(container, L["PvP talent selected"], items, order, talent)
end

local function DrawLoadWarMode(container, warMode)
	local items = {
		IN_WAR_MODE = L["War Mode enabled"],
		NOT_IN_WAR_MODE = L["War Mode disabled"]
	}

	local order = {
		"IN_WAR_MODE",
		"NOT_IN_WAR_MODE"
	}

	DrawDropdownLoadOption(container, L["War Mode"], items, order, warMode)
end

local function DrawLoadPlayerNameRealm(container, playerNameRealm)
	DrawEditFieldLoadOption(container, L["Player Name-Realm"], playerNameRealm)
end

local function DrawLoadCombat(container, combat)
	local items = {
		IN_COMBAT = L["In combat"],
		NOT_IN_COMBAT = L["Not in combat"]
	}

	local order = {
		"IN_COMBAT",
		"NOT_IN_COMBAT"
	}

	DrawDropdownLoadOption(container, COMBAT, items, order, combat)
end

local function DrawLoadSpellKnown(container, spellKnown)
	DrawEditFieldLoadOption(container, L["Spell known"], spellKnown)
end

local function DrawLoadInGroup(container, inGroup)
	local items = {
		IN_GROUP_PARTY_OR_RAID = L["In a party or raid group"],
		IN_GROUP_PARTY = L["In a party"],
		IN_GROUP_RAID = L["In a raid group"],
		IN_GROUP_SOLO = L["Not in a group"]
	}

	local order = {
		"IN_GROUP_PARTY_OR_RAID",
		"IN_GROUP_PARTY",
		"IN_GROUP_RAID",
		"IN_GROUP_SOLO"
	}

	DrawDropdownLoadOption(container, L["In group"], items, order, inGroup)
end

local function DrawLoadPlayerInGroup(container, playerInGroup)
	DrawEditFieldLoadOption(container, L["Player in group"], playerInGroup)
end

local function DrawLoadInStance(container, form, specIds)
	local label = L["Stance"]

	if specIds == nil then
		specIds = {}
		specIds[1] = GetSpecializationInfo(GetSpecialization())
	end

	if #specIds == 1 then
		local specId = specIds[1]

		-- Balance Druid, Feral Druid, Guardian Druid, Restoration Druid, Initial Druid
		if specId == 102 or specId == 103 or specId == 104 or specId == 105 or specId == 1447 then
			label = L["Form"]
		end
	end

	local items, order = Addon:GetLocalizedForms(specIds)
	DrawTristateLoadOption(container, label, items, order, form)
end

local function DrawLoadPet(container, pet)
	local items = {
		ACTIVE = L["Pet exists"],
		INACTIVE = L["No pet"],
	}

	local order = {
		"ACTIVE",
		"INACTIVE"
	}

	DrawDropdownLoadOption(container, PET, items, order, pet)
end

local function DrawLoadInCovenant(container, covenant)
	local ids = C_Covenants.GetCovenantIDs()
	local items = {}
	local order = {}

	for _, id in ipairs(ids) do
		local data = C_Covenants.GetCovenantData(id)
		local name = data.name

		items[id] = name
		table.insert(order, id)
	end

	DrawTristateLoadOption(container, L["Covenant selected"], items, order, covenant)
end

local function DrawLoadInInstanceType(container, instanceType)
	local items
	local order

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		items = {
			NONE = L["No Instance"],
			SCENARIO = L["Scenario"],
			PARTY = L["Dungeon"],
			RAID = L["Raid"],
			PVP = BATTLEGROUND,
			ARENA = ARENA
		}

		order = {
			"NONE",
			"SCENARIO",
			"PARTY",
			"RAID",
			"PVP",
			"ARENA"
		}
	else
		items = {
			NONE = L["No Instance"],
			DUNGEON = L["Dungeon"],
			RAID = L["Raid"]
		}

		order = {
			"NONE",
			"DUNGEON",
			"RAID"
		}
	end

	DrawTristateLoadOption(container, L["Instance type"], items, order, instanceType)
end

local function DrawBindingLoadOptionsPage(container, binding)
	local load = binding.load

	DrawLoadNeverSelection(container, load)
	DrawLoadPlayerNameRealm(container, load.playerNameRealm)
	DrawLoadClass(container, load.class)
	DrawLoadRace(container, load.race)

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		local specializationIds = {}
		local classNames = GetTriStateLoadOptionValue(load.class)

		do
			local specIndices = GetTriStateLoadOptionValue(load.specialization)

			if specIndices == nil then
				specIndices = {}

				if classNames == nil or #classNames == 1 and classNames[1] == select(2, UnitClass("player")) then
					specIndices[1] = GetSpecialization()
				else
					for _, class in ipairs(classNames) do
						local specs = LibTalentInfo:GetClassSpecIDs(class)

						for specIndex in pairs(specs) do
							table.insert(specIndices, specIndex)
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
				local specs = LibTalentInfo:GetClassSpecIDs(class)

				for j = 1, #specIndices do
					local specIndex = specIndices[j]
					local specId = specs[specIndex]

					table.insert(specializationIds, specId)
				end
			end
		end

		DrawLoadSpecialization(container, load.specialization, classNames)
		DrawLoadTalent(container, load.talent, specializationIds)
		DrawLoadPvPTalent(container, load.pvpTalent, specializationIds)
		DrawLoadInStance(container, load.form, specializationIds)
		DrawLoadWarMode(container, load.warMode)
		DrawLoadInInstanceType(container, load.instanceType)
		DrawLoadInCovenant(container, load.covenant)
	end

	DrawLoadCombat(container, load.combat)
	DrawLoadSpellKnown(container, load.spellKnown)
	DrawLoadInGroup(container, load.inGroup)
	DrawLoadPlayerInGroup(container, load.playerInGroup)
	DrawLoadPet(container, load.pet)
end

-- Binding status page and components

local function DrawBindingStatusPage(container, binding)
	if binding.type ~= Addon.BindingTypes.SPELL and binding.type ~= Addon.BindingTypes.ITEM and binding.type ~= Addon.BindingTypes.MACRO then
		return
	end

	if  not Addon:CanBindingLoad(binding) then
		local widget = Addon:GUI_Label(L["Not loaded"], "medium")
		widget:SetFullWidth(true)
		container:AddChild(widget)
	else
		local function DrawStatus(group, bindings, interactionType)
			-- output self text field
			do
				local widget = AceGUI:Create("ClickedReadOnlyMultilineEditBox")
				widget:SetLabel(L["Generated local macro"])
				widget:SetText(Addon:GetMacroForBindings({ binding }, interactionType))
				widget:SetFullWidth(true)
				widget:SetNumLines(5)

				group:AddChild(widget)
			end

			-- output of full macro
			do
				local widget = AceGUI:Create("ClickedReadOnlyMultilineEditBox")
				widget:SetLabel(L["Generated full macro"])
				widget:SetText(Addon:GetMacroForBindings(bindings, interactionType))
				widget:SetFullWidth(true)
				widget:SetNumLines(8)

				group:AddChild(widget)
			end

			if #bindings > 1 then
				do
					local widget = AceGUI:Create("Heading")
					widget:SetFullWidth(true)
					widget:SetText(L["%d related binding(s)"]:format(#bindings - 1))

					group:AddChild(widget)
				end

				for _, other in ipairs(bindings) do
					if other ~= binding then
						do
							local function OnClick()
								tree:SelectByBindingOrGroup(other)
							end

							local widget = AceGUI:Create("InteractiveLabel")
							widget:SetFontObject(GameFontHighlight)
							widget:SetText(other.cache.displayName or "")
							widget:SetImage(other.cache.displayIcon or "Interface\\ICONS\\INV_Misc_QuestionMark")
							widget:SetFullWidth(true)
							widget:SetCallback("OnClick", OnClick)

							group:AddChild(widget)
						end
					end
				end
			end
		end

		if binding.targets.hovercast.enabled then
			local group = Addon:GUI_InlineGroup(L["Unit frame macro"])
			container:AddChild(group)

			local bindings = {}

			for _, other in Clicked:IterateActiveBindings() do
				if other.keybind == binding.keybind and other.targets.hovercast.enabled then
					table.insert(bindings, other)
				end
			end

			DrawStatus(group, bindings, Addon.InteractionType.HOVERCAST)
		end

		if binding.targets.regular.enabled then
			local group = Addon:GUI_InlineGroup(L["Binding macro"])
			container:AddChild(group)

			local bindings = {}

			for _, other in Clicked:IterateActiveBindings() do
				if other.keybind == binding.keybind and other.targets.regular.enabled then
					table.insert(bindings, other)
				end
			end

			DrawStatus(group, bindings, Addon.InteractionType.REGULAR)
		end
	end
end

-- Group page

local function DrawGroup(container)
	local group = GetCurrentGroup()

	local parent = Addon:GUI_InlineGroup(L["Group Name and Icon"])
	container:AddChild(parent)

	-- name text field
	do
		local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", group, "name")
		widget:SetFullWidth(true)

		parent:AddChild(widget)
	end

	-- icon field
	do
		local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", group, "displayIcon")
		widget:SetRelativeWidth(0.7)

		parent:AddChild(widget)
	end

	do
		local function OpenIconPicker()
			showIconPicker = true
			tree:Redraw()
		end

		local widget = Addon:GUI_Button(L["Select"], OpenIconPicker)
		widget:SetRelativeWidth(0.3)

		parent:AddChild(widget)
	end
end

-- Item templates

local function CreateFromItemTemplate(identifier)
	local item = nil

	if identifier == ITEM_TEMPLATE_SIMPLE_BINDING then
		item = Clicked:CreateBinding()
	elseif identifier == ITEM_TEMPLATE_CLICKCAST_BINDING then
		item = Clicked:CreateBinding()
		item.targets.hovercast.enabled = true
		item.targets.regular.enabled = false
	elseif identifier == ITEM_TEMPLATE_HEALER_BINDING then
		item = Clicked:CreateBinding()

		item.targets.hovercast.enabled = true
		item.targets.hovercast.hostility = Addon.TargetHostility.HELP

		item.targets.regular[1] = Addon:GetNewBindingTargetTemplate()
		item.targets.regular[1].unit = Addon.TargetUnits.TARGET
		item.targets.regular[1].hostility = Addon.TargetHostility.HELP

		item.targets.regular[2] = Addon:GetNewBindingTargetTemplate()
		item.targets.regular[2].unit = Addon.TargetUnits.PLAYER
	elseif identifier == ITEM_TEMPLATE_CUSTOM_MACRO then
		item = Clicked:CreateBinding()
		item.type = Addon.BindingTypes.MACRO
	elseif identifier == ITEM_TEMPLATE_GROUP then
		item = Clicked:CreateGroup()
	end

	if item ~= nil then
		Clicked:ReloadActiveBindings()
		tree:SelectByBindingOrGroup(item)
	end
end

local function DrawItemTemplate(container, identifier, name, description)
	local group = Addon:GUI_InlineGroup(name)

	container:AddChild(group)

	do
		local widget = Addon:GUI_Label(description, "medium")
		widget:SetRelativeWidth(0.79)
		group:AddChild(widget)
	end

	do
		local function OnClick()
			CreateFromItemTemplate(identifier)
		end

		local widget = Addon:GUI_Button(L["Create"], OnClick)
		widget:SetRelativeWidth(0.2)
		group:AddChild(widget)
	end
end

-- Main binding frame

local function DrawBinding(container)
	local binding = GetCurrentBinding()

	-- keybinding button
	do
		local function OnKeyChanged(frame, event, value)
			UpdateRequiredTargetModesForBinding(binding.targets, value, binding.type)
			Addon:GUI_Serialize(frame, event, value)
		end

		local widget = Addon:GUI_KeybindingButton(nil, binding, "keybind")
		widget:SetCallback("OnKeyChanged", OnKeyChanged)
		widget:SetFullWidth(true)

		RegisterTooltip(widget, L["Click and press a key to bind, or ESC to clear the binding."])

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
				DrawBindingActionPage(scrollFrame, binding, binding.cache)
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
				text = L["Action"],
				value = "action"
			},
			{
				text = L["Targets"],
				value = "target"
			},
			{
				text = L["Conditions"],
				value = "conditions"
			},
			{
				text = L["Status"],
				value = "status"
			}
		}

		local widget = Addon:GUI_TabGroup(items, OnGroupSelected)
		widget:SetStatusTable(tab)
		widget:SelectTab(tab.selected)

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
		local widget = Addon:GUI_Label(L["Create a new binding"], "large")
		scrollFrame:AddChild(widget)
	end

	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_GROUP, L["Group"], L["A group to organize multiple bindings."])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_SIMPLE_BINDING, L["Simple Binding"], L["A simple binding without any target prioritization, identical to standard action buttons."])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_CLICKCAST_BINDING, L["Clickcast Binding"], L["A binding that only activates when hovering over a unit frame."])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_HEALER_BINDING, L["Healer Binding"], L["A binding commonly used by healers, it will prioritize mouseover -> target -> player."])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_CUSTOM_MACRO, L["Custom Macro (advanced)"], L["A custom macro that can interact with other bindings and can be configured with load conditions."])

	scrollFrame:DoLayout()
end

-- Main frame

local function DrawHeader(container)
	local line = AceGUI:Create("ClickedSimpleGroup")
	line:SetWidth(325)
	line:SetLayout("Flow")

	container:AddChild(line)

	-- create binding button
	do
		local function OnClick()
			tree:SelectByValue("")
		end

		local widget = Addon:GUI_Button(NEW, OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)
	end
end

local function DrawTreeContainer(container)
	container:ReleaseChildren()

	local binding = GetCurrentBinding()
	local group = GetCurrentGroup()

	if showIconPicker then
		local data = binding ~= nil and binding.cache or group

		showIconPicker = false
		DrawIconPicker(container, data)
	else
		if binding ~= nil then
			DrawBinding(container)
		elseif group ~= nil then
			DrawGroup(container)
		else
			DrawItemTemplateSelector(container)
		end
	end
end

local function DrawTreeView(container)
	-- tree view
	do
		tree = AceGUI:Create("ClickedTreeGroup")
		tree:SetLayout("Flow")
		tree:SetFullWidth(true)
		tree:SetFullHeight(true)
		tree:SetCallback("OnGroupSelected", DrawTreeContainer)

		container:AddChild(tree)
	end
end

-- Private addon API

function Addon:BindingConfig_Initialize()
	SpellBookFrame:HookScript("OnHide", function()
		HijackSpellBookButtons(nil)
	end)

	hooksecurefunc("SpellButton_UpdateButton", HijackSpellBookButtons)

	if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
		hooksecurefunc(SpellFlyout, "Toggle", HijackSpellBookFlyoutButtons)
		hooksecurefunc("SpellFlyout_Toggle", HijackSpellBookFlyoutButtons)
	end
end

function Addon:BindingConfig_Open()
	if root ~= nil and root:IsVisible() then
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

		root = AceGUI:Create("ClickedFrame")
		root:SetCallback("OnClose", OnClose)
		root:SetTitle(L["Clicked Binding Configuration"])
		root:SetLayout("Flow")
		root:SetWidth(800)
		root:SetHeight(600)

		tab = {
			selected = "action"
		}
	end

	if InCombatLockdown() then
		Addon:NotifyCombatLockdown()
	end

	DrawHeader(root)
	DrawTreeView(root)

	Addon:BindingConfig_Redraw()
end

function Addon:BindingConfig_Redraw()
	if root == nil or not root:IsVisible() then
		return
	end

	root:SetStatusText(string.format("%s | %s", Clicked.VERSION, Addon.db:GetCurrentProfile()))
	tree:ConstructTree()
end

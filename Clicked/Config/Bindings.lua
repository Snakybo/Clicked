local AceGUI = LibStub("AceGUI-3.0")

--- @type LibTalentInfo
local LibTalentInfo = LibStub("LibTalentInfo-1.0")

--- @type ClickedInternal
local _, Addon = ...

--- @type Localization
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

local ITEM_TEMPLATE_GROUP = "GROUP"
local ITEM_TEMPLATE_SPELL = "CAST_SPELL"
local ITEM_TEMPLATE_SPELL_CC = "CAST_SPELL_CC"
local ITEM_TEMPLATE_ITEM = "USE_ITEM"
local ITEM_TEMPLATE_MACRO = "RUN_MACRO"
local ITEM_TEMPLATE_APPEND = "RUN_MACRO_APPEND"
local ITEM_TEMPLATE_TARGET = "UNIT_TARGET"
local ITEM_TEMPLATE_MENU = "UNIT_MENU"
local ITEM_TEMPLATE_IMPORT_SPELLBOOK = "IMPORT_SPELLBOOK"

local spellbookButtons = {}
local spellFlyOutButtons = {}

--- @type string[]
local iconCache

--- @type table<string|number,boolean>
local waitingForItemInfo = {}

--- @type table
local root

--- @type ClickedTreeGroup
local tree

--- @type table
local tab

-- reset on close
local didOpenSpellbook
local showIconPicker

-- Utility functions

--- @return Binding
local function GetCurrentBinding()
	local item = tree:GetSelectedItem()

	if item ~= nil then
		return item.binding
	end

	return nil
end

--- @return Group
local function GetCurrentGroup()
	local item = tree:GetSelectedItem()

	if item ~= nil then
		return item.group
	end

	return nil
end

--- @param binding Binding
--- @return boolean
local function CanEnableRegularTargetMode(binding)
	if Addon:IsRestrictedKeybind(binding.keybind) or binding.type == Addon.BindingTypes.UNIT_SELECT or binding.type == Addon.BindingTypes.UNIT_MENU then
		return false
	end

	return true
end

--- @param option Binding.TriStateLoadOption
--- @return string[]|number[]
local function GetTriStateLoadOptionValue(option)
	if option.selected == 1 then
		return { option.single }
	elseif option.selected == 2 then
		return { unpack(option.multiple) }
	end

	return nil
end

--- @param classNames string[]
--- @param specIndices integer[]
--- @return integer[]
local function GetRelevantSpecializationIds(classNames, specIndices)
	local specializationIds = {}

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

	return specializationIds
end

--- @param type '"LoadOption"'|'"TriStateLoadOption"'
--- @param selected boolean|integer
local function CreateLoadOptionTooltip(type, selected)
	local options
	local order

	if type == "LoadOption" then
		options = {
			["false"] = L["Off"],
			["true"] = L["On"]
		}

		order = { "false", "true" }
	elseif type == "TriStateLoadOption" then
		options = {
			["0"] = L["Off"],
			["1"] = L["Single"],
			["2"] = L["Multiple"]
		}

		order = { "0", "1", "2" }
	end

	selected = tostring(selected)
	options[selected] = "|cff00ff00" .. options[selected] .. "|r"

	local result = ""

	for _, v in ipairs(order) do
		if not Addon:IsStringNilOrEmpty(result) then
			result = result .. " - "
		end

		result = result .. options[v]
	end

	return result
end

--- @param binding Binding
local function GetAvailableTabs(binding)
	local items = {}
	local type = binding.type

	if type ~= Addon.BindingTypes.UNIT_SELECT and type ~= Addon.BindingTypes.UNIT_MENU then
		table.insert(items, "action")
	end

	if type ~= Addon.BindingTypes.APPEND then
		table.insert(items, "target")
	end

	table.insert(items, "load_conditions")

	if type == Addon.BindingTypes.SPELL or type == Addon.BindingTypes.ITEM or type == Addon.BindingTypes.MACRO then
		table.insert(items, "macro_conditions")
	end


	if type == Addon.BindingTypes.SPELL or type == Addon.BindingTypes.ITEM or type == Addon.BindingTypes.MACRO or type == Addon.BindingTypes.APPEND then
		if Addon:CanBindingLoad(binding) then
			table.insert(items, "status")
		end
	end

	return items
end

-- Tooltips

--- @param widget table
--- @param text string
--- @param subText string|nil
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

--- @param widget table
--- @param text string
--- @param subText string|nil
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

--- @param input string|number
--- @param mode string
--- @return string name
--- @return integer id
--- @return string subtext
local function GetSpellItemNameAndId(input, mode)
	--- @type string
	local name

	--- @type integer
	local id

	if mode == Addon.BindingTypes.SPELL then
		if type(input) == "number" then
			id = input
			name = Addon:GetSpellInfo(id)
		else
			name = input
			id = Addon:GetSpellId(name)
		end
	elseif Addon.BindingTypes.ITEM then
		if type(input) == "number" and tonumber(input) < 20 then
			name = input
		elseif type(input) == "number" then
			id = input
			name = Addon:GetItemInfo(id)
			waitingForItemInfo[input] = name == nil
		else
			name = input
			id = Addon:GetItemId(name)
			waitingForItemInfo[input] = id == nil
		end
	end

	return name, id
end

-- Spell book integration

--- @param button table
--- @param bookType string
--- @return boolean
--- @return Binding
local function IsSpellButtonBound(button, bookType)
	if button == nil then
		return false, nil
	end

	local slot = SpellBook_GetSpellBookSlot(button)

	if slot ~= nil then
		local _, _, spellId = GetSpellBookItemName(slot, bookType)

		if spellId ~= nil then
			--- @type Binding
			for _, binding in Clicked:IterateActiveBindings() do
				if binding.type == Addon.BindingTypes.SPELL and binding.action.spellValue == spellId then
					return true, binding
				end
			end
		end
	end

	return false, nil
end

local function OnSpellBookButtonClick(name, convertValueToId)
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
		binding.action.convertValueToId = convertValueToId

		HideUIPanel(SpellBookFrame)
		Clicked:ReloadActiveBindings()
	end
end

local function HijackSpellButton_UpdateButton(self)
	if didOpenSpellbook and not SpellBookFrame:IsShown() then
		GameTooltip:Hide()
		didOpenSpellbook = false
	end

	for i = 1, SPELLS_PER_PAGE do
		local parent = _G["SpellButton" .. i]
		local button = spellbookButtons[i]
		local shouldUpdate = self == nil or self == parent

		if button == nil then
			button = CreateFrame("Button", nil, parent, "ClickedSpellbookButtonTemplate")

			button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			button:SetID(parent:GetID())

			button:SetScript("OnEnter", function(_, motion)
				SpellButton_OnEnter(parent, motion)
			end)

			button:SetScript("OnLeave", function()
				SpellButton_OnLeave(parent)
			end)

			button:SetScript("OnClick", function(_, mouseButton)
				local slot = SpellBook_GetSpellBookSlot(parent);
				local name, subName = GetSpellBookItemName(slot, SpellBookFrame.bookType)

				if mouseButton ~= "RightButton" and (Addon:IsClassic() or Addon:IsBC() and not Addon:IsStringNilOrEmpty(subName)) then
					name = string.format("%s(%s)", name, subName)
				end

				OnSpellBookButtonClick(name, mouseButton ~= "RightButton")
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

	if self ~= nil and self.SpellHighlightTexture ~= nil and IsSpellButtonBound(self, SpellBookFrame.bookType) then
		self.SpellHighlightTexture:Hide()
	end
end

local function HijackSpellFlyout_Toggle()
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

				button:SetScript("OnEnter", function()
					SpellFlyoutButton_SetTooltip(parent);
				end)

				button:SetScript("OnLeave", function()
					GameTooltip:Hide();
				end)

				button:SetScript("OnClick", function()
					local name = Addon:GetSpellInfo(parent.spellID);
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

		if Addon:IsRetail() then
			iconCache = ClickedMedia:GetRetailIcons()
		elseif Addon:IsClassic() then
			iconCache = ClickedMedia:GetClassicIcons()
		elseif Addon:IsBC() then
			iconCache = ClickedMedia:GetBurningCrusadeIcons()
		end
	end

	if iconCache == nil then
		error("Unable to load icons")
	end

	table.sort(iconCache)
end

--- @param container table
--- @param data Binding.Action
--- @param key string
local function DrawIconPicker(container, data, key)
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

		local widget = Addon:GUI_Button(L["Cancel"], OnClick)
		widget:SetRelativeWidth(0.25)

		container:AddChild(widget)
	end

	do
		-- luacheck: ignore container
		local function OnIconSelected(_, _, value)
			data[key] = value
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

--- @generic T
--- @param container table
--- @param title string
--- @param items table<T,string>
--- @param order T[]
--- @param data Binding.LoadOption
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

		RegisterTooltip(widget, title, CreateLoadOptionTooltip("LoadOption", data.selected))
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

--- @generic T
--- @param container table
--- @param title string
--- @param items table<T,string>
--- @param order T[]
--- @param data Binding.NegatableStringLoadOption
local function DrawNegatableStringLoadOption(container, title, items, order, data)
	-- enabled toggle
	do
		local widget = Addon:GUI_CheckBox(title, data, "selected")

		if not data.selected then
			widget:SetRelativeWidth(1)
		else
			widget:SetRelativeWidth(0.5)
		end

		container:AddChild(widget)

		RegisterTooltip(widget, title, CreateLoadOptionTooltip("LoadOption", data.selected))
	end

	-- state and value
	if data.selected then
		do
			local widget = Addon:GUI_Dropdown(nil, items, order, nil, data, "negated")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end

		-- whitespace
		do
			local widget = Addon:GUI_Label("")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end

		do
			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", data, "value")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end
	end
end

--- @param container table
--- @param title string
--- @param data Binding.LoadOption
--- @return table enabled
--- @return table inputField
local function DrawEditFieldLoadOption(container, title, data)
	local enabled
	local inputField

	-- selected
	do
		enabled = Addon:GUI_CheckBox(title, data, "selected")

		if not data.selected then
			enabled:SetRelativeWidth(1)
		else
			enabled:SetRelativeWidth(0.5)
		end

		container:AddChild(enabled)

		RegisterTooltip(enabled, title, CreateLoadOptionTooltip("LoadOption", data.selected))
	end

	if data.selected then
		-- input
		do
			inputField = Addon:GUI_EditBox(nil, "OnEnterPressed", data, "value")
			inputField:SetRelativeWidth(0.5)

			container:AddChild(inputField)
		end
	end

	return enabled, inputField
end

--- @generic T
--- @param container table
--- @param title string
--- @param items table<T,any>
--- @param order T[]
--- @param data Binding.TriStateLoadOption
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

		RegisterTooltip(widget, title, CreateLoadOptionTooltip("TriStateLoadOption", data.selected))
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

--- @param container table
--- @param action Binding.Action
--- @param mode string
local function DrawSpellItemSelection(container, action, mode)
	local valueKey = mode == Addon.BindingTypes.SPELL and "spellValue" or "itemValue"

	-- target spell or item
	do
		local group = Addon:GUI_InlineGroup(mode == Addon.BindingTypes.SPELL and L["Target Spell"] or L["Target Item"])
		container:AddChild(group)

		local name, id = GetSpellItemNameAndId(action[valueKey], mode)

		if id ~= nil and action.convertValueToId then
			action[valueKey] = id
		end

		-- edit box
		do
			local widget = nil

			local function OnEnterPressed(_, _, value)
				if InCombatLockdown() then
					widget:SetText(name)
					widget:ClearFocus()
					return
				end

				if value == name then
					widget:ClearFocus()
					return
				end

				value = Addon:TrimString(value)

				if not Addon:IsStringNilOrEmpty(value) then
					value = tonumber(value) or value
					local _, newId = GetSpellItemNameAndId(value, mode)

					if newId ~= nil then
						value = newId
					end
				end

				action[valueKey] = value
				action.convertValueToId = true

				Clicked:ReloadActiveBindings()
			end

			local function OnTextChanged(_, _, value)
				local itemLink = string.match(value, "item[%-?%d:]+")
				local spellLink = string.match(value, "spell[%-?%d:]+")
				local talentLink = string.match(value, "talent[%-?%d:]+")
				local linkId = nil

				if not Addon:IsStringNilOrEmpty(itemLink) then
					local match = string.match(itemLink, "(%d+)")
					linkId = tonumber(match)
				elseif not Addon:IsStringNilOrEmpty(spellLink) then
					local match = string.match(spellLink, "(%d+)")
					linkId = tonumber(match)
				elseif not Addon:IsStringNilOrEmpty(talentLink) then
					local match = string.match(talentLink, "(%d+)")
					linkId = tonumber(select(6, GetTalentInfoByID(match)))
				end

				if linkId ~= nil and linkId > 0 then
					action[valueKey] = linkId

					if mode == Addon.BindingTypes.SPELL then
						value = Addon:GetSpellInfo(linkId)
					elseif mode == Addon.BindingTypes.ITEM then
						value = Addon:GetItemInfo(linkId)
					end

					widget:SetText(value)
					widget:ClearFocus()

					Clicked:ReloadActiveBindings()
				end
			end

			widget = AceGUI:Create("EditBox")
			widget:SetText(name)
			widget:SetCallback("OnEnterPressed", OnEnterPressed)
			widget:SetCallback("OnTextChanged", OnTextChanged)

			if id ~= nil then
				widget:SetRelativeWidth(0.85)
			else
				widget:SetFullWidth(true)
			end

			if mode == Addon.BindingTypes.SPELL then
				RegisterTooltip(widget, L["Target Spell"], L["Enter the spell name or spell ID."])
			else
				RegisterTooltip(widget, L["Target Item"], L["Enter an item name, item ID, or equipment slot number."] .. "\n\n" .. L["If the input field is empty you can also shift-click an item from your bags to auto-fill."])
			end

			group:AddChild(widget)
		end

		-- spell id
		if id ~= nil then
			local function OnEnter(widget)
				GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT")

				if mode == Addon.BindingTypes.SPELL then
					GameTooltip:SetSpellByID(id)
				elseif mode == Addon.BindingTypes.ITEM then
					GameTooltip:SetItemByID(id)
				end

				GameTooltip:Show()
			end

			local function OnLeave()
				GameTooltip:Hide()
			end

			local icon

			if mode == Addon.BindingTypes.SPELL then
				icon = select(3, Addon:GetSpellInfo(id))
			elseif mode == Addon.BindingTypes.ITEM then
				icon = select(10, Addon:GetItemInfo(id))
			end

			local widget = AceGUI:Create("ClickedHorizontalIcon")
			widget:SetLabel(tostring(id))
			widget:SetImage(icon)
			widget:SetImageSize(16, 16)
			widget:SetRelativeWidth(0.15)
			widget:SetCallback("OnEnter", OnEnter)
			widget:SetCallback("OnLeave", OnLeave)

			group:AddChild(widget)
		end

		if mode == Addon.BindingTypes.SPELL then
			local hasRank = id ~= nil and string.find(name, "%((.+)%)")

			-- pick from spellbook button
			do
				local function OnClick()
					if InCombatLockdown() then
						Addon:NotifyCombatLockdown()
						return
					end

					didOpenSpellbook = true

					if SpellBookFrame:IsShown() then
						HijackSpellButton_UpdateButton(nil)
					else
						ShowUIPanel(SpellBookFrame)
					end
				end

				local widget = Addon:GUI_Button(L["Pick from spellbook"], OnClick)

				if hasRank then
					widget:SetRelativeWidth(0.65)
				else
					widget:SetFullWidth(true)
				end

				local tooltip = L["Click on a spell book entry to select it."]

				if Addon:IsClassic() or Addon:IsBC() then
					tooltip = tooltip .. "\n" .. L["Right click to use the max rank."]
				end

				RegisterTooltip(widget, tooltip)

				group:AddChild(widget)
			end

			-- remove rank button
			do
				if hasRank then
					local function OnClick()
						action[valueKey] = Addon:GetSpellInfo(id, false)
						action.convertValueToId = false

						Clicked:ReloadActiveBindings()
					end

					local widget = Addon:GUI_Button(L["Remove rank"], OnClick)
					widget:SetRelativeWidth(0.35)

					group:AddChild(widget)
				end
			end
		end
	end
end

--- @param container table
--- @param targets Binding.Target[]
--- @param action Binding.Action
local function DrawMacroSelection(container, targets, action)
	-- macro name and icon
	do
		local group = Addon:GUI_InlineGroup(L["Macro Name and Icon (optional)"])
		container:AddChild(group)

		-- name text field
		do
			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", action, "macroName")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		-- icon field
		do
			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", action, "macroIcon")
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
		if targets.hovercastEnabled and not targets.regularEnabled then
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
end

--- @param container table
--- @param action Binding.Action
local function DrawAppendSelection(container, action)
	-- macro name and icon
	do
		local group = Addon:GUI_InlineGroup(L["Macro Name and Icon (optional)"])
		container:AddChild(group)

		-- name text field
		do
			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", action, "macroName")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		-- icon field
		do
			local widget = Addon:GUI_EditBox(nil, "OnEnterPressed", action, "macroIcon")
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

		-- macro text field
		do
			local widget = Addon:GUI_MultilineEditBox(nil, "OnEnterPressed", action, "macroValue")
			widget:SetFullWidth(true)
			widget:SetNumLines(8)

			group:AddChild(widget)
		end
	end
end

--- @param container table
--- @param binding Binding
local function DrawActionGroupOptions(container, binding)
	local function SortFunc(left, right)
		if left.type == Addon.BindingTypes.MACRO and right.type ~= Addon.BindingTypes.MACRO then
			return true
		end

		if left.type ~= Addon.BindingTypes.MACRO and right.type == Addon.BindingTypes.MACRO then
			return false
		end

		if left.type ~= Addon.BindingTypes.APPEND and right.type == Addon.BindingTypes.APPEND then
			return true
		end

		if left.type == Addon.BindingTypes.APPEND and right.type ~= Addon.BindingTypes.APPEND then
			return false
		end

		local leftName = Addon:GetBindingNameAndIcon(left)
		local rightName = Addon:GetBindingNameAndIcon(right)

		return leftName < rightName
	end

	local group = Addon:GUI_InlineGroup(L["Action Groups"])

	local groups = { }
	local order = {}
	local count = 0

	for _, other in Clicked:IterateActiveBindings() do
		if other.keybind == binding.keybind then
			local id = other.action.executionOrder

			if groups[id] == nil then
				groups[id] = {}
				table.insert(order, id)
			end

			table.insert(groups[id], other)
			count = count + 1
		end
	end

	for _, g in pairs(groups) do
		table.sort(g, SortFunc)
	end

	table.sort(order)

	for _, id in ipairs(order) do
		local bindings = groups[id]

		local header = AceGUI:Create("Label")
		header:SetText(string.format(L["Group %d"], id))
		header:SetFontObject(GameFontHighlight)

		group:AddChild(header)

		for _, other in ipairs(bindings) do
			local function OnClick()
				tree:SelectByBindingOrGroup(other)
			end

			local function OnMoveUp()
				if InCombatLockdown() then
					Addon:NotifyCombatLockdown()
					return
				end

				if other.action.executionOrder > 1 then
					other.action.executionOrder = other.action.executionOrder - 1
				else
					for oid, obindings in pairs(groups) do
						if oid >= id then
							for _, obinding in ipairs(obindings) do
								if obinding ~= other then
									obinding.action.executionOrder = obinding.action.executionOrder + 1
								end
							end
						end
					end
				end

				Clicked:ReloadActiveBindings()
			end

			local function OnMoveDown()
				if InCombatLockdown() then
					Addon:NotifyCombatLockdown()
					return
				end

				other.action.executionOrder = other.action.executionOrder + 1

				Clicked:ReloadActiveBindings()
			end

			local name, icon = Addon:GetBindingNameAndIcon(other)

			local widget = AceGUI:Create("ClickedReorderableLabel")
			widget:SetFontObject(GameFontHighlight)
			widget:SetText(name)
			widget:SetImage(icon)
			widget:SetFullWidth(true)
			widget:SetCallback("OnClick", OnClick)
			widget:SetCallback("OnMoveUp", OnMoveUp)
			widget:SetCallback("OnMoveDown", OnMoveDown)
			widget:SetMoveUpButton(id > 1 or #bindings > 1)

			group:AddChild(widget)
		end
	end

	if count > 1 then
		container:AddChild(group)
	end
end

--- @param container table
--- @param binding Binding
local function DrawSharedOptions(container, binding)
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
		local widget

		local function OnValueChanged(_, _, value)
			if InCombatLockdown() then
				Addon:NotifyCombatLockdown()

				if binding.action[key] then
					widget:SetValue(true)
				else
					if Addon:CanBindingLoad(binding) and IsSharedDataSet(key) then
						widget:SetValue(nil)
					else
						widget:SetValue(false)
					end
				end

				return
			end

			if value == false and isUsingShared then
				value = true
			end

			binding.action[key] = value
			Clicked:ReloadActiveBindings()
		end

		widget = AceGUI:Create("CheckBox")
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
	CreateCheckbox(group, L["Start auto attacks"], L["Allow this binding to start auto attacks, useful for any damaging abilities."], "startAutoAttack")
	CreateCheckbox(group, L["Start pet attacks"], L["Allow this binding to start pet attacks."], "startPetAttack")
	CreateCheckbox(group, L["Override queued spell"], L["Allow this binding to override a spell that is queued by the lag-tolerance system, should be reserved for high-priority spells."], "cancelQueuedSpell")
	CreateCheckbox(group, L["Target on cast"], L["Targets the unit you are casting on."], "targetUnitAfterCast")
end

--- @param container table
--- @param binding Binding
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

--- @param container table
--- @param binding Binding
local function DrawBindingActionPage(container, binding)
	local type = binding.type

	local SPELL = Addon.BindingTypes.SPELL
	local ITEM = Addon.BindingTypes.ITEM
	local MACRO = Addon.BindingTypes.MACRO
	local APPEND = Addon.BindingTypes.APPEND

	if type == SPELL or type == ITEM then
		DrawSpellItemSelection(container, binding.action, binding.type)
	elseif type == MACRO then
		DrawMacroSelection(container, binding.targets, binding.action)
	elseif type == APPEND then
		local msg = {
			L["This mode will directly append the macro text onto an automatically generated command generated by other bindings using the specified keybind. Generally, this means that it will be the last section of an '/use' command."],
			L["With this mode you're not writing a macro command. You're adding parts to an already existing command, so writing '/use Holy Light' will not work, in order to cast Holy Light simply type 'Holy Light'."]
		}

		local group = Addon:GUI_InlineGroup(nil)
		container:AddChild(group)

		local widget = Addon:GUI_Label(table.concat(msg, "\n\n"), "medium")
		widget:SetFullWidth(true)

		group:AddChild(widget)

		DrawAppendSelection(container, binding.action)
	end

	DrawActionGroupOptions(container, binding)

	if type == SPELL or type == ITEM or type == MACRO or type == APPEND then
		DrawSharedOptions(container, binding)
	end

	if type == SPELL or type == ITEM then
		DrawIntegrationsOptions(container, binding)
	end
end

-- Binding target page and components

--- @param container table
--- @param targets Binding.Target[]
--- @param enabled boolean
--- @param index integer
local function DrawTargetSelectionUnit(container, targets, enabled, index)
	local target

	local function OnValueChanged(frame, _, value)
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

--- @param container table
--- @param enabled boolean
--- @param target Binding.Target
local function DrawTargetSelectionHostility(container, enabled, target)
	local items, order = Addon:GetLocalizedTargetHostility()
	local widget = Addon:GUI_Dropdown(nil, items, order, nil, target, "hostility")
	widget:SetFullWidth(true)
	widget:SetDisabled(not enabled)

	container:AddChild(widget)
end

--- @param container table
--- @param enabled boolean
--- @param target Binding.Target
local function DrawTargetSelectionVitals(container, enabled, target)
	local items, order = Addon:GetLocalizedTargetVitals()
	local widget = Addon:GUI_Dropdown(nil, items, order, nil, target, "vitals")
	widget:SetFullWidth(true)
	widget:SetDisabled(not enabled)

	container:AddChild(widget)
end

--- @param container table
--- @param binding Binding
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
		local enabled = binding.targets.hovercastEnabled

		do
			local widget = Addon:GUI_ToggleHeading(L["Unit Frame Target"], binding.targets, "hovercastEnabled")
			container:AddChild(widget)
		end

		DrawTargetSelectionHostility(container, enabled and not isMacro, hovercast)
		DrawTargetSelectionVitals(container, enabled and not isMacro, hovercast)
	end

	-- regular targets
	do
		local regular = binding.targets.regular
		local enabled = binding.targets.regularEnabled

		do
			local widget = Addon:GUI_ToggleHeading(L["Macro Targets"], binding.targets, "regularEnabled")
			widget:SetDisabled(not CanEnableRegularTargetMode(binding))
			container:AddChild(widget)
		end

		if isMacro then
			local group = Addon:GUI_InlineGroup(L["On this target"])
			container:AddChild(group)

			DrawTargetSelectionUnit(group, regular, false, 1)
		else
			-- existing targets
			for i, target in ipairs(regular) do
				local function OnMove(_, event)
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

				if not binding.targets.hovercastEnabled and target.unit == Addon.TargetUnits.MOUSEOVER and Addon:IsMouseButton(binding.keybind) then
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

-- Binding macro conditions page and components

--- @param container table
--- @param form Binding.TriStateLoadOption
--- @param specIds integer[]
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

--- @param container table
--- @param combat Binding.LoadOption
local function DrawLoadCombat(container, combat)
	local items = {
		[true] = L["In combat"],
		[false] = L["Not in combat"]
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, L["Combat"], items, order, combat)
end

--- @param container table
--- @param pet Binding.LoadOption
local function DrawLoadPet(container, pet)
	local items = {
		[true] = L["Pet exists"],
		[false] = L["No pet"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, L["Pet"], items, order, pet)
end

--- @param container table
--- @param stealth Binding.LoadOption
local function DrawLoadStealth(container, stealth)
	local items = {
		[true] = L["In Stealth"],
		[false] = L["Not in Stealth"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, L["Stealth"], items, order, stealth)
end

--- @param container table
--- @param mounted Binding.LoadOption
local function DrawLoadMounted(container, mounted)
	local items = {
		[true] = L["Mounted"],
		[false] = L["Not mounted"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, L["Mounted"], items, order, mounted)
end

--- @param container table
--- @param flying Binding.LoadOption
local function DrawLoadFlying(container, flying)
	local items = {
		[true] = L["Flying"],
		[false] = L["Not flying"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, L["Flying"], items, order, flying)
end

--- @param container table
--- @param flyable Binding.LoadOption
local function DrawLoadFlyable(container, flyable)
	local items = {
		[true] = L["Flyable"],
		[false] = L["Not flyable"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, L["Flyable"], items, order, flyable)
end

--- @param container table
--- @param outdoors Binding.LoadOption
local function DrawLoadOutdoors(container, outdoors)
	local items = {
		[true] = L["Outdoors"],
		[false] = L["Indoors"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, L["Outdoors"], items, order, outdoors)
end

--- @param container table
--- @param swimming Binding.LoadOption
local function DrawLoadSwimming(container, swimming)
	local items = {
		[true] = L["Swimming"],
		[false] = L["Not swimming"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, L["Swimming"], items, order, swimming)
end

--- @param container table
--- @param channeling Binding.NegatableStringLoadOption
local function DrawLoadChanneling(container, channeling)
	local items = {
		[false] = L["Channeling"],
		[true] = L["Not channeling"]
	}

	local order = {
		false,
		true
	}

	DrawNegatableStringLoadOption(container, L["Channeling"], items, order, channeling)
end

--- @param container table
--- @param binding Binding
local function DrawBindingMacroConditionsPage(container, binding)
	local load = binding.load

	if Addon:IsGameVersionAtleast("RETAIL") then
		local classNames = GetTriStateLoadOptionValue(load.class)
		local specIndices = GetTriStateLoadOptionValue(load.specialization)
		local specializationIds = GetRelevantSpecializationIds(classNames, specIndices)

		DrawLoadInStance(container, load.form, specializationIds)
	end

	DrawLoadCombat(container, load.combat)
	DrawLoadPet(container, load.pet)
	DrawLoadStealth(container, load.stealth)
	DrawLoadMounted(container, load.mounted)
	DrawLoadOutdoors(container, load.outdoors)
	DrawLoadSwimming(container, load.swimming)
	DrawLoadChanneling(container, load.channeling)

	if Addon:IsGameVersionAtleast("BC") then
		DrawLoadFlying(container, load.flying)
		DrawLoadFlyable(container, load.flyable)
	end
end

-- Binding load conditions page and components

--- @param container table
--- @param load Binding.Load
local function DrawLoadNeverSelection(container, load)
	-- never load toggle
	do
		local widget = Addon:GUI_CheckBox(L["Never load"] , load, "never")
		widget:SetFullWidth(true)

		container:AddChild(widget)

		RegisterTooltip(widget, L["Never load"], CreateLoadOptionTooltip("LoadOption", load.never))
	end
end

--- @param container table
--- @param class Binding.TriStateLoadOption
local function DrawLoadClass(container, class)
	local items, order = Addon:GetLocalizedClasses()
	DrawTristateLoadOption(container, L["Class"], items, order, class)
end

--- @param container table
--- @param race Binding.TriStateLoadOption
local function DrawLoadRace(container, race)
	local items, order = Addon:GetLocalizedRaces()
	DrawTristateLoadOption(container, L["Race"], items, order, race)
end

--- @param container table
--- @param specialization Binding.TriStateLoadOption
--- @param classNames string[]
local function DrawLoadSpecialization(container, specialization, classNames)
	local items, order = Addon:GetLocalizedSpecializations(classNames)
	DrawTristateLoadOption(container, L["Talent specialization"], items, order, specialization)
end

--- @param container table
--- @param talent Binding.TriStateLoadOption
--- @param specIds integer[]
local function DrawLoadTalent(container, talent, specIds)
	local items, order = Addon:GetLocalizedTalents(specIds)
	DrawTristateLoadOption(container, L["Talent selected"], items, order, talent)
end

--- @param container table
--- @param talent Binding.TriStateLoadOption
--- @param specIds integer[]
local function DrawLoadPvPTalent(container, talent, specIds)
	local items, order = Addon:GetLocalizedPvPTalents(specIds)
	DrawTristateLoadOption(container, L["PvP talent selected"], items, order, talent)
end

--- @param container table
--- @param warMode Binding.LoadOption
local function DrawLoadWarMode(container, warMode)
	local items = {
		[true] = L["War Mode enabled"],
		[false] = L["War Mode disabled"]
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, L["War Mode"], items, order, warMode)
end

--- @param container table
--- @param playerNameRealm Binding.LoadOption
local function DrawLoadPlayerNameRealm(container, playerNameRealm)
	DrawEditFieldLoadOption(container, L["Player Name-Realm"], playerNameRealm)
end

--- @param container table
--- @param spellKnown Binding.LoadOption
local function DrawLoadSpellKnown(container, spellKnown)
	DrawEditFieldLoadOption(container, L["Spell known"], spellKnown)
end

--- @param container table
--- @param inGroup Binding.LoadOption
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

--- @param container table
--- @param playerInGroup Binding.LoadOption
local function DrawLoadPlayerInGroup(container, playerInGroup)
	DrawEditFieldLoadOption(container, L["Player in group"], playerInGroup)
end

--- @param container table
--- @param covenant Binding.TriStateLoadOption
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

--- @param container table
--- @param instanceType Binding.TriStateLoadOption
local function DrawLoadInInstanceType(container, instanceType)
	local items = {}
	local order

	if Addon:IsGameVersionAtleast("CLASSIC") then
		items["NONE"] = L["No Instance"]
		items["PARTY"] = L["Dungeon"]
		items["RAID"] = L["Raid"]
	end

	if Addon:IsGameVersionAtleast("BC") then
		items["PVP"] = L["Battleground"]
		items["ARENA"] = L["Arena"]
	end

	if Addon:IsGameVersionAtleast("RETAIL") then
		items["SCENARIO"] = L["Scenario"]
	end

	if Addon:IsClassic() then
		order = {
			"NONE",
			"PARTY",
			"RAID"
		}
	elseif Addon:IsBC() then
		order = {
			"NONE",
			"PARTY",
			"RAID",
			"PVP",
			"ARENA"
		}
	elseif Addon:IsRetail() then
		order = {
			"NONE",
			"SCENARIO",
			"PARTY",
			"RAID",
			"PVP",
			"ARENA"
		}
	end

	DrawTristateLoadOption(container, L["Instance type"], items, order, instanceType)
end

--- @param container table
--- @param zoneName Binding.LoadOption
local function DrawLoadZoneName(container, zoneName)
	local _, inputField = DrawEditFieldLoadOption(container, L["Zone name(s)"], zoneName)

	if inputField ~= nil then
		local tips = {
			string.format(L["Semicolon separated, use an exclamation mark (%s) to negate a zone condition, for example:"], "|r!|cffffffff"),
			"\n",
			string.format(L["%s will be active if you're not in Oribos"], "|r!" .. L["Oribos"] .. "|cffffffff"),
			string.format(L["%s will be active if you're in Durotar or Orgrimmar"], "|r" .. L["Durotar"] .. ";" .. L["Orgrimmar"] .. "|cffffffff")
		}

		RegisterTooltip(inputField, L["Zone name(s)"],  table.concat(tips, "\n"))
	end
end

--- @param container table
--- @param equipped Binding.LoadOption
local function DrawLoadItemEquipped(container, equipped)
	local _, inputField = DrawEditFieldLoadOption(container, L["Item equipped"], equipped)

	if inputField ~= nil then
		local function OnTextChanged(_, _, value)
			local itemLink = string.match(value, "item[%-?%d:]+")
			local linkId = nil

			if not Addon:IsStringNilOrEmpty(itemLink) then
				local match = string.match(itemLink, "(%d+)")
				linkId = tonumber(match)
			end

			if linkId ~= nil and linkId > 0 then
				equipped.value = Addon:GetItemInfo(linkId)

				inputField:SetText(equipped.value)
				inputField:ClearFocus()

				Clicked:ReloadActiveBindings()
			end
		end

		inputField:SetCallback("OnTextChanged", OnTextChanged)

		RegisterTooltip(inputField, L["This will not update when in combat, so swapping weapons or shields during combat does not work."])
	end
end

--- @param container table
--- @param binding Binding
local function DrawBindingLoadConditionsPage(container, binding)
	local load = binding.load

	DrawLoadNeverSelection(container, load)
	DrawLoadPlayerNameRealm(container, load.playerNameRealm)
	DrawLoadClass(container, load.class)
	DrawLoadRace(container, load.race)

	if Addon:IsGameVersionAtleast("RETAIL") then
		local classNames = GetTriStateLoadOptionValue(load.class)
		local specIndices = GetTriStateLoadOptionValue(load.specialization)
		local specializationIds = GetRelevantSpecializationIds(classNames, specIndices)

		DrawLoadSpecialization(container, load.specialization, classNames)
		DrawLoadTalent(container, load.talent, specializationIds)
		DrawLoadPvPTalent(container, load.pvpTalent, specializationIds)
		DrawLoadWarMode(container, load.warMode)
		DrawLoadInCovenant(container, load.covenant)
	end

	DrawLoadInInstanceType(container, load.instanceType)
	DrawLoadZoneName(container, load.zoneName)
	DrawLoadSpellKnown(container, load.spellKnown)
	DrawLoadInGroup(container, load.inGroup)
	DrawLoadPlayerInGroup(container, load.playerInGroup)
	DrawLoadItemEquipped(container, load.equipped)
end

-- Binding status page and components

--- @param container table
--- @param binding Binding
local function DrawBindingStatusPage(container, binding)
	local function DrawStatus(group, bindings, interactionType)
		if #bindings == 0 then
			return
		end

		-- output of full macro
		do
			local widget = AceGUI:Create("ClickedReadOnlyMultilineEditBox")

			if interactionType == Addon.InteractionType.HOVERCAST then
				widget:SetLabel(L["Generated hovercast macro"])
			else
				widget:SetLabel(L["Generated macro"])
			end

			widget:SetText(Addon:GetMacroForBindings(bindings, interactionType))
			widget:SetFullWidth(true)
			widget:SetNumLines(8)

			group:AddChild(widget)
		end
	end

	local hovercast = {}
	local regular = {}
	local all = {}

	for _, other in Clicked:IterateActiveBindings() do
		if other.keybind == binding.keybind then
			local valid = false

			if binding.targets.hovercastEnabled and other.targets.hovercastEnabled then
				table.insert(hovercast, other)
				valid = true
			end

			if binding.targets.regularEnabled and other.targets.regularEnabled then
				table.insert(regular, other)
				valid = true
			end

			if valid then
				table.insert(all, other)
			end
		end
	end

	DrawStatus(container, hovercast, Addon.InteractionType.HOVERCAST)
	DrawStatus(container, regular, Addon.InteractionType.REGULAR)

	if #all > 1 then
		do
			local widget = AceGUI:Create("Heading")
			widget:SetFullWidth(true)
			widget:SetText(L["%d related binding(s)"]:format(#all - 1))

			container:AddChild(widget)
		end

		for _, other in ipairs(all) do
			if other ~= binding then
				do
					local function OnClick()
						tree:SelectByBindingOrGroup(other)
					end

					local name, icon = Addon:GetBindingNameAndIcon(other)

					local widget = AceGUI:Create("InteractiveLabel")
					widget:SetFontObject(GameFontHighlight)
					widget:SetText(name)
					widget:SetImage(icon)
					widget:SetFullWidth(true)
					widget:SetCallback("OnClick", OnClick)

					container:AddChild(widget)
				end
			end
		end
	end
end

-- Group page

--- @param container table
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

--- @param identifier string
local function CreateFromItemTemplate(identifier)
	local item = nil

	if identifier == ITEM_TEMPLATE_SPELL then
		item = Clicked:CreateBinding()
		item.type = Addon.BindingTypes.SPELL
	elseif identifier == ITEM_TEMPLATE_SPELL_CC then
		item = Clicked:CreateBinding()
		item.type = Addon.BindingTypes.SPELL
		item.targets.hovercastEnabled = true
		item.targets.regularEnabled = false
	elseif identifier == ITEM_TEMPLATE_ITEM then
		item = Clicked:CreateBinding()
		item.type = Addon.BindingTypes.ITEM
	elseif identifier == ITEM_TEMPLATE_MACRO then
		item = Clicked:CreateBinding()
		item.type = Addon.BindingTypes.MACRO
	elseif identifier == ITEM_TEMPLATE_APPEND then
		item = Clicked:CreateBinding()
		item.type = Addon.BindingTypes.APPEND
	elseif identifier == ITEM_TEMPLATE_TARGET then
		item = Clicked:CreateBinding()
		item.type = Addon.BindingTypes.UNIT_SELECT
	elseif identifier == ITEM_TEMPLATE_MENU then
		item = Clicked:CreateBinding()
		item.type = Addon.BindingTypes.UNIT_MENU
	elseif identifier == ITEM_TEMPLATE_GROUP then
		item = Clicked:CreateGroup()
	elseif identifier == ITEM_TEMPLATE_IMPORT_SPELLBOOK then
		for tabIndex = 2, GetNumSpellTabs() do
			local tabName, tabIcon, offset, count, _, specId = GetSpellTabInfo(tabIndex)
			local pendingSpellIds = {}
			local specIndex = nil

			local function RegisterSpell(spellId)
				if IsPassiveSpell(spellId) then
					return {}
				end

				--- @type Binding
				for _, binding in Clicked:IterateConfiguredBindings() do
					if binding.type == Addon.BindingTypes.SPELL and binding.action.spellValue == spellId and binding.parent ~= nil then
						local group = Clicked:GetGroupById(binding.parent)

						-- this spell already exists in the database, however we also want to make sure its in one of the auto-generated groups
						-- before excluding it
						if group.name == tabName and group.displayIcon == tabIcon then
							return {}
						end
					end
				end

				if pendingSpellIds[spellId] == nil then
					pendingSpellIds[spellId] = {
						talentTier = nil,
						talentColumn = nil,
						pvpTalentIndex = nil
					}
				end

				return pendingSpellIds[spellId]
			end

			-- Get spec index from ID
			if Addon:IsGameVersionAtleast("RETAIL") and tabIndex > 2 then
				if specId == 0 then
					specIndex = GetSpecialization()
					specId = GetSpecializationInfo(specIndex)
				else
					for index = 1, GetNumSpecializations() do
						local id = GetSpecializationInfo(index)

						if id == specId then
							specIndex = index
							break
						end
					end
				end
			end

			-- Spellbook items
			for spellBookItemIndex = offset + 1, offset + count do
				local type = GetSpellBookItemInfo(spellBookItemIndex, BOOKTYPE_SPELL)

				if type == "SPELL" or type == "FUTURESPELL" then
					local _, _, spellId = GetSpellBookItemName(spellBookItemIndex, BOOKTYPE_SPELL)
					RegisterSpell(spellId)
				end
			end

			if Addon:IsGameVersionAtleast("RETAIL") and specId > 0 then
				-- Talents
				for tier = 1, MAX_TALENT_TIERS do
					for column = 1, NUM_TALENT_COLUMNS do
						local _, _, _, _, _, spellId = LibTalentInfo:GetTalentInfo(specId, tier, column)

						local data = RegisterSpell(spellId)
						data.talentTier = tier
						data.talentColumn = column
					end
				end

				-- PvP talents
				for index = 1, LibTalentInfo:GetNumPvPTalentsForSpec(specId, 1) do
					local _, _, _, _, _, spellId = LibTalentInfo:GetPvPTalentInfo(specId, 1, index)

					local data = RegisterSpell(spellId)
					data.pvpTalentIndex = index
				end
			end

			if next(pendingSpellIds) ~= nil then
				local group = nil

				--- @type Group
				for _, g in Clicked:IterateGroups() do
					if g.name == tabName and g.displayIcon == tabIcon then
						group = g
						break
					end
				end

				if group == nil then
					group = Clicked:CreateGroup()
					group.name = tabName
					group.displayIcon = tabIcon
				end

				for spellId, data in pairs(pendingSpellIds) do
					local binding = Clicked:CreateBinding()
					binding.type = Addon.BindingTypes.SPELL
					binding.parent = group.identifier
					binding.action.spellValue = spellId

					if specIndex ~= nil then
						binding.load.specialization.selected = 1
						binding.load.specialization.single = specIndex
					end

					if data.talentTier ~= nil and data.talentColumn ~= nil then
						binding.load.talent.selected = 1
						binding.load.talent.single = (data.talentTier - 1) * NUM_TALENT_COLUMNS + data.talentColumn
					end

					if data.pvpTalentIndex ~= nil then
						binding.load.pvpTalent.selected = 1
						binding.load.pvpTalent.single = data.pvpTalentIndex
					end
				end
			end
		end

		Clicked:ReloadActiveBindings()
	end

	if item ~= nil then
		Clicked:ReloadActiveBindings()
		tree:SelectByBindingOrGroup(item)
	end
end

--- @param container table
--- @param identifier string
--- @param name string
local function DrawItemTemplate(container, identifier, name)
	do
		local widget = Addon:GUI_Label(name, "medium")
		widget:SetRelativeWidth(0.79)

		container:AddChild(widget)
	end

	do
		local function OnClick()
			CreateFromItemTemplate(identifier)
		end

		local widget = Addon:GUI_Button(L["Create"], OnClick)
		widget:SetRelativeWidth(0.2)

		container:AddChild(widget)
	end
end

-- Main binding frame

--- @param container table
local function DrawBinding(container)
	local binding = GetCurrentBinding()

	-- keybinding button
	do
		local function OnKeyChanged(frame, event, value)
			Addon:EnsureSupportedTargetModes(binding.targets, value, binding.type)
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
		local function OnGroupSelected(container, _, group)
			local scrollFrame = AceGUI:Create("ScrollFrame")
			scrollFrame:SetLayout("Flow")

			container:AddChild(scrollFrame)

			if group == "action" then
				DrawBindingActionPage(scrollFrame, binding)
			elseif group == "target" then
				DrawBindingTargetPage(scrollFrame, binding)
			elseif group == "macro_conditions" then
				DrawBindingMacroConditionsPage(scrollFrame, binding)
			elseif group == "load_conditions" then
				DrawBindingLoadConditionsPage(scrollFrame, binding)
			elseif group == "status" then
				DrawBindingStatusPage(scrollFrame, binding)
			end

			scrollFrame:DoLayout()
		end

		--- @param availableTabs string[]
		local function CreateTabGroup(availableTabs)
			local items = {}

			for i, availableTab in ipairs(availableTabs) do
				local text = nil

				if availableTab == "action" then
					text = L["Action"]
				elseif availableTab == "target" then
					text = L["Targets"]
				elseif availableTab == "load_conditions" then
					text = L["Load conditions"]
				elseif availableTab == "macro_conditions" then
					text = L["Macro conditions"]
				elseif availableTab == "status" then
					text = L["Status"]
				end

				if text ~= nil then
					items[i] = {
						text = text,
						value = availableTab
					}
				end
			end

			return items
		end

		local availableTabs = GetAvailableTabs(binding)
		local hasSelectedTab = false

		for _, availableTab in ipairs(availableTabs) do
			if availableTab == tab.selected then
				hasSelectedTab = true
				break
			end
		end

		if not hasSelectedTab then
			tab.selected = availableTabs[1]
		end

		tab.widget = Addon:GUI_TabGroup(CreateTabGroup(availableTabs), OnGroupSelected)
		tab.widget:SetStatusTable(tab)
		tab.widget:SelectTab(tab.selected)

		container:AddChild(tab.widget)
	end
end

--- @param container table
local function DrawItemTemplateSelector(container)
	local scrollFrame = AceGUI:Create("ScrollFrame")
	scrollFrame:SetLayout("Flow")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)

	container:AddChild(scrollFrame)

	do
		local widget = Addon:GUI_Label(L["Quick start"], "large")
		widget:SetFullWidth(true)

		scrollFrame:AddChild(widget)
	end

	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_IMPORT_SPELLBOOK, L["Automatically import from spellbook"])

	do
		local widget = Addon:GUI_Label("\n" .. L["Create a new binding"], "large")
		widget:SetFullWidth(true)

		scrollFrame:AddChild(widget)
	end

	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_GROUP, L["Group"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_SPELL, L["Cast a spell"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_SPELL_CC, L["Cast a spell on a unit frame"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_ITEM, L["Use an item"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_TARGET, L["Target the unit"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_MENU, L["Open the unit menu"])

	do
		local widget = Addon:GUI_Label("\n" .. L["Advanced binding types"], "large")
		widget:SetFullWidth(true)

		scrollFrame:AddChild(widget)
	end

	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_MACRO, L["Run a macro"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_APPEND, L["Append a binding segment"])

	scrollFrame:DoLayout()
end

-- Main frame

--- @param container table
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

		local widget = Addon:GUI_Button(L["New"], OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)
	end
end

--- @param container table
local function DrawTreeContainer(container)
	local binding = GetCurrentBinding()
	local group = GetCurrentGroup()

	container:ReleaseChildren()

	if showIconPicker then
		local data = binding ~= nil and binding.action or group
		local key = binding ~= nil and "macroIcon" or "displayIcon"

		showIconPicker = false
		DrawIconPicker(container, data, key)
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

--- @param container table
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
		HijackSpellButton_UpdateButton(nil)
	end)

	hooksecurefunc("SpellButton_UpdateButton", HijackSpellButton_UpdateButton)

	if Addon:IsGameVersionAtleast("RETAIL") then
		hooksecurefunc(SpellFlyout, "Toggle", HijackSpellFlyout_Toggle)
		hooksecurefunc("SpellFlyout_Toggle", HijackSpellFlyout_Toggle)
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

		local function OnReceiveDrag()
			local infoType, info1, info2 = GetCursorInfo()
			local bindingType = nil

			if infoType == "item" then
				bindingType = Addon.BindingTypes.ITEM
			elseif infoType == "spell" then
				bindingType = Addon.BindingTypes.SPELL
				info1 = select(3, GetSpellBookItemName(info1, info2))
			elseif infoType == "petaction" then
				bindingType = Addon.BindingTypes.SPELL
			end

			if bindingType ~= nil then
				local binding = Clicked:CreateBinding()
				binding.type = bindingType
				Addon:SetBindingValue(binding, info1)

				Clicked:ReloadActiveBindings()
				tree:SelectByBindingOrGroup(binding)

				ClearCursor()
			end
		end

		root = AceGUI:Create("ClickedFrame")
		root:SetCallback("OnClose", OnClose)
		root:SetCallback("OnReceiveDrag", OnReceiveDrag)
		root:SetTitle(L["Clicked Binding Configuration"])
		root:SetLayout("Flow")
		root:SetWidth(900)
		root:SetHeight(600)

		tab = {
			selected = "action"
		}
	end

	if InCombatLockdown() then
		Addon:NotifyCombatLockdown()
	end

	wipe(waitingForItemInfo)

	DrawHeader(root)
	DrawTreeView(root)

	Addon:BindingConfig_Redraw()
end

--- @param itemId number
--- @param success boolean
function Addon:BindingConfig_ItemInfoReceived(itemId, success)
	if success == true then
		for item in pairs(waitingForItemInfo) do
			if tonumber(item) == itemId or item == Addon:GetItemInfo(itemId) then
				waitingForItemInfo[item] = nil
				self:BindingConfig_Redraw()
				break
			end
		end
	elseif success == nil then
		-- if the item doesn't exist, just delete it from the queue if it's present
		waitingForItemInfo[itemId] = nil
	end
end

function Addon:BindingConfig_Redraw()
	if root == nil or not root:IsVisible() then
		return
	end

	if not InCombatLockdown() and SpellBookFrame:IsShown() and SpellBookFrame.bookType == BOOKTYPE_SPELL then
		SpellBookFrame_UpdateSpells()
	end

	root:SetStatusText(string.format("%s | %s", Clicked.VERSION, Addon.db:GetCurrentProfile()))
	tree:ConstructTree()
end

-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2022  Kevin Krol
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

local AceGUI = LibStub("AceGUI-3.0")
local LibTalentInfo = LibStub("LibTalentInfo-1.0")
local LibTalentInfoClassic = LibStub("LibTalentInfoClassic-1.0")
local LibMacroSyntaxHighlight = LibStub("LibMacroSyntaxHighlight-1.0")

--- @class ClickedInternal
local Addon = select(2, ...)

local ITEM_TEMPLATE_GROUP = "GROUP"
local ITEM_TEMPLATE_SPELL = "CAST_SPELL"
local ITEM_TEMPLATE_SPELL_CC = "CAST_SPELL_CC"
local ITEM_TEMPLATE_ITEM = "USE_ITEM"
local ITEM_TEMPLATE_MACRO = "RUN_MACRO"
local ITEM_TEMPLATE_APPEND = "RUN_MACRO_APPEND"
local ITEM_TEMPLATE_CANCELAURA = "CANCELAURA"
local ITEM_TEMPLATE_TARGET = "UNIT_TARGET"
local ITEM_TEMPLATE_MENU = "UNIT_MENU"
local ITEM_TEMPLATE_IMPORT_SPELLBOOK = "IMPORT_SPELLBOOK"
local ITEM_TEMPLATE_IMPORT_ACTIONBAR = "IMPORT_ACTIONBAR"

--- @type table<integer,string>
local iconCache

--- @type integer[]
local iconCacheOrder

--- @type table<string|number,boolean>
local waitingForItemInfo = {}

--- @type ClickedFrame
local root

--- @type ClickedTreeGroup
local tree

--- @type AceGUITabGroupTab
local tab

-- reset on close

--- @type Binding?
local prevBinding

--- @type boolean
local showIconPicker

--- @type "talents"|"pvp_talents"?
local showTalentPanel

-- Utility functions

--- @return Binding?
local function GetCurrentBinding()
	local item = tree:GetSelectedItem()

	if item ~= nil and item.type == "binding" then
		--- @cast item ClickedTreeGroupBindingItem
		return item.binding
	end

	return nil
end

--- @return Group?
local function GetCurrentGroup()
	local item = tree:GetSelectedItem()

	if item ~= nil and item.type == "group" then
		--- @cast item ClickedTreeGroupGroupItem
		return item.group
	end

	return nil
end

--- @param binding Binding
--- @return boolean
local function CanEnableRegularTargetMode(binding)
	if Addon:IsRestrictedKeybind(binding.keybind) or binding.actionType == Addon.BindingTypes.UNIT_SELECT or binding.actionType == Addon.BindingTypes.UNIT_MENU then
		return false
	end

	return true
end

--- @generic T
--- @param option Binding.TriStateLoadOption
--- @return T[]?
local function GetTriStateLoadOptionValue(option)
	if option.selected == 1 then
		return { option.single }
	elseif option.selected == 2 then
		return { unpack(option.multiple) }
	end

	return nil
end

--- @param classNames? string[]
--- @param specIndices? integer[]
--- @return integer[]
local function GetRelevantSpecializationIds(classNames, specIndices)
	if Addon:IsGameVersionAtleast("RETAIL") then
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
	else
		local specializationIds = {}

		if specIndices == nil then
			specIndices = {}
			if classNames == nil or #classNames == 1 and classNames[1] == select(2, UnitClass("player")) then
				specIndices[1] = GetPrimaryTalentTree()
			else
				for _, class in ipairs(classNames) do
					local specs = LibTalentInfoClassic:GetClassSpecializations(class)

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
			local specs = LibTalentInfoClassic:GetClassSpecializations(class)

			for j = 1, #specIndices do
				local specIndex = specIndices[j]
				local spec = specs[specIndex]

				table.insert(specializationIds, spec.id)
			end
		end

		return specializationIds
	end
end

--- @param type '"LoadOption"'|'"TriStateLoadOption"'
--- @param selected boolean|integer
local function CreateLoadOptionTooltip(type, selected)
	local options
	local order

	if type == "LoadOption" then
		options = {
			["false"] = Addon.L["Off"],
			["true"] = Addon.L["On"]
		}

		order = { "false", "true" }
	elseif type == "TriStateLoadOption" then
		options = {
			["0"] = Addon.L["Off"],
			["1"] = Addon.L["Single"],
			["2"] = Addon.L["Multiple"]
		}

		order = { "0", "1", "2" }
	end

	local selectedStr = tostring(selected)
	options[selectedStr] = "|cff00ff00" .. options[selectedStr] .. "|r"

	local result = ""

	for _, v in ipairs(order) do
		if not Addon:IsNilOrEmpty(result) then
			result = result .. " - "
		end

		result = result .. options[v]
	end

	return result
end

--- @param binding Binding
local function GetAvailableTabs(binding)
	local items = {}
	local type = binding.actionType

	if type ~= Addon.BindingTypes.UNIT_SELECT and type ~= Addon.BindingTypes.UNIT_MENU then
		table.insert(items, "action")
	end

	if type ~= Addon.BindingTypes.APPEND and type ~= Addon.BindingTypes.CANCELAURA then
		table.insert(items, "target")
	end

	table.insert(items, "load_conditions")

	if type ~= Addon.BindingTypes.MACRO then
		table.insert(items, "macro_conditions")
	end

	if type == Addon.BindingTypes.SPELL or
	   type == Addon.BindingTypes.ITEM or
	   type == Addon.BindingTypes.MACRO or
	   type == Addon.BindingTypes.APPEND or
	   type == Addon.BindingTypes.CANCELAURA then
		if Clicked:IsBindingLoaded(binding) then
			table.insert(items, "status")
		end
	end

	return items
end

-- Tooltips

--- @param widget table
--- @param text string
--- @param subText string|nil
local function RegisterTooltip(widget, text, subText)
	local function OnEnter()
		Addon:ShowTooltip(widget.frame, text, subText)
	end

	local function OnLeave()
		Addon:HideTooltip()
	end

	widget:SetCallback("OnEnter", OnEnter)
	widget:SetCallback("OnLeave", OnLeave)
end

--- @param input string|number
--- @param mode string
--- @param addSubText boolean
--- @return string|integer? name
--- @return integer? id
local function GetSpellItemNameAndId(input, mode, addSubText)
	--- @type string|integer
	local name

	--- @type integer?
	local id

	if mode == Addon.BindingTypes.SPELL then
		if type(input) == "number" then
			local spell = Addon:GetSpellInfo(input, addSubText)

			id = input
			name = spell ~= nil and spell.name or nil
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

-- Icon picker

local function EnsureIconCache()
	local addon = "ClickedMedia"

	if iconCache == nil then
		if not C_AddOns.IsAddOnLoaded(addon) then
			local loaded, reason = C_AddOns.LoadAddOn(addon)

			if not loaded then
				if reason == "DISABLED" then
					C_AddOns.EnableAddOn(addon)
					C_AddOns.LoadAddOn(addon)
				else
					error("Unable to load " .. addon ": " .. reason)
				end
			end
		end

		iconCache, iconCacheOrder = ClickedMedia:GetIcons()
	end

	if iconCache == nil then
		error("Unable to load icons")
	end
end

--- @param container AceGUIContainer
--- @param data Binding.Action
--- @param key string
local function DrawIconPicker(container, data, key)
	EnsureIconCache()

	local searchBox

	do
		local widget = AceGUI:Create("ClickedSearchBox") --[[@as ClickedSearchBox]]
		widget:DisableButton(true)
		widget:SetPlaceholderText(Addon.L["Search..."])
		widget:SetRelativeWidth(0.75)
		searchBox = widget

		container:AddChild(widget)
	end

	do
		local function OnClick()
			tree:Redraw()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Cancel"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.25)

		container:AddChild(widget)
	end

	do
		local function OnIconSelected(_, _, value)
			data[key] = value
			Addon:BindingConfig_Redraw()
		end

		local scrollFrame = AceGUI:Create("ClickedIconSelectorList") --[[@as ClickedIconSelectorList]]
		scrollFrame:SetLayout("Flow")
		scrollFrame:SetFullWidth(true)
		scrollFrame:SetFullHeight(true)
		scrollFrame:SetIcons(iconCache, iconCacheOrder)
		scrollFrame:SetSearchHandler(searchBox)
		scrollFrame:SetCallback("OnIconSelected", OnIconSelected)

		container:AddChild(scrollFrame)
	end
end

-- Common draw functions

--- @generic T
--- @param container AceGUIContainer
--- @param title string
--- @param items table<T,string>
--- @param order T[]
--- @param data Binding.LoadOption
--- @return AceGUICheckBox
--- @return AceGUIDropdown?
local function DrawDropdownLoadOption(container, title, items, order, data)
	local enabledWidget
	local dropdownWidget

	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	-- enabled toggle
	do
		enabledWidget = Addon:GUI_CheckBox(data, "selected", binding)
		enabledWidget:SetLabel(title)

		if not data.selected then
			enabledWidget:SetRelativeWidth(1)
		else
			enabledWidget:SetRelativeWidth(0.5)
		end

		container:AddChild(enabledWidget)

		RegisterTooltip(enabledWidget, title, CreateLoadOptionTooltip("LoadOption", data.selected))
	end

	-- state
	if data.selected then
		do
			dropdownWidget = Addon:GUI_Dropdown(items, order, data, "value", binding)
			dropdownWidget:SetRelativeWidth(0.5)

			container:AddChild(dropdownWidget)
		end
	end

	return enabledWidget, dropdownWidget
end

--- @generic T
--- @param container AceGUIContainer
--- @param title string
--- @param items table<T,string>
--- @param order T[]
--- @param data Binding.NegatableStringLoadOption
--- @return AceGUICheckBox
--- @return AceGUIDropdown?
--- @return AceGUIEditBox?
local function DrawNegatableStringLoadOption(container, title, items, order, data)
	local enabledWidget
	local dropdownWidget
	local editBoxWidget

	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	-- enabled toggle
	do
		enabledWidget = Addon:GUI_CheckBox(data, "selected", binding)
		enabledWidget:SetLabel(title)

		if not data.selected then
			enabledWidget:SetRelativeWidth(1)
		else
			enabledWidget:SetRelativeWidth(0.5)
		end

		container:AddChild(enabledWidget)

		RegisterTooltip(enabledWidget, title, CreateLoadOptionTooltip("LoadOption", data.selected))
	end

	-- state and value
	if data.selected then
		do
			dropdownWidget = Addon:GUI_Dropdown(items, order, data, "negated", binding)
			dropdownWidget:SetRelativeWidth(0.5)

			container:AddChild(dropdownWidget)
		end

		-- whitespace
		do
			local widget = Addon:GUI_Label("")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end

		do
			editBoxWidget = Addon:GUI_EditBox("OnEnterPressed", data, "value", binding)
			editBoxWidget:SetRelativeWidth(0.5)

			container:AddChild(editBoxWidget)
		end
	end

	return enabledWidget, dropdownWidget, editBoxWidget
end

--- @param container AceGUIContainer
--- @param title string
--- @param data Binding.LoadOption
--- @return AceGUICheckBox
--- @return AceGUIEditBox?
local function DrawEditFieldLoadOption(container, title, data)
	local enabledWidget
	local editBoxWidget

	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	-- selected
	do
		enabledWidget = Addon:GUI_CheckBox(data, "selected", binding)
		enabledWidget:SetLabel(title)

		if not data.selected then
			enabledWidget:SetRelativeWidth(1)
		else
			enabledWidget:SetRelativeWidth(0.5)
		end

		container:AddChild(enabledWidget)

		RegisterTooltip(enabledWidget, title, CreateLoadOptionTooltip("LoadOption", data.selected))
	end

	if data.selected then
		-- input
		do
			editBoxWidget = Addon:GUI_EditBox("OnEnterPressed", data, "value", binding)
			editBoxWidget:SetRelativeWidth(0.5)

			container:AddChild(editBoxWidget)
		end
	end

	return enabledWidget, editBoxWidget
end

--- @generic T
--- @param container AceGUIContainer
--- @param title string
--- @param items table<T,any>
--- @param order T[]
--- @param data Binding.TriStateLoadOption
--- @return AceGUICheckBox
--- @return AceGUIDropdown?
local function DrawTristateLoadOption(container, title, items, order, data)
	assert(type(data) == "table", "bad argument #5, expected table but got " .. type(data))

	local enabledWidget
	local dropdownWidget

	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	-- enabled toggle
	do
		enabledWidget = Addon:GUI_TristateCheckBox(data, "selected", binding)
		enabledWidget:SetLabel(title)
		enabledWidget:SetTriState(true)

		if data.selected == 0 then
			enabledWidget:SetRelativeWidth(1)
		else
			enabledWidget:SetRelativeWidth(0.5)
		end

		container:AddChild(enabledWidget)

		RegisterTooltip(enabledWidget, title, CreateLoadOptionTooltip("TriStateLoadOption", data.selected))
	end

	if data.selected == 1 then -- single option variant
		dropdownWidget = Addon:GUI_Dropdown(items, order, data, "single", binding)
	elseif data.selected == 2 then -- multiple option variant
		--- @param widget AceGUIDropdown
		local function UpdateText(widget)
			local selected = {}

			for _, item in widget.pullout:IterateItems() do
				if item.type == "Dropdown-Item-Toggle" then
					if item:GetValue() then
						table.insert(selected, item:GetText())
					end
				end
			end

			if #selected == 0 then
				widget:SetText(Addon.L["Nothing"])
			elseif #selected == 1 then
				widget:SetText(selected[1])
			elseif #selected == #items then
				widget:SetText(Addon.L["Everything"])
			else
				widget:SetText(Addon.L["Mixed..."])
			end

		end

		dropdownWidget = Addon:GUI_MultiselectDropdown(items, order, data, "multiple", binding)
		UpdateText(dropdownWidget)

		for _, item in dropdownWidget.pullout:IterateItems() do
			if item.type == "Dropdown-Item-Toggle" then
				item:SetCallback("OnValueChanged", function()
					UpdateText(dropdownWidget)
				end)
			end
		end
	end

	if dropdownWidget ~= nil then
		dropdownWidget:SetRelativeWidth(0.5)
		container:AddChild(dropdownWidget)
	end

	return enabledWidget, dropdownWidget
end

--- @generic T
--- @param container AceGUIContainer
--- @param title string
--- @param items table<T,any>
--- @param order T[]
--- @param data Binding.TriStateLoadOption
--- @return AceGUICheckBox
--- @return AceGUIDropdown?
--- @return AceGUICheckBox?
local function DrawNegatableTristateLoadOption(container, title, items, order, data)
	local enabledWidget, dropdownWidget = DrawTristateLoadOption(container, title, items, order, data)
	local invertWidget

	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	if dropdownWidget ~= nil then
		do
			local widget = Addon:GUI_Label("")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		end

		do
			invertWidget = Addon:GUI_CheckBox(data, "negated", binding)
			invertWidget:SetLabel(Addon.L["Invert"])
			invertWidget:SetRelativeWidth(0.5)

			container:AddChild(invertWidget)
		end
	end

	return enabledWidget, dropdownWidget, invertWidget
end

--- @param container AceGUIContainer
--- @param talents TalentInfo[]
--- @param data Binding.MutliFieldLoadOption
local function DrawTalentSelectPanel(container, talents, data)
	--- @param name string
	--- @return boolean
	local function DoesTalentExist(name)
		for _, item in ipairs(talents) do
			if item.text == name then
				return true
			end
		end

		return false
	end

	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	local function AddSeparator()
		local widget = AceGUI:Create("Heading") --[[@as AceGUIHeading]]
		widget:SetFullWidth(true)
		widget:SetText(Addon.L["Or"])

		container:AddChild(widget)
	end

	--- @param operation "AND"|"OR"
	--- @param position integer
	--- @param text string
	local function AddAddButton(operation, position, text)
		local function OnClick()
			table.insert(data.entries, position, {
				operation = operation,
				value = ""
			})

			Addon:BindingConfig_Redraw()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.5)
		widget:SetText(text)

		container:AddChild(widget)
	end

	local function CreateTableGroup()
		local group = AceGUI:Create("ClickedSimpleGroup") --[[@as ClickedSimpleGroup]]
		group:SetLayout("Table")
		group:SetFullWidth(true)
		group:SetUserData("table", {
			columns = { 75, 1, 50 },
			spaceH = 1
		})

		container:AddChild(group)
		return group
	end

	do
		local widget = AceGUI:Create("Label")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	local tableContainer = CreateTableGroup()

	for i = 1, #data.entries do
		local entry = data.entries[i]

		if entry.operation == "OR" then
			AddSeparator()
			tableContainer = CreateTableGroup()
		end

		do
			local function OnClick()
				entry.negated = not entry.negated
				Clicked:ReloadBinding(binding, true)
			end

			local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
			widget:SetText(entry.negated and Addon.L["Not"] or "")
			widget:SetCallback("OnClick", OnClick)

			tableContainer:AddChild(widget)
		end

		do
			local widget = Addon:GUI_AutoFillEditBox(entry, "value", binding)
			widget:SetInputError(not DoesTalentExist(entry.value))
			widget:SetValues(talents)
			widget:SetFullWidth(true)

			tableContainer:AddChild(widget)
		end

		do
			local function OnClick()
				table.remove(data.entries, i)

				if #data.entries > 0 then
					do
						local first = data.entries[1]

						if first.operation == "OR" then
							first.operation = "AND"
						end
					end

					do
						local next = data.entries[i]

						if next ~= nil and entry.operation == "OR" and next.operation == "AND" then
							next.operation = "OR"
						end
					end
				end

				Clicked:ReloadBinding(binding, true)
			end

			local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
			widget:SetText(Addon.L["X"])
			widget:SetCallback("OnClick", OnClick)
			widget:SetDisabled(#data.entries == 1)

			tableContainer:AddChild(widget)
		end

		if i == #data.entries or data.entries[i + 1].operation == "OR" then
			AddAddButton("AND", i + 1, Addon.L["Add condition"])

			do
				local function OnClick()
					for j = i, 1, -1 do
						if j == 1 then
							data.entries[1] = {
								operation = "AND",
								value = ""
							}
						else
							local operation = data.entries[j].operation
							table.remove(data.entries, j)

							if operation == "OR" then
								break
							end
						end
					end

					tree:Redraw()
				end

				local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
				widget:SetText(Addon.L["Remove compound"])
				widget:SetCallback("OnClick", OnClick)
				widget:SetDisabled(#data.entries <= 1)
				widget:SetRelativeWidth(0.5)

				container:AddChild(widget)
			end
		end
	end

	AddSeparator()
	AddAddButton(#data.entries == 0 and "AND" or "OR", #data.entries + 1, Addon.L["Add compound"])

	do
		local function OnClick()
			showTalentPanel = nil
			tree:Redraw()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Close"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.5)

		container:AddChild(widget)
	end
end

--- @generic T
--- @param container AceGUIContainer
--- @param title string
--- @param specializations integer[]
--- @param data Binding.MutliFieldLoadOption
--- @param mode "talents"|"pvp_talents"
--- @return AceGUICheckBox
local function DrawTalentSelectOption(container, title, specializations, data, mode)
	assert(type(data) == "table", "bad argument #4, expected table but got " .. type(data))

	local enabledWidget

	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	-- enabled toggle
	do
		local function OnValueChanged(_, enabled)
			if not enabled and showTalentPanel == mode then
				showTalentPanel = nil
			end
		end

		enabledWidget = Addon:GUI_CheckBox(data, "selected", binding)
		enabledWidget:SetLabel(title)

		if not data.selected then
			enabledWidget:SetRelativeWidth(1)
		else
			enabledWidget:SetRelativeWidth(0.5)
		end

		container:AddChild(enabledWidget)

		RegisterTooltip(enabledWidget, title, CreateLoadOptionTooltip("LoadOption", data.selected))
		Addon:GUI_SetPostValueChanged(enabledWidget, OnValueChanged)
	end

	if data.selected then
		local talents

		if Addon:IsGameVersionAtleast("RETAIL") then
			if mode == "talents" then
				talents = Addon:GetLocalizedTalents(specializations)
			elseif mode == "pvp_talents" then
				talents = Addon:GetLocalizedPvPTalents(specializations)
			end
		elseif Addon:IsGameVersionAtleast("CATA") then
			talents = Addon:Cata_GetLocalizedTalents(specializations)
		end

		--- @param name string
		--- @return TalentInfo?
		local function GetTalentInfo(name)
			for _, talent in ipairs(talents) do
				if talent.text == name then
					return talent
				end
			end

			return nil
		end

		if #data.entries == 0 then
			local widget = Addon:GUI_Label("")
			widget:SetRelativeWidth(0.5)

			container:AddChild(widget)
		else
			for i = 1, #data.entries do
				local entry = data.entries[i]

				if entry.operation == "OR" then
					local widget = Addon:GUI_Label("")
					widget:SetWidth(7)

					container:AddChild(widget)
				end

				do
					local talent = GetTalentInfo(entry.value)
					local ticker

					local function OnEnter(widget)
						if talent == nil then
							return
						end

						ticker = C_Timer.NewTimer(Addon.TOOLTIP_SHOW_DELAY, function()
							GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT")

							if talent.spellId ~= nil then
								GameTooltip:SetSpellByID(talent.spellId)
							else
								GameTooltip:SetText(talent.text)
							end

							GameTooltip:Show()
						end)
					end

					local function OnLeave()
						if ticker ~= nil then
							ticker:Cancel()
							GameTooltip:Hide()
						end
					end

					local icon = talent ~= nil and talent.icon or "Interface\\ICONS\\INV_Misc_QuestionMark"

					local widget = AceGUI:Create("ClickedTalentIcon") --[[@as ClickedTalentIcon]]
					widget:SetImage(icon)
					widget:SetImageSize(16, 16)
					widget:SetWidth(18)
					widget:SetHeight(18)

					if entry.negated then
						widget:SetColor(1, 0, 0, 1)
					end

					widget:SetCallback("OnEnter", OnEnter)
					widget:SetCallback("OnLeave", OnLeave)

					container:AddChild(widget)
				end
			end
		end

		if showTalentPanel == mode then
			DrawTalentSelectPanel(container, talents, data)
		else
			do
				local widget = Addon:GUI_Label("")
				widget:SetRelativeWidth(0.5)

				container:AddChild(widget)
			end

			do
				local function OnClick()
					showTalentPanel = mode
					tree:Redraw()
				end

				local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
				widget:SetCallback("OnClick", OnClick)
				widget:SetText(Addon.L["Select talents"])

				widget:SetRelativeWidth(0.5)
				container:AddChild(widget)
			end
		end
	end

	return enabledWidget
end

-- Binding action page and components

--- @param container AceGUIContainer
--- @param action Binding.Action
--- @param mode string
local function DrawSpellItemAuraSelection(container, action, mode)
	local valueKey = nil
	local headerText = nil

	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	if mode == Addon.BindingTypes.SPELL then
		valueKey = "spellValue"
		headerText = Addon.L["Target Spell"]
	elseif mode == Addon.BindingTypes.ITEM then
		valueKey = "itemValue"
		headerText = Addon.L["Target Item"]
	elseif mode == Addon.BindingTypes.CANCELAURA then
		valueKey = "auraName"
		headerText = Addon.L["Target Aura"]
	end

	-- target spell or item
	do
		local group = Addon:GUI_InlineGroup()
		group:SetTitle(headerText)
		container:AddChild(group)

		local name, id = GetSpellItemNameAndId(action[valueKey], mode, not action.spellMaxRank)

		if name == nil and id ~= nil then
			name = id
		end

		name = tostring(name)

		-- edit box
		do
			--- @type AceGUIEditBox
			local widget = nil

			local function OnEnterPressed(_, _, value)
				if value == name then
					widget:ClearFocus()
					return
				end

				value = Addon:TrimString(value)

				if not Addon:IsNilOrEmpty(value) then
					value = tonumber(value) or value

					if type(value) == "string" then
						local _, newId = GetSpellItemNameAndId(value, mode, false)

						if newId ~= nil then
							action[valueKey] = newId
						end
					else
						action[valueKey] = value
					end
				else
					action[valueKey] = ""
				end

				Clicked:ReloadBinding(binding, true)
			end

			local function OnEnterPressedSpell()
				local type, p2, _, p4 = GetCursorInfo()

				if mode == Addon.BindingTypes.ITEM then
					if type == "item" and p2 ~= nil then
						action[valueKey] = p2
						Clicked:ReloadBinding(binding, true)
					end
				elseif mode == Addon.BindingTypes.SPELL then
					if type == "spell" and p4 ~= nil then
						action[valueKey] = p4
						Clicked:ReloadBinding(binding, true)
					elseif type == "petaction" and p2 ~= nil then
						action[valueKey] = p2
						Clicked:ReloadBinding(binding, true)
					end
				end
			end

			local function OnTextChanged(_, _, value)
				local itemLink = string.match(value, "item[%-?%d:]+")
				local spellLink = string.match(value, "spell[%-?%d:]+")
				local talentLink = string.match(value, "talent[%-?%d:]+")
				local linkId = nil

				if not Addon:IsNilOrEmpty(itemLink) then
					local match = string.match(itemLink, "(%d+)")
					linkId = tonumber(match)
				elseif not Addon:IsNilOrEmpty(spellLink) then
					local match = string.match(spellLink, "(%d+)")
					linkId = tonumber(match)
				elseif not Addon:IsNilOrEmpty(talentLink) then
					local match = string.match(talentLink, "(%d+)")
					linkId = tonumber(select(6, GetTalentInfoByID(match, 1)))
				end

				if linkId ~= nil and linkId > 0 then
					action[valueKey] = linkId

					if mode == Addon.BindingTypes.SPELL then
						local spell = Addon:GetSpellInfo(linkId, true)
						value = spell ~= nil and spell.name or nil
					elseif mode == Addon.BindingTypes.ITEM then
						value = Addon:GetItemInfo(linkId)
					end

					widget:SetText(value)
					widget:ClearFocus()

					Clicked:ReloadBinding(binding, true)
				end
			end

			--- @param match ClickedAutoFillEditBox.Match?
			local function OnSelect(_, _, value, match)
				if match == nil then
					local spellId = tonumber(value)

					action[valueKey] = spellId or ""
					Clicked:ReloadBinding(binding, true)
					return
				end

				if match.spellId == id then
					widget:ClearFocus()
					return
				end

				action[valueKey] = match.spellId
				action.spellMaxRank = not string.find(match.text, "%((.+)%)")

				Clicked:ReloadBinding(binding, true)
			end

			local function CreateOptions()
				--- @type ClickedAutoFillEditBox.Option[]
				local result = {}

				--- @type ClickedAutoFillEditBox.Option?
				local selected = nil

				for _, spell in Addon.SpellLibrary:GetSpells() do
					table.insert(result, {
						prefix = spell.tabName,
						text = spell.name,
						icon = spell.icon,
						spellId = spell.spellId
					})

					if spell.name == name then
						selected = result[#result]
					end
				end

				return selected, result
			end

			if mode == Addon.BindingTypes.SPELL then
				local selected, options = CreateOptions()

				widget = AceGUI:Create("ClickedAutoFillEditBox") --[[@as ClickedAutoFillEditBox]]

				if selected == nil then
					widget:SetText(name)
				else
					widget:Select(selected)
				end

				widget:SetStrictMode(false)
				widget:SetInputError(Addon.SpellLibrary:GetSpellByName(name) == nil or (id ~= nil and Addon.SpellLibrary:GetSpellById(id) == nil))
				widget:SetValues(options)
				widget:SetCallback("OnSelect", OnSelect)
				widget:SetCallback("OnEnterPressed", OnEnterPressedSpell)
				widget:SetCallback("OnTextChanged", OnTextChanged)
			else
				widget = AceGUI:Create("EditBox") --[[@as AceGUIEditBox]]
				widget:DisableButton(true)
				widget:SetText(name)
				widget:SetCallback("OnEnterPressed", OnEnterPressed)
				widget:SetCallback("OnTextChanged", OnTextChanged)
			end

			if id ~= nil then
				widget:SetRelativeWidth(0.85)
			else
				widget:SetFullWidth(true)
			end

			if mode == Addon.BindingTypes.SPELL then
				RegisterTooltip(widget, Addon.L["Target Spell"], Addon.L["Enter the spell name or spell ID."])
			elseif mode == Addon.BindingTypes.ITEM then
				RegisterTooltip(widget, Addon.L["Target Item"], Addon.L["Enter an item name, item ID, or equipment slot number."] .. "\n\n" .. Addon.L["If the input field is empty you can also shift-click an item from your bags to auto-fill."])
			elseif mode == Addon.BindingTypes.CANCELAURA then
				RegisterTooltip(widget, Addon.L["Target Aura"], Addon.L["Enter the aura name or spell ID."])
			end

			group:AddChild(widget)
		end

		-- spell id
		if id ~= nil then
			--- @type TickerCallback?
			local ticker

			local function OnEnter(widget)
				ticker = C_Timer.NewTimer(Addon.TOOLTIP_SHOW_DELAY, function()
					GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT")

					if mode == Addon.BindingTypes.SPELL then
						GameTooltip:SetSpellByID(id)
					elseif mode == Addon.BindingTypes.ITEM then
						GameTooltip:SetItemByID(id)
					end

					GameTooltip:Show()
				end)
			end

			local function OnLeave()
				if ticker ~= nil then
					ticker:Cancel()
					GameTooltip:Hide()
				end
			end

			local icon

			if mode == Addon.BindingTypes.SPELL then
				local spell = Addon:GetSpellInfo(id, not action.spellMaxRank)
				icon = spell and spell.iconID or nil
			elseif mode == Addon.BindingTypes.ITEM then
				icon = select(10, Addon:GetItemInfo(id))
			end

			local widget = AceGUI:Create("ClickedHorizontalIcon") --[[@as ClickedHorizontalIcon]]
			widget:SetLabel(tostring(id))
			widget:SetImage(icon)
			widget:SetImageSize(16, 16)
			widget:SetRelativeWidth(0.15)
			widget:SetCallback("OnEnter", OnEnter)
			widget:SetCallback("OnLeave", OnLeave)

			group:AddChild(widget)
		end

		if mode == Addon.BindingTypes.SPELL then
			local hasRank = Addon.EXPANSION_LEVEL <= Addon.EXPANSION.WOTLK and id ~= nil and string.find(name, "%((.+)%)")

			-- remove rank button
			if hasRank then
				local function OnClick()
					if id == nil then
						return
					end

					action.spellMaxRank = true

					Clicked:ReloadBinding(binding, true)
				end

				local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
				widget:SetText(Addon.L["Remove rank"])
				widget:SetCallback("OnClick", OnClick)
				widget:SetFullWidth(true)

				group:AddChild(widget)
			end
		end
	end
end

--- @param container AceGUIContainer
--- @param targets Binding.Targets
--- @param action Binding.Action
local function DrawMacroSelection(container, targets, action)
	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	-- macro name and icon
	do
		local group = Addon:GUI_InlineGroup()
		group:SetTitle(Addon.L["Macro Name and Icon (optional)"])
		container:AddChild(group)

		-- name text field
		do
			local widget = Addon:GUI_EditBox("OnEnterPressed", action, "macroName")
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		-- icon field
		do
			local widget = Addon:GUI_EditBox("OnEnterPressed", action, "macroIcon")
			widget:SetRelativeWidth(0.7)

			group:AddChild(widget)
		end

		-- icon button
		do
			local function OpenIconPicker()
				showIconPicker = true
				tree:Redraw()
			end

			local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
			widget:SetText(Addon.L["Select"])
			widget:SetCallback("OnClick", OpenIconPicker)
			widget:SetRelativeWidth(0.3)

			group:AddChild(widget)
		end
	end

	-- macro text
	do
		local group = Addon:GUI_InlineGroup()
		group:SetTitle(Addon.L["Macro Text"])
		container:AddChild(group)

		-- help text
		if targets.hovercastEnabled and not targets.regularEnabled then
			local widget = Addon:GUI_Label(Addon.L["This macro will only execute when hovering over unit frames, in order to interact with the selected target use the [@mouseover] conditional."] .. "\n")
			widget:SetFullWidth(true)
			group:AddChild(widget)
		end

		-- macro text field
		do
			local widget = Addon:GUI_MultilineEditBox("OnEnterPressed", action, "macroValue", binding)
			widget:SetFullWidth(true)
			widget:SetNumLines(8)
			Addon.Media:UseMonoFont(widget)

			group:AddChild(widget)
		end
	end
end

--- @param container AceGUIContainer
--- @param action Binding.Action
local function DrawAppendSelection(container, action)
	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	-- macro name and icon
	do
		local group = Addon:GUI_InlineGroup()
		group:SetTitle(Addon.L["Macro Name and Icon (optional)"])
		container:AddChild(group)

		-- name text field
		do
			local widget = Addon:GUI_EditBox("OnEnterPressed", action, "macroName", GetCurrentBinding())
			widget:SetFullWidth(true)

			group:AddChild(widget)
		end

		-- icon field
		do
			local widget = Addon:GUI_EditBox("OnEnterPressed", action, "macroIcon", GetCurrentBinding())
			widget:SetRelativeWidth(0.7)

			group:AddChild(widget)
		end

		-- icon button
		do
			local function OpenIconPicker()
				showIconPicker = true
				tree:Redraw()
			end

			local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
			widget:SetText(Addon.L["Select"])
			widget:SetCallback("OnClick", OpenIconPicker)
			widget:SetRelativeWidth(0.3)

			group:AddChild(widget)
		end
	end

	-- macro text
	do
		local group = Addon:GUI_InlineGroup()
		group:SetTitle(Addon.L["Macro Text"])
		container:AddChild(group)

		-- macro text field
		do
			local widget = Addon:GUI_MultilineEditBox("OnEnterPressed", action, "macroValue", binding)
			widget:SetFullWidth(true)
			widget:SetNumLines(8)

			group:AddChild(widget)
		end
	end
end

--- @param container AceGUIContainer
--- @param keybind string
local function DrawActionGroupOptions(container, keybind)
	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	--- @param left Binding
	--- @param right Binding
	--- @return boolean
	local function SortFunc(left, right)
		if left.actionType == Addon.BindingTypes.MACRO and right.actionType ~= Addon.BindingTypes.MACRO then
			return true
		end

		if left.actionType ~= Addon.BindingTypes.MACRO and right.actionType == Addon.BindingTypes.MACRO then
			return false
		end

		if left.actionType ~= Addon.BindingTypes.APPEND and right.actionType == Addon.BindingTypes.APPEND then
			return true
		end

		if left.actionType == Addon.BindingTypes.APPEND and right.actionType ~= Addon.BindingTypes.APPEND then
			return false
		end

		return left.uid < right.uid
	end

	local group = Addon:GUI_InlineGroup()
	group:SetTitle(Addon.L["Action Groups"])

	local groups = { }
	local order = {}
	local count = 0

	for _, other in Clicked:IterateActiveBindings() do
		if other.keybind == keybind then
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

		local header = AceGUI:Create("Label") --[[@as AceGUILabel]]
		header:SetText(string.format(Addon.L["Group %d"], id))
		header:SetFontObject(GameFontHighlight)

		group:AddChild(header)

		for index, current in ipairs(bindings) do
			local function OnClick()
				tree:SelectByBindingOrGroup(current)
			end

			local function OnMoveUp()
				if InCombatLockdown() then
					Addon:NotifyCombatLockdown()
					return
				end

				if current.action.executionOrder > 1 then
					current.action.executionOrder = current.action.executionOrder - 1
				else
					for oid, obindings in pairs(groups) do
						if oid >= id then
							for _, obinding in ipairs(obindings) do
								if obinding ~= current then
									obinding.action.executionOrder = obinding.action.executionOrder + 1
								end
							end
						end
					end
				end

				Clicked:ReloadBinding(current, true)
			end

			local function OnMoveDown()
				if InCombatLockdown() then
					Addon:NotifyCombatLockdown()
					return
				end

				current.action.executionOrder = current.action.executionOrder + 1

				Clicked:ReloadBinding(current, true)
			end

			local name, icon = Addon:GetBindingNameAndIcon(current)

			if index > 1 then
				--- @param b Binding
				--- @return string?
				local function GetType(b)
					if b.actionType == Addon.BindingTypes.SPELL or b.actionType == Addon.BindingTypes.ITEM then
						return "use"
					elseif b.actionType == Addon.BindingTypes.CANCELAURA then
						return "cancel"
					end

					return nil
				end

				--- @type Binding
				local previous = bindings[index - 1]

				local type = GetType(current)
				local previousType = GetType(previous)

				if type ~= nil and previousType ~= nil and type ~= previousType then
					name = "|cffff0000" .. name .. "|r"
				end
			end

			local widget = AceGUI:Create("ClickedReorderableLabel") --[[@as ClickedReorderableLabel]]
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

--- @param container AceGUIContainer
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
					if Clicked:IsBindingLoaded(binding) and IsSharedDataSet(key) then
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
			Clicked:ReloadBinding(binding, true)
		end

		widget = AceGUI:Create("CheckBox") --[[@as AceGUICheckBox]]
		widget:SetType("checkbox")
		widget:SetLabel(label)
		widget:SetCallback("OnValueChanged", OnValueChanged)
		widget:SetFullWidth(true)

		RegisterTooltip(widget, label, tooltipText)

		if binding.action[key] then
			widget:SetValue(true)
		else
			if Clicked:IsBindingLoaded(binding) and IsSharedDataSet(key) then
				widget:SetTriState(true)
				widget:SetValue(nil)
				isUsingShared = true
			end
		end

		group:AddChild(widget)
	end

	local group = Addon:GUI_InlineGroup()
	group:SetTitle(Addon.L["Shared Options"])
	container:AddChild(group)

	CreateCheckbox(group, Addon.L["Interrupt current cast"], Addon.L["Allow this binding to cancel any spells that are currently being cast."], "interrupt")

	if binding.actionType ~= Addon.BindingTypes.CANCELAURA then
		CreateCheckbox(group, Addon.L["Start auto attacks"], Addon.L["Allow this binding to start auto attacks, useful for any damaging abilities."], "startAutoAttack")
		CreateCheckbox(group, Addon.L["Start pet attacks"], Addon.L["Allow this binding to start pet attacks."], "startPetAttack")
		CreateCheckbox(group, Addon.L["Override queued spell"], Addon.L["Allow this binding to override a spell that is queued by the lag-tolerance system, should be reserved for high-priority spells."], "cancelQueuedSpell")
		CreateCheckbox(group, Addon.L["Exit shapeshift form"], Addon.L["Allow this binding to automatically exit your shapeshift form."], "cancelForm")
		CreateCheckbox(group, Addon.L["Target on cast"], Addon.L["Targets the unit you are casting on."], "targetUnitAfterCast")
	end
end

--- @param container AceGUIContainer
--- @param binding Binding
local function DrawIntegrationsOptions(container, binding)
	local group = Addon:GUI_InlineGroup()
	group:SetTitle(Addon.L["External Integrations"])
	local hasAnyChildren = false

	-- weakauras export
	if Addon:IsWeakAurasIntegrationEnabled() then
		local function OnClick()
			Addon:CreateWeakAurasIcon(binding)
		end

		local widget = AceGUI:Create("InteractiveLabel") --[[@as AceGUIInteractiveLabel]]
		widget:SetImage([[Interface\AddOns\WeakAuras\Media\Textures\icon]])
		widget:SetImageSize(16, 16)
		widget:SetText(string.format("%s (%s)", Addon.L["Create WeakAura"], Addon.L["Beta"]))
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

--- @param container AceGUIContainer
--- @param binding Binding
local function DrawBindingActionPage(container, binding)
	local type = binding.actionType

	local SPELL = Addon.BindingTypes.SPELL
	local ITEM = Addon.BindingTypes.ITEM
	local MACRO = Addon.BindingTypes.MACRO
	local APPEND = Addon.BindingTypes.APPEND
	local CANCELAURA = Addon.BindingTypes.CANCELAURA

	if type == SPELL or type == ITEM or type == CANCELAURA then
		DrawSpellItemAuraSelection(container, binding.action, binding.actionType)
	elseif type == MACRO then
		DrawMacroSelection(container, binding.targets, binding.action)
	elseif type == APPEND then
		local msg = {
			Addon.L["This mode will directly append the macro text onto an automatically generated command generated by other bindings using the specified keybind. Generally, this means that it will be the last section of a '/cast' command."],
			Addon.L["With this mode you're not writing a macro command. You're adding parts to an already existing command, so writing '/cast Holy Light' will not work, in order to cast Holy Light simply type 'Holy Light'."]
		}

		local group = Addon:GUI_InlineGroup()
		container:AddChild(group)

		local widget = Addon:GUI_Label(table.concat(msg, "\n\n"), "medium")
		widget:SetFullWidth(true)

		group:AddChild(widget)

		DrawAppendSelection(container, binding.action)
	end

	DrawActionGroupOptions(container, binding.keybind)

	if type == SPELL or type == ITEM or type == MACRO or type == APPEND or type == CANCELAURA then
		DrawSharedOptions(container, binding)
	end

	if type == SPELL or type == ITEM then
		DrawIntegrationsOptions(container, binding)
	end
end

-- Binding target page and components

--- @param container AceGUIContainer
--- @param targets Binding.Target[]
--- @param enabled boolean
--- @param index integer
local function DrawTargetSelectionUnit(container, targets, enabled, index)
	local target

	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

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

			Clicked:ReloadBinding(binding, true)
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

		items["_NONE_"] = Addon.L["<No one>"]
		table.insert(order, "_NONE_")
	else
		target = targets[index]

		if #targets > 1 then
			items["_DELETE_"] = Addon.L["<Remove this target>"]
			table.insert(order, "_DELETE_")
		end
	end

	local widget = Addon:GUI_Dropdown(items, order, target, "unit", binding)
	widget:SetFullWidth(true)
	widget:SetCallback("OnValueChanged", OnValueChanged)
	widget:SetDisabled(not enabled)

	container:AddChild(widget)
end

--- @param container AceGUIContainer
--- @param enabled boolean
--- @param target Binding.Target
local function DrawTargetSelectionHostility(container, enabled, target)
	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	local items, order = Addon:GetLocalizedTargetHostility()
	local widget = Addon:GUI_Dropdown(items, order, target, "hostility", binding)
	widget:SetFullWidth(true)
	widget:SetDisabled(not enabled)

	container:AddChild(widget)
end

--- @param container AceGUIContainer
--- @param enabled boolean
--- @param target Binding.Target
local function DrawTargetSelectionVitals(container, enabled, target)
	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	local items, order = Addon:GetLocalizedTargetVitals()
	local widget = Addon:GUI_Dropdown(items, order, target, "vitals", binding)
	widget:SetFullWidth(true)
	widget:SetDisabled(not enabled)

	container:AddChild(widget)
end

--- @param container AceGUIContainer
--- @param binding Binding
local function DrawBindingTargetPage(container, binding)
	if Addon:IsRestrictedKeybind(binding.keybind) then
		local widget = Addon:GUI_Label(Addon.L["The left and right mouse button can only activate when hovering over unit frames."] .. "\n", "medium")
		widget:SetFullWidth(true)

		container:AddChild(widget)
	end

	local isMacro = binding.actionType == Addon.BindingTypes.MACRO

	-- hovercast targets
	do
		local hovercast = binding.targets.hovercast
		local enabled = binding.targets.hovercastEnabled

		do
			local widget = Addon:GUI_ToggleHeading(binding.targets, "hovercastEnabled", binding)
			widget:SetText(Addon.L["Unit Frame Target"])
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
			local widget = Addon:GUI_ToggleHeading(binding.targets, "regularEnabled", binding)
			widget:SetText(Addon.L["Macro Targets"])
			widget:SetDisabled(not CanEnableRegularTargetMode(binding))
			container:AddChild(widget)
		end

		if isMacro then
			local group = Addon:GUI_InlineGroup()
			group:SetTitle(Addon.L["On this target"])
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

					Clicked:ReloadBinding(binding, true)
				end

				local label = i == 1 and Addon.L["On this target"] or enabled and Addon.L["Or"] or Addon.L["Or (inactive)"]
				local group = Addon:GUI_ReorderableInlineGroup()
				group:SetTitle(label)
				group:SetMoveUpButton(i > 1)
				group:SetMoveDownButton(i < #regular)
				group:SetCallback("OnMoveDown", OnMove)
				group:SetCallback("OnMoveUp", OnMove)
				container:AddChild(group)

				if not binding.targets.hovercastEnabled and target.unit == Addon.TargetUnits.MOUSEOVER and Addon:IsMouseButton(binding.keybind) then
					local widget = Addon:GUI_Label(Addon.L["Bindings using a mouse button and the Mouseover target will not activate when hovering over a unit frame, enable the Unit Frame Target to enable unit frame clicks."] .. "\n")
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
				local group = Addon:GUI_InlineGroup()
				group:SetTitle(enabled and Addon.L["Or"] or Addon.L["Or (inactive)"])
				container:AddChild(group)

				DrawTargetSelectionUnit(group, regular, enabled, 0)
			end
		end
	end
end

-- Binding macro conditions page and components

--- @param container AceGUIContainer
--- @param form Binding.NegatableTriStateLoadOption
--- @param specIds integer[]
local function DrawMacroInStance(container, form, specIds)
	local label = Addon.L["Stance"]

	if specIds == nil then
		specIds = {}
		specIds[1] = GetSpecializationInfo(GetSpecialization())
	end

	if #specIds == 1 then
		local specId = specIds[1]

		-- Balance Druid, Feral Druid, Guardian Druid, Restoration Druid, Initial Druid
		if specId == 102 or specId == 103 or specId == 104 or specId == 105 or specId == 1447 then
			label = Addon.L["Form"]
		end
	end

	local items, order = Addon:GetLocalizedForms(specIds)
	DrawNegatableTristateLoadOption(container, label, items, order, form)
end

--- @param container AceGUIContainer
--- @param form Binding.NegatableTriStateLoadOption
--- @param classes string[]
local function Classic_DrawMacroInStance(container, form, classes)
	local label = Addon.L["Stance"]

	if classes == nil then
		classes = {}
		classes[1] = select(2, UnitClass("player"))
	end

	if #classes == 1 and classes[1] == "DRUID" then
		label = Addon.L["Form"]
	end

	local items, order = Addon:Classic_GetLocalizedForms(classes)
	DrawNegatableTristateLoadOption(container, label, items, order, form)
end

--- @param container AceGUIContainer
--- @param combat Binding.LoadOption
local function DrawMacroCombat(container, combat)
	local items = {
		[true] = Addon.L["In combat"],
		[false] = Addon.L["Not in combat"]
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Combat"], items, order, combat)

	local binding = GetCurrentBinding()
	if binding ~= nil and combat.selected and (binding.actionType == Addon.BindingTypes.UNIT_MENU or binding.actionType == Addon.BindingTypes.UNIT_SELECT) then
		local text = Addon.L["Combat state checks for this binding require additional processing when entering and leaving combat and may cause slight performance degradation."]

		local widget = Addon:GUI_Label(text)
		widget:SetFullWidth(true)
		widget:SetColor(1, 0, 0)

		container:AddChild(widget)
	end
end

--- @param container AceGUIContainer
--- @param pet Binding.LoadOption
local function DrawMacroPet(container, pet)
	local items = {
		[true] = Addon.L["Pet exists"],
		[false] = Addon.L["No pet"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Pet"], items, order, pet)
end

--- @param container AceGUIContainer
--- @param stealth Binding.LoadOption
local function DrawMacroStealth(container, stealth)
	local items = {
		[true] = Addon.L["In Stealth"],
		[false] = Addon.L["Not in Stealth"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Stealth"], items, order, stealth)
end

--- @param container AceGUIContainer
--- @param mounted Binding.LoadOption
local function DrawMacroMounted(container, mounted)
	local items = {
		[true] = Addon.L["Mounted"],
		[false] = Addon.L["Not mounted"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Mounted"], items, order, mounted)
end

--- @param container AceGUIContainer
--- @param flying Binding.LoadOption
local function DrawMacroFlying(container, flying)
	local items = {
		[true] = Addon.L["Flying"],
		[false] = Addon.L["Not flying"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Flying"], items, order, flying)
end

--- @param container AceGUIContainer
--- @param dynamicFlying Binding.LoadOption
local function DrawMacroDynamicFlying(container, dynamicFlying)
	local items = {
		[true] = Addon.L["Skyriding"],
		[false] = Addon.L["Not Skyriding"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Skyriding"], items, order, dynamicFlying)
end

--- @param container AceGUIContainer
--- @param flyable Binding.LoadOption
local function DrawMacroFlyable(container, flyable)
	local items = {
		[true] = Addon.L["Flyable"],
		[false] = Addon.L["Not flyable"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Flyable"], items, order, flyable)
end


--- @param container AceGUIContainer
--- @param advancedFlyable Binding.LoadOption
local function DrawMacroAdvancedFlyable(container, advancedFlyable)
	local items = {
		[true] = Addon.L["Advanced Flyable"],
		[false] = Addon.L["Not advanced flyable"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Advanced Flyable"], items, order, advancedFlyable)
end

--- @param container AceGUIContainer
--- @param bonusbar Binding.NegatableStringLoadOption
local function DrawMacroBonusBar(container, bonusbar)
	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	local items = {
		[false] = Addon.L["Bonus bar"],
		[true] = Addon.L["Not bonus bar"]
	}

	local order = {
		false,
		true
	}

	local _, _, inputField = DrawNegatableStringLoadOption(container, Addon.L["Bonus bar"], items, order, bonusbar)

	if inputField ~= nil then
		local function OnTextChanged(_, _, value)
			if tonumber(value) == nil then
				inputField:SetText(bonusbar.value --[[@as string]])
			end
		end

		inputField:SetCallback("OnTextChanged", OnTextChanged)

		RegisterTooltip(inputField, Addon.L["Bonus bar"])
	end
end

--- @param container AceGUIContainer
--- @param outdoors Binding.LoadOption
local function DrawMacroOutdoors(container, outdoors)
	local items = {
		[true] = Addon.L["Outdoors"],
		[false] = Addon.L["Indoors"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Outdoors"], items, order, outdoors)
end

--- @param container AceGUIContainer
--- @param swimming Binding.LoadOption
local function DrawMacroSwimming(container, swimming)
	local items = {
		[true] = Addon.L["Swimming"],
		[false] = Addon.L["Not swimming"],
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["Swimming"], items, order, swimming)
end

--- @param container AceGUIContainer
--- @param channeling Binding.NegatableStringLoadOption
local function DrawMacroChanneling(container, channeling)
	local items = {
		[false] = Addon.L["Channeling"],
		[true] = Addon.L["Not channeling"]
	}

	local order = {
		false,
		true
	}

	DrawNegatableStringLoadOption(container, Addon.L["Channeling"], items, order, channeling)
end

--- @param container AceGUIContainer
--- @param binding Binding
local function DrawBindingMacroConditionsPage(container, binding)
	local load = binding.load

	if binding.actionType == Addon.BindingTypes.UNIT_SELECT or binding.actionType == Addon.BindingTypes.UNIT_MENU then
		DrawMacroCombat(container, load.combat)
	else
		if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.DF then
			local classNames = GetTriStateLoadOptionValue(load.class)
			local specIndices = GetTriStateLoadOptionValue(load.specialization)
			local specializationIds = GetRelevantSpecializationIds(classNames, specIndices)

			DrawMacroInStance(container, load.form, specializationIds)
		else
			local classNames = GetTriStateLoadOptionValue(load.class)

			Classic_DrawMacroInStance(container, load.form, classNames)
		end

		DrawMacroCombat(container, load.combat)
		DrawMacroPet(container, load.pet)
		DrawMacroStealth(container, load.stealth)
		DrawMacroMounted(container, load.mounted)
		DrawMacroOutdoors(container, load.outdoors)
		DrawMacroSwimming(container, load.swimming)
		DrawMacroChanneling(container, load.channeling)

		if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.BC then
			DrawMacroFlying(container, load.flying)

			if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.TWW then
				DrawMacroDynamicFlying(container, load.dynamicFlying)
			end

			DrawMacroFlyable(container, load.flyable)
		end

		if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.CATA then
			DrawMacroBonusBar(container, load.bonusbar)
		end

		if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.DF then
			DrawMacroAdvancedFlyable(container, load.advancedFlyable)
		end
	end
end

-- Binding load conditions page and components

--- @param container AceGUIContainer
--- @param load Binding.Load
local function DrawLoadNeverSelection(container, load)
	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	-- never load toggle
	do
		local widget = Addon:GUI_CheckBox(load, "never", binding)
		widget:SetLabel(Addon.L["Never load"])
		widget:SetFullWidth(true)

		container:AddChild(widget)

		RegisterTooltip(widget, Addon.L["Never load"], CreateLoadOptionTooltip("LoadOption", load.never))
	end
end

--- @param container AceGUIContainer
--- @param class Binding.TriStateLoadOption
local function DrawLoadClass(container, class)
	local items, order = Addon:GetLocalizedClasses()
	DrawTristateLoadOption(container, Addon.L["Class"], items, order, class)
end

--- @param container AceGUIContainer
--- @param race Binding.TriStateLoadOption
local function DrawLoadRace(container, race)
	local items, order = Addon:GetLocalizedRaces()
	DrawTristateLoadOption(container, Addon.L["Race"], items, order, race)
end

--- @param container AceGUIContainer
--- @param specialization Binding.TriStateLoadOption
--- @param classNames string[]
local function DrawLoadSpecialization(container, specialization, classNames)
	local items, order

	if Addon:IsGameVersionAtleast("RETAIL") then
		items, order = Addon:GetLocalizedSpecializations(classNames)
	else
		items, order = Addon:Cata_GetLocalizedSpecializations(classNames)
	end

	DrawTristateLoadOption(container, Addon.L["Talent specialization"], items, order, specialization)
end

-- --- @param container AceGUIContainer
-- --- @param specialization Binding.TriStateLoadOption
-- local function Classic_DrawLoadSpecialization(container, specialization)
-- 	local items = {
-- 		[1] = Addon.L["Primary Specialization"],
-- 		[2] = Addon.L["Secondary Specialization"]
-- 	}

-- 	local order = {
-- 		1,
-- 		2
-- 	}

-- 	DrawTristateLoadOption(container, Addon.L["Talent specialization"], items, order, specialization)
-- end

--- @param container AceGUIContainer
--- @param talent Binding.MutliFieldLoadOption
--- @param specializations integer[]
local function DrawLoadTalent(container, talent, specializations)
	DrawTalentSelectOption(container, Addon.L["Talent selected"], specializations, talent, "talents")
end

-- --- @param container AceGUIContainer
-- --- @param talent Binding.TriStateLoadOption
-- --- @param classes string[]
-- local function Classic_DrawLoadTalent(container, talent, classes)
-- 	local items, order = Addon:Classic_GetLocalizedTalents(classes)
-- 	DrawTristateLoadOption(container, Addon.L["Talent selected"], items, order, talent)
-- end

--- @param container AceGUIContainer
--- @param talent Binding.MutliFieldLoadOption
--- @param specializations integer[]
local function DrawLoadPvPTalent(container, talent, specializations)
	DrawTalentSelectOption(container, Addon.L["PvP talent selected"], specializations, talent, "pvp_talents")
end

--- @param container AceGUIContainer
--- @param warMode Binding.LoadOption
local function DrawLoadWarMode(container, warMode)
	local items = {
		[true] = Addon.L["War Mode enabled"],
		[false] = Addon.L["War Mode disabled"]
	}

	local order = {
		true,
		false
	}

	DrawDropdownLoadOption(container, Addon.L["War Mode"], items, order, warMode)
end

--- @param container AceGUIContainer
--- @param playerNameRealm Binding.LoadOption
local function DrawLoadPlayerNameRealm(container, playerNameRealm)
	DrawEditFieldLoadOption(container, Addon.L["Player Name-Realm"], playerNameRealm)
end

--- @param container AceGUIContainer
--- @param spellKnown Binding.LoadOption
local function DrawLoadSpellKnown(container, spellKnown)
	DrawEditFieldLoadOption(container, Addon.L["Spell known"], spellKnown)
end

--- @param container AceGUIContainer
--- @param inGroup Binding.LoadOption
local function DrawLoadInGroup(container, inGroup)
	local items = {
		IN_GROUP_PARTY_OR_RAID = Addon.L["In a party or raid group"],
		IN_GROUP_PARTY = Addon.L["In a party"],
		IN_GROUP_RAID = Addon.L["In a raid group"],
		IN_GROUP_SOLO = Addon.L["Not in a group"]
	}

	local order = {
		"IN_GROUP_PARTY_OR_RAID",
		"IN_GROUP_PARTY",
		"IN_GROUP_RAID",
		"IN_GROUP_SOLO"
	}

	DrawDropdownLoadOption(container, Addon.L["In group"], items, order, inGroup)
end

--- @param container AceGUIContainer
--- @param playerInGroup Binding.LoadOption
local function DrawLoadPlayerInGroup(container, playerInGroup)
	DrawEditFieldLoadOption(container, Addon.L["Player in group"], playerInGroup)
end

--- @param container AceGUIContainer
--- @param instanceType Binding.TriStateLoadOption
local function DrawLoadInInstanceType(container, instanceType)
	local items = {
		NONE = Addon.L["No Instance"],
		PARTY = Addon.L["Dungeon"],
		RAID = Addon.L["Raid"]
	}

	local order = {
		"NONE",
		"PARTY",
		"RAID"
	}

	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.BC then
		items["PVP"] = Addon.L["Battleground"]
		items["ARENA"] = Addon.L["Arena"]

		table.insert(order, "PVP")
		table.insert(order, "ARENA")
	end

	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.MOP then
		items["SCENARIO"] = Addon.L["Scenario"]
		table.insert(order, 2, "SCENARIO")
	end

	DrawTristateLoadOption(container, Addon.L["Instance type"], items, order, instanceType)
end

--- @param container AceGUIContainer
--- @param zoneName Binding.LoadOption
local function DrawLoadZoneName(container, zoneName)
	local _, inputField = DrawEditFieldLoadOption(container, Addon.L["Zone name(s)"], zoneName)

	if inputField ~= nil then
		local tips = {
			string.format(Addon.L["Semicolon separated, use an exclamation mark (%s) to negate a zone condition, for example:"], "|r!|cffffffff"),
			"\n",
			string.format(Addon.L["%s will be active if you're not in Oribos"], "|r!" .. Addon.L["Oribos"] .. "|cffffffff"),
			string.format(Addon.L["%s will be active if you're in Durotar or Orgrimmar"], "|r" .. Addon.L["Durotar"] .. ";" .. Addon.L["Orgrimmar"] .. "|cffffffff")
		}

		RegisterTooltip(inputField, Addon.L["Zone name(s)"],  table.concat(tips, "\n"))
	end
end

--- @param container AceGUIContainer
--- @param equipped Binding.LoadOption
local function DrawLoadItemEquipped(container, equipped)
	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	local _, inputField = DrawEditFieldLoadOption(container, Addon.L["Item equipped"], equipped)

	if inputField ~= nil then
		local function OnTextChanged(_, _, value)
			local itemLink = string.match(value, "item[%-?%d:]+")
			local linkId = nil

			if not Addon:IsNilOrEmpty(itemLink) then
				local match = string.match(itemLink, "(%d+)")
				linkId = tonumber(match)
			end

			if linkId ~= nil and linkId > 0 then
				equipped.value = Addon:GetItemInfo(linkId)

				inputField:SetText(tostring(equipped.value))
				inputField:ClearFocus()

				Clicked:ReloadBinding(binding, true)
			end
		end

		inputField:SetCallback("OnTextChanged", OnTextChanged)

		RegisterTooltip(inputField, Addon.L["This will not update when in combat, so swapping weapons or shields during combat does not work."])
	end
end

--- @param container AceGUIContainer
--- @param binding Binding
local function DrawBindingLoadConditionsPage(container, binding)
	local load = binding.load

	DrawLoadNeverSelection(container, load)
	DrawLoadPlayerNameRealm(container, load.playerNameRealm)
	DrawLoadClass(container, load.class)
	DrawLoadRace(container, load.race)

	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.CATA then
		local classNames = GetTriStateLoadOptionValue(load.class)
		local specIndices = GetTriStateLoadOptionValue(load.specialization)
		local specializationIds = GetRelevantSpecializationIds(classNames, specIndices)

		DrawLoadSpecialization(container, load.specialization, classNames)
		DrawLoadTalent(container, load.talent --[[@as Binding.MutliFieldLoadOption]], specializationIds)

		if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.BFA then
			DrawLoadPvPTalent(container, load.pvpTalent, specializationIds)
			DrawLoadWarMode(container, load.warMode)
		end
	-- TODO: Re-enable this once talents are supported in Classic
	-- else
	-- 	local classNames = GetTriStateLoadOptionValue(load.class)

	-- 	Classic_DrawLoadSpecialization(container, load.specialization)
	-- 	Classic_DrawLoadTalent(container, load.talent --[[@as Binding.TriStateLoadOption]], classNames)
	end

	DrawLoadInInstanceType(container, load.instanceType)
	DrawLoadZoneName(container, load.zoneName)
	DrawLoadSpellKnown(container, load.spellKnown)
	DrawLoadInGroup(container, load.inGroup)
	DrawLoadPlayerInGroup(container, load.playerInGroup)
	DrawLoadItemEquipped(container, load.equipped)
end

-- Binding status page and components

--- @param container AceGUIContainer
--- @param binding Binding
local function DrawBindingStatusPage(container, binding)
	local function DrawStatus(group, bindings, interactionType)
		if #bindings == 0 then
			return
		end

		-- output of full macro
		do
			local MAX_MACRO_LENGTH = 255

			local widget = AceGUI:Create("ClickedReadOnlyMultilineEditBox") --[[@as ClickedReadOnlyMultilineEditBox]]
			local text = Addon:GetMacroForBindings(bindings, interactionType)
			local label = interactionType == Addon.InteractionType.HOVERCAST and Addon.L["Generated hovercast macro (%d/%d)"] or Addon.L["Generated macro (%d/%d)"]

			label = string.format(label, #text, MAX_MACRO_LENGTH)

			if #text > MAX_MACRO_LENGTH then
				label = Addon:GetColorizedString(label, "ffff0000")
			end

			widget:SetLabel(label)

			text = LibMacroSyntaxHighlight:Colorize(text)

			Addon.Media:UseMonoFont(widget)
			widget:SetText(text)
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

			if Addon:IsHovercastEnabled(binding) and Addon:IsHovercastEnabled(other) then
				table.insert(hovercast, other)
				valid = true
			end

			if Addon:IsMacroCastEnabled(binding) and Addon:IsMacroCastEnabled(other) then
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
			local widget = AceGUI:Create("Heading") --[[@as AceGUIHeading]]
			widget:SetFullWidth(true)
			widget:SetText(Addon.L["%d related binding(s)"]:format(#all - 1))

			container:AddChild(widget)
		end

		for _, other in ipairs(all) do
			if other ~= binding then
				do
					local function OnClick()
						tree:SelectByBindingOrGroup(other)
					end

					local name, icon = Addon:GetBindingNameAndIcon(other)

					local widget = AceGUI:Create("InteractiveLabel") --[[@as AceGUIInteractiveLabel]]
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

--- @param container AceGUIContainer
local function DrawGroup(container)
	local group = GetCurrentGroup()
	if group == nil then
		error("Cannot draw load option without a group")
	end

	local parent = Addon:GUI_InlineGroup()
	parent:SetTitle(Addon.L["Group Name and Icon"])
	container:AddChild(parent)

	-- name text field
	do
		local widget = Addon:GUI_EditBox("OnEnterPressed", group, "name")
		widget:SetFullWidth(true)

		parent:AddChild(widget)
	end

	-- icon field
	do
		local widget = Addon:GUI_EditBox("OnEnterPressed", group, "displayIcon")
		widget:SetRelativeWidth(0.7)

		parent:AddChild(widget)
	end

	do
		local function OpenIconPicker()
			showIconPicker = true
			tree:Redraw()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Select"])
		widget:SetCallback("OnClick", OpenIconPicker)
		widget:SetRelativeWidth(0.3)

		parent:AddChild(widget)
	end
end

-- Item templates

--- @param identifier string
local function CreateFromItemTemplate(identifier)
	--- @type DataObject?
	local item = nil

	if identifier == ITEM_TEMPLATE_SPELL then
		item = Clicked:CreateBinding()
		item.actionType = Addon.BindingTypes.SPELL
	elseif identifier == ITEM_TEMPLATE_SPELL_CC then
		item = Clicked:CreateBinding()
		item.actionType = Addon.BindingTypes.SPELL
		item.targets.hovercastEnabled = true
		item.targets.regularEnabled = false
	elseif identifier == ITEM_TEMPLATE_ITEM then
		item = Clicked:CreateBinding()
		item.actionType = Addon.BindingTypes.ITEM
	elseif identifier == ITEM_TEMPLATE_MACRO then
		item = Clicked:CreateBinding()
		item.actionType = Addon.BindingTypes.MACRO
	elseif identifier == ITEM_TEMPLATE_APPEND then
		item = Clicked:CreateBinding()
		item.actionType = Addon.BindingTypes.APPEND
	elseif identifier == ITEM_TEMPLATE_CANCELAURA then
		item = Clicked:CreateBinding()
		item.actionType = Addon.BindingTypes.CANCELAURA
	elseif identifier == ITEM_TEMPLATE_TARGET then
		item = Clicked:CreateBinding()
		item.actionType = Addon.BindingTypes.UNIT_SELECT
	elseif identifier == ITEM_TEMPLATE_MENU then
		item = Clicked:CreateBinding()
		item.actionType = Addon.BindingTypes.UNIT_MENU
	elseif identifier == ITEM_TEMPLATE_GROUP then
		item = Clicked:CreateGroup()
	elseif identifier == ITEM_TEMPLATE_IMPORT_SPELLBOOK then
		local pendingSpells = {}
		local pendingGroups = {}

		local groups = {}

		--- @param spell SpellLibrary.Spell
		local function DoesBindingExist(spell)
			for _, binding in Clicked:IterateConfiguredBindings() do
				if binding.actionType == Addon.BindingTypes.SPELL and binding.action.spellValue == spell.spellId and binding.parent ~= nil then
					local group = Clicked:GetByUid(binding.parent)

					-- this spell already exists in the database, however we also want to make sure its in one of the auto-generated groups
					-- before excluding it
					if group ~= nil and group.name == spell.tabName and group.displayIcon == spell.tabIcon then
						return true
					end
				end
			end

			return false
		end

		for _, spell in Addon.SpellLibrary:GetSpells() do
			if not DoesBindingExist(spell) then
				pendingSpells[spell.spellId] = true
				pendingGroups[spell.tabName] = spell.tabIcon
			end
		end

		for name, icon in pairs(pendingGroups) do
			for _, g in Clicked:IterateGroups() do
				if g.name == name and g.displayIcon == icon then
					groups[name] = g.uid
					break
				end
			end

			if groups[name] == nil then
				local group = Clicked:CreateGroup()
				group.name = name
				group.displayIcon = icon

				groups[name] = group.uid
			end
		end

		for spellId in pairs(pendingSpells) do
			local spell = Addon.SpellLibrary:GetSpellById(spellId)

			if spell ~= nil then
				local specIndex = Addon:GetSpecIndexFromId(spell.specId)

				local binding = Clicked:CreateBinding()
				binding.actionType = Addon.BindingTypes.SPELL
				binding.parent = groups[spell.tabName]
				binding.action.spellValue = spellId

				binding.load.class.selected = 1
				binding.load.class.single = select(2, UnitClass("player"))

				if specIndex ~= nil then
					binding.load.specialization.selected = 1
					binding.load.specialization.single = specIndex
				end
			end
		end
	elseif identifier == ITEM_TEMPLATE_IMPORT_ACTIONBAR then
		local group

		if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.CATA then
			local _, name, icon

			if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.MOP then
				_, name, _, icon = GetSpecializationInfo(GetSpecialization())
			else
				local class = select(3, UnitClass("player"))
				_, name, _, icon = GetSpecializationInfoForClassID(class, GetPrimaryTalentTree())
			end

			--- @type Group
			for _, g in Clicked:IterateGroups() do
				if g.name == name and g.displayIcon == icon then
					group = g
					break
				end
			end

			if group == nil then
				group = Clicked:CreateGroup()
				group.name = name
				group.displayIcon = icon
			end
		end

		local function IsDuplicate(key, action, id)
			for _, binding in Clicked:IterateConfiguredBindings() do
				if binding.keybind == key or key == nil and binding.keybind == "" then
					if action == "spell" and binding.action.spellValue == id then
						return true
					end

					if action == "item" and binding.action.itemValue == id then
						return true
					end

					if action == "macro" and binding.action.macroValue == GetMacroBody(id) then
						return true
					end
				end
			end

			return false
		end

		local function Register(key, action, id)
			if action == nil or IsDuplicate(key, action, id) then
				return
			end

			local binding

			if action == "spell" then
				binding = Clicked:CreateBinding()
				binding.actionType = Addon.BindingTypes.SPELL
				binding.action.spellValue = id
			elseif action == "item" then
				binding = Clicked:CreateBinding()
				binding.actionType = Addon.BindingTypes.ITEM
				binding.action.itemValue = id
			elseif action == "macro" then
				binding = Clicked:CreateBinding()
				binding.actionType = Addon.BindingTypes.MACRO
				binding.action.macroValue = GetMacroBody(id) or ""
				binding.action.macroName = GetMacroInfo(id)
				binding.action.macroIcon = select(2, GetMacroInfo(id))
			end

			if binding ~= nil then
				if key ~= nil then
					binding.keybind = key
				end

				if group ~= nil then
					binding.parent = group.uid
				end

				binding.load.class.selected = 1
				binding.load.class.single = select(2, UnitClass("player"))

				if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.MOP then
					binding.load.specialization.selected = 1
					binding.load.specialization.single = GetSpecialization()
				elseif Addon.EXPANSION_LEVEL >= Addon.EXPANSION.CATA then
					binding.load.specialization.selected = 1
					binding.load.specialization.single = GetPrimaryTalentTree()
				end
			end
		end

		-- Primary action bar
		for keyNumber = 1, 12 do
			Register(GetBindingKey("ACTIONBUTTON" .. keyNumber), GetActionInfo(keyNumber))
		end

		-- Shapeshift forms
		for form = 1, GetNumShapeshiftForms() do
			local spell = select(4, GetShapeshiftFormInfo(form))
			Register(GetBindingKey("SHAPESHIFTBUTTON" .. form), "spell", spell)
		end

		-- Pet buttons
		for petAction = 1, NUM_PET_ACTION_SLOTS do
			local spell = select(7, GetPetActionInfo(petAction))

			if spell ~= nil then
				Register(GetBindingKey("BONUSACTIONBUTTON" .. petAction), "spell", spell)
			end
		end

		-- Bartender4 integration
		if _G["Bartender4"] then
			for actionBarNumber = 2, 6 do
				for keyNumber = 1, 12 do
					local actionBarButtonId = (actionBarNumber - 1) * 12 + keyNumber
					local bindingKeyName = "CLICK BT4Button" .. actionBarButtonId .. ":LeftButton"

					Register(GetBindingKey(bindingKeyName), GetActionInfo(actionBarButtonId))
				end
			end
		-- ElvUI integration
		elseif _G["ElvUI"] and _G["ElvUI_Bar1Button1"] then
			for i = 2, 6 do
				for b = 1, 12 do
					local btn = _G["ElvUI_Bar" .. i .. "Button" .. b ]

					if tonumber(btn._state_action) then
						Register(GetBindingKey(btn.keyBoundTarget), GetActionInfo(tonumber(btn._state_action)))
					end
				end
			end
		-- Default
		else
			for i = 25, 36 do
				Register(GetBindingKey("MULTIACTIONBAR3BUTTON" .. i - 24), GetActionInfo(i))
			end

			for i = 37, 48 do
				Register(GetBindingKey("MULTIACTIONBAR4BUTTON" .. i - 36), GetActionInfo(i))
			end

			for i = 49, 60 do
				Register(GetBindingKey("MULTIACTIONBAR2BUTTON" .. i - 48), GetActionInfo(i))
			end

			for i = 61, 72 do
				Register(GetBindingKey("MULTIACTIONBAR1BUTTON" .. i - 60), GetActionInfo(i))
			end
		end

		Clicked:ReloadBindings(true)
	end

	if item ~= nil then
		if not Addon:IsGroup(item) then
			Clicked:ReloadBinding(item --[[@as Binding]], true)
		end

		tree:SelectByBindingOrGroup(item)
	end

	Addon:BindingConfig_Redraw()
end

--- @param container AceGUIContainer
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

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Create"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.2)

		container:AddChild(widget)
	end
end

-- Main binding frame

--- @param container AceGUIContainer
local function DrawBinding(container)
	local binding = GetCurrentBinding()
	if binding == nil then
		error("Cannot draw load option without a binding")
	end

	-- keybinding button
	do
		local function HandleAutomaticBinds(frame)
			local tooltipText = Addon.L["Click and press a key to bind, or right click to unbind."]

			if Addon.db.profile.options.bindUnassignedModifiers and Addon:IsUnmodifiedKeybind(binding.keybind) then
				local automaticBindings = Addon:GetUnusedModifierKeyKeybinds(binding.keybind, Addon:GetActiveBindings())

				if #automaticBindings > 0 then
					frame:SetMarker(true)
					tooltipText = tooltipText .. "\n\n" .. Addon.L["Key combination also bound in combination with unassigned modifiers"]
				end
			end

			RegisterTooltip(frame, tooltipText)
		end

		local function OnPostValueChanged(frame, value)
			Addon:EnsureSupportedTargetModes(binding.targets, value, binding.actionType)
			HandleAutomaticBinds(frame)
		end

		local widget = Addon:GUI_KeybindingButton(binding, "keybind", binding)
		Addon:GUI_SetPostValueChanged(widget, OnPostValueChanged)

		HandleAutomaticBinds(widget)

		container:AddChild(widget)
	end

	-- self-cast text
	if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.DF then
		local selfCastModifier = GetModifiedClick("SELFCAST")

		if selfCastModifier ~= "NONE" then
			local modifiers = Addon:GetKeybindModifiersAndKey(binding.keybind)

			if #modifiers == 1 and modifiers[1] == selfCastModifier then
				local box = Addon:GUI_InlineGroup()
				box:SetFullWidth(true)

				local message = string.format(Addon.L["The behavior of the self-cast modifier has changed in Dragonflight, bindings using the '%s' key modifier may not work correctly. It is recommended to disable it by setting it to 'NONE' in the options menu."], selfCastModifier)
				local widget = Addon:GUI_Label(message, "medium")
				widget:SetFullWidth(true)

				box:AddChild(widget)
				container:AddChild(box)
			end
		end
	end

	-- tabs
	do
		local function OnGroupSelected(c, _, group)
			local scrollFrame = AceGUI:Create("ScrollFrame") --[[@as AceGUIScrollFrame]]
			scrollFrame:SetLayout("Flow")

			if prevBinding ~= GetCurrentBinding() or group ~= "load_conditions" then
				prevBinding = GetCurrentBinding()
				showTalentPanel = nil
			end

			c:ReleaseChildren()
			c:AddChild(scrollFrame)

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
					text = Addon.L["Action"]
				elseif availableTab == "target" then
					text = Addon.L["Targets"]
				elseif availableTab == "load_conditions" then
					text = Addon.L["Load conditions"]
				elseif availableTab == "macro_conditions" then
					text = Addon.L["Macro conditions"]
				elseif availableTab == "status" then
					text = Addon.L["Status"]
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

		tab.widget = Addon:GUI_TabGroup()
		tab.widget:SetTabs(CreateTabGroup(availableTabs))
		tab.widget:SetCallback("OnGroupSelected", OnGroupSelected)
		tab.widget:SetStatusTable(tab)
		tab.widget:SelectTab(tab.selected)

		container:AddChild(tab.widget)
	end
end

--- @param container AceGUIContainer
local function DrawItemTemplateSelector(container)
	local scrollFrame = AceGUI:Create("ScrollFrame") --[[@as AceGUIScrollFrame]]
	scrollFrame:SetLayout("Flow")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)

	container:AddChild(scrollFrame)

	do
		local widget = Addon:GUI_Label(Addon.L["Quick start"], "large")
		widget:SetFullWidth(true)

		scrollFrame:AddChild(widget)
	end

	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_IMPORT_SPELLBOOK, Addon.L["Automatically import from spellbook"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_IMPORT_ACTIONBAR, Addon.L["Automatically import from action bars"])

	do
		local widget = Addon:GUI_Label("\n" .. Addon.L["Create a new binding"], "large")
		widget:SetFullWidth(true)

		scrollFrame:AddChild(widget)
	end

	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_GROUP, Addon.L["Group"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_SPELL, Addon.L["Cast a spell"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_SPELL_CC, Addon.L["Cast a spell on a unit frame"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_ITEM, Addon.L["Use an item"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_CANCELAURA, Addon.L["Cancel an aura"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_TARGET, Addon.L["Target the unit"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_MENU, Addon.L["Open the unit menu"])

	do
		local widget = Addon:GUI_Label("\n" .. Addon.L["Advanced binding types"], "large")
		widget:SetFullWidth(true)

		scrollFrame:AddChild(widget)
	end

	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_MACRO, Addon.L["Run a macro"])
	DrawItemTemplate(scrollFrame, ITEM_TEMPLATE_APPEND, Addon.L["Append a binding segment"])

	scrollFrame:DoLayout()
end

-- Main frame

--- @param container AceGUIContainer
local function DrawHeader(container)
	local line = AceGUI:Create("ClickedSimpleGroup") --[[@as ClickedSimpleGroup]]
	line:SetFullWidth(true)
	line:SetLayout("Table")
	line:SetUserData("table", {
		columns = { 0, 0, 1, 0 },
		spaceH = 1
	})

	container:AddChild(line)

	-- create binding button
	do
		local function OnClick()
			tree:SelectByValue("")
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["New"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)
	end

	-- import button
	do
		local function OnClick()
			Addon.ImportFrame:ImportBindingOrGroup()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Import"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetAutoWidth(true)

		line:AddChild(widget)
	end

	-- Spacer
	do
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetText("")

		line:AddChild(widget)
	end

	-- Visualize button
	local function OnClick()
		Addon.KeyVisualizer:Open()
	end

	local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
	widget:SetText(Addon.L["Show on keyboard"])
	widget:SetCallback("OnClick", OnClick)
	widget:SetAutoWidth(true)

	line:AddChild(widget)
end

--- @param container AceGUIContainer
local function DrawTreeContainer(container)
	local binding = GetCurrentBinding()
	local group = GetCurrentGroup()

	container:ReleaseChildren()

	if showIconPicker then
		local data = binding ~= nil and binding.action or group --[[@as any]]
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

--- @param container AceGUIContainer
local function DrawTreeView(container)
	-- tree view
	do
		tree = AceGUI:Create("ClickedTreeGroup") --[[@as ClickedTreeGroup]]
		tree:SetLayout("Flow")
		tree:SetFullWidth(true)
		tree:SetFullHeight(true)
		tree:SetCallback("OnGroupSelected", DrawTreeContainer)

		container:AddChild(tree)
	end
end

-- Private addon API

--- Check if the binding configuration window is open.
---
--- @return boolean `true` if it is currently open; `false` otherwise.
function Addon:BindingConfig_IsOpen()
	return root ~= nil and root:IsVisible()
end

function Addon:BindingConfig_Open()
	if self:BindingConfig_IsOpen() then
		return
	end

	-- root frame
	do
		local function OnClose(container)
			AceGUI:Release(container)

			showTalentPanel = nil
			root = nil
		end

		local function OnReceiveDrag()
			local infoType, p2, _, p4 = GetCursorInfo()
			local bindingType = nil
			local id = nil

			if infoType == "item" then
				bindingType = Addon.BindingTypes.ITEM
				id = p2
			elseif infoType == "spell" then
				bindingType = Addon.BindingTypes.SPELL
				id = p4
			elseif infoType == "petaction" then
				bindingType = Addon.BindingTypes.SPELL
				id = p2
			end

			if bindingType ~= nil and id ~= nil then
				local binding = Clicked:CreateBinding()
				binding.actionType = bindingType
				Addon:SetBindingValue(binding, id)

				Clicked:ReloadBinding(binding, true)
				tree:SelectByBindingOrGroup(binding)

				ClearCursor()
			end
		end

		root = AceGUI:Create("ClickedFrame") --[[@as ClickedFrame]]
		root:SetCallback("OnClose", OnClose)
		root:SetCallback("OnReceiveDrag", OnReceiveDrag)
		root:SetTitle(Addon.L["Clicked Binding Configuration"])
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

--- Close the binding configuration window if it's open.
---
--- @return boolean `true` if the window was closed; `false` otherwise.
function Addon:BindingConfig_Close()
	if not self:BindingConfig_IsOpen() then
		return false
	end

	root:Hide()
	return true
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
	if not self:BindingConfig_IsOpen() then
		return
	end

	root:SetStatusText(string.format("%s | %s", Clicked.VERSION, Addon.db:GetCurrentProfile()))
	tree:ConstructTree()
end

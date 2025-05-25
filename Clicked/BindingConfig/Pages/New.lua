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

local AceGUI = LibStub("AceGUI-3.0")

-- Deprecated in 5.5.0
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
-- Deprecated in 5.5.0
local GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo or GetSpecializationInfo

--- @class ClickedInternal
local Addon = select(2, ...)

local ItemTemplate = {
	GROUP = 0,
	BINDING_CAST_SPELL = 10,
	BINDING_CAST_SPELL_CLICKCAST = 11,
	BINDING_USE_ITEM = 12,
	BINDING_RUN_MACRO = 13,
	BINDING_RUN_MACRO_APPEND = 14,
	BINDING_CANCELAURA = 15,
	BINDING_UNIT_TARGET = 16,
	BINDING_UNIT_MENU = 17,
	IMPORT_SPELLBOOK = 100,
	IMPORT_ACTIONBAR = 101,
	IMPORT_MACROS = 102
}

--- @return Group
local function CreateGroup()
	local group = Clicked:CreateGroup()

	Addon.BindingConfig.Window:RedrawTree()
	return group
end

--- @param type integer
--- @param parent DataObject?
--- @return Binding
local function CreateBinding(type, parent)
	local binding = Clicked:CreateBinding()

	if type == ItemTemplate.BINDING_CAST_SPELL then
		binding.actionType = Clicked.ActionType.SPELL
	elseif type == ItemTemplate.BINDING_CAST_SPELL_CLICKCAST then
		binding.actionType = Clicked.ActionType.SPELL
		binding.targets.hovercastEnabled = true
		binding.targets.regularEnabled = false
	elseif type == ItemTemplate.BINDING_USE_ITEM then
		binding.actionType = Clicked.ActionType.ITEM
	elseif type == ItemTemplate.BINDING_RUN_MACRO then
		binding.actionType = Clicked.ActionType.MACRO
	elseif type == ItemTemplate.BINDING_RUN_MACRO_APPEND then
		binding.actionType = Clicked.ActionType.APPEND
	elseif type == ItemTemplate.BINDING_CANCELAURA then
		binding.actionType = Clicked.ActionType.CANCELAURA
	elseif type == ItemTemplate.BINDING_UNIT_TARGET then
		binding.actionType = Clicked.ActionType.UNIT_SELECT
	elseif type == ItemTemplate.BINDING_UNIT_MENU then
		binding.actionType = Clicked.ActionType.UNIT_MENU
	end

	if parent ~= nil then
		if parent.type == Clicked.DataObjectType.BINDING then
			--- @cast parent Binding
			binding.parent = parent.parent
		elseif parent.type == Clicked.DataObjectType.GROUP then
			binding.parent = parent.uid
		end
	end

	Addon:ReloadBinding(binding, true)
	return binding
end

--- @return { [string]: Binding[] }
local function CreateActionBarBindingCache()
	--- @type { [string]: Binding[] }
	local result = {}

	for _, binding in Clicked:IterateConfiguredBindings() do
		result[binding.keybind] = result[binding.keybind] or {}
		table.insert(result[binding.keybind], binding)
	end

	return result
end

--- @return { name: string, content: string }[]
local function CreateMacroBindingCache()
	--- @type { name: string, content: string }[]
	local result = {}

	for _, binding in Clicked:IterateConfiguredBindings() do
		if binding.actionType == Clicked.ActionType.MACRO then
			table.insert(result, {
				name = binding.action.macroName,
				content = binding.action.macroValue
			})
		end
	end

	return result
end

--- @param cache { [string]: Binding[] }
--- @param spell SpellLibraryResult
local function DoesActionBarBindingExist(cache, spell)
	local key = spell.key or ""
	local collection = cache[key] or {}

	for _, binding in ipairs(collection) do
		if spell.type == "SPELL" and binding.actionType == Clicked.ActionType.SPELL then
			--- @cast spell SpellLibrarySpellResult
			if binding.action.spellValue == spell.spellId then
				return true
			end
		elseif spell.type == "ITEM" and binding.actionType == Clicked.ActionType.ITEM then
			--- @cast spell SpellLibraryItemResult
			if binding.action.itemValue == spell.itemId then
				return true
			end
		elseif spell.type == "MACRO" and binding.actionType == Clicked.ActionType.MACRO then
			--- @cast spell SpellLibraryMacroResult
			if binding.action.macroName == spell.name and binding.action.macroValue == spell.content then
				return true
			end
		end
	end

	return false
end

--- @param cache { name: string, content: string }[]
--- @param spell SpellLibraryMacroResult
local function DoesMacroBindingExist(cache, spell)
	for _, item in ipairs(cache) do
		if item.name == spell.name and item.content == spell.content then
			return true
		end
	end

	return false
end

--- @param name? string
--- @param icon? integer|string
--- @param disableAutoCreate? boolean
--- @return integer?
local function FindGroupId(name, icon, disableAutoCreate)
	if name == nil and icon == nil then
		return nil
	end

	for _, group in Clicked:IterateGroups() do
		if group.name == name and group.displayIcon == icon then
			return group.uid
		end
	end

	if not disableAutoCreate and name ~= nil and icon ~= nil then
		local group = Clicked:CreateGroup()
		group.name = name
		group.displayIcon = icon
		return group.uid
	end

	return nil
end

--- @param spell SpellLibrarySpellResult
--- @param parent? integer
local function DoesSpellBookBindingExist(spell, parent)
	for _, binding in ipairs(Clicked:GetByActionType(Clicked.ActionType.SPELL)) do
		if binding.action.spellValue == spell.spellId and binding.parent == parent then
			return true
		end
	end

	return false
end

--- @param importClassAbilitiesPerSpec boolean
--- @return Binding[]
local function ImportSpellbook(importClassAbilitiesPerSpec)
	--- @type Binding[]
	local result = {}

	--- @type SpellLibrarySpellResult[]
	local genericSpells = {}

	for _, spell in pairs(Addon.SpellLibrary:GetSpells()) do
		if importClassAbilitiesPerSpec and spell.specId == nil then
			table.insert(genericSpells, spell)
		else
			if not DoesSpellBookBindingExist(spell, FindGroupId(spell.tabName, spell.tabIcon, true)) then
				local binding = Clicked:CreateBinding()
				table.insert(result, binding)

				binding.actionType = Clicked.ActionType.SPELL
				binding.parent = FindGroupId(spell.tabName, spell.tabIcon)
				binding.action.spellValue = spell.spellId

				binding.load.class.selected = 1
				binding.load.class.single = select(2, UnitClass("player"))

				local spec = Addon:GetSpecIndexFromId(spell.specId)
				if spec ~= nil then
					binding.load.specialization.selected = 1
					binding.load.specialization.single = spec
				end

				Addon:ReloadBinding(binding, true)
			end
		end
	end



	if importClassAbilitiesPerSpec and #genericSpells > 0 then
		--- @type { specId: integer, groupId: integer }[]
		local specs = {}

		for i = 1, GetNumSpecializations() do
			local _, name, _, icon = GetSpecializationInfo(i)

			table.insert(specs, {
				specId = i,
				groupId = FindGroupId(name, icon, true)
			})
		end

		for _, spell in ipairs(genericSpells) do
			for _, spec in ipairs(specs) do
				if not DoesSpellBookBindingExist(spell, spec.groupId) then
					local binding = Clicked:CreateBinding()
					table.insert(result, binding)

					binding.actionType = Clicked.ActionType.SPELL
					binding.parent = spec.groupId
					binding.action.spellValue = spell.spellId

					binding.load.class.selected = 1
					binding.load.class.single = select(2, UnitClass("player"))

					binding.load.specialization.selected = 1
					binding.load.specialization.single = spec.specId

					Addon:ReloadBinding(binding, true)
				end
			end
		end
	end

	return result
end

--- @return Binding[]
local function ImportActionbar()
	local cache = CreateActionBarBindingCache()

	--- @type Binding[]
	local result = {}

	for _, spell in ipairs(Addon.SpellLibrary:GetActionBarSpells()) do
		if not DoesActionBarBindingExist(cache, spell) then
			local binding = Clicked:CreateBinding()
			table.insert(result, binding)

			if spell.key ~= nil then
				binding.keybind = spell.key
			end

			if spell.type == "SPELL" then
				--- @cast spell SpellLibrarySpellResult
				binding.parent = FindGroupId(spell.tabName, spell.tabIcon)

				binding.load.class.selected = 1
				binding.load.class.single = select(2, UnitClass("player"))

				if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
					binding.load.specialization.selected = 1
					binding.load.specialization.single = GetSpecialization()
				elseif Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
					binding.load.specialization.selected = 1
					binding.load.specialization.single = GetPrimaryTalentTree()
				end

				binding.actionType = Clicked.ActionType.SPELL
				binding.action.spellValue = spell.spellId
			elseif spell.type == "ITEM" then
				--- @cast spell SpellLibraryItemResult
				binding.actionType = Clicked.ActionType.ITEM
				binding.action.itemValue = spell.itemId
			elseif spell.type == "MACRO" then
				--- @cast spell SpellLibraryMacroResult
				binding.actionType = Clicked.ActionType.MACRO
				binding.action.macroName = spell.name
				binding.action.macroIcon = spell.icon
				binding.action.macroValue = spell.content
			end

			cache[binding.keybind] = cache[binding.keybind] or {}
			table.insert(cache[binding.keybind], binding)

			Addon:ReloadBinding(binding, true)
		end
	end

	return result
end

--- @return Binding[]
local function ImportMacros()
	local cache = CreateMacroBindingCache()

	--- @type Binding[]
	local result = {}

	for _, spell in ipairs(Addon.SpellLibrary:GetMacroSpells()) do
		if not DoesMacroBindingExist(cache, spell) then
			local binding = Clicked:CreateBinding()
			table.insert(result, binding)

			binding.actionType = Clicked.ActionType.MACRO
			binding.action.macroName = spell.name
			binding.action.macroIcon = spell.icon
			binding.action.macroValue = spell.content

			table.insert(cache, {
				name = spell.name,
				content = spell.content
			})

			Addon:ReloadBinding(binding, true)
		end
	end

	return result
end

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigNewPage : BindingConfigPage
--- @field private importClassAbilitiesPerSpec boolean
Addon.BindingConfig.NewPage = {
	keepTreeSelection = true,
	importClassAbilitiesPerSpec = false
}

--- @protected
function Addon.BindingConfig.NewPage:Redraw()
	local scrollFrame = AceGUI:Create("ScrollFrame") --[[@as AceGUIScrollFrame]]
	scrollFrame:SetLayout("Flow")
	scrollFrame:SetFullWidth(true)
	scrollFrame:SetFullHeight(true)

	do
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetText(Addon.L["Quick start"])
		widget:SetFontObject(GameFontHighlightLarge)
		widget:SetFullWidth(true)
		scrollFrame:AddChild(widget)
	end

	self:CreateTemplateButton(scrollFrame, ItemTemplate.IMPORT_SPELLBOOK, Addon.L["Automatically import from spellbook"])

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.MOP then
		local label = AceGUI:Create("Label") --[[@as AceGUILabel]]
		label:SetText(Addon.L["Import class abilities per specialization"])
		label:SetRelativeWidth(0.79)
		scrollFrame:AddChild(label)

		---@param value boolean
		local function OnValueChanged(_, _, value)
			self.importClassAbilitiesPerSpec = value
		end

		local checkbox = AceGUI:Create("ClickedCheckBox") --[[@as ClickedCheckBox]]
		checkbox:SetRelativeWidth(0.2)
		checkbox:SetCallback("OnValueChanged", OnValueChanged)
		scrollFrame:AddChild(checkbox)
	end

	self:CreateTemplateButton(scrollFrame, ItemTemplate.IMPORT_ACTIONBAR, Addon.L["Automatically import from action bars"])
	self:CreateTemplateButton(scrollFrame, ItemTemplate.IMPORT_MACROS, Addon.L["Automatically import from macros"])

	do
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetText("\n" .. Addon.L["Create a new binding"])
		widget:SetFontObject(GameFontHighlightLarge)
		widget:SetFullWidth(true)
		scrollFrame:AddChild(widget)
	end

	self:CreateTemplateButton(scrollFrame, ItemTemplate.GROUP, Addon.L["Group"])
	self:CreateTemplateButton(scrollFrame, ItemTemplate.BINDING_CAST_SPELL, Addon.L["Cast a spell"])
	self:CreateTemplateButton(scrollFrame, ItemTemplate.BINDING_CAST_SPELL_CLICKCAST, Addon.L["Cast a spell on a unit frame"])
	self:CreateTemplateButton(scrollFrame, ItemTemplate.BINDING_USE_ITEM, Addon.L["Use an item"])
	self:CreateTemplateButton(scrollFrame, ItemTemplate.BINDING_CANCELAURA, Addon.L["Cancel an aura"])
	self:CreateTemplateButton(scrollFrame, ItemTemplate.BINDING_UNIT_TARGET, Addon.L["Target the unit"])
	self:CreateTemplateButton(scrollFrame, ItemTemplate.BINDING_UNIT_MENU, Addon.L["Open the unit menu"])

	do
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetText("\n" .. Addon.L["Advanced binding types"])
		widget:SetFontObject(GameFontHighlightLarge)
		widget:SetFullWidth(true)
		scrollFrame:AddChild(widget)
	end

	self:CreateTemplateButton(scrollFrame, ItemTemplate.BINDING_RUN_MACRO, Addon.L["Run a macro"])
	self:CreateTemplateButton(scrollFrame, ItemTemplate.BINDING_RUN_MACRO_APPEND, Addon.L["Append a binding segment"])

	self.container:AddChild(scrollFrame)
end

--- @private
--- @param container AceGUIContainer
--- @param type integer
--- @param label string
function Addon.BindingConfig.NewPage:CreateTemplateButton(container, type, label)
	do
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetText(label)
		widget:SetFontObject(GameFontHighlight)
		widget:SetRelativeWidth(0.79)

		container:AddChild(widget)
	end

	do
		local function OnClick()
			self:CreateItem(type)
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
		widget:SetText(Addon.L["Create"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.2)

		container:AddChild(widget)
	end
end

--- @private
--- @param type integer
function Addon.BindingConfig.NewPage:CreateItem(type)
	--- @type DataObject?
	local target = nil

	if type == ItemTemplate.GROUP then
		target = CreateGroup()
	elseif type >= ItemTemplate.BINDING_CAST_SPELL and type <= ItemTemplate.BINDING_UNIT_MENU then
		target = CreateBinding(type, self.controller:GetSelection()[1])
	elseif type == ItemTemplate.IMPORT_SPELLBOOK then
		target = ImportSpellbook(self.importClassAbilitiesPerSpec)
	elseif type == ItemTemplate.IMPORT_ACTIONBAR then
		target = ImportActionbar()
	elseif type == ItemTemplate.IMPORT_MACROS then
		target = ImportMacros()
	end

	if target ~= nil then
		self.controller:Select(target.uid, true)
	end
end

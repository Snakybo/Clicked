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

--- @class ClickedInternal
local Addon = select(2, ...)

--- @enum BindingConfigNewPageItemTemplate
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

--- @param type BindingConfigNewPageItemTemplate
--- @return Binding
local function CreateBinding(type)
	local binding = Clicked:CreateBinding()

	if type == ItemTemplate.BINDING_CAST_SPELL then
		binding.actionType = Addon.BindingTypes.SPELL
	elseif type == ItemTemplate.BINDING_CAST_SPELL_CLICKCAST then
		binding.actionType = Addon.BindingTypes.SPELL
		binding.targets.hovercastEnabled = true
		binding.targets.regularEnabled = false
	elseif type == ItemTemplate.BINDING_USE_ITEM then
		binding.actionType = Addon.BindingTypes.ITEM
	elseif type == ItemTemplate.BINDING_RUN_MACRO then
		binding.actionType = Addon.BindingTypes.MACRO
	elseif type == ItemTemplate.BINDING_RUN_MACRO_APPEND then
		binding.actionType = Addon.BindingTypes.APPEND
	elseif type == ItemTemplate.BINDING_CANCELAURA then
		binding.actionType = Addon.BindingTypes.CANCELAURA
	elseif type == ItemTemplate.BINDING_UNIT_TARGET then
		binding.actionType = Addon.BindingTypes.UNIT_SELECT
	elseif type == ItemTemplate.BINDING_UNIT_MENU then
		binding.actionType = Addon.BindingTypes.UNIT_MENU
	end

	Clicked:ReloadBinding(binding, true)
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
		if binding.actionType == Addon.BindingTypes.MACRO then
			table.insert(result, {
				name = binding.action.macroName,
				content = binding.action.macroValue
			})
		end
	end

	return result
end

--- @param spell SpellLibrarySpellResult
local function DoesSpellBookBindingExist(spell)
	for _, binding in ipairs(Clicked:GetByActionType(Addon.BindingTypes.SPELL)) do
		if binding.action.spellValue == spell.spellId then
			return true
		end
	end

	return false
end

--- @param cache { [string]: Binding[] }
--- @param spell SpellLibraryResult
local function DoesActionBarBindingExist(cache, spell)
	local key = spell.key or ""
	local collection = cache[key] or {}

	for _, binding in ipairs(collection) do
		if spell.type == Addon.SpellLibrary.ResultType.SPELL and binding.actionType == Addon.BindingTypes.SPELL then
			--- @cast spell SpellLibrarySpellResult
			if binding.action.spellValue == spell.spellId then
				return true
			end
		elseif spell.type == Addon.SpellLibrary.ResultType.ITEM and binding.actionType == Addon.BindingTypes.ITEM then
			--- @cast spell SpellLibraryItemResult
			if binding.action.itemValue == spell.itemId then
				return true
			end
		elseif spell.type == Addon.SpellLibrary.ResultType.MACRO and binding.actionType == Addon.BindingTypes.MACRO then
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
--- @return integer?
local function FindGroupId(name, icon)
	if name == nil and icon == nil then
		return nil
	end

	for _, group in Clicked:IterateGroups() do
		if group.name == name and group.displayIcon == icon then
			return group.uid
		end
	end

	if name ~= nil and icon ~= nil then
		local group = Clicked:CreateGroup()
		group.name = name
		group.displayIcon = icon
		return group.uid
	end

	return nil
end

--- @return Binding?
local function ImportSpellbook()
	--- @type Binding?
	local first = nil

	for _, spell in pairs(Addon.SpellLibrary:GetSpells()) do
		if not DoesSpellBookBindingExist(spell) then
			local binding = Clicked:CreateBinding()
			first = first or binding

			binding.actionType = Addon.BindingTypes.SPELL
			binding.parent = FindGroupId(spell.tabName, spell.tabIcon)
			binding.action.spellValue = spell.spellId

			binding.load.class.selected = 1
			binding.load.class.single = select(2, UnitClass("player"))

			local spec = Addon:GetSpecIndexFromId(spell.specId)
			if spec ~= nil then
				binding.load.specialization.selected = 1
				binding.load.specialization.single = spec
			end
		end
	end

	if first ~= nil then
		Clicked:ReloadBindings(true)
	end

	return first
end

--- @return Binding?
local function ImportActionbar()
	local cache = CreateActionBarBindingCache()

	--- @type Binding?
	local first = nil

	for _, spell in ipairs(Addon.SpellLibrary:GetActionBarSpells()) do
		if not DoesActionBarBindingExist(cache, spell) then
			local binding = Clicked:CreateBinding()
			first = first or binding

			if spell.key ~= nil then
				binding.keybind = spell.key
			end

			if spell.type == Addon.SpellLibrary.ResultType.SPELL then
				--- @cast spell SpellLibrarySpellResult
				binding.parent = FindGroupId(spell.tabName, spell.tabIcon)

				binding.load.class.selected = 1
				binding.load.class.single = select(2, UnitClass("player"))

				if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.MOP then
					binding.load.specialization.selected = 1
					binding.load.specialization.single = GetSpecialization()
				elseif Addon.EXPANSION_LEVEL >= Addon.EXPANSION.CATA then
					binding.load.specialization.selected = 1
					binding.load.specialization.single = GetPrimaryTalentTree()
				end

				binding.actionType = Addon.BindingTypes.SPELL
				binding.action.spellValue = spell.spellId
			elseif spell.type == Addon.SpellLibrary.ResultType.ITEM then
				--- @cast spell SpellLibraryItemResult
				binding.actionType = Addon.BindingTypes.ITEM
				binding.action.itemValue = spell.itemId
			elseif spell.type == Addon.SpellLibrary.ResultType.MACRO then
				--- @cast spell SpellLibraryMacroResult
				binding.actionType = Addon.BindingTypes.MACRO
				binding.action.macroName = spell.name
				binding.action.macroIcon = spell.icon
				binding.action.macroValue = spell.content
			end

			cache[binding.keybind] = cache[binding.keybind] or {}
			table.insert(cache[binding.keybind], binding)
		end
	end

	if first ~= nil then
		Clicked:ReloadBindings(true)
	end

	return first
end

--- @return Binding?
local function ImportMacros()
	local cache = CreateMacroBindingCache()

	--- @type Binding?
	local first = nil

	for _, spell in ipairs(Addon.SpellLibrary:GetMacroSpells()) do
		if not DoesMacroBindingExist(cache, spell) then
			local binding = Clicked:CreateBinding()
			first = first or binding

			binding.actionType = Addon.BindingTypes.MACRO
			binding.action.macroName = spell.name
			binding.action.macroIcon = spell.icon
			binding.action.macroValue = spell.content

			table.insert(cache, {
				name = spell.name,
				content = spell.content
			})
		end
	end

	if first ~= nil then
		Clicked:ReloadBindings(true)
	end

	return first
end

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigNewPage : BindingConfigPage
Addon.BindingConfig.NewPage = {}

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
--- @param type BindingConfigNewPageItemTemplate
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
--- @param type BindingConfigNewPageItemTemplate
function Addon.BindingConfig.NewPage:CreateItem(type)
	--- @type DataObject?
	local target = nil

	if type == ItemTemplate.GROUP then
		target = CreateGroup()
	elseif type >= ItemTemplate.BINDING_CAST_SPELL and type <= ItemTemplate.BINDING_UNIT_MENU then
		target = CreateBinding(type)
	elseif type == ItemTemplate.IMPORT_SPELLBOOK then
		target = ImportSpellbook()
	elseif type == ItemTemplate.IMPORT_ACTIONBAR then
		target = ImportActionbar()
	elseif type == ItemTemplate.IMPORT_MACROS then
		target = ImportMacros()
	end

	if target ~= nil then
		self.controller.treeWidget:Select(target.uid)
	end
end

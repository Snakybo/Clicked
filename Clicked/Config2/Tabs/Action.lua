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

local Helpers = Addon.BindingConfig.Helpers

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigActionTab : BindingConfigTab
--- @field private loadCallback? function
Addon.BindingConfig.BindingActionTab = {}

--- @param binding Binding
--- @param value string|integer
local function SetBindingValue(binding, value)
	if binding.actionType == Addon.BindingTypes.SPELL then
		--- @cast value integer
		binding.action.spellValue = value
		Clicked:ReloadBinding(binding, true)
	elseif binding.actionType == Addon.BindingTypes.ITEM then
		--- @cast value integer
		binding.action.itemValue = value
		Clicked:ReloadBinding(binding, true)
	elseif binding.actionType == Addon.BindingTypes.CANCELAURA then
		binding.action.auraName = value
		Clicked:ReloadBinding(binding, true)
	end
end

--- @param binding Binding
--- @return string|integer?
local function GetRawBindingValue(binding)
	if binding.actionType == Addon.BindingTypes.SPELL then
		return binding.action.spellValue
	elseif binding.actionType == Addon.BindingTypes.ITEM then
		return binding.action.itemValue
	elseif binding.actionType == Addon.BindingTypes.CANCELAURA then
		return binding.action.auraName
	end

	return nil
end

function Addon.BindingConfig.BindingActionTab:Hide()
	if self.loadCallback ~= nil then
		self.loadCallback()
		self.loadCallback = nil
	end
end

function Addon.BindingConfig.BindingActionTab:Redraw()
	local id = tonumber(GetRawBindingValue(self.bindings[1]))
	local hasMixedValues

	--- @param binding Binding
	--- @return string
	local function ValueSelector(binding)
		return Addon:GetBindingValue(binding) or ""
	end

	do
		local mixedValueText
		hasMixedValues, mixedValueText = Helpers:GetMixedValues(self.bindings, ValueSelector)

		local hasMixedTypes = FindInTableIf(self.bindings, function(binding)
			return binding.actionType ~= self.bindings[1].actionType
		end) ~= nil

		--- @param value string
		local function OnEnterPressed(_, _, value)
			if LinkUtil.ExtractLink(value) ~= nil then
				return
			end

			if self.loadCallback ~= nil then
				self.loadCallback()
				self.loadCallback = nil
			end

			for _, binding in ipairs(self.bindings) do
				if binding.actionType == Addon.BindingTypes.SPELL then
					self:UpdateSpellValue(binding, value)
				elseif binding.actionType == Addon.BindingTypes.ITEM then
					self:UpdateItemValue(binding, value)
				elseif binding.actionType == Addon.BindingTypes.CANCELAURA then
					self:UpdateCancelAuraValue(binding, value)
				end
			end

			self.controller:RedrawTab()
		end

		--- @param value string
		local function OnTextChanged(_, _, value)
			local type, info = LinkUtil.ExtractLink(value)
			if type == nil then
				return
			end

			local segments = { string.split(":", info) }

			local linkId = tonumber(segments[1])
			if linkId == nil then
				return
			end

			--- @param name string
			local function UpdateValue(name)
				for _, binding in ipairs(self.bindings) do
					if binding.actionType == Addon.BindingTypes.SPELL and type == "spell" then
						SetBindingValue(binding, linkId)
					elseif binding.actionType == Addon.BindingTypes.ITEM and type == "item" then
						SetBindingValue(binding, linkId)
					elseif binding.actionType == Addon.BindingTypes.CANCELAURA then
						SetBindingValue(binding, name)
					end
				end

				self.controller:RedrawTab()
			end

			if self.loadCallback ~= nil then
				self.loadCallback()
				self.loadCallback = nil
			end

			if type == "item" then
				local item = Item:CreateFromItemID(linkId)

				self.loadCallback = item:ContinueWithCancelOnItemLoad(function()
					UpdateValue(item:GetItemName())
				end)
			elseif type == "spell" then
				local spell = Spell:CreateFromSpellID(linkId)

				self.loadCallback = spell:ContinueWithCancelOnSpellLoad(function()
					UpdateValue(spell:GetSpellName())
				end)
			end
		end

		--- @return string
		--- @return string?
		local function GetTooltipText()
			--- @type string
			local text = nil

			--- @type string[]
			local subtext = {}

			if hasMixedTypes then
				text = Addon.L["Target spell, item, or aura"]
			else
				if self.bindings[1].actionType == Addon.BindingTypes.SPELL then
					text = Addon.L["Target spell"]
					table.insert(subtext, Addon.L["Enter the spell name or spell ID."])
					table.insert(subtext, "")
					table.insert(subtext, Addon.L["You can also shift-click a spell in your spellbook or talent window to auto-fill."])
				elseif self.bindings[1].actionType == Addon.BindingTypes.ITEM then
					text = Addon.L["Target item"]
					table.insert(subtext, Addon.L["Enter an item name, item ID, or equipment slot number."])
					table.insert(subtext, "")
					table.insert(subtext, Addon.L["You can also shift-click an item from your bags to auto-fill."])
				elseif self.bindings[1].actionType == Addon.BindingTypes.CANCELAURA then
					text = Addon.L["Target aura"]
					table.insert(subtext, Addon.L["Enter the aura name or spell ID."])
					table.insert(subtext, "")
					table.insert(subtext, Addon.L["You can also shift-click a spell in your spellbook or talent window to auto-fill."])
				end
			end

			if mixedValueText ~= nil then
				table.insert(subtext, "")
				table.insert(subtext, mixedValueText)
			end

			return text, table.concat(subtext, "\n")
		end

		local widget

		if not hasMixedTypes and self.bindings[1].actionType == Addon.BindingTypes.SPELL then
			local function CreateOptions()
				--- @type ClickedAutoFillEditBox.Option[]
				local result = {}

				--- @type ClickedAutoFillEditBox.Option?
				local selected = nil

				for _, spell in pairs(Addon.SpellLibrary:GetSpells()) do
					table.insert(result, {
						prefix = spell.tabName,
						text = spell.name,
						icon = spell.icon,
						spellId = spell.spellId
					})

					if spell.spellId == id then
						selected = result[#result]
					end
				end

				return selected, result
			end

			--- @param match ClickedAutoFillEditBox.Match?
			local function OnSelect(_, _, value, match)
				local spellId = match ~= nil and match.spellId or value

				for _, binding in ipairs(self.bindings) do
					self:UpdateSpellValue(binding, spellId)
				end

				self.controller:RedrawTab()
			end

			local _, options = CreateOptions()
			widget = AceGUI:Create("ClickedAutoFillEditBox") --[[@as ClickedAutoFillEditBox]]
			widget:SetText(hasMixedValues and Helpers.MIXED_VALUE_TEXT or ValueSelector(self.bindings[1]))


			widget:SetLabel(GetTooltipText())
			widget:SetStrictMode(false)
			widget:SetInputError(id == nil or Addon.SpellLibrary:GetSpellById(id) == nil)
			widget:SetValues(options)
			widget:SetCallback("OnSelect", OnSelect)
			widget:SetCallback("OnEnterPressed", OnEnterPressed)
			widget:SetCallback("OnTextChanged", OnTextChanged)
		else
			widget = AceGUI:Create("EditBox") --[[@as AceGUIEditBox]]
			widget:DisableButton(true)
			widget:SetLabel(GetTooltipText())
			widget:SetText(hasMixedValues and Helpers.MIXED_VALUE_TEXT or ValueSelector(self.bindings[1]))
			widget:SetCallback("OnEnterPressed", OnEnterPressed)
			widget:SetCallback("OnTextChanged", OnTextChanged)
		end

		if hasMixedValues or id == nil then
			widget:SetFullWidth(true)
		else
			widget:SetRelativeWidth(0.85)
		end

		Helpers:RegisterTooltip(widget, GetTooltipText)

		self.container:AddChild(widget)
	end

	if not hasMixedValues and id ~= nil then
		local actionType = self.bindings[1].actionType

		--- @type TickerCallback?
		local ticker

		local function OnEnter(widget)
			ticker = C_Timer.NewTimer(Addon.TOOLTIP_SHOW_DELAY, function()
				GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT")

				if actionType == Addon.BindingTypes.SPELL or actionType == Addon.BindingTypes.CANCELAURA then
					GameTooltip:SetSpellByID(id)
				elseif actionType == Addon.BindingTypes.ITEM then
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

		if actionType == Addon.BindingTypes.SPELL or actionType == Addon.BindingTypes.CANCELAURA then
			if Addon.EXPANSION_LEVEL >= Addon.EXPANSION.TWW then
				icon = C_Spell.GetSpellTexture(id)
			else
				icon = select(3, GetSpellInfo(id))
			end
		elseif actionType == Addon.BindingTypes.ITEM then
			icon = C_Item.GetItemIconByID(id)
		end

		local widget = AceGUI:Create("ClickedHorizontalIcon") --[[@as ClickedHorizontalIcon]]
		widget:SetLabel(tostring(id))
		widget:SetImage(icon)
		widget:SetImageSize(16, 16)
		widget:SetRelativeWidth(0.15)
		widget:SetCallback("OnEnter", OnEnter)
		widget:SetCallback("OnLeave", OnLeave)

		self.container:AddChild(widget)
	end

	if not hasMixedValues and id ~= nil and self.bindings[1].actionType == Addon.BindingTypes.SPELL and Addon.EXPANSION_LEVEL <= Addon.EXPANSION.WOTLK then
		local name = ValueSelector(self.bindings[1])
		local hasRank = string.find(name, "%((.+)%)")

		if hasRank then
			local function OnClick()
				if id == nil then
					return
				end

				for _, binding in ipairs(self.bindings) do
					binding.action.spellMaxRank = true
					Clicked:ReloadBinding(binding, true)
				end

				self.controller:RedrawTab()
			end

			local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
			widget:SetText(Addon.L["Remove rank"])
			widget:SetCallback("OnClick", OnClick)
			widget:SetFullWidth(true)

			self.container:AddChild(widget)
		end
	end
end

--- @private
--- @param binding Binding
--- @param value string
function Addon.BindingConfig.BindingActionTab:UpdateSpellValue(binding, value)
	if binding.actionType ~= Addon.BindingTypes.SPELL then
		error("Cannot set spell value for a binding that is not a spell binding")
	end

	value = string.trim(value)

	local newValue = tonumber(value) or Addon:GetSpellId(value) or value
	if newValue == binding.action.spellValue and not binding.action.spellMaxRank then
		return
	end

	binding.action.spellMaxRank = false

	if newValue ~= nil then
		SetBindingValue(binding, newValue)
	else
		Clicked:ReloadBinding(binding, true)
	end
end

--- @private
--- @param binding Binding
--- @param value string
function Addon.BindingConfig.BindingActionTab:UpdateItemValue(binding, value)
	if binding.actionType ~= Addon.BindingTypes.ITEM then
		error("Cannot set item value for a binding that is not an item binding")
	end

	value = string.trim(value)

	local newValue = tonumber(value) or Addon:GetItemId(value) or value
	if newValue == binding.action.itemValue then
		return
	end

	SetBindingValue(binding, newValue)
end

--- @private
--- @param binding Binding
--- @param value string
function Addon.BindingConfig.BindingActionTab:UpdateCancelAuraValue(binding, value)
	if binding.actionType ~= Addon.BindingTypes.CANCELAURA then
		error("Cannot set cancelaura value for a binding that is not a cancelaura binding")
	end

	value = string.trim(value)

	local id = tonumber(value) or Addon:GetSpellId(value)
	if id == nil then
		local data = C_UnitAuras.GetAuraDataBySpellName("player", value)

		if data ~= nil then
			id = data.spellId
		end
	end

	local newValue = id or value
	if newValue == nil or newValue == binding.action.auraName then
		return
	end

	SetBindingValue(binding, newValue)
end

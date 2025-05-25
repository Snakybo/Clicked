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

--- @param binding Binding
--- @param value string|integer
local function SetBindingValue(binding, value)
	if binding.actionType == Clicked.ActionType.SPELL then
		--- @cast value integer
		binding.action.spellValue = value
		Addon:ReloadBinding(binding, "value")
	elseif binding.actionType == Clicked.ActionType.ITEM then
		--- @cast value integer
		binding.action.itemValue = value
		Addon:ReloadBinding(binding, "value")
	elseif binding.actionType == Clicked.ActionType.CANCELAURA then
		binding.action.auraName = value
		Addon:ReloadBinding(binding, "value")
	end
end

--- @param binding Binding
--- @return string|integer?
local function GetRawBindingValue(binding)
	if binding.actionType == Clicked.ActionType.SPELL then
		return binding.action.spellValue
	elseif binding.actionType == Clicked.ActionType.ITEM then
		return binding.action.itemValue
	elseif binding.actionType == Clicked.ActionType.CANCELAURA then
		return binding.action.auraName
	end

	return nil
end

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigActionTab : BindingConfigTab
--- @field private loadCallback? function
--- @field private references integer[]
Addon.BindingConfig.BindingActionTab = {
	references = {}
}

--- @protected
function Addon.BindingConfig.BindingActionTab:Hide()
	if self.loadCallback ~= nil then
		self.loadCallback()
		self.loadCallback = nil
	end

	table.wipe(self.references)
end

--- @protected
function Addon.BindingConfig.BindingActionTab:Redraw()
	self:RedrawTargetSpell()
	self:RedrawActionGroups()
	self:RedrawKeyOptions()
end

--- @protected
--- @param relevant boolean
--- @param changed integer[]
function Addon.BindingConfig.BindingActionTab:OnBindingReload(relevant, changed)
	if relevant then
		self.controller:RedrawTab()
		return
	end

	for _, uid in ipairs(self.references) do
		if tContains(changed, uid) then
			self.controller:RedrawTab()
			return
		end
	end

	for _, other in Clicked:IterateActiveBindings() do
		if other.keybind == self.bindings[1].keybind and other.actionType ~= Clicked.ActionType.MACRO and tContains(changed, other.uid) then
			self.controller:RedrawTab()
			return
		end
	end
end

--- @private
function Addon.BindingConfig.BindingActionTab:RedrawTargetSpell()
	local id = tonumber(GetRawBindingValue(self.bindings[1]))
	local hasMixedValues

	--- @param binding Binding
	--- @return string
	local function ValueSelector(binding)
		return Addon:GetBindingValue(binding) or ""
	end

	do
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
				if binding.actionType == Clicked.ActionType.SPELL then
					self:UpdateSpellValue(binding, value)
				elseif binding.actionType == Clicked.ActionType.ITEM then
					self:UpdateItemValue(binding, value)
				elseif binding.actionType == Clicked.ActionType.CANCELAURA then
					self:UpdateCancelAuraValue(binding, value)
				end
			end

			self.controller:RedrawTab()
		end

		--- @param value string
		--- @return ClickedAutoFillEditBox.Option?
		local function GetAutoFillOptionFromInput(value)
			local spell = Addon:GetSpellInfo(value, false)
			if spell ~= nil then
				return {
					text = value,
					icon = spell.iconID,
					spellId = spell.spellID
				}
			end

			return nil
		end

		--- @param widget ClickedEditBox|ClickedAutoFillEditBox
		--- @param value string
		local function OnTextChanged(widget, _, value)
			local type, info = LinkUtil.ExtractLink(value)

			if type ~= nil then
				local segments = { string.split(":", info) }

				local linkId = tonumber(segments[1])
				if linkId == nil then
					return
				end

				--- @param name string
				local function UpdateValue(name)
					for _, binding in ipairs(self.bindings) do
						if binding.actionType == Clicked.ActionType.SPELL and type == "spell" then
							SetBindingValue(binding, linkId)
						elseif binding.actionType == Clicked.ActionType.ITEM and type == "item" then
							SetBindingValue(binding, linkId)
						elseif binding.actionType == Clicked.ActionType.CANCELAURA then
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
						UpdateValue(item:GetItemName() --[[@as string]])
					end)
				elseif type == "spell" then
					local spell = Spell:CreateFromSpellID(linkId)

					self.loadCallback = spell:ContinueWithCancelOnSpellLoad(function()
						UpdateValue(spell:GetSpellName())
					end)
				end
			elseif widget.type == "ClickedAutoFillEditBox" then
				--- @cast widget ClickedAutoFillEditBox

				local option = GetAutoFillOptionFromInput(value)

				if option ~= nil then
					widget:SetTemporaryValue(option)
				else
					widget:ClearTemporaryValue()
				end
			end
		end

		--- @return string[]
		local function GetTooltipText()
			--- @type string[]
			local lines = {}

			if hasMixedTypes then
				table.insert(lines, Addon.L["Target spell, item, or aura"])
			else
				if self.bindings[1].actionType == Clicked.ActionType.SPELL then
					table.insert(lines, Addon.L["Target spell"])
					table.insert(lines, Addon.L["Enter the spell name or spell ID."])
					table.insert(lines, "")
					table.insert(lines, Addon.L["You can also shift-click a spell in your spellbook or talent window to auto-fill."])
				elseif self.bindings[1].actionType == Clicked.ActionType.ITEM then
					table.insert(lines, Addon.L["Target item"])
					table.insert(lines, Addon.L["Enter an item name, item ID, or equipment slot number."])
					table.insert(lines, "")
					table.insert(lines, Addon.L["You can also shift-click an item from your bags to auto-fill."])
				elseif self.bindings[1].actionType == Clicked.ActionType.CANCELAURA then
					table.insert(lines, Addon.L["Target aura"])
					table.insert(lines, Addon.L["Enter the aura name or spell ID."])
					table.insert(lines, "")
					table.insert(lines, Addon.L["You can also shift-click a spell in your spellbook or talent window to auto-fill."])
				end
			end

			return lines
		end

		local widget

		if not hasMixedTypes and self.bindings[1].actionType == Clicked.ActionType.SPELL then
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

			local function IsInputError()
				return id == nil or (Addon.SpellLibrary:GetSpellById(id) == nil and GetAutoFillOptionFromInput(ValueSelector(self.bindings[1])) == nil)
			end

			local _, options = CreateOptions()
			widget = AceGUI:Create("ClickedAutoFillEditBox") --[[@as ClickedAutoFillEditBox]]
			widget:SetStrictMode(false)
			widget:SetInputError(IsInputError())
			widget:SetValues(options)
			widget:SetCallback("OnSelect", OnSelect)
			widget:SetCallback("OnEnterPressed", OnEnterPressed)
			widget:SetCallback("OnTextChanged", OnTextChanged)
		else
			widget = AceGUI:Create("ClickedEditBox") --[[@as ClickedEditBox]]
			widget:DisableButton(true)
			widget:SetCallback("OnEnterPressed", OnEnterPressed)
			widget:SetCallback("OnTextChanged", OnTextChanged)
		end

		hasMixedValues = Helpers:HandleWidget(widget, self.bindings, ValueSelector, GetTooltipText)

		if hasMixedValues or id == nil then
			widget:SetFullWidth(true)
		else
			widget:SetRelativeWidth(0.85)
		end

		self.container:AddChild(widget)
	end

	if not hasMixedValues and id ~= nil then
		local actionType = self.bindings[1].actionType

		--- @type TickerCallback?
		local ticker

		local function OnEnter(widget)
			ticker = C_Timer.NewTimer(Addon.TOOLTIP_SHOW_DELAY, function()
				GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT")

				if actionType == Clicked.ActionType.SPELL or actionType == Clicked.ActionType.CANCELAURA then
					GameTooltip:SetSpellByID(id)
				elseif actionType == Clicked.ActionType.ITEM then
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

		--- @type integer
		local icon

		if actionType == Clicked.ActionType.SPELL or actionType == Clicked.ActionType.CANCELAURA then
			icon = C_Spell.GetSpellTexture(id)
		elseif actionType == Clicked.ActionType.ITEM then
			icon = C_Item.GetItemIconByID(id) --[[@as integer]]
		end

		local widget = AceGUI:Create("ClickedHorizontalIcon") --[[@as ClickedHorizontalIcon]]
		widget:SetLabel(tostring(id))
		--- @diagnostic disable-next-line: param-type-mismatch
		widget:SetImage(icon)
		widget:SetImageSize(16, 16)
		widget:SetRelativeWidth(0.15)
		widget:SetCallback("OnEnter", OnEnter)
		widget:SetCallback("OnLeave", OnLeave)

		self.container:AddChild(widget)
	end

	do
		local anyHasRank = FindInTableIf(self.bindings, function(binding)
			if binding.actionType ~= Clicked.ActionType.SPELL then
				return false
			end

			local name = ValueSelector(binding)
			local hasRank = string.find(name, "%((.+)%)")
			return hasRank
		end)

		if Addon.EXPANSION_LEVEL <= Addon.Expansion.WOTLK and anyHasRank then
			local function OnClick()
				for _, binding in ipairs(self.bindings) do
					if binding.actionType == Clicked.ActionType.SPELL and not binding.action.spellMaxRank then
						binding.action.spellMaxRank = true
						Addon:ReloadBinding(binding)
					end
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
function Addon.BindingConfig.BindingActionTab:RedrawActionGroups()
	-- Only show action groups if all bindings have the same keybind as the UI just wouldn't make sense otherwise
	for i = 2, #self.bindings do
		if self.bindings[i].keybind ~= self.bindings[1].keybind then
			return
		end
	end

	local title = AceGUI:Create("Heading") --[[@as AceGUIHeading]]
	title:SetFullWidth(true)
	title:SetText(Addon.L["Action Groups"])

	local group = AceGUI:Create("ClickedSimpleGroup") --[[@as ClickedSimpleGroup]]
	group:SetFullWidth(true)
	group:SetLayout("Flow")

	local count = 0

	local function Redraw()
		--- @type { [integer]: Binding[] }
		local groups = { }

		--- @type integer[]
		local order = {}

		table.wipe(self.references)

		--- @param left Binding
		--- @param right Binding
		--- @return boolean
		local function SortFunc(left, right)
			if left.actionType ~= Clicked.ActionType.APPEND and right.actionType == Clicked.ActionType.APPEND then
				return true
			end

			if left.actionType == Clicked.ActionType.APPEND and right.actionType ~= Clicked.ActionType.APPEND then
				return false
			end

			return left.uid < right.uid
		end

		for _, other in Clicked:IterateActiveBindings() do
			if other.keybind == self.bindings[1].keybind and other.actionType ~= Clicked.ActionType.MACRO then
				local id = other.action.executionOrder

				if groups[id] == nil then
					groups[id] = {}
					table.insert(order, id)
				end

				table.insert(groups[id], other)
				table.insert(self.references, other.uid)

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
					Addon.BindingConfig.Window:Select(current.uid)
				end

				local function OnMoveUp()
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

					Addon:ReloadBinding(current)

					group:ReleaseChildren()
					Redraw()
					self.container:DoLayout()
				end

				local function OnMoveDown()
					current.action.executionOrder = current.action.executionOrder + 1

					Addon:ReloadBinding(current)

					group:ReleaseChildren()
					Redraw()
					self.container:DoLayout()
				end

				local name, icon = Addon:GetBindingNameAndIcon(current)

				if index > 1 then
					-- TODO: There might be a better way for this
					--- @param b Binding
					--- @return string?
					local function GetType(b)
						if b.actionType == Clicked.ActionType.SPELL or b.actionType == Clicked.ActionType.ITEM then
							return "cast"
						elseif b.actionType == Clicked.ActionType.CANCELAURA then
							return "cancelaura"
						end

						return nil
					end

					local type = GetType(current)
					local previousType = GetType(bindings[1])

					if type ~= nil and previousType ~= nil and type ~= previousType then
						name = RED_FONT_COLOR:WrapTextInColorCode(name)
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
	end

	Redraw()

	if count > 1 then
		self.container:AddChild(title)
		self.container:AddChild(group)
	end
end

--- @private
function Addon.BindingConfig.BindingActionTab:RedrawKeyOptions()
	local title = AceGUI:Create("Heading") --[[@as AceGUIHeading]]
	title:SetFullWidth(true)
	title:SetText(Addon.L["Options"])

	self.container:AddChild(title)

	local group = AceGUI:Create("ClickedSimpleGroup") --[[@as ClickedSimpleGroup]]
	group:SetFullWidth(true)
	group:SetLayout("Flow")

	local hasMixedKeys = FindInTableIf(self.bindings, function(obj)
		return obj.keybind ~= self.bindings[1].keybind
	end)

	--- @param binding Binding
	--- @param option string
	--- @return boolean
	--- @return Binding[]
	local function IsSharedDataSet(binding, option)
		--- @type Binding[]
		local setBy = {}

		for _, other in ipairs(Clicked:GetByKey(binding.keybind)) do
			if other ~= binding and Clicked:IsBindingLoaded(other) then
				if other.action[option] then
					table.insert(setBy, other)
				end
			end
		end

		return #setBy > 0, setBy
	end

	--- @param label string
	--- @param tooltipText string
	--- @param key string
	local function CreateCheckbox(label, tooltipText, key)
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			if not hasMixedKeys then
				return Helpers.IGNORE_VALUE
			end

			return binding.action[key] and Addon.L["Enabled"] or Addon.L["Disabled"]
		end

		--- @type boolean, fun():boolean
		local hasMixedValues, updateCb

		local function GetTooltipText()
			local lines = { label, tooltipText }

			if not hasMixedValues and not self.bindings[1].action[key] then
				local hasSharedData, setBy = IsSharedDataSet(self.bindings[1], key)

				if hasSharedData then
					local items = { }

					for _, binding in ipairs(setBy) do
						local name = Addon:GetBindingNameAndIcon(binding)
						table.insert(items, NORMAL_FONT_COLOR:WrapTextInColorCode(name))
					end

					table.insert(lines, "")
					table.insert(lines, string.format(Addon.L["May be enabled by: %s"], table.concat(items, ", ")))
				end
			end

			return lines
		end

		--- @return boolean?
		local function GetEnabledState()
			local anyEnabled = FindInTableIf(self.bindings, function(binding)
				return binding.action[key]
			end)

			if anyEnabled then
				return true
			else
				local _, loaded = FindInTableIf(self.bindings, function(binding)
					return Clicked:IsBindingLoaded(binding)
				end)

				if loaded ~= nil and IsSharedDataSet(loaded, key) then
					return nil
				end
			end

			return false
		end

		--- @param value boolean?
		local function OnValueChanged(_, _, value)
			if value == false then
				value = true
			elseif value == nil then
				value = false
			end

			for _, binding in ipairs(self.bindings) do
				binding.action[key] = value
				Addon:ReloadBinding(binding)
			end

			updateCb()
		end

		local widget = AceGUI:Create("ClickedCheckBox") --[[@as ClickedCheckBox]]
		widget:SetType("checkbox")
		widget:SetCallback("OnValueChanged", OnValueChanged)
		widget:SetFullWidth(true)
		widget:SetTriState(true)

		hasMixedValues, updateCb = Helpers:HandleWidget(widget, self.bindings, ValueSelector, GetTooltipText, GetEnabledState)

		group:AddChild(widget)
	end

	CreateCheckbox(Addon.L["Interrupt current cast"], Addon.L["Allow this binding to cancel any spells that are currently being cast."], "interrupt")
	CreateCheckbox(Addon.L["Start auto attacks"], Addon.L["Allow this binding to start auto attacks, useful for any damaging abilities."], "startAutoAttack")
	CreateCheckbox(Addon.L["Start pet attacks"], Addon.L["Allow this binding to start pet attacks."], "startPetAttack")
	CreateCheckbox(Addon.L["Override queued spell"], Addon.L["Allow this binding to override a spell that is queued by the lag-tolerance system, should be reserved for high-priority spells."], "cancelQueuedSpell")
	CreateCheckbox(Addon.L["Exit shapeshift form"], Addon.L["Allow this binding to automatically exit your shapeshift form."], "cancelForm")
	CreateCheckbox(Addon.L["Target on cast"], Addon.L["Targets the unit you are casting on."], "targetUnitAfterCast")
	CreateCheckbox(Addon.L["Prevent toggle"], Addon.L["Prevent the ability from being toggled off by repeatetly pressing the keybind."], "preventToggle")

	do
		local tooltip = {
			Addon.L["Clears the \"blue casting cursor\"."],
			"",
			Addon.L["It's recommended to always leave this option enabled unless you need the extra space in a macro."],
			Addon.L["Without it you may be left with a dangling cast if the macro cannot determine the target automatically, in other words if your targets don't end in either 'player' or 'cursor' (or 'default' if self-cast is enabled)"]
		}

		CreateCheckbox(Addon.L["Clear blue cursor"], table.concat(tooltip, "\n"), "stopSpellTarget")
	end

	self.container:AddChild(group)
end

--- @private
--- @param binding Binding
--- @param value string
function Addon.BindingConfig.BindingActionTab:UpdateSpellValue(binding, value)
	if binding.actionType ~= Clicked.ActionType.SPELL then
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
		Addon:ReloadBinding(binding, "value")
	end
end

--- @private
--- @param binding Binding
--- @param value string
function Addon.BindingConfig.BindingActionTab:UpdateItemValue(binding, value)
	if binding.actionType ~= Clicked.ActionType.ITEM then
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
	if binding.actionType ~= Clicked.ActionType.CANCELAURA then
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

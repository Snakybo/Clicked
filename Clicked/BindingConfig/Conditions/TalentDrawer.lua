-- Clicked, a World of Warcraft keybind manager.
-- Copyright (C) 2026 Kevin Krol
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

--- @class Addon
local Addon = select(2, ...)

local Helpers = Addon.BindingConfig.Helpers
local Utils = Addon.Condition.Utils

--- @class TalentDrawerEntry
--- @field public operation "AND"|"OR"
--- @field public negate boolean
--- @field public name string

--- @param load LoadCondition<TalentValue[]>
--- @return TalentDrawerEntry[]
local function GetEntries(load)
	--- @type TalentDrawerEntry[]
	local result = {}

	--- @type TalentValue[][]
	local compounds = Utils.UnpackLoadOption(load)

	for i, compound in ipairs(compounds) do
		for j, talent in ipairs(compound) do
			table.insert(result, {
				operation = (i > 1 and j == 1) and "OR" or "AND",
				negate = talent.negate and true or false,
				name = talent.name or ""
			})
		end
	end

	if #result == 0 then
		table.insert(result, {
			operation = "AND",
			negate = false,
			name = ""
		})
	end

	return result
end

--- @param load LoadCondition<TalentValue[]>
--- @param entries TalentDrawerEntry[]
local function SetEntries(load, entries)
	--- @type TalentValue[][]
	local compounds = {}

	--- @type TalentValue[]?
	local current = nil

	for i, entry in ipairs(entries) do
		if i == 1 or entry.operation == "OR" or current == nil then
			current = {}
			table.insert(compounds, current)
		end

		table.insert(current, {
			name = entry.name,
			negate = entry.negate
		})
	end

	load.value = compounds
end

--- @param load LoadCondition<TalentValue[]>
--- @return string
local function TalentValueSelector(load)
	if not Utils.HasEnabledFlag(load) then
		return Helpers.IGNORE_VALUE
	end

	--- @type string[]
	local segments = {}

	--- @type TalentValue[][]
	local compounds = Utils.UnpackLoadOption(load)

	for _, compound in ipairs(compounds) do
		--- @type string[]
		local names = {}

		for _, talent in ipairs(compound) do
			table.insert(names, talent.name)
		end

		table.insert(segments, table.concat(names, ", "))
	end

	return table.concat(segments, " OR ")
end

--- @param talents LibTalentTome.Talent[]
--- @return ClickedAutoFillEditBox.Option[]
local function CreateValues(talents)
	--- @type ClickedAutoFillEditBox.Option[]
	local result = {}

	for _, talent in ipairs(talents) do
		table.insert(result, {
			text = talent.name,
			icon = talent.icon,
			spellId = talent.spellId
		})
	end

	return result
end

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingTalentConditionDrawer : BindingConditionDrawer
--- @field private checkbox ClickedCheckBox
--- @field private miniTalentRow? ClickedSimpleGroup
--- @field private inputFields? ClickedAutoFillEditBox[]
--- @field private status { expand?: boolean }
--- @field private talents LibTalentTome.Talent[]
--- @field private hasMixedValues boolean
local Drawer = {}

--- @private
--- @param binding Binding
--- @return boolean
function Drawer:IsEnabled(binding)
	return Utils.HasEnabledFlag(Utils.GetLoadCondition(binding, self.condition))
end

--- @private
--- @return TalentDrawerEntry[]
function Drawer:GetReferenceEntries()
	--- @param binding Binding
	--- @return boolean
	local function IsEnabled(binding)
		return self:IsEnabled(binding)
	end

	--- @type integer?, Binding?
	local _, binding = FindInTableIf(self.bindings, IsEnabled)

	if binding == nil then
		return GetEntries(Utils.CreateLoadCondition(self.condition))
	end

	return GetEntries(Utils.GetLoadCondition(binding, self.condition))
end

--- @private
--- @param modifier fun(entries: TalentDrawerEntry[])
function Drawer:ModifyEntries(modifier)
	for _, binding in ipairs(self.bindings) do
		local load = Utils.GetLoadCondition(binding, self.condition)

		if Utils.HasEnabledFlag(load) then
			local entries = GetEntries(load)
			modifier(entries)

			SetEntries(load, entries)
			Utils.SetLoadCondition(binding, self.condition, load)
			Addon:ReloadBinding(binding, self.fieldName)
		end
	end
end

--- @protected
function Drawer:Draw()
	--- @param binding Binding
	--- @return boolean
	local function IsEnabled(binding)
		return self:IsEnabled(binding)
	end

	local isAnyEnabled = FindInTableIf(self.bindings, IsEnabled) ~= nil

	self.checkbox = Helpers:DrawConditionToggle(self.container, self.bindings, self.fieldName, self.condition, self.requestRedraw)

	if isAnyEnabled then
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			return TalentValueSelector(Utils.GetLoadCondition(binding, self.condition))
		end

		self.hasMixedValues = Helpers:GetMixedValues(self.bindings, ValueSelector)
		self.talents = self.requestAvailableValues()

		self:DrawMiniTalentRow()

		if not self.hasMixedValues then
			if not self.status.expand then
				do
					local widget = AceGUI:Create("Label")
					widget:SetText("")
					widget:SetRelativeWidth(0.5)

					self.container:AddChild(widget)
				end

				do
					local function OnClick()
						self.status.expand = true
						self.requestRedraw()
					end

					local widget = AceGUI:Create("Button")
					widget:SetCallback("OnClick", OnClick)
					widget:SetText(Addon.L["Select talents"])

					widget:SetRelativeWidth(0.5)
					self.container:AddChild(widget)
				end
			else
				self:DrawTalentSelect()
			end
		end
	end
end

--- @protected
function Drawer:Update()
	if self.miniTalentRow ~= nil then
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			return TalentValueSelector(Utils.GetLoadCondition(binding, self.condition))
		end

		self.hasMixedValues = Helpers:GetMixedValues(self.bindings, ValueSelector)
		self.talents = self.requestAvailableValues()

		self:DrawMiniTalentRow()
	end

	if self.inputFields ~= nil then
		for _, inputField in ipairs(self.inputFields) do
			inputField:SetValues(CreateValues(self.talents))
			inputField:SetInputError(not self:DoesTalentExist(inputField:GetText()))
		end
	end
end

--- @private
function Drawer:DrawMiniTalentRow()
	if self.hasMixedValues then
		if self.miniTalentRow ~= nil then
			self.miniTalentRow:ReleaseChildren()
		end

		local widget = AceGUI:Create("Label")
		widget:SetRelativeWidth(0.5)

		self.container:AddChild(widget)
		return
	end

	local entries = self:GetReferenceEntries()

	local miniTalentRow = self.miniTalentRow

	if miniTalentRow == nil then
		miniTalentRow = AceGUI:Create("ClickedSimpleGroup") --[[@as ClickedSimpleGroup]]
		miniTalentRow:SetLayout("Flow")
		miniTalentRow:SetRelativeWidth(0.5)

		self.miniTalentRow = miniTalentRow
		self.container:AddChild(miniTalentRow)
	else
		miniTalentRow:ReleaseChildren()
	end

	for i = 1, #entries do
		local entry = entries[i]

		if entry.operation == "OR" then
			local widget = AceGUI:Create("Label")
			widget:SetText("")
			widget:SetWidth(7)

			miniTalentRow:AddChild(widget)
		end

		do
			local talent = self:GetTalentInfo(entry.name)
			local ticker

			--- @param widget ClickedTalentIcon
			local function OnEnter(widget)
				if talent == nil then
					return
				end

				ticker = C_Timer.NewTimer(Addon.TOOLTIP_SHOW_DELAY, function()
					GameTooltip:SetOwner(widget.frame, "ANCHOR_TOPLEFT")

					if talent.spellId ~= nil then
						GameTooltip:SetSpellByID(talent.spellId)
					else
						GameTooltip:SetText(talent.name)
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

			if entry.negate then
				widget:SetColor(1, 0, 0, 1)
			end

			widget:SetCallback("OnEnter", OnEnter)
			widget:SetCallback("OnLeave", OnLeave)

			miniTalentRow:AddChild(widget)
		end
	end
end

--- @private
function Drawer:DrawTalentSelect()
	local function AddSeparator()
		local widget = AceGUI:Create("Heading")
		widget:SetFullWidth(true)
		widget:SetText(Addon.L["Or"])

		self.container:AddChild(widget)
	end

	--- @param operation "AND"|"OR"
	--- @param position integer
	--- @param text string
	local function AddAddButton(operation, position, text)
		local function OnClick()
			self:ModifyEntries(function(entries)
				table.insert(entries, math.min(position, #entries + 1), {
					operation = operation,
					negate = false,
					name = ""
				})
			end)

			self.requestRedraw()
		end

		local widget = AceGUI:Create("Button")
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.5)
		widget:SetText(text)

		self.container:AddChild(widget)
	end

	local function CreateTableGroup()
		local group = AceGUI:Create("ClickedSimpleGroup") --[[@as ClickedSimpleGroup]]
		group:SetLayout("Table")
		group:SetFullWidth(true)
		group:SetUserData("table", {
			columns = { 75, 1, 50 },
			spaceH = 1
		})

		self.container:AddChild(group)
		return group
	end

	do
		local widget = AceGUI:Create("Label")
		widget:SetFullWidth(true)

		self.container:AddChild(widget)
	end

	local tableContainer = CreateTableGroup()

	self.inputFields = {}

	local entries = self:GetReferenceEntries()

	for i = 1, #entries do
		local entry = entries[i]

		if entry.operation == "OR" then
			AddSeparator()
			tableContainer = CreateTableGroup()
		end

		do
			--- @param widget AceGUIButton
			local function OnClick(widget)
				entry.negate = not entry.negate

				self:ModifyEntries(function(other)
					if other[i] ~= nil then
						other[i].negate = entry.negate
					end
				end)

				widget:SetText(entry.negate and Addon.L["Not"] or "")

				self:DrawMiniTalentRow()
			end

			local widget = AceGUI:Create("Button")
			widget:SetText(entry.negate and Addon.L["Not"] or "")
			widget:SetCallback("OnClick", OnClick)

			tableContainer:AddChild(widget)
		end

		do
			--- @param widget ClickedAutoFillEditBox
			--- @param event string
			--- @param value string
			local function OnSelect(widget, event, value)
				value = string.trim(value)

				self:ModifyEntries(function(other)
					if other[i] ~= nil then
						other[i].name = value
					end
				end)

				self:DrawMiniTalentRow()
			end

			local widget = AceGUI:Create("ClickedAutoFillEditBox") --[[@as ClickedAutoFillEditBox]]
			widget:SetText(entry.name)
			widget:SetInputError(not self:DoesTalentExist(entry.name))
			widget:SetValues(CreateValues(self.talents))
			widget:SetFullWidth(true)
			widget:SetCallback("OnSelect", OnSelect)

			tableContainer:AddChild(widget)

			table.insert(self.inputFields, widget)
		end

		do
			local function OnClick()
				self:ModifyEntries(function(other)
					if #other <= 1 or other[i] == nil then
						return
					end

					local operation = other[i].operation
					table.remove(other, i)

					other[1].operation = "AND"

					local next = other[i]
					if next ~= nil and operation == "OR" and next.operation == "AND" then
						next.operation = "OR"
					end
				end)

				self.requestRedraw()
			end

			local widget = AceGUI:Create("Button")
			widget:SetText(Addon.L["X"])
			widget:SetCallback("OnClick", OnClick)
			widget:SetDisabled(#entries == 1)

			tableContainer:AddChild(widget)
		end

		if i == #entries or entries[i + 1].operation == "OR" then
			AddAddButton("AND", i + 1, Addon.L["Add condition"])

			do
				local function OnClick()
					self:ModifyEntries(function(other)
						for j = math.min(i, #other), 1, -1 do
							if j == 1 then
								other[1] = {
									operation = "AND",
									negate = false,
									name = ""
								}
							else
								local operation = other[j].operation
								table.remove(other, j)

								if operation == "OR" then
									break
								end
							end
						end
					end)

					self.requestRedraw()
				end

				local widget = AceGUI:Create("Button")
				widget:SetText(Addon.L["Remove compound"])
				widget:SetCallback("OnClick", OnClick)
				widget:SetDisabled(#entries <= 1)
				widget:SetRelativeWidth(0.5)

				self.container:AddChild(widget)
			end
		end
	end

	AddSeparator()
	AddAddButton(#entries == 0 and "AND" or "OR", #entries + 1, Addon.L["Add compound"])

	do
		local function OnClick()
			self.status.expand = false
			self.requestRedraw()
		end

		local widget = AceGUI:Create("Button")
		widget:SetText(Addon.L["Close"])
		widget:SetCallback("OnClick", OnClick)
		widget:SetRelativeWidth(0.5)

		self.container:AddChild(widget)
	end
end

--- @private
--- @param name string
--- @return boolean
function Drawer:DoesTalentExist(name)
	for _, item in ipairs(self.talents) do
		if item.name == name then
			return true
		end
	end

	return false
end

--- @private
--- @param name string
--- @return LibTalentTome.Talent?
function Drawer:GetTalentInfo(name)
	for _, talent in ipairs(self.talents) do
		if talent.name == name then
			return talent
		end
	end

	return nil
end

Addon.BindingConfig.BindingConditionDrawers = Addon.BindingConfig.BindingConditionDrawers or {}
Addon.BindingConfig.BindingConditionDrawers["talent"] = Drawer

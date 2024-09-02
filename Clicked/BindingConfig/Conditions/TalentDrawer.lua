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

--- @param load TalentLoadOption
--- @return string
local function TalentValueSelector(load)
	if load.selected then
		--- @type any[]
		local segments = {{}}

		for _, value in ipairs(load.entries) do
			if value.operation == "OR" and #segments[#segments] > 0 then
				table.insert(segments, {})
			end

			table.insert(segments[#segments], value.value)
		end

		for i = 1, #segments do
			segments[i] = table.concat(segments[i], ", ")
		end

		return table.concat(segments, " OR ")
	end

	return Helpers.IGNORE_VALUE
end

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingTalentConditionDrawer : BindingConditionDrawer
--- @field private checkbox ClickedCheckBox
--- @field private miniTalentRow? ClickedSimpleGroup
--- @field private inputFields? ClickedAutoFillEditBox[]
--- @field private status { expand?: boolean }
--- @field private talents TalentInfo[]
--- @field private hasMixedValues boolean
local Drawer = {}

--- @protected
function Drawer:Draw()
	local isAnyEnabled = FindInTableIf(self.bindings, function(binding)
		--- @type SimpleLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()
		return load.selected
	end) ~= nil

	self.checkbox = Helpers:DrawConditionToggle(self.container, self.bindings, self.fieldName, self.condition, self.requestRedraw)

	if isAnyEnabled then
		local function ValueSelector(binding)
			--- @type TalentLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return TalentValueSelector(load)
		end

		self.hasMixedValues = Helpers:GetMixedValues(self.bindings, ValueSelector)
		self.talents = self.requestAvailableValues()

		self:DrawMiniTalentRow()

		if not self.hasMixedValues then
			if not self.status.expand then
				do
					local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
					widget:SetText("")
					widget:SetRelativeWidth(0.5)

					self.container:AddChild(widget)
				end

				do
					local function OnClick()
						self.status.expand = true
						self.requestRedraw()
					end

					local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
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
		local function ValueSelector(binding)
			--- @type TalentLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return TalentValueSelector(load)
		end

		self.hasMixedValues = Helpers:GetMixedValues(self.bindings, ValueSelector)
		self.talents = self.requestAvailableValues()

		self:DrawMiniTalentRow()
	end

	if self.inputFields ~= nil then
		for _, inputField in ipairs(self.inputFields) do
			inputField:SetValues(self.talents)
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

		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetRelativeWidth(0.5)

		self.container:AddChild(widget)
		return
	end

	local _, binding = FindInTableIf(self.bindings, function(binding)
		--- @type TalentLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()
		return load.selected
	end)

	--- @type TalentLoadOption
	local load = binding.load[self.fieldName] or self.condition.init()

	if self.miniTalentRow == nil then
		self.miniTalentRow = AceGUI:Create("ClickedSimpleGroup") --[[@as ClickedSimpleGroup]]
		self.miniTalentRow:SetLayout("Flow")
		self.miniTalentRow:SetRelativeWidth(0.5)

		self.container:AddChild(self.miniTalentRow)
	else
		self.miniTalentRow:ReleaseChildren()
	end

	for i = 1, #load.entries do
		local entry = load.entries[i]

		if entry.operation == "OR" then
			local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
			widget:SetText("")
			widget:SetWidth(7)

			self.miniTalentRow:AddChild(widget)
		end

		do
			local talent = self:GetTalentInfo(entry.value)
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

			self.miniTalentRow:AddChild(widget)
		end
	end
end

--- @private
function Drawer:DrawTalentSelect()
	local function AddSeparator()
		local widget = AceGUI:Create("Heading") --[[@as AceGUIHeading]]
		widget:SetFullWidth(true)
		widget:SetText(Addon.L["Or"])

		self.container:AddChild(widget)
	end

	--- @param operation "AND"|"OR"
	--- @param position integer
	--- @param text string
	local function AddAddButton(operation, position, text)
		local function OnClick()
			for _, binding in ipairs(self.bindings) do
				--- @type TalentLoadOption
				local load = binding.load[self.fieldName] or self.condition.init()

				if load.selected then
					table.insert(load.entries, position, {
						operation = operation,
						value = ""
					})

					binding.load[self.fieldName] = load
				end
			end

			self.requestRedraw()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
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

	local _, binding = FindInTableIf(self.bindings, function(binding)
		--- @type TalentLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()
		return load.selected
	end)

	self.inputFields = {}

	--- @type TalentLoadOption
	local load = binding.load[self.fieldName] or self.condition.init()

	for i = 1, #load.entries do
		local entry = load.entries[i]

		if entry.operation == "OR" then
			AddSeparator()
			tableContainer = CreateTableGroup()
		end

		do
			--- @param widget AceGUIButton
			local function OnClick(widget)
				for _, other in ipairs(self.bindings) do
					--- @type TalentLoadOption
					local otherLoad = other.load[self.fieldName] or self.condition.init()

					if otherLoad.selected then
						otherLoad.entries[i].negated = not otherLoad.entries[i].negated
						Addon:ReloadBinding(binding, self.fieldName)
					end
				end

				widget:SetText(entry.negated and Addon.L["Not"] or "")

				self:DrawMiniTalentRow()
			end

			local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
			widget:SetText(entry.negated and Addon.L["Not"] or "")
			widget:SetCallback("OnClick", OnClick)

			tableContainer:AddChild(widget)
		end

		do
			local function OnSelect(_, _, value)
				value = string.trim(value)

				for _, other in ipairs(self.bindings) do
					--- @type TalentLoadOption
					local otherLoad = other.load[self.fieldName] or self.condition.init()

					if otherLoad.selected then
						otherLoad.entries[i].value = value
						Addon:ReloadBinding(binding, self.fieldName)
					end
				end

				self:DrawMiniTalentRow()
			end

			local widget = AceGUI:Create("ClickedAutoFillEditBox") --[[@as ClickedAutoFillEditBox]]
			widget:SetText(entry.value)
			widget:SetInputError(not self:DoesTalentExist(entry.value))
			widget:SetValues(self.talents)
			widget:SetFullWidth(true)
			widget:SetCallback("OnSelect", OnSelect)

			tableContainer:AddChild(widget)

			table.insert(self.inputFields, widget)
		end

		do
			local function OnClick()
				for _, other in ipairs(self.bindings) do
					--- @type TalentLoadOption
					local otherLoad = other.load[self.fieldName] or self.condition.init()

					if otherLoad.selected then
						table.remove(otherLoad.entries, i)

						do
							local first = otherLoad.entries[1]
							first.operation = "AND"
						end

						do
							local next = otherLoad.entries[i]
							if next ~= nil and entry.operation == "OR" and next.operation == "AND" then
								next.operation = "OR"
							end
						end

						Addon:ReloadBinding(binding, self.fieldName)
					end
				end

				self.requestRedraw()
			end

			local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
			widget:SetText(Addon.L["X"])
			widget:SetCallback("OnClick", OnClick)
			widget:SetDisabled(#load.entries == 1)

			tableContainer:AddChild(widget)
		end

		if i == #load.entries or load.entries[i + 1].operation == "OR" then
			AddAddButton("AND", i + 1, Addon.L["Add condition"])

			do
				local function OnClick()
					for j = i, 1, -1 do
						if j == 1 then
							load.entries[1] = {
								operation = "AND",
								value = ""
							}
						else
							local operation = load.entries[j].operation
							table.remove(load.entries, j)

							if operation == "OR" then
								break
							end
						end
					end

					self.requestRedraw()
				end

				local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
				widget:SetText(Addon.L["Remove compound"])
				widget:SetCallback("OnClick", OnClick)
				widget:SetDisabled(#load.entries <= 1)
				widget:SetRelativeWidth(0.5)

				self.container:AddChild(widget)
			end
		end
	end

	AddSeparator()
	AddAddButton(#load.entries == 0 and "AND" or "OR", #load.entries + 1, Addon.L["Add compound"])

	do
		local function OnClick()
			self.status.expand = false
			self.requestRedraw()
		end

		local widget = AceGUI:Create("Button") --[[@as AceGUIButton]]
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
		if item.text == name then
			return true
		end
	end

	return false
end

--- @private
--- @param name string
--- @return TalentInfo?
function Drawer:GetTalentInfo(name)
	for _, talent in ipairs(self.talents) do
		if talent.text == name then
			return talent
		end
	end

	return nil
end

Addon.BindingConfig.BindingConditionDrawers = Addon.BindingConfig.BindingConditionDrawers or {}
Addon.BindingConfig.BindingConditionDrawers["talent"] = Drawer

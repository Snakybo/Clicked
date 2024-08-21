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

--- @class BindingMultiselectConditionDrawer : BindingConditionDrawer
--- @field private checkbox ClickedCheckBox
--- @field private dropdown? ClickedDropdown
--- @field private dropdownCb? fun():boolean
--- @field private multiselectDropdown? ClickedDropdown
--- @field private multiselectDropdownCb? fun():boolean
local Drawer = {}

--- @protected
function Drawer:Draw()
	local drawer = self.condition.drawer

	local isAnyEnabled = FindInTableIf(self.bindings, function(binding)
		--- @type MultiselectLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()
		return load.selected > 0
	end) ~= nil

	do
		--- @param state `0`|`1`|`2`
		--- @return boolean?
		local function IndexToValue(state)
			if state == 1 then
				return true
			elseif state == 2 then
				return nil
			end

			return false
		end

		--- @param value? boolean
		--- @return `0`|`1`|`2`
		local function ValueToIndex(value)
			if value == false then
				return 0
			elseif value == true then
				return 1
			else
				return 2
			end
		end

		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type MultiselectLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()

			if load.selected == 0 then
				return Addon.L["Disabled"]
			elseif load.selected == 1 then
				return Addon.L["Single"]
			else
				return Addon.L["Multiple"]
			end
		end

		--- @param binding Binding
		--- @return boolean?
		local function GetEnabledState(binding)
			--- @type MultiselectLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return IndexToValue(load.selected)
		end

		--- @param value boolean|nil
		local function OnValueChanged(_, _, value)
			local index = ValueToIndex(value)

			for _, binding in ipairs(self.bindings) do
				--- @type MultiselectLoadOption
				local load = binding.load[self.fieldName] or self.condition.init()
				load.selected = index
				binding.load[self.fieldName] = load

				Clicked:ReloadBinding(binding, true)
			end

			self.requestRedraw()
		end

		self.checkbox = AceGUI:Create("ClickedCheckBox") --[[@as ClickedCheckBox]]
		self.checkbox:SetType("checkbox")
		self.checkbox:SetCallback("OnValueChanged", OnValueChanged)
		self.checkbox:SetTriState(true)

		if isAnyEnabled then
			self.checkbox:SetRelativeWidth(0.5)
		else
			self.checkbox:SetFullWidth(true)
		end

		Helpers:HandleWidget(self.checkbox, self.bindings, ValueSelector, Addon.L[drawer.label], nil, GetEnabledState)

		self.container:AddChild(self.checkbox)
	end

	if isAnyEnabled then
		local isAnySingleSelect = FindInTableIf(self.bindings, function(binding)
			--- @type MultiselectLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return load.selected == 1
		end) ~= nil

		local isAnyMultiSelect = FindInTableIf(self.bindings, function(binding)
			--- @type MultiselectLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()
			return load.selected == 2
		end) ~= nil

		--- @type table<unknown, string>, unknown[]
		local items, order = self.requestAvailableValues()

		if isAnySingleSelect then
			self:DrawMultiSelectSingle(drawer, items, order)
		end

		if isAnyMultiSelect then
			self:DrawMultiSelectMultiple(drawer, items, order, isAnySingleSelect)
		end
	end
end


--- @protected
function Drawer:Update()
	local items, order = self.requestAvailableValues()

	if self.dropdown ~= nil then
		self.dropdown:SetList(items, order)
		self.dropdownCb()
	end

	if self.multiselectDropdown ~= nil then
		self.multiselectDropdown:SetList(items, order)
		self.multiselectDropdownCb()
	end
end

--- @private
--- @param drawer DrawerConfig
--- @param items table<unknown, string>
--- @param order unknown[]
function Drawer:DrawMultiSelectSingle(drawer, items, order)
	--- @param binding Binding
	--- @return string
	local function ValueSelector(binding)
		--- @type MultiselectLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()

		if load.selected == 1 then
			return items[load.single]
		end

		return Helpers.IGNORE_VALUE
	end

	--- @param binding Binding
	--- @return unknown?
	local function GetRawValue(binding)
		--- @type MultiselectLoadOption
		local load = binding.load[self.fieldName] or self.condition.init()

		if load.selected == 1 then
			return load.single
		end

		return Helpers.IGNORE_VALUE
	end

		--- @param value string
	local function OnValueChanged(_, _, value)
		for _, binding in ipairs(self.bindings) do
			--- @type MultiselectLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()

			if load.selected == 1 then
				load.single = value
				binding.load[self.fieldName] = load
				Clicked:ReloadBinding(binding, true)
			end
		end

		self.requestRedraw(true)
	end

	self.dropdown = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown]]
	self.dropdown:SetCallback("OnValueChanged", OnValueChanged)
	self.dropdown:SetList(items, order)
	self.dropdown:SetRelativeWidth(0.5)

	local _, cb = Helpers:HandleWidget(self.dropdown, self.bindings, ValueSelector, Addon.L[drawer.label], nil, GetRawValue)
	self.dropdownCb = cb

	self.container:AddChild(self.dropdown)
end

--- @private
--- @param drawer DrawerConfig
--- @param items table<unknown, string>
--- @param order unknown[]
--- @param offset boolean
function Drawer:DrawMultiSelectMultiple(drawer, items, order, offset)
	-- padding
	if offset then
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetRelativeWidth(0.5)

		self.container:AddChild(widget)
	end

	-- dropdown
	do
		local changed = false

		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			--- @type MultiselectLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()

			if load.selected == 2 then
				if #load.multiple == 0 then
					return Addon.L["Nothing"]
				elseif #load.multiple == #order then
					return Addon.L["Everything"]
				else
					--- @type string[]
					local result = {}

					for _, index in ipairs(load.multiple) do
						table.insert(result, items[index])
					end

					return table.concat(result, ", ")
				end
			end

			return Helpers.IGNORE_VALUE
		end

		--- @param binding Binding
		--- @return unknown?
		local function GetRawValue(binding)
			--- @type MultiselectLoadOption
			local load = binding.load[self.fieldName] or self.condition.init()

			if load.selected == 2 then
				return load.multiple
			end

			return Helpers.IGNORE_VALUE
		end

		--- @param value string
		--- @param enabled boolean
		local function OnValueChanged(_, _, value, enabled)
			for _, binding in ipairs(self.bindings) do
				--- @type MultiselectLoadOption
				local load = binding.load[self.fieldName] or self.condition.init()

				if load.selected == 2 then
					if enabled then
						table.insert(load.multiple, value)
					else
						for i = #load.multiple, 1, -1 do
							if load.multiple[i] == value then
								table.remove(load.multiple, i)
								break
							end
						end
					end

					changed = true
					binding.load[self.fieldName] = load
				end

			end
		end

		local function OnClosed()
			if changed then
				for _, binding in ipairs(self.bindings) do
					--- @type MultiselectLoadOption
					local load = binding.load[self.fieldName] or self.condition.init()

					if load.selected == 2 then
						Clicked:ReloadBinding(binding, true)
					end
				end

				self.requestRedraw(true)
				changed = false
			end
		end

		self.multiselectDropdown = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown]]
		self.multiselectDropdown:SetCallback("OnValueChanged", OnValueChanged)
		self.multiselectDropdown:SetCallback("OnClosed", OnClosed)
		self.multiselectDropdown:SetList(items, order)
		self.multiselectDropdown:SetRelativeWidth(0.5)
		self.multiselectDropdown:SetMultiselect(true)

		local _, cb = Helpers:HandleWidget(self.multiselectDropdown, self.bindings, ValueSelector, Addon.L[drawer.label], nil, GetRawValue)
		self.multiselectDropdownCb = cb

		self.container:AddChild(self.multiselectDropdown)
	end
end

Addon.BindingConfig.BindingConditionDrawers = Addon.BindingConfig.BindingConditionDrawers or {}
Addon.BindingConfig.BindingConditionDrawers["multiselect"] = Drawer

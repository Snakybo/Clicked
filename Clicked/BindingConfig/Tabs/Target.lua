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

-- Private addon API

--- @enum TargetFlags
Addon.TargetFlags = {
	Friendly = 1,
	Hostile = 2,
	Alive = 4,
	Dead = 8,
}

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigTargetTab : BindingConfigTab
local BindingTargetTab = {}

Addon.BindingConfig.BindingTargetTab = BindingTargetTab

--- @protected
function BindingTargetTab:Redraw()
	--- @param binding Binding
	--- @return boolean
	local function CanToggleRegularTargetMode(binding)
		return not Addon:IsRestrictedKeybind(binding.keybind) and not Addon:IsRestrictedAction(binding.actionType)
	end

	--- @param binding Binding
	--- @return boolean
	local function CanToggleUnitFrameTargetMode(binding)
		return not Addon:IsRestrictedKeybind(binding.keybind) and not Addon:IsRestrictedAction(binding.actionType)
	end


	-- hovercast
	do
		--- @param binding Binding
		--- @return string
		local function ValueSelector(binding)
			return binding.targets.hovercastEnabled and Addon.L["Enabled"] or Addon.L["Disabled"]
		end

		--- @param binding Binding
		--- @return boolean
		local function GetEnabledState(binding)
			return binding.targets.hovercastEnabled
		end

		--- @param widget ClickedToggleHeading
		--- @param event string
		--- @param value boolean
		local function OnValueChanged(widget, event, value)
			for _, binding in ipairs(self.bindings) do
				if CanToggleUnitFrameTargetMode(binding) then
					binding.targets.hovercastEnabled = value
					Addon:ReloadBinding(binding, "targets")
				end
			end

			self.controller:RedrawTab()
		end

		do
			local canInteract = false

			for _, binding in ipairs(self.bindings) do
				if CanToggleUnitFrameTargetMode(binding) then
					canInteract = true
					break
				end
			end

			local widget = AceGUI:Create("ClickedToggleHeading") --[[@as ClickedToggleHeading]]
			widget:SetFullWidth(true)
			widget:SetCallback("OnValueChanged", OnValueChanged)
			widget:SetDisabled(not canInteract)

			Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Unit frame"], GetEnabledState)

			self.container:AddChild(widget)
		end

		--- @param binding Binding
		--- @return boolean
		local function IsHovercastEnabled(binding)
			return binding.targets.hovercastEnabled
		end

		local isAnyEnabled = FindInTableIf(self.bindings, IsHovercastEnabled)

		if isAnyEnabled then
			do
				local widget = self:DrawTargetStates(self.container, -1)

				if widget ~= nil then
					widget:SetFullWidth(true)
				end
			end
		end
	end

	-- regular
	do
		if FindInTableIf(self.bindings, CanToggleRegularTargetMode) ~= nil then
			--- @param binding Binding
			--- @return string
			local function ValueSelector(binding)
				return binding.targets.regularEnabled and Addon.L["Enabled"] or Addon.L["Disabled"]
			end

			--- @param binding Binding
			--- @return boolean
			local function GetEnabledState(binding)
				return binding.targets.regularEnabled
			end

			--- @param widget ClickedToggleHeading
			--- @param event string
			--- @param value boolean
			local function OnValueChanged(widget, event, value)
				for _, binding in ipairs(self.bindings) do
					if CanToggleRegularTargetMode(binding) then
						binding.targets.regularEnabled = value
						Addon:ReloadBinding(binding, "targets")
					end
				end

				self.controller:RedrawTab()
			end

			do
				local widget = AceGUI:Create("ClickedToggleHeading") --[[@as ClickedToggleHeading]]
				widget:SetFullWidth(true)
				widget:SetCallback("OnValueChanged", OnValueChanged)

				Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Global"], GetEnabledState)

				self.container:AddChild(widget)
			end

			--- @param binding Binding
			--- @return boolean
			local function IsRegularEnabled(binding)
				return binding.targets.regularEnabled
			end

			local isAnyEnabled = FindInTableIf(self.bindings, IsRegularEnabled)

			if isAnyEnabled then
				local maxTargets = 0

				for _, binding in ipairs(self.bindings) do
					maxTargets = math.max(maxTargets, #binding.targets.regular)
				end

				for i = 1, maxTargets + 1 do
					--- @param widget ClickedTargetGroup
					--- @param event string
					local function OnMove(widget, event)
						for _, binding in ipairs(self.bindings) do
							if event == "OnMoveUp" then
								local temp = binding.targets.regular[i - 1]

								if temp ~= nil then
									binding.targets.regular[i - 1] = binding.targets.regular[i]
									binding.targets.regular[i] = temp
								end
							elseif event == "OnMoveDown" then
								local temp = binding.targets.regular[i + 1]

								if temp ~= nil then
									binding.targets.regular[i + 1] = binding.targets.regular[i]
									binding.targets.regular[i] = temp
								end
							end

							Addon:ReloadBinding(binding)
						end

						self.controller:RedrawTab()
					end

					local index = i > maxTargets and 0 or i

					local group = AceGUI:Create("ClickedTargetGroup") --[[@as ClickedTargetGroup]]
					group:SetFullWidth(true)
					group:SetLayout("Flow")
					group:SetMoveUpButton(index ~= 0 and i > 1)
					group:SetMoveDownButton(index ~= 0 and i < maxTargets)
					group:SetCallback("OnMoveDown", OnMove)
					group:SetCallback("OnMoveUp", OnMove)

					local unit = self:DrawTargetUnit(group, index, maxTargets > 1)
					local states = self:DrawTargetStates(group, index)

					if states == nil then
						unit:SetRelativeWidth(1)
					else
						unit:SetRelativeWidth(0.5)
						states:SetRelativeWidth(0.5)
					end

					self.container:AddChild(group)
				end
			end
		end
	end

	--- @param binding Binding
	--- @return boolean
	local function IsUnrestrictedKeybind(binding)
		return not Addon:IsRestrictedKeybind(binding.keybind)
	end

	local hasUnrestrictedKeybind = FindInTableIf(self.bindings, IsUnrestrictedKeybind)

	if not hasUnrestrictedKeybind then
		local widget = AceGUI:Create("Label")
		widget:SetText(RED_FONT_COLOR:WrapTextInColorCode(Addon.L["The left and right mouse button can only activate when hovering over unit frames."]) .. "\n")
		widget:SetFullWidth(true)
		widget:SetFontObject(GameFontHighlight)

		self.container:AddChild(widget)
	end
end

--- @protected
--- @param relevant boolean
function BindingTargetTab:OnBindingReload(relevant)
	if relevant then
		self.controller:RedrawTab()
	end
end

--- @private
--- @param container AceGUIContainer
--- @param index integer
--- @param canDelete boolean
--- @return AceGUIDropdown
function BindingTargetTab:DrawTargetUnit(container, index, canDelete)
	local items = {
		[Addon.TargetUnit.DEFAULT] = Addon.L["Default"],
		[Addon.TargetUnit.PLAYER] = Addon.L["Player (you)"],
		[Addon.TargetUnit.TARGET] = Addon.L["Target"],
		[Addon.TargetUnit.TARGET_OF_TARGET] = Addon.L["Target of target"],
		[Addon.TargetUnit.MOUSEOVER] = Addon.L["Mouseover"],
		[Addon.TargetUnit.MOUSEOVER_TARGET] = Addon.L["Target of mouseover"],
		[Addon.TargetUnit.CURSOR] = Addon.L["Cursor"],
		[Addon.TargetUnit.PET] = Addon.L["Pet"],
		[Addon.TargetUnit.PET_TARGET] = Addon.L["Pet target"],
		[Addon.TargetUnit.PARTY_1] = Addon.L["Party %s"]:format("1"),
		[Addon.TargetUnit.PARTY_2] = Addon.L["Party %s"]:format("2"),
		[Addon.TargetUnit.PARTY_3] = Addon.L["Party %s"]:format("3"),
		[Addon.TargetUnit.PARTY_4] = Addon.L["Party %s"]:format("4"),
		[Addon.TargetUnit.PARTY_5] = Addon.L["Party %s"]:format("5")
	}

	local order = {
		Addon.TargetUnit.DEFAULT,
		Addon.TargetUnit.PLAYER,
		Addon.TargetUnit.TARGET,
		Addon.TargetUnit.TARGET_OF_TARGET,
		Addon.TargetUnit.MOUSEOVER,
		Addon.TargetUnit.MOUSEOVER_TARGET,
		Addon.TargetUnit.CURSOR,
		Addon.TargetUnit.PET,
		Addon.TargetUnit.PET_TARGET,
		Addon.TargetUnit.PARTY_1,
		Addon.TargetUnit.PARTY_2,
		Addon.TargetUnit.PARTY_3,
		Addon.TargetUnit.PARTY_4,
		Addon.TargetUnit.PARTY_5
	}

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.TBC or Addon:IsForever() then
		items[Addon.TargetUnit.FOCUS] = Addon.L["Focus"]
		table.insert(order, 7, Addon.TargetUnit.FOCUS)
	end

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.CATA then
		items[Addon.TargetUnit.ARENA_1] = Addon.L["Arena %s"]:format("1")
		items[Addon.TargetUnit.ARENA_2] = Addon.L["Arena %s"]:format("2")
		items[Addon.TargetUnit.ARENA_3] = Addon.L["Arena %s"]:format("3")
		table.insert(order, Addon.TargetUnit.ARENA_1)
		table.insert(order, Addon.TargetUnit.ARENA_2)
		table.insert(order, Addon.TargetUnit.ARENA_3)
	end

	if index == 0 then
		items["_NONE_"] = Addon.L["<No one>"]
		table.insert(order, "_NONE_")
	elseif canDelete then
		items["_DELETE_"] = Addon.L["<Remove this target>"]
		table.insert(order, "_DELETE_")
	end

	--- @param binding Binding
	--- @return string?
	local function ValueSelector(binding)
		if index == 0 then
			return items["_NONE_"]
		end

		local target = binding.targets.regular[index]
		return target ~= nil and target.unit ~= nil and items[target.unit] or Helpers.IGNORE_VALUE
	end

	---@param binding Binding
	---@return string
	local function GetRawValue(binding)
		if index == 0 then
			return "_NONE_"
		end

		local target = binding.targets.regular[index]
		return target ~= nil and target.unit or Helpers.IGNORE_VALUE
	end

	--- @param widget ClickedDropdown<string, string>
	--- @param event string
	--- @param value string
	local function OnValueChanged(widget, event, value)
		if value == "_NONE_" then
			return
		elseif value == "_DELETE_" then
			for _, binding in ipairs(self.bindings) do
				if #binding.targets.regular > 1 and table.remove(binding.targets.regular, index) then
					Addon:ReloadBinding(binding)
				end
			end
		elseif index == 0 then
			for _, binding in ipairs(self.bindings) do
				local last = binding.targets.regular[#binding.targets.regular]

				local new = Addon:GetNewBindingTargetTemplate()
				new.unit = value
				new.flags = last.flags

				table.insert(binding.targets.regular, new)
				Addon:ReloadBinding(binding)
			end
		else
			for _, binding in ipairs(self.bindings) do
				local target = binding.targets.regular[index]

				if target ~= nil then
					target.unit = value
					Addon:ReloadBinding(binding)
				end
			end
		end

		self.controller:RedrawTab()
	end

	local widget = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown<string, string>]]
	widget:SetList(items, order)
	widget:SetCallback("OnValueChanged", OnValueChanged)

	Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Unit"], GetRawValue)

	container:AddChild(widget)

	return widget
end

--- @private
--- @param container AceGUIContainer
--- @param index integer
--- @return AceGUIDropdown?
function BindingTargetTab:DrawTargetStates(container, index)
	--- @param binding Binding
	--- @return boolean
	local function CanBeHostile(binding)
		local target = binding.targets.regular[index]
		return target ~= nil and Addon:CanUnitBeHostile(target.unit)
	end

	--- @param binding Binding
	--- @return boolean
	local function CanBeDead(binding)
		local target = binding.targets.regular[index]
		return target ~= nil and Addon:CanUnitBeDead(target.unit)
	end

	--- @type table<integer, string>
	local items = {}

	--- @type integer[]
	local order = {}

	if index == -1 or FindInTableIf(self.bindings, CanBeHostile) then
		items[Addon.TargetFlags.Friendly] = Addon.L["Friendly"]
		items[Addon.TargetFlags.Hostile] = Addon.L["Hostile"]
		table.insert(order, Addon.TargetFlags.Friendly)
		table.insert(order, Addon.TargetFlags.Hostile)
	end

	if index == -1 or FindInTableIf(self.bindings, CanBeDead) then
		items[Addon.TargetFlags.Alive] = Addon.L["Alive"]
		items[Addon.TargetFlags.Dead] = Addon.L["Dead"]
		table.insert(order, Addon.TargetFlags.Alive)
		table.insert(order, Addon.TargetFlags.Dead)
	end

	local changed = false

	--- @param binding Binding
	--- @return string
	local function ValueSelector(binding)
		local target = index == -1 and binding.targets.hovercast or binding.targets.regular[index]
		if target == nil then
			return Helpers.IGNORE_VALUE
		end

		local values = {}

		for _, flag in ipairs(order) do
			if bit.band(target.flags, flag) > 0 then
				table.insert(values, flag)
			end
		end

		if #values == 0 then
			return Addon.L["Nothing"]
		elseif #values == #order then
			return Addon.L["Everything"]
		end

		--- @type string[]
		local result = {}

		for _, value in ipairs(values) do
			table.insert(result, items[value] or tostring(value))
		end

		return table.concat(result, ", ")
	end

	--- @param binding Binding
	--- @return "\001"|integer[]
	local function GetRawValue(binding)
		local target = index == -1 and binding.targets.hovercast or binding.targets.regular[index]
		if target == nil then
			return Helpers.IGNORE_VALUE
		end

		local result = {}

		for _, flag in ipairs(order) do
			if bit.band(target.flags, flag) > 0 then
				table.insert(result, flag)
			end
		end

		return result
	end

	--- @param widget ClickedDropdown<integer, string>
	--- @param event string
	--- @param value integer
	--- @param enabled boolean
	local function OnValueChanged(widget, event, value, enabled)
		for _, binding in ipairs(self.bindings) do
			local target = index == -1 and binding.targets.hovercast or binding.targets.regular[index]

			if target ~= nil then
				local values = {}

				for _, flag in ipairs(order) do
					if bit.band(target.flags, flag) > 0 then
						table.insert(values, flag)
					end
				end

				if enabled then
					if not tContains(values, value) then
						table.insert(values, value)
					end
				else
					for i = #values, 1, -1 do
						if values[i] == value then
							table.remove(values, i)
						end
					end
				end

				local mask = 0

				for _, flag in ipairs(values) do
					mask = bit.bor(mask, flag)
				end

				target.flags = mask
				changed = true
			end
		end
	end

	local function OnClosed()
		if changed then
			for _, binding in ipairs(self.bindings) do
				Addon:ReloadBinding(binding)
			end

			self.controller:RedrawTab()
			changed = false
		end
	end

	if #order == 0 then
		return nil
	end

	local widget = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown<integer, string>]]
	widget:SetCallback("OnValueChanged", OnValueChanged)
	widget:SetCallback("OnClosed", OnClosed)
	widget:SetList(items, order)
	widget:SetMultiselect(true)

	Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Flags"], GetRawValue)

	container:AddChild(widget)

	return widget
end

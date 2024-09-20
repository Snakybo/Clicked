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

-- Private addon API

Addon.BindingConfig = Addon.BindingConfig or {}

--- @class BindingConfigTargetTab : BindingConfigTab
Addon.BindingConfig.BindingTargetTab = {}

--- @protected
function Addon.BindingConfig.BindingTargetTab:Redraw()
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

		--- @param value boolean
		local function OnValueChanged(_, _, value)
			for _, binding in ipairs(self.bindings) do
				binding.targets.hovercastEnabled = value
				Addon:ReloadBinding(binding, "targets")
			end

			self.controller:RedrawTab()
		end

		do
			local widget = AceGUI:Create("ClickedToggleHeading") --[[@as ClickedToggleHeading]]
			widget:SetFullWidth(true)
			widget:SetCallback("OnValueChanged", OnValueChanged)

			Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Unit frame"], GetEnabledState)

			self.container:AddChild(widget)
		end

		local isAnyEnabled = FindInTableIf(self.bindings, function(binding)
			return binding.targets.hovercastEnabled
		end)

		if isAnyEnabled then
			do
				local widget = self:DrawTargetHostility(self.container, -1)
				widget:SetRelativeWidth(0.5)
			end

			do
				local widget = self:DrawTargetVitals(self.container, -1)
				widget:SetRelativeWidth(0.5)
			end
		end
	end

	-- regular
	do
		--- @param binding Binding
		--- @return boolean
		local function CanEnableRegularTargetMode(binding)
			local disallowed = { Clicked.ActionType.UNIT_SELECT, Clicked.ActionType.UNIT_MENU }

			if Addon:IsRestrictedKeybind(binding.keybind) or tContains(disallowed, binding.actionType) then
				return false
			end

			return true
		end

		if FindInTableIf(self.bindings, CanEnableRegularTargetMode) ~= nil then
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

			--- @param value boolean
			local function OnValueChanged(_, _, value)
				for _, binding in ipairs(self.bindings) do
					if CanEnableRegularTargetMode(binding) then
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

			local isAnyEnabled = FindInTableIf(self.bindings, function(binding)
				return binding.targets.regularEnabled
			end)

			if isAnyEnabled then
				local maxTargets = 0

				for _, binding in ipairs(self.bindings) do
					maxTargets = math.max(maxTargets, #binding.targets.regular)
				end

				for i = 1, maxTargets + 1 do
					local function OnMove(_, event)
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

					local canAnyBeHostile = FindInTableIf(self.bindings, function(binding)
						local target = binding.targets.regular[i]
						return target ~= nil and Addon:CanUnitBeHostile(target.unit)
					end)

					local canAnyBeDead = FindInTableIf(self.bindings, function(binding)
						local target = binding.targets.regular[i]
						return target ~= nil and Addon:CanUnitBeDead(target.unit)
					end)

					do
						local widget = self:DrawTargetUnit(group, index, maxTargets > 1)
						widget:SetRelativeWidth(0.33)
					end

					do
						local widget = self:DrawTargetHostility(group, index)
						widget:SetRelativeWidth(0.33)

						if index == 0 or not canAnyBeHostile then
							widget:SetDisabled(true)
						end
					end

					do
						local widget = self:DrawTargetVitals(group, index)
						widget:SetRelativeWidth(0.33)

						if index == 0 or not canAnyBeDead then
							widget:SetDisabled(true)
						end
					end

					self.container:AddChild(group)
				end
			end
		end
	end

	local hasUnrestrictedKeybind = FindInTableIf(self.bindings, function(binding)
		return not Addon:IsRestrictedKeybind(binding.keybind)
	end)

	if not hasUnrestrictedKeybind then
		local widget = AceGUI:Create("Label") --[[@as AceGUILabel]]
		widget:SetText(RED_FONT_COLOR:WrapTextInColorCode(Addon.L["The left and right mouse button can only activate when hovering over unit frames."]) .. "\n")
		widget:SetFullWidth(true)
		widget:SetFontObject(GameFontHighlight)

		self.container:AddChild(widget)
	end
end

--- @protected
--- @param relevant boolean
function Addon.BindingConfig.BindingTargetTab:OnBindingReload(relevant)
	if relevant then
		self.controller:RedrawTab()
	end
end

--- @private
--- @param container AceGUIContainer
--- @param index integer
--- @param canDelete boolean
--- @return AceGUIDropdown
function Addon.BindingConfig.BindingTargetTab:DrawTargetUnit(container, index, canDelete)
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

	if Addon.EXPANSION_LEVEL >= Addon.Expansion.BC then
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
		return target and items[target.unit] or Helpers.IGNORE_VALUE
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

	--- @param value string
	local function OnValueChanged(_, _, value)
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
				new.hostility = last.hostility or new.hostility
				new.vitals = last.vitals or new.vitals

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

	local widget = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown]]
	widget:SetList(items, order)
	widget:SetCallback("OnValueChanged", OnValueChanged)

	Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Unit"], GetRawValue)

	container:AddChild(widget)

	return widget
end

--- @private
--- @param container AceGUIContainer
--- @param index integer
--- @return AceGUIDropdown
function Addon.BindingConfig.BindingTargetTab:DrawTargetHostility(container, index)
	local items = {
		[Addon.TargetHostility.ANY] = Addon.L["Any"],
		[Addon.TargetHostility.HELP] = Addon.L["Friendly"],
		[Addon.TargetHostility.HARM] = Addon.L["Hostile"]
	}

	local order = {
		Addon.TargetHostility.ANY,
		Addon.TargetHostility.HELP,
		Addon.TargetHostility.HARM
	}

	--- @param binding Binding
	--- @return string?
	local function ValueSelector(binding)
		local target = index == -1 and binding.targets.hovercast or binding.targets.regular[index]
		return target and items[target.hostility] or Helpers.IGNORE_VALUE
	end

	---@param binding Binding
	---@return string
	local function GetRawValue(binding)
		local target = index == -1 and binding.targets.hovercast or binding.targets.regular[index]
		return target and target.hostility or Helpers.IGNORE_VALUE
	end

	--- @param value string
	local function OnValueChanged(_, _, value)
		for _, binding in ipairs(self.bindings) do
			local target = index == -1 and binding.targets.hovercast or binding.targets.regular[index]

			if target ~= nil then
				target.hostility = value
				Addon:ReloadBinding(binding)
			end
		end

		self.controller:RedrawTab()
	end

	local widget = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown]]
	widget:SetList(items, order)
	widget:SetCallback("OnValueChanged", OnValueChanged)

	Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Hostility"], GetRawValue)

	container:AddChild(widget)

	return widget
end

--- @private
--- @param container AceGUIContainer
--- @param index integer
--- @return AceGUIDropdown
function Addon.BindingConfig.BindingTargetTab:DrawTargetVitals(container, index)
	local items = {
		[Addon.TargetVitals.ANY] = Addon.L["Any"],
		[Addon.TargetVitals.ALIVE] = Addon.L["Alive"],
		[Addon.TargetVitals.DEAD] = Addon.L["Dead"]
	}

	local order = {
		Addon.TargetVitals.ANY,
		Addon.TargetVitals.ALIVE,
		Addon.TargetVitals.DEAD
	}

	--- @param binding Binding
	--- @return string?
	local function ValueSelector(binding)
		local target = index == -1 and binding.targets.hovercast or binding.targets.regular[index]
		return target and items[target.vitals] or Helpers.IGNORE_VALUE
	end

	---@param binding Binding
	---@return string
	local function GetRawValue(binding)
		local target = index == -1 and binding.targets.hovercast or binding.targets.regular[index]
		return target and target.vitals or Helpers.IGNORE_VALUE
	end

	--- @param value string
	local function OnValueChanged(_, _, value)
		for _, binding in ipairs(self.bindings) do
			local target = index == -1 and binding.targets.hovercast or binding.targets.regular[index]

			if target ~= nil then
				target.vitals = value
				Addon:ReloadBinding(binding)
			end
		end

		self.controller:RedrawTab()
	end

	local widget = AceGUI:Create("ClickedDropdown") --[[@as ClickedDropdown]]
	widget:SetList(items, order)
	widget:SetCallback("OnValueChanged", OnValueChanged)

	Helpers:HandleWidget(widget, self.bindings, ValueSelector, Addon.L["Vitals"], GetRawValue)

	container:AddChild(widget)

	return widget
end

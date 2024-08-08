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

--- @class ClickedUIWidgetHandler
--- @field public setValueFunc fun(self: AceGUIWidget, value: any)
--- @field public onPreValueChanged fun(self: AceGUIWidget, value: any, previousValue: any)?
--- @field public onPostValueChanged fun(AceGUIWidget, value: any)?
--- @field public ref table
--- @field public key string

--- @class ClickedInternal
local Addon = select(2, ...)

--- @type { [AceGUIWidget]: ClickedUIWidgetHandler }
local widgets = {}

--- @type table<AceGUIWidget, Binding>
local bindingMap = {}

--- @param frame AceGUIWidget
--- @param _ any
--- @param value any
local function OnSerialize(frame, _, value)
	local data = widgets[frame]

	if InCombatLockdown() then
		data.setValueFunc(frame, data.ref[data.key])
		Addon:NotifyCombatLockdown()
		return
	end

	if data.onPreValueChanged ~= nil then
		value = data.onPreValueChanged(frame, value, data.ref[data.key])
	end

	data.ref[data.key] = value

	if data.onPostValueChanged ~= nil then
		data.onPostValueChanged(frame, value)
	end

	if bindingMap[frame] ~= nil then
		Clicked:ReloadBinding(bindingMap[frame], true)
	else
		Addon:BindingConfig_Redraw()
	end
end

--- @param type AceGUIWidgetType
--- @return AceGUIWidget
local function CreateGUI(type)
	local widget = AceGUI:Create(type)

	local orgininalOnRelease = widget.OnRelease

	widget.OnRelease = function()
		widgets[widget] = nil

		if orgininalOnRelease ~= nil then
			orgininalOnRelease(widget)
		end
	end

	return widget
end

--- Set a callback which is invoked prior to when the value is changed
---
--- @generic T
--- @param widget AceGUIWidget
--- @param callback fun(frame: AceGUIWidget, newValue: T, oldValue: T):T
function Addon:GUI_SetPreValueChanged(widget, callback)
	if widget == nil or widgets[widget] == nil then
		return
	end

	widgets[widget].onPreValueChanged = callback
end

--- Set a callback which is invoked after the value is changed
---
--- @generic T
--- @param widget AceGUIWidget
--- @param callback fun(frame: AceGUIWidget, value: T)
function Addon:GUI_SetPostValueChanged(widget, callback)
	if widget == nil or widgets[widget] == nil then
		return
	end

	widgets[widget].onPostValueChanged = callback
end

--- @param text string
--- @param fontSize? '"small"'|'"medium"'|'"large"'
--- @return AceGUILabel
function Addon:GUI_Label(text, fontSize)
	local widget = CreateGUI("Label") --[[@as AceGUILabel]]
	widget:SetText(text)

	if fontSize == "medium" then
		widget:SetFontObject(GameFontHighlight)
	elseif fontSize == "large" then
		widget:SetFontObject(GameFontHighlightLarge)
	else -- small or invalid
		widget:SetFontObject(GameFontHighlightSmall)
	end

	return widget
end

--- @param callback '"OnTextChanged"'|'"OnEnterPressed"'
--- @param ref table
--- @param key string
--- @param binding Binding?
--- @return AceGUIEditBox
function Addon:GUI_EditBox(callback, ref, key, binding)
	local function OnCallback(frame, event, value)
		value = Addon:TrimString(value)
		OnSerialize(frame, event, value)
	end

	assert(type(ref) == "table", "bad argument #3, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #4, expected string but got " .. type(key))

	local widget = CreateGUI("EditBox") --[[@as AceGUIEditBox]]
	widget:SetText(ref[key])
	widget:SetCallback(callback, OnCallback)

	bindingMap[widget] = binding
	widgets[widget] = {
		setValueFunc = widget.SetText,
		ref = ref,
		key = key
	}

	return widget
end

--- @param ref table
--- @param key string
--- @param binding Binding
--- @return ClickedAutoFillEditBox
function Addon:GUI_AutoFillEditBox(ref, key, binding)
	local function OnCallback(frame, event, value)
		value = Addon:TrimString(value)
		OnSerialize(frame, event, value)
	end

	assert(type(ref) == "table", "bad argument #3, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #4, expected string but got " .. type(key))

	local widget = CreateGUI("ClickedAutoFillEditBox") --[[@as ClickedAutoFillEditBox]]
	widget:SetText(ref[key], true)
	widget:SetCallback("OnSelect", OnCallback)

	bindingMap[widget] = binding
	widgets[widget] = {
		setValueFunc = function(_, value) widget:SetText(value, true) end,
		ref = ref,
		key = key
	}

	return widget
end

--- @param callback '"OnTextChanged"'|'"OnEnterPressed"'
--- @param ref table
--- @param key string
--- @param binding Binding
--- @return AceGUIMultiLineEditBox
function Addon:GUI_MultilineEditBox(callback, ref, key, binding)
	assert(type(ref) == "table", "bad argument #2, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #3, expected string but got " .. type(key))

	local widget = CreateGUI("MultiLineEditBox") --[[@as AceGUIMultiLineEditBox]]
	widget:SetText(ref[key])
	widget:SetCallback(callback, OnSerialize)

	bindingMap[widget] = binding
	widgets[widget] = {
		setValueFunc = widget.SetText,
		ref = ref,
		key = key
	}

	return widget
end

--- @param ref table
--- @param key string
--- @param binding Binding
--- @return AceGUICheckBox
function Addon:GUI_CheckBox(ref, key, binding)
	local widget = CreateGUI("CheckBox") --[[@as AceGUICheckBox]]
	widget:SetType("checkbox")
	widget:SetCallback("OnValueChanged", OnSerialize)
	widget:SetValue(ref[key])

	bindingMap[widget] = binding
	widgets[widget] = {
		setValueFunc = widget.SetValue,
		ref = ref,
		key = key
	}

	return widget
end

--- @param ref table
--- @param key string
--- @param binding Binding
--- @return AceGUICheckBox
function Addon:GUI_TristateCheckBox(ref, key, binding)
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

	--- @param value boolean
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

	local function OnValueChanged(frame, event, value)
		value = ValueToIndex(value)
		OnSerialize(frame, event, value)
	end

	local function SetValue(widget, value)
		widget:SetValue(IndexToValue(value))
	end

	assert(type(ref) == "table", "bad argument #1, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #2, expected string but got " .. type(key))

	local widget = CreateGUI("CheckBox") --[[@as AceGUICheckBox]]
	widget:SetType("checkbox")
	widget:SetCallback("OnValueChanged", OnValueChanged)
	widget:SetTriState(true)
	widget:SetValue(IndexToValue(ref[key]))

	bindingMap[widget] = binding
	widgets[widget] = {
		setValueFunc = SetValue,
		ref = ref,
		key = key
	}

	return widget
end

--- @generic T
--- @param items table<T,any>
--- @param order T[]
--- @param ref table
--- @param key string
--- @param binding Binding
--- @return AceGUIDropdown
function Addon:GUI_Dropdown(items, order, ref, key, binding)
	assert(type(ref) == "table", "bad argument #3, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #4, expected string but got " .. type(key))

	local widget = CreateGUI("Dropdown") --[[@as AceGUIDropdown]]
	widget:SetList(items, order)
	widget:SetCallback("OnValueChanged", OnSerialize)
	widget:SetValue(ref[key])

	bindingMap[widget] = binding
	widgets[widget] = {
		setValueFunc = widget.SetValue,
		ref = ref,
		key = key
	}

	return widget
end

--- @generic T
--- @param items table<T,any>
--- @param order T[]
--- @param ref table
--- @param key string
--- @param binding Binding
--- @return ClickedDropdown
function Addon:GUI_MultiselectDropdown(items, order, ref, key, binding)
	local function OnValueChanged(frame, event)
		local total = {}

		for _, item in frame.pullout:IterateItems() do
			if item.GetValue and item:GetValue() then
				table.insert(total, item.userdata.value)
			end
		end

		OnSerialize(frame, event, total)
	end

	assert(type(ref) == "table", "bad argument #3, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #4, expected string but got " .. type(key))

	local widget = CreateGUI("Dropdown") --[[@as AceGUIDropdown]]
	widget:SetList(items, order)
	widget:SetMultiselect(true)
	widget:SetCallback("OnClosed", OnValueChanged)

	--- @generic T
	--- @param value T[]
	local function SetValue(value)
		for item in pairs(items) do
			widget:SetItemValue(item, false)
		end

		for _, saved in ipairs(value) do
			widget:SetItemValue(saved, true)
		end
	end

	SetValue(ref[key])

	bindingMap[widget] = binding
	widgets[widget] = {
		setValueFunc = SetValue,
		ref = ref,
		key = key
	}

	return widget
end

--- @param ref table
--- @param key string
--- @param binding Binding
--- @return ClickedKeybinding
function Addon:GUI_KeybindingButton(ref, key, binding)
	assert(type(ref) == "table", "bad argument #1, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #2, expected string but got " .. type(key))

	local widget = CreateGUI("ClickedKeybinding") --[[ @as ClickedKeybinding ]]
	local keybind = Addon:SanitizeKeybind(ref[key])

	widget:SetFullWidth(true)
	widget:SetKey(keybind)
	widget:SetCallback("OnKeyChanged", OnSerialize)

	bindingMap[widget] = binding
	widgets[widget] = {
		setValueFunc = widget.SetKey,
		ref = ref,
		key = key
	}

	return widget
end

--- @return ClickedTabGroup
function Addon:GUI_TabGroup()
	local widget = CreateGUI("ClickedTabGroup") --[[@as ClickedTabGroup]]
	widget:SetFullWidth(true)
	widget:SetFullHeight(true)
	widget:SetLayout("Fill")

	return widget
end

--- @return AceGUIInlineGroup
function Addon:GUI_InlineGroup()
	local widget = AceGUI:Create("InlineGroup") --[[@as AceGUIInlineGroup]]
	widget:SetFullWidth(true)
	widget:SetLayout("Flow")

	return widget
end

--- @return ClickedReorderableInlineGroup
function Addon:GUI_ReorderableInlineGroup()
	local widget = AceGUI:Create("ClickedReorderableInlineGroup") --[[@as ClickedReorderableInlineGroup]]
	widget:SetFullWidth(true)
	widget:SetLayout("Flow")

	return widget
end

--- @param ref table
--- @param key string
--- @param binding Binding
--- @return ClickedToggleHeading
function Addon:GUI_ToggleHeading(ref, key, binding)
	assert(type(ref) == "table", "bad argument #1, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #2, expected string but got " .. type(key))

	local widget = AceGUI:Create("ClickedToggleHeading") --[[@as ClickedToggleHeading]]
	widget:SetFullWidth(true)
	widget:SetCallback("OnValueChanged", OnSerialize)
	widget:SetValue(ref[key])

	bindingMap[widget] = binding
	widgets[widget] = {
		setValueFunc = widget.SetValue,
		ref = ref,
		key = key
	}

	return widget
end

local AceGUI = LibStub("AceGUI-3.0")

--- @type ClickedInternal
local _, Addon = ...

local widgets = {}

--- @param frame table
--- @param value any
local function OnSerialize(frame, _, value)
	local data = widgets[frame]

	if InCombatLockdown() then
		data.setValueFunc(frame, data.ref[data.key])
		Addon:NotifyCombatLockdown()
		return
	end

	data.ref[data.key] = value

	Clicked:ReloadActiveBindings()
end

--- @param type string
--- @return table
local function CreateGUI(type)
	local widget = AceGUI:Create(type)
	local orgininalOnRelease = widget.OnRelease

	widget.OnRelease = function(_)
		widgets[widget] = nil

		if orgininalOnRelease ~= nil then
			orgininalOnRelease(widget)
		end
	end

	return widget
end

--- @param frame table
--- @param event string
--- @param value any
function Addon:GUI_Serialize(frame, event, value)
	OnSerialize(frame, event, value)
end

--- @param text string
--- @param fontSize nil|'"small"'|'"medium"'|'"large"'
--- @return table
function Addon:GUI_Label(text, fontSize)
	local widget = CreateGUI("Label")
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

--- @param label string
--- @param callback '"OnTextChanged"'|'"OnEnterPressed"'
--- @param ref table
--- @param key any
--- @return table
function Addon:GUI_EditBox(label, callback, ref, key)
	local function OnCallback(frame, event, value)
		value = Addon:TrimString(value)
		OnSerialize(frame, event, value)
	end

	assert(type(ref) == "table", "bad argument #3, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #4, expected string but got " .. type(key))

	local widget = CreateGUI("EditBox")
	widget:SetText(ref[key])
	widget:SetLabel(label)
	widget:SetCallback(callback, OnCallback)

	widgets[widget] = {
		setValueFunc = widget.SetText,
		ref = ref,
		key = key
	}

	return widget
end

--- @param label string
--- @param callback '"OnTextChanged"'|'"OnEnterPressed"'
--- @param ref table
--- @param key any
--- @return table
function Addon:GUI_MultilineEditBox(label, callback, ref, key)
	assert(type(ref) == "table", "bad argument #3, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #4, expected string but got " .. type(key))

	local widget = CreateGUI("MultiLineEditBox")
	widget:SetLabel(label)
	widget:SetText(ref[key])
	widget:SetCallback(callback, OnSerialize)

	widgets[widget] = {
		setValueFunc = widget.SetText,
		ref = ref,
		key = key
	}

	return widget
end

--- @param label string
--- @param ref table
--- @param key any
--- @return table
function Addon:GUI_CheckBox(label, ref, key)
	local widget = CreateGUI("CheckBox")
	widget:SetType("checkbox")
	widget:SetLabel(label)
	widget:SetCallback("OnValueChanged", OnSerialize)
	widget:SetValue(ref[key])

	widgets[widget] = {
		setValueFunc = widget.SetValue,
		ref = ref,
		key = key
	}

	return widget
end

--- @param label string
--- @param ref table
--- @param key any
--- @return table
function Addon:GUI_TristateCheckBox(label, ref, key)
	local function IndexToValue(state)
		if state == 1 then
			return true
		elseif state == 2 then
			return nil
		end

		return false
	end

	local function ValueToIndex(value)
		if value == false then
			return 0
		elseif value == true then
			return 1
		elseif value == nil then
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

	assert(type(ref) == "table", "bad argument #2, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #3, expected string but got " .. type(key))

	local widget = CreateGUI("CheckBox")
	widget:SetType("checkbox")
	widget:SetLabel(label)
	widget:SetCallback("OnValueChanged", OnValueChanged)
	widget:SetTriState(true)
	widget:SetValue(IndexToValue(ref[key]))

	widgets[widget] = {
		setValueFunc = SetValue,
		ref = ref,
		key = key
	}

	return widget
end

--- @param label string
--- @param action fun(frame:table, event:string)
--- @return table
function Addon:GUI_Button(label, action)
	local widget = CreateGUI("Button")
	widget:SetText(label)
	widget:SetCallback("OnClick", action)

	return widget
end

--- @generic T
--- @param label string
--- @param items table<T,any>
--- @param order T[]
--- @param itemType string
--- @param ref table
--- @param key any
--- @return table
function Addon:GUI_Dropdown(label, items, order, itemType, ref, key)
	assert(type(ref) == "table", "bad argument #5, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #6, expected string but got " .. type(key))

	local widget = CreateGUI("ClickedDropDown")
	widget:SetList(items, order, itemType)
	widget:SetLabel(label)
	widget:SetCallback("OnValueChanged", OnSerialize)
	widget:SetValue(ref[key])

	widgets[widget] = {
		setValueFunc = widget.SetValue,
		ref = ref,
		key = key
	}

	return widget
end

--- @generic T
--- @param label string
--- @param items table<T,any>
--- @param order T[]
--- @param itemType string
--- @param ref table
--- @param key any
--- @return table
function Addon:GUI_MultiselectDropdown(label, items, order, itemType, ref, key)
	local function OnValueChanged(frame, event)
		local total = {}

		for _, item in frame.pullout:IterateItems() do
			if item.GetValue and item:GetValue() then
				table.insert(total, item.userdata.value)
			end
		end

		OnSerialize(frame, event, total)
	end

	assert(type(ref) == "table", "bad argument #5, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #6, expected string but got " .. type(key))

	local widget = CreateGUI("ClickedDropDown")
	widget:SetList(items, order, itemType)
	widget:SetMultiselect(true)
	widget:SetLabel(label)
	widget:SetCallback("OnClosed", OnValueChanged)

	local function SetValue(value, state)
		if type(value) == "table" then
			for item in pairs(items) do
				widget:SetItemValue(item, false)
			end

			for _, saved in ipairs(value) do
				widget:SetItemValue(saved, true)
			end
		else
			widget:SetItemValue(value, state)
		end
	end

	SetValue(ref[key])

	widgets[widget] = {
		setValueFunc = SetValue,
		ref = ref,
		key = key
	}

	return widget
end

--- @param label string
--- @param ref table
--- @param key any
--- @return table
function Addon:GUI_KeybindingButton(label, ref, key)
	assert(type(ref) == "table", "bad argument #2, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #3, expected string but got " .. type(key))

	local widget = CreateGUI("ClickedKeybinding")
	local keybind = Addon:SanitizeKeybind(ref[key])

	widget:SetLabel(label)
	widget:SetKey(keybind)
	widget:SetCallback("OnKeyChanged", OnSerialize)

	widgets[widget] = {
		setValueFunc = widget.SetKey,
		ref = ref,
		key = key
	}

	return widget
end

--- @param items table
--- @param handler fun(container:table, event:string, group:table)
--- @return table
function Addon:GUI_TabGroup(items, handler)
	local function OnGroupSelected(container, event, group)
		container:ReleaseChildren()
		handler(container, event, group)
	end

	local widget = CreateGUI("ClickedTabGroup")
	widget:SetFullWidth(true)
	widget:SetFullHeight(true)
	widget:SetLayout("Fill")
	widget:SetTabs(items)
	widget:SetCallback("OnGroupSelected", OnGroupSelected)

	return widget
end

--- @param title string
--- @return table
function Addon:GUI_InlineGroup(title)
	local widget = AceGUI:Create("InlineGroup")
	widget:SetFullWidth(true)
	widget:SetLayout("Flow")

	if title then
		widget:SetTitle(title)
	end

	return widget
end

--- @param title string
--- @return table
function Addon:GUI_ReorderableInlineGroup(title)
	local widget = AceGUI:Create("ClickedReorderableInlineGroup")
	widget:SetFullWidth(true)
	widget:SetLayout("Flow")

	if title then
		widget:SetTitle(title)
	end

	return widget
end

--- @param title string
--- @param ref table
--- @param key any
--- @return table
function Addon:GUI_ToggleHeading(title, ref, key)
	assert(type(ref) == "table", "bad argument #2, expected table but got " .. type(ref))
	assert(type(key) == "string", "bad argument #3, expected string but got " .. type(key))

	local widget = AceGUI:Create("ClickedToggleHeading")
	widget:SetFullWidth(true)
	widget:SetCallback("OnValueChanged", OnSerialize)
	widget:SetValue(ref[key])

	if title then
		widget:SetText(title)
	end

	widgets[widget] = {
		setValueFunc = widget.SetValue,
		ref = ref,
		key = key
	}

	return widget
end

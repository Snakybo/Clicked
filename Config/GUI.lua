local AceGUI = LibStub("AceGUI-3.0")

-- Create a namespace for GUI functions
local GUI = Clicked.GUI or {}
Clicked.GUI = GUI

GUI.EVENT_UPDATE = "CLICKED_GUI_UPDATE"

local widgets = {}

local function OnSerialize(frame, event, value)
	local data = widgets[frame]

	if InCombatLockdown() then
		data.setValueFunc(frame, data.ref[data.key])
		return
	end

	data.ref[data.key] = value

	Clicked:SendMessage(GUI.EVENT_UPDATE)
end

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

function GUI:Serialize(...)
	OnSerialize(...)
end

function GUI:Label(text, fontSize)
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

function GUI:EditBox(label, callback, ref, key)
	local function OnCallback(frame, event, value)
		value = Clicked:Trim(value)
		OnSerialize(frame, event, value)
	end

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

function GUI:MultilineEditBox(label, callback, ref, key)
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

function GUI:CheckBox(label, ref, key)
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

function GUI:TristateCheckBox(label, ref, key)
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

function GUI:Button(label, action)
	local widget = CreateGUI("Button")
	widget:SetText(label)
	widget:SetCallback("OnClick", action)

	return widget
end

function GUI:Dropdown(label, items, order, ref, key)
	local widget = CreateGUI("Dropdown")
	widget:SetList(items, order)
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

function GUI:MultiselectDropdown(label, items, order, ref, key)
	local function OnValueChanged(frame, event, value, state)
		local total = {}

		for _, item in ipairs(ref[key]) do
			table.insert(total, item)
		end

		if state then
			table.insert(total, value)
		else
			for index, item in ipairs(total) do
				if item == value then
					table.remove(total, index)
					break
				end
			end
		end

		OnSerialize(frame, event, total)
	end

	local widget = CreateGUI("Dropdown")
	widget:SetList(items, order)
	widget:SetMultiselect(true)
	widget:SetLabel(label)
	widget:SetCallback("OnValueChanged", OnValueChanged)

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

function GUI:KeybindingButton(label, ref, key)
	local widget = CreateGUI("ClickedKeybinding")
	widget:SetLabel(label)
	widget:SetKey(ref[key])
	widget:SetCallback("OnKeyChanged", OnSerialize)

	widgets[widget] = {
		setValueFunc = widget.SetKey,
		ref = ref,
		key = key
	}

	return widget
end

function GUI:TabGroup(items, handler)
	local function OnGroupSelected(container, event, group)
		container:ReleaseChildren()
		handler(container, event, group)
	end

	local widget = CreateGUI("TabGroup")
	widget:SetFullWidth(true)
	widget:SetFullHeight(true)
	widget:SetLayout("Fill")
	widget:SetTabs(items)
	widget:SetCallback("OnGroupSelected", OnGroupSelected)

	return widget
end

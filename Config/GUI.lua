local AceGUI = LibStub("AceGUI-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Clicked")

-- Create a namespace for GUI functions
local GUI = Clicked.GUI or {}
Clicked.GUI = GUI

GUI.EVENT_UPDATE = "CLICKED_GUI_UPDATE"

local widgets = {}

local function OnSerialize(frame, event, value)
	local data = widgets[frame]

	if InCombatLockdown() then
		data.setValueFunc(frame, data.ref[data.key])
		print(L["MSG_BINDING_UI_READ_ONLY_MODE"])
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

function GUI:TrimString(str)
	str = str or ""
	return string.gsub(str, "^%s*(.-)%s*$", "%1")
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
		value = self:TrimString(value)
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

function GUI:Dropdown(label, items, order, itemType, ref, key)
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

function GUI:MultiselectDropdown(label, items, order, itemType, ref, key)
	local function OnValueChanged(frame, event, value, state)
		local total = {}

		for _, item in frame.pullout:IterateItems() do
			if item.GetValue and item:GetValue() then
				table.insert(total, item.userdata.value)
			end
		end

		OnSerialize(frame, event, total)
	end

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

function GUI:InlineGroup(title)
	local widget = AceGUI:Create("InlineGroup")
	widget:SetFullWidth(true)
	widget:SetLayout("Flow")

	if title then
		widget:SetTitle(title)
	end

	return widget
end
